
--
-- User API: WP_User class
--
-- @package WordPress
-- @subpackage Users
-- @since 4.4.0
--

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Strings.Unbounded;

with Arrays;
with Lists;

package Inc_Class_Wp_Users
is
   use Ada.Strings.Unbounded;
   use Arrays;
   use Lists;

   -- By jq
   type Property_Type is
      record
         Nickname      : Unbounded_String;
         User_Login    : Unbounded_String;
         User_Nicename : Unbounded_String;
         User_Email    : Unbounded_String;
         Display_Name  : Unbounded_String;
      end record;

   package Boolean_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => Boolean);
   --
   -- Core class used to implement the WP_User object.
   --
   -- @since 2.0.0
   --
   -- @property string $nickname
   -- @property string $description
   -- @property string $user_description
   -- @property string $first_name
   -- @property string $user_firstname
   -- @property string $last_name
   -- @property string $user_lastname
   -- @property string $user_login
   -- @property string $user_pass
   -- @property string $user_nicename
   -- @property string $user_email
   -- @property string $user_url
   -- @property string $user_registered
   -- @property string $user_activation_key
   -- @property string $user_status
   -- @property int    $user_level
   -- @property string $display_name
   -- @property string $spam
   -- @property string $deleted
   -- @property string $locale
   -- @property string $rich_editing
   -- @property string $syntax_highlighting
   -- @property string use_ssl
   --
   --#[AllowDynamicProperties]
   type Wp_User;
   type Wp_User_Access is access all Wp_User;

   type Wp_User is tagged
      record
         --
         -- User data container.
         --
         -- @since 2.0.0
         -- @var stdClass
         --
         Data : Wp_User_Access;

         --
         -- The user's ID.
         --
         -- @since 2.1.0
         -- @var int
         --
         Id : Integer := 0;

         --
         -- Capabilities that the individual user has been granted outside of those
         -- inherited from their role.
         --
         -- @since 2.0.0
         -- @var bool[] Array of key/value pairs where keys represent a capability name
         --             and boolean values represent whether the user has that
         --             capability.
         --
         Caps : Array_Type; -- Boolean_Maps.Map; -- = array();

         --
         -- User metadata option name.
         --
         -- @since 2.0.0
         -- @var string
         --
         Cap_Key : Unbounded_String;

         --
         -- The roles the user is part of.
         --
         -- @since 2.0.0
         -- @var string[]
         --
         Roles : List_Type;

         --
         -- All capabilities the user has, including individual and role based.
         --
         -- @since 2.0.0
         -- @var bool[] Array of key/value pairs where keys represent a capability name
         --             and boolean values represent whether the user has that
         --             capability.
         --
         Allcaps : Array_Type;

         --
         -- The filter context applied to user data fields.
         --
         -- @since 2.9.0
         -- @var string
         --
--        public filter = null;

         --
         -- The site ID the capabilities of this user are initialized for.
         --
         -- @since 4.9.0
         -- @var int
         --
         -- private
         Site_Id : Integer := 0;

         --
         -- @since 3.3.0
         -- @var array
         --
--        private static back_compat_keys;

         -- Added by jq
         Prop : Property_Type;

      end record;

   --
   -- Sets up object properties, including capabilities.
   --
   -- @since 3.3.0
   --
   -- @param object data    User DB row object.
   -- @param int    site_id Optional. The site ID to initialize for.
   --
   procedure Init (This    : in out Wp_User;
                   Data    : Wp_User;
                   Site_Id : Integer := 0); -- ''

   --
   -- Returns only the main user fields.
   --
   -- @since 3.3.0
   -- @since 4.4.0 Added 'ID' as an alias of 'id' for the `field` parameter.
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string     field The field to query against: 'id', 'ID', 'slug', 'email'
   --                          or 'login'.
   -- @param string|int value The field value.
   -- @return object|false Raw user object.
   --
   -- public static
   function Get_Data_By (Field : String;
                         Value : Integer)
                         return Wp_User;

   --
   -- Determines whether the user exists in the database.
   --
   -- @since 3.4.0
   --
   -- @return bool True if user exists in the database, false if not.
   --
   function Exists (This : Wp_User)
                    return Boolean
                    is (True);

   --
   -- Retrieves all of the capabilities of the user's roles, and merges them with
   -- individual user capabilities.
   --
   -- All of the capabilities of the user's roles are merged with the user's individual
   -- capabilities. This means that the user can be denied specific capabilities that
   -- their role might have, but the user is specifically denied.
   --
   -- @since 2.0.0
   --
   -- @return bool[] Array of key/value pairs where keys represent a capability name
   --                and boolean values represent whether the user has that capability.
   --
   function Get_Role_Caps (This : in out Wp_User)
                           return Array_Type; -- Boolean_Maps.Map;

   procedure Get_Role_Caps (This : in out Wp_User);

   --
   -- Returns whether the user has the specified capability.
   --
   -- This function also accepts an ID of an object to check against if the capability
   -- is a meta capability. Meta capabilities such as `edit_post` and `edit_user` are
   -- capabilities used by the `map_meta_cap()` function to map to primitive
   -- capabilities that a user or role has, such as `edit_posts` and
   -- `edit_others_posts`.
   --
   -- Example usage:
   --
   --     user->has_cap( 'edit_posts' );
   --     user->has_cap( 'edit_post', post->ID );
   --     user->has_cap( 'edit_post_meta', post->ID, meta_key );
   --
   -- While checking against a role in place of a capability is supported in part,
   -- this practice is discouraged as it may produce unreliable results.
   --
   -- @since 2.0.0
   -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
   --              by adding it to the function signature.
   --
   -- @see map_meta_cap()
   --
   -- @param string cap     Capability name.
   -- @param mixed  ...args Optional further parameters, typically starting with an
   --                        object ID.
   -- @return bool Whether the user has the given capability, or, if an object ID is
   --              passed, whether the user has the given capability for that object.
   --
   function Has_Cap (This : Wp_User;
                     Cap  : String)
                     -- ...args )
                     return Boolean;

   --
   -- Sets the site to operate on. Defaults to the current site.
   --
   -- @since 4.9.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param int site_id Site ID to initialize user capabilities for. Default is the
   --                    current site.
   --
   procedure For_Site (This    : in out Wp_User;
                       Site_Id : Integer := 0); -- ''

   --
   -- Gets the available user capabilities data.
   --
   -- @since 4.9.0
   --
   -- @return bool[] List of capabilities keyed by the capability name,
   --                e.g. array( 'edit_posts' => true, 'delete_posts' => false ).
   --
   -- private
   function Get_Caps_Data (This : Wp_User)
                           return Array_Type;

   Null_User : constant Wp_User :=
     (Data    => null,
      Id      => 0,
      Caps    => Empty_Array, -- Boolean_Maps.Empty_Map,
      Cap_Key => Null_Unbounded_String,
      Roles   => Empty_List,
      Allcaps => Empty_Array,
      Site_Id => 0,
      Prop    => (others => Null_Unbounded_String));

end Inc_Class_Wp_Users;
