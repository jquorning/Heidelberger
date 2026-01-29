--
-- Theme, template, and stylesheet functions.
--
-- @package WordPress
-- @subpackage Theme
--

with Ada.Containers;

with Php.Arrays;
with Php.Echoing;
with Php.Files;
with Php.HTML;
with Php.Lists;
with Php.Strings;
with Php.Types;

with Binder;
with Constants;
with Globals;
with UStrings;
with Wp_Common;

-- with Class_Customize_Managers;
with Inc_Formatting;
with Inc_Functions;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Plugins;
with Inc_Post_Formats;
with Inc_REST_API;

package body Inc_Themes
is

   Global_Wp_Theme_Features : Array_Type;

-- --
-- -- Returns an array of WP_Theme objects based on the arguments.
-- --
-- -- Despite advances over get_themes(), this function is quite expensive, and grows
-- -- linearly with additional themes. Stick to wp_get_theme() if possible.
-- --
-- -- @since 3.4.0
-- --
-- -- @global array wp_theme_directories
-- --
-- -- @param array args then
-- --     Optional. The search arguments.
-- --
-- --     @type mixed errors  True to return themes with errors, false to return
-- --                          themes without errors, null to return all themes.
-- --                          Default false.
-- --     @type mixed allowed (Multisite) True to return only allowed themes for a site.
-- --                          False to return only disallowed themes for a site.
-- --                          "site" to return only site-allowed themes.
-- --                          "network" to return only network-allowed themes.
-- --                          Null to return all themes. Default null.
-- --     @type int   blog_id (Multisite) The blog ID used to calculate which themes
-- --                          are allowed. Default 0, synonymous for the current blog.
-- -- end;
-- -- @return WP_Theme[] Array of WP_Theme objects.
-- --
-- function wp_get_themes( args = array() ) then
--         global wp_theme_directories;

--         defaults = array(
--                 "errors"  => false,
--                 "allowed" => null,
--                 "blog_id" => 0,
--         );
--         args     = wp_parse_args( args, defaults );

--         theme_directories = search_theme_directories();

--         if ( is_array( wp_theme_directories ) && count( wp_theme_directories ) > 1 ) then
--                 // Make sure the active theme wins out, in case search_theme_directories() picks the wrong
--                 // one in the case of a conflict. (Normally, last registered theme root wins.)
--                 current_theme = get_stylesheet();
--                 if ( isset( theme_directories[ current_theme ] ) ) then
--                         root_of_current_theme = get_raw_theme_root( current_theme );
--                         if ( ! in_array( root_of_current_theme, wp_theme_directories, true ) ) then
--                                 root_of_current_theme = WP_CONTENT_DIR . root_of_current_theme;
--                         end;
--                         theme_directories[ current_theme ]["theme_root"] = root_of_current_theme;
--                 end;
--         end;

--         if ( empty( theme_directories ) ) then
--                 return array();
--         end;

--         if ( is_multisite() && null !== args["allowed"] ) then
--                 allowed = args["allowed"];
--                 if ( "network" === allowed ) then
--                         theme_directories = array_intersect_key( theme_directories, WP_Theme::get_allowed_on_network() );
--                 end; elseif ( "site" === allowed ) then
--                         theme_directories = array_intersect_key( theme_directories, WP_Theme::get_allowed_on_site( args["blog_id"] ) );
--                 end; elseif ( allowed ) then
--                         theme_directories = array_intersect_key( theme_directories, WP_Theme::get_allowed( args["blog_id"] ) );
--                 end; else then
--                         theme_directories = array_diff_key( theme_directories, WP_Theme::get_allowed( args["blog_id"] ) );
--                 end;
--         end;

--         themes         = array();
--         static _themes = array();

--         foreach ( theme_directories as theme => theme_root ) then
--                 if ( isset( _themes[ theme_root["theme_root"] . "/" . theme ] ) ) then
--                         themes[ theme ] = _themes[ theme_root["theme_root"] . "/" . theme ];
--                 end; else then
--                         themes[ theme ] = new WP_Theme( theme, theme_root["theme_root"] );

--                         _themes[ theme_root["theme_root"] . "/" . theme ] = themes[ theme ];
--                 end;
--         end;

--         if ( null !== args["errors"] ) then
--                 foreach ( themes as theme => wp_theme ) then
--                         if ( wp_theme.errors() != args["errors"] ) then
--                                 unset( themes[ theme ] );
--                         end;
--                 end;
--         end;

--         return themes;
-- end;

   ------------------
   -- Wp_Get_Theme --
   ------------------

   function Wp_Get_Theme (Stylesheet : String := "";
                          Theme_Root : String := "")
                          return Class_Themes.Wp_Theme
   is
      use Php.Lists;
      use Php.Strings;
      use UStrings;

      Stylesheet_2 : String := (if Empty (Stylesheet)
                                then Get_Stylesheet
                                else Stylesheet);
   begin
      if Empty (Theme_Root) then
         declare
            Theme_Root : UString := +Get_Raw_Theme_Root (Stylesheet_2);
         begin
            if "" = Theme_Root then -- False =
               Theme_Root := Globals.WP_CONTENT_DIR & "/themes";
            elsif not In_List (-Theme_Root, Wp_Theme_Directories, True) then
               Theme_Root := Globals.WP_CONTENT_DIR & Theme_Root;
            end if;
         end;
      end if;

      declare
         use Class_Themes;

         T : Wp_Theme := Null_Theme;
      begin
         return Class_Themes.X_Construct (Stylesheet_2, Theme_Root, T);
      end;
   end Wp_Get_Theme;

-- --
-- -- Clears the cache held by get_theme_roots() and WP_Theme.
-- --
-- -- @since 3.5.0
-- -- @param bool clear_update_cache Whether to clear the theme updates cache.
-- --
-- function wp_clean_themes_cache( clear_update_cache = true ) then
--         if ( clear_update_cache ) then
--                 delete_site_transient( "update_themes" );
--         end;
--         search_theme_directories( true );
--         foreach ( wp_get_themes( array( "errors" => null ) ) as theme ) then
--                 theme.cache_delete();
--         end;
-- end;

-- --
-- -- Whether a child theme is in use.
-- --
-- -- @since 3.0.0
-- --
-- -- @return bool True if a child theme is in use, false otherwise.
-- --
-- function is_child_theme() then
--         return ( TEMPLATEPATH !== STYLESHEETPATH );
-- end;

   --------------------
   -- Get_Stylesheet --
   --------------------

   function Get_Stylesheet
            return String
   is
      use Wp_Common;
      use Inc_Options;
   begin
      --
      -- Filters the name of current stylesheet.
      --
      -- @since 1.5.0
      --
      -- @param string stylesheet Name of the current stylesheet.
      --
      return Apply_Filters ("stylesheet", Get_Option ("stylesheet"));
   end Get_Stylesheet;

   ------------------------------
   -- Get_Stylesheet_Directory --
   ------------------------------

   function Get_Stylesheet_Directory
            return String
   is
      use Wp_Common;

      Stylesheet     : constant String := Get_Stylesheet; -- ();
      Theme_Root     : constant String := Get_Theme_Root (Stylesheet);
      Stylesheet_Dir : constant String := "theme_root/stylesheet";
   begin
      --
      -- Filters the stylesheet directory path for the active theme.
      --
      -- @since 1.5.0
      --
      -- @param string stylesheet_dir Absolute path to the active theme.
      -- @param string stylesheet     Directory name of the active theme.
      -- @param string theme_root     Absolute path to themes directory.
      --
      return Apply_Filters ("stylesheet_directory", Stylesheet_Dir, Stylesheet,
                            Theme_Root);
   end Get_Stylesheet_Directory;

   ----------------------------------
   -- Get_Stylesheet_Directory_URI --
   ----------------------------------

   function Get_Stylesheet_Directory_URI
            return String
   is
      use Php.HTML;
      use Php.Strings;
      use Wp_Common;

      Stylesheet : constant String :=
        Str_Replace ("%2F", "/", Raw_URL_Encode (Get_Stylesheet));

      Theme_Root_URI : constant String :=
        Get_Theme_Root_URI (Stylesheet);

      Stylesheet_Dir_URI : constant String :=
        Theme_Root_URI & "/" & Stylesheet;
   begin
      --
      -- Filters the stylesheet directory URI.
      --
      -- @since 1.5.0
      --
      -- @param string stylesheet_dir_uri Stylesheet directory URI.
      -- @param string stylesheet         Name of the activated theme"s directory.
      -- @param string theme_root_uri     Themes root URI.
      --
      return
        Apply_Filters ("stylesheet_directory_uri", Stylesheet_Dir_URI,
                       Stylesheet, Theme_Root_URI);
   end Get_Stylesheet_Directory_URI;

-- --
-- -- Retrieves stylesheet URI for the active theme.
-- --
-- -- The stylesheet file name is "style.css" which is appended to the stylesheet directory URI path.
-- -- See get_stylesheet_directory_uri().
-- --
-- -- @since 1.5.0
-- --
-- -- @return string URI to active theme"s stylesheet.
-- --
-- function get_stylesheet_uri() then
--         stylesheet_dir_uri = get_stylesheet_directory_uri();
--         stylesheet_uri     = stylesheet_dir_uri . "/style.css";
--         --
--         -- Filters the URI of the active theme stylesheet.
--         --
--         -- @since 1.5.0
--         --
--         -- @param string stylesheet_uri     Stylesheet URI for the active theme/child theme.
--         -- @param string stylesheet_dir_uri Stylesheet directory URI for the active theme/child theme.
--         --
--         return apply_filters( "stylesheet_uri", stylesheet_uri, stylesheet_dir_uri );
-- end;

-- --
-- -- Retrieves the localized stylesheet URI.
-- --
-- -- The stylesheet directory for the localized stylesheet files are located, by
-- -- default, in the base theme directory. The name of the locale file will be the
-- -- locale followed by ".css". If that does not exist, then the text direction
-- -- stylesheet will be checked for existence, for example "ltr.css".
-- --
-- -- The theme may change the location of the stylesheet directory by either using
-- -- the {@see "stylesheet_directory_uri"} or {@see "locale_stylesheet_uri"} filters.
-- --
-- -- If you want to change the location of the stylesheet files for the entire
-- -- WordPress workflow, then change the former. If you just have the locale in a
-- -- separate folder, then change the latter.
-- --
-- -- @since 2.1.0
-- --
-- -- @global WP_Locale wp_locale WordPress date and time locale object.
-- --
-- -- @return string URI to active theme"s localized stylesheet.
-- --
-- function get_locale_stylesheet_uri() then
--         global wp_locale;
--         stylesheet_dir_uri = get_stylesheet_directory_uri();
--         dir                = get_stylesheet_directory();
--         locale             = get_locale();
--         if ( file_exists( "dir/locale.css" ) ) then
--                 stylesheet_uri = "stylesheet_dir_uri/locale.css";
--         end; elseif ( ! empty( wp_locale.text_direction ) && file_exists( "dir/thenwp_locale.text_directionend;.css" ) ) then
--                 stylesheet_uri = "stylesheet_dir_uri/thenwp_locale.text_directionend;.css";
--         end; else then
--                 stylesheet_uri = "";
--         end;
--         --
--         -- Filters the localized stylesheet URI.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string stylesheet_uri     Localized stylesheet URI.
--         -- @param string stylesheet_dir_uri Stylesheet directory URI.
--         --
--         return apply_filters( "locale_stylesheet_uri", stylesheet_uri, stylesheet_dir_uri );
-- end;

   ------------------
   -- Get_Template --
   ------------------

   function Get_Template
            return String
   is
      use Wp_Common;
      use Inc_Options;
   begin
      --
      -- Filters the name of the active theme.
      --
      -- @since 1.5.0
      --
      -- @param string template active theme"s directory name.
      --
      return Apply_Filters ("template", Get_Option ("template"));
   end Get_Template;

   ----------------------------
   -- Get_Template_Directory --
   ----------------------------

   function Get_Template_Directory
            return String
   is
      use Wp_Common;

      Template     : constant String := Get_Template; -- ();
      Theme_Root   : constant String := Get_Theme_Root (Template);
      Template_Dir : constant String := "theme_root/template";
   begin
      --
      -- Filters the active theme directory path.
      --
      -- @since 1.5.0
      --
      -- @param string template_dir The path of the active theme directory.
      -- @param string template     Directory name of the active theme.
      -- @param string theme_root   Absolute path to the themes directory.
      --
      return Apply_Filters ("template_directory", Template_Dir, Template,
                            Theme_Root);
   end Get_Template_Directory;

   --------------------------------
   -- Get_Template_Directory_URI --
   --------------------------------

   function Get_Template_Directory_URI
            return String
   is
      use Php.HTML;
      use Php.Strings;
      use Wp_Common;

      Template : constant String :=
        Str_Replace ("%2F", "/", Raw_URL_Encode (Get_Template));

      Theme_Root_URI : constant String :=
        Get_Theme_Root_URI (Template);

      Template_Dir_URI : constant String :=
        Theme_Root_URI & "/" & Template;
   begin
      --
      -- Filters the active theme directory URI.
      --
      -- @since 1.5.0
      --
      -- @param string template_dir_uri The URI of the active theme directory.
      -- @param string template         Directory name of the active theme.
      -- @param string theme_root_uri   The themes root URI.
      --
      return
        Apply_Filters ("template_directory_uri", Template_Dir_URI,
                       Template, Theme_Root_URI);
   end Get_Template_Directory_URI;

   ---------------------
   -- Get_Theme_Roots --
   ---------------------

   function Get_Theme_Roots
            return Inc_Options.String_Maps.Map
   is
      use Ada.Containers;
      use Php.Types;
      use Inc_Options;

--         global wp_theme_directories;
      Theme_Roots : String_Maps.Map;
      Unused      : Array_Type;
   begin
      if
        not Is_Array (Wp_Theme_Directories) or else
        Wp_Theme_Directories.Length <= 1
      then
         declare
            M : String_Maps.Map;
         begin
            M.Include ("/themes", "/themes");
            return M; -- "/themes";
         end;
      end if;

      Theme_Roots := Get_Site_Transient ("theme_roots");
      if Theme_Roots.Is_Empty then
--    if ( false === theme_roots ) then
         Unused := Search_Theme_Directories (Force => True);
         -- Regenerate the transient.
         Theme_Roots := Get_Site_Transient ("theme_roots");
      end if;
      return Theme_Roots;
   end Get_Theme_Roots;

   ------------------------------
   -- Register_Theme_Directory --
   ------------------------------

   function Register_Theme_Directory (Directory : String)
                                      return Boolean
   is
      use Php.Files;
      use Php.Lists;
      use Php.Strings;
      use Globals;
      use UStrings;
      use Inc_Formatting;

      Directory_2 : UString;
      Untrailed   : UString;
   begin
      if not File_Exists (Directory) then
         -- Try prepending as the theme directory could be relative to the content
         -- directory.
         Directory_2 := WP_CONTENT_DIR & "/" & Directory;

         -- If this directory does not exist, return and do not register.
         if not File_Exists (-Directory_2) then
            return False;
         end if;
      end if;

--      if ( ! is_array( wp_theme_directories ) ) then
--              wp_theme_directories = array();
--      end;

      Untrailed := +Un_Trailing_Slash_It (-Directory_2);
      if
        not Empty (Untrailed) and then
        not In_List (-Untrailed, Wp_Theme_Directories, True)
      then
         Wp_Theme_Directories.Append (-Untrailed);
      end if;

      return True;
   end Register_Theme_Directory;

-- --
-- -- Searches all registered theme directories for complete and valid themes.
-- --
-- -- @since 2.9.0
-- --
-- -- @global array wp_theme_directories
-- --
-- -- @param bool force Optional. Whether to force a new directory scan. Default false.
-- -- @return array|false Valid themes found on success, false on failure.
-- --
-- function search_theme_directories( force = false ) then
--         global wp_theme_directories;
--         static found_themes = null;

--         if ( empty( wp_theme_directories ) ) then
--                 return false;
--         end;

--         if ( ! force && isset( found_themes ) ) then
--                 return found_themes;
--         end;

--         found_themes = array();

--         wp_theme_directories = (array) wp_theme_directories;
--         relative_theme_roots = array();

--         /*
--         -- Set up maybe-relative, maybe-absolute array of theme directories.
--         -- We always want to return absolute, but we need to cache relative
--         -- to use in get_theme_root().
--         --
--         foreach ( wp_theme_directories as theme_root ) then
--                 if ( 0 === strpos( theme_root, WP_CONTENT_DIR ) ) then
--                         relative_theme_roots[ str_replace( WP_CONTENT_DIR, "", theme_root ) ] = theme_root;
--                 end; else then
--                         relative_theme_roots[ theme_root ] = theme_root;
--                 end;
--         end;

--         --
--         -- Filters whether to get the cache of the registered theme directories.
--         --
--         -- @since 3.4.0
--         --
--         -- @param bool   cache_expiration Whether to get the cache of the theme directories. Default false.
--         -- @param string context          The class or function name calling the filter.
--         --
--         cache_expiration = apply_filters( "wp_cache_themes_persistently", false, "search_theme_directories" );

--         if ( cache_expiration ) then
--                 cached_roots = get_site_transient( "theme_roots" );
--                 if ( is_array( cached_roots ) ) then
--                         foreach ( cached_roots as theme_dir => theme_root ) then
--                                 // A cached theme root is no longer around, so skip it.
--                                 if ( ! isset( relative_theme_roots[ theme_root ] ) ) then
--                                         continue;
--                                 end;
--                                 found_themes[ theme_dir ] = array(
--                                         "theme_file" => theme_dir . "/style.css",
--                                         "theme_root" => relative_theme_roots[ theme_root ], // Convert relative to absolute.
--                                 );
--                         end;
--                         return found_themes;
--                 end;
--                 if ( ! is_int( cache_expiration ) ) then
--                         cache_expiration = 30-- MINUTE_IN_SECONDS;
--                 end;
--         end; else then
--                 cache_expiration = 30-- MINUTE_IN_SECONDS;
--         end;

--         /* Loop the registered theme directories and extract all themes--
--         foreach ( wp_theme_directories as theme_root ) then

--                 // Start with directories in the root of the active theme directory.
--                 dirs = @ scandir( theme_root );
--                 if ( ! dirs ) then
--                         trigger_error( "theme_root is not readable", E_USER_NOTICE );
--                         continue;
--                 end;
--                 foreach ( dirs as dir ) then
--                         if ( ! is_dir( theme_root . "/" . dir ) || "." === dir[0] || "CVS" === dir ) then
--                                 continue;
--                         end;
--                         if ( file_exists( theme_root . "/" . dir . "/style.css" ) ) then
--                                 // wp-content/themes/a-single-theme
--                                 // wp-content/themes is theme_root, a-single-theme is dir.
--                                 found_themes[ dir ] = array(
--                                         "theme_file" => dir . "/style.css",
--                                         "theme_root" => theme_root,
--                                 );
--                         end; else then
--                                 found_theme = false;
--                                 // wp-content/themes/a-folder-of-themes/*
--                                 // wp-content/themes is theme_root, a-folder-of-themes is dir, then themes are sub_dirs.
--                                 sub_dirs = @ scandir( theme_root . "/" . dir );
--                                 if ( ! sub_dirs ) then
--                                         trigger_error( "theme_root/dir is not readable", E_USER_NOTICE );
--                                         continue;
--                                 end;
--                                 foreach ( sub_dirs as sub_dir ) then
--                                         if ( ! is_dir( theme_root . "/" . dir . "/" . sub_dir ) || "." === dir[0] || "CVS" === dir ) then
--                                                 continue;
--                                         end;
--                                         if ( ! file_exists( theme_root . "/" . dir . "/" . sub_dir . "/style.css" ) ) then
--                                                 continue;
--                                         end;
--                                         found_themes[ dir . "/" . sub_dir ] = array(
--                                                 "theme_file" => dir . "/" . sub_dir . "/style.css",
--                                                 "theme_root" => theme_root,
--                                         );
--                                         found_theme                           = true;
--                                 end;
--                                 // Never mind the above, it"s just a theme missing a style.css.
--                                 // Return it; WP_Theme will catch the error.
--                                 if ( ! found_theme ) then
--                                         found_themes[ dir ] = array(
--                                                 "theme_file" => dir . "/style.css",
--                                                 "theme_root" => theme_root,
--                                         );
--                                 end;
--                         end;
--                 end;
--         end;

--         asort( found_themes );

--         theme_roots          = array();
--         relative_theme_roots = array_flip( relative_theme_roots );

--         foreach ( found_themes as theme_dir => theme_data ) then
--                 theme_roots[ theme_dir ] = relative_theme_roots[ theme_data["theme_root"] ]; // Convert absolute to relative.
--         end;

--         if ( get_site_transient( "theme_roots" ) != theme_roots ) then
--                 set_site_transient( "theme_roots", theme_roots, cache_expiration );
--         end;

--         return found_themes;
-- end;

   --------------------
   -- Get_Theme_Root --
   --------------------

   function Get_Theme_Root (Stylesheet_Or_Template : String := "")
                            return String
   is
      use Php.Lists;
      use Globals;
      use UStrings;
      use Wp_Common;
--      global wp_theme_directories;

      Theme_Root : UString; --  = "";
   begin
      if Stylesheet_Or_Template /= "" then
         Theme_Root := +Get_Raw_Theme_Root (Stylesheet_Or_Template);
         if Theme_Root /= "" then
            -- Always prepend WP_CONTENT_DIR unless the root currently registered as
            -- a theme directory. This gives relative theme roots the benefit of the
            -- doubt when things go haywire.
            if not In_List (-Theme_Root, Wp_Theme_Directories, True) then -- (array)
               Theme_Root := WP_CONTENT_DIR & Theme_Root;
            end if;
         end if;
      end if;

      if Theme_Root /= "" then
         Theme_Root := WP_CONTENT_DIR & "/themes";
      end if;

      --
      -- Filters the absolute path to the themes directory.
      --
      -- @since 1.5.0
      --
      -- @param string theme_root Absolute path to themes directory.
      --
      return Apply_Filters ("theme_root", -Theme_Root);
   end Get_Theme_Root;

   ------------------------
   -- Get_Theme_Root_URI --
   ------------------------

   function Get_Theme_Root_URI (Stylesheet_Or_Template : String := "";
                                Theme_Root             : String := "")
                                return String
   is
      use Php.Files;
      use Php.Lists;
      use Php.Strings;
      use Constants;
      use Globals;
      use UStrings;
      use Wp_Common;
      use Inc_Link_Templates;
      use Inc_Options;
--    global wp_theme_directories;

      Theme_Root_2 : constant String :=
        (if Stylesheet_Or_Template /= "" and then Theme_Root = ""
         then Get_Raw_Theme_Root (Stylesheet_Or_Template)
         else Theme_Root);

      Theme_Root_URI : UString;
   begin
      if Stylesheet_Or_Template /= "" and then Theme_Root_2 /= "" then
         if In_List (Theme_Root_2, Wp_Theme_Directories, True) then -- (array)
            -- Absolute path. Make an educated guess. YMMV -- but note the
            -- filter below.
            if 0 = Strpos (Theme_Root_2, -WP_CONTENT_DIR) then
               Theme_Root_URI :=
                 +Content_URL (Str_Replace (-WP_CONTENT_DIR, "", Theme_Root_2));
            elsif 0 = Strpos (Theme_Root_2, ABSPATH) then
               Theme_Root_URI := +Site_URL (Str_Replace (ABSPATH, "", Theme_Root_2));
            elsif
              0 = Strpos (Theme_Root_2, -WP_PLUGIN_DIR) or else
              0 = Strpos (Theme_Root_2, -WPMU_PLUGIN_DIR)
            then
               Theme_Root_URI := +Plugins_URL (Basename (Theme_Root_2), Theme_Root_2);
            else
               Theme_Root_URI := +Theme_Root_2;
            end if;
         else
            Theme_Root_URI := +Content_URL (Theme_Root_2);
         end if;
      else
         Theme_Root_URI := +Content_URL ("themes");
      end if;

      --
      -- Filters the URI for themes directory.
      --
      -- @since 1.5.0
      --
      -- @param string theme_root_uri         The URI for themes directory.
      -- @param string siteurl                WordPress web address which is set in
      --                                      General Options.
      -- @param string stylesheet_or_template The stylesheet or template name of
      --                                      the theme.
      --
      return Apply_Filters ("theme_root_uri", -Theme_Root_URI,
                            String'(Get_Option ("siteurl")),
                            Stylesheet_Or_Template);
   end Get_Theme_Root_URI;

-- --
-- -- Gets the raw theme root relative to the content directory with no filters applied.
-- --
-- -- @since 3.1.0
-- --
-- -- @global array wp_theme_directories
-- --
-- -- @param string stylesheet_or_template The stylesheet or template name of the theme.
-- -- @param bool   skip_cache             Optional. Whether to skip the cache.
-- --                                       Defaults to false, meaning the cache is used.
-- -- @return string Theme root.
-- --
-- function get_raw_theme_root( stylesheet_or_template, skip_cache = false ) then
   function Get_Raw_Theme_Root (Stylesheet_Or_Template : String;
                                Skip_Cache             : Boolean := False)
                                return String
   is
      use Ada.Containers;
      use Php.Strings;
      use Php.Types;
      use Inc_Options;
      use UStrings;

--    global wp_theme_directories;
      Theme_Root : UString;
   begin
      if
        not Is_Array (Wp_Theme_Directories) or else
        Wp_Theme_Directories.Length <= 1
--      Count (Wp_Theme_Directories) <= 1
      then
         return "/themes";
      end if;

--    theme_root = false;

      -- If requesting the root for the active theme, consult options to avoid
      -- calling get_theme_roots().
      if not Skip_Cache then
         if Get_Option ("stylesheet") = Stylesheet_Or_Template then
            Theme_Root := +Get_Option ("stylesheet_root");
         elsif Get_Option ("template") = Stylesheet_Or_Template then
            Theme_Root := +Get_Option ("template_root");
         end if;
      end if;

      if Empty (Theme_Root) then
         declare
            Theme_Roots : constant String_Maps.Map := Get_Theme_Roots; -- ()
         begin
            if not Empty (Theme_Roots (Stylesheet_Or_Template)) then
               Theme_Root := +Theme_Roots (Stylesheet_Or_Template);
            end if;
         end;
      end if;

      return -Theme_Root;
   end Get_Raw_Theme_Root;

-- --
-- -- Displays localized stylesheet link element.
-- --
-- -- @since 2.1.0
-- --
-- function locale_stylesheet() then
--         stylesheet = get_locale_stylesheet_uri();
--         if ( empty( stylesheet ) ) then
--                 return;
--         end;

--         type_attr = current_theme_supports( "html5", "style" ) ? "" : " type="text/css"";

--         printf(
--                 "<link rel="stylesheet" href="%s"%s media="screen" />",
--                 stylesheet,
--                 type_attr
--         );
-- end;

-- --
-- -- Switches the theme.
-- --
-- -- Accepts one argument: stylesheet of the theme. It also accepts an additional function signature
-- -- of two arguments: template then stylesheet. This is for backward compatibility.
-- --
-- -- @since 2.5.0
-- --
-- -- @global array                wp_theme_directories
-- -- @global WP_Customize_Manager wp_customize
-- -- @global array                sidebars_widgets
-- --
-- -- @param string stylesheet Stylesheet name.
-- --
-- function switch_theme( stylesheet ) then
--         global wp_theme_directories, wp_customize, sidebars_widgets;

--         requirements = validate_theme_requirements( stylesheet );
--         if ( is_wp_error( requirements ) ) then
--                 wp_die( requirements );
--         end;

--         _sidebars_widgets = null;
--         if ( "wp_ajax_customize_save" === current_action() ) then
--                 old_sidebars_widgets_data_setting = wp_customize.get_setting( "old_sidebars_widgets_data" );
--                 if ( old_sidebars_widgets_data_setting ) then
--                         _sidebars_widgets = wp_customize.post_value( old_sidebars_widgets_data_setting );
--                 end;
--         end; elseif ( is_array( sidebars_widgets ) ) then
--                 _sidebars_widgets = sidebars_widgets;
--         end;

--         if ( is_array( _sidebars_widgets ) ) then
--                 set_theme_mod(
--                         "sidebars_widgets",
--                         array(
--                                 "time" => time(),
--                                 "data" => _sidebars_widgets,
--                         )
--                 );
--         end;

--         nav_menu_locations = get_theme_mod( "nav_menu_locations" );
--         update_option( "theme_switch_menu_locations", nav_menu_locations );

--         if ( func_num_args() > 1 ) then
--                 stylesheet = func_get_arg( 1 );
--         end;

--         old_theme = wp_get_theme();
--         new_theme = wp_get_theme( stylesheet );
--         template  = new_theme.get_template();

--         if ( wp_is_recovery_mode() ) then
--                 paused_themes = wp_paused_themes();
--                 paused_themes.delete( old_theme.get_stylesheet() );
--                 paused_themes.delete( old_theme.get_template() );
--         end;

--         update_option( "template", template );
--         update_option( "stylesheet", stylesheet );

--         if ( count( wp_theme_directories ) > 1 ) then
--                 update_option( "template_root", get_raw_theme_root( template, true ) );
--                 update_option( "stylesheet_root", get_raw_theme_root( stylesheet, true ) );
--         end; else then
--                 delete_option( "template_root" );
--                 delete_option( "stylesheet_root" );
--         end;

--         new_name = new_theme.get( "Name" );

--         update_option( "current_theme", new_name );

--         // Migrate from the old mods_thennameend; option to theme_mods_thenslugend;.
--         if ( is_admin() && false === get_option( "theme_mods_" . stylesheet ) ) then
--                 default_theme_mods = (array) get_option( "mods_" . new_name );
--                 if ( ! empty( nav_menu_locations ) && empty( default_theme_mods["nav_menu_locations"] ) ) then
--                         default_theme_mods["nav_menu_locations"] = nav_menu_locations;
--                 end;
--                 add_option( "theme_mods_stylesheet", default_theme_mods );
--         end; else then
--                 /*
--                 -- Since retrieve_widgets() is called when initializing a theme in the Customizer,
--                 -- we need to remove the theme mods to avoid overwriting changes made via
--                 -- the Customizer when accessing wp-admin/widgets.php.
--                 --
--                 if ( "wp_ajax_customize_save" === current_action() ) then
--                         remove_theme_mod( "sidebars_widgets" );
--                 end;
--         end;

--         update_option( "theme_switched", old_theme.get_stylesheet() );

--         --
--         -- Fires after the theme is switched.
--         --
--         -- @since 1.5.0
--         -- @since 4.5.0 Introduced the `old_theme` parameter.
--         --
--         -- @param string   new_name  Name of the new theme.
--         -- @param WP_Theme new_theme WP_Theme instance of the new theme.
--         -- @param WP_Theme old_theme WP_Theme instance of the old theme.
--         --
--         do_action( "switch_theme", new_name, new_theme, old_theme );
-- end;

-- --
-- -- Checks that the active theme has the required files.
-- --
-- -- Standalone themes need to have a `templates/index.html` or `index.php` template file.
-- -- Child themes need to have a `Template` header in the `style.css` stylesheet.
-- --
-- -- Does not initially check the default theme, which is the fallback and should always exist.
-- -- But if it doesn"t exist, it"ll fall back to the latest core default theme that does exist.
-- -- Will switch theme to the fallback theme if active theme does not validate.
-- --
-- -- You can use the {@see "validate_current_theme"} filter to return false to disable
-- -- this functionality.
-- --
-- -- @since 1.5.0
-- -- @since 6.0.0 Removed the requirement for block themes to have an `index.php` template.
-- --
-- -- @see WP_DEFAULT_THEME
-- --
-- -- @return bool
-- --
-- function validate_current_theme() then
--         --
--         -- Filters whether to validate the active theme.
--         --
--         -- @since 2.7.0
--         --
--         -- @param bool validate Whether to validate the active theme. Default true.
--         --
--         if ( wp_installing() || ! apply_filters( "validate_current_theme", true ) ) then
--                 return true;
--         end;

--         if (
--                 ! file_exists( get_template_directory() . "/templates/index.html" )
--                 && ! file_exists( get_template_directory() . "/block-templates/index.html" ) // Deprecated path support since 5.9.0.
--                 && ! file_exists( get_template_directory() . "/index.php" )
--         ) then
--                 // Invalid.
--         end; elseif ( ! file_exists( get_template_directory() . "/style.css" ) ) then
--                 // Invalid.
--         end; elseif ( is_child_theme() && ! file_exists( get_stylesheet_directory() . "/style.css" ) ) then
--                 // Invalid.
--         end; else then
--                 // Valid.
--                 return true;
--         end;

--         default = wp_get_theme( WP_DEFAULT_THEME );
--         if ( default.exists() ) then
--                 switch_theme( WP_DEFAULT_THEME );
--                 return false;
--         end;

--         --
--         -- If we"re in an invalid state but WP_DEFAULT_THEME doesn"t exist,
--         -- switch to the latest core default theme that"s installed.
--         --
--         -- If it turns out that this latest core default theme is our current
--         -- theme, then there"s nothing we can do about that, so we have to bail,
--         -- rather than going into an infinite loop. (This is why there are
--         -- checks against WP_DEFAULT_THEME above, also.) We also can"t do anything
--         -- if it turns out there is no default theme installed. (That"s `false`.)
--         --
--         default = WP_Theme::get_core_default_theme();
--         if ( false === default || get_stylesheet() == default.get_stylesheet() ) then
--                 return true;
--         end;

--         switch_theme( default.get_stylesheet() );
--         return false;
-- end;

-- --
-- -- Validates the theme requirements for WordPress version and PHP version.
-- --
-- -- Uses the information from `Requires at least` and `Requires PHP` headers
-- -- defined in the theme"s `style.css` file.
-- --
-- -- @since 5.5.0
-- -- @since 5.8.0 Removed support for using `readme.txt` as a fallback.
-- --
-- -- @param string stylesheet Directory name for the theme.
-- -- @return true|WP_Error True if requirements are met, WP_Error on failure.
-- --
-- function validate_theme_requirements( stylesheet ) then
--         theme = wp_get_theme( stylesheet );

--         requirements = array(
--                 "requires"     => ! empty( theme.get( "RequiresWP" ) ) ? theme.get( "RequiresWP" ) : "",
--                 "requires_php" => ! empty( theme.get( "RequiresPHP" ) ) ? theme.get( "RequiresPHP" ) : "",
--         );

--         compatible_wp  = is_wp_version_compatible( requirements["requires"] );
--         compatible_php = is_php_version_compatible( requirements["requires_php"] );

--         if ( ! compatible_wp && ! compatible_php ) then
--                 return new WP_Error(
--                         "theme_wp_php_incompatible",
--                         sprintf(
--                                 /* translators: %s: Theme name.--
--                                 _x( "<strong>Error:</strong> Current WordPress and PHP versions do not meet minimum requirements for %s.", "theme" ),
--                                 theme.display( "Name" )
--                         )
--                 );
--         end; elseif ( ! compatible_php ) then
--                 return new WP_Error(
--                         "theme_php_incompatible",
--                         sprintf(
--                                 /* translators: %s: Theme name.--
--                                 _x( "<strong>Error:</strong> Current PHP version does not meet minimum requirements for %s.", "theme" ),
--                                 theme.display( "Name" )
--                         )
--                 );
--         end; elseif ( ! compatible_wp ) then
--                 return new WP_Error(
--                         "theme_wp_incompatible",
--                         sprintf(
--                                 /* translators: %s: Theme name.--
--                                 _x( "<strong>Error:</strong> Current WordPress version does not meet minimum requirements for %s.", "theme" ),
--                                 theme.display( "Name" )
--                         )
--                 );
--         end;

--         return true;
-- end;

-- --
-- -- Retrieves all theme modifications.
-- --
-- -- @since 3.1.0
-- -- @since 5.9.0 The return value is always an array.
-- --
-- -- @return array Theme modifications.
-- --
-- function get_theme_mods() then
--         theme_slug = get_option( "stylesheet" );
--         mods       = get_option( "theme_mods_theme_slug" );

--         if ( false === mods ) then
--                 theme_name = get_option( "current_theme" );
--                 if ( false === theme_name ) then
--                         theme_name = wp_get_theme().get( "Name" );
--                 end;

--                 mods = get_option( "mods_theme_name" ); // Deprecated location.
--                 if ( is_admin() && false !== mods ) then
--                         update_option( "theme_mods_theme_slug", mods );
--                         delete_option( "mods_theme_name" );
--                 end;
--         end;

--         if ( ! is_array( mods ) ) then
--                 mods = array();
--         end;

--         return mods;
-- end;

-- --
-- -- Retrieves theme modification value for the active theme.
-- --
-- -- If the modification name does not exist and `default` is a string, then the
-- -- default will be passed through the {@link https://www.php.net/sprintf sprintf()}
-- -- PHP function with the template directory URI as the first value and the
-- -- stylesheet directory URI as the second value.
-- --
-- -- @since 2.1.0
-- --
-- -- @param string name    Theme modification name.
-- -- @param mixed  default Optional. Theme modification default value. Default false.
-- -- @return mixed Theme modification value.
-- --
-- function get_theme_mod( name, default = false ) then
--         mods = get_theme_mods();

--         if ( isset( mods[ name ] ) ) then
--                 --
--                 -- Filters the theme modification, or "theme_mod", value.
--                 --
--                 -- The dynamic portion of the hook name, `name`, refers to the key name
--                 -- of the modification array. For example, "header_textcolor", "header_image",
--                 -- and so on depending on the theme options.
--                 --
--                 -- @since 2.2.0
--                 --
--                 -- @param mixed current_mod The value of the active theme modification.
--                 --
--                 return apply_filters( "theme_mod_thennameend;", mods[ name ] );
--         end;

--         if ( is_string( default ) ) then
--                 // Only run the replacement if an sprintf() string format pattern was found.
--                 if ( preg_match( "#(?<!%)%(?:\d+\?)?s#", default ) ) then
--                         // Remove a single trailing percent sign.
--                         default = preg_replace( "#(?<!%)%#", "", default );
--                         default = sprintf( default, get_template_directory_uri(), get_stylesheet_directory_uri() );
--                 end;
--         end;

--         -- This filter is documented in wp-includes/theme.php--
--         return apply_filters( "theme_mod_thennameend;", default );
-- end;

-- --
-- -- Updates theme modification value for the active theme.
-- --
-- -- @since 2.1.0
-- -- @since 5.6.0 A return value was added.
-- --
-- -- @param string name  Theme modification name.
-- -- @param mixed  value Theme modification value.
-- -- @return bool True if the value was updated, false otherwise.
-- --
-- function set_theme_mod( name, value ) then
--         mods      = get_theme_mods();
--         old_value = isset( mods[ name ] ) ? mods[ name ] : false;

--         --
--         -- Filters the theme modification, or "theme_mod", value on save.
--         --
--         -- The dynamic portion of the hook name, `name`, refers to the key name
--         -- of the modification array. For example, "header_textcolor", "header_image",
--         -- and so on depending on the theme options.
--         --
--         -- @since 3.9.0
--         --
--         -- @param mixed value     The new value of the theme modification.
--         -- @param mixed old_value The current value of the theme modification.
--         --
--         mods[ name ] = apply_filters( "pre_set_theme_mod_thennameend;", value, old_value );

--         theme = get_option( "stylesheet" );

--         return update_option( "theme_mods_theme", mods );
-- end;

-- --
-- -- Removes theme modification name from active theme list.
-- --
-- -- If removing the name also removes all elements, then the entire option
-- -- will be removed.
-- --
-- -- @since 2.1.0
-- --
-- -- @param string name Theme modification name.
-- --
-- function remove_theme_mod( name ) then
--         mods = get_theme_mods();

--         if ( ! isset( mods[ name ] ) ) then
--                 return;
--         end;

--         unset( mods[ name ] );

--         if ( empty( mods ) ) then
--                 remove_theme_mods();
--                 return;
--         end;

--         theme = get_option( "stylesheet" );

--         update_option( "theme_mods_theme", mods );
-- end;

-- --
-- -- Removes theme modifications option for the active theme.
-- --
-- -- @since 2.1.0
-- --
-- function remove_theme_mods() then
--         delete_option( "theme_mods_" . get_option( "stylesheet" ) );

--         // Old style.
--         theme_name = get_option( "current_theme" );
--         if ( false === theme_name ) then
--                 theme_name = wp_get_theme().get( "Name" );
--         end;

--         delete_option( "mods_" . theme_name );
-- end;

-- --
-- -- Retrieves the custom header text color in 3- or 6-digit hexadecimal form.
-- --
-- -- @since 2.1.0
-- --
-- -- @return string Header text color in 3- or 6-digit hexadecimal form (minus the hash symbol).
-- --
-- function get_header_textcolor() then
--         return get_theme_mod( "header_textcolor", get_theme_support( "custom-header", "default-text-color" ) );
-- end;

-- --
-- -- Displays the custom header text color in 3- or 6-digit hexadecimal form (minus the hash symbol).
-- --
-- -- @since 2.1.0
-- --
-- function header_textcolor() then
--         echo get_header_textcolor();
-- end;

-- --
-- -- Whether to display the header text.
-- --
-- -- @since 3.4.0
-- --
-- -- @return bool
-- --
-- function display_header_text() then
--         if ( ! current_theme_supports( "custom-header", "header-text" ) ) then
--                 return false;
--         end;

--         text_color = get_theme_mod( "header_textcolor", get_theme_support( "custom-header", "default-text-color" ) );
--         return "blank" !== text_color;
-- end;

-- --
-- -- Checks whether a header image is set or not.
-- --
-- -- @since 4.2.0
-- --
-- -- @see get_header_image()
-- --
-- -- @return bool Whether a header image is set or not.
-- --
-- function has_header_image() then
--         return (bool) get_header_image();
-- end;

-- --
-- -- Retrieves header image for custom header.
-- --
-- -- @since 2.1.0
-- --
-- -- @return string|false
-- --
-- function get_header_image() then
--         url = get_theme_mod( "header_image", get_theme_support( "custom-header", "default-image" ) );

--         if ( "remove-header" === url ) then
--                 return false;
--         end;

--         if ( is_random_header_image() ) then
--                 url = get_random_header_image();
--         end;

--         --
--         -- Filters the header image URL.
--         --
--         -- @since 6.1.0
--         --
--         -- @param string url Header image URL.
--         --
--         url = apply_filters( "get_header_image", url );

--         if ( ! is_string( url ) ) then
--                 return false;
--         end;

--         url = trim( url );
--         return sanitize_url( set_url_scheme( url ) );
-- end;

-- --
-- -- Creates image tag markup for a custom header image.
-- --
-- -- @since 4.4.0
-- --
-- -- @param array attr Optional. Additional attributes for the image tag. Can be used
-- --                              to override the default attributes. Default empty.
-- -- @return string HTML image element markup or empty string on failure.
-- --
-- function get_header_image_tag( attr = array() ) then
--         header      = get_custom_header();
--         header.url = get_header_image();

--         if ( ! header.url ) then
--                 return "";
--         end;

--         width  = absint( header.width );
--         height = absint( header.height );
--         alt    = "";

--         // Use alternative text assigned to the image, if available. Otherwise, leave it empty.
--         if ( ! empty( header.attachment_id ) ) then
--                 image_alt = get_post_meta( header.attachment_id, "_wp_attachment_image_alt", true );

--                 if ( is_string( image_alt ) ) then
--                         alt = image_alt;
--                 end;
--         end;

--         attr = wp_parse_args(
--                 attr,
--                 array(
--                         "src"    => header.url,
--                         "width"  => width,
--                         "height" => height,
--                         "alt"    => alt,
--                 )
--         );

--         // Generate "srcset" and "sizes" if not already present.
--         if ( empty( attr["srcset"] ) && ! empty( header.attachment_id ) ) then
--                 image_meta = get_post_meta( header.attachment_id, "_wp_attachment_metadata", true );
--                 size_array = array( width, height );

--                 if ( is_array( image_meta ) ) then
--                         srcset = wp_calculate_image_srcset( size_array, header.url, image_meta, header.attachment_id );

--                         if ( ! empty( attr["sizes"] ) ) then
--                                 sizes = attr["sizes"];
--                         end; else then
--                                 sizes = wp_calculate_image_sizes( size_array, header.url, image_meta, header.attachment_id );
--                         end;

--                         if ( srcset && sizes ) then
--                                 attr["srcset"] = srcset;
--                                 attr["sizes"]  = sizes;
--                         end;
--                 end;
--         end;

--         --
--         -- Filters the list of header image attributes.
--         --
--         -- @since 5.9.0
--         --
--         -- @param array  attr   Array of the attributes for the image tag.
--         -- @param object header The custom header object returned by "get_custom_header()".
--         --
--         attr = apply_filters( "get_header_image_tag_attributes", attr, header );

--         attr = array_map( "esc_attr", attr );
--         html = "<img";

--         foreach ( attr as name => value ) then
--                 html .= " " . name . "="" . value . """;
--         end;

--         html .= " />";

--         --
--         -- Filters the markup of header images.
--         --
--         -- @since 4.4.0
--         --
--         -- @param string html   The HTML image tag markup being filtered.
--         -- @param object header The custom header object returned by "get_custom_header()".
--         -- @param array  attr   Array of the attributes for the image tag.
--         --
--         return apply_filters( "get_header_image_tag", html, header, attr );
-- end;

-- --
-- -- Displays the image markup for a custom header image.
-- --
-- -- @since 4.4.0
-- --
-- -- @param array attr Optional. Attributes for the image markup. Default empty.
-- --
-- function the_header_image_tag( attr = array() ) then
--         echo get_header_image_tag( attr );
-- end;

-- --
-- -- Gets random header image data from registered images in theme.
-- --
-- -- @since 3.4.0
-- --
-- -- @access private
-- --
-- -- @global array _wp_default_headers
-- --
-- -- @return object
-- --
-- function _get_random_header_data() then
--         global _wp_default_headers;
--         static _wp_random_header = null;

--         if ( empty( _wp_random_header ) ) then
--                 header_image_mod = get_theme_mod( "header_image", "" );
--                 headers          = array();

--                 if ( "random-uploaded-image" === header_image_mod ) then
--                         headers = get_uploaded_header_images();
--                 end; elseif ( ! empty( _wp_default_headers ) ) then
--                         if ( "random-default-image" === header_image_mod ) then
--                                 headers = _wp_default_headers;
--                         end; else then
--                                 if ( current_theme_supports( "custom-header", "random-default" ) ) then
--                                         headers = _wp_default_headers;
--                                 end;
--                         end;
--                 end;

--                 if ( empty( headers ) ) then
--                         return new stdClass;
--                 end;

--                 _wp_random_header = (object) headers[ array_rand( headers ) ];

--                 _wp_random_header.url = sprintf(
--                         _wp_random_header.url,
--                         get_template_directory_uri(),
--                         get_stylesheet_directory_uri()
--                 );

--                 _wp_random_header.thumbnail_url = sprintf(
--                         _wp_random_header.thumbnail_url,
--                         get_template_directory_uri(),
--                         get_stylesheet_directory_uri()
--                 );
--         end;

--         return _wp_random_header;
-- end;

-- --
-- -- Gets random header image URL from registered images in theme.
-- --
-- -- @since 3.2.0
-- --
-- -- @return string Path to header image.
-- --
-- function get_random_header_image() then
--         random_image = _get_random_header_data();

--         if ( empty( random_image.url ) ) then
--                 return "";
--         end;

--         return random_image.url;
-- end;

-- --
-- -- Checks if random header image is in use.
-- --
-- -- Always true if user expressly chooses the option in Appearance > Header.
-- -- Also true if theme has multiple header images registered, no specific header image
-- -- is chosen, and theme turns on random headers with add_theme_support().
-- --
-- -- @since 3.2.0
-- --
-- -- @param string type The random pool to use. Possible values include "any",
-- --                     "default", "uploaded". Default "any".
-- -- @return bool
-- --
-- function is_random_header_image( type = "any" ) then
--         header_image_mod = get_theme_mod( "header_image", get_theme_support( "custom-header", "default-image" ) );

--         if ( "any" === type ) then
--                 if ( "random-default-image" === header_image_mod
--                         || "random-uploaded-image" === header_image_mod
--                         || ( "" !== get_random_header_image() && empty( header_image_mod ) )
--                 ) then
--                         return true;
--                 end;
--         end; else then
--                 if ( "random-type-image" === header_image_mod ) then
--                         return true;
--                 end; elseif ( "default" === type && empty( header_image_mod ) && "" !== get_random_header_image() ) then
--                         return true;
--                 end;
--         end;

--         return false;
-- end;

-- --
-- -- Displays header image URL.
-- --
-- -- @since 2.1.0
-- --
-- function header_image() then
--         image = get_header_image();

--         if ( image ) then
--                 echo esc_url( image );
--         end;
-- end;

-- --
-- -- Gets the header images uploaded for the active theme.
-- --
-- -- @since 3.2.0
-- --
-- -- @return array
-- --
-- function get_uploaded_header_images() then
--         header_images = array();

--         // @todo Caching.
--         headers = get_posts(
--                 array(
--                         "post_type"  => "attachment",
--                         "meta_key"   => "_wp_attachment_is_custom_header",
--                         "meta_value" => get_option( "stylesheet" ),
--                         "orderby"    => "none",
--                         "nopaging"   => true,
--                 )
--         );

--         if ( empty( headers ) ) then
--                 return array();
--         end;

--         foreach ( (array) headers as header ) then
--                 url          = sanitize_url( wp_get_attachment_url( header.ID ) );
--                 header_data  = wp_get_attachment_metadata( header.ID );
--                 header_index = header.ID;

--                 header_images[ header_index ]                  = array();
--                 header_images[ header_index ]["attachment_id"] = header.ID;
--                 header_images[ header_index ]["url"]           = url;
--                 header_images[ header_index ]["thumbnail_url"] = url;
--                 header_images[ header_index ]["alt_text"]      = get_post_meta( header.ID, "_wp_attachment_image_alt", true );

--                 if ( isset( header_data["attachment_parent"] ) ) then
--                         header_images[ header_index ]["attachment_parent"] = header_data["attachment_parent"];
--                 end; else then
--                         header_images[ header_index ]["attachment_parent"] = "";
--                 end;

--                 if ( isset( header_data["width"] ) ) then
--                         header_images[ header_index ]["width"] = header_data["width"];
--                 end;
--                 if ( isset( header_data["height"] ) ) then
--                         header_images[ header_index ]["height"] = header_data["height"];
--                 end;
--         end;

--         return header_images;
-- end;

-- --
-- -- Gets the header image data.
-- --
-- -- @since 3.4.0
-- --
-- -- @global array _wp_default_headers
-- --
-- -- @return object
-- --
-- function get_custom_header() then
--         global _wp_default_headers;

--         if ( is_random_header_image() ) then
--                 data = _get_random_header_data();
--         end; else then
--                 data = get_theme_mod( "header_image_data" );
--                 if ( ! data && current_theme_supports( "custom-header", "default-image" ) ) then
--                         directory_args        = array( get_template_directory_uri(), get_stylesheet_directory_uri() );
--                         data                  = array();
--                         data["url"]           = vsprintf( get_theme_support( "custom-header", "default-image" ), directory_args );
--                         data["thumbnail_url"] = data["url"];
--                         if ( ! empty( _wp_default_headers ) ) then
--                                 foreach ( (array) _wp_default_headers as default_header ) then
--                                         url = vsprintf( default_header["url"], directory_args );
--                                         if ( data["url"] == url ) then
--                                                 data                  = default_header;
--                                                 data["url"]           = url;
--                                                 data["thumbnail_url"] = vsprintf( data["thumbnail_url"], directory_args );
--                                                 break;
--                                         end;
--                                 end;
--                         end;
--                 end;
--         end;

--         default = array(
--                 "url"           => "",
--                 "thumbnail_url" => "",
--                 "width"         => get_theme_support( "custom-header", "width" ),
--                 "height"        => get_theme_support( "custom-header", "height" ),
--                 "video"         => get_theme_support( "custom-header", "video" ),
--         );
--         return (object) wp_parse_args( data, default );
-- end;

-- --
-- -- Registers a selection of default headers to be displayed by the custom header admin UI.
-- --
-- -- @since 3.0.0
-- --
-- -- @global array _wp_default_headers
-- --
-- -- @param array headers Array of headers keyed by a string ID. The IDs point to arrays
-- --                       containing "url", "thumbnail_url", and "description" keys.
-- --
-- function register_default_headers( headers ) then
--         global _wp_default_headers;

--         _wp_default_headers = array_merge( (array) _wp_default_headers, (array) headers );
-- end;

-- --
-- -- Unregisters default headers.
-- --
-- -- This function must be called after register_default_headers() has already added the
-- -- header you want to remove.
-- --
-- -- @see register_default_headers()
-- -- @since 3.0.0
-- --
-- -- @global array _wp_default_headers
-- --
-- -- @param string|array header The header string id (key of array) to remove, or an array thereof.
-- -- @return bool|void A single header returns true on success, false on failure.
-- --                   There is currently no return value for multiple headers.
-- --
-- function unregister_default_headers( header ) then
--         global _wp_default_headers;

--         if ( is_array( header ) ) then
--                 array_map( "unregister_default_headers", header );
--         end; elseif ( isset( _wp_default_headers[ header ] ) ) then
--                 unset( _wp_default_headers[ header ] );
--                 return true;
--         end; else then
--                 return false;
--         end;
-- end;

-- --
-- -- Checks whether a header video is set or not.
-- --
-- -- @since 4.7.0
-- --
-- -- @see get_header_video_url()
-- --
-- -- @return bool Whether a header video is set or not.
-- --
-- function has_header_video() then
--         return (bool) get_header_video_url();
-- end;

-- --
-- -- Retrieves header video URL for custom header.
-- --
-- -- Uses a local video if present, or falls back to an external video.
-- --
-- -- @since 4.7.0
-- --
-- -- @return string|false Header video URL or false if there is no video.
-- --
-- function get_header_video_url() then
--         id = absint( get_theme_mod( "header_video" ) );

--         if ( id ) then
--                 // Get the file URL from the attachment ID.
--                 url = wp_get_attachment_url( id );
--         end; else then
--                 url = get_theme_mod( "external_header_video" );
--         end;

--         --
--         -- Filters the header video URL.
--         --
--         -- @since 4.7.3
--         --
--         -- @param string url Header video URL, if available.
--         --
--         url = apply_filters( "get_header_video_url", url );

--         if ( ! id && ! url ) then
--                 return false;
--         end;

--         return sanitize_url( set_url_scheme( url ) );
-- end;

-- --
-- -- Displays header video URL.
-- --
-- -- @since 4.7.0
-- --
-- function the_header_video_url() then
--         video = get_header_video_url();

--         if ( video ) then
--                 echo esc_url( video );
--         end;
-- end;

-- --
-- -- Retrieves header video settings.
-- --
-- -- @since 4.7.0
-- --
-- -- @return array
-- --
-- function get_header_video_settings() then
--         header     = get_custom_header();
--         video_url  = get_header_video_url();
--         video_type = wp_check_filetype( video_url, wp_get_mime_types() );

--         settings = array(
--                 "mimeType"  => "",
--                 "posterUrl" => get_header_image(),
--                 "videoUrl"  => video_url,
--                 "width"     => absint( header.width ),
--                 "height"    => absint( header.height ),
--                 "minWidth"  => 900,
--                 "minHeight" => 500,
--                 "l10n"      => array(
--                         "pause"      => __( "Pause" ),
--                         "play"       => __( "Play" ),
--                         "pauseSpeak" => __( "Video is paused." ),
--                         "playSpeak"  => __( "Video is playing." ),
--                 ),
--         );

--         if ( preg_match( "#^https?://(?:www\.)?(?:youtube\.com/watch|youtu\.be/)#", video_url ) ) then
--                 settings["mimeType"] = "video/x-youtube";
--         end; elseif ( ! empty( video_type["type"] ) ) then
--                 settings["mimeType"] = video_type["type"];
--         end;

--         --
--         -- Filters header video settings.
--         --
--         -- @since 4.7.0
--         --
--         -- @param array settings An array of header video settings.
--         --
--         return apply_filters( "header_video_settings", settings );
-- end;

-- --
-- -- Checks whether a custom header is set or not.
-- --
-- -- @since 4.7.0
-- --
-- -- @return bool True if a custom header is set. False if not.
-- --
-- function has_custom_header() then
--         if ( has_header_image() || ( has_header_video() && is_header_video_active() ) ) then
--                 return true;
--         end;

--         return false;
-- end;

-- --
-- -- Checks whether the custom header video is eligible to show on the current page.
-- --
-- -- @since 4.7.0
-- --
-- -- @return bool True if the custom header video should be shown. False if not.
-- --
-- function is_header_video_active() then
--         if ( ! get_theme_support( "custom-header", "video" ) ) then
--                 return false;
--         end;

--         video_active_cb = get_theme_support( "custom-header", "video-active-callback" );

--         if ( empty( video_active_cb ) || ! is_callable( video_active_cb ) ) then
--                 show_video = true;
--         end; else then
--                 show_video = call_user_func( video_active_cb );
--         end;

--         --
--         -- Filters whether the custom header video is eligible to show on the current page.
--         --
--         -- @since 4.7.0
--         --
--         -- @param bool show_video Whether the custom header video should be shown. Returns the value
--         --                         of the theme setting for the `custom-header`"s `video-active-callback`.
--         --                         If no callback is set, the default value is that of `is_front_page()`.
--         --
--         return apply_filters( "is_header_video_active", show_video );
-- end;

-- --
-- -- Retrieves the markup for a custom header.
-- --
-- -- The container div will always be returned in the Customizer preview.
-- --
-- -- @since 4.7.0
-- --
-- -- @return string The markup for a custom header on success.
-- --
-- function get_custom_header_markup() then
--         if ( ! has_custom_header() && ! is_customize_preview() ) then
--                 return "";
--         end;

--         return sprintf(
--                 "<div id="wp-custom-header" class="wp-custom-header">%s</div>",
--                 get_header_image_tag()
--         );
-- end;

-- --
-- -- Prints the markup for a custom header.
-- --
-- -- A container div will always be printed in the Customizer preview.
-- --
-- -- @since 4.7.0
-- --
-- function the_custom_header_markup() then
--         custom_header = get_custom_header_markup();
--         if ( empty( custom_header ) ) then
--                 return;
--         end;

--         echo custom_header;

--         if ( is_header_video_active() && ( has_header_video() || is_customize_preview() ) ) then
--                 wp_enqueue_script( "wp-custom-header" );
--                 wp_localize_script( "wp-custom-header", "_wpCustomHeaderSettings", get_header_video_settings() );
--         end;
-- end;

-- --
-- -- Retrieves background image for custom background.
-- --
-- -- @since 3.0.0
-- --
-- -- @return string
-- --
-- function get_background_image() then
--         return get_theme_mod( "background_image", get_theme_support( "custom-background", "default-image" ) );
-- end;

-- --
-- -- Displays background image path.
-- --
-- -- @since 3.0.0
-- --
-- function background_image() then
--         echo get_background_image();
-- end;

-- --
-- -- Retrieves value for custom background color.
-- --
-- -- @since 3.0.0
-- --
-- -- @return string
-- --
-- function get_background_color() then
--         return get_theme_mod( "background_color", get_theme_support( "custom-background", "default-color" ) );
-- end;

-- --
-- -- Displays background color value.
-- --
-- -- @since 3.0.0
-- --
-- function background_color() then
--         echo get_background_color();
-- end;

-- --
-- -- Default custom background callback.
-- --
-- -- @since 3.0.0
-- --
-- function _custom_background_cb() then
--         // background is the saved custom image, or the default image.
--         background = set_url_scheme( get_background_image() );

--         // color is the saved custom color.
--         // A default has to be specified in style.css. It will not be printed here.
--         color = get_background_color();

--         if ( get_theme_support( "custom-background", "default-color" ) === color ) then
--                 color = false;
--         end;

--         type_attr = current_theme_supports( "html5", "style" ) ? "" : " type="text/css"";

--         if ( ! background && ! color ) then
--                 if ( is_customize_preview() ) then
--                         printf( "<style%s id="custom-background-css"></style>", type_attr );
--                 end;
--                 return;
--         end;

--         style = color ? "background-color: #color;" : "";

--         if ( background ) then
--                 image = " background-image: url("" . sanitize_url( background ) . "");";

--                 // Background Position.
--                 position_x = get_theme_mod( "background_position_x", get_theme_support( "custom-background", "default-position-x" ) );
--                 position_y = get_theme_mod( "background_position_y", get_theme_support( "custom-background", "default-position-y" ) );

--                 if ( ! in_array( position_x, array( "left", "center", "right" ), true ) ) then
--                         position_x = "left";
--                 end;

--                 if ( ! in_array( position_y, array( "top", "center", "bottom" ), true ) ) then
--                         position_y = "top";
--                 end;

--                 position = " background-position: position_x position_y;";

--                 // Background Size.
--                 size = get_theme_mod( "background_size", get_theme_support( "custom-background", "default-size" ) );

--                 if ( ! in_array( size, array( "auto", "contain", "cover" ), true ) ) then
--                         size = "auto";
--                 end;

--                 size = " background-size: size;";

--                 // Background Repeat.
--                 repeat = get_theme_mod( "background_repeat", get_theme_support( "custom-background", "default-repeat" ) );

--                 if ( ! in_array( repeat, array( "repeat-x", "repeat-y", "repeat", "no-repeat" ), true ) ) then
--                         repeat = "repeat";
--                 end;

--                 repeat = " background-repeat: repeat;";

--                 // Background Scroll.
--                 attachment = get_theme_mod( "background_attachment", get_theme_support( "custom-background", "default-attachment" ) );

--                 if ( "fixed" !== attachment ) then
--                         attachment = "scroll";
--                 end;

--                 attachment = " background-attachment: attachment;";

--                 style .= image . position . size . repeat . attachment;
--         end;
--         ?>
-- <style<?php echo type_attr; ?> id="custom-background-css">
-- body.custom-background then <?php echo trim( style ); ?> end;
-- </style>
--         <?php
-- end;

-- --
-- -- Renders the Custom CSS style element.
-- --
-- -- @since 4.7.0
-- --
-- function wp_custom_css_cb() then
--         styles = wp_get_custom_css();
--         if ( styles || is_customize_preview() ) :
--                 type_attr = current_theme_supports( "html5", "style" ) ? "" : " type="text/css"";
--                 ?>
--                 <style<?php echo type_attr; ?> id="wp-custom-css">
--                         <?php
--                         // Note that esc_html() cannot be used because `div &gt; span` is not interpreted properly.
--                         echo strip_tags( styles );
--                         ?>
--                 </style>
--                 <?php
--         endif;
-- end;

-- --
-- -- Fetches the `custom_css` post for a given theme.
-- --
-- -- @since 4.7.0
-- --
-- -- @param string stylesheet Optional. A theme object stylesheet name. Defaults to the active theme.
-- -- @return WP_Post|null The custom_css post or null if none exists.
-- --
-- function wp_get_custom_css_post( stylesheet = "" ) then
--         if ( empty( stylesheet ) ) then
--                 stylesheet = get_stylesheet();
--         end;

--         custom_css_query_vars = array(
--                 "post_type"              => "custom_css",
--                 "post_status"            => get_post_stati(),
--                 "name"                   => sanitize_title( stylesheet ),
--                 "posts_per_page"         => 1,
--                 "no_found_rows"          => true,
--                 "cache_results"          => true,
--                 "update_post_meta_cache" => false,
--                 "update_post_term_cache" => false,
--                 "lazy_load_term_meta"    => false,
--         );

--         post = null;
--         if ( get_stylesheet() === stylesheet ) then
--                 post_id = get_theme_mod( "custom_css_post_id" );

--                 if ( post_id > 0 && get_post( post_id ) ) then
--                         post = get_post( post_id );
--                 end;

--                 // `-1` indicates no post exists; no query necessary.
--                 if ( ! post && -1 !== post_id ) then
--                         query = new WP_Query( custom_css_query_vars );
--                         post  = query.post;
--                         /*
--                         -- Cache the lookup. See wp_update_custom_css_post().
--                         -- @todo This should get cleared if a custom_css post is added/removed.
--                         --
--                         set_theme_mod( "custom_css_post_id", post ? post.ID : -1 );
--                 end;
--         end; else then
--                 query = new WP_Query( custom_css_query_vars );
--                 post  = query.post;
--         end;

--         return post;
-- end;

-- --
-- -- Fetches the saved Custom CSS content for rendering.
-- --
-- -- @since 4.7.0
-- --
-- -- @param string stylesheet Optional. A theme object stylesheet name. Defaults to the active theme.
-- -- @return string The Custom CSS Post content.
-- --
-- function wp_get_custom_css( stylesheet = "" ) then
--         css = "";

--         if ( empty( stylesheet ) ) then
--                 stylesheet = get_stylesheet();
--         end;

--         post = wp_get_custom_css_post( stylesheet );
--         if ( post ) then
--                 css = post.post_content;
--         end;

--         --
--         -- Filters the custom CSS output into the head element.
--         --
--         -- @since 4.7.0
--         --
--         -- @param string css        CSS pulled in from the Custom CSS post type.
--         -- @param string stylesheet The theme stylesheet name.
--         --
--         css = apply_filters( "wp_get_custom_css", css, stylesheet );

--         return css;
-- end;

-- --
-- -- Updates the `custom_css` post for a given theme.
-- --
-- -- Inserts a `custom_css` post when one doesn"t yet exist.
-- --
-- -- @since 4.7.0
-- --
-- -- @param string css CSS, stored in `post_content`.
-- -- @param array  args then
-- --     Args.
-- --
-- --     @type string preprocessed Optional. Pre-processed CSS, stored in `post_content_filtered`.
-- --                                Normally empty string.
-- --     @type string stylesheet   Optional. Stylesheet (child theme) to update.
-- --                                Defaults to active theme/stylesheet.
-- -- end;
-- -- @return WP_Post|WP_Error Post on success, error on failure.
-- --
-- function wp_update_custom_css_post( css, args = array() ) then
--         args = wp_parse_args(
--                 args,
--                 array(
--                         "preprocessed" => "",
--                         "stylesheet"   => get_stylesheet(),
--                 )
--         );

--         data = array(
--                 "css"          => css,
--                 "preprocessed" => args["preprocessed"],
--         );

--         --
--         -- Filters the `css` (`post_content`) and `preprocessed` (`post_content_filtered`) args
--         -- for a `custom_css` post being updated.
--         --
--         -- This filter can be used by plugin that offer CSS pre-processors, to store the original
--         -- pre-processed CSS in `post_content_filtered` and then store processed CSS in `post_content`.
--         -- When used in this way, the `post_content_filtered` should be supplied as the setting value
--         -- instead of `post_content` via a the `customize_value_custom_css` filter, for example:
--         --
--         -- <code>
--         -- add_filter( "customize_value_custom_css", function( value, setting ) then
--         --     post = wp_get_custom_css_post( setting.stylesheet );
--         --     if ( post && ! empty( post.post_content_filtered ) ) then
--         --         css = post.post_content_filtered;
--         --     end;
--         --     return css;
--         -- end;, 10, 2 );
--         -- </code>
--         --
--         -- @since 4.7.0
--         -- @param array data then
--         --     Custom CSS data.
--         --
--         --     @type string css          CSS stored in `post_content`.
--         --     @type string preprocessed Pre-processed CSS stored in `post_content_filtered`.
--         --                                Normally empty string.
--         -- end;
--         -- @param array args then
--         --     The args passed into `wp_update_custom_css_post()` merged with defaults.
--         --
--         --     @type string css          The original CSS passed in to be updated.
--         --     @type string preprocessed The original preprocessed CSS passed in to be updated.
--         --     @type string stylesheet   The stylesheet (theme) being updated.
--         -- end;
--         --
--         data = apply_filters( "update_custom_css_data", data, array_merge( args, compact( "css" ) ) );

--         post_data = array(
--                 "post_title"            => args["stylesheet"],
--                 "post_name"             => sanitize_title( args["stylesheet"] ),
--                 "post_type"             => "custom_css",
--                 "post_status"           => "publish",
--                 "post_content"          => data["css"],
--                 "post_content_filtered" => data["preprocessed"],
--         );

--         // Update post if it already exists, otherwise create a new one.
--         post = wp_get_custom_css_post( args["stylesheet"] );
--         if ( post ) then
--                 post_data["ID"] = post.ID;
--                 r               = wp_update_post( wp_slash( post_data ), true );
--         end; else then
--                 r = wp_insert_post( wp_slash( post_data ), true );

--                 if ( ! is_wp_error( r ) ) then
--                         if ( get_stylesheet() === args["stylesheet"] ) then
--                                 set_theme_mod( "custom_css_post_id", r );
--                         end;

--                         // Trigger creation of a revision. This should be removed once #30854 is resolved.
--                         revisions = wp_get_latest_revision_id_and_total_count( r );
--                         if ( ! is_wp_error( revisions ) && 0 === revisions["count"] ) then
--                                 wp_save_post_revision( r );
--                         end;
--                 end;
--         end;

--         if ( is_wp_error( r ) ) then
--                 return r;
--         end;
--         return get_post( r );
-- end;

-- --
-- -- Adds callback for custom TinyMCE editor stylesheets.
-- --
-- -- The parameter stylesheet is the name of the stylesheet, relative to
-- -- the theme root. It also accepts an array of stylesheets.
-- -- It is optional and defaults to "editor-style.css".
-- --
-- -- This function automatically adds another stylesheet with -rtl prefix, e.g. editor-style-rtl.css.
-- -- If that file doesn"t exist, it is removed before adding the stylesheet(s) to TinyMCE.
-- -- If an array of stylesheets is passed to add_editor_style(),
-- -- RTL is only added for the first stylesheet.
-- --
-- -- Since version 3.4 the TinyMCE body has .rtl CSS class.
-- -- It is a better option to use that class and add any RTL styles to the main stylesheet.
-- --
-- -- @since 3.0.0
-- --
-- -- @global array editor_styles
-- --
-- -- @param array|string stylesheet Optional. Stylesheet name or array thereof, relative to theme root.
-- --                                 Defaults to "editor-style.css"
-- --
-- function add_editor_style( stylesheet = "editor-style.css" ) then
--         global editor_styles;

--         add_theme_support( "editor-style" );

--         editor_styles = (array) editor_styles;
--         stylesheet    = (array) stylesheet;

--         if ( is_rtl() ) then
--                 rtl_stylesheet = str_replace( ".css", "-rtl.css", stylesheet[0] );
--                 stylesheet[]   = rtl_stylesheet;
--         end;

--         editor_styles = array_merge( editor_styles, stylesheet );
-- end;

-- --
-- -- Removes all visual editor stylesheets.
-- --
-- -- @since 3.1.0
-- --
-- -- @global array editor_styles
-- --
-- -- @return bool True on success, false if there were no stylesheets to remove.
-- --
-- function remove_editor_styles() then
--         if ( ! current_theme_supports( "editor-style" ) ) then
--                 return false;
--         end;
--         _remove_theme_support( "editor-style" );
--         if ( is_admin() ) then
--                 GLOBALS["editor_styles"] = array();
--         end;
--         return true;
-- end;

-- --
-- -- Retrieves any registered editor stylesheet URLs.
-- --
-- -- @since 4.0.0
-- --
-- -- @global array editor_styles Registered editor stylesheets
-- --
-- -- @return string[] If registered, a list of editor stylesheet URLs.
-- --
-- function get_editor_stylesheets() then
--         stylesheets = array();
--         // Load editor_style.css if the active theme supports it.
--         if ( ! empty( GLOBALS["editor_styles"] ) && is_array( GLOBALS["editor_styles"] ) ) then
--                 editor_styles = GLOBALS["editor_styles"];

--                 editor_styles = array_unique( array_filter( editor_styles ) );
--                 style_uri     = get_stylesheet_directory_uri();
--                 style_dir     = get_stylesheet_directory();

--                 // Support externally referenced styles (like, say, fonts).
--                 foreach ( editor_styles as key => file ) then
--                         if ( preg_match( "~^(https?:)?//~", file ) ) then
--                                 stylesheets[] = sanitize_url( file );
--                                 unset( editor_styles[ key ] );
--                         end;
--                 end;

--                 // Look in a parent theme first, that way child theme CSS overrides.
--                 if ( is_child_theme() ) then
--                         template_uri = get_template_directory_uri();
--                         template_dir = get_template_directory();

--                         foreach ( editor_styles as key => file ) then
--                                 if ( file && file_exists( "template_dir/file" ) ) then
--                                         stylesheets[] = "template_uri/file";
--                                 end;
--                         end;
--                 end;

--                 foreach ( editor_styles as file ) then
--                         if ( file && file_exists( "style_dir/file" ) ) then
--                                 stylesheets[] = "style_uri/file";
--                         end;
--                 end;
--         end;

--         --
--         -- Filters the array of URLs of stylesheets applied to the editor.
--         --
--         -- @since 4.3.0
--         --
--         -- @param string[] stylesheets Array of URLs of stylesheets to be applied to the editor.
--         --
--         return apply_filters( "editor_stylesheets", stylesheets );
-- end;

-- --
-- -- Expands a theme"s starter content configuration using core-provided data.
-- --
-- -- @since 4.7.0
-- --
-- -- @return array Array of starter content.
-- --
-- function get_theme_starter_content() then
--         theme_support = get_theme_support( "starter-content" );
--         if ( is_array( theme_support ) && ! empty( theme_support[0] ) && is_array( theme_support[0] ) ) then
--                 config = theme_support[0];
--         end; else then
--                 config = array();
--         end;

--         core_content = array(
--                 "widgets"   => array(
--                         "text_business_info" => array(
--                                 "text",
--                                 array(
--                                         "title"  => _x( "Find Us", "Theme starter content" ),
--                                         "text"   => implode(
--                                                 "",
--                                                 array(
--                                                         "<strong>" . _x( "Address", "Theme starter content" ) . "</strong>\n",
--                                                         _x( "123 Main Street", "Theme starter content" ) . "\n",
--                                                         _x( "New York, NY 10001", "Theme starter content" ) . "\n\n",
--                                                         "<strong>" . _x( "Hours", "Theme starter content" ) . "</strong>\n",
--                                                         _x( "Monday&ndash;Friday: 9:00AM&ndash;5:00PM", "Theme starter content" ) . "\n",
--                                                         _x( "Saturday &amp; Sunday: 11:00AM&ndash;3:00PM", "Theme starter content" ),
--                                                 )
--                                         ),
--                                         "filter" => true,
--                                         "visual" => true,
--                                 ),
--                         ),
--                         "text_about"         => array(
--                                 "text",
--                                 array(
--                                         "title"  => _x( "About This Site", "Theme starter content" ),
--                                         "text"   => _x( "This may be a good place to introduce yourself and your site or include some credits.", "Theme starter content" ),
--                                         "filter" => true,
--                                         "visual" => true,
--                                 ),
--                         ),
--                         "archives"           => array(
--                                 "archives",
--                                 array(
--                                         "title" => _x( "Archives", "Theme starter content" ),
--                                 ),
--                         ),
--                         "calendar"           => array(
--                                 "calendar",
--                                 array(
--                                         "title" => _x( "Calendar", "Theme starter content" ),
--                                 ),
--                         ),
--                         "categories"         => array(
--                                 "categories",
--                                 array(
--                                         "title" => _x( "Categories", "Theme starter content" ),
--                                 ),
--                         ),
--                         "meta"               => array(
--                                 "meta",
--                                 array(
--                                         "title" => _x( "Meta", "Theme starter content" ),
--                                 ),
--                         ),
--                         "recent-comments"    => array(
--                                 "recent-comments",
--                                 array(
--                                         "title" => _x( "Recent Comments", "Theme starter content" ),
--                                 ),
--                         ),
--                         "recent-posts"       => array(
--                                 "recent-posts",
--                                 array(
--                                         "title" => _x( "Recent Posts", "Theme starter content" ),
--                                 ),
--                         ),
--                         "search"             => array(
--                                 "search",
--                                 array(
--                                         "title" => _x( "Search", "Theme starter content" ),
--                                 ),
--                         ),
--                 ),
--                 "nav_menus" => array(
--                         "link_home"       => array(
--                                 "type"  => "custom",
--                                 "title" => _x( "Home", "Theme starter content" ),
--                                 "url"   => home_url( "/" ),
--                         ),
--                         "page_home"       => array( // Deprecated in favor of "link_home".
--                                 "type"      => "post_type",
--                                 "object"    => "page",
--                                 "object_id" => "thenthenhomeend;end;",
--                         ),
--                         "page_about"      => array(
--                                 "type"      => "post_type",
--                                 "object"    => "page",
--                                 "object_id" => "thenthenaboutend;end;",
--                         ),
--                         "page_blog"       => array(
--                                 "type"      => "post_type",
--                                 "object"    => "page",
--                                 "object_id" => "thenthenblogend;end;",
--                         ),
--                         "page_news"       => array(
--                                 "type"      => "post_type",
--                                 "object"    => "page",
--                                 "object_id" => "thenthennewsend;end;",
--                         ),
--                         "page_contact"    => array(
--                                 "type"      => "post_type",
--                                 "object"    => "page",
--                                 "object_id" => "thenthencontactend;end;",
--                         ),

--                         "link_email"      => array(
--                                 "title" => _x( "Email", "Theme starter content" ),
--                                 "url"   => "mailto:wordpress@example.com",
--                         ),
--                         "link_facebook"   => array(
--                                 "title" => _x( "Facebook", "Theme starter content" ),
--                                 "url"   => "https://www.facebook.com/wordpress",
--                         ),
--                         "link_foursquare" => array(
--                                 "title" => _x( "Foursquare", "Theme starter content" ),
--                                 "url"   => "https://foursquare.com/",
--                         ),
--                         "link_github"     => array(
--                                 "title" => _x( "GitHub", "Theme starter content" ),
--                                 "url"   => "https://github.com/wordpress/",
--                         ),
--                         "link_instagram"  => array(
--                                 "title" => _x( "Instagram", "Theme starter content" ),
--                                 "url"   => "https://www.instagram.com/explore/tags/wordcamp/",
--                         ),
--                         "link_linkedin"   => array(
--                                 "title" => _x( "LinkedIn", "Theme starter content" ),
--                                 "url"   => "https://www.linkedin.com/company/1089783",
--                         ),
--                         "link_pinterest"  => array(
--                                 "title" => _x( "Pinterest", "Theme starter content" ),
--                                 "url"   => "https://www.pinterest.com/",
--                         ),
--                         "link_twitter"    => array(
--                                 "title" => _x( "Twitter", "Theme starter content" ),
--                                 "url"   => "https://twitter.com/wordpress",
--                         ),
--                         "link_yelp"       => array(
--                                 "title" => _x( "Yelp", "Theme starter content" ),
--                                 "url"   => "https://www.yelp.com",
--                         ),
--                         "link_youtube"    => array(
--                                 "title" => _x( "YouTube", "Theme starter content" ),
--                                 "url"   => "https://www.youtube.com/channel/UCdof4Ju7amm1chz1gi1T2ZA",
--                         ),
--                 ),
--                 "posts"     => array(
--                         "home"             => array(
--                                 "post_type"    => "page",
--                                 "post_title"   => _x( "Home", "Theme starter content" ),
--                                 "post_content" => sprintf(
--                                         "<!-- wp:paragraph -.\n<p>%s</p>\n<!-- /wp:paragraph -.",
--                                         _x( "Welcome to your site! This is your homepage, which is what most visitors will see when they come to your site for the first time.", "Theme starter content" )
--                                 ),
--                         ),
--                         "about"            => array(
--                                 "post_type"    => "page",
--                                 "post_title"   => _x( "About", "Theme starter content" ),
--                                 "post_content" => sprintf(
--                                         "<!-- wp:paragraph -.\n<p>%s</p>\n<!-- /wp:paragraph -.",
--                                         _x( "You might be an artist who would like to introduce yourself and your work here or maybe you&rsquo;re a business with a mission to describe.", "Theme starter content" )
--                                 ),
--                         ),
--                         "contact"          => array(
--                                 "post_type"    => "page",
--                                 "post_title"   => _x( "Contact", "Theme starter content" ),
--                                 "post_content" => sprintf(
--                                         "<!-- wp:paragraph -.\n<p>%s</p>\n<!-- /wp:paragraph -.",
--                                         _x( "This is a page with some basic contact information, such as an address and phone number. You might also try a plugin to add a contact form.", "Theme starter content" )
--                                 ),
--                         ),
--                         "blog"             => array(
--                                 "post_type"  => "page",
--                                 "post_title" => _x( "Blog", "Theme starter content" ),
--                         ),
--                         "news"             => array(
--                                 "post_type"  => "page",
--                                 "post_title" => _x( "News", "Theme starter content" ),
--                         ),

--                         "homepage-section" => array(
--                                 "post_type"    => "page",
--                                 "post_title"   => _x( "A homepage section", "Theme starter content" ),
--                                 "post_content" => sprintf(
--                                         "<!-- wp:paragraph -.\n<p>%s</p>\n<!-- /wp:paragraph -.",
--                                         _x( "This is an example of a homepage section. Homepage sections can be any page other than the homepage itself, including the page that shows your latest blog posts.", "Theme starter content" )
--                                 ),
--                         ),
--                 ),
--         );

--         content = array();

--         foreach ( config as type => args ) then
--                 switch ( type ) then
--                         // Use options and theme_mods as-is.
--                         case "options":
--                         case "theme_mods":
--                                 content[ type ] = config[ type ];
--                                 break;

--                         // Widgets are grouped into sidebars.
--                         case "widgets":
--                                 foreach ( config[ type ] as sidebar_id => widgets ) then
--                                         foreach ( widgets as id => widget ) then
--                                                 if ( is_array( widget ) ) then

--                                                         // Item extends core content.
--                                                         if ( ! empty( core_content[ type ][ id ] ) ) then
--                                                                 widget = array(
--                                                                         core_content[ type ][ id ][0],
--                                                                         array_merge( core_content[ type ][ id ][1], widget ),
--                                                                 );
--                                                         end;

--                                                         content[ type ][ sidebar_id ][] = widget;
--                                                 end; elseif ( is_string( widget )
--                                                         && ! empty( core_content[ type ] )
--                                                         && ! empty( core_content[ type ][ widget ] )
--                                                 ) then
--                                                         content[ type ][ sidebar_id ][] = core_content[ type ][ widget ];
--                                                 end;
--                                         end;
--                                 end;
--                                 break;

--                         // And nav menu items are grouped into nav menus.
--                         case "nav_menus":
--                                 foreach ( config[ type ] as nav_menu_location => nav_menu ) then

--                                         // Ensure nav menus get a name.
--                                         if ( empty( nav_menu["name"] ) ) then
--                                                 nav_menu["name"] = nav_menu_location;
--                                         end;

--                                         content[ type ][ nav_menu_location ]["name"] = nav_menu["name"];

--                                         foreach ( nav_menu["items"] as id => nav_menu_item ) then
--                                                 if ( is_array( nav_menu_item ) ) then

--                                                         // Item extends core content.
--                                                         if ( ! empty( core_content[ type ][ id ] ) ) then
--                                                                 nav_menu_item = array_merge( core_content[ type ][ id ], nav_menu_item );
--                                                         end;

--                                                         content[ type ][ nav_menu_location ]["items"][] = nav_menu_item;
--                                                 end; elseif ( is_string( nav_menu_item )
--                                                         && ! empty( core_content[ type ] )
--                                                         && ! empty( core_content[ type ][ nav_menu_item ] )
--                                                 ) then
--                                                         content[ type ][ nav_menu_location ]["items"][] = core_content[ type ][ nav_menu_item ];
--                                                 end;
--                                         end;
--                                 end;
--                                 break;

--                         // Attachments are posts but have special treatment.
--                         case "attachments":
--                                 foreach ( config[ type ] as id => item ) then
--                                         if ( ! empty( item["file"] ) ) then
--                                                 content[ type ][ id ] = item;
--                                         end;
--                                 end;
--                                 break;

--                         // All that"s left now are posts (besides attachments).
--                         // Not a default case for the sake of clarity and future work.
--                         case "posts":
--                                 foreach ( config[ type ] as id => item ) then
--                                         if ( is_array( item ) ) then

--                                                 // Item extends core content.
--                                                 if ( ! empty( core_content[ type ][ id ] ) ) then
--                                                         item = array_merge( core_content[ type ][ id ], item );
--                                                 end;

--                                                 // Enforce a subset of fields.
--                                                 content[ type ][ id ] = wp_array_slice_assoc(
--                                                         item,
--                                                         array(
--                                                                 "post_type",
--                                                                 "post_title",
--                                                                 "post_excerpt",
--                                                                 "post_name",
--                                                                 "post_content",
--                                                                 "menu_order",
--                                                                 "comment_status",
--                                                                 "thumbnail",
--                                                                 "template",
--                                                         )
--                                                 );
--                                         end; elseif ( is_string( item ) && ! empty( core_content[ type ][ item ] ) ) then
--                                                 content[ type ][ item ] = core_content[ type ][ item ];
--                                         end;
--                                 end;
--                                 break;
--                 end;
--         end;

--         --
--         -- Filters the expanded array of starter content.
--         --
--         -- @since 4.7.0
--         --
--         -- @param array content Array of starter content.
--         -- @param array config  Array of theme-specific starter content configuration.
--         --
--         return apply_filters( "get_theme_starter_content", content, config );
-- end;

   -----------------------
   -- Add_Theme_Support --
   -----------------------

   -- Compatibility
   NO_HEADER_TEXT      : Boolean;
   HEADER_IMAGE_WIDTH  : Natural;
   HEADER_IMAGE_HEIGHT : Natural;
   HEADER_TEXTCOLOR    : UStrings.UString;
   HEADER_IMAGE        : UStrings.UString;
   BACKGROUND_COLOR    : UStrings.UString;
   BACKGROUND_IMAGE    : UStrings.UString;

   procedure Add_Theme_Support (Feature : String;
                                List    : List_Type  := Empty_List;
                                Arry    : Array_Type := Empty_Array) -- ...args
   is
      use Php.Arrays;
      use Php.Lists;
      use Php.Strings;
      use List_Vectors;
      use UStrings;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Plugins;
      use Inc_Post_Formats;

      Arry_2 : Array_Type;
      List_2 : List_Type;
      Args_2 : Boolean := False;
   begin
      if List.Is_Empty and Arry = Empty_Array then
         Args_2 := True;
      end if;

      if Feature = "post-thumbnails" then
         -- All post types are already supported.
         if not Get_Theme_Support ("post-thumbnails").Is_Empty then
            return;
         end if;

         --
         -- Merge post types with any that already declared their support
         -- for post thumbnails.
         --
         if
           Arry /= Empty_Array and then
--         Isset ( args[0]) and then
--         Is_Array (args[0]) and then
           Isset (Global_Wp_Theme_Features, "post-thumbnails")
         then
            Arry_2 :=
              Array_Unique (
                Array_Merge (As_Array (Get (
                  Global_Wp_Theme_Features, "post-thumbnails")), -- [0],
                  Arry));
--          args[0] := Array_Unique (Array_Merge (x_wp_theme_features["post-thumbnails"][0], args[0] ) );
         end if;

      elsif Feature = "post-formats" then
         if Arry /= Empty_Array then
--       if Isset ( args[0] ) and then is_array( args[0] ) ) then
            declare
               Post_Formats : constant List_Type := Get_Post_Format_Slugs;
            begin
--             Post_Formats.Delete ("standard");

               List_2 := List_Intersect (List, List_Keys (Post_Formats));
--             args[0] = array_intersect( args[0], array_keys( post_formats ) );
            end;
         else
            X_Doing_It_Wrong (
              "add_theme_support('post-formats')",
              abs "You need to pass an array of post formats.",
              "5.6.0"
            );
            raise Support_Error;
         end if;

      elsif Feature = "html5" then
         -- You can't just pass "html5", you need to pass an array of types.
         if List.Is_Empty then
--       if ( empty( args[0] ) || ! is_array( args[0] ) ) then
            X_Doing_It_Wrong (
              "add_theme_support('html5')",
              abs "You need to pass an array of types.",
              "3.6.1"
            );

            if List = Empty then
--          if ( ! empty( args[0] ) && ! is_array( args[0] ) ) then
               raise Support_Error;
            end if;

            -- Build an array of types for back-compat.
--          args = array( 0 => array("comment-list", "comment-form", "search-form"));
         end if;

         -- Calling "html5" again merges, rather than overwrites.
         if Isset (Global_Wp_Theme_Features, "html5") then
            Arry_2 :=
              Array_Merge (As_Array (Get (Global_Wp_Theme_Features, "html5")), -- [0],
                           Arry);
--          args[0] = array_merge( _wp_theme_features["html5"][0], args[0] );
         end if;

      elsif Feature = "custom-logo" then
         declare
            Defaults : constant Array_Type := To_Array (List => (
              Build ("width",                Null_Value),
              Build ("height",               Null_Value),
              Build ("flex-width",           False),
              Build ("flex-height",          False),
              Build ("header-text",          ""),
              Build ("unlink-homepage-logo", False)
            ));
            Args : constant Array_Type :=
              (if Args_2
               then Empty_Array
               else Arry);
         begin
            Arry_2 :=
              Wp_Parse_Args (Array_Intersect_Key (Args, Defaults), Defaults);
         end;

         -- Allow full flexibility if no size is specified.
         if
           not Isset (Arry_2, "width") and then -- is_null( args[0]["width"] )
           not Isset (Arry_2, "height") -- is_null( args[0]["height"] )
         then
            Set (Arry_2, "flex-width",  From_Boolean (True));
            Set (Arry_2, "flex-height", From_Boolean (True));
         end if;

      elsif Feature = "custom-header-uploads" then
         Add_Theme_Support ("custom-header",
                            Arry => To_Array (List => (1 =>
                              Build ("uploads", True))));
         return;

      elsif Feature = "custom-header" then
         declare
            Args : constant Array_Type :=
              (if Args_2
               then Empty_Array
               else Arry);

            Defaults : constant Array_Type := To_Array (List => (
              Build ("default-image",          ""),
              Build ("random-default",         False),
              Build ("width",                  0),
              Build ("height",                 0),
              Build ("flex-height",            False),
              Build ("flex-width",             False),
              Build ("default-text-color",     ""),
              Build ("header-text",            True),
              Build ("uploads",                True),
              Build ("wp-head-callback",       ""),
              Build ("admin-head-callback",    ""),
              Build ("admin-preview-callback", ""),
              Build ("video",                  False),
              Build ("video-active-callback",  "is_front_page")
            ));

            JIT : constant Boolean := Isset (Arry, "__jit");
         begin
--          unset( args[0]["__jit"] );

            -- Merge in data from previous add_theme_support() calls.
            -- The first value registered wins. (A child theme is set up first.)
            if Isset (Global_Wp_Theme_Features, "custom-header") then
               Arry_2 :=
                 Wp_Parse_Args (As_Array (Get (
                   Global_Wp_Theme_Features, "custom-header")), -- [0],
                   Arry);
            end if;

            -- Load in the defaults at the end, as we need to insure first one wins.
            -- This will cause all constants to be defined, as each arg will then be
            -- set to the default.
            if JIT then
               Arry_2 := Wp_Parse_Args (Arry_2, Defaults);
            end if;

            --
            -- If a constant was defined, use that value. Otherwise, define the
            -- constant to ensure the constant is always accurate (and is not defined
            -- later,  overriding our value).
            -- As stated above, the first value wins.
            -- Once we get to wp_loaded (just-in-time), define any constants we
            -- haven't already.
            -- Constants are lame. Don't reference them. This is just for backward
            -- compatibility.
            --
            if True then
               Set (Arry_2, "header-text", From_Boolean (not NO_HEADER_TEXT));
            elsif Isset (Arry, "header-text") then
               NO_HEADER_TEXT := Isset (Arry, "header-test");
               -- empty( args[0]["header-text"] );
            end if;

            if True then
               Set (Arry_2, "width", From_Integer (HEADER_IMAGE_WIDTH));
            elsif Isset (Arry, "width") then
               HEADER_IMAGE_WIDTH := As_Integer (Get (Arry, "width"));
            end if;

            if True then
               Set (Arry_2, "height", From_Integer (HEADER_IMAGE_HEIGHT));
            elsif Isset (Arry, "height") then
               HEADER_IMAGE_HEIGHT := As_Integer (Get (Arry, "height"));
            end if;

            if True then
               Set (Arry_2, "default-text-color", From_String (-HEADER_TEXTCOLOR));
            elsif Isset (Arry, "default-text-color") then
               HEADER_TEXTCOLOR := +Get_As_String (Arry, "default-text-color");
            end if;

            if True then
               Set (Arry_2, "default-image", From_String (-HEADER_IMAGE));
            elsif Isset (Arry, "default-image") then
               HEADER_IMAGE := +Get_As_String (Arry, "default-image");
            end if;

            if JIT and then not Empty (Arry, "default-image") then
               Set (Arry_2, "random-default", From_Boolean (False));
            end if;

            -- If headers are supported, and we still don't have a defined width or
            -- height, we have implicit flex sizes.
            if JIT then
               if
                 not Isset (Arry_2, "width") and then
                 not Isset (Arry_2, "flex-width")
               then
                  Set (Arry_2, "flex-width", From_Boolean (True));
               end if;

               if
                 not Isset (Arry_2, "height") and then
                 not Isset (Arry_2, "flex-height")
               then
                  Set (Arry_2, "flex-height", From_Boolean (True));
               end if;
            end if;
         end;

      elsif Feature = "custom-background" then
         declare
            Args : constant Array_Type :=
              (if Args_2 then Empty_Array else Arry);

            Defaults : constant Array_Type := To_Array (List => (
              Build ("default-image",          ""),
              Build ("default-preset",         "default"),
              Build ("default-position-x",     "left"),
              Build ("default-position-y",     "top"),
              Build ("default-size",           "auto"),
              Build ("default-repeat",         "repeat"),
              Build ("default-attachment",     "scroll"),
              Build ("default-color",          ""),
              Build ("wp-head-callback",       "_custom_background_cb"),
              Build ("admin-head-callback",    ""),
              Build ("admin-preview-callback", "")
            ));

            JIT : constant Boolean := Isset (Arry, "__jit");
         begin
--          unset( args[0]["__jit"] );

            -- Merge in data from previous add_theme_support() calls. The first
            -- value registered wins.
            if Isset (Global_Wp_Theme_Features, "custom-background") then
               Arry_2 :=
                 Wp_Parse_Args (As_Array (Get (
                   Global_Wp_Theme_Features, "custom-background")),
                   Arry);
            end if;

            if JIT then
               Arry_2 := Wp_Parse_Args (Arry_2, Defaults);
            end if;

            if True then
               Set (Arry_2, "default-color", From_String (-BACKGROUND_COLOR));
            elsif Isset (Arry, "default-color") or JIT then
               BACKGROUND_COLOR := +Get_As_String (Arry, "default-color");
            end if;

            if True then
               Set (Arry_2, "default-image", From_String (-BACKGROUND_IMAGE));
            elsif Isset (Arry, "default-image") or JIT then
               BACKGROUND_IMAGE := +Get_As_String (Arry, "default-image");
            end if;
         end;

      -- Ensure that "title-tag" is accessible in the admin.
      elsif Feature = "title-tag" then
         -- Can be called in functions.php but must happen before wp_loaded, i.e.
         -- not in header.php.
         if Did_Action ("wp_loaded") then
            X_Doing_It_Wrong (
              "add_theme_support('title-tag')",
              Sprintf (
                -- translators: 1: title-tag, 2: wp_loaded
                abs "Theme support for %1s should be registered before the %2s hook.",
                [
                  1 => "<code>title-tag</code>",
                  2 => "<code>wp_loaded</code>"
                ]),
                "4.1.0"
            );
            raise Support_Error;
         end if;
      end if;

      Set (Global_Wp_Theme_Features, Feature, From_Array (Arry_2));
   end Add_Theme_Support;

-- --
-- -- Registers the internal custom header and background routines.
-- --
-- -- @since 3.4.0
-- -- @access private
-- --
-- -- @global Custom_Image_Header custom_image_header
-- -- @global Custom_Background   custom_background
-- --
-- function _custom_header_background_just_in_time() then
--         global custom_image_header, custom_background;

--         if ( current_theme_supports( "custom-header" ) ) then
--                 // In elsif Feature = any constants were defined after an add_custom_image_header() call, re-run.
--                 add_theme_support( "custom-header", array( "__jit" => true ) );

--                 args = get_theme_support( "custom-header" );
--                 if ( args[0]["wp-head-callback"] ) then
--                         add_action( "wp_head", args[0]["wp-head-callback"] );
--                 end;

--                 if ( is_admin() ) then
--                         require_once ABSPATH . "wp-admin/includes/class-custom-image-header.php";
--                         custom_image_header = new Custom_Image_Header( args[0]["admin-head-callback"], args[0]["admin-preview-callback"] );
--                 end;
--         end;

--         if ( current_theme_supports( "custom-background" ) ) then
--                 // In elsif Feature = any constants were defined after an add_custom_background() call, re-run.
--                 add_theme_support( "custom-background", array( "__jit" => true ) );

--                 args = get_theme_support( "custom-background" );
--                 add_action( "wp_head", args[0]["wp-head-callback"] );

--                 if ( is_admin() ) then
--                         require_once ABSPATH . "wp-admin/includes/class-custom-background.php";
--                         custom_background = new Custom_Background( args[0]["admin-head-callback"], args[0]["admin-preview-callback"] );
--                 end;
--         end;
-- end;

   ---------------------------------
   -- X_Custom_Logo_Header_Styles --
   ---------------------------------

   procedure X_Custom_Logo_Header_Styles
   is
      use Php.Echoing;
      use Php.Lists;
      use Php.Strings;
      use List_Vectors;
      use UStrings;
      use Inc_Formatting;
   begin
      if
        not Current_Theme_Supports ("custom-header", "header-text")   and then
        not Get_Theme_Support ("custom-logo", "header-text").Is_Empty and then
        0 = Get_Theme_Mod ("header_text", True)
      then
         declare
            Classes_3 : constant List_Type :=
              Get_Theme_Support ("custom-logo", "header-text"); -- (array)

            Classes_2 : constant List_Type :=
              List_Map (Sanitize_HTML_Class'Access, Classes_3);

            Classes : constant String := "." & Implode (", .", Classes_2);

            Type_Attr : constant String :=
              (if Current_Theme_Supports ("html5", "style")
               then "" else " type=""text/css""");
         begin
            Echo ("<!-- Custom Logo: hide header text -->" & NL);
            Echo ("<style id=""custom-logo-css""" & Type_Attr & ">" & NL);
            Echo ("    " & Classes & " {" & NL);
            Echo ("        position: absolute;" & NL);
            Echo ("        clip: rect(1px, 1px, 1px, 1px);" & NL);
            Echo ("    }"    & NL);
            Echo ("</style>" & NL);
         end;
      end if;
   end X_Custom_Logo_Header_Styles;

-- --
-- -- Gets the theme support arguments passed when registering that support.
-- --
-- -- Example usage:
-- --
-- --     get_theme_support( "custom-logo" );
-- --     get_theme_support( "custom-header", "width" );
-- --
-- -- @since 3.1.0
-- -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
-- --              by adding it to the function signature.
-- --
-- -- @global array _wp_theme_features
-- --
-- -- @param string feature The feature to check. See add_theme_support() for the list
-- --                        of possible values.
-- -- @param mixed  ...args Optional extra arguments to be checked against certain features.
-- -- @return mixed The array of extra arguments or the value for the registered feature.
-- --
-- function get_theme_support( feature, ...args ) then
--         global _wp_theme_features;

--         if ( ! isset( _wp_theme_features[ feature ] ) ) then
--                 return false;
--         end;

--         if ( ! args ) then
--                 return _wp_theme_features[ feature ];
--         end;

--         switch ( feature ) then
--                 elsif Feature = "custom-logo":
--                 elsif Feature = "custom-header":
--                 elsif Feature = "custom-background":
--                         if ( isset( _wp_theme_features[ feature ][0][ args[0] ] ) ) then
--                                 return _wp_theme_features[ feature ][0][ args[0] ];
--                         end;
--                         return false;

--                 default:
--                         return _wp_theme_features[ feature ];
--         end;
-- end;

-- --
-- -- Allows a theme to de-register its support of a certain feature
-- --
-- -- Should be called in the theme"s functions.php file. Generally would
-- -- be used for child themes to override support from the parent theme.
-- --
-- -- @since 3.0.0
-- --
-- -- @see add_theme_support()
-- --
-- -- @param string feature The feature being removed. See add_theme_support() for the list
-- --                        of possible values.
-- -- @return bool|void Whether feature was removed.
-- --
-- function remove_theme_support( feature ) then
--         // Do not remove internal registrations that are not used directly by themes.
--         if ( in_array( feature, array( "editor-style", "widgets", "menus" ), true ) ) then
--                 return false;
--         end;

--         return _remove_theme_support( feature );
-- end;

-- --
-- -- Do not use. Removes theme support internally without knowledge of those not used
-- -- by themes directly.
-- --
-- -- @access private
-- -- @since 3.1.0
-- -- @global array               _wp_theme_features
-- -- @global Custom_Image_Header custom_image_header
-- -- @global Custom_Background   custom_background
-- --
-- -- @param string feature The feature being removed. See add_theme_support() for the list
-- --                        of possible values.
-- -- @return bool True if support was removed, false if the feature was not registered.
-- --
-- function _remove_theme_support( feature ) then
--         global _wp_theme_features;

--         switch ( feature ) then
--                 elsif Feature = "custom-header-uploads":
--                         if ( ! isset( _wp_theme_features["custom-header"] ) ) then
--                                 return false;
--                         end;
--                         add_theme_support( "custom-header", array( "uploads" => false ) );
--                         return; // Do not continue - custom-header-uploads no longer exists.
--         end;

--         if ( ! isset( _wp_theme_features[ feature ] ) ) then
--                 return false;
--         end;

--         switch ( feature ) then
--                 elsif Feature = "custom-header":
--                         if ( ! did_action( "wp_loaded" ) ) then
--                                 break;
--                         end;
--                         support = get_theme_support( "custom-header" );
--                         if ( isset( support[0]["wp-head-callback"] ) ) then
--                                 remove_action( "wp_head", support[0]["wp-head-callback"] );
--                         end;
--                         if ( isset( GLOBALS["custom_image_header"] ) ) then
--                                 remove_action( "admin_menu", array( GLOBALS["custom_image_header"], "init" ) );
--                                 unset( GLOBALS["custom_image_header"] );
--                         end;
--                         break;

--                 elsif Feature = "custom-background":
--                         if ( ! did_action( "wp_loaded" ) ) then
--                                 break;
--                         end;
--                         support = get_theme_support( "custom-background" );
--                         if ( isset( support[0]["wp-head-callback"] ) ) then
--                                 remove_action( "wp_head", support[0]["wp-head-callback"] );
--                         end;
--                         remove_action( "admin_menu", array( GLOBALS["custom_background"], "init" ) );
--                         unset( GLOBALS["custom_background"] );
--                         break;
--         end;

--         unset( _wp_theme_features[ feature ] );

--         return true;
-- end;

-- --
-- -- Checks a theme"s support for a given feature.
-- --
-- -- Example usage:
-- --
-- --     current_theme_supports( "custom-logo" );
-- --     current_theme_supports( "html5", "comment-form" );
-- --
-- -- @since 2.9.0
-- -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
-- --              by adding it to the function signature.
-- --
-- -- @global array _wp_theme_features
-- --
-- -- @param string feature The feature being checked. See add_theme_support() for the list
-- --                        of possible values.
-- -- @param mixed  ...args Optional extra arguments to be checked against certain features.
-- -- @return bool True if the active theme supports the feature, false otherwise.
-- --
-- function current_theme_supports( feature, ...args ) then
--         global _wp_theme_features;

--         if ( "custom-header-uploads" === feature ) then
--                 return current_theme_supports( "custom-header", "uploads" );
--         end;

--         if ( ! isset( _wp_theme_features[ feature ] ) ) then
--                 return false;
--         end;

--         // If no args passed then no extra checks need to be performed.
--         if ( ! args ) then
--                 -- This filter is documented in wp-includes/theme.php--
--                 return apply_filters( "current_theme_supports-thenfeatureend;", true, args, _wp_theme_features[ feature ] ); // phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
--         end;

--         switch ( feature ) then
--                 elsif Feature = "post-thumbnails":
--                         /*
--                         -- post-thumbnails can be registered for only certain content/post types
--                         -- by passing an array of types to add_theme_support().
--                         -- If no array was passed, then any type is accepted.
--                         --
--                         if ( true === _wp_theme_features[ feature ] ) then  // Registered for all types.
--                                 return true;
--                         end;
--                         content_type = args[0];
--                         return in_array( content_type, _wp_theme_features[ feature ][0], true );

--                 elsif Feature = "html5":
--                 elsif Feature = "post-formats":
--                         /*
--                         -- Specific post formats can be registered by passing an array of types
--                         -- to add_theme_support().
--                         --
--                         -- Specific areas of HTML5 support--must* be passed via an array to add_theme_support().
--                         --
--                         type = args[0];
--                         return in_array( type, _wp_theme_features[ feature ][0], true );

--                 elsif Feature = "custom-logo":
--                 elsif Feature = "custom-header":
--                 elsif Feature = "custom-background":
--                         // Specific capabilities can be registered by passing an array to add_theme_support().
--                         return ( isset( _wp_theme_features[ feature ][0][ args[0] ] ) && _wp_theme_features[ feature ][0][ args[0] ] );
--         end;

--         --
--         -- Filters whether the active theme supports a specific feature.
--         --
--         -- The dynamic portion of the hook name, `feature`, refers to the specific
--         -- theme feature. See add_theme_support() for the list of possible values.
--         --
--         -- @since 3.4.0
--         --
--         -- @param bool   supports Whether the active theme supports the given feature. Default true.
--         -- @param array  args     Array of arguments for the feature.
--         -- @param string feature  The theme feature.
--         --
--         return apply_filters( "current_theme_supports-thenfeatureend;", true, args, _wp_theme_features[ feature ] ); // phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
-- end;

-- --
-- -- Checks a theme"s support for a given feature before loading the functions which implement it.
-- --
-- -- @since 2.9.0
-- --
-- -- @param string feature The feature being checked. See add_theme_support() for the list
-- --                        of possible values.
-- -- @param string include Path to the file.
-- -- @return bool True if the active theme supports the supplied feature, false otherwise.
-- --
-- function require_if_theme_supports( feature, include ) then
--         if ( current_theme_supports( feature ) ) then
--                 require include;
--                 return true;
--         end;
--         return false;
-- end;

   Global_Wp_Registered_Theme_Features : Array_Type;

   ----------------------------
   -- Register_Theme_Feature --
   ----------------------------

   procedure Register_Theme_Feature (Feature : String;
                                     Args    : Array_Type)
   is
      use Php.Arrays;
      use Php.Lists;
      use Php.Strings;
      use Inc_Functions;
      use Inc_REST_API;

      Defaults : constant Array_Type := To_Array (List => (
                Build ("type",         "boolean"),
                Build ("variadic",     False),
                Build ("description",  ""),
                Build ("show_in_rest", False)
      ));

      Args_2 : Array_Type := Wp_Parse_Args (Args, Defaults);
   begin
      -- if ( ! is_array( _wp_registered_theme_features ) ) then
      --    _wp_registered_theme_features = array();
      -- end if;

      if True = As_Boolean (Get (Args_2, "show_in_rest")) then
         Set (Args_2, "show_in_rest", From_Array (Empty_Array));
      end if;

      if Kind_Of (Get (Args_2, "show_in_rest")) in Kind_Array then
         Set (Args_2,
              "show_in_rest",
              From_Array (
                Wp_Parse_Args (
                  As_Array (Get (Args_2, "show_in_rest")),
                  To_Array (List => (
                    Build ("schema",           Empty_Array),
                    Build ("name",             Feature),
                    Build ("prepare_callback", Null_Value)
                  ))
              )));
      end if;

      if
        not In_List (Get_As_String (Args_2, "type"),
                     List_Type'["string", "boolean", "integer",
                                "number", "array", "object"], True)
      then
         raise Feature_Error with "invalid_type";
         -- return new WP_Error(
         --   "invalid_type",
         --   __( "The feature "type" is not valid JSON Schema type." )
         -- );
      end if;

      if
        True = As_Boolean (Get (Args_2, "variadic")) and then
        "array" /= Get_As_String (Args_2, "type")
      then
         raise Feature_Error with "variadic_must_be_array";
         -- return new WP_Error(
         --   "variadic_must_be_array",
         --   __( "When registering a "variadic" theme feature, the "type" must be an "array"." )
         -- );
      end if;

      if
        False /= As_Boolean (Get (Args_2, "show_in_rest")) and then
        In_List (Get_As_String (Args_2, "type"),
                            List_Type'["array", "object"], True)
      then
         if
           Kind_Of (Get (Args_2, "show_in_rest")) not in Kind_Array or else
           Empty (As_String (Get (Ref_2 (Args_2, "show_in_rest", "schema"))))
         then
            raise Feature_Error with "missing_schema";
            -- return new WP_Error(
            --   "missing_schema",
            --   __( "When registering an 'array' or 'object' feature to show in the REST API, the feature\'s schema must also be defined." )
            -- );
         end if;

         if
           "array" = Get_As_String (Args_2, "type") and then
           not Isset_3 (Args_2, "show_in_rest", "schema", "items")
         then
            raise Feature_Error with "missing_schema_items";
            -- return new WP_Error(
            --   "missing_schema_items",
            --   __( "When registering an 'array' feature, the feature\'s schema must include the 'items' keyword." )
            -- );
         end if;

         if
           "object" = Get_As_String (Args_2, "type") and then
           not Isset_3 (Args_2, "show_in_rest", "schema", "properties")
         then
            raise Feature_Error with "missing_schema_properties";
            -- return new WP_Error(
            --   "missing_schema_properties",
            --   __( "When registering an 'object' feature, the feature\'s schema must include the 'properties' keyword." )
            -- );
         end if;
      end if;

      if Kind_Of (Get (Args_2, "show_in_rest")) in Kind_Array then
         if
           Isset_2 (Args_2, "show_in_rest", "prepare_callback") and then
           Kind_Of (Get (Ref_2 (Args_2, "show_in_rest", "prepare_callback")))
             not in Kind_Callable
         then
            raise Feature_Error with "invalid_rest_prepare_callback";
            -- return new WP_Error(
            --   "invalid_rest_prepare_callback",
            --   sprintf(
            --     /* translators: %s: prepare_callback--
            --     __( "The "%s" must be a callable function." ),
            --     "prepare_callback"
            --   )
            -- );
         end if;

         Set_2 (Args_2,
                Key_1 => "show_in_rest",
                Key_2 => "schema",
                Value =>
                  From_Array (Wp_Parse_Args (
                    As_Array (Get (Ref_2 (Args_2, "show_in_rest", "schema"))),
                    To_Array (List => (
                      Build ("description", Get_As_String (Args_2, "description")),
                      Build ("type",        Get_As_String (Args_2, "type")),
                      Build ("default",     False)
                    ))
                  )));

         if
           Kind_Of (Get (Ref_3 (Args_2, "show_in_rest", "schema", "default")))
             in Kind_Boolean and then
           not In_Array ("boolean",
                         As_Array (Get (Ref_3 (Args_2, Key_1 => "show_in_rest",
                                                       Key_2 => "schema",
                                                       Key_3 => "type"))), True)
         then
            -- Automatically include the "boolean" type when the default value is
            -- a boolean.
            Set_3 (Args_2,
                   Key_1 => "show_in_rest",
                   Key_2 => "schema",
                   Key_3 => "type",
                   Value =>
                     Get (Ref_3 (Args_2, "show_in_rest", "schema", "type")));

--          Array_Unshift (Ref_3 (Args_2, "show_in_rest", "schema", "type"),
--                         "boolean");
         end if;

         Set_2 (Args_2,
                Key_1 => "show_in_rest",
                Key_2 => "schema",
                Value => From_Array (
                  REST_Default_Additional_Properties_To_False (
                    As_Array (Get (Ref_2 (Args_2,
                                          Key_1 => "show_in_rest",
                                          Key_2 => "schema"))))));
      end if;

      Set (Global_Wp_Registered_Theme_Features, Feature, From_Array (Args_2));

   end Register_Theme_Feature;

-- --
-- -- Gets the list of registered theme features.
-- --
-- -- @since 5.5.0
-- --
-- -- @global array _wp_registered_theme_features
-- --
-- -- @return array[] List of theme features, keyed by their name.
-- --
-- function get_registered_theme_features() then
--         global _wp_registered_theme_features;

--         if ( ! is_array( _wp_registered_theme_features ) ) then
--                 return array();
--         end;

--         return _wp_registered_theme_features;
-- end;

-- --
-- -- Gets the registration config for a theme feature.
-- --
-- -- @since 5.5.0
-- --
-- -- @global array _wp_registered_theme_features
-- --
-- -- @param string feature The feature name. See add_theme_support() for the list
-- --                        of possible values.
-- -- @return array|null The registration args, or null if the feature was not registered.
-- --
-- function get_registered_theme_feature( feature ) then
--         global _wp_registered_theme_features;

--         if ( ! is_array( _wp_registered_theme_features ) ) then
--                 return null;
--         end;

--         return isset( _wp_registered_theme_features[ feature ] ) ? _wp_registered_theme_features[ feature ] : null;
-- end;

-- --
-- -- Checks an attachment being deleted to see if it"s a header or background image.
-- --
-- -- If true it removes the theme modification which would be pointing at the deleted
-- -- attachment.
-- --
-- -- @access private
-- -- @since 3.0.0
-- -- @since 4.3.0 Also removes `header_image_data`.
-- -- @since 4.5.0 Also removes custom logo theme mods.
-- --
-- -- @param int id The attachment ID.
-- --
-- function _delete_attachment_theme_mod( id ) then
--         attachment_image = wp_get_attachment_url( id );
--         header_image     = get_header_image();
--         background_image = get_background_image();
--         custom_logo_id   = get_theme_mod( "custom_logo" );

--         if ( custom_logo_id && custom_logo_id == id ) then
--                 remove_theme_mod( "custom_logo" );
--                 remove_theme_mod( "header_text" );
--         end;

--         if ( header_image && header_image == attachment_image ) then
--                 remove_theme_mod( "header_image" );
--                 remove_theme_mod( "header_image_data" );
--         end;

--         if ( background_image && background_image == attachment_image ) then
--                 remove_theme_mod( "background_image" );
--         end;
-- end;

-- --
-- -- Checks if a theme has been changed and runs "after_switch_theme" hook on the next WP load.
-- --
-- -- See {@see "after_switch_theme"}.
-- --
-- -- @since 3.3.0
-- --
-- function check_theme_switched() then
--         stylesheet = get_option( "theme_switched" );

--         if ( stylesheet ) then
--                 old_theme = wp_get_theme( stylesheet );

--                 // Prevent widget & menu mapping from running since Customizer already called it up front.
--                 if ( get_option( "theme_switched_via_customizer" ) ) then
--                         remove_action( "after_switch_theme", "_wp_menus_changed" );
--                         remove_action( "after_switch_theme", "_wp_sidebars_changed" );
--                         update_option( "theme_switched_via_customizer", false );
--                 end;

--                 if ( old_theme.exists() ) then
--                         --
--                         -- Fires on the first WP load after a theme switch if the old theme still exists.
--                         --
--                         -- This action fires multiple times and the parameters differs
--                         -- according to the context, if the old theme exists or not.
--                         -- If the old theme is missing, the parameter will be the slug
--                         -- of the old theme.
--                         --
--                         -- @since 3.3.0
--                         --
--                         -- @param string   old_name  Old theme name.
--                         -- @param WP_Theme old_theme WP_Theme instance of the old theme.
--                         --
--                         do_action( "after_switch_theme", old_theme.get( "Name" ), old_theme );
--                 end; else then
--                         -- This action is documented in wp-includes/theme.php--
--                         do_action( "after_switch_theme", stylesheet, old_theme );
--                 end;

--                 flush_rewrite_rules();

--                 update_option( "theme_switched", false );
--         end;
-- end;

   ----------------------------
   -- X_Wp_Customize_Include --
   ----------------------------

   procedure X_Wp_Customize_Include
   is
      use Php.Arrays;
      use Php.Files;
      use Php.Strings;
      use Binder;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Load;

      Is_Customize_Admin_Page : constant Boolean :=
        Is_Admin and then
        "customize.php" = Basename (Get_As_String (X_SERVER, "PHP_SELF"));

      Should_Include : constant Boolean :=
        Is_Customize_Admin_Page or else
        (Isset (X_REQUEST, "wp_customize") and then
         "on" = Get_As_String (X_REQUEST, "wp_customize")) or else
        (not Empty (XX_GET, "customize_changeset_uuid") or else
--      (not Empty (Get_As_String (X_GET, "customize_changeset_uuid")) or else
         not Empty (X_POST, "customize_changeset_uuid"));
--       not Empty (Get_As_String (X_POST, "customize_changeset_uuid")));
   begin
      if not Should_Include then
         return;
      end if;

      --
      -- Note that wp_unslash() is not being used on the input vars because it is
      -- called before wp_magic_quotes() gets called. Besides this fact, none of
      -- the values should contain any characters needing slashes anyway.
      --
      declare
         Keys : constant List_Type :=
           [
             "changeset_uuid",
             "customize_changeset_uuid",
             "customize_theme",
             "theme",
             "customize_messenger_channel",
             "customize_autosaved"
           ];

         Input_Vars : constant Array_Type :=
           Array_Merge (
             Wp_Array_Slice_Assoc (XX_GET, Keys),
             Wp_Array_Slice_Assoc (X_POST, Keys)
           );

         -- Value false indicates UUID should be determined after_setup_theme
         -- to either re-use existing saved changeset or else generate a new UUID
         -- if none exists.
         Changeset_UUID : constant String :=
           (if
             Is_Customize_Admin_Page and then
             Isset (Input_Vars, "changeset_uuid")
           then
              Sanitize_Key (Get_As_String (Input_Vars, "changeset_uuid"))
           elsif
             not Empty (Get_As_String (Input_Vars, "customize_changeset_uuid"))
           then
              Sanitize_Key (Get_As_String (Input_Vars, "customize_changeset_uuid"))
           else "");

         -- Note that theme will be sanitized via WP_Theme.
         Theme : constant String :=
           (if
              Is_Customize_Admin_Page and then
              Isset (Input_Vars, "theme")
            then
               Get_As_String (Input_Vars, "theme")
            elsif Isset (Input_Vars, "customize_theme") then
               Get_As_String (Input_Vars, "customize_theme")
            else "");

         Autosaved : constant Boolean :=
           (if not Empty (Input_Vars, "customize_autosaved")
            then True
            else False);

         Messenger_Channel : constant String :=
           (if Isset (Input_Vars, "customize_messenger_channel")
            then Sanitize_Key
                    (Get_As_String (Input_Vars, "customize_messenger_channel"))
            else "");

         -- Set initially fo false since defaults to true for back-compat;
         -- can be overridden via the customize_changeset_branching filter.
         Branching : constant Boolean := False;

         --
         -- Note that settings must be previewed even outside the customizer preview
         -- and also in the customizer pane itself. This is to enable loading an
         -- existing changeset into the customizer. Previewing the settings only has
         -- to be prevented here in the case of a customize_save action because this
         -- will cause WP to think there is nothing changed that needs to be saved.
         --
         Is_Customize_Save_Action : constant Boolean := (
            Wp_Doing_AJAX
            and then
            Isset (X_REQUEST, "action")
            and then
            "customize_save" = Wp_Unslash (Get_As_String (X_REQUEST, "action"))
         );

         Settings_Previewed : constant Boolean := not Is_Customize_Save_Action;

         Comp : constant Array_Type := To_Array (List => (
--         Compact (
           Build ("changeset_uuid",     Changeset_UUID),
           Build ("theme",              Theme),
           Build ("messenger_channel",  Messenger_Channel),
           Build ("settings_previewed", Settings_Previewed),
           Build ("autosaved",          Autosaved),
           Build ("branching",          Branching)
         ));
      begin
--       require_once ABSPATH . WPINC . "/class-wp-customize-manager.php";
         null;
--       Set (Globals.GLOBALS, "wp_customize",
--            Class_Customize_Managers.X_Construct (Comp));
      end;
   end X_Wp_Customize_Include;

-- --
-- -- Publishes a snapshot"s changes.
-- --
-- -- @since 4.7.0
-- -- @access private
-- --
-- -- @global wpdb                 wpdb         WordPress database abstraction object.
-- -- @global WP_Customize_Manager wp_customize Customizer instance.
-- --
-- -- @param string  new_status     New post status.
-- -- @param string  old_status     Old post status.
-- -- @param WP_Post changeset_post Changeset post object.
-- --
-- function _wp_customize_publish_changeset( new_status, old_status, changeset_post ) then
--         global wp_customize, wpdb;

--         is_publishing_changeset = (
--                 "customize_changeset" === changeset_post.post_type
--                 &&
--                 "publish" === new_status
--                 &&
--                 "publish" !== old_status
--         );
--         if ( ! is_publishing_changeset ) then
--                 return;
--         end;

--         if ( empty( wp_customize ) ) then
--                 require_once ABSPATH . WPINC . "/class-wp-customize-manager.php";
--                 wp_customize = new WP_Customize_Manager(
--                         array(
--                                 "changeset_uuid"     => changeset_post.post_name,
--                                 "settings_previewed" => false,
--                         )
--                 );
--         end;

--         if ( ! did_action( "customize_register" ) ) then
--                 /*
--                 -- When running from CLI or Cron, the customize_register action will need
--                 -- to be triggered in order for core, themes, and plugins to register their
--                 -- settings. Normally core will add_action( "customize_register" ) at
--                 -- priority 10 to register the core settings, and if any themes/plugins
--                 -- also add_action( "customize_register" ) at the same priority, they
--                 -- will have a wp_customize with those settings registered since they
--                 -- call add_action() afterward, normally. However, when manually doing
--                 -- the customize_register action after the setup_theme, then the order
--                 -- will be reversed for two actions added at priority 10, resulting in
--                 -- the core settings no longer being available as expected to themes/plugins.
--                 -- So the following manually calls the method that registers the core
--                 -- settings up front before doing the action.
--                 --
--                 remove_action( "customize_register", array( wp_customize, "register_controls" ) );
--                 wp_customize.register_controls();

--                 -- This filter is documented in /wp-includes/class-wp-customize-manager.php--
--                 do_action( "customize_register", wp_customize );
--         end;
--         wp_customize._publish_changeset_values( changeset_post.ID );

--         /*
--         -- Trash the changeset post if revisions are not enabled. Unpublished
--         -- changesets by default get garbage collected due to the auto-draft status.
--         -- When a changeset post is published, however, it would no longer get cleaned
--         -- out. This is a problem when the changeset posts are never displayed anywhere,
--         -- since they would just be endlessly piling up. So here we use the revisions
--         -- feature to indicate whether or not a published changeset should get trashed
--         -- and thus garbage collected.
--         --
--         if ( ! wp_revisions_enabled( changeset_post ) ) then
--                 wp_customize.trash_changeset_post( changeset_post.ID );
--         end;
-- end;

-- --
-- -- Filters changeset post data upon insert to ensure post_name is intact.
-- --
-- -- This is needed to prevent the post_name from being dropped when the post is
-- -- transitioned into pending status by a contributor.
-- --
-- -- @since 4.7.0
-- --
-- -- @see wp_insert_post()
-- --
-- -- @param array post_data          An array of slashed post data.
-- -- @param array supplied_post_data An array of sanitized, but otherwise unmodified post data.
-- -- @return array Filtered data.
-- --
-- function _wp_customize_changeset_filter_insert_post_data( post_data, supplied_post_data ) then
--         if ( isset( post_data["post_type"] ) && "customize_changeset" === post_data["post_type"] ) then

--                 // Prevent post_name from being dropped, such as when contributor saves a changeset post as pending.
--                 if ( empty( post_data["post_name"] ) && ! empty( supplied_post_data["post_name"] ) ) then
--                         post_data["post_name"] = supplied_post_data["post_name"];
--                 end;
--         end;
--         return post_data;
-- end;

-- --
-- -- Adds settings for the customize-loader script.
-- --
-- -- @since 3.4.0
-- --
-- function _wp_customize_loader_settings() then
--         admin_origin = parse_url( admin_url() );
--         home_origin  = parse_url( home_url() );
--         cross_domain = ( strtolower( admin_origin["host"] ) != strtolower( home_origin["host"] ) );

--         browser = array(
--                 "mobile" => wp_is_mobile(),
--                 "ios"    => wp_is_mobile() && preg_match( "/iPad|iPod|iPhone/", _SERVER["HTTP_USER_AGENT"] ),
--         );

--         settings = array(
--                 "url"           => esc_url( admin_url( "customize.php" ) ),
--                 "isCrossDomain" => cross_domain,
--                 "browser"       => browser,
--                 "l10n"          => array(
--                         "saveAlert"       => __( "The changes you made will be lost if you navigate away from this page." ),
--                         "mainIframeTitle" => __( "Customizer" ),
--                 ),
--         );

--         script = "var _wpCustomizeLoaderSettings = " . wp_json_encode( settings ) . ";";

--         wp_scripts = wp_scripts();
--         data       = wp_scripts.get_data( "customize-loader", "data" );
--         if ( data ) then
--                 script = "data\nscript";
--         end;

--         wp_scripts.add_data( "customize-loader", "data", script );
-- end;

-- --
-- -- Returns a URL to load the Customizer.
-- --
-- -- @since 3.4.0
-- --
-- -- @param string stylesheet Optional. Theme to customize. Defaults to active theme.
-- --                           The theme"s stylesheet will be urlencoded if necessary.
-- -- @return string
-- --
-- function wp_customize_url( stylesheet = "" ) then
--         url = admin_url( "customize.php" );
--         if ( stylesheet ) then
--                 url .= "?theme=" . urlencode( stylesheet );
--         end;
--         return esc_url( url );
-- end;

-- --
-- -- Prints a script to check whether or not the Customizer is supported,
-- -- and apply either the no-customize-support or customize-support class
-- -- to the body.
-- --
-- -- This function MUST be called inside the body tag.
-- --
-- -- Ideally, call this function immediately after the body tag is opened.
-- -- This prevents a flash of unstyled content.
-- --
-- -- It is also recommended that you add the "no-customize-support" class
-- -- to the body tag by default.
-- --
-- -- @since 3.4.0
-- -- @since 4.7.0 Support for IE8 and below is explicitly removed via conditional comments.
-- -- @since 5.5.0 IE8 and older are no longer supported.
-- --
-- function wp_customize_support_script() then
--         admin_origin = parse_url( admin_url() );
--         home_origin  = parse_url( home_url() );
--         cross_domain = ( strtolower( admin_origin["host"] ) != strtolower( home_origin["host"] ) );
--         type_attr    = current_theme_supports( "html5", "script" ) ? "" : " type="text/javascript"";
--         ?>
--         <script<?php echo type_attr; ?>>
--                 (function() then
--                         var request, b = document.body, c = "className", cs = "customize-support", rcs = new RegExp("(^|\\s+)(no-)?"+cs+"(\\s+|)");

--         <?php   if ( cross_domain ) : ?>
--                         request = (function()then var xhr = new XMLHttpRequest(); return ("withCredentials" in xhr); end;)();
--         <?php   else : ?>
--                         request = true;
--         <?php   endif; ?>

--                         b[c] = b[c].replace( rcs, " " );
--                         // The customizer requires postMessage and CORS (if the site is cross domain).
--                         b[c] += ( window.postMessage && request ? " " : " no-" ) + cs;
--                 end;());
--         </script>
--         <?php
-- end;

-- --
-- -- Whether the site is being previewed in the Customizer.
-- --
-- -- @since 4.0.0
-- --
-- -- @global WP_Customize_Manager wp_customize Customizer instance.
-- --
-- -- @return bool True if the site is being previewed in the Customizer, false otherwise.
-- --
-- function is_customize_preview() then
--         global wp_customize;

--         return ( wp_customize instanceof WP_Customize_Manager ) && wp_customize.is_preview();
-- end;

-- --
-- -- Makes sure that auto-draft posts get their post_date bumped or status changed
-- -- to draft to prevent premature garbage-collection.
-- --
-- -- When a changeset is updated but remains an auto-draft, ensure the post_date
-- -- for the auto-draft posts remains the same so that it will be
-- -- garbage-collected at the same time by `wp_delete_auto_drafts()`. Otherwise,
-- -- if the changeset is updated to be a draft then update the posts
-- -- to have a far-future post_date so that they will never be garbage collected
-- -- unless the changeset post itself is deleted.
-- --
-- -- When a changeset is updated to be a persistent draft or to be scheduled for
-- -- publishing, then transition any dependent auto-drafts to a draft status so
-- -- that they likewise will not be garbage-collected but also so that they can
-- -- be edited in the admin before publishing since there is not yet a post/page
-- -- editing flow in the Customizer. See #39752.
-- --
-- -- @link https://core.trac.wordpress.org/ticket/39752
-- --
-- -- @since 4.8.0
-- -- @access private
-- -- @see wp_delete_auto_drafts()
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string   new_status Transition to this post status.
-- -- @param string   old_status Previous post status.
-- -- @param \WP_Post post       Post data.
-- --
-- function _wp_keep_alive_customize_changeset_dependent_auto_drafts( new_status, old_status, post ) then
--         global wpdb;
--         unset( old_status );

--         // Short-circuit if not a changeset or if the changeset was published.
--         if ( "customize_changeset" !== post.post_type || "publish" === new_status ) then
--                 return;
--         end;

--         data = json_decode( post.post_content, true );
--         if ( empty( data["nav_menus_created_posts"]["value"] ) ) then
--                 return;
--         end;

--         /*
--         -- Actually, in lieu of keeping alive, trash any customization drafts here if the changeset itself is
--         -- getting trashed. This is needed because when a changeset transitions to a draft, then any of the
--         -- dependent auto-draft post/page stubs will also get transitioned to customization drafts which
--         -- are then visible in the WP Admin. We cannot wait for the deletion of the changeset in which
--         -- _wp_delete_customize_changeset_dependent_auto_drafts() will be called, since they need to be
--         -- trashed to remove from visibility immediately.
--         --
--         if ( "trash" === new_status ) then
--                 foreach ( data["nav_menus_created_posts"]["value"] as post_id ) then
--                         if ( ! empty( post_id ) && "draft" === get_post_status( post_id ) ) then
--                                 wp_trash_post( post_id );
--                         end;
--                 end;
--                 return;
--         end;

--         post_args = array();
--         if ( "auto-draft" === new_status ) then
--                 /*
--                 -- Keep the post date for the post matching the changeset
--                 -- so that it will not be garbage-collected before the changeset.
--                 --
--                 post_args["post_date"] = post.post_date; // Note wp_delete_auto_drafts() only looks at this date.
--         end; else then
--                 /*
--                 -- Since the changeset no longer has an auto-draft (and it is not published)
--                 -- it is now a persistent changeset, a long-lived draft, and so any
--                 -- associated auto-draft posts should likewise transition into having a draft
--                 -- status. These drafts will be treated differently than regular drafts in
--                 -- that they will be tied to the given changeset. The publish meta box is
--                 -- replaced with a notice about how the post is part of a set of customized changes
--                 -- which will be published when the changeset is published.
--                 --
--                 post_args["post_status"] = "draft";
--         end;

--         foreach ( data["nav_menus_created_posts"]["value"] as post_id ) then
--                 if ( empty( post_id ) || "auto-draft" !== get_post_status( post_id ) ) then
--                         continue;
--                 end;
--                 wpdb.update(
--                         wpdb.posts,
--                         post_args,
--                         array( "ID" => post_id )
--                 );
--                 clean_post_cache( post_id );
--         end;
-- end;

   -----------------------------------
   -- Create_Initial_Theme_Features --
   -----------------------------------

   procedure Create_Initial_Theme_Features
   is
      use Inc_L10n;
   begin
      Register_Theme_Feature (
                "align-wide",
                To_Array (List => (
                        Build ("description",  abs "Whether theme opts in to wide alignment CSS class."),
                        Build ("show_in_rest", True)
                ))
        );
      Register_Theme_Feature (
                "automatic-feed-links",
                To_Array (List => (
                        Build ("description",  abs "Whether posts and comments RSS feed links are added to head."),
                        Build ("show_in_rest", True)
                ))
        );
      Register_Theme_Feature (
                "block-templates",
                To_Array (List => (
                        Build ("description",  abs "Whether a theme uses block-based templates."),
                        Build ("show_in_rest", True)
                ))
        );
      Register_Theme_Feature (
                "block-template-parts",
                To_Array (List => (
                        Build ("description",  abs "Whether a theme uses block-based template parts."),
                        Build ("show_in_rest", True)
                ))
        );
      Register_Theme_Feature (
        "custom-background",
        To_Array (List => (
          Build ("description",  abs "Custom background if defined by the theme."),
          Build ("type",         "object"),
          Build ("show_in_rest", To_Array (List => (1 =>
            Build ("schema",      To_Array (List => (1 =>
              Build ("properties", To_Array (List => (
                Build ("default-image",      To_Array (List => (
                  Build ("type",   "string"),
                  Build ("format", "uri")
                ))),
                Build ("default-preset",     To_Array (List => (
                  Build ("type", "string"),
                  Build ("enum", List_Type'["default", "fill",
                                            "fit", "repeat", "custom"])
                ))),
                Build ("default-position-x", To_Array (List => (
                  Build ("type", "string"),
                  Build ("enum", List_Type'["left", "center", "right"])
                ))),
                Build ("default-position-y", To_Array (List => (
                  Build ("type", "string"),
                  Build ("enum", List_Type'["left", "center", "right"])
                ))),
                Build ("default-size",       To_Array (List => (
                  Build ("type", "string"),
                  Build ("enum", List_Type'["auto", "contain", "cover"])
                ))),
                Build ("default-repeat",     To_Array (List => (
                  Build ("type", "string"),
                  Build ("enum", List_Type'["repeat-x", "repeat-y",
                                            "repeat", "no-repeat"])
                ))),
                Build ("default-attachment", To_Array (List => (
                  Build ("type", "string"),
                  Build ("enum", List_Type'["scroll", "fixed"])
                ))),
                Build ("default-color",      To_Array (List => (1 =>
                  Build ("type", "string")
                )))
              )))
            )))
          )))
        ))
      );

      Register_Theme_Feature (
                "custom-header",
                To_Array (List => (
                        Build ("description",  abs "Custom header if defined by the theme."),
                        Build ("type",         "object"),
                        Build ("show_in_rest", To_Array (List => (1 =>
                                Build ("schema", To_Array (List => (1 =>
                                        Build ("properties", To_Array (List => (
                                                Build ("default-image",      To_Array (List => (
                                                        Build ("type",   "string"),
                                                        Build ("format", "uri")
                                                ))),
                                                Build ("random-default",     To_Array (List => (1 =>
                                                        Build ("type", "boolean")
                                                ))),
                                                Build ("width",              To_Array (List => (1 =>
                                                        Build ("type", "integer")
                                                ))),
                                                Build ("height",             To_Array (List => (1 =>
                                                        Build ("type", "integer")
                                                ))),
                                                Build ("flex-height",        To_Array (List => (1 =>
                                                        Build ("type", "boolean")
                                                ))),
                                                Build ("flex-width",         To_Array (List => (1 =>
                                                        Build ("type", "boolean")
                                                ))),
                                                Build ("default-text-color", To_Array (List => (1 =>
                                                        Build ("type", "string")
                                                ))),
                                                Build ("header-text",        To_Array (List => (1 =>
                                                        Build ("type", "boolean")
                                                ))),
                                                Build ("uploads",            To_Array (List => (1 =>
                                                        Build ("type", "boolean")
                                                ))),
                                                Build ("video",              To_Array (List => (1 =>
                                                        Build ("type", "boolean")
                                                )))
                                        )))
                                )))
                        )))
                ))
        );
      Register_Theme_Feature (
                "custom-logo",
                To_Array (List => (
                        Build ("type",         "object"),
                        Build ("description",  abs "Custom logo if defined by the theme."),
                        Build ("show_in_rest", To_Array (List => (1 =>
                                Build ("schema", To_Array (List => (1 =>
                                        Build ("properties", To_Array (List => (
                                                Build ("width",                To_Array (List => (1 =>
                                                        Build ("type", "integer")
                                                ))),
                                                Build ("height",               To_Array (List => (1 =>
                                                        Build ("type", "integer")
                                                ))),
                                                Build ("flex-width",           To_Array (List => (1 =>
                                                        Build ("type", "boolean")
                                                ))),
                                                Build ("flex-height",          To_Array (List => (1 =>
                                                        Build ("type", "boolean")
                                                ))),
                                                Build ("header-text",          To_Array (List => (
                                                        Build ("type",  "array"),
                                                        Build ("items", To_Array (List => (1 =>
                                                                Build ("type", "string")
                                                        )))
                                                ))),
                                                Build ("unlink-homepage-logo", To_Array (List => (1 =>
                                                        Build ("type", "boolean")
                                                )))
                                        )))
                                )))
                        )))
                ))
        );
      Register_Theme_Feature (
                "customize-selective-refresh-widgets",
                To_Array (List => (
                        Build ("description",  abs "Whether the theme enables Selective Refresh for Widgets being managed with the Customizer."),
                        Build ("show_in_rest", True)
                ))
        );
      Register_Theme_Feature (
                "dark-editor-style",
                To_Array (List => (
                        Build ("description",  abs "Whether theme opts in to the dark editor style UI."),
                        Build ("show_in_rest", True)
                ))
        );
      Register_Theme_Feature (
                "disable-custom-colors",
                To_Array (List => (
                        Build ("description",  abs "Whether the theme disables custom colors."),
                        Build ("show_in_rest", True)
                ))
        );
      Register_Theme_Feature (
                "disable-custom-font-sizes",
                To_Array (List => (
                        Build ("description",  abs "Whether the theme disables custom font sizes."),
                        Build ("show_in_rest", True)
                ))
        );
      Register_Theme_Feature (
                "disable-custom-gradients",
                To_Array (List => (
                        Build ("description",  abs "Whether the theme disables custom gradients."),
                        Build ("show_in_rest", True)
                ))
        );
      Register_Theme_Feature (
                "disable-layout-styles",
                To_Array (List => (
                        Build ("description",  abs "Whether the theme disables generated layout styles."),
                        Build ("show_in_rest", True)
                ))
        );
      Register_Theme_Feature (
                "editor-color-palette",
                To_Array (List => (
                        Build ("type",         "array"),
                        Build ("description",  abs "Custom color palette if defined by the theme."),
                        Build ("show_in_rest", To_Array (List => (1 =>
                                Build ("schema", To_Array (List => (1 =>
                                        Build ("items", To_Array (List => (
                                                Build ("type",       "object"),
                                                Build ("properties", To_Array (List => (
                                                        Build ("name",  To_Array (List => (1 =>
                                                                Build ("type", "string")
                                                        ))),
                                                        Build ("slug",  To_Array (List => (1 =>
                                                                Build ("type", "string")
                                                        ))),
                                                        Build ("color", To_Array (List => (1 =>
                                                                Build ("type", "string")
                                                        )))
                                                )))
                                        )))
                                )))
                        )))
                ))
        );
      Register_Theme_Feature (
                "editor-font-sizes",
                To_Array (List => (
                        Build ("type",         "array"),
                        Build ("description",  abs "Custom font sizes if defined by the theme."),
                        Build ("show_in_rest", To_Array (List => (1 =>
                                Build ("schema", To_Array (List => (1 =>
                                        Build ("items", To_Array (List => (
                                                Build ("type",       "object"),
                                                Build ("properties", To_Array (List => (
                                                        Build ("name", To_Array (List => (1 =>
                                                                Build ("type", "string")
                                                        ))),
                                                        Build ("size", To_Array (List => (1 =>
                                                                Build ("type", "number")
                                                        ))),
                                                        Build ("slug", To_Array (List => (1 =>
                                                                Build ("type", "string")
                                                        )))
                                                )))
                                        )))
                                )))
                        )))
                ))
        );
      Register_Theme_Feature (
                "editor-gradient-presets",
                To_Array (List => (
                        Build ("type",         "array"),
                        Build ("description",  abs "Custom gradient presets if defined by the theme."),
                        Build ("show_in_rest", To_Array (List => (1 =>
                                Build ("schema", To_Array (List => (1 =>
                                        Build ("items", To_Array (List => (
                                                Build ("type",       "object"),
                                                Build ("properties", To_Array (List => (
                                                        Build ("name",     To_Array (List => (1 =>
                                                                Build ("type", "string")
                                                        ))),
                                                        Build ("gradient", To_Array (List => (1 =>
                                                                Build ("type", "string")
                                                        ))),
                                                        Build ("slug",     To_Array (List => (1 =>
                                                                Build ("type", "string")
                                                        )))
                                                )))
                                        )))
                                )))
                        )))
                ))
        );
      Register_Theme_Feature (
                "editor-styles",
                To_Array (List => (
                        Build ("description",  abs "Whether theme opts in to the editor styles CSS wrapper."),
                        Build ("show_in_rest", True)
                ))
        );

      Register_Theme_Feature (
        "html5",
        To_Array (List => (
          Build ("type",         "array"),
          Build ("description",  abs "Allows use of HTML5 markup for search forms, comment forms, comment lists, gallery, and caption."),
          Build ("show_in_rest", To_Array (List => (1 =>
            Build ("schema", To_Array (List => (1 =>
              Build ("items", To_Array (List => (
                Build ("type", "string"),
                Build ("enum", List_Type'["search-form", "comment-form",
                                          "comment-list", "gallery",
                                          "caption", "script", "style"])
              )))
            )))
          )))
        ))
      );

      Register_Theme_Feature (
        "post-formats",
        To_Array (List => (
          Build ("type",         "array"),
          Build ("description",  abs "Post formats supported."),
          Build ("show_in_rest", To_Array (List => (
            Build ("name",             "formats"),
            Build ("schema",           To_Array (List => (
              Build ("items",   To_Array (List => (1 =>
                Build ("type", "string")
--              Build ("enum", Get_Post_Format_Slugs) -- ()
              ))),
              Build ("default", List_Type'["standard"])
            )))
            -- Build ("prepare_callback", static function ( formats ) then
            --         formats = is_Array (List => ( formats ) ? array_values( formats[0] ) : To_Array (List => ();
            --         formats = array_merge( To_Array (List => ( "standard" ), formats );
            --         return formats;
            -- end;,
          )))
        ))
      );

      Register_Theme_Feature (
        "post-thumbnails",
        To_Array (List => (
          Build ("type",         "array"),
          Build ("description",  abs "The post types that support thumbnails or true if all post types are supported."),
          Build ("show_in_rest", To_Array (List => (
            Build ("type",   List_Type'["boolean", "array"]),
            Build ("schema", To_Array (List => (1 =>
              Build ("items", To_Array (List => (1 =>
                Build ("type", "string")
              )))
            )))
          )))
        ))
      );

      Register_Theme_Feature (
                "responsive-embeds",
                To_Array (List => (
                        Build ("description",  abs "Whether the theme supports responsive embedded content."),
                        Build ("show_in_rest", True)
                ))
        );
      Register_Theme_Feature (
                "title-tag",
                To_Array (List => (
                        Build ("description",  abs "Whether the theme can manage the document title tag."),
                        Build ("show_in_rest", True)
                ))
        );
      Register_Theme_Feature (
                "wp-block-styles",
                To_Array (List => (
                        Build ("description",  abs "Whether theme opts in to default WordPress block styles for viewing."),
                        Build ("show_in_rest", True)
                ))
        );
   end Create_Initial_Theme_Features;

-- --
-- -- Returns whether the active theme is a block-based theme or not.
-- --
-- -- @since 5.9.0
-- --
-- -- @return boolean Whether the active theme is a block-based theme or not.
-- --
-- function wp_is_block_theme() then
--         return wp_get_theme().is_block_theme();
-- end;

-- --
-- -- Given an element name, returns a class name.
-- --
-- -- Alias of WP_Theme_JSON::get_element_class_name.
-- --
-- -- @since 6.1.0
-- --
-- -- @param string element The name of the element.
-- --
-- -- @return string The name of the class.
-- --
-- function wp_theme_get_element_class_name( element ) then
--         return WP_Theme_JSON::get_element_class_name( element );
-- end;

   ----------------------------------
   -- X_Add_Default_Theme_Supports --
   ----------------------------------

   procedure X_Add_Default_Theme_Supports
   is
--    use Inc_Functions;
--    use Inc_Plugins;
   begin
      if not Wp_Is_Block_Theme then
         return;
      end if;

      Add_Theme_Support ("post-thumbnails");
      Add_Theme_Support ("responsive-embeds");
      Add_Theme_Support ("editor-styles");

      --
      -- Makes block themes support HTML5 by default for the comment block and search
      -- form (which use default template functions) and `[caption]` and `[gallery]`
      -- shortcodes. Other blocks contain their own HTML5 markup.
      --
      Add_Theme_Support ("html5", List_Type'["comment-form", "comment-list",
                                             "search-form", "gallery", "caption",
                                             "style", "script"]);
      Add_Theme_Support ("automatic-feed-links");

--    Add_Filter ("should_load_separate_core_block_assets", X_Return_True'Access);

      --
      -- Remove the Customizer"s Menus panel when block theme is active.
      --
      -- Add_Filter (
      --   "customize_panel_active",
      --           static function ( active, WP_Customize_Panel panel ) then
      --                   if (
      --                           "nav_menus" === panel.id &&
      --                           ! current_theme_supports( "menus" ) &&
      --                           ! current_theme_supports( "widgets" )
      --                   ) then
      --                           active = false;
      --                   end;
      --                   return active;
      --           end;,
      --           10,
      --           2
      --   );
   end X_Add_Default_Theme_Supports;

end Inc_Themes;
