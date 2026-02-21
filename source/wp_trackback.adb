--
-- Handle Trackbacks and Pingbacks Sent to WordPress
--
-- @since 0.71
--
-- @package WordPress
-- @subpackage Trackbacks
--

with Php.Echoing;
with Php.Errors;
with Php.HTML;
with Php.Misc;
with Php.Multibyte;
with Php.Strings;

with Arrays;
with Array_Lists;
with Binder;
with Globals;
with Lists;
with UStrings;
with Wp_Common;

with Class_Posts;

with Inc_Comments;
with Inc_Comments_Templates;
with Inc_Formatting;
with Inc_Functions;
with Inc_Link_Templates;
with Inc_L10n;
with Inc_Options;
with Inc_Pluggables;
with Inc_Querys;

with Wp_Load;

package body Wp_Trackback
is
   use Arrays;
   use Lists;

   --
   --
   --
   procedure Trackback_Response (Error   : Boolean := False;
                                 Message : String  := "");

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Php.Errors;
      use Php.HTML;
      use Php.Misc;
      use Php.Multibyte;
      use Php.Strings;
      use Array_Lists;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Class_Posts;
      use Inc_Comments;
      use Inc_Comments_Templates;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
      use Inc_Querys;

      Post_Id : Post_Id_Type renames
        Globals.Global_Post_Id;
   begin
--    if Empty (Wp) then
         Wp_Load.Run;
         Wp (Build ("tb", "1"));
--    end if;

      -- Always run as an unauthenticated user.
      Wp_Set_Current_User (0);

      if
        not Isset (XX_GET, "tb_id") or else
        "" = Get_As_String (XX_GET, "tb_id")
      then
         declare
            Post_Id_2 : constant List_Type :=
              Explode ("/", Get_As_String (X_SERVER, "REQUEST_URI"));
         begin
            Post_Id := Post_Id_Type'Value (Post_Id_2.Last_Element);
            --  (Post_Id_2.Length - 1)); -- (int)
         end;
      end if;

      declare
         Trackback_URL : constant String :=
           (if Isset (X_POST, "url")
            then Get_As_String (X_POST, "url") else "");

         Charset_2 : constant String :=
           (if Isset (X_POST, "charset")
            then Get_As_String (X_POST, "charset") else "");

         -- These three are stripslashed here so they can be properly escaped
         -- after mb_convert_encoding().
         Title : UString :=
           +(if Isset (X_POST, "title")
             then Wp_Unslash (Get_As_String (X_POST, "title")) else "");

         Excerpt : UString :=
           +(if Isset (X_POST, "excerpt")
             then Wp_Unslash (Get_As_String (X_POST, "excerpt")) else "");

         Blog_Name : UString :=
           +(if Isset (X_POST, "blog_name")
             then Wp_Unslash (Get_As_String (X_POST, "blog_name")) else "");

         Charset : constant String :=
           (if Charset_2 /= ""
            then Str_Replace (List_Type'[",", " "], "", Strtoupper (Trim (Charset_2)))
            else "ASCII, UTF-8, ISO-8859-1, JIS, EUC-JP, SJIS");
      begin
         -- No valid uses for UTF-7.
         if 0 /= Strpos (Charset, "UTF-7") then -- false
            Die;
         end if;

         -- For international trackbacks.
         if Function_Exists ("mb_convert_encoding") then
            Title     :=
              +MB_Convert_Encoding (-Title, Get_Option ("blog_charset"), Charset);

            Excerpt   :=
              +MB_Convert_Encoding (-Excerpt, Get_Option ("blog_charset"), Charset);

            Blog_Name :=
              +MB_Convert_Encoding (-Blog_Name, Get_Option ("blog_charset"), Charset);
         end if;

         -- Now that mb_convert_encoding() has been given a swing, we need to
         -- escape these three.
         Title     := +Wp_Slash (-Title);
         Excerpt   := +Wp_Slash (-Excerpt);
         Blog_Name := +Wp_Slash (-Blog_Name);

         if Is_Single or else Is_Page then
            null;
            -- Post_Id := Posts (0).ID; -- XXX ???
         end if;

         if Post_Id = 0 then
--       if not Isset (Post_Id) or else not Post_Id then -- (int)
            Trackback_Response (
              Error   => True,
              Message => abs "I really need an ID for this to work.");
         end if;

         if
           Empty (-Title)        and then
           Empty (Trackback_URL) and then
           Empty (-Blog_Name)
         then
            -- If it doesn't look like a trackback at all.
            Wp_Redirect (Get_Permalink (Post_Id));
            Die; -- exit;
         end if;

         if not Empty (Trackback_URL) and then not Empty (-Title) then
            --
            -- Fires before the trackback is added to a post.
            --
            -- @since 4.7.0
            --
            -- @param int    post_id       Post ID related to the trackback.
            -- @param string trackback_url Trackback URL.
            -- @param string charset       Character set.
            -- @param string title         Trackback title.
            -- @param string excerpt       Trackback excerpt.
            -- @param string blog_name     Blog name.
            --
            Do_Action ("pre_trackback_post", Post_Id, Trackback_URL,
                       Charset, -Title, -Excerpt, -Blog_Name);

            Header ("Content-Type: text/xml; charset=" & Get_Option ("blog_charset"));

            if not Pings_Open (Post_Id) then
               Trackback_Response (
                 Error   => True,
                 Message => abs "Sorry, trackbacks are closed for this item.");
            end if;

            Title   := +Wp_HTML_Excerpt (-Title,   250, "&#8230;");
            Excerpt := +Wp_HTML_Excerpt (-Excerpt, 252, "&#8230;");

            declare
               Comment_Post_Id      : constant String := Post_Id'Image; -- (int)
               Comment_Author       : constant String := -Blog_Name;
               Comment_Author_Email : constant String := "";
               Comment_Author_URL   : constant String := Trackback_URL;
               Comment_Content      : constant String :=
                 -("<strong>" & Title & "</strong>" & NL & NL & Excerpt);
               Comment_Type         : constant String := "trackback";

               Dupe : constant Array_List := Globals.WpDB.Get_Results (
                 Globals.WpDB.Prepare (
                   "SELECT * FROM wpdb.comments WHERE comment_post_ID = %d AND comment_author_url = %s",
                   [
                    1 => Comment_Post_Id,
                    2 => Comment_Author_URL
                   ]
                 )
               );
            begin
               if not Dupe.Is_Empty then
                  Trackback_Response (
                    Error   => True,
                    Message => abs "There is already a ping from that URL for this post.");
               end if;

               declare
                  Commentdata_2 : constant Array_Type := To_Array_Type ([
                    Build ("comment_post_ID", Comment_Post_Id)
                  ]);

                  Commentdata : constant Array_Type := To_Array_Type ([ -- += Compact (
                    Commentdata_2,
                    Build ("comment_author",       Comment_Author),
                    Build ("comment_author_email", Comment_Author_Email),
                    Build ("comment_author_url",   Comment_Author_URL),
                    Build ("comment_content",      Comment_Content),
                    Build ("comment_type",         Comment_Type)
                  ]);

                  Result : constant Comment_Error_Type :=
                    Wp_New_Comment (Commentdata);
               begin
                  if not Result.Success then
--                if Is_Wp_Error (Result) then
                     Trackback_Response (
                       Error   => True,
                       Message => Result.Error.Get_Error_Message);
                  end if;
               end;
            end;

            declare
               Trackback_Id : constant Integer := Globals.WpDB.Insert_Id;
            begin
               --
               -- Fires after a trackback is added to a post.
               --
               -- @since 1.2.0
               --
               -- @param int trackback_id Trackback ID.
               --
               Do_Action ("trackback_post", Trackback_Id);
            end;

            Trackback_Response (Error => False);
         end if;
      end;
   end Render;

   --
   -- Response to a trackback.
   --
   -- Responds with an error or success XML message.
   --
   -- @since 0.71
   --
   -- @param int|bool error         Whether there was an error.
   --                                Default "0". Accepts "0" or "1", true or false.
   -- @param string   error_message Error message if an error occurred.
   --
   procedure Trackback_Response (Error   : Boolean := False;
                                 Message : String  := "")
   is
      use Php.Echoing;
      use Php.Errors;
      use Php.HTML;
      use UStrings;
      use Inc_Options;
   begin
      Header ("Content-Type: text/xml; charset=" & Get_Option ("blog_charset"));

      if Error then
         Echo ("<?xml version=""1.0"" encoding=""utf-8""?" & ">" & NL);
         Echo ("<response>" & NL);
         Echo ("<error>1</error>" & NL);
         Echo ("<message>" & Message & "</message>" & NL);
         Echo ("</response>");
         Die;
      else
         Echo ("<?xml version=""1.0"" encoding=""utf-8""?" & ">" & NL);
         Echo ("<response>" & NL);
         Echo ("<error>0</error>" & NL);
         Echo ("</response>");
      end if;
   end Trackback_Response;

end Wp_Trackback;
