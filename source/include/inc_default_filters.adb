--
-- Sets up the default filters and actions for most
-- of the WordPress hooks.
--
-- If you need to remove a default hook, this file will
-- give you the priority to use for removing the hook.
--
-- Not all of the default hooks are found in this file.
-- For instance, administration-related hooks are located in
-- wp-admin/includes/admin-filters.php.
--
-- If a hook should only be called from a specific context
-- (admin area, multisite environment…), please move it
-- to a more appropriate file instead.
--
-- @package WordPress
--

with Arrays;
with Binder;
with Hb_Common;
with Globals;

with Inc_Load;
with Inc_Plugins;
with Inc_Script_Loader;

package body Inc_Default_Filters
is

   procedure Run
   is
      use Arrays;
      use Hb_Common;
      use Inc_Load;
      use Inc_Plugins;
   begin
      -- Strip, trim, kses, special chars for string saves.
      for Filter of To_List (List => (+"pre_term_name", +"pre_comment_author_name",
                              +"pre_link_name", +"pre_link_target",
                              +"pre_link_rel", +"pre_user_display_name",
                              +"pre_user_first_name", +"pre_user_last_name",
                              +"pre_user_nickname"))
      loop
         Add_Filter (-Filter, "sanitize_text_field");
         Add_Filter (-Filter, "wp_filter_kses");
         Add_Filter (-Filter, "_wp_specialchars", 30);
      end loop;

      -- Strip, kses, special chars for string display.
      for Filter of To_List (List => (+"term_name", +"comment_author_name",
                              +"link_name", +"link_target", +"link_rel",
                              +"user_display_name", +"user_first_name",
                              +"user_last_name", +"user_nickname"))
      loop
         if Is_Admin then
            -- These are expensive. Run only on admin pages for defense in depth.
            Add_Filter (-Filter, "sanitize_text_field");
            Add_Filter (-Filter, "wp_kses_data");
         end if;
         Add_Filter (-Filter, "_wp_specialchars", 30);
      end loop;

      -- Kses only for textarea saves.
      for Filter of To_List (List => (+"pre_term_description", +"pre_link_description",
                              +"pre_link_notes", +"pre_user_description"))
      loop
         Add_Filter (-Filter, "wp_filter_kses");
      end loop;

      -- Kses only for textarea admin displays.
      if Is_Admin then
         for Filter of To_List (List => (+"term_description", +"link_description",
                                 +"link_notes", +"user_description"))
      loop
            Add_Filter (-Filter, "wp_kses_data");
         end loop;
         Add_Filter ("comment_text", "wp_kses_post");
      end if;

      -- Email saves.
      for Filter of To_List (List => (+"pre_comment_author_email",
                                      +"pre_user_email"))
      loop
         Add_Filter (-Filter, "trim");
         Add_Filter (-Filter, "sanitize_email");
         Add_Filter (-Filter, "wp_filter_kses");
      end loop;

      -- Email admin display.
      for Filter of To_List (List => (+"comment_author_email", +"user_email")) loop
         Add_Filter (-Filter, "sanitize_email");
         if Is_Admin then
            Add_Filter (-Filter, "wp_kses_data");
         end if;
      end loop;

      -- Save URL.
      for Filter of To_List (List => (
        +"pre_comment_author_url",
        +"pre_user_url",
        +"pre_link_url",
        +"pre_link_image",
        +"pre_link_rss",
        +"pre_post_guid"
        ))
      loop
         Add_Filter (-Filter, "wp_strip_all_tags");
         Add_Filter (-Filter, "sanitize_url");
         Add_Filter (-Filter, "wp_filter_kses");
      end loop;

      -- Display URL.
      for Filter of To_List (List => (+"user_url", +"link_url", +"link_image",
                                      +"link_rss", +"comment_url", +"post_guid"))
      loop
         if Is_Admin then
            Add_Filter (-Filter, "wp_strip_all_tags");
         end if;
         Add_Filter (-Filter, "esc_url");
         if Is_Admin then
            Add_Filter (-Filter, "wp_kses_data");
         end if;
      end loop;

      -- Slugs.
      Add_Filter ("pre_term_slug", "sanitize_title");
      Add_Filter ("wp_insert_post_data",
                  "_wp_customize_changeset_filter_insert_post_data", 10, 2);

      -- Keys.
      for Filter of To_List (List => (+"pre_post_type", +"pre_post_status",
                              +"pre_post_comment_status", +"pre_post_ping_status"))
      loop
         Add_Filter (-Filter, "sanitize_key");
      end loop;

      -- Mime types.
      Add_Filter ("pre_post_mime_type", "sanitize_mime_type");
      Add_Filter ("post_mime_type", "sanitize_mime_type");

      -- Meta.
      Add_Filter ("register_meta_args", "_wp_register_meta_args_allowed_list", 10, 2);

      -- Counts.
      Add_Action ("admin_init", "wp_schedule_update_user_counts");
      Add_Action ("wp_update_user_counts", "wp_schedule_update_user_counts", 10, 0);
      for Action of To_List (List => (+"user_register", +"deleted_user")) loop
         Add_Action (-Action, "wp_maybe_update_user_counts", 10, 0);
      end loop;

      -- Post meta.
      Add_Action ("added_post_meta", "wp_cache_set_posts_last_changed");
      Add_Action ("updated_post_meta", "wp_cache_set_posts_last_changed");
      Add_Action ("deleted_post_meta", "wp_cache_set_posts_last_changed");

      -- Term meta.
      Add_Action ("added_term_meta", "wp_cache_set_terms_last_changed");
      Add_Action ("updated_term_meta", "wp_cache_set_terms_last_changed");
      Add_Action ("deleted_term_meta", "wp_cache_set_terms_last_changed");
      Add_Filter ("get_term_metadata", "wp_check_term_meta_support_prefilter");
      Add_Filter ("add_term_metadata", "wp_check_term_meta_support_prefilter");
      Add_Filter ("update_term_metadata", "wp_check_term_meta_support_prefilter");
      Add_Filter ("delete_term_metadata", "wp_check_term_meta_support_prefilter");
      Add_Filter ("get_term_metadata_by_mid", "wp_check_term_meta_support_prefilter");
      Add_Filter ("update_term_metadata_by_mid",
                  "wp_check_term_meta_support_prefilter");
      Add_Filter ("delete_term_metadata_by_mid",
                  "wp_check_term_meta_support_prefilter");
      Add_Filter ("update_term_metadata_cache",
                  "wp_check_term_meta_support_prefilter");

      -- Comment meta.
      Add_Action ("added_comment_meta", "wp_cache_set_comments_last_changed");
      Add_Action ("updated_comment_meta", "wp_cache_set_comments_last_changed");
      Add_Action ("deleted_comment_meta", "wp_cache_set_comments_last_changed");

      -- Places to balance tags on input.
      for Filter of To_List (List => (+"content_save_pre", +"excerpt_save_pre",
                              +"comment_save_pre", +"pre_comment_content"))
      loop
         Add_Filter (-Filter, "convert_invalid_entities");
         Add_Filter (-Filter, "balanceTags", 50);
      end loop;

      -- Add proper rel values for links with target.
      Add_Action ("init", "wp_init_targeted_link_rel_filters");

      -- Format strings for display.
      for Filter of To_List (List => (+"comment_author", +"term_name", +"link_name",
                              +"link_description", +"link_notes", +"bloginfo",
                              +"wp_title", +"document_title", +"widget_title"))
      loop
         Add_Filter (-Filter, "wptexturize");
         Add_Filter (-Filter, "convert_chars");
         Add_Filter (-Filter, "esc_html");
      end loop;

      -- Format WordPress.
      for Filter of To_List (List => (+"the_content", +"the_title", +"wp_title",
                              +"document_title"))
      loop
         Add_Filter (-Filter, "capital_P_dangit", 11);
      end loop;
      Add_Filter ("comment_text", "capital_P_dangit", 31);

      -- Format titles.
      for Filter of To_List (List => (+"single_post_title", +"single_cat_title",
                              +"single_tag_title", +"single_month_title",
                              +"nav_menu_attr_title", +"nav_menu_description"))
      loop
         Add_Filter (-Filter, "wptexturize");
         Add_Filter (-Filter, "strip_tags");
      end loop;

      -- Format text area for display.
      for Filter of To_List (List => (+"term_description",
                              +"get_the_post_type_description"))
      loop
         Add_Filter (-Filter, "wptexturize");
         Add_Filter (-Filter, "convert_chars");
         Add_Filter (-Filter, "wpautop");
         Add_Filter (-Filter, "shortcode_unautop");
      end loop;

      -- Format for RSS.
      Add_Filter ("term_name_rss", "convert_chars");

      -- Pre save hierarchy.
      Add_Filter ("wp_insert_post_parent", "wp_check_post_hierarchy_for_loops", 10, 2);
      Add_Filter ("wp_update_term_parent", "wp_check_term_hierarchy_for_loops", 10, 3);

      -- Display filters.
      Add_Filter ("the_title", "wptexturize");
      Add_Filter ("the_title", "convert_chars");
      Add_Filter ("the_title", "trim");

      Add_Filter ("the_content", "do_blocks", 9);
      Add_Filter ("the_content", "wptexturize");
      Add_Filter ("the_content", "convert_smilies", 20);
      Add_Filter ("the_content", "wpautop");
      Add_Filter ("the_content", "shortcode_unautop");
      Add_Filter ("the_content", "prepend_attachment");
      Add_Filter ("the_content", "wp_filter_content_tags");
      Add_Filter ("the_content", "wp_replace_insecure_home_url");

      Add_Filter ("the_excerpt", "wptexturize");
      Add_Filter ("the_excerpt", "convert_smilies");
      Add_Filter ("the_excerpt", "convert_chars");
      Add_Filter ("the_excerpt", "wpautop");
      Add_Filter ("the_excerpt", "shortcode_unautop");
      Add_Filter ("the_excerpt", "wp_filter_content_tags");
      Add_Filter ("the_excerpt", "wp_replace_insecure_home_url");
      Add_Filter ("get_the_excerpt", "wp_trim_excerpt", 10, 2);

      Add_Filter ("the_post_thumbnail_caption", "wptexturize");
      Add_Filter ("the_post_thumbnail_caption", "convert_smilies");
      Add_Filter ("the_post_thumbnail_caption", "convert_chars");

      Add_Filter ("comment_text", "wptexturize");
      Add_Filter ("comment_text", "convert_chars");
      Add_Filter ("comment_text", "make_clickable", 9);
      Add_Filter ("comment_text", "force_balance_tags", 25);
      Add_Filter ("comment_text", "convert_smilies", 20);
      Add_Filter ("comment_text", "wpautop", 30);

      Add_Filter ("comment_excerpt", "convert_chars");

      Add_Filter ("list_cats", "wptexturize");

      Add_Filter ("wp_sprintf", "wp_sprintf_l", 10, 2);

      Add_Filter ("widget_text", "balanceTags");
      Add_Filter ("widget_text_content", "capital_P_dangit", 11);
      Add_Filter ("widget_text_content", "wptexturize");
      Add_Filter ("widget_text_content", "convert_smilies", 20);
      Add_Filter ("widget_text_content", "wpautop");
      Add_Filter ("widget_text_content", "shortcode_unautop");
      Add_Filter ("widget_text_content", "wp_filter_content_tags");
      Add_Filter ("widget_text_content", "wp_replace_insecure_home_url");
      Add_Filter ("widget_text_content", "do_shortcode", 11);
      -- Runs after wpautop(); note that post global will be null when shortcodes run.

      Add_Filter ("widget_block_content", "do_blocks", 9);
      Add_Filter ("widget_block_content", "wp_filter_content_tags");
      Add_Filter ("widget_block_content", "do_shortcode", 11);

      Add_Filter ("block_type_metadata", "wp_migrate_old_typography_shape");

      Add_Filter ("wp_get_custom_css", "wp_replace_insecure_home_url");

      -- RSS filters.
      Add_Filter ("the_title_rss", "strip_tags");
      Add_Filter ("the_title_rss", "ent2ncr", 8);
      Add_Filter ("the_title_rss", "esc_html");
      Add_Filter ("the_content_rss", "ent2ncr", 8);
      Add_Filter ("the_content_feed", "wp_staticize_emoji");
      Add_Filter ("the_content_feed", "_oembed_filter_feed_content");
      Add_Filter ("the_excerpt_rss", "convert_chars");
      Add_Filter ("the_excerpt_rss", "ent2ncr", 8);
      Add_Filter ("comment_author_rss", "ent2ncr", 8);
      Add_Filter ("comment_text_rss", "ent2ncr", 8);
      Add_Filter ("comment_text_rss", "esc_html");
      Add_Filter ("comment_text_rss", "wp_staticize_emoji");
      Add_Filter ("bloginfo_rss", "ent2ncr", 8);
      Add_Filter ("the_author", "ent2ncr", 8);
      Add_Filter ("the_guid", "esc_url");

      -- Email filters.
      Add_Filter ("wp_mail", "wp_staticize_emoji_for_email");

      -- Robots filters.
      Add_Filter ("wp_robots", "wp_robots_noindex");
      Add_Filter ("wp_robots", "wp_robots_noindex_embeds");
      Add_Filter ("wp_robots", "wp_robots_noindex_search");
      Add_Filter ("wp_robots", "wp_robots_max_image_preview_large");

      -- Mark site as no longer fresh.
      for Action of
         To_List (List => (
                +"publish_post",
                +"publish_page",
                +"wp_ajax_save-widget",
                +"wp_ajax_widgets-order",
                +"customize_save_after",
                +"rest_after_save_widget",
                +"rest_delete_widget",
                +"rest_save_sidebar"
         ))
      loop
         Add_Action (-Action, "_delete_option_fresh_site", 0);
      end loop;

      -- Misc filters.
      Add_Filter ("option_ping_sites", "privacy_ping_filter");
      Add_Filter ("option_blog_charset", "_wp_specialchars");
      -- IMPORTANT: This must not be wp_specialchars() or esc_html() or it"ll
      -- cause an infinite loop.
      Add_Filter ("option_blog_charset", "_canonical_charset");
      Add_Filter ("option_home", "_config_wp_home");
      Add_Filter ("option_siteurl", "_config_wp_siteurl");
      Add_Filter ("tiny_mce_before_init", "_mce_set_direction");
      Add_Filter ("teeny_mce_before_init", "_mce_set_direction");
      Add_Filter ("pre_kses", "wp_pre_kses_less_than");
      Add_Filter ("pre_kses", "wp_pre_kses_block_attributes", 10, 3);
      Add_Filter ("sanitize_title", "sanitize_title_with_dashes", 10, 3);
      Add_Action ("check_comment_flood", "check_comment_flood_db", 10, 4);
      Add_Filter ("comment_flood_filter", "wp_throttle_comment_flood", 10, 3);
      Add_Filter ("pre_comment_content", "wp_rel_ugc", 15);
      Add_Filter ("comment_email", "antispambot");
      Add_Filter ("option_tag_base", "_wp_filter_taxonomy_base");
      Add_Filter ("option_category_base", "_wp_filter_taxonomy_base");
      Add_Filter ("the_posts", "_close_comments_for_old_posts", 10, 2);
      Add_Filter ("comments_open", "_close_comments_for_old_post", 10, 2);
      Add_Filter ("pings_open", "_close_comments_for_old_post", 10, 2);
      Add_Filter ("editable_slug", "urldecode");
      Add_Filter ("editable_slug", "esc_textarea");
      Add_Filter ("pingback_ping_source_uri", "pingback_ping_source_uri");
      Add_Filter ("xmlrpc_pingback_error", "xmlrpc_pingback_error");
      Add_Filter ("title_save_pre", "trim");

      Add_Action ("transition_comment_status",
                  "_clear_modified_cache_on_transition_comment_status", 10, 2);

      Add_Filter ("http_request_host_is_external",
                  "allowed_http_request_hosts", 10, 2);

      -- REST API filters.
      Add_Action ("xmlrpc_rsd_apis", "rest_output_rsd");
      Add_Action ("wp_head", "rest_output_link_wp_head", 10, 0);
      Add_Action ("template_redirect", "rest_output_link_header", 11, 0);
      Add_Action ("auth_cookie_malformed", "rest_cookie_collect_status");
      Add_Action ("auth_cookie_expired", "rest_cookie_collect_status");
      Add_Action ("auth_cookie_bad_username", "rest_cookie_collect_status");
      Add_Action ("auth_cookie_bad_hash", "rest_cookie_collect_status");
      Add_Action ("auth_cookie_valid", "rest_cookie_collect_status");
      Add_Action ("application_password_failed_authentication",
                  "rest_application_password_collect_status");
      Add_Action ("application_password_did_authenticate",
                  "rest_application_password_collect_status", 10, 2);
      Add_Filter ("rest_authentication_errors",
                  "rest_application_password_check_errors", 90);
      Add_Filter ("rest_authentication_errors", "rest_cookie_check_errors", 100);

      -- Actions.
      Add_Action ("wp_head", "_wp_render_title_tag", 1);
      Add_Action ("wp_head", "wp_enqueue_scripts", 1);
      Add_Action ("wp_head", "wp_resource_hints", 2);
      Add_Action ("wp_head", "wp_preload_resources", 1);
      Add_Action ("wp_head", "feed_links", 2);
      Add_Action ("wp_head", "feed_links_extra", 3);
      Add_Action ("wp_head", "rsd_link");
      Add_Action ("wp_head", "wlwmanifest_link");
      Add_Action ("wp_head", "locale_stylesheet");
      Add_Action ("publish_future_post", "check_and_publish_future_post", 10, 1);
      Add_Action ("wp_head", "wp_robots", 1);
      Add_Action ("wp_head", "print_emoji_detection_script", 7);
      Add_Action ("wp_head", "wp_print_styles", 8);
      Add_Action ("wp_head", "wp_print_head_scripts", 9);
      Add_Action ("wp_head", "wp_generator");
      Add_Action ("wp_head", "rel_canonical");
      Add_Action ("wp_head", "wp_shortlink_wp_head", 10, 0);
      Add_Action ("wp_head", "wp_custom_css_cb", 101);
      Add_Action ("wp_head", "wp_site_icon", 99);
      Add_Action ("wp_footer", "wp_print_footer_scripts", 20);
      Add_Action ("template_redirect", "wp_shortlink_header", 11, 0);
      Add_Action ("wp_print_footer_scripts", "_wp_footer_scripts");
      Add_Action ("init", "_register_core_block_patterns_and_categories");
      Add_Action ("init", "check_theme_switched", 99);
--    Add_Action ("init", To_Array (("WP_Block_Supports", "init")), 22);
--    Add_Action ("switch_theme", To_Array (("WP_Theme_JSON_Resolver", "clean_cached_data")));
--    Add_Action ("start_previewing_theme", To_Array (("WP_Theme_JSON_Resolver", "clean_cached_data")));
      Add_Action ("after_switch_theme", "_wp_menus_changed");
      Add_Action ("after_switch_theme", "_wp_sidebars_changed");
      Add_Action ("wp_print_styles", "print_emoji_styles");
      Add_Action ("plugins_loaded", "_wp_theme_json_webfonts_handler");

      if Isset (Binder.XX_GET, "replytocom") then
         Add_Filter ("wp_robots", "wp_robots_no_robots");
      end if;

      -- Login actions.
      Add_Action ("login_head", "wp_robots", 1);
      Add_Filter ("login_head", "wp_resource_hints", 8);
      Add_Action ("login_head", "wp_print_head_scripts", 9);
      Add_Action ("login_head", "print_admin_styles", 9);
      Add_Action ("login_head", "wp_site_icon", 99);
      Add_Action ("login_footer", "wp_print_footer_scripts", 20);
      Add_Action ("login_init", "send_frame_options_header", 10, 0);

      -- Feed generator tags.
      for Action of To_List (List => (+"rss2_head", +"commentsrss2_head", +"rss_head",
                              +"rdf_header", +"atom_head", +"comments_atom_head",
                              +"opml_head", +"app_head"))
      loop
         Add_Action (-Action, "the_generator");
      end loop;

      -- Feed Site Icon.
      Add_Action ("atom_head", "atom_site_icon");
      Add_Action ("rss2_head", "rss2_site_icon");

      -- WP Cron.
      if not Globals.DOING_CRON then
--    if not Defined ("DOING_CRON") then
         Add_Action ("init", "wp_cron");
      end if;

      -- HTTPS detection.
      Add_Action ("init", "wp_schedule_https_detection");
      Add_Action ("wp_https_detection", "wp_update_https_detection_errors");
      Add_Filter ("cron_request", "wp_cron_conditionally_prevent_sslverify", 9999);

      -- HTTPS migration.
      Add_Action ("update_option_home", "wp_update_https_migration_required", 10, 2);

      -- 2 Actions 2 Furious.
      Add_Action ("do_feed_rdf", "do_feed_rdf", 10, 0);
      Add_Action ("do_feed_rss", "do_feed_rss", 10, 0);
      Add_Action ("do_feed_rss2", "do_feed_rss2", 10, 1);
      Add_Action ("do_feed_atom", "do_feed_atom", 10, 1);
      Add_Action ("do_pings", "do_all_pings", 10, 0);
      Add_Action ("do_all_pings", "do_all_pingbacks", 10, 0);
      Add_Action ("do_all_pings", "do_all_enclosures", 10, 0);
      Add_Action ("do_all_pings", "do_all_trackbacks", 10, 0);
      Add_Action ("do_all_pings", "generic_ping", 10, 0);
      Add_Action ("do_robots", "do_robots");
      Add_Action ("do_favicon", "do_favicon");
      Add_Action ("set_comment_cookies", "wp_set_comment_cookies", 10, 3);
      Add_Action ("sanitize_comment_cookies", "sanitize_comment_cookies");
      Add_Action ("init", "smilies_init", 5);
      Add_Action ("plugins_loaded", "wp_maybe_load_widgets", 0);
      Add_Action ("plugins_loaded", "wp_maybe_load_embeds", 0);
      Add_Action ("shutdown", "wp_ob_end_flush_all", 1);
      -- Create a revision whenever a post is updated.
      Add_Action ("post_updated", "wp_save_post_revision", 10, 1);
      Add_Action ("publish_post", "_publish_post_hook", 5, 1);
      Add_Action ("transition_post_status", "_transition_post_status", 5, 3);
      Add_Action ("transition_post_status",
                  "_update_term_count_on_transition_post_status", 10, 3);
      Add_Action ("comment_form", "wp_comment_form_unfiltered_html_nonce");

      -- Privacy.
      Add_Action ("user_request_action_confirmed",
                  "_wp_privacy_account_request_confirmed");
      Add_Action ("user_request_action_confirmed",
                  "_wp_privacy_send_request_confirmation_notification", 12);
                  -- After request marked as completed.
      Add_Filter ("wp_privacy_personal_data_exporters",
                  "wp_register_comment_personal_data_exporter");
      Add_Filter ("wp_privacy_personal_data_exporters",
                  "wp_register_media_personal_data_exporter");
      Add_Filter ("wp_privacy_personal_data_exporters",
                  "wp_register_user_personal_data_exporter", 1);
      Add_Filter ("wp_privacy_personal_data_erasers",
                  "wp_register_comment_personal_data_eraser");
      Add_Action ("init", "wp_schedule_delete_old_privacy_export_files");
      Add_Action ("wp_privacy_delete_old_export_files",
                  "wp_privacy_delete_old_export_files");

      -- Cron tasks.
      Add_Action ("wp_scheduled_delete", "wp_scheduled_delete");
      Add_Action ("wp_scheduled_auto_draft_delete", "wp_delete_auto_drafts");
      Add_Action ("importer_scheduled_cleanup", "wp_delete_attachment");
      Add_Action ("upgrader_scheduled_cleanup", "wp_delete_attachment");
      Add_Action ("delete_expired_transients", "delete_expired_transients");

      -- Navigation menu actions.
      Add_Action ("delete_post", "_wp_delete_post_menu_item");
      Add_Action ("delete_term", "_wp_delete_tax_menu_item", 10, 3);
      Add_Action ("transition_post_status", "_wp_auto_add_pages_to_menu", 10, 3);
      Add_Action ("delete_post",
                  "_wp_delete_customize_changeset_dependent_auto_drafts");

      -- Post Thumbnail CSS class filtering.
      Add_Action ("begin_fetch_post_thumbnail_html",
                  "_wp_post_thumbnail_class_filter_add");
      Add_Action ("end_fetch_post_thumbnail_html",
                  "_wp_post_thumbnail_class_filter_remove");

      -- Redirect old slugs.
      Add_Action ("template_redirect", "wp_old_slug_redirect");
      Add_Action ("post_updated", "wp_check_for_changed_slugs", 12, 3);
      Add_Action ("attachment_updated", "wp_check_for_changed_slugs", 12, 3);

      -- Redirect old dates.
      Add_Action ("post_updated", "wp_check_for_changed_dates", 12, 3);
      Add_Action ("attachment_updated", "wp_check_for_changed_dates", 12, 3);

      -- Nonce check for post previews.
      Add_Action ("init", "_show_post_preview");

      -- Output JS to reset window.name for previews.
      Add_Action ("wp_head", "wp_post_preview_js", 1);

      -- Timezone.
      Add_Filter ("pre_option_gmt_offset", "wp_timezone_override_offset");

      -- If the upgrade hasn"t run yet, assume link manager is used.
      Add_Filter ("default_option_link_manager_enabled", "__return_true");

      -- This option no longer exists; tell plugins we always support auto-embedding.
      Add_Filter ("pre_option_embed_autourls", "__return_true");

      -- Default settings for heartbeat.
      Add_Filter ("heartbeat_settings", "wp_heartbeat_settings");

      -- Check if the user is logged out.
      Add_Action ("admin_enqueue_scripts", "wp_auth_check_load");
      Add_Filter ("heartbeat_send", "wp_auth_check");
      Add_Filter ("heartbeat_nopriv_send", "wp_auth_check");

      -- Default authentication filters.
      Add_Filter ("authenticate", "wp_authenticate_username_password", 20, 3);
      Add_Filter ("authenticate", "wp_authenticate_email_password", 20, 3);
      Add_Filter ("authenticate", "wp_authenticate_application_password", 20, 3);
      Add_Filter ("authenticate", "wp_authenticate_spam_check", 99);
      Add_Filter ("determine_current_user", "wp_validate_auth_cookie");
      Add_Filter ("determine_current_user", "wp_validate_logged_in_cookie", 20);
      Add_Filter ("determine_current_user", "wp_validate_application_password", 20);

      -- Split term updates.
      Add_Action ("admin_init", "_wp_check_for_scheduled_split_terms");
      Add_Action ("split_shared_term", "_wp_check_split_default_terms", 10, 4);
      Add_Action ("split_shared_term", "_wp_check_split_terms_in_menus", 10, 4);
      Add_Action ("split_shared_term", "_wp_check_split_nav_menu_terms", 10, 4);
      Add_Action ("wp_split_shared_term_batch", "_wp_batch_split_terms");

      -- Comment type updates.
      Add_Action ("admin_init", "_wp_check_for_scheduled_update_comment_type");
      Add_Action ("wp_update_comment_type_batch", "_wp_batch_update_comment_type");

      -- Email notifications.
      Add_Action ("comment_post", "wp_new_comment_notify_moderator");
      Add_Action ("comment_post", "wp_new_comment_notify_postauthor");
      Add_Action ("after_password_reset", "wp_password_change_notification");
      Add_Action ("register_new_user", "wp_send_new_user_notifications");
      Add_Action ("edit_user_created_user", "wp_send_new_user_notifications", 10, 2);

      -- REST API actions.
      Add_Action ("init", "rest_api_init");
      Add_Action ("rest_api_init", "rest_api_default_filters", 10, 1);
      Add_Action ("rest_api_init", "register_initial_settings", 10);
      Add_Action ("rest_api_init", "create_initial_rest_routes", 99);
      Add_Action ("parse_request", "rest_api_loaded");

      -- Sitemaps actions.
      Add_Action ("init", "wp_sitemaps_get_server");

      --
      -- Filters formerly mixed into wp-includes.
      --
      -- Theme.
      Add_Action ("setup_theme", "create_initial_theme_features", 0);
      Add_Action ("setup_theme", "_add_default_theme_supports", 1);
      Add_Action ("wp_loaded", "_custom_header_background_just_in_time");
      Add_Action ("wp_head", "_custom_logo_header_styles");
      Add_Action ("plugins_loaded", "_wp_customize_include");
      Add_Action ("transition_post_status", "_wp_customize_publish_changeset", 10, 3);
      Add_Action ("admin_enqueue_scripts", "_wp_customize_loader_settings");
      Add_Action ("delete_attachment", "_delete_attachment_theme_mod");
      Add_Action ("transition_post_status",
                  "_wp_keep_alive_customize_changeset_dependent_auto_drafts", 20, 3);

      -- Calendar widget cache.
      Add_Action ("save_post", "delete_get_calendar_cache");
      Add_Action ("delete_post", "delete_get_calendar_cache");
      Add_Action ("update_option_start_of_week", "delete_get_calendar_cache");
      Add_Action ("update_option_gmt_offset", "delete_get_calendar_cache");

      -- Author.
      Add_Action ("transition_post_status", "__clear_multi_author_cache");

      -- Post.
      Add_Action ("init", "create_initial_post_types", 0); -- Highest priority.
      Add_Action ("admin_menu", "_add_post_type_submenus");
      Add_Action ("before_delete_post", "_reset_front_page_settings_for_post");
      Add_Action ("wp_trash_post", "_reset_front_page_settings_for_post");
      Add_Action ("change_locale", "create_initial_post_types");

      -- Post Formats.
      Add_Filter ("request", "_post_format_request");
      Add_Filter ("term_link", "_post_format_link", 10, 3);
      Add_Filter ("get_post_format", "_post_format_get_term");
      Add_Filter ("get_terms", "_post_format_get_terms", 10, 3);
      Add_Filter ("wp_get_object_terms", "_post_format_wp_get_object_terms");

      -- KSES.
      Add_Action ("init", "kses_init");
      Add_Action ("set_current_user", "kses_init");

      -- Script Loader.
      Add_Action ("wp_default_scripts", "wp_default_scripts");
      Add_Action ("wp_default_scripts", "wp_default_packages");

      Add_Action ("wp_enqueue_scripts", "wp_localize_jquery_ui_datepicker", 1000);
      Add_Action ("wp_enqueue_scripts", "wp_common_block_scripts_and_styles");
      Add_Action ("wp_enqueue_scripts",
                  Inc_Script_Loader.Wp_Enqueue_Classic_Theme_Styles'Access);
      Add_Action ("admin_enqueue_scripts", "wp_localize_jquery_ui_datepicker", 1000);
      Add_Action ("admin_enqueue_scripts", "wp_common_block_scripts_and_styles");
      Add_Action ("enqueue_block_assets",
                  "wp_enqueue_registered_block_scripts_and_styles");
      Add_Action ("enqueue_block_assets", "enqueue_block_styles_assets", 30);
      Add_Action ("enqueue_block_editor_assets",
                  "wp_enqueue_registered_block_scripts_and_styles");
      Add_Action ("enqueue_block_editor_assets", "enqueue_editor_block_styles_assets");
      Add_Action ("enqueue_block_editor_assets",
                  "wp_enqueue_editor_block_directory_assets");
      Add_Action ("enqueue_block_editor_assets",
                  "wp_enqueue_editor_format_library_assets");
      Add_Action ("enqueue_block_editor_assets",
                  "wp_enqueue_global_styles_css_custom_properties");
      Add_Filter ("wp_print_scripts", "wp_just_in_time_script_localization");
      Add_Filter ("print_scripts_array", "wp_prototype_before_jquery");
      Add_Filter ("customize_controls_print_styles", "wp_resource_hints", 1);
      Add_Action ("admin_head", "wp_check_widget_editor_deps");
      Add_Filter ("block_editor_settings_all", "wp_add_editor_classic_theme_styles");

      -- Global styles can be enqueued in both the header and the footer. See
      -- https://core.trac.wordpress.org/ticket/53494.
      Add_Action ("wp_enqueue_scripts", "wp_enqueue_global_styles");
      Add_Action ("wp_footer", "wp_enqueue_global_styles", 1);

      -- Block supports, and other styles parsed and stored in the Style Engine.
      Add_Action ("wp_enqueue_scripts", "wp_enqueue_stored_styles");
      Add_Action ("wp_footer", "wp_enqueue_stored_styles", 1);

      -- SVG filters like duotone have to be loaded at the beginning of the body in
      -- both admin and the front-end.
      Add_Action ("wp_body_open", "wp_global_styles_render_svg_filters");
      Add_Action ("in_admin_header", "wp_global_styles_render_svg_filters");

      Add_Action ("wp_default_styles", "wp_default_styles");
      Add_Filter ("style_loader_src", "wp_style_loader_src", 10, 2);

      Add_Action ("wp_head", "wp_maybe_inline_styles", 1);
      -- Run for styles enqueued in <head>.

      Add_Action ("wp_footer", "wp_maybe_inline_styles", 1);
      -- Run for late-loaded styles in the footer.

      --
      -- Disable "Post Attributes" for wp_navigation post type. The attributes are
      -- also conditionally enabled when a site has custom templates. Block Theme
      -- templates can be available for every post type.
      --
      Add_Filter ("theme_wp_navigation_templates", "__return_empty_array");

      -- Taxonomy.
      Add_Action ("init", "create_initial_taxonomies", 0); -- Highest priority.
      Add_Action ("change_locale", "create_initial_taxonomies");

      -- Canonical.
      Add_Action ("template_redirect", "redirect_canonical");
      Add_Action ("template_redirect", "wp_redirect_admin_locations", 1000);

      -- Shortcodes.
      Add_Filter ("the_content", "do_shortcode", 11); -- AFTER wpautop().

      -- Media.
      Add_Action ("wp_playlist_scripts", "wp_playlist_scripts");
      Add_Action ("customize_controls_enqueue_scripts",
                  "wp_plupload_default_settings");
      Add_Action ("plugins_loaded", "_wp_add_additional_image_sizes", 0);
      Add_Filter ("plupload_default_settings", "wp_show_heic_upload_error");

      -- Nav menu.
      Add_Filter ("nav_menu_item_id", "_nav_menu_item_id_use_once", 10, 2);

      -- Widgets.
      Add_Action ("after_setup_theme", "wp_setup_widgets_block_editor", 1);
      Add_Action ("init", "wp_widgets_init", 1);
--    Add_Action ("change_locale", To_Array (("WP_Widget_Media", "reset_default_labels")));

      -- Admin Bar.
      -- Don"t remove. Wrong way to disable.
      Add_Action ("template_redirect", "_wp_admin_bar_init", 0);
      Add_Action ("admin_init", "_wp_admin_bar_init");
      Add_Action ("before_signup_header", "_wp_admin_bar_init");
      Add_Action ("activate_header", "_wp_admin_bar_init");
      Add_Action ("wp_body_open", "wp_admin_bar_render", 0);

      Add_Action ("wp_footer", "wp_admin_bar_render", 1000);
      -- Back-compat for themes not using `wp_body_open`.

      Add_Action ("in_admin_header", "wp_admin_bar_render", 0);

      -- Former admin filters that can also be hooked on the front end.
      Add_Action ("media_buttons", "media_buttons");
      Add_Filter ("image_send_to_editor", "image_add_caption", 20, 8);
      Add_Filter ("media_send_to_editor", "image_media_send_to_editor", 10, 3);

      -- Embeds.
      Add_Action ("rest_api_init", "wp_oembed_register_route");
      Add_Filter ("rest_pre_serve_request", "_oembed_rest_pre_serve_request", 10, 4);

      Add_Action ("wp_head", "wp_oembed_add_discovery_links");
      Add_Action ("wp_head", "wp_oembed_add_host_js");
      -- Back-compat for sites disabling oEmbed host JS by removing action.
      Add_Filter ("embed_oembed_html", "wp_maybe_enqueue_oembed_host_js");

      Add_Action ("embed_head", "enqueue_embed_scripts", 1);
      Add_Action ("embed_head", "print_emoji_detection_script");
      Add_Action ("embed_head", "print_embed_styles");
      Add_Action ("embed_head", "wp_print_head_scripts", 20);
      Add_Action ("embed_head", "wp_print_styles", 20);
      Add_Action ("embed_head", "wp_robots");
      Add_Action ("embed_head", "rel_canonical");
      Add_Action ("embed_head", "locale_stylesheet", 30);

      Add_Action ("embed_content_meta", "print_embed_comments_button");
      Add_Action ("embed_content_meta", "print_embed_sharing_button");

      Add_Action ("embed_footer", "print_embed_sharing_dialog");
      Add_Action ("embed_footer", "print_embed_scripts");
      Add_Action ("embed_footer", "wp_print_footer_scripts", 20);

      Add_Filter ("excerpt_more", "wp_embed_excerpt_more", 20);
      Add_Filter ("the_excerpt_embed", "wptexturize");
      Add_Filter ("the_excerpt_embed", "convert_chars");
      Add_Filter ("the_excerpt_embed", "wpautop");
      Add_Filter ("the_excerpt_embed", "shortcode_unautop");
      Add_Filter ("the_excerpt_embed", "wp_embed_excerpt_attachment");

      Add_Filter ("oembed_dataparse", "wp_filter_oembed_iframe_title_attribute", 5, 3);
      Add_Filter ("oembed_dataparse", "wp_filter_oembed_result", 10, 3);
      Add_Filter ("oembed_response_data", "get_oembed_response_data_rich", 10, 4);
      Add_Filter ("pre_oembed_result", "wp_filter_pre_oembed_result", 10, 3);

      -- Capabilities.
      Add_Filter ("user_has_cap", "wp_maybe_grant_install_languages_cap", 1);
      Add_Filter ("user_has_cap", "wp_maybe_grant_resume_extensions_caps", 1);
      Add_Filter ("user_has_cap", "wp_maybe_grant_site_health_caps", 1, 4);

      -- Block templates post type and rendering.
      Add_Filter ("render_block_context",
                  "_block_template_render_without_post_block_context");
      Add_Filter ("pre_wp_unique_post_slug",
                  "wp_filter_wp_template_unique_post_slug", 10, 5);
      Add_Action ("save_post_wp_template_part",
                  "wp_set_unique_slug_on_create_template_part");
      Add_Action ("wp_footer", "the_block_template_skip_link");
      Add_Action ("setup_theme", "wp_enable_block_templates");
      Add_Action ("wp_loaded", "_add_template_loader_filters");

      -- Fluid typography.
      Add_Filter ("render_block", "wp_render_typography_support", 10, 2);

      -- User preferences.
      Add_Action ("init", "wp_register_persisted_preferences_meta");

      -- unset (filter, action);

   end Run;

end Inc_Default_Filters;
