--
-- List Table API: WP_Terms_List_Table class
--
-- @package WordPress
-- @subpackage Administration
-- @since 3.1.0
--

with Php.Lists;

with Globals;
with Hb_Common;

with Inc_Functions;
with Inc_Taxonomys;
with Inc_L10n;
with Inc_Posts;

package body Adi_Class_Wp_Terms_List_Tables
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Args : Array_Type := Empty_Array)
                         return Wp_Terms_List_Table
   is
      use Hb_Common;
      use Php.Lists;
--    use Php;
      use Inc_L10n;
--    use Inc_Posts;

--    global post_type, taxonomy, action, tax;
      This : constant Wp_Terms_List_Table := (
        Adi_Class_Wp_List_Tables.X_Construct (
--      parent::x_Construct (
          To_Array ((
            Build ("plural",   "tags"),
            Build ("singular", "tag"),
            Build ("screen",   (if Isset (Args, "screen")
                                then As_String (Get (Args, "screen")) else "null"))
          ))
        )
        with
          Level => 0
      );

   begin
      Globals.Action    := This.Screen.Action;
      Globals.Post_Type := This.Screen.Post_Type;
      Globals.Taxonomy  := This.Screen.Taxonomy;

      if Empty (-Globals.Taxonomy) then
         Globals.Taxonomy := +"post_tag";
      end if;

      if not Inc_Taxonomys.Taxonomy_Exists (-Globals.Taxonomy) then
         Inc_Functions.Wp_Die (abs "Invalid taxonomy.");
      end if;

      Globals.Tax := Inc_Taxonomys.Get_Taxonomy (-Globals.Taxonomy);

      -- @todo Still needed? Maybe just the show_ui part.
      if
        Empty (-Globals.Post_Type) or else
        not Php.Lists.In_Array (-Globals.Post_Type,
                                Inc_Posts.Get_Post_Types (To_Array ((1 =>
                                  Build ("show_ui", "true")))),
                                True)
      then
         Globals.Post_Type := +"post";
      end if;

      return This;
   end X_Construct;

--         --
--         -- @return bool
--         --
--         public function ajax_user_can() then
--                 return current_user_can( get_taxonomy( this.screen.taxonomy ).cap.manage_terms );
--         end;

--         --
--         --
--         public function prepare_items() then
--                 taxonomy = this.screen.taxonomy;

--                 tags_per_page = this.get_items_per_page( "edit_thentaxonomyend;_per_page" );

--                 if ( "post_tag" === taxonomy ) then
--                         --
--                         -- Filters the number of terms displayed per page for the Tags list table.
--                         --
--                         -- @since 2.8.0
--                         --
--                         -- @param int tags_per_page Number of tags to be displayed. Default 20.
--                         --
--                         tags_per_page = apply_filters( "edit_tags_per_page", tags_per_page );

--                         --
--                         -- Filters the number of terms displayed per page for the Tags list table.
--                         --
--                         -- @since 2.7.0
--                         -- @deprecated 2.8.0 Use {@see "edit_tags_per_page"} instead.
--                         --
--                         -- @param int tags_per_page Number of tags to be displayed. Default 20.
--                         --
--                         tags_per_page = apply_filters_deprecated( "tagsperpage", array( tags_per_page ), "2.8.0", "edit_tags_per_page" );
--                 end; elseif ( "category" === taxonomy ) then
--                         --
--                         -- Filters the number of terms displayed per page for the Categories list table.
--                         --
--                         -- @since 2.8.0
--                         --
--                         -- @param int tags_per_page Number of categories to be displayed. Default 20.
--                         --
--                         tags_per_page = apply_filters( "edit_categories_per_page", tags_per_page );
--                 end;

--                 search = ! empty( _REQUEST["s"] ) ? trim( wp_unslash( _REQUEST["s"] ) ) : "";

--                 args = array(
--                         "taxonomy"   => taxonomy,
--                         "search"     => search,
--                         "page"       => this.get_pagenum(),
--                         "number"     => tags_per_page,
--                         "hide_empty" => 0,
--                 );

--                 if ( ! empty( _REQUEST["orderby"] ) ) then
--                         args["orderby"] = trim( wp_unslash( _REQUEST["orderby"] ) );
--                 end;

--                 if ( ! empty( _REQUEST["order"] ) ) then
--                         args["order"] = trim( wp_unslash( _REQUEST["order"] ) );
--                 end;

--                 args["offset"] = ( args["page"] - 1 )-- args["number"];

--                 -- Save the values because "number" and "offset" can be subsequently overridden.
--                 this.callback_args = args;

--                 if ( is_taxonomy_hierarchical( taxonomy ) && ! isset( args["orderby"] ) ) then
--                         -- We"ll need the full set of terms then.
--                         args["number"] = 0;
--                         args["offset"] = args["number"];
--                 end;

--                 this.items = get_terms( args );

--                 this.set_pagination_args(
--                         array(
--                                 "total_items" => wp_count_terms(
--                                         array(
--                                                 "taxonomy" => taxonomy,
--                                                 "search"   => search,
--                                         )
--                                 ),
--                                 "per_page"    => tags_per_page,
--                         )
--                 );
--         end;

--         --
--         --
--         public function no_items() then
--                 echo get_taxonomy( this.screen.taxonomy ).labels.not_found;
--         end;

--         --
--         -- @return array
--         --
--         protected function get_bulk_actions() then
--                 actions = array();

--                 if ( current_user_can( get_taxonomy( this.screen.taxonomy ).cap.delete_terms ) ) then
--                         actions["delete"] = __( "Delete" );
--                 end;

--                 return actions;
--         end;

--         --
--         -- @return string
--         --
--         public function current_action() then
--                 if ( isset( _REQUEST["action"] ) && isset( _REQUEST["delete_tags"] ) && "delete" === _REQUEST["action"] ) then
--                         return "bulk-delete";
--                 end;

--                 return parent::current_action();
--         end;

--         --
--         -- @return array
--         --
--         public function get_columns() then
--                 columns = array(
--                         "cb"          => "<input type="checkbox" />",
--                         "name"        => _x( "Name", "term name" ),
--                         "description" => __( "Description" ),
--                         "slug"        => __( "Slug" ),
--                 );

--                 if ( "link_category" === this.screen.taxonomy ) then
--                         columns["links"] = __( "Links" );
--                 end; else then
--                         columns["posts"] = _x( "Count", "Number/count of items" );
--                 end;

--                 return columns;
--         end;

--         --
--         -- @return array
--         --
--         protected function get_sortable_columns() then
--                 return array(
--                         "name"        => "name",
--                         "description" => "description",
--                         "slug"        => "slug",
--                         "posts"       => "count",
--                         "links"       => "count",
--                 );
--         end;

--         --
--         --
--         public function display_rows_or_placeholder() then
--                 taxonomy = this.screen.taxonomy;

--                 number = this.callback_args["number"];
--                 offset = this.callback_args["offset"];

--                 -- Convert it to table rows.
--                 count = 0;

--                 if ( empty( this.items ) || ! is_array( this.items ) ) then
--                         echo "<tr class="no-items"><td class="colspanchange" colspan="" . this.get_column_count() . "">";
--                         this.no_items();
--                         echo "</td></tr>";
--                         return;
--                 end;

--                 if ( is_taxonomy_hierarchical( taxonomy ) && ! isset( this.callback_args["orderby"] ) ) then
--                         if ( ! empty( this.callback_args["search"] ) ) then-- Ignore children on searches.
--                                 children = array();
--                         end; else then
--                                 children = _get_term_hierarchy( taxonomy );
--                         end;

--                         /*
--                         -- Some funky recursion to get the job done (paging & parents mainly) is contained within.
--                         -- Skip it for non-hierarchical taxonomies for performance sake.
--                         --
--                         this._rows( taxonomy, this.items, children, offset, number, count );
--                 end; else then
--                         foreach ( this.items as term ) then
--                                 this.single_row( term );
--                         end;
--                 end;
--         end;

--         --
--         -- @param string taxonomy
--         -- @param array  terms
--         -- @param array  children
--         -- @param int    start
--         -- @param int    per_page
--         -- @param int    count
--         -- @param int    parent_term
--         -- @param int    level
--         --
--         private function _rows( taxonomy, terms, &children, start, per_page, &count, parent_term = 0, level = 0 ) then

--                 end = start + per_page;

--                 foreach ( terms as key => term ) then

--                         if ( count >= end ) then
--                                 break;
--                         end;

--                         if ( term.parent !== parent_term && empty( _REQUEST["s"] ) ) then
--                                 continue;
--                         end;

--                         -- If the page starts in a subtree, print the parents.
--                         if ( count === start && term.parent > 0 && empty( _REQUEST["s"] ) ) then
--                                 my_parents = array();
--                                 parent_ids = array();
--                                 p          = term.parent;

--                                 while ( p ) then
--                                         my_parent    = get_term( p, taxonomy );
--                                         my_parents[] = my_parent;
--                                         p            = my_parent.parent;

--                                         if ( in_array( p, parent_ids, true ) ) then -- Prevent parent loops.
--                                                 break;
--                                         end;

--                                         parent_ids[] = p;
--                                 end;

--                                 unset( parent_ids );

--                                 num_parents = count( my_parents );

--                                 while ( my_parent = array_pop( my_parents ) ) then
--                                         echo "\t";
--                                         this.single_row( my_parent, level - num_parents );
--                                         num_parents--;
--                                 end;
--                         end;

--                         if ( count >= start ) then
--                                 echo "\t";
--                                 this.single_row( term, level );
--                         end;

--                         ++count;

--                         unset( terms[ key ] );

--                         if ( isset( children[ term.term_id ] ) && empty( _REQUEST["s"] ) ) then
--                                 this._rows( taxonomy, terms, children, start, per_page, count, term.term_id, level + 1 );
--                         end;
--                 end;
--         end;

--         --
--         -- @global string taxonomy
--         -- @param WP_Term tag   Term object.
--         -- @param int     level
--         --
--         public function single_row( tag, level = 0 ) then
--                 global taxonomy;
--                 tag = sanitize_term( tag, taxonomy );

--                 this.level = level;

--                 if ( tag.parent ) then
--                         count = count( get_ancestors( tag.term_id, taxonomy, "taxonomy" ) );
--                         level = "level-" . count;
--                 end; else then
--                         level = "level-0";
--                 end;

--                 echo "<tr id="tag-" . tag.term_id . "" class="" . level . "">";
--                 this.single_row_columns( tag );
--                 echo "</tr>";
--         end;

--         --
--         -- @since 5.9.0 Renamed `tag` to `item` to match parent class for PHP 8 named parameter support.
--         --
--         -- @param WP_Term item Term object.
--         -- @return string
--         --
--         public function column_cb( item ) then
--                 -- Restores the more descriptive, specific name for use within this method.
--                 tag = item;

--                 if ( current_user_can( "delete_term", tag.term_id ) ) then
--                         return sprintf(
--                                 "<label class="screen-reader-text" for="cb-select-%1s">%2s</label>" .
--                                 "<input type="checkbox" name="delete_tags[]" value="%1s" id="cb-select-%1s" />",
--                                 tag.term_id,
--                                 /* translators: %s: Taxonomy term name.--
--                                 sprintf( __( "Select %s" ), tag.name )
--                         );
--                 end;

--                 return "&nbsp;";
--         end;

--         --
--         -- @param WP_Term tag Term object.
--         -- @return string
--         --
--         public function column_name( tag ) then
--                 taxonomy = this.screen.taxonomy;

--                 pad = str_repeat( "&#8212; ", max( 0, this.level ) );

--                 --
--                 -- Filters display of the term name in the terms list table.
--                 --
--                 -- The default output may include padding due to the term"s
--                 -- current level in the term hierarchy.
--                 --
--                 -- @since 2.5.0
--                 --
--                 -- @see WP_Terms_List_Table::column_name()
--                 --
--                 -- @param string pad_tag_name The term name, padded if not top-level.
--                 -- @param WP_Term tag         Term object.
--                 --
--                 name = apply_filters( "term_name", pad . " " . tag.name, tag );

--                 qe_data = get_term( tag.term_id, taxonomy, OBJECT, "edit" );

--                 uri = wp_doing_ajax() ? wp_get_referer() : _SERVER["REQUEST_URI"];

--                 edit_link = get_edit_term_link( tag, taxonomy, this.screen.post_type );

--                 if ( edit_link ) then
--                         edit_link = add_query_arg(
--                                 "wp_http_referer",
--                                 urlencode( wp_unslash( uri ) ),
--                                 edit_link
--                         );
--                         name      = sprintf(
--                                 "<a class="row-title" href="%s" aria-label="%s">%s</a>",
--                                 esc_url( edit_link ),
--                                 /* translators: %s: Taxonomy term name.--
--                                 esc_attr( sprintf( __( "&#8220;%s&#8221; (Edit)" ), tag.name ) ),
--                                 name
--                         );
--                 end;

--                 output = sprintf(
--                         "<strong>%s</strong><br />",
--                         name
--                 );

--                 output .= "<div class="hidden" id="inline_" . qe_data.term_id . "">";
--                 output .= "<div class="name">" . qe_data.name . "</div>";

--                 -- This filter is documented in wp-admin/edit-tag-form.php--
--                 output .= "<div class="slug">" . apply_filters( "editable_slug", qe_data.slug, qe_data ) . "</div>";
--                 output .= "<div class="parent">" . qe_data.parent . "</div></div>";

--                 return output;
--         end;

--         --
--         -- Gets the name of the default primary column.
--         --
--         -- @since 4.3.0
--         --
--         -- @return string Name of the default primary column, in this case, "name".
--         --
--         protected function get_default_primary_column_name() then
--                 return "name";
--         end;

--         --
--         -- Generates and displays row action links.
--         --
--         -- @since 4.3.0
--         -- @since 5.9.0 Renamed `tag` to `item` to match parent class for PHP 8 named parameter support.
--         --
--         -- @param WP_Term item        Tag being acted upon.
--         -- @param string  column_name Current column name.
--         -- @param string  primary     Primary column name.
--         -- @return string Row actions output for terms, or an empty string
--         --                if the current column is not the primary column.
--         --
--         protected function handle_row_actions( item, column_name, primary ) then
--                 if ( primary !== column_name ) then
--                         return "";
--                 end;

--                 -- Restores the more descriptive, specific name for use within this method.
--                 tag      = item;
--                 taxonomy = this.screen.taxonomy;
--                 uri      = wp_doing_ajax() ? wp_get_referer() : _SERVER["REQUEST_URI"];

--                 edit_link = add_query_arg(
--                         "wp_http_referer",
--                         urlencode( wp_unslash( uri ) ),
--                         get_edit_term_link( tag, taxonomy, this.screen.post_type )
--                 );

--                 actions = array();

--                 if ( current_user_can( "edit_term", tag.term_id ) ) then
--                         actions["edit"] = sprintf(
--                                 "<a href="%s" aria-label="%s">%s</a>",
--                                 esc_url( edit_link ),
--                                 /* translators: %s: Taxonomy term name.--
--                                 esc_attr( sprintf( __( "Edit &#8220;%s&#8221;" ), tag.name ) ),
--                                 __( "Edit" )
--                         );
--                         actions["inline hide-if-no-js"] = sprintf(
--                                 "<button type="button" class="button-link editinline" aria-label="%s" aria-expanded="false">%s</button>",
--                                 /* translators: %s: Taxonomy term name.--
--                                 esc_attr( sprintf( __( "Quick edit &#8220;%s&#8221; inline" ), tag.name ) ),
--                                 __( "Quick&nbsp;Edit" )
--                         );
--                 end;

--                 if ( current_user_can( "delete_term", tag.term_id ) ) then
--                         actions["delete"] = sprintf(
--                                 "<a href="%s" class="delete-tag aria-button-if-js" aria-label="%s">%s</a>",
--                                 wp_nonce_url( "edit-tags.php?action=delete&amp;taxonomy=taxonomy&amp;tag_ID=tag.term_id", "delete-tag_" . tag.term_id ),
--                                 /* translators: %s: Taxonomy term name.--
--                                 esc_attr( sprintf( __( "Delete &#8220;%s&#8221;" ), tag.name ) ),
--                                 __( "Delete" )
--                         );
--                 end;

--                 if ( is_term_publicly_viewable( tag ) ) then
--                         actions["view"] = sprintf(
--                                 "<a href="%s" aria-label="%s">%s</a>",
--                                 get_term_link( tag ),
--                                 /* translators: %s: Taxonomy term name.--
--                                 esc_attr( sprintf( __( "View &#8220;%s&#8221; archive" ), tag.name ) ),
--                                 __( "View" )
--                         );
--                 end;

--                 --
--                 -- Filters the action links displayed for each term in the Tags list table.
--                 --
--                 -- @since 2.8.0
--                 -- @since 3.0.0 Deprecated in favor of {@see "{taxonomy}_row_actions"} filter.
--                 -- @since 5.4.2 Restored (un-deprecated).
--                 --
--                 -- @param string[] actions An array of action links to be displayed. Default
--                 --                          "Edit", "Quick Edit", "Delete", and "View".
--                 -- @param WP_Term  tag     Term object.
--                 --
--                 actions = apply_filters( "tag_row_actions", actions, tag );

--                 --
--                 -- Filters the action links displayed for each term in the terms list table.
--                 --
--                 -- The dynamic portion of the hook name, `taxonomy`, refers to the taxonomy slug.
--                 --
--                 -- Possible hook names include:
--                 --
--                 --  - `category_row_actions`
--                 --  - `post_tag_row_actions`
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param string[] actions An array of action links to be displayed. Default
--                 --                          "Edit", "Quick Edit", "Delete", and "View".
--                 -- @param WP_Term  tag     Term object.
--                 --
--                 actions = apply_filters( "thentaxonomyend;_row_actions", actions, tag );

--                 return this.row_actions( actions );
--         end;

--         --
--         -- @param WP_Term tag Term object.
--         -- @return string
--         --
--         public function column_description( tag ) then
--                 if ( tag.description ) then
--                         return tag.description;
--                 end; else then
--                         return "<span aria-hidden="true">&#8212;</span><span class="screen-reader-text">" . __( "No description" ) . "</span>";
--                 end;
--         end;

--         --
--         -- @param WP_Term tag Term object.
--         -- @return string
--         --
--         public function column_slug( tag ) then
--                 -- This filter is documented in wp-admin/edit-tag-form.php--
--                 return apply_filters( "editable_slug", tag.slug, tag );
--         end;

--         --
--         -- @param WP_Term tag Term object.
--         -- @return string
--         --
--         public function column_posts( tag ) then
--                 count = number_format_i18n( tag.count );

--                 tax = get_taxonomy( this.screen.taxonomy );

--                 ptype_object = get_post_type_object( this.screen.post_type );
--                 if ( ! ptype_object.show_ui ) then
--                         return count;
--                 end;

--                 if ( tax.query_var ) then
--                         args = array( tax.query_var => tag.slug );
--                 end; else then
--                         args = array(
--                                 "taxonomy" => tax.name,
--                                 "term"     => tag.slug,
--                         );
--                 end;

--                 if ( "post" !== this.screen.post_type ) then
--                         args["post_type"] = this.screen.post_type;
--                 end;

--                 if ( "attachment" === this.screen.post_type ) then
--                         return "<a href="" . esc_url( add_query_arg( args, "upload.php" ) ) . "">count</a>";
--                 end;

--                 return "<a href="" . esc_url( add_query_arg( args, "edit.php" ) ) . "">count</a>";
--         end;

--         --
--         -- @param WP_Term tag Term object.
--         -- @return string
--         --
--         public function column_links( tag ) then
--                 count = number_format_i18n( tag.count );

--                 if ( count ) then
--                         count = "<a href="link-manager.php?cat_id=tag.term_id">count</a>";
--                 end;

--                 return count;
--         end;

--         --
--         -- @since 5.9.0 Renamed `tag` to `item` to match parent class for PHP 8 named parameter support.
--         --
--         -- @param WP_Term item        Term object.
--         -- @param string  column_name Name of the column.
--         -- @return string
--         --
--         public function column_default( item, column_name ) then
--                 --
--                 -- Filters the displayed columns in the terms list table.
--                 --
--                 -- The dynamic portion of the hook name, `this.screen.taxonomy`,
--                 -- refers to the slug of the current taxonomy.
--                 --
--                 -- Possible hook names include:
--                 --
--                 --  - `manage_category_custom_column`
--                 --  - `manage_post_tag_custom_column`
--                 --
--                 -- @since 2.8.0
--                 --
--                 -- @param string string      Custom column output. Default empty.
--                 -- @param string column_name Name of the column.
--                 -- @param int    term_id     Term ID.
--                 --
--                 return apply_filters( "manage_thenthis.screen.taxonomyend;_custom_column", "", column_name, item.term_id );
--         end;

--         --
--         -- Outputs the hidden row displayed when inline editing
--         --
--         -- @since 3.1.0
--         --
--         public function inline_edit() then
--                 tax = get_taxonomy( this.screen.taxonomy );

--                 if ( ! current_user_can( tax.cap.edit_terms ) ) then
--                         return;
--                 end;
--                 ?>

--                 <form method="get">
--                 <table style="display: none"><tbody id="inlineedit">

--                         <tr id="inline-edit" class="inline-edit-row" style="display: none">
--                         <td colspan="<?php echo this.get_column_count(); ?>" class="colspanchange">
--                         <div class="inline-edit-wrapper">

--                         <fieldset>
--                                 <legend class="inline-edit-legend"><?php _e( "Quick Edit" ); ?></legend>
--                                 <div class="inline-edit-col">
--                                 <label>
--                                         <span class="title"><?php _ex( "Name", "term name" ); ?></span>
--                                         <span class="input-text-wrap"><input type="text" name="name" class="ptitle" value="" /></span>
--                                 </label>

--                                 <label>
--                                         <span class="title"><?php _e( "Slug" ); ?></span>
--                                         <span class="input-text-wrap"><input type="text" name="slug" class="ptitle" value="" /></span>
--                                 </label>
--                                 </div>
--                         </fieldset>

--                         <?php
--                         core_columns = array(
--                                 "cb"          => true,
--                                 "description" => true,
--                                 "name"        => true,
--                                 "slug"        => true,
--                                 "posts"       => true,
--                         );

--                         list( columns ) = this.get_column_info();

--                         foreach ( columns as column_name => column_display_name ) then
--                                 if ( isset( core_columns[ column_name ] ) ) then
--                                         continue;
--                                 end;

--                                 -- This action is documented in wp-admin/includes/class-wp-posts-list-table.php--
--                                 do_action( "quick_edit_custom_box", column_name, "edit-tags", this.screen.taxonomy );
--                         end;
--                         ?>

--                         <div class="inline-edit-save submit">
--                                 <button type="button" class="save button button-primary"><?php echo tax.labels.update_item; ?></button>
--                                 <button type="button" class="cancel button"><?php _e( "Cancel" ); ?></button>
--                                 <span class="spinner"></span>

--                                 <?php wp_nonce_field( "taxinlineeditnonce", "_inline_edit", false ); ?>
--                                 <input type="hidden" name="taxonomy" value="<?php echo esc_attr( this.screen.taxonomy ); ?>" />
--                                 <input type="hidden" name="post_type" value="<?php echo esc_attr( this.screen.post_type ); ?>" />

--                                 <div class="notice notice-error notice-alt inline hidden">
--                                         <p class="error"></p>
--                                 </div>
--                         </div>
--                         </div>

--                         </td></tr>

--                 </tbody></table>
--                 </form>
--                 <?php
--         end;
-- end;

end Adi_Class_Wp_Terms_List_Tables;
