create table public.daily_stats (
  id bigserial not null,
  profile_id uuid not null,
  date date not null default CURRENT_DATE,
  swipe_count integer null default 0,
  super_like_count integer null default 0,
  rewind_count integer null default 0,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  constraint daily_stats_pkey primary key (id),
  constraint daily_stats_profile_id_fkey foreign KEY (profile_id) references profiles (id) on delete CASCADE
) TABLESPACE pg_default;

create unique INDEX IF not exists idx_daily_stats_profile_date on public.daily_stats using btree (profile_id, date) TABLESPACE pg_default;

create index IF not exists idx_daily_stats_date on public.daily_stats using btree (date) TABLESPACE pg_default;

create table public.interest_chips (
  id uuid not null default gen_random_uuid (),
  section text not null,
  label text not null,
  is_active boolean not null default true,
  constraint interest_chips_pkey primary key (id),
  constraint uq_interest unique (section, label)
) TABLESPACE pg_default;

create table public.lifestyle_categories (
  id smallserial not null,
  key text not null,
  is_multiselect boolean not null default false,
  constraint lifestyle_categories_pkey primary key (id),
  constraint lifestyle_categories_key_key unique (key)
) TABLESPACE pg_default;

create table public.lifestyle_chips (
  id uuid not null default gen_random_uuid (),
  category_id smallint not null,
  label text not null,
  is_active boolean not null default true,
  constraint lifestyle_chips_pkey primary key (id),
  constraint uq_lifestyle unique (category_id, label),
  constraint lifestyle_chips_category_id_fkey foreign KEY (category_id) references lifestyle_categories (id) on delete RESTRICT
) TABLESPACE pg_default;

create table public.profile_interest_chips (
  profile_id uuid not null,
  chip_id uuid not null,
  created_at timestamp with time zone not null default now(),
  constraint profile_interest_chips_pkey primary key (profile_id, chip_id),
  constraint profile_interest_chips_chip_id_fkey foreign KEY (chip_id) references interest_chips (id) on delete RESTRICT,
  constraint profile_interest_chips_profile_id_fkey foreign KEY (profile_id) references profiles (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_profile_interest_profile on public.profile_interest_chips using btree (profile_id) TABLESPACE pg_default;

create index IF not exists idx_profile_interest_chip on public.profile_interest_chips using btree (chip_id) TABLESPACE pg_default;

create table public.profile_lifestyle_chips (
  profile_id uuid not null,
  chip_id uuid not null,
  created_at timestamp with time zone not null default now(),
  constraint profile_lifestyle_chips_pkey primary key (profile_id, chip_id),
  constraint profile_lifestyle_chips_chip_id_fkey foreign KEY (chip_id) references lifestyle_chips (id) on delete RESTRICT,
  constraint profile_lifestyle_chips_profile_id_fkey foreign KEY (profile_id) references profiles (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_profile_lifestyle_profile on public.profile_lifestyle_chips using btree (profile_id) TABLESPACE pg_default;

create index IF not exists idx_profile_lifestyle_chip on public.profile_lifestyle_chips using btree (chip_id) TABLESPACE pg_default;

create table public.profile_prompts (
  id uuid not null default gen_random_uuid (),
  profile_id uuid not null,
  prompt_template_id uuid not null,
  user_response text not null,
  prompt_display_order integer null default 1,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  constraint profile_prompts_pkey primary key (id),
  constraint profile_prompts_profile_id_fkey foreign KEY (profile_id) references profiles (id) on delete CASCADE,
  constraint profile_prompts_prompt_template_id_fkey foreign KEY (prompt_template_id) references prompt_templates (id),
  constraint profile_prompts_display_order_chk check (
    (
      (prompt_display_order >= 1)
      and (prompt_display_order <= 3)
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_profile_prompts_profile_id on public.profile_prompts using btree (profile_id) TABLESPACE pg_default;

create unique INDEX IF not exists uq_profile_prompt_template on public.profile_prompts using btree (profile_id, prompt_template_id) TABLESPACE pg_default;

create unique INDEX IF not exists uq_profile_prompt_order on public.profile_prompts using btree (profile_id, prompt_display_order) TABLESPACE pg_default;

create table public.profiles (
  id uuid not null default gen_random_uuid (),
  user_id uuid not null,
  display_name character varying(100) null,
  bio text null,
  birth_date date null,
  gender public.gender_enum null,
  location_geom geography null,
  city character varying(100) null,
  state character varying(100) null,
  country character varying(50) null default 'IN'::character varying,
  trust_score integer null default 0,
  is_verified boolean null default false,
  verification_level public.verification_level null default 'unverified'::verification_level,
  profile_completeness integer null default 0,
  last_active timestamp with time zone null default CURRENT_TIMESTAMP,
  is_active boolean null default true,
  is_deleted boolean null default false,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  updated_at timestamp with time zone null default CURRENT_TIMESTAMP,
  onboarding_status character varying(20) null default 'in_progress'::character varying,
  steps_progress jsonb null default '{}'::jsonb,
  languages_known text[] null default array['en'::text],
  passport_location_geom geography null,
  selected_lifestyle_ids uuid[] null default '{}'::uuid[],
  selected_interest_ids uuid[] null default '{}'::uuid[],
  constraint profiles_pkey primary key (id),
  constraint profiles_user_id_key unique (user_id),
  constraint profiles_user_id_fkey foreign KEY (user_id) references auth.users (id) on delete CASCADE,
  constraint profiles_trust_score_check check (
    (
      (trust_score >= 0)
      and (trust_score <= 100)
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_profiles_location on public.profiles using gist (location_geom) TABLESPACE pg_default;

create index IF not exists idx_profiles_user_id on public.profiles using btree (user_id) TABLESPACE pg_default;

create index IF not exists idx_profiles_city_state on public.profiles using btree (city, state) TABLESPACE pg_default;

create index IF not exists idx_profiles_is_verified on public.profiles using btree (is_verified) TABLESPACE pg_default
where
  (is_active = true);

create index IF not exists idx_profiles_trust_score on public.profiles using btree (trust_score desc) TABLESPACE pg_default
where
  (is_active = true);

create index IF not exists idx_profiles_last_active on public.profiles using btree (last_active desc) TABLESPACE pg_default;

create index IF not exists idx_profiles_created_at on public.profiles using btree (created_at desc) TABLESPACE pg_default;

create index IF not exists idx_profiles_passport_location on public.profiles using gist (passport_location_geom) TABLESPACE pg_default;

create index IF not exists idx_profiles_lifestyle_ids on public.profiles using gin (selected_lifestyle_ids) TABLESPACE pg_default;

create index IF not exists idx_profiles_interest_ids on public.profiles using gin (selected_interest_ids) TABLESPACE pg_default;

create trigger profiles_completeness_trigger BEFORE
update on profiles for EACH row
execute FUNCTION calculate_profile_completeness ();

create table public.prompt_categories (
  id smallserial not null,
  key text not null,
  display_name text not null,
  is_active boolean not null default true,
  created_at timestamp with time zone not null default now(),
  constraint prompt_categories_pkey primary key (id),
  constraint prompt_categories_key_key unique (key)
) TABLESPACE pg_default;

create table public.prompt_templates (
  id uuid not null default gen_random_uuid (),
  prompt_text text not null,
  language character varying(10) not null,
  is_active boolean null default true,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  category_id smallint not null,
  constraint prompt_templates_pkey primary key (id),
  constraint prompt_templates_category_id_fkey foreign KEY (category_id) references prompt_categories (id) on delete RESTRICT
) TABLESPACE pg_default;

create index IF not exists idx_prompt_templates_category_id on public.prompt_templates using btree (category_id) TABLESPACE pg_default;

create index IF not exists idx_prompt_templates_language on public.prompt_templates using btree (language) TABLESPACE pg_default;

create unique INDEX IF not exists uq_prompt_templates_lang_text on public.prompt_templates using btree (language, prompt_text) TABLESPACE pg_default;

create table public.swipes (
  id bigserial not null,
  actor_id uuid not null,
  target_id uuid not null,
  action_type public.swipe_action_enum not null,
  device_fingerprint character varying(255) null default null::character varying,
  ip_address_hash character varying(255) null default null::character varying,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  constraint swipes_pkey primary key (id),
  constraint unique_swipe_per_actor_target unique (actor_id, target_id),
  constraint swipes_actor_id_fkey foreign KEY (actor_id) references profiles (id) on delete CASCADE,
  constraint swipes_target_id_fkey foreign KEY (target_id) references profiles (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_swipes_actor_target on public.swipes using btree (actor_id, target_id) TABLESPACE pg_default;

create index IF not exists idx_swipes_actor_created_at on public.swipes using btree (actor_id, created_at desc) TABLESPACE pg_default;

create index IF not exists idx_swipes_target_created_at on public.swipes using btree (target_id, created_at desc) TABLESPACE pg_default;

create index IF not exists idx_swipes_action_type on public.swipes using btree (action_type) TABLESPACE pg_default;

create table public.user_media (
  id uuid not null default gen_random_uuid (),
  profile_id uuid not null,
  media_url text not null,
  media_type character varying(20) not null,
  display_order integer not null,
  is_primary boolean null default false,
  is_deleted boolean null default false,
  file_size_bytes integer not null,
  dimensions_width integer null,
  dimensions_height integer null,
  moderation_status public.moderation_status null default 'pending'::moderation_status,
  moderation_reason public.moderation_reason_enum null,
  ai_labels jsonb null default '{}'::jsonb,
  ai_confidence_score numeric(3, 2) null,
  nsfw_detected boolean null default false,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  updated_at timestamp with time zone null default CURRENT_TIMESTAMP,
  approved_at timestamp with time zone null,
  duration_seconds integer null,
  mime_type text null,
  constraint user_media_pkey primary key (id),
  constraint user_media_profile_id_fkey foreign KEY (profile_id) references profiles (id) on delete CASCADE,
  constraint user_media_media_type_check check (
    (
      (media_type)::text = any (
        array[
          'photo'::text,
          'video_intro'::text,
          'voice_intro'::text
        ]
      )
    )
  ),
  constraint user_media_voice_intro_duration_check check (
    (
      ((media_type)::text <> 'voice_intro'::text)
      or (
        (duration_seconds is not null)
        and (
          (duration_seconds >= 1)
          and (duration_seconds <= 60)
        )
      )
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_user_media_profile_id on public.user_media using btree (profile_id) TABLESPACE pg_default;

create index IF not exists idx_user_media_status on public.user_media using btree (moderation_status) TABLESPACE pg_default
where
  (
    moderation_status = any (
      array[
        'pending'::moderation_status,
        'appeal'::moderation_status
      ]
    )
  );

create index IF not exists idx_user_media_nsfw on public.user_media using btree (nsfw_detected) TABLESPACE pg_default
where
  (nsfw_detected = true);

create index IF not exists idx_user_media_display_order on public.user_media using btree (profile_id, display_order) TABLESPACE pg_default;

create table public.verifications (
  id uuid not null default gen_random_uuid (),
  profile_id uuid not null,
  verification_type public.verification_type not null,
  provider character varying(50) null default 'aws_rekognition'::character varying,
  attempt_number integer not null,
  status public.verification_status not null,
  failure_reason text null,
  provider_request_id character varying(255) null,
  provider_response jsonb null,
  confidence_score numeric(3, 2) null,
  selfie_video_url text null,
  id_document_url text null,
  review_notes text null,
  reviewed_by_admin_id uuid null,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  updated_at timestamp with time zone null default CURRENT_TIMESTAMP,
  verified_at timestamp with time zone null,
  constraint verifications_pkey primary key (id),
  constraint verifications_profile_id_fkey foreign KEY (profile_id) references profiles (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_verifications_profile_id on public.verifications using btree (profile_id) TABLESPACE pg_default;

create index IF not exists idx_verifications_status on public.verifications using btree (status) TABLESPACE pg_default;

create index IF not exists idx_verifications_type_status on public.verifications using btree (verification_type, status) TABLESPACE pg_default;

create index IF not exists idx_verifications_created_at on public.verifications using btree (created_at desc) TABLESPACE pg_default;

