--
-- WP_Theme Class
--
-- @package WordPress
-- @subpackage Theme
-- @since 3.4.0

with Ada.Strings.Unbounded;

with Arrays;

with Inc_Class_Wp_Errors;

package Inc_Class_Wp_Themes
is
   use Ada.Strings.Unbounded;
   use Arrays;

   type Wp_Theme;
   type Wp_Theme_Access is access all Wp_Theme;
   --
   -- #[AllowDynamicProperties]
   type Wp_Theme is tagged -- implements ArrayAccess then
      record
         --
         -- Whether the theme has been marked as updateable.
         --
         -- @since 4.4.0
         -- @var bool
         --
         -- @see WP_MS_Themes_List_Table
         --
--         public update = false;

         --
         -- Renamed theme tags.
         --
         -- @since 3.8.0
         -- @var string[]
         --
         -- private static tag_map = array(
         --         'fixed-width'    => 'fixed-layout',
         --         'flexible-width' => 'fluid-layout',
         -- );

         --
         -- Absolute path to the theme root, usually wp-content/themes
         --
         -- @since 3.4.0
         -- @var string
         --
         -- private
         Theme_Root : Unbounded_String;

         --
         -- Header data from the theme's style.css file.
         --
         -- @since 3.4.0
         -- @var array
         --
         -- private
         Headers : Array_Type;

         --
         -- Header data from the theme's style.css file after being sanitized.
         --
         -- @since 3.4.0
         -- @var array
         --
         -- private
         Headers_Sanitized : Array_Type;

         --
         -- Header name from the theme's style.css after being translated.
         --
         -- Cached due to sorting functions running over the translated name.
         --
         -- @since 3.4.0
         -- @var string
         --
--         private name_translated;

         --
         -- Errors encountered when initializing the theme.
         --
         -- @since 3.4.0
         -- @var WP_Error
         --
         -- private
         M_Errors : Inc_Class_Wp_Errors.Wp_Error;

         --
         -- The directory name of the theme's files, inside the theme root.
         --
         -- In the case of a child theme, this is directory name of the child theme.
         -- Otherwise, 'stylesheet' is the same as 'template'.
         --
         -- @since 3.4.0
         -- @var string
         --
         -- private
         Stylesheet : Unbounded_String;

         --
         -- The directory name of the theme's files, inside the theme root.
         --
         -- In the case of a child theme, this is the directory name of the parent
         -- theme. Otherwise, 'template' is the same as 'stylesheet'.
         --
         -- @since 3.4.0
         -- @var string
         --
         -- private
         Template : Unbounded_String;

         --
         -- A reference to the parent theme, in the case of a child theme.
         --
         -- @since 3.4.0
         -- @var WP_Theme
         --
         -- private
         M_Parent : Wp_Theme_Access;

         --
         -- URL to the theme root, usually an absolute URL to wp-content/themes
         --
         -- @since 3.4.0
         -- @var string
         --
--         private theme_root_uri;

         --
         -- Flag for whether the theme's textdomain is loaded.
         --
         -- @since 3.4.0
         -- @var bool
         --
--         private textdomain_loaded;

         --
         -- Stores an md5 hash of the theme root, to function as the cache key.
         --
         -- @since 3.4.0
         -- @var string
         --
         -- private
         Cache_Hash : Unbounded_String;

      end record;

   --
   -- Headers for style.css files.
   --
   -- @since 3.4.0
   -- @since 5.4.0 Added `Requires at least` and `Requires PHP` headers.
   -- @since 6.1.0 Added `Update URI` header.
   -- @var string[]
   --
   -- private static
   Static_File_Headers : Array_Type := To_Array (List => (
     Build ("Name",        "Theme Name"),
     Build ("ThemeURI",    "Theme URI"),
     Build ("Description", "Description"),
     Build ("Author",      "Author"),
     Build ("AuthorURI",   "Author URI"),
     Build ("Version",     "Version"),
     Build ("Template",    "Template"),
     Build ("Status",      "Status"),
     Build ("Tags",        "Tags"),
     Build ("TextDomain",  "Text Domain"),
     Build ("DomainPath",  "Domain Path"),
     Build ("RequiresWP",  "Requires at least"),
     Build ("RequiresPHP", "Requires PHP"),
     Build ("UpdateURI",   "Update URI")
   ));

   --
   -- Default themes.
   --
   -- @since 3.4.0
   -- @since 3.5.0 Added the Twenty Twelve theme.
   -- @since 3.6.0 Added the Twenty Thirteen theme.
   -- @since 3.8.0 Added the Twenty Fourteen theme.
   -- @since 4.1.0 Added the Twenty Fifteen theme.
   -- @since 4.4.0 Added the Twenty Sixteen theme.
   -- @since 4.7.0 Added the Twenty Seventeen theme.
   -- @since 5.0.0 Added the Twenty Nineteen theme.
   -- @since 5.3.0 Added the Twenty Twenty theme.
   -- @since 5.6.0 Added the Twenty Twenty-One theme.
   -- @since 5.9.0 Added the Twenty Twenty-Two theme.
   -- @var string[]
   --
   -- private static
   Static_Default_Themes : Array_Type := To_Array (List => (
     Build ("classic",           "WordPress Classic"),
     Build ("default",           "WordPress Default"),
     Build ("twentyten",         "Twenty Ten"),
     Build ("twentyeleven",      "Twenty Eleven"),
     Build ("twentytwelve",      "Twenty Twelve"),
     Build ("twentythirteen",    "Twenty Thirteen"),
     Build ("twentyfourteen",    "Twenty Fourteen"),
     Build ("twentyfifteen",     "Twenty Fifteen"),
     Build ("twentysixteen",     "Twenty Sixteen"),
     Build ("twentyseventeen",   "Twenty Seventeen"),
     Build ("twentynineteen",    "Twenty Nineteen"),
     Build ("twentytwenty",      "Twenty Twenty"),
     Build ("twentytwentyone",   "Twenty Twenty-One"),
     Build ("twentytwentytwo",   "Twenty Twenty-Two"),
     Build ("twentytwentythree", "Twenty Twenty-Three")
   ));

   --
   -- Flag for whether the themes cache bucket should be persistently cached.
   --
   -- Default is false. Can be set with the {@see 'wp_cache_themes_persistently'}
   -- filter.
   --
   -- @since 3.4.0
   -- @var bool
   --
   -- private static
   Static_Persistently_Cache : Boolean;

   --
   -- Expiration time for the themes cache bucket.
   --
   -- By default the bucket is not cached, so this value is useless.
   --
   -- @since 3.4.0
   -- @var bool
   --
   -- private
   Static_Cache_Expiration : Integer := 1800;

   --
   -- Constructor for WP_Theme.
   --
   -- @since 3.4.0
   --
   -- @global array wp_theme_directories
   --
   -- @param string        theme_dir  Directory of the theme within the theme_root.
   -- @param string        theme_root Theme root.
   -- @param WP_Theme|null _child If this theme is a parent theme, the child may be
   --                              passed for validation purposes.
   --
   function X_Construct (Theme_Dir  : String;
                         Theme_Root : String;
                         X_Child    : in out Wp_Theme) -- _Access := null)
                         return Wp_Theme;

--         --
--         -- When converting the object to a string, the theme name is returned.
--         --
--         -- @since 3.4.0
--         --
--         -- @return string Theme name, ready for display (translated)
--         --
--         public function __toString() then
--                 return (string) this->display( 'Name' );
--         end;

--         --
--         -- __isset() magic method for properties formerly returned by current_theme_info()
--         --
--         -- @since 3.4.0
--         --
--         -- @param string offset Property to check if set.
--         -- @return bool Whether the given property is set.
--         --
--         public function __isset( offset ) then
--                 static properties = array(
--                         'name',
--                         'title',
--                         'version',
--                         'parent_theme',
--                         'template_dir',
--                         'stylesheet_dir',
--                         'template',
--                         'stylesheet',
--                         'screenshot',
--                         'description',
--                         'author',
--                         'tags',
--                         'theme_root',
--                         'theme_root_uri',
--                 );

--                 return in_array( offset, properties, true );
--         end;

--         --
--         -- __get() magic method for properties formerly returned by current_theme_info()
--         --
--         -- @since 3.4.0
--         --
--         -- @param string offset Property to get.
--         -- @return mixed Property value.
--         --
--         public function __get( offset ) then
--                 switch ( offset ) then
--                         case 'name':
--                         case 'title':
--                                 return this->get( 'Name' );
--                         case 'version':
--                                 return this->get( 'Version' );
--                         case 'parent_theme':
--                                 return this->parent() ? this->parent()->get( 'Name' ) : '';
--                         case 'template_dir':
--                                 return this->get_template_directory();
--                         case 'stylesheet_dir':
--                                 return this->get_stylesheet_directory();
--                         case 'template':
--                                 return this->get_template();
--                         case 'stylesheet':
--                                 return this->get_stylesheet();
--                         case 'screenshot':
--                                 return this->get_screenshot( 'relative' );
--                         // 'author' and 'description' did not previously return translated data.
--                         case 'description':
--                                 return this->display( 'Description' );
--                         case 'author':
--                                 return this->display( 'Author' );
--                         case 'tags':
--                                 return this->get( 'Tags' );
--                         case 'theme_root':
--                                 return this->get_theme_root();
--                         case 'theme_root_uri':
--                                 return this->get_theme_root_uri();
--                         // For cases where the array was converted to an object.
--                         default:
--                                 return this->offsetGet( offset );
--                 end;
--         end;

--         --
--         -- Method to implement ArrayAccess for keys formerly returned by get_themes()
--         --
--         -- @since 3.4.0
--         --
--         -- @param mixed offset
--         -- @param mixed value
--         --
--         #[ReturnTypeWillChange]
--         public function offsetSet( offset, value ) thenend;

--         --
--         -- Method to implement ArrayAccess for keys formerly returned by get_themes()
--         --
--         -- @since 3.4.0
--         --
--         -- @param mixed offset
--         --
--         #[ReturnTypeWillChange]
--         public function offsetUnset( offset ) thenend;

--         --
--         -- Method to implement ArrayAccess for keys formerly returned by get_themes()
--         --
--         -- @since 3.4.0
--         --
--         -- @param mixed offset
--         -- @return bool
--         --
--         #[ReturnTypeWillChange]
--         public function offsetExists( offset ) then
--                 static keys = array(
--                         'Name',
--                         'Version',
--                         'Status',
--                         'Title',
--                         'Author',
--                         'Author Name',
--                         'Author URI',
--                         'Description',
--                         'Template',
--                         'Stylesheet',
--                         'Template Files',
--                         'Stylesheet Files',
--                         'Template Dir',
--                         'Stylesheet Dir',
--                         'Screenshot',
--                         'Tags',
--                         'Theme Root',
--                         'Theme Root URI',
--                         'Parent Theme',
--                 );

--                 return in_array( offset, keys, true );
--         end;

--         --
--         -- Method to implement ArrayAccess for keys formerly returned by get_themes().
--         --
--         -- Author, Author Name, Author URI, and Description did not previously return
--         -- translated data. We are doing so now as it is safe to do. However, as
--         -- Name and Title could have been used as the key for get_themes(), both remain
--         -- untranslated for back compatibility. This means that ['Name'] is not ideal,
--         -- and care should be taken to use `theme::display( 'Name' )` to get a properly
--         -- translated header.
--         --
--         -- @since 3.4.0
--         --
--         -- @param mixed offset
--         -- @return mixed
--         --
--         #[ReturnTypeWillChange]
--         public function offsetGet( offset ) then
--                 switch ( offset ) then
--                         case 'Name':
--                         case 'Title':
--                                 /*
--                                 -- See note above about using translated data. get() is not ideal.
--                                 -- It is only for backward compatibility. Use display().
--                                 --
--                                 return this->get( 'Name' );
--                         case 'Author':
--                                 return this->display( 'Author' );
--                         case 'Author Name':
--                                 return this->display( 'Author', false );
--                         case 'Author URI':
--                                 return this->display( 'AuthorURI' );
--                         case 'Description':
--                                 return this->display( 'Description' );
--                         case 'Version':
--                         case 'Status':
--                                 return this->get( offset );
--                         case 'Template':
--                                 return this->get_template();
--                         case 'Stylesheet':
--                                 return this->get_stylesheet();
--                         case 'Template Files':
--                                 return this->get_files( 'php', 1, true );
--                         case 'Stylesheet Files':
--                                 return this->get_files( 'css', 0, false );
--                         case 'Template Dir':
--                                 return this->get_template_directory();
--                         case 'Stylesheet Dir':
--                                 return this->get_stylesheet_directory();
--                         case 'Screenshot':
--                                 return this->get_screenshot( 'relative' );
--                         case 'Tags':
--                                 return this->get( 'Tags' );
--                         case 'Theme Root':
--                                 return this->get_theme_root();
--                         case 'Theme Root URI':
--                                 return this->get_theme_root_uri();
--                         case 'Parent Theme':
--                                 return this->parent() ? this->parent()->get( 'Name' ) : '';
--                         default:
--                                 return null;
--                 end;
--         end;

   --
   -- Returns errors property.
   --
   -- @since 3.4.0
   --
   -- @return WP_Error|false WP_Error if there are errors, or false.
   --
   function Errors (This : Wp_Theme)
                    return Inc_Class_Wp_Errors.Wp_Error;
--                 return is_wp_error( this->errors ) ? this->errors : false;
--         end;

   --
   -- Determines whether the theme exists.
   --
   -- A theme with errors exists. A theme with the error of 'theme_not_found',
   -- meaning that the theme's directory was not found, does not exist.
   --
   -- @since 3.4.0
   --
   -- @return bool Whether the theme exists.
   --
   function Exists (This : Wp_Theme)
                    return Boolean;

   --
   -- Returns reference to the parent theme.
   --
   -- @since 3.4.0
   --
   -- @return WP_Theme|false Parent theme, or false if the active theme is not a
   --                        child theme.
   --
   function Parent (This : Wp_Theme)
                    return Wp_Theme;

--         --
--         -- Perform reinitialization tasks.
--         --
--         -- Prevents a callback from being injected during unserialization of an object.
--         --
--         -- @return void
--         --
--         public function __wakeup() then
--                 if ( this->parent && ! this->parent instanceof self ) then
--                         throw new UnexpectedValueException();
--                 end;
--                 if ( this->headers && ! is_array( this->headers ) ) then
--                         throw new UnexpectedValueException();
--                 end;
--                 foreach ( this->headers as value ) then
--                         if ( ! is_string( value ) ) then
--                                 throw new UnexpectedValueException();
--                         end;
--                 end;
--                 this->headers_sanitized = array();
--         end;

   --
   -- Adds theme data to cache.
   --
   -- Cache entries keyed by the theme and the type of data.
   --
   -- @since 3.4.0
   --
   -- @param string       key  Type of data to store (theme, screenshot, headers,
   --                           post_templates)
   -- @param array|string data Data to store
   -- @return bool Return value from wp_cache_add()
   --
   -- private
   function Cache_Add (This : Wp_Theme;
                       Key  : String;
                       Data : Array_Type)
                       return Boolean;

   procedure Cache_Add (This : Wp_Theme;
                        Key  : String;
                        Data : Array_Type);

   --
   -- Gets theme data from cache.
   --
   -- Cache entries are keyed by the theme and the type of data.
   --
   -- @since 3.4.0
   --
   -- @param string key Type of data to retrieve (theme, screenshot, headers,
   --                    post_templates)
   -- @return mixed Retrieved data
   --
   -- private
   function Cache_Get (This : Wp_Theme;
                       Key  : String)
                       return Array_Type;
--                 return wp_cache_get( key . '-' . this->cache_hash, 'themes' );
--         end;

--         --
--         -- Clears the cache for the theme.
--         --
--         -- @since 3.4.0
--         --
--         public function cache_delete() then
--                 foreach ( array( 'theme', 'screenshot', 'headers', 'post_templates' ) as key ) then
--                         wp_cache_delete( key . '-' . this->cache_hash, 'themes' );
--                 end;
--                 this->template          = null;
--                 this->textdomain_loaded = null;
--                 this->theme_root_uri    = null;
--                 this->parent            = null;
--                 this->errors            = null;
--                 this->headers_sanitized = null;
--                 this->name_translated   = null;
--                 this->headers           = array();
--                 this->__construct( this->stylesheet, this->theme_root );
--         end;

   --
   -- Gets a raw, unformatted theme header.
   --
   -- The header is sanitized, but is not translated, and is not marked up for display.
   -- To get a theme header for display, use the display() method.
   --
   -- Use the get_template() method, not the 'Template' header, for finding the template.
   -- The 'Template' header is only good for what was written in the style.css, while
   -- get_template() takes into account where WordPress actually located the theme and
   -- whether it is actually valid.
   --
   -- @since 3.4.0
   --
   -- @param string header Theme header. Name, Description, Author, Version, ThemeURI, AuthorURI,
   --                       Status, Tags.
   -- @return string|array|false String or array (for Tags header) on success, false on failure.
   --
   function Get (This   : in out Wp_Theme;
                 Header : String)
                 return String;
--                 if ( ! isset( this->headers[ header ] ) ) then
--                         return false;
--                 end;

--                 if ( ! isset( this->headers_sanitized ) ) then
--                         this->headers_sanitized = this->cache_get( 'headers' );
--                         if ( ! is_array( this->headers_sanitized ) ) then
--                                 this->headers_sanitized = array();
--                         end;
--                 end;

--                 if ( isset( this->headers_sanitized[ header ] ) ) then
--                         return this->headers_sanitized[ header ];
--                 end;

--                 // If themes are a persistent group, sanitize everything and cache it. One cache add is better than many cache sets.
--                 if ( self::persistently_cache ) then
--                         foreach ( array_keys( this->headers ) as _header ) then
--                                 this->headers_sanitized[ _header ] = this->sanitize_header( _header, this->headers[ _header ] );
--                         end;
--                         this->cache_add( 'headers', this->headers_sanitized );
--                 end; else then
--                         this->headers_sanitized[ header ] = this->sanitize_header( header, this->headers[ header ] );
--                 end;

--                 return this->headers_sanitized[ header ];
--         end;

--         --
--         -- Gets a theme header, formatted and translated for display.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string header    Theme header. Name, Description, Author, Version, ThemeURI, AuthorURI, Status, Tags.
--         -- @param bool   markup    Optional. Whether to mark up the header. Defaults to true.
--         -- @param bool   translate Optional. Whether to translate the header. Defaults to true.
--         -- @return string|array|false Processed header. An array for Tags if `markup` is false, string otherwise.
--         --                            False on failure.
--         --
--         public function display( header, markup = true, translate = true ) then
--                 value = this->get( header );
--                 if ( false === value ) then
--                         return false;
--                 end;

--                 if ( translate && ( empty( value ) || ! this->load_textdomain() ) ) then
--                         translate = false;
--                 end;

--                 if ( translate ) then
--                         value = this->translate_header( header, value );
--                 end;

--                 if ( markup ) then
--                         value = this->markup_header( header, value, translate );
--                 end;

--                 return value;
--         end;

   --
   -- Sanitizes a theme header.
   --
   -- @since 3.4.0
   -- @since 5.4.0 Added support for `Requires at least` and `Requires PHP` headers.
   -- @since 6.1.0 Added support for `Update URI` header.
   --
   -- @param string header Theme header. Accepts 'Name', 'Description', 'Author',
   --                       'Version', 'ThemeURI', 'AuthorURI', 'Status', 'Tags',
   --                       'RequiresWP', 'RequiresPHP', 'UpdateURI'.
   -- @param string value  Value to sanitize.
   -- @return string|array An array for Tags header, string otherwise.
   --
   -- private
   function Sanitize_Header (This   : Wp_Theme;
                             Header : String;
                             Value  : String)
                             return String;
--                 switch ( header ) then
--                         case 'Status':
--                                 if ( ! value ) then
--                                         value = 'publish';
--                                         break;
--                                 end;
--                                 // Fall through otherwise.
--                         case 'Name':
--                                 static header_tags = array(
--                                         'abbr'    => array( 'title' => true ),
--                                         'acronym' => array( 'title' => true ),
--                                         'code'    => true,
--                                         'em'      => true,
--                                         'strong'  => true,
--                                 );

--                                 value = wp_kses( value, header_tags );
--                                 break;
--                         case 'Author':
--                                 // There shouldn't be anchor tags in Author, but some themes like to be challenging.
--                         case 'Description':
--                                 static header_tags_with_a = array(
--                                         'a'       => array(
--                                                 'href'  => true,
--                                                 'title' => true,
--                                         ),
--                                         'abbr'    => array( 'title' => true ),
--                                         'acronym' => array( 'title' => true ),
--                                         'code'    => true,
--                                         'em'      => true,
--                                         'strong'  => true,
--                                 );

--                                 value = wp_kses( value, header_tags_with_a );
--                                 break;
--                         case 'ThemeURI':
--                         case 'AuthorURI':
--                                 value = sanitize_url( value );
--                                 break;
--                         case 'Tags':
--                                 value = array_filter( array_map( 'trim', explode( ',', strip_tags( value ) ) ) );
--                                 break;
--                         case 'Version':
--                         case 'RequiresWP':
--                         case 'RequiresPHP':
--                         case 'UpdateURI':
--                                 value = strip_tags( value );
--                                 break;
--                 end;

--                 return value;
--         end;

--         --
--         -- Marks up a theme header.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string       header    Theme header. Name, Description, Author, Version, ThemeURI, AuthorURI, Status, Tags.
--         -- @param string|array value     Value to mark up. An array for Tags header, string otherwise.
--         -- @param string       translate Whether the header has been translated.
--         -- @return string Value, marked up.
--         --
--         private function markup_header( header, value, translate ) then
--                 switch ( header ) then
--                         case 'Name':
--                                 if ( empty( value ) ) then
--                                         value = esc_html( this->get_stylesheet() );
--                                 end;
--                                 break;
--                         case 'Description':
--                                 value = wptexturize( value );
--                                 break;
--                         case 'Author':
--                                 if ( this->get( 'AuthorURI' ) ) then
--                                         value = sprintf( '<a href="%1s">%2s</a>', this->display( 'AuthorURI', true, translate ), value );
--                                 end; elseif ( ! value ) then
--                                         value = __( 'Anonymous' );
--                                 end;
--                                 break;
--                         case 'Tags':
--                                 static comma = null;
--                                 if ( ! isset( comma ) ) then
--                                         comma = wp_get_list_item_separator();
--                                 end;
--                                 value = implode( comma, value );
--                                 break;
--                         case 'ThemeURI':
--                         case 'AuthorURI':
--                                 value = esc_url( value );
--                                 break;
--                 end;

--                 return value;
--         end;

--         --
--         -- Translates a theme header.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string       header Theme header. Name, Description, Author, Version, ThemeURI, AuthorURI, Status, Tags.
--         -- @param string|array value  Value to translate. An array for Tags header, string otherwise.
--         -- @return string|array Translated value. An array for Tags header, string otherwise.
--         --
--         private function translate_header( header, value ) then
--                 switch ( header ) then
--                         case 'Name':
--                                 // Cached for sorting reasons.
--                                 if ( isset( this->name_translated ) ) then
--                                         return this->name_translated;
--                                 end;

--                                 // phpcs:ignore WordPress.WP.I18n.LowLevelTranslationFunction,WordPress.WP.I18n.NonSingularStringLiteralText,WordPress.WP.I18n.NonSingularStringLiteralDomain
--                                 this->name_translated = translate( value, this->get( 'TextDomain' ) );

--                                 return this->name_translated;
--                         case 'Tags':
--                                 if ( empty( value ) || ! function_exists( 'get_theme_feature_list' ) ) then
--                                         return value;
--                                 end;

--                                 static tags_list;
--                                 if ( ! isset( tags_list ) ) then
--                                         tags_list = array(
--                                                 // As of 4.6, deprecated tags which are only used to provide translation for older themes.
--                                                 'black'             => __( 'Black' ),
--                                                 'blue'              => __( 'Blue' ),
--                                                 'brown'             => __( 'Brown' ),
--                                                 'gray'              => __( 'Gray' ),
--                                                 'green'             => __( 'Green' ),
--                                                 'orange'            => __( 'Orange' ),
--                                                 'pink'              => __( 'Pink' ),
--                                                 'purple'            => __( 'Purple' ),
--                                                 'red'               => __( 'Red' ),
--                                                 'silver'            => __( 'Silver' ),
--                                                 'tan'               => __( 'Tan' ),
--                                                 'white'             => __( 'White' ),
--                                                 'yellow'            => __( 'Yellow' ),
--                                                 'dark'              => _x( 'Dark', 'color scheme' ),
--                                                 'light'             => _x( 'Light', 'color scheme' ),
--                                                 'fixed-layout'      => __( 'Fixed Layout' ),
--                                                 'fluid-layout'      => __( 'Fluid Layout' ),
--                                                 'responsive-layout' => __( 'Responsive Layout' ),
--                                                 'blavatar'          => __( 'Blavatar' ),
--                                                 'photoblogging'     => __( 'Photoblogging' ),
--                                                 'seasonal'          => __( 'Seasonal' ),
--                                         );

--                                         feature_list = get_theme_feature_list( false ); // No API.

--                                         foreach ( feature_list as tags ) then
--                                                 tags_list += tags;
--                                         end;
--                                 end;

--                                 foreach ( value as &tag ) then
--                                         if ( isset( tags_list[ tag ] ) ) then
--                                                 tag = tags_list[ tag ];
--                                         end; elseif ( isset( self::tag_map[ tag ] ) ) then
--                                                 tag = tags_list[ self::tag_map[ tag ] ];
--                                         end;
--                                 end;

--                                 return value;

--                         default:
--                                 // phpcs:ignore WordPress.WP.I18n.LowLevelTranslationFunction,WordPress.WP.I18n.NonSingularStringLiteralText,WordPress.WP.I18n.NonSingularStringLiteralDomain
--                                 value = translate( value, this->get( 'TextDomain' ) );
--                 end;
--                 return value;
--         end;

   --
   -- Returns the directory name of the theme's "stylesheet" files, inside the theme root.
   --
   -- In the case of a child theme, this is directory name of the child theme.
   -- Otherwise, get_stylesheet() is the same as get_template().
   --
   -- @since 3.4.0
   --
   -- @return string Stylesheet
   --
   function Get_Stylesheet (This : Wp_Theme)
                            return String;

   --
   -- Returns the directory name of the theme's "template" files, inside the theme
   -- root.
   --
   -- In the case of a child theme, this is the directory name of the parent theme.
   -- Otherwise, the get_template() is the same as get_stylesheet().
   --
   -- @since 3.4.0
   --
   -- @return string Template
   --
   function Get_Template (This : Wp_Theme)
                          return String;

--         --
--         -- Returns the absolute path to the directory of a theme's "stylesheet" files.
--         --
--         -- In the case of a child theme, this is the absolute path to the directory
--         -- of the child theme's files.
--         --
--         -- @since 3.4.0
--         --
--         -- @return string Absolute path of the stylesheet directory.
--         --
--         public function get_stylesheet_directory() then
--                 if ( this->errors() && in_array( 'theme_root_missing', this->errors()->get_error_codes(), true ) ) then
--                         return '';
--                 end;

--                 return this->theme_root . '/' . this->stylesheet;
--         end;

--         --
--         -- Returns the absolute path to the directory of a theme's "template" files.
--         --
--         -- In the case of a child theme, this is the absolute path to the directory
--         -- of the parent theme's files.
--         --
--         -- @since 3.4.0
--         --
--         -- @return string Absolute path of the template directory.
--         --
--         public function get_template_directory() then
--                 if ( this->parent() ) then
--                         theme_root = this->parent()->theme_root;
--                 end; else then
--                         theme_root = this->theme_root;
--                 end;

--                 return theme_root . '/' . this->template;
--         end;

--         --
--         -- Returns the URL to the directory of a theme's "stylesheet" files.
--         --
--         -- In the case of a child theme, this is the URL to the directory of the
--         -- child theme's files.
--         --
--         -- @since 3.4.0
--         --
--         -- @return string URL to the stylesheet directory.
--         --
--         public function get_stylesheet_directory_uri() then
--                 return this->get_theme_root_uri() . '/' . str_replace( '%2F', '/', rawurlencode( this->stylesheet ) );
--         end;

--         --
--         -- Returns the URL to the directory of a theme's "template" files.
--         --
--         -- In the case of a child theme, this is the URL to the directory of the
--         -- parent theme's files.
--         --
--         -- @since 3.4.0
--         --
--         -- @return string URL to the template directory.
--         --
--         public function get_template_directory_uri() then
--                 if ( this->parent() ) then
--                         theme_root_uri = this->parent()->get_theme_root_uri();
--                 end; else then
--                         theme_root_uri = this->get_theme_root_uri();
--                 end;

--                 return theme_root_uri . '/' . str_replace( '%2F', '/', rawurlencode( this->template ) );
--         end;

--         --
--         -- Returns the absolute path to the directory of the theme root.
--         --
--         -- This is typically the absolute path to wp-content/themes.
--         --
--         -- @since 3.4.0
--         --
--         -- @return string Theme root.
--         --
--         public function get_theme_root() then
--                 return this->theme_root;
--         end;

--         --
--         -- Returns the URL to the directory of the theme root.
--         --
--         -- This is typically the absolute URL to wp-content/themes. This forms the basis
--         -- for all other URLs returned by WP_Theme, so we pass it to the public function
--         -- get_theme_root_uri() and allow it to run the then@see 'theme_root_uri'end; filter.
--         --
--         -- @since 3.4.0
--         --
--         -- @return string Theme root URI.
--         --
--         public function get_theme_root_uri() then
--                 if ( ! isset( this->theme_root_uri ) ) then
--                         this->theme_root_uri = get_theme_root_uri( this->stylesheet, this->theme_root );
--                 end;
--                 return this->theme_root_uri;
--         end;

--         --
--         -- Returns the main screenshot file for the theme.
--         --
--         -- The main screenshot is called screenshot.png. gif and jpg extensions are also allowed.
--         --
--         -- Screenshots for a theme must be in the stylesheet directory. (In the case of child
--         -- themes, parent theme screenshots are not inherited.)
--         --
--         -- @since 3.4.0
--         --
--         -- @param string uri Type of URL to return, either 'relative' or an absolute URI. Defaults to absolute URI.
--         -- @return string|false Screenshot file. False if the theme does not have a screenshot.
--         --
--         public function get_screenshot( uri = 'uri' ) then
--                 screenshot = this->cache_get( 'screenshot' );
--                 if ( screenshot ) then
--                         if ( 'relative' === uri ) then
--                                 return screenshot;
--                         end;
--                         return this->get_stylesheet_directory_uri() . '/' . screenshot;
--                 end; elseif ( 0 === screenshot ) then
--                         return false;
--                 end;

--                 foreach ( array( 'png', 'gif', 'jpg', 'jpeg', 'webp' ) as ext ) then
--                         if ( file_exists( this->get_stylesheet_directory() . "/screenshot.ext" ) ) then
--                                 this->cache_add( 'screenshot', 'screenshot.' . ext );
--                                 if ( 'relative' === uri ) then
--                                         return 'screenshot.' . ext;
--                                 end;
--                                 return this->get_stylesheet_directory_uri() . '/' . 'screenshot.' . ext;
--                         end;
--                 end;

--                 this->cache_add( 'screenshot', 0 );
--                 return false;
--         end;

--         --
--         -- Returns files in the theme's directory.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string[]|string type          Optional. Array of extensions to find, string of a single extension,
--         --                                       or null for all extensions. Default null.
--         -- @param int             depth         Optional. How deep to search for files. Defaults to a flat scan (0 depth).
--         --                                       -1 depth is infinite.
--         -- @param bool            search_parent Optional. Whether to return parent files. Default false.
--         -- @return string[] Array of files, keyed by the path to the file relative to the theme's directory, with the values
--         --                  being absolute paths.
--         --
--         public function get_files( type = null, depth = 0, search_parent = false ) then
--                 files = (array) self::scandir( this->get_stylesheet_directory(), type, depth );

--                 if ( search_parent && this->parent() ) then
--                         files += (array) self::scandir( this->get_template_directory(), type, depth );
--                 end;

--                 return array_filter( files );
--         end;

--         --
--         -- Returns the theme's post templates.
--         --
--         -- @since 4.7.0
--         -- @since 5.8.0 Include block templates.
--         --
--         -- @return array[] Array of page template arrays, keyed by post type and filename,
--         --                 with the value of the translated header name.
--         --
--         public function get_post_templates() then
--                 // If you screw up your active theme and we invalidate your parent, most things still work. Let it slide.
--                 if ( this->errors() && this->errors()->get_error_codes() !== array( 'theme_parent_invalid' ) ) then
--                         return array();
--                 end;

--                 post_templates = this->cache_get( 'post_templates' );

--                 if ( ! is_array( post_templates ) ) then
--                         post_templates = array();

--                         files = (array) this->get_files( 'php', 1, true );

--                         foreach ( files as file => full_path ) then
--                                 if ( ! preg_match( '|Template Name:(.*)|mi', file_get_contents( full_path ), header ) ) then
--                                         continue;
--                                 end;

--                                 types = array( 'page' );
--                                 if ( preg_match( '|Template Post Type:(.*)|mi', file_get_contents( full_path ), type ) ) then
--                                         types = explode( ',', _cleanup_header_comment( type[1] ) );
--                                 end;

--                                 foreach ( types as type ) then
--                                         type = sanitize_key( type );
--                                         if ( ! isset( post_templates[ type ] ) ) then
--                                                 post_templates[ type ] = array();
--                                         end;

--                                         post_templates[ type ][ file ] = _cleanup_header_comment( header[1] );
--                                 end;
--                         end;

--                         if ( current_theme_supports( 'block-templates' ) ) then
--                                 block_templates = get_block_templates( array(), 'wp_template' );
--                                 foreach ( get_post_types( array( 'public' => true ) ) as type ) then
--                                         foreach ( block_templates as block_template ) then
--                                                 if ( ! block_template->is_custom ) then
--                                                         continue;
--                                                 end;

--                                                 if ( isset( block_template->post_types ) && ! in_array( type, block_template->post_types, true ) ) then
--                                                         continue;
--                                                 end;

--                                                 post_templates[ type ][ block_template->slug ] = block_template->title;
--                                         end;
--                                 end;
--                         end;

--                         this->cache_add( 'post_templates', post_templates );
--                 end;

--                 if ( this->load_textdomain() ) then
--                         foreach ( post_templates as &post_type ) then
--                                 foreach ( post_type as &post_template ) then
--                                         post_template = this->translate_header( 'Template Name', post_template );
--                                 end;
--                         end;
--                 end;

--                 return post_templates;
--         end;

--         --
--         -- Returns the theme's post templates for a given post type.
--         --
--         -- @since 3.4.0
--         -- @since 4.7.0 Added the `post_type` parameter.
--         --
--         -- @param WP_Post|null post      Optional. The post being edited, provided for context.
--         -- @param string       post_type Optional. Post type to get the templates for. Default 'page'.
--         --                                If a post is provided, its post type is used.
--         -- @return string[] Array of template header names keyed by the template file name.
--         --
--         public function get_page_templates( post = null, post_type = 'page' ) then
--                 if ( post ) then
--                         post_type = get_post_type( post );
--                 end;

--                 post_templates = this->get_post_templates();
--                 post_templates = isset( post_templates[ post_type ] ) ? post_templates[ post_type ] : array();

--                 --
--                 -- Filters list of page templates for a theme.
--                 --
--                 -- @since 4.9.6
--                 --
--                 -- @param string[]     post_templates Array of template header names keyed by the template file name.
--                 -- @param WP_Theme     theme          The theme object.
--                 -- @param WP_Post|null post           The post being edited, provided for context, or null.
--                 -- @param string       post_type      Post type to get the templates for.
--                 --
--                 post_templates = (array) apply_filters( 'theme_templates', post_templates, this, post, post_type );

--                 --
--                 -- Filters list of page templates for a theme.
--                 --
--                 -- The dynamic portion of the hook name, `post_type`, refers to the post type.
--                 --
--                 -- Possible hook names include:
--                 --
--                 --  - `theme_post_templates`
--                 --  - `theme_page_templates`
--                 --  - `theme_attachment_templates`
--                 --
--                 -- @since 3.9.0
--                 -- @since 4.4.0 Converted to allow complete control over the `page_templates` array.
--                 -- @since 4.7.0 Added the `post_type` parameter.
--                 --
--                 -- @param string[]     post_templates Array of template header names keyed by the template file name.
--                 -- @param WP_Theme     theme          The theme object.
--                 -- @param WP_Post|null post           The post being edited, provided for context, or null.
--                 -- @param string       post_type      Post type to get the templates for.
--                 --
--                 post_templates = (array) apply_filters( "theme_thenpost_typeend;_templates", post_templates, this, post, post_type );

--                 return post_templates;
--         end;

--         --
--         -- Scans a directory for files of a certain extension.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string            path          Absolute path to search.
--         -- @param array|string|null extensions    Optional. Array of extensions to find, string of a single extension,
--         --                                         or null for all extensions. Default null.
--         -- @param int               depth         Optional. How many levels deep to search for files. Accepts 0, 1+, or
--         --                                         -1 (infinite depth). Default 0.
--         -- @param string            relative_path Optional. The basename of the absolute path. Used to control the
--         --                                         returned path for the found files, particularly when this function
--         --                                         recurses to lower depths. Default empty.
--         -- @return string[]|false Array of files, keyed by the path to the file relative to the `path` directory prepended
--         --                        with `relative_path`, with the values being absolute paths. False otherwise.
--         --
--         private static function scandir( path, extensions = null, depth = 0, relative_path = '' ) then
--                 if ( ! is_dir( path ) ) then
--                         return false;
--                 end;

--                 if ( extensions ) then
--                         extensions  = (array) extensions;
--                         _extensions = implode( '|', extensions );
--                 end;

--                 relative_path = trailingslashit( relative_path );
--                 if ( '/' === relative_path ) then
--                         relative_path = '';
--                 end;

--                 results = scandir( path );
--                 files   = array();

--                 --
--                 -- Filters the array of excluded directories and files while scanning theme folder.
--                 --
--                 -- @since 4.7.4
--                 --
--                 -- @param string[] exclusions Array of excluded directories and files.
--                 --
--                 exclusions = (array) apply_filters( 'theme_scandir_exclusions', array( 'CVS', 'node_modules', 'vendor', 'bower_components' ) );

--                 foreach ( results as result ) then
--                         if ( '.' === result[0] || in_array( result, exclusions, true ) ) then
--                                 continue;
--                         end;
--                         if ( is_dir( path . '/' . result ) ) then
--                                 if ( ! depth ) then
--                                         continue;
--                                 end;
--                                 found = self::scandir( path . '/' . result, extensions, depth - 1, relative_path . result );
--                                 files = array_merge_recursive( files, found );
--                         end; elseif ( ! extensions || preg_match( '~\.(' . _extensions . ')~', result ) ) then
--                                 files[ relative_path . result ] = path . '/' . result;
--                         end;
--                 end;

--                 return files;
--         end;

--         --
--         -- Loads the theme's textdomain.
--         --
--         -- Translation files are not inherited from the parent theme. TODO: If this fails for the
--         -- child theme, it should probably try to load the parent theme's translations.
--         --
--         -- @since 3.4.0
--         --
--         -- @return bool True if the textdomain was successfully loaded or has already been loaded.
--         --  False if no textdomain was specified in the file headers, or if the domain could not be loaded.
--         --
--         public function load_textdomain() then
--                 if ( isset( this->textdomain_loaded ) ) then
--                         return this->textdomain_loaded;
--                 end;

--                 textdomain = this->get( 'TextDomain' );
--                 if ( ! textdomain ) then
--                         this->textdomain_loaded = false;
--                         return false;
--                 end;

--                 if ( is_textdomain_loaded( textdomain ) ) then
--                         this->textdomain_loaded = true;
--                         return true;
--                 end;

--                 path       = this->get_stylesheet_directory();
--                 domainpath = this->get( 'DomainPath' );
--                 if ( domainpath ) then
--                         path .= domainpath;
--                 end; else then
--                         path .= '/languages';
--                 end;

--                 this->textdomain_loaded = load_theme_textdomain( textdomain, path );
--                 return this->textdomain_loaded;
--         end;

--         --
--         -- Determines whether the theme is allowed (multisite only).
--         --
--         -- @since 3.4.0
--         --
--         -- @param string check   Optional. Whether to check only the 'network'-wide settings, the 'site'
--         --                        settings, or 'both'. Defaults to 'both'.
--         -- @param int    blog_id Optional. Ignored if only network-wide settings are checked. Defaults to current site.
--         -- @return bool Whether the theme is allowed for the network. Returns true in single-site.
--         --
--         public function is_allowed( check = 'both', blog_id = null ) then
--                 if ( ! is_multisite() ) then
--                         return true;
--                 end;

--                 if ( 'both' === check || 'network' === check ) then
--                         allowed = self::get_allowed_on_network();
--                         if ( ! empty( allowed[ this->get_stylesheet() ] ) ) then
--                                 return true;
--                         end;
--                 end;

--                 if ( 'both' === check || 'site' === check ) then
--                         allowed = self::get_allowed_on_site( blog_id );
--                         if ( ! empty( allowed[ this->get_stylesheet() ] ) ) then
--                                 return true;
--                         end;
--                 end;

--                 return false;
--         end;

--         --
--         -- Returns whether this theme is a block-based theme or not.
--         --
--         -- @since 5.9.0
--         --
--         -- @return bool
--         --
--         public function is_block_theme() then
--                 paths_to_index_block_template = array(
--                         this->get_file_path( '/block-templates/index.html' ),
--                         this->get_file_path( '/templates/index.html' ),
--                 );

--                 foreach ( paths_to_index_block_template as path_to_index_block_template ) then
--                         if ( is_file( path_to_index_block_template ) && is_readable( path_to_index_block_template ) ) then
--                                 return true;
--                         end;
--                 end;

--                 return false;
--         end;

--         --
--         -- Retrieves the path of a file in the theme.
--         --
--         -- Searches in the stylesheet directory before the template directory so themes
--         -- which inherit from a parent theme can just override one file.
--         --
--         -- @since 5.9.0
--         --
--         -- @param string file Optional. File to search for in the stylesheet directory.
--         -- @return string The path of the file.
--         --
--         public function get_file_path( file = '' ) then
--                 file = ltrim( file, '/' );

--                 stylesheet_directory = this->get_stylesheet_directory();
--                 template_directory   = this->get_template_directory();

--                 if ( empty( file ) ) then
--                         path = stylesheet_directory;
--                 end; elseif ( file_exists( stylesheet_directory . '/' . file ) ) then
--                         path = stylesheet_directory . '/' . file;
--                 end; else then
--                         path = template_directory . '/' . file;
--                 end;

--                 -- This filter is documented in wp-includes/link-template.php--
--                 return apply_filters( 'theme_file_path', path, file );
--         end;

   --
   -- Determines the latest WordPress default theme that is installed.
   --
   -- This hits the filesystem.
   --
   -- @since 4.4.0
   --
   -- @return WP_Theme|false Object, or false if no theme is installed, which would
   --                         be bad.
   --
   -- static
   function Get_Core_Default_Theme
            return Wp_Theme;

--         --
--         -- Returns array of stylesheet names of themes allowed on the site or network.
--         --
--         -- @since 3.4.0
--         --
--         -- @param int blog_id Optional. ID of the site. Defaults to the current site.
--         -- @return string[] Array of stylesheet names.
--         --
--         public static function get_allowed( blog_id = null ) then
--                 --
--                 -- Filters the array of themes allowed on the network.
--                 --
--                 -- Site is provided as context so that a list of network allowed themes can
--                 -- be filtered further.
--                 --
--                 -- @since 4.5.0
--                 --
--                 -- @param string[] allowed_themes An array of theme stylesheet names.
--                 -- @param int      blog_id        ID of the site.
--                 --
--                 network = (array) apply_filters( 'network_allowed_themes', self::get_allowed_on_network(), blog_id );
--                 return network + self::get_allowed_on_site( blog_id );
--         end;

--         --
--         -- Returns array of stylesheet names of themes allowed on the network.
--         --
--         -- @since 3.4.0
--         --
--         -- @return string[] Array of stylesheet names.
--         --
--         public static function get_allowed_on_network() then
--                 static allowed_themes;
--                 if ( ! isset( allowed_themes ) ) then
--                         allowed_themes = (array) get_site_option( 'allowedthemes' );
--                 end;

--                 --
--                 -- Filters the array of themes allowed on the network.
--                 --
--                 -- @since MU (3.0.0)
--                 --
--                 -- @param string[] allowed_themes An array of theme stylesheet names.
--                 --
--                 allowed_themes = apply_filters( 'allowed_themes', allowed_themes );

--                 return allowed_themes;
--         end;

--         --
--         -- Returns array of stylesheet names of themes allowed on the site.
--         --
--         -- @since 3.4.0
--         --
--         -- @param int blog_id Optional. ID of the site. Defaults to the current site.
--         -- @return string[] Array of stylesheet names.
--         --
--         public static function get_allowed_on_site( blog_id = null ) then
--                 static allowed_themes = array();

--                 if ( ! blog_id || ! is_multisite() ) then
--                         blog_id = get_current_blog_id();
--                 end;

--                 if ( isset( allowed_themes[ blog_id ] ) ) then
--                         --
--                         -- Filters the array of themes allowed on the site.
--                         --
--                         -- @since 4.5.0
--                         --
--                         -- @param string[] allowed_themes An array of theme stylesheet names.
--                         -- @param int      blog_id        ID of the site. Defaults to current site.
--                         --
--                         return (array) apply_filters( 'site_allowed_themes', allowed_themes[ blog_id ], blog_id );
--                 end;

--                 current = get_current_blog_id() == blog_id;

--                 if ( current ) then
--                         allowed_themes[ blog_id ] = get_option( 'allowedthemes' );
--                 end; else then
--                         switch_to_blog( blog_id );
--                         allowed_themes[ blog_id ] = get_option( 'allowedthemes' );
--                         restore_current_blog();
--                 end;

--                 // This is all super old MU back compat joy.
--                 // 'allowedthemes' keys things by stylesheet. 'allowed_themes' keyed things by name.
--                 if ( false === allowed_themes[ blog_id ] ) then
--                         if ( current ) then
--                                 allowed_themes[ blog_id ] = get_option( 'allowed_themes' );
--                         end; else then
--                                 switch_to_blog( blog_id );
--                                 allowed_themes[ blog_id ] = get_option( 'allowed_themes' );
--                                 restore_current_blog();
--                         end;

--                         if ( ! is_array( allowed_themes[ blog_id ] ) || empty( allowed_themes[ blog_id ] ) ) then
--                                 allowed_themes[ blog_id ] = array();
--                         end; else then
--                                 converted = array();
--                                 themes    = wp_get_themes();
--                                 foreach ( themes as stylesheet => theme_data ) then
--                                         if ( isset( allowed_themes[ blog_id ][ theme_data->get( 'Name' ) ] ) ) then
--                                                 converted[ stylesheet ] = true;
--                                         end;
--                                 end;
--                                 allowed_themes[ blog_id ] = converted;
--                         end;
--                         // Set the option so we never have to go through this pain again.
--                         if ( is_admin() && allowed_themes[ blog_id ] ) then
--                                 if ( current ) then
--                                         update_option( 'allowedthemes', allowed_themes[ blog_id ] );
--                                         delete_option( 'allowed_themes' );
--                                 end; else then
--                                         switch_to_blog( blog_id );
--                                         update_option( 'allowedthemes', allowed_themes[ blog_id ] );
--                                         delete_option( 'allowed_themes' );
--                                         restore_current_blog();
--                                 end;
--                         end;
--                 end;

--                 -- This filter is documented in wp-includes/class-wp-theme.php--
--                 return (array) apply_filters( 'site_allowed_themes', allowed_themes[ blog_id ], blog_id );
--         end;

--         --
--         -- Enables a theme for all sites on the current network.
--         --
--         -- @since 4.6.0
--         --
--         -- @param string|string[] stylesheets Stylesheet name or array of stylesheet names.
--         --
--         public static function network_enable_theme( stylesheets ) then
--                 if ( ! is_multisite() ) then
--                         return;
--                 end;

--                 if ( ! is_array( stylesheets ) ) then
--                         stylesheets = array( stylesheets );
--                 end;

--                 allowed_themes = get_site_option( 'allowedthemes' );
--                 foreach ( stylesheets as stylesheet ) then
--                         allowed_themes[ stylesheet ] = true;
--                 end;

--                 update_site_option( 'allowedthemes', allowed_themes );
--         end;

--         --
--         -- Disables a theme for all sites on the current network.
--         --
--         -- @since 4.6.0
--         --
--         -- @param string|string[] stylesheets Stylesheet name or array of stylesheet names.
--         --
--         public static function network_disable_theme( stylesheets ) then
--                 if ( ! is_multisite() ) then
--                         return;
--                 end;

--                 if ( ! is_array( stylesheets ) ) then
--                         stylesheets = array( stylesheets );
--                 end;

--                 allowed_themes = get_site_option( 'allowedthemes' );
--                 foreach ( stylesheets as stylesheet ) then
--                         if ( isset( allowed_themes[ stylesheet ] ) ) then
--                                 unset( allowed_themes[ stylesheet ] );
--                         end;
--                 end;

--                 update_site_option( 'allowedthemes', allowed_themes );
--         end;

--         --
--         -- Sorts themes by name.
--         --
--         -- @since 3.4.0
--         --
--         -- @param WP_Theme[] themes Array of theme objects to sort (passed by reference).
--         --
--         public static function sort_by_name( &themes ) then
--                 if ( 0 === strpos( get_user_locale(), 'en_' ) ) then
--                         uasort( themes, array( 'WP_Theme', '_name_sort' ) );
--                 end; else then
--                         foreach ( themes as key => theme ) then
--                                 theme->translate_header( 'Name', theme->headers['Name'] );
--                         end;
--                         uasort( themes, array( 'WP_Theme', '_name_sort_i18n' ) );
--                 end;
--         end;

--         --
--         -- Callback function for usort() to naturally sort themes by name.
--         --
--         -- Accesses the Name header directly from the class for maximum speed.
--         -- Would choke on HTML but we don't care enough to slow it down with strip_tags().
--         --
--         -- @since 3.4.0
--         --
--         -- @param WP_Theme a First theme.
--         -- @param WP_Theme b Second theme.
--         -- @return int Negative if `a` falls lower in the natural order than `b`. Zero if they fall equally.
--         --             Greater than 0 if `a` falls higher in the natural order than `b`. Used with usort().
--         --
--         private static function _name_sort( a, b ) then
--                 return strnatcasecmp( a->headers['Name'], b->headers['Name'] );
--         end;

--         --
--         -- Callback function for usort() to naturally sort themes by translated name.
--         --
--         -- @since 3.4.0
--         --
--         -- @param WP_Theme a First theme.
--         -- @param WP_Theme b Second theme.
--         -- @return int Negative if `a` falls lower in the natural order than `b`. Zero if they fall equally.
--         --             Greater than 0 if `a` falls higher in the natural order than `b`. Used with usort().
--         --
--         private static function _name_sort_i18n( a, b ) then
--                 return strnatcasecmp( a->name_translated, b->name_translated );
--         end;

--         private static function _check_headers_property_has_correct_type( headers ) then
--                 if ( ! is_array( headers ) ) then
--                         return false;
--                 end;
--                 foreach ( headers as key => value ) then
--                         if ( ! is_string( key ) || ! is_string( value ) ) then
--                                 return false;
--                         end;
--                 end;
--                 return true;
--         end;

   Null_Theme : constant Wp_Theme :=
      (Theme_Root        => Null_Unbounded_String,
       Headers           => Empty_Array,
       Headers_Sanitized => Empty_Array,
       Stylesheet        => Null_Unbounded_String,
       Template          => Null_Unbounded_String,
       M_Parent          => null,
       Cache_Hash        => Null_Unbounded_String,
       M_Errors          => Inc_Class_Wp_Errors.Null_Wp_Error);

end Inc_Class_Wp_Themes;
