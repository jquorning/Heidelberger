--
-- Creates common globals for the rest of WordPress
--
-- Sets $pagenow global which is the filename of the current screen.
-- Checks for the browser to set which one is currently being used.
--
-- Detects which user environment WordPress is being used on.
-- Only attempts to check for Apache, Nginx and IIS -- three web
-- servers with known pretty permalink capability.
--
-- Note: Though Nginx is detected, WordPress does not currently
-- generate rewrite rules for it. See https://wordpress.org/support/article/nginx/
--
-- @package WordPress
--

with Php.HTML;
with Php.Preg;
with Php.Strings;

with Arrays;
with Binder;
with Lists;
with Wp_Common;

with Inc_Load;
with Inc_Plugins;

package body Inc_Vars
is

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Php.HTML;
      use Php.Preg;
      use Php.Strings;
      use Arrays;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Inc_Load;

      Php_Self : constant String := As_String (Get (X_SERVER, "PHP_SELF"));
      Self_Matches : Lists.List_Type;
      Unused : Integer;
   begin
      -- On which page are we?
      if Is_Admin then
         -- wp-admin pages are checked more carefully.
         if Is_Network_Admin then
            Unused := Preg_Match ("#/wp-admin/network/?(.*?)#i",
                                  Php_Self, Self_Matches);
         elsif Is_User_Admin then
            Unused := Preg_Match ("#/wp-admin/user/?(.*?)#i", Php_Self, Self_Matches);
         else
            Unused := Preg_Match ("#/wp-admin/?(.*?)#i", Php_Self, Self_Matches);
         end if;

         Pagenow := +(if Self_Matches.Length in 1
                     then -Self_Matches (1) else "");
         Pagenow := +Trim (-Pagenow, "/");
         Pagenow := +Preg_Replace ("#\?.*?#", "", -Pagenow);

         if -Pagenow in "" | "index" | "index.php" then
            Pagenow := +"index.php";
         else
            Unused  := Preg_Match ("#(.*?)(/|)#", -Pagenow, Self_Matches);
            Pagenow := +Strtolower (-Self_Matches (1));

            if ".php" /= Substr (-Pagenow, -4, 4) then
               Pagenow := Pagenow & ".php";
               -- For `Options +Multiviews`: /wp-admin/themes/index.php (themes.php
               -- is queried).
            end if;
         end if;
      else
         if
           0 /= Preg_Match ("#((^/)+\.php)((?/).*?)?#i", Php_Self, Self_Matches)
         then
            Pagenow := +Strtolower (-Self_Matches (1));
         else
            Pagenow := +"index.php";
         end if;
      end if;
--    Unset (Self_Matches);

      -- Simple browser detection.
      Is_Lynx   := False;
      Is_Gecko  := False;
      Is_winIE  := False;
      Is_macIE  := False;
      Is_Opera  := False;
      Is_NS4    := False;
      Is_Safari := False;
      Is_Chrome := False;
      Is_iPhone := False;
      Is_Edge   := False;

      if Isset (X_SERVER, "HTTP_USER_AGENT") then
         declare
            use Inc_Plugins;

            Http_User_Agent : constant String := As_String (Get (X_SERVER, "HTTP_USER_AGENT"));
            Is_Admin : Boolean;
         begin
            if Strpos (Http_User_Agent, "Lynx") /= 0 then
               Is_Lynx := True;
            elsif Strpos (Http_User_Agent, "Edg") /= 0 then
               Is_Edge := True;
            elsif Stripos (Http_User_Agent, "chrome") /= 0 then
               if Stripos (Http_User_Agent, "chromeframe") /= 0 then
                  Is_Admin := Inc_Load.Is_Admin;
                  --
                  -- Filters whether Google Chrome Frame should be used, if available.
                  --
                  -- @since 3.2.0
                  --
                  -- @param bool is_admin Whether to use the Google Chrome Frame.
                  --                      Default is the value of is_admin().
                  --
                  Is_Chrome := Apply_Filters ("use_google_chrome_frame", Is_Admin);
                  if Is_Chrome then
                     Header ("X-UA-Compatible: chrome=1");
                  end if;
                  Is_winIE := not Is_Chrome;
               else
                  Is_Chrome := True;
               end if;

            elsif Stripos (Http_User_Agent, "safari") /= 0 then
               Is_Safari := True;
            elsif
              (Strpos (Http_User_Agent, "MSIE")    /= 0 or else
               Strpos (Http_User_Agent, "Trident") /= 0) and then
              Strpos (Http_User_Agent, "Win") /= 0
            then
               Is_winIE := True;
            elsif
              Strpos (Http_User_Agent, "MSIE") /= 0 and then
              Strpos (Http_User_Agent, "Mac")  /= 0
            then
               Is_macIE := True;
            elsif Strpos (Http_User_Agent, "Gecko") /= 0 then
               Is_Gecko := True;
            elsif Strpos (Http_User_Agent, "Opera") /= 0 then
               Is_Opera := True;
            elsif
              Strpos (Http_User_Agent, "Nav") /= 0 and then
              Strpos (Http_User_Agent, "Mozilla/4.") /= 0
            then
               Is_NS4 := True;
            end if;
         end;
      end if;

      declare
         Http_User_Agent : constant String := As_String (Get (X_SERVER, "HTTP_USER_AGENT"));
      begin
         if
           Is_Safari and then Stripos (Http_User_Agent, "mobile") /= 0
         then
            Is_iPhone := True;
         end if;
      end;

      Is_IE := (Is_macIE or else Is_winIE);

      -- Server detection.
      declare
         Server_Software : constant String := As_String (Get (X_SERVER, "SERVER_SOFTWARE"));
      begin
         --
         -- Whether the server software is Apache or something else
         --
         -- @global bool is_apache
         --
         Is_Apache := (Strpos (Server_Software, "Apache")    /= 0 or else
                       Strpos (Server_Software, "LiteSpeed") /= 0);

         --
         -- Whether the server software is Nginx or something else
         --
         -- @global bool is_nginx
         --
         Is_Nginx := (Strpos (Server_Software, "nginx") /= 0);

         --
         -- Whether the server software is IIS or something else
         --
         -- @global bool is_IIS
         --
         Is_IIS := not Is_Apache and then
           (Strpos (Server_Software, "Microsoft-IIS") /= 0 or else
            Strpos (Server_Software, "ExpressionDevServer") /= 0);

         --
         -- Whether the server software is IIS 7.X or greater
         --
         -- @global bool is_iis7
         --
--       Is_IIS7 := Is_IIS and then Substr (Server_Software,
--          Strpos (Server_Software, "Microsoft-IIS/") + 14) >= 7;
      end;
   end Run;

   ------------------
   -- Wp_Is_Mobile --
   ------------------

   function Wp_Is_Mobile
            return Boolean
   is
      use Php.Strings;
      use Arrays;
      use Wp_Common;

      Http_User_Agent : constant String :=
        As_String (Get (Binder.X_SERVER, "HTTP_USER_AGENT"));

      Is_Mobile : Boolean;
   begin
      if Empty (Http_User_Agent) then
         Is_Mobile := False;
      elsif Strpos (Http_User_Agent, "Mobile") /= 0
            -- Many mobile devices (all iPhone, iPad, etc.)
            or else Strpos (Http_User_Agent, "Android")    /= 0
            or else Strpos (Http_User_Agent, "Silk/")      /= 0
            or else Strpos (Http_User_Agent, "Kindle")     /= 0
            or else Strpos (Http_User_Agent, "BlackBerry") /= 0
            or else Strpos (Http_User_Agent, "Opera Mini") /= 0
            or else Strpos (Http_User_Agent, "Opera Mobi") /= 0
      then
         Is_Mobile := True;
      else
         Is_Mobile := False;
      end if;

      --
      -- Filters whether the request should be treated as coming from a mobile
      -- device or not.
      --
      -- @since 4.9.0
      --
      -- @param bool is_mobile Whether the request is from a mobile device or not.
      --
      return Apply_Filters ("wp_is_mobile", Is_Mobile);
   end Wp_Is_Mobile;

end Inc_Vars;
