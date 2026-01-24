--
-- User API: WP_Roles class
--
-- @package WordPress
-- @subpackage Users
-- @since 4.4.0
--

with Ada.Strings.Unbounded;

with Arrays;

with Class_Role;

package Class_Roles
is
   use Ada.Strings.Unbounded;
   use Arrays;

   Global_Wp_User_Roles : Array_Type;

   --
   -- Core class used to implement a user roles API.
   --
   -- The role option is simple, the structure is organized by role name that store
   -- the name in value of the "name" key. The capabilities are stored as an array
   -- in the value of the "capability" key.
   --
   --     array (
   --          "rolename" => array (
   --              "name" => "rolename",
   --              "capabilities" => array()
   --          )
   --     )
   --
   -- @since 2.0.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Roles is tagged
      record
         --
         -- List of roles and capabilities.
         --
         -- @since 2.0.0
         -- @var array[]
         --
         Roles : Array_Type;

         --
         -- List of the role objects.
         --
         -- @since 2.0.0
         -- @var WP_Role[]
         --
         Role_Objects : Class_Role.Role_Maps.Map; -- Array_Type;

         --
         -- List of role names.
         --
         -- @since 2.0.0
         -- @var string[]
         --
         Role_Names : Array_Type; -- List_Type;

         --
         -- Option name for storing role list.
         --
         -- @since 2.0.0
         -- @var string
         --
         Role_Key : Unbounded_String;

         --
         -- Whether to use the database for retrieval and storage.
         --
         -- @since 2.1.0
         -- @var bool
         --
         Use_DB : Boolean := True;

         --
         -- The site ID the roles are initialized for.
         --
         -- @since 4.9.0
         -- @var int
         --
         -- protected
         Site_Id : Integer := 0;

      end record;

   --
   -- Constructor.
   --
   -- @since 2.0.0
   -- @since 4.9.0 The `site_id` argument was added.
   --
   -- @global array wp_user_roles Used to set the "roles" property value.
   --
   -- @param int site_id Site ID to initialize roles for. Default is the current site.
   --
   function X_Construct (Site_Id : Integer := 0) -- null
                         return Wp_Roles;
--                 global wp_user_roles;

--                 this.use_db = empty( wp_user_roles );

--                 this.for_site( site_id );
--         end;

--         --
--         -- Makes private/protected methods readable for backward compatibility.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string name      Method to call.
--         -- @param array  arguments Arguments to pass when calling.
--         -- @return mixed|false Return value of the callback, false otherwise.
--         --
--         public function __call( name, arguments ) then
--                 if ( "_init" === name ) then
--                         return this._init( ...arguments );
--                 end;
--                 return false;
--         end;

--         --
--         -- Sets up the object properties.
--         --
--         -- The role key is set to the current prefix for the wpdb object with
--         -- "user_roles" appended. If the wp_user_roles global is set, then it will
--         -- be used and the role option will not be updated or used.
--         --
--         -- @since 2.1.0
--         -- @deprecated 4.9.0 Use WP_Roles::for_site()
--         --
--         protected function _init() then
--                 _deprecated_function( __METHOD__, "4.9.0", "WP_Roles::for_site()" );

--                 this.for_site();
--         end;

--         --
--         -- Reinitializes the object.
--         --
--         -- Recreates the role objects. This is typically called only by switch_to_blog()
--         -- after switching wpdb to a new site ID.
--         --
--         -- @since 3.5.0
--         -- @deprecated 4.7.0 Use WP_Roles::for_site()
--         --
--         public function reinit() then
--                 _deprecated_function( __METHOD__, "4.7.0", "WP_Roles::for_site()" );

--                 this.for_site();
--         end;

   --
   -- Adds a role name with capabilities to the list.
   --
   -- Updates the list of roles, if the role doesn't already exist.
   --
   -- The capabilities are defined in the following format: `array( "read" => true )`.
   -- To explicitly deny the role a capability, set the value for that capability
   -- to false.
   --
   -- @since 2.0.0
   --
   -- @param string role         Role name.
   -- @param string display_name Role display name.
   -- @param bool[] capabilities Optional. List of capabilities keyed by the
   --                             capability name, e.g. `array( "edit_posts" => true,
   --                             "delete_posts" => false )`.
   --                             Default empty array.
   -- @return WP_Role|void WP_Role object, if the role is added.
   --
   function Add_Role (This         : in out Wp_Roles;
                      Role         : String;
                      Display_Name : String;
                      Capabilities : Array_Type := Empty_Array)
                      return Class_Role.Wp_Role;

--         --
--         -- Removes a role by name.
--         --
--         -- @since 2.0.0
--         --
--         -- @param string role Role name.
--         --
--         public function remove_role( role ) then
--                 if ( ! isset( this.role_objects[ role ] ) ) then
--                         return;
--                 end;

--                 unset( this.role_objects[ role ] );
--                 unset( this.role_names[ role ] );
--                 unset( this.roles[ role ] );

--                 if ( this.use_db ) then
--                         update_option( this.role_key, this.roles );
--                 end;

--                 if ( get_option( "default_role" ) == role ) then
--                         update_option( "default_role", "subscriber" );
--                 end;
--         end;

   --
   -- Adds a capability to role.
   --
   -- @since 2.0.0
   --
   -- @param string role  Role name.
   -- @param string cap   Capability name.
   -- @param bool   grant Optional. Whether role is capable of performing capability.
   --                      Default true.
   --
   procedure Add_Cap (This  : in out Wp_Roles;
                      Role  : String;
                      Cap   : String;
                      Grant : Boolean := True);

   --
   -- Removes a capability from role.
   --
   -- @since 2.0.0
   --
   -- @param string role Role name.
   -- @param string cap  Capability name.
   --
   procedure Remove_Cap (This : in out Wp_Roles;
                         Role : String;
                         Cap  : String);

   --
   -- Retrieves a role object by name.
   --
   -- @since 2.0.0
   --
   -- @param string role Role name.
   -- @return WP_Role|null WP_Role object if found, null if the role does not exist.
   --
   function Get_Role (This : Wp_Roles;
                      Role : String)
                      return Class_Role.Wp_Role;

--         --
--         -- Retrieves a list of role names.
--         --
--         -- @since 2.0.0
--         --
--         -- @return string[] List of role names.
--         --
--         public function get_names() then
--                 return this.role_names;
--         end;

--         --
--         -- Determines whether a role name is currently in the list of available roles.
--         --
--         -- @since 2.0.0
--         --
--         -- @param string role Role name to look up.
--         -- @return bool
--         --
--         public function is_role( role ) then
--                 return isset( this.role_names[ role ] );
--         end;

   --
   -- Initializes all of the available roles.
   --
   -- @since 4.9.0
   --
   procedure Init_Roles (This : in out Wp_Roles);

   --
   -- Sets the site to operate on. Defaults to the current site.
   --
   -- @since 4.9.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param int site_id Site ID to initialize roles for. Default is the current site.
   --
   procedure For_Site (This    : in out Wp_Roles;
                       Site_Id : Integer := 0); -- null
--                 global wpdb;

--                 if ( ! empty( site_id ) ) then
--                         this.site_id = absint( site_id );
--                 end; else then
--                         this.site_id = get_current_blog_id();
--                 end;

--                 this.role_key = wpdb.get_blog_prefix( this.site_id ) . "user_roles";

--                 if ( ! empty( this.roles ) && ! this.use_db ) then
--                         return;
--                 end;

--                 this.roles = this.get_roles_data();

--                 this.init_roles();
--         end;

--         --
--         -- Gets the ID of the site for which roles are currently initialized.
--         --
--         -- @since 4.9.0
--         --
--         -- @return int Site ID.
--         --
--         public function get_site_id() then
--                 return this.site_id;
--         end;

   --
   -- Gets the available roles data.
   --
   -- @since 4.9.0
   --
   -- @global array wp_user_roles Used to set the "roles" property value.
   --
   -- @return array Roles array.
   --
   -- protected
   function Get_Roles_Data (This : Wp_Roles)
                            return Array_Type;
--                 global wp_user_roles;

--                 if ( ! empty( wp_user_roles ) ) then
--                         return wp_user_roles;
--                 end;

--                 if ( is_multisite() && get_current_blog_id() != this.site_id ) then
--                         remove_action( "switch_blog", "wp_switch_roles_and_user", 1 );

--                         roles = get_blog_option( this.site_id, this.role_key, array() );

--                         add_action( "switch_blog", "wp_switch_roles_and_user", 1, 2 );

--                         return roles;
--                 end;

--                 return get_option( this.role_key, array() );
--         end;

end Class_Roles;
