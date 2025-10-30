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

with Ada.Text_IO; use Ada.Text_IO;

with Arrays;
with Binder;
with Hb_Common;
with Globals;

with Inc_Admin_Bar;
with Inc_General_Templates;
with Inc_Load;
with Inc_Plugins;
with Inc_Posts;
with Inc_Script_Loader;
with Inc_Taxonomys;

package body Inc_Default_Filters
is
   ---------
   -- Run --
   ---------

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
--       Add_Filter (-Filter, "sanitize_text_field");
--       Add_Filter (-Filter, "wp_filter_kses");
--       Add_Filter (-Filter, "_wp_specialchars", 30);
         null;
      end loop;

      -- Strip, kses, special chars for string display.
      for Filter of To_List (List => (+"term_name", +"comment_author_name",
                              +"link_name", +"link_target", +"link_rel",
                              +"user_display_name", +"user_first_name",
                              +"user_last_name", +"user_nickname"))
      loop
         if Is_Admin then
            -- These are expensive. Run only on admin pages for defense in depth.
--          Add_Filter (-Filter, "sanitize_text_field");
--          Add_Filter (-Filter, "wp_kses_data");
            null;
         end if;
--       Add_Filter (-Filter, "_wp_specialchars", 30);
      end loop;

      -- Kses only for textarea saves.
      for Filter of To_List (List => (+"pre_term_description", +"pre_link_description",
                              +"pre_link_notes", +"pre_user_description"))
      loop
--       Add_Filter (-Filter, "wp_filter_kses");
         null;
      end loop;

      -- Kses only for textarea admin displays.
      if Is_Admin then
         for Filter of To_List (List => (+"term_description", +"link_description",
                                 +"link_notes", +"user_description"))
         loop
--          Add_Filter (-Filter, "wp_kses_data");
            null;
         end loop;
--       Add_Filter ("comment_text", "wp_kses_post");
      end if;

      -- Email saves.
      for Filter of To_List (List => (+"pre_comment_author_email",
                                      +"pre_user_email"))
      loop
--       Add_Filter (-Filter, "trim");
--       Add_Filter (-Filter, "sanitize_email");
--       Add_Filter (-Filter, "wp_filter_kses");
         null;
      end loop;

      -- Email admin display.
      for Filter of To_List (List => (+"comment_author_email", +"user_email")) loop
--       Add_Filter (-Filter, "sanitize_email");
         if Is_Admin then
--          Add_Filter (-Filter, "wp_kses_data");
            null;
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
--       Add_Filter (-Filter, "wp_strip_all_tags");
--       Add_Filter (-Filter, "sanitize_url");
--       Add_Filter (-Filter, "wp_filter_kses");
         null;
      end loop;

      -- Display URL.
      for Filter of To_List (List => (+"user_url", +"link_url", +"link_image",
                                      +"link_rss", +"comment_url", +"post_guid"))
      loop
         if Is_Admin then
--          Add_Filter (-Filter, "wp_strip_all_tags");
            null;
         end if;
--       Add_Filter (-Filter, "esc_url");
         if Is_Admin then
--          Add_Filter (-Filter, "wp_kses_data");
            null;
         end if;
      end loop;

      -- Slugs.
--    Add_Filter ("pre_term_slug", "sanitize_title");
--    Add_Filter ("wp_insert_post_data",
--                "_wp_customize_changeset_filter_insert_post_data", 10, 2);

      -- Keys.
      for Filter of To_List (List => (+"pre_post_type", +"pre_post_status",
                              +"pre_post_comment_status", +"pre_post_ping_status"))
      loop
--       Add_Filter (-Filter, "sanitize_key");
         null;
      end loop;

      -- Mime types.
--    Add_Filter ("pre_post_mime_type", "sanitize_mime_type");
--    Add_Filter ("post_mime_type", "sanitize_mime_type");

      -- Meta.
--    Add_Filter ("register_meta_args", "_wp_register_meta_args_allowed_list", 10, 2);

      -- Counts.
--    Add_Action ("admin_init", Wp_Schedule_Update_User_Counts'Access);
--    Add_Action ("wp_update_user_counts", Wp_Schedule_Update_User_Counts'Access, 10, 0);
      for Action of To_List (List => (+"user_register", +"deleted_user")) loop
--       Add_Action (-Action, Wp_Maybe_Update_User_Counts'Access, 10, 0);
         null;
      end loop;

      -- Post meta.
--    Add_Action ("added_post_meta", Wp_Cache_Set_Posts_Last_Changed'Access);
--    Add_Action ("updated_post_meta", Wp_Cache_Set_Posts_Last_Changed'Access);
--    Add_Action ("deleted_post_meta", Wp_Cache_Set_Posts_Last_Changed'Access);

      -- Term meta.
--    Add_Action ("added_term_meta", Wp_Cache_Set_Terms_Last_Changed'Access);
--    Add_Action ("updated_term_meta", Wp_Cache_Set_Terms_Last_Changed'Access);
--    Add_Action ("deleted_term_meta", Wp_Cache_Set_Terms_Last_Changed'Access);
--    Add_Filter ("get_term_metadata", "wp_check_term_meta_support_prefilter");
--    Add_Filter ("add_term_metadata", "wp_check_term_meta_support_prefilter");
--    Add_Filter ("update_term_metadata", "wp_check_term_meta_support_prefilter");
--    Add_Filter ("delete_term_metadata", "wp_check_term_meta_support_prefilter");
--    Add_Filter ("get_term_metadata_by_mid", "wp_check_term_meta_support_prefilter");
--    Add_Filter ("update_term_metadata_by_mid",
--                "wp_check_term_meta_support_prefilter");
--    Add_Filter ("delete_term_metadata_by_mid",
--                "wp_check_term_meta_support_prefilter");
--    Add_Filter ("update_term_metadata_cache",
--                "wp_check_term_meta_support_prefilter");

      -- Comment meta.
--    Add_Action ("added_comment_meta", Wp_Cache_Set_Comments_Last_Changed'Access);
--    Add_Action ("updated_comment_meta", Wp_Cache_Set_Comments_Last_Changed'Access);
--    Add_Action ("deleted_comment_meta", Wp_Cache_Set_Comments_Last_Changed'Access);

      -- Places to balance tags on input.
      for Filter of To_List (List => (+"content_save_pre", +"excerpt_save_pre",
                              +"comment_save_pre", +"pre_comment_content"))
      loop
--       Add_Filter (-Filter, "convert_invalid_entities");
--       Add_Filter (-Filter, "balanceTags", 50);
         null;
      end loop;

      -- Add proper rel values for links with target.
--    Add_Action ("init", Wp_Init_Targeted_Link_Rel_Filters'Access);

      -- Format strings for display.
      for Filter of To_List (List => (+"comment_author", +"term_name", +"link_name",
                              +"link_description", +"link_notes", +"bloginfo",
                              +"wp_title", +"document_title", +"widget_title"))
      loop
--       Add_Filter (-Filter, "wptexturize");
--       Add_Filter (-Filter, "convert_chars");
--       Add_Filter (-Filter, "esc_html");
         null;
      end loop;

      -- Format WordPress.
      for Filter of To_List (List => (+"the_content", +"the_title", +"wp_title",
                              +"document_title"))
      loop
--       Add_Filter (-Filter, "capital_P_dangit", 11);
         null;
      end loop;
--    Add_Filter ("comment_text", "capital_P_dangit", 31);

      -- Format titles.
      for Filter of To_List (List => (+"single_post_title", +"single_cat_title",
                              +"single_tag_title", +"single_month_title",
                              +"nav_menu_attr_title", +"nav_menu_description"))
      loop
--       Add_Filter (-Filter, "wptexturize");
--       Add_Filter (-Filter, "strip_tags");
         null;
      end loop;

      -- Format text area for display.
      for Filter of To_List (List => (+"term_description",
                              +"get_the_post_type_description"))
      loop
--       Add_Filter (-Filter, "wptexturize");
--       Add_Filter (-Filter, "convert_chars");
--       Add_Filter (-Filter, "wpautop");
--       Add_Filter (-Filter, "shortcode_unautop");
         null;
      end loop;

      -- Format for RSS.
--    Add_Filter ("term_name_rss", "convert_chars");

      -- Pre save hierarchy.
--    Add_Filter ("wp_insert_post_parent", "wp_check_post_hierarchy_for_loops", 10, 2);
--    Add_Filter ("wp_update_term_parent", "wp_check_term_hierarchy_for_loops", 10, 3);

      -- Display filters.
--    Add_Filter ("the_title", "wptexturize");
--    Add_Filter ("the_title", "convert_chars");
--    Add_Filter ("the_title", "trim");

--    Add_Filter ("the_content", "do_blocks", 9);
--    Add_Filter ("the_content", "wptexturize");
--    Add_Filter ("the_content", "convert_smilies", 20);
--    Add_Filter ("the_content", "wpautop");
--    Add_Filter ("the_content", "shortcode_unautop");
--    Add_Filter ("the_content", "prepend_attachment");
--    Add_Filter ("the_content", "wp_filter_content_tags");
--    Add_Filter ("the_content", "wp_replace_insecure_home_url");

--    Add_Filter ("the_excerpt", "wptexturize");
--    Add_Filter ("the_excerpt", "convert_smilies");
--    Add_Filter ("the_excerpt", "convert_chars");
--    Add_Filter ("the_excerpt", "wpautop");
--    Add_Filter ("the_excerpt", "shortcode_unautop");
--    Add_Filter ("the_excerpt", "wp_filter_content_tags");
--    Add_Filter ("the_excerpt", "wp_replace_insecure_home_url");
--    Add_Filter ("get_the_excerpt", "wp_trim_excerpt", 10, 2);

--    Add_Filter ("the_post_thumbnail_caption", "wptexturize");
--    Add_Filter ("the_post_thumbnail_caption", "convert_smilies");
--    Add_Filter ("the_post_thumbnail_caption", "convert_chars");

--    Add_Filter ("comment_text", "wptexturize");
--    Add_Filter ("comment_text", "convert_chars");
--    Add_Filter ("comment_text", "make_clickable", 9);
--    Add_Filter ("comment_text", "force_balance_tags", 25);
--    Add_Filter ("comment_text", "convert_smilies", 20);
--    Add_Filter ("comment_text", "wpautop", 30);

--    Add_Filter ("comment_excerpt", "convert_chars");

--    Add_Filter ("list_cats", "wptexturize");

--    Add_Filter ("wp_sprintf", "wp_sprintf_l", 10, 2);

--    Add_Filter ("widget_text", "balanceTags");
--    Add_Filter ("widget_text_content", "capital_P_dangit", 11);
--    Add_Filter ("widget_text_content", "wptexturize");
--    Add_Filter ("widget_text_content", "convert_smilies", 20);
--    Add_Filter ("widget_text_content", "wpautop");
--    Add_Filter ("widget_text_content", "shortcode_unautop");
--    Add_Filter ("widget_text_content", "wp_filter_content_tags");
--    Add_Filter ("widget_text_content", "wp_replace_insecure_home_url");
--    Add_Filter ("widget_text_content", "do_shortcode", 11);
      -- Runs after wpautop(); note that post global will be null when shortcodes run.

--    Add_Filter ("widget_block_content", "do_blocks", 9);
--    Add_Filter ("widget_block_content", "wp_filter_content_tags");
--    Add_Filter ("widget_block_content", "do_shortcode", 11);

--    Add_Filter ("block_type_metadata", "wp_migrate_old_typography_shape");

--    Add_Filter ("wp_get_custom_css", "wp_replace_insecure_home_url");

      -- RSS filters.
--    Add_Filter ("the_title_rss", "strip_tags");
--    Add_Filter ("the_title_rss", "ent2ncr", 8);
--    Add_Filter ("the_title_rss", "esc_html");
--    Add_Filter ("the_content_rss", "ent2ncr", 8);
--    Add_Filter ("the_content_feed", "wp_staticize_emoji");
--    Add_Filter ("the_content_feed", "_oembed_filter_feed_content");
--    Add_Filter ("the_excerpt_rss", "convert_chars");
--    Add_Filter ("the_excerpt_rss", "ent2ncr", 8);
--    Add_Filter ("comment_author_rss", "ent2ncr", 8);
--    Add_Filter ("comment_text_rss", "ent2ncr", 8);
--    Add_Filter ("comment_text_rss", "esc_html");
--    Add_Filter ("comment_text_rss", "wp_staticize_emoji");
--    Add_Filter ("bloginfo_rss", "ent2ncr", 8);
--    Add_Filter ("the_author", "ent2ncr", 8);
--    Add_Filter ("the_guid", "esc_url");

      -- Email filters.
--    Add_Filter ("wp_mail", "wp_staticize_emoji_for_email");

      -- Robots filters.
--    Add_Filter ("wp_robots", "wp_robots_noindex");
--    Add_Filter ("wp_robots", "wp_robots_noindex_embeds");
--    Add_Filter ("wp_robots", "wp_robots_noindex_search");
--    Add_Filter ("wp_robots", "wp_robots_max_image_preview_large");

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
--       Add_Action (-Action, X_Delete_Option_Fresh_Site'Access, 0);
         null;
      end loop;

      -- Misc filters.
--    Add_Filter ("option_ping_sites", "privacy_ping_filter");
--    Add_Filter ("option_blog_charset", "_wp_specialchars");
      -- IMPORTANT: This must not be wp_specialchars() or esc_html() or it'll
      -- cause an infinite loop.
--    Add_Filter ("option_blog_charset", "_canonical_charset");
--    Add_Filter ("option_home", "_config_wp_home");
--    Add_Filter ("option_siteurl", "_config_wp_siteurl");
--    Add_Filter ("tiny_mce_before_init", "_mce_set_direction");
--    Add_Filter ("teeny_mce_before_init", "_mce_set_direction");
--    Add_Filter ("pre_kses", "wp_pre_kses_less_than");
--    Add_Filter ("pre_kses", "wp_pre_kses_block_attributes", 10, 3);
--    Add_Filter ("sanitize_title", "sanitize_title_with_dashes", 10, 3);
--    Add_Action ("check_comment_flood", Check_Comment_Flood_Db'Access, 10, 4);
--    Add_Filter ("comment_flood_filter", "wp_throttle_comment_flood", 10, 3);
--    Add_Filter ("pre_comment_content", "wp_rel_ugc", 15);
--    Add_Filter ("comment_email", "antispambot");
--    Add_Filter ("option_tag_base", "_wp_filter_taxonomy_base");
--    Add_Filter ("option_category_base", "_wp_filter_taxonomy_base");
--    Add_Filter ("the_posts", "_close_comments_for_old_posts", 10, 2);
--    Add_Filter ("comments_open", "_close_comments_for_old_post", 10, 2);
--    Add_Filter ("pings_open", "_close_comments_for_old_post", 10, 2);
--    Add_Filter ("editable_slug", "urldecode");
--    Add_Filter ("editable_slug", "esc_textarea");
--    Add_Filter ("pingback_ping_source_uri", "pingback_ping_source_uri");
--    Add_Filter ("xmlrpc_pingback_error", "xmlrpc_pingback_error");
--    Add_Filter ("title_save_pre", "trim");

--    Add_Action ("transition_comment_status",
--                X_Clear_Modified_Cache_On_Transition_Comment_Status'Access, 10, 2);

--    Add_Filter ("http_request_host_is_external",
--                "allowed_http_request_hosts", 10, 2);

      -- REST API filters.
--    Add_Action ("xmlrpc_rsd_apis", Rest_Output_Rsd'Access);
--    Add_Action ("wp_head", Rest_Output_Link_Wp_Head'Access, 10, 0);
--    Add_Action ("template_redirect", Rest_Output_Link_Header'Access, 11, 0);
--    Add_Action ("auth_cookie_malformed", Rest_Cookie_Collect_Status'Access);
--    Add_Action ("auth_cookie_expired", Rest_Cookie_Collect_Status'Access);
--    Add_Action ("auth_cookie_bad_username", Rest_Cookie_Collect_Status'Access);
--    Add_Action ("auth_cookie_bad_hash", Rest_Cookie_Collect_Status'Access);
--    Add_Action ("auth_cookie_valid", Rest_Cookie_Collect_Status'Access);
--    Add_Action ("application_password_failed_authentication",
--                Rest_Application_Password_Collect_Status'Access);
--    Add_Action ("application_password_did_authenticate",
--                Rest_Application_Password_Collect_Status'Access, 10, 2);
--    Add_Filter ("rest_authentication_errors",
--                "rest_application_password_check_errors", 90);
--    Add_Filter ("rest_authentication_errors", "rest_cookie_check_errors", 100);

      -- Actions.
      Add_Action ("wp_head", Inc_General_Templates.X_Wp_Render_Title_Tag'Access, 1);
      Add_Action ("wp_head", Inc_Script_Loader.Wp_Enqueue_Scripts'Access, 1);
--    Add_Action ("wp_head", Wp_Resource_Hints'Access, 2);
--    Add_Action ("wp_head", Wp_Preload_Resources'Access, 1);
--    Add_Action ("wp_head", Feed_Links'Access, 2);
--    Add_Action ("wp_head", Feed_Links_Extra'Access, 3);
--    Add_Action ("wp_head", Rsd_Link'Access);
--    Add_Action ("wp_head", Wlwmanifest_Link'Access);
--    Add_Action ("wp_head", Locale_Stylesheet'Access);
--    Add_Action ("publish_future_post", Check_And_Publish_Future_Post'Access, 10, 1);
--    Add_Action ("wp_head", Wp_Robots'Access, 1);
--    Add_Action ("wp_head", Print_Emoji_Detection_Script'Access, 7);
--    Add_Action ("wp_head", Wp_Print_Styles'Access, 8);
--    Add_Action ("wp_head", Wp_Print_Head_Scripts'Access, 9);
--    Add_Action ("wp_head", Wp_Generator'Access);
--    Add_Action ("wp_head", Rel_Canonical'Access);
--    Add_Action ("wp_head", Wp_Shortlink_Wp_Head'Access, 10, 0);
--    Add_Action ("wp_head", Wp_Custom_Css_Cb'Access, 101);
--    Add_Action ("wp_head", Wp_Site_Icon'Access, 99);
--    Add_Action ("wp_footer", Wp_Print_Footer_Scripts'Access, 20);
--    Add_Action ("template_redirect", Wp_Shortlink_Header'Access, 11, 0);
--    Add_Action ("wp_print_footer_scripts", X_Wp_Footer_Scripts'Access);
--    Add_Action ("init", X_Register_Core_Block_Patterns_And_Categories'Access);
--    Add_Action ("init", Check_Theme_Switched'Access, 99);

--    Add_Action ("init", To_Array (("WP_Block_Supports", "init")), 22);
--    Add_Action ("switch_theme", To_Array (("WP_Theme_JSON_Resolver", "clean_cached_data")));
--    Add_Action ("start_previewing_theme", To_Array (("WP_Theme_JSON_Resolver", "clean_cached_data")));

--    Add_Action ("after_switch_theme", X_Wp_Menus_Changed'Access);
--    Add_Action ("after_switch_theme", X_Wp_Sidebars_Changed'Access);
--    Add_Action ("wp_print_styles", Print_Emoji_Styles'Access);
--    Add_Action ("plugins_loaded", X_Wp_Theme_Json_Webfonts_Handler'Access);

      if Isset (Binder.XX_GET, "replytocom") then
--       Add_Filter ("wp_robots", "wp_robots_no_robots");
         null;
      end if;

      -- Login actions.
--    Add_Action ("login_head", Wp_Robots'Access, 1);
--    Add_Filter ("login_head", "wp_resource_hints", 8);
--    Add_Action ("login_head", Wp_Print_Head_Scripts'Access, 9);
--    Add_Action ("login_head", Inc_Script_Loader.Print_Admin_Styles'Access, 9);
--    Add_Action ("login_head", Wp_Site_Icon'Access, 99);
--    Add_Action ("login_footer", Wp_Print_Footer_Scripts'Access, 20);
--    Add_Action ("login_init", Send_Frame_Options_Header'Access, 10, 0);

      -- Feed generator tags.
      for Action of To_List (List => (+"rss2_head", +"commentsrss2_head", +"rss_head",
                              +"rdf_header", +"atom_head", +"comments_atom_head",
                              +"opml_head", +"app_head"))
      loop
--       Add_Action (-Action, The_Generator'Access);
         null;
      end loop;

      -- Feed Site Icon.
--    Add_Action ("atom_head", Atom_Site_Icon'Access);
--    Add_Action ("rss2_head", Rss2_Site_Icon'Access);

      -- WP Cron.
      if not Globals.DOING_CRON then
--    if not Defined ("DOING_CRON") then
--       Add_Action ("init", Wp_Cron'Access);
         null;
      end if;

      -- HTTPS detection.
--    Add_Action ("init", Wp_Schedule_Https_Detection'Access);
--    Add_Action ("wp_https_detection", Wp_Update_Https_Detection_Errors'Access);
--    Add_Filter ("cron_request", "wp_cron_conditionally_prevent_sslverify", 9999);

      -- HTTPS migration.
--    Add_Action ("update_option_home",
--                Wp_Update_Https_Migration_Required'Access, 10, 2);

      -- 2 Actions 2 Furious.
--    Add_Action ("do_feed_rdf", Do_Feed_Rdf'Access, 10, 0);
--    Add_Action ("do_feed_rss", Do_Feed_Rss'Access, 10, 0);
--    Add_Action ("do_feed_rss2", Do_Feed_Rss2'Access, 10, 1);
--    Add_Action ("do_feed_atom", Do_Feed_Atom'Access, 10, 1);
--    Add_Action ("do_pings", Do_All_Pings'Access, 10, 0);
--    Add_Action ("do_all_pings", Do_All_Pingbacks'Access, 10, 0);
--    Add_Action ("do_all_pings", Do_All_Enclosures'Access, 10, 0);
--    Add_Action ("do_all_pings", Do_All_Trackbacks'Access, 10, 0);
--    Add_Action ("do_all_pings", Generic_Ping'Access, 10, 0);
--    Add_Action ("do_robots", Do_Robots'Access);
--    Add_Action ("do_favicon", Do_Favicon'Access);
--    Add_Action ("set_comment_cookies", Wp_Set_Comment_Cookies'Access, 10, 3);
--    Add_Action ("sanitize_comment_cookies", Sanitize_Comment_Cookies'Access);
--    Add_Action ("init", Smilies_Init'Access, 5);
--    Add_Action ("plugins_loaded", Wp_Maybe_Load_Widgets'Access, 0);
--    Add_Action ("plugins_loaded", Wp_Maybe_Load_Embeds'Access, 0);
--    Add_Action ("shutdown", Wp_Ob_End_Flush_All'Access, 1);
      -- Create a revision whenever a post is updated.
--    Add_Action ("post_updated", Wp_Save_Post_Revision'Access, 10, 1);
--    Add_Action ("publish_post", X_Publish_Post_Hook'Access, 5, 1);
--    Add_Action ("transition_post_status", X_Transition_Post_Status'Access, 5, 3);
--    Add_Action ("transition_post_status",
--                X_Update_Term_Count_On_Transition_Post_Status'Access, 10, 3);
--    Add_Action ("comment_form", Wp_Comment_Form_Unfiltered_Html_Nonce'Access);

      -- Privacy.
--      Add_Action ("user_request_action_confirmed",
--                  X_Wp_Privacy_Account_Request_Confirmed'Access);
--      Add_Action ("user_request_action_confirmed",
--                  X_Wp_Privacy_Send_Request_Confirmation_Notification'Access, 12);

                  -- After request marked as completed.
--    Add_Filter ("wp_privacy_personal_data_exporters",
--                "wp_register_comment_personal_data_exporter");
--    Add_Filter ("wp_privacy_personal_data_exporters",
--                "wp_register_media_personal_data_exporter");
--    Add_Filter ("wp_privacy_personal_data_exporters",
--                "wp_register_user_personal_data_exporter", 1);
--    Add_Filter ("wp_privacy_personal_data_erasers",
--                "wp_register_comment_personal_data_eraser");
--    Add_Action ("init", Wp_Schedule_Delete_Old_Privacy_Export_Files'Access);
--    Add_Action ("wp_privacy_delete_old_export_files",
--                Wp_Privacy_Delete_Old_Export_Files'Access);

      -- Cron tasks.
--    Add_Action ("wp_scheduled_delete", Wp_Scheduled_Delete'Access);
--    Add_Action ("wp_scheduled_auto_draft_delete", Wp_Delete_Auto_Drafts'Access);
--    Add_Action ("importer_scheduled_cleanup", Wp_Delete_Attachment'Access);
--    Add_Action ("upgrader_scheduled_cleanup", Wp_Delete_Attachment'Access);
--    Add_Action ("delete_expired_transients", Delete_Expired_Transients'Access);

      -- Navigation menu actions.
--    Add_Action ("delete_post", X_Wp_Delete_Post_Menu_Item'Access);
--    Add_Action ("delete_term", X_Wp_Delete_Tax_Menu_Item'Access, 10, 3);
--    Add_Action ("transition_post_status", X_Wp_Auto_Add_Pages_To_Menu'Access, 10, 3);
--    Add_Action ("delete_post",
--                X_Wp_Delete_Customize_Changeset_Dependent_Auto_Drafts'Access);

      -- Post Thumbnail CSS class filtering.
--    Add_Action ("begin_fetch_post_thumbnail_html",
--                X_Wp_Post_Thumbnail_Class_Filter_Add'Access);
--    Add_Action ("end_fetch_post_thumbnail_html",
--                X_Wp_Post_Thumbnail_Class_Filter_Remove'Access);

      -- Redirect old slugs.
--    Add_Action ("template_redirect", Wp_Old_Slug_Redirect'Access);
--    Add_Action ("post_updated", Wp_Check_For_Changed_Slugs'Access, 12, 3);
--    Add_Action ("attachment_updated", Wp_Check_For_Changed_Slugs'Access, 12, 3);

      -- Redirect old dates.
--    Add_Action ("post_updated", Wp_Check_For_Changed_Dates'Access, 12, 3);
--    Add_Action ("attachment_updated", Wp_Check_For_Changed_Dates'Access, 12, 3);

      -- Nonce check for post previews.
--    Add_Action ("init", X_Show_Post_Preview'Access);

      -- Output JS to reset window.name for previews.
--    Add_Action ("wp_head", Wp_Post_Preview_Js'Access, 1);

      -- Timezone.
--    Add_Filter ("pre_option_gmt_offset", "wp_timezone_override_offset");

      -- If the upgrade hasn"t run yet, assume link manager is used.
--    Add_Filter ("default_option_link_manager_enabled", "__return_true");

      -- This option no longer exists; tell plugins we always support auto-embedding.
--    Add_Filter ("pre_option_embed_autourls", "__return_true");

      -- Default settings for heartbeat.
--    Add_Filter ("heartbeat_settings", "wp_heartbeat_settings");

      -- Check if the user is logged out.
--    Add_Action ("admin_enqueue_scripts", Wp_Auth_Check_Load'Access);
--    Add_Filter ("heartbeat_send", "wp_auth_check");
--    Add_Filter ("heartbeat_nopriv_send", "wp_auth_check");

      -- Default authentication filters.
--    Add_Filter ("authenticate", "wp_authenticate_username_password", 20, 3);
--    Add_Filter ("authenticate", "wp_authenticate_email_password", 20, 3);
--    Add_Filter ("authenticate", "wp_authenticate_application_password", 20, 3);
--    Add_Filter ("authenticate", "wp_authenticate_spam_check", 99);
--    Add_Filter ("determine_current_user", "wp_validate_auth_cookie");
--    Add_Filter ("determine_current_user", "wp_validate_logged_in_cookie", 20);
--    Add_Filter ("determine_current_user", "wp_validate_application_password", 20);

      -- Split term updates.
--    Add_Action ("admin_init", X_Wp_Check_For_Scheduled_Split_Terms'Access);
--    Add_Action ("split_shared_term", X_Wp_Check_Split_Default_Terms'Access, 10, 4);
--    Add_Action ("split_shared_term", X_Wp_Check_Split_Terms_In_Menus'Access, 10, 4);
--    Add_Action ("split_shared_term", X_Wp_Check_Split_Nav_Menu_Terms'Access, 10, 4);
--    Add_Action ("wp_split_shared_term_batch", X_Wp_Batch_Split_Terms'Access);

      -- Comment type updates.
--    Add_Action ("admin_init", X_Wp_Check_For_Scheduled_Update_Comment_Type'Access);
--    Add_Action ("wp_update_comment_type_batch",
--                X_Wp_Batch_Update_Comment_Type'Access);

      -- Email notifications.
--    Add_Action ("comment_post", Wp_New_Comment_Notify_Moderator'Access);
--    Add_Action ("comment_post", Wp_New_Comment_Notify_Postauthor'Access);
--    Add_Action ("after_password_reset", Wp_Password_Change_Notification'Access);
--    Add_Action ("register_new_user", Wp_Send_New_User_Notifications'Access);
--    Add_Action ("edit_user_created_user",
--                Wp_Send_New_User_Notifications'Access, 10, 2);

      -- REST API actions.
--    Add_Action ("init", Rest_Api_Init'Access);
--    Add_Action ("rest_api_init", Rest_Api_Default_Filters'Access, 10, 1);
--    Add_Action ("rest_api_init", Register_Initial_Settings'Access, 10);
--    Add_Action ("rest_api_init", Create_Initial_Rest_Routes'Access, 99);
--    Add_Action ("parse_request", Rest_Api_Loaded'Access);

      -- Sitemaps actions.
--    Add_Action ("init", Wp_Sitemaps_Get_Server'Access);

      --
      -- Filters formerly mixed into wp-includes.
      --
      -- Theme.
--    Add_Action ("setup_theme", Create_Initial_Theme_Features'Access, 0);
--    Add_Action ("setup_theme", X_Add_Default_Theme_Supports'Access, 1);
--    Add_Action ("wp_loaded", X_Custom_Header_Background_Just_In_Time'Access);
--    Add_Action ("wp_head", X_Custom_Logo_Header_Styles'Access);
--    Add_Action ("plugins_loaded", X_Wp_Customize_Include'Access);
--    Add_Action ("transition_post_status", X_Wp_Customize_Publish_Changeset'Access, 10, 3);
--    Add_Action ("admin_enqueue_scripts", X_Wp_Customize_Loader_Settings'Access);
--    Add_Action ("delete_attachment", X_Delete_Attachment_Theme_Mod'Access);
--    Add_Action ("transition_post_status",
--                X_Wp_Keep_Alive_Customize_Changeset_Dependent_Auto_Drafts'Access, 20, 3);

      -- Calendar widget cache.
--    Add_Action ("save_post", Delete_Get_Calendar_Cache'Access);
--    Add_Action ("delete_post", Delete_Get_Calendar_Cache'Access);
--    Add_Action ("update_option_start_of_week", Delete_Get_Calendar_Cache'Access);
--    Add_Action ("update_option_gmt_offset", Delete_Get_Calendar_Cache'Access);

      -- Author.
--    Add_Action ("transition_post_status", X_Clear_Multi_Author_Cache'Access); -- __

      -- Post.
      Add_Action ("init", Inc_Posts.Create_Initial_Post_Types'Access, 0);
      -- Highest priority.
      Add_Action ("admin_menu", Inc_Posts.X_Add_Post_Type_Submenus'Access);
--    Add_Action ("before_delete_post", X_Reset_Front_Page_Settings_For_Post'Access);
--    Add_Action ("wp_trash_post", X_Reset_Front_Page_Settings_For_Post'Access);
      Add_Action ("change_locale", Inc_Posts.Create_Initial_Post_Types'Access);

      -- Post Formats.
--    Add_Filter ("request", "_post_format_request");
--    Add_Filter ("term_link", "_post_format_link", 10, 3);
--    Add_Filter ("get_post_format", "_post_format_get_term");
--    Add_Filter ("get_terms", "_post_format_get_terms", 10, 3);
--    Add_Filter ("wp_get_object_terms", "_post_format_wp_get_object_terms");

      -- KSES.
--    Add_Action ("init", Kses_Init'Access);
--    Add_Action ("set_current_user", Kses_Init'Access);

      -- Script Loader.
--    Add_Action ("wp_default_scripts", Inc_Script_Loader.Wp_Default_Scripts'Access);
--    Add_Action ("wp_default_scripts", Inc_Script_Loader.Wp_Default_Packages'Access);

--    Add_Action ("wp_enqueue_scripts", Wp_Localize_Jquery_Ui_Datepicker'Access, 1000);
      Add_Action ("wp_enqueue_scripts",
                  Inc_Script_Loader.Wp_Common_Block_Scripts_And_Styles'Access);
      Add_Action ("wp_enqueue_scripts",
                  Inc_Script_Loader.Wp_Enqueue_Classic_Theme_Styles'Access);
--    Add_Action ("admin_enqueue_scripts", Wp_Localize_Jquery_Ui_Datepicker'Access, 1000);
      Add_Action ("admin_enqueue_scripts",
                  Inc_Script_Loader.Wp_Common_Block_Scripts_And_Styles'Access);
--    Add_Action ("enqueue_block_assets",
--                Wp_Enqueue_Registered_Block_Scripts_And_Styles'Access);
--    Add_Action ("enqueue_block_assets", Enqueue_Block_Styles_Assets'Access, 30);
--    Add_Action ("enqueue_block_editor_assets",
--                Wp_Enqueue_Registered_Block_Scripts_And_Styles'Access);
--    Add_Action ("enqueue_block_editor_assets",
--                Enqueue_Editor_Block_Styles_Assets'Access);
--    Add_Action ("enqueue_block_editor_assets",
--                Wp_Enqueue_Editor_Block_Directory_Assets'Access);
--    Add_Action ("enqueue_block_editor_assets",
--                Wp_Enqueue_Editor_Format_Library_Assets'Access);
--    Add_Action ("enqueue_block_editor_assets",
--                Wp_Enqueue_Global_Styles_Css_Custom_Properties'Access);
--    Add_Filter ("wp_print_scripts", "wp_just_in_time_script_localization");
--    Add_Filter ("print_scripts_array", "wp_prototype_before_jquery");
--    Add_Filter ("customize_controls_print_styles", "wp_resource_hints", 1);
--    Add_Action ("admin_head", Wp_Check_Widget_Editor_Deps'Access);
--    Add_Filter ("block_editor_settings_all", "wp_add_editor_classic_theme_styles");

      -- Global styles can be enqueued in both the header and the footer. See
      -- https://core.trac.wordpress.org/ticket/53494.
--    Add_Action ("wp_enqueue_scripts", Wp_Enqueue_Global_Styles'Access);
--    Add_Action ("wp_footer", Wp_Enqueue_Global_Styles'Access, 1);

      -- Block supports, and other styles parsed and stored in the Style Engine.
--    Add_Action ("wp_enqueue_scripts", Wp_Enqueue_Stored_Styles'Access);
--    Add_Action ("wp_footer", Wp_Enqueue_Stored_Styles'Access, 1);

      -- SVG filters like duotone have to be loaded at the beginning of the body in
      -- both admin and the front-end.
--    Add_Action ("wp_body_open", Wp_Global_Styles_Render_Svg_Filters'Access);
--    Add_Action ("in_admin_header", Wp_Global_Styles_Render_Svg_Filters'Access);

--    Add_Action ("wp_default_styles", Inc_Script_Loader.Wp_Default_Styles'Access);
--    Add_Filter ("style_loader_src", "wp_style_loader_src", 10, 2);

--    Add_Action ("wp_head", Wp_Maybe_Inline_Styles'Access, 1);
      -- Run for styles enqueued in <head>.

--    Add_Action ("wp_footer", Wp_Maybe_Inline_Styles'Access, 1);
      -- Run for late-loaded styles in the footer.

      --
      -- Disable "Post Attributes" for wp_navigation post type. The attributes are
      -- also conditionally enabled when a site has custom templates. Block Theme
      -- templates can be available for every post type.
      --
--    Add_Filter ("theme_wp_navigation_templates", "__return_empty_array");

      -- Taxonomy.
      Add_Action ("init", Inc_Taxonomys.Create_Initial_Taxonomies'Access, 0);
      -- Highest priority.
--    Add_Action ("change_locale", Create_Initial_Taxonomies'Access);

      -- Canonical.
--    Add_Action ("template_redirect", Redirect_Canonical'Access);
--    Add_Action ("template_redirect", Wp_Redirect_Admin_Locations'Access, 1000);

      -- Shortcodes.
--    Add_Filter ("the_content", "do_shortcode", 11); -- AFTER wpautop().

      -- Media.
--    Add_Action ("wp_playlist_scripts", Wp_Playlist_Scripts'Access);
--    Add_Action ("customize_controls_enqueue_scripts",
--                Wp_Plupload_Default_Settings'Access);
--    Add_Action ("plugins_loaded", X_Wp_Add_Additional_Image_Sizes'Access, 0);
--    Add_Filter ("plupload_default_settings", "wp_show_heic_upload_error");

      -- Nav menu.
--    Add_Filter ("nav_menu_item_id", "_nav_menu_item_id_use_once", 10, 2);

      -- Widgets.
--    Add_Action ("after_setup_theme", Wp_Setup_Widgets_Block_Editor'Access, 1);
--    Add_Action ("init", Wp_Widgets_Init'Access, 1);
--    Add_Action ("change_locale", To_Array (("WP_Widget_Media", "reset_default_labels")));

      -- Admin Bar.
      -- Don"t remove. Wrong way to disable.
      Add_Action ("template_redirect",    Inc_Admin_Bar.X_Wp_Admin_Bar_Init'Access, 0);
      Add_Action ("admin_init",           Inc_Admin_Bar.X_Wp_Admin_Bar_Init'Access);
      Add_Action ("before_signup_header", Inc_Admin_Bar.X_Wp_Admin_Bar_Init'Access);
      Add_Action ("activate_header",      Inc_Admin_Bar.X_Wp_Admin_Bar_Init'Access);
      Add_Action ("wp_body_open",         Inc_Admin_Bar.Wp_Admin_Bar_Render'Access, 0);

      Add_Action ("wp_footer", Inc_Admin_Bar.Wp_Admin_Bar_Render'Access, 1000);
      -- Back-compat for themes not using `wp_body_open`.

      Add_Action ("in_admin_header", Inc_Admin_Bar.Wp_Admin_Bar_Render'Access, 0);

      -- Former admin filters that can also be hooked on the front end.
--    Add_Action ("media_buttons", Media_Buttons'Access);
--    Add_Filter ("image_send_to_editor", "image_add_caption", 20, 8);
--    Add_Filter ("media_send_to_editor", "image_media_send_to_editor", 10, 3);

      -- Embeds.
--    Add_Action ("rest_api_init", Wp_Oembed_Register_Route'Access);
--    Add_Filter ("rest_pre_serve_request", "_oembed_rest_pre_serve_request", 10, 4);

--    Add_Action ("wp_head", Wp_Oembed_Add_Discovery_Links'Access);
--    Add_Action ("wp_head", Wp_Oembed_Add_Host_Js'Access);
      -- Back-compat for sites disabling oEmbed host JS by removing action.
--    Add_Filter ("embed_oembed_html", "wp_maybe_enqueue_oembed_host_js");

--    Add_Action ("embed_head", Enqueue_Embed_Scripts'Access, 1);
--    Add_Action ("embed_head", Print_Emoji_Detection_Script'Access);
--    Add_Action ("embed_head", Print_Embed_Styles'Access);
--    Add_Action ("embed_head", Wp_Print_Head_Scripts'Access, 20);
--    Add_Action ("embed_head", Wp_Print_Styles'Access, 20);
--    Add_Action ("embed_head", Wp_Robots'Access);
--    Add_Action ("embed_head", Rel_Canonical'Access);
--    Add_Action ("embed_head", Locale_Stylesheet'Access, 30);

--    Add_Action ("embed_content_meta", Print_Embed_Comments_Button'Access);
--    Add_Action ("embed_content_meta", Print_Embed_Sharing_Button'Access);

--    Add_Action ("embed_footer", Print_Embed_Sharing_Dialog'Access);
--    Add_Action ("embed_footer", Print_Embed_Scripts'Access);
--    Add_Action ("embed_footer", Wp_Print_Footer_Scripts'Access, 20);

--    Add_Filter ("excerpt_more", "wp_embed_excerpt_more", 20);
--    Add_Filter ("the_excerpt_embed", "wptexturize");
--    Add_Filter ("the_excerpt_embed", "convert_chars");
--    Add_Filter ("the_excerpt_embed", "wpautop");
--    Add_Filter ("the_excerpt_embed", "shortcode_unautop");
--    Add_Filter ("the_excerpt_embed", "wp_embed_excerpt_attachment");

--    Add_Filter ("oembed_dataparse", "wp_filter_oembed_iframe_title_attribute", 5, 3);
--    Add_Filter ("oembed_dataparse", "wp_filter_oembed_result", 10, 3);
--    Add_Filter ("oembed_response_data", "get_oembed_response_data_rich", 10, 4);
--    Add_Filter ("pre_oembed_result", "wp_filter_pre_oembed_result", 10, 3);

      -- Capabilities.
--    Add_Filter ("user_has_cap", "wp_maybe_grant_install_languages_cap", 1);
--    Add_Filter ("user_has_cap", "wp_maybe_grant_resume_extensions_caps", 1);
--    Add_Filter ("user_has_cap", "wp_maybe_grant_site_health_caps", 1, 4);

      -- Block templates post type and rendering.
--    Add_Filter ("render_block_context",
--                "_block_template_render_without_post_block_context");
--    Add_Filter ("pre_wp_unique_post_slug",
--                "wp_filter_wp_template_unique_post_slug", 10, 5);
--    Add_Action ("save_post_wp_template_part",
--                Wp_Set_Unique_Slug_On_Create_Template_Part'Access);
--    Add_Action ("wp_footer", The_Block_Template_Skip_Link'Access);
--    Add_Action ("setup_theme", Wp_Enable_Block_Templates'Access);
--    Add_Action ("wp_loaded", X_Add_Template_Loader_Filters'Access);

      -- Fluid typography.
--    Add_Filter ("render_block", "wp_render_typography_support", 10, 2);

      -- User preferences.
--    Add_Action ("init", Wp_Register_Persisted_Preferences_Meta'Access);

      -- unset (filter, action);

   end Run;

end Inc_Default_Filters;
