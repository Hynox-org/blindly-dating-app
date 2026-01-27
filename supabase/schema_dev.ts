export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.1"
  }
  public: {
    Tables: {
      cron_debug_logs: {
        Row: {
          created_at: string | null
          id: number
          message: string | null
        }
        Insert: {
          created_at?: string | null
          id?: number
          message?: string | null
        }
        Update: {
          created_at?: string | null
          id?: number
          message?: string | null
        }
        Relationships: []
      }
      daily_stats: {
        Row: {
          created_at: string | null
          date: string
          id: number
          profile_id: string
          rewind_count: number | null
          super_like_count: number | null
          swipe_count: number | null
        }
        Insert: {
          created_at?: string | null
          date?: string
          id?: number
          profile_id: string
          rewind_count?: number | null
          super_like_count?: number | null
          swipe_count?: number | null
        }
        Update: {
          created_at?: string | null
          date?: string
          id?: number
          profile_id?: string
          rewind_count?: number | null
          super_like_count?: number | null
          swipe_count?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "daily_stats_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      interest_chips: {
        Row: {
          id: string
          is_active: boolean
          label: string
          section: string
        }
        Insert: {
          id?: string
          is_active?: boolean
          label: string
          section: string
        }
        Update: {
          id?: string
          is_active?: boolean
          label?: string
          section?: string
        }
        Relationships: []
      }
      lifestyle_categories: {
        Row: {
          id: number
          is_multiselect: boolean
          key: string
        }
        Insert: {
          id?: number
          is_multiselect?: boolean
          key: string
        }
        Update: {
          id?: number
          is_multiselect?: boolean
          key?: string
        }
        Relationships: []
      }
      lifestyle_chips: {
        Row: {
          category_id: number
          id: string
          is_active: boolean
          label: string
        }
        Insert: {
          category_id: number
          id?: string
          is_active?: boolean
          label: string
        }
        Update: {
          category_id?: number
          id?: string
          is_active?: boolean
          label?: string
        }
        Relationships: [
          {
            foreignKeyName: "lifestyle_chips_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "lifestyle_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      matches: {
        Row: {
          chat_started: boolean
          chat_started_at: string | null
          created_at: string
          ended_at: string | null
          ended_by_profile_id: string | null
          expires_at: string
          extension_count: number
          id: string
          matched_at: string
          profile_a_id: string
          profile_b_id: string
          status: Database["public"]["Enums"]["match_status_enum"]
          updated_at: string
        }
        Insert: {
          chat_started?: boolean
          chat_started_at?: string | null
          created_at?: string
          ended_at?: string | null
          ended_by_profile_id?: string | null
          expires_at: string
          extension_count?: number
          id?: string
          matched_at?: string
          profile_a_id: string
          profile_b_id: string
          status?: Database["public"]["Enums"]["match_status_enum"]
          updated_at?: string
        }
        Update: {
          chat_started?: boolean
          chat_started_at?: string | null
          created_at?: string
          ended_at?: string | null
          ended_by_profile_id?: string | null
          expires_at?: string
          extension_count?: number
          id?: string
          matched_at?: string
          profile_a_id?: string
          profile_b_id?: string
          status?: Database["public"]["Enums"]["match_status_enum"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "matches_profile_a_fkey"
            columns: ["profile_a_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "matches_profile_b_fkey"
            columns: ["profile_b_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      notifications: {
        Row: {
          actor_profile_id: string
          body: string
          created_at: string | null
          id: string
          is_read: boolean | null
          recipient_profile_id: string
          title: string
          type: string
        }
        Insert: {
          actor_profile_id: string
          body: string
          created_at?: string | null
          id?: string
          is_read?: boolean | null
          recipient_profile_id: string
          title: string
          type: string
        }
        Update: {
          actor_profile_id?: string
          body?: string
          created_at?: string | null
          id?: string
          is_read?: boolean | null
          recipient_profile_id?: string
          title?: string
          type?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_notification_actor"
            columns: ["actor_profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_notification_recipient"
            columns: ["recipient_profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      onboarding_steps: {
        Row: {
          created_at: string | null
          estimated_time_seconds: number | null
          id: string
          is_mandatory: boolean | null
          is_parallel: boolean | null
          max_skips_allowed: number | null
          step_key: string
          step_name: string
          step_position: number
          step_type: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          estimated_time_seconds?: number | null
          id?: string
          is_mandatory?: boolean | null
          is_parallel?: boolean | null
          max_skips_allowed?: number | null
          step_key: string
          step_name: string
          step_position: number
          step_type: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          estimated_time_seconds?: number | null
          id?: string
          is_mandatory?: boolean | null
          is_parallel?: boolean | null
          max_skips_allowed?: number | null
          step_key?: string
          step_name?: string
          step_position?: number
          step_type?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      otp_logs: {
        Row: {
          created_at: string | null
          id: string
          phone: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          phone: string
        }
        Update: {
          created_at?: string | null
          id?: string
          phone?: string
        }
        Relationships: []
      }
      profile_interest_chips: {
        Row: {
          chip_id: string
          created_at: string
          profile_id: string
        }
        Insert: {
          chip_id: string
          created_at?: string
          profile_id: string
        }
        Update: {
          chip_id?: string
          created_at?: string
          profile_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "profile_interest_chips_chip_id_fkey"
            columns: ["chip_id"]
            isOneToOne: false
            referencedRelation: "interest_chips"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "profile_interest_chips_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profile_lifestyle_chips: {
        Row: {
          chip_id: string
          created_at: string
          profile_id: string
        }
        Insert: {
          chip_id: string
          created_at?: string
          profile_id: string
        }
        Update: {
          chip_id?: string
          created_at?: string
          profile_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "profile_lifestyle_chips_chip_id_fkey"
            columns: ["chip_id"]
            isOneToOne: false
            referencedRelation: "lifestyle_chips"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "profile_lifestyle_chips_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profile_prompts: {
        Row: {
          created_at: string | null
          id: string
          profile_id: string
          prompt_display_order: number | null
          prompt_template_id: string
          user_response: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          profile_id: string
          prompt_display_order?: number | null
          prompt_template_id: string
          user_response: string
        }
        Update: {
          created_at?: string | null
          id?: string
          profile_id?: string
          prompt_display_order?: number | null
          prompt_template_id?: string
          user_response?: string
        }
        Relationships: [
          {
            foreignKeyName: "profile_prompts_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "profile_prompts_prompt_template_id_fkey"
            columns: ["prompt_template_id"]
            isOneToOne: false
            referencedRelation: "prompt_templates"
            referencedColumns: ["id"]
          },
        ]
      }
      profile_views: {
        Row: {
          created_at: string | null
          id: number
          view_duration_seconds: number | null
          viewed_profile_id: string
          viewer_profile_id: string
        }
        Insert: {
          created_at?: string | null
          id?: number
          view_duration_seconds?: number | null
          viewed_profile_id: string
          viewer_profile_id: string
        }
        Update: {
          created_at?: string | null
          id?: number
          view_duration_seconds?: number | null
          viewed_profile_id?: string
          viewer_profile_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "profile_views_viewed_profile_id_fkey"
            columns: ["viewed_profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "profile_views_viewer_profile_id_fkey"
            columns: ["viewer_profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profile_visibility: {
        Row: {
          id: string
          incognito_hidden_user_ids: string[] | null
          incognito_mode: boolean | null
          profile_id: string
          show_exact_distance: boolean | null
          show_last_active: boolean | null
          updated_at: string | null
          visibility_setting:
            | Database["public"]["Enums"]["visibility_enum"]
            | null
        }
        Insert: {
          id?: string
          incognito_hidden_user_ids?: string[] | null
          incognito_mode?: boolean | null
          profile_id: string
          show_exact_distance?: boolean | null
          show_last_active?: boolean | null
          updated_at?: string | null
          visibility_setting?:
            | Database["public"]["Enums"]["visibility_enum"]
            | null
        }
        Update: {
          id?: string
          incognito_hidden_user_ids?: string[] | null
          incognito_mode?: boolean | null
          profile_id?: string
          show_exact_distance?: boolean | null
          show_last_active?: boolean | null
          updated_at?: string | null
          visibility_setting?:
            | Database["public"]["Enums"]["visibility_enum"]
            | null
        }
        Relationships: [
          {
            foreignKeyName: "profile_visibility_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          bio: string | null
          birth_date: string | null
          city: string | null
          country: string | null
          created_at: string | null
          discovery_mode: Database["public"]["Enums"]["discovery_mode_enum"]
          display_name: string | null
          gender: Database["public"]["Enums"]["gender_enum"] | null
          id: string
          is_active: boolean | null
          is_deleted: boolean | null
          is_verified: boolean | null
          languages_known: string[] | null
          last_active: string | null
          location_geom: unknown
          onboarding_status: string | null
          passport_location_geom: unknown
          profile_completeness: number | null
          selected_interest_ids: string[] | null
          selected_lifestyle_ids: string[] | null
          state: string | null
          steps_progress: Json | null
          trust_score: number | null
          updated_at: string | null
          user_id: string
          verification_level:
            | Database["public"]["Enums"]["verification_level"]
            | null
        }
        Insert: {
          bio?: string | null
          birth_date?: string | null
          city?: string | null
          country?: string | null
          created_at?: string | null
          discovery_mode?: Database["public"]["Enums"]["discovery_mode_enum"]
          display_name?: string | null
          gender?: Database["public"]["Enums"]["gender_enum"] | null
          id?: string
          is_active?: boolean | null
          is_deleted?: boolean | null
          is_verified?: boolean | null
          languages_known?: string[] | null
          last_active?: string | null
          location_geom?: unknown
          onboarding_status?: string | null
          passport_location_geom?: unknown
          profile_completeness?: number | null
          selected_interest_ids?: string[] | null
          selected_lifestyle_ids?: string[] | null
          state?: string | null
          steps_progress?: Json | null
          trust_score?: number | null
          updated_at?: string | null
          user_id: string
          verification_level?:
            | Database["public"]["Enums"]["verification_level"]
            | null
        }
        Update: {
          bio?: string | null
          birth_date?: string | null
          city?: string | null
          country?: string | null
          created_at?: string | null
          discovery_mode?: Database["public"]["Enums"]["discovery_mode_enum"]
          display_name?: string | null
          gender?: Database["public"]["Enums"]["gender_enum"] | null
          id?: string
          is_active?: boolean | null
          is_deleted?: boolean | null
          is_verified?: boolean | null
          languages_known?: string[] | null
          last_active?: string | null
          location_geom?: unknown
          onboarding_status?: string | null
          passport_location_geom?: unknown
          profile_completeness?: number | null
          selected_interest_ids?: string[] | null
          selected_lifestyle_ids?: string[] | null
          state?: string | null
          steps_progress?: Json | null
          trust_score?: number | null
          updated_at?: string | null
          user_id?: string
          verification_level?:
            | Database["public"]["Enums"]["verification_level"]
            | null
        }
        Relationships: []
      }
      prompt_categories: {
        Row: {
          created_at: string
          display_name: string
          id: number
          is_active: boolean
          key: string
        }
        Insert: {
          created_at?: string
          display_name: string
          id?: number
          is_active?: boolean
          key: string
        }
        Update: {
          created_at?: string
          display_name?: string
          id?: number
          is_active?: boolean
          key?: string
        }
        Relationships: []
      }
      prompt_templates: {
        Row: {
          category_id: number
          created_at: string | null
          id: string
          is_active: boolean | null
          language: string
          prompt_text: string
        }
        Insert: {
          category_id: number
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          language: string
          prompt_text: string
        }
        Update: {
          category_id?: number
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          language?: string
          prompt_text?: string
        }
        Relationships: [
          {
            foreignKeyName: "prompt_templates_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "prompt_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      safety_flags: {
        Row: {
          confidence_score: number | null
          created_at: string | null
          details: Json | null
          flag_type: string
          id: string
          user_id: string | null
        }
        Insert: {
          confidence_score?: number | null
          created_at?: string | null
          details?: Json | null
          flag_type: string
          id?: string
          user_id?: string | null
        }
        Update: {
          confidence_score?: number | null
          created_at?: string | null
          details?: Json | null
          flag_type?: string
          id?: string
          user_id?: string | null
        }
        Relationships: []
      }
      swipes: {
        Row: {
          action_type: Database["public"]["Enums"]["swipe_action_enum"]
          actor_id: string
          created_at: string | null
          device_fingerprint: string | null
          id: number
          ip_address_hash: string | null
          resolution:
            | Database["public"]["Enums"]["swipe_resolution_enum"]
            | null
          target_id: string
        }
        Insert: {
          action_type: Database["public"]["Enums"]["swipe_action_enum"]
          actor_id: string
          created_at?: string | null
          device_fingerprint?: string | null
          id?: number
          ip_address_hash?: string | null
          resolution?:
            | Database["public"]["Enums"]["swipe_resolution_enum"]
            | null
          target_id: string
        }
        Update: {
          action_type?: Database["public"]["Enums"]["swipe_action_enum"]
          actor_id?: string
          created_at?: string | null
          device_fingerprint?: string | null
          id?: number
          ip_address_hash?: string | null
          resolution?:
            | Database["public"]["Enums"]["swipe_resolution_enum"]
            | null
          target_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "swipes_actor_id_fkey"
            columns: ["actor_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "swipes_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_media: {
        Row: {
          ai_confidence_score: number | null
          ai_labels: Json | null
          approved_at: string | null
          created_at: string | null
          dimensions_height: number | null
          dimensions_width: number | null
          display_order: number
          duration_seconds: number | null
          file_size_bytes: number
          id: string
          is_deleted: boolean | null
          is_primary: boolean | null
          media_type: string
          media_url: string
          mime_type: string | null
          moderation_reason:
            | Database["public"]["Enums"]["moderation_reason_enum"]
            | null
          moderation_status:
            | Database["public"]["Enums"]["moderation_status"]
            | null
          nsfw_detected: boolean | null
          profile_id: string
          updated_at: string | null
        }
        Insert: {
          ai_confidence_score?: number | null
          ai_labels?: Json | null
          approved_at?: string | null
          created_at?: string | null
          dimensions_height?: number | null
          dimensions_width?: number | null
          display_order: number
          duration_seconds?: number | null
          file_size_bytes: number
          id?: string
          is_deleted?: boolean | null
          is_primary?: boolean | null
          media_type: string
          media_url: string
          mime_type?: string | null
          moderation_reason?:
            | Database["public"]["Enums"]["moderation_reason_enum"]
            | null
          moderation_status?:
            | Database["public"]["Enums"]["moderation_status"]
            | null
          nsfw_detected?: boolean | null
          profile_id: string
          updated_at?: string | null
        }
        Update: {
          ai_confidence_score?: number | null
          ai_labels?: Json | null
          approved_at?: string | null
          created_at?: string | null
          dimensions_height?: number | null
          dimensions_width?: number | null
          display_order?: number
          duration_seconds?: number | null
          file_size_bytes?: number
          id?: string
          is_deleted?: boolean | null
          is_primary?: boolean | null
          media_type?: string
          media_url?: string
          mime_type?: string | null
          moderation_reason?:
            | Database["public"]["Enums"]["moderation_reason_enum"]
            | null
          moderation_status?:
            | Database["public"]["Enums"]["moderation_status"]
            | null
          nsfw_detected?: boolean | null
          profile_id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "user_media_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_push_tokens: {
        Row: {
          created_at: string | null
          device_platform: string
          fcm_token: string
          id: string
          profile_id: string
        }
        Insert: {
          created_at?: string | null
          device_platform: string
          fcm_token: string
          id?: string
          profile_id: string
        }
        Update: {
          created_at?: string | null
          device_platform?: string
          fcm_token?: string
          id?: string
          profile_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_push_profile"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      verifications: {
        Row: {
          attempt_number: number
          confidence_score: number | null
          created_at: string | null
          failure_reason: string | null
          id: string
          id_document_url: string | null
          profile_id: string
          provider: string | null
          provider_request_id: string | null
          provider_response: Json | null
          review_notes: string | null
          reviewed_by_admin_id: string | null
          selfie_video_url: string | null
          status: Database["public"]["Enums"]["verification_status"]
          updated_at: string | null
          verification_type: Database["public"]["Enums"]["verification_type"]
          verified_at: string | null
        }
        Insert: {
          attempt_number: number
          confidence_score?: number | null
          created_at?: string | null
          failure_reason?: string | null
          id?: string
          id_document_url?: string | null
          profile_id: string
          provider?: string | null
          provider_request_id?: string | null
          provider_response?: Json | null
          review_notes?: string | null
          reviewed_by_admin_id?: string | null
          selfie_video_url?: string | null
          status: Database["public"]["Enums"]["verification_status"]
          updated_at?: string | null
          verification_type: Database["public"]["Enums"]["verification_type"]
          verified_at?: string | null
        }
        Update: {
          attempt_number?: number
          confidence_score?: number | null
          created_at?: string | null
          failure_reason?: string | null
          id?: string
          id_document_url?: string | null
          profile_id?: string
          provider?: string | null
          provider_request_id?: string | null
          provider_response?: Json | null
          review_notes?: string | null
          reviewed_by_admin_id?: string | null
          selfie_video_url?: string | null
          status?: Database["public"]["Enums"]["verification_status"]
          updated_at?: string | null
          verification_type?: Database["public"]["Enums"]["verification_type"]
          verified_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "verifications_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      create_match: { Args: { p_other_profile_id: string }; Returns: string }
      delete_user_account: { Args: never; Returns: undefined }
      get_discovery_feed_debug: {
        Args: {
          p_limit: number
          p_offset: number
          p_radius_meters: number
          p_user_id: string
        }
        Returns: {
          display_name: string
          media_url: string
          profile_id: string
        }[]
      }
      get_discovery_feed_final: {
        Args: { p_limit: number; p_offset: number; p_radius_meters: number }
        Returns: {
          age: number
          bio: string
          city: string
          display_name: string
          distance_meters: number
          gender: string
          interest_match_count: number
          lifestyle_match_count: number
          match_score: number
          media_url: string
          profile_id: string
        }[]
      }
      get_likes_received: {
        Args: never
        Returns: {
          age: number
          display_name: string
          image_path: string
          liked_at: string
          profile_id: string
          total_likes: number
        }[]
      }
      get_recent_matches: {
        Args: never
        Returns: {
          display_name: string
          image_path: string
          match_id: string
          matched_at: string
          other_profile_id: string
        }[]
      }
      ignore_like: { Args: { p_from_profile_id: string }; Returns: undefined }
      random_tn_location: { Args: never; Returns: unknown }
      record_swipe_action: {
        Args: {
          p_action: Database["public"]["Enums"]["swipe_action_enum"]
          p_target_profile_id: string
        }
        Returns: undefined
      }
      undo_last_swipe: { Args: never; Returns: boolean }
      update_passport_location: {
        Args: { p_lat: number; p_long: number }
        Returns: undefined
      }
    }
    Enums: {
      admin_role: "moderator" | "senior_mod" | "admin" | "super_admin"
      attribute_category_enum:
        | "diet"
        | "religion"
        | "education"
        | "smoking"
        | "drinking"
        | "language"
        | "height"
        | "occupation"
        | "income"
        | "relationship_status"
        | "children"
      attribute_importance: "low" | "medium" | "high" | "dealbreaker"
      billing_cycle_type: "1_month" | "3_month" | "6_month" | "12_month"
      block_reason_enum:
        | "harassment"
        | "spam"
        | "catfish"
        | "offensive_behavior"
        | "other"
      challenge_status: "active" | "completed" | "claimed" | "expired"
      challenge_type: "daily" | "weekly" | "monthly"
      content_type: "profile" | "photo" | "message" | "event"
      conversation_type: "direct" | "event_group"
      discovery_mode_enum: "dating" | "bff"
      event_category:
        | "foodie"
        | "tech"
        | "outdoor"
        | "adventure"
        | "volunteer"
        | "cultural"
        | "sports"
        | "nightlife"
      event_rsvp_status:
        | "going"
        | "maybe"
        | "waitlist"
        | "checked_in"
        | "cancelled"
      export_format_type: "json" | "csv"
      export_status:
        | "requested"
        | "processing"
        | "ready"
        | "downloaded"
        | "expired"
      gender_enum: "M" | "F" | "NB" | "Prefer Not"
      icebreaker_category: "funny" | "deep" | "foodie" | "travel" | "interests"
      importance_level: "low" | "medium" | "high" | "dealbreaker"
      match_status: "active" | "expired" | "unmatched" | "blocked"
      match_status_enum:
        | "active"
        | "chat_active"
        | "expired"
        | "unmatched"
        | "blocked"
      message_type: "text" | "image" | "voice_note" | "call_log" | "emoji_only"
      metric_type:
        | "coins_earned"
        | "matches_made"
        | "events_attended"
        | "messages_sent"
      moderation_action: "warned" | "suspended" | "banned" | "false_report"
      moderation_queue_status: "pending" | "assigned" | "completed" | "appealed"
      moderation_reason_enum:
        | "nudity_detected"
        | "low_quality"
        | "face_not_visible"
        | "group_photo"
        | "logo_detected"
        | "watermark"
        | "repeated_edit"
        | "other"
      moderation_status: "pending" | "approved" | "rejected" | "appeal"
      payment_status: "pending" | "completed" | "failed" | "refunded"
      period_type: "daily" | "weekly" | "monthly"
      priority_level: "low" | "medium" | "high" | "critical"
      razorpay_payment_status:
        | "created"
        | "authorized"
        | "captured"
        | "refunded"
        | "failed"
      report_category:
        | "fake_profile"
        | "underage"
        | "harassment"
        | "spam"
        | "offensive_photo"
        | "scam"
        | "inappropriate_message"
        | "bot_behavior"
      report_status:
        | "open"
        | "investigating"
        | "resolved"
        | "dismissed"
        | "appealed"
      review_status: "unreviewed" | "confirmed" | "false_positive"
      safety_flag_type:
        | "bot_behavior"
        | "fake_profile"
        | "payment_fraud"
        | "aggressive_messaging"
        | "photo_manipulation"
        | "location_spoofing"
      swipe_action_enum: "like" | "pass" | "super_like" | "rewind"
      swipe_resolution_enum: "pending" | "matched" | "rejected" | "expired"
      verification_level: "unverified" | "liveness_only" | "full_verified"
      verification_status:
        | "pending"
        | "processing"
        | "verified"
        | "failed"
        | "manual_review"
      verification_type: "liveness" | "gov_id"
      visibility_enum: "everyone" | "verified_only" | "matches_only" | "hidden"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      admin_role: ["moderator", "senior_mod", "admin", "super_admin"],
      attribute_category_enum: [
        "diet",
        "religion",
        "education",
        "smoking",
        "drinking",
        "language",
        "height",
        "occupation",
        "income",
        "relationship_status",
        "children",
      ],
      attribute_importance: ["low", "medium", "high", "dealbreaker"],
      billing_cycle_type: ["1_month", "3_month", "6_month", "12_month"],
      block_reason_enum: [
        "harassment",
        "spam",
        "catfish",
        "offensive_behavior",
        "other",
      ],
      challenge_status: ["active", "completed", "claimed", "expired"],
      challenge_type: ["daily", "weekly", "monthly"],
      content_type: ["profile", "photo", "message", "event"],
      conversation_type: ["direct", "event_group"],
      discovery_mode_enum: ["dating", "bff"],
      event_category: [
        "foodie",
        "tech",
        "outdoor",
        "adventure",
        "volunteer",
        "cultural",
        "sports",
        "nightlife",
      ],
      event_rsvp_status: [
        "going",
        "maybe",
        "waitlist",
        "checked_in",
        "cancelled",
      ],
      export_format_type: ["json", "csv"],
      export_status: [
        "requested",
        "processing",
        "ready",
        "downloaded",
        "expired",
      ],
      gender_enum: ["M", "F", "NB", "Prefer Not"],
      icebreaker_category: ["funny", "deep", "foodie", "travel", "interests"],
      importance_level: ["low", "medium", "high", "dealbreaker"],
      match_status: ["active", "expired", "unmatched", "blocked"],
      match_status_enum: [
        "active",
        "chat_active",
        "expired",
        "unmatched",
        "blocked",
      ],
      message_type: ["text", "image", "voice_note", "call_log", "emoji_only"],
      metric_type: [
        "coins_earned",
        "matches_made",
        "events_attended",
        "messages_sent",
      ],
      moderation_action: ["warned", "suspended", "banned", "false_report"],
      moderation_queue_status: ["pending", "assigned", "completed", "appealed"],
      moderation_reason_enum: [
        "nudity_detected",
        "low_quality",
        "face_not_visible",
        "group_photo",
        "logo_detected",
        "watermark",
        "repeated_edit",
        "other",
      ],
      moderation_status: ["pending", "approved", "rejected", "appeal"],
      payment_status: ["pending", "completed", "failed", "refunded"],
      period_type: ["daily", "weekly", "monthly"],
      priority_level: ["low", "medium", "high", "critical"],
      razorpay_payment_status: [
        "created",
        "authorized",
        "captured",
        "refunded",
        "failed",
      ],
      report_category: [
        "fake_profile",
        "underage",
        "harassment",
        "spam",
        "offensive_photo",
        "scam",
        "inappropriate_message",
        "bot_behavior",
      ],
      report_status: [
        "open",
        "investigating",
        "resolved",
        "dismissed",
        "appealed",
      ],
      review_status: ["unreviewed", "confirmed", "false_positive"],
      safety_flag_type: [
        "bot_behavior",
        "fake_profile",
        "payment_fraud",
        "aggressive_messaging",
        "photo_manipulation",
        "location_spoofing",
      ],
      swipe_action_enum: ["like", "pass", "super_like", "rewind"],
      swipe_resolution_enum: ["pending", "matched", "rejected", "expired"],
      verification_level: ["unverified", "liveness_only", "full_verified"],
      verification_status: [
        "pending",
        "processing",
        "verified",
        "failed",
        "manual_review",
      ],
      verification_type: ["liveness", "gov_id"],
      visibility_enum: ["everyone", "verified_only", "matches_only", "hidden"],
    },
  },
} as const
