
--
-- Site API: WP_Site class
--
-- @package WordPress
-- @subpackage Multisite
-- @since 4.5.0
--

package body Class_Sites
is
   procedure Dummy is null;
--         --
--         -- Retrieves a site from the database by its ID.
--         --
--         -- @since 4.5.0
--         --
--         -- @global wpdb wpdb WordPress database abstraction object.
--         --
--         -- @param int site_id The ID of the site to retrieve.
--         -- @return WP_Site|false The site"s object if found. False if not.
--         --
--         public static function get_instance( site_id ) then
--                 global wpdb;

--                 site_id = (int) site_id;
--                 if ( ! site_id ) then
--                         return false;
--                 end;

--                 _site = wp_cache_get( site_id, "sites" );

--                 if ( false === _site ) then
--                         _site = wpdb->get_row( wpdb->prepare( "SELECT-- FROM thenwpdb->blogsend; WHERE blog_id = %d LIMIT 1", site_id ) );

--                         if ( empty( _site ) || is_wp_error( _site ) ) then
--                                 _site = -1;
--                         end;

--                         wp_cache_add( site_id, _site, "sites" );
--                 end;

--                 if ( is_numeric( _site ) ) then
--                         return false;
--                 end;

--                 return new WP_Site( _site );
--         end;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Site : Integer)
                         return Wp_Site
   is
      This : Wp_Site;
   begin
--    foreach ( get_object_vars( site ) as key => value ) then
--       this->key = value;
--    end;
      This.Blog_Id := Site;
      return This;
   end X_Construct;

--         --
--         -- Converts an object to array.
--         --
--         -- @since 4.6.0
--         --
--         -- @return array Object as array.
--         --
--         public function to_array() then
--                 return get_object_vars( this );
--         end;

--         --
--         -- Getter.
--         --
--         -- Allows current multisite naming conventions when getting properties.
--         -- Allows access to extended site properties.
--         --
--         -- @since 4.6.0
--         --
--         -- @param string key Property to get.
--         -- @return mixed Value of the property. Null if not available.
--         --
--         public function __get( key ) then
--                 switch ( key ) then
--                         case "id":
--                                 return (int) this->blog_id;
--                         case "network_id":
--                                 return (int) this->site_id;
--                         case "blogname":
--                         case "siteurl":
--                         case "post_count":
--                         case "home":
--                         default: -- Custom properties added by "site_details" filter.
--                                 if ( ! did_action( "ms_loaded" ) ) then
--                                         return null;
--                                 end;

--                                 details = this->get_details();
--                                 if ( isset( details->key ) ) then
--                                         return details->key;
--                                 end;
--                 end;

--                 return null;
--         end;

--         --
--         -- Isset-er.
--         --
--         -- Allows current multisite naming conventions when checking for properties.
--         -- Checks for extended site properties.
--         --
--         -- @since 4.6.0
--         --
--         -- @param string key Property to check if set.
--         -- @return bool Whether the property is set.
--         --
--         public function __isset( key ) then
--                 switch ( key ) then
--                         case "id":
--                         case "network_id":
--                                 return true;
--                         case "blogname":
--                         case "siteurl":
--                         case "post_count":
--                         case "home":
--                                 if ( ! did_action( "ms_loaded" ) ) then
--                                         return false;
--                                 end;
--                                 return true;
--                         default: -- Custom properties added by "site_details" filter.
--                                 if ( ! did_action( "ms_loaded" ) ) then
--                                         return false;
--                                 end;

--                                 details = this->get_details();
--                                 if ( isset( details->key ) ) then
--                                         return true;
--                                 end;
--                 end;

--                 return false;
--         end;

--         --
--         -- Setter.
--         --
--         -- Allows current multisite naming conventions while setting properties.
--         --
--         -- @since 4.6.0
--         --
--         -- @param string key   Property to set.
--         -- @param mixed  value Value to assign to the property.
--         --
--         public function __set( key, value ) then
--                 switch ( key ) then
--                         case "id":
--                                 this->blog_id = (string) value;
--                                 break;
--                         case "network_id":
--                                 this->site_id = (string) value;
--                                 break;
--                         default:
--                                 this->key = value;
--                 end;
--         end;

--         --
--         -- Retrieves the details for this site.
--         --
--         -- This method is used internally to lazy-load the extended properties of a site.
--         --
--         -- @since 4.6.0
--         --
--         -- @see WP_Site::__get()
--         --
--         -- @return stdClass A raw site object with all details included.
--         --
--         private function get_details() then
--                 details = wp_cache_get( this->blog_id, "site-details" );

--                 if ( false === details ) then

--                         switch_to_blog( this->blog_id );
--                         -- Create a raw copy of the object for backward compatibility with the filter below.
--                         details = new stdClass();
--                         foreach ( get_object_vars( this ) as key => value ) then
--                                 details->key = value;
--                         end;
--                         details->blogname   = get_option( "blogname" );
--                         details->siteurl    = get_option( "siteurl" );
--                         details->post_count = get_option( "post_count" );
--                         details->home       = get_option( "home" );
--                         restore_current_blog();

--                         wp_cache_set( this->blog_id, details, "site-details" );
--                 end;

--                 -- This filter is documented in wp-includes/ms-blogs.php--
--                 details = apply_filters_deprecated( "blog_details", array( details ), "4.7.0", "site_details" );

--                 --
--                 -- Filters a site"s extended properties.
--                 --
--                 -- @since 4.6.0
--                 --
--                 -- @param stdClass details The site details.
--                 --
--                 details = apply_filters( "site_details", details );

--                 return details;
--         end;
-- end;

end Class_Sites;
