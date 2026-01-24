--
-- WordPress Customize Nav Menus classes
--
-- @package WordPress
-- @subpackage Customize
-- @since 4.3.0
--

with Inc_Capabilities;
with Inc_Nav_Menus;

package body Class_Customize_Nav_Menus
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct
              (Manager : access Class_Customize_Managers.Wp_Customize_Manager)
               return Wp_Customize_Nav_Menus
   is
      use Inc_Capabilities;
      use Inc_Nav_Menus;

      This : Wp_Customize_Nav_Menus;
   begin
      This.Manager                     := Manager;
      This.Original_Nav_Menu_Locations := Get_Nav_Menu_Locations;

      -- See https://github.com/xwp/wp-customize-snapshots/blob/962586659688a5b1fd9ae93618b7ce2d4e7a421c/php/class-customize-snapshot-manager.php#L469-L499
      -- Add_Action ("customize_register", array( this, "customize_register" ), 11 );
      -- Add_Filter ("customize_dynamic_setting_args", array( this, "filter_dynamic_setting_args" ), 10, 2 );
      -- Add_Filter ("customize_dynamic_setting_class", array( this, "filter_dynamic_setting_class" ), 10, 3 );
      -- Add_Action ("customize_save_nav_menus_created_posts", array( this, "save_nav_menus_created_posts" ) );

      -- Skip remaining hooks when the user can't manage nav menus anyway.
      if not Current_User_Can ("edit_theme_options") then
         return This; -- this added
      end if;

      -- Add_Filter ("customize_refresh_nonces", array( this, "filter_nonces" ) );
      -- Add_Action ("wp_ajax_load-available-menu-items-customizer", array( this, "ajax_load_available_items" ) );
      -- Add_Action ("wp_ajax_search-available-menu-items-customizer", array( this, "ajax_search_available_items" ) );
      -- Add_Action ("wp_ajax_customize-nav-menus-insert-auto-draft", array( this, "ajax_insert_auto_draft_post" ) );
      -- Add_Action ("customize_controls_enqueue_scripts", array( this, "enqueue_scripts" ) );
      -- Add_Action ("customize_controls_print_footer_scripts", array( this, "print_templates" ) );
      -- Add_Action ("customize_controls_print_footer_scripts", array( this, "available_items_template" ) );
      -- Add_Action ("customize_preview_init", array( this, "customize_preview_init" ) );
      -- Add_Action ("customize_preview_init", array( this, "make_auto_draft_status_previewable" ) );

      -- -- Selective Refresh partials.
      -- Add_Filter ("customize_dynamic_partial_args", array( this, "customize_dynamic_partial_args" ), 10, 2 );

      return This;
   end X_Construct;

end Class_Customize_Nav_Menus;
