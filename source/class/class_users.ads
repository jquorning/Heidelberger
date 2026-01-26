
--
-- User API: WP_User class
--
-- @package WordPress
-- @subpackage Users
-- @since 4.4.0
--

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers.Vectors;

with Arrays;
with Lists;
with UStrings;

package Class_Users
is
   use Arrays;
   use Lists;

   -- By jq
   type Property_Type is
      record
         Nickname         : UStrings.UString;
         User_Description : UStrings.UString;
         User_Firstname   : UStrings.UString;
         User_Lastname    : UStrings.UString;
         User_Login       : UStrings.UString;
         User_Pass        : UStrings.UString;
         User_Nicename    : UStrings.UString;
         User_Email       : UStrings.UString;
         User_URL         : UStrings.UString;
         Display_Name     : UStrings.UString;
         User_Level       : Natural;
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
         Cap_Key : UStrings.UString;

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

         -- Added by jq
         Prop : Property_Type;

      end record;

   --
   -- Constructor.
   --
   -- Retrieves the userdata and passes it to WP_User::init().
   --
   -- @since 2.0.0
   --
   -- @param int|string|stdClass|WP_User id      User's ID, a WP_User object, or a
   --                                             user object from the DB.
   -- @param string                      name    Optional. User's username
   -- @param int                         site_id Optional Site ID, defaults to
   --                                             current site.
   --
   function X_Construct (Id      : Integer := 0;
                         Name    : String  := "";
                         Site_Id : Integer := 0) -- ""
                         return Wp_User;

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

   function Get_Data_By (Field : String;
                         Value : String)
                         return Wp_User;

   --
   -- Determines whether the user exists in the database.
   --
   -- @since 3.4.0
   --
   -- @return bool True if user exists in the database, false if not.
   --
   function Exists (This : Wp_User)
                    return Boolean;

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
   -- Sets the role of the user.
   --
   -- This will remove the previous roles of the user and assign the user the
   -- new one. You can set the role to an empty string and it will remove all
   -- of the roles from the user.
   --
   -- @since 2.0.0
   --
   -- @param string role Role name.
   --
   procedure Set_Role (This : in out Wp_User;
                       Role : String);

   --
   -- Chooses the maximum level the user has.
   --
   -- Will compare the level from the item parameter against the max
   -- parameter. If the item is incorrect, then just the max parameter value
   -- will be returned.
   --
   -- Used to get the max level based on the capabilities the user has. This
   -- is also based on roles, so if the user is assigned the Administrator role
   -- then the capability 'level_10' will exist and the user will get that
   -- value.
   --
   -- @since 2.0.0
   --
   -- @param int    max  Max level of user.
   -- @param string item Level capability name.
   -- @return int Max Level.
   --
   function Level_Reduction (Max  : Integer;
                             Item : String)
                             return Integer;

   --
   -- Updates the maximum user level for the user.
   --
   -- Updates the 'user_level' user metadata (includes prefix that is the
   -- database table prefix) with the maximum user level. Gets the value from
   -- the all of the capabilities that the user has.
   --
   -- @since 2.0.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   procedure Update_User_Level_From_Caps (This : in out Wp_User);

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
      Cap_Key => UStrings.Null_UString,
      Roles   => Empty_List,
      Allcaps => Empty_Array,
      Site_Id => 0,
      Prop    => (User_Level => 0,
                  others     => UStrings.Null_UString));

   package User_Vectors is new
     Ada.Containers.Vectors (Index_Type   => Positive,
                             Element_Type => Wp_User);

   subtype User_List is User_Vectors.Vector;

   Empty_User_List : constant User_List := User_Vectors.Empty_Vector;

private
   --
   -- @since 3.3.0
   -- @var array
   --
   -- private static
   Back_Compat_Keys : Array_Type;

end Class_Users;
