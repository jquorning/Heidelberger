--
-- WordPress Customize Manager classes
--
-- @package WordPress
-- @subpackage Customize
-- @since 3.4.0
--

with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

with Arrays;
with Hb_Common;
with Lists;

with Inc_Class_Wp_Customize_Controls;
with Inc_Class_Wp_Customize_Nav_Menus;
with Inc_Class_Wp_Customize_Panels;
with Inc_Class_Wp_Customize_Sections;
with Inc_Class_Wp_Customize_Settings;
with Inc_Class_Wp_Customize_Widgets;
with Class_Posts;
with Inc_Class_Wp_Themes;

with Cust_Class_Wp_Customize_Selective_Refresh;

package Inc_Class_Wp_Customize_Managers
is
   use Ada.Strings.Unbounded;
   use Arrays;
   use Hb_Common;
   use Lists;

   subtype Wp_Customize_Setting
     is Inc_Class_Wp_Customize_Settings.Wp_Customize_Setting;

   subtype Post_Id is Class_Posts.Post_Id;

   subtype Setting_Index is Positive;

   package Setting_Lists is new
      Ada.Containers.Vectors
        (Index_Type   => Setting_Index,
         Element_Type => Inc_Class_Wp_Customize_Settings.Wp_Customize_Setting,
         "="          => Inc_Class_Wp_Customize_Settings."=");

   type Wp_Customize_Manager;
   type Manager_Ref is access Wp_Customize_Manager;

   --
   -- Customize Manager class.
   --
   -- Bootstraps the Customize experience on the server-side.
   --
   -- Sets up the theme-switching process if a theme other than the active one is
   -- being previewed and customized.
   --
   -- Serves as a factory for Customize Controls and Settings, and
   -- instantiates default Customize Controls and Settings.
   --
   -- @since 3.4.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Customize_Manager is tagged
      record
         --
         -- An instance of the theme being previewed.
         --
         -- @since 3.4.0
         -- @var WP_Theme
         --
         -- protected
         Theme : Inc_Class_Wp_Themes.Wp_Theme;

         --
         -- The directory name of the previously active theme (within the theme_root).
         --
         -- @since 3.4.0
         -- @var string
         --
         -- protected
         Original_Stylesheet : Unbounded_String;

         --
         -- Whether this is a Customizer pageload.
         --
         -- @since 3.4.0
         -- @var bool
         --
--        protected previewing = false;

         --
         -- Methods and properties dealing with managing widgets in the Customizer.
         --
         -- @since 3.9.0
         -- @var WP_Customize_Widgets
         --
         Widgets : Inc_Class_Wp_Customize_Widgets.Wp_Customize_Widgets;

         --
         -- Methods and properties dealing with managing nav menus in the Customizer.
         --
         -- @since 4.3.0
         -- @var WP_Customize_Nav_Menus
         --
         Nav_Menus : Inc_Class_Wp_Customize_Nav_Menus.Wp_Customize_Nav_Menus;

         --
         -- Methods and properties dealing with selective refresh in the Customizer
         -- preview.
         --
         -- @since 4.5.0
         -- @var WP_Customize_Selective_Refresh
         --
         -- public
         Selective_Refresh :
           Cust_Class_Wp_Customize_Selective_Refresh.Wp_Customize_Selective_Refresh;

         --
         -- Registered instances of WP_Customize_Setting.
         --
         -- @since 3.4.0
         -- @var array
         --
         -- protected
         Settings : Array_Type;

         --
         -- Sorted top-level instances of WP_Customize_Panel and WP_Customize_Section.
         --
         -- @since 4.0.0
         -- @var array
         --
--        protected containers = array();

         --
         -- Registered instances of WP_Customize_Panel.
         --
         -- @since 4.0.0
         -- @var array
         --
         -- protected
         Panels : Array_Type;

         --
         -- List of core components.
         --
         -- @since 4.5.0
         -- @var array
         --
         -- protected
         Components : List_Type := To_List (List => (+"widgets", +"nav_menus"));

         --
         -- Registered instances of WP_Customize_Section.
         --
         -- @since 3.4.0
         -- @var array
         --
         -- protected
         Sections : Array_Type;

         --
         -- Registered instances of WP_Customize_Control.
         --
         -- @since 3.4.0
         -- @var array
         --
         -- protected
         Controls : Array_Type;

         --
         -- Panel types that may be rendered from JS templates.
         --
         -- @since 4.3.0
         -- @var array
         --
--        protected registered_panel_types = array();

         --
         -- Section types that may be rendered from JS templates.
         --
         -- @since 4.3.0
         -- @var array
         --
--        protected registered_section_types = array();

         --
         -- Control types that may be rendered from JS templates.
         --
         -- @since 4.1.0
         -- @var array
         --
--        protected registered_control_types = array();

         --
         -- Initial URL being previewed.
         --
         -- @since 4.4.0
         -- @var string
         --
--        protected preview_url;

         --
         -- URL to link the user to when closing the Customizer.
         --
         -- @since 4.4.0
         -- @var string
         --
--        protected return_url;

         --
         -- Mapping of 'panel', 'section', 'control' to the ID which should be
         -- autofocused.
         --
         -- @since 4.4.0
         -- @var string[]
         --
--        protected autofocus = array();

         --
         -- Messenger channel.
         --
         -- @since 4.7.0
         -- @var string
         --
         -- protected
         Messenger_Channel : Unbounded_String;

         --
         -- Whether the autosave revision of the changeset should be loaded.
         --
         -- @since 4.9.0
         -- @var bool
         --
--        protected autosaved = false;

         --
         -- Whether the changeset branching is allowed.
         --
         -- @since 4.9.0
         -- @var bool
         --
         -- protected
         M_Branching : Boolean := True;

         --
         -- Whether settings should be previewed.
         --
         -- @since 4.9.0
         -- @var bool
         --
         -- protected
         M_Settings_Previewed : Boolean := True;

         --
         -- Whether a starter content changeset was saved.
         --
         -- @since 4.9.0
         -- @var bool
         --
--        protected saved_starter_content_changeset = false;

         --
         -- Unsanitized values for Customize Settings parsed from _POST['customized'].
         --
         -- @var array
         --
         -- private
         X_Post_Values : Array_Type;

         --
         -- Changeset UUID.
         --
         -- @since 4.7.0
         -- @var string
         --
--        private _changeset_uuid;
         X_Changeset_UUID : Unbounded_String;

         --
         -- Changeset post ID.
         --
         -- @since 4.7.0
         -- @var int|false
         --
         -- private
         X_Changeset_Post_Id     : Post_Id; -- Integer;
         X_Changeset_Post_Id_Set : Boolean := False;

         --
         -- Changeset data loaded from a customize_changeset post.
         --
         -- @since 4.7.0
         -- @var array|null
         --
         -- private
         X_Changeset_Data : Array_Type;

      end record;

   --
   -- Constructor.
   --
   -- @since 3.4.0
   -- @since 4.7.0 Added `args` parameter.
   --
   -- @param array args {
   --     Args.
   --
   --     @type null|string|false changeset_uuid
   --       Changeset UUID, the `post_name` for the customize_changeset post
   --       containing the customized state. Defaults to `null` resulting in a UUID to
   --       be immediately generated. If `false` is provided, then the changeset UUID
   --       will be determined during `after_setup_theme`: when the
   --       `customize_changeset_branching` filter returns false, then the default
   --       UUID will be that of the most recent `customize_changeset` post that has
   --       a status other than "auto-draft", "publish", or "trash". Otherwise, if
   --       changeset branching is enabled, then a random UUID will be used.
   --
   --     @type string theme              Theme to be previewed (for theme switch).
   --                                     Defaults to customize_theme or theme query
   --                                     params.
   --     @type string messenger_channel  Messenger channel. Defaults to
   --                                     customize_messenger_channel query param.
   --     @type bool   settings_previewed If settings should be previewed. Defaults
   --                                     to true.
   --     @type bool   branching          If changeset branching is allowed;
   --                                     otherwise, changesets are linear. Defaults
   --                                     to true.
   --     @type bool   autosaved          If data from a changeset"s autosaved
   --                                     revision should be loaded if it exists.
   --                                     Defaults to false.
   -- }
   --
   function X_Construct (Args : Array_Type)
                         return Wp_Customize_Manager;

   --
   -- Returns true if it's an Ajax request.
   --
   -- @since 3.4.0
   -- @since 4.2.0 Added `action` param.
   --
   -- @param string|null action Whether the supplied Ajax action is being run.
   -- @return bool True if it"s an Ajax request, false otherwise.
   --
   function Doing_AJAX (This   : Wp_Customize_Manager;
                        Action : String := "") -- null
                        return Boolean;

   --
   -- Starts preview and customize theme.
   --
   -- Check if customize query variable exist. Init filters to filter the active theme.
   --
   -- @since 3.4.0
   --
   -- @global string pagenow The filename of the current screen.
   --
   procedure Setup_Theme (This : in out Wp_Customize_Manager);

   --
   -- Establishes the loaded changeset.
   --
   -- This method runs right at after_setup_theme and applies the
   -- "customize_changeset_branching" filter to determine whether concurrent
   -- changesets are allowed. Then if the Customizer is not initialized with a
   -- `changeset_uuid` param, this method will determine which UUID should be used.
   -- If changeset branching is disabled, then the most saved changeset will be loaded
   -- by default. Otherwise, if there are no existing saved changesets or if changeset
   -- branching is enabled, then a new UUID will be generated.
   --
   -- @since 4.9.0
   --
   -- @global string pagenow The filename of the current screen.
   --
   procedure Establish_Loaded_Changeset (This : in out Wp_Customize_Manager);

   --
   -- Gets whether settings are or will be previewed.
   --
   -- @since 4.9.0
   --
   -- @see WP_Customize_Setting::preview()
   --
   -- @return bool
   --
   function Settings_Previewed (This : Wp_Customize_Manager)
                                return Boolean;

   --
   -- Whether the changeset branching is allowed.
   --
   -- @since 4.9.0
   --
   -- @see WP_Customize_Manager::establish_loaded_changeset()
   --
   -- @return bool Is changeset branching.
   --
   function Branching (This : in out Wp_Customize_Manager)
                       return Boolean;

   --
   -- Gets the changeset UUID.
   --
   -- @since 4.7.0
   --
   -- @see WP_Customize_Manager::establish_loaded_changeset()
   --
   -- @return string UUID.
   --
   function Changeset_UUID (This : in out Wp_Customize_Manager)
                            return String;

   --
   -- Checks if the current theme is active.
   --
   -- @since 3.4.0
   --
   -- @return bool
   --
   function Is_Theme_Active (This : Wp_Customize_Manager)
                             return Boolean;

   --
   -- Registers styles/scripts and initialize the preview of each setting
   --
   -- @since 3.4.0
   --
   procedure Wp_Loaded (This : in out Wp_Customize_Manager);

   --
   -- Finds the changeset post ID for a given changeset UUID.
   --
   -- @since 4.7.0
   --
   -- @param string uuid Changeset UUID.
   -- @return int|null Returns post ID on success and null on failure.
   --
   function Find_Changeset_Post_Id (This : Wp_Customize_Manager;
                                    UUID : String)
                                    return Post_Id; -- Natural;

   --
   -- Gets changeset posts.
   --
   -- @since 4.9.0
   --
   -- @param array args {
   --     Args to pass into `get_posts()` to query changesets.
   --
   --     @type int    posts_per_page             Number of posts to return. Defaults
   --                                              to -1 (all posts).
   --     @type int    author                     Post author. Defaults to current
   --                                              user.
   --     @type string post_status                Status of changeset. Defaults to
   --                                              "auto-draft".
   --     @type bool   exclude_restore_dismissed  Whether to exclude changeset
   --                                              auto-drafts that have been
   --                                              dismissed. Defaults to true.
   -- }
   -- @return WP_Post[] Auto-draft changesets.
   --
   -- protected
   function Get_Changeset_Posts (This : Wp_Customize_Manager;
                                 Args : Array_Type)
                                 return Class_Posts.Post_Array;

   --
   -- Gets the changeset post ID for the loaded changeset.
   --
   -- @since 4.7.0
   --
   -- @return int|null Post ID on success or null if there is no post yet saved.
   --
   function Changeset_Post_Id (This : in out Wp_Customize_Manager)
                               return Post_Id; -- Natural;

   --
   -- Returns the sanitized value for a given setting from the current customized
   -- state.
   --
   -- The name "post_value" is a carry-over from when the customized state was
   -- exclusively sourced from `_POST["customized"]`. Nevertheless, the value
   -- returned will come from the current changeset post and from the incoming post
   -- data.
   --
   -- @since 3.4.0
   -- @since 4.1.1 Introduced the `default_value` parameter.
   -- @since 4.6.0 `default_value` is now returned early when the setting post value
   --               is invalid.
   --
   -- @see WP_REST_Server::dispatch()
   -- @see WP_REST_Request::sanitize_params()
   -- @see WP_REST_Request::has_valid_params()
   --
   -- @param WP_Customize_Setting setting       A WP_Customize_Setting derived object.
   -- @param mixed                default_value Value returned if `setting` has no
   --                                            post value (added in 4.2.0) or the
   --                                            post value is invalid (added in
   --                                            4.6.0).
   -- @return string|mixed Sanitized value or the `default_value` provided.
   --
   function Post_Value (This          : in out Wp_Customize_Manager;
                        Setting       : Wp_Customize_Setting;
                        Default_Value : String := "") -- null
                        return String;

   --
   -- Overrides a setting's value in the current customized state.
   --
   -- The name "post_value" is a carry-over from when the customized state was
   -- exclusively sourced from `_POST["customized"]`.
   --
   -- @since 4.2.0
   --
   -- @param string setting_id ID for the WP_Customize_Setting instance.
   -- @param mixed  value      Post value.
   --
   procedure Set_Post_Value (This       : in out Wp_Customize_Manager;
                             Setting_Id : String;
                             Value      : Array_Type); -- Multi_Type);

   --
   -- Retrieves the stylesheet name of the previewed theme.
   --
   -- @since 3.4.0
   --
   -- @return string Stylesheet name.
   --
   function Get_Stylesheet (This : Wp_Customize_Manager)
                            return String;

   --
   -- Gets dirty pre-sanitized setting values in the current customized state.
   --
   -- The returned array consists of a merge of three sources:
   -- 1. If the theme is not currently active, then the base array is any stashed
   --    theme mods that were modified previously but never published.
   -- 2. The values from the current changeset, if it exists.
   -- 3. If the user can customize, the values parsed from the incoming
   --    `_POST["customized"]` JSON data.
   -- 4. Any programmatically-set post values via
   --    `WP_Customize_Manager::set_post_value()`.
   --
   -- The name "unsanitized_post_values" is a carry-over from when the customized
   -- state was exclusively sourced from `_POST["customized"]`. Nevertheless,
   -- the value returned will come from the current changeset post and from the
   -- incoming post data.
   --
   -- @since 4.1.1
   -- @since 4.7.0 Added `args` parameter and merging with changeset values and
   --              stashed theme mods.
   --
   -- @param array args {
   --     Args.
   --
   --     @type bool exclude_changeset Whether the changeset values should also be
   --                                   excluded. Defaults to false.
   --     @type bool exclude_post_data Whether the post input values should also be
   --                                   excluded. Defaults to false when lacking the
   --                                   customize capability.
   -- }
   -- @return array
   --
   function Unsanitized_Post_Values (This : in out Wp_Customize_Manager;
                                     Args : Array_Type := Empty_Array)
                                     return Array_Type;

   procedure Unsanitized_Post_Values (This : in out Wp_Customize_Manager;
                                      Args : Array_Type := Empty_Array);

   --
   -- Marks the changeset post as being currently edited by the current user.
   --
   -- @since 4.9.0
   --
   -- @param int  changeset_post_id Changeset post ID.
   -- @param bool take_over Whether to take over the changeset. Default false.
   --
   procedure Set_Changeset_Lock (This              : Wp_Customize_Manager;
                                 Changeset_Post_Id : Post_Id; -- Integer;
                                 Take_Over         : Boolean := False);
   --
   -- Refreshes changeset lock with the current time if current user edited the
   -- changeset before.
   --
   -- @since 4.9.0
   --
   -- @param int changeset_post_id Changeset post ID.
   --
   procedure Refresh_Changeset_Lock (This              : Wp_Customize_Manager;
                                     Changeset_Post_Id : Post_Id); -- Integer);

   --
   -- Adds a customize setting.
   --
   -- @since 3.4.0
   -- @since 4.5.0 Return added WP_Customize_Setting instance.
   --
   -- @see WP_Customize_Setting::__construct()
   -- @link https://developer.wordpress.org/themes/customize-api
   --
   -- @param WP_Customize_Setting|string id   Customize Setting object, or ID.
   -- @param array                       args Optional. Array of properties for the
   --                                          new Setting object.
   --                                          See WP_Customize_Setting::__construct()
   --                                          for information on accepted arguments.
   --                                          Default empty array.
   -- @return WP_Customize_Setting The instance of the setting that was added.
   --
   function Add_Setting (This : Wp_Customize_Manager;
                         Id   : String;
                         Args : Array_Type := Empty_Array)
                         return Inc_Class_Wp_Customize_Settings.Wp_Customize_Setting;

   procedure Add_Setting (This : Wp_Customize_Manager;
                          Id   : String;
                          Args : Array_Type := Empty_Array);

   procedure Add_Setting (This : Wp_Customize_Manager;
                          Id   : Wp_Customize_Setting;
                          Args : Array_Type := Empty_Array);

   --
   -- Registers any dynamically-created settings, such as those from
   -- _POST["customized"] that have no corresponding setting created.
   --
   -- This is a mechanism to "wake up" settings that have been dynamically created
   -- on the front end and have been sent to WordPress in `_POST["customized"]`. When
   -- WP loads, the dynamically-created settings then will get created and previewed
   -- even though they are not directly created statically with code.
   --
   -- @since 4.2.0
   --
   -- @param array setting_ids The setting IDs to add.
   -- @return array The WP_Customize_Setting objects added.
   --
   function Add_Dynamic_Settings (This : Wp_Customize_Manager;
                                  Setting_Ids : List_Type)
                                  return Setting_Lists.Vector; -- Array_Type;

   --
   -- Adds a customize section.
   --
   -- @since 3.4.0
   -- @since 4.5.0 Return added WP_Customize_Section instance.
   --
   -- @see WP_Customize_Section::__construct()
   --
   -- @param WP_Customize_Section|string id   Customize Section object, or ID.
   -- @param array                       args Optional. Array of properties for the
   --                                          new Section object.
   --                                          See WP_Customize_Section::__construct()
   --                                          for information on accepted arguments.
   --                                          Default empty array.
   --
   -- @return WP_Customize_Section The instance of the section that was added.
   --
   function Add_Section (This : aliased Wp_Customize_Manager;
                         Id   : String;
                         Args : Array_Type := Empty_Array)
                         return Inc_Class_Wp_Customize_Sections.Wp_Customize_Section;

   function Add_Section (This : aliased Wp_Customize_Manager;
                         Id   : Inc_Class_Wp_Customize_Sections.Wp_Customize_Section;
                         Args : Array_Type := Empty_Array)
                         return Inc_Class_Wp_Customize_Sections.Wp_Customize_Section;

   procedure Add_Section (This : Wp_Customize_Manager;
                          Id   : String;
                          Args : Array_Type := Empty_Array);

   procedure Add_Section (This : Wp_Customize_Manager;
                          Id   : Inc_Class_Wp_Customize_Sections.Wp_Customize_Section;
                          Args : Array_Type := Empty_Array);

   --
   -- Adds a customize control.
   --
   -- @since 3.4.0
   -- @since 4.5.0 Return added WP_Customize_Control instance.
   --
   -- @see WP_Customize_Control::__construct()
   --
   -- @param WP_Customize_Control|string id   Customize Control object, or ID.
   -- @param array                       args Optional. Array of properties for the
   --                                          new Control object.
   --                                          See WP_Customize_Control::__construct()
   --                                          for information on accepted arguments.
   --                                          Default empty array.
   -- @return WP_Customize_Control The instance of the control that was added.
   --
   function Add_Control (This : aliased Wp_Customize_Manager;
                         Id   : String;
                         Args : Array_Type := Empty_Array)
                         return Inc_Class_Wp_Customize_Controls.Wp_Customize_Control;

   function Add_Control (This : aliased Wp_Customize_Manager;
                         Id   : Inc_Class_Wp_Customize_Controls.Wp_Customize_Control;
                         Args : Array_Type := Empty_Array)
                         return Inc_Class_Wp_Customize_Controls.Wp_Customize_Control;

   procedure Add_Control (This : Wp_Customize_Manager;
                          Id   : Inc_Class_Wp_Customize_Controls.Wp_Customize_Control;
                          Args : Array_Type := Empty_Array);

   --
   -- Retrieves a customize setting.
   --
   -- @since 3.4.0
   --
   -- @param string id Customize Setting ID.
   -- @return WP_Customize_Setting|void The setting, if set.
   --
   function Get_Setting (This : Wp_Customize_Manager;
                         Id   : String)
                         return Inc_Class_Wp_Customize_Settings.Wp_Customize_Setting;
   --
   -- Adds a customize panel.
   --
   -- @since 4.0.0
   -- @since 4.5.0 Return added WP_Customize_Panel instance.
   --
   -- @see WP_Customize_Panel::__construct()
   --
   -- @param WP_Customize_Panel|string id   Customize Panel object, or ID.
   -- @param array                     args Optional. Array of properties for the new
   --                                        Panel object.
   --                                        See WP_Customize_Panel::__construct() for
   --                                        information on accepted arguments.
   --                                        Default empty array.
   -- @return WP_Customize_Panel The instance of the panel that was added.
   --
   function Add_Panel (This : aliased Wp_Customize_Manager;
                       Id   : String;
                       Args : Array_Type := Empty_Array)
                       return Inc_Class_Wp_Customize_Panels.Wp_Customize_Panel;

   procedure Add_Panel (This : Wp_Customize_Manager;
                        Id   : String;
                        Args : Array_Type := Empty_Array);

   --
   -- Retrieves a customize panel.
   --
   -- @since 4.0.0
   --
   -- @param string id Panel ID to get.
   -- @return WP_Customize_Panel|void Requested panel instance, if set.
   --
   function Get_Panel (This : Wp_Customize_Manager;
                       Id   : String)
                       return Inc_Class_Wp_Customize_Panels.Wp_Customize_Panel;

end Inc_Class_Wp_Customize_Managers;
