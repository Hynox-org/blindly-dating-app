# Supabase Sync Script (No Docker)
# This script pulls the latest TypeScript types from both Dev and Prod projects.

$supabase = Join-Path $PSScriptRoot "..\supabase_bin\supabase.exe"
$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

# Project References
$devRef = "amkznnhcqfpdmrvjtkip"
$prodRef = "icvncmawahwbpiohrcxv"

Write-Host "🚀 Starting Supabase Type Sync..." -ForegroundColor Cyan

# Ensure logged in
Write-Host "🔑 Checking login status..."
& $supabase login

# Sync Development
Write-Host "📦 Syncing Development Types ($devRef)..." -ForegroundColor Yellow
& $supabase link --project-ref $devRef
& $supabase gen types typescript --linked > (Join-Path $projectRoot "supabase\schema_dev.ts")

# Sync Production
Write-Host "📦 Syncing Production Types ($prodRef)..." -ForegroundColor Yellow
& $supabase link --project-ref $prodRef
& $supabase gen types typescript --linked > (Join-Path $projectRoot "supabase\schema_user.ts")

Write-Host "✅ Sync Complete!" -ForegroundColor Green
