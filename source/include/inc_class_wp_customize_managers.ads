--
-- WordPress Customize Manager classes
--
-- @package WordPress
-- @subpackage Customize
-- @since 3.4.0
--

with Ada.Strings.Unbounded;

package Inc_Class_Wp_Customize_Managers
is
   use Ada.Strings.Unbounded;

   procedure Dummy;
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
--        protected theme;

        --
        -- The directory name of the previously active theme (within the theme_root).
        --
        -- @since 3.4.0
        -- @var string
        --
--        protected original_stylesheet;

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
--        public widgets;

        --
        -- Methods and properties dealing with managing nav menus in the Customizer.
        --
        -- @since 4.3.0
        -- @var WP_Customize_Nav_Menus
        --
--        public nav_menus;

        --
        -- Methods and properties dealing with selective refresh in the Customizer preview.
        --
        -- @since 4.5.0
        -- @var WP_Customize_Selective_Refresh
        --
--        public selective_refresh;

        --
        -- Registered instances of WP_Customize_Setting.
        --
        -- @since 3.4.0
        -- @var array
        --
--        protected settings = array();

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
--        protected panels = array();

        --
        -- List of core components.
        --
        -- @since 4.5.0
        -- @var array
        --
--        protected components = array( 'widgets', 'nav_menus' );

        --
        -- Registered instances of WP_Customize_Section.
        --
        -- @since 3.4.0
        -- @var array
        --
--        protected sections = array();

        --
        -- Registered instances of WP_Customize_Control.
        --
        -- @since 3.4.0
        -- @var array
        --
--        protected controls = array();

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
        -- Mapping of 'panel', 'section', 'control' to the ID which should be autofocused.
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
--        protected messenger_channel;

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
--        protected branching = true;

        --
        -- Whether settings should be previewed.
        --
        -- @since 4.9.0
        -- @var bool
        --
--        protected settings_previewed = true;

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
--        private _post_values;

        --
        -- Changeset UUID.
        --
        -- @since 4.7.0
        -- @var string
        --
--        private _changeset_uuid;
        Changeset_Uuid : Unbounded_String;

        --
        -- Changeset post ID.
        --
        -- @since 4.7.0
        -- @var int|false
        --
--        private _changeset_post_id;
        Changeset_Post_Id : Integer;

        --
        -- Changeset data loaded from a customize_changeset post.
        --
        -- @since 4.7.0
        -- @var array|null
        --
--        private _changeset_data;

      end record;

end Inc_Class_Wp_Customize_Managers;
