--
-- User API: WP_User class
--
-- @package WordPress
-- @subpackage Users
-- @since 4.4.0
--

with Globals;
with Hb_Common;
with Php;

with Inc_Caches;
with Inc_Capabilities;
with Inc_Class_Wp_Role;
with Inc_Class_Wp_Roles;
with Inc_Class_Wpdb;
with Inc_Formatting;
with Inc_Load;
with Inc_Ms_Blogs;
-- with Inc_Plugins;
with Inc_Users;

package body Inc_Class_Wp_Users
is

   function Apply_Filters (Hook  : String;
                           Value : Array_Type;
                           Caps  : List_Type;
                           -- Args,
                           This  : Wp_User)
                           return Array_Type
                           is (Value);
--         --
--         -- Constructor.
--         --
--         -- Retrieves the userdata and passes it to WP_User::init().
--         --
--         -- @since 2.0.0
--         --
--         -- @param int|string|stdClass|WP_User id      User's ID, a WP_User object, or a user object from the DB.
--         -- @param string                      name    Optional. User's username
--         -- @param int                         site_id Optional Site ID, defaults to current site.
--         --
--         public function __construct( id = 0, name = '', site_id = '' ) then
--                 if ( ! isset( self::back_compat_keys ) ) then
--                         prefix                 = GLOBALS['wpdb']->prefix;
--                         self::back_compat_keys = array(
--                                 'user_firstname'             => 'first_name',
--                                 'user_lastname'              => 'last_name',
--                                 'user_description'           => 'description',
--                                 'user_level'                 => prefix . 'user_level',
--                                 prefix . 'usersettings'     => prefix . 'user-settings',
--                                 prefix . 'usersettingstime' => prefix . 'user-settings-time',
--                         );
--                 end;

--                 if ( id instanceof WP_User ) then
--                         this->init( id->data, site_id );
--                         return;
--                 end; elseif ( is_object( id ) ) then
--                         this->init( id, site_id );
--                         return;
--                 end;

--                 if ( ! empty( id ) && ! is_numeric( id ) ) then
--                         name = id;
--                         id   = 0;
--                 end;

--                 if ( id ) then
--                         data = self::get_data_by( 'id', id );
--                 end; else then
--                         data = self::get_data_by( 'login', name );
--                 end;

--                 if ( data ) then
--                         this->init( data, site_id );
--                 end; else then
--                         this->data = new stdClass;
--                 end;
--         end;

   ----------
   -- Init --
   ----------

   procedure Init (This    : in out Wp_User;
                   Data    : Wp_User;
                   Site_Id : Integer := 0) -- ''
   is
      Data_2 : Wp_User := Data;
   begin
      if Data.Id = 0 then
--    if not Isset (Data.Id) then
         Data_2.Id := 0;
      end if;
      This.Data := new Wp_User'(Data_2);
      This.Id   := Data_2.Id; -- (int)

      This.For_Site (Site_Id);
   end Init;

   -----------------
   -- Get_Data_By --
   -----------------

   function Get_Data_By (Field : String;
                         Value : Integer)
                         return Inc_Class_Wp_Users.Wp_User
   is
      use Hb_Common;
      use Php;
      use Inc_Caches;
      use Inc_Formatting;
      use Inc_Users;

      -- 'ID' is an alias of 'id'.
      Field_2 : String :=
        (if "ID" = Field then "id" else Field);

      Value_2  : Unbounded_String := +Value'Image;
      User_Id  : Integer;
      DB_Field : Unbounded_String;
      Unused_Found : Boolean;
   begin
      if "id" = Field_2 then
         -- Make sure the value is numeric to avoid casting objects, for example,
         -- to int 1.
         if not Is_Numeric (Value) then
            return Null_User; -- False;
         end if;
--       Value_2 := +Value'Image; -- (int)
         if Value < 1 then
            return Null_User; -- False;
         end if;
      else
         Value_2 := +Trim (-Value_2);
      end if;

      if Value_2 = "" then
         return Null_User; -- False;
      end if;

      if Field_2 = "id" then
         User_Id  := Value;
         DB_Field := +"ID";

      elsif Field_2 = "slug" then
         User_Id  := Wp_Cache_Get (-Value_2, "userslugs", Found => Unused_Found);
         DB_Field := +"user_nicename";

      elsif Field_2 = "email" then
         User_Id  := Wp_Cache_Get (-Value_2, "useremail", Found => Unused_Found);
         DB_Field := +"user_email";

      elsif Field_2 = "login" then
         Value_2  := +Sanitize_User (-Value_2);
         User_Id  := Wp_Cache_Get (-Value_2, "userlogins", Found => Unused_Found);
         DB_Field := +"user_login";

      else
         return Null_User; -- False;
      end if;

      if 0 /= User_Id then
         declare
            User : constant Wp_User :=
              Wp_Cache_Get (User_Id, "users", Found => Unused_Found);
         begin
            if User /= Null_User then
               return User;
            end if;
         end;
      end if;

      declare
         use Globals;

         Unused_Success : Boolean;

         Statement : constant String :=
           WpDB.Prepare (
             "SELECT * FROM wpdb->users WHERE db_field = %s LIMIT 1", -Value_2);

         User : constant Wp_User :=
           WpDB.Get_Row (Statement,
                         Success => Unused_Success);
      begin
         if User = Null_User then
            return Null_User; -- False;
         end if;

         Update_User_Caches (User);

         return User;
      end;
   end Get_Data_By;

--         --
--         -- Magic method for checking the existence of a certain custom field.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string key User meta key to check if set.
--         -- @return bool Whether the given user meta key is set.
--         --
--         public function __isset( key ) then
--                 if ( 'id' === key ) then
--                         _deprecated_argument(
--                                 'WP_User->id',
--                                 '2.1.0',
--                                 sprintf(
--                                         /* translators: %s: WP_User->ID--
--                                         __( 'Use %s instead.' ),
--                                         '<code>WP_User->ID</code>'
--                                 )
--                         );
--                         key = 'ID';
--                 end;

--                 if ( isset( this->data->key ) ) then
--                         return true;
--                 end;

--                 if ( isset( self::back_compat_keys[ key ] ) ) then
--                         key = self::back_compat_keys[ key ];
--                 end;

--                 return metadata_exists( 'user', this->ID, key );
--         end;

--         --
--         -- Magic method for accessing custom fields.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string key User meta key to retrieve.
--         -- @return mixed Value of the given user meta key (if set). If `key` is 'id', the user ID.
--         --
--         public function __get( key ) then
--                 if ( 'id' === key ) then
--                         _deprecated_argument(
--                                 'WP_User->id',
--                                 '2.1.0',
--                                 sprintf(
--                                         /* translators: %s: WP_User->ID--
--                                         __( 'Use %s instead.' ),
--                                         '<code>WP_User->ID</code>'
--                                 )
--                         );
--                         return this->ID;
--                 end;

--                 if ( isset( this->data->key ) ) then
--                         value = this->data->key;
--                 end; else then
--                         if ( isset( self::back_compat_keys[ key ] ) ) then
--                                 key = self::back_compat_keys[ key ];
--                         end;
--                         value = get_user_meta( this->ID, key, true );
--                 end;

--                 if ( this->filter ) then
--                         value = sanitize_user_field( key, value, this->ID, this->filter );
--                 end;

--                 return value;
--         end;

--         --
--         -- Magic method for setting custom user fields.
--         --
--         -- This method does not update custom fields in the database. It only stores
--         -- the value on the WP_User instance.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string key   User meta key.
--         -- @param mixed  value User meta value.
--         --
--         public function __set( key, value ) then
--                 if ( 'id' === key ) then
--                         _deprecated_argument(
--                                 'WP_User->id',
--                                 '2.1.0',
--                                 sprintf(
--                                         /* translators: %s: WP_User->ID--
--                                         __( 'Use %s instead.' ),
--                                         '<code>WP_User->ID</code>'
--                                 )
--                         );
--                         this->ID = value;
--                         return;
--                 end;

--                 this->data->key = value;
--         end;

--         --
--         -- Magic method for unsetting a certain custom field.
--         --
--         -- @since 4.4.0
--         --
--         -- @param string key User meta key to unset.
--         --
--         public function __unset( key ) then
--                 if ( 'id' === key ) then
--                         _deprecated_argument(
--                                 'WP_User->id',
--                                 '2.1.0',
--                                 sprintf(
--                                         /* translators: %s: WP_User->ID--
--                                         __( 'Use %s instead.' ),
--                                         '<code>WP_User->ID</code>'
--                                 )
--                         );
--                 end;

--                 if ( isset( this->data->key ) ) then
--                         unset( this->data->key );
--                 end;

--                 if ( isset( self::back_compat_keys[ key ] ) ) then
--                         unset( self::back_compat_keys[ key ] );
--                 end;
--         end;

--         --
--         -- Determines whether the user exists in the database.
--         --
--         -- @since 3.4.0
--         --
--         -- @return bool True if user exists in the database, false if not.
--         --
--         public function exists() then
--                 return ! empty( this->ID );
--         end;

--         --
--         -- Retrieves the value of a property or meta key.
--         --
--         -- Retrieves from the users and usermeta table.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string key Property
--         -- @return mixed
--         --
--         public function get( key ) then
--                 return this->__get( key );
--         end;

--         --
--         -- Determines whether a property or meta key is set.
--         --
--         -- Consults the users and usermeta tables.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string key Property.
--         -- @return bool
--         --
--         public function has_prop( key ) then
--                 return this->__isset( key );
--         end;

--         --
--         -- Returns an array representation.
--         --
--         -- @since 3.5.0
--         --
--         -- @return array Array representation.
--         --
--         public function to_array() then
--                 return get_object_vars( this->data );
--         end;

--         --
--         -- Makes private/protected methods readable for backward compatibility.
--         --
--         -- @since 4.3.0
--         --
--         -- @param string name      Method to call.
--         -- @param array  arguments Arguments to pass when calling.
--         -- @return mixed|false Return value of the callback, false otherwise.
--         --
--         public function __call( name, arguments ) then
--                 if ( '_init_caps' === name ) then
--                         return this->_init_caps( ...arguments );
--                 end;
--                 return false;
--         end;

--         --
--         -- Sets up capability object properties.
--         --
--         -- Will set the value for the 'cap_key' property to current database table
--         -- prefix, followed by 'capabilities'. Will then check to see if the
--         -- property matching the 'cap_key' exists and is an array. If so, it will be
--         -- used.
--         --
--         -- @since 2.1.0
--         -- @deprecated 4.9.0 Use WP_User::for_site()
--         --
--         -- @global wpdb wpdb WordPress database abstraction object.
--         --
--         -- @param string cap_key Optional capability key
--         --
--         protected function _init_caps( cap_key = '' ) then
--                 global wpdb;

--                 _deprecated_function( __METHOD__, '4.9.0', 'WP_User::for_site()' );

--                 if ( empty( cap_key ) ) then
--                         this->cap_key = wpdb->get_blog_prefix( this->site_id ) . 'capabilities';
--                 end; else then
--                         this->cap_key = cap_key;
--                 end;

--                 this->caps = this->get_caps_data();

--                 this->get_role_caps();
--         end;

   -------------------
   -- Get_Role_Caps --
   -------------------

   function Get_Role_Caps (This : in out Wp_User)
                           return Array_Type -- Boolean_Maps.Map
   is
      use Hb_Common;
      use Php;
      use Inc_Capabilities;
      use Inc_Class_Wp_Role;
      use Inc_Class_Wp_Roles;
      use Inc_Load;
      use Inc_Ms_Blogs;

      Switch_Site : Boolean := False;
   begin
      if Is_Multisite and then Get_Current_Blog_Id /= This.Site_Id then -- ()
         Switch_Site := True;

         Switch_To_Blog (This.Site_Id);
      end if;

      declare
         Roles : constant Wp_Roles := Wp_Roles_X; -- ();
      begin
         -- Filter out caps that are not role names and assign to this->roles.
         -- if Is_Array (This.Caps) then
         --    This.Roles :=
         --      Array_Filter (Array_Keys (This.Caps), To_Array (Roles, "is_role"));
         -- end if;

         -- Build allcaps from role caps, overlay user's caps.
         This.Allcaps := Empty_Array;
         for Role of This.Roles loop -- (array)
            declare
               The_Role : constant Wp_Role := Roles.Get_Role (-Role);
            begin
               This.Allcaps :=
                 Array_Merge (This.Allcaps, The_Role.Capabilities); -- 2x(array)
            end;
         end loop;
      end;
      This.Allcaps := Array_Merge (This.Allcaps, This.Caps); -- 2x(array)

      if Switch_Site then
         Restore_Current_Blog; -- ();
      end if;

      return This.Allcaps;
   end Get_Role_Caps;

   procedure Get_Role_Caps (This : in out Wp_User)
   is
      Unused : constant Array_Type := Get_Role_Caps (This);
   begin
      null;
   end Get_Role_Caps;

--         --
--         -- Adds role to user.
--         --
--         -- Updates the user's meta data option with capabilities and roles.
--         --
--         -- @since 2.0.0
--         --
--         -- @param string role Role name.
--         --
--         public function add_role( role ) then
--                 if ( empty( role ) ) then
--                         return;
--                 end;

--                 if ( in_array( role, this->roles, true ) ) then
--                         return;
--                 end;

--                 this->caps[ role ] = true;
--                 update_user_meta( this->ID, this->cap_key, this->caps );
--                 this->get_role_caps();
--                 this->update_user_level_from_caps();

--                 --
--                 -- Fires immediately after the user has been given a new role.
--                 --
--                 -- @since 4.3.0
--                 --
--                 -- @param int    user_id The user ID.
--                 -- @param string role    The new role.
--                 --
--                 do_action( 'add_user_role', this->ID, role );
--         end;

--         --
--         -- Removes role from user.
--         --
--         -- @since 2.0.0
--         --
--         -- @param string role Role name.
--         --
--         public function remove_role( role ) then
--                 if ( ! in_array( role, this->roles, true ) ) then
--                         return;
--                 end;

--                 unset( this->caps[ role ] );
--                 update_user_meta( this->ID, this->cap_key, this->caps );
--                 this->get_role_caps();
--                 this->update_user_level_from_caps();

--                 --
--                 -- Fires immediately after a role as been removed from a user.
--                 --
--                 -- @since 4.3.0
--                 --
--                 -- @param int    user_id The user ID.
--                 -- @param string role    The removed role.
--                 --
--                 do_action( 'remove_user_role', this->ID, role );
--         end;

--         --
--         -- Sets the role of the user.
--         --
--         -- This will remove the previous roles of the user and assign the user the
--         -- new one. You can set the role to an empty string and it will remove all
--         -- of the roles from the user.
--         --
--         -- @since 2.0.0
--         --
--         -- @param string role Role name.
--         --
--         public function set_role( role ) then
--                 if ( 1 === count( this->roles ) && current( this->roles ) == role ) then
--                         return;
--                 end;

--                 foreach ( (array) this->roles as oldrole ) then
--                         unset( this->caps[ oldrole ] );
--                 end;

--                 old_roles = this->roles;

--                 if ( ! empty( role ) ) then
--                         this->caps[ role ] = true;
--                         this->roles         = array( role => true );
--                 end; else then
--                         this->roles = array();
--                 end;

--                 update_user_meta( this->ID, this->cap_key, this->caps );
--                 this->get_role_caps();
--                 this->update_user_level_from_caps();

--                 foreach ( old_roles as old_role ) then
--                         if ( ! old_role || old_role === role ) then
--                                 continue;
--                         end;

--                         -- This action is documented in wp-includes/class-wp-user.php--
--                         do_action( 'remove_user_role', this->ID, old_role );
--                 end;

--                 if ( role && ! in_array( role, old_roles, true ) ) then
--                         -- This action is documented in wp-includes/class-wp-user.php--
--                         do_action( 'add_user_role', this->ID, role );
--                 end;

--                 --
--                 -- Fires after the user's role has changed.
--                 --
--                 -- @since 2.9.0
--                 -- @since 3.6.0 Added old_roles to include an array of the user's previous roles.
--                 --
--                 -- @param int      user_id   The user ID.
--                 -- @param string   role      The new role.
--                 -- @param string[] old_roles An array of the user's previous roles.
--                 --
--                 do_action( 'set_user_role', this->ID, role, old_roles );
--         end;

--         --
--         -- Chooses the maximum level the user has.
--         --
--         -- Will compare the level from the item parameter against the max
--         -- parameter. If the item is incorrect, then just the max parameter value
--         -- will be returned.
--         --
--         -- Used to get the max level based on the capabilities the user has. This
--         -- is also based on roles, so if the user is assigned the Administrator role
--         -- then the capability 'level_10' will exist and the user will get that
--         -- value.
--         --
--         -- @since 2.0.0
--         --
--         -- @param int    max  Max level of user.
--         -- @param string item Level capability name.
--         -- @return int Max Level.
--         --
--         public function level_reduction( max, item ) then
--                 if ( preg_match( '/^level_(10|[0-9])/i', item, matches ) ) then
--                         level = (int) matches[1];
--                         return max( max, level );
--                 end; else then
--                         return max;
--                 end;
--         end;

--         --
--         -- Updates the maximum user level for the user.
--         --
--         -- Updates the 'user_level' user metadata (includes prefix that is the
--         -- database table prefix) with the maximum user level. Gets the value from
--         -- the all of the capabilities that the user has.
--         --
--         -- @since 2.0.0
--         --
--         -- @global wpdb wpdb WordPress database abstraction object.
--         --
--         public function update_user_level_from_caps() then
--                 global wpdb;
--                 this->user_level = array_reduce( array_keys( this->allcaps ), array( this, 'level_reduction' ), 0 );
--                 update_user_meta( this->ID, wpdb->get_blog_prefix() . 'user_level', this->user_level );
--         end;

--         --
--         -- Adds capability and grant or deny access to capability.
--         --
--         -- @since 2.0.0
--         --
--         -- @param string cap   Capability name.
--         -- @param bool   grant Whether to grant capability to user.
--         --
--         public function add_cap( cap, grant = true ) then
--                 this->caps[ cap ] = grant;
--                 update_user_meta( this->ID, this->cap_key, this->caps );
--                 this->get_role_caps();
--                 this->update_user_level_from_caps();
--         end;

--         --
--         -- Removes capability from user.
--         --
--         -- @since 2.0.0
--         --
--         -- @param string cap Capability name.
--         --
--         public function remove_cap( cap ) then
--                 if ( ! isset( this->caps[ cap ] ) ) then
--                         return;
--                 end;
--                 unset( this->caps[ cap ] );
--                 update_user_meta( this->ID, this->cap_key, this->caps );
--                 this->get_role_caps();
--                 this->update_user_level_from_caps();
--         end;

--         --
--         -- Removes all of the capabilities of the user.
--         --
--         -- @since 2.1.0
--         --
--         -- @global wpdb wpdb WordPress database abstraction object.
--         --
--         public function remove_all_caps() then
--                 global wpdb;
--                 this->caps = array();
--                 delete_user_meta( this->ID, this->cap_key );
--                 delete_user_meta( this->ID, wpdb->get_blog_prefix() . 'user_level' );
--                 this->get_role_caps();
--         end;

   -------------
   -- Has_Cap --
   -------------

   function Has_Cap (This : Wp_User;
                     Cap  : String)
                     -- ...args )
                     return Boolean
   is
      use Hb_Common;
      use Php;
      use Inc_Capabilities;
      use Inc_Load;
--    use Inc_Plugins;
   begin
      -- if Is_Numeric (Cap) then
      --   X_Deprecated_Argument (
      --     "__FUNCTION__",
      --     "2.0.0",
      --     abs "Usage of user levels is deprecated. Use capabilities instead.");
      --     Cap_2 := This.Translate_Level_To_Cap (Cap);
      -- end if;
      declare
         Caps : constant List_Type := Map_Meta_Cap (Cap, This.Id); -- , ...args );
      begin
         -- Multisite super admin has all caps by definition, Unless specifically
         -- denied.
         if Is_Multisite and then Is_Super_Admin (This.Id) then
            if In_Array ("do_not_allow", Caps, True) then
               return False;
            end if;
            return True;
         end if;

         declare
            -- Maintain BC for the argument passed to the "user_has_cap" filter.
            Args : Array_Type; --  := Array_Merge (To_Array (Cap, This.Id), Args);

            --
            -- Dynamically filter a user's capabilities.
            --
            -- @since 2.0.0
            -- @since 3.7.0 Added the `user` parameter.
            --
            -- @param bool[]   allcaps Array of key/value pairs where keys represent a
            --                          capability name and boolean values represent
            --                          whether the user has that capability.
            -- @param string[] caps    Required primitive capabilities for the
            --                          requested capability.
            -- @param array    args {
            --     Arguments that accompany the requested capability check.
            --
            --     @type string    0 Requested capability.
            --     @type int       1 Concerned user ID.
            --     @type mixed  ...2 Optional second and further parameters, typically
            --                       object ID.
            -- }
            -- @param WP_User  user    The user object.
            --
            Capabilities : Array_Type :=
              Apply_Filters ("user_has_cap",
                             This.Allcaps, Caps, -- Args,
                             This);

         begin
            -- Everyone is allowed to exist.
            Set (Capabilities, "exist", From_Boolean (True));

            -- Nobody is allowed to do things they are not allowed to do.
            Delete (Ref (Capabilities, "do_not_allow"));

            -- Must have ALL requested caps.
            for Cap of Caps loop -- (array)
               if Empty (As_String (Get (Capabilities, -Cap))) then
                  return False;
               end if;
            end loop;
         end;
      end;

      return True;
   end Has_Cap;

--         --
--         -- Converts numeric level to level capability name.
--         --
--         -- Prepends 'level_' to level number.
--         --
--         -- @since 2.0.0
--         --
--         -- @param int level Level number, 1 to 10.
--         -- @return string
--         --
--         public function translate_level_to_cap( level ) then
--                 return 'level_' . level;
--         end;

--         --
--         -- Sets the site to operate on. Defaults to the current site.
--         --
--         -- @since 3.0.0
--         -- @deprecated 4.9.0 Use WP_User::for_site()
--         --
--         -- @param int blog_id Optional. Site ID, defaults to current site.
--         --
--         public function for_blog( blog_id = '' ) then
--                 _deprecated_function( __METHOD__, '4.9.0', 'WP_User::for_site()' );

--                 this->for_site( blog_id );
--         end;

   --------------
   -- For_Site --
   --------------

   procedure For_Site (This    : in out Wp_User;
                       Site_Id : Integer := 0) -- ''
   is
      use Globals;
      use Hb_Common;
--    use Inc_Class_Wp_Users;
      use Inc_Load;
   begin
      if Site_Id = 0 then
--    if not Empty (Site_Id) then
         This.Site_Id := Site_Id; -- abs
      else
         This.Site_Id := Get_Current_Blog_Id;
      end if;

      This.Cap_Key := +WpDB.Get_Blog_Prefix (This.Site_Id) & "capabilities";

      This.Caps := This.Get_Caps_Data;

      This.Get_Role_Caps;
   end For_Site;

--         --
--         -- Gets the ID of the site for which the user's capabilities are currently initialized.
--         --
--         -- @since 4.9.0
--         --
--         -- @return int Site ID.
--         --
--         public function get_site_id() then
--                 return this->site_id;
--         end;

   -------------------
   -- Get_Caps_Data --
   -------------------

   function Get_Caps_Data (This : Wp_User)
                           return Array_Type
   is
      use Hb_Common;
      use Php;
      use Inc_Users;

      Caps : constant Array_Type :=
        Get_User_Meta (This.Id, -This.Cap_Key, True);
   begin
      if not Is_Array (Caps) then
         return Empty_Array;
      end if;

      return Caps;
   end Get_Caps_Data;

end Inc_Class_Wp_Users;
