
--
-- These functions can be replaced via plugins. If plugins do not redefine these
-- functions, then these will be used instead.
--
-- @package WordPress
--

with Ada.Containers;
with Ada.Numerics.Discrete_Random;

with Php.Arrays;
with Php.Errors;
with Php.Files;
with Php.HTML;
with Php.Lists;
with Php.Misc;
with Php.Preg;
with Php.Strings;

with Binder;
with Constants;
with UStrings;
with Helpers;
with Globals;
with Wp_Common;

with Class_Errors;
with Class_Session_Tokens;
with Class_Session_Tokens_Factory;
with Inc_Compat;
with Inc_Formatting;
with Inc_Functions;
with Inc_General_Templates;
with Inc_KSES;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Media;
with Inc_Options;
with Inc_Plugins;
with Inc_Vars;

package body Inc_Pluggables
is

   subtype User_Id_Type is Class_Users.User_Id_Type;

   Global_Current_User : Class_Users.Wp_User :=
     Class_Users.Null_User;

-- if ( ! function_exists( 'wp_set_current_user' ) ) :

   -------------------------
   -- Wp_Set_Current_User --
   -------------------------

   function Wp_Set_Current_User (Id   : User_Id_Type;
                                 Name : String := "")
                                 return Class_Users.Wp_User
   is
      use Class_Users;
      use Inc_Plugins;
      use Inc_Users;
--    global current_user;
   begin
      -- If `id` matches the current user, there is nothing to do.
      if
        Global_Current_User /= Null_User and then
--      Isset (Global_Current_User) and then
        Global_Current_User in Wp_User and then -- instaceof
        Id = Global_Current_User.Id -- and then
--      ( null !== id )
      then
         return Global_Current_User;
      end if;

      Global_Current_User := X_Construct (User_Id_Type (Id), Name);
      -- new WP_User( id, name );

      Setup_Userdata (Global_Current_User.Id);

      --
      -- Fires after the current user is set.
      --
      -- @since 2.0.1
      --
      Do_Action ("set_current_user");

      return Global_Current_User;
   end Wp_Set_Current_User;

   -------------------------
   -- Wp_Set_Current_User --
   -------------------------

   procedure Wp_Set_Current_User (Id   : User_Id_Type;
                                  Name : String := "")
   is
      use Class_Users;

      Unused : constant Wp_User :=
        Wp_Set_Current_User (Id, Name);
   begin
      null;
   end Wp_Set_Current_User;

-- endif;

-- if ( ! function_exists( 'wp_get_current_user' ) ) :

   -------------------------
   -- Wp_Get_Current_User --
   -------------------------

-- function wp_get_current_user() then
   function Wp_Get_Current_User
            return Class_Users.Wp_User
   is
      use Inc_Users;
   begin
      return X_Wp_Get_Current_User; -- ();
   end Wp_Get_Current_User;
-- endif;

-- if ( ! function_exists( 'get_userdata' ) ) :
--         --
--         -- Retrieves user info by user ID.
--         --
--         -- @since 0.71
--         --
--         -- @param int user_id User ID
--         -- @return WP_User|false WP_User object on success, false on failure.
--         --
   function Get_Userdata (User_Id : User_Id_Type)
                          return Class_Users.Wp_User
   is
   begin
      return Get_User_By ("id", Integer (User_Id));
   end Get_Userdata;

-- endif;

-- if ( ! function_exists( 'get_user_by' ) ) :

   -----------------
   -- Get_User_By --
   -----------------

   function Get_User_By (Field : String;
                         Value : Integer)
                         return Class_Users.Wp_User
   is
      use Class_Users;

      Userdata : constant Wp_User := Get_Data_By (Field, Value);
   begin
      if Userdata = Null_User then
         return Null_User; -- False;
      end if;

      declare
         User : Wp_User; --  = new WP_User;
      begin
         User.Init (Userdata);

         return User;
      end;
   end Get_User_By;

   -----------------
   -- Get_User_By --
   -----------------

   function Get_User_By (Field : String;
                         Value : String)
                         return Class_Users.Wp_User
   is
      use Class_Users;

      Userdata : constant Wp_User := Get_Data_By (Field, Value);
   begin
      if Userdata = Null_User then
         return Null_User; -- False;
      end if;

      declare
         User : Wp_User; --  = new WP_User;
      begin
         User.Init (Userdata);

         return User;
      end;
   end Get_User_By;

-- endif;

-- if ( ! function_exists( 'cache_users' ) ) :
--         --
--         -- Retrieves info for user lists to prevent multiple queries by get_userdata().
--         --
--         -- @since 3.0.0
--         --
--         -- @global wpdb wpdb WordPress database abstraction object.
--         --
--         -- @param int[] user_ids User ID numbers list
--         --
--         function cache_users( user_ids ) then
--                 global wpdb;

--                 update_meta_cache( 'user', user_ids );

--                 clean = _get_non_cached_ids( user_ids, 'users' );

--                 if ( empty( clean ) ) then
--                         return;
--                 end;

--                 list = implode( ',', clean );

--                 users = wpdb->get_results( "SELECT-- FROM wpdb->users WHERE ID IN (list)" );

--                 foreach ( users as user ) then
--                         update_user_caches( user );
--                 end;
--         end;
-- endif;

-- if ( ! function_exists( 'wp_mail' ) ) :
--         --
--         -- Sends an email, similar to PHP's mail function.
--         --
--         -- A true return value does not automatically mean that the user received the
--         -- email successfully. It just only means that the method used was able to
--         -- process the request without any errors.
--         --
--         -- The default content type is `text/plain` which does not allow using HTML.
--         -- However, you can set the content type of the email by using the
--         -- {@see 'wp_mail_content_type'} filter.
--         --
--         -- The default charset is based on the charset used on the blog. The charset can
--         -- be set using the {@see 'wp_mail_charset'} filter.
--         --
--         -- @since 1.2.1
--         -- @since 5.5.0 is_email() is used for email validation,
--         --              instead of PHPMailer's default validator.
--         --
--         -- @global PHPMailer\PHPMailer\PHPMailer phpmailer
--         --
--         -- @param string|string[] to          Array or comma-separated list of email addresses to send message.
--         -- @param string          subject     Email subject.
--         -- @param string          message     Message contents.
--         -- @param string|string[] headers     Optional. Additional headers.
--         -- @param string|string[] attachments Optional. Paths to files to attach.
--         -- @return bool Whether the email was sent successfully.
--         --
--         function wp_mail( to, subject, message, headers = '', attachments = array() ) then
--                 -- Compact the input, apply the filters, and extract them back out.

--                 --
--                 -- Filters the wp_mail() arguments.
--                 --
--                 -- @since 2.2.0
--                 --
--                 -- @param array args then
--                 --     Array of the `wp_mail()` arguments.
--                 --
--                 --     @type string|string[] to          Array or comma-separated list of email addresses to send message.
--                 --     @type string          subject     Email subject.
--                 --     @type string          message     Message contents.
--                 --     @type string|string[] headers     Additional headers.
--                 --     @type string|string[] attachments Paths to files to attach.
--                 -- end;
--                 --
--                 atts = apply_filters( 'wp_mail', compact( 'to', 'subject', 'message', 'headers', 'attachments' ) );

--                 --
--                 -- Filters whether to preempt sending an email.
--                 --
--                 -- Returning a non-null value will short-circuit {@see wp_mail()}, returning
--                 -- that value instead. A boolean return value should be used to indicate whether
--                 -- the email was successfully sent.
--                 --
--                 -- @since 5.7.0
--                 --
--                 -- @param null|bool return Short-circuit return value.
--                 -- @param array     atts then
--                 --     Array of the `wp_mail()` arguments.
--                 --
--                 --     @type string|string[] to          Array or comma-separated list of email addresses to send message.
--                 --     @type string          subject     Email subject.
--                 --     @type string          message     Message contents.
--                 --     @type string|string[] headers     Additional headers.
--                 --     @type string|string[] attachments Paths to files to attach.
--                 -- end;
--                 --
--                 pre_wp_mail = apply_filters( 'pre_wp_mail', null, atts );

--                 if ( null !== pre_wp_mail ) then
--                         return pre_wp_mail;
--                 end;

--                 if ( isset( atts['to'] ) ) then
--                         to = atts['to'];
--                 end;

--                 if ( ! is_array( to ) ) then
--                         to = explode( ',', to );
--                 end;

--                 if ( isset( atts['subject'] ) ) then
--                         subject = atts['subject'];
--                 end;

--                 if ( isset( atts['message'] ) ) then
--                         message = atts['message'];
--                 end;

--                 if ( isset( atts['headers'] ) ) then
--                         headers = atts['headers'];
--                 end;

--                 if ( isset( atts['attachments'] ) ) then
--                         attachments = atts['attachments'];
--                 end;

--                 if ( ! is_array( attachments ) ) then
--                         attachments = explode( "\n", str_replace( "\r\n", "\n", attachments ) );
--                 end;
--                 global phpmailer;

--                 -- (Re)create it, if it's gone missing.
--                 if ( ! ( phpmailer instanceof PHPMailer\PHPMailer\PHPMailer ) ) then
--                         require_once ABSPATH . WPINC . '/PHPMailer/PHPMailer.php';
--                         require_once ABSPATH . WPINC . '/PHPMailer/SMTP.php';
--                         require_once ABSPATH . WPINC . '/PHPMailer/Exception.php';
--                         phpmailer = new PHPMailer\PHPMailer\PHPMailer( true );

--                         phpmailer::validator = static function ( email ) then
--                                 return (bool) is_email( email );
--                         end;;
--                 end;

--                 -- Headers.
--                 cc       = array();
--                 bcc      = array();
--                 reply_to = array();

--                 if ( empty( headers ) ) then
--                         headers = array();
--                 end; else then
--                         if ( ! is_array( headers ) ) then
--                                 -- Explode the headers out, so this function can take
--                                 -- both string headers and an array of headers.
--                                 tempheaders = explode( "\n", str_replace( "\r\n", "\n", headers ) );
--                         end; else then
--                                 tempheaders = headers;
--                         end;
--                         headers = array();

--                         -- If it's actually got contents.
--                         if ( ! empty( tempheaders ) ) then
--                                 -- Iterate through the raw headers.
--                                 foreach ( (array) tempheaders as header ) then
--                                         if ( strpos( header, ':' ) === false ) then
--                                                 if ( false !== stripos( header, 'boundary=' ) ) then
--                                                         parts    = preg_split( '/boundary=/i', trim( header ) );
--                                                         boundary = trim( str_replace( array( "'", '"' ), '', parts[1] ) );
--                                                 end;
--                                                 continue;
--                                         end;
--                                         -- Explode them out.
--                                         list( name, content ) = explode( ':', trim( header ), 2 );

--                                         -- Cleanup crew.
--                                         name    = trim( name );
--                                         content = trim( content );

--                                         switch ( strtolower( name ) ) then
--                                                 -- Mainly for legacy -- process a "From:" header if it's there.
--                                                 case 'from':
--                                                         bracket_pos = strpos( content, '<' );
--                                                         if ( false !== bracket_pos ) then
--                                                                 -- Text before the bracketed email is the "From" name.
--                                                                 if ( bracket_pos > 0 ) then
--                                                                         from_name = substr( content, 0, bracket_pos );
--                                                                         from_name = str_replace( '"', '', from_name );
--                                                                         from_name = trim( from_name );
--                                                                 end;

--                                                                 from_email = substr( content, bracket_pos + 1 );
--                                                                 from_email = str_replace( '>', '', from_email );
--                                                                 from_email = trim( from_email );

--                                                                 -- Avoid setting an empty from_email.
--                                                         end; elseif ( '' !== trim( content ) ) then
--                                                                 from_email = trim( content );
--                                                         end;
--                                                         break;
--                                                 case 'content-type':
--                                                         if ( strpos( content, ';' ) !== false ) then
--                                                                 list( type, charset_content ) = explode( ';', content );
--                                                                 content_type                   = trim( type );
--                                                                 if ( false !== stripos( charset_content, 'charset=' ) ) then
--                                                                         charset = trim( str_replace( array( 'charset=', '"' ), '', charset_content ) );
--                                                                 end; elseif ( false !== stripos( charset_content, 'boundary=' ) ) then
--                                                                         boundary = trim( str_replace( array( 'BOUNDARY=', 'boundary=', '"' ), '', charset_content ) );
--                                                                         charset  = '';
--                                                                 end;

--                                                                 -- Avoid setting an empty content_type.
--                                                         end; elseif ( '' !== trim( content ) ) then
--                                                                 content_type = trim( content );
--                                                         end;
--                                                         break;
--                                                 case 'cc':
--                                                         cc = array_merge( (array) cc, explode( ',', content ) );
--                                                         break;
--                                                 case 'bcc':
--                                                         bcc = array_merge( (array) bcc, explode( ',', content ) );
--                                                         break;
--                                                 case 'reply-to':
--                                                         reply_to = array_merge( (array) reply_to, explode( ',', content ) );
--                                                         break;
--                                                 default:
--                                                         -- Add it to our grand headers array.
--                                                         headers[ trim( name ) ] = trim( content );
--                                                         break;
--                                         end;
--                                 end;
--                         end;
--                 end;

--                 -- Empty out the values that may be set.
--                 phpmailer->clearAllRecipients();
--                 phpmailer->clearAttachments();
--                 phpmailer->clearCustomHeaders();
--                 phpmailer->clearReplyTos();
--                 phpmailer->Body    = '';
--                 phpmailer->AltBody = '';

--                 -- Set "From" name and email.

--                 -- If we don't have a name from the input headers.
--                 if ( ! isset( from_name ) ) then
--                         from_name = 'WordPress';
--                 end;

--                 /*
--                 -- If we don't have an email from the input headers, default to wordpress@sitename
--                 -- Some hosts will block outgoing mail from this address if it doesn't exist,
--                 -- but there's no easy alternative. Defaulting to admin_email might appear to be
--                 -- another option, but some hosts may refuse to relay mail from an unknown domain.
--                 -- See https://core.trac.wordpress.org/ticket/5007.
--                 --
--                 if ( ! isset( from_email ) ) then
--                         -- Get the site domain and get rid of www.
--                         sitename   = wp_parse_url( network_home_url(), PHP_URL_HOST );
--                         from_email = 'wordpress@';

--                         if ( null !== sitename ) then
--                                 if ( 'www.' === substr( sitename, 0, 4 ) ) then
--                                         sitename = substr( sitename, 4 );
--                                 end;

--                                 from_email .= sitename;
--                         end;
--                 end;

--                 --
--                 -- Filters the email address to send from.
--                 --
--                 -- @since 2.2.0
--                 --
--                 -- @param string from_email Email address to send from.
--                 --
--                 from_email = apply_filters( 'wp_mail_from', from_email );

--                 --
--                 -- Filters the name to associate with the "from" email address.
--                 --
--                 -- @since 2.3.0
--                 --
--                 -- @param string from_name Name associated with the "from" email address.
--                 --
--                 from_name = apply_filters( 'wp_mail_from_name', from_name );

--                 try then
--                         phpmailer->setFrom( from_email, from_name, false );
--                 end; catch ( PHPMailer\PHPMailer\Exception e ) then
--                         mail_error_data                             = compact( 'to', 'subject', 'message', 'headers', 'attachments' );
--                         mail_error_data['phpmailer_exception_code'] = e->getCode();

--                         -- This filter is documented in wp-includes/pluggable.php--
--                         do_action( 'wp_mail_failed', new WP_Error( 'wp_mail_failed', e->getMessage(), mail_error_data ) );

--                         return false;
--                 end;

--                 -- Set mail's subject and body.
--                 phpmailer->Subject = subject;
--                 phpmailer->Body    = message;

--                 -- Set destination addresses, using appropriate methods for handling addresses.
--                 address_headers = compact( 'to', 'cc', 'bcc', 'reply_to' );

--                 foreach ( address_headers as address_header => addresses ) then
--                         if ( empty( addresses ) ) then
--                                 continue;
--                         end;

--                         foreach ( (array) addresses as address ) then
--                                 try then
--                                         -- Break recipient into name and address parts if in the format "Foo <bar@baz.com>".
--                                         recipient_name = '';

--                                         if ( preg_match( '/(.*)<(.+)>/', address, matches ) ) then
--                                                 if ( count( matches ) == 3 ) then
--                                                         recipient_name = matches[1];
--                                                         address        = matches[2];
--                                                 end;
--                                         end;

--                                         switch ( address_header ) then
--                                                 case 'to':
--                                                         phpmailer->addAddress( address, recipient_name );
--                                                         break;
--                                                 case 'cc':
--                                                         phpmailer->addCc( address, recipient_name );
--                                                         break;
--                                                 case 'bcc':
--                                                         phpmailer->addBcc( address, recipient_name );
--                                                         break;
--                                                 case 'reply_to':
--                                                         phpmailer->addReplyTo( address, recipient_name );
--                                                         break;
--                                         end;
--                                 end; catch ( PHPMailer\PHPMailer\Exception e ) then
--                                         continue;
--                                 end;
--                         end;
--                 end;

--                 -- Set to use PHP's mail().
--                 phpmailer->isMail();

--                 -- Set Content-Type and charset.

--                 -- If we don't have a content-type from the input headers.
--                 if ( ! isset( content_type ) ) then
--                         content_type = 'text/plain';
--                 end;

--                 --
--                 -- Filters the wp_mail() content type.
--                 --
--                 -- @since 2.3.0
--                 --
--                 -- @param string content_type Default wp_mail() content type.
--                 --
--                 content_type = apply_filters( 'wp_mail_content_type', content_type );

--                 phpmailer->ContentType = content_type;

--                 -- Set whether it's plaintext, depending on content_type.
--                 if ( 'text/html' === content_type ) then
--                         phpmailer->isHTML( true );
--                 end;

--                 -- If we don't have a charset from the input headers.
--                 if ( ! isset( charset ) ) then
--                         charset = get_bloginfo( 'charset' );
--                 end;

--                 --
--                 -- Filters the default wp_mail() charset.
--                 --
--                 -- @since 2.3.0
--                 --
--                 -- @param string charset Default email charset.
--                 --
--                 phpmailer->CharSet = apply_filters( 'wp_mail_charset', charset );

--                 -- Set custom headers.
--                 if ( ! empty( headers ) ) then
--                         foreach ( (array) headers as name => content ) then
--                                 -- Only add custom headers not added automatically by PHPMailer.
--                                 if ( ! in_array( name, array( 'MIME-Version', 'X-Mailer' ), true ) ) then
--                                         try then
--                                                 phpmailer->addCustomHeader( sprintf( '%1s: %2s', name, content ) );
--                                         end; catch ( PHPMailer\PHPMailer\Exception e ) then
--                                                 continue;
--                                         end;
--                                 end;
--                         end;

--                         if ( false !== stripos( content_type, 'multipart' ) && ! empty( boundary ) ) then
--                                 phpmailer->addCustomHeader( sprintf( 'Content-Type: %s; boundary="%s"', content_type, boundary ) );
--                         end;
--                 end;

--                 if ( ! empty( attachments ) ) then
--                         foreach ( attachments as attachment ) then
--                                 try then
--                                         phpmailer->addAttachment( attachment );
--                                 end; catch ( PHPMailer\PHPMailer\Exception e ) then
--                                         continue;
--                                 end;
--                         end;
--                 end;

--                 --
--                 -- Fires after PHPMailer is initialized.
--                 --
--                 -- @since 2.2.0
--                 --
--                 -- @param PHPMailer phpmailer The PHPMailer instance (passed by reference).
--                 --
--                 do_action_ref_array( 'phpmailer_init', array( &phpmailer ) );

--                 mail_data = compact( 'to', 'subject', 'message', 'headers', 'attachments' );

--                 -- Send!
--                 try then
--                         send = phpmailer->send();

--                         --
--                         -- Fires after PHPMailer has successfully sent an email.
--                         --
--                         -- The firing of this action does not necessarily mean that the recipient(s) received the
--                         -- email successfully. It only means that the `send` method above was able to
--                         -- process the request without any errors.
--                         --
--                         -- @since 5.9.0
--                         --
--                         -- @param array mail_data then
--                         --     An array containing the email recipient(s), subject, message, headers, and attachments.
--                         --
--                         --     @type string[] to          Email addresses to send message.
--                         --     @type string   subject     Email subject.
--                         --     @type string   message     Message contents.
--                         --     @type string[] headers     Additional headers.
--                         --     @type string[] attachments Paths to files to attach.
--                         -- end;
--                         --
--                         do_action( 'wp_mail_succeeded', mail_data );

--                         return send;
--                 end; catch ( PHPMailer\PHPMailer\Exception e ) then
--                         mail_data['phpmailer_exception_code'] = e->getCode();

--                         --
--                         -- Fires after a PHPMailer\PHPMailer\Exception is caught.
--                         --
--                         -- @since 4.4.0
--                         --
--                         -- @param WP_Error error A WP_Error object with the PHPMailer\PHPMailer\Exception message, and an array
--                         --                        containing the mail recipient, subject, message, headers, and attachments.
--                         --
--                         do_action( 'wp_mail_failed', new WP_Error( 'wp_mail_failed', e->getMessage(), mail_data ) );

--                         return false;
--                 end;
--         end;
-- endif;

-- if ( ! function_exists( 'wp_authenticate' ) ) :

   ---------------------
   -- Wp_Authenticate --
   ---------------------

   function Wp_Authenticate (Username : String;
                             Password : String)
                             return Inc_Users.User_Error_Type
   is
      use Php.Lists;
      use Php.Strings;
      use Wp_Common;
      use Class_Errors;
      use Class_Users;
      use Inc_Formatting;
      use Inc_L10n;
      use Inc_Users;

      Username_2 : constant String := Sanitize_User (Username);
      Password_2 : constant String := Trim (Password);

      Ignore_Codes : constant List_Type :=
        ["empty_username", "empty_password"];

      --
      -- Filters whether a set of user login credentials are valid.
      --
      -- A WP_User object is returned if the credentials authenticate a user.
      -- WP_Error or null otherwise.
      --
      -- @since 2.8.0
      -- @since 4.5.0 `username` now accepts an email address.
      --
      -- @param null|WP_User|WP_Error user     WP_User if the user is authenticated.
      --                                        WP_Error or null otherwise.
      -- @param string                username Username or email address.
      -- @param string                password User password.
      --

      Null_User_Error : constant User_Error_Type :=
        (Success => False,
         User    => Null_User,
         Error   => Null_Wp_Error);

      User : User_Error_Type :=
        Apply_Filters ("authenticate",
                       Null_User_Error,
                       Username_2, Password_2);
   begin
      if not User.Success then
--    if null = User then
         -- TODO: What should the error message be? (Or would these even happen?)
         -- Only needed if all authentication handlers fail to return anything.
         User.Error :=
           X_Construct ("authentication_failed",
                        abs "<strong>Error:</strong> Invalid username, email address or incorrect password.");
      end if;

      if
        not User.Success and then
--      Is_Wp_Error (User) and then
        not In_List (User.Error.Get_Error_Code, Ignore_Codes, True)
      then
         --
         -- Fires after a user login has failed.
         --
         -- @since 2.5.0
         -- @since 4.5.0 The value of `username` can now be an email address.
         -- @since 5.4.0 The `error` parameter was added.
         --
         -- @param string   username Username or email address.
         -- @param WP_Error error    A WP_Error object with the authentication
         --                          failure details.
         --
         Do_Action ("wp_login_failed", Username_2, User.Error);
      end if;

      return User;
   end Wp_Authenticate;

-- endif;

-- if ( ! function_exists( 'wp_logout' ) ) :

   ---------------
   -- Wp_Logout --
   ---------------

   procedure Wp_Logout
   is
      use Wp_Common;
--    use Inc_Plugins;
      use Inc_Users;

      User_Id : constant User_Id_Type := Get_Current_User_Id;
   begin
      Wp_Destroy_Current_Session;
      Wp_Clear_Auth_Cookie;
      Wp_Set_Current_User (0);

      --
      -- Fires after a user is logged out.
      --
      -- @since 1.5.0
      -- @since 5.5.0 Added the `user_id` parameter.
      --
      -- @param int user_id ID of the user that was logged out.
      --
      Do_Action ("wp_logout", User_Id);
   end Wp_Logout;

-- endif;

-- if ( ! function_exists( 'wp_validate_auth_cookie' ) ) :

   -----------------------------
   -- Wp_Validate_Auth_Cookie --
   -----------------------------

   function Wp_Validate_Auth_Cookie (Cookie : String := "";
                                     Scheme : String := "")
                                     return Class_Users.User_Id_Type
   is
      use Php.Misc;
      use Php.Strings;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Class_Users;
      use Inc_Compat;
      use Inc_Load;
      use Inc_Plugins;

      Cookie_Elements : constant Array_Type :=
        Wp_Parse_Auth_Cookie (Cookie, Scheme);
   begin
      if Cookie_Elements = Empty_Array then -- not
         --
         -- Fires if an authentication cookie is malformed.
         --
         -- @since 2.7.0
         --
         -- @param string cookie Malformed auth cookie.
         -- @param string scheme Authentication scheme. Values include 'auth',
         --                      'secure_auth', or 'logged_in'.
         --
         Do_Action ("auth_cookie_malformed", Cookie, Scheme);
         return 0; -- False;
      end if;

      declare
         Scheme     : constant String := Get_As_String (Cookie_Elements, "scheme");
         Username   : constant String := Get_As_String (Cookie_Elements, "username");
         Hmac       : constant String := Get_As_String (Cookie_Elements, "hmac");
         Token      : constant String := Get_As_String (Cookie_Elements, "token");
         Expiration : constant String := Get_As_String (Cookie_Elements, "expiration");
         Expired    : Natural := As_Integer (Get (Cookie_Elements, "expiration"));
      begin
         -- Allow a grace period for POST and Ajax requests.
         if
           Wp_Doing_AJAX or else
           "POST" = Get_As_String (X_SERVER, "REQUEST_METHOD")
         then
            Expired := Expired + Constants.HOUR_IN_SECONDS;
         end if;

         -- Quick check to see if an honest cookie has expired.
         if Expired < Php.Misc.Time then
            --
            -- Fires once an authentication cookie has expired.
            --
            -- @since 2.7.0
            --
            -- @param string[] cookie_elements {
            --     Authentication cookie components. None of the components should
            --     be assumed to be valid as they come directly from a client-provided
            --     cookie value.
            --
            --     @type string username   User's username.
            --     @type string expiration The time the cookie expires as a UNIX
            --                              timestamp.
            --     @type string token      User's session token used.
            --     @type string hmac       The security hash for the cookie.
            --     @type string scheme     The cookie scheme to use.
            -- }
            --
            Do_Action ("auth_cookie_expired", Cookie_Elements);
            return 0; -- False;
         end if;

         declare
            User : constant Wp_User := Get_User_By ("login", Username);
         begin
            if User = Null_User then  -- not
               --
               -- Fires if a bad username is entered in the user authentication
               -- process.
               --
               -- @since 2.7.0
               --
               -- @param string[] cookie_elements {
               --     Authentication cookie components. None of the components
               --     should be assumed to be valid as they come directly from a
               --     client-provided cookie value.
               --
               --     @type string username   User's username.
               --     @type string expiration The time the cookie expires as a
               --                             UNIX timestamp.
               --     @type string token      User's session token used.
               --     @type string hmac       The security hash for the cookie.
               --     @type string scheme     The cookie scheme to use.
               -- }
               --
               Do_Action ("auth_cookie_bad_username", Cookie_Elements);
               return 0; -- False;
            end if;

            declare
               Pass_Frag : constant String := Substr (-User.Prop.User_Pass, 8, 4);

               Key : constant String :=
                 Wp_Hash (Username & '|' & Pass_Frag & '|' & Expiration & '|' & Token,
                          Scheme);

               -- If ext/hash is not present, compat.php's hash_hmac() does not
               -- support sha256.
               Algo : String := (if Function_Exists ("hash")
                                 then "sha256" else "sha1");

               Hash : constant String :=
                 Hash_Hmac (Algo, Username & '|' & Expiration & '|' & Token, Key);
            begin
               if not Hash_Equals (Hash, Hmac) then
                  --
                  -- Fires if a bad authentication cookie hash is encountered.
                  --
                  -- @since 2.7.0
                  --
                  -- @param string[] cookie_elements {
                  --     Authentication cookie components. None of the components
                  --     should be assumed to be valid as they come directly from
                  --     a client-provided cookie value.
                  --
                  --     @type string username   User's username.
                  --     @type string expiration The time the cookie expires as a
                  --                             UNIX timestamp.
                  --     @type string token      User's session token used.
                  --     @type string hmac       The security hash for the cookie.
                  --     @type string scheme     The cookie scheme to use.
                  -- }
                  --
                  Do_Action ("auth_cookie_bad_hash", Cookie_Elements);
                  return 0; -- False;
               end if;
            end;

            declare
               use Class_Session_Tokens;
               use Class_Session_Tokens_Factory;

               Manager : constant Wp_Session_Tokens'Class :=
                 Get_Instance (User.Id);
            begin
               if not Manager.Verify (Token) then
                  --
                  -- Fires if a bad session token is encountered.
                  --
                  -- @since 4.0.0
                  --
                  -- @param string[] cookie_elements {
                  --     Authentication cookie components. None of the components
                  --     should be assumed to be valid as they come directly from
                  --     a client-provided cookie value.
                  --
                  --     @type string username   User's username.
                  --     @type string expiration The time the cookie expires as a
                  --                             UNIX timestamp.
                  --     @type string token      User's session token used.
                  --     @type string hmac       The security hash for the cookie.
                  --     @type string scheme     The cookie scheme to use.
                  -- }
                  --
                  Do_Action ("auth_cookie_bad_session_token", Cookie_Elements);
                  return 0; -- False;
               end if;
            end;

            -- Ajax/POST grace period set above.
            if Expired < Php.Misc.Time then
--          if Expiration < Php.Misc.Time then            -- ???
               Globals.Login_Grace_Period := 1;
--             GLOBALS["login_grace_period"] = 1;
            end if;

            --
            -- Fires once an authentication cookie has been validated.
            --
            -- @since 2.7.0
            --
            -- @param string[] cookie_elements {
            --     Authentication cookie components.
            --
            --     @type string username   User's username.
            --     @type string expiration The time the cookie expires as a UNIX
            --                             timestamp.
            --     @type string token      User's session token used.
            --     @type string hmac       The security hash for the cookie.
            --     @type string scheme     The cookie scheme to use.
            -- }
            -- @param WP_User  user            User object.
            --
            Do_Action ("auth_cookie_valid", Cookie_Elements, User);

            return User.Id;
         end;
      end;
   end Wp_Validate_Auth_Cookie;

-- endif;

-- if ( ! function_exists( 'wp_generate_auth_cookie' ) ) :
--         --
--         -- Generates authentication cookie contents.
--         --
--         -- @since 2.5.0
--         -- @since 4.0.0 The `token` parameter was added.
--         --
--         -- @param int    user_id    User ID.
--         -- @param int    expiration The time the cookie expires as a UNIX timestamp.
--         -- @param string scheme     Optional. The cookie scheme to use: 'auth', 'secure_auth', or 'logged_in'.
--         --                           Default 'auth'.
--         -- @param string token      User's session token to use for this cookie.
--         -- @return string Authentication cookie contents. Empty string if user does not exist.
--         --
--         function wp_generate_auth_cookie( user_id, expiration, scheme = 'auth', token = '' ) then
--                 user = get_userdata( user_id );
--                 if ( ! user ) then
--                         return '';
--                 end;

--                 if ( ! token ) then
--                         manager = WP_Session_Tokens::get_instance( user_id );
--                         token   = manager->create( expiration );
--                 end;

--                 pass_frag = substr( user->user_pass, 8, 4 );

--                 key = wp_hash( user->user_login . '|' . pass_frag . '|' . expiration . '|' . token, scheme );

--                 -- If ext/hash is not present, compat.php's hash_hmac() does not support sha256.
--                 algo = function_exists( 'hash' ) ? 'sha256' : 'sha1';
--                 hash = hash_hmac( algo, user->user_login . '|' . expiration . '|' . token, key );

--                 cookie = user->user_login . '|' . expiration . '|' . token . '|' . hash;

--                 --
--                 -- Filters the authentication cookie.
--                 --
--                 -- @since 2.5.0
--                 -- @since 4.0.0 The `token` parameter was added.
--                 --
--                 -- @param string cookie     Authentication cookie.
--                 -- @param int    user_id    User ID.
--                 -- @param int    expiration The time the cookie expires as a UNIX timestamp.
--                 -- @param string scheme     Cookie scheme used. Accepts 'auth', 'secure_auth', or 'logged_in'.
--                 -- @param string token      User's session token used.
--                 --
--                 return apply_filters( 'auth_cookie', cookie, user_id, expiration, scheme, token );
--         end;
-- endif;

-- if ( ! function_exists( 'wp_parse_auth_cookie' ) ) :

   --------------------------
   -- Wp_Parse_Auth_Cookie --
   --------------------------

   function Wp_Parse_Auth_Cookie (Cookie : String := "";
                                  Scheme : String := "")
                                  return Array_Type
   is
      use Binder;
      use UStrings;
      use Inc_Load;

      Cookie_Name : UString;
      Cookie_2    : UString := +Cookie;
      Scheme_2    : UString := +Scheme;
   begin
      if Cookie = "" then
--    if ( empty( cookie ) ) then
         if Scheme = "auth" then
            -- case 'auth':
            Cookie_Name := Constants.AUTH_COOKIE;

         elsif Scheme = "secure_auth" then
            Cookie_Name := Constants.SECURE_AUTH_COOKIE;

         elsif Scheme = "logged_in" then
            Cookie_Name := Constants.LOGGED_IN_COOKIE;

         else
            if Is_SSL then
               Cookie_Name := Constants.SECURE_AUTH_COOKIE;
               Scheme_2    := +"secure_auth";
            else
               Cookie_Name := Constants.AUTH_COOKIE;
               Scheme_2    := +"auth";
            end if;
         end if;

         if Empty (X_COOKIE, -Cookie_Name) then
            return Empty_Array; -- false;
         end if;
         Cookie_2 := +Get_As_String (X_COOKIE, -Cookie_Name);
      end if;

      declare
         use Ada.Containers;

         Cookie_Elements : constant List_Type := Php.Strings.Explode ("|", -Cookie_2);
      begin
         if Cookie_Elements.Length /= 4 then
            return Empty_Array; -- false;
         end if;

         declare
            Username   : constant String := Cookie_Elements (1);
            Expiration : constant String := Cookie_Elements (2);
            Token      : constant String := Cookie_Elements (3);
            Hmac       : constant String := Cookie_Elements (4);
         begin
            return To_Array (List => (
              Build ("username",   Username),
              Build ("expiration", Expiration),
              Build ("token",      Token),
              Build ("hmac",       Hmac),
              Build ("scheme",     -Scheme_2)
            ));
--          return Php.Compact ("username", "expiration", "token", "hmac", "scheme");
         end;
      end;
   end Wp_Parse_Auth_Cookie;

-- endif;

-- if ( ! function_exists( 'wp_set_auth_cookie' ) ) :

   ------------------------
   -- Wp_Set_Auth_Cookie --
   ------------------------

   procedure Wp_Set_Auth_Cookie (User_Id  : User_Id_Type;
                                 Remember : Boolean := False;
                                 Secure   : Boolean := False; -- ""
                                 Token    : String  := "")
   is
   begin
      raise Program_Error with "not implemented";
   end Wp_Set_Auth_Cookie;
--                 if ( remember ) then
--                         --
--                         -- Filters the duration of the authentication cookie expiration period.
--                         --
--                         -- @since 2.8.0
--                         --
--                         -- @param int  length   Duration of the expiration period in seconds.
--                         -- @param int  user_id  User ID.
--                         -- @param bool remember Whether to remember the user login. Default false.
--                         --
--                         expiration = time() + apply_filters( 'auth_cookie_expiration', 14-- DAY_IN_SECONDS, user_id, remember );

--                         /*
--                         -- Ensure the browser will continue to send the cookie after the expiration time is reached.
--                         -- Needed for the login grace period in wp_validate_auth_cookie().
--                         --
--                         expire = expiration + ( 12-- HOUR_IN_SECONDS );
--                 end; else then
--                         -- This filter is documented in wp-includes/pluggable.php--
--                         expiration = time() + apply_filters( 'auth_cookie_expiration', 2-- DAY_IN_SECONDS, user_id, remember );
--                         expire     = 0;
--                 end;

--                 if ( '' === secure ) then
--                         secure = is_ssl();
--                 end;

--                 -- Front-end cookie is secure when the auth cookie is secure and the site's home URL uses HTTPS.
--                 secure_logged_in_cookie = secure && 'https' === parse_url( get_option( 'home' ), PHP_URL_SCHEME );

--                 --
--                 -- Filters whether the auth cookie should only be sent over HTTPS.
--                 --
--                 -- @since 3.1.0
--                 --
--                 -- @param bool secure  Whether the cookie should only be sent over HTTPS.
--                 -- @param int  user_id User ID.
--                 --
--                 secure = apply_filters( 'secure_auth_cookie', secure, user_id );

--                 --
--                 -- Filters whether the logged in cookie should only be sent over HTTPS.
--                 --
--                 -- @since 3.1.0
--                 --
--                 -- @param bool secure_logged_in_cookie Whether the logged in cookie should only be sent over HTTPS.
--                 -- @param int  user_id                 User ID.
--                 -- @param bool secure                  Whether the auth cookie should only be sent over HTTPS.
--                 --
--                 secure_logged_in_cookie = apply_filters( 'secure_logged_in_cookie', secure_logged_in_cookie, user_id, secure );

--                 if ( secure ) then
--                         auth_cookie_name = SECURE_AUTH_COOKIE;
--                         scheme           = 'secure_auth';
--                 end; else then
--                         auth_cookie_name = AUTH_COOKIE;
--                         scheme           = 'auth';
--                 end;

--                 if ( '' === token ) then
--                         manager = WP_Session_Tokens::get_instance( user_id );
--                         token   = manager->create( expiration );
--                 end;

--                 auth_cookie      = wp_generate_auth_cookie( user_id, expiration, scheme, token );
--                 logged_in_cookie = wp_generate_auth_cookie( user_id, expiration, 'logged_in', token );

--                 --
--                 -- Fires immediately before the authentication cookie is set.
--                 --
--                 -- @since 2.5.0
--                 -- @since 4.9.0 The `token` parameter was added.
--                 --
--                 -- @param string auth_cookie Authentication cookie value.
--                 -- @param int    expire      The time the login grace period expires as a UNIX timestamp.
--                 --                            Default is 12 hours past the cookie's expiration time.
--                 -- @param int    expiration  The time when the authentication cookie expires as a UNIX timestamp.
--                 --                            Default is 14 days from now.
--                 -- @param int    user_id     User ID.
--                 -- @param string scheme      Authentication scheme. Values include 'auth' or 'secure_auth'.
--                 -- @param string token       User's session token to use for this cookie.
--                 --
--                 do_action( 'set_auth_cookie', auth_cookie, expire, expiration, user_id, scheme, token );

--                 --
--                 -- Fires immediately before the logged-in authentication cookie is set.
--                 --
--                 -- @since 2.6.0
--                 -- @since 4.9.0 The `token` parameter was added.
--                 --
--                 -- @param string logged_in_cookie The logged-in cookie value.
--                 -- @param int    expire           The time the login grace period expires as a UNIX timestamp.
--                 --                                 Default is 12 hours past the cookie's expiration time.
--                 -- @param int    expiration       The time when the logged-in authentication cookie expires as a UNIX timestamp.
--                 --                                 Default is 14 days from now.
--                 -- @param int    user_id          User ID.
--                 -- @param string scheme           Authentication scheme. Default 'logged_in'.
--                 -- @param string token            User's session token to use for this cookie.
--                 --
--                 do_action( 'set_logged_in_cookie', logged_in_cookie, expire, expiration, user_id, 'logged_in', token );

--                 --
--                 -- Allows preventing auth cookies from actually being sent to the client.
--                 --
--                 -- @since 4.7.4
--                 --
--                 -- @param bool send Whether to send auth cookies to the client.
--                 --
--                 if ( ! apply_filters( 'send_auth_cookies', true ) ) then
--                         return;
--                 end;

--                 setcookie( auth_cookie_name, auth_cookie, expire, PLUGINS_COOKIE_PATH, COOKIE_DOMAIN, secure, true );
--                 setcookie( auth_cookie_name, auth_cookie, expire, ADMIN_COOKIE_PATH, COOKIE_DOMAIN, secure, true );
--                 setcookie( LOGGED_IN_COOKIE, logged_in_cookie, expire, COOKIEPATH, COOKIE_DOMAIN, secure_logged_in_cookie, true );
--                 if ( COOKIEPATH != SITECOOKIEPATH ) then
--                         setcookie( LOGGED_IN_COOKIE, logged_in_cookie, expire, SITECOOKIEPATH, COOKIE_DOMAIN, secure_logged_in_cookie, true );
--                 end;
--         end;
-- endif;

-- if ( ! function_exists( 'wp_clear_auth_cookie' ) ) :

   --------------------------
   -- Wp_Clear_Auth_Cookie --
   --------------------------

   procedure Wp_Clear_Auth_Cookie
   is
      use Php.HTML;
      use Php.Misc;
      use Constants;
      use UStrings;
      use Wp_Common;
      use Inc_Plugins;
      use Inc_Users;
   begin
      --
      -- Fires just before the authentication cookies are cleared.
      --
      -- @since 2.7.0
      --
      Do_Action ("clear_auth_cookie");

      -- This filter is documented in wp-includes/pluggable.php
      if not Apply_Filters ("send_auth_cookies", True) then
         return;
      end if;

      -- Auth cookies.
      Set_Cookie (-AUTH_COOKIE, " ", Time - YEAR_IN_SECONDS,
                  -ADMIN_COOKIE_PATH, -COOKIE_DOMAIN);
      Set_Cookie (-SECURE_AUTH_COOKIE, " ", Time - YEAR_IN_SECONDS,
                  -ADMIN_COOKIE_PATH, -COOKIE_DOMAIN);
      Set_Cookie (-AUTH_COOKIE, " ", Time - YEAR_IN_SECONDS,
                  -PLUGINS_COOKIE_PATH, -COOKIE_DOMAIN);
      Set_Cookie (-SECURE_AUTH_COOKIE, " ", Time - YEAR_IN_SECONDS,
                  -PLUGINS_COOKIE_PATH, -COOKIE_DOMAIN);
      Set_Cookie (-LOGGED_IN_COOKIE, " ", Time - YEAR_IN_SECONDS,
                  -COOKIEPATH, -COOKIE_DOMAIN);
      Set_Cookie (-LOGGED_IN_COOKIE, " ", Time - YEAR_IN_SECONDS,
                  -SITECOOKIEPATH, -COOKIE_DOMAIN);

      -- Settings cookies.
      Set_Cookie ("wp-settings-" & Helpers.Image (Integer (Get_Current_User_Id)), " ",
                  Time - YEAR_IN_SECONDS, -SITECOOKIEPATH);
      Set_Cookie ("wp-settings-time-" & Helpers.Image (Integer (Get_Current_User_Id)), " ",
                  Time - YEAR_IN_SECONDS, -SITECOOKIEPATH);

      -- Old cookies.
      Set_Cookie (-AUTH_COOKIE, " ", Time - YEAR_IN_SECONDS,
                  -COOKIEPATH, -COOKIE_DOMAIN);
      Set_Cookie (-AUTH_COOKIE, " ", Time - YEAR_IN_SECONDS,
                  -SITECOOKIEPATH, -COOKIE_DOMAIN);
      Set_Cookie (-SECURE_AUTH_COOKIE, " ", Time - YEAR_IN_SECONDS,
                  -COOKIEPATH, -COOKIE_DOMAIN);
      Set_Cookie (-SECURE_AUTH_COOKIE, " ", Time - YEAR_IN_SECONDS,
                  -SITECOOKIEPATH, -COOKIE_DOMAIN);

      -- Even older cookies.
      Set_Cookie (-USER_COOKIE, " ", Time - YEAR_IN_SECONDS,
                  -COOKIEPATH, -COOKIE_DOMAIN);
      Set_Cookie (-PASS_COOKIE, " ", Time - YEAR_IN_SECONDS,
                  -COOKIEPATH, -COOKIE_DOMAIN);
      Set_Cookie (-USER_COOKIE, " ", Time - YEAR_IN_SECONDS,
                  -SITECOOKIEPATH, -COOKIE_DOMAIN);
      Set_Cookie (-PASS_COOKIE, " ", Time - YEAR_IN_SECONDS,
                  -SITECOOKIEPATH, -COOKIE_DOMAIN);

      -- Post password cookie.
      Set_Cookie ("wp-postpass_" & (-COOKIEHASH), " ",
                  Time - YEAR_IN_SECONDS, -COOKIEPATH, -COOKIE_DOMAIN);
   end Wp_Clear_Auth_Cookie;

-- endif;

-- if ( ! function_exists( 'is_user_logged_in' ) ) :

   -----------------------
   -- Is_User_Logged_In --
   -----------------------

   function Is_User_Logged_In
            return Boolean
   is
      use Class_Users;

      User : constant Wp_User := Wp_Get_Current_User;
   begin
      return User.Exists;
   end Is_User_Logged_In;

-- endif;

-- if ( ! function_exists( 'auth_redirect' ) ) :

   -------------------
   -- Auth_Redirect --
   -------------------

   procedure Auth_Redirect
   is
      use Php.Errors;
      use Php.Strings;
      use Binder;
      use Wp_Common;
      use Class_Users;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_Users;

      Secure_2 : constant Boolean := Is_SSL or else Force_SSL_Admin;

      --
      -- Filters whether to use a secure authentication redirect.
      --
      -- @since 3.1.0
      --
      -- @param bool secure Whether to use a secure authentication redirect.
      --                    Default false.
      --
      Secure : constant Boolean :=
        Apply_Filters ("secure_auth_redirect", Secure_2);
   begin
      -- If https is required and request is http, redirect.
      if
        Secure and then
        not Is_SSL and then
        0 /= Strpos (Get_As_String (X_SERVER, "REQUEST_URI"), "wp-admin") -- false
      then
         if 0 = Strpos (Get_As_String (X_SERVER, "REQUEST_URI"), "http") then
            Wp_Redirect (Set_URL_Scheme (Get_As_String (X_SERVER, "REQUEST_URI"),
                                         "https"));
            Die; -- exit;
         else
            Wp_Redirect ("https://" &
                         Get_As_String (X_SERVER, "HTTP_HOST") &
                         Get_As_String (X_SERVER, "REQUEST_URI"));
            Die; -- exit;
         end if;
      end if;

      --
      -- Filters the authentication redirect scheme.
      --
      -- @since 2.9.0
      --
      -- @param string scheme Authentication redirect scheme. Default empty.
      --
      declare
         Scheme  : constant String  :=
           Apply_Filters ("auth_redirect_scheme", "");

         User_Id : constant User_Id_Type :=
           Wp_Validate_Auth_Cookie ("", Scheme);
      begin
         if User_Id /= 0 then
            --
            -- Fires before the authentication redirect.
            --
            -- @since 2.8.0
            --
            -- @param int user_id User ID.
            --
            Do_Action ("auth_redirect", User_Id);

            -- If the user wants ssl but the session is not ssl, redirect.
            if
              not Secure and then
              Get_User_Option ("use_ssl", User_Id) and then
              0 /= Strpos (Get_As_String (X_SERVER, "REQUEST_URI"), "wp-admin") -- false
            then
               if 0 = Strpos (Get_As_String (X_SERVER, "REQUEST_URI"), "http") then
                  Wp_Redirect
                    (Set_URL_Scheme (Get_As_String (X_SERVER, "REQUEST_URI"),
                     "https"));
                  Die; -- exit;
               else
                  Wp_Redirect ("https://" &
                               Get_As_String (X_SERVER, "HTTP_HOST") &
                               Get_As_String (X_SERVER, "REQUEST_URI"));
                  Die; -- exit;
               end if;
            end if;

            return; -- The cookie is good, so we're done.
         end if;

         -- The cookie is no good, so force login.
         Nocache_Headers;

         declare
            Redirect : constant String :=
              (if Strpos (Get_As_String (X_SERVER, "REQUEST_URI"),
                         "/options.php") /= 0 and then Wp_Get_Referer /= ""
               then Wp_Get_Referer
               else Set_URL_Scheme ("http://" &
                                    Get_As_String (X_SERVER, "HTTP_HOST") &
                                    Get_As_String (X_SERVER, "REQUEST_URI")));

            Login_URL : constant String :=
              Wp_Login_URL (Redirect, True);
         begin
            Wp_Redirect (Login_URL);
            Die; -- exit;
         end;
      end;
   end Auth_Redirect;

-- endif;

-- if ( ! function_exists( 'check_admin_referer' ) ) :

   -------------------------
   -- Check_Admin_Referer --
   -------------------------

   function Check_Admin_Referer (Action    : String := "-1";
                                 Query_Arg : String := "_wpnonce")
                                 return Integer
   is
      use Php.Errors;
      use Php.Strings;
      use Binder;
      use Wp_Common;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_L10n;
   begin
      if "-1" = Action then -- -1
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "You should specify an action to be verified by using the first parameter.",
           "3.2.0");
      end if;

      declare
         Adminurl : constant String := Strtolower (Admin_URL);
         Referer  : constant String := Strtolower (Wp_Get_Referer);

         Result : constant Integer :=
           (if Isset (X_REQUEST, Query_Arg)
            then Wp_Verify_Nonce (Get_As_String (X_REQUEST, Query_Arg), Action)
            else 0); -- False);
      begin
         --
         -- Fires once the admin request has been validated or not.
         --
         -- @since 1.5.1
         --
         -- @param string    action The nonce action.
         -- @param false|int result False if the nonce is invalid, 1 if the nonce is
         --                          valid and generated between 0-12 hours ago, 2 if
         --                          the nonce is valid and generated between 12-24
         --                          hours ago.
         --
         --
         Do_Action ("check_admin_referer", Action, Result);

         if
           Result = 0 and then -- not
           not ("-1" = Action and then Strpos (Referer, Adminurl) = 0) -- -1
         then
            Wp_Nonce_AYS (Action'Image); -- 'image added
            Die;
         end if;

         return Result;
      end;
   end Check_Admin_Referer;

   -------------------------
   -- Check_Admin_Referer --
   -------------------------

   procedure Check_Admin_Referer (Action    : String := "-1";  -- = -1
                                  Query_Arg : String := "_wpnonce")
   is
      Unused : constant Integer :=
        Check_Admin_Referer (Action, Query_Arg);
   begin
      null;
   end Check_Admin_Referer;

-- endif;

-- if ( ! function_exists( 'check_ajax_referer' ) ) :
--         --
--         -- Verifies the Ajax request to prevent processing requests external of the blog.
--         --
--         -- @since 2.0.3
--         --
--         -- @param int|string   action    Action nonce.
--         -- @param false|string query_arg Optional. Key to check for the nonce in `_REQUEST` (since 2.5). If false,
--         --                                `_REQUEST` values will be evaluated for '_ajax_nonce', and '_wpnonce'
--         --                                (in that order). Default false.
--         -- @param bool         die       Optional. Whether to die early when the nonce cannot be verified.
--         --                                Default true.
--         -- @return int|false 1 if the nonce is valid and generated between 0-12 hours ago,
--         --                   2 if the nonce is valid and generated between 12-24 hours ago.
--         --                   False if the nonce is invalid.
--         --
--         function check_ajax_referer( action = -1, query_arg = false, die = true ) then
--                 if ( -1 == action ) then
--                         _doing_it_wrong( __FUNCTION__, __( 'You should specify an action to be verified by using the first parameter.' ), '4.7.0' );
--                 end;

--                 nonce = '';

--                 if ( query_arg && isset( _REQUEST[ query_arg ] ) ) then
--                         nonce = _REQUEST[ query_arg ];
--                 end; elseif ( isset( _REQUEST['_ajax_nonce'] ) ) then
--                         nonce = _REQUEST['_ajax_nonce'];
--                 end; elseif ( isset( _REQUEST['_wpnonce'] ) ) then
--                         nonce = _REQUEST['_wpnonce'];
--                 end;

--                 result = wp_verify_nonce( nonce, action );

--                 --
--                 -- Fires once the Ajax request has been validated or not.
--                 --
--                 -- @since 2.1.0
--                 --
--                 -- @param string    action The Ajax nonce action.
--                 -- @param false|int result False if the nonce is invalid, 1 if the nonce is valid and generated between
--                 --                          0-12 hours ago, 2 if the nonce is valid and generated between 12-24 hours ago.
--                 --
--                 do_action( 'check_ajax_referer', action, result );

--                 if ( die && false === result ) then
--                         if ( wp_doing_ajax() ) then
--                                 wp_die( -1, 403 );
--                         end; else then
--                                 die( '-1' );
--                         end;
--                 end;

--                 return result;
--         end;
-- endif;

-- if ( ! function_exists( 'wp_redirect' ) ) :

   -----------------
   -- Wp_Redirect --
   -----------------

   function Wp_Redirect (Location      : String;
                         Status        : Integer := 302;
                         X_Redirect_By : String  := "WordPress")
                         return Boolean
   is
      use Php.HTML;
      use Wp_Common;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Vars;

      --
      -- Filters the redirect location.
      --
      -- @since 2.1.0
      --
      -- @param string location The path or URL to redirect to.
      -- @param int    status   The HTTP response status code to use.
      --
      Location_2 : constant String :=
        Apply_Filters ("wp_redirect", Location, Status);

      --
      -- Filters the redirect HTTP response status code to use.
      --
      -- @since 2.3.0
      --
      -- @param int    status   The HTTP response status code to use.
      -- @param string location The path or URL to redirect to.
      --
      Status_2 : constant Integer :=
        Apply_Filters ("wp_redirect_status", Status, Location_2);
   begin
      if Location_2 = "" then
         return False;
      end if;

      if Status_2 not in 300 .. 399 then
         Wp_Die (abs "HTTP redirect status code must be a redirection code, 3xx.");
      end if;

      declare
         Location_3 : constant String := Wp_Sanitize_Redirect (Location_2);
      begin
         if not Is_IIS and then "cgi-fcgi" /= PHP_SAPI then
            Status_Header (Status_2);
            -- This causes problems on IIS and some FastCGI setups.
         end if;

         --
         -- Filters the X-Redirect-By header.
         --
         -- Allows applications to identify themselves when they're doing a redirect.
         --
         -- @since 5.1.0
         --
         -- @param string x_redirect_by The application doing the redirect.
         -- @param int    status        Status code to use.
         -- @param string location      The path to redirect to.
         --
         declare
            X_Redirect_By_2 : constant String :=
              Apply_Filters ("x_redirect_by", X_Redirect_By, Status_2, Location_3);
         begin
            if True then -- Is_String (X_Redirect_By_2) then
               Header ("X-Redirect-By: " & X_Redirect_By_2);
            end if;

            Header ("Location: " & Location_3, True, Status_2);

            return True;
         end;
      end;
   end Wp_Redirect;

   -----------------
   -- Wp_Redirect --
   -----------------

   procedure Wp_Redirect (Location      : String;
                          Status        : Integer := 302;
                          X_Redirect_By : String  := "WordPress")
   is
      Unused : constant Boolean :=
        Wp_Redirect (Location, Status, X_Redirect_By);
   begin
      null;
   end Wp_Redirect;

-- endif;

-- if ( ! function_exists( 'wp_sanitize_redirect' ) ) :

   --------------------------
   -- Wp_Sanitize_Redirect --
   --------------------------

   function Wp_Sanitize_Redirect (Location : String)
                                  return String
   is
      use Php.Preg;
      use Php.Strings;
      use Inc_Formatting;
      use Inc_KSES;

      -- Encode spaces.
      Location_2 : constant String := Str_Replace (" ", "%20", Location);

      Regex : constant String :=
        "/("
          & "(?: [\xC2-\xDF][\x80-\xBF]"
          -- double-byte sequences   110xxxxx 10xxxxxx
          & "|   \xE0[\xA0-\xBF][\x80-\xBF]"
          -- triple-byte sequences   1110xxxx 10xxxxxx-- 2
          & "|   [\xE1-\xEC][\x80-\xBF]{2}"
          & "|   \xED[\x80-\x9F][\x80-\xBF]"
          & "|   [\xEE-\xEF][\x80-\xBF]{2}"
          & "|   \xF0[\x90-\xBF][\x80-\xBF]{2}"
          -- four-byte sequences   11110xxx 10xxxxxx-- 3
          & "|   [\xF1-\xF3][\x80-\xBF]{3}"
          & "|   \xF4[\x80-\x8F][\x80-\xBF]{2}"
        & "){1,40}"              -- ...one or more times
        & ")/x";

      Location_3 : constant String :=
        Preg_Replace_Callback (Regex,
                               X_Wp_Sanitize_UTF8_In_Redirect'Access,
                               Location_2);

      Location_4 : constant String :=
        Preg_Replace ("|[^a-z0-9-~+_.?#=&;,/:%!*\[\]()@]|i", "", Location_3);

      Location_5 : constant String := Wp_KSES_No_Null (Location_4);

      -- Remove %0D and %0A from location.
      Strip : constant List_Type :=
        ["%0d", "%0a", "%0D", "%0A"];
   begin
      return X_Deep_Replace (Strip, Location_5);
   end Wp_Sanitize_Redirect;

   ------------------------------------
   -- X_Wp_Sanitize_UTF8_In_Redirect --
   ------------------------------------

   function X_Wp_Sanitize_UTF8_In_Redirect (Matches : List_Type)
                                            return String
   is
      use Php.HTML;
   begin
      return URL_Encode (Matches.First_Element); -- [0]
   end X_Wp_Sanitize_UTF8_In_Redirect;

-- endif;

-- if ( ! function_exists( 'wp_safe_redirect' ) ) :

   ----------------------
   -- Wp_Safe_Redirect --
   ----------------------

   function Wp_Safe_Redirect (Location      : String;
                              Status        : Integer := 302;
                              X_Redirect_By : String := "WordPress")
                              return Boolean
   is
      use Wp_Common;
      use Inc_Link_Templates;

      -- Need to look at the URL the way it will end up in wp_redirect().
      Location_2 : constant String :=
        Wp_Sanitize_Redirect (Location);

      --
      -- Filters the redirect fallback URL for when the provided redirect is not
      -- safe (local).
      --
      -- @since 4.3.0
      --
      -- @param string fallback_url The fallback URL to use by default.
      -- @param int    status       The HTTP response status code to use.
      --
      Location_3 : constant String :=
        Wp_Validate_Redirect
          (Location_2,
           Apply_Filters ("wp_safe_redirect_fallback", Admin_URL, Status));
   begin
      return Wp_Redirect (Location_3, Status, X_Redirect_By);
   end Wp_Safe_Redirect;

   ----------------------
   -- Wp_Safe_Redirect --
   ----------------------

   procedure Wp_Safe_Redirect (Location      : String;
                               Status        : Integer := 302;
                               X_Redirect_By : String := "WordPress")
   is
      Unused : constant Boolean :=
        Wp_Safe_Redirect (Location, Status, X_Redirect_By);
   begin
      null;
   end Wp_Safe_Redirect;

-- endif;

-- if ( ! function_exists( 'wp_validate_redirect' ) ) :

   --------------------------
   -- Wp_Validate_Redirect --
   --------------------------

   function Wp_Validate_Redirect (Location : String;
                                  Default  : String := "")
                                  return String
   is
      use Php.Files;
      use Php.HTML;
      use Php.Lists;
      use Php.Strings;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Inc_Functions;
      use Inc_Link_Templates;

      Location_2 : constant String :=
        Wp_Sanitize_Redirect (Trim (Location, " \t\n\r\0\x08\x0B"));

      Location_3 : UString := +Location_2;
   begin
      -- Browsers will assume 'http' is your protocol, and will obey a redirect
      -- to a URL starting with '//'.
      if "//" = Substr (-Location_3, 0, 2) then
         Location_3 := "http:" & Location_3;
      end if;

      -- In PHP 5 parse_url() may fail if the URL query part contains 'http://'.
      -- See https://bugs.php.net/bug.php?id=38143
      declare
         Cut : constant Natural := Strpos (-Location_3, "?");

         Test : constant String :=
           (if Cut /= 0 then Substr (-Location_3, 0, Cut) else -Location_3);

         Lp : constant Array_Type := Parse_URL (Test);
      begin
         -- Give up if malformed URL.
         if Lp = Empty_Array then -- false
            return Default;
         end if;

         -- Allow only 'http' and 'https' schemes. No 'data:', etc.
         if
           Isset (Lp, "scheme") and then
           Get_As_String (Lp, "scheme") not in "http" | "https"
         then
            return Default;
         end if;

         if
           not Isset (Lp, "host") and then
           not Empty (Lp, "path") and then
           '/' /= Get_As_String (Lp, "path") (1)
         then
            declare
               Path : UString;
            begin
               if not Empty (X_SERVER, "REQUEST_URI") then
                  Path :=
                    +Dirname (Parse_URL ("http://placeholder" &
                              Get_As_String (X_SERVER, "REQUEST_URI"),
                              PHP_URL_PATH) & '?');

                  Path := +Wp_Normalize_Path (-Path);
               end if;
               Location_3 := '/' & Ltrim ((-Path) & '/', "/") & Location_3;
            end;
         end if;

         -- Reject if certain components are set but host is not.
         -- This catches URLs like https:host.com for which parse_url() does not
         -- set the host field.
         if
           not Isset (Lp, "host") and then
           (Isset (Lp, "scheme") or else
            Isset (Lp, "user")   or else
            Isset (Lp, "pass")   or else
            Isset (Lp, "port"))
         then
            return Default;
         end if;

         -- Reject malformed components parse_url() can return on odd inputs.
         for Component of List_Type'["user", "pass", "host"] loop
            if
              Isset (Lp, Component) and then
              Strpbrk (Get_As_String (Lp, Component), ":/?#@") /= ""
            then
               return Default;
            end if;
         end loop;

         declare
            Wpp : constant Array_Type := Parse_URL (Home_URL);

            --
            -- Filters the list of allowed hosts to redirect to.
            --
            -- @since 2.3.0
            --
            -- @param string[] hosts An array of allowed host names.
            -- @param string   host  The host name of the redirect destination;
            --                       empty string if not set.
            --
            Allowed_Hosts : constant List_Type :=
              Apply_Filters ("allowed_redirect_hosts",
                             [Get_As_String (Wpp, "host")],
                             (if Isset (Lp, "host")
                              then Get_As_String (Lp, "host") else "")); -- (array)
         begin
            if
              Isset (Lp, "host") and then
              (not In_List (Get_As_String (Lp, "host"), Allowed_Hosts, True) and then
               Strtolower (Get_As_String (Wpp, "host")) /= Get_As_String (Lp, "host"))
            then
               Location_3 := +Default;
            end if;

            return -Location_3;
         end;
      end;
   end Wp_Validate_Redirect;

-- endif;

-- if ( ! function_exists( 'wp_notify_postauthor' ) ) :
--         --
--         -- Notifies an author (and/or others) of a comment/trackback/pingback on a post.
--         --
--         -- @since 1.0.0
--         --
--         -- @param int|WP_Comment comment_id Comment ID or WP_Comment object.
--         -- @param string         deprecated Not used.
--         -- @return bool True on completion. False if no email addresses were specified.
--         --
--         function wp_notify_postauthor( comment_id, deprecated = null ) then
--                 if ( null !== deprecated ) then
--                         _deprecated_argument( __FUNCTION__, '3.8.0' );
--                 end;

--                 comment = get_comment( comment_id );
--                 if ( empty( comment ) || empty( comment->comment_post_ID ) ) then
--                         return false;
--                 end;

--                 post   = get_post( comment->comment_post_ID );
--                 author = get_userdata( post->post_author );

--                 -- Who to notify? By default, just the post author, but others can be added.
--                 emails = array();
--                 if ( author ) then
--                         emails[] = author->user_email;
--                 end;

--                 --
--                 -- Filters the list of email addresses to receive a comment notification.
--                 --
--                 -- By default, only post authors are notified of comments. This filter allows
--                 -- others to be added.
--                 --
--                 -- @since 3.7.0
--                 --
--                 -- @param string[] emails     An array of email addresses to receive a comment notification.
--                 -- @param string   comment_id The comment ID as a numeric string.
--                 --
--                 emails = apply_filters( 'comment_notification_recipients', emails, comment->comment_ID );
--                 emails = array_filter( emails );

--                 -- If there are no addresses to send the comment to, bail.
--                 if ( ! count( emails ) ) then
--                         return false;
--                 end;

--                 -- Facilitate unsetting below without knowing the keys.
--                 emails = array_flip( emails );

--                 --
--                 -- Filters whether to notify comment authors of their comments on their own posts.
--                 --
--                 -- By default, comment authors aren't notified of their comments on their own
--                 -- posts. This filter allows you to override that.
--                 --
--                 -- @since 3.8.0
--                 --
--                 -- @param bool   notify     Whether to notify the post author of their own comment.
--                 --                           Default false.
--                 -- @param string comment_id The comment ID as a numeric string.
--                 --
--                 notify_author = apply_filters( 'comment_notification_notify_author', false, comment->comment_ID );

--                 -- The comment was left by the author.
--                 if ( author && ! notify_author && comment->user_id == post->post_author ) then
--                         unset( emails[ author->user_email ] );
--                 end;

--                 -- The author moderated a comment on their own post.
--                 if ( author && ! notify_author && get_current_user_id() == post->post_author ) then
--                         unset( emails[ author->user_email ] );
--                 end;

--                 -- The post author is no longer a member of the blog.
--                 if ( author && ! notify_author && ! user_can( post->post_author, 'read_post', post->ID ) ) then
--                         unset( emails[ author->user_email ] );
--                 end;

--                 -- If there's no email to send the comment to, bail, otherwise flip array back around for use below.
--                 if ( ! count( emails ) ) then
--                         return false;
--                 end; else then
--                         emails = array_flip( emails );
--                 end;

--                 switched_locale = switch_to_locale( get_locale() );

--                 comment_author_domain = '';
--                 if ( WP_Http::is_ip_address( comment->comment_author_IP ) ) then
--                         comment_author_domain = gethostbyaddr( comment->comment_author_IP );
--                 end;

--                 -- The blogname option is escaped with esc_html() on the way into the database in sanitize_option().
--                 -- We want to reverse this for the plain text arena of emails.
--                 blogname        = wp_specialchars_decode( get_option( 'blogname' ), ENT_QUOTES );
--                 comment_content = wp_specialchars_decode( comment->comment_content );

--                 switch ( comment->comment_type ) then
--                         case 'trackback':
--                                 /* translators: %s: Post title.--
--                                 notify_message = sprintf( __( 'New trackback on your post "%s"' ), post->post_title ) . "\r\n";
--                                 /* translators: 1: Trackback/pingback website name, 2: Website IP address, 3: Website hostname.--
--                                 notify_message .= sprintf( __( 'Website: %1s (IP address: %2s, %3s)' ), comment->comment_author, comment->comment_author_IP, comment_author_domain ) . "\r\n";
--                                 /* translators: %s: Trackback/pingback/comment author URL.--
--                                 notify_message .= sprintf( __( 'URL: %s' ), comment->comment_author_url ) . "\r\n";
--                                 /* translators: %s: Comment text.--
--                                 notify_message .= sprintf( __( 'Comment: %s' ), "\r\n" . comment_content ) . "\r\n\r\n";
--                                 notify_message .= __( 'You can see all trackbacks on this post here:' ) . "\r\n";
--                                 /* translators: Trackback notification email subject. 1: Site title, 2: Post title.--
--                                 subject = sprintf( __( '[%1s] Trackback: "%2s"' ), blogname, post->post_title );
--                                 break;

--                         case 'pingback':
--                                 /* translators: %s: Post title.--
--                                 notify_message = sprintf( __( 'New pingback on your post "%s"' ), post->post_title ) . "\r\n";
--                                 /* translators: 1: Trackback/pingback website name, 2: Website IP address, 3: Website hostname.--
--                                 notify_message .= sprintf( __( 'Website: %1s (IP address: %2s, %3s)' ), comment->comment_author, comment->comment_author_IP, comment_author_domain ) . "\r\n";
--                                 /* translators: %s: Trackback/pingback/comment author URL.--
--                                 notify_message .= sprintf( __( 'URL: %s' ), comment->comment_author_url ) . "\r\n";
--                                 /* translators: %s: Comment text.--
--                                 notify_message .= sprintf( __( 'Comment: %s' ), "\r\n" . comment_content ) . "\r\n\r\n";
--                                 notify_message .= __( 'You can see all pingbacks on this post here:' ) . "\r\n";
--                                 /* translators: Pingback notification email subject. 1: Site title, 2: Post title.--
--                                 subject = sprintf( __( '[%1s] Pingback: "%2s"' ), blogname, post->post_title );
--                                 break;

--                         default: -- Comments.
--                                 /* translators: %s: Post title.--
--                                 notify_message = sprintf( __( 'New comment on your post "%s"' ), post->post_title ) . "\r\n";
--                                 /* translators: 1: Comment author's name, 2: Comment author's IP address, 3: Comment author's hostname.--
--                                 notify_message .= sprintf( __( 'Author: %1s (IP address: %2s, %3s)' ), comment->comment_author, comment->comment_author_IP, comment_author_domain ) . "\r\n";
--                                 /* translators: %s: Comment author email.--
--                                 notify_message .= sprintf( __( 'Email: %s' ), comment->comment_author_email ) . "\r\n";
--                                 /* translators: %s: Trackback/pingback/comment author URL.--
--                                 notify_message .= sprintf( __( 'URL: %s' ), comment->comment_author_url ) . "\r\n";

--                                 if ( comment->comment_parent && user_can( post->post_author, 'edit_comment', comment->comment_parent ) ) then
--                                         /* translators: Comment moderation. %s: Parent comment edit URL.--
--                                         notify_message .= sprintf( __( 'In reply to: %s' ), admin_url( "comment.php?action=editcomment&c=thencomment->comment_parentend;#wpbody-content" ) ) . "\r\n";
--                                 end;

--                                 /* translators: %s: Comment text.--
--                                 notify_message .= sprintf( __( 'Comment: %s' ), "\r\n" . comment_content ) . "\r\n\r\n";
--                                 notify_message .= __( 'You can see all comments on this post here:' ) . "\r\n";
--                                 /* translators: Comment notification email subject. 1: Site title, 2: Post title.--
--                                 subject = sprintf( __( '[%1s] Comment: "%2s"' ), blogname, post->post_title );
--                                 break;
--                 end;

--                 notify_message .= get_permalink( comment->comment_post_ID ) . "#comments\r\n\r\n";
--                 /* translators: %s: Comment URL.--
--                 notify_message .= sprintf( __( 'Permalink: %s' ), get_comment_link( comment ) ) . "\r\n";

--                 if ( user_can( post->post_author, 'edit_comment', comment->comment_ID ) ) then
--                         if ( EMPTY_TRASH_DAYS ) then
--                                 /* translators: Comment moderation. %s: Comment action URL.--
--                                 notify_message .= sprintf( __( 'Trash it: %s' ), admin_url( "comment.php?action=trash&c=thencomment->comment_IDend;#wpbody-content" ) ) . "\r\n";
--                         end; else then
--                                 /* translators: Comment moderation. %s: Comment action URL.--
--                                 notify_message .= sprintf( __( 'Delete it: %s' ), admin_url( "comment.php?action=delete&c=thencomment->comment_IDend;#wpbody-content" ) ) . "\r\n";
--                         end;
--                         /* translators: Comment moderation. %s: Comment action URL.--
--                         notify_message .= sprintf( __( 'Spam it: %s' ), admin_url( "comment.php?action=spam&c=thencomment->comment_IDend;#wpbody-content" ) ) . "\r\n";
--                 end;

--                 wp_email = 'wordpress@' . preg_replace( '#^www\.#', '', wp_parse_url( network_home_url(), PHP_URL_HOST ) );

--                 if ( '' === comment->comment_author ) then
--                         from = "From: \"blogname\" <wp_email>";
--                         if ( '' !== comment->comment_author_email ) then
--                                 reply_to = "Reply-To: comment->comment_author_email";
--                         end;
--                 end; else then
--                         from = "From: \"comment->comment_author\" <wp_email>";
--                         if ( '' !== comment->comment_author_email ) then
--                                 reply_to = "Reply-To: \"comment->comment_author_email\" <comment->comment_author_email>";
--                         end;
--                 end;

--                 message_headers = "from\n"
--                 . 'Content-Type: text/plain; charset="' . get_option( 'blog_charset' ) . "\"\n";

--                 if ( isset( reply_to ) ) then
--                         message_headers .= reply_to . "\n";
--                 end;

--                 --
--                 -- Filters the comment notification email text.
--                 --
--                 -- @since 1.5.2
--                 --
--                 -- @param string notify_message The comment notification email text.
--                 -- @param string comment_id     Comment ID as a numeric string.
--                 --
--                 notify_message = apply_filters( 'comment_notification_text', notify_message, comment->comment_ID );

--                 --
--                 -- Filters the comment notification email subject.
--                 --
--                 -- @since 1.5.2
--                 --
--                 -- @param string subject    The comment notification email subject.
--                 -- @param string comment_id Comment ID as a numeric string.
--                 --
--                 subject = apply_filters( 'comment_notification_subject', subject, comment->comment_ID );

--                 --
--                 -- Filters the comment notification email headers.
--                 --
--                 -- @since 1.5.2
--                 --
--                 -- @param string message_headers Headers for the comment notification email.
--                 -- @param string comment_id      Comment ID as a numeric string.
--                 --
--                 message_headers = apply_filters( 'comment_notification_headers', message_headers, comment->comment_ID );

--                 foreach ( emails as email ) then
--                         wp_mail( email, wp_specialchars_decode( subject ), notify_message, message_headers );
--                 end;

--                 if ( switched_locale ) then
--                         restore_previous_locale();
--                 end;

--                 return true;
--         end;
-- endif;

-- if ( ! function_exists( 'wp_notify_moderator' ) ) :
--         --
--         -- Notifies the moderator of the site about a new comment that is awaiting approval.
--         --
--         -- @since 1.0.0
--         --
--         -- @global wpdb wpdb WordPress database abstraction object.
--         --
--         -- Uses the {@see 'notify_moderator'} filter to determine whether the site moderator
--         -- should be notified, overriding the site setting.
--         --
--         -- @param int comment_id Comment ID.
--         -- @return true Always returns true.
--         --
--         function wp_notify_moderator( comment_id ) then
--                 global wpdb;

--                 maybe_notify = get_option( 'moderation_notify' );

--                 --
--                 -- Filters whether to send the site moderator email notifications, overriding the site setting.
--                 --
--                 -- @since 4.4.0
--                 --
--                 -- @param bool maybe_notify Whether to notify blog moderator.
--                 -- @param int  comment_ID   The id of the comment for the notification.
--                 --
--                 maybe_notify = apply_filters( 'notify_moderator', maybe_notify, comment_id );

--                 if ( ! maybe_notify ) then
--                         return true;
--                 end;

--                 comment = get_comment( comment_id );
--                 post    = get_post( comment->comment_post_ID );
--                 user    = get_userdata( post->post_author );
--                 -- Send to the administration and to the post author if the author can modify the comment.
--                 emails = array( get_option( 'admin_email' ) );
--                 if ( user && user_can( user->ID, 'edit_comment', comment_id ) && ! empty( user->user_email ) ) then
--                         if ( 0 !== strcasecmp( user->user_email, get_option( 'admin_email' ) ) ) then
--                                 emails[] = user->user_email;
--                         end;
--                 end;

--                 switched_locale = switch_to_locale( get_locale() );

--                 comment_author_domain = '';
--                 if ( WP_Http::is_ip_address( comment->comment_author_IP ) ) then
--                         comment_author_domain = gethostbyaddr( comment->comment_author_IP );
--                 end;

--                 comments_waiting = wpdb->get_var( "SELECT COUNT(*) FROM wpdb->comments WHERE comment_approved = '0'" );

--                 -- The blogname option is escaped with esc_html() on the way into the database in sanitize_option().
--                 -- We want to reverse this for the plain text arena of emails.
--                 blogname        = wp_specialchars_decode( get_option( 'blogname' ), ENT_QUOTES );
--                 comment_content = wp_specialchars_decode( comment->comment_content );

--                 switch ( comment->comment_type ) then
--                         case 'trackback':
--                                 /* translators: %s: Post title.--
--                                 notify_message  = sprintf( __( 'A new trackback on the post "%s" is waiting for your approval' ), post->post_title ) . "\r\n";
--                                 notify_message .= get_permalink( comment->comment_post_ID ) . "\r\n\r\n";
--                                 /* translators: 1: Trackback/pingback website name, 2: Website IP address, 3: Website hostname.--
--                                 notify_message .= sprintf( __( 'Website: %1s (IP address: %2s, %3s)' ), comment->comment_author, comment->comment_author_IP, comment_author_domain ) . "\r\n";
--                                 /* translators: %s: Trackback/pingback/comment author URL.--
--                                 notify_message .= sprintf( __( 'URL: %s' ), comment->comment_author_url ) . "\r\n";
--                                 notify_message .= __( 'Trackback excerpt: ' ) . "\r\n" . comment_content . "\r\n\r\n";
--                                 break;

--                         case 'pingback':
--                                 /* translators: %s: Post title.--
--                                 notify_message  = sprintf( __( 'A new pingback on the post "%s" is waiting for your approval' ), post->post_title ) . "\r\n";
--                                 notify_message .= get_permalink( comment->comment_post_ID ) . "\r\n\r\n";
--                                 /* translators: 1: Trackback/pingback website name, 2: Website IP address, 3: Website hostname.--
--                                 notify_message .= sprintf( __( 'Website: %1s (IP address: %2s, %3s)' ), comment->comment_author, comment->comment_author_IP, comment_author_domain ) . "\r\n";
--                                 /* translators: %s: Trackback/pingback/comment author URL.--
--                                 notify_message .= sprintf( __( 'URL: %s' ), comment->comment_author_url ) . "\r\n";
--                                 notify_message .= __( 'Pingback excerpt: ' ) . "\r\n" . comment_content . "\r\n\r\n";
--                                 break;

--                         default: -- Comments.
--                                 /* translators: %s: Post title.--
--                                 notify_message  = sprintf( __( 'A new comment on the post "%s" is waiting for your approval' ), post->post_title ) . "\r\n";
--                                 notify_message .= get_permalink( comment->comment_post_ID ) . "\r\n\r\n";
--                                 /* translators: 1: Comment author's name, 2: Comment author's IP address, 3: Comment author's hostname.--
--                                 notify_message .= sprintf( __( 'Author: %1s (IP address: %2s, %3s)' ), comment->comment_author, comment->comment_author_IP, comment_author_domain ) . "\r\n";
--                                 /* translators: %s: Comment author email.--
--                                 notify_message .= sprintf( __( 'Email: %s' ), comment->comment_author_email ) . "\r\n";
--                                 /* translators: %s: Trackback/pingback/comment author URL.--
--                                 notify_message .= sprintf( __( 'URL: %s' ), comment->comment_author_url ) . "\r\n";

--                                 if ( comment->comment_parent ) then
--                                         /* translators: Comment moderation. %s: Parent comment edit URL.--
--                                         notify_message .= sprintf( __( 'In reply to: %s' ), admin_url( "comment.php?action=editcomment&c=thencomment->comment_parentend;#wpbody-content" ) ) . "\r\n";
--                                 end;

--                                 /* translators: %s: Comment text.--
--                                 notify_message .= sprintf( __( 'Comment: %s' ), "\r\n" . comment_content ) . "\r\n\r\n";
--                                 break;
--                 end;

--                 /* translators: Comment moderation. %s: Comment action URL.--
--                 notify_message .= sprintf( __( 'Approve it: %s' ), admin_url( "comment.php?action=approve&c=thencomment_idend;#wpbody-content" ) ) . "\r\n";

--                 if ( EMPTY_TRASH_DAYS ) then
--                         /* translators: Comment moderation. %s: Comment action URL.--
--                         notify_message .= sprintf( __( 'Trash it: %s' ), admin_url( "comment.php?action=trash&c=thencomment_idend;#wpbody-content" ) ) . "\r\n";
--                 end; else then
--                         /* translators: Comment moderation. %s: Comment action URL.--
--                         notify_message .= sprintf( __( 'Delete it: %s' ), admin_url( "comment.php?action=delete&c=thencomment_idend;#wpbody-content" ) ) . "\r\n";
--                 end;

--                 /* translators: Comment moderation. %s: Comment action URL.--
--                 notify_message .= sprintf( __( 'Spam it: %s' ), admin_url( "comment.php?action=spam&c=thencomment_idend;#wpbody-content" ) ) . "\r\n";

--                 notify_message .= sprintf(
--                         /* translators: Comment moderation. %s: Number of comments awaiting approval.--
--                         _n(
--                                 'Currently %s comment is waiting for approval. Please visit the moderation panel:',
--                                 'Currently %s comments are waiting for approval. Please visit the moderation panel:',
--                                 comments_waiting
--                         ),
--                         number_format_i18n( comments_waiting )
--                 ) . "\r\n";
--                 notify_message .= admin_url( 'edit-comments.php?comment_status=moderated#wpbody-content' ) . "\r\n";

--                 /* translators: Comment moderation notification email subject. 1: Site title, 2: Post title.--
--                 subject         = sprintf( __( '[%1s] Please moderate: "%2s"' ), blogname, post->post_title );
--                 message_headers = '';

--                 --
--                 -- Filters the list of recipients for comment moderation emails.
--                 --
--                 -- @since 3.7.0
--                 --
--                 -- @param string[] emails     List of email addresses to notify for comment moderation.
--                 -- @param int      comment_id Comment ID.
--                 --
--                 emails = apply_filters( 'comment_moderation_recipients', emails, comment_id );

--                 --
--                 -- Filters the comment moderation email text.
--                 --
--                 -- @since 1.5.2
--                 --
--                 -- @param string notify_message Text of the comment moderation email.
--                 -- @param int    comment_id     Comment ID.
--                 --
--                 notify_message = apply_filters( 'comment_moderation_text', notify_message, comment_id );

--                 --
--                 -- Filters the comment moderation email subject.
--                 --
--                 -- @since 1.5.2
--                 --
--                 -- @param string subject    Subject of the comment moderation email.
--                 -- @param int    comment_id Comment ID.
--                 --
--                 subject = apply_filters( 'comment_moderation_subject', subject, comment_id );

--                 --
--                 -- Filters the comment moderation email headers.
--                 --
--                 -- @since 2.8.0
--                 --
--                 -- @param string message_headers Headers for the comment moderation email.
--                 -- @param int    comment_id      Comment ID.
--                 --
--                 message_headers = apply_filters( 'comment_moderation_headers', message_headers, comment_id );

--                 foreach ( emails as email ) then
--                         wp_mail( email, wp_specialchars_decode( subject ), notify_message, message_headers );
--                 end;

--                 if ( switched_locale ) then
--                         restore_previous_locale();
--                 end;

--                 return true;
--         end;
-- endif;

-- if ( ! function_exists( 'wp_password_change_notification' ) ) :
--         --
--         -- Notifies the blog admin of a user changing password, normally via email.
--         --
--         -- @since 2.7.0
--         --
--         -- @param WP_User user User object.
--         --
--         function wp_password_change_notification( user ) then
--                 -- Send a copy of password change notification to the admin,
--                 -- but check to see if it's the admin whose password we're changing, and skip this.
--                 if ( 0 !== strcasecmp( user->user_email, get_option( 'admin_email' ) ) ) then
--                         /* translators: %s: User name.--
--                         message = sprintf( __( 'Password changed for user: %s' ), user->user_login ) . "\r\n";
--                         -- The blogname option is escaped with esc_html() on the way into the database in sanitize_option().
--                         -- We want to reverse this for the plain text arena of emails.
--                         blogname = wp_specialchars_decode( get_option( 'blogname' ), ENT_QUOTES );

--                         wp_password_change_notification_email = array(
--                                 'to'      => get_option( 'admin_email' ),
--                                 /* translators: Password change notification email subject. %s: Site title.--
--                                 'subject' => __( '[%s] Password Changed' ),
--                                 'message' => message,
--                                 'headers' => '',
--                         );

--                         --
--                         -- Filters the contents of the password change notification email sent to the site admin.
--                         --
--                         -- @since 4.9.0
--                         --
--                         -- @param array   wp_password_change_notification_email then
--                         --     Used to build wp_mail().
--                         --
--                         --     @type string to      The intended recipient - site admin email address.
--                         --     @type string subject The subject of the email.
--                         --     @type string message The body of the email.
--                         --     @type string headers The headers of the email.
--                         -- end;
--                         -- @param WP_User user     User object for user whose password was changed.
--                         -- @param string  blogname The site title.
--                         --
--                         wp_password_change_notification_email = apply_filters( 'wp_password_change_notification_email', wp_password_change_notification_email, user, blogname );

--                         wp_mail(
--                                 wp_password_change_notification_email['to'],
--                                 wp_specialchars_decode( sprintf( wp_password_change_notification_email['subject'], blogname ) ),
--                                 wp_password_change_notification_email['message'],
--                                 wp_password_change_notification_email['headers']
--                         );
--                 end;
--         end;
-- endif;

-- if ( ! function_exists( 'wp_new_user_notification' ) ) :
--         --
--         -- Emails login credentials to a newly-registered user.
--         --
--         -- A new user registration notification is also sent to admin email.
--         --
--         -- @since 2.0.0
--         -- @since 4.3.0 The `plaintext_pass` parameter was changed to `notify`.
--         -- @since 4.3.1 The `plaintext_pass` parameter was deprecated. `notify` added as a third parameter.
--         -- @since 4.6.0 The `notify` parameter accepts 'user' for sending notification only to the user created.
--         --
--         -- @param int    user_id    User ID.
--         -- @param null   deprecated Not used (argument deprecated).
--         -- @param string notify     Optional. Type of notification that should happen. Accepts 'admin' or an empty
--         --                           string (admin only), 'user', or 'both' (admin and user). Default empty.
--         --
--         function wp_new_user_notification( user_id, deprecated = null, notify = '' ) then
--                 if ( null !== deprecated ) then
--                         _deprecated_argument( __FUNCTION__, '4.3.1' );
--                 end;

--                 -- Accepts only 'user', 'admin' , 'both' or default '' as notify.
--                 if ( ! in_array( notify, array( 'user', 'admin', 'both', '' ), true ) ) then
--                         return;
--                 end;

--                 user = get_userdata( user_id );

--                 -- The blogname option is escaped with esc_html() on the way into the database in sanitize_option().
--                 -- We want to reverse this for the plain text arena of emails.
--                 blogname = wp_specialchars_decode( get_option( 'blogname' ), ENT_QUOTES );

--                 --
--                 -- Filters whether the admin is notified of a new user registration.
--                 --
--                 -- @since 6.1.0
--                 --
--                 -- @param bool    send Whether to send the email. Default true.
--                 -- @param WP_User user User object for new user.
--                 --
--                 send_notification_to_admin = apply_filters( 'wp_send_new_user_notification_to_admin', true, user );

--                 if ( 'user' !== notify && true === send_notification_to_admin ) then
--                         switched_locale = switch_to_locale( get_locale() );

--                         /* translators: %s: Site title.--
--                         message = sprintf( __( 'New user registration on your site %s:' ), blogname ) . "\r\n\r\n";
--                         /* translators: %s: User login.--
--                         message .= sprintf( __( 'Username: %s' ), user->user_login ) . "\r\n\r\n";
--                         /* translators: %s: User email address.--
--                         message .= sprintf( __( 'Email: %s' ), user->user_email ) . "\r\n";

--                         wp_new_user_notification_email_admin = array(
--                                 'to'      => get_option( 'admin_email' ),
--                                 /* translators: New user registration notification email subject. %s: Site title.--
--                                 'subject' => __( '[%s] New User Registration' ),
--                                 'message' => message,
--                                 'headers' => '',
--                         );

--                         --
--                         -- Filters the contents of the new user notification email sent to the site admin.
--                         --
--                         -- @since 4.9.0
--                         --
--                         -- @param array   wp_new_user_notification_email_admin then
--                         --     Used to build wp_mail().
--                         --
--                         --     @type string to      The intended recipient - site admin email address.
--                         --     @type string subject The subject of the email.
--                         --     @type string message The body of the email.
--                         --     @type string headers The headers of the email.
--                         -- end;
--                         -- @param WP_User user     User object for new user.
--                         -- @param string  blogname The site title.
--                         --
--                         wp_new_user_notification_email_admin = apply_filters( 'wp_new_user_notification_email_admin', wp_new_user_notification_email_admin, user, blogname );

--                         wp_mail(
--                                 wp_new_user_notification_email_admin['to'],
--                                 wp_specialchars_decode( sprintf( wp_new_user_notification_email_admin['subject'], blogname ) ),
--                                 wp_new_user_notification_email_admin['message'],
--                                 wp_new_user_notification_email_admin['headers']
--                         );

--                         if ( switched_locale ) then
--                                 restore_previous_locale();
--                         end;
--                 end;

--                 --
--                 -- Filters whether the user is notified of their new user registration.
--                 --
--                 -- @since 6.1.0
--                 --
--                 -- @param bool    send Whether to send the email. Default true.
--                 -- @param WP_User user User object for new user.
--                 --
--                 send_notification_to_user = apply_filters( 'wp_send_new_user_notification_to_user', true, user );

--                 -- `deprecated` was pre-4.3 `plaintext_pass`. An empty `plaintext_pass` didn't sent a user notification.
--                 if ( 'admin' === notify || true !== send_notification_to_user || ( empty( deprecated ) && empty( notify ) ) ) then
--                         return;
--                 end;

--                 key = get_password_reset_key( user );
--                 if ( is_wp_error( key ) ) then
--                         return;
--                 end;

--                 switched_locale = switch_to_locale( get_user_locale( user ) );

--                 /* translators: %s: User login.--
--                 message  = sprintf( __( 'Username: %s' ), user->user_login ) . "\r\n\r\n";
--                 message .= __( 'To set your password, visit the following address:' ) . "\r\n\r\n";
--                 message .= network_site_url( "wp-login.php?action=rp&key=key&login=" . rawurlencode( user->user_login ), 'login' ) . "\r\n\r\n";

--                 message .= wp_login_url() . "\r\n";

--                 wp_new_user_notification_email = array(
--                         'to'      => user->user_email,
--                         /* translators: Login details notification email subject. %s: Site title.--
--                         'subject' => __( '[%s] Login Details' ),
--                         'message' => message,
--                         'headers' => '',
--                 );

--                 --
--                 -- Filters the contents of the new user notification email sent to the new user.
--                 --
--                 -- @since 4.9.0
--                 --
--                 -- @param array   wp_new_user_notification_email then
--                 --     Used to build wp_mail().
--                 --
--                 --     @type string to      The intended recipient - New user email address.
--                 --     @type string subject The subject of the email.
--                 --     @type string message The body of the email.
--                 --     @type string headers The headers of the email.
--                 -- end;
--                 -- @param WP_User user     User object for new user.
--                 -- @param string  blogname The site title.
--                 --
--                 wp_new_user_notification_email = apply_filters( 'wp_new_user_notification_email', wp_new_user_notification_email, user, blogname );

--                 wp_mail(
--                         wp_new_user_notification_email['to'],
--                         wp_specialchars_decode( sprintf( wp_new_user_notification_email['subject'], blogname ) ),
--                         wp_new_user_notification_email['message'],
--                         wp_new_user_notification_email['headers']
--                 );

--                 if ( switched_locale ) then
--                         restore_previous_locale();
--                 end;
--         end;
-- endif;

-- if ( ! function_exists( 'wp_nonce_tick' ) ) :

   -------------------
   -- Wp_Nonce_Tick --
   -------------------

   function Wp_Nonce_Tick (Action : String)
                           return Float
   is
      use Constants;
      use Wp_Common;

      Nonce_Life : Integer;
   begin
      --
      -- Filters the lifespan of nonces in seconds.
      --
      -- @since 2.5.0
      -- @since 6.1.0 Added `action` argument to allow for more targeted filters.
      --
      -- @param int        lifespan Lifespan of nonces in seconds. Default 86,400
      --                            seconds, or one day.
      -- @param string|int action   The nonce action, or -1 if none was provided.
      --
      Nonce_Life := Apply_Filters ("nonce_life", DAY_IN_SECONDS, Action);

      return Float'Ceiling (0.0 / Float (Nonce_Life / 2));
--    return Float'Ceil (time() / ( nonce_life / 2));
   end Wp_Nonce_Tick;

-- endif;

-- if ( ! function_exists( 'wp_verify_nonce' ) ) :

   ---------------------
   -- Wp_Verify_Nonce --
   ---------------------

   function Wp_Verify_Nonce (Nonce  : String;
                             Action : String := "-1") -- Integer := -1)
                             return Integer
   is
      use Php.Misc;
      use Php.Strings;
      use Helpers;
      use Wp_Common;
      use Class_Users;
      use Inc_Users;

--    Nonce := (string) nonce;
      User : constant Wp_User := Wp_Get_Current_User;
      Uid  : Integer := Integer (User.Id); -- (int)
   begin
      if Uid = 0 then
         --
         -- Filters whether the user who generated the nonce is logged out.
         --
         -- @since 3.5.0
         --
         -- @param int        uid    ID of the nonce-owning user.
         -- @param string|int action The nonce action, or -1 if none was provided.
         --
         Uid := Apply_Filters ("nonce_user_logged_out", Uid, Action);
      end if;

      if Empty (Nonce) then
         return 0; -- False;
      end if;

      declare
         Token : constant String := Wp_Get_Session_Token;
         I     : constant Float  := Wp_Nonce_Tick (Action);
         II    : constant Integer := Integer (I); -- added

         -- Nonce generated 0-12 hours ago.
         Expected_1 : constant String :=
           Substr (Wp_Hash (Image (II) & '|' & Action & '|' &
                            Image (Uid) & '|' & Token,
                            "nonce"),
                   -12, 10);
      begin
         if Hash_Equals (Expected_1, Nonce) then
            return 1;
         end if;

         declare
            -- Nonce generated 12-24 hours ago.
            Expected_2 : constant String :=
              Substr (Wp_Hash (Image (II - 1) & '|' & Action & '|' &
                               Image (Uid) & '|' & Token,
                               "nonce"),
                      -12, 10);
         begin
            if Hash_Equals (Expected_2, Nonce) then
               return 2;
            end if;
         end;

         --
         -- Fires when nonce verification fails.
         --
         -- @since 4.4.0
         --
         -- @param string     nonce  The invalid nonce.
         -- @param string|int action The nonce action.
         -- @param WP_User    user   The current user object.
         -- @param string     token  The user's session token.
         --
         Do_Action ("wp_verify_nonce_failed", Nonce, Action, User, Token);
      end;

      -- Invalid nonce.
      return 0; -- false;
   end Wp_Verify_Nonce;

-- endif;

-- if ( ! function_exists( 'wp_create_nonce' ) ) :

   ---------------------
   -- Wp_Create_Nonce --
   ---------------------

   function Wp_Create_Nonce (Action : String)
            return String
   is
      use Php.Strings;
      use Wp_Common;
      use Class_Users;
      use Inc_Users;

      User : constant Wp_User := Wp_Get_Current_User;
      Uid  : Integer := Integer (User.Id); -- (int)
   begin
      if Uid = 0 then
         -- This filter is documented in wp-includes/pluggable.php
         Uid := Apply_Filters ("nonce_user_logged_out", Uid, Action);
      end if;

      declare
         Token : constant String := Wp_Get_Session_Token;
         I     : constant Float  := Wp_Nonce_Tick (Action);
      begin
         return Substr
           (Wp_Hash (Float'Image (I) & '|' & Action & '|' &
                     Helpers.Image (Uid) & '|' & Token, "nonce"),
            Offset => -12, Length => 10);
      end;
   end Wp_Create_Nonce;

   ---------------------
   -- Wp_Create_Nonce --
   ---------------------

   function Wp_Create_Nonce (Action : Integer := -1)
            return String
   is
   begin
      return Wp_Create_Nonce (Integer'Image (Action));
   end Wp_Create_Nonce;

-- endif;

-- if ( ! function_exists( 'wp_salt' ) ) :

   Static_Cached_Salts    : Array_Type;
   Static_Duplicated_Keys : Array_Type;

   SECRET_KEY  : constant String := "";
   SECRET_SALT : constant String := "";

   -------------
   -- Wp_Salt --
   -------------

   function Wp_Salt (Scheme : String := "auth")
                     return String
   is
      use Php.Lists;
      use Wp_Common;
      use Inc_L10n;
      use Inc_Options;
   begin
      if Isset (Static_Cached_Salts, Scheme) then
         --
         -- Filters the WordPress salt.
         --
         -- @since 2.5.0
         --
         -- @param string cached_salt Cached salt for the given scheme.
         -- @param string scheme      Authentication scheme. Values include 'auth',
         --                            'secure_auth', 'logged_in', and 'nonce'.
         --
         return Apply_Filters ("salt", Get_As_String (Static_Cached_Salts, Scheme), Scheme);
      end if;

      if Static_Duplicated_Keys = Empty_Array then
         Static_Duplicated_Keys := To_Array (List => (
           Build ("put your unique phrase here", True),
           --
           -- translators: This string should only be translated if
           -- wp-config-sample.php is localized.
           -- You can check the localized release package or
           -- https://i18n.svn.wordpress.org/<locale code>/branches/<wp version>
           -- /dist/wp-config-sample.php
           --
           Build (abs "put your unique phrase here", True)
         ));
         for
           First of List_Type'["AUTH", "SECURE_AUTH", "LOGGED_IN",
                               "NONCE", "SECRET"]
         loop
            for Second of List_Type'["KEY", "SALT"] loop
--             if not Defined ("{first}_{second}") then
--                goto Continue;
--             end if;

               declare
                  Value : constant String := First & "_" & Second;
               begin
                  Set (Static_Duplicated_Keys, Key => Value,
                       Value => From_Boolean (Isset (Static_Duplicated_Keys, Value)));
               end;
--             << Continue >>
            end loop;
         end loop;
      end if;

      declare
         Values : Array_Type := To_Array (List => (
           Build ("key",  ""),
           Build ("salt", "")
         ));
      begin
         if
--         Defined ('SECRET_KEY') and then
           SECRET_KEY /= "" and then
           Empty (Static_Duplicated_Keys, SECRET_KEY)
         then
            Set (Values, "key", From_String (SECRET_KEY));
         end if;

         if
           "auth" = Scheme and then
--         Defined ("SECRET_SALT") and then
           SECRET_SALT /= "" and then
           Empty (Static_Duplicated_Keys, SECRET_SALT)
         then
            Set (Values, "salt", From_String (SECRET_SALT));
         end if;

         if
           In_List (Scheme, List_Type'["auth", "secure_auth",
                                       "logged_in", "nonce"], True)
         then
            for Typ of List_Type'["key", "salt"] loop
               declare
                  Const : constant String :=
                    Php.Strings.Strtoupper (Scheme & "_" & Typ);
               begin
                  if
--                  Defined (const) and then
--                  constant( const ) and then
                    Empty (Static_Duplicated_Keys, Const) -- [ constant( const ) ])
                  then
                     Set (Values, Typ, From_String (Const)); -- constant( const ));
                  elsif not Isset (Values, Typ) then
--                elsif not Values (Typ) then
                     Set (Values, Typ, Get_Site_Option (Scheme & "_" & Typ));
                     if not Isset (Values, Typ) then
--                   if not Values (Typ) then
                        Set (Values, Typ,
                             From_String (Wp_Generate_Password (64, True, True)));
                        Update_Site_Option (Scheme & "_" & Typ, Get (Values, Typ));
                     end if;
                  end if;
               end;
            end loop;
         else
            if not Isset (Values, "key") then
--          if not Values ("key") then

               Set (Values, "key",
                    Get_Site_Option ("secret_key"));

               if not Isset (Values, "key") then
--             if not Values ("key") then

                  Set (Values, "key",
                       From_String (Wp_Generate_Password (64, True, True)));

                  Update_Site_Option ("secret_key", Get (Values, "key"));
               end if;
            end if;
            Set (Values, "salt",
                 From_String (Inc_Compat.Hash_Hmac ("md5", Scheme,
                                                    Get_As_String (Values, "key"))));
         end if;

         Set (Static_Cached_Salts, Scheme,
              From_String (Get_As_String (Values, "key") &
                           Get_As_String (Values, "salt")));
--       Set (Static_Cached_Salts, Scheme, Values ("key") & Values ("salt"));

         -- This filter is documented in wp-includes/pluggable.php--
         return Apply_Filters ("salt", Get_As_String (Static_Cached_Salts, Scheme), Scheme);
      end;
   end Wp_Salt;

-- endif;

-- if ( ! function_exists( 'wp_hash' ) ) :

   -------------
   -- Wp_Hash --
   -------------

   function Wp_Hash (Data   : String;
                     Scheme : String := "auth")
                     return String
   is
      Salt : constant String := Wp_Salt (Scheme);
   begin
      return Inc_Compat.Hash_Hmac ("md5", Data, Salt);
   end Wp_Hash;
-- endif;

-- if ( ! function_exists( 'wp_hash_password' ) ) :
--         --
--         -- Creates a hash (encrypt) of a plain text password.
--         --
--         -- For integration with other applications, this function can be overwritten to
--         -- instead use the other package password checking algorithm.
--         --
--         -- @since 2.5.0
--         --
--         -- @global PasswordHash wp_hasher PHPass object
--         --
--         -- @param string password Plain text user password to hash.
--         -- @return string The hash string of the password.
--         --
--         function wp_hash_password( password ) then
--                 global wp_hasher;

--                 if ( empty( wp_hasher ) ) then
--                         require_once ABSPATH . WPINC . '/class-phpass.php';
--                         -- By default, use the portable hash from phpass.
--                         wp_hasher = new PasswordHash( 8, true );
--                 end;

--                 return wp_hasher->HashPassword( trim( password ) );
--         end;
-- endif;

-- if ( ! function_exists( 'wp_check_password' ) ) :
--         --
--         -- Checks the plaintext password against the encrypted Password.
--         --
--         -- Maintains compatibility between old version and the new cookie authentication
--         -- protocol using PHPass library. The hash parameter is the encrypted password
--         -- and the function compares the plain text password when encrypted similarly
--         -- against the already encrypted password to see if they match.
--         --
--         -- For integration with other applications, this function can be overwritten to
--         -- instead use the other package password checking algorithm.
--         --
--         -- @since 2.5.0
--         --
--         -- @global PasswordHash wp_hasher PHPass object used for checking the password
--         --                                 against the hash + password.
--         -- @uses PasswordHash::CheckPassword
--         --
--         -- @param string     password Plaintext user's password.
--         -- @param string     hash     Hash of the user's password to check against.
--         -- @param string|int user_id  Optional. User ID.
--         -- @return bool False, if the password does not match the hashed password.
--         --
--         function wp_check_password( password, hash, user_id = '' ) then
--                 global wp_hasher;

--                 -- If the hash is still md5...
--                 if ( strlen( hash ) <= 32 ) then
--                         check = hash_equals( hash, md5( password ) );
--                         if ( check && user_id ) then
--                                 -- Rehash using new hash.
--                                 wp_set_password( password, user_id );
--                                 hash = wp_hash_password( password );
--                         end;

--                         --
--                         -- Filters whether the plaintext password matches the encrypted password.
--                         --
--                         -- @since 2.5.0
--                         --
--                         -- @param bool       check    Whether the passwords match.
--                         -- @param string     password The plaintext password.
--                         -- @param string     hash     The hashed password.
--                         -- @param string|int user_id  User ID. Can be empty.
--                         --
--                         return apply_filters( 'check_password', check, password, hash, user_id );
--                 end;

--                 -- If the stored hash is longer than an MD5,
--                 -- presume the new style phpass portable hash.
--                 if ( empty( wp_hasher ) ) then
--                         require_once ABSPATH . WPINC . '/class-phpass.php';
--                         -- By default, use the portable hash from phpass.
--                         wp_hasher = new PasswordHash( 8, true );
--                 end;

--                 check = wp_hasher->CheckPassword( password, hash );

--                 -- This filter is documented in wp-includes/pluggable.php--
--                 return apply_filters( 'check_password', check, password, hash, user_id );
--         end;
-- endif;

-- if ( ! function_exists( 'wp_generate_password' ) ) :

   --------------------------
   -- Wp_Generate_Password --
   --------------------------

   function Wp_Generate_Password (Length              : Natural := 12;
                                  Special_Chars       : Boolean := True;
                                  Extra_Special_Chars : Boolean := False)
                                  return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;

      Chars : UString :=
        +"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
      Password : UString;
   begin
      if Special_Chars then
         Append (Chars, "!@#%^&*()");
      end if;

      if Extra_Special_Chars then
         Append (Chars, "-_ []{}<>~`+=,.;:/?|");
      end if;

      declare
         subtype Result_Type is Positive
           range 1 .. UStrings.Length (Chars);

         package Rand is new
           Ada.Numerics.Discrete_Random (Result_Subtype => Result_Type);

         Gen : Rand.Generator;
      begin
         Rand.Reset (Gen);

         for I in 1 .. Length loop
            Append (Password,
                    Substr (-Chars, Rand.Random (Gen), 1));
--                       Wp_Rand (0, Ada.Strings.Unbounded.Length (Chars) - 1), 1));
         end loop;
      end;

      --
      -- Filters the randomly-generated password.
      --
      -- @since 3.0.0
      -- @since 5.3.0 Added the `length`, `special_chars`, and `extra_special_chars`
      --              parameters.
      --
      -- @param string password            The generated password.
      -- @param int    length              The length of password to generate.
      -- @param bool   special_chars       Whether to include standard special
      --                                    characters.
      -- @param bool   extra_special_chars Whether to include other special characters.
      --
      return Apply_Filters ("random_password", -Password, Length,
                            Special_Chars, Extra_Special_Chars);
   end Wp_Generate_Password;

-- endif;

-- if ( ! function_exists( 'wp_rand' ) ) :
--         --
--         -- Generates a random non-negative number.
--         --
--         -- @since 2.6.2
--         -- @since 4.4.0 Uses PHP7 random_int() or the random_compat library if available.
--         -- @since 6.1.0 Returns zero instead of a random number if both `min` and `max` are zero.
--         --
--         -- @global string rnd_value
--         --
--         -- @param int min Optional. Lower limit for the generated number.
--         --                 Accepts positive integers or zero. Defaults to 0.
--         -- @param int max Optional. Upper limit for the generated number.
--         --                 Accepts positive integers. Defaults to 4294967295.
--         -- @return int A random non-negative number between min and max.
--         --
--         function wp_rand( min = null, max = null ) then
--                 global rnd_value;

--                 -- Some misconfigured 32-bit environments (Entropy PHP, for example)
--                 -- truncate integers larger than PHP_INT_MAX to PHP_INT_MAX rather than overflowing them to floats.
--                 max_random_number = 3000000000 === 2147483647 ? (float) '4294967295' : 4294967295; -- 4294967295 = 0xffffffff

--                 if ( null === min ) then
--                         min = 0;
--                 end;

--                 if ( null === max ) then
--                         max = max_random_number;
--                 end;

--                 -- We only handle ints, floats are truncated to their integer value.
--                 min = (int) min;
--                 max = (int) max;

--                 -- Use PHP's CSPRNG, or a compatible method.
--                 static use_random_int_functionality = true;
--                 if ( use_random_int_functionality ) then
--                         try then
--                                 -- wp_rand() can accept arguments in either order, PHP cannot.
--                                 _max = max( min, max );
--                                 _min = min( min, max );
--                                 val  = random_int( _min, _max );
--                                 if ( false !== val ) then
--                                         return absint( val );
--                                 end; else then
--                                         use_random_int_functionality = false;
--                                 end;
--                         end; catch ( Error e ) then
--                                 use_random_int_functionality = false;
--                         end; catch ( Exception e ) then
--                                 use_random_int_functionality = false;
--                         end;
--                 end;

--                 -- Reset rnd_value after 14 uses.
--                 -- 32 (md5) + 40 (sha1) + 40 (sha1) / 8 = 14 random numbers from rnd_value.
--                 if ( strlen( rnd_value ) < 8 ) then
--                         if ( defined( 'WP_SETUP_CONFIG' ) ) then
--                                 static seed = '';
--                         end; else then
--                                 seed = get_transient( 'random_seed' );
--                         end;
--                         rnd_value  = md5( uniqid( microtime() . mt_rand(), true ) . seed );
--                         rnd_value .= sha1( rnd_value );
--                         rnd_value .= sha1( rnd_value . seed );
--                         seed       = md5( seed . rnd_value );
--                         if ( ! defined( 'WP_SETUP_CONFIG' ) && ! defined( 'WP_INSTALLING' ) ) then
--                                 set_transient( 'random_seed', seed );
--                         end;
--                 end;

--                 -- Take the first 8 digits for our value.
--                 value = substr( rnd_value, 0, 8 );

--                 -- Strip the first eight, leaving the remainder for the next call to wp_rand().
--                 rnd_value = substr( rnd_value, 8 );

--                 value = abs( hexdec( value ) );

--                 -- Reduce the value to be within the min - max range.
--                 value = min + ( max - min + 1 )-- value / ( max_random_number + 1 );

--                 return abs( (int) value );
--         end;
-- endif;

-- if ( ! function_exists( 'wp_set_password' ) ) :
--         --
--         -- Updates the user's password with a new encrypted one.
--         --
--         -- For integration with other applications, this function can be overwritten to
--         -- instead use the other package password checking algorithm.
--         --
--         -- Please note: This function should be used sparingly and is really only meant for single-time
--         -- application. Leveraging this improperly in a plugin or theme could result in an endless loop
--         -- of password resets if precautions are not taken to ensure it does not execute on every page load.
--         --
--         -- @since 2.5.0
--         --
--         -- @global wpdb wpdb WordPress database abstraction object.
--         --
--         -- @param string password The plaintext new user password.
--         -- @param int    user_id  User ID.
--         --
--         function wp_set_password( password, user_id ) then
--                 global wpdb;

--                 hash = wp_hash_password( password );
--                 wpdb->update(
--                         wpdb->users,
--                         array(
--                                 'user_pass'           => hash,
--                                 'user_activation_key' => '',
--                         ),
--                         array( 'ID' => user_id )
--                 );

--                 clean_user_cache( user_id );
--         end;
-- endif;

-- if ( ! function_exists( 'get_avatar' ) ) :

   ----------------
   -- Get_Avatar --
   ----------------

   function Get_Avatar (Id_Or_Email : String;
                        Size        : Integer    := 96;
                        Default     : String     := "";
                        Alt         : String     := "";
                        Args        : Array_Type := Empty_Array)
                        return String
   is
      use Php.Arrays;
      use Php.Lists;
      use Php.Preg;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_Media;
      use Inc_Options;

      Defaults : Array_Type := To_Array (List => (
        -- get_avatar_data() args.
        Build ("size",          96),
        Build ("height",        Null_Value),
        Build ("width",         Null_Value),
        Build ("default",       String'(Get_Option ("avatar_default", "mystery"))),
        Build ("force_default", False),
        Build ("rating",        String'(Get_Option ("avatar_rating"))),
        Build ("scheme",        Null_Value),
        Build ("alt",           ""),
        Build ("class",         Null_Value),
        Build ("force_display", False),
        Build ("loading",       Null_Value),
        Build ("extra_attr",    ""),
        Build ("decoding",      "async")
      ));

      Args_2 : Array_Type := Args;
   begin
      if Wp_Lazy_Loading_Enabled ("img", "get_avatar") then
         Set (Defaults, "loading", From_String (
              Wp_Get_Loading_Attr_Default ("get_avatar")));
      end if;

      if Args = Empty_Array then
         Args_2 := Empty_Array;
      end if;

      Set (Args_2, "size",    From_Integer (Size));
      Set (Args_2, "default", From_String (Default));
      Set (Args_2, "alt",     From_String (Alt));

      Args_2 := Wp_Parse_Args (Args_2, Defaults);

      if Empty (Args_2, "height") then
         Set (Args_2, "height",
              From_Integer (As_Integer (Get (Args_2, "size"))));
      end if;

      if Empty (Args_2, "width") then
         Set (Args_2, "width",
              From_Integer (As_Integer (Get (Args_2, "size"))));
      end if;

      -- if
      --   Is_Object (Id_Or_Email) and then
      --   Isset (Id_Or_Email.Comment_Id)
      -- then
      --    Id_Or_Email := Get_Comment (Id_Or_Email);
      -- end if;

      --
      -- Allows the HTML for a user"s avatar to be returned early.
      --
      -- Returning a non-null value will effectively short-circuit get_avatar(),
      -- passing the value through the {@see "get_avatar"} filter and returning early.
      --
      -- @since 4.2.0
      --
      -- @param string|null avatar      HTML for the user's avatar. Default null.
      -- @param mixed       id_or_email The avatar to retrieve. Accepts a user_id,
      --                                Gravatar MD5 hash,  user email, WP_User
      --                                object, WP_Post object, or WP_Comment object.
      -- @param array       args        Arguments passed to get_avatar_url(), after
      --                                processing.
      --
      declare
         Avatar : constant String :=
           Apply_Filters ("pre_get_avatar", "", Id_Or_Email, Args_2); -- null
      begin
         if Avatar /= "" then
--       if not Is_Null (Avatar) then
            -- This filter is documented in wp-includes/pluggable.php
            return
              Apply_Filters ("get_avatar", Avatar, Id_Or_Email,
                             As_Integer (Get (Args_2, "size")),
                             As_Array   (Get (Args_2, "default")),
                             Get_As_String   (Args_2, "alt"),
                             Args_2);
         end if;

         if
           not As_Boolean (Get (Args_2, "force_display")) and then
           not Get_Option ("show_avatars")
         then
            return ""; -- False
         end if;

         declare
            URL_2x : constant String :=
              Get_Avatar_URL (Id_Or_Email,
                              Array_Merge (Args_2, To_Array (List => (1 =>
                                Build ("size",
                                       As_Integer (Get (Args_2, "size")) * 2)))));

            Args_3 : constant Array_Type := Get_Avatar_Data (Id_Or_Email, Args_2);

            URL : constant String := Get_As_String (Args_3, "url");
         begin
            if URL = "" or else Is_Wp_Error (URL) then
               return ""; -- False
            end if;

            declare
               Class : List_Type :=
                 ["avatar",
                  ("avatar-" & Helpers.Image (As_Integer (Get (Args_3, "size")))),
                  "photo"]; -- (int)
            begin
               if
                 not As_Boolean (Get (Args_2, "found_avatar")) or else
                 As_Boolean (Get (Args_3, "force_default"))
               then
                  Class.Append ("avatar-default");
               end if;

               if As_Boolean (Get (Args_3, "class")) then
                  if Kind_Of (Get (Args_3, "class")) = Kind_List then -- array
                     Class := List_Merge (Class, As_List (Get (Args, "class")));
                  else
                     Class.Append (Get_As_String (Args_3, "class"));
                  end if;
               end if;

               -- Add `loading` attribute.
               declare
                  Extra_Attr : UString :=
                    +Get_As_String (Args_3, "extra_attr");

                  Loading : constant String :=
                    Get_As_String (Args_3, "loading");

                  Lazy_Eager : constant List_Type :=
                    ["lazy", "eager"];

                  Async_Sync_Auto : constant List_Type :=
                    ["async", "sync", "auto"];
               begin
                  if
                    In_List (Loading, Lazy_Eager, True) and then
                    not Preg_Match ("/\bloading\s*=/", -Extra_Attr)
                  then
                     if not Empty (Extra_Attr) then
                        Append (Extra_Attr, " ");
                     end if;

                     Append (Extra_Attr, "loading=""" & Loading & """");
                  end if;

                  if
                    In_List (Get_As_String (Args_2, "decoding"),
                             Async_Sync_Auto)
                    and then
                    not Preg_Match ("/\bdecoding\s*=/", -Extra_Attr)
                  then
                     if not Empty (Extra_Attr) then
                        Append (Extra_Attr, " ");
                     end if;
                     Append (Extra_Attr,
                             "decoding=""" &
                             Get_As_String (Args_3, "decoding") &
                             """");
                  end if;

                  declare
                     Avatar_2 : constant String :=
                       Sprintf (
                         "<img alt=""%s"" src=""%s"" srcset=""%s"" class=""%s"" height=""%d"" width=""%d"" %s/>",
                         [
                           1 => ESC_Attr (Get_As_String (Args_3, "alt")),
                           2 => ESC_URL (URL),
                           3 => ESC_URL (URL_2x) & " 2x",
                           4 => ESC_Attr (Implode (" ", Class)),
                           5 => Helpers.Image (As_Integer (Get (Args_3, "height"))),
                           6 => Helpers.Image (As_Integer (Get (Args_3, "width"))),
                           7 => -Extra_Attr
                         ]
                       );
                  begin
                     --
                     -- Filters the HTML for a user"s avatar.
                     --
                     -- @since 2.5.0
                     -- @since 4.2.0 The `args` parameter was added.
                     --
                     -- @param string avatar      HTML for the user"s avatar.
                     -- @param mixed  id_or_email The avatar to retrieve. Accepts a
                     --                           user_id, Gravatar MD5 hash,  user
                     --                           email, WP_User object, WP_Post
                     --                           object, or WP_Comment object.
                     -- @param int    size        Square avatar width and height in
                     --                           pixels to retrieve.
                     -- @param string default     URL for the default image or a
                     --                           default type. Accepts "404",
                     --                           "retro", "monsterid", "wavatar",
                     --                           "indenticon", "mystery", "mm",
                     --                           "mysteryman", "blank", or
                     --                           "gravatar_default".
                     -- @param string alt         Alternative text to use in the
                     --                           avatar image tag.
                     -- @param array  args        Arguments passed to
                     --                           get_avatar_data(), after processing.
                     --
                     return Apply_Filters ("get_avatar", Avatar_2, Id_Or_Email,
                                           As_Integer (Get (Args_3, "size")),
                                           As_Array   (Get (Args_3, "default")),
                                           Get_As_String   (Args_3, "alt"),
                                           Args_3);
                  end;
               end;
            end;
         end;
      end;
   end Get_Avatar;

-- endif;

-- if ( ! function_exists( "wp_text_diff" ) ) :
--         --
--         -- Displays a human readable HTML representation of the difference between two strings.
--         --
--         -- The Diff is available for getting the changes between versions. The output is
--         -- HTML, so the primary use is for displaying the changes. If the two strings
--         -- are equivalent, then an empty string will be returned.
--         --
--         -- @since 2.6.0
--         --
--         -- @see wp_parse_args() Used to change defaults to user defined settings.
--         -- @uses Text_Diff
--         -- @uses WP_Text_Diff_Renderer_Table
--         --
--         -- @param string       left_string  "old" (left) version of string.
--         -- @param string       right_string "new" (right) version of string.
--         -- @param string|array args then
--         --     Associative array of options to pass to WP_Text_Diff_Renderer_Table().
--         --
--         --     @type string title           Titles the diff in a manner compatible
--         --                                   with the output. Default empty.
--         --     @type string title_left      Change the HTML to the left of the title.
--         --                                   Default empty.
--         --     @type string title_right     Change the HTML to the right of the title.
--         --                                   Default empty.
--         --     @type bool   show_split_view True for split view (two columns), false for
--         --                                   un-split view (single column). Default true.
--         -- end;
--         -- @return string Empty string if strings are equivalent or HTML with differences.
--         --
--         function wp_text_diff( left_string, right_string, args = null ) then
--                 defaults = array(
--                         "title"           => "",
--                         "title_left"      => "",
--                         "title_right"     => "",
--                         "show_split_view" => true,
--                 );
--                 args     = wp_parse_args( args, defaults );

--                 if ( ! class_exists( "WP_Text_Diff_Renderer_Table", false ) ) then
--                         require ABSPATH . WPINC . "/wp-diff.php";
--                 end;

--                 left_string  = normalize_whitespace( left_string );
--                 right_string = normalize_whitespace( right_string );

--                 left_lines  = explode( "\n", left_string );
--                 right_lines = explode( "\n", right_string );
--                 text_diff   = new Text_Diff( left_lines, right_lines );
--                 renderer    = new WP_Text_Diff_Renderer_Table( args );
--                 diff        = renderer->render( text_diff );

--                 if ( ! diff ) then
--                         return "";
--                 end;

--                 is_split_view       = ! empty( args["show_split_view"] );
--                 is_split_view_class = is_split_view ? " is-split-view" : "";

--                 r = "<table class="diffis_split_view_class">\n";

--                 if ( args["title"] ) then
--                         r .= "<caption class="diff-title">args[title]</caption>\n";
--                 end;

--                 if ( args["title_left"] || args["title_right"] ) then
--                         r .= "<thead>";
--                 end;

--                 if ( args["title_left"] || args["title_right"] ) then
--                         th_or_td_left  = empty( args["title_left"] ) ? "td" : "th";
--                         th_or_td_right = empty( args["title_right"] ) ? "td" : "th";

--                         r .= "<tr class="diff-sub-title">\n";
--                         r .= "\t<th_or_td_left>args[title_left]</th_or_td_left>\n";
--                         if ( is_split_view ) then
--                                 r .= "\t<th_or_td_right>args[title_right]</th_or_td_right>\n";
--                         end;
--                         r .= "</tr>\n";
--                 end;

--                 if ( args["title_left"] || args["title_right"] ) then
--                         r .= "</thead>\n";
--                 end;

--                 r .= "<tbody>\ndiff\n</tbody>\n";
--                 r .= "</table>";

--                 return r;
--         end;
-- endif;

end Inc_Pluggables;
