--
-- List Table API: WP_Posts_List_Table class
--
-- @package WordPress
-- @subpackage Administration
-- @since 3.1.0
--

with Php.Lists;
with Php.Numerics;
with Php.Strings;

with Array_Lists;
with Binder;
with Globals;
with UStrings;
with Helpers;
with Lists;

with Class_Post_Type;
with Class_WpDB;
with Inc_Options;
with Inc_Posts;
-- with Inc_Capabilities;
with Inc_Users;

package body Class_Posts_List_Tables
is
   use Lists;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Args : Array_Type := Empty_Array)
                         return Wp_Posts_List_Table
   is
      use Php.Lists;
      use Php.Numerics;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Binder;
      use Class_Post_Type;
      use Class_WpDB;
--    use Inc_Capabilities;
      use Inc_Posts;
      use Inc_Users;

      List_Table : Wp_Posts_List_Table := (
        Class_List_Tables.X_Construct (
          To_Array_Type ([
            Build ("plural", "posts"),
            Build ("screen", (if Isset (Args, "screen")
                              then Get_As_String (Args, "screen")
                              else "null"))
          ])
        )
        with
          Hierarchical_Display => False,
          User_Posts_Count     => 0,
          Sticky_Posts_Count   => 0
      );

      Exclude_States : constant List_Type := Get_Post_Stati (
        To_Array_Type ([
          Build ("show_in_admin_all_list", "false")
        ])
      );

      Posts : constant Statement_Type := Statement_Type (-Globals.WpDB.Posts);
   begin
      Globals.Global_Post_Type :=
        List_Table.Screen.Post_Type;

      Globals.Global_Post_Type_Object :=
        Get_Post_Type_Object (-Globals.Global_Post_Type);

      List_Table.User_Posts_Count := Natural'Value (
        Globals.WpDB.Get_Var ( -- (int)
          Globals.WpDB.Prepare (
            "SELECT COUNT( 1 )"           &
            " FROM " & Posts              &
            " WHERE post_type = %s"       &
            " AND post_status NOT IN ( '" &
            Statement_Type (Implode ("','", Exclude_States) & "' )") &
            " AND post_author = %d",
            [
              1 => -Globals.Global_Post_Type,
              2 => Helpers.Image (Integer (Get_Current_User_Id))
            ]
          )));

      if
        List_Table.User_Posts_Count /= 0
--      and then not Current_User_Can (Post_Type_Object.Cap.Edit_Others_Posts)
        and then Empty (X_REQUEST, "post_status")
        and then Empty (X_REQUEST, "all_posts")
        and then Empty (X_REQUEST, "author")
        and then Empty (X_REQUEST, "show_sticky")
      then
         Set (XX_GET, "author",
              From_String (Helpers.Image (Integer (Get_Current_User_Id))));
      end if;

      declare
         Sticky_Posts : constant List_Type :=
           Inc_Options.Get_Option ("sticky_posts");
      begin
         if "post" = Globals.Global_Post_Type and not Sticky_Posts.Is_Empty then
            declare
               Sticky_Posts_2 : constant Statement_Type :=
                 Statement_Type (Implode (", ", List_Map (Absint'Access,
                                                          Sticky_Posts))); -- (array)
            begin
               List_Table.Sticky_Posts_Count := Natural'Value (
                 Globals.WpDB.Get_Var ( -- (int)
                   Globals.WpDB.Prepare (
                     "SELECT COUNT( 1 )"     &
                     " FROM " & Posts        &
                     " WHERE post_type = %s" &
                     " AND post_status NOT IN ('trash', 'auto-draft')" &
                     " AND ID IN (" & Sticky_Posts_2 & ")",
                     [1 => -Globals.Global_Post_Type]
                 )));
            end;
         end if;
      end;

      return List_Table;
   end X_Construct;

--         --
--         -- Sets whether the table layout should be hierarchical or not.
--         --
--         -- @since 4.2.0
--         --
--         -- @param bool display Whether the table layout should be hierarchical.
--         --
--         public function set_hierarchical_display( display ) then
--                 this->hierarchical_display = display;
--         end;

--         --
--         -- @return bool
--         --
--         public function ajax_user_can() then
--                 return current_user_can( get_post_type_object( this->screen->post_type )->cap->edit_posts );
--         end;

--         --
--         -- @global string   mode             List table view mode.
--         -- @global array    avail_post_stati
--         -- @global WP_Query wp_query         WordPress Query object.
--         -- @global int      per_page
--         --
--         public function prepare_items() then
--                 global mode, avail_post_stati, wp_query, per_page;

--                 if ( ! empty( _REQUEST["mode"] ) ) then
--                         mode = "excerpt" === _REQUEST["mode"] ? "excerpt" : "list";
--                         set_user_setting( "posts_list_mode", mode );
--                 end; else then
--                         mode = get_user_setting( "posts_list_mode", "list" );
--                 end;

--                 // Is going to call wp().
--                 avail_post_stati = wp_edit_posts_query();

--                 this->set_hierarchical_display(
--                         is_post_type_hierarchical( this->screen->post_type )
--                         && "menu_order title" === wp_query->query["orderby"]
--                 );

--                 post_type = this->screen->post_type;
--                 per_page  = this->get_items_per_page( "edit_" . post_type . "_per_page" );

--                 -- This filter is documented in wp-admin/includes/post.php--
--                 per_page = apply_filters( "edit_posts_per_page", per_page, post_type );

--                 if ( this->hierarchical_display ) then
--                         total_items = wp_query->post_count;
--                 end; elseif ( wp_query->found_posts || this->get_pagenum() === 1 ) then
--                         total_items = wp_query->found_posts;
--                 end; else then
--                         post_counts = (array) wp_count_posts( post_type, "readable" );

--                         if ( isset( _REQUEST["post_status"] ) && in_array( _REQUEST["post_status"], avail_post_stati, true ) ) then
--                                 total_items = post_counts[ _REQUEST["post_status"] ];
--                         end; elseif ( isset( _REQUEST["show_sticky"] ) && _REQUEST["show_sticky"] ) then
--                                 total_items = this->sticky_posts_count;
--                         end; elseif ( isset( _GET["author"] ) && get_current_user_id() === (int) _GET["author"] ) then
--                                 total_items = this->user_posts_count;
--                         end; else then
--                                 total_items = array_sum( post_counts );

--                                 // Subtract post types that are not included in the admin all list.
--                                 foreach ( get_post_stati( array( "show_in_admin_all_list" => false ) ) as state ) then
--                                         total_items -= post_counts[ state ];
--                                 end;
--                         end;
--                 end;

--                 this->is_trash = isset( _REQUEST["post_status"] ) && "trash" === _REQUEST["post_status"];

--                 this->set_pagination_args(
--                         array(
--                                 "total_items" => total_items,
--                                 "per_page"    => per_page,
--                         )
--                 );
--         end;

--         --
--         -- @return bool
--         --
--         public function has_items() then
--                 return have_posts();
--         end;

--         --
--         --
--         public function no_items() then
--                 if ( isset( _REQUEST["post_status"] ) && "trash" === _REQUEST["post_status"] ) then
--                         echo get_post_type_object( this->screen->post_type )->labels->not_found_in_trash;
--                 end; else then
--                         echo get_post_type_object( this->screen->post_type )->labels->not_found;
--                 end;
--         end;

--         --
--         -- Determine if the current view is the "All" view.
--         --
--         -- @since 4.2.0
--         --
--         -- @return bool Whether the current view is the "All" view.
--         --
--         protected function is_base_request() then
--                 vars = _GET;
--                 unset( vars["paged"] );

--                 if ( empty( vars ) ) then
--                         return true;
--                 end; elseif ( 1 === count( vars ) && ! empty( vars["post_type"] ) ) then
--                         return this->screen->post_type === vars["post_type"];
--                 end;

--                 return 1 === count( vars ) && ! empty( vars["mode"] );
--         end;

--         --
--         -- Helper to create links to edit.php with params.
--         --
--         -- @since 4.4.0
--         --
--         -- @param string[] args      Associative array of URL parameters for the link.
--         -- @param string   link_text Link text.
--         -- @param string   css_class Optional. Class attribute. Default empty string.
--         -- @return string The formatted link string.
--         --
--         protected function get_edit_link( args, link_text, css_class = "" ) then
--                 url = add_query_arg( args, "edit.php" );

--                 class_html   = "";
--                 aria_current = "";

--                 if ( ! empty( css_class ) ) then
--                         class_html = sprintf(
--                                 " class="%s"",
--                                 esc_attr( css_class )
--                         );

--                         if ( "current" === css_class ) then
--                                 aria_current = " aria-current="page"";
--                         end;
--                 end;

--                 return sprintf(
--                         "<a href="%s"%s%s>%s</a>",
--                         esc_url( url ),
--                         class_html,
--                         aria_current,
--                         link_text
--                 );
--         end;

--         --
--         -- @global array locked_post_status This seems to be deprecated.
--         -- @global array avail_post_stati
--         -- @return array
--         --
--         protected function get_views() then
--                 global locked_post_status, avail_post_stati;

--                 post_type = this->screen->post_type;

--                 if ( ! empty( locked_post_status ) ) then
--                         return array();
--                 end;

--                 status_links = array();
--                 num_posts    = wp_count_posts( post_type, "readable" );
--                 total_posts  = array_sum( (array) num_posts );
--                 class        = "";

--                 current_user_id = get_current_user_id();
--                 all_args        = array( "post_type" => post_type );
--                 mine            = "";

--                 // Subtract post types that are not included in the admin all list.
--                 foreach ( get_post_stati( array( "show_in_admin_all_list" => false ) ) as state ) then
--                         total_posts -= num_posts->state;
--                 end;

--                 if ( this->user_posts_count && this->user_posts_count !== total_posts ) then
--                         if ( isset( _GET["author"] ) && ( current_user_id === (int) _GET["author"] ) ) then
--                                 class = "current";
--                         end;

--                         mine_args = array(
--                                 "post_type" => post_type,
--                                 "author"    => current_user_id,
--                         );

--                         mine_inner_html = sprintf(
--                                 /* translators: %s: Number of posts.--
--                                 _nx(
--                                         "Mine <span class="count">(%s)</span>",
--                                         "Mine <span class="count">(%s)</span>",
--                                         this->user_posts_count,
--                                         "posts"
--                                 ),
--                                 number_format_i18n( this->user_posts_count )
--                         );

--                         mine = array(
--                                 "url"     => esc_url( add_query_arg( mine_args, "edit.php" ) ),
--                                 "label"   => mine_inner_html,
--                                 "current" => isset( _GET["author"] ) && ( current_user_id === (int) _GET["author"] ),
--                         );

--                         all_args["all_posts"] = 1;
--                         class                 = "";
--                 end;

--                 all_inner_html = sprintf(
--                         /* translators: %s: Number of posts.--
--                         _nx(
--                                 "All <span class="count">(%s)</span>",
--                                 "All <span class="count">(%s)</span>",
--                                 total_posts,
--                                 "posts"
--                         ),
--                         number_format_i18n( total_posts )
--                 );

--                 status_links["all"] = array(
--                         "url"     => esc_url( add_query_arg( all_args, "edit.php" ) ),
--                         "label"   => all_inner_html,
--                         "current" => empty( class ) && ( this->is_base_request() || isset( _REQUEST["all_posts"] ) ),
--                 );

--                 if ( mine ) then
--                         status_links["mine"] = mine;
--                 end;

--                 foreach ( get_post_stati( array( "show_in_admin_status_list" => true ), "objects" ) as status ) then
--                         class = "";

--                         status_name = status->name;

--                         if ( ! in_array( status_name, avail_post_stati, true ) || empty( num_posts->status_name ) ) then
--                                 continue;
--                         end;

--                         if ( isset( _REQUEST["post_status"] ) && status_name === _REQUEST["post_status"] ) then
--                                 class = "current";
--                         end;

--                         status_args = array(
--                                 "post_status" => status_name,
--                                 "post_type"   => post_type,
--                         );

--                         status_label = sprintf(
--                                 translate_nooped_plural( status->label_count, num_posts->status_name ),
--                                 number_format_i18n( num_posts->status_name )
--                         );

--                         status_links[ status_name ] = array(
--                                 "url"     => esc_url( add_query_arg( status_args, "edit.php" ) ),
--                                 "label"   => status_label,
--                                 "current" => isset( _REQUEST["post_status"] ) && status_name === _REQUEST["post_status"],
--                         );
--                 end;

--                 if ( ! empty( this->sticky_posts_count ) ) then
--                         class = ! empty( _REQUEST["show_sticky"] ) ? "current" : "";

--                         sticky_args = array(
--                                 "post_type"   => post_type,
--                                 "show_sticky" => 1,
--                         );

--                         sticky_inner_html = sprintf(
--                                 /* translators: %s: Number of posts.--
--                                 _nx(
--                                         "Sticky <span class="count">(%s)</span>",
--                                         "Sticky <span class="count">(%s)</span>",
--                                         this->sticky_posts_count,
--                                         "posts"
--                                 ),
--                                 number_format_i18n( this->sticky_posts_count )
--                         );

--                         sticky_link = array(
--                                 "sticky" => array(
--                                         "url"     => esc_url( add_query_arg( sticky_args, "edit.php" ) ),
--                                         "label"   => sticky_inner_html,
--                                         "current" => ! empty( _REQUEST["show_sticky"] ),
--                                 ),
--                         );

--                         // Sticky comes after Publish, or if not listed, after All.
--                         split        = 1 + array_search( ( isset( status_links["publish"] ) ? "publish" : "all" ), array_keys( status_links ), true );
--                         status_links = array_merge( array_slice( status_links, 0, split ), sticky_link, array_slice( status_links, split ) );
--                 end;

--                 return this->get_views_links( status_links );
--         end;

--         --
--         -- @return array
--         --
--         protected function get_bulk_actions() then
--                 actions       = array();
--                 post_type_obj = get_post_type_object( this->screen->post_type );

--                 if ( current_user_can( post_type_obj->cap->edit_posts ) ) then
--                         if ( this->is_trash ) then
--                                 actions["untrash"] = __( "Restore" );
--                         end; else then
--                                 actions["edit"] = __( "Edit" );
--                         end;
--                 end;

--                 if ( current_user_can( post_type_obj->cap->delete_posts ) ) then
--                         if ( this->is_trash || ! EMPTY_TRASH_DAYS ) then
--                                 actions["delete"] = __( "Delete permanently" );
--                         end; else then
--                                 actions["trash"] = __( "Move to Trash" );
--                         end;
--                 end;

--                 return actions;
--         end;

--         --
--         -- Displays a categories drop-down for filtering on the Posts list table.
--         --
--         -- @since 4.6.0
--         --
--         -- @global int cat Currently selected category.
--         --
--         -- @param string post_type Post type slug.
--         --
--         protected function categories_dropdown( post_type ) then
--                 global cat;

--                 --
--                 -- Filters whether to remove the "Categories" drop-down from the post list table.
--                 --
--                 -- @since 4.6.0
--                 --
--                 -- @param bool   disable   Whether to disable the categories drop-down. Default false.
--                 -- @param string post_type Post type slug.
--                 --
--                 if ( false !== apply_filters( "disable_categories_dropdown", false, post_type ) ) then
--                         return;
--                 end;

--                 if ( is_object_in_taxonomy( post_type, "category" ) ) then
--                         dropdown_options = array(
--                                 "show_option_all" => get_taxonomy( "category" )->labels->all_items,
--                                 "hide_empty"      => 0,
--                                 "hierarchical"    => 1,
--                                 "show_count"      => 0,
--                                 "orderby"         => "name",
--                                 "selected"        => cat,
--                         );

--                         echo "<label class="screen-reader-text" for="cat">" . get_taxonomy( "category" )->labels->filter_by_item . "</label>";

--                         wp_dropdown_categories( dropdown_options );
--                 end;
--         end;

--         --
--         -- Displays a formats drop-down for filtering items.
--         --
--         -- @since 5.2.0
--         -- @access protected
--         --
--         -- @param string post_type Post type slug.
--         --
--         protected function formats_dropdown( post_type ) then
--                 --
--                 -- Filters whether to remove the "Formats" drop-down from the post list table.
--                 --
--                 -- @since 5.2.0
--                 -- @since 5.5.0 The `post_type` parameter was added.
--                 --
--                 -- @param bool   disable   Whether to disable the drop-down. Default false.
--                 -- @param string post_type Post type slug.
--                 --
--                 if ( apply_filters( "disable_formats_dropdown", false, post_type ) ) then
--                         return;
--                 end;

--                 // Return if the post type doesn"t have post formats or if we"re in the Trash.
--                 if ( ! is_object_in_taxonomy( post_type, "post_format" ) || this->is_trash ) then
--                         return;
--                 end;

--                 // Make sure the dropdown shows only formats with a post count greater than 0.
--                 used_post_formats = get_terms(
--                         array(
--                                 "taxonomy"   => "post_format",
--                                 "hide_empty" => true,
--                         )
--                 );

--                 // Return if there are no posts using formats.
--                 if ( ! used_post_formats ) then
--                         return;
--                 end;

--                 displayed_post_format = isset( _GET["post_format"] ) ? _GET["post_format"] : "";
--                 ?>
--                 <label for="filter-by-format" class="screen-reader-text"><?php _e( "Filter by post format" ); ?></label>
--                 <select name="post_format" id="filter-by-format">
--                         <option<?php selected( displayed_post_format, "" ); ?> value=""><?php _e( "All formats" ); ?></option>
--                         <?php
--                         foreach ( used_post_formats as used_post_format ) then
--                                 // Post format slug.
--                                 slug = str_replace( "post-format-", "", used_post_format->slug );
--                                 // Pretty, translated version of the post format slug.
--                                 pretty_name = get_post_format_string( slug );

--                                 // Skip the standard post format.
--                                 if ( "standard" === slug ) then
--                                         continue;
--                                 end;
--                                 ?>
--                                 <option<?php selected( displayed_post_format, slug ); ?> value="<?php echo esc_attr( slug ); ?>"><?php echo esc_html( pretty_name ); ?></option>
--                                 <?php
--                         end;
--                         ?>
--                 </select>
--                 <?php
--         end;

--         --
--         -- @param string which
--         --
--         protected function extra_tablenav( which ) then
--                 ?>
--                 <div class="alignleft actions">
--                 <?php
--                 if ( "top" === which ) then
--                         ob_start();

--                         this->months_dropdown( this->screen->post_type );
--                         this->categories_dropdown( this->screen->post_type );
--                         this->formats_dropdown( this->screen->post_type );

--                         --
--                         -- Fires before the Filter button on the Posts and Pages list tables.
--                         --
--                         -- The Filter button allows sorting by date and/or category on the
--                         -- Posts list table, and sorting by date on the Pages list table.
--                         --
--                         -- @since 2.1.0
--                         -- @since 4.4.0 The `post_type` parameter was added.
--                         -- @since 4.6.0 The `which` parameter was added.
--                         --
--                         -- @param string post_type The post type slug.
--                         -- @param string which     The location of the extra table nav markup:
--                         --                          "top" or "bottom" for WP_Posts_List_Table,
--                         --                          "bar" for WP_Media_List_Table.
--                         --
--                         do_action( "restrict_manage_posts", this->screen->post_type, which );

--                         output = ob_get_clean();

--                         if ( ! empty( output ) ) then
--                                 echo output;
--                                 submit_button( __( "Filter" ), "", "filter_action", false, array( "id" => "post-query-submit" ) );
--                         end;
--                 end;

--                 if ( this->is_trash && this->has_items()
--                         && current_user_can( get_post_type_object( this->screen->post_type )->cap->edit_others_posts )
--                 ) then
--                         submit_button( __( "Empty Trash" ), "apply", "delete_all", false );
--                 end;
--                 ?>
--                 </div>
--                 <?php
--                 --
--                 -- Fires immediately following the closing "actions" div in the tablenav for the posts
--                 -- list table.
--                 --
--                 -- @since 4.4.0
--                 --
--                 -- @param string which The location of the extra table nav markup: "top" or "bottom".
--                 --
--                 do_action( "manage_posts_extra_tablenav", which );
--         end;

--         --
--         -- @return string
--         --
--         public function current_action() then
--                 if ( isset( _REQUEST["delete_all"] ) || isset( _REQUEST["delete_all2"] ) ) then
--                         return "delete_all";
--                 end;

--                 return parent::current_action();
--         end;

--         --
--         -- @global string mode List table view mode.
--         --
--         -- @return array
--         --
--         protected function get_table_classes() then
--                 global mode;

--                 mode_class = esc_attr( "table-view-" . mode );

--                 return array(
--                         "widefat",
--                         "fixed",
--                         "striped",
--                         mode_class,
--                         is_post_type_hierarchical( this->screen->post_type ) ? "pages" : "posts",
--                 );
--         end;

--         --
--         -- @return array
--         --
--         public function get_columns() then
--                 post_type = this->screen->post_type;

--                 posts_columns = array();

--                 posts_columns["cb"] = "<input type="checkbox" />";

--                 /* translators: Posts screen column name.--
--                 posts_columns["title"] = _x( "Title", "column name" );

--                 if ( post_type_supports( post_type, "author" ) ) then
--                         posts_columns["author"] = __( "Author" );
--                 end;

--                 taxonomies = get_object_taxonomies( post_type, "objects" );
--                 taxonomies = wp_filter_object_list( taxonomies, array( "show_admin_column" => true ), "and", "name" );

--                 --
--                 -- Filters the taxonomy columns in the Posts list table.
--                 --
--                 -- The dynamic portion of the hook name, `post_type`, refers to the post
--                 -- type slug.
--                 --
--                 -- Possible hook names include:
--                 --
--                 --  - `manage_taxonomies_for_post_columns`
--                 --  - `manage_taxonomies_for_page_columns`
--                 --
--                 -- @since 3.5.0
--                 --
--                 -- @param string[] taxonomies Array of taxonomy names to show columns for.
--                 -- @param string   post_type  The post type.
--                 --
--                 taxonomies = apply_filters( "manage_taxonomies_for_thenpost_typeend;_columns", taxonomies, post_type );
--                 taxonomies = array_filter( taxonomies, "taxonomy_exists" );

--                 foreach ( taxonomies as taxonomy ) then
--                         if ( "category" === taxonomy ) then
--                                 column_key = "categories";
--                         end; elseif ( "post_tag" === taxonomy ) then
--                                 column_key = "tags";
--                         end; else then
--                                 column_key = "taxonomy-" . taxonomy;
--                         end;

--                         posts_columns[ column_key ] = get_taxonomy( taxonomy )->labels->name;
--                 end;

--                 post_status = ! empty( _REQUEST["post_status"] ) ? _REQUEST["post_status"] : "all";

--                 if ( post_type_supports( post_type, "comments" )
--                         && ! in_array( post_status, array( "pending", "draft", "future" ), true )
--                 ) then
--                         posts_columns["comments"] = sprintf(
--                                 "<span class="vers comment-grey-bubble" title="%1s" aria-hidden="true"></span><span class="screen-reader-text">%2s</span>",
--                                 esc_attr__( "Comments" ),
--                                 __( "Comments" )
--                         );
--                 end;

--                 posts_columns["date"] = __( "Date" );

--                 if ( "page" === post_type ) then

--                         --
--                         -- Filters the columns displayed in the Pages list table.
--                         --
--                         -- @since 2.5.0
--                         --
--                         -- @param string[] post_columns An associative array of column headings.
--                         --
--                         posts_columns = apply_filters( "manage_pages_columns", posts_columns );
--                 end; else then

--                         --
--                         -- Filters the columns displayed in the Posts list table.
--                         --
--                         -- @since 1.5.0
--                         --
--                         -- @param string[] post_columns An associative array of column headings.
--                         -- @param string   post_type    The post type slug.
--                         --
--                         posts_columns = apply_filters( "manage_posts_columns", posts_columns, post_type );
--                 end;

--                 --
--                 -- Filters the columns displayed in the Posts list table for a specific post type.
--                 --
--                 -- The dynamic portion of the hook name, `post_type`, refers to the post type slug.
--                 --
--                 -- Possible hook names include:
--                 --
--                 --  - `manage_post_posts_columns`
--                 --  - `manage_page_posts_columns`
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param string[] post_columns An associative array of column headings.
--                 --
--                 return apply_filters( "manage_thenpost_typeend;_posts_columns", posts_columns );
--         end;

--         --
--         -- @return array
--         --
--         protected function get_sortable_columns() then
--                 return array(
--                         "title"    => "title",
--                         "parent"   => "parent",
--                         "comments" => "comment_count",
--                         "date"     => array( "date", true ),
--                 );
--         end;

--         --
--         -- @global WP_Query wp_query WordPress Query object.
--         -- @global int per_page
--         -- @param array posts
--         -- @param int   level
--         --
--         public function display_rows( posts = array(), level = 0 ) then
--                 global wp_query, per_page;

--                 if ( empty( posts ) ) then
--                         posts = wp_query->posts;
--                 end;

--                 add_filter( "the_title", "esc_html" );

--                 if ( this->hierarchical_display ) then
--                         this->_display_rows_hierarchical( posts, this->get_pagenum(), per_page );
--                 end; else then
--                         this->_display_rows( posts, level );
--                 end;
--         end;

--         --
--         -- @param array posts
--         -- @param int   level
--         --
--         private function _display_rows( posts, level = 0 ) then
--                 post_type = this->screen->post_type;

--                 // Create array of post IDs.
--                 post_ids = array();

--                 foreach ( posts as a_post ) then
--                         post_ids[] = a_post->ID;
--                 end;

--                 if ( post_type_supports( post_type, "comments" ) ) then
--                         this->comment_pending_count = get_pending_comments_num( post_ids );
--                 end;
--                 update_post_author_caches( posts );

--                 foreach ( posts as post ) then
--                         this->single_row( post, level );
--                 end;
--         end;

--         --
--         -- @global wpdb    wpdb WordPress database abstraction object.
--         -- @global WP_Post post Global post object.
--         -- @param array pages
--         -- @param int   pagenum
--         -- @param int   per_page
--         --
--         private function _display_rows_hierarchical( pages, pagenum = 1, per_page = 20 ) then
--                 global wpdb;

--                 level = 0;

--                 if ( ! pages ) then
--                         pages = get_pages( array( "sort_column" => "menu_order" ) );

--                         if ( ! pages ) then
--                                 return;
--                         end;
--                 end;

--                 /*
--                 -- Arrange pages into two parts: top level pages and children_pages.
--                 -- children_pages is two dimensional array. Example:
--                 -- children_pages[10][] contains all sub-pages whose parent is 10.
--                 -- It only takes O( N ) to arrange this and it takes O( 1 ) for subsequent lookup operations
--                 -- If searching, ignore hierarchy and treat everything as top level
--                 --
--                 if ( empty( _REQUEST["s"] ) ) then
--                         top_level_pages = array();
--                         children_pages  = array();

--                         foreach ( pages as page ) then
--                                 // Catch and repair bad pages.
--                                 if ( page->post_parent === page->ID ) then
--                                         page->post_parent = 0;
--                                         wpdb->update( wpdb->posts, array( "post_parent" => 0 ), array( "ID" => page->ID ) );
--                                         clean_post_cache( page );
--                                 end;

--                                 if ( page->post_parent > 0 ) then
--                                         children_pages[ page->post_parent ][] = page;
--                                 end; else then
--                                         top_level_pages[] = page;
--                                 end;
--                         end;

--                         pages = &top_level_pages;
--                 end;

--                 count      = 0;
--                 start      = ( pagenum - 1 )-- per_page;
--                 end        = start + per_page;
--                 to_display = array();

--                 foreach ( pages as page ) then
--                         if ( count >= end ) then
--                                 break;
--                         end;

--                         if ( count >= start ) then
--                                 to_display[ page->ID ] = level;
--                         end;

--                         count++;

--                         if ( isset( children_pages ) ) then
--                                 this->_page_rows( children_pages, count, page->ID, level + 1, pagenum, per_page, to_display );
--                         end;
--                 end;

--                 // If it is the last pagenum and there are orphaned pages, display them with paging as well.
--                 if ( isset( children_pages ) && count < end ) then
--                         foreach ( children_pages as orphans ) then
--                                 foreach ( orphans as op ) then
--                                         if ( count >= end ) then
--                                                 break;
--                                         end;

--                                         if ( count >= start ) then
--                                                 to_display[ op->ID ] = 0;
--                                         end;

--                                         count++;
--                                 end;
--                         end;
--                 end;

--                 ids = array_keys( to_display );
--                 _prime_post_caches( ids );
--                 _posts = array_map( "get_post", ids );
--                 update_post_author_caches( _posts );

--                 if ( ! isset( GLOBALS["post"] ) ) then
--                         GLOBALS["post"] = reset( ids );
--                 end;

--                 foreach ( to_display as page_id => level ) then
--                         echo "\t";
--                         this->single_row( page_id, level );
--                 end;
--         end;

--         --
--         -- Given a top level page ID, display the nested hierarchy of sub-pages
--         -- together with paging support
--         --
--         -- @since 3.1.0 (Standalone function exists since 2.6.0)
--         -- @since 4.2.0 Added the `to_display` parameter.
--         --
--         -- @param array children_pages
--         -- @param int   count
--         -- @param int   parent_page
--         -- @param int   level
--         -- @param int   pagenum
--         -- @param int   per_page
--         -- @param array to_display List of pages to be displayed. Passed by reference.
--         --
--         private function _page_rows( &children_pages, &count, parent_page, level, pagenum, per_page, &to_display ) then
--                 if ( ! isset( children_pages[ parent_page ] ) ) then
--                         return;
--                 end;

--                 start = ( pagenum - 1 )-- per_page;
--                 end   = start + per_page;

--                 foreach ( children_pages[ parent_page ] as page ) then
--                         if ( count >= end ) then
--                                 break;
--                         end;

--                         // If the page starts in a subtree, print the parents.
--                         if ( count === start && page->post_parent > 0 ) then
--                                 my_parents = array();
--                                 my_parent  = page->post_parent;

--                                 while ( my_parent ) then
--                                         // Get the ID from the list or the attribute if my_parent is an object.
--                                         parent_id = my_parent;

--                                         if ( is_object( my_parent ) ) then
--                                                 parent_id = my_parent->ID;
--                                         end;

--                                         my_parent    = get_post( parent_id );
--                                         my_parents[] = my_parent;

--                                         if ( ! my_parent->post_parent ) then
--                                                 break;
--                                         end;

--                                         my_parent = my_parent->post_parent;
--                                 end;

--                                 num_parents = count( my_parents );

--                                 while ( my_parent = array_pop( my_parents ) ) then
--                                         to_display[ my_parent->ID ] = level - num_parents;
--                                         num_parents--;
--                                 end;
--                         end;

--                         if ( count >= start ) then
--                                 to_display[ page->ID ] = level;
--                         end;

--                         count++;

--                         this->_page_rows( children_pages, count, page->ID, level + 1, pagenum, per_page, to_display );
--                 end;

--                 unset( children_pages[ parent_page ] ); // Required in order to keep track of orphans.
--         end;

--         --
--         -- Handles the checkbox column output.
--         --
--         -- @since 4.3.0
--         -- @since 5.9.0 Renamed `post` to `item` to match parent class for PHP 8 named parameter support.
--         --
--         -- @param WP_Post item The current WP_Post object.
--         --
--         public function column_cb( item ) then
--                 // Restores the more descriptive, specific name for use within this method.
--                 post = item;
--                 show = current_user_can( "edit_post", post->ID );

--                 --
--                 -- Filters whether to show the bulk edit checkbox for a post in its list table.
--                 --
--                 -- By default the checkbox is only shown if the current user can edit the post.
--                 --
--                 -- @since 5.7.0
--                 --
--                 -- @param bool    show Whether to show the checkbox.
--                 -- @param WP_Post post The current WP_Post object.
--                 --
--                 if ( apply_filters( "wp_list_table_show_post_checkbox", show, post ) ) :
--                         ?>
--                         <label class="screen-reader-text" for="cb-select-<?php the_ID(); ?>">
--                                 <?php
--                                         /* translators: %s: Post title.--
--                                         printf( __( "Select %s" ), _draft_or_post_title() );
--                                 ?>
--                         </label>
--                         <input id="cb-select-<?php the_ID(); ?>" type="checkbox" name="post[]" value="<?php the_ID(); ?>" />
--                         <div class="locked-indicator">
--                                 <span class="locked-indicator-icon" aria-hidden="true"></span>
--                                 <span class="screen-reader-text">
--                                 <?php
--                                 printf(
--                                         /* translators: %s: Post title.--
--                                         __( "&#8220;%s&#8221; is locked" ),
--                                         _draft_or_post_title()
--                                 );
--                                 ?>
--                                 </span>
--                         </div>
--                         <?php
--                 endif;
--         end;

--         --
--         -- @since 4.3.0
--         --
--         -- @param WP_Post post
--         -- @param string  classes
--         -- @param string  data
--         -- @param string  primary
--         --
--         protected function _column_title( post, classes, data, primary ) then
--                 echo "<td class="" . classes . " page-title" ", data, ">";
--                 echo this->column_title( post );
--                 echo this->handle_row_actions( post, "title", primary );
--                 echo "</td>";
--         end;

--         --
--         -- Handles the title column output.
--         --
--         -- @since 4.3.0
--         --
--         -- @global string mode List table view mode.
--         --
--         -- @param WP_Post post The current WP_Post object.
--         --
--         public function column_title( post ) then
--                 global mode;

--                 if ( this->hierarchical_display ) then
--                         if ( 0 === this->current_level && (int) post->post_parent > 0 ) then
--                                 // Sent level 0 by accident, by default, or because we don"t know the actual level.
--                                 find_main_page = (int) post->post_parent;

--                                 while ( find_main_page > 0 ) then
--                                         parent = get_post( find_main_page );

--                                         if ( is_null( parent ) ) then
--                                                 break;
--                                         end;

--                                         this->current_level++;
--                                         find_main_page = (int) parent->post_parent;

--                                         if ( ! isset( parent_name ) ) then
--                                                 -- This filter is documented in wp-includes/post-template.php--
--                                                 parent_name = apply_filters( "the_title", parent->post_title, parent->ID );
--                                         end;
--                                 end;
--                         end;
--                 end;

--                 can_edit_post = current_user_can( "edit_post", post->ID );

--                 if ( can_edit_post && "trash" !== post->post_status ) then
--                         lock_holder = wp_check_post_lock( post->ID );

--                         if ( lock_holder ) then
--                                 lock_holder   = get_userdata( lock_holder );
--                                 locked_avatar = get_avatar( lock_holder->ID, 18 );
--                                 /* translators: %s: User"s display name.--
--                                 locked_text = esc_html( sprintf( __( "%s is currently editing" ), lock_holder->display_name ) );
--                         end; else then
--                                 locked_avatar = "";
--                                 locked_text   = "";
--                         end;

--                         echo "<div class="locked-info"><span class="locked-avatar">" . locked_avatar . "</span> <span class="locked-text">" . locked_text . "</span></div>\n";
--                 end;

--                 pad = str_repeat( "&#8212; ", this->current_level );
--                 echo "<strong>";

--                 title = _draft_or_post_title();

--                 if ( can_edit_post && "trash" !== post->post_status ) then
--                         printf(
--                                 "<a class="row-title" href="%s" aria-label="%s">%s%s</a>",
--                                 get_edit_post_link( post->ID ),
--                                 /* translators: %s: Post title.--
--                                 esc_attr( sprintf( __( "&#8220;%s&#8221; (Edit)" ), title ) ),
--                                 pad,
--                                 title
--                         );
--                 end; else then
--                         printf(
--                                 "<span>%s%s</span>",
--                                 pad,
--                                 title
--                         );
--                 end;
--                 _post_states( post );

--                 if ( isset( parent_name ) ) then
--                         post_type_object = get_post_type_object( post->post_type );
--                         echo " | " . post_type_object->labels->parent_item_colon . " " . esc_html( parent_name );
--                 end;

--                 echo "</strong>\n";

--                 if ( "excerpt" === mode
--                         && ! is_post_type_hierarchical( this->screen->post_type )
--                         && current_user_can( "read_post", post->ID )
--                 ) then
--                         if ( post_password_required( post ) ) then
--                                 echo "<span class="protected-post-excerpt">" . esc_html( get_the_excerpt() ) . "</span>";
--                         end; else then
--                                 echo esc_html( get_the_excerpt() );
--                         end;
--                 end;

--                 get_inline_data( post );
--         end;

--         --
--         -- Handles the post date column output.
--         --
--         -- @since 4.3.0
--         --
--         -- @global string mode List table view mode.
--         --
--         -- @param WP_Post post The current WP_Post object.
--         --
--         public function column_date( post ) then
--                 global mode;

--                 if ( "0000-00-00 00:00:00" === post->post_date ) then
--                         t_time    = __( "Unpublished" );
--                         time_diff = 0;
--                 end; else then
--                         t_time = sprintf(
--                                 /* translators: 1: Post date, 2: Post time.--
--                                 __( "%1s at %2s" ),
--                                 /* translators: Post date format. See https://www.php.net/manual/datetime.format.php--
--                                 get_the_time( __( "Y/m/d" ), post ),
--                                 /* translators: Post time format. See https://www.php.net/manual/datetime.format.php--
--                                 get_the_time( __( "g:i a" ), post )
--                         );

--                         time      = get_post_timestamp( post );
--                         time_diff = time() - time;
--                 end;

--                 if ( "publish" === post->post_status ) then
--                         status = __( "Published" );
--                 end; elseif ( "future" === post->post_status ) then
--                         if ( time_diff > 0 ) then
--                                 status = "<strong class="error-message">" . __( "Missed schedule" ) . "</strong>";
--                         end; else then
--                                 status = __( "Scheduled" );
--                         end;
--                 end; else then
--                         status = __( "Last Modified" );
--                 end;

--                 --
--                 -- Filters the status text of the post.
--                 --
--                 -- @since 4.8.0
--                 --
--                 -- @param string  status      The status text.
--                 -- @param WP_Post post        Post object.
--                 -- @param string  column_name The column name.
--                 -- @param string  mode        The list display mode ("excerpt" or "list").
--                 --
--                 status = apply_filters( "post_date_column_status", status, post, "date", mode );

--                 if ( status ) then
--                         echo status . "<br />";
--                 end;

--                 --
--                 -- Filters the published time of the post.
--                 --
--                 -- @since 2.5.1
--                 -- @since 5.5.0 Removed the difference between "excerpt" and "list" modes.
--                 --              The published time and date are both displayed now,
--                 --              which is equivalent to the previous "excerpt" mode.
--                 --
--                 -- @param string  t_time      The published time.
--                 -- @param WP_Post post        Post object.
--                 -- @param string  column_name The column name.
--                 -- @param string  mode        The list display mode ("excerpt" or "list").
--                 --
--                 echo apply_filters( "post_date_column_time", t_time, post, "date", mode );
--         end;

--         --
--         -- Handles the comments column output.
--         --
--         -- @since 4.3.0
--         --
--         -- @param WP_Post post The current WP_Post object.
--         --
--         public function column_comments( post ) then
--                 ?>
--                 <div class="post-com-count-wrapper">
--                 <?php
--                         pending_comments = isset( this->comment_pending_count[ post->ID ] ) ? this->comment_pending_count[ post->ID ] : 0;

--                         this->comments_bubble( post->ID, pending_comments );
--                 ?>
--                 </div>
--                 <?php
--         end;

--         --
--         -- Handles the post author column output.
--         --
--         -- @since 4.3.0
--         --
--         -- @param WP_Post post The current WP_Post object.
--         --
--         public function column_author( post ) then
--                 args = array(
--                         "post_type" => post->post_type,
--                         "author"    => get_the_author_meta( "ID" ),
--                 );
--                 echo this->get_edit_link( args, get_the_author() );
--         end;

--         --
--         -- Handles the default column output.
--         --
--         -- @since 4.3.0
--         -- @since 5.9.0 Renamed `post` to `item` to match parent class for PHP 8 named parameter support.
--         --
--         -- @param WP_Post item        The current WP_Post object.
--         -- @param string  column_name The current column name.
--         --
--         public function column_default( item, column_name ) then
--                 // Restores the more descriptive, specific name for use within this method.
--                 post = item;

--                 if ( "categories" === column_name ) then
--                         taxonomy = "category";
--                 end; elseif ( "tags" === column_name ) then
--                         taxonomy = "post_tag";
--                 end; elseif ( 0 === strpos( column_name, "taxonomy-" ) ) then
--                         taxonomy = substr( column_name, 9 );
--                 end; else then
--                         taxonomy = false;
--                 end;

--                 if ( taxonomy ) then
--                         taxonomy_object = get_taxonomy( taxonomy );
--                         terms           = get_the_terms( post->ID, taxonomy );

--                         if ( is_array( terms ) ) then
--                                 term_links = array();

--                                 foreach ( terms as t ) then
--                                         posts_in_term_qv = array();

--                                         if ( "post" !== post->post_type ) then
--                                                 posts_in_term_qv["post_type"] = post->post_type;
--                                         end;

--                                         if ( taxonomy_object->query_var ) then
--                                                 posts_in_term_qv[ taxonomy_object->query_var ] = t->slug;
--                                         end; else then
--                                                 posts_in_term_qv["taxonomy"] = taxonomy;
--                                                 posts_in_term_qv["term"]     = t->slug;
--                                         end;

--                                         label = esc_html( sanitize_term_field( "name", t->name, t->term_id, taxonomy, "display" ) );

--                                         term_links[] = this->get_edit_link( posts_in_term_qv, label );
--                                 end;

--                                 --
--                                 -- Filters the links in `taxonomy` column of edit.php.
--                                 --
--                                 -- @since 5.2.0
--                                 --
--                                 -- @param string[]  term_links Array of term editing links.
--                                 -- @param string    taxonomy   Taxonomy name.
--                                 -- @param WP_Term[] terms      Array of term objects appearing in the post row.
--                                 --
--                                 term_links = apply_filters( "post_column_taxonomy_links", term_links, taxonomy, terms );

--                                 echo implode( wp_get_list_item_separator(), term_links );
--                         end; else then
--                                 echo "<span aria-hidden="true">&#8212;</span><span class="screen-reader-text">" . taxonomy_object->labels->no_terms . "</span>";
--                         end;
--                         return;
--                 end;

--                 if ( is_post_type_hierarchical( post->post_type ) ) then

--                         --
--                         -- Fires in each custom column on the Posts list table.
--                         --
--                         -- This hook only fires if the current post type is hierarchical,
--                         -- such as pages.
--                         --
--                         -- @since 2.5.0
--                         --
--                         -- @param string column_name The name of the column to display.
--                         -- @param int    post_id     The current post ID.
--                         --
--                         do_action( "manage_pages_custom_column", column_name, post->ID );
--                 end; else then

--                         --
--                         -- Fires in each custom column in the Posts list table.
--                         --
--                         -- This hook only fires if the current post type is non-hierarchical,
--                         -- such as posts.
--                         --
--                         -- @since 1.5.0
--                         --
--                         -- @param string column_name The name of the column to display.
--                         -- @param int    post_id     The current post ID.
--                         --
--                         do_action( "manage_posts_custom_column", column_name, post->ID );
--                 end;

--                 --
--                 -- Fires for each custom column of a specific post type in the Posts list table.
--                 --
--                 -- The dynamic portion of the hook name, `post->post_type`, refers to the post type.
--                 --
--                 -- Possible hook names include:
--                 --
--                 --  - `manage_post_posts_custom_column`
--                 --  - `manage_page_posts_custom_column`
--                 --
--                 -- @since 3.1.0
--                 --
--                 -- @param string column_name The name of the column to display.
--                 -- @param int    post_id     The current post ID.
--                 --
--                 do_action( "manage_thenpost->post_typeend;_posts_custom_column", column_name, post->ID );
--         end;

--         --
--         -- @global WP_Post post Global post object.
--         --
--         -- @param int|WP_Post post
--         -- @param int         level
--         --
--         public function single_row( post, level = 0 ) then
--                 global_post = get_post();

--                 post                = get_post( post );
--                 this->current_level = level;

--                 GLOBALS["post"] = post;
--                 setup_postdata( post );

--                 classes = "iedit author-" . ( get_current_user_id() === (int) post->post_author ? "self" : "other" );

--                 lock_holder = wp_check_post_lock( post->ID );

--                 if ( lock_holder ) then
--                         classes .= " wp-locked";
--                 end;

--                 if ( post->post_parent ) then
--                         count    = count( get_post_ancestors( post->ID ) );
--                         classes .= " level-" . count;
--                 end; else then
--                         classes .= " level-0";
--                 end;
--                 ?>
--                 <tr id="post-<?php echo post->ID; ?>" class="<?php echo implode( " ", get_post_class( classes, post->ID ) ); ?>">
--                         <?php this->single_row_columns( post ); ?>
--                 </tr>
--                 <?php
--                 GLOBALS["post"] = global_post;
--         end;

--         --
--         -- Gets the name of the default primary column.
--         --
--         -- @since 4.3.0
--         --
--         -- @return string Name of the default primary column, in this case, "title".
--         --
--         protected function get_default_primary_column_name() then
--                 return "title";
--         end;

--         --
--         -- Generates and displays row action links.
--         --
--         -- @since 4.3.0
--         -- @since 5.9.0 Renamed `post` to `item` to match parent class for PHP 8 named parameter support.
--         --
--         -- @param WP_Post item        Post being acted upon.
--         -- @param string  column_name Current column name.
--         -- @param string  primary     Primary column name.
--         -- @return string Row actions output for posts, or an empty string
--         --                if the current column is not the primary column.
--         --
--         protected function handle_row_actions( item, column_name, primary ) then
--                 if ( primary !== column_name ) then
--                         return "";
--                 end;

--                 // Restores the more descriptive, specific name for use within this method.
--                 post             = item;
--                 post_type_object = get_post_type_object( post->post_type );
--                 can_edit_post    = current_user_can( "edit_post", post->ID );
--                 actions          = array();
--                 title            = _draft_or_post_title();

--                 if ( can_edit_post && "trash" !== post->post_status ) then
--                         actions["edit"] = sprintf(
--                                 "<a href="%s" aria-label="%s">%s</a>",
--                                 get_edit_post_link( post->ID ),
--                                 /* translators: %s: Post title.--
--                                 esc_attr( sprintf( __( "Edit &#8220;%s&#8221;" ), title ) ),
--                                 __( "Edit" )
--                         );

--                         if ( "wp_block" !== post->post_type ) then
--                                 actions["inline hide-if-no-js"] = sprintf(
--                                         "<button type="button" class="button-link editinline" aria-label="%s" aria-expanded="false">%s</button>",
--                                         /* translators: %s: Post title.--
--                                         esc_attr( sprintf( __( "Quick edit &#8220;%s&#8221; inline" ), title ) ),
--                                         __( "Quick&nbsp;Edit" )
--                                 );
--                         end;
--                 end;

--                 if ( current_user_can( "delete_post", post->ID ) ) then
--                         if ( "trash" === post->post_status ) then
--                                 actions["untrash"] = sprintf(
--                                         "<a href="%s" aria-label="%s">%s</a>",
--                                         wp_nonce_url( admin_url( sprintf( post_type_object->_edit_link . "&amp;action=untrash", post->ID ) ), "untrash-post_" . post->ID ),
--                                         /* translators: %s: Post title.--
--                                         esc_attr( sprintf( __( "Restore &#8220;%s&#8221; from the Trash" ), title ) ),
--                                         __( "Restore" )
--                                 );
--                         end; elseif ( EMPTY_TRASH_DAYS ) then
--                                 actions["trash"] = sprintf(
--                                         "<a href="%s" class="submitdelete" aria-label="%s">%s</a>",
--                                         get_delete_post_link( post->ID ),
--                                         /* translators: %s: Post title.--
--                                         esc_attr( sprintf( __( "Move &#8220;%s&#8221; to the Trash" ), title ) ),
--                                         _x( "Trash", "verb" )
--                                 );
--                         end;

--                         if ( "trash" === post->post_status || ! EMPTY_TRASH_DAYS ) then
--                                 actions["delete"] = sprintf(
--                                         "<a href="%s" class="submitdelete" aria-label="%s">%s</a>",
--                                         get_delete_post_link( post->ID, "", true ),
--                                         /* translators: %s: Post title.--
--                                         esc_attr( sprintf( __( "Delete &#8220;%s&#8221; permanently" ), title ) ),
--                                         __( "Delete Permanently" )
--                                 );
--                         end;
--                 end;

--                 if ( is_post_type_viewable( post_type_object ) ) then
--                         if ( in_array( post->post_status, array( "pending", "draft", "future" ), true ) ) then
--                                 if ( can_edit_post ) then
--                                         preview_link    = get_preview_post_link( post );
--                                         actions["view"] = sprintf(
--                                                 "<a href="%s" rel="bookmark" aria-label="%s">%s</a>",
--                                                 esc_url( preview_link ),
--                                                 /* translators: %s: Post title.--
--                                                 esc_attr( sprintf( __( "Preview &#8220;%s&#8221;" ), title ) ),
--                                                 __( "Preview" )
--                                         );
--                                 end;
--                         end; elseif ( "trash" !== post->post_status ) then
--                                 actions["view"] = sprintf(
--                                         "<a href="%s" rel="bookmark" aria-label="%s">%s</a>",
--                                         get_permalink( post->ID ),
--                                         /* translators: %s: Post title.--
--                                         esc_attr( sprintf( __( "View &#8220;%s&#8221;" ), title ) ),
--                                         __( "View" )
--                                 );
--                         end;
--                 end;

--                 if ( "wp_block" === post->post_type ) then
--                         actions["export"] = sprintf(
--                                 "<button type="button" class="wp-list-reusable-blocks__export button-link" data-id="%s" aria-label="%s">%s</button>",
--                                 post->ID,
--                                 /* translators: %s: Post title.--
--                                 esc_attr( sprintf( __( "Export &#8220;%s&#8221; as JSON" ), title ) ),
--                                 __( "Export as JSON" )
--                         );
--                 end;

--                 if ( is_post_type_hierarchical( post->post_type ) ) then

--                         --
--                         -- Filters the array of row action links on the Pages list table.
--                         --
--                         -- The filter is evaluated only for hierarchical post types.
--                         --
--                         -- @since 2.8.0
--                         --
--                         -- @param string[] actions An array of row action links. Defaults are
--                         --                          "Edit", "Quick Edit", "Restore", "Trash",
--                         --                          "Delete Permanently", "Preview", and "View".
--                         -- @param WP_Post  post    The post object.
--                         --
--                         actions = apply_filters( "page_row_actions", actions, post );
--                 end; else then

--                         --
--                         -- Filters the array of row action links on the Posts list table.
--                         --
--                         -- The filter is evaluated only for non-hierarchical post types.
--                         --
--                         -- @since 2.8.0
--                         --
--                         -- @param string[] actions An array of row action links. Defaults are
--                         --                          "Edit", "Quick Edit", "Restore", "Trash",
--                         --                          "Delete Permanently", "Preview", and "View".
--                         -- @param WP_Post  post    The post object.
--                         --
--                         actions = apply_filters( "post_row_actions", actions, post );
--                 end;

--                 return this->row_actions( actions );
--         end;

--         --
--         -- Outputs the hidden row displayed when inline editing
--         --
--         -- @since 3.1.0
--         --
--         -- @global string mode List table view mode.
--         --
--         public function inline_edit() then
--                 global mode;

--                 screen = this->screen;

--                 post             = get_default_post_to_edit( screen->post_type );
--                 post_type_object = get_post_type_object( screen->post_type );

--                 taxonomy_names          = get_object_taxonomies( screen->post_type );
--                 hierarchical_taxonomies = array();
--                 flat_taxonomies         = array();

--                 foreach ( taxonomy_names as taxonomy_name ) then
--                         taxonomy = get_taxonomy( taxonomy_name );

--                         show_in_quick_edit = taxonomy->show_in_quick_edit;

--                         --
--                         -- Filters whether the current taxonomy should be shown in the Quick Edit panel.
--                         --
--                         -- @since 4.2.0
--                         --
--                         -- @param bool   show_in_quick_edit Whether to show the current taxonomy in Quick Edit.
--                         -- @param string taxonomy_name      Taxonomy name.
--                         -- @param string post_type          Post type of current Quick Edit post.
--                         --
--                         if ( ! apply_filters( "quick_edit_show_taxonomy", show_in_quick_edit, taxonomy_name, screen->post_type ) ) then
--                                 continue;
--                         end;

--                         if ( taxonomy->hierarchical ) then
--                                 hierarchical_taxonomies[] = taxonomy;
--                         end; else then
--                                 flat_taxonomies[] = taxonomy;
--                         end;
--                 end;

--                 m            = ( isset( mode ) && "excerpt" === mode ) ? "excerpt" : "list";
--                 can_publish  = current_user_can( post_type_object->cap->publish_posts );
--                 core_columns = array(
--                         "cb"         => true,
--                         "date"       => true,
--                         "title"      => true,
--                         "categories" => true,
--                         "tags"       => true,
--                         "comments"   => true,
--                         "author"     => true,
--                 );
--                 ?>

--                 <form method="get">
--                 <table style="display: none"><tbody id="inlineedit">
--                 <?php
--                 hclass              = count( hierarchical_taxonomies ) ? "post" : "page";
--                 inline_edit_classes = "inline-edit-row inline-edit-row-hclass";
--                 bulk_edit_classes   = "bulk-edit-row bulk-edit-row-hclass bulk-edit-thenscreen->post_typeend;";
--                 quick_edit_classes  = "quick-edit-row quick-edit-row-hclass inline-edit-thenscreen->post_typeend;";

--                 bulk = 0;

--                 while ( bulk < 2 ) :
--                         classes  = inline_edit_classes . " ";
--                         classes .= bulk ? bulk_edit_classes : quick_edit_classes;
--                         ?>
--                         <tr id="<?php echo bulk ? "bulk-edit" : "inline-edit"; ?>" class="<?php echo classes; ?>" style="display: none">
--                         <td colspan="<?php echo this->get_column_count(); ?>" class="colspanchange">
--                         <div class="inline-edit-wrapper" role="region" aria-labelledby="<?php echo bulk ? "bulk" : "quick"; ?>-edit-legend">
--                         <fieldset class="inline-edit-col-left">
--                                 <legend class="inline-edit-legend" id="<?php echo bulk ? "bulk" : "quick"; ?>-edit-legend"><?php echo bulk ? __( "Bulk Edit" ) : __( "Quick Edit" ); ?></legend>
--                                 <div class="inline-edit-col">

--                                 <?php if ( post_type_supports( screen->post_type, "title" ) ) : ?>

--                                         <?php if ( bulk ) : ?>

--                                                 <div id="bulk-title-div">
--                                                         <div id="bulk-titles"></div>
--                                                 </div>

--                                         <?php else : // bulk ?>

--                                                 <label>
--                                                         <span class="title"><?php _e( "Title" ); ?></span>
--                                                         <span class="input-text-wrap"><input type="text" name="post_title" class="ptitle" value="" /></span>
--                                                 </label>

--                                                 <?php if ( is_post_type_viewable( screen->post_type ) ) : ?>

--                                                         <label>
--                                                                 <span class="title"><?php _e( "Slug" ); ?></span>
--                                                                 <span class="input-text-wrap"><input type="text" name="post_name" value="" autocomplete="off" spellcheck="false" /></span>
--                                                         </label>

--                                                 <?php endif; // is_post_type_viewable() ?>

--                                         <?php endif; // bulk ?>

--                                 <?php endif; // post_type_supports( ... "title" ) ?>

--                                 <?php if ( ! bulk ) : ?>
--                                         <fieldset class="inline-edit-date">
--                                                 <legend><span class="title"><?php _e( "Date" ); ?></span></legend>
--                                                 <?php touch_time( 1, 1, 0, 1 ); ?>
--                                         </fieldset>
--                                         <br class="clear" />
--                                 <?php endif; // bulk ?>

--                                 <?php
--                                 if ( post_type_supports( screen->post_type, "author" ) ) then
--                                         authors_dropdown = "";

--                                         if ( current_user_can( post_type_object->cap->edit_others_posts ) ) then
--                                                 dropdown_name  = "post_author";
--                                                 dropdown_class = "authors";
--                                                 if ( wp_is_large_user_count() ) then
--                                                         authors_dropdown = sprintf( "<select name="%s" class="%s hidden"></select>", esc_attr( dropdown_name ), esc_attr( dropdown_class ) );
--                                                 end; else then
--                                                         users_opt = array(
--                                                                 "hide_if_only_one_author" => false,
--                                                                 "capability"              => array( post_type_object->cap->edit_posts ),
--                                                                 "name"                    => dropdown_name,
--                                                                 "class"                   => dropdown_class,
--                                                                 "multi"                   => 1,
--                                                                 "echo"                    => 0,
--                                                                 "show"                    => "display_name_with_login",
--                                                         );

--                                                         if ( bulk ) then
--                                                                 users_opt["show_option_none"] = __( "&mdash; No Change &mdash;" );
--                                                         end;

--                                                         --
--                                                         -- Filters the arguments used to generate the Quick Edit authors drop-down.
--                                                         --
--                                                         -- @since 5.6.0
--                                                         --
--                                                         -- @see wp_dropdown_users()
--                                                         --
--                                                         -- @param array users_opt An array of arguments passed to wp_dropdown_users().
--                                                         -- @param bool bulk A flag to denote if it"s a bulk action.
--                                                         --
--                                                         users_opt = apply_filters( "quick_edit_dropdown_authors_args", users_opt, bulk );

--                                                         authors = wp_dropdown_users( users_opt );

--                                                         if ( authors ) then
--                                                                 authors_dropdown  = "<label class="inline-edit-author">";
--                                                                 authors_dropdown .= "<span class="title">" . __( "Author" ) . "</span>";
--                                                                 authors_dropdown .= authors;
--                                                                 authors_dropdown .= "</label>";
--                                                         end;
--                                                 end;
--                                         end; // current_user_can( "edit_others_posts" )

--                                         if ( ! bulk ) then
--                                                 echo authors_dropdown;
--                                         end;
--                                 end; // post_type_supports( ... "author" )
--                                 ?>

--                                 <?php if ( ! bulk && can_publish ) : ?>

--                                         <div class="inline-edit-group wp-clearfix">
--                                                 <label class="alignleft">
--                                                         <span class="title"><?php _e( "Password" ); ?></span>
--                                                         <span class="input-text-wrap"><input type="text" name="post_password" class="inline-edit-password-input" value="" /></span>
--                                                 </label>

--                                                 <span class="alignleft inline-edit-or">
--                                                         <?php
--                                                         /* translators: Between password field and private checkbox on post quick edit interface.--
--                                                         _e( "&ndash;OR&ndash;" );
--                                                         ?>
--                                                 </span>
--                                                 <label class="alignleft inline-edit-private">
--                                                         <input type="checkbox" name="keep_private" value="private" />
--                                                         <span class="checkbox-title"><?php _e( "Private" ); ?></span>
--                                                 </label>
--                                         </div>

--                                 <?php endif; ?>

--                                 </div>
--                         </fieldset>

--                         <?php if ( count( hierarchical_taxonomies ) && ! bulk ) : ?>

--                                 <fieldset class="inline-edit-col-center inline-edit-categories">
--                                         <div class="inline-edit-col">

--                                         <?php foreach ( hierarchical_taxonomies as taxonomy ) : ?>

--                                                 <span class="title inline-edit-categories-label"><?php echo esc_html( taxonomy->labels->name ); ?></span>
--                                                 <input type="hidden" name="<?php echo ( "category" === taxonomy->name ) ? "post_category[]" : "tax_input[" . esc_attr( taxonomy->name ) . "][]"; ?>" value="0" />
--                                                 <ul class="cat-checklist <?php echo esc_attr( taxonomy->name ); ?>-checklist">
--                                                         <?php wp_terms_checklist( 0, array( "taxonomy" => taxonomy->name ) ); ?>
--                                                 </ul>

--                                         <?php endforeach; // hierarchical_taxonomies as taxonomy ?>

--                                         </div>
--                                 </fieldset>

--                         <?php endif; // count( hierarchical_taxonomies ) && ! bulk ?>

--                         <fieldset class="inline-edit-col-right">
--                                 <div class="inline-edit-col">

--                                 <?php
--                                 if ( post_type_supports( screen->post_type, "author" ) && bulk ) then
--                                         echo authors_dropdown;
--                                 end;
--                                 ?>

--                                 <?php if ( post_type_supports( screen->post_type, "page-attributes" ) ) : ?>

--                                         <?php if ( post_type_object->hierarchical ) : ?>

--                                                 <label>
--                                                         <span class="title"><?php _e( "Parent" ); ?></span>
--                                                         <?php
--                                                         dropdown_args = array(
--                                                                 "post_type"         => post_type_object->name,
--                                                                 "selected"          => post->post_parent,
--                                                                 "name"              => "post_parent",
--                                                                 "show_option_none"  => __( "Main Page (no parent)" ),
--                                                                 "option_none_value" => 0,
--                                                                 "sort_column"       => "menu_order, post_title",
--                                                         );

--                                                         if ( bulk ) then
--                                                                 dropdown_args["show_option_no_change"] = __( "&mdash; No Change &mdash;" );
--                                                         end;

--                                                         --
--                                                         -- Filters the arguments used to generate the Quick Edit page-parent drop-down.
--                                                         --
--                                                         -- @since 2.7.0
--                                                         -- @since 5.6.0 The `bulk` parameter was added.
--                                                         --
--                                                         -- @see wp_dropdown_pages()
--                                                         --
--                                                         -- @param array dropdown_args An array of arguments passed to wp_dropdown_pages().
--                                                         -- @param bool  bulk          A flag to denote if it"s a bulk action.
--                                                         --
--                                                         dropdown_args = apply_filters( "quick_edit_dropdown_pages_args", dropdown_args, bulk );

--                                                         wp_dropdown_pages( dropdown_args );
--                                                         ?>
--                                                 </label>

--                                         <?php endif; // hierarchical ?>

--                                         <?php if ( ! bulk ) : ?>

--                                                 <label>
--                                                         <span class="title"><?php _e( "Order" ); ?></span>
--                                                         <span class="input-text-wrap"><input type="text" name="menu_order" class="inline-edit-menu-order-input" value="<?php echo post->menu_order; ?>" /></span>
--                                                 </label>

--                                         <?php endif; // ! bulk ?>

--                                 <?php endif; // post_type_supports( ... "page-attributes" ) ?>

--                                 <?php if ( 0 < count( get_page_templates( null, screen->post_type ) ) ) : ?>

--                                         <label>
--                                                 <span class="title"><?php _e( "Template" ); ?></span>
--                                                 <select name="page_template">
--                                                         <?php if ( bulk ) : ?>
--                                                         <option value="-1"><?php _e( "&mdash; No Change &mdash;" ); ?></option>
--                                                         <?php endif; // bulk ?>
--                                                         <?php
--                                                         -- This filter is documented in wp-admin/includes/meta-boxes.php--
--                                                         default_title = apply_filters( "default_page_template_title", __( "Default template" ), "quick-edit" );
--                                                         ?>
--                                                         <option value="default"><?php echo esc_html( default_title ); ?></option>
--                                                         <?php page_template_dropdown( "", screen->post_type ); ?>
--                                                 </select>
--                                         </label>

--                                 <?php endif; ?>

--                                 <?php if ( count( flat_taxonomies ) && ! bulk ) : ?>

--                                         <?php foreach ( flat_taxonomies as taxonomy ) : ?>

--                                                 <?php if ( current_user_can( taxonomy->cap->assign_terms ) ) : ?>
--                                                         <?php taxonomy_name = esc_attr( taxonomy->name ); ?>
--                                                         <div class="inline-edit-tags-wrap">
--                                                         <label class="inline-edit-tags">
--                                                                 <span class="title"><?php echo esc_html( taxonomy->labels->name ); ?></span>
--                                                                 <textarea data-wp-taxonomy="<?php echo taxonomy_name; ?>" cols="22" rows="1" name="tax_input[<?php echo esc_attr( taxonomy->name ); ?>]" class="tax_input_<?php echo esc_attr( taxonomy->name ); ?>" aria-describedby="inline-edit-<?php echo esc_attr( taxonomy->name ); ?>-desc"></textarea>
--                                                         </label>
--                                                         <p class="howto" id="inline-edit-<?php echo esc_attr( taxonomy->name ); ?>-desc"><?php echo esc_html( taxonomy->labels->separate_items_with_commas ); ?></p>
--                                                         </div>
--                                                 <?php endif; // current_user_can( "assign_terms" ) ?>

--                                         <?php endforeach; // flat_taxonomies as taxonomy ?>

--                                 <?php endif; // count( flat_taxonomies ) && ! bulk ?>

--                                 <?php if ( post_type_supports( screen->post_type, "comments" ) || post_type_supports( screen->post_type, "trackbacks" ) ) : ?>

--                                         <?php if ( bulk ) : ?>

--                                                 <div class="inline-edit-group wp-clearfix">

--                                                 <?php if ( post_type_supports( screen->post_type, "comments" ) ) : ?>

--                                                         <label class="alignleft">
--                                                                 <span class="title"><?php _e( "Comments" ); ?></span>
--                                                                 <select name="comment_status">
--                                                                         <option value=""><?php _e( "&mdash; No Change &mdash;" ); ?></option>
--                                                                         <option value="open"><?php _e( "Allow" ); ?></option>
--                                                                         <option value="closed"><?php _e( "Do not allow" ); ?></option>
--                                                                 </select>
--                                                         </label>

--                                                 <?php endif; ?>

--                                                 <?php if ( post_type_supports( screen->post_type, "trackbacks" ) ) : ?>

--                                                         <label class="alignright">
--                                                                 <span class="title"><?php _e( "Pings" ); ?></span>
--                                                                 <select name="ping_status">
--                                                                         <option value=""><?php _e( "&mdash; No Change &mdash;" ); ?></option>
--                                                                         <option value="open"><?php _e( "Allow" ); ?></option>
--                                                                         <option value="closed"><?php _e( "Do not allow" ); ?></option>
--                                                                 </select>
--                                                         </label>

--                                                 <?php endif; ?>

--                                                 </div>

--                                         <?php else : // bulk ?>

--                                                 <div class="inline-edit-group wp-clearfix">

--                                                 <?php if ( post_type_supports( screen->post_type, "comments" ) ) : ?>

--                                                         <label class="alignleft">
--                                                                 <input type="checkbox" name="comment_status" value="open" />
--                                                                 <span class="checkbox-title"><?php _e( "Allow Comments" ); ?></span>
--                                                         </label>

--                                                 <?php endif; ?>

--                                                 <?php if ( post_type_supports( screen->post_type, "trackbacks" ) ) : ?>

--                                                         <label class="alignleft">
--                                                                 <input type="checkbox" name="ping_status" value="open" />
--                                                                 <span class="checkbox-title"><?php _e( "Allow Pings" ); ?></span>
--                                                         </label>

--                                                 <?php endif; ?>

--                                                 </div>

--                                         <?php endif; // bulk ?>

--                                 <?php endif; // post_type_supports( ... comments or pings ) ?>

--                                         <div class="inline-edit-group wp-clearfix">

--                                                 <label class="inline-edit-status alignleft">
--                                                         <span class="title"><?php _e( "Status" ); ?></span>
--                                                         <select name="_status">
--                                                                 <?php if ( bulk ) : ?>
--                                                                         <option value="-1"><?php _e( "&mdash; No Change &mdash;" ); ?></option>
--                                                                 <?php endif; // bulk ?>

--                                                                 <?php if ( can_publish ) : // Contributors only get "Unpublished" and "Pending Review". ?>
--                                                                         <option value="publish"><?php _e( "Published" ); ?></option>
--                                                                         <option value="future"><?php _e( "Scheduled" ); ?></option>
--                                                                         <?php if ( bulk ) : ?>
--                                                                                 <option value="private"><?php _e( "Private" ); ?></option>
--                                                                         <?php endif; // bulk ?>
--                                                                 <?php endif; ?>

--                                                                 <option value="pending"><?php _e( "Pending Review" ); ?></option>
--                                                                 <option value="draft"><?php _e( "Draft" ); ?></option>
--                                                         </select>
--                                                 </label>

--                                                 <?php if ( "post" === screen->post_type && can_publish && current_user_can( post_type_object->cap->edit_others_posts ) ) : ?>

--                                                         <?php if ( bulk ) : ?>

--                                                                 <label class="alignright">
--                                                                         <span class="title"><?php _e( "Sticky" ); ?></span>
--                                                                         <select name="sticky">
--                                                                                 <option value="-1"><?php _e( "&mdash; No Change &mdash;" ); ?></option>
--                                                                                 <option value="sticky"><?php _e( "Sticky" ); ?></option>
--                                                                                 <option value="unsticky"><?php _e( "Not Sticky" ); ?></option>
--                                                                         </select>
--                                                                 </label>

--                                                         <?php else : // bulk ?>

--                                                                 <label class="alignleft">
--                                                                         <input type="checkbox" name="sticky" value="sticky" />
--                                                                         <span class="checkbox-title"><?php _e( "Make this post sticky" ); ?></span>
--                                                                 </label>

--                                                         <?php endif; // bulk ?>

--                                                 <?php endif; // "post" && can_publish && current_user_can( "edit_others_posts" ) ?>

--                                         </div>

--                                 <?php if ( bulk && current_theme_supports( "post-formats" ) && post_type_supports( screen->post_type, "post-formats" ) ) : ?>
--                                         <?php post_formats = get_theme_support( "post-formats" ); ?>

--                                         <label class="alignleft">
--                                                 <span class="title"><?php _ex( "Format", "post format" ); ?></span>
--                                                 <select name="post_format">
--                                                         <option value="-1"><?php _e( "&mdash; No Change &mdash;" ); ?></option>
--                                                         <option value="0"><?php echo get_post_format_string( "standard" ); ?></option>
--                                                         <?php if ( is_array( post_formats[0] ) ) : ?>
--                                                                 <?php foreach ( post_formats[0] as format ) : ?>
--                                                                         <option value="<?php echo esc_attr( format ); ?>"><?php echo esc_html( get_post_format_string( format ) ); ?></option>
--                                                                 <?php endforeach; ?>
--                                                         <?php endif; ?>
--                                                 </select>
--                                         </label>

--                                 <?php endif; ?>

--                                 </div>
--                         </fieldset>

--                         <?php
--                         list( columns ) = this->get_column_info();

--                         foreach ( columns as column_name => column_display_name ) then
--                                 if ( isset( core_columns[ column_name ] ) ) then
--                                         continue;
--                                 end;

--                                 if ( bulk ) then

--                                         --
--                                         -- Fires once for each column in Bulk Edit mode.
--                                         --
--                                         -- @since 2.7.0
--                                         --
--                                         -- @param string column_name Name of the column to edit.
--                                         -- @param string post_type   The post type slug.
--                                         --
--                                         do_action( "bulk_edit_custom_box", column_name, screen->post_type );
--                                 end; else then

--                                         --
--                                         -- Fires once for each column in Quick Edit mode.
--                                         --
--                                         -- @since 2.7.0
--                                         --
--                                         -- @param string column_name Name of the column to edit.
--                                         -- @param string post_type   The post type slug, or current screen name if this is a taxonomy list table.
--                                         -- @param string taxonomy    The taxonomy name, if any.
--                                         --
--                                         do_action( "quick_edit_custom_box", column_name, screen->post_type, "" );
--                                 end;
--                         end;
--                         ?>

--                         <div class="submit inline-edit-save">
--                                 <?php if ( ! bulk ) : ?>
--                                         <?php wp_nonce_field( "inlineeditnonce", "_inline_edit", false ); ?>
--                                         <button type="button" class="button button-primary save"><?php _e( "Update" ); ?></button>
--                                 <?php else : ?>
--                                         <?php submit_button( __( "Update" ), "primary", "bulk_edit", false ); ?>
--                                 <?php endif; ?>

--                                 <button type="button" class="button cancel"><?php _e( "Cancel" ); ?></button>

--                                 <?php if ( ! bulk ) : ?>
--                                         <span class="spinner"></span>
--                                 <?php endif; ?>

--                                 <input type="hidden" name="post_view" value="<?php echo esc_attr( m ); ?>" />
--                                 <input type="hidden" name="screen" value="<?php echo esc_attr( screen->id ); ?>" />
--                                 <?php if ( ! bulk && ! post_type_supports( screen->post_type, "author" ) ) : ?>
--                                         <input type="hidden" name="post_author" value="<?php echo esc_attr( post->post_author ); ?>" />
--                                 <?php endif; ?>

--                                 <div class="notice notice-error notice-alt inline hidden">
--                                         <p class="error"></p>
--                                 </div>
--                         </div>
--                 </div> <!-- end of .inline-edit-wrapper -->

--                         </td></tr>

--                         <?php
--                         bulk++;
--                 endwhile;
--                 ?>
--                 </tbody></table>
--                 </form>
--                 <?php
--         end;
-- end;

end Class_Posts_List_Tables;
