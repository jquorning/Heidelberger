--
-- WordPress Link Template Functions
--
-- @package WordPress
-- @subpackage Template
--

with Ada.Containers;
with Ada.Strings.Unbounded;

with Php.Arrays;
with Php.HTML;
with Php.Lists;
with Php.Misc;
with Php.Numerics;
with Php.Preg;
with Php.Strings;
with Php.Types;

with Globals;
with Hb_Common;
with Helpers;
with Lists;
with Wp_Common;

with Inc_Capabilities;
with Inc_Class_Wp_Post_Type;
with Inc_Class_Wp_Terms;
with Inc_Class_Wp_Users;
with Inc_Category_Templates;
with Inc_Formatting;
with Inc_Functions;
with Inc_General_Templates;
with Inc_Load;
with Inc_Ms_Blogs;
with Inc_Options;
with Inc_Plugins;
with Inc_Pluggables;
with Inc_Posts;
with Inc_Taxonomys;
with Inc_Querys;

package body Inc_Link_Templates
is
   use Lists;

-- --
-- -- Displays the permalink for the current post.
-- --
-- -- @since 1.2.0
-- -- @since 4.4.0 Added the `post` parameter.
-- --
-- -- @param int|WP_Post post Optional. Post ID or post object. Default is the global `post`.
-- --
-- function the_permalink( post = 0 ) then
--         --
--         -- Filters the display of the permalink for the current post.
--         --
--         -- @since 1.5.0
--         -- @since 4.4.0 Added the `post` parameter.
--         --
--         -- @param string      permalink The permalink for the current post.
--         -- @param int|WP_Post post      Post ID, WP_Post object, or 0. Default 0.
--         --
--         echo esc_url( apply_filters( "the_permalink", get_permalink( post ), post ) );
-- end;

   ----------------------------
   -- User_Trailing_Slash_It --
   ----------------------------

   function User_Trailing_Slash_It (Item        : String;
                                    Type_Of_URL : String := "")
                                    return String
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Inc_Formatting;
      use Inc_Plugins;

      Item_2 : Unbounded_String;
   begin
      if Global_Wp_Rewrite.Use_Trailing_Slashes then
         Item_2 := +Trailing_Slash_It (Item);
      else
         Item_2 := +Un_Trailing_Slash_It (Item);
      end if;

      --
      -- Filters the trailing-slashed string, depending on whether the site is set to
      -- use trailing slashes.
      --
      -- @since 2.2.0
      --
      -- @param string string      URL with or without a trailing slash.
      -- @param string type_of_url The type of URL being considered. Accepts "single",
      --                            "single_trackback", "single_feed", "single_paged",
      --                            "commentpaged", "paged", "home", "feed",
      --                            "category", "page", "year", "month", "day",
      --                            "post_type_archive".
      --
      return Apply_Filters ("user_trailingslashit", -Item_2, Type_Of_URL);
   end User_Trailing_Slash_It;

-- --
-- -- Displays the permalink anchor for the current post.
-- --
-- -- The permalink mode title will use the post title for the "a" element "id"
-- -- attribute. The id mode uses "post-" with the post ID for the "id" attribute.
-- --
-- -- @since 0.71
-- --
-- -- @param string mode Optional. Permalink mode. Accepts "title" or "id". Default "id".
-- --
-- function permalink_anchor( mode = "id" ) then
--         post = get_post();
--         switch ( strtolower( mode ) ) then
--                 case "title":
--                         title = sanitize_title( post->post_title ) . "-" . post->ID;
--                         echo "<a id="" . title . ""></a>";
--                         break;
--                 case "id":
--                 default:
--                         echo "<a id="post-" . post->ID . ""></a>";
--                         break;
--         end;
-- end;

   -----------------------------------
   -- Wp_Force_Plain_Post_Permalink --
   -----------------------------------

   function Wp_Force_Plain_Post_Permalink
              (Post   : Inc_Class_Wp_Posts.Wp_Post; -- null
               Sample : Boolean := False) -- null
               return Boolean
   is
      use Inc_Capabilities;
      use Inc_Class_Wp_Posts;
      use Inc_Class_Wp_Post_Type;
      use Inc_Posts;

      Sample_2 : Boolean := Sample;
   begin
--      if
--        not Sample and then -- null
--        Is_Object (Post) and then
--        Isset (Post.filter) and then
--        "sample" = Post.Filter
--      then
         Sample_2 := True;
--      else
--         Post   := Get_Post (Post);
--         Sample := null !== sample ? sample : false;
--      end if;

      if Post = Null_Post then
         return True;
      end if;

      declare
         Post_Status_Obj : constant Status_Type :=
           Get_Post_Status_Object (Get_Post_Status (Post));

         Post_Type_Obj : constant Wp_Post_Type :=
           Get_Post_Type_Object (Get_Post_Type (Post));
      begin
         if
           Post_Status_Obj = Null_Status or else -- not
           Post_Type_Obj = Null_Post_Type -- not
         then
            return True;
         end if;

         if
           -- Publicly viewable links never have plain permalinks.
           Is_Post_Status_Viewable (Post_Status_Obj) or else
           (
            -- Private posts don't have plain permalinks if the user can read them.
            Post_Status_Obj.Privat and then
            Current_User_Can ("read_post", Integer (Post.Id))
           ) or else
           -- Protected posts don't have plain links if getting a sample URL.
           (Post_Status_Obj.Protect and then Sample_2)
         then
            return False;
         end if;
      end;
      return True;
   end Wp_Force_Plain_Post_Permalink;

-- --
-- -- Retrieves the full permalink for the current post or post ID.
-- --
-- -- This function is an alias for get_permalink().
-- --
-- -- @since 3.9.0
-- --
-- -- @see get_permalink()
-- --
-- -- @param int|WP_Post post      Optional. Post ID or post object. Default is the global `post`.
-- -- @param bool        leavename Optional. Whether to keep post name or page name. Default false.
-- -- @return string|false The permalink URL. False if the post does not exist.
-- --
-- function get_the_permalink( post = 0, leavename = false ) then
--         return get_permalink( post, leavename );
-- end;

   -------------------
   -- Get_Permalink --
   -------------------

   function Get_Permalink (Id        : Inc_Class_Wp_Posts.Post_Id := 0;
                           Leavename : Boolean := False)
                           return String
   is
      use Ada.Strings.Unbounded;
      use Php.Lists;
      use Php.Strings;
--    use Php.Types;
      use Hb_Common;
      use Wp_Common;
      use Inc_Class_Wp_Posts;
      use Inc_Class_Wp_Terms;
      use Inc_Class_Wp_Users;
      use Inc_Class_Wp_Terms.Term_Vectors;
      use Inc_Category_Templates;
--    use Inc_Functions;
      use Inc_Load;
      use Inc_Options;
--    use Inc_Plugins;
      use Inc_Pluggables;
      use Inc_Posts;
      use Inc_Taxonomys;
      use List_Vectors;

      Rewrite_Code : constant List_Type := To_List (List => (
        +"%year%",
        +"%monthnum%",
        +"%day%",
        +"%hour%",
        +"%minute%",
        +"%second%",
        +(if Leavename then "" else "%postname%"),
        +"%post_id%",
        +"%category%",
        +"%author%",
        +(if Leavename then "" else "%pagename%")
      ));

      Sample : Boolean;
      Post   : Wp_Post;
      Permalink : Unbounded_String;
   begin
--      if
--        Is_Object (Post)    and then
--        Isset (Post.Filter) and then
--        "sample" = Post.Filter
--      then
--         Sample := True;
--      else
         Post   := Get_Post (Id); -- Post);
         Sample := False;
--      end if;

      if Post.Id = 0 then
--    if Empty (Post.Id) then
         return ""; -- False;
      end if;

      if "page" = Post.Post_Type then
         return Get_Page_Link (Post, Leavename, Sample);
      elsif "attachment" = Post.Post_Type then
         return Get_Attachment_Link (Post, Leavename);
      elsif
        In_List (-Post.Post_Type,
                 Get_Post_Types (To_Array (List => (1 =>
                    Build ("_builtin", False)))), True)
      then
         return Get_Post_Permalink (Post, Leavename, Sample);
      end if;

      Permalink := +Get_Option ("permalink_structure");

      --
      -- Filters the permalink structure for a post before token replacement occurs.
      --
      -- Only applies to posts with post_type of "post".
      --
      -- @since 3.0.0
      --
      -- @param string  permalink The site"s permalink structure.
      -- @param WP_Post post      The post in question.
      -- @param bool    leavename Whether to keep the post name.
      --
      Permalink := +Apply_Filters ("pre_post_link", -Permalink, Post, Leavename);

      if
        Permalink /= "" and then
        not Wp_Force_Plain_Post_Permalink (Post)
      then
         declare
            Category : List_Type; -- Unbounded_String;
         begin
            if Strpos (-Permalink, "%category%") /= 0 then
               declare
                  Cats : constant Wp_Term_Array := Get_The_Category (Post.Id);
               begin
                  if Cats /= Empty_Term_Array then
--                     Cats :=
--                       Wp_List_Sort (
--                         Cats,
--                         To_Array (List => (1 =>
--                           Build ("term_id", "ASC")
--                         ))
--                       );

                     --
                     -- Filters the category that gets used in the %category%
                     -- permalink token.
                     --
                     -- @since 3.5.0
                     --
                     -- @param WP_Term  cat  The category to use in the permalink.
                     -- @param array    cats Array of all categories (WP_Term objects)
                     --                       associated with the post.
                     -- @param WP_Post  post The post in question.
                     --
                     declare
                        Category_Object : Wp_Term :=
                          Apply_Filters ("post_link_category",
                                         Cats.First_Element, Cats, Post); -- [0]
                     begin
                        Category_Object := Get_Term (Category_Object, "category");
                        Category.Append (Category_Object.Slug);
                        if Category_Object.Parent /= 0 then
                           Category.Prepend (
                             +Get_Category_Parents (Category_Object.Parent,
                                                   False, "/", True));
                           -- Category :=
                           --   Get_Category_Parents (Category_Object.Parent,
                           --                         False, "/", True) & Category;
                        end if;
                     end;
                  end if;

                  -- Show default category in permalinks,
                  -- without having to assign it explicitly.
                  if Category.Is_Empty then
--                if Empty (Category) then
                     declare
                        Default_Category : constant Wp_Term :=
                          Get_Term (Get_Option ("default_category"), "category");
                     begin
                        if
                          Default_Category /= Null_Term and then
                          not Is_Wp_Error (Default_Category)
                        then
                           Category := Empty_List & Default_Category.Slug;
                        end if;
                     end;
                  end if;
               end;

               declare
                  Author : Unbounded_String;
               begin
                  if Strpos (-Permalink, "%author%") /= 0 then
                     declare
                        Authordata : constant Wp_User :=
                          Get_Userdata (Post.Post_Author);
                     begin
                        Author := Authordata.Prop.User_Nicename;
                     end;
                  end if;

                  -- This is not an API call because the permalink is based on the
                  -- stored post_date value, which should be parsed as local time
                  -- regardless of the default PHP timezone.
                  declare
                     L : constant List_Type := To_List (List => (+"-", +":"));

                     Date : constant List_Type :=
                       Explode (" ", Str_Replace (L, " ", -Post.Post_Date));

                     Rewrite_Replace : constant List_Type := To_List (List => (
                        Date (1),
                        Date (2),
                        Date (3),
                        Date (4),
                        Date (5),
                        Date (6),
                        Post.Post_Name,
                        +Helpers.Image (Integer (Post.Id)),
                        Category.First_Element, -- First_Element added
                        Author,
                        Post.Post_Name
                     ));
                  begin
                     Permalink :=
                       +Home_URL (Str_Replace (Rewrite_Code,
                                               Rewrite_Replace,
                                               -Permalink));

                     Permalink := +User_Trailing_Slash_It (-Permalink, "single");
                  end;
               end;
            end if;
         end;
      else  -- If they're not using the fancy permalink option.
         Permalink := +Home_URL ("?p=" & Helpers.Image (Integer (Post.Id)));
      end if;
--      end;
      --
      -- Filters the permalink for a post.
      --
      -- Only applies to posts with post_type of "post".
      --
      -- @since 1.5.0
      --
      -- @param string  permalink The post"s permalink.
      -- @param WP_Post post      The post in question.
      -- @param bool    leavename Whether to keep the post name.
      --
      return Apply_Filters ("post_link", -Permalink, Post, Leavename);
   end Get_Permalink;

   ------------------------
   -- Get_Post_Permalink --
   ------------------------

   function Get_Post_Permalink (Id        : Inc_Class_Wp_Posts.Wp_Post; -- = 0,
                                Leavename : Boolean := False;
                                Sample    : Boolean := False)
                                return String
   is
      use Ada.Strings.Unbounded;
      use Php.Strings;
      use Hb_Common;
      use Wp_Common;
      use Inc_Class_Wp_Posts;
      use Inc_Class_Wp_Post_Type;
      use Inc_Functions;
      use Inc_Posts;
--    use Inc_Plugins;

      Post : constant Wp_Post := Get_Post (Id);
   begin
      if Post = Null_Post then
         return ""; -- false;
      end if;

      declare
         Post_Link : Unbounded_String :=
           +Global_Wp_Rewrite.Get_Extra_Permastruct (-Post.Post_Type);

         Slug : String := -Post.Post_Name;

         Force_Plain_Link : constant Boolean := Wp_Force_Plain_Post_Permalink (Post);

         Post_Type : constant Wp_Post_Type := Get_Post_Type_Object (-Post.Post_Type);
      begin
         if Post_Type.Hierarchical then
            Slug := Get_Page_URI (Post);
         end if;

         if
           not Empty (-Post_Link) and then
           (not Force_Plain_Link or Sample)
         then
            if not Leavename then
               Post_Link := +Str_Replace ("%post->post_type%", Slug, -Post_Link);
            end if;
            Post_Link := +Home_URL (User_Trailing_Slash_It (-Post_Link));
         else
            if
              Post_Type.Query_Var /= "" and then
              (Isset (-Post.Post_Status) and then not Force_Plain_Link)
            then
               Post_Link := +Add_Query_Arg (-Post_Type.Query_Var, Slug, "");
            else
               Post_Link :=
                 +Add_Query_Arg (
                   To_Array (List => (
                     Build ("post_type", -Post.Post_Type),
                     Build ("p",         Helpers.Image (Integer (Post.Id)))
                   )),
                   ""
                 );
            end if;
            Post_Link := +Home_URL (-Post_Link);
         end if;

         --
         -- Filters the permalink for a post of a custom post type.
         --
         -- @since 3.0.0
         --
         -- @param string  post_link The post"s permalink.
         -- @param WP_Post post      The post in question.
         -- @param bool    leavename Whether to keep the post name.
         -- @param bool    sample    Is it a sample permalink.
         --
         return Apply_Filters ("post_type_link", -Post_Link, Post, Leavename, Sample);
      end;
   end Get_Post_Permalink;

   -------------------
   -- Get_Page_Link --
   -------------------

   function Get_Page_Link (Post      : Inc_Class_Wp_Posts.Wp_Post;
                           Leavename : Boolean := False;
                           Sample    : Boolean := False)
                           return String
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Wp_Common;
      use Inc_Class_Wp_Posts;
      use Inc_Posts;
--    use Inc_Plugins;
      use Inc_Options;

      Post_2 : constant Wp_Post := Get_Post (Post);
      Link   : Unbounded_String;
   begin
      if
        "page" = Get_Option ("show_on_front") and then
         Get_Option ("page_on_front") = Integer (Post_2.Id)
      then
         Link := +Home_URL ("/");
      else
         Link := +X_Get_Page_Link (Post_2, Leavename, Sample);
      end if;

      --
      -- Filters the permalink for a page.
      --
      -- @since 1.5.0
      --
      -- @param string link    The page"s permalink.
      -- @param int    post_id The ID of the page.
      -- @param bool   sample  Is it a sample permalink.
      --
      return Apply_Filters ("page_link", -Link, Post_2.Id, Sample);
   end Get_Page_Link;

   ---------------------
   -- X_Get_Page_Link --
   ---------------------

   function X_Get_Page_Link (Post      : Inc_Class_Wp_Posts.Wp_Post; -- = false,
                             Leavename : Boolean := False;
                             Sample    : Boolean := False)
                             return String
   is
      use Ada.Strings.Unbounded;
      use Php.Strings;
      use Hb_Common;
      use Inc_Class_Wp_Posts;
      use Inc_Posts;
      use Inc_Plugins;

--        global wp_rewrite;

      Post_2 : constant Wp_Post := Get_Post (Post);

      Force_Plain_Link : constant Boolean := Wp_Force_Plain_Post_Permalink (Post_2);

      Link : Unbounded_String := +Global_Wp_Rewrite.Get_Page_Permastruct;
   begin
      if
        not Empty (-Link) and then
        ((Isset (-Post_2.Post_Status) and then
          not Force_Plain_Link) or else Sample)
      then
         if not Leavename then
            Link := +Str_Replace ("%pagename%", Get_Page_URI (Post_2), -Link);
         end if;

         Link := +Home_URL (-Link);
         Link := +User_Trailing_Slash_It (-Link, "page");
      else
         Link := +Home_URL ("?page_id=" & Helpers.Image (Integer (Post_2.Id)));
      end if;

      --
      -- Filters the permalink for a non-page_on_front page.
      --
      -- @since 2.1.0
      --
      -- @param string link    The page"s permalink.
      -- @param int    post_id The ID of the page.
      --
      return Apply_Filters ("_get_page_link",
                            -Link, Helpers.Image (Integer (Post_2.Id)));
   end X_Get_Page_Link;

   -------------------------
   -- Get_Attachment_Link --
   -------------------------

   function Get_Attachment_Link (Post      : Inc_Class_Wp_Posts.Wp_Post; -- null
                                 Leavename : Boolean := False)
                                 return String
   is
      use Ada.Strings.Unbounded;
      use Php.Strings;
      use Php.Types;
      use Hb_Common;
      use Inc_Class_Wp_Posts;
      use Inc_Formatting;
      use Inc_Options;
      use Inc_Posts;
      use Inc_Plugins;

      Link : Unbounded_String; -- Boolean := false;

      Post_2           : constant Wp_Post := Get_Post (Post);
      Force_Plain_Link : constant Boolean := Wp_Force_Plain_Post_Permalink (Post_2);
      Parent_Id        : constant Post_Id := Post_2.Post_Parent;
      Parent           : Wp_Post := (if Parent_Id /= 0
                                     then Get_Post (Parent_Id)
                                     else Null_Post); -- False);
      Parent_Valid     : Boolean := True; -- Default for no parent.
      Parentlink       : Unbounded_String;
      Name             : Unbounded_String;
   begin
      if
        Parent_Id /= 0 and then
        (
          Post.Post_Parent = Post.Id or else
          Parent = Null_Post or else -- not
          not Is_Post_Type_Viewable (Get_Post_Type (Parent))
        )
      then
         -- Post is either its own parent or parent post unavailable.
         Parent_Valid := False;
      end if;

      if Force_Plain_Link or else not Parent_Valid then
         Link := +""; -- False;
      elsif
        Global_Wp_Rewrite.Using_Permalinks and then
        Parent /= Null_Post
      then
         if "page" = Parent.Post_Type then
            Parentlink := +X_Get_Page_Link (Post.Post_Parent);
            -- Ignores page_on_front.
         else
            Parentlink := +Get_Permalink (Post.Post_Parent);
         end if;

         if
           Is_Numeric (-Post.Post_Name) or else
           0 /= Strpos (Get_Option ("permalink_structure"), "%category%")
         then
            Name := +"attachment/" & Post.Post_Name;
            -- <permalink>/<int>/ is paged so we use the explicit attachment marker.
         else
            Name := Post.Post_Name;
         end if;

         if Strpos (-Parentlink, "?") = 0 then
            Link := +User_Trailing_Slash_It (
                       Trailing_Slash_It (-Parentlink) & "%postname%");
         end if;

         if not Leavename then
            Link := +Str_Replace ("%postname%", -Name, -Link);
         end if;

      elsif Global_Wp_Rewrite.Using_Permalinks and then not Leavename then
         Link := +Home_URL (User_Trailing_Slash_It (-Post.Post_Name));
      end if;

      if Link = "" then -- not
         Link := +Home_URL ("/?attachment_id=" & Helpers.Image (Integer (Post.Id)));
      end if;

      --
      -- Filters the permalink for an attachment.
      --
      -- @since 2.0.0
      -- @since 5.6.0 Providing an empty string will now disable
      --              the view attachment page link on the media modal.
      --
      -- @param string link    The attachment"s permalink.
      -- @param int    post_id Attachment ID.
      --
      return Apply_Filters ("attachment_link", -Link, Integer (Post.Id));
   end Get_Attachment_Link;

-- --
-- -- Retrieves the permalink for the year archives.
-- --
-- -- @since 1.5.0
-- --
-- -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
-- --
-- -- @param int|false year Integer of year. False for current year.
-- -- @return string The permalink for the specified year archive.
-- --
-- function get_year_link( year ) then
--         global wp_rewrite;
--         if ( ! year ) then
--                 year = current_time( "Y" );
--         end;
--         yearlink = wp_rewrite->get_year_permastruct();
--         if ( ! empty( yearlink ) ) then
--                 yearlink = str_replace( "%year%", year, yearlink );
--                 yearlink = home_url( user_trailingslashit( yearlink, "year" ) );
--         end; else then
--                 yearlink = home_url( "?m=" . year );
--         end;

--         --
--         -- Filters the year archive permalink.
--         --
--         -- @since 1.5.0
--         --
--         -- @param string yearlink Permalink for the year archive.
--         -- @param int    year     Year for the archive.
--         --
--         return apply_filters( "year_link", yearlink, year );
-- end;

-- --
-- -- Retrieves the permalink for the month archives with year.
-- --
-- -- @since 1.0.0
-- --
-- -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
-- --
-- -- @param int|false year  Integer of year. False for current year.
-- -- @param int|false month Integer of month. False for current month.
-- -- @return string The permalink for the specified month and year archive.
-- --
-- function get_month_link( year, month ) then
--         global wp_rewrite;
--         if ( ! year ) then
--                 year = current_time( "Y" );
--         end;
--         if ( ! month ) then
--                 month = current_time( "m" );
--         end;
--         monthlink = wp_rewrite->get_month_permastruct();
--         if ( ! empty( monthlink ) ) then
--                 monthlink = str_replace( "%year%", year, monthlink );
--                 monthlink = str_replace( "%monthnum%", zeroise( (int) month, 2 ), monthlink );
--                 monthlink = home_url( user_trailingslashit( monthlink, "month" ) );
--         end; else then
--                 monthlink = home_url( "?m=" . year . zeroise( month, 2 ) );
--         end;

--         --
--         -- Filters the month archive permalink.
--         --
--         -- @since 1.5.0
--         --
--         -- @param string monthlink Permalink for the month archive.
--         -- @param int    year      Year for the archive.
--         -- @param int    month     The month for the archive.
--         --
--         return apply_filters( "month_link", monthlink, year, month );
-- end;

-- --
-- -- Retrieves the permalink for the day archives with year and month.
-- --
-- -- @since 1.0.0
-- --
-- -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
-- --
-- -- @param int|false year  Integer of year. False for current year.
-- -- @param int|false month Integer of month. False for current month.
-- -- @param int|false day   Integer of day. False for current day.
-- -- @return string The permalink for the specified day, month, and year archive.
-- --
-- function get_day_link( year, month, day ) then
--         global wp_rewrite;
--         if ( ! year ) then
--                 year = current_time( "Y" );
--         end;
--         if ( ! month ) then
--                 month = current_time( "m" );
--         end;
--         if ( ! day ) then
--                 day = current_time( "j" );
--         end;

--         daylink = wp_rewrite->get_day_permastruct();
--         if ( ! empty( daylink ) ) then
--                 daylink = str_replace( "%year%", year, daylink );
--                 daylink = str_replace( "%monthnum%", zeroise( (int) month, 2 ), daylink );
--                 daylink = str_replace( "%day%", zeroise( (int) day, 2 ), daylink );
--                 daylink = home_url( user_trailingslashit( daylink, "day" ) );
--         end; else then
--                 daylink = home_url( "?m=" . year . zeroise( month, 2 ) . zeroise( day, 2 ) );
--         end;

--         --
--         -- Filters the day archive permalink.
--         --
--         -- @since 1.5.0
--         --
--         -- @param string daylink Permalink for the day archive.
--         -- @param int    year    Year for the archive.
--         -- @param int    month   Month for the archive.
--         -- @param int    day     The day for the archive.
--         --
--         return apply_filters( "day_link", daylink, year, month, day );
-- end;

-- --
-- -- Displays the permalink for the feed type.
-- --
-- -- @since 3.0.0
-- --
-- -- @param string anchor The link"s anchor text.
-- -- @param string feed   Optional. Feed type. Possible values include "rss2", "atom".
-- --                       Default is the value of get_default_feed().
-- --
-- function the_feed_link( anchor, feed = "" ) then
--         link = "<a href="" . esc_url( get_feed_link( feed ) ) . "">" . anchor . "</a>";

--         --
--         -- Filters the feed link anchor tag.
--         --
--         -- @since 3.0.0
--         --
--         -- @param string link The complete anchor tag for a feed link.
--         -- @param string feed The feed type. Possible values include "rss2", "atom",
--         --                     or an empty string for the default feed type.
--         --
--         echo apply_filters( "the_feed_link", link, feed );
-- end;

-- --
-- -- Retrieves the permalink for the feed type.
-- --
-- -- @since 1.5.0
-- --
-- -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
-- --
-- -- @param string feed Optional. Feed type. Possible values include "rss2", "atom".
-- --                     Default is the value of get_default_feed().
-- -- @return string The feed permalink.
-- --
-- function get_feed_link( feed = "" ) then
--         global wp_rewrite;

--         permalink = wp_rewrite->get_feed_permastruct();

--         if ( permalink ) then
--                 if ( false !== strpos( feed, "comments_" ) ) then
--                         feed      = str_replace( "comments_", "", feed );
--                         permalink = wp_rewrite->get_comment_feed_permastruct();
--                 end;

--                 if ( get_default_feed() == feed ) then
--                         feed = "";
--                 end;

--                 permalink = str_replace( "%feed%", feed, permalink );
--                 permalink = preg_replace( "#/+#", "/", "/permalink" );
--                 output    = home_url( user_trailingslashit( permalink, "feed" ) );
--         end; else then
--                 if ( empty( feed ) ) then
--                         feed = get_default_feed();
--                 end;

--                 if ( false !== strpos( feed, "comments_" ) ) then
--                         feed = str_replace( "comments_", "comments-", feed );
--                 end;

--                 output = home_url( "?feed=thenfeedend;" );
--         end;

--         --
--         -- Filters the feed type permalink.
--         --
--         -- @since 1.5.0
--         --
--         -- @param string output The feed permalink.
--         -- @param string feed   The feed type. Possible values include "rss2", "atom",
--         --                       or an empty string for the default feed type.
--         --
--         return apply_filters( "feed_link", output, feed );
-- end;

-- --
-- -- Retrieves the permalink for the post comments feed.
-- --
-- -- @since 2.2.0
-- --
-- -- @param int    post_id Optional. Post ID. Default is the ID of the global `post`.
-- -- @param string feed    Optional. Feed type. Possible values include "rss2", "atom".
-- --                        Default is the value of get_default_feed().
-- -- @return string The permalink for the comments feed for the given post on success, empty string on failure.
-- --
-- function get_post_comments_feed_link( post_id = 0, feed = "" ) then
--         post_id = absint( post_id );

--         if ( ! post_id ) then
--                 post_id = get_the_ID();
--         end;

--         if ( empty( feed ) ) then
--                 feed = get_default_feed();
--         end;

--         post = get_post( post_id );

--         // Bail out if the post does not exist.
--         if ( ! post instanceof WP_Post ) then
--                 return "";
--         end;

--         unattached = "attachment" === post->post_type && 0 === (int) post->post_parent;

--         if ( get_option( "permalink_structure" ) ) then
--                 if ( "page" === get_option( "show_on_front" ) && get_option( "page_on_front" ) == post_id ) then
--                         url = _get_page_link( post_id );
--                 end; else then
--                         url = get_permalink( post_id );
--                 end;

--                 if ( unattached ) then
--                         url = home_url( "/feed/" );
--                         if ( get_default_feed() !== feed ) then
--                                 url .= "feed/";
--                         end;
--                         url = add_query_arg( "attachment_id", post_id, url );
--                 end; else then
--                         url = trailingslashit( url ) . "feed";
--                         if ( get_default_feed() != feed ) then
--                                 url .= "/feed";
--                         end;
--                         url = user_trailingslashit( url, "single_feed" );
--                 end;
--         end; else then
--                 if ( unattached ) then
--                         url = add_query_arg(
--                                 array(
--                                         "feed"          => feed,
--                                         "attachment_id" => post_id,
--                                 ),
--                                 home_url( "/" )
--                         );
--                 end; elseif ( "page" === post->post_type ) then
--                         url = add_query_arg(
--                                 array(
--                                         "feed"    => feed,
--                                         "page_id" => post_id,
--                                 ),
--                                 home_url( "/" )
--                         );
--                 end; else then
--                         url = add_query_arg(
--                                 array(
--                                         "feed" => feed,
--                                         "p"    => post_id,
--                                 ),
--                                 home_url( "/" )
--                         );
--                 end;
--         end;

--         --
--         -- Filters the post comments feed permalink.
--         --
--         -- @since 1.5.1
--         --
--         -- @param string url Post comments feed permalink.
--         --
--         return apply_filters( "post_comments_feed_link", url );
-- end;

-- --
-- -- Displays the comment feed link for a post.
-- --
-- -- Prints out the comment feed link for a post. Link text is placed in the
-- -- anchor. If no link text is specified, default text is used. If no post ID is
-- -- specified, the current post is used.
-- --
-- -- @since 2.5.0
-- --
-- -- @param string link_text Optional. Descriptive link text. Default "Comments Feed".
-- -- @param int    post_id   Optional. Post ID. Default is the ID of the global `post`.
-- -- @param string feed      Optional. Feed type. Possible values include "rss2", "atom".
-- --                          Default is the value of get_default_feed().
-- --
-- function post_comments_feed_link( link_text = "", post_id = "", feed = "" ) then
--         url = get_post_comments_feed_link( post_id, feed );
--         if ( empty( link_text ) ) then
--                 link_text = __( "Comments Feed" );
--         end;

--         link = "<a href="" . esc_url( url ) . "">" . link_text . "</a>";
--         --
--         -- Filters the post comment feed link anchor tag.
--         --
--         -- @since 2.8.0
--         --
--         -- @param string link    The complete anchor tag for the comment feed link.
--         -- @param int    post_id Post ID.
--         -- @param string feed    The feed type. Possible values include "rss2", "atom",
--         --                        or an empty string for the default feed type.
--         --
--         echo apply_filters( "post_comments_feed_link_html", link, post_id, feed );
-- end;

-- --
-- -- Retrieves the feed link for a given author.
-- --
-- -- Returns a link to the feed for all posts by a given author. A specific feed
-- -- can be requested or left blank to get the default feed.
-- --
-- -- @since 2.5.0
-- --
-- -- @param int    author_id Author ID.
-- -- @param string feed      Optional. Feed type. Possible values include "rss2", "atom".
-- --                          Default is the value of get_default_feed().
-- -- @return string Link to the feed for the author specified by author_id.
-- --
-- function get_author_feed_link( author_id, feed = "" ) then
--         author_id           = (int) author_id;
--         permalink_structure = get_option( "permalink_structure" );

--         if ( empty( feed ) ) then
--                 feed = get_default_feed();
--         end;

--         if ( ! permalink_structure ) then
--                 link = home_url( "?feed=feed&amp;author=" . author_id );
--         end; else then
--                 link = get_author_posts_url( author_id );
--                 if ( get_default_feed() == feed ) then
--                         feed_link = "feed";
--                 end; else then
--                         feed_link = "feed/feed";
--                 end;

--                 link = trailingslashit( link ) . user_trailingslashit( feed_link, "feed" );
--         end;

--         --
--         -- Filters the feed link for a given author.
--         --
--         -- @since 1.5.1
--         --
--         -- @param string link The author feed link.
--         -- @param string feed Feed type. Possible values include "rss2", "atom".
--         --
--         link = apply_filters( "author_feed_link", link, feed );

--         return link;
-- end;

-- --
-- -- Retrieves the feed link for a category.
-- --
-- -- Returns a link to the feed for all posts in a given category. A specific feed
-- -- can be requested or left blank to get the default feed.
-- --
-- -- @since 2.5.0
-- --
-- -- @param int|WP_Term|object cat  The ID or category object whose feed link will be retrieved.
-- -- @param string             feed Optional. Feed type. Possible values include "rss2", "atom".
-- --                                 Default is the value of get_default_feed().
-- -- @return string Link to the feed for the category specified by `cat`.
-- --
-- function get_category_feed_link( cat, feed = "" ) then
--         return get_term_feed_link( cat, "category", feed );
-- end;

-- --
-- -- Retrieves the feed link for a term.
-- --
-- -- Returns a link to the feed for all posts in a given term. A specific feed
-- -- can be requested or left blank to get the default feed.
-- --
-- -- @since 3.0.0
-- --
-- -- @param int|WP_Term|object term     The ID or term object whose feed link will be retrieved.
-- -- @param string             taxonomy Optional. Taxonomy of `term_id`.
-- -- @param string             feed     Optional. Feed type. Possible values include "rss2", "atom".
-- --                                     Default is the value of get_default_feed().
-- -- @return string|false Link to the feed for the term specified by `term` and `taxonomy`.
-- --
-- function get_term_feed_link( term, taxonomy = "", feed = "" ) then
--         if ( ! is_object( term ) ) then
--                 term = (int) term;
--         end;

--         term = get_term( term, taxonomy );

--         if ( empty( term ) || is_wp_error( term ) ) then
--                 return false;
--         end;

--         taxonomy = term->taxonomy;

--         if ( empty( feed ) ) then
--                 feed = get_default_feed();
--         end;

--         permalink_structure = get_option( "permalink_structure" );

--         if ( ! permalink_structure ) then
--                 if ( "category" === taxonomy ) then
--                         link = home_url( "?feed=feed&amp;cat=term->term_id" );
--                 end; elseif ( "post_tag" === taxonomy ) then
--                         link = home_url( "?feed=feed&amp;tag=term->slug" );
--                 end; else then
--                         t    = get_taxonomy( taxonomy );
--                         link = home_url( "?feed=feed&amp;t->query_var=term->slug" );
--                 end;
--         end; else then
--                 link = get_term_link( term, term->taxonomy );
--                 if ( get_default_feed() == feed ) then
--                         feed_link = "feed";
--                 end; else then
--                         feed_link = "feed/feed";
--                 end;

--                 link = trailingslashit( link ) . user_trailingslashit( feed_link, "feed" );
--         end;

--         if ( "category" === taxonomy ) then
--                 --
--                 -- Filters the category feed link.
--                 --
--                 -- @since 1.5.1
--                 --
--                 -- @param string link The category feed link.
--                 -- @param string feed Feed type. Possible values include "rss2", "atom".
--                 --
--                 link = apply_filters( "category_feed_link", link, feed );
--         end; elseif ( "post_tag" === taxonomy ) then
--                 --
--                 -- Filters the post tag feed link.
--                 --
--                 -- @since 2.3.0
--                 --
--                 -- @param string link The tag feed link.
--                 -- @param string feed Feed type. Possible values include "rss2", "atom".
--                 --
--                 link = apply_filters( "tag_feed_link", link, feed );
--         end; else then
--                 --
--                 -- Filters the feed link for a taxonomy other than "category" or "post_tag".
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param string link     The taxonomy feed link.
--                 -- @param string feed     Feed type. Possible values include "rss2", "atom".
--                 -- @param string taxonomy The taxonomy name.
--                 --
--                 link = apply_filters( "taxonomy_feed_link", link, feed, taxonomy );
--         end;

--         return link;
-- end;

-- --
-- -- Retrieves the permalink for a tag feed.
-- --
-- -- @since 2.3.0
-- --
-- -- @param int|WP_Term|object tag  The ID or term object whose feed link will be retrieved.
-- -- @param string             feed Optional. Feed type. Possible values include "rss2", "atom".
-- --                                 Default is the value of get_default_feed().
-- -- @return string                  The feed permalink for the given tag.
-- --
-- function get_tag_feed_link( tag, feed = "" ) then
--         return get_term_feed_link( tag, "post_tag", feed );
-- end;

-- --
-- -- Retrieves the edit link for a tag.
-- --
-- -- @since 2.7.0
-- --
-- -- @param int|WP_Term|object tag      The ID or term object whose edit link will be retrieved.
-- -- @param string             taxonomy Optional. Taxonomy slug. Default "post_tag".
-- -- @return string The edit tag link URL for the given tag.
-- --
-- function get_edit_tag_link( tag, taxonomy = "post_tag" ) then
--         --
--         -- Filters the edit link for a tag (or term in another taxonomy).
--         --
--         -- @since 2.7.0
--         --
--         -- @param string link The term edit link.
--         --
--         return apply_filters( "get_edit_tag_link", get_edit_term_link( tag, taxonomy ) );
-- end;

-- --
-- -- Displays or retrieves the edit link for a tag with formatting.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string  link   Optional. Anchor text. If empty, default is "Edit This". Default empty.
-- -- @param string  before Optional. Display before edit link. Default empty.
-- -- @param string  after  Optional. Display after edit link. Default empty.
-- -- @param WP_Term tag    Optional. Term object. If null, the queried object will be inspected.
-- --                        Default null.
-- --
-- function edit_tag_link( link = "", before = "", after = "", tag = null ) then
--         link = edit_term_link( link, "", "", tag, false );

--         --
--         -- Filters the anchor tag for the edit link for a tag (or term in another taxonomy).
--         --
--         -- @since 2.7.0
--         --
--         -- @param string link The anchor tag for the edit link.
--         --
--         echo before . apply_filters( "edit_tag_link", link ) . after;
-- end;

-- --
-- -- Retrieves the URL for editing a given term.
-- --
-- -- @since 3.1.0
-- -- @since 4.5.0 The `taxonomy` parameter was made optional.
-- --
-- -- @param int|WP_Term|object term        The ID or term object whose edit link will be retrieved.
-- -- @param string             taxonomy    Optional. Taxonomy. Defaults to the taxonomy of the term identified
-- --                                        by `term`.
-- -- @param string             object_type Optional. The object type. Used to highlight the proper post type
-- --                                        menu on the linked page. Defaults to the first object_type associated
-- --                                        with the taxonomy.
-- -- @return string|null The edit term link URL for the given term, or null on failure.
-- --
-- function get_edit_term_link( term, taxonomy = "", object_type = "" ) then
--         term = get_term( term, taxonomy );
--         if ( ! term || is_wp_error( term ) ) then
--                 return;
--         end;

--         tax     = get_taxonomy( term->taxonomy );
--         term_id = term->term_id;
--         if ( ! tax || ! current_user_can( "edit_term", term_id ) ) then
--                 return;
--         end;

--         args = array(
--                 "taxonomy" => taxonomy,
--                 "tag_ID"   => term_id,
--         );

--         if ( object_type ) then
--                 args["post_type"] = object_type;
--         end; elseif ( ! empty( tax->object_type ) ) then
--                 args["post_type"] = reset( tax->object_type );
--         end;

--         if ( tax->show_ui ) then
--                 location = add_query_arg( args, admin_url( "term.php" ) );
--         end; else then
--                 location = "";
--         end;

--         --
--         -- Filters the edit link for a term.
--         --
--         -- @since 3.1.0
--         --
--         -- @param string location    The edit link.
--         -- @param int    term_id     Term ID.
--         -- @param string taxonomy    Taxonomy name.
--         -- @param string object_type The object type.
--         --
--         return apply_filters( "get_edit_term_link", location, term_id, taxonomy, object_type );
-- end;

-- --
-- -- Displays or retrieves the edit term link with formatting.
-- --
-- -- @since 3.1.0
-- --
-- -- @param string           link   Optional. Anchor text. If empty, default is "Edit This". Default empty.
-- -- @param string           before Optional. Display before edit link. Default empty.
-- -- @param string           after  Optional. Display after edit link. Default empty.
-- -- @param int|WP_Term|null term   Optional. Term ID or object. If null, the queried object will be inspected. Default null.
-- -- @param bool             echo   Optional. Whether or not to echo the return. Default true.
-- -- @return string|void HTML content.
-- --
-- function edit_term_link( link = "", before = "", after = "", term = null, echo = true ) then
--         if ( is_null( term ) ) then
--                 term = get_queried_object();
--         end; else then
--                 term = get_term( term );
--         end;

--         if ( ! term ) then
--                 return;
--         end;

--         tax = get_taxonomy( term->taxonomy );
--         if ( ! current_user_can( "edit_term", term->term_id ) ) then
--                 return;
--         end;

--         if ( empty( link ) ) then
--                 link = __( "Edit This" );
--         end;

--         link = "<a href="" . get_edit_term_link( term->term_id, term->taxonomy ) . "">" . link . "</a>";

--         --
--         -- Filters the anchor tag for the edit link of a term.
--         --
--         -- @since 3.1.0
--         --
--         -- @param string link    The anchor tag for the edit link.
--         -- @param int    term_id Term ID.
--         --
--         link = before . apply_filters( "edit_term_link", link, term->term_id ) . after;

--         if ( echo ) then
--                 echo link;
--         end; else then
--                 return link;
--         end;
-- end;

-- --
-- -- Retrieves the permalink for a search.
-- --
-- -- @since 3.0.0
-- --
-- -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
-- --
-- -- @param string query Optional. The query string to use. If empty the current query is used. Default empty.
-- -- @return string The search permalink.
-- --
-- function get_search_link( query = "" ) then
--         global wp_rewrite;

--         if ( empty( query ) ) then
--                 search = get_search_query( false );
--         end; else then
--                 search = stripslashes( query );
--         end;

--         permastruct = wp_rewrite->get_search_permastruct();

--         if ( empty( permastruct ) ) then
--                 link = home_url( "?s=" . urlencode( search ) );
--         end; else then
--                 search = urlencode( search );
--                 search = str_replace( "%2F", "/", search ); // %2F(/) is not valid within a URL, send it un-encoded.
--                 link   = str_replace( "%search%", search, permastruct );
--                 link   = home_url( user_trailingslashit( link, "search" ) );
--         end;

--         --
--         -- Filters the search permalink.
--         --
--         -- @since 3.0.0
--         --
--         -- @param string link   Search permalink.
--         -- @param string search The URL-encoded search term.
--         --
--         return apply_filters( "search_link", link, search );
-- end;

-- --
-- -- Retrieves the permalink for the search results feed.
-- --
-- -- @since 2.5.0
-- --
-- -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
-- --
-- -- @param string search_query Optional. Search query. Default empty.
-- -- @param string feed         Optional. Feed type. Possible values include "rss2", "atom".
-- --                             Default is the value of get_default_feed().
-- -- @return string The search results feed permalink.
-- --
-- function get_search_feed_link( search_query = "", feed = "" ) then
--         global wp_rewrite;
--         link = get_search_link( search_query );

--         if ( empty( feed ) ) then
--                 feed = get_default_feed();
--         end;

--         permastruct = wp_rewrite->get_search_permastruct();

--         if ( empty( permastruct ) ) then
--                 link = add_query_arg( "feed", feed, link );
--         end; else then
--                 link  = trailingslashit( link );
--                 link .= "feed/feed/";
--         end;

--         --
--         -- Filters the search feed link.
--         --
--         -- @since 2.5.0
--         --
--         -- @param string link Search feed link.
--         -- @param string feed Feed type. Possible values include "rss2", "atom".
--         -- @param string type The search type. One of "posts" or "comments".
--         --
--         return apply_filters( "search_feed_link", link, feed, "posts" );
-- end;

-- --
-- -- Retrieves the permalink for the search results comments feed.
-- --
-- -- @since 2.5.0
-- --
-- -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
-- --
-- -- @param string search_query Optional. Search query. Default empty.
-- -- @param string feed         Optional. Feed type. Possible values include "rss2", "atom".
-- --                             Default is the value of get_default_feed().
-- -- @return string The comments feed search results permalink.
-- --
-- function get_search_comments_feed_link( search_query = "", feed = "" ) then
--         global wp_rewrite;

--         if ( empty( feed ) ) then
--                 feed = get_default_feed();
--         end;

--         link = get_search_feed_link( search_query, feed );

--         permastruct = wp_rewrite->get_search_permastruct();

--         if ( empty( permastruct ) ) then
--                 link = add_query_arg( "feed", "comments-" . feed, link );
--         end; else then
--                 link = add_query_arg( "withcomments", 1, link );
--         end;

--         -- This filter is documented in wp-includes/link-template.php--
--         return apply_filters( "search_feed_link", link, feed, "comments" );
-- end;

   --------------------------------
   -- Get_Post_Type_Archive_Link --
   --------------------------------

   function Get_Post_Type_Archive_Link (Post_Type : String)
                                        return String
   is
      use Ada.Strings.Unbounded;
      use Php.Types;
      use Hb_Common;
      use Inc_Class_Wp_Post_Type;
      use Inc_Class_Wp_Posts;
      use Inc_Plugins;
      use Inc_Options;
      use Inc_Posts;

      Post_Type_Obj : constant Wp_Post_Type := Get_Post_Type_Object (Post_Type);
      Link          : Unbounded_String;
   begin
      if Post_Type_Obj = Null_Post_Type then -- !
         return ""; -- false;
      end if;

      if "post" = Post_Type then
         declare
            Show_On_Front  : constant String  := Get_Option ("show_on_front");

            Page_For_Posts : constant Inc_Class_Wp_Posts.Post_Id :=
              Inc_Class_Wp_Posts.Post_Id (Integer'(Get_Option ("page_for_posts")));
         begin
            if "page" = Show_On_Front and then Page_For_Posts /= 0 then
               Link := +Get_Permalink (Page_For_Posts);
            else
               Link := +Get_Home_URL;
            end if;
            -- This filter is documented in wp-includes/link-template.php
            return Apply_Filters ("post_type_archive_link", -Link, Post_Type);
         end;
      end if;

      if not Post_Type_Obj.Has_Archive then
         return ""; -- False;
      end if;

      if
        Get_Option ("permalink_structure") and then
        Is_Array (Post_Type_Obj.Rewrite)
      then
         declare
            Struct : String :=
              (if Post_Type_Obj.Has_Archive
               then Get_As_String (Post_Type_Obj.Rewrite, "slug")
               else Post_Type_Obj.Has_Archive'Image); -- 'image added
         begin
            if Get_As_String (Post_Type_Obj.Rewrite, "with_front") /= "" then
               Struct := (-Global_Wp_Rewrite.Front) & Struct;
            else
               Struct := (-Global_Wp_Rewrite.Root) & Struct;
            end if;
            Link := +Home_URL (User_Trailing_Slash_It (Struct, "post_type_archive"));
         end;
      else
         Link := +Home_URL ("?post_type=" & Post_Type);
      end if;

      --
      -- Filters the post type archive permalink.
      --
      -- @since 3.1.0
      --
      -- @param string link      The post type archive permalink.
      -- @param string post_type Post type name.
      --
      return Apply_Filters ("post_type_archive_link", -Link, Post_Type);
   end Get_Post_Type_Archive_Link;

-- --
-- -- Retrieves the permalink for a post type archive feed.
-- --
-- -- @since 3.1.0
-- --
-- -- @param string post_type Post type.
-- -- @param string feed      Optional. Feed type. Possible values include "rss2", "atom".
-- --                          Default is the value of get_default_feed().
-- -- @return string|false The post type feed permalink. False if the post type
-- --                      does not exist or does not have an archive.
-- --
-- function get_post_type_archive_feed_link( post_type, feed = "" ) then
--         default_feed = get_default_feed();
--         if ( empty( feed ) ) then
--                 feed = default_feed;
--         end;

--         link = get_post_type_archive_link( post_type );
--         if ( ! link ) then
--                 return false;
--         end;

--         post_type_obj = get_post_type_object( post_type );
--         if ( get_option( "permalink_structure" ) && is_array( post_type_obj->rewrite ) && post_type_obj->rewrite["feeds"] ) then
--                 link  = trailingslashit( link );
--                 link .= "feed/";
--                 if ( feed != default_feed ) then
--                         link .= "feed/";
--                 end;
--         end; else then
--                 link = add_query_arg( "feed", feed, link );
--         end;

--         --
--         -- Filters the post type archive feed link.
--         --
--         -- @since 3.1.0
--         --
--         -- @param string link The post type archive feed link.
--         -- @param string feed Feed type. Possible values include "rss2", "atom".
--         --
--         return apply_filters( "post_type_archive_feed_link", link, feed );
-- end;

-- --
-- -- Retrieves the URL used for the post preview.
-- --
-- -- Allows additional query args to be appended.
-- --
-- -- @since 4.4.0
-- --
-- -- @param int|WP_Post post         Optional. Post ID or `WP_Post` object. Defaults to global `post`.
-- -- @param array       query_args   Optional. Array of additional query args to be appended to the link.
-- --                                  Default empty array.
-- -- @param string      preview_link Optional. Base preview link to be used if it should differ from the
-- --                                  post permalink. Default empty.
-- -- @return string|null URL used for the post preview, or null if the post does not exist.
-- --
-- function get_preview_post_link( post = null, query_args = array(), preview_link = "" ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return;
--         end;

--         post_type_object = get_post_type_object( post->post_type );
--         if ( is_post_type_viewable( post_type_object ) ) then
--                 if ( ! preview_link ) then
--                         preview_link = set_url_scheme( get_permalink( post ) );
--                 end;

--                 query_args["preview"] = "true";
--                 preview_link          = add_query_arg( query_args, preview_link );
--         end;

--         --
--         -- Filters the URL used for a post preview.
--         --
--         -- @since 2.0.5
--         -- @since 4.0.0 Added the `post` parameter.
--         --
--         -- @param string  preview_link URL used for the post preview.
--         -- @param WP_Post post         Post object.
--         --
--         return apply_filters( "preview_post_link", preview_link, post );
-- end;

-- --
-- -- Retrieves the edit post link for post.
-- --
-- -- Can be used within the WordPress loop or outside of it. Can be used with
-- -- pages, posts, attachments, and revisions.
-- --
-- -- @since 2.3.0
-- --
-- -- @param int|WP_Post post    Optional. Post ID or post object. Default is the global `post`.
-- -- @param string      context Optional. How to output the "&" character. Default "&amp;".
-- -- @return string|null The edit post link for the given post. Null if the post type does not exist
-- --                     or does not allow an editing UI.
-- --
-- function get_edit_post_link( post = 0, context = "display" ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return;
--         end;

--         if ( "revision" === post->post_type ) then
--                 action = "";
--         end; elseif ( "display" === context ) then
--                 action = "&amp;action=edit";
--         end; else then
--                 action = "&action=edit";
--         end;

--         post_type_object = get_post_type_object( post->post_type );

--         if ( ! post_type_object ) then
--                 return;
--         end;

--         if ( ! current_user_can( "edit_post", post->ID ) ) then
--                 return;
--         end;

--         if ( post_type_object->_edit_link ) then
--                 link = admin_url( sprintf( post_type_object->_edit_link . action, post->ID ) );
--         end; else then
--                 link = "";
--         end;

--         --
--         -- Filters the post edit link.
--         --
--         -- @since 2.3.0
--         --
--         -- @param string link    The edit link.
--         -- @param int    post_id Post ID.
--         -- @param string context The link context. If set to "display" then ampersands
--         --                        are encoded.
--         --
--         return apply_filters( "get_edit_post_link", link, post->ID, context );
-- end;

-- --
-- -- Displays the edit post link for post.
-- --
-- -- @since 1.0.0
-- -- @since 4.4.0 The `class` argument was added.
-- --
-- -- @param string      text   Optional. Anchor text. If null, default is "Edit This". Default null.
-- -- @param string      before Optional. Display before edit link. Default empty.
-- -- @param string      after  Optional. Display after edit link. Default empty.
-- -- @param int|WP_Post post   Optional. Post ID or post object. Default is the global `post`.
-- -- @param string      class  Optional. Add custom class to link. Default "post-edit-link".
-- --
-- function edit_post_link( text = null, before = "", after = "", post = 0, class = "post-edit-link" ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return;
--         end;

--         url = get_edit_post_link( post->ID );

--         if ( ! url ) then
--                 return;
--         end;

--         if ( null === text ) then
--                 text = __( "Edit This" );
--         end;

--         link = "<a class="" . esc_attr( class ) . "" href="" . esc_url( url ) . "">" . text . "</a>";

--         --
--         -- Filters the post edit link anchor tag.
--         --
--         -- @since 2.3.0
--         --
--         -- @param string link    Anchor tag for the edit link.
--         -- @param int    post_id Post ID.
--         -- @param string text    Anchor text.
--         --
--         echo before . apply_filters( "edit_post_link", link, post->ID, text ) . after;
-- end;

-- --
-- -- Retrieves the delete posts link for post.
-- --
-- -- Can be used within the WordPress loop or outside of it, with any post type.
-- --
-- -- @since 2.9.0
-- --
-- -- @param int|WP_Post post         Optional. Post ID or post object. Default is the global `post`.
-- -- @param string      deprecated   Not used.
-- -- @param bool        force_delete Optional. Whether to bypass Trash and force deletion. Default false.
-- -- @return string|void The delete post link URL for the given post.
-- --
-- function get_delete_post_link( post = 0, deprecated = "", force_delete = false ) then
--         if ( ! empty( deprecated ) ) then
--                 _deprecated_argument( __FUNCTION__, "3.0.0" );
--         end;

--         post = get_post( post );

--         if ( ! post ) then
--                 return;
--         end;

--         post_type_object = get_post_type_object( post->post_type );

--         if ( ! post_type_object ) then
--                 return;
--         end;

--         if ( ! current_user_can( "delete_post", post->ID ) ) then
--                 return;
--         end;

--         action = ( force_delete || ! EMPTY_TRASH_DAYS ) ? "delete" : "trash";

--         delete_link = add_query_arg( "action", action, admin_url( sprintf( post_type_object->_edit_link, post->ID ) ) );

--         --
--         -- Filters the post delete link.
--         --
--         -- @since 2.9.0
--         --
--         -- @param string link         The delete link.
--         -- @param int    post_id      Post ID.
--         -- @param bool   force_delete Whether to bypass the Trash and force deletion. Default false.
--         --
--         return apply_filters( "get_delete_post_link", wp_nonce_url( delete_link, "action-post_thenpost->IDend;" ), post->ID, force_delete );
-- end;

-- --
-- -- Retrieves the edit comment link.
-- --
-- -- @since 2.3.0
-- --
-- -- @param int|WP_Comment comment_id Optional. Comment ID or WP_Comment object.
-- -- @return string|void The edit comment link URL for the given comment.
-- --
-- function get_edit_comment_link( comment_id = 0 ) then
--         comment = get_comment( comment_id );

--         if ( ! current_user_can( "edit_comment", comment->comment_ID ) ) then
--                 return;
--         end;

--         location = admin_url( "comment.php?action=editcomment&amp;c=" ) . comment->comment_ID;

--         --
--         -- Filters the comment edit link.
--         --
--         -- @since 2.3.0
--         --
--         -- @param string location The edit link.
--         --
--         return apply_filters( "get_edit_comment_link", location );
-- end;

-- --
-- -- Displays the edit comment link with formatting.
-- --
-- -- @since 1.0.0
-- --
-- -- @param string text   Optional. Anchor text. If null, default is "Edit This". Default null.
-- -- @param string before Optional. Display before edit link. Default empty.
-- -- @param string after  Optional. Display after edit link. Default empty.
-- --
-- function edit_comment_link( text = null, before = "", after = "" ) then
--         comment = get_comment();

--         if ( ! current_user_can( "edit_comment", comment->comment_ID ) ) then
--                 return;
--         end;

--         if ( null === text ) then
--                 text = __( "Edit This" );
--         end;

--         link = "<a class="comment-edit-link" href="" . esc_url( get_edit_comment_link( comment ) ) . "">" . text . "</a>";

--         --
--         -- Filters the comment edit link anchor tag.
--         --
--         -- @since 2.3.0
--         --
--         -- @param string link       Anchor tag for the edit link.
--         -- @param string comment_id Comment ID as a numeric string.
--         -- @param string text       Anchor text.
--         --
--         echo before . apply_filters( "edit_comment_link", link, comment->comment_ID, text ) . after;
-- end;

-- --
-- -- Displays the edit bookmark link.
-- --
-- -- @since 2.7.0
-- --
-- -- @param int|stdClass link Optional. Bookmark ID. Default is the ID of the current bookmark.
-- -- @return string|void The edit bookmark link URL.
-- --
-- function get_edit_bookmark_link( link = 0 ) then
--         link = get_bookmark( link );

--         if ( ! current_user_can( "manage_links" ) ) then
--                 return;
--         end;

--         location = admin_url( "link.php?action=edit&amp;link_id=" ) . link->link_id;

--         --
--         -- Filters the bookmark edit link.
--         --
--         -- @since 2.7.0
--         --
--         -- @param string location The edit link.
--         -- @param int    link_id  Bookmark ID.
--         --
--         return apply_filters( "get_edit_bookmark_link", location, link->link_id );
-- end;

-- --
-- -- Displays the edit bookmark link anchor content.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string link     Optional. Anchor text. If empty, default is "Edit This". Default empty.
-- -- @param string before   Optional. Display before edit link. Default empty.
-- -- @param string after    Optional. Display after edit link. Default empty.
-- -- @param int    bookmark Optional. Bookmark ID. Default is the current bookmark.
-- --
-- function edit_bookmark_link( link = "", before = "", after = "", bookmark = null ) then
--         bookmark = get_bookmark( bookmark );

--         if ( ! current_user_can( "manage_links" ) ) then
--                 return;
--         end;

--         if ( empty( link ) ) then
--                 link = __( "Edit This" );
--         end;

--         link = "<a href="" . esc_url( get_edit_bookmark_link( bookmark ) ) . "">" . link . "</a>";

--         --
--         -- Filters the bookmark edit link anchor tag.
--         --
--         -- @since 2.7.0
--         --
--         -- @param string link    Anchor tag for the edit link.
--         -- @param int    link_id Bookmark ID.
--         --
--         echo before . apply_filters( "edit_bookmark_link", link, bookmark->link_id ) . after;
-- end;

-- --
-- -- Retrieves the edit user link.
-- --
-- -- @since 3.5.0
-- --
-- -- @param int user_id Optional. User ID. Defaults to the current user.
-- -- @return string URL to edit user page or empty string.
-- --
-- function get_edit_user_link( user_id = null ) then
--         if ( ! user_id ) then
--                 user_id = get_current_user_id();
--         end;

--         if ( empty( user_id ) || ! current_user_can( "edit_user", user_id ) ) then
--                 return "";
--         end;

--         user = get_userdata( user_id );

--         if ( ! user ) then
--                 return "";
--         end;

--         if ( get_current_user_id() == user->ID ) then
--                 link = get_edit_profile_url( user->ID );
--         end; else then
--                 link = add_query_arg( "user_id", user->ID, self_admin_url( "user-edit.php" ) );
--         end;

--         --
--         -- Filters the user edit link.
--         --
--         -- @since 3.5.0
--         --
--         -- @param string link    The edit link.
--         -- @param int    user_id User ID.
--         --
--         return apply_filters( "get_edit_user_link", link, user->ID );
-- end;

-- //
-- // Navigation links.
-- //

-- --
-- -- Retrieves the previous post that is adjacent to the current post.
-- --
-- -- @since 1.5.0
-- --
-- -- @param bool         in_same_term   Optional. Whether post should be in a same taxonomy term. Default false.
-- -- @param int[]|string excluded_terms Optional. Array or comma-separated list of excluded term IDs. Default empty.
-- -- @param string       taxonomy       Optional. Taxonomy, if in_same_term is true. Default "category".
-- -- @return WP_Post|null|string Post object if successful. Null if global post is not set. Empty string if no
-- --                             corresponding post exists.
-- --
-- function get_previous_post( in_same_term = false, excluded_terms = "", taxonomy = "category" ) then
--         return get_adjacent_post( in_same_term, excluded_terms, true, taxonomy );
-- end;

-- --
-- -- Retrieves the next post that is adjacent to the current post.
-- --
-- -- @since 1.5.0
-- --
-- -- @param bool         in_same_term   Optional. Whether post should be in a same taxonomy term. Default false.
-- -- @param int[]|string excluded_terms Optional. Array or comma-separated list of excluded term IDs. Default empty.
-- -- @param string       taxonomy       Optional. Taxonomy, if in_same_term is true. Default "category".
-- -- @return WP_Post|null|string Post object if successful. Null if global post is not set. Empty string if no
-- --                             corresponding post exists.
-- --
-- function get_next_post( in_same_term = false, excluded_terms = "", taxonomy = "category" ) then
--         return get_adjacent_post( in_same_term, excluded_terms, false, taxonomy );
-- end;

-- --
-- -- Retrieves the adjacent post.
-- --
-- -- Can either be next or previous post.
-- --
-- -- @since 2.5.0
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param bool         in_same_term   Optional. Whether post should be in a same taxonomy term. Default false.
-- -- @param int[]|string excluded_terms Optional. Array or comma-separated list of excluded term IDs. Default empty string.
-- -- @param bool         previous       Optional. Whether to retrieve previous post. Default true
-- -- @param string       taxonomy       Optional. Taxonomy, if in_same_term is true. Default "category".
-- -- @return WP_Post|null|string Post object if successful. Null if global post is not set. Empty string if no
-- --                             corresponding post exists.
-- --
-- function get_adjacent_post( in_same_term = false, excluded_terms = "", previous = true, taxonomy = "category" ) then
--         global wpdb;

--         post = get_post();

--         if ( ! post || ! taxonomy_exists( taxonomy ) ) then
--                 return null;
--         end;

--         current_post_date = post->post_date;

--         join     = "";
--         where    = "";
--         adjacent = previous ? "previous" : "next";

--         if ( ! empty( excluded_terms ) && ! is_array( excluded_terms ) ) then
--                 // Back-compat, excluded_terms used to be excluded_categories with IDs separated by " and ".
--                 if ( false !== strpos( excluded_terms, " and " ) ) then
--                         _deprecated_argument(
--                                 __FUNCTION__,
--                                 "3.3.0",
--                                 sprintf(
--                                         /* translators: %s: The word "and".--
--                                         __( "Use commas instead of %s to separate excluded terms." ),
--                                         ""and""
--                                 )
--                         );
--                         excluded_terms = explode( " and ", excluded_terms );
--                 end; else then
--                         excluded_terms = explode( ",", excluded_terms );
--                 end;

--                 excluded_terms = array_map( "intval", excluded_terms );
--         end;

--         --
--         -- Filters the IDs of terms excluded from adjacent post queries.
--         --
--         -- The dynamic portion of the hook name, `adjacent`, refers to the type
--         -- of adjacency, "next" or "previous".
--         --
--         -- Possible hook names include:
--         --
--         --  - `get_next_post_excluded_terms`
--         --  - `get_previous_post_excluded_terms`
--         --
--         -- @since 4.4.0
--         --
--         -- @param int[]|string excluded_terms Array of excluded term IDs. Empty string if none were provided.
--         --
--         excluded_terms = apply_filters( "get_thenadjacentend;_post_excluded_terms", excluded_terms );

--         if ( in_same_term || ! empty( excluded_terms ) ) then
--                 if ( in_same_term ) then
--                         join  .= " INNER JOIN wpdb->term_relationships AS tr ON p.ID = tr.object_id INNER JOIN wpdb->term_taxonomy AS tt ON tr.term_taxonomy_id = tt.term_taxonomy_id";
--                         where .= wpdb->prepare( "AND tt.taxonomy = %s", taxonomy );

--                         if ( ! is_object_in_taxonomy( post->post_type, taxonomy ) ) then
--                                 return "";
--                         end;
--                         term_array = wp_get_object_terms( post->ID, taxonomy, array( "fields" => "ids" ) );

--                         // Remove any exclusions from the term array to include.
--                         term_array = array_diff( term_array, (array) excluded_terms );
--                         term_array = array_map( "intval", term_array );

--                         if ( ! term_array || is_wp_error( term_array ) ) then
--                                 return "";
--                         end;

--                         where .= " AND tt.term_id IN (" . implode( ",", term_array ) . ")";
--                 end;

--                 if ( ! empty( excluded_terms ) ) then
--                         where .= " AND p.ID NOT IN ( SELECT tr.object_id FROM wpdb->term_relationships tr LEFT JOIN wpdb->term_taxonomy tt ON (tr.term_taxonomy_id = tt.term_taxonomy_id) WHERE tt.term_id IN (" . implode( ",", array_map( "intval", excluded_terms ) ) . ") )";
--                 end;
--         end;

--         // "post_status" clause depends on the current user.
--         if ( is_user_logged_in() ) then
--                 user_id = get_current_user_id();

--                 post_type_object = get_post_type_object( post->post_type );
--                 if ( empty( post_type_object ) ) then
--                         post_type_cap    = post->post_type;
--                         read_private_cap = "read_private_" . post_type_cap . "s";
--                 end; else then
--                         read_private_cap = post_type_object->cap->read_private_posts;
--                 end;

--                 /*
--                 -- Results should include private posts belonging to the current user, or private posts where the
--                 -- current user has the "read_private_posts" cap.
--                 --
--                 private_states = get_post_stati( array( "private" => true ) );
--                 where         .= " AND ( p.post_status = "publish"";
--                 foreach ( private_states as state ) then
--                         if ( current_user_can( read_private_cap ) ) then
--                                 where .= wpdb->prepare( " OR p.post_status = %s", state );
--                         end; else then
--                                 where .= wpdb->prepare( " OR (p.post_author = %d AND p.post_status = %s)", user_id, state );
--                         end;
--                 end;
--                 where .= " )";
--         end; else then
--                 where .= " AND p.post_status = "publish"";
--         end;

--         op    = previous ? "<" : ">";
--         order = previous ? "DESC" : "ASC";

--         --
--         -- Filters the JOIN clause in the SQL for an adjacent post query.
--         --
--         -- The dynamic portion of the hook name, `adjacent`, refers to the type
--         -- of adjacency, "next" or "previous".
--         --
--         -- Possible hook names include:
--         --
--         --  - `get_next_post_join`
--         --  - `get_previous_post_join`
--         --
--         -- @since 2.5.0
--         -- @since 4.4.0 Added the `taxonomy` and `post` parameters.
--         --
--         -- @param string       join           The JOIN clause in the SQL.
--         -- @param bool         in_same_term   Whether post should be in a same taxonomy term.
--         -- @param int[]|string excluded_terms Array of excluded term IDs. Empty string if none were provided.
--         -- @param string       taxonomy       Taxonomy. Used to identify the term used when `in_same_term` is true.
--         -- @param WP_Post      post           WP_Post object.
--         --
--         join = apply_filters( "get_thenadjacentend;_post_join", join, in_same_term, excluded_terms, taxonomy, post );

--         --
--         -- Filters the WHERE clause in the SQL for an adjacent post query.
--         --
--         -- The dynamic portion of the hook name, `adjacent`, refers to the type
--         -- of adjacency, "next" or "previous".
--         --
--         -- Possible hook names include:
--         --
--         --  - `get_next_post_where`
--         --  - `get_previous_post_where`
--         --
--         -- @since 2.5.0
--         -- @since 4.4.0 Added the `taxonomy` and `post` parameters.
--         --
--         -- @param string       where          The `WHERE` clause in the SQL.
--         -- @param bool         in_same_term   Whether post should be in a same taxonomy term.
--         -- @param int[]|string excluded_terms Array of excluded term IDs. Empty string if none were provided.
--         -- @param string       taxonomy       Taxonomy. Used to identify the term used when `in_same_term` is true.
--         -- @param WP_Post      post           WP_Post object.
--         --
--         where = apply_filters( "get_thenadjacentend;_post_where", wpdb->prepare( "WHERE p.post_date op %s AND p.post_type = %s where", current_post_date, post->post_type ), in_same_term, excluded_terms, taxonomy, post );

--         --
--         -- Filters the ORDER BY clause in the SQL for an adjacent post query.
--         --
--         -- The dynamic portion of the hook name, `adjacent`, refers to the type
--         -- of adjacency, "next" or "previous".
--         --
--         -- Possible hook names include:
--         --
--         --  - `get_next_post_sort`
--         --  - `get_previous_post_sort`
--         --
--         -- @since 2.5.0
--         -- @since 4.4.0 Added the `post` parameter.
--         -- @since 4.9.0 Added the `order` parameter.
--         --
--         -- @param string order_by The `ORDER BY` clause in the SQL.
--         -- @param WP_Post post    WP_Post object.
--         -- @param string  order   Sort order. "DESC" for previous post, "ASC" for next.
--         --
--         sort = apply_filters( "get_thenadjacentend;_post_sort", "ORDER BY p.post_date order LIMIT 1", post, order );

--         query     = "SELECT p.ID FROM wpdb->posts AS p join where sort";
--         query_key = "adjacent_post_" . md5( query );
--         result    = wp_cache_get( query_key, "counts" );
--         if ( false !== result ) then
--                 if ( result ) then
--                         result = get_post( result );
--                 end;
--                 return result;
--         end;

--         result = wpdb->get_var( query );
--         if ( null === result ) then
--                 result = "";
--         end;

--         wp_cache_set( query_key, result, "counts" );

--         if ( result ) then
--                 result = get_post( result );
--         end;

--         return result;
-- end;

-- --
-- -- Retrieves the adjacent post relational link.
-- --
-- -- Can either be next or previous post relational link.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string       title          Optional. Link title format. Default "%title".
-- -- @param bool         in_same_term   Optional. Whether link should be in a same taxonomy term. Default false.
-- -- @param int[]|string excluded_terms Optional. Array or comma-separated list of excluded term IDs. Default empty.
-- -- @param bool         previous       Optional. Whether to display link to previous or next post. Default true.
-- -- @param string       taxonomy       Optional. Taxonomy, if in_same_term is true. Default "category".
-- -- @return string|void The adjacent post relational link URL.
-- --
-- function get_adjacent_post_rel_link( title = "%title", in_same_term = false, excluded_terms = "", previous = true, taxonomy = "category" ) then
--         post = get_post();
--         if ( previous && is_attachment() && post ) then
--                 post = get_post( post->post_parent );
--         end; else then
--                 post = get_adjacent_post( in_same_term, excluded_terms, previous, taxonomy );
--         end;

--         if ( empty( post ) ) then
--                 return;
--         end;

--         post_title = the_title_attribute(
--                 array(
--                         "echo" => false,
--                         "post" => post,
--                 )
--         );

--         if ( empty( post_title ) ) then
--                 post_title = previous ? __( "Previous Post" ) : __( "Next Post" );
--         end;

--         date = mysql2date( get_option( "date_format" ), post->post_date );

--         title = str_replace( "%title", post_title, title );
--         title = str_replace( "%date", date, title );

--         link  = previous ? "<link rel="prev" title="" : "<link rel="next" title="";
--         link .= esc_attr( title );
--         link .= "" href="" . get_permalink( post ) . "" />\n";

--         adjacent = previous ? "previous" : "next";

--         --
--         -- Filters the adjacent post relational link.
--         --
--         -- The dynamic portion of the hook name, `adjacent`, refers to the type
--         -- of adjacency, "next" or "previous".
--         --
--         -- Possible hook names include:
--         --
--         --  - `next_post_rel_link`
--         --  - `previous_post_rel_link`
--         --
--         -- @since 2.8.0
--         --
--         -- @param string link The relational link.
--         --
--         return apply_filters( "thenadjacentend;_post_rel_link", link );
-- end;

-- --
-- -- Displays the relational links for the posts adjacent to the current post.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string       title          Optional. Link title format. Default "%title".
-- -- @param bool         in_same_term   Optional. Whether link should be in a same taxonomy term. Default false.
-- -- @param int[]|string excluded_terms Optional. Array or comma-separated list of excluded term IDs. Default empty.
-- -- @param string       taxonomy       Optional. Taxonomy, if in_same_term is true. Default "category".
-- --
-- function adjacent_posts_rel_link( title = "%title", in_same_term = false, excluded_terms = "", taxonomy = "category" ) then
--         echo get_adjacent_post_rel_link( title, in_same_term, excluded_terms, true, taxonomy );
--         echo get_adjacent_post_rel_link( title, in_same_term, excluded_terms, false, taxonomy );
-- end;

-- --
-- -- Displays relational links for the posts adjacent to the current post for single post pages.
-- --
-- -- This is meant to be attached to actions like "wp_head". Do not call this directly in plugins
-- -- or theme templates.
-- --
-- -- @since 3.0.0
-- -- @since 5.6.0 No longer used in core.
-- --
-- -- @see adjacent_posts_rel_link()
-- --
-- function adjacent_posts_rel_link_wp_head() then
--         if ( ! is_single() || is_attachment() ) then
--                 return;
--         end;
--         adjacent_posts_rel_link();
-- end;

-- --
-- -- Displays the relational link for the next post adjacent to the current post.
-- --
-- -- @since 2.8.0
-- --
-- -- @see get_adjacent_post_rel_link()
-- --
-- -- @param string       title          Optional. Link title format. Default "%title".
-- -- @param bool         in_same_term   Optional. Whether link should be in a same taxonomy term. Default false.
-- -- @param int[]|string excluded_terms Optional. Array or comma-separated list of excluded term IDs. Default empty.
-- -- @param string       taxonomy       Optional. Taxonomy, if in_same_term is true. Default "category".
-- --
-- function next_post_rel_link( title = "%title", in_same_term = false, excluded_terms = "", taxonomy = "category" ) then
--         echo get_adjacent_post_rel_link( title, in_same_term, excluded_terms, false, taxonomy );
-- end;

-- --
-- -- Displays the relational link for the previous post adjacent to the current post.
-- --
-- -- @since 2.8.0
-- --
-- -- @see get_adjacent_post_rel_link()
-- --
-- -- @param string       title          Optional. Link title format. Default "%title".
-- -- @param bool         in_same_term   Optional. Whether link should be in a same taxonomy term. Default false.
-- -- @param int[]|string excluded_terms Optional. Array or comma-separated list of excluded term IDs. Default true.
-- -- @param string       taxonomy       Optional. Taxonomy, if in_same_term is true. Default "category".
-- --
-- function prev_post_rel_link( title = "%title", in_same_term = false, excluded_terms = "", taxonomy = "category" ) then
--         echo get_adjacent_post_rel_link( title, in_same_term, excluded_terms, true, taxonomy );
-- end;

-- --
-- -- Retrieves the boundary post.
-- --
-- -- Boundary being either the first or last post by publish date within the constraints specified
-- -- by in_same_term or excluded_terms.
-- --
-- -- @since 2.8.0
-- --
-- -- @param bool         in_same_term   Optional. Whether returned post should be in a same taxonomy term.
-- --                                     Default false.
-- -- @param int[]|string excluded_terms Optional. Array or comma-separated list of excluded term IDs.
-- --                                     Default empty.
-- -- @param bool         start          Optional. Whether to retrieve first or last post. Default true
-- -- @param string       taxonomy       Optional. Taxonomy, if in_same_term is true. Default "category".
-- -- @return null|array Array containing the boundary post object if successful, null otherwise.
-- --
-- function get_boundary_post( in_same_term = false, excluded_terms = "", start = true, taxonomy = "category" ) then
--         post = get_post();

--         if ( ! post || ! is_single() || is_attachment() || ! taxonomy_exists( taxonomy ) ) then
--                 return null;
--         end;

--         query_args = array(
--                 "posts_per_page"         => 1,
--                 "order"                  => start ? "ASC" : "DESC",
--                 "update_post_term_cache" => false,
--                 "update_post_meta_cache" => false,
--         );

--         term_array = array();

--         if ( ! is_array( excluded_terms ) ) then
--                 if ( ! empty( excluded_terms ) ) then
--                         excluded_terms = explode( ",", excluded_terms );
--                 end; else then
--                         excluded_terms = array();
--                 end;
--         end;

--         if ( in_same_term || ! empty( excluded_terms ) ) then
--                 if ( in_same_term ) then
--                         term_array = wp_get_object_terms( post->ID, taxonomy, array( "fields" => "ids" ) );
--                 end;

--                 if ( ! empty( excluded_terms ) ) then
--                         excluded_terms = array_map( "intval", excluded_terms );
--                         excluded_terms = array_diff( excluded_terms, term_array );

--                         inverse_terms = array();
--                         foreach ( excluded_terms as excluded_term ) then
--                                 inverse_terms[] = excluded_term-- -1;
--                         end;
--                         excluded_terms = inverse_terms;
--                 end;

--                 query_args["tax_query"] = array(
--                         array(
--                                 "taxonomy" => taxonomy,
--                                 "terms"    => array_merge( term_array, excluded_terms ),
--                         ),
--                 );
--         end;

--         return get_posts( query_args );
-- end;

-- --
-- -- Retrieves the previous post link that is adjacent to the current post.
-- --
-- -- @since 3.7.0
-- --
-- -- @param string       format         Optional. Link anchor format. Default "&laquo; %link".
-- -- @param string       link           Optional. Link permalink format. Default "%title".
-- -- @param bool         in_same_term   Optional. Whether link should be in a same taxonomy term. Default false.
-- -- @param int[]|string excluded_terms Optional. Array or comma-separated list of excluded term IDs. Default empty.
-- -- @param string       taxonomy       Optional. Taxonomy, if in_same_term is true. Default "category".
-- -- @return string The link URL of the previous post in relation to the current post.
-- --
-- function get_previous_post_link( format = "&laquo; %link", link = "%title", in_same_term = false, excluded_terms = "", taxonomy = "category" ) then
--         return get_adjacent_post_link( format, link, in_same_term, excluded_terms, true, taxonomy );
-- end;

-- --
-- -- Displays the previous post link that is adjacent to the current post.
-- --
-- -- @since 1.5.0
-- --
-- -- @see get_previous_post_link()
-- --
-- -- @param string       format         Optional. Link anchor format. Default "&laquo; %link".
-- -- @param string       link           Optional. Link permalink format. Default "%title".
-- -- @param bool         in_same_term   Optional. Whether link should be in a same taxonomy term. Default false.
-- -- @param int[]|string excluded_terms Optional. Array or comma-separated list of excluded term IDs. Default empty.
-- -- @param string       taxonomy       Optional. Taxonomy, if in_same_term is true. Default "category".
-- --
-- function previous_post_link( format = "&laquo; %link", link = "%title", in_same_term = false, excluded_terms = "", taxonomy = "category" ) then
--         echo get_previous_post_link( format, link, in_same_term, excluded_terms, taxonomy );
-- end;

-- --
-- -- Retrieves the next post link that is adjacent to the current post.
-- --
-- -- @since 3.7.0
-- --
-- -- @param string       format         Optional. Link anchor format. Default "&laquo; %link".
-- -- @param string       link           Optional. Link permalink format. Default "%title".
-- -- @param bool         in_same_term   Optional. Whether link should be in a same taxonomy term. Default false.
-- -- @param int[]|string excluded_terms Optional. Array or comma-separated list of excluded term IDs. Default empty.
-- -- @param string       taxonomy       Optional. Taxonomy, if in_same_term is true. Default "category".
-- -- @return string The link URL of the next post in relation to the current post.
-- --
-- function get_next_post_link( format = "%link &raquo;", link = "%title", in_same_term = false, excluded_terms = "", taxonomy = "category" ) then
--         return get_adjacent_post_link( format, link, in_same_term, excluded_terms, false, taxonomy );
-- end;

-- --
-- -- Displays the next post link that is adjacent to the current post.
-- --
-- -- @since 1.5.0
-- --
-- -- @see get_next_post_link()
-- --
-- -- @param string       format         Optional. Link anchor format. Default "&laquo; %link".
-- -- @param string       link           Optional. Link permalink format. Default "%title"
-- -- @param bool         in_same_term   Optional. Whether link should be in a same taxonomy term. Default false.
-- -- @param int[]|string excluded_terms Optional. Array or comma-separated list of excluded term IDs. Default empty.
-- -- @param string       taxonomy       Optional. Taxonomy, if in_same_term is true. Default "category".
-- --
-- function next_post_link( format = "%link &raquo;", link = "%title", in_same_term = false, excluded_terms = "", taxonomy = "category" ) then
--         echo get_next_post_link( format, link, in_same_term, excluded_terms, taxonomy );
-- end;

-- --
-- -- Retrieves the adjacent post link.
-- --
-- -- Can be either next post link or previous.
-- --
-- -- @since 3.7.0
-- --
-- -- @param string       format         Link anchor format.
-- -- @param string       link           Link permalink format.
-- -- @param bool         in_same_term   Optional. Whether link should be in a same taxonomy term. Default false.
-- -- @param int[]|string excluded_terms Optional. Array or comma-separated list of excluded terms IDs. Default empty.
-- -- @param bool         previous       Optional. Whether to display link to previous or next post. Default true.
-- -- @param string       taxonomy       Optional. Taxonomy, if in_same_term is true. Default "category".
-- -- @return string The link URL of the previous or next post in relation to the current post.
-- --
-- function get_adjacent_post_link( format, link, in_same_term = false, excluded_terms = "", previous = true, taxonomy = "category" ) then
--         if ( previous && is_attachment() ) then
--                 post = get_post( get_post()->post_parent );
--         end; else then
--                 post = get_adjacent_post( in_same_term, excluded_terms, previous, taxonomy );
--         end;

--         if ( ! post ) then
--                 output = "";
--         end; else then
--                 title = post->post_title;

--                 if ( empty( post->post_title ) ) then
--                         title = previous ? __( "Previous Post" ) : __( "Next Post" );
--                 end;

--                 -- This filter is documented in wp-includes/post-template.php--
--                 title = apply_filters( "the_title", title, post->ID );

--                 date = mysql2date( get_option( "date_format" ), post->post_date );
--                 rel  = previous ? "prev" : "next";

--                 string = "<a href="" . get_permalink( post ) . "" rel="" . rel . "">";
--                 inlink = str_replace( "%title", title, link );
--                 inlink = str_replace( "%date", date, inlink );
--                 inlink = string . inlink . "</a>";

--                 output = str_replace( "%link", inlink, format );
--         end;

--         adjacent = previous ? "previous" : "next";

--         --
--         -- Filters the adjacent post link.
--         --
--         -- The dynamic portion of the hook name, `adjacent`, refers to the type
--         -- of adjacency, "next" or "previous".
--         --
--         -- Possible hook names include:
--         --
--         --  - `next_post_link`
--         --  - `previous_post_link`
--         --
--         -- @since 2.6.0
--         -- @since 4.2.0 Added the `adjacent` parameter.
--         --
--         -- @param string  output   The adjacent post link.
--         -- @param string  format   Link anchor format.
--         -- @param string  link     Link permalink format.
--         -- @param WP_Post post     The adjacent post.
--         -- @param string  adjacent Whether the post is previous or next.
--         --
--         return apply_filters( "thenadjacentend;_post_link", output, format, link, post, adjacent );
-- end;

-- --
-- -- Displays the adjacent post link.
-- --
-- -- Can be either next post link or previous.
-- --
-- -- @since 2.5.0
-- --
-- -- @param string       format         Link anchor format.
-- -- @param string       link           Link permalink format.
-- -- @param bool         in_same_term   Optional. Whether link should be in a same taxonomy term. Default false.
-- -- @param int[]|string excluded_terms Optional. Array or comma-separated list of excluded category IDs. Default empty.
-- -- @param bool         previous       Optional. Whether to display link to previous or next post. Default true.
-- -- @param string       taxonomy       Optional. Taxonomy, if in_same_term is true. Default "category".
-- --
-- function adjacent_post_link( format, link, in_same_term = false, excluded_terms = "", previous = true, taxonomy = "category" ) then
--         echo get_adjacent_post_link( format, link, in_same_term, excluded_terms, previous, taxonomy );
-- end;

   ----------------------
   -- Get_Pagenum_Link --
   ----------------------

   function Get_Pagenum_Link (Pagenum : Integer := 1;
                              Escape  : Boolean := True)
                              return String
   is
      use Ada.Containers;
      use Ada.Strings.Unbounded;
      use Php.HTML;
      use Php.Preg;
      use Php.Strings;
      use Hb_Common;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_Load;
      use Inc_Plugins;
--    global wp_rewrite;

--    pagenum = (int) pagenum;

      Request_1 : constant String := Remove_Query_Arg ("paged");

      Home_Root_1 : constant Array_Type := Parse_URL (Home_URL);

      Home_Root_2 : constant String :=
        (if Isset (Home_Root_1, "path")
         then Get_As_String (Home_Root_1, "path") else "");

      Home_Root : constant String := Preg_Quote (Home_Root_2, "|");

      Request_2 : constant String :=
        Preg_Replace ("|^" & Home_Root & "|i", "", Request_1);

      Request   : String := Preg_Replace ("|^/+|", "", Request_2);

      Result : Unbounded_String;
   begin
      if
        not Global_Wp_Rewrite.Using_Permalinks or else
        Is_Admin
      then
         declare
            Base : constant String :=
              Trailing_Slash_It (Get_Bloginfo ("url"));
         begin
            if Pagenum > 1 then
               Result :=
                 +Add_Query_Arg ("paged", Helpers.Image (Pagenum), Base & Request);
            else
               Result := +(Base & Request);
            end if;
         end;
      else
         declare
            Qs_Regex : constant String := "|\?.*?|";
            Qs_Match : List_Type;
            Query_String : Unbounded_String;
         begin
            Preg_Match (Qs_Regex, Request, Qs_Match);

            if Qs_Match.Length >= 1 then
--          if ( ! empty( qs_match[0] ) ) then
               Query_String := Qs_Match (1); -- [0];
               Request      := Preg_Replace (Qs_Regex, "", Request);
            else
               Query_String := +"";
            end if;

            declare
               Request_4 : constant String :=
                 Preg_Replace ("|" & (-Global_Wp_Rewrite.Pagination_Base) & "/\d+/?|",
                               "", Request);

               Request_5 : constant String :=
                 Preg_Replace
                   ("|^" & Preg_Quote (-Global_Wp_Rewrite.Index, "|") & "|i",
                    "", Request_4);

               Request_6 : constant String := Ltrim (Request_5, "/");

               Base : Unbounded_String := +Trailing_Slash_It (Get_Bloginfo ("url"));

               Request_7 : Unbounded_String;
            begin
               if
                 Global_Wp_Rewrite.Using_Index_Permalinks and then
                 (Pagenum > 1 or "" /= Request_6)
               then
                  Append (Base, Global_Wp_Rewrite.Index & "/");
               end if;

               if Pagenum > 1 then
                  Request_7 :=
                    +(if not Empty (-Request_7)
                      then Trailing_Slash_It (-Request_7)
                      else -Request_7)
                    & User_Trailing_Slash_It
                       ((-Global_Wp_Rewrite.Pagination_Base) & "/" &
                        Helpers.Image (Pagenum), "paged");
               end if;

               Result := Base & Request_7 & Query_String;
            end;
         end;
      end if;

      --
      -- Filters the page number link for the current request.
      --
      -- @since 2.5.0
      -- @since 5.2.0 Added the `pagenum` argument.
      --
      -- @param string result  The page number link.
      -- @param int    pagenum The page number.
      --
      Result := +Apply_Filters ("get_pagenum_link", -Result, Pagenum);

      if Escape then
         return ESC_URL (-Result);
      else
         return Sanitize_URL (-Result);
      end if;
   end Get_Pagenum_Link;

-- --
-- -- Retrieves the next posts page link.
-- --
-- -- Backported from 2.1.3 to 2.0.10.
-- --
-- -- @since 2.0.10
-- --
-- -- @global int paged
-- --
-- -- @param int max_page Optional. Max pages. Default 0.
-- -- @return string|void The link URL for next posts page.
-- --
-- function get_next_posts_page_link( max_page = 0 ) then
--         global paged;

--         if ( ! is_single() ) then
--                 if ( ! paged ) then
--                         paged = 1;
--                 end;
--                 nextpage = (int) paged + 1;
--                 if ( ! max_page || max_page >= nextpage ) then
--                         return get_pagenum_link( nextpage );
--                 end;
--         end;
-- end;

-- --
-- -- Displays or retrieves the next posts page link.
-- --
-- -- @since 0.71
-- --
-- -- @param int  max_page Optional. Max pages. Default 0.
-- -- @param bool echo     Optional. Whether to echo the link. Default true.
-- -- @return string|void The link URL for next posts page if `echo = false`.
-- --
-- function next_posts( max_page = 0, echo = true ) then
--         output = esc_url( get_next_posts_page_link( max_page ) );

--         if ( echo ) then
--                 echo output;
--         end; else then
--                 return output;
--         end;
-- end;

-- --
-- -- Retrieves the next posts page link.
-- --
-- -- @since 2.7.0
-- --
-- -- @global int      paged
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @param string label    Content for link text.
-- -- @param int    max_page Optional. Max pages. Default 0.
-- -- @return string|void HTML-formatted next posts page link.
-- --
-- function get_next_posts_link( label = null, max_page = 0 ) then
--         global paged, wp_query;

--         if ( ! max_page ) then
--                 max_page = wp_query->max_num_pages;
--         end;

--         if ( ! paged ) then
--                 paged = 1;
--         end;

--         nextpage = (int) paged + 1;

--         if ( null === label ) then
--                 label = __( "Next Page &raquo;" );
--         end;

--         if ( ! is_single() && ( nextpage <= max_page ) ) then
--                 --
--                 -- Filters the anchor tag attributes for the next posts page link.
--                 --
--                 -- @since 2.7.0
--                 --
--                 -- @param string attributes Attributes for the anchor tag.
--                 --
--                 attr = apply_filters( "next_posts_link_attributes", "" );

--                 return "<a href="" . next_posts( max_page, false ) . "\" attr>" . preg_replace( "/&([^#])(?![a-z]then1,8end;;)/i", "&#038;1", label ) . "</a>";
--         end;
-- end;

-- --
-- -- Displays the next posts page link.
-- --
-- -- @since 0.71
-- --
-- -- @param string label    Content for link text.
-- -- @param int    max_page Optional. Max pages. Default 0.
-- --
-- function next_posts_link( label = null, max_page = 0 ) then
--         echo get_next_posts_link( label, max_page );
-- end;

   ----------------------------------
   -- Get_Previout_Posts_Page_Link --
   ----------------------------------

   function Get_Previous_Posts_Page_Link
            return String
   is
      use Globals;
      use Inc_Querys;
   begin
      if not Is_Single then
         declare
            Nextpage : Integer := Global_Paged - 1;  -- (int)
         begin
            if Nextpage < 1 then
               Nextpage := 1;
            end if;
            return Get_Pagenum_Link (Nextpage);
         end;
      end if;
      return ""; -- added ???
   end Get_Previous_Posts_Page_Link;

-- --
-- -- Displays or retrieves the previous posts page link.
-- --
-- -- @since 0.71
-- --
-- -- @param bool echo Optional. Whether to echo the link. Default true.
-- -- @return string|void The previous posts page link if `echo = false`.
-- --
-- function previous_posts( echo = true ) then
--         output = esc_url( get_previous_posts_page_link() );

--         if ( echo ) then
--                 echo output;
--         end; else then
--                 return output;
--         end;
-- end;

-- --
-- -- Retrieves the previous posts page link.
-- --
-- -- @since 2.7.0
-- --
-- -- @global int paged
-- --
-- -- @param string label Optional. Previous page link text.
-- -- @return string|void HTML-formatted previous page link.
-- --
-- function get_previous_posts_link( label = null ) then
--         global paged;

--         if ( null === label ) then
--                 label = __( "&laquo; Previous Page" );
--         end;

--         if ( ! is_single() && paged > 1 ) then
--                 --
--                 -- Filters the anchor tag attributes for the previous posts page link.
--                 --
--                 -- @since 2.7.0
--                 --
--                 -- @param string attributes Attributes for the anchor tag.
--                 --
--                 attr = apply_filters( "previous_posts_link_attributes", "" );
--                 return "<a href="" . previous_posts( false ) . "\" attr>" . preg_replace( "/&([^#])(?![a-z]then1,8end;;)/i", "&#038;1", label ) . "</a>";
--         end;
-- end;

-- --
-- -- Displays the previous posts page link.
-- --
-- -- @since 0.71
-- --
-- -- @param string label Optional. Previous page link text.
-- --
-- function previous_posts_link( label = null ) then
--         echo get_previous_posts_link( label );
-- end;

-- --
-- -- Retrieves the post pages link navigation for previous and next pages.
-- --
-- -- @since 2.8.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @param string|array args then
-- --     Optional. Arguments to build the post pages link navigation.
-- --
-- --     @type string sep      Separator character. Default "&#8212;".
-- --     @type string prelabel Link text to display for the previous page link.
-- --                            Default "&laquo; Previous Page".
-- --     @type string nxtlabel Link text to display for the next page link.
-- --                            Default "Next Page &raquo;".
-- -- end;
-- -- @return string The posts link navigation.
-- --
-- function get_posts_nav_link( args = array() ) then
--         global wp_query;

--         return = "";

--         if ( ! is_singular() ) then
--                 defaults = array(
--                         "sep"      => " &#8212; ",
--                         "prelabel" => __( "&laquo; Previous Page" ),
--                         "nxtlabel" => __( "Next Page &raquo;" ),
--                 );
--                 args     = wp_parse_args( args, defaults );

--                 max_num_pages = wp_query->max_num_pages;
--                 paged         = get_query_var( "paged" );

--                 // Only have sep if there"s both prev and next results.
--                 if ( paged < 2 || paged >= max_num_pages ) then
--                         args["sep"] = "";
--                 end;

--                 if ( max_num_pages > 1 ) then
--                         return  = get_previous_posts_link( args["prelabel"] );
--                         return .= preg_replace( "/&([^#])(?![a-z]then1,8end;;)/i", "&#038;1", args["sep"] );
--                         return .= get_next_posts_link( args["nxtlabel"] );
--                 end;
--         end;
--         return return;

-- end;

-- --
-- -- Displays the post pages link navigation for previous and next pages.
-- --
-- -- @since 0.71
-- --
-- -- @param string sep      Optional. Separator for posts navigation links. Default empty.
-- -- @param string prelabel Optional. Label for previous pages. Default empty.
-- -- @param string nxtlabel Optional Label for next pages. Default empty.
-- --
-- function posts_nav_link( sep = "", prelabel = "", nxtlabel = "" ) then
--         args = array_filter( compact( "sep", "prelabel", "nxtlabel" ) );
--         echo get_posts_nav_link( args );
-- end;

-- --
-- -- Retrieves the navigation to next/previous post, when applicable.
-- --
-- -- @since 4.1.0
-- -- @since 4.4.0 Introduced the `in_same_term`, `excluded_terms`, and `taxonomy` arguments.
-- -- @since 5.3.0 Added the `aria_label` parameter.
-- -- @since 5.5.0 Added the `class` parameter.
-- --
-- -- @param array args then
-- --     Optional. Default post navigation arguments. Default empty array.
-- --
-- --     @type string       prev_text          Anchor text to display in the previous post link. Default "%title".
-- --     @type string       next_text          Anchor text to display in the next post link. Default "%title".
-- --     @type bool         in_same_term       Whether link should be in a same taxonomy term. Default false.
-- --     @type int[]|string excluded_terms     Array or comma-separated list of excluded term IDs. Default empty.
-- --     @type string       taxonomy           Taxonomy, if `in_same_term` is true. Default "category".
-- --     @type string       screen_reader_text Screen reader text for the nav element. Default "Post navigation".
-- --     @type string       aria_label         ARIA label text for the nav element. Default "Posts".
-- --     @type string       class              Custom class for the nav element. Default "post-navigation".
-- -- end;
-- -- @return string Markup for post links.
-- --
-- function get_the_post_navigation( args = array() ) then
--         // Make sure the nav element has an aria-label attribute: fallback to the screen reader text.
--         if ( ! empty( args["screen_reader_text"] ) && empty( args["aria_label"] ) ) then
--                 args["aria_label"] = args["screen_reader_text"];
--         end;

--         args = wp_parse_args(
--                 args,
--                 array(
--                         "prev_text"          => "%title",
--                         "next_text"          => "%title",
--                         "in_same_term"       => false,
--                         "excluded_terms"     => "",
--                         "taxonomy"           => "category",
--                         "screen_reader_text" => __( "Post navigation" ),
--                         "aria_label"         => __( "Posts" ),
--                         "class"              => "post-navigation",
--                 )
--         );

--         navigation = "";

--         previous = get_previous_post_link(
--                 "<div class="nav-previous">%link</div>",
--                 args["prev_text"],
--                 args["in_same_term"],
--                 args["excluded_terms"],
--                 args["taxonomy"]
--         );

--         next = get_next_post_link(
--                 "<div class="nav-next">%link</div>",
--                 args["next_text"],
--                 args["in_same_term"],
--                 args["excluded_terms"],
--                 args["taxonomy"]
--         );

--         -- Only add markup if there's somewhere to navigate to.
--         if ( previous || next ) then
--                 navigation = _navigation_markup( previous . next, args["class"], args["screen_reader_text"], args["aria_label"] );
--         end;

--         return navigation;
-- end;

-- --
-- -- Displays the navigation to next/previous post, when applicable.
-- --
-- -- @since 4.1.0
-- --
-- -- @param array args Optional. See get_the_post_navigation() for available arguments.
-- --                    Default empty array.
-- --
-- function the_post_navigation( args = array() ) then
--         echo get_the_post_navigation( args );
-- end;

-- --
-- -- Returns the navigation to next/previous set of posts, when applicable.
-- --
-- -- @since 4.1.0
-- -- @since 5.3.0 Added the `aria_label` parameter.
-- -- @since 5.5.0 Added the `class` parameter.
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @param array args then
-- --     Optional. Default posts navigation arguments. Default empty array.
-- --
-- --     @type string prev_text          Anchor text to display in the previous posts link.
-- --                                      Default "Older posts".
-- --     @type string next_text          Anchor text to display in the next posts link.
-- --                                      Default "Newer posts".
-- --     @type string screen_reader_text Screen reader text for the nav element.
-- --                                      Default "Posts navigation".
-- --     @type string aria_label         ARIA label text for the nav element. Default "Posts".
-- --     @type string class              Custom class for the nav element. Default "posts-navigation".
-- -- end;
-- -- @return string Markup for posts links.
-- --
-- function get_the_posts_navigation( args = array() ) then
--         global wp_query;

--         navigation = "";

--         // Don"t print empty markup if there"s only one page.
--         if ( wp_query->max_num_pages > 1 ) then
--                 // Make sure the nav element has an aria-label attribute: fallback to the screen reader text.
--                 if ( ! empty( args["screen_reader_text"] ) && empty( args["aria_label"] ) ) then
--                         args["aria_label"] = args["screen_reader_text"];
--                 end;

--                 args = wp_parse_args(
--                         args,
--                         array(
--                                 "prev_text"          => __( "Older posts" ),
--                                 "next_text"          => __( "Newer posts" ),
--                                 "screen_reader_text" => __( "Posts navigation" ),
--                                 "aria_label"         => __( "Posts" ),
--                                 "class"              => "posts-navigation",
--                         )
--                 );

--                 next_link = get_previous_posts_link( args["next_text"] );
--                 prev_link = get_next_posts_link( args["prev_text"] );

--                 if ( prev_link ) then
--                         navigation .= "<div class="nav-previous">" . prev_link . "</div>";
--                 end;

--                 if ( next_link ) then
--                         navigation .= "<div class="nav-next">" . next_link . "</div>";
--                 end;

--                 navigation = _navigation_markup( navigation, args["class"], args["screen_reader_text"], args["aria_label"] );
--         end;

--         return navigation;
-- end;

-- --
-- -- Displays the navigation to next/previous set of posts, when applicable.
-- --
-- -- @since 4.1.0
-- --
-- -- @param array args Optional. See get_the_posts_navigation() for available arguments.
-- --                    Default empty array.
-- --
-- function the_posts_navigation( args = array() ) then
--         echo get_the_posts_navigation( args );
-- end;

-- --
-- -- Retrieves a paginated navigation to next/previous set of posts, when applicable.
-- --
-- -- @since 4.1.0
-- -- @since 5.3.0 Added the `aria_label` parameter.
-- -- @since 5.5.0 Added the `class` parameter.
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @param array args then
-- --     Optional. Default pagination arguments, see paginate_links().
-- --
-- --     @type string screen_reader_text Screen reader text for navigation element.
-- --                                      Default "Posts navigation".
-- --     @type string aria_label         ARIA label text for the nav element. Default "Posts".
-- --     @type string class              Custom class for the nav element. Default "pagination".
-- -- end;
-- -- @return string Markup for pagination links.
-- --
-- function get_the_posts_pagination( args = array() ) then
--         global wp_query;

--         navigation = "";

--         // Don"t print empty markup if there"s only one page.
--         if ( wp_query->max_num_pages > 1 ) then
--                 // Make sure the nav element has an aria-label attribute: fallback to the screen reader text.
--                 if ( ! empty( args["screen_reader_text"] ) && empty( args["aria_label"] ) ) then
--                         args["aria_label"] = args["screen_reader_text"];
--                 end;

--                 args = wp_parse_args(
--                         args,
--                         array(
--                                 "mid_size"           => 1,
--                                 "prev_text"          => _x( "Previous", "previous set of posts" ),
--                                 "next_text"          => _x( "Next", "next set of posts" ),
--                                 "screen_reader_text" => __( "Posts navigation" ),
--                                 "aria_label"         => __( "Posts" ),
--                                 "class"              => "pagination",
--                         )
--                 );

--                 --
--                 -- Filters the arguments for posts pagination links.
--                 --
--                 -- @since 6.1.0
--                 --
--                 -- @param array args then
--                 --     Optional. Default pagination arguments, see paginate_links().
--                 --
--                 --     @type string screen_reader_text Screen reader text for navigation element.
--                 --                                      Default "Posts navigation".
--                 --     @type string aria_label         ARIA label text for the nav element. Default "Posts".
--                 --     @type string class              Custom class for the nav element. Default "pagination".
--                 -- end;
--                 --
--                 args = apply_filters( "the_posts_pagination_args", args );

--                 // Make sure we get a string back. Plain is the next best thing.
--                 if ( isset( args["type"] ) && "array" === args["type"] ) then
--                         args["type"] = "plain";
--                 end;

--                 // Set up paginated links.
--                 links = paginate_links( args );

--                 if ( links ) then
--                         navigation = _navigation_markup( links, args["class"], args["screen_reader_text"], args["aria_label"] );
--                 end;
--         end;

--         return navigation;
-- end;

-- --
-- -- Displays a paginated navigation to next/previous set of posts, when applicable.
-- --
-- -- @since 4.1.0
-- --
-- -- @param array args Optional. See get_the_posts_pagination() for available arguments.
-- --                    Default empty array.
-- --
-- function the_posts_pagination( args = array() ) then
--         echo get_the_posts_pagination( args );
-- end;

-- --
-- -- Wraps passed links in navigational markup.
-- --
-- -- @since 4.1.0
-- -- @since 5.3.0 Added the `aria_label` parameter.
-- -- @access private
-- --
-- -- @param string links              Navigational links.
-- -- @param string class              Optional. Custom class for the nav element.
-- --                                   Default "posts-navigation".
-- -- @param string screen_reader_text Optional. Screen reader text for the nav element.
-- --                                   Default "Posts navigation".
-- -- @param string aria_label         Optional. ARIA label for the nav element.
-- --                                   Defaults to the value of `screen_reader_text`.
-- -- @return string Navigation template tag.
-- --
-- function _navigation_markup( links, class = "posts-navigation", screen_reader_text = "", aria_label = "" ) then
--         if ( empty( screen_reader_text ) ) then
--                 screen_reader_text = __( "Posts navigation" );
--         end;
--         if ( empty( aria_label ) ) then
--                 aria_label = screen_reader_text;
--         end;

--         template = "
--         <nav class="navigation %1s" aria-label="%4s">
--                 <h2 class="screen-reader-text">%2s</h2>
--                 <div class="nav-links">%3s</div>
--         </nav>";

--         --
--         -- Filters the navigation markup template.
--         --
--         -- Note: The filtered template HTML must contain specifiers for the navigation
--         -- class (%1s), the screen-reader-text value (%2s), placement of the navigation
--         -- links (%3s), and ARIA label text if screen-reader-text does not fit that (%4s):
--         --
--         --     <nav class="navigation %1s" aria-label="%4s">
--         --         <h2 class="screen-reader-text">%2s</h2>
--         --         <div class="nav-links">%3s</div>
--         --     </nav>
--         --
--         -- @since 4.4.0
--         --
--         -- @param string template The default template.
--         -- @param string class    The class passed by the calling function.
--         -- @return string Navigation template.
--         --
--         template = apply_filters( "navigation_markup_template", template, class );

--         return sprintf( template, sanitize_html_class( class ), esc_html( screen_reader_text ), links, esc_html( aria_label ) );
-- end;

-- --
-- -- Retrieves the comments page number link.
-- --
-- -- @since 2.7.0
-- --
-- -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
-- --
-- -- @param int pagenum  Optional. Page number. Default 1.
-- -- @param int max_page Optional. The maximum number of comment pages. Default 0.
-- -- @return string The comments page number link URL.
-- --
-- function get_comments_pagenum_link( pagenum = 1, max_page = 0 ) then
--         global wp_rewrite;

--         pagenum = (int) pagenum;

--         result = get_permalink();

--         if ( "newest" === get_option( "default_comments_page" ) ) then
--                 if ( pagenum != max_page ) then
--                         if ( wp_rewrite->using_permalinks() ) then
--                                 result = user_trailingslashit( trailingslashit( result ) . wp_rewrite->comments_pagination_base . "-" . pagenum, "commentpaged" );
--                         end; else then
--                                 result = add_query_arg( "cpage", pagenum, result );
--                         end;
--                 end;
--         end; elseif ( pagenum > 1 ) then
--                 if ( wp_rewrite->using_permalinks() ) then
--                         result = user_trailingslashit( trailingslashit( result ) . wp_rewrite->comments_pagination_base . "-" . pagenum, "commentpaged" );
--                 end; else then
--                         result = add_query_arg( "cpage", pagenum, result );
--                 end;
--         end;

--         result .= "#comments";

--         --
--         -- Filters the comments page number link for the current request.
--         --
--         -- @since 2.7.0
--         --
--         -- @param string result The comments page number link.
--         --
--         return apply_filters( "get_comments_pagenum_link", result );
-- end;

-- --
-- -- Retrieves the link to the next comments page.
-- --
-- -- @since 2.7.1
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @param string label    Optional. Label for link text. Default empty.
-- -- @param int    max_page Optional. Max page. Default 0.
-- -- @return string|void HTML-formatted link for the next page of comments.
-- --
-- function get_next_comments_link( label = "", max_page = 0 ) then
--         global wp_query;

--         if ( ! is_singular() ) then
--                 return;
--         end;

--         page = get_query_var( "cpage" );

--         if ( ! page ) then
--                 page = 1;
--         end;

--         nextpage = (int) page + 1;

--         if ( empty( max_page ) ) then
--                 max_page = wp_query->max_num_comment_pages;
--         end;

--         if ( empty( max_page ) ) then
--                 max_page = get_comment_pages_count();
--         end;

--         if ( nextpage > max_page ) then
--                 return;
--         end;

--         if ( empty( label ) ) then
--                 label = __( "Newer Comments &raquo;" );
--         end;

--         --
--         -- Filters the anchor tag attributes for the next comments page link.
--         --
--         -- @since 2.7.0
--         --
--         -- @param string attributes Attributes for the anchor tag.
--         --
--         return "<a href="" . esc_url( get_comments_pagenum_link( nextpage, max_page ) ) . "" " . apply_filters( "next_comments_link_attributes", "" ) . ">" . preg_replace( "/&([^#])(?![a-z]then1,8end;;)/i", "&#038;1", label ) . "</a>";
-- end;

-- --
-- -- Displays the link to the next comments page.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string label    Optional. Label for link text. Default empty.
-- -- @param int    max_page Optional. Max page. Default 0.
-- --
-- function next_comments_link( label = "", max_page = 0 ) then
--         echo get_next_comments_link( label, max_page );
-- end;

-- --
-- -- Retrieves the link to the previous comments page.
-- --
-- -- @since 2.7.1
-- --
-- -- @param string label Optional. Label for comments link text. Default empty.
-- -- @return string|void HTML-formatted link for the previous page of comments.
-- --
-- function get_previous_comments_link( label = "" ) then
--         if ( ! is_singular() ) then
--                 return;
--         end;

--         page = get_query_var( "cpage" );

--         if ( (int) page <= 1 ) then
--                 return;
--         end;

--         prevpage = (int) page - 1;

--         if ( empty( label ) ) then
--                 label = __( "&laquo; Older Comments" );
--         end;

--         --
--         -- Filters the anchor tag attributes for the previous comments page link.
--         --
--         -- @since 2.7.0
--         --
--         -- @param string attributes Attributes for the anchor tag.
--         --
--         return "<a href="" . esc_url( get_comments_pagenum_link( prevpage ) ) . "" " . apply_filters( "previous_comments_link_attributes", "" ) . ">" . preg_replace( "/&([^#])(?![a-z]then1,8end;;)/i", "&#038;1", label ) . "</a>";
-- end;

-- --
-- -- Displays the link to the previous comments page.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string label Optional. Label for comments link text. Default empty.
-- --
-- function previous_comments_link( label = "" ) then
--         echo get_previous_comments_link( label );
-- end;

-- --
-- -- Displays or retrieves pagination links for the comments on the current post.
-- --
-- -- @see paginate_links()
-- -- @since 2.7.0
-- --
-- -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
-- --
-- -- @param string|array args Optional args. See paginate_links(). Default empty array.
-- -- @return void|string|array Void if "echo" argument is true and "type" is not an array,
-- --                           or if the query is not for an existing single post of any post type.
-- --                           Otherwise, markup for comment page links or array of comment page links,
-- --                           depending on "type" argument.
-- --
-- function paginate_comments_links( args = array() ) then
--         global wp_rewrite;

--         if ( ! is_singular() ) then
--                 return;
--         end;

--         page = get_query_var( "cpage" );
--         if ( ! page ) then
--                 page = 1;
--         end;
--         max_page = get_comment_pages_count();
--         defaults = array(
--                 "base"         => add_query_arg( "cpage", "%#%" ),
--                 "format"       => "",
--                 "total"        => max_page,
--                 "current"      => page,
--                 "echo"         => true,
--                 "type"         => "plain",
--                 "add_fragment" => "#comments",
--         );
--         if ( wp_rewrite->using_permalinks() ) then
--                 defaults["base"] = user_trailingslashit( trailingslashit( get_permalink() ) . wp_rewrite->comments_pagination_base . "-%#%", "commentpaged" );
--         end;

--         args       = wp_parse_args( args, defaults );
--         page_links = paginate_links( args );

--         if ( args["echo"] && "array" !== args["type"] ) then
--                 echo page_links;
--         end; else then
--                 return page_links;
--         end;
-- end;

-- --
-- -- Retrieves navigation to next/previous set of comments, when applicable.
-- --
-- -- @since 4.4.0
-- -- @since 5.3.0 Added the `aria_label` parameter.
-- -- @since 5.5.0 Added the `class` parameter.
-- --
-- -- @param array args then
-- --     Optional. Default comments navigation arguments.
-- --
-- --     @type string prev_text          Anchor text to display in the previous comments link.
-- --                                      Default "Older comments".
-- --     @type string next_text          Anchor text to display in the next comments link.
-- --                                      Default "Newer comments".
-- --     @type string screen_reader_text Screen reader text for the nav element. Default "Comments navigation".
-- --     @type string aria_label         ARIA label text for the nav element. Default "Comments".
-- --     @type string class              Custom class for the nav element. Default "comment-navigation".
-- -- end;
-- -- @return string Markup for comments links.
-- --
-- function get_the_comments_navigation( args = array() ) then
--         navigation = "";

--         // Are there comments to navigate through?
--         if ( get_comment_pages_count() > 1 ) then
--                 // Make sure the nav element has an aria-label attribute: fallback to the screen reader text.
--                 if ( ! empty( args["screen_reader_text"] ) && empty( args["aria_label"] ) ) then
--                         args["aria_label"] = args["screen_reader_text"];
--                 end;

--                 args = wp_parse_args(
--                         args,
--                         array(
--                                 "prev_text"          => __( "Older comments" ),
--                                 "next_text"          => __( "Newer comments" ),
--                                 "screen_reader_text" => __( "Comments navigation" ),
--                                 "aria_label"         => __( "Comments" ),
--                                 "class"              => "comment-navigation",
--                         )
--                 );

--                 prev_link = get_previous_comments_link( args["prev_text"] );
--                 next_link = get_next_comments_link( args["next_text"] );

--                 if ( prev_link ) then
--                         navigation .= "<div class="nav-previous">" . prev_link . "</div>";
--                 end;

--                 if ( next_link ) then
--                         navigation .= "<div class="nav-next">" . next_link . "</div>";
--                 end;

--                 navigation = _navigation_markup( navigation, args["class"], args["screen_reader_text"], args["aria_label"] );
--         end;

--         return navigation;
-- end;

-- --
-- -- Displays navigation to next/previous set of comments, when applicable.
-- --
-- -- @since 4.4.0
-- --
-- -- @param array args See get_the_comments_navigation() for available arguments. Default empty array.
-- --
-- function the_comments_navigation( args = array() ) then
--         echo get_the_comments_navigation( args );
-- end;

-- --
-- -- Retrieves a paginated navigation to next/previous set of comments, when applicable.
-- --
-- -- @since 4.4.0
-- -- @since 5.3.0 Added the `aria_label` parameter.
-- -- @since 5.5.0 Added the `class` parameter.
-- --
-- -- @see paginate_comments_links()
-- --
-- -- @param array args then
-- --     Optional. Default pagination arguments.
-- --
-- --     @type string screen_reader_text Screen reader text for the nav element. Default "Comments navigation".
-- --     @type string aria_label         ARIA label text for the nav element. Default "Comments".
-- --     @type string class              Custom class for the nav element. Default "comments-pagination".
-- -- end;
-- -- @return string Markup for pagination links.
-- --
-- function get_the_comments_pagination( args = array() ) then
--         navigation = "";

--         // Make sure the nav element has an aria-label attribute: fallback to the screen reader text.
--         if ( ! empty( args["screen_reader_text"] ) && empty( args["aria_label"] ) ) then
--                 args["aria_label"] = args["screen_reader_text"];
--         end;

--         args         = wp_parse_args(
--                 args,
--                 array(
--                         "screen_reader_text" => __( "Comments navigation" ),
--                         "aria_label"         => __( "Comments" ),
--                         "class"              => "comments-pagination",
--                 )
--         );
--         args["echo"] = false;

--         // Make sure we get a string back. Plain is the next best thing.
--         if ( isset( args["type"] ) && "array" === args["type"] ) then
--                 args["type"] = "plain";
--         end;

--         links = paginate_comments_links( args );

--         if ( links ) then
--                 navigation = _navigation_markup( links, args["class"], args["screen_reader_text"], args["aria_label"] );
--         end;

--         return navigation;
-- end;

-- --
-- -- Displays a paginated navigation to next/previous set of comments, when applicable.
-- --
-- -- @since 4.4.0
-- --
-- -- @param array args See get_the_comments_pagination() for available arguments. Default empty array.
-- --
-- function the_comments_pagination( args = array() ) then
--         echo get_the_comments_pagination( args );
-- end;

-- --
-- -- Retrieves the URL for the current site where the front end is accessible.
-- --
-- -- Returns the "home" option with the appropriate protocol. The protocol will be "https"
-- -- if is_ssl() evaluates to true; otherwise, it will be the same as the "home" option.
-- -- If `scheme` is "http" or "https", is_ssl() is overridden.
-- --
-- -- @since 3.0.0
-- --
-- -- @param string      path   Optional. Path relative to the home URL. Default empty.
-- -- @param string|null scheme Optional. Scheme to give the home URL context. Accepts
-- --                            "http", "https", "relative", "rest", or null. Default null.
-- -- @return string Home URL link with optional path appended.
-- --
-- function home_url( path = "", scheme = null ) then
--         return get_home_url( null, path, scheme );
-- end;

-- --
-- -- Retrieves the URL for a given site where the front end is accessible.
-- --
-- -- Returns the "home" option with the appropriate protocol. The protocol will be "https"
-- -- if is_ssl() evaluates to true; otherwise, it will be the same as the "home" option.
-- -- If `scheme` is "http" or "https", is_ssl() is overridden.
-- --
-- -- @since 3.0.0
-- --
-- -- @param int|null    blog_id Optional. Site ID. Default null (current site).
-- -- @param string      path    Optional. Path relative to the home URL. Default empty.
-- -- @param string|null scheme  Optional. Scheme to give the home URL context. Accepts
-- --                             "http", "https", "relative", "rest", or null. Default null.
-- -- @return string Home URL link with optional path appended.
-- --
-- function get_home_url( blog_id = null, path = "", scheme = null ) then
--         orig_scheme = scheme;

--         if ( empty( blog_id ) || ! is_multisite() ) then
--                 url = get_option( "home" );
--         end; else then
--                 switch_to_blog( blog_id );
--                 url = get_option( "home" );
--                 restore_current_blog();
--         end;

--         if ( ! in_array( scheme, array( "http", "https", "relative" ), true ) ) then
--                 if ( is_ssl() ) then
--                         scheme = "https";
--                 end; else then
--                         scheme = parse_url( url, PHP_URL_SCHEME );
--                 end;
--         end;

--         url = set_url_scheme( url, scheme );

--         if ( path && is_string( path ) ) then
--                 url .= "/" . ltrim( path, "/" );
--         end;

--         --
--         -- Filters the home URL.
--         --
--         -- @since 3.0.0
--         --
--         -- @param string      url         The complete home URL including scheme and path.
--         -- @param string      path        Path relative to the home URL. Blank string if no path is specified.
--         -- @param string|null orig_scheme Scheme to give the home URL context. Accepts "http", "https",
--         --                                 "relative", "rest", or null.
--         -- @param int|null    blog_id     Site ID, or null for the current site.
--         --
--         return apply_filters( "home_url", url, path, orig_scheme, blog_id );
-- end;

   --------------
   -- Site_URL --
   --------------

   function Site_URL (Path   : String := "";
                      Scheme : String := "") --  = null
                      return String
   is
   begin
      return Get_Site_URL (0, Path, Scheme); -- null
   end Site_URL;

   ------------------
   -- Get_Site_URL --
   ------------------

   function Get_Site_URL (Blog_Id : Integer := 0; -- null
                          Path    : String  := "";
                          Scheme  : String  := "") -- null
                          return String
   is
      use Ada.Strings.Unbounded;
      use Php.Strings;
      use Hb_Common;
      use Inc_Load;
      use Inc_Ms_Blogs;
      use Inc_Options;
      use Inc_Plugins;

      URL : Unbounded_String;
   begin
      if Blog_Id = 0 or else not Is_Multisite then
         URL := +Get_Option ("siteurl");
      else
         Switch_To_Blog (Blog_Id);
         URL := +Get_Option ("siteurl");
         Restore_Current_Blog;
      end if;

      URL := +Set_URL_Scheme (-URL, Scheme);

      if Path /= "" then --  && is_string( path ) ) then
         Append (URL, "/" & Ltrim (Path, "/"));
      end if;

      --
      -- Filters the site URL.
      --
      -- @since 2.7.0
      --
      -- @param string      url     The complete site URL including scheme and path.
      -- @param string      path    Path relative to the site URL. Blank string if no
      --                             path is specified.
      -- @param string|null scheme  Scheme to give the site URL context. Accepts
      --                             "http", "https", "login", "login_post", "admin",
      --                             "relative" or null.
      -- @param int|null    blog_id Site ID, or null for the current site.
      --
      return Apply_Filters ("site_url", -URL, Path, Scheme, Blog_Id);
   end Get_Site_URL;

-- --
-- -- Retrieves the URL to the admin area for the current site.
-- --
-- -- @since 2.6.0
-- --
-- -- @param string path   Optional. Path relative to the admin URL. Default empty.
-- -- @param string scheme The scheme to use. Default is "admin", which obeys force_ssl_admin() and is_ssl().
-- --                       "http" or "https" can be passed to force those schemes.
-- -- @return string Admin URL link with optional path appended.
-- --
-- function admin_url( path = "", scheme = "admin" ) then
--         return get_admin_url( null, path, scheme );
-- end;

-- --
-- -- Retrieves the URL to the admin area for a given site.
-- --
-- -- @since 3.0.0
-- --
-- -- @param int|null blog_id Optional. Site ID. Default null (current site).
-- -- @param string   path    Optional. Path relative to the admin URL. Default empty.
-- -- @param string   scheme  Optional. The scheme to use. Accepts "http" or "https",
-- --                          to force those schemes. Default "admin", which obeys
-- --                          force_ssl_admin() and is_ssl().
-- -- @return string Admin URL link with optional path appended.
-- --
-- function get_admin_url( blog_id = null, path = "", scheme = "admin" ) then
--         url = get_site_url( blog_id, "wp-admin/", scheme );

--         if ( path && is_string( path ) ) then
--                 url .= ltrim( path, "/" );
--         end;

--         --
--         -- Filters the admin area URL.
--         --
--         -- @since 2.8.0
--         -- @since 5.8.0 The `scheme` parameter was added.
--         --
--         -- @param string      url     The complete admin area URL including scheme and path.
--         -- @param string      path    Path relative to the admin area URL. Blank string if no path is specified.
--         -- @param int|null    blog_id Site ID, or null for the current site.
--         -- @param string|null scheme  The scheme to use. Accepts "http", "https",
--         --                             "admin", or null. Default "admin", which obeys force_ssl_admin() and is_ssl().
--         --
--         return apply_filters( "admin_url", url, path, blog_id, scheme );
-- end;

   ------------------
   -- Includes_URL --
   ------------------

   function Includes_URL (Path   : String := "";
                          Scheme : String := "") -- null
                          return String
   is
      use Ada.Strings.Unbounded;
      use Php.Strings;
      use Globals;
      use Hb_Common;
      use Inc_Plugins;

      URL : Unbounded_String := +Site_URL ("/" & (-WPINC) & "/", Scheme);
   begin
      if Path /= "" then -- and then is_string( path ) ) then
         Append (URL, Ltrim (Path, "/"));
      end if;

      --
      -- Filters the URL to the includes directory.
      --
      -- @since 2.8.0
      -- @since 5.8.0 The `scheme` parameter was added.
      --
      -- @param string      url    The complete URL to the includes directory
      --                            including scheme and path.
      -- @param string      path   Path relative to the URL to the wp-includes
      --                            directory. Blank string if no path is specified.
      -- @param string|null scheme Scheme to give the includes URL context. Accepts
      --                            "http", "https", "relative", or null. Default null.
      --
      return Apply_Filters ("includes_url", -URL, Path, Scheme);
   end Includes_URL;

-- --
-- -- Retrieves the URL to the content directory.
-- --
-- -- @since 2.6.0
-- --
-- -- @param string path Optional. Path relative to the content URL. Default empty.
-- -- @return string Content URL link with optional path appended.
-- --
-- function content_url( path = "" ) then
--         url = set_url_scheme( WP_CONTENT_URL );

--         if ( path && is_string( path ) ) then
--                 url .= "/" . ltrim( path, "/" );
--         end;

--         --
--         -- Filters the URL to the content directory.
--         --
--         -- @since 2.8.0
--         --
--         -- @param string url  The complete URL to the content directory including scheme and path.
--         -- @param string path Path relative to the URL to the content directory. Blank string
--         --                     if no path is specified.
--         --
--         return apply_filters( "content_url", url, path );
-- end;

-- --
-- -- Retrieves a URL within the plugins or mu-plugins directory.
-- --
-- -- Defaults to the plugins directory URL if no arguments are supplied.
-- --
-- -- @since 2.6.0
-- --
-- -- @param string path   Optional. Extra path appended to the end of the URL, including
-- --                       the relative directory if plugin is supplied. Default empty.
-- -- @param string plugin Optional. A full path to a file inside a plugin or mu-plugin.
-- --                       The URL will be relative to its directory. Default empty.
-- --                       Typically this is done by passing `__FILE__` as the argument.
-- -- @return string Plugins URL link with optional paths appended.
-- --
-- function plugins_url( path = "", plugin = "" ) then

--         path          = wp_normalize_path( path );
--         plugin        = wp_normalize_path( plugin );
--         mu_plugin_dir = wp_normalize_path( WPMU_PLUGIN_DIR );

--         if ( ! empty( plugin ) && 0 === strpos( plugin, mu_plugin_dir ) ) then
--                 url = WPMU_PLUGIN_URL;
--         end; else then
--                 url = WP_PLUGIN_URL;
--         end;

--         url = set_url_scheme( url );

--         if ( ! empty( plugin ) && is_string( plugin ) ) then
--                 folder = dirname( plugin_basename( plugin ) );
--                 if ( "." !== folder ) then
--                         url .= "/" . ltrim( folder, "/" );
--                 end;
--         end;

--         if ( path && is_string( path ) ) then
--                 url .= "/" . ltrim( path, "/" );
--         end;

--         --
--         -- Filters the URL to the plugins directory.
--         --
--         -- @since 2.8.0
--         --
--         -- @param string url    The complete URL to the plugins directory including scheme and path.
--         -- @param string path   Path relative to the URL to the plugins directory. Blank string
--         --                       if no path is specified.
--         -- @param string plugin The plugin file path to be relative to. Blank string if no plugin
--         --                       is specified.
--         --
--         return apply_filters( "plugins_url", url, path, plugin );
-- end;

-- --
-- -- Retrieves the site URL for the current network.
-- --
-- -- Returns the site URL with the appropriate protocol, "https" if
-- -- is_ssl() and "http" otherwise. If scheme is "http" or "https", is_ssl() is
-- -- overridden.
-- --
-- -- @since 3.0.0
-- --
-- -- @see set_url_scheme()
-- --
-- -- @param string      path   Optional. Path relative to the site URL. Default empty.
-- -- @param string|null scheme Optional. Scheme to give the site URL context. Accepts
-- --                            "http", "https", or "relative". Default null.
-- -- @return string Site URL link with optional path appended.
-- --
-- function network_site_url( path = "", scheme = null ) then
--         if ( ! is_multisite() ) then
--                 return site_url( path, scheme );
--         end;

--         current_network = get_network();

--         if ( "relative" === scheme ) then
--                 url = current_network->path;
--         end; else then
--                 url = set_url_scheme( "http://" . current_network->domain . current_network->path, scheme );
--         end;

--         if ( path && is_string( path ) ) then
--                 url .= ltrim( path, "/" );
--         end;

--         --
--         -- Filters the network site URL.
--         --
--         -- @since 3.0.0
--         --
--         -- @param string      url    The complete network site URL including scheme and path.
--         -- @param string      path   Path relative to the network site URL. Blank string if
--         --                            no path is specified.
--         -- @param string|null scheme Scheme to give the URL context. Accepts "http", "https",
--         --                            "relative" or null.
--         --
--         return apply_filters( "network_site_url", url, path, scheme );
-- end;

-- --
-- -- Retrieves the home URL for the current network.
-- --
-- -- Returns the home URL with the appropriate protocol, "https" is_ssl()
-- -- and "http" otherwise. If `scheme` is "http" or "https", `is_ssl()` is
-- -- overridden.
-- --
-- -- @since 3.0.0
-- --
-- -- @param string      path   Optional. Path relative to the home URL. Default empty.
-- -- @param string|null scheme Optional. Scheme to give the home URL context. Accepts
-- --                            "http", "https", or "relative". Default null.
-- -- @return string Home URL link with optional path appended.
-- --
-- function network_home_url( path = "", scheme = null ) then
--         if ( ! is_multisite() ) then
--                 return home_url( path, scheme );
--         end;

--         current_network = get_network();
--         orig_scheme     = scheme;

--         if ( ! in_array( scheme, array( "http", "https", "relative" ), true ) ) then
--                 scheme = is_ssl() ? "https" : "http";
--         end;

--         if ( "relative" === scheme ) then
--                 url = current_network->path;
--         end; else then
--                 url = set_url_scheme( "http://" . current_network->domain . current_network->path, scheme );
--         end;

--         if ( path && is_string( path ) ) then
--                 url .= ltrim( path, "/" );
--         end;

--         --
--         -- Filters the network home URL.
--         --
--         -- @since 3.0.0
--         --
--         -- @param string      url         The complete network home URL including scheme and path.
--         -- @param string      path        Path relative to the network home URL. Blank string
--         --                                 if no path is specified.
--         -- @param string|null orig_scheme Scheme to give the URL context. Accepts "http", "https",
--         --                                 "relative" or null.
--         --
--         return apply_filters( "network_home_url", url, path, orig_scheme );
-- end;

-- --
-- -- Retrieves the URL to the admin area for the network.
-- --
-- -- @since 3.0.0
-- --
-- -- @param string path   Optional path relative to the admin URL. Default empty.
-- -- @param string scheme Optional. The scheme to use. Default is "admin", which obeys force_ssl_admin()
-- --                       and is_ssl(). "http" or "https" can be passed to force those schemes.
-- -- @return string Admin URL link with optional path appended.
-- --
-- function network_admin_url( path = "", scheme = "admin" ) then
--         if ( ! is_multisite() ) then
--                 return admin_url( path, scheme );
--         end;

--         url = network_site_url( "wp-admin/network/", scheme );

--         if ( path && is_string( path ) ) then
--                 url .= ltrim( path, "/" );
--         end;

--         --
--         -- Filters the network admin URL.
--         --
--         -- @since 3.0.0
--         -- @since 5.8.0 The `scheme` parameter was added.
--         --
--         -- @param string      url    The complete network admin URL including scheme and path.
--         -- @param string      path   Path relative to the network admin URL. Blank string if
--         --                            no path is specified.
--         -- @param string|null scheme The scheme to use. Accepts "http", "https",
--         --                            "admin", or null. Default is "admin", which obeys force_ssl_admin() and is_ssl().
--         --
--         return apply_filters( "network_admin_url", url, path, scheme );
-- end;

-- --
-- -- Retrieves the URL to the admin area for the current user.
-- --
-- -- @since 3.0.0
-- --
-- -- @param string path   Optional. Path relative to the admin URL. Default empty.
-- -- @param string scheme Optional. The scheme to use. Default is "admin", which obeys force_ssl_admin()
-- --                       and is_ssl(). "http" or "https" can be passed to force those schemes.
-- -- @return string Admin URL link with optional path appended.
-- --
-- function user_admin_url( path = "", scheme = "admin" ) then
--         url = network_site_url( "wp-admin/user/", scheme );

--         if ( path && is_string( path ) ) then
--                 url .= ltrim( path, "/" );
--         end;

--         --
--         -- Filters the user admin URL for the current user.
--         --
--         -- @since 3.1.0
--         -- @since 5.8.0 The `scheme` parameter was added.
--         --
--         -- @param string      url    The complete URL including scheme and path.
--         -- @param string      path   Path relative to the URL. Blank string if
--         --                            no path is specified.
--         -- @param string|null scheme The scheme to use. Accepts "http", "https",
--         --                            "admin", or null. Default is "admin", which obeys force_ssl_admin() and is_ssl().
--         --
--         return apply_filters( "user_admin_url", url, path, scheme );
-- end;

-- --
-- -- Retrieves the URL to the admin area for either the current site or the network depending on context.
-- --
-- -- @since 3.1.0
-- --
-- -- @param string path   Optional. Path relative to the admin URL. Default empty.
-- -- @param string scheme Optional. The scheme to use. Default is "admin", which obeys force_ssl_admin()
-- --                       and is_ssl(). "http" or "https" can be passed to force those schemes.
-- -- @return string Admin URL link with optional path appended.
-- --
-- function self_admin_url( path = "", scheme = "admin" ) then
--         if ( is_network_admin() ) then
--                 url = network_admin_url( path, scheme );
--         end; elseif ( is_user_admin() ) then
--                 url = user_admin_url( path, scheme );
--         end; else then
--                 url = admin_url( path, scheme );
--         end;

--         --
--         -- Filters the admin URL for the current site or network depending on context.
--         --
--         -- @since 4.9.0
--         --
--         -- @param string url    The complete URL including scheme and path.
--         -- @param string path   Path relative to the URL. Blank string if no path is specified.
--         -- @param string scheme The scheme to use.
--         --
--         return apply_filters( "self_admin_url", url, path, scheme );
-- end;

   --------------------
   -- Set_URL_Scheme --
   --------------------

   function Set_URL_Scheme (URL    : String;
                            Scheme : String := "") -- null
                            return String
   is
      use Ada.Strings.Unbounded;
      use Php.Preg;
      use Php.Strings;
      use Hb_Common;
      use Inc_Functions;
      use Inc_Load;
      use Inc_Plugins;

      Orig_Scheme : constant String := Scheme;

      Scheme_2 : Unbounded_String := +Scheme;
      URL_2    : Unbounded_String := +Trim (URL);
   begin
      if -Scheme_2 = "" then
         Scheme_2 := +(if Is_SSL then "https" else "http");
      elsif -Scheme_2 in "admin" | "login" | "login_post" | "rpc" then
         Scheme_2 := +(if Is_SSL or else Force_SSL_Admin then "https" else "http");
      elsif -Scheme_2 not in "http" | "https" | "relative" then
         Scheme_2 := +(if Is_SSL then "https" else "http");
      end if;

      if Substr (-URL_2, 0, 2) = "//" then
         URL_2 := "http:" & URL_2;
      end if;

      if "relative" = Scheme_2 then
         URL_2 := +Ltrim (Preg_Replace ("#^\w+://[^/]*#", "", -URL_2));
         if "" /= URL_2 and then '/' = Element (URL_2, 1) then -- [0]
            URL_2 := +"/" & Ltrim (-URL_2, "/ \t\n\r\0\x0B");
         end if;
      else
         URL_2 := +Preg_Replace ("#^\w+://#", -Scheme_2 & "://", -URL_2);
      end if;

      --
      -- Filters the resulting URL after setting the scheme.
      --
      -- @since 3.4.0
      --
      -- @param string      url         The complete URL including scheme and path.
      -- @param string      scheme      Scheme applied to the URL. One of "http",
      --                                 "https", or "relative".
      -- @param string|null orig_scheme Scheme requested for the URL. One of "http",
      --                                 "https", "login", "login_post", "admin",
      --                                 "relative", "rest", "rpc", or null.
      --
      --
      return Apply_Filters ("set_url_scheme", -URL_2, -Scheme_2, Orig_Scheme);
   end Set_URL_Scheme;

-- --
-- -- Retrieves the URL to the user"s dashboard.
-- --
-- -- If a user does not belong to any site, the global user dashboard is used. If the user
-- -- belongs to the current site, the dashboard for the current site is returned. If the user
-- -- cannot edit the current site, the dashboard to the user"s primary site is returned.
-- --
-- -- @since 3.1.0
-- --
-- -- @param int    user_id Optional. User ID. Defaults to current user.
-- -- @param string path    Optional path relative to the dashboard. Use only paths known to
-- --                        both site and user admins. Default empty.
-- -- @param string scheme  The scheme to use. Default is "admin", which obeys force_ssl_admin()
-- --                        and is_ssl(). "http" or "https" can be passed to force those schemes.
-- -- @return string Dashboard URL link with optional path appended.
-- --
-- function get_dashboard_url( user_id = 0, path = "", scheme = "admin" ) then
--         user_id = user_id ? (int) user_id : get_current_user_id();

--         blogs = get_blogs_of_user( user_id );

--         if ( is_multisite() && ! user_can( user_id, "manage_network" ) && empty( blogs ) ) then
--                 url = user_admin_url( path, scheme );
--         end; elseif ( ! is_multisite() ) then
--                 url = admin_url( path, scheme );
--         end; else then
--                 current_blog = get_current_blog_id();

--                 if ( current_blog && ( user_can( user_id, "manage_network" ) || in_array( current_blog, array_keys( blogs ), true ) ) ) then
--                         url = admin_url( path, scheme );
--                 end; else then
--                         active = get_active_blog_for_user( user_id );
--                         if ( active ) then
--                                 url = get_admin_url( active->blog_id, path, scheme );
--                         end; else then
--                                 url = user_admin_url( path, scheme );
--                         end;
--                 end;
--         end;

--         --
--         -- Filters the dashboard URL for a user.
--         --
--         -- @since 3.1.0
--         --
--         -- @param string url     The complete URL including scheme and path.
--         -- @param int    user_id The user ID.
--         -- @param string path    Path relative to the URL. Blank string if no path is specified.
--         -- @param string scheme  Scheme to give the URL context. Accepts "http", "https", "login",
--         --                        "login_post", "admin", "relative" or null.
--         --
--         return apply_filters( "user_dashboard_url", url, user_id, path, scheme );
-- end;

-- --
-- -- Retrieves the URL to the user"s profile editor.
-- --
-- -- @since 3.1.0
-- --
-- -- @param int    user_id Optional. User ID. Defaults to current user.
-- -- @param string scheme  Optional. The scheme to use. Default is "admin", which obeys force_ssl_admin()
-- --                        and is_ssl(). "http" or "https" can be passed to force those schemes.
-- -- @return string Dashboard URL link with optional path appended.
-- --
-- function get_edit_profile_url( user_id = 0, scheme = "admin" ) then
--         user_id = user_id ? (int) user_id : get_current_user_id();

--         if ( is_user_admin() ) then
--                 url = user_admin_url( "profile.php", scheme );
--         end; elseif ( is_network_admin() ) then
--                 url = network_admin_url( "profile.php", scheme );
--         end; else then
--                 url = get_dashboard_url( user_id, "profile.php", scheme );
--         end;

--         --
--         -- Filters the URL for a user"s profile editor.
--         --
--         -- @since 3.1.0
--         --
--         -- @param string url     The complete URL including scheme and path.
--         -- @param int    user_id The user ID.
--         -- @param string scheme  Scheme to give the URL context. Accepts "http", "https", "login",
--         --                        "login_post", "admin", "relative" or null.
--         --
--         return apply_filters( "edit_profile_url", url, user_id, scheme );
-- end;

-- --
-- -- Returns the canonical URL for a post.
-- --
-- -- When the post is the same as the current requested page the function will handle the
-- -- pagination arguments too.
-- --
-- -- @since 4.6.0
-- --
-- -- @param int|WP_Post post Optional. Post ID or object. Default is global `post`.
-- -- @return string|false The canonical URL. False if the post does not exist
-- --                      or has not been published yet.
-- --
-- function wp_get_canonical_url( post = null ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return false;
--         end;

--         if ( "publish" !== post->post_status ) then
--                 return false;
--         end;

--         canonical_url = get_permalink( post );

--         // If a canonical is being generated for the current page, make sure it has pagination if needed.
--         if ( get_queried_object_id() === post->ID ) then
--                 page = get_query_var( "page", 0 );
--                 if ( page >= 2 ) then
--                         if ( ! get_option( "permalink_structure" ) ) then
--                                 canonical_url = add_query_arg( "page", page, canonical_url );
--                         end; else then
--                                 canonical_url = trailingslashit( canonical_url ) . user_trailingslashit( page, "single_paged" );
--                         end;
--                 end;

--                 cpage = get_query_var( "cpage", 0 );
--                 if ( cpage ) then
--                         canonical_url = get_comments_pagenum_link( cpage );
--                 end;
--         end;

--         --
--         -- Filters the canonical URL for a post.
--         --
--         -- @since 4.6.0
--         --
--         -- @param string  canonical_url The post"s canonical URL.
--         -- @param WP_Post post          Post object.
--         --
--         return apply_filters( "get_canonical_url", canonical_url, post );
-- end;

-- --
-- -- Outputs rel=canonical for singular queries.
-- --
-- -- @since 2.9.0
-- -- @since 4.6.0 Adjusted to use `wp_get_canonical_url()`.
-- --
-- function rel_canonical() then
--         if ( ! is_singular() ) then
--                 return;
--         end;

--         id = get_queried_object_id();

--         if ( 0 === id ) then
--                 return;
--         end;

--         url = wp_get_canonical_url( id );

--         if ( ! empty( url ) ) then
--                 echo "<link rel="canonical" href="" . esc_url( url ) . "" />" . "\n";
--         end;
-- end;

   ----------------------
   -- Wp_Get_Shortlink --
   ----------------------

   function Wp_Get_Shortlink (Id          : Integer := 0;
                              Context     : String  := "post";
                              Allow_Slugs : Boolean := True)
                              return String
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Inc_Class_Wp_Posts;
      use Inc_Class_Wp_Post_Type;
      use Inc_Options;
      use Inc_Plugins;
      use Inc_Posts;
      use Inc_Querys;

      --
      -- Filters whether to preempt generating a shortlink for the given post.
      --
      -- Returning a value other than false from the filter will short-circuit
      -- the shortlink generation process, returning that value instead.
      --
      -- @since 3.0.0
      --
      -- @param false|string return      Short-circuit return value. Either false or
      --                                  a URL string.
      -- @param int          id          Post ID, or 0 for the current post.
      -- @param string       context     The context for the link. One of "post" or
      --                                  "query",
      -- @param bool         allow_slugs Whether to allow post slugs in the shortlink.
      --
      Shortlink : Unbounded_String :=
        +Apply_Filters ("pre_get_shortlink", "False", Id, Context, Allow_Slugs);

      Post_Id : Inc_Class_Wp_Posts.Post_Id := 0;
      Post    : Wp_Post;
   begin

      if "" /= Shortlink then -- false
         return -Shortlink;
      end if;

      if "query" = Context and then Is_Singular then
         Post_Id := Get_Queried_Object_Id;
         Post    := Get_Post (Post_Id);
      elsif "post" = Context then
         Post := Get_Post (Inc_Class_Wp_Posts.Post_Id (Id));
         if Post.Id /= 0 then
--       if not Empty (Post.Id) then
            Post_Id := Post.Id;
         end if;
      end if;

      Shortlink := +"";

      -- Return `?p=` link for all public post types.
      if Post_Id /= 0 then
--    if not Empty (Post_Id) then
         declare
            Post_Type : constant Wp_Post_Type :=
              Get_Post_Type_Object (-Post.Post_Type);
         begin
            if
              "page" = Post.Post_Type and then
              Get_Option ("page_on_front") = Helpers.Image (Integer (Post.Id)) and then
              "page" = Get_Option ("show_on_front")
            then
               Shortlink := +Home_URL ("/");
            elsif Post_Type /= Null_Post_Type and then Post_Type.Public then
               Shortlink := +Home_URL ("?p=" & Helpers.Image (Integer (Post_Id)));
            end if;
         end;
      end if;

      --
      -- Filters the shortlink for a post.
      --
      -- @since 3.0.0
      --
      -- @param string shortlink   Shortlink URL.
      -- @param int    id          Post ID, or 0 for the current post.
      -- @param string context     The context for the link. One of "post" or "query",
      -- @param bool   allow_slugs Whether to allow post slugs in the shortlink. Not
      --                            used by default.
      --
      return Apply_Filters ("get_shortlink", -Shortlink, Id, Context, Allow_Slugs);
   end Wp_Get_Shortlink;

-- --
-- -- Injects rel=shortlink into the head if a shortlink is defined for the current page.
-- --
-- -- Attached to the {@see "wp_head"} action.
-- --
-- -- @since 3.0.0
-- --
-- function wp_shortlink_wp_head() then
--         shortlink = wp_get_shortlink( 0, "query" );

--         if ( empty( shortlink ) ) then
--                 return;
--         end;

--         echo "<link rel="shortlink" href="" . esc_url( shortlink ) . "" />\n";
-- end;

-- --
-- -- Sends a Link: rel=shortlink header if a shortlink is defined for the current page.
-- --
-- -- Attached to the {@see "wp"} action.
-- --
-- -- @since 3.0.0
-- --
-- function wp_shortlink_header() then
--         if ( headers_sent() ) then
--                 return;
--         end;

--         shortlink = wp_get_shortlink( 0, "query" );

--         if ( empty( shortlink ) ) then
--                 return;
--         end;

--         header( "Link: <" . shortlink . ">; rel=shortlink", false );
-- end;

-- --
-- -- Displays the shortlink for a post.
-- --
-- -- Must be called from inside "The Loop"
-- --
-- -- Call like the_shortlink( __( "Shortlinkage FTW" ) )
-- --
-- -- @since 3.0.0
-- --
-- -- @param string text   Optional The link text or HTML to be displayed. Defaults to "This is the short link."
-- -- @param string title  Optional The tooltip for the link. Must be sanitized. Defaults to the sanitized post title.
-- -- @param string before Optional HTML to display before the link. Default empty.
-- -- @param string after  Optional HTML to display after the link. Default empty.
-- --
-- function the_shortlink( text = "", title = "", before = "", after = "" ) then
--         post = get_post();

--         if ( empty( text ) ) then
--                 text = __( "This is the short link." );
--         end;

--         if ( empty( title ) ) then
--                 title = the_title_attribute( array( "echo" => false ) );
--         end;

--         shortlink = wp_get_shortlink( post->ID );

--         if ( ! empty( shortlink ) ) then
--                 link = "<a rel="shortlink" href="" . esc_url( shortlink ) . "" title="" . title . "">" . text . "</a>";

--                 --
--                 -- Filters the short link anchor tag for a post.
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param string link      Shortlink anchor tag.
--                 -- @param string shortlink Shortlink URL.
--                 -- @param string text      Shortlink"s text.
--                 -- @param string title     Shortlink"s title attribute.
--                 --
--                 link = apply_filters( "the_shortlink", link, shortlink, text, title );
--                 echo before, link, after;
--         end;
-- end;

   --------------------
   -- Get_Avatar_URL --
   --------------------

   function Get_Avatar_URL (Id_Or_Email : String;
                            Args        : Array_Type := Empty_Array) -- null
                            return String
   is
      Args_2 : constant Array_Type :=
        Get_Avatar_Data (Id_Or_Email, Args);
   begin
      return Get_As_String (Args_2, "url");
   end Get_Avatar_URL;

-- --
-- -- Check if this comment type allows avatars to be retrieved.
-- --
-- -- @since 5.1.0
-- --
-- -- @param string comment_type Comment type to check.
-- -- @return bool Whether the comment type is allowed for retrieving avatars.
-- --
-- function is_avatar_comment_type( comment_type ) then
--         --
--         -- Filters the list of allowed comment types for retrieving avatars.
--         --
--         -- @since 3.0.0
--         --
--         -- @param array types An array of content types. Default only contains "comment".
--         --
--         allowed_comment_types = apply_filters( "get_avatar_comment_types", array( "comment" ) );

--         return in_array( comment_type, (array) allowed_comment_types, true );
-- end;

   ---------------------
   -- Get_Avatar_Data --
   ---------------------

   function Get_Avatar_Data (Id_Or_Email : String;
                             Args        : Array_Type) -- = null
                             return Array_Type
   is
      use Ada.Strings.Unbounded;
      use Php.Arrays;
      use Php.Misc;
      use Php.Numerics;
      use Php.Strings;
      use Php.Types;
      use Hb_Common;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Load;
      use Inc_Options;
      use Inc_Plugins;

      Args_2 : Array_Type :=
        Wp_Parse_Args (
          Args,
          To_Array (List => (
            Build ("size",           96),
            Build ("height",         Null_Value),
            Build ("width",          Null_Value),
            Build ("default",
                   String'(Get_Option ("avatar_default", "mystery"))),
            Build ("force_default",  False),
            Build ("rating",
                   String'(Get_Option ("avatar_rating"))),
            Build ("scheme",         Null_Value),
            Build ("processed_args", Null_Value), -- If used, should be a reference.
            Build ("extra_attr",     "")
          ))
        );
   begin

      if Is_Numeric (Get_As_String (Args_2, "size")) then
         Set (Args_2, "size", From_Integer (abs As_Integer (Get (Args_2, "size"))));
         if Kind_Of (Get (Args_2, "size")) in Kind_Null then
            Set (Args_2, "size", From_Integer (96));
         end if;
      else
         Set (Args_2, "size", From_Integer (96));
      end if;

      if Is_Numeric (Get_As_String (Args_2, "height")) then
         Set (Args_2, "height",
              From_Integer (abs As_Integer (Get (Args_2, "height"))));
         if Kind_Of (Get (Args_2, "height")) in Kind_Null then
            Set (Args_2, "height", Get (Args_2, "size"));
         end if;
      else
         Set (Args_2, "height", Get (Args_2, "size"));
      end if;

      if Is_Numeric (Get_As_String (Args_2, "width")) then
         Set (Args_2, "width",
              From_Integer (abs As_Integer (Get (Args_2, "width"))));
         if Kind_Of (Get (Args_2, "width")) in Kind_Null then
            Set (Args_2, "width", Get (Args_2, "size"));
         end if;
      else
         Set (Args_2, "width", Get (Args_2, "size"));
      end if;

      if Empty (Args_2, "default") then
         Set (Args_2, "default",
              From_String (Get_Option ("avatar_default", "mystery")));
      end if;

      declare
         Default : constant String := Get_As_String (Args_2, "default");
      begin
         if Default in "mm" | "mystery" | "mysteryman" then
            Set (Args_2, "default", From_String ("mm"));
         elsif Default in "gravatar_default" then
            Set (Args_2, "default", From_Boolean (False));
         end if;
      end;

      Set (Args_2, "force_default",
           From_Boolean (As_Boolean (Get (Args_2, "force_default"))));

      Set (Args_2, "rating",
           From_String (Strtolower (Get_As_String (Args_2, "rating"))));

      Set (Args_2, "found_avatar", From_Boolean (False));

      --
      -- Filters whether to retrieve the avatar URL early.
      --
      -- Passing a non-null value in the "url" member of the return array will
      -- effectively short circuit get_avatar_data(), passing the value through
      -- the {@see "get_avatar_data"} filter and returning early.
      --
      -- @since 4.2.0
      --
      -- @param array args        Arguments passed to get_avatar_data(), after
      --                           processing.
      -- @param mixed id_or_email The avatar to retrieve. Accepts a user ID, Gravatar
      --                           MD5 hash, user email, WP_User object,
      --                           WP_Post object, or WP_Comment object.
      --
      Args_2 := Apply_Filters ("pre_get_avatar_data", Args_2, Id_Or_Email);

      if Isset (Args_2, "url") then
         -- This filter is documented in wp-includes/link-template.php
         return Apply_Filters ("get_avatar_data", Args_2, Id_Or_Email);
      end if;

      declare
         Id_Or_Email_2 : constant Unbounded_String := +Id_Or_Email;
         Email_Hash    : Unbounded_String;
         User       : Unbounded_String; -- Boolean := False;
         Email      : Unbounded_String; -- Boolean := False;
         Gravatar_Server : Natural;
      begin
--       if Is_Object (Id_Or_Email) and then Isset (Id_Or_Email.Comment_Id) then
--          Id_Or_Email := Get_Comment (Id_Or_Email);
--       end if;

         -- Process the user identifier.
--       if Is_Numeric (Id_Or_Email) then
--          User := Get_User_By ("id", abs Id_Or_Email);
--       elsif Is_String (Id_Or_Email) then
            if 0 /= Strpos (-Id_Or_Email_2, "@md5.gravatar.com") then
               -- MD5 hash.
               declare
                  L : constant List_Type := Explode ("@", -Id_Or_Email_2);
               begin
                  Email_Hash := L.First_Element;
               end;
            else
               -- Email address.
               Email := Id_Or_Email_2;
            end if;
         -- elsif id_or_email instanceof WP_User then
         --         -- User object.
         --         user = id_or_email;
         -- elsif id_or_email instanceof WP_Post then
         --         -- Post object.
         --         user = get_user_by( "id", (int) id_or_email->post_author );
         -- elsif id_or_email instanceof WP_Comment then
         --         if ( ! is_avatar_comment_type( get_comment_type( id_or_email ) ) ) then
         --                 args["url"] = false;
         --                 -- This filter is documented in wp-includes/link-template.php--
         --                 return apply_filters( "get_avatar_data", args, id_or_email );
         --         end if;

         --         if ( ! empty( id_or_email->user_id ) ) then
         --                 user = get_user_by( "id", (int) id_or_email->user_id );
         --         end if;
         --         if ( ( ! user || is_wp_error( user ) ) && ! empty( id_or_email->comment_author_email ) ) then
         --                 email = id_or_email->comment_author_email;
         --         end if;
--       end if;

         if Email_Hash = "" then -- not
--          if User /= "" then
--             Email := User.User_Email;
--          end if;

            if Email /= "" then
               Email_Hash := +MD5 (Strtolower (Trim (-Email)));
            end if;
         end if;

         if Email_Hash /= "" then
            Set (Args_2, "found_avatar", From_Boolean (True));
            Gravatar_Server := Hexdec ("" & Element (Email_Hash, 1)) mod 3;
         else
            Gravatar_Server := Rand (0, 2);
         end if;

         declare
            URL_Args : constant Array_Type := To_Array (List => (
                Build ("s", As_Integer (Get (Args_2, "size"))),
                Build ("d", Get_As_String (Args_2, "default")),
                Build ("f", (if As_Boolean (Get (Args_2, "force_default"))
                             then "y" else "False")),
                Build ("r", Get_As_String (Args_2, "rating"))
            ));

            URL : Unbounded_String;
         begin
            if Is_SSL then
               URL := +"https://secure.gravatar.com/avatar/" & Email_Hash;
            else
               URL := +Sprintf ("http://%d.gravatar.com/avatar/%s",
                                To_List (List => (
                                  +Helpers.Image (Gravatar_Server),
                                  Email_Hash)));
            end if;

            URL := +Add_Query_Arg (
                As_Array (Raw_URL_Encode_Deep (From_Array (Array_Filter (URL_Args)))),
                Set_URL_Scheme (-URL, Get_As_String (Args_2, "scheme"))
            );

            --
            -- Filters the avatar URL.
            --
            -- @since 4.2.0
            --
            -- @param string url         The URL of the avatar.
            -- @param mixed  id_or_email The avatar to retrieve. Accepts a user ID,
            --                            Gravatar MD5 hash, user email, WP_User
            --                            object, WP_Post object, or WP_Comment object.
            -- @param array  args        Arguments passed to get_avatar_data(), after
            --                            processing.
            --
            Set (Args_2, "url", From_String (
                 Apply_Filters ("get_avatar_url", -URL, -Id_Or_Email_2, Args_2)));

            --
            -- Filters the avatar data.
            --
            -- @since 4.2.0
            --
            -- @param array args        Arguments passed to get_avatar_data(), after
            --                           processing.
            -- @param mixed id_or_email The avatar to retrieve. Accepts a user ID,
            --                           Gravatar MD5 hash, user email, WP_User
            --                           object, WP_Post object, or WP_Comment object.
            --
            --
            return Apply_Filters ("get_avatar_data", Args_2, Id_Or_Email);
         end;
      end;
   end Get_Avatar_Data;

-- --
-- -- Retrieves the URL of a file in the theme.
-- --
-- -- Searches in the stylesheet directory before the template directory so themes
-- -- which inherit from a parent theme can just override one file.
-- --
-- -- @since 4.7.0
-- --
-- -- @param string file Optional. File to search for in the stylesheet directory.
-- -- @return string The URL of the file.
-- --
-- function get_theme_file_uri( file = "" ) then
--         file = ltrim( file, "/" );

--         if ( empty( file ) ) then
--                 url = get_stylesheet_directory_uri();
--         end; elseif ( file_exists( get_stylesheet_directory() . "/" . file ) ) then
--                 url = get_stylesheet_directory_uri() . "/" . file;
--         end; else then
--                 url = get_template_directory_uri() . "/" . file;
--         end;

--         --
--         -- Filters the URL to a file in the theme.
--         --
--         -- @since 4.7.0
--         --
--         -- @param string url  The file URL.
--         -- @param string file The requested file to search for.
--         --
--         return apply_filters( "theme_file_uri", url, file );
-- end;

-- --
-- -- Retrieves the URL of a file in the parent theme.
-- --
-- -- @since 4.7.0
-- --
-- -- @param string file Optional. File to return the URL for in the template directory.
-- -- @return string The URL of the file.
-- --
-- function get_parent_theme_file_uri( file = "" ) then
--         file = ltrim( file, "/" );

--         if ( empty( file ) ) then
--                 url = get_template_directory_uri();
--         end; else then
--                 url = get_template_directory_uri() . "/" . file;
--         end;

--         --
--         -- Filters the URL to a file in the parent theme.
--         --
--         -- @since 4.7.0
--         --
--         -- @param string url  The file URL.
--         -- @param string file The requested file to search for.
--         --
--         return apply_filters( "parent_theme_file_uri", url, file );
-- end;

-- --
-- -- Retrieves the path of a file in the theme.
-- --
-- -- Searches in the stylesheet directory before the template directory so themes
-- -- which inherit from a parent theme can just override one file.
-- --
-- -- @since 4.7.0
-- --
-- -- @param string file Optional. File to search for in the stylesheet directory.
-- -- @return string The path of the file.
-- --
-- function get_theme_file_path( file = "" ) then
--         file = ltrim( file, "/" );

--         if ( empty( file ) ) then
--                 path = get_stylesheet_directory();
--         end; elseif ( file_exists( get_stylesheet_directory() . "/" . file ) ) then
--                 path = get_stylesheet_directory() . "/" . file;
--         end; else then
--                 path = get_template_directory() . "/" . file;
--         end;

--         --
--         -- Filters the path to a file in the theme.
--         --
--         -- @since 4.7.0
--         --
--         -- @param string path The file path.
--         -- @param string file The requested file to search for.
--         --
--         return apply_filters( "theme_file_path", path, file );
-- end;

-- --
-- -- Retrieves the path of a file in the parent theme.
-- --
-- -- @since 4.7.0
-- --
-- -- @param string file Optional. File to return the path for in the template directory.
-- -- @return string The path of the file.
-- --
-- function get_parent_theme_file_path( file = "" ) then
--         file = ltrim( file, "/" );

--         if ( empty( file ) ) then
--                 path = get_template_directory();
--         end; else then
--                 path = get_template_directory() . "/" . file;
--         end;

--         --
--         -- Filters the path to a file in the parent theme.
--         --
--         -- @since 4.7.0
--         --
--         -- @param string path The file path.
--         -- @param string file The requested file to search for.
--         --
--         return apply_filters( "parent_theme_file_path", path, file );
-- end;

-- --
-- -- Retrieves the URL to the privacy policy page.
-- --
-- -- @since 4.9.6
-- --
-- -- @return string The URL to the privacy policy page. Empty string if it doesn"t exist.
-- --
-- function get_privacy_policy_url() then
--         url            = "";
--         policy_page_id = (int) get_option( "wp_page_for_privacy_policy" );

--         if ( ! empty( policy_page_id ) && get_post_status( policy_page_id ) === "publish" ) then
--                 url = (string) get_permalink( policy_page_id );
--         end;

--         --
--         -- Filters the URL of the privacy policy page.
--         --
--         -- @since 4.9.6
--         --
--         -- @param string url            The URL to the privacy policy page. Empty string
--         --                               if it doesn"t exist.
--         -- @param int    policy_page_id The ID of privacy policy page.
--         --
--         return apply_filters( "privacy_policy_url", url, policy_page_id );
-- end;

-- --
-- -- Displays the privacy policy link with formatting, when applicable.
-- --
-- -- @since 4.9.6
-- --
-- -- @param string before Optional. Display before privacy policy link. Default empty.
-- -- @param string after  Optional. Display after privacy policy link. Default empty.
-- --
-- function the_privacy_policy_link( before = "", after = "" ) then
--         echo get_the_privacy_policy_link( before, after );
-- end;

-- --
-- -- Returns the privacy policy link with formatting, when applicable.
-- --
-- -- @since 4.9.6
-- --
-- -- @param string before Optional. Display before privacy policy link. Default empty.
-- -- @param string after  Optional. Display after privacy policy link. Default empty.
-- -- @return string Markup for the link and surrounding elements. Empty string if it
-- --                doesn"t exist.
-- --
-- function get_the_privacy_policy_link( before = "", after = "" ) then
--         link               = "";
--         privacy_policy_url = get_privacy_policy_url();
--         policy_page_id     = (int) get_option( "wp_page_for_privacy_policy" );
--         page_title         = ( policy_page_id ) ? get_the_title( policy_page_id ) : "";

--         if ( privacy_policy_url && page_title ) then
--                 link = sprintf(
--                         "<a class="privacy-policy-link" href="%s">%s</a>",
--                         esc_url( privacy_policy_url ),
--                         esc_html( page_title )
--                 );
--         end;

--         --
--         -- Filters the privacy policy link.
--         --
--         -- @since 4.9.6
--         --
--         -- @param string link               The privacy policy link. Empty string if it
--         --                                   doesn"t exist.
--         -- @param string privacy_policy_url The URL of the privacy policy. Empty string
--         --                                   if it doesn"t exist.
--         --
--         link = apply_filters( "the_privacy_policy_link", link, privacy_policy_url );

--         if ( link ) then
--                 return before . link . after;
--         end;

--         return "";
-- end;

end Inc_Link_Templates;
