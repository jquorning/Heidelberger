--
-- WordPress Link Template Functions
--
-- @package WordPress
-- @subpackage Template
--

with Ada.Containers;

with Php.Arrays;
with Php.Echoing;
with Php.Files;
with Php.HTML;
with Php.Lists;
with Php.Misc;
with Php.Numerics;
with Php.Preg;
with Php.Strings;
with Php.Types;

with Constants;
with Globals;
with Helpers;
with Lists;
with UStrings;
with Wp_Common;

with Class_Admin_Bar; -- ???
with Class_Networks;
with Class_Post_Type;
with Class_Sites;
with Class_Taxonomy;
with Class_Terms;
with Inc_Author_Templates;
with Inc_Capabilities;
with Inc_Category_Templates;
with Inc_Feeds;
with Inc_Formatting;
with Inc_Functions;
with Inc_General_Templates;
with Inc_Load;
with Inc_Ms_Blogs;
with Inc_Ms_Functions;
with Inc_Ms_Networks;
with Inc_Options;
with Inc_Pluggables;
with Inc_Plugins;
with Inc_Post_Templates;
with Inc_Posts;
with Inc_Taxonomys;
with Inc_Themes;
with Inc_Users;
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
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;

      Item_2 : UString;
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
              (Post   : Class_Posts.Wp_Post; -- null
               Sample : Boolean := False) -- null
               return Boolean
   is
      use Inc_Capabilities;
      use Class_Posts;
      use Class_Post_Type;
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

   function Get_Permalink (Post      : Class_Posts.Wp_Post;
                           Leavename : Boolean := False)
                           return String
--   function Get_Permalink (Id        : Class_Posts.Post_Id := 0;
--                           Leavename : Boolean := False)
--                           return String
   is
      use Php.Lists;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Class_Posts;
      use Class_Terms;
      use Class_Users;
      use Class_Terms.Term_Vectors;
      use Inc_Category_Templates;
      use Inc_Load;
      use Inc_Options;
      use Inc_Pluggables;
      use Inc_Posts;
      use Inc_Taxonomys;
      use List_Vectors;

      Rewrite_Code : constant List_Type :=
        [
          "%year%",
          "%monthnum%",
          "%day%",
          "%hour%",
          "%minute%",
          "%second%",
          (if Leavename then "" else "%postname%"),
          "%post_id%",
          "%category%",
          "%author%",
          (if Leavename then "" else "%pagename%")
        ];

      Sample : Boolean;
      Permalink : UString;
   begin
      if
--      Is_Object (Post)    and then
        Isset (-Post.Filter) and then
        "sample" = Post.Filter
      then
         Sample := True;
      else
         Sample := False;
      end if;

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
            Category : List_Type; -- UString;
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
                        Category.Append (-Category_Object.Slug);
                        if Category_Object.Parent /= 0 then
                           Category.Prepend (
                             Get_Category_Parents (Category_Object.Parent,
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
                           Category := Empty_List & (-Default_Category.Slug);
                        end if;
                     end;
                  end if;
               end;

               declare
                  Author : UString;
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
                     L : constant List_Type := ["-", ":"];

                     Date : constant List_Type :=
                       Explode (" ", Str_Replace (L, " ", -Post.Post_Date));

                     Rewrite_Replace : constant List_Type := [
                        Date (1),
                        Date (2),
                        Date (3),
                        Date (4),
                        Date (5),
                        Date (6),
                        -Post.Post_Name,
                        Helpers.Image (Integer (Post.Id)),
                        Category.First_Element, -- First_Element added
                        -Author,
                        -Post.Post_Name
                     ];
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

   -------------------
   -- Get_Permalink --
   -------------------

   function Get_Permalink (Id        : Class_Posts.Post_Id_Type := 0;
                           Leavename : Boolean := False)
                           return String
   is
      use Class_Posts;
      use Inc_Posts;

      Post : constant Wp_Post := Get_Post (Id);
   begin
      return Get_Permalink (Post, Leavename);
   end Get_Permalink;

   ------------------------
   -- Get_Post_Permalink --
   ------------------------

   function Get_Post_Permalink (Id        : Class_Posts.Wp_Post; -- = 0,
                                Leavename : Boolean := False;
                                Sample    : Boolean := False)
                                return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Class_Posts;
      use Class_Post_Type;
      use Inc_Functions;
      use Inc_Posts;
--    use Inc_Plugins;

      Post : constant Wp_Post := Get_Post (Id);
   begin
      if Post = Null_Post then
         return ""; -- false;
      end if;

      declare
         Post_Link : UString :=
           +Global_Wp_Rewrite.Get_Extra_Permastruct (-Post.Post_Type);

         Slug : String := -Post.Post_Name;

         Force_Plain_Link : constant Boolean := Wp_Force_Plain_Post_Permalink (Post);

         Post_Type : constant Wp_Post_Type := Get_Post_Type_Object (-Post.Post_Type);
      begin
         if Post_Type.Hierarchical then
            Slug := Get_Page_URI (Post);
         end if;

         if
           not Empty (Post_Link) and then
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

   function Get_Page_Link (Post      : Class_Posts.Wp_Post;
                           Leavename : Boolean := False;
                           Sample    : Boolean := False)
                           return String
   is
      use UStrings;
      use Wp_Common;
      use Class_Posts;
      use Inc_Posts;
--    use Inc_Plugins;
      use Inc_Options;

      Post_2 : constant Wp_Post := Get_Post (Post);
      Link   : UString;
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

   function X_Get_Page_Link (Post      : Class_Posts.Wp_Post; -- = false,
                             Leavename : Boolean := False;
                             Sample    : Boolean := False)
                             return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Class_Posts;
      use Inc_Posts;

--        global wp_rewrite;

      Post_2 : constant Wp_Post := Get_Post (Post);

      Force_Plain_Link : constant Boolean := Wp_Force_Plain_Post_Permalink (Post_2);

      Link : UString := +Global_Wp_Rewrite.Get_Page_Permastruct;
   begin
      if
        not Empty (Link) and then
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

   function Get_Attachment_Link (Post      : Class_Posts.Wp_Post; -- null
                                 Leavename : Boolean := False)
                                 return String
   is
      use Php.Strings;
      use Php.Types;
      use UStrings;
      use Wp_Common;
      use Class_Posts;
      use Inc_Formatting;
      use Inc_Options;
      use Inc_Posts;

      Link : UString; -- Boolean := false;

      Post_2           : constant Wp_Post := Get_Post (Post);
      Force_Plain_Link : constant Boolean := Wp_Force_Plain_Post_Permalink (Post_2);
      Parent_Id        : constant Post_Id_Type := Post_2.Post_Parent;
      Parent           : Wp_Post := (if Parent_Id /= 0
                                     then Get_Post (Parent_Id)
                                     else Null_Post); -- False);
      Parent_Valid     : Boolean := True; -- Default for no parent.
      Parentlink       : UString;
      Name             : UString;
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
         Link := Null_UString; -- False;
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

   -------------------
   -- Get_Feed_Link --
   -------------------

   function Get_Feed_Link (Feed : String := "")
                           return String
   is
      use Php.Preg;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Class_Rewrites;
      use Inc_Feeds;

--    global wp_rewrite;
      Permalink : UString := +Global_Wp_Rewrite.Get_Feed_Permastruct;
      Feed_2 : UString := +Feed;
      Output : UString;
   begin
      if Permalink /= "" then
         if 0 /= Strpos (Feed, "comments_") then
            Feed_2    := +Str_Replace ("comments_", "", Feed);
            Permalink := +Global_Wp_Rewrite.Get_Comment_Feed_Permastruct;
         end if;

         if Get_Default_Feed = Feed_2 then
            Feed_2 := Null_UString;
         end if;

         Permalink := +Str_Replace ("%feed%", -Feed_2, -Permalink);
         Permalink := +Preg_Replace ("#/+#", "/", "/" & (-Permalink));
         Output    := +Home_URL (User_Trailing_Slash_It (-Permalink, "feed"));

      else
         if Empty (Feed) then
            Feed_2 := +Get_Default_Feed;
         end if;

         if 0 /= Strpos (-Feed_2, "comments_") then
            Feed_2 := +Str_Replace ("comments_", "comments-", Feed);
         end if;

         Output := +Home_URL ("?feed=" & (-Feed_2));
      end if;

      --
      -- Filters the feed type permalink.
      --
      -- @since 1.5.0
      --
      -- @param string output The feed permalink.
      -- @param string feed   The feed type. Possible values include "rss2", "atom",
      --                       or an empty string for the default feed type.
      --
      return Apply_Filters ("feed_link", -Output, -Feed_2);
   end Get_Feed_Link;

   ---------------------------------
   -- Get_Post_Comments_Feed_Link --
   ---------------------------------

   function Get_Post_Comments_Feed_Link (Post_Id : Class_Posts.Post_Id_Type := 0;
                                         Feed    : String                   := "")
                                         return String
   is
      use Php.Strings;
      use Wp_Common;
      use UStrings;
      use Class_Posts;
      use Inc_Feeds;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Options;
      use Inc_Posts;
      use Inc_Post_Templates;
--    post_id = absint( post_id );

      Post_Id_2 : constant Class_Posts.Post_Id_Type :=
        (if Post_Id = 0 then Get_The_Id else Post_Id);

      Feed_2 : constant String :=
        (if Empty (Feed) then Get_Default_Feed else Feed);

      Post : constant Wp_Post := Get_Post (Post_Id_2);

      URL : UString;
   begin
      -- -- Bail out if the post does not exist.
      -- if not post in Wp_Post then -- instanceof
      --    return "";
      -- end if;

      declare
         Unattached : constant Boolean :=
           "attachment" = Post.Post_Type and then
           0 = Post.Post_Parent; -- (int)
      begin
         if Get_Option ("permalink_structure") then
            if
              "page" = Get_Option ("show_on_front") and then
              Get_Option ("page_on_front") = Integer (Post_Id_2)
            then
               URL := +X_Get_Page_Link (Post_Id_2);
            else
               URL := +Get_Permalink (Post_Id_2);
            end if;

            if Unattached then
               URL := +Home_URL ("/feed/");
               if Get_Default_Feed /= Feed_2 then
                  Append (URL, "feed/");
               end if;
               URL := +Add_Query_Arg ("attachment_id", Image (Post_Id_2), -URL);
            else
               URL := +Trailing_Slash_It (-URL) & "feed";
               if Get_Default_Feed /= Feed_2 then
                  Append (URL, "/feed");
               end if;
               URL := +User_Trailing_Slash_It (-URL, "single_feed");
            end if;

         else
            if Unattached then
               URL :=
                 +Add_Query_Arg (
                    To_Array (List => (
                      Build ("feed",          Feed),
                      Build ("attachment_id", Integer (Post_Id))
                    )),
                    Home_URL ("/")
                  );
            elsif "page" = Post.Post_Type then
               URL :=
                 +Add_Query_Arg (
                    To_Array (List => (
                      Build ("feed",    Feed),
                      Build ("page_id", Integer (Post_Id))
                    )),
                    Home_URL ("/")
                  );
            else
               URL :=
                 +Add_Query_Arg (
                    To_Array (List => (
                      Build ("feed", Feed),
                      Build ("p",    Integer (Post_Id))
                    )),
                    Home_URL ("/")
                  );
            end if;
         end if;

         --
         -- Filters the post comments feed permalink.
         --
         -- @since 1.5.1
         --
         -- @param string url Post comments feed permalink.
         --
         return Apply_Filters ("post_comments_feed_link", -URL);
      end;
   end Get_Post_Comments_Feed_Link;

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

   --------------------------
   -- Get_Author_Feed_Link --
   --------------------------

   function Get_Author_Feed_Link (Author_Id : Integer;
                                  Feed      : String := "")
                                  return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Author_Templates;
      use Inc_Feeds;
      use Inc_Formatting;
      use Inc_Options;

--    author_id           = (int) author_id;
      Permalink_Structure : constant Boolean := Get_Option ("permalink_structure");

      Feed_2 : String :=
        (if Empty (Feed) then Get_Default_Feed else Feed);

      Link      : UString;
      Feed_Link : UString;
   begin
      if not Permalink_Structure then
         Link := +Home_URL ("?feed=" & Feed_2 & "&amp;author=" &
                            Helpers.Image (Author_Id));
      else
         Link := +Get_Author_Posts_Url (Author_Id);
         if Get_Default_Feed = Feed_2 then
            Feed_Link := +"feed";
         else
            Feed_Link := +"feed/feed";
         end if;

         Link :=
           +Trailing_Slash_It (-Link) & User_Trailing_Slash_It (-Feed_Link, "feed");
      end if;

      --
      -- Filters the feed link for a given author.
      --
      -- @since 1.5.1
      --
      -- @param string link The author feed link.
      -- @param string feed Feed type. Possible values include "rss2", "atom".
      --
      Link := +Apply_Filters ("author_feed_link", -Link, Feed_2);

      return -Link;
   end Get_Author_Feed_Link;

   ----------------------------
   -- Get_Category_Feed_Link --
   ----------------------------

   function Get_Category_Feed_Link (Cat  : Integer;
                                    Feed : String := "")
                                    return String
   is
   begin
      return Get_Term_Feed_Link (Cat, "category", Feed);
   end Get_Category_Feed_Link;

   ------------------------
   -- Get_Term_Feed_Link --
   ------------------------

   function Get_Term_Feed_Link (Term     : Integer;
                                Taxonomy : String := "";
                                Feed     : String := "")
                                return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Class_Taxonomy;
      use Class_Terms;
      use Inc_Feeds;
      use Inc_Formatting;
      use Inc_Load;
      use Inc_Options;
      use Inc_Taxonomys;

      Term_2 : constant Integer := Term;
--      (if not Is_Object (Term) then Term else Term);  -- (int)

      Term_3 : constant Wp_Term := Get_Term (Term_2, Taxonomy);
   begin
      if Term_3 = Null_Term or else Is_Wp_Error (Term_3) then
         return ""; -- false;
      end if;

      declare
         Taxonomy : constant String := -Term_3.Taxonomy;

         Feed_2 : constant String :=
           (if Empty (Feed) then Get_Default_Feed else Feed);

         Permalink_Structure : constant Boolean :=
           Get_Option ("permalink_structure");

         Link      : UString;
         Feed_Link : UString;
      begin
         if not Permalink_Structure then
            if "category" = Taxonomy then
               Link := +Home_URL ("?feed=" & Feed_2 & "&amp;cat=" &
                                  Helpers.Image (Term_3.Term_Id));
            elsif "post_tag" = Taxonomy then
               Link := +Home_URL ("?feed=" & Feed_2 & "&amp;tag=" & (-Term_3.Slug));
            else
               declare
                  T : constant Wp_Taxonomy := Get_Taxonomy (Taxonomy);
               begin
                  Link := +Home_URL ("?feed=" & Feed_2 & "&amp;" &
                                     (-T.Query_Var) & "=" & (-Term_3.Slug));
               end;
            end if;
         else
            Link := +Get_Term_Link (Term_3, -Term_3.Taxonomy);
            if Get_Default_Feed = Feed_2 then
               Feed_Link := +"feed";
            else
               Feed_Link := +"feed/feed";
            end if;

            Link :=
              +Trailing_Slash_It (-Link) &
              User_Trailing_Slash_It (-Feed_Link, "feed");
         end if;

         if "category" = Taxonomy then
            --
            -- Filters the category feed link.
            --
            -- @since 1.5.1
            --
            -- @param string link The category feed link.
            -- @param string feed Feed type. Possible values include "rss2", "atom".
            --
            Link := +Apply_Filters ("category_feed_link", -Link, Feed_2);

         elsif "post_tag" = Taxonomy then
            --
            -- Filters the post tag feed link.
            --
            -- @since 2.3.0
            --
            -- @param string link The tag feed link.
            -- @param string feed Feed type. Possible values include "rss2", "atom".
            --
            Link := +Apply_Filters ("tag_feed_link", -Link, Feed_2);

         else
            --
            -- Filters the feed link for a taxonomy other than "category" or
            -- "post_tag".
            --
            -- @since 3.0.0
            --
            -- @param string link     The taxonomy feed link.
            -- @param string feed     Feed type. Possible values include "rss2",
            --                        "atom".
            -- @param string taxonomy The taxonomy name.
            --
            Link := +Apply_Filters ("taxonomy_feed_link", -Link, Feed_2, Taxonomy);
         end if;

         return -Link;
      end;
   end Get_Term_Feed_Link;

   -----------------------
   -- Get_Tag_Feed_Link --
   -----------------------

   function Get_Tag_Feed_Link (Tag  : Integer;
                               Feed : String := "")
                               return String
   is
   begin
      return Get_Term_Feed_Link (Tag, "post_tag", Feed);
   end Get_Tag_Feed_Link;

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

   ------------------------
   -- Get_Edit_Term_Link --
   ------------------------

   function Get_Edit_Term_Link (Term        : Integer;
                                Taxonomy    : String := "";
                                Object_Type : String := "")
                                return String
   is
      use UStrings;
      use Wp_Common;
      use Inc_Capabilities;
      use Class_Taxonomy;
      use Class_Terms;
      use Inc_Functions;
      use Inc_Load;
      use Inc_Taxonomys;

      Term_2 : constant Wp_Term := Get_Term (Term, Taxonomy);
   begin
      if
        Term_2 = Null_Term or else
--      not Term_2 or else
        Is_Wp_Error (Term_2)
      then
         return "";
      end if;

      declare
         Tax     : constant Wp_Taxonomy := Get_Taxonomy (-Term_2.Taxonomy);
         Term_Id : constant Integer := Term_2.Term_Id;
      begin
         if
           Tax = Null_Taxonomy or else not
--         not Tax or else not
           Current_User_Can ("edit_term", Term_Id)
         then
            return "";
         end if;

         declare
            Args : Array_Type := To_Array (List => (
              Build ("taxonomy", Taxonomy),
              Build ("tag_ID",   Term_Id)
            ));

            Location : UString;
         begin
            if Object_Type /= "" then
               Set (Args, "post_type", From_String (Object_Type));
            elsif not Tax.Object_Type.Is_Empty then
--          elsif not Empty (Tax.Object_Type) then
               Set (Args, "post_type",
                    From_String (Tax.Object_Type.First_Element));
--             Set (Args, "post_type", Reset (Tax.Object_Type));
            end if;

            if Tax.Show_UI then
               Location := +Add_Query_Arg (Args, Admin_URL ("term.php"));
            else
               Location := Null_UString;
            end if;

            --
            -- Filters the edit link for a term.
            --
            -- @since 3.1.0
            --
            -- @param string location    The edit link.
            -- @param int    term_id     Term ID.
            -- @param string taxonomy    Taxonomy name.
            -- @param string object_type The object type.
            --
            return Apply_Filters ("get_edit_term_link", -Location,
                                  Term_Id, Taxonomy, Object_Type);
         end;
      end;
   end Get_Edit_Term_Link;

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

   ---------------------
   -- Get_Search_Link --
   ---------------------

   function Get_Search_Link (Query : String := "")
                             return String
   is
      use Php.HTML;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_General_Templates;
--    global wp_rewrite;

      Search : UString :=
        (if Empty (Query)
         then +Get_Search_Query (False)
         else +Strip_Slashes (Query));

      Permastruct : constant String :=
        Global_Wp_Rewrite.Get_Search_Permastruct;

      Link : UString;
   begin
      if Empty (Permastruct) then
         Link := +Home_URL ("?s=" & URL_Encode (-Search));
      else
         Search := +URL_Encode (-Search);
         Search := +Str_Replace ("%2F", "/", -Search);
         -- %2F(/) is not valid within a URL, send it un-encoded.
         Link   := +Str_Replace ("%search%", -Search, Permastruct);
         Link   := +Home_URL (User_Trailing_Slash_It (-Link, "search"));
      end if;

      --
      -- Filters the search permalink.
      --
      -- @since 3.0.0
      --
      -- @param string link   Search permalink.
      -- @param string search The URL-encoded search term.
      --
      return Apply_Filters ("search_link", -Link, -Search);
   end Get_Search_Link;

   --------------------------
   -- Get_Search_Feed_Link --
   --------------------------

   function Get_Search_Feed_Link (Search_Query : String := "";
                                  Feed         : String := "")
                                  return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Feeds;
      use Inc_Formatting;
      use Inc_Functions;

--    global wp_rewrite;
      Link : UString := +Get_Search_Link (Search_Query);

      Feed_2 : constant String :=
        (if Empty (Feed) then Get_Default_Feed else Feed);

      Permastruct : constant String :=
        Global_Wp_Rewrite.Get_Search_Permastruct;
   begin
      if Empty (Permastruct) then
         Link := +Add_Query_Arg ("feed", Feed_2, -Link);
      else
         Link := +Trailing_Slash_It (-Link);
         Append (Link, "feed/feed/");
      end if;

      --
      -- Filters the search feed link.
      --
      -- @since 2.5.0
      --
      -- @param string link Search feed link.
      -- @param string feed Feed type. Possible values include "rss2", "atom".
      -- @param string type The search type. One of "posts" or "comments".
      --
      return Apply_Filters ("search_feed_link", -Link, Feed_2, "posts");
   end Get_Search_Feed_Link;

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
      use Php.Types;
      use UStrings;
      use Wp_Common;
      use Class_Post_Type;
      use Class_Posts;
      use Inc_Options;
      use Inc_Posts;

      Post_Type_Obj : constant Wp_Post_Type := Get_Post_Type_Object (Post_Type);
      Link          : UString;
   begin
      if Post_Type_Obj = Null_Post_Type then -- !
         return ""; -- false;
      end if;

      if "post" = Post_Type then
         declare
            Show_On_Front  : constant String  := Get_Option ("show_on_front");

            Page_For_Posts : constant Class_Posts.Post_Id_Type :=
              Class_Posts.Post_Id_Type (Integer'(Get_Option ("page_for_posts")));
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

   -------------------------------------
   -- Get_Post_Type_Archive_Feed_Link --
   -------------------------------------

   function Get_Post_Type_Archive_Feed_Link (Post_Type : String;
                                             Feed      : String := "")
                                             return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Class_Post_Type;
      use Inc_Feeds;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Options;
      use Inc_Posts;

      Default_Feed : constant String := Get_Default_Feed;

      Feed_2 : String :=
        (if Empty (Feed) then Default_Feed else Feed);

      Link : UString := +Get_Post_Type_Archive_Link (Post_Type);
   begin
      if Link = "" then
         return ""; -- false;
      end if;

      declare
         Post_Type_Obj : constant Wp_Post_Type := Get_Post_Type_Object (Post_Type);
      begin
         if
           Get_Option ("permalink_structure") and then
--         Is_Array (Post_Type_Obj.Rewrite)   and then
           "" /= Get_As_String (Post_Type_Obj.Rewrite, "feeds")
         then
            Link := +Trailing_Slash_It (-Link);
            Append (Link, "feed/");
            if Feed_2 /= Default_Feed then
               Append (Link, "feed/");
            end if;
         else
            Link := +Add_Query_Arg ("feed", Feed_2, -Link);
         end if;
      end;

      --
      -- Filters the post type archive feed link.
      --
      -- @since 3.1.0
      --
      -- @param string link The post type archive feed link.
      -- @param string feed Feed type. Possible values include "rss2", "atom".
      --
      return Apply_Filters ("post_type_archive_feed_link", -Link, Feed_2);
   end Get_Post_Type_Archive_Feed_Link;

   ---------------------------
   -- Get_Preview_Post_Link --
   ---------------------------

   function Get_Preview_Post_Link
      (Post         : Class_Posts.Wp_Post := Class_Posts.Null_Post;
       Query_Args   : Array_Type := Empty_Array;
       Preview_Link : String     := "")
       return String
   is
      use UStrings;
      use Wp_Common;
      use Class_Posts;
      use Class_Post_Type;
      use Inc_Functions;
      use Inc_Posts;

      Query_Args_2 : Array_Type := Query_Args;
      Post_2 : constant Wp_Post := Get_Post (Post);
   begin
      if Post_2 = Null_Post then
         return "";
      end if;

      declare
         Post_Type_Object : constant Wp_Post_Type :=
           Get_Post_Type_Object (-Post_2.Post_Type);

         Preview_Link_2 : UString;
      begin
         if Is_Post_Type_Viewable (Post_Type_Object) then
            if Preview_Link = "" then
               Preview_Link_2 := +Set_URL_Scheme (Get_Permalink (Post_2));
            end if;

            Set (Query_Args_2, "preview", From_String ("true"));
            Preview_Link_2 := +Add_Query_Arg (Query_Args_2, -Preview_Link_2);
         end if;

         --
         -- Filters the URL used for a post preview.
         --
         -- @since 2.0.5
         -- @since 4.0.0 Added the `post` parameter.
         --
         -- @param string  preview_link URL used for the post preview.
         -- @param WP_Post post         Post object.
         --
         return Apply_Filters ("preview_post_link", -Preview_Link_2, Post_2);
      end;
   end Get_Preview_Post_Link;

   ------------------------
   -- Get_Edit_Post_Link --
   ------------------------

   function Get_Edit_Post_Link (Post    : Integer := 0;
                                Context : String  := "display")
                                return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Capabilities;
      use Class_Posts;
      use Class_Post_Type;
      use Inc_Posts;

      Post_2 : constant Wp_Post := Get_Post (Post_Id_Type (Post));
      Action : UString;
      Link   : UString;
   begin
      if Post_2 = Null_Post then
         return "";
      end if;

      if "revision" = Post_2.Post_Type then
         Action := Null_UString;
      elsif "display" = Context then
         Action := +"&amp;action=edit";
      else
         Action := +"&action=edit";
      end if;

      declare
         Post_Type_Object : constant Wp_Post_Type :=
           Get_Post_Type_Object (-Post_2.Post_Type);
      begin
         if Post_Type_Object = Null_Post_Type then
--       if not Post_Type_Object then
            return "";
         end if;

         if not Current_User_Can ("edit_post", Integer (Post_2.Id)) then
            return "";
         end if;

         if Post_Type_Object.X_Edit_Link /= "" then
            Link :=
              +Admin_URL (Sprintf (-(Post_Type_Object.X_Edit_Link & Action),
                                   [1 => Helpers.Image (Integer (Post_2.Id))]));
         else
            Link := Null_UString;
         end if;
      end;

      --
      -- Filters the post edit link.
      --
      -- @since 2.3.0
      --
      -- @param string link    The edit link.
      -- @param int    post_id Post ID.
      -- @param string context The link context. If set to "display" then ampersands
      --                        are encoded.
      --
      return Apply_Filters ("get_edit_post_link", -Link,
                            Integer (Post_2.Id), Context);
   end Get_Edit_Post_Link;

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

   ------------------------
   -- Get_Edit_User_Link --
   ------------------------

   function Get_Edit_User_Link (User_Id : Class_Users.User_Id_Type := 0) -- = null
                                return String
   is
      use UStrings;
      use Wp_Common;
      use Class_Users;
      use Inc_Capabilities;
      use Inc_Functions;
      use Inc_Pluggables;
      use Inc_Users;

      User_Id_2 : constant Class_Users.User_Id_Type :=
        (if User_Id = 0
         then Get_Current_User_Id
         else User_Id);

      Link : UString;
   begin
      if
        User_Id_2 = 0 or else -- Empty (User_Id_2) or else
        not Current_User_Can ("edit_user", Integer (User_Id_2))
      then
         return "";
      end if;

      declare
         User : constant Wp_User := Get_Userdata (User_Id_2);
      begin
         if User = Null_User then
            return "";
         end if;

         if Get_Current_User_Id = User.Id then
            Link := +Get_Edit_Profile_URL (User.Id);
         else
            Link :=
              +Add_Query_Arg ("user_id", Helpers.Image (Integer (User.Id)), -- ???
                              Self_Admin_URL ("user-edit.php"));
         end if;

         --
         -- Filters the user edit link.
         --
         -- @since 3.5.0
         --
         -- @param string link    The edit link.
         -- @param int    user_id User ID.
         --
         return Apply_Filters ("get_edit_user_link", -Link, Integer (User.Id));
      end;
   end Get_Edit_User_Link;

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
      use Php.HTML;
      use Php.Preg;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_Load;
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

      Result : UString;
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
            Query_String : UString;
         begin
            Preg_Match (Qs_Regex, Request, Qs_Match);

            if Qs_Match.Length >= 1 then
--          if ( ! empty( qs_match[0] ) ) then
               Query_String := +Qs_Match (1); -- [0];
               Request      := Preg_Replace (Qs_Regex, "", Request);
            else
               Query_String := Null_UString;
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

               Base : UString := +Trailing_Slash_It (Get_Bloginfo ("url"));

               Request_7 : UString;
            begin
               if
                 Global_Wp_Rewrite.Using_Index_Permalinks and then
                 (Pagenum > 1 or "" /= Request_6)
               then
                  Append (Base, Global_Wp_Rewrite.Index & "/");
               end if;

               if Pagenum > 1 then
                  Request_7 :=
                    +(if not Empty (Request_7)
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

   --------------
   -- Home_URL --
   --------------

   function Home_URL (Path   : String := "";
                      Scheme : String := "") --  = null
                      return String
   is
   begin
      return Get_Home_URL (0, Path, Scheme); -- null
   end Home_URL;

   ------------------
   -- Get_Home_URL --
   ------------------

   function Get_Home_URL (Blog_Id : Integer := 0;
                          Path    : String  := "";
                          Scheme  : String  := "")
                          return String
   is
      use Php.HTML;
      use Php.Lists;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Load;
      use Inc_Ms_Blogs;
      use Inc_Options;

      Orig_Scheme : constant String := Scheme;
      URL      : UString;
      Scheme_2 : UString;
   begin
      if
        Blog_Id = 0 or else -- Empty (Blog_Id) or else
        not Is_Multisite
      then
         URL := +Get_Option ("home");
      else
         Switch_To_Blog (Blog_Id);
         URL := +Get_Option ("home");
         Restore_Current_Blog;
      end if;

      if
        not In_List (Scheme, List_Type'["http", "https", "relative"], True)
      then
         if Is_SSL then
            Scheme_2 := +"https";
         else
            Scheme_2 := +Parse_URL (-URL, PHP_URL_SCHEME);
         end if;
      end if;

      URL := +Set_URL_Scheme (-URL, -Scheme_2);

      if Path /= "" then -- and then Is_String (Path) then
         Append (URL, "/" & Ltrim (Path, "/"));
      end if;

      --
      -- Filters the home URL.
      --
      -- @since 3.0.0
      --
      -- @param string      url         The complete home URL including scheme and path.
      -- @param string      path        Path relative to the home URL. Blank string
      --                                if no path is specified.
      -- @param string|null orig_scheme Scheme to give the home URL context. Accepts
      --                                "http", "https", "relative", "rest", or null.
      -- @param int|null    blog_id     Site ID, or null for the current site.
      --
      return Apply_Filters ("home_url", -URL, Path, Orig_Scheme, Blog_Id);
   end Get_Home_URL;

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
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Load;
      use Inc_Ms_Blogs;
      use Inc_Options;

      URL : UString;
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

   ---------------
   -- Admin_URL --
   ---------------

   function Admin_URL (Path   : String := "";
                       Scheme : String := "admin")
                       return String
   is
   begin
      return Get_Admin_URL (0, Path, Scheme); -- null
   end Admin_URL;

   -------------------
   -- Get_Admin_URL --
   -------------------

   function Get_Admin_URL (Blog_Id : Integer := 0; --  = null
                           Path    : String  := "";
                           Scheme  : String  := "admin")
                           return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;

      URL : UString := +Get_Site_URL (Blog_Id, "wp-admin/", Scheme);
   begin
      if Path /= "" then --  && is_string( path ) ) then
         Append (URL, Ltrim (Path, "/"));
      end if;

      --
      -- Filters the admin area URL.
      --
      -- @since 2.8.0
      -- @since 5.8.0 The `scheme` parameter was added.
      --
      -- @param string      url     The complete admin area URL including scheme
      --                            and path.
      -- @param string      path    Path relative to the admin area URL. Blank
      --                            string if no path is specified.
      -- @param int|null    blog_id Site ID, or null for the current site.
      -- @param string|null scheme  The scheme to use. Accepts "http", "https",
      --                            "admin", or null. Default "admin", which obeys
      --                            force_ssl_admin() and is_ssl().
      --
      return Apply_Filters ("admin_url", -URL, Path, Blog_Id, Scheme);
   end Get_Admin_URL;

   ------------------
   -- Includes_URL --
   ------------------

   function Includes_URL (Path   : String := "";
                          Scheme : String := "") -- null
                          return String
   is
      use Php.Strings;
      use Globals;
      use UStrings;
      use Wp_Common;

      URL_2 : constant String := Site_URL ("/" & (-WPINC) & "/", Scheme);

      URL : constant String :=
        (if Path /= ""
         then URL_2 & Ltrim (Path, "/")
         else URL_2);
   begin
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
      return Apply_Filters ("includes_url", URL, Path, Scheme);
   end Includes_URL;

   -----------------
   -- Content_URL --
   -----------------

   function Content_URL (Path : String := "")
                         return String
   is
      use Php.Strings;
      use Constants;
      use UStrings;
      use Wp_Common;

      URL : constant String :=
        (if Path /= "" -- and then Is_String (Path)
         then Set_URL_Scheme (-WP_CONTENT_URL) & "/" & Ltrim (Path, "/")
         else Set_URL_Scheme (-WP_CONTENT_URL));
   begin
      --
      -- Filters the URL to the content directory.
      --
      -- @since 2.8.0
      --
      -- @param string url  The complete URL to the content directory including
      --                    scheme and path.
      -- @param string path Path relative to the URL to the content directory.
      --                    Blank string if no path is specified.
      --
      return Apply_Filters ("content_url", URL, Path);
   end Content_URL;

   -----------------
   -- Plugins_URL --
   -----------------

   function Plugins_URL (Path   : String := "";
                         Plugin : String := "")
                         return String
   is
      use Php.Files;
      use Php.Strings;
      use Constants;
      use UStrings;
      use Wp_Common;
      use Inc_Functions;
      use Inc_Plugins;

      Path_2        : constant String := Wp_Normalize_Path (Path);
      Plugin_2      : constant String := Wp_Normalize_Path (Plugin);
      MU_Plugin_Dir : constant String := Wp_Normalize_Path (-WPMU_PLUGIN_DIR);

      URL_2 : constant String :=
        (if
           not Empty (Plugin_2) and then
           0 = Strpos (Plugin_2, MU_Plugin_Dir)
         then -WPMU_PLUGIN_URL
         else -WP_PLUGIN_URL);

      URL : UString := +Set_URL_Scheme (URL_2);
   begin
      if not Empty (Plugin_2) then -- and then Is_String (Plugin_2) then
         declare
            Folder : constant String := Dirname (Plugin_Basename (Plugin_2));
         begin
            if "." /= Folder then
               Append (URL, "/" & Ltrim (Folder, "/"));
            end if;
         end;
      end if;

      if Path_2 /= "" then -- and then Is_String (Path_2) then
         Append (URL, "/" & Ltrim (Path_2, "/"));
      end if;

      --
      -- Filters the URL to the plugins directory.
      --
      -- @since 2.8.0
      --
      -- @param string url    The complete URL to the plugins directory including
      --                      scheme and path.
      -- @param string path   Path relative to the URL to the plugins directory.
      --                      Blank string if no path is specified.
      -- @param string plugin The plugin file path to be relative to. Blank string
      --                      if no plugin is specified.
      --
      return Apply_Filters ("plugins_url", -URL, Path_2, Plugin_2);
   end Plugins_URL;

   ----------------------
   -- Network_Site_URL --
   ----------------------

   function Network_Site_URL (Path   : String := "";
                              Scheme : String := "") -- null
                              return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Class_Networks;
      use Inc_Load;
      use Inc_Ms_Networks;

      URL : UString;
   begin
      if not Is_Multisite then
         return Site_URL (Path, Scheme);
      end if;

      declare
         Current_Network : constant Wp_Network := Get_Network;
      begin
         if "relative" = Scheme then
            URL := Current_Network.Path;
         else
            URL :=
              +Set_URL_Scheme
                 ("http://" &
                  (-Current_Network.Domain) &
                  (-Current_Network.Path),
                  Scheme);
         end if;

         if Path /= "" then --  && is_string( path ) ) then
            Append (URL, Ltrim (Path, "/"));
         end if;
      end;

      --
      -- Filters the network site URL.
      --
      -- @since 3.0.0
      --
      -- @param string      url    The complete network site URL including scheme
      --                           and path.
      -- @param string      path   Path relative to the network site URL. Blank
      --                           string if no path is specified.
      -- @param string|null scheme Scheme to give the URL context. Accepts "http",
      --                           "https", "relative" or null.
      --
      return Apply_Filters ("network_site_url", -URL, Path, Scheme);
   end Network_Site_URL;

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

   -----------------------
   -- Network_Admin_URL --
   -----------------------

   function Network_Admin_URL (Path   : String := "";
                               Scheme : String := "admin")
                               return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Load;
   begin
      if not Is_Multisite then
         return Admin_URL (Path, Scheme);
      end if;

      declare
         URL : UString :=
           +Network_Site_URL ("wp-admin/network/", Scheme);
      begin
         if Path /= "" then --  && is_string( path ) ) then
            Append (URL, Ltrim (Path, "/"));
         end if;

         --
         -- Filters the network admin URL.
         --
         -- @since 3.0.0
         -- @since 5.8.0 The `scheme` parameter was added.
         --
         -- @param string      url    The complete network admin URL including
         --                           scheme and path.
         -- @param string      path   Path relative to the network admin URL. Blank
         --                           string if no path is specified.
         -- @param string|null scheme The scheme to use. Accepts "http", "https",
         --                           "admin", or null. Default is "admin", which
         --                           obeys force_ssl_admin() and is_ssl().
         --
         return Apply_Filters ("network_admin_url", -URL, Path, Scheme);
      end;
   end Network_Admin_URL;

   --------------------
   -- User_Admin_URL --
   --------------------

   function User_Admin_URL (Path   : String := "";
                            Scheme : String := "admin")
                            return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;

      URL : UString :=
        +Network_Site_URL ("wp-admin/user/", Scheme);
   begin
      if Path /= "" then -- and then Is_String (Path) then
         Append (URL, Ltrim (Path, "/"));
      end if;

      --
      -- Filters the user admin URL for the current user.
      --
      -- @since 3.1.0
      -- @since 5.8.0 The `scheme` parameter was added.
      --
      -- @param string      url    The complete URL including scheme and path.
      -- @param string      path   Path relative to the URL. Blank string if
      --                            no path is specified.
      -- @param string|null scheme The scheme to use. Accepts "http", "https",
      --                            "admin", or null. Default is "admin", which obeys
      --                            force_ssl_admin() and is_ssl().
      --
      return Apply_Filters ("user_admin_url", -URL, Path, Scheme);
   end User_Admin_URL;

   --------------------
   -- Self_Admin_URL --
   --------------------

   function Self_Admin_URL (Path   : String := "";
                            Scheme : String := "admin")
                            return String
   is
      use Wp_Common;
      use Inc_Load;

      URL : constant String :=
        (if Is_Network_Admin then Network_Admin_URL (Path, Scheme)
         elsif Is_User_Admin then User_Admin_URL (Path, Scheme)
         else                     Admin_URL (Path, Scheme));
   begin
      --
      -- Filters the admin URL for the current site or network depending on context.
      --
      -- @since 4.9.0
      --
      -- @param string url    The complete URL including scheme and path.
      -- @param string path   Path relative to the URL. Blank string if no path
      --                      is specified.
      -- @param string scheme The scheme to use.
      --
      return Apply_Filters ("self_admin_url", URL, Path, Scheme);
   end Self_Admin_URL;

   --------------------
   -- Set_URL_Scheme --
   --------------------

   function Set_URL_Scheme (URL    : String;
                            Scheme : String := "") -- null
                            return String
   is
      use Php.Preg;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Functions;
      use Inc_Load;

      Orig_Scheme : constant String := Scheme;

      Scheme_2 : UString := +Scheme;
      URL_2    : UString := +Trim (URL);
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

   -----------------------
   -- Get_Dashboard_URL --
   -----------------------

   function Get_Dashboard_URL (User_Id : Class_Users.User_Id_Type := 0;
                               Path    : String  := "";
                               Scheme  : String  := "admin")
                               return String
   is
      use UStrings;
      use Wp_Common;
      use Class_Admin_Bar; -- ???
      use Class_Sites;
      use Class_Users;
      use Inc_Capabilities;
      use Inc_Load;
      use Inc_Ms_Functions;
      use Inc_Users;

      function Blog_In_Blogs (Needle   : Integer;
                              Haystack : Blog_List)
                              return Boolean;

      function Blog_In_Blogs (Needle   : Integer;
                              Haystack : Blog_List)
                              return Boolean
      is
      begin
         for Blog of Haystack loop
            if Needle = Blog.Userblog_Id then
               return True;
            end if;
         end loop;
         return False;
      end Blog_In_Blogs;

      User_Id_2 : constant User_Id_Type :=
        (if User_Id not in 0
         then User_Id
         else Get_Current_User_Id);

      Blogs : constant Blog_List := Get_Blogs_Of_User (User_Id_2);
      URL : UString;
   begin
      if
        Is_Multisite and then
        not User_Can (User_Id_2, "manage_network") and then
        Blogs.Is_Empty -- Empty (Blogs)
      then
         URL := +User_Admin_URL (Path, Scheme);
      elsif not Is_Multisite then
         URL := +Admin_URL (Path, Scheme);
      else
         declare
            Current_Blog : constant Integer := Get_Current_Blog_Id;
         begin
            if
              Current_Blog = 0 and then
--            Current_Blog and then
              (User_Can (User_Id_2, "manage_network") or else
               Blog_In_Blogs (Current_Blog, Blogs))
--             In_Array (Current_Blog, Array_Keys (Blogs), True))
            then
               URL := +Admin_URL (Path, Scheme);
            else
               declare
                  Active : constant Wp_Site :=
                    Get_Active_Blog_For_User (User_Id_2);
               begin
                  if Active /= Null_Site then
                     URL := +Get_Admin_URL (Active.Blog_Id, Path, Scheme);
                  else
                     URL := +User_Admin_URL (Path, Scheme);
                  end if;
               end;
            end if;
         end;
      end if;

      --
      -- Filters the dashboard URL for a user.
      --
      -- @since 3.1.0
      --
      -- @param string url     The complete URL including scheme and path.
      -- @param int    user_id The user ID.
      -- @param string path    Path relative to the URL. Blank string if no path is
      --                       specified.
      -- @param string scheme  Scheme to give the URL context. Accepts "http",
      --                       "https", "login", "login_post", "admin", "relative"
      --                       or null.
      --
      return Apply_Filters ("user_dashboard_url", -URL,
                            Integer (User_Id_2), Path, Scheme);
   end Get_Dashboard_URL;

   --------------------------
   -- Get_Edit_Profile_URL --
   --------------------------

   function Get_Edit_Profile_URL (User_Id : Class_Users.User_Id_Type := 0;
                                  Scheme  : String  := "admin")
                                  return String
   is
      use Wp_Common;
      use Class_Users;
      use Inc_Load;
      use Inc_Users;

      User_Id_2 : constant User_Id_Type :=
        (if User_Id /= 0
         then User_Id
         else Get_Current_User_Id);

      URL : constant String :=
        (if Is_User_Admin then User_Admin_URL ("profile.php", Scheme)
         elsif Is_Network_Admin then Network_Admin_URL ("profile.php", Scheme)
         else  Get_Dashboard_URL (User_Id_2, "profile.php", Scheme));
   begin
      --
      -- Filters the URL for a user"s profile editor.
      --
      -- @since 3.1.0
      --
      -- @param string url     The complete URL including scheme and path.
      -- @param int    user_id The user ID.
      -- @param string scheme  Scheme to give the URL context. Accepts "http",
      --                       "https", "login", "login_post", "admin", "relative"
      --                       or null.
      --
      return Apply_Filters ("edit_profile_url", URL, Integer (User_Id_2), Scheme);
   end Get_Edit_Profile_URL;

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
      use UStrings;
      use Wp_Common;
      use Class_Posts;
      use Class_Post_Type;
      use Inc_Options;
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
      Shortlink : UString :=
        +Apply_Filters ("pre_get_shortlink", "False", Id, Context, Allow_Slugs);

      Post_Id : Class_Posts.Post_Id_Type := 0;
      Post    : Wp_Post;
   begin

      if "" /= Shortlink then -- false
         return -Shortlink;
      end if;

      if "query" = Context and then Is_Singular then
         Post_Id := Get_Queried_Object_Id;
         Post    := Get_Post (Post_Id);
      elsif "post" = Context then
         Post := Get_Post (Class_Posts.Post_Id_Type (Id));
         if Post.Id /= 0 then
--       if not Empty (Post.Id) then
            Post_Id := Post.Id;
         end if;
      end if;

      Shortlink := Null_UString;

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
      use Php.Arrays;
      use Php.Misc;
      use Php.Numerics;
      use Php.Strings;
      use Php.Types;
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Load;
      use Inc_Options;

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
         Id_Or_Email_2 : constant UString := +Id_Or_Email;
         Email_Hash    : UString;
         User       : UString; -- Boolean := False;
         Email      : UString; -- Boolean := False;
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
                  Email_Hash := +L.First_Element;
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

            URL_2 : constant String :=
              (if Is_SSL
                 then "https://secure.gravatar.com/avatar/" & (-Email_Hash)
               else
                 Sprintf ("http://%d.gravatar.com/avatar/%s",
                          [
                            1 => Helpers.Image (Gravatar_Server),
                            2 => -Email_Hash
                          ]));

            URL : constant String :=
              Add_Query_Arg (
                Raw_URL_Encode_Deep (Array_Filter (URL_Args)),
                Set_URL_Scheme (URL_2, Get_As_String (Args_2, "scheme")));
         begin
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
                 Apply_Filters ("get_avatar_url", URL, -Id_Or_Email_2, Args_2)));

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

   ------------------------
   -- Get_Theme_File_URI --
   ------------------------

   function Get_Theme_File_URI (File : String := "")
                                return String
   is
      use Php.Files;
      use Php.Strings;
      use Wp_Common;
      use Inc_Themes;

      File_2 : constant String := Ltrim (File, "/");

      URL : constant String :=
        (if Empty (File_2)
           then Get_Stylesheet_Directory_URI
        elsif File_Exists (Get_Stylesheet_Directory & "/" & File_2)
           then Get_Stylesheet_Directory_URI & "/" & File_2
        else  Get_Template_Directory_URI & "/" & File_2);
   begin
      --
      -- Filters the URL to a file in the theme.
      --
      -- @since 4.7.0
      --
      -- @param string url  The file URL.
      -- @param string file The requested file to search for.
      --
      return Apply_Filters ("theme_file_uri", URL, File_2);
   end Get_Theme_File_URI;

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

   -------------------------
   -- Get_Theme_File_Path --
   -------------------------

   function Get_Theme_File_Path (File : String := "")
                                 return String
   is
      use Php.Files;
      use Php.Strings;
      use Wp_Common;
      use Inc_Themes;

      File_2 : constant String := Ltrim (File, "/");

      Path : constant String :=
        (if Empty (File_2)
           then Get_Stylesheet_Directory
        elsif File_Exists (Get_Stylesheet_Directory & "/" & File_2)
           then Get_Stylesheet_Directory & "/" & File_2
        else
            Get_Template_Directory & "/" & File_2);
   begin
      --
      -- Filters the path to a file in the theme.
      --
      -- @since 4.7.0
      --
      -- @param string path The file path.
      -- @param string file The requested file to search for.
      --
      return Apply_Filters ("theme_file_path", Path, File_2);
   end Get_Theme_File_Path;

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

   ----------------------------
   -- Get_Privacy_Policy_URL --
   ----------------------------

   function Get_Privacy_Policy_URL
            return String
   is
      use Wp_Common;
      use Class_Posts;
      use Inc_Options;
      use Inc_Posts;

      Policy_Page_Id : constant Integer :=
        Get_Option ("wp_page_for_privacy_policy");

      URL : constant String :=
        (if
           Policy_Page_Id /= 0 and then
--         not Empty (Policy_Page_Id) and then
           Get_Post_Status (Post_Id_Type (Policy_Page_Id)) = "publish"
         then String'(Get_Permalink (Post_Id_Type (Policy_Page_Id)))
         else "");
   begin
      --
      -- Filters the URL of the privacy policy page.
      --
      -- @since 4.9.6
      --
      -- @param string url            The URL to the privacy policy page. Empty string
      --                               if it doesn"t exist.
      -- @param int    policy_page_id The ID of privacy policy page.
      --
      return Apply_Filters ("privacy_policy_url", URL, Policy_Page_Id);
   end Get_Privacy_Policy_URL;

   -----------------------------
   -- The_Privacy_Policy_Link --
   -----------------------------

   procedure The_Privacy_Policy_Link (Before : String := "";
                                      After  : String := "")
   is
      use Php.Echoing;
   begin
      Echo (Get_The_Privacy_Policy_Link (Before, After));
   end The_Privacy_Policy_Link;

   ---------------------------------
   -- Get_The_Privacy_Policy_Link --
   ---------------------------------

   function Get_The_Privacy_Policy_Link (Before : String := "";
                                         After  : String := "")
                                         return String
   is
      use Php.Strings;
      use Wp_Common;
      use Inc_Formatting;
      use Inc_Options;
      use Inc_Post_Templates;

      Privacy_Policy_URL : constant String :=
        Get_Privacy_Policy_URL;

      Policy_Page_Id : constant Integer :=
        Get_Option ("wp_page_for_privacy_policy");

      Page_Title : constant String :=
        (if Policy_Page_Id /= 0
         then Get_The_Title (Policy_Page_Id) else "");

      Link_2 : constant String :=
        (if Privacy_Policy_URL /= "" and then Page_Title /= ""
         then
           Sprintf (
             "<a class=""privacy-policy-link"" href=""%s"">%s</a>",
             [
               1 => ESC_URL (Privacy_Policy_URL),
               2 => ESC_HTML (Page_Title)
             ])
         else "");

      --
      -- Filters the privacy policy link.
      --
      -- @since 4.9.6
      --
      -- @param string link               The privacy policy link. Empty string if it
      --                                   doesn"t exist.
      -- @param string privacy_policy_url The URL of the privacy policy. Empty string
      --                                   if it doesn"t exist.
      --
      Link : constant String :=
        Apply_Filters ("the_privacy_policy_link", Link_2, Privacy_Policy_URL);
   begin
      if Link /= "" then
         return Before & Link & After;
      end if;

      return "";
   end Get_The_Privacy_Policy_Link;

end Inc_Link_Templates;
