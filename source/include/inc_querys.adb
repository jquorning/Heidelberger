--
-- WordPress Query API
--
-- The query API attempts to get which part of WordPress the user is on. It
-- also provides functionality for getting URL query information.
--
-- @link https://developer.wordpress.org/themes/basics/the-loop/ More information
-- on The Loop.
--
-- @package WordPress
-- @subpackage Query
--

with Php.Strings;

with Hb_Common;
with Lists;

with Inc_Functions;
with Inc_L10n;
with Inc_Plugins;

package body Inc_Querys
is
   use Lists;

   function Isset (Query : Inc_Class_Wp_Querys.Wp_Query)
                   return Boolean;

   -----------
   -- Isset --
   -----------

   function Isset (Query : Inc_Class_Wp_Querys.Wp_Query)
                   return Boolean
   is
      use Inc_Class_Wp_Querys;
   begin
      return Query = Null_Query;
   end Isset;

   -------------------
   -- Get_Query_Var --
   -------------------

   function Get_Query_Var (Var     : String;
                           Default : String := "")
                           return String
   is
   begin
      return Global_Wp_Query.Get (Var, Default);
   end Get_Query_Var;

   ------------------------
   -- Get_Queried_Object --
   ------------------------

   function Get_Queried_Object
            return Class_Terms.Wp_Term
   is
   begin
      return Global_Wp_Query.Get_Queried_Object;
   end Get_Queried_Object;

   function Get_Queried_Object
            return Class_Posts.Wp_Post
            is (Class_Posts.Null_Post);

   function Get_Queried_Object
            return Class_Users.Wp_User
            is (Class_Users.Null_User);

   ---------------------------
   -- Get_Queried_Object_Id --
   ---------------------------

   function Get_Queried_Object_Id
            return Class_Posts.Post_Id
   is
--    global wp_query;
   begin
      return Global_Wp_Query.Get_Queried_Object_Id;
   end Get_Queried_Object_Id;

-- --
-- -- Sets the value of a query variable in the WP_Query class.
-- --
-- -- @since 2.2.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @param string var   Query variable key.
-- -- @param mixed  value Query variable value.
-- --
-- function set_query_var( var, value ) then
--         global wp_query;
--         wp_query->set( var, value );
-- end;

-- --
-- -- Sets up The Loop with query parameters.
-- --
-- -- Note: This function will completely override the main query and isn"t intended for use
-- -- by plugins or themes. Its overly-simplistic approach to modifying the main query can be
-- -- problematic and should be avoided wherever possible. In most cases, there are better,
-- -- more performant options for modifying the main query such as via the then@see "pre_get_posts"end;
-- -- action within WP_Query.
-- --
-- -- This must not be used within the WordPress Loop.
-- --
-- -- @since 1.5.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @param array|string query Array or string of WP_Query arguments.
-- -- @return WP_Post[]|int[] Array of post objects or post IDs.
-- --
-- function query_posts( query ) then
--         GLOBALS["wp_query"] = new WP_Query();
--         return GLOBALS["wp_query"]->query( query );
-- end;

-- --
-- -- Destroys the previous query and sets up a new query.
-- --
-- -- This should be used after query_posts() and before another query_posts().
-- -- This will remove obscure bugs that occur when the previous WP_Query object
-- -- is not destroyed properly before another is set up.
-- --
-- -- @since 2.3.0
-- --
-- -- @global WP_Query wp_query     WordPress Query object.
-- -- @global WP_Query wp_the_query Copy of the global WP_Query instance created during wp_reset_query().
-- --
-- function wp_reset_query() then
--         GLOBALS["wp_query"] = GLOBALS["wp_the_query"];
--         wp_reset_postdata();
-- end;

-- --
-- -- After looping through a separate query, this function restores
-- -- the post global to the current post in the main query.
-- --
-- -- @since 3.0.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- function wp_reset_postdata() then
--         global wp_query;

--         if ( isset( wp_query ) ) then
--                 wp_query->reset_postdata();
--         end;
-- end;

-- /*
-- -- Query type checks.
-- --

-- --
-- -- Determines whether the query is for an existing archive page.
-- --
-- -- Archive pages include category, tag, author, date, custom post type,
-- -- and custom taxonomy based archives.
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tagsend; article in the Theme Developer Handbook.
-- --
-- -- @since 1.5.0
-- --
-- -- @see is_category()
-- -- @see is_tag()
-- -- @see is_author()
-- -- @see is_date()
-- -- @see is_post_type_archive()
-- -- @see is_tax()
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @return bool Whether the query is for an existing archive page.
-- --
-- function is_archive() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "Conditional query tags do not work before the query is run. Before then, they always return false." ), "3.1.0" );
--                 return false;
--         end;

--         return wp_query->is_archive();
-- end;

   --------------------------
   -- Is_Post_Type_Archive --
   --------------------------

   function Is_Post_Type_Archive (Post_Types : String := "")
                                  return Boolean
   is
--    use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "3.1.0");
         return False;
      end if;

      return Global_Wp_Query.Is_Post_Type_Archive (Post_Types);
   end Is_Post_Type_Archive;

-- --
-- -- Determines whether the query is for an existing attachment page.
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tagsend; article in the Theme Developer Handbook.
-- --
-- -- @since 2.0.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @param int|string|int[]|string[] attachment Optional. Attachment ID, title, slug, or array of such
-- --                                              to check against. Default empty.
-- -- @return bool Whether the query is for an existing attachment page.
-- --
-- function is_attachment( attachment = "" ) then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "Conditional query tags do not work before the query is run. Before then, they always return false." ), "3.1.0" );
--                 return false;
--         end;

--         return wp_query->is_attachment( attachment );
-- end;

   ---------------
   -- Is_Author --
   ---------------

   function Is_Author (Author : String := "")
                       return Boolean
   is
--    use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "3.1.0");
         return False;
      end if;

      return Global_Wp_Query.Is_Author (Author);
   end Is_Author;

   -----------------
   -- Is_Category --
   -----------------

   function Is_Category (Category : String := "")
                         return Boolean
   is
--    use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "3.1.0"
         );
         return False;
      end if;

      return Global_Wp_Query.Is_Category (Category);
   end Is_Category;

   ------------
   -- Is_Tag --
   ------------

   function Is_Tag (Tag : String := "")
                    return Boolean
   is
--    use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "3.1.0");
         return False;
      end if;

      return Global_Wp_Query.Is_Tag (Tag);
   end Is_Tag;

   ------------
   -- Is_Tax --
   ------------

   function Is_Tax (Taxonomy : String := "";
                    Term     : String := "")
                    return Boolean
   is
--    use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "3.1.0");
         return False;
      end if;

      return Global_Wp_Query.Is_Tax (Taxonomy, Term);
   end Is_Tax;

-- --
-- -- Determines whether the query is for an existing date archive.
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tagsend; article in the Theme Developer Handbook.
-- --
-- -- @since 1.5.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @return bool Whether the query is for an existing date archive.
-- --
-- function is_date() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "Conditional query tags do not work before the query is run. Before then, they always return false." ), "3.1.0" );
--                 return false;
--         end;

--         return wp_query->is_date();
-- end;

   ------------
   -- Is_Day --
   ------------

   function Is_Day
            return Boolean
   is
--    use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
--    global wp_query;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "3.1.0");
         return False;
      end if;

      return Global_Wp_Query.Is_Day;
   end Is_Day;

-- --
-- -- Determines whether the query is for a feed.
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tagsend; article in the Theme Developer Handbook.
-- --
-- -- @since 1.5.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @param string|string[] feeds Optional. Feed type or array of feed types
-- --                                         to check against. Default empty.
-- -- @return bool Whether the query is for a feed.
-- --
-- function is_feed( feeds = "" ) then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "Conditional query tags do not work before the query is run. Before then, they always return false." ), "3.1.0" );
--                 return false;
--         end;

--         return wp_query->is_feed( feeds );
-- end;

-- --
-- -- Is the query for a comments feed?
-- --
-- -- @since 3.0.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @return bool Whether the query is for a comments feed.
-- --
-- function is_comment_feed() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "Conditional query tags do not work before the query is run. Before then, they always return false." ), "3.1.0" );
--                 return false;
--         end;

--         return wp_query->is_comment_feed();
-- end;

   -------------------
   -- Is_Front_Page --
   -------------------

   function Is_Front_Page
            return Boolean
   is
--    use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
--         global wp_query;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "3.1.0");
         return False;
      end if;

      return Global_Wp_Query.Is_Front_Page;
   end Is_Front_Page;

   -------------
   -- Is_Home --
   -------------

   function Is_Home
            return Boolean
   is
--    use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
--         global wp_query;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "3.1.0");
         return False;
      end if;

      return Global_Wp_Query.Is_Home;
   end Is_Home;

-- --
-- -- Determines whether the query is for the Privacy Policy page.
-- --
-- -- The Privacy Policy page is the page that shows the Privacy Policy content of the site.
-- --
-- -- is_privacy_policy() is dependent on the site"s "Change your Privacy Policy page" Privacy Settings "wp_page_for_privacy_policy".
-- --
-- -- This function will return true only on the page you set as the "Privacy Policy page".
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tagsend; article in the Theme Developer Handbook.
-- --
-- -- @since 5.2.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @return bool Whether the query is for the Privacy Policy page.
-- --
-- function is_privacy_policy() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "Conditional query tags do not work before the query is run. Before then, they always return false." ), "3.1.0" );
--                 return false;
--         end;

--         return wp_query->is_privacy_policy();
-- end;

   --------------
   -- Is_Month --
   --------------

   function Is_Month
            return Boolean
   is
--    use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
--         global wp_query;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "3.1.0");
         return False;
      end if;

      return Global_Wp_Query.Is_Month;
   end Is_Month;

-- --
-- -- Determines whether the query is for an existing single page.
-- --
-- -- If the page parameter is specified, this function will additionally
-- -- check if the query is for one of the pages specified.
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tagsend; article in the Theme Developer Handbook.
-- --
-- -- @since 1.5.0
-- --
-- -- @see is_single()
-- -- @see is_singular()
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @param int|string|int[]|string[] page Optional. Page ID, title, slug, or array of such
-- --                                        to check against. Default empty.
-- -- @return bool Whether the query is for an existing single page.
-- --
-- function is_page( page = "" ) then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "Conditional query tags do not work before the query is run. Before then, they always return false." ), "3.1.0" );
--                 return false;
--         end;

--         return wp_query->is_page( page );
-- end;

-- --
-- -- Determines whether the query is for a paged result and not for the first page.
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tagsend; article in the Theme Developer Handbook.
-- --
-- -- @since 1.5.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @return bool Whether the query is for a paged result.
-- --
-- function is_paged() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "Conditional query tags do not work before the query is run. Before then, they always return false." ), "3.1.0" );
--                 return false;
--         end;

--         return wp_query->is_paged();
-- end;

-- --
-- -- Determines whether the query is for a post or page preview.
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tagsend; article in the Theme Developer Handbook.
-- --
-- -- @since 2.0.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @return bool Whether the query is for a post or page preview.
-- --
-- function is_preview() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "Conditional query tags do not work before the query is run. Before then, they always return false." ), "3.1.0" );
--                 return false;
--         end;

--         return wp_query->is_preview();
-- end;

-- --
-- -- Is the query for the robots.txt file?
-- --
-- -- @since 2.1.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @return bool Whether the query is for the robots.txt file.
-- --
-- function is_robots() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "Conditional query tags do not work before the query is run. Before then, they always return false." ), "3.1.0" );
--                 return false;
--         end;

--         return wp_query->is_robots();
-- end;

-- --
-- -- Is the query for the favicon.ico file?
-- --
-- -- @since 5.4.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @return bool Whether the query is for the favicon.ico file.
-- --
-- function is_favicon() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "Conditional query tags do not work before the query is run. Before then, they always return false." ), "3.1.0" );
--                 return false;
--         end;

--         return wp_query->is_favicon();
-- end;

   ---------------
   -- Is_Search --
   ---------------

   function Is_Search
            return Boolean
   is
--    use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "3.1.0");
         return False;
      end if;

      return Global_Wp_Query.Is_Search;
   end Is_Search;

   ---------------
   -- Is_Single --
   ---------------

   function Is_Single (Post : String := "")
            return Boolean
   is
--    use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "3.1.0");
         return False;
      end if;

      return Global_Wp_Query.Is_Single (Post);
   end Is_Single;

   -----------------
   -- Is_Singular --
   -----------------

   function Is_Singular (Post_Types : String := "")
                         return Boolean
   is
--    use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "3.1.0");
         return False;
      end if;

      return Global_Wp_Query.Is_Singular (Post_Types);
   end Is_Singular;

-- --
-- -- Determines whether the query is for a specific time.
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tagsend; article in the Theme Developer Handbook.
-- --
-- -- @since 1.5.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @return bool Whether the query is for a specific time.
-- --
-- function is_time() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "Conditional query tags do not work before the query is run. Before then, they always return false." ), "3.1.0" );
--                 return false;
--         end;

--         return wp_query->is_time();
-- end;

-- --
-- -- Determines whether the query is for a trackback endpoint call.
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tagsend; article in the Theme Developer Handbook.
-- --
-- -- @since 1.5.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @return bool Whether the query is for a trackback endpoint call.
-- --
-- function is_trackback() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "Conditional query tags do not work before the query is run. Before then, they always return false." ), "3.1.0" );
--                 return false;
--         end;

--         return wp_query->is_trackback();
-- end;

   -------------
   -- Is_Year --
   -------------

   function Is_Year
            return Boolean
   is
--    use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
--         global wp_query;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "3.1.0");
         return False;
      end if;

      return Global_Wp_Query.Is_Year;
   end Is_Year;

   ------------
   -- Is_404 --
   ------------

   function Is_404
            return Boolean
   is
--    use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
--    global wp_query;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "3.1.0");
         return False;
      end if;

      return Global_Wp_Query.Is_404;
   end Is_404;

-- --
-- -- Is the query for an embedded post?
-- --
-- -- @since 4.4.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @return bool Whether the query is for an embedded post.
-- --
-- function is_embed() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "Conditional query tags do not work before the query is run. Before then, they always return false." ), "3.1.0" );
--                 return false;
--         end;

--         return wp_query->is_embed();
-- end;

   -------------------
   -- Is_Main_Query --
   -------------------

   function Is_Main_Query
            return Boolean
   is
      use Php.Strings;
      use Hb_Common;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Plugins;

--    global wp_query;
   begin
      if not Isset (Global_Wp_Query) then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Conditional query tags do not work before the query is run. Before then, they always return false.",
           "6.1.0");
         return False;
      end  if;

      if "pre_get_posts" = Current_Filter then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           Sprintf (
             -- translators: 1: pre_get_posts, 2: WP_Query->is_main_query(), 3: is_main_query(), 4: Documentation URL.
             abs "In %1s, use the %2s method, not the %3s function. See %4s.",
             To_List (List => (
               1 => +"<code>pre_get_posts</code>",
               2 => +"<code>WP_Query->is_main_query()</code>",
               3 => +"<code>is_main_query()</code>",
               4 => +abs "https://developer.wordpress.org/reference/functions/is_main_query/"
             ))
           ),
           "3.7.0"
         );
      end if;

      return Global_Wp_Query.Is_Main_Query;
   end Is_Main_Query;

-- /*
-- -- The Loop. Post loop control.
-- --

-- --
-- -- Determines whether current WordPress query has posts to loop over.
-- --
-- -- @since 1.5.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @return bool True if posts are available, false if end of the loop.
-- --
-- function have_posts() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 return false;
--         end;

--         return wp_query->have_posts();
-- end;

   -----------------
   -- In_The_Loop --
   -----------------

   function In_The_Loop
            return Boolean
   is
--    global wp_query;
   begin
      if not Isset (Global_Wp_Query) then
         return False;
      end if;

      return Global_Wp_Query.In_The_Loop;
   end In_The_Loop;

-- --
-- -- Rewind the loop posts.
-- --
-- -- @since 1.5.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- function rewind_posts() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 return;
--         end;

--         wp_query->rewind_posts();
-- end;

-- --
-- -- Iterate the post index in the loop.
-- --
-- -- @since 1.5.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- function the_post() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 return;
--         end;

--         wp_query->the_post();
-- end;

-- /*
-- -- Comments loop.
-- --

-- --
-- -- Determines whether current WordPress query has comments to loop over.
-- --
-- -- @since 2.2.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @return bool True if comments are available, false if no more comments.
-- --
-- function have_comments() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 return false;
--         end;

--         return wp_query->have_comments();
-- end;

-- --
-- -- Iterate comment index in the comment loop.
-- --
-- -- @since 2.2.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- function the_comment() then
--         global wp_query;

--         if ( ! isset( wp_query ) ) then
--                 return;
--         end;

--         wp_query->the_comment();
-- end;

-- --
-- -- Redirect old slugs to the correct permalink.
-- --
-- -- Attempts to find the current slug from the past slugs.
-- --
-- -- @since 2.1.0
-- --
-- function wp_old_slug_redirect() then
--         if ( is_404() && "" !== get_query_var( "name" ) ) then
--                 -- Guess the current post type based on the query vars.
--                 if ( get_query_var( "post_type" ) ) then
--                         post_type = get_query_var( "post_type" );
--                 end; elseif ( get_query_var( "attachment" ) ) then
--                         post_type = "attachment";
--                 end; elseif ( get_query_var( "pagename" ) ) then
--                         post_type = "page";
--                 end; else then
--                         post_type = "post";
--                 end;

--                 if ( is_array( post_type ) ) then
--                         if ( count( post_type ) > 1 ) then
--                                 return;
--                         end;
--                         post_type = reset( post_type );
--                 end;

--                 -- Do not attempt redirect for hierarchical post types.
--                 if ( is_post_type_hierarchical( post_type ) ) then
--                         return;
--                 end;

--                 id = _find_post_by_old_slug( post_type );

--                 if ( ! id ) then
--                         id = _find_post_by_old_date( post_type );
--                 end;

--                 --
--                 -- Filters the old slug redirect post ID.
--                 --
--                 -- @since 4.9.3
--                 --
--                 -- @param int id The redirect post ID.
--                 --
--                 id = apply_filters( "old_slug_redirect_post_id", id );

--                 if ( ! id ) then
--                         return;
--                 end;

--                 link = get_permalink( id );

--                 if ( get_query_var( "paged" ) > 1 ) then
--                         link = user_trailingslashit( trailingslashit( link ) . "page/" . get_query_var( "paged" ) );
--                 end; elseif ( is_embed() ) then
--                         link = user_trailingslashit( trailingslashit( link ) . "embed" );
--                 end;

--                 --
--                 -- Filters the old slug redirect URL.
--                 --
--                 -- @since 4.4.0
--                 --
--                 -- @param string link The redirect URL.
--                 --
--                 link = apply_filters( "old_slug_redirect_url", link );

--                 if ( ! link ) then
--                         return;
--                 end;

--                 wp_redirect( link, 301 ); -- Permanent redirect.
--                 exit;
--         end;
-- end;

-- --
-- -- Find the post ID for redirecting an old slug.
-- --
-- -- @since 4.9.3
-- -- @access private
-- --
-- -- @see wp_old_slug_redirect()
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string post_type The current post type based on the query vars.
-- -- @return int The Post ID.
-- --
-- function _find_post_by_old_slug( post_type ) then
--         global wpdb;

--         query = wpdb->prepare( "SELECT post_id FROM wpdb->postmeta, wpdb->posts WHERE ID = post_id AND post_type = %s AND meta_key = "_wp_old_slug" AND meta_value = %s", post_type, get_query_var( "name" ) );

--         -- If year, monthnum, or day have been specified, make our query more precise
--         -- just in case there are multiple identical _wp_old_slug values.
--         if ( get_query_var( "year" ) ) then
--                 query .= wpdb->prepare( " AND YEAR(post_date) = %d", get_query_var( "year" ) );
--         end;
--         if ( get_query_var( "monthnum" ) ) then
--                 query .= wpdb->prepare( " AND MONTH(post_date) = %d", get_query_var( "monthnum" ) );
--         end;
--         if ( get_query_var( "day" ) ) then
--                 query .= wpdb->prepare( " AND DAYOFMONTH(post_date) = %d", get_query_var( "day" ) );
--         end;

--         key          = md5( query );
--         last_changed = wp_cache_get_last_changed( "posts" );
--         cache_key    = "find_post_by_old_slug:key:last_changed";
--         cache        = wp_cache_get( cache_key, "posts" );
--         if ( false !== cache ) then
--                 id = cache;
--         end; else then
--                 id = (int) wpdb->get_var( query );
--                 wp_cache_set( cache_key, id, "posts" );
--         end;

--         return id;
-- end;

-- --
-- -- Find the post ID for redirecting an old date.
-- --
-- -- @since 4.9.3
-- -- @access private
-- --
-- -- @see wp_old_slug_redirect()
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string post_type The current post type based on the query vars.
-- -- @return int The Post ID.
-- --
-- function _find_post_by_old_date( post_type ) then
--         global wpdb;

--         date_query = "";
--         if ( get_query_var( "year" ) ) then
--                 date_query .= wpdb->prepare( " AND YEAR(pm_date.meta_value) = %d", get_query_var( "year" ) );
--         end;
--         if ( get_query_var( "monthnum" ) ) then
--                 date_query .= wpdb->prepare( " AND MONTH(pm_date.meta_value) = %d", get_query_var( "monthnum" ) );
--         end;
--         if ( get_query_var( "day" ) ) then
--                 date_query .= wpdb->prepare( " AND DAYOFMONTH(pm_date.meta_value) = %d", get_query_var( "day" ) );
--         end;

--         id = 0;
--         if ( date_query ) then
--                 query        = wpdb->prepare( "SELECT post_id FROM wpdb->postmeta AS pm_date, wpdb->posts WHERE ID = post_id AND post_type = %s AND meta_key = "_wp_old_date" AND post_name = %s" . date_query, post_type, get_query_var( "name" ) );
--                 key          = md5( query );
--                 last_changed = wp_cache_get_last_changed( "posts" );
--                 cache_key    = "find_post_by_old_date:key:last_changed";
--                 cache        = wp_cache_get( cache_key, "posts" );
--                 if ( false !== cache ) then
--                         id = cache;
--                 end; else then
--                         id = (int) wpdb->get_var( query );
--                         if ( ! id ) then
--                                 -- Check to see if an old slug matches the old date.
--                                 id = (int) wpdb->get_var( wpdb->prepare( "SELECT ID FROM wpdb->posts, wpdb->postmeta AS pm_slug, wpdb->postmeta AS pm_date WHERE ID = pm_slug.post_id AND ID = pm_date.post_id AND post_type = %s AND pm_slug.meta_key = "_wp_old_slug" AND pm_slug.meta_value = %s AND pm_date.meta_key = "_wp_old_date"" . date_query, post_type, get_query_var( "name" ) ) );
--                         end;
--                         wp_cache_set( cache_key, id, "posts" );
--                 end;
--         end;

--         return id;
-- end;

-- --
-- -- Set up global post data.
-- --
-- -- @since 1.5.0
-- -- @since 4.4.0 Added the ability to pass a post ID to `post`.
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @param WP_Post|object|int post WP_Post instance or Post ID/object.
-- -- @return bool True when finished.
-- --
-- function setup_postdata( post ) then
--         global wp_query;

--         if ( ! empty( wp_query ) && wp_query instanceof WP_Query ) then
--                 return wp_query->setup_postdata( post );
--         end;

--         return false;
-- end;

-- --
-- -- Generates post data.
-- --
-- -- @since 5.2.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @param WP_Post|object|int post WP_Post instance or Post ID/object.
-- -- @return array|false Elements of post, or false on failure.
-- --
-- function generate_postdata( post ) then
--         global wp_query;

--         if ( ! empty( wp_query ) && wp_query instanceof WP_Query ) then
--                 return wp_query->generate_postdata( post );
--         end;

--         return false;
-- end;

end Inc_Querys;
