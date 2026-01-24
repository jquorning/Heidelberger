--
-- Error Protection API: WP_Recovery_Mode class
--
-- @package WordPress
-- @since 5.2.0
--

with Ada.Strings.Unbounded;

package Inc_Class_Wp_Recovery_Mode
is
   use Ada.Strings.Unbounded;

   EXIT_ACTION : constant String := "exit_recovery_mode";

   --
   -- Core class used to implement Recovery Mode.
   --
   -- @since 5.2.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Recovery_Mode is tagged
      record
         --
         -- Service to handle cookies.
         --
         -- @since 5.2.0
         -- @var WP_Recovery_Mode_Cookie_Service
         --
--        private cookie_service;

         --
         -- Service to generate a recovery mode key.
         --
         -- @since 5.2.0
         -- @var WP_Recovery_Mode_Key_Service
         --
--        private key_service;

         --
         -- Service to generate and validate recovery mode links.
         --
         -- @since 5.2.0
         -- @var WP_Recovery_Mode_Link_Service
         --
--        private link_service;

         --
         -- Service to handle sending an email with a recovery mode link.
         --
         -- @since 5.2.0
         -- @var WP_Recovery_Mode_Email_Service
         --
--        private email_service;

         --
         -- Is recovery mode initialized.
         --
         -- @since 5.2.0
         -- @var bool
         --
--        private
         Is_Initialized : Boolean := False;

         --
         -- Is recovery mode active in this session.
         --
         -- @since 5.2.0
         -- @var bool
         --
--        private
         Is_Active : Boolean := False;

         --
         -- Get an ID representing the current recovery mode session.
         --
         -- @since 5.2.0
         -- @var string
         --
--        private
         Session_Id : Unbounded_String;

      end record;

   --
   -- Gets the recovery mode session ID.
   --
   -- @since 5.2.0
   --
   -- @return string The session ID if recovery mode is active, empty string otherwise.
   --
   function Get_Session_Id (This : Wp_Recovery_Mode)
                            return String;

   Default_Recovery_Mode : constant Wp_Recovery_Mode :=
     (Is_Initialized => False,
      Is_Active      => False,
      Session_Id     => Null_Unbounded_String);

   Null_Recovery_Mode : constant Wp_Recovery_Mode :=
     (Is_Initialized => False,
      Is_Active      => False,
      Session_Id     => Null_Unbounded_String);

end Inc_Class_Wp_Recovery_Mode;
