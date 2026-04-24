--
-- Filesystem API: Top-level functionality
--
-- Functions for reading, writing, modifying, and deleting files on the file system.
-- Includes functionality for theme-specific files as well as operations for uploading,
-- archiving, and rendering output when necessary.
--
-- @package WordPress
-- @subpackage Filesystem
-- @since 2.3.0
--

with Php.Echoing;
with Php.Files;
with Php.Misc;
with Php.Preg;
with Php.Strings;
with Php.Types;

with Array_Lists;
with Binder;
with Constants;
with Globals;
with Logging;
with UStrings;
with Wp_Common;

with Adi_Templates;
with Inc_Formatting;
with Inc_Functions;
with Inc_General_Templates;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Options;
with Inc_Pluggables;

package body Adi_Files
is

   -------------------
   -- Get_Home_Path --
   -------------------

   function Get_Home_Path
            return String
   is
      use Php.Strings;
      use Binder;
      use Constants;
      use UStrings;
      use Inc_Formatting;
      use Inc_Link_Templates;
      use Inc_Options;

      Home     : constant String :=
        Set_URL_Scheme (Get_Option ("home"), "http");

      Site_URL : constant String :=
        Set_URL_Scheme (Get_Option ("siteurl"), "http");

      Home_Path : UString;
   begin
      if not Empty (Home) and then 0 /= Strcasecmp (Home, Site_URL) then
         declare
            Wp_Path_Rel_To_Home : constant String :=
              Str_Ireplace (Home, "", Site_URL); -- siteurl - home

            Pos : constant Natural :=
              Strripos (
                Str_Replace ("\\", "/",
                             Get_As_String (X_SERVER, "SCRIPT_FILENAME")),
                             Trailing_Slash_It (Wp_Path_Rel_To_Home));

            Home_Path_1 : constant String :=
              Substr (Get_As_String (X_SERVER, "SCRIPT_FILENAME"), 0, Pos);
         begin
            Home_Path := +Trailing_Slash_It (Home_Path_1);
         end;
      else
         Home_Path := +ABSPATH;
      end if;

      return Str_Replace ("\\", "/", -Home_Path);
   end Get_Home_Path;

   ---------------------------
   -- Get_Filesystem_Method --
   ---------------------------

   function Get_Filesystem_Method
     (Args                         : Array_Type := Empty_Array;
      Context                      : String := "";
      Allow_Relaxed_File_Ownership : Boolean := False) return String
   is
      use Php.Files;
      use Php.Misc;
      use Php.Strings;
      use Globals;
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;

      -- Please ensure that this is either "direct", "ssh2", "ftpext", or "ftpsockets".
      Method : UString :=
        +Constants.FS_METHOD; -- defined( "FS_METHOD" ) ? FS_METHOD : false;

      Context_2 : String :=
        (if Context = "" then -WP_CONTENT_DIR else Context);

      -- If the directory doesn't exist (wp-content/languages) then use the parent directory as we'll create it.
      Context_3 : String :=
        (if WP_LANG_DIR = Context_2 and then not Is_Dir (Context_2)
         then Dirname (Context_2)
         else Context_2);

      Context_4 : constant String := Trailing_Slash_It (Context_3);
   begin
      if Method /= "" then
         declare
            Temp_File_Name : String :=
              Context_4
              & "temp-write-test-"
              & Str_Replace (".", "-", Uniqid ("", True));

            Temp_Handle : File_Type := Fopen (Temp_File_Name, "w"); -- @
         begin
            if Is_Open (Temp_Handle) then

               -- Attempt to determine the file owner of the WordPress files, and that of newly created files.
               declare
                  Wp_File_Owner   : Integer := 0; -- False
                  Temp_File_Owner : Integer := 0; -- False
               begin
                  if Function_Exists ("fileowner") then
                     Wp_File_Owner := Fileowner ("__FILE__"); -- @
                     Temp_File_Owner := Fileowner (Temp_File_Name); -- @

                  end if;

                  if 0 /= Wp_File_Owner -- false
                    and then Wp_File_Owner = Temp_File_Owner
                  then
                     --
                     -- WordPress is creating files as the same owner as the WordPress files,
                     -- this means it"s safe to modify & create new files via PHP.
                     --
                     Method := +"direct";
                  -- GLOBALS["_wp_filesystem_direct_method"] := "file_owner";
                  elsif Allow_Relaxed_File_Ownership then
                     --
                     -- The context directory is writable, and allow_relaxed_file_ownership is set,
                     -- this means we can modify files safely in this directory.
                     -- This mode doesn"t create new files, only alter existing ones.
                     --
                     Method := +"direct";
                  -- GLOBALS["_wp_filesystem_direct_method"] := "relaxed_ownership";
                  end if;

                  Fclose (Temp_Handle);
                  Unlink (Temp_File_Name); -- @
               end;
            end if;
         end;
      end if;

      if Method = ""
        and then Isset (Args, "connection_type")
        and then "ssh" = Get_As_String (Args, "connection_type")
        and then Extension_Loaded ("ssh2")
      then
         Method := +"ssh2";
      end if;

      if Method = "" and then Extension_Loaded ("ftp") then
         Method := +"ftpext";
      end if;

      if Method = ""
        and then (Extension_Loaded ("sockets")
                  or else Function_Exists ("fsockopen"))
      then
         Method :=
           +"ftpsockets"; -- Sockets: Socket extension; PHP Mode: FSockopen / fwrite / fread.

      end if;

      --
      -- Filters the filesystem method to use.
      --
      -- @since 2.6.0
      --
      -- @param string method                       Filesystem method to return.
      -- @param array  args                         An array of connection details for the method.
      -- @param string context                      Full path to the directory that is tested for being writable.
      -- @param bool   allow_relaxed_file_ownership Whether to allow Group/World writable.
      --
      return
        Apply_Filters
          ("filesystem_method",
           -Method,
           Args,
           Context,
           Allow_Relaxed_File_Ownership);

   end Get_Filesystem_Method;

   ------------------------------------
   -- Request_Filesystem_Credentials --
   ------------------------------------

   function Request_Filesystem_Credentials
     (Form_Post                    : String;
      Typ                          : String := "";
      Error                        : Class_Errors.Wp_Error := Class_Errors.Null_Wp_Error;
      Context                      : String := "";
      Extra_Fields                 : List_Type := Empty_List; -- Array_Type := Empty_Array;
      Allow_Relaxed_File_Ownership : Boolean := False) return Array_Type
   is
      use Php.Echoing;
      use Php.Misc;
      use Php.Preg;
      use Php.Strings;
      use Php.Types;
      use Array_Lists;
      use Binder;
      use Constants;
      use UStrings;
      use Wp_Common;
      use Adi_Templates;
      use Class_Errors;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
      -- global pagenow;

      Pagenow : constant String := -Globals.Global_Pagenow;

      function Defined (Item : String) return Boolean;
      function Defined (Item : String) return String;

      function Defined (Item : String) return Boolean is
      begin
         Logging.Log ("defined", "stub, item: " & Item);
         return True;
      end Defined;

      function Defined (Item : String) return String is
      begin
         Logging.Log ("defined", "stub, item: " & Item);
         return "XXX-C98";
      end Defined;
      --
      -- Filters the filesystem credentials.
      --
      -- Returning anything other than an empty string will effectively short-circuit
      -- output of the filesystem credentials form, returning that value instead.
      --
      -- A filter should return true if no filesystem credentials are required, false if they are required but have not been
      -- provided, or an array of credentials if they are required and have been provided.
      --
      -- @since 2.5.0
      -- @since 4.6.0 The `context` parameter default changed from `false` to an empty string.
      --
      -- @param mixed         credentials                  Credentials to return instead. Default empty string.
      -- @param string        form_post                    The URL to post the form to.
      -- @param string        type                         Chosen type of filesystem.
      -- @param bool|WP_Error error                        Whether the current request has failed to connect,
      --                                                    or an error object.
      -- @param string        context                      Full path to the directory that is tested for
      --                                                    being writable.
      -- @param array         extra_fields                 Extra POST fields.
      -- @param bool          allow_relaxed_file_ownership Whether to allow Group/World writable.
      --
      Req_Cred : constant Array_Type :=
        Apply_Filters
          ("request_filesystem_credentials",
           Empty_Array, -- "",
           Form_Post,
           Typ,
           Error,
           Context,
           Extra_Fields,
           Allow_Relaxed_File_Ownership);
   begin
      if not Req_Cred.Is_Empty then
         return Req_Cred;
      end if;

      declare
         Typ_2 : String :=
           (if Empty (Typ)
            then
              Get_Filesystem_Method
                (Empty_Array, Context, Allow_Relaxed_File_Ownership)
            else Typ);

         Extra_Fields_2 : List_Type :=
           (if Extra_Fields.Is_Empty
            then
              -- if Is_Null (Extra_Fields) then
              List_Type'["version", "locale"]
            else Extra_Fields);
      begin
         if "direct" = Typ_2 then
            return Empty_Array; -- True;

         end if;

         declare
            Credentials : Array_Type :=
              Get_Option
                ("ftp_credentials",
                 To_Array_Type
                   ([Build ("hostname", ""), Build ("username", "")]));

            Submitted_Form : Array_Type := Wp_Unslash (X_POST);
         begin
            -- Verify nonce, or unset submitted form field values on failure.
            if not Isset (X_POST, "_fs_nonce")
              or else 0
                      = Wp_Verify_Nonce
                          (Get_As_String (X_POST, "_fs_nonce"),
                           "filesystem-credentials")
            then
               -- unset(
               Delete (Submitted_Form, "hostname");
               Delete (Submitted_Form, "username");
               Delete (Submitted_Form, "password");
               Delete (Submitted_Form, "public_key");
               Delete (Submitted_Form, "private_key");
               Delete (Submitted_Form, "connection_type");
            -- );

            end if;

            declare
               FTP_Constants : constant Array_Type :=
                 To_Array_Type
                   ([Build ("hostname", "FTP_HOST"),
                     Build ("username", "FTP_USER"),
                     Build ("password", "FTP_PASS"),
                     Build ("public_key", "FTP_PUBKEY"),
                     Build ("private_key", "FTP_PRIKEY")]);
            begin
               -- If defined, set it to that. Else, if POST'd, set it to that. If not, set it to an empty string.
               -- Otherwise, keep it as it previously was (saved details in option).
               for A in FTP_Constants.Iterate loop
                  declare
                     Keyy  : constant String := Key (A);
                     Const : constant String := As_String (Element (A));
                  begin
                     if Defined (Const) then
                        Set (Credentials, Keyy, From_String (Const));
                     elsif not Empty (Submitted_Form, Keyy) then
                        Set (Credentials, Keyy, Get (Submitted_Form, Keyy));
                     elsif not Isset (Credentials, Keyy) then
                        Set (Credentials, Keyy, From_String (""));
                     end if;
                  end;
               end loop;
            end;

            -- Sanitize the hostname, some people might pass in odd data.
            Set
              (Credentials,
               Key   => "hostname",
               Value =>
                 From_String
                   (Preg_Replace
                      ("|\w+://|",
                       "",
                       Get_As_String (Credentials, "hostname")))); -- Strip any schemes off.

            if Strpos (Get_As_String (Credentials, "hostname"), ":") /= 0 then
               declare
                  List : constant List_Type :=
                    Explode
                      (":",
                       Get_As_String (Credentials, "hostname"),
                       Limit => 2);
               begin
                  Set (Credentials, "hostname", From_String (List (1)));
                  Set (Credentials, "port", From_String (List (2)));
                  if not Is_Numeric (Get_As_String (Credentials, "port")) then
                     Delete (Credentials, "port");
                  end if;
               end;
            else
               Delete (Credentials, "port");
            end if;

            if (Defined ("FTP_SSH") and then FTP_SSH)
              or else (Defined ("FS_METHOD")
                       and then "ssh2" = Constants.FS_METHOD)
            then
               Set (Credentials, "connection_type", From_String ("ssh"));

            elsif (Defined ("FTP_SSL") and then FTP_SSL)
              and then "ftpext" = Typ_2
            then
               -- Only the FTP Extension understands SSL.
               Set (Credentials, "connection_type", From_String ("ftps"));

            elsif not Empty (Submitted_Form, "connection_type") then
               Set
                 (Credentials,
                  Key   => "connection_type",
                  Value =>
                    From_String
                      (Get_As_String (Submitted_Form, "connection_type")));

            elsif not Isset (Credentials, "connection_type") then
               -- All else fails (and it's not defaulted to something else saved), default to FTP.
               Set (Credentials, "connection_type", From_String ("ftp"));
            end if;

            if Error = Null_Wp_Error
              -- and then (not empty (Credentials, "hostname")
              --           and then not empty (credentials, "username")
              --           and then not empty (Credentials, "password"))
              -- or else ("ssh" = Get_As_String (Credentials, "connection_type")
              --          and then not empty (Credentials, "public_key")
              --          and then not empty (Credentials, "private_key"))
            then
               declare
                  Stored_Credentials : Array_Type := Credentials;
               begin
                  if not Empty (Stored_Credentials, "port") then
                     -- Save port as part of hostname to simplify above code.
                     Set
                       (Stored_Credentials,
                        Key   => "hostname",
                        Value =>
                          From_String
                            (Get_As_String (Stored_Credentials, "hostname")
                             & ":"
                             & Get_As_String (Stored_Credentials, "port")));
                  end if;

                  -- unset(
                  Delete (Stored_Credentials, "password");
                  Delete (Stored_Credentials, "port");
                  Delete (Stored_Credentials, "private_key");
                  Delete (Stored_Credentials, "public_key");
                  -- );

                  if not Wp_Installing then
                     Update_Option
                       ("ftp_credentials", From_Array (Stored_Credentials));
                  end if;

                  return Credentials;
               end;
            end if;

            declare
               Hostname : String :=
                 (if Isset (Credentials, "hostname")
                  then Get_As_String (Credentials, "hostname")
                  else "");

               Username : String :=
                 (if Isset (Credentials, "username")
                  then Get_As_String (Credentials, "username")
                  else "");

               Public_Key : String :=
                 (if Isset (Credentials, "public_key")
                  then Get_As_String (Credentials, "public_key")
                  else "");

               Private_Key : String :=
                 (if Isset (Credentials, "private_key")
                  then Get_As_String (Credentials, "private_key")
                  else "");

               Port : String :=
                 (if Isset (Credentials, "port")
                  then Get_As_String (Credentials, "port")
                  else "");

               Connection_Type : String :=
                 (if Isset (Credentials, "connection_type")
                  then Get_As_String (Credentials, "connection_type")
                  else "");
            begin
               if Error /= Null_Wp_Error then
                  declare
                     Error_String : String :=
                       abs "<strong>Error:</strong> Could not connect to the server. Please verify the settings are correct.";
                  begin
                     if Is_Wp_Error (Error) then
                        Error_String := ESC_HTML (Error.Get_Error_Message);
                     end if;
                     Echo
                       ("<div id=""message"" class=""error""><p>"
                        & Error_String
                        & "</p></div>");
                  end;
               end if;

               declare
                  Types : Array_Type := Empty_Array;
               begin
                  if Extension_Loaded ("ftp")
                    or else Extension_Loaded ("sockets")
                    or else Function_Exists ("fsockopen")
                  then
                     Set (Types, "ftp", From_String (abs "FTP"));
                  end if;

                  if Extension_Loaded ("ftp") then
                     -- Only this supports FTPS.
                     Set (Types, "ftps", From_String (abs "FTPS (SSL)"));
                  end if;

                  if Extension_Loaded ("ssh2") then
                     Set (Types, "ssh", From_String (abs "SSH2"));
                  end if;

                  --
                  -- Filters the connection types to output to the filesystem credentials form.
                  --
                  -- @since 2.9.0
                  -- @since 4.6.0 The `context` parameter default changed from `false` to an empty string.
                  --
                  -- @param string[]      types       Types of connections.
                  -- @param array         credentials Credentials to connect with.
                  -- @param string        type        Chosen filesystem method.
                  -- @param bool|WP_Error error       Whether the current request has failed to connect,
                  --                                   or an error object.
                  -- @param string        context     Full path to the directory that is tested for being writable.
                  --
                  Types :=
                    Apply_Filters
                      ("fs_ftp_connection_types",
                       Types,
                       Credentials,
                       Typ_2,
                       Error,
                       Context);

                  Echo
                    ("<form action="""
                     & ESC_URL (Form_Post)
                     & """ method=""post"">");
                  Echo
                    ("<div id=""request-filesystem-credentials-form"" class=""request-filesystem-credentials-form"">");

                  -- Print a H1 heading in the FTP credentials modal dialog, default is a H2.
                  declare
                     Heading_Tag : String :=
                       (if "plugins.php" = Pagenow
                          or else "plugin-install.php" = Pagenow
                        then "h1"
                        else "h2");
                  begin
                     Echo
                       ("<"
                        & Heading_Tag
                        & " id=""request-filesystem-credentials-title"">"
                        & abs "Connection Information"
                        & "</"
                        & Heading_Tag
                        & ">");
                  end;

                  Echo ("<p id=""request-filesystem-credentials-desc"">");
                  declare
                     Label_User : UString := +abs "Username";
                     Label_Pass : UString := +abs "Password";
                  begin
                     X_E
                       ("To perform the requested action, WordPress needs to access your web server.");
                     Echo (" ");
                     if Isset (Types, "ftp") or else Isset (Types, "ftps") then
                        if Isset (Types, "ssh") then
                           X_E
                             ("Please enter your FTP or SSH credentials to proceed.");
                           Label_User := +abs "FTP/SSH Username";
                           Label_Pass := +abs "FTP/SSH Password";
                        else
                           X_E
                             ("Please enter your FTP credentials to proceed.");
                           Label_User := +abs "FTP Username";
                           Label_Pass := +abs "FTP Password";
                        end if;
                        Echo (" ");
                     end if;

                     X_E
                       ("If you do not remember your credentials, you should contact your web host.");

                     declare
                        Hostname_Value : String :=
                          (if not Empty (Port)
                           then ESC_Attr (Hostname) & ":port"
                           else ESC_Attr (Hostname));

                        Password_Value : String :=
                          (if Defined ("FTP_PASS") then "*****" else "");
                     begin
                        Echo ("</p>");
                        Echo ("<label for=""hostname"">");
                        Echo ("        <span class=""field-title"">");
                        X_E ("Hostname");
                        Echo ("</span>");
                        Echo
                          ("        <input name=""hostname"" type=""text"" id=""hostname"" aria-describedby=""request-filesystem-credentials-desc"" class=""code"" placeholder=""");
                        ESC_Attr_E ("example: www.wordpress.org");
                        Echo
                          (""" value="""
                           & Hostname_Value
                           & """"
                           & Disabled (Defined ("FTP_HOST"))
                           & " />");
                        Echo ("</label>");

                        Echo ("<div class=""ftp-username"">");
                        Echo ("        <label for=""username"">");
                        Echo
                          ("                <span class=""field-title"">"
                           & (-Label_User)
                           & "</span>");
                        Echo
                          ("                <input name=""username"" type=""text"" id=""username"" value="""
                           & ESC_Attr (Username)
                           & """"
                           & Disabled (Defined ("FTP_USER"))
                           & " />");
                        Echo ("        </label>");
                        Echo ("</div>");
                        Echo ("<div class=""ftp-password"">");
                        Echo ("        <label for=""password"">");
                        Echo
                          ("                <span class=""field-title"">"
                           & (-Label_Pass)
                           & "</span>");
                        Echo
                          ("                <input name=""password"" type=""password"" id=""password"" value="""
                           & Password_Value
                           & """"
                           & Disabled (Defined ("FTP_PASS"))
                           & """ />");
                        if not Defined ("FTP_PASS") then
                           X_E
                             ("This password will not be stored on the server.");
                        end if;

                        Echo ("        </label>");
                        Echo ("</div>");
                     end;
                  end;
                  Echo ("<fieldset>");
                  Echo ("<legend>");
                  X_E ("Connection Type");
                  Echo ("</legend>");

                  declare
                     Cond : constant Boolean :=
                       (Defined ("FTP_SSL") and then FTP_SSL)
                       or else (Defined ("FTP_SSH") and then FTP_SSH);

                     Disabled_2 : constant String :=
                       Disabled (Boolean'Image (Cond), "True", False);
                  begin
                     for A in Types.Iterate loop
                        declare
                           Name : constant String := Key (A);
                           Text : constant String := As_String (Element (A));
                        begin
                           Echo
                             ("        <label for="""
                              & ESC_Attr (Name)
                              & """>");
                           Echo
                             ("                <input type=""radio"" name=""connection_type"" id="""
                              & ESC_Attr (Name)
                              & """ value="""
                              & ESC_Attr (Name)
                              & """ "
                              & Checked (Name, Connection_Type)
                              & " "
                              & Disabled_2
                              & " />");
                           Echo ("                " & Text);
                           Echo ("        </label>");
                        end;
                     end loop;
                  end;
                  Echo ("</fieldset>");

                  if Isset (Types, "ssh") then
                     declare
                        Hidden_Class : String :=
                          (if "ssh" /= Connection_Type
                             or else Empty (Connection_Type)
                           then " class=""hidden"""
                           else "");
                     begin
                        Echo
                          ("<fieldset id=""ssh-keys""" & Hidden_Class & ">");
                     end;
                     Echo ("<legend>");
                     X_E ("Authentication Keys");
                     Echo ("</legend>");
                     Echo ("<label for=""public_key"">");
                     Echo ("        <span class=""field-title"">");
                     X_E ("Public Key:");
                     Echo ("</span>");
                     Echo
                       ("        <input name=""public_key"" type=""text"" id=""public_key"" aria-describedby=""auth-keys-desc"" value="""
                        & ESC_Attr (Public_Key)
                        & """"
                        & Disabled (Defined ("FTP_PUBKEY"))
                        & " />");
                     Echo ("</label>");
                     Echo ("<label for=""private_key"">");
                     Echo ("        <span class=""field-title"">");
                     X_E ("Private Key:");
                     Echo ("</span>");
                     Echo
                       ("        <input name=""private_key"" type=""text"" id=""private_key"" value="""
                        & ESC_Attr (Private_Key)
                        & """"
                        & Disabled (Defined ("FTP_PRIKEY"))
                        & " />");
                     Echo ("</label>");
                     Echo ("<p id=""auth-keys-desc"">");
                     X_E
                       ("Enter the location on the server where the public and private keys are located. If a passphrase is needed, enter that in the password field above.");
                     Echo ("</p>");
                     Echo ("</fieldset>");

                  end if;

                  for Field of Extra_Fields_2 loop
                     -- (array)
                     if Isset (Submitted_Form, Field) then
                        Echo
                          ("<input type=""hidden"" name="""""
                           & ESC_Attr (Field)
                           & """ value="""
                           & ESC_Attr (Get_As_String (Submitted_Form, Field))
                           & """ />");
                     end if;
                  end loop;

                  -- Make sure the `submit_button()` function is available during the REST API call
                  -- from WP_Site_Health_Auto_Updates::test_check_wp_filesystem_method().
                  -- if not Function_Exists ("submit_button") then
                  --    require_once ABSPATH . "/wp-admin/includes/template.php";
                  -- end if;

                  Echo
                    ("        <p class=""request-filesystem-credentials-action-buttons"">");
                  Echo
                    ("                "
                     & Wp_Nonce_Field
                         ("filesystem-credentials", "_fs_nonce", False, True));
                  Echo
                    ("                <button class=""button cancel-button"" data-js-action=""close"" type=""button"">");
                  X_E ("Cancel");
                  Echo ("</button>");
                  Echo ("                ");
                  Submit_Button (abs "Proceed", "", "upgrade", False);
                  Echo ("        </p>");
                  Echo ("</div>");
                  Echo ("</form>");
               end;
            end;
         end;
      end;
      return Empty_Array; -- False;
   end Request_Filesystem_Credentials;

   ---------------------------------------------------
   -- Wp_Print_Request_Filesystem_Credentials_Modal --
   ---------------------------------------------------

   procedure Wp_Print_Request_Filesystem_Credentials_Modal
   is
      use Php.Echoing;
      use Inc_Link_Templates;

      Filesystem_Method : constant String := Get_Filesystem_Method;

      Filesystem_Credentials_Are_Stored : Boolean;
      Request_Filesystem_Credentials_2  : Boolean;
   begin
      OB_Start;

      Filesystem_Credentials_Are_Stored :=
        Request_Filesystem_Credentials (Self_Admin_URL) /= Empty_Array;

      OB_End_Clean;

      Request_Filesystem_Credentials_2 :=
        ("direct" /= Filesystem_Method and then
         not Filesystem_Credentials_Are_Stored);

      if not Request_Filesystem_Credentials_2 then
         return;
      end if;

      Echo ("<div id=""request-filesystem-credentials-dialog"" class=""notification-dialog-wrap request-filesystem-credentials-dialog"">");
      Echo ("  <div class=""notification-dialog-background""></div>");
      Echo ("  <div class=""notification-dialog"" role=""dialog"" aria-labelledby=""request-filesystem-credentials-title"" tabindex=""0"">");
      Echo ("    <div class=""request-filesystem-credentials-dialog-content"">");
      Echo ("      " & Boolean'Image (Request_Filesystem_Credentials (Site_URL) /= Empty_Array));
      Echo ("    </div>");
      Echo ("  </div>");
      Echo ("</div>");

   end Wp_Print_Request_Filesystem_Credentials_Modal;

end Adi_Files;
