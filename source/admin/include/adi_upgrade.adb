--
-- WordPress Upgrade API
--
-- Most of the functions are pluggable and can be overwritten.
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Strings.Unbounded;

with Php.Strings;

with Hb_Common;
with Wp_Common;

with Adi_Schemas;

with Inc_Caches;
with Inc_Class_Wp_Users;
with Inc_Functions;
with Inc_L10n;
with Inc_Options;
with Inc_Pluggables;
-- with Inc_Plugins;
with Inc_Rewrites;
with Inc_Users;

package body Adi_Upgrade
is

   ----------------
   -- Wp_Install --
   ----------------

   function Wp_Install (Blog_Title    : String;
                        User_Name     : String;
                        User_Email    : String;
                        Is_Public     : Boolean;
                        Deprecated    : String := "";
                        User_Password : String := "";
                        Language      : String := "")
                        return Arrays.Array_Type
   is
      use Ada.Strings.Unbounded;
      use Php.Strings;
      use Arrays;
      use Hb_Common;
      use Wp_Common;
      use Adi_Schemas;
      use Inc_Caches;
      use Inc_Class_Wp_Users;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
--    use Inc_Plugins;
      use Inc_Rewrites;
      use Inc_Users;
   begin
      if not Empty (Deprecated) then
         X_Deprecated_Argument ("__FUNCTION__", "2.6.0");
      end if;

      Wp_Check_MySQL_Version;
      Wp_Cache_Flush;
      Make_DB_Current_Silent;
      Populate_Options;
      Populate_Roles;

      Update_Option ("blogname",    From_String  (Blog_Title));
      Update_Option ("admin_email", From_String  (User_Email));
      Update_Option ("blog_public", From_Boolean (Is_Public));

      -- Freshness of site - in the future, this could get more specific about
      -- actions taken, perhaps.
      Update_Option ("fresh_site", From_Integer (1));

      if Language /= "" then
         Update_Option ("WPLANG", From_String (Language));
      end if;

      declare
         Guess_URL : constant String := Wp_Guess_URL;
      begin
         Update_Option ("siteurl", From_String (Guess_URL));

         -- If not a public site, don't ping.
         if not Is_Public then
            Update_Option ("default_pingback_flag", From_Integer (0));
         end if;

         --
         -- Create default user. If the user already exists, the user tables are
         -- being shared among sites. Just set the role in that case.
         --
         declare
            User_Id         : Integer := Username_Exists (User_Name);
            User_Password_2 : constant String  := Trim (User_Password);
            Email_Password  : Boolean := False;
            User_Created    : Boolean := False;

            Message : Unbounded_String;
         begin
            if User_Id = 0 and then Empty (User_Password_2) then
               declare
                  User_Password : constant String := Wp_Generate_Password (12, False);
                  User_Id       : constant Integer :=
                    Wp_Create_User (User_Name, User_Password, User_Email);
               begin
                  Update_User_Meta (User_Id,
                                    "default_password_nag",
                                    Empty_Array); -- True);
               end;
               Message        := +abs "<strong><em>Note that password</em></strong> carefully! It is a <em>random</em> password that was generated just for you.";
               Email_Password := True;
               User_Created   := True;
            elsif User_Id = 0 then
               -- Password has been provided.
               Message      := +"<em>" & abs "Your chosen password." & "</em>";
               User_Id      := Wp_Create_User (User_Name, User_Password, User_Email);
               User_Created := True;
            else
               Message := +abs "User already exists. Password inherited.";
            end if;

            declare
               User : Wp_User := X_Construct (User_Id);
            begin
               User.Set_Role ("administrator");

               if User_Created then
                  User.Prop.User_URL := +Guess_URL;
                  Wp_Update_User (User);
               end if;

               Wp_Install_Defaults (User_Id);

               Wp_Install_Maybe_Enable_Pretty_Permalinks;

               Flush_Rewrite_Rules;

               Wp_New_Blog_Notification
                 (Blog_Title, Guess_URL, User_Id,
                  (if Email_Password then User_Password
                   else abs "The password you chose during installation."));

               Wp_Cache_Flush;

               --
               -- Fires after a site is fully installed.
               --
               -- @since 3.9.0
               --
               -- @param WP_User user The site owner.
               --
               Do_Action ("wp_install", User);

               return
                 To_Array (List => (
                        Build ("url",              Guess_URL),
                        Build ("user_id",          User_Id),
                        Build ("password",         User_Password),
                        Build ("password_message", -Message)
                 ));
            end;
         end;
      end;
   end Wp_Install;

end Adi_Upgrade;
