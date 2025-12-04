--
-- WordPress Customize Manager classes
--
-- @package WordPress
-- @subpackage Customize
-- @since 3.4.0
--

with Binder;
with Globals;
with Helpers;
with Php.JSON;
with Php.Preg;
with Php.Strings;

with Inc_Caches;
with Inc_Class_Wp_Querys;
with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_Load;
with Inc_Options;
with Inc_Plugins;
with Inc_Posts;
with Inc_Themes;
with Inc_Users;

-- require_once ABSPATH . WPINC . "/class-wp-customize-setting.php";
-- require_once ABSPATH . WPINC . "/class-wp-customize-panel.php";
-- require_once ABSPATH . WPINC . "/class-wp-customize-section.php";
-- require_once ABSPATH . WPINC . "/class-wp-customize-control.php";

-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-color-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-media-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-upload-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-image-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-background-image-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-background-position-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-cropped-image-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-site-icon-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-header-image-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-theme-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-code-editor-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-widget-area-customize-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-widget-form-customize-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-item-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-location-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-name-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-locations-control.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-auto-add-control.php";

-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menus-panel.php";

-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-themes-panel.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-themes-section.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-sidebar-section.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-section.php";

-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-custom-css-setting.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-filter-setting.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-header-image-setting.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-background-image-setting.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-item-setting.php";
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-setting.php";

-- with Cust_Class_Wp_Customize_Selective_Refresh;
-- with Inc_Class_Wp_Customize_Widgets;
-- with Inc_Class_Wp_Customize_Nav_Menus;
-- require_once ABSPATH . "wp-admin/includes/update.php";

package body Inc_Class_Wp_Customize_Managers
is

   function Apply_Filters (Hook  : String;
                           Value : List_Type;
                           T     : Wp_Customize_Manager)
                           return List_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Wp_Customize_Setting;
                           Id        : String;
                           A         : Array_Type)
                           return Wp_Customize_Setting
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Wp_Customize_Setting;
                           Id        : String;
                           Setting   : Boolean)
                           return Wp_Customize_Setting
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           T         : Wp_Customize_Manager)
                           return Boolean
                           is (Value);

   procedure Do_Action (Hook_Name : String;
                        Value     : Array_Type;
                        This      : Wp_Customize_Manager)
   is null;

   procedure Do_Action (Hook_Name : String;
                        Value     : String;
                        Value_2   : Array_Type;
                        This      : Wp_Customize_Manager)
   is null;

   type Proc_Access is access procedure (This : in out Wp_Customize_Manager);

   function To_Array (This : Wp_Customize_Manager;
                      CB   : Proc_Access)
                      return Callable;

   function To_Array (This : Wp_Customize_Manager;
                      CB   : Proc_Access)
                      return Callable
   is
   begin
      return null;
   end To_Array;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Args : Array_Type)
                         return Wp_Customize_Manager
   is
      use Binder;
      use Php;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Plugins;
      use Inc_Themes;

      This_Ref : constant Manager_Ref := -- not null access Wp_Customize_Manager
        new Wp_Customize_Manager; -- XXX

      This : Wp_Customize_Manager renames This_Ref.all;

      Args_2 : Array_Type :=
        Array_Merge (
          Array_Fill_Keys (To_List (List => (
            +"changeset_uuid", +"theme", +"messenger_channel", +"settings_previewed",
            +"autosaved", +"branching")), From_Null),
          Args
        );
      Components : List_Type;
   begin
      -- Note that the UUID format will be validated in the setup_theme() method.
      if not Isset (Args, "changeset_uuid") then
         Set (Args_2, "changeset_uuid", From_String (Wp_Generate_UUID4));
      end if;

      -- The theme and messenger_channel should be supplied via args,
      -- but they are also looked at in the _REQUEST global here for back-compat.
      if not Isset (Args_2, "theme") then
         if Isset (X_REQUEST, "customize_theme") then
            Set (Args_2, "theme", From_String (
                 Wp_Unslash (As_String (Get (X_REQUEST, "customize_theme")))));
         elsif Isset (X_REQUEST, "theme") then -- Deprecated.
            Set (Args_2, "theme", From_String (
                 Wp_Unslash (As_String (Get (X_REQUEST, "theme")))));
         end if;
      end if;

      if
        not Isset (Args_2, "messenger_channel") and then
        Isset (X_REQUEST, "customize_messenger_channel")
      then
         Set (Args_2, "messenger_channel", From_String (
              Sanitize_Key (
                Wp_Unslash (As_String (Get (X_REQUEST, "customize_messenger_channel")))
              )));
      end if;

      This.Original_Stylesheet := +Get_Stylesheet;

      This.Theme :=
        Wp_Get_Theme (if 0 = Validate_File (As_String (Get (Args_2, "theme")))
                      then As_String (Get (Args, "theme")) else ""); -- null

      This.Messenger_Channel   := +As_String (Get (Args_2, "messenger_channel"));
      This.X_Changeset_UUID    := +As_String (Get (Args_2, "changeset_uuid"));

      for
        Key of To_List (List => (+"settings_previewed", +"autosaved", +"branching"))
      loop
         if In_Array (-Key, Args_2) then -- Isset (Args_2, Key) then
            null;
--          This.Key := As_Boolean (Get (Args_2, Key)); -- (bool)
         end if;
      end loop;

      --
      -- Filters the core Customizer components to load.
      --
      -- This allows Core components to be excluded from being instantiated by
      -- filtering them out of the array. Note that this filter generally runs
      -- during the {@see "plugins_loaded"} action, so it cannot be added
      -- in a theme.
      --
      -- @since 4.4.0
      --
      -- @see WP_Customize_Manager::__construct()
      --
      -- @param string[]             components Array of core components to load.
      -- @param WP_Customize_Manager manager    WP_Customize_Manager instance.
      --
      Components :=
        Apply_Filters ("customize_loaded_components", This.Components, This);

      This.Selective_Refresh :=
        Cust_Class_Wp_Customize_Selective_Refresh.X_Construct (This_Ref);

      if In_Array ("widgets", Components, True) then
         This.Widgets :=
           Inc_Class_Wp_Customize_Widgets.X_Construct (This_Ref);
      end if;

      if In_Array ("nav_menus", Components, True) then
         This.Nav_Menus :=
           Inc_Class_Wp_Customize_Nav_Menus.X_Construct (This_Ref);
      end if;

      Add_Action ("setup_theme", To_Array (This, Setup_Theme'Access));
      Add_Action ("wp_loaded",   To_Array (This, Wp_Loaded'Access));
      raise Program_Error with "not implemented";
      -- -- Do not spawn cron (especially the alternate cron) while running the
      -- -- Customizer.
      -- Remove_Action ("init", Wp_Cron'Access);

      -- -- Do not run update checks when rendering the controls.
      -- Remove_Action ("admin_init", X_Maybe_Update_Core'Access);
      -- Remove_Action ("admin_init", X_Maybe_Update_Plugins'Access);
      -- Remove_Action ("admin_init", X_Maybe_Update_Themes'Access);

      -- Add_Action ("wp_ajax_customize_save",
      --             To_Array (This, Save'Access));
      -- Add_Action ("wp_ajax_customize_trash",
      --             To_Array (This, Handle_Changeset_Trash_Request'Access));
      -- Add_Action ("wp_ajax_customize_refresh_nonces",
      --             To_Array (This, Refresh_Nonces'Access));
      -- Add_Action ("wp_ajax_customize_load_themes",
      --             To_Array (This, Handle_Load_Themes_Request'Access));
      -- Add_Filter ("heartbeat_settings",
      --             To_Array (This, Add_Customize_Screen_To_Heartbeat_Settings'Access));
      -- Add_Filter ("heartbeat_received",
      --             To_Array (This, Check_Changeset_Lock_With_Heartbeat'Access), 10, 3);
      -- Add_Action ("wp_ajax_customize_override_changeset_lock",
      --             To_Array (This, Handle_Override_Changeset_Lock_Request'Access));
      -- Add_Action ("wp_ajax_customize_dismiss_autosave_or_lock",
      --             To_Array (This, Handle_Dismiss_Autosave_Or_Lock_Request'Access));

      -- Add_Action ("customize_register",
      --             To_Array (This, Register_Controls'Access));
      -- Add_Action ("customize_register",
      --             To_Array (This, Register_Dynamic_Settings'Access), 11);

      -- -- Allow code to create settings first.
      -- Add_Action ("customize_controls_init",
      --             To_Array (This, Prepare_Controls'Access));
      -- Add_Action ("customize_controls_enqueue_scripts",
      --             To_Array (This, Enqueue_Control_Scripts'Access));

      -- -- Render Common, Panel, Section, and Control templates.
      -- Add_Action ("customize_controls_print_footer_scripts",
      --             To_Array (This, Render_Panel_Templates'Access), 1);
      -- Add_Action ("customize_controls_print_footer_scripts",
      --             To_Array (This, Render_Section_Templates'Access), 1);
      -- Add_Action ("customize_controls_print_footer_scripts",
      --             To_Array (This, Render_Control_Templates'Access), 1);

      -- -- Export header video settings with the partial response.
      -- Add_Filter ("customize_render_partials_response",
      --             To_Array (This, Export_Header_Video_Settings'Access), 10, 3);

      -- -- Export the settings to JS via the _wpCustomizeSettings variable.
      -- Add_Action ("customize_controls_print_footer_scripts",
      --             To_Array (This, Customize_Pane_Settings'Access), 1000);

      -- Add theme update notices.
      if
        Current_User_Can ("install_themes") or else
        Current_User_Can ("update_themes")
      then
         null;
--       require_once ABSPATH . "wp-admin/includes/update.php";
--       Add_Action ("customize_controls_print_footer_scripts",
--                   Wp_Print_Admin_Notice_Templates'Access);
      end if;

      return This;
   end X_Construct;

   ----------------
   -- Doing_AJAX --
   ----------------

   function Doing_AJAX (This   : Wp_Customize_Manager;
                        Action : String := "") -- null
                        return Boolean
   is
      use Binder;
      use Inc_Formatting;
      use Inc_Load;
   begin
      if not Wp_Doing_AJAX then
         return False;
      end if;

      if Action = "" then
         return True;
      else
         --
         -- Note: we can't just use doing_action( "wp_ajax_{action}" ) because
         -- we need to check before admin-ajax.php gets to that point.
         --
         return
           Isset (X_REQUEST, "action") and then
           Wp_Unslash (As_String (Get (X_REQUEST, "action"))) = Action;
      end if;
   end Doing_AJAX;

--         --
--         -- Custom wp_die wrapper. Returns either the standard message for UI
--         -- or the Ajax message.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string|WP_Error ajax_message Ajax return.
--         -- @param string          message      Optional. UI message.
--         --
--         protected function wp_die( ajax_message, message = null ) then
--                 if ( this->doing_ajax() ) then
--                         wp_die( ajax_message );
--                 end;

--                 if ( ! message ) then
--                         message = __( "Something went wrong." );
--                 end;

--                 if ( this->messenger_channel ) then
--                         ob_start();
--                         wp_enqueue_scripts();
--                         wp_print_scripts( array( "customize-base" ) );

--                         settings = array(
--                                 "messengerArgs" => array(
--                                         "channel" => this->messenger_channel,
--                                         "url"     => wp_customize_url(),
--                                 ),
--                                 "error"         => ajax_message,
--                         );
--                         ?>
--                         <script>
--                         ( function( api, settings ) then
--                                 var preview = new api.Messenger( settings.messengerArgs );
--                                 preview.send( "iframe-loading-error", settings.error );
--                         end; )( wp.customize, <?php echo wp_json_encode( settings ); ?> );
--                         </script>
--                         <?php
--                         message .= ob_get_clean();
--                 end;

--                 wp_die( message );
--         end;

--         --
--         -- Returns the Ajax wp_die() handler if it"s a customized request.
--         --
--         -- @since 3.4.0
--         -- @deprecated 4.7.0
--         --
--         -- @return callable Die handler.
--         --
--         public function wp_die_handler() then
--                 _deprecated_function( __METHOD__, "4.7.0" );

--                 if ( this->doing_ajax() || isset( _POST["customized"] ) ) then
--                         return "_ajax_wp_die_handler";
--                 end;

--                 return "_default_wp_die_handler";
--         end;

   -----------------
   -- Setup_Theme --
   -----------------

   procedure Setup_Theme (This : in out Wp_Customize_Manager)
   is
   begin
      raise Program_Error with "not implemented";
   end Setup_Theme;
--                 global pagenow;

--                 -- Check permissions for customize.php access since this method is called before customize.php can run any code.
--                 if ( "customize.php" === pagenow && ! current_user_can( "customize" ) ) then
--                         if ( ! is_user_logged_in() ) then
--                                 auth_redirect();
--                         end; else then
--                                 wp_die(
--                                         "<h1>" . __( "You need a higher level of permission." ) . "</h1>" .
--                                         "<p>" . __( "Sorry, you are not allowed to customize this site." ) . "</p>",
--                                         403
--                                 );
--                         end;
--                         return;
--                 end;

--                 -- If a changeset was provided is invalid.
--                 if ( isset( this->_changeset_uuid ) && false !== this->_changeset_uuid && ! wp_is_uuid( this->_changeset_uuid ) ) then
--                         this->wp_die( -1, __( "Invalid changeset UUID" ) );
--                 end;

--                 /*
--                 -- Clear incoming post data if the user lacks a CSRF token (nonce). Note that the customizer
--                 -- application will inject the customize_preview_nonce query parameter into all Ajax requests.
--                 -- For similar behavior elsewhere in WordPress, see rest_cookie_check_errors() which logs out
--                 -- a user when a valid nonce isn"t present.
--                 --
--                 has_post_data_nonce = (
--                         check_ajax_referer( "preview-customize_" . this->get_stylesheet(), "nonce", false )
--                         ||
--                         check_ajax_referer( "save-customize_" . this->get_stylesheet(), "nonce", false )
--                         ||
--                         check_ajax_referer( "preview-customize_" . this->get_stylesheet(), "customize_preview_nonce", false )
--                 );
--                 if ( ! current_user_can( "customize" ) || ! has_post_data_nonce ) then
--                         unset( _POST["customized"] );
--                         unset( _REQUEST["customized"] );
--                 end;

--                 /*
--                 -- If unauthenticated then require a valid changeset UUID to load the preview.
--                 -- In this way, the UUID serves as a secret key. If the messenger channel is present,
--                 -- then send unauthenticated code to prompt re-auth.
--                 --
--                 if ( ! current_user_can( "customize" ) && ! this->changeset_post_id() ) then
--                         this->wp_die( this->messenger_channel ? 0 : -1, __( "Non-existent changeset UUID." ) );
--                 end;

--                 if ( ! headers_sent() ) then
--                         send_origin_headers();
--                 end;

--                 -- Hide the admin bar if we"re embedded in the customizer iframe.
--                 if ( this->messenger_channel ) then
--                         show_admin_bar( false );
--                 end;

--                 if ( this->is_theme_active() ) then
--                         -- Once the theme is loaded, we"ll validate it.
--                         add_action( "after_setup_theme", array( this, "after_setup_theme" ) );
--                 end; else then
--                         -- If the requested theme is not the active theme and the user doesn"t have
--                         -- the switch_themes cap, bail.
--                         if ( ! current_user_can( "switch_themes" ) ) then
--                                 this->wp_die( -1, __( "Sorry, you are not allowed to edit theme options on this site." ) );
--                         end;

--                         -- If the theme has errors while loading, bail.
--                         if ( this->theme()->errors() ) then
--                                 this->wp_die( -1, this->theme()->errors()->get_error_message() );
--                         end;

--                         -- If the theme isn"t allowed per multisite settings, bail.
--                         if ( ! this->theme()->is_allowed() ) then
--                                 this->wp_die( -1, __( "The requested theme does not exist." ) );
--                         end;
--                 end;

--                 -- Make sure changeset UUID is established immediately after the theme is loaded.
--                 add_action( "after_setup_theme", array( this, "establish_loaded_changeset" ), 5 );

--                 /*
--                 -- Import theme starter content for fresh installations when landing in the customizer.
--                 -- Import starter content at after_setup_theme:100 so that any
--                 -- add_theme_support( "starter-content" ) calls will have been made.
--                 --
--                 if ( get_option( "fresh_site" ) && "customize.php" === pagenow ) then
--                         add_action( "after_setup_theme", array( this, "import_theme_starter_content" ), 100 );
--                 end;

--                 this->start_previewing_theme();
--         end;

   --------------------------------
   -- Establish_Loaded_Changeset --
   --------------------------------

   procedure Establish_Loaded_Changeset (This : in out Wp_Customize_Manager)
   is
      use Php;
      use Inc_Class_Wp_Posts;
      use Inc_Functions;
      use Inc_Load;
      use Inc_Posts;
   begin
      if Empty (-This.X_Changeset_UUID) then
         declare
            Changeset_UUID : Unbounded_String; -- null
         begin
            if not This.Branching and then This.Is_Theme_Active then
               declare
                  Unpublished_Changeset_Posts : constant Post_Array :=
                    This.Get_Changeset_Posts (
                      To_Array (List => (
                        Build ("post_status",
                               Array_Diff (Get_Post_Stati, To_List (List => (
                                 +"auto-draft", +"publish", +"trash",
                                 +"inherit", +"private")))),
                        Build ("exclude_restore_dismissed", False),
                        Build ("author",                    "any"),
                        Build ("posts_per_page",            1),
                        Build ("order",                     "DESC"),
                        Build ("orderby",                   "date")
                      ))
                    );
               begin
                  if Unpublished_Changeset_Posts.Length not in 0 then
                     declare
                        Unpublished_Changeset_Post : constant Wp_Post :=
                          Unpublished_Changeset_Posts
                            (Unpublished_Changeset_Posts.First_Index);
--                          Array_Shift (Unpublished_Changeset_Posts);
                     begin
                        if
--                        not Empty (Unpublished_Changeset_Post) and then
                          Wp_Is_UUID (-Unpublished_Changeset_Post.Post_Name)
                        then
                           Changeset_UUID := Unpublished_Changeset_Post.Post_Name;
                        end if;
                     end;
                  end if;
               end;
            end if;

            -- If no changeset UUID has been set yet, then generate a new one.
            if Empty (-Changeset_UUID) then
               Changeset_UUID := +Wp_Generate_UUID4;
            end if;

            This.X_Changeset_UUID := Changeset_UUID;
         end;
      end if;

      if Is_Admin and then "customize.php" = Globals.Pagenow then
         This.Set_Changeset_Lock (This.Changeset_Post_Id);
      end if;
   end Establish_Loaded_Changeset;

--         --
--         -- Callback to validate a theme once it is loaded
--         --
--         -- @since 3.4.0
--         --
--         public function after_setup_theme() then
--                 doing_ajax_or_is_customized = ( this->doing_ajax() || isset( _POST["customized"] ) );
--                 if ( ! doing_ajax_or_is_customized && ! validate_current_theme() ) then
--                         wp_redirect( "themes.php?broken=true" );
--                         exit;
--                 end;
--         end;

--         --
--         -- If the theme to be previewed isn"t the active theme, add filter callbacks
--         -- to swap it out at runtime.
--         --
--         -- @since 3.4.0
--         --
--         public function start_previewing_theme() then
--                 -- Bail if we"re already previewing.
--                 if ( this->is_preview() ) then
--                         return;
--                 end;

--                 this->previewing = true;

--                 if ( ! this->is_theme_active() ) then
--                         add_filter( "template", array( this, "get_template" ) );
--                         add_filter( "stylesheet", array( this, "get_stylesheet" ) );
--                         add_filter( "pre_option_current_theme", array( this, "current_theme" ) );

--                         -- @link: https://core.trac.wordpress.org/ticket/20027
--                         add_filter( "pre_option_stylesheet", array( this, "get_stylesheet" ) );
--                         add_filter( "pre_option_template", array( this, "get_template" ) );

--                         -- Handle custom theme roots.
--                         add_filter( "pre_option_stylesheet_root", array( this, "get_stylesheet_root" ) );
--                         add_filter( "pre_option_template_root", array( this, "get_template_root" ) );
--                 end;

--                 --
--                 -- Fires once the Customizer theme preview has started.
--                 --
--                 -- @since 3.4.0
--                 --
--                 -- @param WP_Customize_Manager manager WP_Customize_Manager instance.
--                 --
--                 do_action( "start_previewing_theme", this );
--         end;

--         --
--         -- Stops previewing the selected theme.
--         --
--         -- Removes filters to change the active theme.
--         --
--         -- @since 3.4.0
--         --
--         public function stop_previewing_theme() then
--                 if ( ! this->is_preview() ) then
--                         return;
--                 end;

--                 this->previewing = false;

--                 if ( ! this->is_theme_active() ) then
--                         remove_filter( "template", array( this, "get_template" ) );
--                         remove_filter( "stylesheet", array( this, "get_stylesheet" ) );
--                         remove_filter( "pre_option_current_theme", array( this, "current_theme" ) );

--                         -- @link: https://core.trac.wordpress.org/ticket/20027
--                         remove_filter( "pre_option_stylesheet", array( this, "get_stylesheet" ) );
--                         remove_filter( "pre_option_template", array( this, "get_template" ) );

--                         -- Handle custom theme roots.
--                         remove_filter( "pre_option_stylesheet_root", array( this, "get_stylesheet_root" ) );
--                         remove_filter( "pre_option_template_root", array( this, "get_template_root" ) );
--                 end;

--                 --
--                 -- Fires once the Customizer theme preview has stopped.
--                 --
--                 -- @since 3.4.0
--                 --
--                 -- @param WP_Customize_Manager manager WP_Customize_Manager instance.
--                 --
--                 do_action( "stop_previewing_theme", this );
--         end;

   ------------------------
   -- Settings_Previewed --
   ------------------------

   function Settings_Previewed (This : Wp_Customize_Manager)
                                return Boolean
   is
   begin
      return This.M_Settings_Previewed;
   end Settings_Previewed;

--         --
--         -- Gets whether data from a changeset"s autosaved revision should be loaded if it exists.
--         --
--         -- @since 4.9.0
--         --
--         -- @see WP_Customize_Manager::changeset_data()
--         --
--         -- @return bool Is using autosaved changeset revision.
--         --
--         public function autosaved() then
--                 return this->autosaved;
--         end;

   ---------------
   -- Branching --
   ---------------

   function Branching (This : in out Wp_Customize_Manager)
                       return Boolean
   --
   -- Filters whether or not changeset branching is allowed.
   --
   -- By default in core, when changeset branching is not allowed, changesets will
   -- operate linearly in that only one saved changeset will exist at a time (with a
   -- "draft" or "future" status). This makes the Customizer operate in a way that is
   -- similar to going to "edit" to one existing post: all users will be making
   -- changes to the same post, and autosave revisions will be made for that post.
   --
   -- By contrast, when changeset branching is allowed, then the model is like users
   -- going to "add new" for a page and each user makes changes independently of each
   -- other since they are all operating on their own separate pages, each getting
   -- their own separate initial auto-drafts and then once initially saved, autosave
   -- revisions on top of that user's specific post.
   --
   -- Since linear changesets are deemed to be more suitable for the majority of
   -- WordPress users, they are the default. For WordPress sites that have heavy site
   -- management in the Customizer by multiple users then branching changesets should
   -- be enabled by means of this filter.
   --
   -- @since 4.9.0
   --
   -- @param bool                 allow_branching Whether branching is allowed. If
   --                                              `false`, the default, then only
   --                                              one saved changeset exists at a
   --                                              time.
   -- @param WP_Customize_Manager wp_customize    Manager instance.
   --
   is
--    use Inc_Plugins;
   begin
      This.M_Branching :=
        Apply_Filters ("customize_changeset_branching", This.M_Branching, This);

      return This.M_Branching;
   end Branching;

   --------------------
   -- Changeset_UUID --
   --------------------

   function Changeset_UUID (This : in out Wp_Customize_Manager)
                            return String
   is
   begin
      if Empty (-This.X_Changeset_UUID) then
         This.Establish_Loaded_Changeset;
      end if;
      return -This.X_Changeset_UUID;
   end Changeset_UUID;

--         --
--         -- Gets the theme being customized.
--         --
--         -- @since 3.4.0
--         --
--         -- @return WP_Theme
--         --
--         public function theme() then
--                 if ( ! this->theme ) then
--                         this->theme = wp_get_theme();
--                 end;
--                 return this->theme;
--         end;

--         --
--         -- Gets the registered settings.
--         --
--         -- @since 3.4.0
--         --
--         -- @return array
--         --
--         public function settings() then
--                 return this->settings;
--         end;

--         --
--         -- Gets the registered controls.
--         --
--         -- @since 3.4.0
--         --
--         -- @return array
--         --
--         public function controls() then
--                 return this->controls;
--         end;

--         --
--         -- Gets the registered containers.
--         --
--         -- @since 4.0.0
--         --
--         -- @return array
--         --
--         public function containers() then
--                 return this->containers;
--         end;

--         --
--         -- Gets the registered sections.
--         --
--         -- @since 3.4.0
--         --
--         -- @return array
--         --
--         public function sections() then
--                 return this->sections;
--         end;

--         --
--         -- Gets the registered panels.
--         --
--         -- @since 4.0.0
--         --
--         -- @return array Panels.
--         --
--         public function panels() then
--                 return this->panels;
--         end;

   ---------------------
   -- Is_Theme_Active --
   ---------------------

   function Is_Theme_Active (This : Wp_Customize_Manager)
                             return Boolean
   is
   begin
      return This.Get_Stylesheet = This.Original_Stylesheet;
   end Is_Theme_Active;

   ---------------
   -- Wp_Loaded --
   ---------------

   procedure Wp_Loaded (This : in out Wp_Customize_Manager)
   is
   begin
      raise Program_Error with "not implemented";
   end Wp_Loaded;
--         public function wp_loaded() then

--                 -- Unconditionally register core types for panels, sections, and controls
--                 -- in case plugin unhooks all customize_register actions.
--                 this->register_panel_type( "WP_Customize_Panel" );
--                 this->register_panel_type( "WP_Customize_Themes_Panel" );
--                 this->register_section_type( "WP_Customize_Section" );
--                 this->register_section_type( "WP_Customize_Sidebar_Section" );
--                 this->register_section_type( "WP_Customize_Themes_Section" );
--                 this->register_control_type( "WP_Customize_Color_Control" );
--                 this->register_control_type( "WP_Customize_Media_Control" );
--                 this->register_control_type( "WP_Customize_Upload_Control" );
--                 this->register_control_type( "WP_Customize_Image_Control" );
--                 this->register_control_type( "WP_Customize_Background_Image_Control" );
--                 this->register_control_type( "WP_Customize_Background_Position_Control" );
--                 this->register_control_type( "WP_Customize_Cropped_Image_Control" );
--                 this->register_control_type( "WP_Customize_Site_Icon_Control" );
--                 this->register_control_type( "WP_Customize_Theme_Control" );
--                 this->register_control_type( "WP_Customize_Code_Editor_Control" );
--                 this->register_control_type( "WP_Customize_Date_Time_Control" );

--                 --
--                 -- Fires once WordPress has loaded, allowing scripts and styles to be initialized.
--                 --
--                 -- @since 3.4.0
--                 --
--                 -- @param WP_Customize_Manager manager WP_Customize_Manager instance.
--                 --
--                 do_action( "customize_register", this );

--                 if ( this->settings_previewed() ) then
--                         foreach ( this->settings as setting ) then
--                                 setting->preview();
--                         end;
--                 end;

--                 if ( this->is_preview() && ! is_admin() ) then
--                         this->customize_preview_init();
--                 end;
--         end;

--         --
--         -- Prevents Ajax requests from following redirects when previewing a theme
--         -- by issuing a 200 response instead of a 30x.
--         --
--         -- Instead, the JS will sniff out the location header.
--         --
--         -- @since 3.4.0
--         -- @deprecated 4.7.0
--         --
--         -- @param int status Status.
--         -- @return int
--         --
--         public function wp_redirect_status( status ) then
--                 _deprecated_function( __FUNCTION__, "4.7.0" );

--                 if ( this->is_preview() && ! is_admin() ) then
--                         return 200;
--                 end;

--                 return status;
--         end;

   ----------------------------
   -- Find_Changeset_Post_Id --
   ----------------------------

   function Find_Changeset_Post_Id (This : Wp_Customize_Manager;
                                    UUID : String)
                                    return Post_Id -- Natural
   is
      use Inc_Caches;
      use Inc_Class_Wp_Posts;
      use Inc_Class_Wp_Querys;
      use Inc_Posts;

      Cache_Group       : constant String  := "customize_changeset_post";
      Found             : Boolean;
      Changeset_Post_Id : Post_Id := Post_Id (Integer'(
        Wp_Cache_Get (UUID, Cache_Group, Found => Found)));
   begin
      if
        Changeset_Post_Id not in 0 and then
        "customize_changeset" = Get_Post_Type (Changeset_Post_Id)
      then
         return Changeset_Post_Id;
      end if;

      declare
         Changeset_Post_Query : constant Wp_Query := X_Construct (
           To_Array (List => (
             Build ("post_type",              "customize_changeset"),
             Build ("post_status",            Get_Post_Stati),
             Build ("name",                   UUID),
             Build ("posts_per_page",         1),
             Build ("no_found_rows",          True),
             Build ("cache_results",          True),
             Build ("update_post_meta_cache", False),
             Build ("update_post_term_cache", False),
             Build ("lazy_load_term_meta",    False)
           ))
         );
      begin
         if Changeset_Post_Query.Posts not in Empty_Post_Array then
--       if not Empty (Changeset_Post_Query.Posts) then
            -- Note: "fields"=>"ids" is not being used in order to cache the post
            -- object as it will be needed.
            Changeset_Post_Id := Changeset_Post_Query.Posts (0).Id;
            Wp_Cache_Set (UUID, Integer (Changeset_Post_Id), Cache_Group);
            return Changeset_Post_Id;
         end if;
      end;
      return 0; -- null;
   end Find_Changeset_Post_Id;

   -------------------------
   -- Get_Changeset_Posts --
   -------------------------

   function Get_Changeset_Posts (This : Wp_Customize_Manager;
                                 Args : Array_Type)
                                 return Inc_Class_Wp_Posts.Post_Array
   is
      use Php;
      use Inc_Posts;
      use Inc_Users;

      Default_Args : Array_Type := To_Array (List => (
        Build ("exclude_restore_dismissed", True),
        Build ("posts_per_page",            -1),
        Build ("post_type",                 "customize_changeset"),
        Build ("post_status",               "auto-draft"),
        Build ("order",                     "DESC"),
        Build ("orderby",                   "date"),
        Build ("no_found_rows",             True),
        Build ("cache_results",             True),
        Build ("update_post_meta_cache",    False),
        Build ("update_post_term_cache",    False),
        Build ("lazy_load_term_meta",       False)
      ));

      Args_2 : Array_Type;
   begin
      if Get_Current_User_Id /= 0 then
         Set (Default_Args, "author", From_Integer (Get_Current_User_Id));
      end if;

      Args_2 := Array_Merge (Default_Args, Args);

      if not Empty (Args_2, "exclude_restore_dismissed") then
         Delete (Ref (Args_2, "exclude_restore_dismissed"));
         Set (Args_2, "meta_query", From_Array (To_Array (List => (1 =>
              To_Array (List => (
                Build ("key",     "_customize_restore_dismissed"),
                Build ("compare", "NOT EXISTS")
              ))
             ))));
      end if;

      return Get_Posts (Args_2);
   end Get_Changeset_Posts;

--         --
--         -- Dismisses all of the current user"s auto-drafts (other than the present one).
--         --
--         -- @since 4.9.0
--         -- @return int The number of auto-drafts that were dismissed.
--         --
--         protected function dismiss_user_auto_draft_changesets() then
--                 changeset_autodraft_posts = this->get_changeset_posts(
--                         array(
--                                 "post_status"               => "auto-draft",
--                                 "exclude_restore_dismissed" => true,
--                                 "posts_per_page"            => -1,
--                         )
--                 );
--                 dismissed                 = 0;
--                 foreach ( changeset_autodraft_posts as autosave_autodraft_post ) then
--                         if ( autosave_autodraft_post->ID === this->changeset_post_id() ) then
--                                 continue;
--                         end;
--                         if ( update_post_meta( autosave_autodraft_post->ID, "_customize_restore_dismissed", true ) ) then
--                                 dismissed++;
--                         end;
--                 end;
--                 return dismissed;
--         end;

   -----------------------
   -- Changeset_Post_Id --
   -----------------------

   function Changeset_Post_Id (This : in out Wp_Customize_Manager)
                               return Post_Id -- Natural
   is
      Post : Post_Id;
   begin
      if not This.X_Changeset_Post_Id_Set then
--    if not Isset (This.X_Changeset_Post_Id) then
         Post := This.Find_Changeset_Post_Id (This.Changeset_UUID);
         if Post in 0 then
--       if not Post_Id then
--          Post_Id := False;
            This.X_Changeset_Post_Id_Set := False;
         end if;
         This.X_Changeset_Post_Id := Post;
      end if;

      if not This.X_Changeset_Post_Id_Set then
         return 0; -- null
      end if;
      return This.X_Changeset_Post_Id;
   end Changeset_Post_Id;

--         --
--         -- Gets the data stored in a changeset post.
--         --
--         -- @since 4.7.0
--         --
--         -- @param int post_id Changeset post ID.
--         -- @return array|WP_Error Changeset data or WP_Error on error.
--         --
--         protected function get_changeset_post_data( post_id ) then
--                 if ( ! post_id ) then
--                         return new WP_Error( "empty_post_id" );
--                 end;
--                 changeset_post = get_post( post_id );
--                 if ( ! changeset_post ) then
--                         return new WP_Error( "missing_post" );
--                 end;
--                 if ( "revision" === changeset_post->post_type ) then
--                         if ( "customize_changeset" !== get_post_type( changeset_post->post_parent ) ) then
--                                 return new WP_Error( "wrong_post_type" );
--                         end;
--                 end; elseif ( "customize_changeset" !== changeset_post->post_type ) then
--                         return new WP_Error( "wrong_post_type" );
--                 end;
--                 changeset_data = json_decode( changeset_post->post_content, true );
--                 last_error     = json_last_error();
--                 if ( last_error ) then
--                         return new WP_Error( "json_parse_error", "", last_error );
--                 end;
--                 if ( ! is_array( changeset_data ) ) then
--                         return new WP_Error( "expected_array" );
--                 end;
--                 return changeset_data;
--         end;

--         --
--         -- Gets changeset data.
--         --
--         -- @since 4.7.0
--         -- @since 4.9.0 This will return the changeset"s data with a user"s autosave revision merged on top, if one exists and autosaved is true.
--         --
--         -- @return array Changeset data.
--         --
--         public function changeset_data() then
--                 if ( isset( this->_changeset_data ) ) then
--                         return this->_changeset_data;
--                 end;
--                 changeset_post_id = this->changeset_post_id();
--                 if ( ! changeset_post_id ) then
--                         this->_changeset_data = array();
--                 end; else then
--                         if ( this->autosaved() && is_user_logged_in() ) then
--                                 autosave_post = wp_get_post_autosave( changeset_post_id, get_current_user_id() );
--                                 if ( autosave_post ) then
--                                         data = this->get_changeset_post_data( autosave_post->ID );
--                                         if ( ! is_wp_error( data ) ) then
--                                                 this->_changeset_data = data;
--                                         end;
--                                 end;
--                         end;

--                         -- Load data from the changeset if it was not loaded from an autosave.
--                         if ( ! isset( this->_changeset_data ) ) then
--                                 data = this->get_changeset_post_data( changeset_post_id );
--                                 if ( ! is_wp_error( data ) ) then
--                                         this->_changeset_data = data;
--                                 end; else then
--                                         this->_changeset_data = array();
--                                 end;
--                         end;
--                 end;
--                 return this->_changeset_data;
--         end;

--         --
--         -- Starter content setting IDs.
--         --
--         -- @since 4.7.0
--         -- @var array
--         --
--         protected pending_starter_content_settings_ids = array();

--         --
--         -- Imports theme starter content into the customized state.
--         --
--         -- @since 4.7.0
--         --
--         -- @param array starter_content Starter content. Defaults to `get_theme_starter_content()`.
--         --
--         public function import_theme_starter_content( starter_content = array() ) then
--                 if ( empty( starter_content ) ) then
--                         starter_content = get_theme_starter_content();
--                 end;

--                 changeset_data = array();
--                 if ( this->changeset_post_id() ) then
--                         /*
--                         -- Don"t re-import starter content into a changeset saved persistently.
--                         -- This will need to be revisited in the future once theme switching
--                         -- is allowed with drafted/scheduled changesets, since switching to
--                         -- another theme could result in more starter content being applied.
--                         -- However, when doing an explicit save it is currently possible for
--                         -- nav menus and nav menu items specifically to lose their starter_content
--                         -- flags, thus resulting in duplicates being created since they fail
--                         -- to get re-used. See #40146.
--                         --
--                         if ( "auto-draft" !== get_post_status( this->changeset_post_id() ) ) then
--                                 return;
--                         end;

--                         changeset_data = this->get_changeset_post_data( this->changeset_post_id() );
--                 end;

--                 sidebars_widgets = isset( starter_content["widgets"] ) && ! empty( this->widgets ) ? starter_content["widgets"] : array();
--                 attachments      = isset( starter_content["attachments"] ) && ! empty( this->nav_menus ) ? starter_content["attachments"] : array();
--                 posts            = isset( starter_content["posts"] ) && ! empty( this->nav_menus ) ? starter_content["posts"] : array();
--                 options          = isset( starter_content["options"] ) ? starter_content["options"] : array();
--                 nav_menus        = isset( starter_content["nav_menus"] ) && ! empty( this->nav_menus ) ? starter_content["nav_menus"] : array();
--                 theme_mods       = isset( starter_content["theme_mods"] ) ? starter_content["theme_mods"] : array();

--                 -- Widgets.
--                 max_widget_numbers = array();
--                 foreach ( sidebars_widgets as sidebar_id => widgets ) then
--                         sidebar_widget_ids = array();
--                         foreach ( widgets as widget ) then
--                                 list( id_base, instance ) = widget;

--                                 if ( ! isset( max_widget_numbers[ id_base ] ) ) then

--                                         -- When settings is an array-like object, get an intrinsic array for use with array_keys().
--                                         settings = get_option( "widget_thenid_baseend;", array() );
--                                         if ( settings instanceof ArrayObject || settings instanceof ArrayIterator ) then
--                                                 settings = settings->getArrayCopy();
--                                         end;

--                                         unset( settings["_multiwidget"] );

--                                         -- Find the max widget number for this type.
--                                         widget_numbers = array_keys( settings );
--                                         if ( count( widget_numbers ) > 0 ) then
--                                                 widget_numbers[]               = 1;
--                                                 max_widget_numbers[ id_base ] = max( ...widget_numbers );
--                                         end; else then
--                                                 max_widget_numbers[ id_base ] = 1;
--                                         end;
--                                 end;
--                                 max_widget_numbers[ id_base ] += 1;

--                                 widget_id  = sprintf( "%s-%d", id_base, max_widget_numbers[ id_base ] );
--                                 setting_id = sprintf( "widget_%s[%d]", id_base, max_widget_numbers[ id_base ] );

--                                 setting_value = this->widgets->sanitize_widget_js_instance( instance );
--                                 if ( empty( changeset_data[ setting_id ] ) || ! empty( changeset_data[ setting_id ]["starter_content"] ) ) then
--                                         this->set_post_value( setting_id, setting_value );
--                                         this->pending_starter_content_settings_ids[] = setting_id;
--                                 end;
--                                 sidebar_widget_ids[] = widget_id;
--                         end;

--                         setting_id = sprintf( "sidebars_widgets[%s]", sidebar_id );
--                         if ( empty( changeset_data[ setting_id ] ) || ! empty( changeset_data[ setting_id ]["starter_content"] ) ) then
--                                 this->set_post_value( setting_id, sidebar_widget_ids );
--                                 this->pending_starter_content_settings_ids[] = setting_id;
--                         end;
--                 end;

--                 starter_content_auto_draft_post_ids = array();
--                 if ( ! empty( changeset_data["nav_menus_created_posts"]["value"] ) ) then
--                         starter_content_auto_draft_post_ids = array_merge( starter_content_auto_draft_post_ids, changeset_data["nav_menus_created_posts"]["value"] );
--                 end;

--                 -- Make an index of all the posts needed and what their slugs are.
--                 needed_posts = array();
--                 attachments  = this->prepare_starter_content_attachments( attachments );
--                 foreach ( attachments as attachment ) then
--                         key                  = "attachment:" . attachment["post_name"];
--                         needed_posts[ key ] = true;
--                 end;
--                 foreach ( array_keys( posts ) as post_symbol ) then
--                         if ( empty( posts[ post_symbol ]["post_name"] ) && empty( posts[ post_symbol ]["post_title"] ) ) then
--                                 unset( posts[ post_symbol ] );
--                                 continue;
--                         end;
--                         if ( empty( posts[ post_symbol ]["post_name"] ) ) then
--                                 posts[ post_symbol ]["post_name"] = sanitize_title( posts[ post_symbol ]["post_title"] );
--                         end;
--                         if ( empty( posts[ post_symbol ]["post_type"] ) ) then
--                                 posts[ post_symbol ]["post_type"] = "post";
--                         end;
--                         needed_posts[ posts[ post_symbol ]["post_type"] . ":" . posts[ post_symbol ]["post_name"] ] = true;
--                 end;
--                 all_post_slugs = array_merge(
--                         wp_list_pluck( attachments, "post_name" ),
--                         wp_list_pluck( posts, "post_name" )
--                 );

--                 /*
--                 -- Obtain all post types referenced in starter content to use in query.
--                 -- This is needed because "any" will not account for post types not yet registered.
--                 --
--                 post_types = array_filter( array_merge( array( "attachment" ), wp_list_pluck( posts, "post_type" ) ) );

--                 -- Re-use auto-draft starter content posts referenced in the current customized state.
--                 existing_starter_content_posts = array();
--                 if ( ! empty( starter_content_auto_draft_post_ids ) ) then
--                         existing_posts_query = new WP_Query(
--                                 array(
--                                         "post__in"       => starter_content_auto_draft_post_ids,
--                                         "post_status"    => "auto-draft",
--                                         "post_type"      => post_types,
--                                         "posts_per_page" => -1,
--                                 )
--                         );
--                         foreach ( existing_posts_query->posts as existing_post ) then
--                                 post_name = existing_post->post_name;
--                                 if ( empty( post_name ) ) then
--                                         post_name = get_post_meta( existing_post->ID, "_customize_draft_post_name", true );
--                                 end;
--                                 existing_starter_content_posts[ existing_post->post_type . ":" . post_name ] = existing_post;
--                         end;
--                 end;

--                 -- Re-use non-auto-draft posts.
--                 if ( ! empty( all_post_slugs ) ) then
--                         existing_posts_query = new WP_Query(
--                                 array(
--                                         "post_name__in"  => all_post_slugs,
--                                         "post_status"    => array_diff( get_post_stati(), array( "auto-draft" ) ),
--                                         "post_type"      => "any",
--                                         "posts_per_page" => -1,
--                                 )
--                         );
--                         foreach ( existing_posts_query->posts as existing_post ) then
--                                 key = existing_post->post_type . ":" . existing_post->post_name;
--                                 if ( isset( needed_posts[ key ] ) && ! isset( existing_starter_content_posts[ key ] ) ) then
--                                         existing_starter_content_posts[ key ] = existing_post;
--                                 end;
--                         end;
--                 end;

--                 -- Attachments are technically posts but handled differently.
--                 if ( ! empty( attachments ) ) then

--                         attachment_ids = array();

--                         foreach ( attachments as symbol => attachment ) then
--                                 file_array    = array(
--                                         "name" => attachment["file_name"],
--                                 );
--                                 file_path     = attachment["file_path"];
--                                 attachment_id = null;
--                                 attached_file = null;
--                                 if ( isset( existing_starter_content_posts[ "attachment:" . attachment["post_name"] ] ) ) then
--                                         attachment_post = existing_starter_content_posts[ "attachment:" . attachment["post_name"] ];
--                                         attachment_id   = attachment_post->ID;
--                                         attached_file   = get_attached_file( attachment_id );
--                                         if ( empty( attached_file ) || ! file_exists( attached_file ) ) then
--                                                 attachment_id = null;
--                                                 attached_file = null;
--                                         end; elseif ( this->get_stylesheet() !== get_post_meta( attachment_post->ID, "_starter_content_theme", true ) ) then

--                                                 -- Re-generate attachment metadata since it was previously generated for a different theme.
--                                                 metadata = wp_generate_attachment_metadata( attachment_post->ID, attached_file );
--                                                 wp_update_attachment_metadata( attachment_id, metadata );
--                                                 update_post_meta( attachment_id, "_starter_content_theme", this->get_stylesheet() );
--                                         end;
--                                 end;

--                                 -- Insert the attachment auto-draft because it doesn"t yet exist or the attached file is gone.
--                                 if ( ! attachment_id ) then

--                                         -- Copy file to temp location so that original file won"t get deleted from theme after sideloading.
--                                         temp_file_name = wp_tempnam( wp_basename( file_path ) );
--                                         if ( temp_file_name && copy( file_path, temp_file_name ) ) then
--                                                 file_array["tmp_name"] = temp_file_name;
--                                         end;
--                                         if ( empty( file_array["tmp_name"] ) ) then
--                                                 continue;
--                                         end;

--                                         attachment_post_data = array_merge(
--                                                 wp_array_slice_assoc( attachment, array( "post_title", "post_content", "post_excerpt" ) ),
--                                                 array(
--                                                         "post_status" => "auto-draft", -- So attachment will be garbage collected in a week if changeset is never published.
--                                                 )
--                                         );

--                                         attachment_id = media_handle_sideload( file_array, 0, null, attachment_post_data );
--                                         if ( is_wp_error( attachment_id ) ) then
--                                                 continue;
--                                         end;
--                                         update_post_meta( attachment_id, "_starter_content_theme", this->get_stylesheet() );
--                                         update_post_meta( attachment_id, "_customize_draft_post_name", attachment["post_name"] );
--                                 end;

--                                 attachment_ids[ symbol ] = attachment_id;
--                         end;
--                         starter_content_auto_draft_post_ids = array_merge( starter_content_auto_draft_post_ids, array_values( attachment_ids ) );
--                 end;

--                 -- Posts & pages.
--                 if ( ! empty( posts ) ) then
--                         foreach ( array_keys( posts ) as post_symbol ) then
--                                 if ( empty( posts[ post_symbol ]["post_type"] ) || empty( posts[ post_symbol ]["post_name"] ) ) then
--                                         continue;
--                                 end;
--                                 post_type = posts[ post_symbol ]["post_type"];
--                                 if ( ! empty( posts[ post_symbol ]["post_name"] ) ) then
--                                         post_name = posts[ post_symbol ]["post_name"];
--                                 end; elseif ( ! empty( posts[ post_symbol ]["post_title"] ) ) then
--                                         post_name = sanitize_title( posts[ post_symbol ]["post_title"] );
--                                 end; else then
--                                         continue;
--                                 end;

--                                 -- Use existing auto-draft post if one already exists with the same type and name.
--                                 if ( isset( existing_starter_content_posts[ post_type . ":" . post_name ] ) ) then
--                                         posts[ post_symbol ]["ID"] = existing_starter_content_posts[ post_type . ":" . post_name ]->ID;
--                                         continue;
--                                 end;

--                                 -- Translate the featured image symbol.
--                                 if ( ! empty( posts[ post_symbol ]["thumbnail"] )
--                                         && preg_match( "/^thenthen(?P<symbol>.+)end;end;/", posts[ post_symbol ]["thumbnail"], matches )
--                                         && isset( attachment_ids[ matches["symbol"] ] ) ) then
--                                         posts[ post_symbol ]["meta_input"]["_thumbnail_id"] = attachment_ids[ matches["symbol"] ];
--                                 end;

--                                 if ( ! empty( posts[ post_symbol ]["template"] ) ) then
--                                         posts[ post_symbol ]["meta_input"]["_wp_page_template"] = posts[ post_symbol ]["template"];
--                                 end;

--                                 r = this->nav_menus->insert_auto_draft_post( posts[ post_symbol ] );
--                                 if ( r instanceof WP_Post ) then
--                                         posts[ post_symbol ]["ID"] = r->ID;
--                                 end;
--                         end;

--                         starter_content_auto_draft_post_ids = array_merge( starter_content_auto_draft_post_ids, wp_list_pluck( posts, "ID" ) );
--                 end;

--                 -- The nav_menus_created_posts setting is why nav_menus component is dependency for adding posts.
--                 if ( ! empty( this->nav_menus ) && ! empty( starter_content_auto_draft_post_ids ) ) then
--                         setting_id = "nav_menus_created_posts";
--                         this->set_post_value( setting_id, array_unique( array_values( starter_content_auto_draft_post_ids ) ) );
--                         this->pending_starter_content_settings_ids[] = setting_id;
--                 end;

--                 -- Nav menus.
--                 placeholder_id              = -1;
--                 reused_nav_menu_setting_ids = array();
--                 foreach ( nav_menus as nav_menu_location => nav_menu ) then

--                         nav_menu_term_id    = null;
--                         nav_menu_setting_id = null;
--                         matches             = array();

--                         -- Look for an existing placeholder menu with starter content to re-use.
--                         foreach ( changeset_data as setting_id => setting_params ) then
--                                 can_reuse = (
--                                         ! empty( setting_params["starter_content"] )
--                                         &&
--                                         ! in_array( setting_id, reused_nav_menu_setting_ids, true )
--                                         &&
--                                         preg_match( "#^nav_menu\[(?P<nav_menu_id>-?\d+)\]#", setting_id, matches )
--                                 );
--                                 if ( can_reuse ) then
--                                         nav_menu_term_id              = (int) matches["nav_menu_id"];
--                                         nav_menu_setting_id           = setting_id;
--                                         reused_nav_menu_setting_ids[] = setting_id;
--                                         break;
--                                 end;
--                         end;

--                         if ( ! nav_menu_term_id ) then
--                                 while ( isset( changeset_data[ sprintf( "nav_menu[%d]", placeholder_id ) ] ) ) then
--                                         placeholder_id--;
--                                 end;
--                                 nav_menu_term_id    = placeholder_id;
--                                 nav_menu_setting_id = sprintf( "nav_menu[%d]", placeholder_id );
--                         end;

--                         this->set_post_value(
--                                 nav_menu_setting_id,
--                                 array(
--                                         "name" => isset( nav_menu["name"] ) ? nav_menu["name"] : nav_menu_location,
--                                 )
--                         );
--                         this->pending_starter_content_settings_ids[] = nav_menu_setting_id;

--                         -- @todo Add support for menu_item_parent.
--                         position = 0;
--                         foreach ( nav_menu["items"] as nav_menu_item ) then
--                                 nav_menu_item_setting_id = sprintf( "nav_menu_item[%d]", placeholder_id-- );
--                                 if ( ! isset( nav_menu_item["position"] ) ) then
--                                         nav_menu_item["position"] = position++;
--                                 end;
--                                 nav_menu_item["nav_menu_term_id"] = nav_menu_term_id;

--                                 if ( isset( nav_menu_item["object_id"] ) ) then
--                                         if ( "post_type" === nav_menu_item["type"] && preg_match( "/^thenthen(?P<symbol>.+)end;end;/", nav_menu_item["object_id"], matches ) && isset( posts[ matches["symbol"] ] ) ) then
--                                                 nav_menu_item["object_id"] = posts[ matches["symbol"] ]["ID"];
--                                                 if ( empty( nav_menu_item["title"] ) ) then
--                                                         original_object        = get_post( nav_menu_item["object_id"] );
--                                                         nav_menu_item["title"] = original_object->post_title;
--                                                 end;
--                                         end; else then
--                                                 continue;
--                                         end;
--                                 end; else then
--                                         nav_menu_item["object_id"] = 0;
--                                 end;

--                                 if ( empty( changeset_data[ nav_menu_item_setting_id ] ) || ! empty( changeset_data[ nav_menu_item_setting_id ]["starter_content"] ) ) then
--                                         this->set_post_value( nav_menu_item_setting_id, nav_menu_item );
--                                         this->pending_starter_content_settings_ids[] = nav_menu_item_setting_id;
--                                 end;
--                         end;

--                         setting_id = sprintf( "nav_menu_locations[%s]", nav_menu_location );
--                         if ( empty( changeset_data[ setting_id ] ) || ! empty( changeset_data[ setting_id ]["starter_content"] ) ) then
--                                 this->set_post_value( setting_id, nav_menu_term_id );
--                                 this->pending_starter_content_settings_ids[] = setting_id;
--                         end;
--                 end;

--                 -- Options.
--                 foreach ( options as name => value ) then

--                         -- Serialize the value to check for post symbols.
--                         value = maybe_serialize( value );

--                         if ( is_serialized( value ) ) then
--                                 if ( preg_match( "/s:\d+:"thenthen(?P<symbol>.+)end;end;"/", value, matches ) ) then
--                                         if ( isset( posts[ matches["symbol"] ] ) ) then
--                                                 symbol_match = posts[ matches["symbol"] ]["ID"];
--                                         end; elseif ( isset( attachment_ids[ matches["symbol"] ] ) ) then
--                                                 symbol_match = attachment_ids[ matches["symbol"] ];
--                                         end;

--                                         -- If we have any symbol matches, update the values.
--                                         if ( isset( symbol_match ) ) then
--                                                 -- Replace found string matches with post IDs.
--                                                 value = str_replace( matches[0], "i:thensymbol_matchend;", value );
--                                         end; else then
--                                                 continue;
--                                         end;
--                                 end;
--                         end; elseif ( preg_match( "/^thenthen(?P<symbol>.+)end;end;/", value, matches ) ) then
--                                 if ( isset( posts[ matches["symbol"] ] ) ) then
--                                         value = posts[ matches["symbol"] ]["ID"];
--                                 end; elseif ( isset( attachment_ids[ matches["symbol"] ] ) ) then
--                                         value = attachment_ids[ matches["symbol"] ];
--                                 end; else then
--                                         continue;
--                                 end;
--                         end;

--                         -- Unserialize values after checking for post symbols, so they can be properly referenced.
--                         value = maybe_unserialize( value );

--                         if ( empty( changeset_data[ name ] ) || ! empty( changeset_data[ name ]["starter_content"] ) ) then
--                                 this->set_post_value( name, value );
--                                 this->pending_starter_content_settings_ids[] = name;
--                         end;
--                 end;

--                 -- Theme mods.
--                 foreach ( theme_mods as name => value ) then

--                         -- Serialize the value to check for post symbols.
--                         value = maybe_serialize( value );

--                         -- Check if value was serialized.
--                         if ( is_serialized( value ) ) then
--                                 if ( preg_match( "/s:\d+:"thenthen(?P<symbol>.+)end;end;"/", value, matches ) ) then
--                                         if ( isset( posts[ matches["symbol"] ] ) ) then
--                                                 symbol_match = posts[ matches["symbol"] ]["ID"];
--                                         end; elseif ( isset( attachment_ids[ matches["symbol"] ] ) ) then
--                                                 symbol_match = attachment_ids[ matches["symbol"] ];
--                                         end;

--                                         -- If we have any symbol matches, update the values.
--                                         if ( isset( symbol_match ) ) then
--                                                 -- Replace found string matches with post IDs.
--                                                 value = str_replace( matches[0], "i:thensymbol_matchend;", value );
--                                         end; else then
--                                                 continue;
--                                         end;
--                                 end;
--                         end; elseif ( preg_match( "/^thenthen(?P<symbol>.+)end;end;/", value, matches ) ) then
--                                 if ( isset( posts[ matches["symbol"] ] ) ) then
--                                         value = posts[ matches["symbol"] ]["ID"];
--                                 end; elseif ( isset( attachment_ids[ matches["symbol"] ] ) ) then
--                                         value = attachment_ids[ matches["symbol"] ];
--                                 end; else then
--                                         continue;
--                                 end;
--                         end;

--                         -- Unserialize values after checking for post symbols, so they can be properly referenced.
--                         value = maybe_unserialize( value );

--                         -- Handle header image as special case since setting has a legacy format.
--                         if ( "header_image" === name ) then
--                                 name     = "header_image_data";
--                                 metadata = wp_get_attachment_metadata( value );
--                                 if ( empty( metadata ) ) then
--                                         continue;
--                                 end;
--                                 value = array(
--                                         "attachment_id" => value,
--                                         "url"           => wp_get_attachment_url( value ),
--                                         "height"        => metadata["height"],
--                                         "width"         => metadata["width"],
--                                 );
--                         end; elseif ( "background_image" === name ) then
--                                 value = wp_get_attachment_url( value );
--                         end;

--                         if ( empty( changeset_data[ name ] ) || ! empty( changeset_data[ name ]["starter_content"] ) ) then
--                                 this->set_post_value( name, value );
--                                 this->pending_starter_content_settings_ids[] = name;
--                         end;
--                 end;

--                 if ( ! empty( this->pending_starter_content_settings_ids ) ) then
--                         if ( did_action( "customize_register" ) ) then
--                                 this->_save_starter_content_changeset();
--                         end; else then
--                                 add_action( "customize_register", array( this, "_save_starter_content_changeset" ), 1000 );
--                         end;
--                 end;
--         end;

--         --
--         -- Prepares starter content attachments.
--         --
--         -- Ensure that the attachments are valid and that they have slugs and file name/path.
--         --
--         -- @since 4.7.0
--         --
--         -- @param array attachments Attachments.
--         -- @return array Prepared attachments.
--         --
--         protected function prepare_starter_content_attachments( attachments ) then
--                 prepared_attachments = array();
--                 if ( empty( attachments ) ) then
--                         return prepared_attachments;
--                 end;

--                 -- Such is The WordPress Way.
--                 require_once ABSPATH . "wp-admin/includes/file.php";
--                 require_once ABSPATH . "wp-admin/includes/media.php";
--                 require_once ABSPATH . "wp-admin/includes/image.php";

--                 foreach ( attachments as symbol => attachment ) then

--                         -- A file is required and URLs to files are not currently allowed.
--                         if ( empty( attachment["file"] ) || preg_match( "#^https?:--#", attachment["file"] ) ) then
--                                 continue;
--                         end;

--                         file_path = null;
--                         if ( file_exists( attachment["file"] ) ) then
--                                 file_path = attachment["file"]; -- Could be absolute path to file in plugin.
--                         end; elseif ( is_child_theme() && file_exists( get_stylesheet_directory() . "/" . attachment["file"] ) ) then
--                                 file_path = get_stylesheet_directory() . "/" . attachment["file"];
--                         end; elseif ( file_exists( get_template_directory() . "/" . attachment["file"] ) ) then
--                                 file_path = get_template_directory() . "/" . attachment["file"];
--                         end; else then
--                                 continue;
--                         end;
--                         file_name = wp_basename( attachment["file"] );

--                         -- Skip file types that are not recognized.
--                         checked_filetype = wp_check_filetype( file_name );
--                         if ( empty( checked_filetype["type"] ) ) then
--                                 continue;
--                         end;

--                         -- Ensure post_name is set since not automatically derived from post_title for new auto-draft posts.
--                         if ( empty( attachment["post_name"] ) ) then
--                                 if ( ! empty( attachment["post_title"] ) ) then
--                                         attachment["post_name"] = sanitize_title( attachment["post_title"] );
--                                 end; else then
--                                         attachment["post_name"] = sanitize_title( preg_replace( "/\.\w+/", "", file_name ) );
--                                 end;
--                         end;

--                         attachment["file_name"]         = file_name;
--                         attachment["file_path"]         = file_path;
--                         prepared_attachments[ symbol ] = attachment;
--                 end;
--                 return prepared_attachments;
--         end;

--         --
--         -- Saves starter content changeset.
--         --
--         -- @since 4.7.0
--         --
--         public function _save_starter_content_changeset() then

--                 if ( empty( this->pending_starter_content_settings_ids ) ) then
--                         return;
--                 end;

--                 this->save_changeset_post(
--                         array(
--                                 "data"            => array_fill_keys( this->pending_starter_content_settings_ids, array( "starter_content" => true ) ),
--                                 "starter_content" => true,
--                         )
--                 );
--                 this->saved_starter_content_changeset = true;

--                 this->pending_starter_content_settings_ids = array();
--         end;

   -----------------------------
   -- Unsanitized_Post_Values --
   -----------------------------

   function Unsanitized_Post_Values (This : in out Wp_Customize_Manager;
                                     Args : Array_Type := Empty_Array)
                                     return Array_Type
   is
      use Binder;
      use Php;
      use Php.JSON;
      use Php.Preg;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Options;

      Args_2 : constant Array_Type := Array_Merge (
        To_Array (List => (
          Build ("exclude_changeset", False),
          Build ("exclude_post_data", not Current_User_Can ("customize"))
        )),
        Args
      );

      Values : Array_Type;
   begin
      -- Let default values be from the stashed theme mods if doing a theme switch
      -- and if no changeset is present.
      if not This.Is_Theme_Active then
         declare
            Stashed_Theme_Mods : constant Array_Type :=
              Get_Option ("customize_stashed_theme_mods");
            Stylesheet : constant String := This.Get_Stylesheet;
         begin
            if Isset (Stashed_Theme_Mods, Stylesheet) then
               Values :=
                 Array_Merge
                   (Values,
                    Wp_List_Pluck (As_Array (Get (
                      Stashed_Theme_Mods, Stylesheet)), "value"));
            end if;
         end;
      end if;

      if "" = Get_As_String (Args_2, "exclude_changeset") then
--    if not Get (Args_2, "exclude_changeset") then
         for A in This.X_Changeset_Data.Iterate loop
            declare
               Setting_Id     : constant String     := Key (A);
               Setting_Params : constant Array_Type := As_Array (Element (A));
            begin
               if not Array_Key_Exists ("value", Setting_Params) then
                  goto Continue;
               end if;

               if
                 Isset (Setting_Params, "type") and then
                 "theme_mod" = As_String (Get (Setting_Params, "type"))
               then
                  -- Ensure that theme mods values are only used if they were saved
                  -- under the active theme.
                  declare
                     Namespace_Pattern : constant String :=
                       "/^(?P<stylesheet>.+?)::(?P<setting_id>.+)/";
                     Matches : Array_Type;
                  begin
                     if
                       Preg_Match (Namespace_Pattern, Setting_Id, Matches) /= 0 and then
                       This.Get_Stylesheet = Get_As_String (Matches, "stylesheet")
                     then
                        Set (Values,
                             Key   => Get_As_String (Matches, "setting_id"),
                             Value => Get (Setting_Params, "value"));
                     end if;
                  end;
               else
                  Set (Values, Setting_Id, Get (Setting_Params, "value"));
               end if;
            end;
            << Continue >>
         end loop;
      end if;

      if "" = Get_As_String (Args_2, "exclude_post_data") then -- not
         if not Isset (This.X_Post_Values) then
            declare
               Post_Values : Array_Type;
            begin
               if Isset (X_POST, "customized") then
                  Post_Values :=
                    JSON_Decode (
                      Wp_Unslash (Get_As_String (X_POST, "customized")), True);
               else
                  Post_Values := Empty_Array;
               end if;

               if Is_Array (Post_Values) then
                  This.X_Post_Values := Post_Values;
               else
                  This.X_Post_Values := Empty_Array;
               end if;
            end;
         end if;
         Values := Array_Merge (Values, This.X_Post_Values);
      end if;
      return Values;
   end Unsanitized_Post_Values;

   procedure Unsanitized_Post_Values (This : in out Wp_Customize_Manager;
                                      Args : Array_Type := Empty_Array)
   is
      Unused : constant Array_Type :=
        Unsanitized_Post_Values (This, Args);
   begin
      null;
   end Unsanitized_Post_Values;

   ----------------
   -- Post_Value --
   ----------------

   function Post_Value (This          : in out Wp_Customize_Manager;
                        Setting       : Wp_Customize_Setting;
                        Default_Value : String := "") -- null
                        return String
   is
      use Php;
      use Inc_Class_Wp_Customize_Settings;
      use Inc_Load;

      Post_Values : constant Array_Type :=
        This.Unsanitized_Post_Values;
   begin
      if not Array_Key_Exists (-Setting.Id, Post_Values) then
         return Default_Value;
      end if;

      declare
         Value : Multi_Type := Get (Post_Values, -Setting.Id);
         Valid : constant Validate_Result := Setting.Validate (Value);
      begin
         if Is_Wp_Error (Valid.Error) then
            return Default_Value;
         end if;

         Value := Setting.Sanitize (Value);
         if Is_Null (Value) then -- or else Is_Wp_Error (Value) then
            return Default_Value;
         end if;

         return As_String (Value);
      end;
   end Post_Value;

   --------------------
   -- Set_Post_Value --
   --------------------

   procedure Set_Post_Value (This       : in out Wp_Customize_Manager;
                             Setting_Id : String;
                             Value      : Array_Type)
   is
--    use Inc_Plugins;
   begin
      This.Unsanitized_Post_Values; -- Populate _post_values from _POST["customized"].
      Set (This.X_Post_Values, Setting_Id, From_Array (Value));

      --
      -- Announces when a specific setting's unsanitized post value has been set.
      --
      -- Fires when the WP_Customize_Manager::set_post_value() method is called.
      --
      -- The dynamic portion of the hook name, `setting_id`, refers to the setting ID.
      --
      -- @since 4.4.0
      --
      -- @param mixed                value   Unsanitized setting post value.
      -- @param WP_Customize_Manager manager WP_Customize_Manager instance.
      --
      Do_Action ("customize_post_value_set_" & Setting_Id, Value, This);

      --
      -- Announces when any setting's unsanitized post value has been set.
      --
      -- Fires when the WP_Customize_Manager::set_post_value() method is called.
      --
      -- This is useful for `WP_Customize_Setting` instances to watch
      -- in order to update a cached previewed value.
      --
      -- @since 4.4.0
      --
      -- @param string               setting_id Setting ID.
      -- @param mixed                value      Unsanitized setting post value.
      -- @param WP_Customize_Manager manager    WP_Customize_Manager instance.
      --
      Do_Action ("customize_post_value_set", Setting_Id, Value, This);
   end Set_Post_Value;

--         --
--         -- Prints JavaScript settings.
--         --
--         -- @since 3.4.0
--         --
--         public function customize_preview_init() then

--                 /*
--                 -- Now that Customizer previews are loaded into iframes via GET requests
--                 -- and natural URLs with transaction UUIDs added, we need to ensure that
--                 -- the responses are never cached by proxies. In practice, this will not
--                 -- be needed if the user is logged-in anyway. But if anonymous access is
--                 -- allowed then the auth cookies would not be sent and WordPress would
--                 -- not send no-cache headers by default.
--                 --
--                 if ( ! headers_sent() ) then
--                         nocache_headers();
--                         header( "X-Robots: noindex, nofollow, noarchive" );
--                 end;
--                 add_filter( "wp_robots", "wp_robots_no_robots" );
--                 add_filter( "wp_headers", array( this, "filter_iframe_security_headers" ) );

--                 /*
--                 -- If preview is being served inside the customizer preview iframe, and
--                 -- if the user doesn"t have customize capability, then it is assumed
--                 -- that the user"s session has expired and they need to re-authenticate.
--                 --
--                 if ( this->messenger_channel && ! current_user_can( "customize" ) ) then
--                         this->wp_die(
--                                 -1,
--                                 sprintf(
--                                         /* translators: %s: customize_messenger_channel--
--                                         __( "Unauthorized. You may remove the %s param to preview as frontend." ),
--                                         "<code>customize_messenger_channel<code>"
--                                 )
--                         );
--                         return;
--                 end;

--                 this->prepare_controls();

--                 add_filter( "wp_redirect", array( this, "add_state_query_params" ) );

--                 wp_enqueue_script( "customize-preview" );
--                 wp_enqueue_style( "customize-preview" );
--                 add_action( "wp_head", array( this, "customize_preview_loading_style" ) );
--                 add_action( "wp_head", array( this, "remove_frameless_preview_messenger_channel" ) );
--                 add_action( "wp_footer", array( this, "customize_preview_settings" ), 20 );
--                 add_filter( "get_edit_post_link", "__return_empty_string" );

--                 --
--                 -- Fires once the Customizer preview has initialized and JavaScript
--                 -- settings have been printed.
--                 --
--                 -- @since 3.4.0
--                 --
--                 -- @param WP_Customize_Manager manager WP_Customize_Manager instance.
--                 --
--                 do_action( "customize_preview_init", this );
--         end;

--         --
--         -- Filters the X-Frame-Options and Content-Security-Policy headers to ensure frontend can load in customizer.
--         --
--         -- @since 4.7.0
--         --
--         -- @param array headers Headers.
--         -- @return array Headers.
--         --
--         public function filter_iframe_security_headers( headers ) then
--                 headers["X-Frame-Options"]         = "SAMEORIGIN";
--                 headers["Content-Security-Policy"] = "frame-ancestors "self"";
--                 return headers;
--         end;

--         --
--         -- Adds customize state query params to a given URL if preview is allowed.
--         --
--         -- @since 4.7.0
--         --
--         -- @see wp_redirect()
--         -- @see WP_Customize_Manager::get_allowed_url()
--         --
--         -- @param string url URL.
--         -- @return string URL.
--         --
--         public function add_state_query_params( url ) then
--                 parsed_original_url = wp_parse_url( url );
--                 is_allowed          = false;
--                 foreach ( this->get_allowed_urls() as allowed_url ) then
--                         parsed_allowed_url = wp_parse_url( allowed_url );
--                         is_allowed         = (
--                                 parsed_allowed_url["scheme"] === parsed_original_url["scheme"]
--                                 &&
--                                 parsed_allowed_url["host"] === parsed_original_url["host"]
--                                 &&
--                                 0 === strpos( parsed_original_url["path"], parsed_allowed_url["path"] )
--                         );
--                         if ( is_allowed ) then
--                                 break;
--                         end;
--                 end;

--                 if ( is_allowed ) then
--                         query_params = array(
--                                 "customize_changeset_uuid" => this->changeset_uuid(),
--                         );
--                         if ( ! this->is_theme_active() ) then
--                                 query_params["customize_theme"] = this->get_stylesheet();
--                         end;
--                         if ( this->messenger_channel ) then
--                                 query_params["customize_messenger_channel"] = this->messenger_channel;
--                         end;
--                         url = add_query_arg( query_params, url );
--                 end;

--                 return url;
--         end;

--         --
--         -- Prevents sending a 404 status when returning the response for the customize
--         -- preview, since it causes the jQuery Ajax to fail. Send 200 instead.
--         --
--         -- @since 4.0.0
--         -- @deprecated 4.7.0
--         --
--         public function customize_preview_override_404_status() then
--                 _deprecated_function( __METHOD__, "4.7.0" );
--         end;

--         --
--         -- Prints base element for preview frame.
--         --
--         -- @since 3.4.0
--         -- @deprecated 4.7.0
--         --
--         public function customize_preview_base() then
--                 _deprecated_function( __METHOD__, "4.7.0" );
--         end;

--         --
--         -- Prints a workaround to handle HTML5 tags in IE < 9.
--         --
--         -- @since 3.4.0
--         -- @deprecated 4.7.0 Customizer no longer supports IE8, so all supported browsers recognize HTML5.
--         --
--         public function customize_preview_html5() then
--                 _deprecated_function( __FUNCTION__, "4.7.0" );
--         end;

--         --
--         -- Prints CSS for loading indicators for the Customizer preview.
--         --
--         -- @since 4.2.0
--         --
--         public function customize_preview_loading_style() then
--                 ?>
--                 <style>
--                         body.wp-customizer-unloading then
--                                 opacity: 0.25;
--                                 cursor: progress !important;
--                                 -webkit-transition: opacity 0.5s;
--                                 transition: opacity 0.5s;
--                         end;
--                         body.wp-customizer-unloading-- then
--                                 pointer-events: none !important;
--                         end;
--                         form.customize-unpreviewable,
--                         form.customize-unpreviewable input,
--                         form.customize-unpreviewable select,
--                         form.customize-unpreviewable button,
--                         a.customize-unpreviewable,
--                         area.customize-unpreviewable then
--                                 cursor: not-allowed !important;
--                         end;
--                 </style>
--                 <?php
--         end;

--         --
--         -- Removes customize_messenger_channel query parameter from the preview window when it is not in an iframe.
--         --
--         -- This ensures that the admin bar will be shown. It also ensures that link navigation will
--         -- work as expected since the parent frame is not being sent the URL to navigate to.
--         --
--         -- @since 4.7.0
--         --
--         public function remove_frameless_preview_messenger_channel() then
--                 if ( ! this->messenger_channel ) then
--                         return;
--                 end;
--                 ?>
--                 <script>
--                 ( function() then
--                         var urlParser, oldQueryParams, newQueryParams, i;
--                         if ( parent !== window ) then
--                                 return;
--                         end;
--                         urlParser = document.createElement( "a" );
--                         urlParser.href = location.href;
--                         oldQueryParams = urlParser.search.substr( 1 ).split( /&/ );
--                         newQueryParams = [];
--                         for ( i = 0; i < oldQueryParams.length; i += 1 ) then
--                                 if ( ! /^customize_messenger_channel=/.test( oldQueryParams[ i ] ) ) then
--                                         newQueryParams.push( oldQueryParams[ i ] );
--                                 end;
--                         end;
--                         urlParser.search = newQueryParams.join( "&" );
--                         if ( urlParser.search !== location.search ) then
--                                 location.replace( urlParser.href );
--                         end;
--                 end; )();
--                 </script>
--                 <?php
--         end;

--         --
--         -- Prints JavaScript settings for preview frame.
--         --
--         -- @since 3.4.0
--         --
--         public function customize_preview_settings() then
--                 post_values                 = this->unsanitized_post_values( array( "exclude_changeset" => true ) );
--                 setting_validities          = this->validate_setting_values( post_values );
--                 exported_setting_validities = array_map( array( this, "prepare_setting_validity_for_js" ), setting_validities );

--                 -- Note that the REQUEST_URI is not passed into home_url() since this breaks subdirectory installations.
--                 self_url           = empty( _SERVER["REQUEST_URI"] ) ? home_url( "/" ) : sanitize_url( wp_unslash( _SERVER["REQUEST_URI"] ) );
--                 state_query_params = array(
--                         "customize_theme",
--                         "customize_changeset_uuid",
--                         "customize_messenger_channel",
--                 );
--                 self_url           = remove_query_arg( state_query_params, self_url );

--                 allowed_urls  = this->get_allowed_urls();
--                 allowed_hosts = array();
--                 foreach ( allowed_urls as allowed_url ) then
--                         parsed = wp_parse_url( allowed_url );
--                         if ( empty( parsed["host"] ) ) then
--                                 continue;
--                         end;
--                         host = parsed["host"];
--                         if ( ! empty( parsed["port"] ) ) then
--                                 host .= ":" . parsed["port"];
--                         end;
--                         allowed_hosts[] = host;
--                 end;

--                 switched_locale = switch_to_locale( get_user_locale() );
--                 l10n            = array(
--                         "shiftClickToEdit"  => __( "Shift-click to edit this element." ),
--                         "linkUnpreviewable" => __( "This link is not live-previewable." ),
--                         "formUnpreviewable" => __( "This form is not live-previewable." ),
--                 );
--                 if ( switched_locale ) then
--                         restore_previous_locale();
--                 end;

--                 settings = array(
--                         "changeset"         => array(
--                                 "uuid"      => this->changeset_uuid(),
--                                 "autosaved" => this->autosaved(),
--                         ),
--                         "timeouts"          => array(
--                                 "selectiveRefresh" => 250,
--                                 "keepAliveSend"    => 1000,
--                         ),
--                         "theme"             => array(
--                                 "stylesheet" => this->get_stylesheet(),
--                                 "active"     => this->is_theme_active(),
--                         ),
--                         "url"               => array(
--                                 "self"          => self_url,
--                                 "allowed"       => array_map( "sanitize_url", this->get_allowed_urls() ),
--                                 "allowedHosts"  => array_unique( allowed_hosts ),
--                                 "isCrossDomain" => this->is_cross_domain(),
--                         ),
--                         "channel"           => this->messenger_channel,
--                         "activePanels"      => array(),
--                         "activeSections"    => array(),
--                         "activeControls"    => array(),
--                         "settingValidities" => exported_setting_validities,
--                         "nonce"             => current_user_can( "customize" ) ? this->get_nonces() : array(),
--                         "l10n"              => l10n,
--                         "_dirty"            => array_keys( post_values ),
--                 );

--                 foreach ( this->panels as panel_id => panel ) then
--                         if ( panel->check_capabilities() ) then
--                                 settings["activePanels"][ panel_id ] = panel->active();
--                                 foreach ( panel->sections as section_id => section ) then
--                                         if ( section->check_capabilities() ) then
--                                                 settings["activeSections"][ section_id ] = section->active();
--                                         end;
--                                 end;
--                         end;
--                 end;
--                 foreach ( this->sections as id => section ) then
--                         if ( section->check_capabilities() ) then
--                                 settings["activeSections"][ id ] = section->active();
--                         end;
--                 end;
--                 foreach ( this->controls as id => control ) then
--                         if ( control->check_capabilities() ) then
--                                 settings["activeControls"][ id ] = control->active();
--                         end;
--                 end;

--                 ?>
--                 <script type="text/javascript">
--                         var _wpCustomizeSettings = <?php echo wp_json_encode( settings ); ?>;
--                         _wpCustomizeSettings.values = thenend;;
--                         (function( v ) then
--                                 <?php
--                                 /*
--                                 -- Serialize settings separately from the initial _wpCustomizeSettings
--                                 -- serialization in order to avoid a peak memory usage spike.
--                                 -- @todo We may not even need to export the values at all since the pane syncs them anyway.
--                                 --
--                                 foreach ( this->settings as id => setting ) then
--                                         if ( setting->check_capabilities() ) then
--                                                 printf(
--                                                         "v[%s] = %s;\n",
--                                                         wp_json_encode( id ),
--                                                         wp_json_encode( setting->js_value() )
--                                                 );
--                                         end;
--                                 end;
--                                 ?>
--                         end;)( _wpCustomizeSettings.values );
--                 </script>
--                 <?php
--         end;

--         --
--         -- Prints a signature so we can ensure the Customizer was properly executed.
--         --
--         -- @since 3.4.0
--         -- @deprecated 4.7.0
--         --
--         public function customize_preview_signature() then
--                 _deprecated_function( __METHOD__, "4.7.0" );
--         end;

--         --
--         -- Removes the signature in case we experience a case where the Customizer was not properly executed.
--         --
--         -- @since 3.4.0
--         -- @deprecated 4.7.0
--         --
--         -- @param callable|null callback Optional. Value passed through for {@see "wp_die_handler"} filter.
--         --                                Default null.
--         -- @return callable|null Value passed through for {@see "wp_die_handler"} filter.
--         --
--         public function remove_preview_signature( callback = null ) then
--                 _deprecated_function( __METHOD__, "4.7.0" );

--                 return callback;
--         end;

--         --
--         -- Determines whether it is a theme preview or not.
--         --
--         -- @since 3.4.0
--         --
--         -- @return bool True if it"s a preview, false if not.
--         --
--         public function is_preview() then
--                 return (bool) this->previewing;
--         end;

--         --
--         -- Retrieves the template name of the previewed theme.
--         --
--         -- @since 3.4.0
--         --
--         -- @return string Template name.
--         --
--         public function get_template() then
--                 return this->theme()->get_template();
--         end;

   --------------------
   -- Get_Stylesheet --
   --------------------

   function Get_Stylesheet (This : Wp_Customize_Manager)
                            return String
   is
   begin
      return This.Theme.Get_Stylesheet; -- ()
   end Get_Stylesheet;

--         --
--         -- Retrieves the template root of the previewed theme.
--         --
--         -- @since 3.4.0
--         --
--         -- @return string Theme root.
--         --
--         public function get_template_root() then
--                 return get_raw_theme_root( this->get_template(), true );
--         end;

--         --
--         -- Retrieves the stylesheet root of the previewed theme.
--         --
--         -- @since 3.4.0
--         --
--         -- @return string Theme root.
--         --
--         public function get_stylesheet_root() then
--                 return get_raw_theme_root( this->get_stylesheet(), true );
--         end;

--         --
--         -- Filters the active theme and return the name of the previewed theme.
--         --
--         -- @since 3.4.0
--         --
--         -- @param mixed current_theme then@internal Parameter is not usedend;
--         -- @return string Theme name.
--         --
--         public function current_theme( current_theme ) then
--                 return this->theme()->display( "Name" );
--         end;

--         --
--         -- Validates setting values.
--         --
--         -- Validation is skipped for unregistered settings or for values that are
--         -- already null since they will be skipped anyway. Sanitization is applied
--         -- to values that pass validation, and values that become null or `WP_Error`
--         -- after sanitizing are marked invalid.
--         --
--         -- @since 4.6.0
--         --
--         -- @see WP_REST_Request::has_valid_params()
--         -- @see WP_Customize_Setting::validate()
--         --
--         -- @param array setting_values Mapping of setting IDs to values to validate and sanitize.
--         -- @param array options then
--         --     Options.
--         --
--         --     @type bool validate_existence  Whether a setting"s existence will be checked.
--         --     @type bool validate_capability Whether the setting capability will be checked.
--         -- end;
--         -- @return array Mapping of setting IDs to return value of validate method calls, either `true` or `WP_Error`.
--         --
--         public function validate_setting_values( setting_values, options = array() ) then
--                 options = wp_parse_args(
--                         options,
--                         array(
--                                 "validate_capability" => false,
--                                 "validate_existence"  => false,
--                         )
--                 );

--                 validities = array();
--                 foreach ( setting_values as setting_id => unsanitized_value ) then
--                         setting = this->get_setting( setting_id );
--                         if ( ! setting ) then
--                                 if ( options["validate_existence"] ) then
--                                         validities[ setting_id ] = new WP_Error( "unrecognized", __( "Setting does not exist or is unrecognized." ) );
--                                 end;
--                                 continue;
--                         end;
--                         if ( options["validate_capability"] && ! current_user_can( setting->capability ) ) then
--                                 validity = new WP_Error( "unauthorized", __( "Unauthorized to modify setting due to capability." ) );
--                         end; else then
--                                 if ( is_null( unsanitized_value ) ) then
--                                         continue;
--                                 end;
--                                 validity = setting->validate( unsanitized_value );
--                         end;
--                         if ( ! is_wp_error( validity ) ) then
--                                 -- This filter is documented in wp-includes/class-wp-customize-setting.php--
--                                 late_validity = apply_filters( "customize_validate_thensetting->idend;", new WP_Error(), unsanitized_value, setting );
--                                 if ( is_wp_error( late_validity ) && late_validity->has_errors() ) then
--                                         validity = late_validity;
--                                 end;
--                         end;
--                         if ( ! is_wp_error( validity ) ) then
--                                 value = setting->sanitize( unsanitized_value );
--                                 if ( is_null( value ) ) then
--                                         validity = false;
--                                 end; elseif ( is_wp_error( value ) ) then
--                                         validity = value;
--                                 end;
--                         end;
--                         if ( false === validity ) then
--                                 validity = new WP_Error( "invalid_value", __( "Invalid value." ) );
--                         end;
--                         validities[ setting_id ] = validity;
--                 end;
--                 return validities;
--         end;

--         --
--         -- Prepares setting validity for exporting to the client (JS).
--         --
--         -- Converts `WP_Error` instance into array suitable for passing into the
--         -- `wp.customize.Notification` JS model.
--         --
--         -- @since 4.6.0
--         --
--         -- @param true|WP_Error validity Setting validity.
--         -- @return true|array If `validity` was a WP_Error, the error codes will be array-mapped
--         --                    to their respective `message` and `data` to pass into the
--         --                    `wp.customize.Notification` JS model.
--         --
--         public function prepare_setting_validity_for_js( validity ) then
--                 if ( is_wp_error( validity ) ) then
--                         notification = array();
--                         foreach ( validity->errors as error_code => error_messages ) then
--                                 notification[ error_code ] = array(
--                                         "message" => implode( " ", error_messages ),
--                                         "data"    => validity->get_error_data( error_code ),
--                                 );
--                         end;
--                         return notification;
--                 end; else then
--                         return true;
--                 end;
--         end;

--         --
--         -- Handles customize_save WP Ajax request to save/update a changeset.
--         --
--         -- @since 3.4.0
--         -- @since 4.7.0 The semantics of this method have changed to update a changeset, optionally to also change the status and other attributes.
--         --
--         public function save() then
--                 if ( ! is_user_logged_in() ) then
--                         wp_send_json_error( "unauthenticated" );
--                 end;

--                 if ( ! this->is_preview() ) then
--                         wp_send_json_error( "not_preview" );
--                 end;

--                 action = "save-customize_" . this->get_stylesheet();
--                 if ( ! check_ajax_referer( action, "nonce", false ) ) then
--                         wp_send_json_error( "invalid_nonce" );
--                 end;

--                 changeset_post_id = this->changeset_post_id();
--                 is_new_changeset  = empty( changeset_post_id );
--                 if ( is_new_changeset ) then
--                         if ( ! current_user_can( get_post_type_object( "customize_changeset" )->cap->create_posts ) ) then
--                                 wp_send_json_error( "cannot_create_changeset_post" );
--                         end;
--                 end; else then
--                         if ( ! current_user_can( get_post_type_object( "customize_changeset" )->cap->edit_post, changeset_post_id ) ) then
--                                 wp_send_json_error( "cannot_edit_changeset_post" );
--                         end;
--                 end;

--                 if ( ! empty( _POST["customize_changeset_data"] ) ) then
--                         input_changeset_data = json_decode( wp_unslash( _POST["customize_changeset_data"] ), true );
--                         if ( ! is_array( input_changeset_data ) ) then
--                                 wp_send_json_error( "invalid_customize_changeset_data" );
--                         end;
--                 end; else then
--                         input_changeset_data = array();
--                 end;

--                 -- Validate title.
--                 changeset_title = null;
--                 if ( isset( _POST["customize_changeset_title"] ) ) then
--                         changeset_title = sanitize_text_field( wp_unslash( _POST["customize_changeset_title"] ) );
--                 end;

--                 -- Validate changeset status param.
--                 is_publish       = null;
--                 changeset_status = null;
--                 if ( isset( _POST["customize_changeset_status"] ) ) then
--                         changeset_status = wp_unslash( _POST["customize_changeset_status"] );
--                         if ( ! get_post_status_object( changeset_status ) || ! in_array( changeset_status, array( "draft", "pending", "publish", "future" ), true ) ) then
--                                 wp_send_json_error( "bad_customize_changeset_status", 400 );
--                         end;
--                         is_publish = ( "publish" === changeset_status || "future" === changeset_status );
--                         if ( is_publish && ! current_user_can( get_post_type_object( "customize_changeset" )->cap->publish_posts ) ) then
--                                 wp_send_json_error( "changeset_publish_unauthorized", 403 );
--                         end;
--                 end;

--                 /*
--                 -- Validate changeset date param. Date is assumed to be in local time for
--                 -- the WP if in MySQL format (YYYY-MM-DD HH:MM:SS). Otherwise, the date
--                 -- is parsed with strtotime() so that ISO date format may be supplied
--                 -- or a string like "+10 minutes".
--                 --
--                 changeset_date_gmt = null;
--                 if ( isset( _POST["customize_changeset_date"] ) ) then
--                         changeset_date = wp_unslash( _POST["customize_changeset_date"] );
--                         if ( preg_match( "/^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d/", changeset_date ) ) then
--                                 mm         = substr( changeset_date, 5, 2 );
--                                 jj         = substr( changeset_date, 8, 2 );
--                                 aa         = substr( changeset_date, 0, 4 );
--                                 valid_date = wp_checkdate( mm, jj, aa, changeset_date );
--                                 if ( ! valid_date ) then
--                                         wp_send_json_error( "bad_customize_changeset_date", 400 );
--                                 end;
--                                 changeset_date_gmt = get_gmt_from_date( changeset_date );
--                         end; else then
--                                 timestamp = strtotime( changeset_date );
--                                 if ( ! timestamp ) then
--                                         wp_send_json_error( "bad_customize_changeset_date", 400 );
--                                 end;
--                                 changeset_date_gmt = gmdate( "Y-m-d H:i:s", timestamp );
--                         end;
--                 end;

--                 lock_user_id = null;
--                 autosave     = ! empty( _POST["customize_changeset_autosave"] );
--                 if ( ! is_new_changeset ) then
--                         lock_user_id = wp_check_post_lock( this->changeset_post_id() );
--                 end;

--                 -- Force request to autosave when changeset is locked.
--                 if ( lock_user_id && ! autosave ) then
--                         autosave           = true;
--                         changeset_status   = null;
--                         changeset_date_gmt = null;
--                 end;

--                 if ( autosave && ! defined( "DOING_AUTOSAVE" ) ) then -- Back-compat.
--                         define( "DOING_AUTOSAVE", true );
--                 end;

--                 autosaved = false;
--                 r         = this->save_changeset_post(
--                         array(
--                                 "status"   => changeset_status,
--                                 "title"    => changeset_title,
--                                 "date_gmt" => changeset_date_gmt,
--                                 "data"     => input_changeset_data,
--                                 "autosave" => autosave,
--                         )
--                 );
--                 if ( autosave && ! is_wp_error( r ) ) then
--                         autosaved = true;
--                 end;

--                 -- If the changeset was locked and an autosave request wasn"t itself an error, then now explicitly return with a failure.
--                 if ( lock_user_id && ! is_wp_error( r ) ) then
--                         r = new WP_Error(
--                                 "changeset_locked",
--                                 __( "Changeset is being edited by other user." ),
--                                 array(
--                                         "lock_user" => this->get_lock_user_data( lock_user_id ),
--                                 )
--                         );
--                 end;

--                 if ( is_wp_error( r ) ) then
--                         response = array(
--                                 "message" => r->get_error_message(),
--                                 "code"    => r->get_error_code(),
--                         );
--                         if ( is_array( r->get_error_data() ) ) then
--                                 response = array_merge( response, r->get_error_data() );
--                         end; else then
--                                 response["data"] = r->get_error_data();
--                         end;
--                 end; else then
--                         response       = r;
--                         changeset_post = get_post( this->changeset_post_id() );

--                         -- Dismiss all other auto-draft changeset posts for this user (they serve like autosave revisions), as there should only be one.
--                         if ( is_new_changeset ) then
--                                 this->dismiss_user_auto_draft_changesets();
--                         end;

--                         -- Note that if the changeset status was publish, then it will get set to Trash if revisions are not supported.
--                         response["changeset_status"] = changeset_post->post_status;
--                         if ( is_publish && "trash" === response["changeset_status"] ) then
--                                 response["changeset_status"] = "publish";
--                         end;

--                         if ( "publish" !== response["changeset_status"] ) then
--                                 this->set_changeset_lock( changeset_post->ID );
--                         end;

--                         if ( "future" === response["changeset_status"] ) then
--                                 response["changeset_date"] = changeset_post->post_date;
--                         end;

--                         if ( "publish" === response["changeset_status"] || "trash" === response["changeset_status"] ) then
--                                 response["next_changeset_uuid"] = wp_generate_uuid4();
--                         end;
--                 end;

--                 if ( autosave ) then
--                         response["autosaved"] = autosaved;
--                 end;

--                 if ( isset( response["setting_validities"] ) ) then
--                         response["setting_validities"] = array_map( array( this, "prepare_setting_validity_for_js" ), response["setting_validities"] );
--                 end;

--                 --
--                 -- Filters response data for a successful customize_save Ajax request.
--                 --
--                 -- This filter does not apply if there was a nonce or authentication failure.
--                 --
--                 -- @since 4.2.0
--                 --
--                 -- @param array                response Additional information passed back to the "saved"
--                 --                                       event on `wp.customize`.
--                 -- @param WP_Customize_Manager manager  WP_Customize_Manager instance.
--                 --
--                 response = apply_filters( "customize_save_response", response, this );

--                 if ( is_wp_error( r ) ) then
--                         wp_send_json_error( response );
--                 end; else then
--                         wp_send_json_success( response );
--                 end;
--         end;

--         --
--         -- Saves the post for the loaded changeset.
--         --
--         -- @since 4.7.0
--         --
--         -- @param array args then
--         --     Args for changeset post.
--         --
--         --     @type array  data            Optional additional changeset data. Values will be merged on top of any existing post values.
--         --     @type string status          Post status. Optional. If supplied, the save will be transactional and a post revision will be allowed.
--         --     @type string title           Post title. Optional.
--         --     @type string date_gmt        Date in GMT. Optional.
--         --     @type int    user_id         ID for user who is saving the changeset. Optional, defaults to the current user ID.
--         --     @type bool   starter_content Whether the data is starter content. If false (default), then starter_content will be cleared for any data being saved.
--         --     @type bool   autosave        Whether this is a request to create an autosave revision.
--         -- end;
--         --
--         -- @return array|WP_Error Returns array on success and WP_Error with array data on error.
--         --
--         public function save_changeset_post( args = array() ) then

--                 args = array_merge(
--                         array(
--                                 "status"          => null,
--                                 "title"           => null,
--                                 "data"            => array(),
--                                 "date_gmt"        => null,
--                                 "user_id"         => get_current_user_id(),
--                                 "starter_content" => false,
--                                 "autosave"        => false,
--                         ),
--                         args
--                 );

--                 changeset_post_id       = this->changeset_post_id();
--                 existing_changeset_data = array();
--                 if ( changeset_post_id ) then
--                         existing_status = get_post_status( changeset_post_id );
--                         if ( "publish" === existing_status || "trash" === existing_status ) then
--                                 return new WP_Error(
--                                         "changeset_already_published",
--                                         __( "The previous set of changes has already been published. Please try saving your current set of changes again." ),
--                                         array(
--                                                 "next_changeset_uuid" => wp_generate_uuid4(),
--                                         )
--                                 );
--                         end;

--                         existing_changeset_data = this->get_changeset_post_data( changeset_post_id );
--                         if ( is_wp_error( existing_changeset_data ) ) then
--                                 return existing_changeset_data;
--                         end;
--                 end;

--                 -- Fail if attempting to publish but publish hook is missing.
--                 if ( "publish" === args["status"] && false === has_action( "transition_post_status", "_wp_customize_publish_changeset" ) ) then
--                         return new WP_Error( "missing_publish_callback" );
--                 end;

--                 -- Validate date.
--                 now = gmdate( "Y-m-d H:i:59" );
--                 if ( args["date_gmt"] ) then
--                         is_future_dated = ( mysql2date( "U", args["date_gmt"], false ) > mysql2date( "U", now, false ) );
--                         if ( ! is_future_dated ) then
--                                 return new WP_Error( "not_future_date", __( "You must supply a future date to schedule." ) ); -- Only future dates are allowed.
--                         end;

--                         if ( ! this->is_theme_active() && ( "future" === args["status"] || is_future_dated ) ) then
--                                 return new WP_Error( "cannot_schedule_theme_switches" ); -- This should be allowed in the future, when theme is a regular setting.
--                         end;
--                         will_remain_auto_draft = ( ! args["status"] && ( ! changeset_post_id || "auto-draft" === get_post_status( changeset_post_id ) ) );
--                         if ( will_remain_auto_draft ) then
--                                 return new WP_Error( "cannot_supply_date_for_auto_draft_changeset" );
--                         end;
--                 end; elseif ( changeset_post_id && "future" === args["status"] ) then

--                         -- Fail if the new status is future but the existing post"s date is not in the future.
--                         changeset_post = get_post( changeset_post_id );
--                         if ( mysql2date( "U", changeset_post->post_date_gmt, false ) <= mysql2date( "U", now, false ) ) then
--                                 return new WP_Error( "not_future_date", __( "You must supply a future date to schedule." ) );
--                         end;
--                 end;

--                 if ( ! empty( is_future_dated ) && "publish" === args["status"] ) then
--                         args["status"] = "future";
--                 end;

--                 -- Validate autosave param. See _wp_post_revision_fields() for why these fields are disallowed.
--                 if ( args["autosave"] ) then
--                         if ( args["date_gmt"] ) then
--                                 return new WP_Error( "illegal_autosave_with_date_gmt" );
--                         end; elseif ( args["status"] ) then
--                                 return new WP_Error( "illegal_autosave_with_status" );
--                         end; elseif ( args["user_id"] && get_current_user_id() !== args["user_id"] ) then
--                                 return new WP_Error( "illegal_autosave_with_non_current_user" );
--                         end;
--                 end;

--                 -- The request was made via wp.customize.previewer.save().
--                 update_transactionally = (bool) args["status"];
--                 allow_revision         = (bool) args["status"];

--                 -- Amend post values with any supplied data.
--                 foreach ( args["data"] as setting_id => setting_params ) then
--                         if ( is_array( setting_params ) && array_key_exists( "value", setting_params ) ) then
--                                 this->set_post_value( setting_id, setting_params["value"] ); -- Add to post values so that they can be validated and sanitized.
--                         end;
--                 end;

--                 -- Note that in addition to post data, this will include any stashed theme mods.
--                 post_values = this->unsanitized_post_values(
--                         array(
--                                 "exclude_changeset" => true,
--                                 "exclude_post_data" => false,
--                         )
--                 );
--                 this->add_dynamic_settings( array_keys( post_values ) ); -- Ensure settings get created even if they lack an input value.

--                 /*
--                 -- Get list of IDs for settings that have values different from what is currently
--                 -- saved in the changeset. By skipping any values that are already the same, the
--                 -- subset of changed settings can be passed into validate_setting_values to prevent
--                 -- an underprivileged modifying a single setting for which they have the capability
--                 -- from being blocked from saving. This also prevents a user from touching of the
--                 -- previous saved settings and overriding the associated user_id if they made no change.
--                 --
--                 changed_setting_ids = array();
--                 foreach ( post_values as setting_id => setting_value ) then
--                         setting = this->get_setting( setting_id );

--                         if ( setting && "theme_mod" === setting->type ) then
--                                 prefixed_setting_id = this->get_stylesheet() . "::" . setting->id;
--                         end; else then
--                                 prefixed_setting_id = setting_id;
--                         end;

--                         is_value_changed = (
--                                 ! isset( existing_changeset_data[ prefixed_setting_id ] )
--                                 ||
--                                 ! array_key_exists( "value", existing_changeset_data[ prefixed_setting_id ] )
--                                 ||
--                                 existing_changeset_data[ prefixed_setting_id ]["value"] !== setting_value
--                         );
--                         if ( is_value_changed ) then
--                                 changed_setting_ids[] = setting_id;
--                         end;
--                 end;

--                 --
--                 -- Fires before save validation happens.
--                 --
--                 -- Plugins can add just-in-time {@see "customize_validate_{this->ID}"} filters
--                 -- at this point to catch any settings registered after `customize_register`.
--                 -- The dynamic portion of the hook name, `this->ID` refers to the setting ID.
--                 --
--                 -- @since 4.6.0
--                 --
--                 -- @param WP_Customize_Manager manager WP_Customize_Manager instance.
--                 --
--                 do_action( "customize_save_validation_before", this );

--                 -- Validate settings.
--                 validated_values      = array_merge(
--                         array_fill_keys( array_keys( args["data"] ), null ), -- Make sure existence/capability checks are done on value-less setting updates.
--                         post_values
--                 );
--                 setting_validities    = this->validate_setting_values(
--                         validated_values,
--                         array(
--                                 "validate_capability" => true,
--                                 "validate_existence"  => true,
--                         )
--                 );
--                 invalid_setting_count = count( array_filter( setting_validities, "is_wp_error" ) );

--                 /*
--                 -- Short-circuit if there are invalid settings the update is transactional.
--                 -- A changeset update is transactional when a status is supplied in the request.
--                 --
--                 if ( update_transactionally && invalid_setting_count > 0 ) then
--                         response = array(
--                                 "setting_validities" => setting_validities,
--                                 /* translators: %s: Number of invalid settings.--
--                                 "message"            => sprintf( _n( "Unable to save due to %s invalid setting.", "Unable to save due to %s invalid settings.", invalid_setting_count ), number_format_i18n( invalid_setting_count ) ),
--                         );
--                         return new WP_Error( "transaction_fail", "", response );
--                 end;

--                 -- Obtain/merge data for changeset.
--                 original_changeset_data = this->get_changeset_post_data( changeset_post_id );
--                 data                    = original_changeset_data;
--                 if ( is_wp_error( data ) ) then
--                         data = array();
--                 end;

--                 -- Ensure that all post values are included in the changeset data.
--                 foreach ( post_values as setting_id => post_value ) then
--                         if ( ! isset( args["data"][ setting_id ] ) ) then
--                                 args["data"][ setting_id ] = array();
--                         end;
--                         if ( ! isset( args["data"][ setting_id ]["value"] ) ) then
--                                 args["data"][ setting_id ]["value"] = post_value;
--                         end;
--                 end;

--                 foreach ( args["data"] as setting_id => setting_params ) then
--                         setting = this->get_setting( setting_id );
--                         if ( ! setting || ! setting->check_capabilities() ) then
--                                 continue;
--                         end;

--                         -- Skip updating changeset for invalid setting values.
--                         if ( isset( setting_validities[ setting_id ] ) && is_wp_error( setting_validities[ setting_id ] ) ) then
--                                 continue;
--                         end;

--                         changeset_setting_id = setting_id;
--                         if ( "theme_mod" === setting->type ) then
--                                 changeset_setting_id = sprintf( "%s::%s", this->get_stylesheet(), setting_id );
--                         end;

--                         if ( null === setting_params ) then
--                                 -- Remove setting from changeset entirely.
--                                 unset( data[ changeset_setting_id ] );
--                         end; else then

--                                 if ( ! isset( data[ changeset_setting_id ] ) ) then
--                                         data[ changeset_setting_id ] = array();
--                                 end;

--                                 -- Merge any additional setting params that have been supplied with the existing params.
--                                 merged_setting_params = array_merge( data[ changeset_setting_id ], setting_params );

--                                 -- Skip updating setting params if unchanged (ensuring the user_id is not overwritten).
--                                 if ( data[ changeset_setting_id ] === merged_setting_params ) then
--                                         continue;
--                                 end;

--                                 data[ changeset_setting_id ] = array_merge(
--                                         merged_setting_params,
--                                         array(
--                                                 "type"              => setting->type,
--                                                 "user_id"           => args["user_id"],
--                                                 "date_modified_gmt" => current_time( "mysql", true ),
--                                         )
--                                 );

--                                 -- Clear starter_content flag in data if changeset is not explicitly being updated for starter content.
--                                 if ( empty( args["starter_content"] ) ) then
--                                         unset( data[ changeset_setting_id ]["starter_content"] );
--                                 end;
--                         end;
--                 end;

--                 filter_context = array(
--                         "uuid"          => this->changeset_uuid(),
--                         "title"         => args["title"],
--                         "status"        => args["status"],
--                         "date_gmt"      => args["date_gmt"],
--                         "post_id"       => changeset_post_id,
--                         "previous_data" => is_wp_error( original_changeset_data ) ? array() : original_changeset_data,
--                         "manager"       => this,
--                 );

--                 --
--                 -- Filters the settings" data that will be persisted into the changeset.
--                 --
--                 -- Plugins may amend additional data (such as additional meta for settings) into the changeset with this filter.
--                 --
--                 -- @since 4.7.0
--                 --
--                 -- @param array data Updated changeset data, mapping setting IDs to arrays containing a value item and optionally other metadata.
--                 -- @param array context then
--                 --     Filter context.
--                 --
--                 --     @type string               uuid          Changeset UUID.
--                 --     @type string               title         Requested title for the changeset post.
--                 --     @type string               status        Requested status for the changeset post.
--                 --     @type string               date_gmt      Requested date for the changeset post in MySQL format and GMT timezone.
--                 --     @type int|false            post_id       Post ID for the changeset, or false if it doesn"t exist yet.
--                 --     @type array                previous_data Previous data contained in the changeset.
--                 --     @type WP_Customize_Manager manager       Manager instance.
--                 -- end;
--                 --
--                 data = apply_filters( "customize_changeset_save_data", data, filter_context );

--                 -- Switch theme if publishing changes now.
--                 if ( "publish" === args["status"] && ! this->is_theme_active() ) then
--                         -- Temporarily stop previewing the theme to allow switch_themes() to operate properly.
--                         this->stop_previewing_theme();
--                         switch_theme( this->get_stylesheet() );
--                         update_option( "theme_switched_via_customizer", true );
--                         this->start_previewing_theme();
--                 end;

--                 -- Gather the data for wp_insert_post()/wp_update_post().
--                 post_array = array(
--                         -- JSON_UNESCAPED_SLASHES is only to improve readability as slashes needn"t be escaped in storage.
--                         "post_content" => wp_json_encode( data, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT ),
--                 );
--                 if ( args["title"] ) then
--                         post_array["post_title"] = args["title"];
--                 end;
--                 if ( changeset_post_id ) then
--                         post_array["ID"] = changeset_post_id;
--                 end; else then
--                         post_array["post_type"]   = "customize_changeset";
--                         post_array["post_name"]   = this->changeset_uuid();
--                         post_array["post_status"] = "auto-draft";
--                 end;
--                 if ( args["status"] ) then
--                         post_array["post_status"] = args["status"];
--                 end;

--                 -- Reset post date to now if we are publishing, otherwise pass post_date_gmt and translate for post_date.
--                 if ( "publish" === args["status"] ) then
--                         post_array["post_date_gmt"] = "0000-00-00 00:00:00";
--                         post_array["post_date"]     = "0000-00-00 00:00:00";
--                 end; elseif ( args["date_gmt"] ) then
--                         post_array["post_date_gmt"] = args["date_gmt"];
--                         post_array["post_date"]     = get_date_from_gmt( args["date_gmt"] );
--                 end; elseif ( changeset_post_id && "auto-draft" === get_post_status( changeset_post_id ) ) then
--                         /*
--                         -- Keep bumping the date for the auto-draft whenever it is modified;
--                         -- this extends its life, preserving it from garbage-collection via
--                         -- wp_delete_auto_drafts().
--                         --
--                         post_array["post_date"]     = current_time( "mysql" );
--                         post_array["post_date_gmt"] = "";
--                 end;

--                 this->store_changeset_revision = allow_revision;
--                 add_filter( "wp_save_post_revision_post_has_changed", array( this, "_filter_revision_post_has_changed" ), 5, 3 );

--                 /*
--                 -- Update the changeset post. The publish_customize_changeset action will cause the settings in the
--                 -- changeset to be saved via WP_Customize_Setting::save(). Updating a post with publish status will
--                 -- trigger WP_Customize_Manager::publish_changeset_values().
--                 --
--                 add_filter( "wp_insert_post_data", array( this, "preserve_insert_changeset_post_content" ), 5, 3 );
--                 if ( changeset_post_id ) then
--                         if ( args["autosave"] && "auto-draft" !== get_post_status( changeset_post_id ) ) then
--                                 -- See _wp_translate_postdata() for why this is required as it will use the edit_post meta capability.
--                                 add_filter( "map_meta_cap", array( this, "grant_edit_post_capability_for_changeset" ), 10, 4 );

--                                 post_array["post_ID"]   = post_array["ID"];
--                                 post_array["post_type"] = "customize_changeset";

--                                 r = wp_create_post_autosave( wp_slash( post_array ) );

--                                 remove_filter( "map_meta_cap", array( this, "grant_edit_post_capability_for_changeset" ), 10 );
--                         end; else then
--                                 post_array["edit_date"] = true; -- Prevent date clearing.

--                                 r = wp_update_post( wp_slash( post_array ), true );

--                                 -- Delete autosave revision for user when the changeset is updated.
--                                 if ( ! empty( args["user_id"] ) ) then
--                                         autosave_draft = wp_get_post_autosave( changeset_post_id, args["user_id"] );
--                                         if ( autosave_draft ) then
--                                                 wp_delete_post( autosave_draft->ID, true );
--                                         end;
--                                 end;
--                         end;
--                 end; else then
--                         r = wp_insert_post( wp_slash( post_array ), true );
--                         if ( ! is_wp_error( r ) ) then
--                                 this->_changeset_post_id = r; -- Update cached post ID for the loaded changeset.
--                         end;
--                 end;
--                 remove_filter( "wp_insert_post_data", array( this, "preserve_insert_changeset_post_content" ), 5 );

--                 this->_changeset_data = null; -- Reset so WP_Customize_Manager::changeset_data() will re-populate with updated contents.

--                 remove_filter( "wp_save_post_revision_post_has_changed", array( this, "_filter_revision_post_has_changed" ) );

--                 response = array(
--                         "setting_validities" => setting_validities,
--                 );

--                 if ( is_wp_error( r ) ) then
--                         response["changeset_post_save_failure"] = r->get_error_code();
--                         return new WP_Error( "changeset_post_save_failure", "", response );
--                 end;

--                 return response;
--         end;

--         --
--         -- Preserves the initial JSON post_content passed to save into the post.
--         --
--         -- This is needed to prevent KSES and other {@see "content_save_pre"} filters
--         -- from corrupting JSON data.
--         --
--         -- Note that WP_Customize_Manager::validate_setting_values() have already
--         -- run on the setting values being serialized as JSON into the post content
--         -- so it is pre-sanitized.
--         --
--         -- Also, the sanitization logic is re-run through the respective
--         -- WP_Customize_Setting::sanitize() method when being read out of the
--         -- changeset, via WP_Customize_Manager::post_value(), and this sanitized
--         -- value will also be sent into WP_Customize_Setting::update() for
--         -- persisting to the DB.
--         --
--         -- Multiple users can collaborate on a single changeset, where one user may
--         -- have the unfiltered_html capability but another may not. A user with
--         -- unfiltered_html may add a script tag to some field which needs to be kept
--         -- intact even when another user updates the changeset to modify another field
--         -- when they do not have unfiltered_html.
--         --
--         -- @since 5.4.1
--         --
--         -- @param array data                An array of slashed and processed post data.
--         -- @param array postarr             An array of sanitized (and slashed) but otherwise unmodified post data.
--         -- @param array unsanitized_postarr An array of slashed yet--unsanitized* and unprocessed post data as originally passed to wp_insert_post().
--         -- @return array Filtered post data.
--         --
--         public function preserve_insert_changeset_post_content( data, postarr, unsanitized_postarr ) then
--                 if (
--                         isset( data["post_type"] ) &&
--                         isset( unsanitized_postarr["post_content"] ) &&
--                         "customize_changeset" === data["post_type"] ||
--                         (
--                                 "revision" === data["post_type"] &&
--                                 ! empty( data["post_parent"] ) &&
--                                 "customize_changeset" === get_post_type( data["post_parent"] )
--                         )
--                 ) then
--                         data["post_content"] = unsanitized_postarr["post_content"];
--                 end;
--                 return data;
--         end;

--         --
--         -- Trashes or deletes a changeset post.
--         --
--         -- The following re-formulates the logic from `wp_trash_post()` as done in
--         -- `wp_publish_post()`. The reason for bypassing `wp_trash_post()` is that it
--         -- will mutate the the `post_content` and the `post_name` when they should be
--         -- untouched.
--         --
--         -- @since 4.9.0
--         --
--         -- @see wp_trash_post()
--         -- @global wpdb wpdb WordPress database abstraction object.
--         --
--         -- @param int|WP_Post post The changeset post.
--         -- @return mixed A WP_Post object for the trashed post or an empty value on failure.
--         --
--         public function trash_changeset_post( post ) then
--                 global wpdb;

--                 post = get_post( post );

--                 if ( ! ( post instanceof WP_Post ) ) then
--                         return post;
--                 end;
--                 post_id = post->ID;

--                 if ( ! EMPTY_TRASH_DAYS ) then
--                         return wp_delete_post( post_id, true );
--                 end;

--                 if ( "trash" === get_post_status( post ) ) then
--                         return false;
--                 end;

--                 -- This filter is documented in wp-includes/post.php--
--                 check = apply_filters( "pre_trash_post", null, post );
--                 if ( null !== check ) then
--                         return check;
--                 end;

--                 -- This action is documented in wp-includes/post.php--
--                 do_action( "wp_trash_post", post_id );

--                 add_post_meta( post_id, "_wp_trash_meta_status", post->post_status );
--                 add_post_meta( post_id, "_wp_trash_meta_time", time() );

--                 old_status = post->post_status;
--                 new_status = "trash";
--                 wpdb->update( wpdb->posts, array( "post_status" => new_status ), array( "ID" => post->ID ) );
--                 clean_post_cache( post->ID );

--                 post->post_status = new_status;
--                 wp_transition_post_status( new_status, old_status, post );

--                 -- This action is documented in wp-includes/post.php--
--                 do_action( "edit_post_thenpost->post_typeend;", post->ID, post );

--                 -- This action is documented in wp-includes/post.php--
--                 do_action( "edit_post", post->ID, post );

--                 -- This action is documented in wp-includes/post.php--
--                 do_action( "save_post_thenpost->post_typeend;", post->ID, post, true );

--                 -- This action is documented in wp-includes/post.php--
--                 do_action( "save_post", post->ID, post, true );

--                 -- This action is documented in wp-includes/post.php--
--                 do_action( "wp_insert_post", post->ID, post, true );

--                 wp_after_insert_post( get_post( post_id ), true, post );

--                 wp_trash_post_comments( post_id );

--                 -- This action is documented in wp-includes/post.php--
--                 do_action( "trashed_post", post_id );

--                 return post;
--         end;

--         --
--         -- Handles request to trash a changeset.
--         --
--         -- @since 4.9.0
--         --
--         public function handle_changeset_trash_request() then
--                 if ( ! is_user_logged_in() ) then
--                         wp_send_json_error( "unauthenticated" );
--                 end;

--                 if ( ! this->is_preview() ) then
--                         wp_send_json_error( "not_preview" );
--                 end;

--                 if ( ! check_ajax_referer( "trash_customize_changeset", "nonce", false ) ) then
--                         wp_send_json_error(
--                                 array(
--                                         "code"    => "invalid_nonce",
--                                         "message" => __( "There was an authentication problem. Please reload and try again." ),
--                                 )
--                         );
--                 end;

--                 changeset_post_id = this->changeset_post_id();

--                 if ( ! changeset_post_id ) then
--                         wp_send_json_error(
--                                 array(
--                                         "message" => __( "No changes saved yet, so there is nothing to trash." ),
--                                         "code"    => "non_existent_changeset",
--                                 )
--                         );
--                         return;
--                 end;

--                 if ( changeset_post_id ) then
--                         if ( ! current_user_can( get_post_type_object( "customize_changeset" )->cap->delete_post, changeset_post_id ) ) then
--                                 wp_send_json_error(
--                                         array(
--                                                 "code"    => "changeset_trash_unauthorized",
--                                                 "message" => __( "Unable to trash changes." ),
--                                         )
--                                 );
--                         end;

--                         lock_user = (int) wp_check_post_lock( changeset_post_id );

--                         if ( lock_user && get_current_user_id() !== lock_user ) then
--                                 wp_send_json_error(
--                                         array(
--                                                 "code"     => "changeset_locked",
--                                                 "message"  => __( "Changeset is being edited by other user." ),
--                                                 "lockUser" => this->get_lock_user_data( lock_user ),
--                                         )
--                                 );
--                         end;
--                 end;

--                 if ( "trash" === get_post_status( changeset_post_id ) ) then
--                         wp_send_json_error(
--                                 array(
--                                         "message" => __( "Changes have already been trashed." ),
--                                         "code"    => "changeset_already_trashed",
--                                 )
--                         );
--                         return;
--                 end;

--                 r = this->trash_changeset_post( changeset_post_id );
--                 if ( ! ( r instanceof WP_Post ) ) then
--                         wp_send_json_error(
--                                 array(
--                                         "code"    => "changeset_trash_failure",
--                                         "message" => __( "Unable to trash changes." ),
--                                 )
--                         );
--                 end;

--                 wp_send_json_success(
--                         array(
--                                 "message" => __( "Changes trashed successfully." ),
--                         )
--                 );
--         end;

--         --
--         -- Re-maps "edit_post" meta cap for a customize_changeset post to be the same as "customize" maps.
--         --
--         -- There is essentially a "meta meta" cap in play here, where "edit_post" meta cap maps to
--         -- the "customize" meta cap which then maps to "edit_theme_options". This is currently
--         -- required in core for `wp_create_post_autosave()` because it will call
--         -- `_wp_translate_postdata()` which in turn will check if a user can "edit_post", but the
--         -- the caps for the customize_changeset post type are all mapping to the meta capability.
--         -- This should be able to be removed once #40922 is addressed in core.
--         --
--         -- @since 4.9.0
--         --
--         -- @link https://core.trac.wordpress.org/ticket/40922
--         -- @see WP_Customize_Manager::save_changeset_post()
--         -- @see _wp_translate_postdata()
--         --
--         -- @param string[] caps    Array of the user"s capabilities.
--         -- @param string   cap     Capability name.
--         -- @param int      user_id The user ID.
--         -- @param array    args    Adds the context to the cap. Typically the object ID.
--         -- @return array Capabilities.
--         --
--         public function grant_edit_post_capability_for_changeset( caps, cap, user_id, args ) then
--                 if ( "edit_post" === cap && ! empty( args[0] ) && "customize_changeset" === get_post_type( args[0] ) ) then
--                         post_type_obj = get_post_type_object( "customize_changeset" );
--                         caps          = map_meta_cap( post_type_obj->cap->cap, user_id );
--                 end;
--                 return caps;
--         end;

   ------------------------
   -- Set_Changeset_Lock --
   ------------------------

   procedure Set_Changeset_Lock (This              : Wp_Customize_Manager;
                                 Changeset_Post_Id : Post_Id; -- Integer;
                                 Take_Over         : Boolean := False)
   is
      use Php;
      use Php.Strings;
      use Inc_Posts;
      use Inc_Users;
   begin
      if Changeset_Post_Id not in 0 then
         declare
            Can_Override : Boolean :=
              "" = Get_Post_Meta (Changeset_Post_Id, "_edit_lock", True); -- (bool)
         begin
            if Take_Over then
               Can_Override := True;
            end if;

            if Can_Override then
               declare
                  Lock : constant String :=
                    Sprintf ("%s:%s",
                             To_List (List => (
                               1 => +Helpers.Image (Time),        -- time()
                               2 => +Helpers.Image (Get_Current_User_Id)
                            )));
               begin
                  Update_Post_Meta (Changeset_Post_Id, "_edit_lock", Lock);
               end;
            else
               This.Refresh_Changeset_Lock (Changeset_Post_Id);
            end if;
         end;
      end if;
   end Set_Changeset_Lock;

   ----------------------------
   -- Refresh_Changeset_Lock --
   ----------------------------

   procedure Refresh_Changeset_Lock (This              : Wp_Customize_Manager;
                                     Changeset_Post_Id : Post_Id) -- Integer)
   is
      use Php;
      use Php.Strings;
      use Inc_Posts;
      use Inc_Users;
   begin
      if Changeset_Post_Id in 0 then
         return;
      end if;

      declare
         Lock_0 : constant String :=
           Get_Post_Meta (Changeset_Post_Id, "_edit_lock", True);

         Lock : constant List_Type := Explode (":", Lock_0);
      begin
         if
           Lock not in Empty_List and then
           not Empty (-Lock (1))        -- [1]
         then
            declare
               User_Id : constant Integer :=
                 Integer'Value (-Lock (1));  -- (int) [1]

               Current_User_Id : constant Integer := Get_Current_User_Id;
            begin
               if User_Id = Current_User_Id then
                  declare
                     Lock_2 : constant String :=
                       Sprintf ("%s:%s", To_List (List => (
                         1 => +Helpers.Image (Time),
                         2 => +Helpers.Image (User_Id))));
                  begin
                     Update_Post_Meta (Changeset_Post_Id,
                                       "_edit_lock", Lock_2);
                  end;
               end if;
            end;
         end if;
      end;
   end Refresh_Changeset_Lock;

--         --
--         -- Filters heartbeat settings for the Customizer.
--         --
--         -- @since 4.9.0
--         --
--         -- @global string pagenow The filename of the current screen.
--         --
--         -- @param array settings Current settings to filter.
--         -- @return array Heartbeat settings.
--         --
--         public function add_customize_screen_to_heartbeat_settings( settings ) then
--                 global pagenow;

--                 if ( "customize.php" === pagenow ) then
--                         settings["screenId"] = "customize";
--                 end;

--                 return settings;
--         end;

--         --
--         -- Gets lock user data.
--         --
--         -- @since 4.9.0
--         --
--         -- @param int user_id User ID.
--         -- @return array|null User data formatted for client.
--         --
--         protected function get_lock_user_data( user_id ) then
--                 if ( ! user_id ) then
--                         return null;
--                 end;

--                 lock_user = get_userdata( user_id );

--                 if ( ! lock_user ) then
--                         return null;
--                 end;

--                 return array(
--                         "id"     => lock_user->ID,
--                         "name"   => lock_user->display_name,
--                         "avatar" => get_avatar_url( lock_user->ID, array( "size" => 128 ) ),
--                 );
--         end;

--         --
--         -- Checks locked changeset with heartbeat API.
--         --
--         -- @since 4.9.0
--         --
--         -- @param array  response  The Heartbeat response.
--         -- @param array  data      The _POST data sent.
--         -- @param string screen_id The screen id.
--         -- @return array The Heartbeat response.
--         --
--         public function check_changeset_lock_with_heartbeat( response, data, screen_id ) then
--                 if ( isset( data["changeset_uuid"] ) ) then
--                         changeset_post_id = this->find_changeset_post_id( data["changeset_uuid"] );
--                 end; else then
--                         changeset_post_id = this->changeset_post_id();
--                 end;

--                 if (
--                         array_key_exists( "check_changeset_lock", data )
--                         && "customize" === screen_id
--                         && changeset_post_id
--                         && current_user_can( get_post_type_object( "customize_changeset" )->cap->edit_post, changeset_post_id )
--                 ) then
--                         lock_user_id = wp_check_post_lock( changeset_post_id );

--                         if ( lock_user_id ) then
--                                 response["customize_changeset_lock_user"] = this->get_lock_user_data( lock_user_id );
--                         end; else then

--                                 -- Refreshing time will ensure that the user is sitting on customizer and has not closed the customizer tab.
--                                 this->refresh_changeset_lock( changeset_post_id );
--                         end;
--                 end;

--                 return response;
--         end;

--         --
--         -- Removes changeset lock when take over request is sent via Ajax.
--         --
--         -- @since 4.9.0
--         --
--         public function handle_override_changeset_lock_request() then
--                 if ( ! this->is_preview() ) then
--                         wp_send_json_error( "not_preview", 400 );
--                 end;

--                 if ( ! check_ajax_referer( "customize_override_changeset_lock", "nonce", false ) ) then
--                         wp_send_json_error(
--                                 array(
--                                         "code"    => "invalid_nonce",
--                                         "message" => __( "Security check failed." ),
--                                 )
--                         );
--                 end;

--                 changeset_post_id = this->changeset_post_id();

--                 if ( empty( changeset_post_id ) ) then
--                         wp_send_json_error(
--                                 array(
--                                         "code"    => "no_changeset_found_to_take_over",
--                                         "message" => __( "No changeset found to take over" ),
--                                 )
--                         );
--                 end;

--                 if ( ! current_user_can( get_post_type_object( "customize_changeset" )->cap->edit_post, changeset_post_id ) ) then
--                         wp_send_json_error(
--                                 array(
--                                         "code"    => "cannot_remove_changeset_lock",
--                                         "message" => __( "Sorry, you are not allowed to take over." ),
--                                 )
--                         );
--                 end;

--                 this->set_changeset_lock( changeset_post_id, true );

--                 wp_send_json_success( "changeset_taken_over" );
--         end;

--         --
--         -- Determines whether a changeset revision should be made.
--         --
--         -- @since 4.7.0
--         -- @var bool
--         --
--         protected store_changeset_revision;

--         --
--         -- Filters whether a changeset has changed to create a new revision.
--         --
--         -- Note that this will not be called while a changeset post remains in auto-draft status.
--         --
--         -- @since 4.7.0
--         --
--         -- @param bool    post_has_changed Whether the post has changed.
--         -- @param WP_Post latest_revision  The latest revision post object.
--         -- @param WP_Post post             The post object.
--         -- @return bool Whether a revision should be made.
--         --
--         public function _filter_revision_post_has_changed( post_has_changed, latest_revision, post ) then
--                 unset( latest_revision );
--                 if ( "customize_changeset" === post->post_type ) then
--                         post_has_changed = this->store_changeset_revision;
--                 end;
--                 return post_has_changed;
--         end;

--         --
--         -- Publishes the values of a changeset.
--         --
--         -- This will publish the values contained in a changeset, even changesets that do not
--         -- correspond to current manager instance. This is called by
--         -- `_wp_customize_publish_changeset()` when a customize_changeset post is
--         -- transitioned to the `publish` status. As such, this method should not be
--         -- called directly and instead `wp_publish_post()` should be used.
--         --
--         -- Please note that if the settings in the changeset are for a non-activated
--         -- theme, the theme must first be switched to (via `switch_theme()`) before
--         -- invoking this method.
--         --
--         -- @since 4.7.0
--         --
--         -- @see _wp_customize_publish_changeset()
--         -- @global wpdb wpdb WordPress database abstraction object.
--         --
--         -- @param int changeset_post_id ID for customize_changeset post. Defaults to the changeset for the current manager instance.
--         -- @return true|WP_Error True or error info.
--         --
--         public function _publish_changeset_values( changeset_post_id ) then
--                 global wpdb;

--                 publishing_changeset_data = this->get_changeset_post_data( changeset_post_id );
--                 if ( is_wp_error( publishing_changeset_data ) ) then
--                         return publishing_changeset_data;
--                 end;

--                 changeset_post = get_post( changeset_post_id );

--                 /*
--                 -- Temporarily override the changeset context so that it will be read
--                 -- in calls to unsanitized_post_values() and so that it will be available
--                 -- on the wp_customize object passed to hooks during the save logic.
--                 --
--                 previous_changeset_post_id = this->_changeset_post_id;
--                 this->_changeset_post_id   = changeset_post_id;
--                 previous_changeset_uuid    = this->_changeset_uuid;
--                 this->_changeset_uuid      = changeset_post->post_name;
--                 previous_changeset_data    = this->_changeset_data;
--                 this->_changeset_data      = publishing_changeset_data;

--                 -- Parse changeset data to identify theme mod settings and user IDs associated with settings to be saved.
--                 setting_user_ids   = array();
--                 theme_mod_settings = array();
--                 namespace_pattern  = "/^(?P<stylesheet>.+?)::(?P<setting_id>.+)/";
--                 matches            = array();
--                 foreach ( this->_changeset_data as raw_setting_id => setting_params ) then
--                         actual_setting_id    = null;
--                         is_theme_mod_setting = (
--                                 isset( setting_params["value"] )
--                                 &&
--                                 isset( setting_params["type"] )
--                                 &&
--                                 "theme_mod" === setting_params["type"]
--                                 &&
--                                 preg_match( namespace_pattern, raw_setting_id, matches )
--                         );
--                         if ( is_theme_mod_setting ) then
--                                 if ( ! isset( theme_mod_settings[ matches["stylesheet"] ] ) ) then
--                                         theme_mod_settings[ matches["stylesheet"] ] = array();
--                                 end;
--                                 theme_mod_settings[ matches["stylesheet"] ][ matches["setting_id"] ] = setting_params;

--                                 if ( this->get_stylesheet() === matches["stylesheet"] ) then
--                                         actual_setting_id = matches["setting_id"];
--                                 end;
--                         end; else then
--                                 actual_setting_id = raw_setting_id;
--                         end;

--                         -- Keep track of the user IDs for settings actually for this theme.
--                         if ( actual_setting_id && isset( setting_params["user_id"] ) ) then
--                                 setting_user_ids[ actual_setting_id ] = setting_params["user_id"];
--                         end;
--                 end;

--                 changeset_setting_values = this->unsanitized_post_values(
--                         array(
--                                 "exclude_post_data" => true,
--                                 "exclude_changeset" => false,
--                         )
--                 );
--                 changeset_setting_ids    = array_keys( changeset_setting_values );
--                 this->add_dynamic_settings( changeset_setting_ids );

--                 --
--                 -- Fires once the theme has switched in the Customizer, but before settings
--                 -- have been saved.
--                 --
--                 -- @since 3.4.0
--                 --
--                 -- @param WP_Customize_Manager manager WP_Customize_Manager instance.
--                 --
--                 do_action( "customize_save", this );

--                 /*
--                 -- Ensure that all settings will allow themselves to be saved. Note that
--                 -- this is safe because the setting would have checked the capability
--                 -- when the setting value was written into the changeset. So this is why
--                 -- an additional capability check is not required here.
--                 --
--                 original_setting_capabilities = array();
--                 foreach ( changeset_setting_ids as setting_id ) then
--                         setting = this->get_setting( setting_id );
--                         if ( setting && ! isset( setting_user_ids[ setting_id ] ) ) then
--                                 original_setting_capabilities[ setting->id ] = setting->capability;
--                                 setting->capability                           = "exist";
--                         end;
--                 end;

--                 original_user_id = get_current_user_id();
--                 foreach ( changeset_setting_ids as setting_id ) then
--                         setting = this->get_setting( setting_id );
--                         if ( setting ) then
--                                 /*
--                                 -- Set the current user to match the user who saved the value into
--                                 -- the changeset so that any filters that apply during the save
--                                 -- process will respect the original user"s capabilities. This
--                                 -- will ensure, for example, that KSES won"t strip unsafe HTML
--                                 -- when a scheduled changeset publishes via WP Cron.
--                                 --
--                                 if ( isset( setting_user_ids[ setting_id ] ) ) then
--                                         wp_set_current_user( setting_user_ids[ setting_id ] );
--                                 end; else then
--                                         wp_set_current_user( original_user_id );
--                                 end;

--                                 setting->save();
--                         end;
--                 end;
--                 wp_set_current_user( original_user_id );

--                 -- Update the stashed theme mod settings, removing the active theme"s stashed settings, if activated.
--                 if ( did_action( "switch_theme" ) ) then
--                         other_theme_mod_settings = theme_mod_settings;
--                         unset( other_theme_mod_settings[ this->get_stylesheet() ] );
--                         this->update_stashed_theme_mod_settings( other_theme_mod_settings );
--                 end;

--                 --
--                 -- Fires after Customize settings have been saved.
--                 --
--                 -- @since 3.6.0
--                 --
--                 -- @param WP_Customize_Manager manager WP_Customize_Manager instance.
--                 --
--                 do_action( "customize_save_after", this );

--                 -- Restore original capabilities.
--                 foreach ( original_setting_capabilities as setting_id => capability ) then
--                         setting = this->get_setting( setting_id );
--                         if ( setting ) then
--                                 setting->capability = capability;
--                         end;
--                 end;

--                 -- Restore original changeset data.
--                 this->_changeset_data    = previous_changeset_data;
--                 this->_changeset_post_id = previous_changeset_post_id;
--                 this->_changeset_uuid    = previous_changeset_uuid;

--                 /*
--                 -- Convert all autosave revisions into their own auto-drafts so that users can be prompted to
--                 -- restore them when a changeset is published, but they had been locked out from including
--                 -- their changes in the changeset.
--                 --
--                 revisions = wp_get_post_revisions( changeset_post_id, array( "check_enabled" => false ) );
--                 foreach ( revisions as revision ) then
--                         if ( false !== strpos( revision->post_name, "thenchangeset_post_idend;-autosave" ) ) then
--                                 wpdb->update(
--                                         wpdb->posts,
--                                         array(
--                                                 "post_status" => "auto-draft",
--                                                 "post_type"   => "customize_changeset",
--                                                 "post_name"   => wp_generate_uuid4(),
--                                                 "post_parent" => 0,
--                                         ),
--                                         array(
--                                                 "ID" => revision->ID,
--                                         )
--                                 );
--                                 clean_post_cache( revision->ID );
--                         end;
--                 end;

--                 return true;
--         end;

--         --
--         -- Updates stashed theme mod settings.
--         --
--         -- @since 4.7.0
--         --
--         -- @param array inactive_theme_mod_settings Mapping of stylesheet to arrays of theme mod settings.
--         -- @return array|false Returns array of updated stashed theme mods or false if the update failed or there were no changes.
--         --
--         protected function update_stashed_theme_mod_settings( inactive_theme_mod_settings ) then
--                 stashed_theme_mod_settings = get_option( "customize_stashed_theme_mods" );
--                 if ( empty( stashed_theme_mod_settings ) ) then
--                         stashed_theme_mod_settings = array();
--                 end;

--                 -- Delete any stashed theme mods for the active theme since they would have been loaded and saved upon activation.
--                 unset( stashed_theme_mod_settings[ this->get_stylesheet() ] );

--                 -- Merge inactive theme mods with the stashed theme mod settings.
--                 foreach ( inactive_theme_mod_settings as stylesheet => theme_mod_settings ) then
--                         if ( ! isset( stashed_theme_mod_settings[ stylesheet ] ) ) then
--                                 stashed_theme_mod_settings[ stylesheet ] = array();
--                         end;

--                         stashed_theme_mod_settings[ stylesheet ] = array_merge(
--                                 stashed_theme_mod_settings[ stylesheet ],
--                                 theme_mod_settings
--                         );
--                 end;

--                 autoload = false;
--                 result   = update_option( "customize_stashed_theme_mods", stashed_theme_mod_settings, autoload );
--                 if ( ! result ) then
--                         return false;
--                 end;
--                 return stashed_theme_mod_settings;
--         end;

--         --
--         -- Refreshes nonces for the current preview.
--         --
--         -- @since 4.2.0
--         --
--         public function refresh_nonces() then
--                 if ( ! this->is_preview() ) then
--                         wp_send_json_error( "not_preview" );
--                 end;

--                 wp_send_json_success( this->get_nonces() );
--         end;

--         --
--         -- Deletes a given auto-draft changeset or the autosave revision for a given changeset or delete changeset lock.
--         --
--         -- @since 4.9.0
--         --
--         public function handle_dismiss_autosave_or_lock_request() then
--                 -- Calls to dismiss_user_auto_draft_changesets() and wp_get_post_autosave() require non-zero get_current_user_id().
--                 if ( ! is_user_logged_in() ) then
--                         wp_send_json_error( "unauthenticated", 401 );
--                 end;

--                 if ( ! this->is_preview() ) then
--                         wp_send_json_error( "not_preview", 400 );
--                 end;

--                 if ( ! check_ajax_referer( "customize_dismiss_autosave_or_lock", "nonce", false ) ) then
--                         wp_send_json_error( "invalid_nonce", 403 );
--                 end;

--                 changeset_post_id = this->changeset_post_id();
--                 dismiss_lock      = ! empty( _POST["dismiss_lock"] );
--                 dismiss_autosave  = ! empty( _POST["dismiss_autosave"] );

--                 if ( dismiss_lock ) then
--                         if ( empty( changeset_post_id ) && ! dismiss_autosave ) then
--                                 wp_send_json_error( "no_changeset_to_dismiss_lock", 404 );
--                         end;
--                         if ( ! current_user_can( get_post_type_object( "customize_changeset" )->cap->edit_post, changeset_post_id ) && ! dismiss_autosave ) then
--                                 wp_send_json_error( "cannot_remove_changeset_lock", 403 );
--                         end;

--                         delete_post_meta( changeset_post_id, "_edit_lock" );

--                         if ( ! dismiss_autosave ) then
--                                 wp_send_json_success( "changeset_lock_dismissed" );
--                         end;
--                 end;

--                 if ( dismiss_autosave ) then
--                         if ( empty( changeset_post_id ) || "auto-draft" === get_post_status( changeset_post_id ) ) then
--                                 dismissed = this->dismiss_user_auto_draft_changesets();
--                                 if ( dismissed > 0 ) then
--                                         wp_send_json_success( "auto_draft_dismissed" );
--                                 end; else then
--                                         wp_send_json_error( "no_auto_draft_to_delete", 404 );
--                                 end;
--                         end; else then
--                                 revision = wp_get_post_autosave( changeset_post_id, get_current_user_id() );

--                                 if ( revision ) then
--                                         if ( ! current_user_can( get_post_type_object( "customize_changeset" )->cap->delete_post, changeset_post_id ) ) then
--                                                 wp_send_json_error( "cannot_delete_autosave_revision", 403 );
--                                         end;

--                                         if ( ! wp_delete_post( revision->ID, true ) ) then
--                                                 wp_send_json_error( "autosave_revision_deletion_failure", 500 );
--                                         end; else then
--                                                 wp_send_json_success( "autosave_revision_deleted" );
--                                         end;
--                                 end; else then
--                                         wp_send_json_error( "no_autosave_revision_to_delete", 404 );
--                                 end;
--                         end;
--                 end;

--                 wp_send_json_error( "unknown_error", 500 );
--         end;

   -----------------
   -- Add_Setting --
   -----------------

   function Add_Setting (This : Wp_Customize_Manager;
                         Id   : String;
                         Args : Array_Type := Empty_Array)
                         return Inc_Class_Wp_Customize_Settings.Wp_Customize_Setting
   is
      use Inc_Class_Wp_Customize_Settings;
      use Inc_Plugins;

      Args_2 : Array_Type := Args;
      Setting : Wp_Customize_Setting;
   begin
--    if Id in WP_Customize_Setting then -- instanceof
--       Setting := Id;
--    else
         declare
            Class   : Wp_Customize_Setting;
         begin
            -- This filter is documented in wp-includes/class-wp-customize-manager.php
            Args_2 := Apply_Filters ("customize_dynamic_setting_args", Args_2, Id);

            -- This filter is documented in wp-includes/class-wp-customize-manager.php
            Class := Apply_Filters ("customize_dynamic_setting_class",
                                    Class, Id, Args_2);

--          Setting := new Class (This, Id, Args_2);
         end;
--    end if;

--    Set (This.Settings, -Setting.Id, Setting);
      return Setting;
   end Add_Setting;

   procedure Add_Setting (This : Wp_Customize_Manager;
                          Id   : String;
                          Args : Array_Type := Empty_Array)
   is
      use Inc_Class_Wp_Customize_Settings;
      Unused : constant Wp_Customize_Setting :=
        Add_Setting (This, Id, Args);
   begin
      null;
   end Add_Setting;

   procedure Add_Setting (This : Wp_Customize_Manager;
                          Id   : Wp_Customize_Setting;
                          Args : Array_Type := Empty_Array)
   is null;

   --------------------------
   -- Add_Dynamic_Settings --
   --------------------------

   function Add_Dynamic_Settings (This : Wp_Customize_Manager;
                                  Setting_Ids : List_Type)
                                  return Setting_Lists.Vector -- Array_Type;
   is
      use Inc_Class_Wp_Customize_Settings;
      use Inc_Plugins;

      New_Settings : Setting_Lists.Vector; -- Array_Type;
   begin
      for Setting_Id of Setting_Ids loop
         -- Skip settings already created.
         if This.Get_Setting (-Setting_Id) /= Null_Setting then
--       if This.Get_Setting (-Setting_Id) then
            goto Continue;
         end if;

         declare
            Setting_Args  : Boolean := False;
            Setting_Class : Wp_Customize_Setting;
            Setting       : Wp_Customize_Setting;
         begin
            --
            -- Filters a dynamic setting"s constructor args.
            --
            -- For a dynamic setting to be registered, this filter must be employed
            -- to override the default false value with an array of args to pass to
            -- the WP_Customize_Setting constructor.
            --
            -- @since 4.2.0
            --
            -- @param false|array setting_args The arguments to the
            --                                  WP_Customize_Setting constructor.
            -- @param string      setting_id   ID for dynamic setting, usually coming
            --                                  from `_POST["customized"]`.
            --
            Setting_Args :=
              Apply_Filters ("customize_dynamic_setting_args",
                             Setting_Args, -Setting_Id);

            if False = Setting_Args then
               goto Continue;
            end if;

            --
            -- Allow non-statically created settings to be constructed with custom
            -- WP_Customize_Setting subclass.
            --
            -- @since 4.2.0
            --
            -- @param string setting_class WP_Customize_Setting or a subclass.
            -- @param string setting_id    ID for dynamic setting, usually coming
            --                              from `_POST["customized"]`.
            -- @param array  setting_args  WP_Customize_Setting or a subclass.
            --
            Setting_Class :=
              Apply_Filters ("customize_dynamic_setting_class",
                             Setting_Class, -Setting_Id, Setting_Args);

--          Setting := new Setting_Class (This, Setting_Id, Setting_Args);

            This.Add_Setting (Setting);
            New_Settings.Append (Setting);
         end;
         << Continue >>
      end loop;
      return New_Settings;
   end Add_Dynamic_Settings;

   -----------------
   -- Get_Setting --
   -----------------

   function Get_Setting (This : Wp_Customize_Manager;
                         Id   : String)
                         return Inc_Class_Wp_Customize_Settings.Wp_Customize_Setting
   is
      use Inc_Class_Wp_Customize_Settings;
   begin
      if Isset (This.Settings, Id) then
         return Null_Setting; -- This.Settings (Id);
      end if;
      return Null_Setting; -- added
   end Get_Setting;

--         --
--         -- Removes a customize setting.
--         --
--         -- Note that removing the setting doesn"t destroy the WP_Customize_Setting instance or remove its filters.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string id Customize Setting ID.
--         --
--         public function remove_setting( id ) then
--                 unset( this->settings[ id ] );
--         end;

   ---------------
   -- Add_Panel --
   ---------------

   function Add_Panel (This : aliased Wp_Customize_Manager;
                       Id   : String;
                       Args : Array_Type := Empty_Array)
                       return Inc_Class_Wp_Customize_Panels.Wp_Customize_Panel
   is
      use Inc_Class_Wp_Customize_Panels;

      Panel : Wp_Customize_Panel;
   begin
--      if Id in WP_Customize_Panel then -- instanceof
--         Panel := Id;
--      else
         Panel := X_Construct (This'Unrestricted_Access, Id, Args);
         -- new Wp_Customize_Panel (This, Id, Args);
--      end if;

--    This.Panels (Panel.Id) := Panel;
      return Panel;
   end Add_Panel;

   procedure Add_Panel (This : Wp_Customize_Manager;
                        Id   : String;
                        Args : Array_Type := Empty_Array)
   is
      use Inc_Class_Wp_Customize_Panels;

      Unused : constant Wp_Customize_Panel := Add_Panel (This, Id, Args);
   begin
      null;
   end Add_Panel;

   ---------------
   -- Get_Panel --
   ---------------

   function Get_Panel (This : Wp_Customize_Manager;
                       Id   : String)
                       return Inc_Class_Wp_Customize_Panels.Wp_Customize_Panel
   is
      use Inc_Class_Wp_Customize_Panels;
   begin
      if Isset (This.Panels, Id) then
         return Null_Panel; -- This.Panels (Id);
      end if;
      raise Program_Error with "no return";
   end Get_Panel;

--         --
--         -- Removes a customize panel.
--         --
--         -- Note that removing the panel doesn"t destroy the WP_Customize_Panel instance or remove its filters.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string id Panel ID to remove.
--         --
--         public function remove_panel( id ) then
--                 -- Removing core components this way is _doing_it_wrong().
--                 if ( in_array( id, this->components, true ) ) then
--                         _doing_it_wrong(
--                                 __METHOD__,
--                                 sprintf(
--                                         /* translators: 1: Panel ID, 2: Link to "customize_loaded_components" filter reference.--
--                                         __( "Removing %1s manually will cause PHP warnings. Use the %2s filter instead." ),
--                                         id,
--                                         sprintf(
--                                                 "<a href="%1s">%2s</a>",
--                                                 esc_url( "https://developer.wordpress.org/reference/hooks/customize_loaded_components/" ),
--                                                 "<code>customize_loaded_components</code>"
--                                         )
--                                 ),
--                                 "4.5.0"
--                         );
--                 end;
--                 unset( this->panels[ id ] );
--         end;

--         --
--         -- Registers a customize panel type.
--         --
--         -- Registered types are eligible to be rendered via JS and created dynamically.
--         --
--         -- @since 4.3.0
--         --
--         -- @see WP_Customize_Panel
--         --
--         -- @param string panel Name of a custom panel which is a subclass of WP_Customize_Panel.
--         --
--         public function register_panel_type( panel ) then
--                 this->registered_panel_types[] = panel;
--         end;

--         --
--         -- Renders JS templates for all registered panel types.
--         --
--         -- @since 4.3.0
--         --
--         public function render_panel_templates() then
--                 foreach ( this->registered_panel_types as panel_type ) then
--                         panel = new panel_type( this, "temp", array() );
--                         panel->print_template();
--                 end;
--         end;

   -----------------
   -- Add_Section --
   -----------------

   function Add_Section (This : aliased Wp_Customize_Manager;
                         Id   : String;
                         Args : Array_Type := Empty_Array)
                         return Inc_Class_Wp_Customize_Sections.Wp_Customize_Section
   is
      use Inc_Class_Wp_Customize_Sections;

      Section : Wp_Customize_Section;
   begin
--    if Id in Wp_Customize_Section then -- instanceof
--       Section := Id;
--    else
         Section := X_Construct (This'Unrestricted_Access, Id, Args);
         -- new Wp_Customize_Section (This, Id, Args);
--    end if;

--    This.Sections (-Section.Id) := Section;
      return Section;
   end Add_Section;

   function Add_Section (This : aliased Wp_Customize_Manager;
                         Id   : Inc_Class_Wp_Customize_Sections.Wp_Customize_Section;
                         Args : Array_Type := Empty_Array)
                         return Inc_Class_Wp_Customize_Sections.Wp_Customize_Section
   is
      use Inc_Class_Wp_Customize_Sections;

      Section : Wp_Customize_Section;
   begin
      if Id in Wp_Customize_Section then -- instanceof
         Section := Id;
--    else
--         Section := X_Construct (This'Unrestricted_Access, Id, Args);
         -- new Wp_Customize_Section (This, Id, Args);
      end if;

--    This.Sections (-Section.Id) := Section;
      return Section;
   end Add_Section;

   procedure Add_Section (This : Wp_Customize_Manager;
                          Id   : String;
                          Args : Array_Type := Empty_Array)
   is
      use Inc_Class_Wp_Customize_Sections;

      Unused : constant Wp_Customize_Section := Add_Section (This, Id, Args);
   begin
      null;
   end Add_Section;

   procedure Add_Section (This : Wp_Customize_Manager;
                          Id   : Inc_Class_Wp_Customize_Sections.Wp_Customize_Section;
                          Args : Array_Type := Empty_Array)
   is
      use Inc_Class_Wp_Customize_Sections;

      Unused : constant Wp_Customize_Section := Add_Section (This, Id, Args);
   begin
      null;
   end Add_Section;

--         --
--         -- Retrieves a customize section.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string id Section ID.
--         -- @return WP_Customize_Section|void The section, if set.
--         --
--         public function get_section( id ) then
--                 if ( isset( this->sections[ id ] ) ) then
--                         return this->sections[ id ];
--                 end;
--         end;

--         --
--         -- Removes a customize section.
--         --
--         -- Note that removing the section doesn"t destroy the WP_Customize_Section instance or remove its filters.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string id Section ID.
--         --
--         public function remove_section( id ) then
--                 unset( this->sections[ id ] );
--         end;

--         --
--         -- Registers a customize section type.
--         --
--         -- Registered types are eligible to be rendered via JS and created dynamically.
--         --
--         -- @since 4.3.0
--         --
--         -- @see WP_Customize_Section
--         --
--         -- @param string section Name of a custom section which is a subclass of WP_Customize_Section.
--         --
--         public function register_section_type( section ) then
--                 this->registered_section_types[] = section;
--         end;

--         --
--         -- Renders JS templates for all registered section types.
--         --
--         -- @since 4.3.0
--         --
--         public function render_section_templates() then
--                 foreach ( this->registered_section_types as section_type ) then
--                         section = new section_type( this, "temp", array() );
--                         section->print_template();
--                 end;
--         end;

   -----------------
   -- Add_Control --
   -----------------

   function Add_Control (This : aliased Wp_Customize_Manager;
                         Id   : String;
                         Args : Array_Type := Empty_Array)
                         return Inc_Class_Wp_Customize_Controls.Wp_Customize_Control
   is
      use Inc_Class_Wp_Customize_Controls;

      Control : Wp_Customize_Control;
   begin
--    if Id in WP_Customize_Control then -- instanceof
--       Control := Id;
--    else
         Control := X_Construct (This'Unrestricted_Access, Id, Args);
         -- new Wp_Customize_Control (This, Id, Args);
--    end if;

--    This.Controls (-Control.Id) := Control;
      return Control;
   end Add_Control;

   function Add_Control (This : aliased Wp_Customize_Manager;
                         Id   : Inc_Class_Wp_Customize_Controls.Wp_Customize_Control;
                         Args : Array_Type := Empty_Array)
                         return Inc_Class_Wp_Customize_Controls.Wp_Customize_Control
   is
      use Inc_Class_Wp_Customize_Controls;

      Control : Wp_Customize_Control;
   begin
--    if Id in WP_Customize_Control then -- instanceof
      Control := Id;
--    else
--         Control := X_Construct (This'Unrestricted_Access, Id, Args);
         -- new Wp_Customize_Control (This, Id, Args);
--    end if;

--    This.Controls (-Control.Id) := Control;
      return Control;
   end Add_Control;

   procedure Add_Control (This : Wp_Customize_Manager;
                          Id   : Inc_Class_Wp_Customize_Controls.Wp_Customize_Control;
                          Args : Array_Type := Empty_Array)
   is
      use Inc_Class_Wp_Customize_Controls;

      Unused : constant Wp_Customize_Control := Add_Control (This, Id, Args);
   begin
      null;
   end Add_Control;

--         --
--         -- Retrieves a customize control.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string id ID of the control.
--         -- @return WP_Customize_Control|void The control object, if set.
--         --
--         public function get_control( id ) then
--                 if ( isset( this->controls[ id ] ) ) then
--                         return this->controls[ id ];
--                 end;
--         end;

--         --
--         -- Removes a customize control.
--         --
--         -- Note that removing the control doesn"t destroy the WP_Customize_Control instance or remove its filters.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string id ID of the control.
--         --
--         public function remove_control( id ) then
--                 unset( this->controls[ id ] );
--         end;

--         --
--         -- Registers a customize control type.
--         --
--         -- Registered types are eligible to be rendered via JS and created dynamically.
--         --
--         -- @since 4.1.0
--         --
--         -- @param string control Name of a custom control which is a subclass of
--         --                        WP_Customize_Control.
--         --
--         public function register_control_type( control ) then
--                 this->registered_control_types[] = control;
--         end;

--         --
--         -- Renders JS templates for all registered control types.
--         --
--         -- @since 4.1.0
--         --
--         public function render_control_templates() then
--                 if ( this->branching() ) then
--                         l10n = array(
--                                 /* translators: %s: User who is customizing the changeset in customizer.--
--                                 "locked"                => __( "%s is already customizing this changeset. Please wait until they are done to try customizing. Your latest changes have been autosaved." ),
--                                 /* translators: %s: User who is customizing the changeset in customizer.--
--                                 "locked_allow_override" => __( "%s is already customizing this changeset. Do you want to take over?" ),
--                         );
--                 end; else then
--                         l10n = array(
--                                 /* translators: %s: User who is customizing the changeset in customizer.--
--                                 "locked"                => __( "%s is already customizing this site. Please wait until they are done to try customizing. Your latest changes have been autosaved." ),
--                                 /* translators: %s: User who is customizing the changeset in customizer.--
--                                 "locked_allow_override" => __( "%s is already customizing this site. Do you want to take over?" ),
--                         );
--                 end;

--                 foreach ( this->registered_control_types as control_type ) then
--                         control = new control_type(
--                                 this,
--                                 "temp",
--                                 array(
--                                         "settings" => array(),
--                                 )
--                         );
--                         control->print_template();
--                 end;
--                 ?>

--                 <script type="text/html" id="tmpl-customize-control-default-content">
--                         <#
--                         var inputId = _.uniqueId( "customize-control-default-input-" );
--                         var descriptionId = _.uniqueId( "customize-control-default-description-" );
--                         var describedByAttr = data.description ? " aria-describedby="" + descriptionId + "" " : "";
--                         #>
--                         <# switch ( data.type ) then
--                                 case "checkbox": #>
--                                         <span class="customize-inside-control-row">
--                                                 <input
--                                                         id="thenthen inputId end;end;"
--                                                         thenthenthen describedByAttr end;end;end;
--                                                         type="checkbox"
--                                                         value="thenthen data.value end;end;"
--                                                         data-customize-setting-key-link="default"
--                                                 >
--                                                 <label for="thenthen inputId end;end;">
--                                                         thenthen data.label end;end;
--                                                 </label>
--                                                 <# if ( data.description ) then #>
--                                                         <span id="thenthen descriptionId end;end;" class="description customize-control-description">thenthenthen data.description end;end;end;</span>
--                                                 <# end; #>
--                                         </span>
--                                         <#
--                                         break;
--                                 case "radio":
--                                         if ( ! data.choices ) then
--                                                 return;
--                                         end;
--                                         #>
--                                         <# if ( data.label ) then #>
--                                                 <label for="thenthen inputId end;end;" class="customize-control-title">
--                                                         thenthen data.label end;end;
--                                                 </label>
--                                         <# end; #>
--                                         <# if ( data.description ) then #>
--                                                 <span id="thenthen descriptionId end;end;" class="description customize-control-description">thenthenthen data.description end;end;end;</span>
--                                         <# end; #>
--                                         <# _.each( data.choices, function( val, key ) then #>
--                                                 <span class="customize-inside-control-row">
--                                                         <#
--                                                         var value, text;
--                                                         if ( _.isObject( val ) ) then
--                                                                 value = val.value;
--                                                                 text = val.text;
--                                                         end; else then
--                                                                 value = key;
--                                                                 text = val;
--                                                         end;
--                                                         #>
--                                                         <input
--                                                                 id="thenthen inputId + "-" + value end;end;"
--                                                                 type="radio"
--                                                                 value="thenthen value end;end;"
--                                                                 name="thenthen inputId end;end;"
--                                                                 data-customize-setting-key-link="default"
--                                                                 thenthenthen describedByAttr end;end;end;
--                                                         >
--                                                         <label for="thenthen inputId + "-" + value end;end;">thenthen text end;end;</label>
--                                                 </span>
--                                         <# end; ); #>
--                                         <#
--                                         break;
--                                 default:
--                                         #>
--                                         <# if ( data.label ) then #>
--                                                 <label for="thenthen inputId end;end;" class="customize-control-title">
--                                                         thenthen data.label end;end;
--                                                 </label>
--                                         <# end; #>
--                                         <# if ( data.description ) then #>
--                                                 <span id="thenthen descriptionId end;end;" class="description customize-control-description">thenthenthen data.description end;end;end;</span>
--                                         <# end; #>

--                                         <#
--                                         var inputAttrs = then
--                                                 id: inputId,
--                                                 "data-customize-setting-key-link": "default"
--                                         end;;
--                                         if ( "textarea" === data.type ) then
--                                                 inputAttrs.rows = "5";
--                                         end; else if ( "button" === data.type ) then
--                                                 inputAttrs["class"] = "button button-secondary";
--                                                 inputAttrs.type = "button";
--                                         end; else then
--                                                 inputAttrs.type = data.type;
--                                         end;
--                                         if ( data.description ) then
--                                                 inputAttrs["aria-describedby"] = descriptionId;
--                                         end;
--                                         _.extend( inputAttrs, data.input_attrs );
--                                         #>

--                                         <# if ( "button" === data.type ) then #>
--                                                 <button
--                                                         <# _.each( _.extend( inputAttrs ), function( value, key ) then #>
--                                                                 thenthenthen key end;end;end;="thenthen value end;end;"
--                                                         <# end; ); #>
--                                                 >thenthen inputAttrs.value end;end;</button>
--                                         <# end; else if ( "textarea" === data.type ) then #>
--                                                 <textarea
--                                                         <# _.each( _.extend( inputAttrs ), function( value, key ) then #>
--                                                                 thenthenthen key end;end;end;="thenthen value end;end;"
--                                                         <# end;); #>
--                                                 >thenthen inputAttrs.value end;end;</textarea>
--                                         <# end; else if ( "select" === data.type ) then #>
--                                                 <# delete inputAttrs.type; #>
--                                                 <select
--                                                         <# _.each( _.extend( inputAttrs ), function( value, key ) then #>
--                                                                 thenthenthen key end;end;end;="thenthen value end;end;"
--                                                         <# end;); #>
--                                                         >
--                                                         <# _.each( data.choices, function( val, key ) then #>
--                                                                 <#
--                                                                 var value, text;
--                                                                 if ( _.isObject( val ) ) then
--                                                                         value = val.value;
--                                                                         text = val.text;
--                                                                 end; else then
--                                                                         value = key;
--                                                                         text = val;
--                                                                 end;
--                                                                 #>
--                                                                 <option value="thenthen value end;end;">thenthen text end;end;</option>
--                                                         <# end; ); #>
--                                                 </select>
--                                         <# end; else then #>
--                                                 <input
--                                                         <# _.each( _.extend( inputAttrs ), function( value, key ) then #>
--                                                                 thenthenthen key end;end;end;="thenthen value end;end;"
--                                                         <# end;); #>
--                                                         >
--                                         <# end; #>
--                         <# end; #>
--                 </script>

--                 <script type="text/html" id="tmpl-customize-notification">
--                         <li class="notice notice-thenthen data.type || "info" end;end; thenthen data.alt ? "notice-alt" : "" end;end; thenthen data.dismissible ? "is-dismissible" : "" end;end; thenthen data.containerClasses || "" end;end;" data-code="thenthen data.code end;end;" data-type="thenthen data.type end;end;">
--                                 <div class="notification-message">thenthenthen data.message || data.code end;end;end;</div>
--                                 <# if ( data.dismissible ) then #>
--                                         <button type="button" class="notice-dismiss"><span class="screen-reader-text"><?php _e( "Dismiss" ); ?></span></button>
--                                 <# end; #>
--                         </li>
--                 </script>

--                 <script type="text/html" id="tmpl-customize-changeset-locked-notification">
--                         <li class="notice notice-thenthen data.type || "info" end;end; thenthen data.containerClasses || "" end;end;" data-code="thenthen data.code end;end;" data-type="thenthen data.type end;end;">
--                                 <div class="notification-message customize-changeset-locked-message">
--                                         <img class="customize-changeset-locked-avatar" src="thenthen data.lockUser.avatar end;end;" alt="thenthen data.lockUser.name end;end;" />
--                                         <p class="currently-editing">
--                                                 <# if ( data.message ) then #>
--                                                         thenthenthen data.message end;end;end;
--                                                 <# end; else if ( data.allowOverride ) then #>
--                                                         <?php
--                                                         echo esc_html( sprintf( l10n["locked_allow_override"], "thenthen data.lockUser.name end;end;" ) );
--                                                         ?>
--                                                 <# end; else then #>
--                                                         <?php
--                                                         echo esc_html( sprintf( l10n["locked"], "thenthen data.lockUser.name end;end;" ) );
--                                                         ?>
--                                                 <# end; #>
--                                         </p>
--                                         <p class="notice notice-error notice-alt" hidden></p>
--                                         <p class="action-buttons">
--                                                 <# if ( data.returnUrl !== data.previewUrl ) then #>
--                                                         <a class="button customize-notice-go-back-button" href="thenthen data.returnUrl end;end;"><?php _e( "Go back" ); ?></a>
--                                                 <# end; #>
--                                                 <a class="button customize-notice-preview-button" href="thenthen data.frontendPreviewUrl end;end;"><?php _e( "Preview" ); ?></a>
--                                                 <# if ( data.allowOverride ) then #>
--                                                         <button class="button button-primary wp-tab-last customize-notice-take-over-button"><?php _e( "Take over" ); ?></button>
--                                                 <# end; #>
--                                         </p>
--                                 </div>
--                         </li>
--                 </script>

--                 <script type="text/html" id="tmpl-customize-code-editor-lint-error-notification">
--                         <li class="notice notice-thenthen data.type || "info" end;end; thenthen data.alt ? "notice-alt" : "" end;end; thenthen data.dismissible ? "is-dismissible" : "" end;end; thenthen data.containerClasses || "" end;end;" data-code="thenthen data.code end;end;" data-type="thenthen data.type end;end;">
--                                 <div class="notification-message">thenthenthen data.message || data.code end;end;end;</div>

--                                 <p>
--                                         <# var elementId = "el-" + String( Math.random() ); #>
--                                         <input id="thenthen elementId end;end;" type="checkbox">
--                                         <label for="thenthen elementId end;end;"><?php _e( "Update anyway, even though it might break your site?" ); ?></label>
--                                 </p>
--                         </li>
--                 </script>

--                 <?php
--                 /* The following template is obsolete in core but retained for plugins.--
--                 ?>
--                 <script type="text/html" id="tmpl-customize-control-notifications">
--                         <ul>
--                                 <# _.each( data.notifications, function( notification ) then #>
--                                         <li class="notice notice-thenthen notification.type || "info" end;end; thenthen data.altNotice ? "notice-alt" : "" end;end;" data-code="thenthen notification.code end;end;" data-type="thenthen notification.type end;end;">thenthenthen notification.message || notification.code end;end;end;</li>
--                                 <# end; ); #>
--                         </ul>
--                 </script>

--                 <script type="text/html" id="tmpl-customize-preview-link-control" >
--                         <# var elementPrefix = _.uniqueId( "el" ) + "-" #>
--                         <p class="customize-control-title">
--                                 <?php esc_html_e( "Share Preview Link" ); ?>
--                         </p>
--                         <p class="description customize-control-description"><?php esc_html_e( "See how changes would look live on your website, and share the preview with people who can\"t access the Customizer." ); ?></p>
--                         <div class="customize-control-notifications-container"></div>
--                         <div class="preview-link-wrapper">
--                                 <label for="thenthen elementPrefix end;end;customize-preview-link-input" class="screen-reader-text"><?php esc_html_e( "Preview Link" ); ?></label>
--                                 <a href="" target="">
--                                         <span class="preview-control-element" data-component="url"></span>
--                                         <span class="screen-reader-text"><?php _e( "(opens in a new tab)" ); ?></span>
--                                 </a>
--                                 <input id="thenthen elementPrefix end;end;customize-preview-link-input" readonly tabindex="-1" class="preview-control-element" data-component="input">
--                                 <button class="customize-copy-preview-link preview-control-element button button-secondary" data-component="button" data-copy-text="<?php esc_attr_e( "Copy" ); ?>" data-copied-text="<?php esc_attr_e( "Copied" ); ?>" ><?php esc_html_e( "Copy" ); ?></button>
--                         </div>
--                 </script>
--                 <script type="text/html" id="tmpl-customize-selected-changeset-status-control">
--                         <# var inputId = _.uniqueId( "customize-selected-changeset-status-control-input-" ); #>
--                         <# var descriptionId = _.uniqueId( "customize-selected-changeset-status-control-description-" ); #>
--                         <# if ( data.label ) then #>
--                                 <label for="thenthen inputId end;end;" class="customize-control-title">thenthen data.label end;end;</label>
--                         <# end; #>
--                         <# if ( data.description ) then #>
--                                 <span id="thenthen descriptionId end;end;" class="description customize-control-description">thenthenthen data.description end;end;end;</span>
--                         <# end; #>
--                         <# _.each( data.choices, function( choice ) then #>
--                                 <# var choiceId = inputId + "-" + choice.status; #>
--                                 <span class="customize-inside-control-row">
--                                         <input id="thenthen choiceId end;end;" type="radio" value="thenthen choice.status end;end;" name="thenthen inputId end;end;" data-customize-setting-key-link="default">
--                                         <label for="thenthen choiceId end;end;">thenthen choice.label end;end;</label>
--                                 </span>
--                         <# end; ); #>
--                 </script>
--                 <?php
--         end;

--         --
--         -- Helper function to compare two objects by priority, ensuring sort stability via instance_number.
--         --
--         -- @since 3.4.0
--         -- @deprecated 4.7.0 Use wp_list_sort()
--         --
--         -- @param WP_Customize_Panel|WP_Customize_Section|WP_Customize_Control a Object A.
--         -- @param WP_Customize_Panel|WP_Customize_Section|WP_Customize_Control b Object B.
--         -- @return int
--         --
--         protected function _cmp_priority( a, b ) then
--                 _deprecated_function( __METHOD__, "4.7.0", "wp_list_sort" );

--                 if ( a->priority === b->priority ) then
--                         return a->instance_number - b->instance_number;
--                 end; else then
--                         return a->priority - b->priority;
--                 end;
--         end;

--         --
--         -- Prepares panels, sections, and controls.
--         --
--         -- For each, check if required related components exist,
--         -- whether the user has the necessary capabilities,
--         -- and sort by priority.
--         --
--         -- @since 3.4.0
--         --
--         public function prepare_controls() then

--                 controls       = array();
--                 this->controls = wp_list_sort(
--                         this->controls,
--                         array(
--                                 "priority"        => "ASC",
--                                 "instance_number" => "ASC",
--                         ),
--                         "ASC",
--                         true
--                 );

--                 foreach ( this->controls as id => control ) then
--                         if ( ! isset( this->sections[ control->section ] ) || ! control->check_capabilities() ) then
--                                 continue;
--                         end;

--                         this->sections[ control->section ]->controls[] = control;
--                         controls[ id ]                                 = control;
--                 end;
--                 this->controls = controls;

--                 -- Prepare sections.
--                 this->sections = wp_list_sort(
--                         this->sections,
--                         array(
--                                 "priority"        => "ASC",
--                                 "instance_number" => "ASC",
--                         ),
--                         "ASC",
--                         true
--                 );
--                 sections       = array();

--                 foreach ( this->sections as section ) then
--                         if ( ! section->check_capabilities() ) then
--                                 continue;
--                         end;

--                         section->controls = wp_list_sort(
--                                 section->controls,
--                                 array(
--                                         "priority"        => "ASC",
--                                         "instance_number" => "ASC",
--                                 )
--                         );

--                         if ( ! section->panel ) then
--                                 -- Top-level section.
--                                 sections[ section->id ] = section;
--                         end; else then
--                                 -- This section belongs to a panel.
--                                 if ( isset( this->panels [ section->panel ] ) ) then
--                                         this->panels[ section->panel ]->sections[ section->id ] = section;
--                                 end;
--                         end;
--                 end;
--                 this->sections = sections;

--                 -- Prepare panels.
--                 this->panels = wp_list_sort(
--                         this->panels,
--                         array(
--                                 "priority"        => "ASC",
--                                 "instance_number" => "ASC",
--                         ),
--                         "ASC",
--                         true
--                 );
--                 panels       = array();

--                 foreach ( this->panels as panel ) then
--                         if ( ! panel->check_capabilities() ) then
--                                 continue;
--                         end;

--                         panel->sections      = wp_list_sort(
--                                 panel->sections,
--                                 array(
--                                         "priority"        => "ASC",
--                                         "instance_number" => "ASC",
--                                 ),
--                                 "ASC",
--                                 true
--                         );
--                         panels[ panel->id ] = panel;
--                 end;
--                 this->panels = panels;

--                 -- Sort panels and top-level sections together.
--                 this->containers = array_merge( this->panels, this->sections );
--                 this->containers = wp_list_sort(
--                         this->containers,
--                         array(
--                                 "priority"        => "ASC",
--                                 "instance_number" => "ASC",
--                         ),
--                         "ASC",
--                         true
--                 );
--         end;

--         --
--         -- Enqueues scripts for customize controls.
--         --
--         -- @since 3.4.0
--         --
--         public function enqueue_control_scripts() then
--                 foreach ( this->controls as control ) then
--                         control->enqueue();
--                 end;

--                 if ( ! is_multisite() && ( current_user_can( "install_themes" ) || current_user_can( "update_themes" ) || current_user_can( "delete_themes" ) ) ) then
--                         wp_enqueue_script( "updates" );
--                         wp_localize_script(
--                                 "updates",
--                                 "_wpUpdatesItemCounts",
--                                 array(
--                                         "totals" => wp_get_update_data(),
--                                 )
--                         );
--                 end;
--         end;

--         --
--         -- Determines whether the user agent is iOS.
--         --
--         -- @since 4.4.0
--         --
--         -- @return bool Whether the user agent is iOS.
--         --
--         public function is_ios() then
--                 return wp_is_mobile() && preg_match( "/iPad|iPod|iPhone/", _SERVER["HTTP_USER_AGENT"] );
--         end;

--         --
--         -- Gets the template string for the Customizer pane document title.
--         --
--         -- @since 4.4.0
--         --
--         -- @return string The template string for the document title.
--         --
--         public function get_document_title_template() then
--                 if ( this->is_theme_active() ) then
--                         /* translators: %s: Document title from the preview.--
--                         document_title_tmpl = __( "Customize: %s" );
--                 end; else then
--                         /* translators: %s: Document title from the preview.--
--                         document_title_tmpl = __( "Live Preview: %s" );
--                 end;
--                 document_title_tmpl = html_entity_decode( document_title_tmpl, ENT_QUOTES, "UTF-8" ); -- Because exported to JS and assigned to document.title.
--                 return document_title_tmpl;
--         end;

--         --
--         -- Sets the initial URL to be previewed.
--         --
--         -- URL is validated.
--         --
--         -- @since 4.4.0
--         --
--         -- @param string preview_url URL to be previewed.
--         --
--         public function set_preview_url( preview_url ) then
--                 preview_url       = sanitize_url( preview_url );
--                 this->preview_url = wp_validate_redirect( preview_url, home_url( "/" ) );
--         end;

--         --
--         -- Gets the initial URL to be previewed.
--         --
--         -- @since 4.4.0
--         --
--         -- @return string URL being previewed.
--         --
--         public function get_preview_url() then
--                 if ( empty( this->preview_url ) ) then
--                         preview_url = home_url( "/" );
--                 end; else then
--                         preview_url = this->preview_url;
--                 end;
--                 return preview_url;
--         end;

--         --
--         -- Determines whether the admin and the frontend are on different domains.
--         --
--         -- @since 4.7.0
--         --
--         -- @return bool Whether cross-domain.
--         --
--         public function is_cross_domain() then
--                 admin_origin = wp_parse_url( admin_url() );
--                 home_origin  = wp_parse_url( home_url() );
--                 cross_domain = ( strtolower( admin_origin["host"] ) !== strtolower( home_origin["host"] ) );
--                 return cross_domain;
--         end;

--         --
--         -- Gets URLs allowed to be previewed.
--         --
--         -- If the front end and the admin are served from the same domain, load the
--         -- preview over ssl if the Customizer is being loaded over ssl. This avoids
--         -- insecure content warnings. This is not attempted if the admin and front end
--         -- are on different domains to avoid the case where the front end doesn"t have
--         -- ssl certs. Domain mapping plugins can allow other urls in these conditions
--         -- using the customize_allowed_urls filter.
--         --
--         -- @since 4.7.0
--         --
--         -- @return array Allowed URLs.
--         --
--         public function get_allowed_urls() then
--                 allowed_urls = array( home_url( "/" ) );

--                 if ( is_ssl() && ! this->is_cross_domain() ) then
--                         allowed_urls[] = home_url( "/", "https" );
--                 end;

--                 --
--                 -- Filters the list of URLs allowed to be clicked and followed in the Customizer preview.
--                 --
--                 -- @since 3.4.0
--                 --
--                 -- @param string[] allowed_urls An array of allowed URLs.
--                 --
--                 allowed_urls = array_unique( apply_filters( "customize_allowed_urls", allowed_urls ) );

--                 return allowed_urls;
--         end;

--         --
--         -- Gets messenger channel.
--         --
--         -- @since 4.7.0
--         --
--         -- @return string Messenger channel.
--         --
--         public function get_messenger_channel() then
--                 return this->messenger_channel;
--         end;

--         --
--         -- Sets URL to link the user to when closing the Customizer.
--         --
--         -- URL is validated.
--         --
--         -- @since 4.4.0
--         --
--         -- @param string return_url URL for return link.
--         --
--         public function set_return_url( return_url ) then
--                 return_url       = sanitize_url( return_url );
--                 return_url       = remove_query_arg( wp_removable_query_args(), return_url );
--                 return_url       = wp_validate_redirect( return_url );
--                 this->return_url = return_url;
--         end;

--         --
--         -- Gets URL to link the user to when closing the Customizer.
--         --
--         -- @since 4.4.0
--         --
--         -- @global array _registered_pages
--         --
--         -- @return string URL for link to close Customizer.
--         --
--         public function get_return_url() then
--                 global _registered_pages;

--                 referer                    = wp_get_referer();
--                 excluded_referer_basenames = array( "customize.php", "wp-login.php" );

--                 if ( this->return_url ) then
--                         return_url = this->return_url;

--                         return_url_basename = wp_basename( parse_url( this->return_url, PHP_URL_PATH ) );
--                         return_url_query    = parse_url( this->return_url, PHP_URL_QUERY );

--                         if ( "themes.php" === return_url_basename && return_url_query ) then
--                                 parse_str( return_url_query, query_vars );

--                                 /*
--                                 -- If the return URL is a page added by a theme to the Appearance menu via add_submenu_page(),
--                                 -- verify that it belongs to the active theme, otherwise fall back to the Themes screen.
--                                 --
--                                 if ( isset( query_vars["page"] ) && ! isset( _registered_pages[ "appearance_page_thenquery_vars["page"]end;" ] ) ) then
--                                         return_url = admin_url( "themes.php" );
--                                 end;
--                         end;
--                 end; elseif ( referer && ! in_array( wp_basename( parse_url( referer, PHP_URL_PATH ) ), excluded_referer_basenames, true ) ) then
--                         return_url = referer;
--                 end; elseif ( this->preview_url ) then
--                         return_url = this->preview_url;
--                 end; else then
--                         return_url = home_url( "/" );
--                 end;

--                 return return_url;
--         end;

--         --
--         -- Sets the autofocused constructs.
--         --
--         -- @since 4.4.0
--         --
--         -- @param array autofocus then
--         --     Mapping of "panel", "section", "control" to the ID which should be autofocused.
--         --
--         --     @type string control ID for control to be autofocused.
--         --     @type string section ID for section to be autofocused.
--         --     @type string panel   ID for panel to be autofocused.
--         -- end;
--         --
--         public function set_autofocus( autofocus ) then
--                 this->autofocus = array_filter( wp_array_slice_assoc( autofocus, array( "panel", "section", "control" ) ), "is_string" );
--         end;

--         --
--         -- Gets the autofocused constructs.
--         --
--         -- @since 4.4.0
--         --
--         -- @return string[] then
--         --     Mapping of "panel", "section", "control" to the ID which should be autofocused.
--         --
--         --     @type string control ID for control to be autofocused.
--         --     @type string section ID for section to be autofocused.
--         --     @type string panel   ID for panel to be autofocused.
--         -- end;
--         --
--         public function get_autofocus() then
--                 return this->autofocus;
--         end;

--         --
--         -- Gets nonces for the Customizer.
--         --
--         -- @since 4.5.0
--         --
--         -- @return array Nonces.
--         --
--         public function get_nonces() then
--                 nonces = array(
--                         "save"                     => wp_create_nonce( "save-customize_" . this->get_stylesheet() ),
--                         "preview"                  => wp_create_nonce( "preview-customize_" . this->get_stylesheet() ),
--                         "switch_themes"            => wp_create_nonce( "switch_themes" ),
--                         "dismiss_autosave_or_lock" => wp_create_nonce( "customize_dismiss_autosave_or_lock" ),
--                         "override_lock"            => wp_create_nonce( "customize_override_changeset_lock" ),
--                         "trash"                    => wp_create_nonce( "trash_customize_changeset" ),
--                 );

--                 --
--                 -- Filters nonces for Customizer.
--                 --
--                 -- @since 4.2.0
--                 --
--                 -- @param string[]             nonces  Array of refreshed nonces for save and
--                 --                                      preview actions.
--                 -- @param WP_Customize_Manager manager WP_Customize_Manager instance.
--                 --
--                 nonces = apply_filters( "customize_refresh_nonces", nonces, this );

--                 return nonces;
--         end;

--         --
--         -- Prints JavaScript settings for parent window.
--         --
--         -- @since 4.4.0
--         --
--         public function customize_pane_settings() then

--                 login_url = add_query_arg(
--                         array(
--                                 "interim-login"   => 1,
--                                 "customize-login" => 1,
--                         ),
--                         wp_login_url()
--                 );

--                 -- Ensure dirty flags are set for modified settings.
--                 foreach ( array_keys( this->unsanitized_post_values() ) as setting_id ) then
--                         setting = this->get_setting( setting_id );
--                         if ( setting ) then
--                                 setting->dirty = true;
--                         end;
--                 end;

--                 autosave_revision_post  = null;
--                 autosave_autodraft_post = null;
--                 changeset_post_id       = this->changeset_post_id();
--                 if ( ! this->saved_starter_content_changeset && ! this->autosaved() ) then
--                         if ( changeset_post_id ) then
--                                 if ( is_user_logged_in() ) then
--                                         autosave_revision_post = wp_get_post_autosave( changeset_post_id, get_current_user_id() );
--                                 end;
--                         end; else then
--                                 autosave_autodraft_posts = this->get_changeset_posts(
--                                         array(
--                                                 "posts_per_page"            => 1,
--                                                 "post_status"               => "auto-draft",
--                                                 "exclude_restore_dismissed" => true,
--                                         )
--                                 );
--                                 if ( ! empty( autosave_autodraft_posts ) ) then
--                                         autosave_autodraft_post = array_shift( autosave_autodraft_posts );
--                                 end;
--                         end;
--                 end;

--                 current_user_can_publish = current_user_can( get_post_type_object( "customize_changeset" )->cap->publish_posts );

--                 -- @todo Include all of the status labels here from script-loader.php, and then allow it to be filtered.
--                 status_choices = array();
--                 if ( current_user_can_publish ) then
--                         status_choices[] = array(
--                                 "status" => "publish",
--                                 "label"  => __( "Publish" ),
--                         );
--                 end;
--                 status_choices[] = array(
--                         "status" => "draft",
--                         "label"  => __( "Save Draft" ),
--                 );
--                 if ( current_user_can_publish ) then
--                         status_choices[] = array(
--                                 "status" => "future",
--                                 "label"  => _x( "Schedule", "customizer changeset action/button label" ),
--                         );
--                 end;

--                 -- Prepare Customizer settings to pass to JavaScript.
--                 changeset_post = null;
--                 if ( changeset_post_id ) then
--                         changeset_post = get_post( changeset_post_id );
--                 end;

--                 -- Determine initial date to be at present or future, not past.
--                 current_time = current_time( "mysql", false );
--                 initial_date = current_time;
--                 if ( changeset_post ) then
--                         initial_date = get_the_time( "Y-m-d H:i:s", changeset_post->ID );
--                         if ( initial_date < current_time ) then
--                                 initial_date = current_time;
--                         end;
--                 end;

--                 lock_user_id = false;
--                 if ( this->changeset_post_id() ) then
--                         lock_user_id = wp_check_post_lock( this->changeset_post_id() );
--                 end;

--                 settings = array(
--                         "changeset"              => array(
--                                 "uuid"                  => this->changeset_uuid(),
--                                 "branching"             => this->branching(),
--                                 "autosaved"             => this->autosaved(),
--                                 "hasAutosaveRevision"   => ! empty( autosave_revision_post ),
--                                 "latestAutoDraftUuid"   => autosave_autodraft_post ? autosave_autodraft_post->post_name : null,
--                                 "status"                => changeset_post ? changeset_post->post_status : "",
--                                 "currentUserCanPublish" => current_user_can_publish,
--                                 "publishDate"           => initial_date,
--                                 "statusChoices"         => status_choices,
--                                 "lockUser"              => lock_user_id ? this->get_lock_user_data( lock_user_id ) : null,
--                         ),
--                         "initialServerDate"      => current_time,
--                         "dateFormat"             => get_option( "date_format" ),
--                         "timeFormat"             => get_option( "time_format" ),
--                         "initialServerTimestamp" => floor( microtime( true )-- 1000 ),
--                         "initialClientTimestamp" => -1, -- To be set with JS below.
--                         "timeouts"               => array(
--                                 "windowRefresh"           => 250,
--                                 "changesetAutoSave"       => AUTOSAVE_INTERVAL-- 1000,
--                                 "keepAliveCheck"          => 2500,
--                                 "reflowPaneContents"      => 100,
--                                 "previewFrameSensitivity" => 2000,
--                         ),
--                         "theme"                  => array(
--                                 "stylesheet"  => this->get_stylesheet(),
--                                 "active"      => this->is_theme_active(),
--                                 "_canInstall" => current_user_can( "install_themes" ),
--                         ),
--                         "url"                    => array(
--                                 "preview"       => sanitize_url( this->get_preview_url() ),
--                                 "return"        => sanitize_url( this->get_return_url() ),
--                                 "parent"        => sanitize_url( admin_url() ),
--                                 "activated"     => sanitize_url( home_url( "/" ) ),
--                                 "ajax"          => sanitize_url( admin_url( "admin-ajax.php", "relative" ) ),
--                                 "allowed"       => array_map( "sanitize_url", this->get_allowed_urls() ),
--                                 "isCrossDomain" => this->is_cross_domain(),
--                                 "home"          => sanitize_url( home_url( "/" ) ),
--                                 "login"         => sanitize_url( login_url ),
--                         ),
--                         "browser"                => array(
--                                 "mobile" => wp_is_mobile(),
--                                 "ios"    => this->is_ios(),
--                         ),
--                         "panels"                 => array(),
--                         "sections"               => array(),
--                         "nonce"                  => this->get_nonces(),
--                         "autofocus"              => this->get_autofocus(),
--                         "documentTitleTmpl"      => this->get_document_title_template(),
--                         "previewableDevices"     => this->get_previewable_devices(),
--                         "l10n"                   => array(
--                                 "confirmDeleteTheme"   => __( "Are you sure you want to delete this theme?" ),
--                                 /* translators: %d: Number of theme search results, which cannot currently consider singular vs. plural forms.--
--                                 "themeSearchResults"   => __( "%d themes found" ),
--                                 /* translators: %d: Number of themes being displayed, which cannot currently consider singular vs. plural forms.--
--                                 "announceThemeCount"   => __( "Displaying %d themes" ),
--                                 /* translators: %s: Theme name.--
--                                 "announceThemeDetails" => __( "Showing details for theme: %s" ),
--                         ),
--                 );

--                 -- Temporarily disable installation in Customizer. See #42184.
--                 filesystem_method = get_filesystem_method();
--                 ob_start();
--                 filesystem_credentials_are_stored = request_filesystem_credentials( self_admin_url() );
--                 ob_end_clean();
--                 if ( "direct" !== filesystem_method && ! filesystem_credentials_are_stored ) then
--                         settings["theme"]["_filesystemCredentialsNeeded"] = true;
--                 end;

--                 -- Prepare Customize Section objects to pass to JavaScript.
--                 foreach ( this->sections() as id => section ) then
--                         if ( section->check_capabilities() ) then
--                                 settings["sections"][ id ] = section->json();
--                         end;
--                 end;

--                 -- Prepare Customize Panel objects to pass to JavaScript.
--                 foreach ( this->panels() as panel_id => panel ) then
--                         if ( panel->check_capabilities() ) then
--                                 settings["panels"][ panel_id ] = panel->json();
--                                 foreach ( panel->sections as section_id => section ) then
--                                         if ( section->check_capabilities() ) then
--                                                 settings["sections"][ section_id ] = section->json();
--                                         end;
--                                 end;
--                         end;
--                 end;

--                 ?>
--                 <script type="text/javascript">
--                         var _wpCustomizeSettings = <?php echo wp_json_encode( settings ); ?>;
--                         _wpCustomizeSettings.initialClientTimestamp = _.now();
--                         _wpCustomizeSettings.controls = thenend;;
--                         _wpCustomizeSettings.settings = thenend;;
--                         <?php

--                         -- Serialize settings one by one to improve memory usage.
--                         echo "(function ( s )then\n";
--                         foreach ( this->settings() as setting ) then
--                                 if ( setting->check_capabilities() ) then
--                                         printf(
--                                                 "s[%s] = %s;\n",
--                                                 wp_json_encode( setting->id ),
--                                                 wp_json_encode( setting->json() )
--                                         );
--                                 end;
--                         end;
--                         echo "end;)( _wpCustomizeSettings.settings );\n";

--                         -- Serialize controls one by one to improve memory usage.
--                         echo "(function ( c )then\n";
--                         foreach ( this->controls() as control ) then
--                                 if ( control->check_capabilities() ) then
--                                         printf(
--                                                 "c[%s] = %s;\n",
--                                                 wp_json_encode( control->id ),
--                                                 wp_json_encode( control->json() )
--                                         );
--                                 end;
--                         end;
--                         echo "end;)( _wpCustomizeSettings.controls );\n";
--                         ?>
--                 </script>
--                 <?php
--         end;

--         --
--         -- Returns a list of devices to allow previewing.
--         --
--         -- @since 4.5.0
--         --
--         -- @return array List of devices with labels and default setting.
--         --
--         public function get_previewable_devices() then
--                 devices = array(
--                         "desktop" => array(
--                                 "label"   => __( "Enter desktop preview mode" ),
--                                 "default" => true,
--                         ),
--                         "tablet"  => array(
--                                 "label" => __( "Enter tablet preview mode" ),
--                         ),
--                         "mobile"  => array(
--                                 "label" => __( "Enter mobile preview mode" ),
--                         ),
--                 );

--                 --
--                 -- Filters the available devices to allow previewing in the Customizer.
--                 --
--                 -- @since 4.5.0
--                 --
--                 -- @see WP_Customize_Manager::get_previewable_devices()
--                 --
--                 -- @param array devices List of devices with labels and default setting.
--                 --
--                 devices = apply_filters( "customize_previewable_devices", devices );

--                 return devices;
--         end;

--         --
--         -- Registers some default controls.
--         --
--         -- @since 3.4.0
--         --
--         public function register_controls() then

--                 /* Themes (controls are loaded via ajax)--

--                 this->add_panel(
--                         new WP_Customize_Themes_Panel(
--                                 this,
--                                 "themes",
--                                 array(
--                                         "title"       => this->theme()->display( "Name" ),
--                                         "description" => (
--                                         "<p>" . __( "Looking for a theme? You can search or browse the WordPress.org theme directory, install and preview themes, then activate them right here." ) . "</p>" .
--                                         "<p>" . __( "While previewing a new theme, you can continue to tailor things like widgets and menus, and explore theme-specific options." ) . "</p>"
--                                         ),
--                                         "capability"  => "switch_themes",
--                                         "priority"    => 0,
--                                 )
--                         )
--                 );

--                 this->add_section(
--                         new WP_Customize_Themes_Section(
--                                 this,
--                                 "installed_themes",
--                                 array(
--                                         "title"      => __( "Installed themes" ),
--                                         "action"     => "installed",
--                                         "capability" => "switch_themes",
--                                         "panel"      => "themes",
--                                         "priority"   => 0,
--                                 )
--                         )
--                 );

--                 if ( ! is_multisite() ) then
--                         this->add_section(
--                                 new WP_Customize_Themes_Section(
--                                         this,
--                                         "wporg_themes",
--                                         array(
--                                                 "title"       => __( "WordPress.org themes" ),
--                                                 "action"      => "wporg",
--                                                 "filter_type" => "remote",
--                                                 "capability"  => "install_themes",
--                                                 "panel"       => "themes",
--                                                 "priority"    => 5,
--                                         )
--                                 )
--                         );
--                 end;

--                 -- Themes Setting (unused - the theme is considerably more fundamental to the Customizer experience).
--                 this->add_setting(
--                         new WP_Customize_Filter_Setting(
--                                 this,
--                                 "active_theme",
--                                 array(
--                                         "capability" => "switch_themes",
--                                 )
--                         )
--                 );

--                 /* Site Identity--

--                 this->add_section(
--                         "title_tagline",
--                         array(
--                                 "title"    => __( "Site Identity" ),
--                                 "priority" => 20,
--                         )
--                 );

--                 this->add_setting(
--                         "blogname",
--                         array(
--                                 "default"    => get_option( "blogname" ),
--                                 "type"       => "option",
--                                 "capability" => "manage_options",
--                         )
--                 );

--                 this->add_control(
--                         "blogname",
--                         array(
--                                 "label"   => __( "Site Title" ),
--                                 "section" => "title_tagline",
--                         )
--                 );

--                 this->add_setting(
--                         "blogdescription",
--                         array(
--                                 "default"    => get_option( "blogdescription" ),
--                                 "type"       => "option",
--                                 "capability" => "manage_options",
--                         )
--                 );

--                 this->add_control(
--                         "blogdescription",
--                         array(
--                                 "label"   => __( "Tagline" ),
--                                 "section" => "title_tagline",
--                         )
--                 );

--                 -- Add a setting to hide header text if the theme doesn"t support custom headers.
--                 if ( ! current_theme_supports( "custom-header", "header-text" ) ) then
--                         this->add_setting(
--                                 "header_text",
--                                 array(
--                                         "theme_supports"    => array( "custom-logo", "header-text" ),
--                                         "default"           => 1,
--                                         "sanitize_callback" => "absint",
--                                 )
--                         );

--                         this->add_control(
--                                 "header_text",
--                                 array(
--                                         "label"    => __( "Display Site Title and Tagline" ),
--                                         "section"  => "title_tagline",
--                                         "settings" => "header_text",
--                                         "type"     => "checkbox",
--                                 )
--                         );
--                 end;

--                 this->add_setting(
--                         "site_icon",
--                         array(
--                                 "type"       => "option",
--                                 "capability" => "manage_options",
--                                 "transport"  => "postMessage", -- Previewed with JS in the Customizer controls window.
--                         )
--                 );

--                 this->add_control(
--                         new WP_Customize_Site_Icon_Control(
--                                 this,
--                                 "site_icon",
--                                 array(
--                                         "label"       => __( "Site Icon" ),
--                                         "description" => sprintf(
--                                                 "<p>" . __( "Site Icons are what you see in browser tabs, bookmark bars, and within the WordPress mobile apps. Upload one here!" ) . "</p>" .
--                                                 /* translators: %s: Site icon size in pixels.--
--                                                 "<p>" . __( "Site Icons should be square and at least %s pixels." ) . "</p>",
--                                                 "<strong>512 &times; 512</strong>"
--                                         ),
--                                         "section"     => "title_tagline",
--                                         "priority"    => 60,
--                                         "height"      => 512,
--                                         "width"       => 512,
--                                 )
--                         )
--                 );

--                 this->add_setting(
--                         "custom_logo",
--                         array(
--                                 "theme_supports" => array( "custom-logo" ),
--                                 "transport"      => "postMessage",
--                         )
--                 );

--                 custom_logo_args = get_theme_support( "custom-logo" );
--                 this->add_control(
--                         new WP_Customize_Cropped_Image_Control(
--                                 this,
--                                 "custom_logo",
--                                 array(
--                                         "label"         => __( "Logo" ),
--                                         "section"       => "title_tagline",
--                                         "priority"      => 8,
--                                         "height"        => isset( custom_logo_args[0]["height"] ) ? custom_logo_args[0]["height"] : null,
--                                         "width"         => isset( custom_logo_args[0]["width"] ) ? custom_logo_args[0]["width"] : null,
--                                         "flex_height"   => isset( custom_logo_args[0]["flex-height"] ) ? custom_logo_args[0]["flex-height"] : null,
--                                         "flex_width"    => isset( custom_logo_args[0]["flex-width"] ) ? custom_logo_args[0]["flex-width"] : null,
--                                         "button_labels" => array(
--                                                 "select"       => __( "Select logo" ),
--                                                 "change"       => __( "Change logo" ),
--                                                 "remove"       => __( "Remove" ),
--                                                 "default"      => __( "Default" ),
--                                                 "placeholder"  => __( "No logo selected" ),
--                                                 "frame_title"  => __( "Select logo" ),
--                                                 "frame_button" => __( "Choose logo" ),
--                                         ),
--                                 )
--                         )
--                 );

--                 this->selective_refresh->add_partial(
--                         "custom_logo",
--                         array(
--                                 "settings"            => array( "custom_logo" ),
--                                 "selector"            => ".custom-logo-link",
--                                 "render_callback"     => array( this, "_render_custom_logo_partial" ),
--                                 "container_inclusive" => true,
--                         )
--                 );

--                 /* Colors--

--                 this->add_section(
--                         "colors",
--                         array(
--                                 "title"    => __( "Colors" ),
--                                 "priority" => 40,
--                         )
--                 );

--                 this->add_setting(
--                         "header_textcolor",
--                         array(
--                                 "theme_supports"       => array( "custom-header", "header-text" ),
--                                 "default"              => get_theme_support( "custom-header", "default-text-color" ),

--                                 "sanitize_callback"    => array( this, "_sanitize_header_textcolor" ),
--                                 "sanitize_js_callback" => "maybe_hash_hex_color",
--                         )
--                 );

--                 -- Input type: checkbox.
--                 -- With custom value.
--                 this->add_control(
--                         "display_header_text",
--                         array(
--                                 "settings" => "header_textcolor",
--                                 "label"    => __( "Display Site Title and Tagline" ),
--                                 "section"  => "title_tagline",
--                                 "type"     => "checkbox",
--                                 "priority" => 40,
--                         )
--                 );

--                 this->add_control(
--                         new WP_Customize_Color_Control(
--                                 this,
--                                 "header_textcolor",
--                                 array(
--                                         "label"   => __( "Header Text Color" ),
--                                         "section" => "colors",
--                                 )
--                         )
--                 );

--                 -- Input type: color.
--                 -- With sanitize_callback.
--                 this->add_setting(
--                         "background_color",
--                         array(
--                                 "default"              => get_theme_support( "custom-background", "default-color" ),
--                                 "theme_supports"       => "custom-background",

--                                 "sanitize_callback"    => "sanitize_hex_color_no_hash",
--                                 "sanitize_js_callback" => "maybe_hash_hex_color",
--                         )
--                 );

--                 this->add_control(
--                         new WP_Customize_Color_Control(
--                                 this,
--                                 "background_color",
--                                 array(
--                                         "label"   => __( "Background Color" ),
--                                         "section" => "colors",
--                                 )
--                         )
--                 );

--                 /* Custom Header--

--                 if ( current_theme_supports( "custom-header", "video" ) ) then
--                         title       = __( "Header Media" );
--                         description = "<p>" . __( "If you add a video, the image will be used as a fallback while the video loads." ) . "</p>";

--                         width  = absint( get_theme_support( "custom-header", "width" ) );
--                         height = absint( get_theme_support( "custom-header", "height" ) );
--                         if ( width && height ) then
--                                 control_description = sprintf(
--                                         /* translators: 1: .mp4, 2: Header size in pixels.--
--                                         __( "Upload your video in %1s format and minimize its file size for best results. Your theme recommends dimensions of %2s pixels." ),
--                                         "<code>.mp4</code>",
--                                         sprintf( "<strong>%s &times; %s</strong>", width, height )
--                                 );
--                         end; elseif ( width ) then
--                                 control_description = sprintf(
--                                         /* translators: 1: .mp4, 2: Header width in pixels.--
--                                         __( "Upload your video in %1s format and minimize its file size for best results. Your theme recommends a width of %2s pixels." ),
--                                         "<code>.mp4</code>",
--                                         sprintf( "<strong>%s</strong>", width )
--                                 );
--                         end; else then
--                                 control_description = sprintf(
--                                         /* translators: 1: .mp4, 2: Header height in pixels.--
--                                         __( "Upload your video in %1s format and minimize its file size for best results. Your theme recommends a height of %2s pixels." ),
--                                         "<code>.mp4</code>",
--                                         sprintf( "<strong>%s</strong>", height )
--                                 );
--                         end;
--                 end; else then
--                         title               = __( "Header Image" );
--                         description         = "";
--                         control_description = "";
--                 end;

--                 this->add_section(
--                         "header_image",
--                         array(
--                                 "title"          => title,
--                                 "description"    => description,
--                                 "theme_supports" => "custom-header",
--                                 "priority"       => 60,
--                         )
--                 );

--                 this->add_setting(
--                         "header_video",
--                         array(
--                                 "theme_supports"    => array( "custom-header", "video" ),
--                                 "transport"         => "postMessage",
--                                 "sanitize_callback" => "absint",
--                                 "validate_callback" => array( this, "_validate_header_video" ),
--                         )
--                 );

--                 this->add_setting(
--                         "external_header_video",
--                         array(
--                                 "theme_supports"    => array( "custom-header", "video" ),
--                                 "transport"         => "postMessage",
--                                 "sanitize_callback" => array( this, "_sanitize_external_header_video" ),
--                                 "validate_callback" => array( this, "_validate_external_header_video" ),
--                         )
--                 );

--                 this->add_setting(
--                         new WP_Customize_Filter_Setting(
--                                 this,
--                                 "header_image",
--                                 array(
--                                         "default"        => sprintf( get_theme_support( "custom-header", "default-image" ), get_template_directory_uri(), get_stylesheet_directory_uri() ),
--                                         "theme_supports" => "custom-header",
--                                 )
--                         )
--                 );

--                 this->add_setting(
--                         new WP_Customize_Header_Image_Setting(
--                                 this,
--                                 "header_image_data",
--                                 array(
--                                         "theme_supports" => "custom-header",
--                                 )
--                         )
--                 );

--                 /*
--                 -- Switch image settings to postMessage when video support is enabled since
--                 -- it entails that the_custom_header_markup() will be used, and thus selective
--                 -- refresh can be utilized.
--                 --
--                 if ( current_theme_supports( "custom-header", "video" ) ) then
--                         this->get_setting( "header_image" )->transport      = "postMessage";
--                         this->get_setting( "header_image_data" )->transport = "postMessage";
--                 end;

--                 this->add_control(
--                         new WP_Customize_Media_Control(
--                                 this,
--                                 "header_video",
--                                 array(
--                                         "theme_supports"  => array( "custom-header", "video" ),
--                                         "label"           => __( "Header Video" ),
--                                         "description"     => control_description,
--                                         "section"         => "header_image",
--                                         "mime_type"       => "video",
--                                         "active_callback" => "is_header_video_active",
--                                 )
--                         )
--                 );

--                 this->add_control(
--                         "external_header_video",
--                         array(
--                                 "theme_supports"  => array( "custom-header", "video" ),
--                                 "type"            => "url",
--                                 "description"     => __( "Or, enter a YouTube URL:" ),
--                                 "section"         => "header_image",
--                                 "active_callback" => "is_header_video_active",
--                         )
--                 );

--                 this->add_control( new WP_Customize_Header_Image_Control( this ) );

--                 this->selective_refresh->add_partial(
--                         "custom_header",
--                         array(
--                                 "selector"            => "#wp-custom-header",
--                                 "render_callback"     => "the_custom_header_markup",
--                                 "settings"            => array( "header_video", "external_header_video", "header_image" ), -- The image is used as a video fallback here.
--                                 "container_inclusive" => true,
--                         )
--                 );

--                 /* Custom Background--

--                 this->add_section(
--                         "background_image",
--                         array(
--                                 "title"          => __( "Background Image" ),
--                                 "theme_supports" => "custom-background",
--                                 "priority"       => 80,
--                         )
--                 );

--                 this->add_setting(
--                         "background_image",
--                         array(
--                                 "default"           => get_theme_support( "custom-background", "default-image" ),
--                                 "theme_supports"    => "custom-background",
--                                 "sanitize_callback" => array( this, "_sanitize_background_setting" ),
--                         )
--                 );

--                 this->add_setting(
--                         new WP_Customize_Background_Image_Setting(
--                                 this,
--                                 "background_image_thumb",
--                                 array(
--                                         "theme_supports"    => "custom-background",
--                                         "sanitize_callback" => array( this, "_sanitize_background_setting" ),
--                                 )
--                         )
--                 );

--                 this->add_control( new WP_Customize_Background_Image_Control( this ) );

--                 this->add_setting(
--                         "background_preset",
--                         array(
--                                 "default"           => get_theme_support( "custom-background", "default-preset" ),
--                                 "theme_supports"    => "custom-background",
--                                 "sanitize_callback" => array( this, "_sanitize_background_setting" ),
--                         )
--                 );

--                 this->add_control(
--                         "background_preset",
--                         array(
--                                 "label"   => _x( "Preset", "Background Preset" ),
--                                 "section" => "background_image",
--                                 "type"    => "select",
--                                 "choices" => array(
--                                         "default" => _x( "Default", "Default Preset" ),
--                                         "fill"    => __( "Fill Screen" ),
--                                         "fit"     => __( "Fit to Screen" ),
--                                         "repeat"  => _x( "Repeat", "Repeat Image" ),
--                                         "custom"  => _x( "Custom", "Custom Preset" ),
--                                 ),
--                         )
--                 );

--                 this->add_setting(
--                         "background_position_x",
--                         array(
--                                 "default"           => get_theme_support( "custom-background", "default-position-x" ),
--                                 "theme_supports"    => "custom-background",
--                                 "sanitize_callback" => array( this, "_sanitize_background_setting" ),
--                         )
--                 );

--                 this->add_setting(
--                         "background_position_y",
--                         array(
--                                 "default"           => get_theme_support( "custom-background", "default-position-y" ),
--                                 "theme_supports"    => "custom-background",
--                                 "sanitize_callback" => array( this, "_sanitize_background_setting" ),
--                         )
--                 );

--                 this->add_control(
--                         new WP_Customize_Background_Position_Control(
--                                 this,
--                                 "background_position",
--                                 array(
--                                         "label"    => __( "Image Position" ),
--                                         "section"  => "background_image",
--                                         "settings" => array(
--                                                 "x" => "background_position_x",
--                                                 "y" => "background_position_y",
--                                         ),
--                                 )
--                         )
--                 );

--                 this->add_setting(
--                         "background_size",
--                         array(
--                                 "default"           => get_theme_support( "custom-background", "default-size" ),
--                                 "theme_supports"    => "custom-background",
--                                 "sanitize_callback" => array( this, "_sanitize_background_setting" ),
--                         )
--                 );

--                 this->add_control(
--                         "background_size",
--                         array(
--                                 "label"   => __( "Image Size" ),
--                                 "section" => "background_image",
--                                 "type"    => "select",
--                                 "choices" => array(
--                                         "auto"    => _x( "Original", "Original Size" ),
--                                         "contain" => __( "Fit to Screen" ),
--                                         "cover"   => __( "Fill Screen" ),
--                                 ),
--                         )
--                 );

--                 this->add_setting(
--                         "background_repeat",
--                         array(
--                                 "default"           => get_theme_support( "custom-background", "default-repeat" ),
--                                 "sanitize_callback" => array( this, "_sanitize_background_setting" ),
--                                 "theme_supports"    => "custom-background",
--                         )
--                 );

--                 this->add_control(
--                         "background_repeat",
--                         array(
--                                 "label"   => __( "Repeat Background Image" ),
--                                 "section" => "background_image",
--                                 "type"    => "checkbox",
--                         )
--                 );

--                 this->add_setting(
--                         "background_attachment",
--                         array(
--                                 "default"           => get_theme_support( "custom-background", "default-attachment" ),
--                                 "sanitize_callback" => array( this, "_sanitize_background_setting" ),
--                                 "theme_supports"    => "custom-background",
--                         )
--                 );

--                 this->add_control(
--                         "background_attachment",
--                         array(
--                                 "label"   => __( "Scroll with Page" ),
--                                 "section" => "background_image",
--                                 "type"    => "checkbox",
--                         )
--                 );

--                 -- If the theme is using the default background callback, we can update
--                 -- the background CSS using postMessage.
--                 if ( get_theme_support( "custom-background", "wp-head-callback" ) === "_custom_background_cb" ) then
--                         foreach ( array( "color", "image", "preset", "position_x", "position_y", "size", "repeat", "attachment" ) as prop ) then
--                                 this->get_setting( "background_" . prop )->transport = "postMessage";
--                         end;
--                 end;

--                 /*
--                 -- Static Front Page
--                 -- See also https://core.trac.wordpress.org/ticket/19627 which introduces the static-front-page theme_support.
--                 -- The following replicates behavior from options-reading.php.
--                 --

--                 this->add_section(
--                         "static_front_page",
--                         array(
--                                 "title"           => __( "Homepage Settings" ),
--                                 "priority"        => 120,
--                                 "description"     => __( "You can choose what&#8217;s displayed on the homepage of your site. It can be posts in reverse chronological order (classic blog), or a fixed/static page. To set a static homepage, you first need to create two Pages. One will become the homepage, and the other will be where your posts are displayed." ),
--                                 "active_callback" => array( this, "has_published_pages" ),
--                         )
--                 );

--                 this->add_setting(
--                         "show_on_front",
--                         array(
--                                 "default"    => get_option( "show_on_front" ),
--                                 "capability" => "manage_options",
--                                 "type"       => "option",
--                         )
--                 );

--                 this->add_control(
--                         "show_on_front",
--                         array(
--                                 "label"   => __( "Your homepage displays" ),
--                                 "section" => "static_front_page",
--                                 "type"    => "radio",
--                                 "choices" => array(
--                                         "posts" => __( "Your latest posts" ),
--                                         "page"  => __( "A static page" ),
--                                 ),
--                         )
--                 );

--                 this->add_setting(
--                         "page_on_front",
--                         array(
--                                 "type"       => "option",
--                                 "capability" => "manage_options",
--                         )
--                 );

--                 this->add_control(
--                         "page_on_front",
--                         array(
--                                 "label"          => __( "Homepage" ),
--                                 "section"        => "static_front_page",
--                                 "type"           => "dropdown-pages",
--                                 "allow_addition" => true,
--                         )
--                 );

--                 this->add_setting(
--                         "page_for_posts",
--                         array(
--                                 "type"       => "option",
--                                 "capability" => "manage_options",
--                         )
--                 );

--                 this->add_control(
--                         "page_for_posts",
--                         array(
--                                 "label"          => __( "Posts page" ),
--                                 "section"        => "static_front_page",
--                                 "type"           => "dropdown-pages",
--                                 "allow_addition" => true,
--                         )
--                 );

--                 /* Custom CSS--
--                 section_description  = "<p>";
--                 section_description .= __( "Add your own CSS code here to customize the appearance and layout of your site." );
--                 section_description .= sprintf(
--                         " <a href="%1s" class="external-link" target="_blank">%2s<span class="screen-reader-text"> %3s</span></a>",
--                         esc_url( __( "https://wordpress.org/support/article/css/" ) ),
--                         __( "Learn more about CSS" ),
--                         /* translators: Accessibility text.--
--                         __( "(opens in a new tab)" )
--                 );
--                 section_description .= "</p>";

--                 section_description .= "<p id="editor-keyboard-trap-help-1">" . __( "When using a keyboard to navigate:" ) . "</p>";
--                 section_description .= "<ul>";
--                 section_description .= "<li id="editor-keyboard-trap-help-2">" . __( "In the editing area, the Tab key enters a tab character." ) . "</li>";
--                 section_description .= "<li id="editor-keyboard-trap-help-3">" . __( "To move away from this area, press the Esc key followed by the Tab key." ) . "</li>";
--                 section_description .= "<li id="editor-keyboard-trap-help-4">" . __( "Screen reader users: when in forms mode, you may need to press the Esc key twice." ) . "</li>";
--                 section_description .= "</ul>";

--                 if ( "false" !== wp_get_current_user()->syntax_highlighting ) then
--                         section_description .= "<p>";
--                         section_description .= sprintf(
--                                 /* translators: 1: Link to user profile, 2: Additional link attributes, 3: Accessibility text.--
--                                 __( "The edit field automatically highlights code syntax. You can disable this in your <a href="%1s" %2s>user profile%3s</a> to work in plain text mode." ),
--                                 esc_url( get_edit_profile_url() ),
--                                 "class="external-link" target="_blank"",
--                                 sprintf(
--                                         "<span class="screen-reader-text"> %s</span>",
--                                         /* translators: Accessibility text.--
--                                         __( "(opens in a new tab)" )
--                                 )
--                         );
--                         section_description .= "</p>";
--                 end;

--                 section_description .= "<p class="section-description-buttons">";
--                 section_description .= "<button type="button" class="button-link section-description-close">" . __( "Close" ) . "</button>";
--                 section_description .= "</p>";

--                 this->add_section(
--                         "custom_css",
--                         array(
--                                 "title"              => __( "Additional CSS" ),
--                                 "priority"           => 200,
--                                 "description_hidden" => true,
--                                 "description"        => section_description,
--                         )
--                 );

--                 custom_css_setting = new WP_Customize_Custom_CSS_Setting(
--                         this,
--                         sprintf( "custom_css[%s]", get_stylesheet() ),
--                         array(
--                                 "capability" => "edit_css",
--                                 "default"    => "",
--                         )
--                 );
--                 this->add_setting( custom_css_setting );

--                 this->add_control(
--                         new WP_Customize_Code_Editor_Control(
--                                 this,
--                                 "custom_css",
--                                 array(
--                                         "label"       => __( "CSS code" ),
--                                         "section"     => "custom_css",
--                                         "settings"    => array( "default" => custom_css_setting->id ),
--                                         "code_type"   => "text/css",
--                                         "input_attrs" => array(
--                                                 "aria-describedby" => "editor-keyboard-trap-help-1 editor-keyboard-trap-help-2 editor-keyboard-trap-help-3 editor-keyboard-trap-help-4",
--                                         ),
--                                 )
--                         )
--                 );
--         end;

--         --
--         -- Returns whether there are published pages.
--         --
--         -- Used as active callback for static front page section and controls.
--         --
--         -- @since 4.7.0
--         --
--         -- @return bool Whether there are published (or to be published) pages.
--         --
--         public function has_published_pages() then

--                 setting = this->get_setting( "nav_menus_created_posts" );
--                 if ( setting ) then
--                         foreach ( setting->value() as post_id ) then
--                                 if ( "page" === get_post_type( post_id ) ) then
--                                         return true;
--                                 end;
--                         end;
--                 end;
--                 return 0 !== count( get_pages( array( "number" => 1 ) ) );
--         end;

--         --
--         -- Adds settings from the POST data that were not added with code, e.g. dynamically-created settings for Widgets
--         --
--         -- @since 4.2.0
--         --
--         -- @see add_dynamic_settings()
--         --
--         public function register_dynamic_settings() then
--                 setting_ids = array_keys( this->unsanitized_post_values() );
--                 this->add_dynamic_settings( setting_ids );
--         end;

--         --
--         -- Loads themes into the theme browsing/installation UI.
--         --
--         -- @since 4.9.0
--         --
--         public function handle_load_themes_request() then
--                 check_ajax_referer( "switch_themes", "nonce" );

--                 if ( ! current_user_can( "switch_themes" ) ) then
--                         wp_die( -1 );
--                 end;

--                 if ( empty( _POST["theme_action"] ) ) then
--                         wp_send_json_error( "missing_theme_action" );
--                 end;
--                 theme_action = sanitize_key( _POST["theme_action"] );
--                 themes       = array();
--                 args         = array();

--                 -- Define query filters based on user input.
--                 if ( ! array_key_exists( "search", _POST ) ) then
--                         args["search"] = "";
--                 end; else then
--                         args["search"] = sanitize_text_field( wp_unslash( _POST["search"] ) );
--                 end;

--                 if ( ! array_key_exists( "tags", _POST ) ) then
--                         args["tag"] = "";
--                 end; else then
--                         args["tag"] = array_map( "sanitize_text_field", wp_unslash( (array) _POST["tags"] ) );
--                 end;

--                 if ( ! array_key_exists( "page", _POST ) ) then
--                         args["page"] = 1;
--                 end; else then
--                         args["page"] = absint( _POST["page"] );
--                 end;

--                 require_once ABSPATH . "wp-admin/includes/theme.php";

--                 if ( "installed" === theme_action ) then

--                         -- Load all installed themes from wp_prepare_themes_for_js().
--                         themes = array( "themes" => array() );
--                         foreach ( wp_prepare_themes_for_js() as theme ) then
--                                 theme["type"]      = "installed";
--                                 theme["active"]    = ( isset( _POST["customized_theme"] ) && _POST["customized_theme"] === theme["id"] );
--                                 themes["themes"][] = theme;
--                         end;
--                 end; elseif ( "wporg" === theme_action ) then

--                         -- Load WordPress.org themes from the .org API and normalize data to match installed theme objects.
--                         if ( ! current_user_can( "install_themes" ) ) then
--                                 wp_die( -1 );
--                         end;

--                         -- Arguments for all queries.
--                         wporg_args = array(
--                                 "per_page" => 100,
--                                 "fields"   => array(
--                                         "reviews_url" => true, -- Explicitly request the reviews URL to be linked from the customizer.
--                                 ),
--                         );

--                         args = array_merge( wporg_args, args );

--                         if ( "" === args["search"] && "" === args["tag"] ) then
--                                 args["browse"] = "new"; -- Sort by latest themes by default.
--                         end;

--                         -- Load themes from the .org API.
--                         themes = themes_api( "query_themes", args );
--                         if ( is_wp_error( themes ) ) then
--                                 wp_send_json_error();
--                         end;

--                         -- This list matches the allowed tags in wp-admin/includes/theme-install.php.
--                         themes_allowedtags                     = array_fill_keys(
--                                 array( "a", "abbr", "acronym", "code", "pre", "em", "strong", "div", "p", "ul", "ol", "li", "h1", "h2", "h3", "h4", "h5", "h6", "img" ),
--                                 array()
--                         );
--                         themes_allowedtags["a"]                = array_fill_keys( array( "href", "title", "target" ), true );
--                         themes_allowedtags["acronym"]["title"] = true;
--                         themes_allowedtags["abbr"]["title"]    = true;
--                         themes_allowedtags["img"]              = array_fill_keys( array( "src", "class", "alt" ), true );

--                         -- Prepare a list of installed themes to check against before the loop.
--                         installed_themes = array();
--                         wp_themes        = wp_get_themes();
--                         foreach ( wp_themes as theme ) then
--                                 installed_themes[] = theme->get_stylesheet();
--                         end;
--                         update_php = network_admin_url( "update.php?action=install-theme" );

--                         -- Set up properties for themes available on WordPress.org.
--                         foreach ( themes->themes as &theme ) then
--                                 theme->install_url = add_query_arg(
--                                         array(
--                                                 "theme"    => theme->slug,
--                                                 "_wpnonce" => wp_create_nonce( "install-theme_" . theme->slug ),
--                                         ),
--                                         update_php
--                                 );

--                                 theme->name        = wp_kses( theme->name, themes_allowedtags );
--                                 theme->version     = wp_kses( theme->version, themes_allowedtags );
--                                 theme->description = wp_kses( theme->description, themes_allowedtags );
--                                 theme->stars       = wp_star_rating(
--                                         array(
--                                                 "rating" => theme->rating,
--                                                 "type"   => "percent",
--                                                 "number" => theme->num_ratings,
--                                                 "echo"   => false,
--                                         )
--                                 );
--                                 theme->num_ratings = number_format_i18n( theme->num_ratings );
--                                 theme->preview_url = set_url_scheme( theme->preview_url );

--                                 -- Handle themes that are already installed as installed themes.
--                                 if ( in_array( theme->slug, installed_themes, true ) ) then
--                                         theme->type = "installed";
--                                 end; else then
--                                         theme->type = theme_action;
--                                 end;

--                                 -- Set active based on customized theme.
--                                 theme->active = ( isset( _POST["customized_theme"] ) && _POST["customized_theme"] === theme->slug );

--                                 -- Map available theme properties to installed theme properties.
--                                 theme->id            = theme->slug;
--                                 theme->screenshot    = array( theme->screenshot_url );
--                                 theme->authorAndUri  = wp_kses( theme->author["display_name"], themes_allowedtags );
--                                 theme->compatibleWP  = is_wp_version_compatible( theme->requires ); -- phpcs:ignore WordPress.NamingConventions.ValidVariableName
--                                 theme->compatiblePHP = is_php_version_compatible( theme->requires_php ); -- phpcs:ignore WordPress.NamingConventions.ValidVariableName

--                                 if ( isset( theme->parent ) ) then
--                                         theme->parent = theme->parent["slug"];
--                                 end; else then
--                                         theme->parent = false;
--                                 end;
--                                 unset( theme->slug );
--                                 unset( theme->screenshot_url );
--                                 unset( theme->author );
--                         end; -- End foreach().
--                 end; -- End if().

--                 --
--                 -- Filters the theme data loaded in the customizer.
--                 --
--                 -- This allows theme data to be loading from an external source,
--                 -- or modification of data loaded from `wp_prepare_themes_for_js()`
--                 -- or WordPress.org via `themes_api()`.
--                 --
--                 -- @since 4.9.0
--                 --
--                 -- @see wp_prepare_themes_for_js()
--                 -- @see themes_api()
--                 -- @see WP_Customize_Manager::__construct()
--                 --
--                 -- @param array|stdClass       themes  Nested array or object of theme data.
--                 -- @param array                args    List of arguments, such as page, search term, and tags to query for.
--                 -- @param WP_Customize_Manager manager Instance of Customize manager.
--                 --
--                 themes = apply_filters( "customize_load_themes", themes, args, this );

--                 wp_send_json_success( themes );
--         end;

--         --
--         -- Callback for validating the header_textcolor value.
--         --
--         -- Accepts "blank", and otherwise uses sanitize_hex_color_no_hash().
--         -- Returns default text color if hex color is empty.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string color
--         -- @return mixed
--         --
--         public function _sanitize_header_textcolor( color ) then
--                 if ( "blank" === color ) then
--                         return "blank";
--                 end;

--                 color = sanitize_hex_color_no_hash( color );
--                 if ( empty( color ) ) then
--                         color = get_theme_support( "custom-header", "default-text-color" );
--                 end;

--                 return color;
--         end;

--         --
--         -- Callback for validating a background setting value.
--         --
--         -- @since 4.7.0
--         --
--         -- @param string               value   Repeat value.
--         -- @param WP_Customize_Setting setting Setting.
--         -- @return string|WP_Error Background value or validation error.
--         --
--         public function _sanitize_background_setting( value, setting ) then
--                 if ( "background_repeat" === setting->id ) then
--                         if ( ! in_array( value, array( "repeat-x", "repeat-y", "repeat", "no-repeat" ), true ) ) then
--                                 return new WP_Error( "invalid_value", __( "Invalid value for background repeat." ) );
--                         end;
--                 end; elseif ( "background_attachment" === setting->id ) then
--                         if ( ! in_array( value, array( "fixed", "scroll" ), true ) ) then
--                                 return new WP_Error( "invalid_value", __( "Invalid value for background attachment." ) );
--                         end;
--                 end; elseif ( "background_position_x" === setting->id ) then
--                         if ( ! in_array( value, array( "left", "center", "right" ), true ) ) then
--                                 return new WP_Error( "invalid_value", __( "Invalid value for background position X." ) );
--                         end;
--                 end; elseif ( "background_position_y" === setting->id ) then
--                         if ( ! in_array( value, array( "top", "center", "bottom" ), true ) ) then
--                                 return new WP_Error( "invalid_value", __( "Invalid value for background position Y." ) );
--                         end;
--                 end; elseif ( "background_size" === setting->id ) then
--                         if ( ! in_array( value, array( "auto", "contain", "cover" ), true ) ) then
--                                 return new WP_Error( "invalid_value", __( "Invalid value for background size." ) );
--                         end;
--                 end; elseif ( "background_preset" === setting->id ) then
--                         if ( ! in_array( value, array( "default", "fill", "fit", "repeat", "custom" ), true ) ) then
--                                 return new WP_Error( "invalid_value", __( "Invalid value for background size." ) );
--                         end;
--                 end; elseif ( "background_image" === setting->id || "background_image_thumb" === setting->id ) then
--                         value = empty( value ) ? "" : sanitize_url( value );
--                 end; else then
--                         return new WP_Error( "unrecognized_setting", __( "Unrecognized background setting." ) );
--                 end;
--                 return value;
--         end;

--         --
--         -- Exports header video settings to facilitate selective refresh.
--         --
--         -- @since 4.7.0
--         --
--         -- @param array                          response          Response.
--         -- @param WP_Customize_Selective_Refresh selective_refresh Selective refresh component.
--         -- @param array                          partials          Array of partials.
--         -- @return array
--         --
--         public function export_header_video_settings( response, selective_refresh, partials ) then
--                 if ( isset( partials["custom_header"] ) ) then
--                         response["custom_header_settings"] = get_header_video_settings();
--                 end;

--                 return response;
--         end;

--         --
--         -- Callback for validating the header_video value.
--         --
--         -- Ensures that the selected video is less than 8MB and provides an error message.
--         --
--         -- @since 4.7.0
--         --
--         -- @param WP_Error validity
--         -- @param mixed    value
--         -- @return mixed
--         --
--         public function _validate_header_video( validity, value ) then
--                 video = get_attached_file( absint( value ) );
--                 if ( video ) then
--                         size = filesize( video );
--                         if ( size > 8-- MB_IN_BYTES ) then
--                                 validity->add(
--                                         "size_too_large",
--                                         __( "This video file is too large to use as a header video. Try a shorter video or optimize the compression settings and re-upload a file that is less than 8MB. Or, upload your video to YouTube and link it with the option below." )
--                                 );
--                         end;
--                         if ( ".mp4" !== substr( video, -4 ) && ".mov" !== substr( video, -4 ) ) then -- Check for .mp4 or .mov format, which (assuming h.264 encoding) are the only cross-browser-supported formats.
--                                 validity->add(
--                                         "invalid_file_type",
--                                         sprintf(
--                                                 /* translators: 1: .mp4, 2: .mov--
--                                                 __( "Only %1s or %2s files may be used for header video. Please convert your video file and try again, or, upload your video to YouTube and link it with the option below." ),
--                                                 "<code>.mp4</code>",
--                                                 "<code>.mov</code>"
--                                         )
--                                 );
--                         end;
--                 end;
--                 return validity;
--         end;

--         --
--         -- Callback for validating the external_header_video value.
--         --
--         -- Ensures that the provided URL is supported.
--         --
--         -- @since 4.7.0
--         --
--         -- @param WP_Error validity
--         -- @param mixed    value
--         -- @return mixed
--         --
--         public function _validate_external_header_video( validity, value ) then
--                 video = sanitize_url( value );
--                 if ( video ) then
--                         if ( ! preg_match( "#^https?://(?:www\.)?(?:youtube\.com/watch|youtu\.be/)#", video ) ) then
--                                 validity->add( "invalid_url", __( "Please enter a valid YouTube URL." ) );
--                         end;
--                 end;
--                 return validity;
--         end;

--         --
--         -- Callback for sanitizing the external_header_video value.
--         --
--         -- @since 4.7.1
--         --
--         -- @param string value URL.
--         -- @return string Sanitized URL.
--         --
--         public function _sanitize_external_header_video( value ) then
--                 return sanitize_url( trim( value ) );
--         end;

--         --
--         -- Callback for rendering the custom logo, used in the custom_logo partial.
--         --
--         -- This method exists because the partial object and context data are passed
--         -- into a partial"s render_callback so we cannot use get_custom_logo() as
--         -- the render_callback directly since it expects a blog ID as the first
--         -- argument. When WP no longer supports PHP 5.3, this method can be removed
--         -- in favor of an anonymous function.
--         --
--         -- @see WP_Customize_Manager::register_controls()
--         --
--         -- @since 4.5.0
--         --
--         -- @return string Custom logo.
--         --
--         public function _render_custom_logo_partial() then
--                 return get_custom_logo();
--         end;
-- end;

end Inc_Class_Wp_Customize_Managers;
