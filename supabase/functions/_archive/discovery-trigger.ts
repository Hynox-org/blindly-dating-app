/**
 * RETIRED 2026-08-05 — kept only because this was deployed-only code with no
 * source in the repo, and deleting the deployed copy would have destroyed the
 * only version that existed.
 *
 * Replaced by the get_discovery_categories RPC
 * (supabase/migrations/20260805150000_discovery_categories.sql).
 *
 * It never worked: get_discovery_candidates threw
 * `type "public.profile_mode_enum" does not exist` on every call, so
 * daily_discovery_matches was never written. Its category names
 * (best_match/interests/location/age/lifestyle) also did not match the ones
 * discover_screen.dart reads.
 *
 * Safe to delete this file. Nothing imports it.
 */

import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL   = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_KEY   = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const LAMBDA_API_URL = "https://up3qv5kay3atda7yunenglas3a0wktrv.lambda-url.us-east-1.on.aws/";
const LAMBDA_BATCH   = 50;

interface ModeFilters {
  minAge: number;
  maxAge: number;
  distanceLimit: number;
  genderPreference: string;
}

interface TargetData {
  profile_id: string;
  profile_mode_id: string;
  mode: string;
  birth_date: string;
  location: { lat: number; lng: number };
  interest_chips: string[];
  lifestyle_chips: string[];
  mode_filters: ModeFilters;
}

interface BatchItem {
  target: TargetData;
  candidate_ids: string[];
}

interface Categories {
  best_match: string[];
  interests: string[];
  location: string[];
  age: string[];
  lifestyle: string[];
}

interface ScoredResult {
  profile_id: string;
  profile_mode_id: string;
  mode: string;
  candidate_count: number;
  categories: Categories;
  status: "ok" | "skipped" | "error";
  reason?: string;
}

interface LambdaResponse {
  total: number;
  scored: number;
  skipped: number;
  errors: number;
  results: ScoredResult[];
}

interface ProfileModeRow {
  id: string;
  profile_id: string;
  mode: string;
}

interface RpcResult {
  mode: string;
  target: TargetData;
  candidate_ids: string[];
}

async function fetchActiveProfileModes(sb: SupabaseClient): Promise<ProfileModeRow[]> {
  const { data, error } = await sb
    .from("profile_modes")
    .select("id, profile_id, mode")
    .eq("is_active", true);

  if (error) throw new Error(`fetchActiveProfileModes failed: ${error.message}`);
  return (data ?? []) as ProfileModeRow[];
}

async function callRpc(
  sb: SupabaseClient,
  profileId: string,
  mode: string
): Promise<RpcResult | null> {
  try {
    const { data, error } = await sb.rpc("get_discovery_candidates", {
      target_profile_id: profileId,
      target_mode_input: mode,
    });

    if (error) {
      console.error(`RPC error [${profileId}/${mode}]: ${error.message}`);
      return null;
    }

    const result = Array.isArray(data) ? data[0] : data;
    if (!result || typeof result !== "object") {
      console.warn(`RPC returned empty [${profileId}/${mode}]`);
      return null;
    }

    return result as RpcResult;
  } catch (err) {
    console.error(`RPC exception [${profileId}/${mode}]: ${err}`);
    return null;
  }
}

async function callLambda(batch: BatchItem[]): Promise<LambdaResponse | null> {
  try {
    const res = await fetch(LAMBDA_API_URL.trim(), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ batch }),
    });

    if (!res.ok) {
      console.error(`Lambda HTTP ${res.status}: ${await res.text()}`);
      return null;
    }

    const outer = await res.json();
    if (outer.body && typeof outer.body === "string") return JSON.parse(outer.body) as LambdaResponse;
    if (outer.body && typeof outer.body === "object") return outer.body as LambdaResponse;
    return outer as LambdaResponse;
  } catch (err) {
    console.error(`Lambda fetch error: ${err}`);
    return null;
  }
}

async function writeFeedData(
  sb: SupabaseClient,
  profileModeId: string,
  categories: Categories
): Promise<void> {
  const { error } = await sb.from("daily_discovery_matches").upsert(
    {
      profile_mode_id: profileModeId,
      feed_data: { categories },
      created_at: new Date().toISOString(),
    },
    { onConflict: "profile_mode_id" }
  );

  if (error) throw new Error(`writeFeedData failed for ${profileModeId}: ${error.message}`);
}

async function appendSeenProfiles(
  sb: SupabaseClient,
  profileModeId: string,
  shownToday: string[]
): Promise<void> {
  if (shownToday.length === 0) return;

  const { error } = await sb.rpc("append_seen_profiles", {
    p_profile_mode_id: profileModeId,
    p_new_seen: shownToday,
  });

  if (error) throw new Error(`appendSeenProfiles failed for ${profileModeId}: ${error.message}`);
}

async function processResult(sb: SupabaseClient, result: ScoredResult): Promise<void> {
  const { profile_id, profile_mode_id, mode, categories } = result;

  await writeFeedData(sb, profile_mode_id, categories);

  const shownToday = [
    ...categories.best_match,
    ...categories.interests,
    ...categories.location,
    ...categories.age,
    ...categories.lifestyle,
  ];

  await appendSeenProfiles(sb, profile_mode_id, shownToday);

  console.log(
    `  ✓ ${profile_id} | mode=${mode} | candidates=${result.candidate_count} | shown=${shownToday.length}`
  );
}

Deno.serve(async (_req) => {
  const startedAt = new Date().toISOString();
  console.log(`[${startedAt}] Discovery trigger started`);

  try {
    const sb = createClient(SUPABASE_URL, SUPABASE_KEY);

    const profileModeRows = await fetchActiveProfileModes(sb);

    if (profileModeRows.length === 0) {
      return new Response(JSON.stringify({ message: "No active profile modes found" }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    const batchItems: BatchItem[] = [];
    let rpcFailed = 0;

    for (const row of profileModeRows) {
      const rpcResult = await callRpc(sb, row.profile_id, row.mode);

      if (!rpcResult) {
        console.warn(`RPC returned null [${row.profile_id}/${row.mode}] — skipping`);
        rpcFailed++;
        continue;
      }

      batchItems.push({
        target: rpcResult.target,
        candidate_ids: rpcResult.candidate_ids ?? [],
      });
    }

    if (batchItems.length === 0) {
      return new Response(
        JSON.stringify({ message: "No scoreable items after RPC", rpc_failed: rpcFailed }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    const lambdaBatches: BatchItem[][] = [];
    for (let i = 0; i < batchItems.length; i += LAMBDA_BATCH) {
      lambdaBatches.push(batchItems.slice(i, i + LAMBDA_BATCH));
    }

    let totalScored = 0;
    let totalSkipped = 0;
    let totalErrors = 0;
    let totalWritten = 0;
    let totalFailed = 0;

    for (let i = 0; i < lambdaBatches.length; i++) {
      const batch = lambdaBatches[i];
      const lambdaRes = await callLambda(batch);

      if (!lambdaRes) {
        totalErrors += batch.length;
        continue;
      }

      totalScored += lambdaRes.scored;
      totalSkipped += lambdaRes.skipped;
      totalErrors += lambdaRes.errors;

      for (const result of lambdaRes.results) {
        if (result.status !== "ok") continue;
        if (!result.profile_mode_id) {
          totalFailed++;
          continue;
        }

        try {
          await processResult(sb, result);
          totalWritten++;
        } catch (err) {
          console.error(`  ✗ Write failed [${result.profile_id}/${result.mode}]: ${err}`);
          totalFailed++;
        }
      }
    }

    return new Response(
      JSON.stringify({
        started_at: startedAt,
        finished_at: new Date().toISOString(),
        active_modes: profileModeRows.length,
        rpc_failed: rpcFailed,
        lambda_batches: lambdaBatches.length,
        total_scored: totalScored,
        total_skipped: totalSkipped,
        total_errors: totalErrors,
        total_written: totalWritten,
        write_failed: totalFailed,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (err) {
    console.error(`Fatal error: ${err}`);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
