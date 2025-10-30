
--
-- User API: WP_User class
--
-- @package WordPress
-- @subpackage Users
-- @since 4.4.0
--

with Ada.Strings.Unbounded;

package Inc_Class_Wp_Users
is
   use Ada.Strings.Unbounded;

   procedure Dummy;

   -- By jq
   type Property_Type is
      record
         Nickname      : Unbounded_String;
         User_Login    : Unbounded_String;
         User_Nicename : Unbounded_String;
         Display_Name  : Unbounded_String;
      end record;

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
   type Wp_User is tagged
      record
         --
         -- User data container.
         --
         -- @since 2.0.0
         -- @var stdClass
         --
--        public data;

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
--        public caps = array();

         --
         -- User metadata option name.
         --
         -- @since 2.0.0
         -- @var string
         --
--        public cap_key;

         --
         -- The roles the user is part of.
         --
         -- @since 2.0.0
         -- @var string[]
         --
--        public roles = array();

         --
         -- All capabilities the user has, including individual and role based.
         --
         -- @since 2.0.0
         -- @var bool[] Array of key/value pairs where keys represent a capability name
         --             and boolean values represent whether the user has that
         --             capability.
         --
--        public allcaps = array();

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
--      private site_id = 0;

         --
         -- @since 3.3.0
         -- @var array
         --
--        private static back_compat_keys;

         -- Added by jq
         Prop : Property_Type;

      end record;

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

   Null_User : constant Wp_User :=
     (Id   => 0,
      Prop => (others => Null_Unbounded_String));

end Inc_Class_Wp_Users;
