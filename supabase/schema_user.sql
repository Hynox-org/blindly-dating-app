-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.calls (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  caller_id uuid NOT NULL,
  receiver_id uuid NOT NULL,
  channel_name text NOT NULL,
  call_type text NOT NULL CHECK (call_type = ANY (ARRAY['audio'::text, 'video'::text])),
  status text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  agora_token text,
  caller_uid integer,
  CONSTRAINT calls_pkey PRIMARY KEY (id),
  CONSTRAINT calls_caller_id_fkey FOREIGN KEY (caller_id) REFERENCES public.profiles(id),
  CONSTRAINT calls_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.connected_accounts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL,
  provider character varying NOT NULL,
  provider_user_id character varying,
  display_handle character varying,
  is_connected boolean NOT NULL DEFAULT true,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT connected_accounts_pkey PRIMARY KEY (id),
  CONSTRAINT connected_accounts_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.daily_discovery_matches (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  profile_mode_id uuid NOT NULL UNIQUE,
  feed_data jsonb NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT daily_discovery_matches_pkey PRIMARY KEY (id),
  CONSTRAINT daily_discovery_matches_profile_mode_id_fkey FOREIGN KEY (profile_mode_id) REFERENCES public.profile_modes(id)
);
CREATE TABLE public.daily_stats (
  id bigint NOT NULL DEFAULT nextval('daily_stats_id_seq'::regclass),
  profile_id uuid NOT NULL,
  date date NOT NULL DEFAULT CURRENT_DATE,
  swipe_count integer DEFAULT 0,
  super_like_count integer DEFAULT 0,
  rewind_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT daily_stats_pkey PRIMARY KEY (id),
  CONSTRAINT daily_stats_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.interest_chips (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  section text NOT NULL,
  label text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  CONSTRAINT interest_chips_pkey PRIMARY KEY (id)
);
CREATE TABLE public.lifestyle_categories (
  id smallint NOT NULL DEFAULT nextval('lifestyle_categories_id_seq'::regclass),
  key text NOT NULL UNIQUE,
  is_multiselect boolean NOT NULL DEFAULT false,
  CONSTRAINT lifestyle_categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.lifestyle_chips (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  category_id smallint NOT NULL,
  label text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  CONSTRAINT lifestyle_chips_pkey PRIMARY KEY (id),
  CONSTRAINT lifestyle_chips_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.lifestyle_categories(id)
);
CREATE TABLE public.match_blocks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_a_id uuid NOT NULL,
  user_b_id uuid NOT NULL,
  reason text DEFAULT 'unmatched'::text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT match_blocks_pkey PRIMARY KEY (id),
  CONSTRAINT match_blocks_user_a_id_fkey FOREIGN KEY (user_a_id) REFERENCES auth.users(id),
  CONSTRAINT match_blocks_user_b_id_fkey FOREIGN KEY (user_b_id) REFERENCES auth.users(id)
);
CREATE TABLE public.matches (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_a_id uuid NOT NULL,
  user_b_id uuid NOT NULL,
  status USER-DEFINED NOT NULL DEFAULT 'active'::match_status_enum CHECK (status::text = ANY (ARRAY['active'::character varying, 'expired'::character varying, 'blocked'::character varying]::text[])),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  expires_at timestamp with time zone NOT NULL,
  extended_count integer NOT NULL DEFAULT 0,
  extended_until timestamp with time zone,
  unmatched_by_user_id uuid,
  unmatched_at timestamp with time zone,
  extension_count integer DEFAULT 0,
  chat_started boolean DEFAULT false,
  chat_started_at timestamp with time zone,
  matched_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  last_message text,
  last_message_at timestamp with time zone,
  CONSTRAINT matches_pkey PRIMARY KEY (id),
  CONSTRAINT matches_unmatched_by_user_id_fkey FOREIGN KEY (unmatched_by_user_id) REFERENCES public.profiles(id),
  CONSTRAINT matches_user_a_id_fkey FOREIGN KEY (user_a_id) REFERENCES public.profiles(id),
  CONSTRAINT matches_user_b_id_fkey FOREIGN KEY (user_b_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  match_id uuid NOT NULL,
  sender_profile_id uuid NOT NULL,
  receiver_profile_id uuid NOT NULL,
  content text NOT NULL,
  message_type text DEFAULT 'text'::text CHECK (message_type = ANY (ARRAY['text'::text, 'image'::text, 'voice'::text, 'video'::text])),
  voice_duration integer,
  created_at timestamp with time zone DEFAULT now(),
  delivered_at timestamp with time zone,
  read_at timestamp with time zone,
  is_read boolean DEFAULT false,
  reply_to_id uuid,
  reaction text,
  edited_at timestamp with time zone,
  deleted_for_sender boolean DEFAULT false,
  deleted_for_receiver boolean DEFAULT false,
  deleted_for_everyone boolean DEFAULT false,
  CONSTRAINT messages_pkey PRIMARY KEY (id),
  CONSTRAINT messages_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id),
  CONSTRAINT messages_sender_profile_id_fkey FOREIGN KEY (sender_profile_id) REFERENCES public.profiles(id),
  CONSTRAINT messages_receiver_profile_id_fkey FOREIGN KEY (receiver_profile_id) REFERENCES public.profiles(id),
  CONSTRAINT messages_reply_to_id_fkey FOREIGN KEY (reply_to_id) REFERENCES public.messages(id)
);
CREATE TABLE public.onboarding_steps (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  step_key text NOT NULL UNIQUE,
  step_name text NOT NULL,
  step_position integer NOT NULL,
  is_mandatory boolean DEFAULT false,
  step_type text NOT NULL,
  estimated_time_seconds integer DEFAULT 30,
  max_skips_allowed integer DEFAULT 0,
  is_parallel boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT onboarding_steps_pkey PRIMARY KEY (id)
);
CREATE TABLE public.otp_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  phone text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT otp_logs_pkey PRIMARY KEY (id)
);
CREATE TABLE public.profile_languages (
  profile_id uuid NOT NULL,
  language_code character varying NOT NULL,
  proficiency character varying,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT profile_languages_pkey PRIMARY KEY (profile_id, language_code),
  CONSTRAINT profile_languages_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.profile_mode_interestchips (
  profile_mode_id uuid NOT NULL,
  chip_id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT profile_mode_interestchips_pkey PRIMARY KEY (profile_mode_id, chip_id),
  CONSTRAINT profile_mode_interestchips_profile_mode_id_fkey FOREIGN KEY (profile_mode_id) REFERENCES public.profile_modes(id),
  CONSTRAINT profile_mode_interestchips_chip_id_fkey FOREIGN KEY (chip_id) REFERENCES public.interest_chips(id)
);
CREATE TABLE public.profile_mode_lifestylechips (
  profile_mode_id uuid NOT NULL,
  chip_id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT profile_mode_lifestylechips_pkey PRIMARY KEY (profile_mode_id, chip_id),
  CONSTRAINT profile_mode_lifestylechips_profile_mode_id_fkey FOREIGN KEY (profile_mode_id) REFERENCES public.profile_modes(id),
  CONSTRAINT profile_mode_lifestylechips_chip_id_fkey FOREIGN KEY (chip_id) REFERENCES public.lifestyle_chips(id)
);
CREATE TABLE public.profile_mode_media (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_mode_id uuid NOT NULL,
  media_url text NOT NULL,
  media_type character varying NOT NULL CHECK (media_type::text = ANY (ARRAY['photo'::character varying, 'video'::character varying, 'voice_intro'::character varying, 'selfie'::character varying, 'gov_id'::character varying]::text[])),
  display_order smallint NOT NULL,
  is_primary boolean NOT NULL DEFAULT false,
  moderation_status USER-DEFINED NOT NULL DEFAULT 'pending'::moderation_status,
  moderation_reason USER-DEFINED,
  is_deleted boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  duration_seconds integer,
  CONSTRAINT profile_mode_media_pkey PRIMARY KEY (id),
  CONSTRAINT profile_mode_media_profile_mode_id_fkey FOREIGN KEY (profile_mode_id) REFERENCES public.profile_modes(id)
);
CREATE TABLE public.profile_mode_prompts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_mode_id uuid NOT NULL,
  prompt_template_id uuid NOT NULL,
  user_response text NOT NULL,
  display_order smallint NOT NULL DEFAULT 1,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT profile_mode_prompts_pkey PRIMARY KEY (id),
  CONSTRAINT profile_mode_prompts_profile_mode_id_fkey FOREIGN KEY (profile_mode_id) REFERENCES public.profile_modes(id),
  CONSTRAINT profile_mode_prompts_prompt_template_id_fkey FOREIGN KEY (prompt_template_id) REFERENCES public.prompt_templates(id)
);
CREATE TABLE public.profile_modes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL,
  mode USER-DEFINED NOT NULL,
  bio text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  discovery_last_refreshed_at timestamp with time zone,
  discovery_seen_profiles ARRAY DEFAULT '{}'::uuid[],
  CONSTRAINT profile_modes_pkey PRIMARY KEY (id),
  CONSTRAINT profile_modes_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.profile_prompts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL,
  prompt_template_id uuid NOT NULL,
  user_response text NOT NULL,
  prompt_display_order integer DEFAULT 1 CHECK (prompt_display_order >= 1 AND prompt_display_order <= 3),
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT profile_prompts_pkey PRIMARY KEY (id),
  CONSTRAINT profile_prompts_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id),
  CONSTRAINT profile_prompts_prompt_template_id_fkey FOREIGN KEY (prompt_template_id) REFERENCES public.prompt_templates(id)
);
CREATE TABLE public.profile_views (
  id bigint NOT NULL DEFAULT nextval('profile_views_id_seq'::regclass),
  viewer_profile_id uuid NOT NULL,
  viewed_profile_id uuid NOT NULL,
  view_duration_seconds integer,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT profile_views_pkey PRIMARY KEY (id),
  CONSTRAINT profile_views_viewed_profile_id_fkey FOREIGN KEY (viewed_profile_id) REFERENCES public.profiles(id),
  CONSTRAINT profile_views_viewer_profile_id_fkey FOREIGN KEY (viewer_profile_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.profile_visibility (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL UNIQUE,
  visibility_setting USER-DEFINED DEFAULT 'everyone'::visibility_enum,
  show_exact_distance boolean DEFAULT false,
  show_last_active boolean DEFAULT false,
  incognito_mode boolean DEFAULT false,
  incognito_hidden_user_ids ARRAY DEFAULT '{}'::uuid[],
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT profile_visibility_pkey PRIMARY KEY (id),
  CONSTRAINT profile_visibility_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  display_name character varying,
  birth_date date,
  gender USER-DEFINED,
  location_geom USER-DEFINED,
  city character varying,
  state character varying,
  country character varying DEFAULT 'IN'::character varying,
  trust_score integer DEFAULT 0 CHECK (trust_score >= 0 AND trust_score <= 100),
  is_verified boolean DEFAULT false,
  verification_level USER-DEFINED DEFAULT 'unverified'::verification_level,
  profile_completeness integer DEFAULT 0,
  last_active timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  is_active boolean DEFAULT true,
  is_deleted boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  onboarding_status character varying DEFAULT 'in_progress'::character varying,
  steps_progress jsonb DEFAULT '{}'::jsonb,
  passport_location_geom USER-DEFINED,
  pronouns USER-DEFINED DEFAULT 'prefer_not'::pronouns_enum,
  hometown_city character varying,
  hometown_state character varying,
  height_cm smallint CHECK (height_cm IS NULL OR height_cm >= 120 AND height_cm <= 230),
  work_title character varying,
  work_company character varying,
  education_school character varying,
  education_level character varying,
  politics character varying,
  religion character varying,
  star_sign character varying,
  kids_preference character varying,
  have_kids boolean DEFAULT false,
  drinking character varying,
  smoking character varying,
  exercise character varying,
  current_mode text NOT NULL DEFAULT 'date'::text,
  relationship_type character varying,
  sexual_orientation character varying,
  languages ARRAY,
  causes_communities ARRAY,
  qualities ARRAY,
  educated_at text,
  graduation_year integer,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.prompt_categories (
  id smallint NOT NULL DEFAULT nextval('prompt_categories_id_seq'::regclass),
  key text NOT NULL UNIQUE,
  display_name text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT prompt_categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.prompt_templates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  prompt_text text NOT NULL,
  language character varying NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  category_id smallint NOT NULL,
  CONSTRAINT prompt_templates_pkey PRIMARY KEY (id),
  CONSTRAINT prompt_templates_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.prompt_categories(id)
);
CREATE TABLE public.safety_flags (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  flag_type text NOT NULL,
  confidence_score double precision DEFAULT 0.0,
  details jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT safety_flags_pkey PRIMARY KEY (id),
  CONSTRAINT safety_flags_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.swipes (
  id bigint NOT NULL DEFAULT nextval('swipes_id_seq'::regclass),
  actor_id uuid NOT NULL,
  target_id uuid NOT NULL,
  action_type USER-DEFINED NOT NULL,
  device_fingerprint character varying DEFAULT NULL::character varying,
  ip_address_hash character varying DEFAULT NULL::character varying,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  resolution USER-DEFINED DEFAULT 'pending'::swipe_resolution_enum,
  CONSTRAINT swipes_pkey PRIMARY KEY (id),
  CONSTRAINT swipes_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.profiles(id),
  CONSTRAINT swipes_target_id_fkey FOREIGN KEY (target_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.user_media (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL,
  media_url text NOT NULL,
  media_type character varying NOT NULL CHECK (media_type::text = ANY (ARRAY['photo'::text, 'video_intro'::text, 'voice_intro'::text])),
  display_order integer NOT NULL,
  is_primary boolean DEFAULT false,
  is_deleted boolean DEFAULT false,
  file_size_bytes integer NOT NULL,
  dimensions_width integer,
  dimensions_height integer,
  moderation_status USER-DEFINED DEFAULT 'pending'::moderation_status,
  moderation_reason USER-DEFINED,
  ai_labels jsonb DEFAULT '{}'::jsonb,
  ai_confidence_score numeric,
  nsfw_detected boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  approved_at timestamp with time zone,
  duration_seconds integer,
  mime_type text,
  CONSTRAINT user_media_pkey PRIMARY KEY (id),
  CONSTRAINT user_media_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.veriff_verifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL,
  veriff_session_id text NOT NULL,
  session_url text NOT NULL,
  status text DEFAULT 'created'::text,
  fail_reason text,
  risk_score numeric DEFAULT 0,
  attempt_count integer DEFAULT 1,
  meta_payload jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT veriff_verifications_pkey PRIMARY KEY (id),
  CONSTRAINT veriff_verifications_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.verifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL,
  verification_type USER-DEFINED NOT NULL,
  provider character varying DEFAULT 'aws_rekognition'::character varying,
  attempt_number integer NOT NULL,
  status USER-DEFINED NOT NULL,
  failure_reason text,
  provider_request_id character varying,
  provider_response jsonb,
  confidence_score numeric,
  selfie_video_url text,
  id_document_url text,
  review_notes text,
  reviewed_by_admin_id uuid,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  verified_at timestamp with time zone,
  CONSTRAINT verifications_pkey PRIMARY KEY (id),
  CONSTRAINT verifications_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);