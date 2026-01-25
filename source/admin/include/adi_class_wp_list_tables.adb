--
-- Administration API: WP_List_Table class
--
-- @package WordPress
-- @subpackage List_Table
-- @since 3.1.0
--

with Ada.Containers;

with Php.Arrays;
with Php.Echoing;
with Php.Errors;
with Php.Lists;
with Php.Misc;
with Php.Strings;

with Binder;

with Adi_Screens;
with Adi_Templates;

with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_Formatting;
with Inc_L10n;
with Inc_Link_Templates;
with Inc_Options;
with Inc_Plugins;

package body Adi_Class_Wp_List_Tables
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Args : Array_Type := Empty_Array)
                         return Wp_List_Table
   is
      use Php.Arrays;
      use UStrings;
      use Adi_Templates;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_L10n;
--    use Inc_Plugins;

      This : Wp_List_Table;

      Args_2 : Array_Type :=
        Wp_Parse_Args (
          Args,
          To_Array ((
            Build ("plural",   ""),
            Build ("singular", ""),
            Build ("ajax",     False),
            Build ("screen",   "null")
          ))
        );
   begin
      This.Screen := Convert_To_Screen (As_String (Get (Args, "screen")));

--    Add_Filter ("manage_" & (-This.Screen.Id) & "_columns",
--                "Empty_Array", -- To_Array (This, "get_columns"),
--                0);

      if "" = As_String (Get (Args_2, "plural")) then
--    if not Args_2 ("plural") then
         Set (Args_2, "plural", From_String (-This.Screen.Base));
      end if;

      Set (Args_2, "plural",   From_String (Sanitize_Key (As_String (Get (Args_2, "plural")))));
      Set (Args_2, "singular", From_String (Sanitize_Key (As_String (Get (Args_2, "singular")))));

      This.X_Args := Args_2;

      if As_Boolean (Get (Args_2, "ajax")) then
         Wp_Enqueue_Script ("list-table");
--       Add_Action ("admin_footer", "Empty_Array"); -- To_Array (This, "_js_vars"));
         null;
      end if;

      if Empty (This.Modes) then
         This.Modes := To_Array ((
           Build ("list",    abs "Compact view"),
           Build ("excerpt", abs "Extended view")
         ));
      end if;

      return This;
   end X_Construct;

--         --
--         -- Make private properties readable for backward compatibility.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string name Property to get.
--         -- @return mixed Property.
--         --
--         public function __get( name ) then
--                 if ( in_array( name, this.compat_fields, true ) ) then
--                         return this.name;
--                 end;
--         end;

--         --
--         -- Make private properties settable for backward compatibility.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string name  Property to check if set.
--         -- @param mixed  value Property value.
--         -- @return mixed Newly-set property.
--         --
--         public function __set( name, value ) then
--                 if ( in_array( name, this.compat_fields, true ) ) then
--                         return this.name = value;
--                 end;
--         end;

--         --
--         -- Make private properties checkable for backward compatibility.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string name Property to check if set.
--         -- @return bool Whether the property is a back-compat property and it is set.
--         --
--         public function __isset( name ) then
--                 if ( in_array( name, this.compat_fields, true ) ) then
--                         return isset( this.name );
--                 end;

--                 return false;
--         end;

--         --
--         -- Make private properties un-settable for backward compatibility.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string name Property to unset.
--         --
--         public function __unset( name ) then
--                 if ( in_array( name, this.compat_fields, true ) ) then
--                         unset( this.name );
--                 end;
--         end;

--         --
--         -- Make private/protected methods readable for backward compatibility.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string name      Method to call.
--         -- @param array  arguments Arguments to pass when calling.
--         -- @return mixed|bool Return value of the callback, false otherwise.
--         --
--         public function __call( name, arguments ) then
--                 if ( in_array( name, this.compat_methods, true ) ) then
--                         return this.name( ...arguments );
--                 end;
--                 return false;
--         end;

--         --
--         -- Checks the current user"s permissions
--         --
--         -- @since 3.1.0
--         -- @abstract
--         --
--         public function ajax_user_can() then
--                 die( "function WP_List_Table::ajax_user_can() must be overridden in a subclass." );
--         end;

--         --
--         -- Prepares the list of items for displaying.
--         --
--         -- @uses WP_List_Table::set_pagination_args()
--         --
--         -- @since 3.1.0
--         -- @abstract
--         --
--         public function prepare_items() then
--                 die( "function WP_List_Table::prepare_items() must be overridden in a subclass." );
--         end;

--         --
--         -- An internal method that sets all the necessary pagination arguments
--         --
--         -- @since 3.1.0
--         --
--         -- @param array|string args Array or string of arguments with information about the pagination.
--         --
--         protected function set_pagination_args( args ) then
--                 args = wp_parse_args(
--                         args,
--                         array(
--                                 "total_items" => 0,
--                                 "total_pages" => 0,
--                                 "per_page"    => 0,
--                         )
--                 );

--                 if ( ! args["total_pages"] && args["per_page"] > 0 ) then
--                         args["total_pages"] = ceil( args["total_items"] / args["per_page"] );
--                 end;

--                 // Redirect if page number is invalid and headers are not already sent.
--                 if ( ! headers_sent() && ! wp_doing_ajax() && args["total_pages"] > 0 && this.get_pagenum() > args["total_pages"] ) then
--                         wp_redirect( add_query_arg( "paged", args["total_pages"] ) );
--                         exit;
--                 end;

--                 this._pagination_args = args;
--         end;

--         --
--         -- Access the pagination args.
--         --
--         -- @since 3.1.0
--         --
--         -- @param string key Pagination argument to retrieve. Common values include "total_items",
--         --                    "total_pages", "per_page", or "infinite_scroll".
--         -- @return int Number of items that correspond to the given pagination argument.
--         --
--         public function get_pagination_arg( key ) then
--                 if ( "page" === key ) then
--                         return this.get_pagenum();
--                 end;

--                 if ( isset( this._pagination_args[ key ] ) ) then
--                         return this._pagination_args[ key ];
--                 end;

--                 return 0;
--         end;

   ---------------
   -- Has_Items --
   ---------------

   function Has_Items (This : Wp_List_Table)
                       return Boolean
   is
   begin
      return not This.Items.Is_Empty;
   end Has_Items;

   -------------
   -- No_Item --
   -------------

   procedure No_Items (This : Wp_List_Table)
   is
--    use Php;
      use Inc_L10n;
   begin
      X_E ("No items found.");
   end No_Items;

   ----------------
   -- Search_Box --
   ----------------

   procedure Search_Box (This     : Wp_List_Table;
                         Text     : String;
                         Input_Id : String)
   is
      use Binder;
      use UStrings;
      use Php;
      use Php.Echoing;
      use Adi_Templates;
      use Inc_Formatting;

      Input_Id_2 : constant String := Input_Id & "-search-input";
   begin
      if Empty (X_REQUEST, "s") and then not This.Has_Items then
         return;
      end if;

      if not Empty (X_REQUEST, "orderby") then
         Echo ("<input type=""hidden"" name=""orderby"" value=""""" &
               ESC_Attr (As_String (Get (X_REQUEST, "orderby"))) & """ />");
      end if;

      if not Empty (X_REQUEST, "order") then
         Echo ("<input type=""hidden"" name=""order"" value=""""" &
               ESC_Attr (As_String (Get (X_REQUEST, "order"))) & """ />");
      end if;

      if not Empty (X_REQUEST, "post_mime_type") then
         Echo ("<input type=""hidden"" name=""post_mime_type"" value=""""" &
               ESC_Attr (As_String (Get (X_REQUEST, "post_mime_type"))) & """ />");
      end if;

      if not Empty (X_REQUEST, "detached") then
         Echo ("<input type=""hidden"" name=""detached"" value=""""" &
               ESC_Attr (As_String (Get (X_REQUEST, "detached"))) & """ />");
      end if;

      Echo ("<p class=""search-box"">" & NL);
      Echo ("  <label class=""screen-reader-text"" for=" & ESC_Attr (Input_Id_2) &
            ">" & Text & "</label>" & NL);
      Echo ("  <input type=""search"" id=" & ESC_Attr (Input_Id_2) &
            " name=""s"" value=""");
      X_Admin_Search_Query;
      Echo (""" />" & NL);
      Echo ("  ");
      Submit_Button
         (Text, "", "", False,
          To_Array ((1 => Build ("id", "search-submit"))));
      Echo ("</p>" & NL);

   end Search_Box;

--         --
--         -- Generates views links.
--         --
--         -- @since 6.1.0
--         --
--         -- @param array link_data then
--         --     An array of link data.
--         --
--         --     @type string url     The link URL.
--         --     @type string label   The link label.
--         --     @type bool   current Optional. Whether this is the currently selected view.
--         -- end;
--         -- @return array An array of link markup. Keys match the `link_data` input array.
--         --
--         protected function get_views_links( link_data = array() ) then
--                 if ( ! is_array( link_data ) ) then
--                         _doing_it_wrong(
--                                 __METHOD__,
--                                 sprintf(
--                                         /* translators: %s: The link_data argument.--
--                                         __( "The %s argument must be an array." ),
--                                         "<code>link_data</code>"
--                                 ),
--                                 "6.1.0"
--                         );

--                         return array( "" );
--                 end;

--                 views_links = array();

--                 foreach ( link_data as view => link ) then
--                         if ( empty( link["url"] ) || ! is_string( link["url"] ) || "" === trim( link["url"] ) ) then
--                                 _doing_it_wrong(
--                                         __METHOD__,
--                                         sprintf(
--                                                 /* translators: %1s: The argument name. %2s: The view name.--
--                                                 __( "The %1s argument must be a non-empty string for %2s." ),
--                                                 "<code>url</code>",
--                                                 "<code>" . esc_html( view ) . "</code>"
--                                         ),
--                                         "6.1.0"
--                                 );

--                                 continue;
--                         end;

--                         if ( empty( link["label"] ) || ! is_string( link["label"] ) || "" === trim( link["label"] ) ) then
--                                 _doing_it_wrong(
--                                         __METHOD__,
--                                         sprintf(
--                                                 /* translators: %1s: The argument name. %2s: The view name.--
--                                                 __( "The %1s argument must be a non-empty string for %2s." ),
--                                                 "<code>label</code>",
--                                                 "<code>" . esc_html( view ) . "</code>"
--                                         ),
--                                         "6.1.0"
--                                 );

--                                 continue;
--                         end;

--                         views_links[ view ] = sprintf(
--                                 "<a href="%s"%s>%s</a>",
--                                 esc_url( link["url"] ),
--                                 isset( link["current"] ) && true === link["current"] ? " class="current" aria-current="page"" : "",
--                                 link["label"]
--                         );
--                 end;

--                 return views_links;
--         end;

   ---------------
   -- Get_Views --
   ---------------

   function Get_Views (This : Wp_List_Table)
            return Array_Type
   is
   begin
      return Empty_Array;
   end Get_Views;

   -----------
   -- Views --
   -----------

   procedure Views (This : Wp_List_Table)
   is
      use UStrings;
      use Php;
      use Php.Echoing;
      use Php.Strings;
      use Inc_Plugins;

      Views : Array_Type := This.Get_Views;
   begin
      --
      -- Filters the list of available list table views.
      --
      -- The dynamic portion of the hook name, `this.screen.id`, refers
      -- to the ID of the current screen.
      --
      -- @since 3.1.0
      --
      -- @param string[] views An array of available list table views.
      --
      Views := Apply_Filters ("views_" & (-This.Screen.Id), Views);

      if Views.Is_Empty then
--    if Empty (Views) then
         return;
      end if;

      This.Screen.Render_Screen_Reader_Content ("heading_views");

      Echo ("<ul class=""subsubsub"">\n");
      for A in Views.Iterate loop
         declare
            Class : constant String := Key (A);
            View  : constant String := As_String (Get (Views, Class));
         begin
            Set (Views, Class,
                 From_String ("\t<li class=""" & Class  & """>" & View));
         end;
      end loop;
      Echo (Implode (" |</li>\n", Views) & "</li>\n");
      Echo ("</ul>");
   end Views;

   ----------------------
   -- Get_Bulk_Actions --
   ----------------------

   function Get_Bulk_Actions (This : Wp_List_Table)
                              return Array_Type
   is
   begin
      return Empty_Array;
   end Get_Bulk_Actions;

   ------------------
   -- Bulk_Actions --
   ------------------

   procedure Bulk_Actions (This  : in out Wp_List_Table;
                           Which : String := "")
   is
      use UStrings;
      use Php.Arrays;
      use Php.Echoing;
      use Inc_Formatting;
      use Inc_L10n;
      use Inc_Plugins;

      Two : UString;
   begin
      if This.X_Actions.Is_Empty then
--    if Is_Null (This.X_Actions) then
         This.X_Actions := This.Get_Bulk_Actions;

         --
         -- Filters the items in the bulk actions menu of the list table.
         --
         -- The dynamic portion of the hook name, `this.screen.id`, refers
         -- to the ID of the current screen.
         --
         -- @since 3.1.0
         -- @since 5.6.0 A bulk action can now contain an array of options in order
         --              to create an optgroup.
         --
         -- @param array actions An array of the available bulk actions.
         --
         This.X_Actions :=
           Apply_Filters ("bulk_actions-thenthis.screen.idend;", This.X_Actions);
         -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

         Two := +"";
      else
         Two := +"2";
      end if;

      if Empty (This.X_Actions) then
         return;
      end if;

      Echo ("<label for=""bulk-action-selector-" & ESC_Attr (Which) &
            """ class=""screen-reader-text"">" & abs "Select bulk action" &
            "</label>" & NL);
      Echo ("<select name=""action""" & (-Two) & """ id=""bulk-action-selector-" &
             ESC_Attr (Which) & "\"">" & NL & NL);
      Echo ("<option value=""-1"">" & abs "Bulk actions" & "</option>" & NL & NL);

      for A in This.X_Actions.Iterate loop --  as key => value ) then
         declare
            Key   : constant String := Arrays.Key     (A);
            Value : constant String := As_String (Get (This.X_Actions, Key));
         begin
            if False then -- Is_Array (Value) then
               Echo (TAB & "<optgroup label=""" & ESC_Attr (Key) & """>" & NL & NL);

               for B in Empty_Array.Iterate loop -- Value.Iterate loop
                  declare
                     Name  : constant String := Arrays.Key (B);
                     Title : constant String := As_String (Get (Empty_Array, Name));
                     -- Array_Maps.Element (B);

                     Class : constant String :=
                       (if "edit" = Name
                        then " class=""hide-if-no-js""" else "");
                  begin
                     Echo (TAB & TAB & "<option value=""" & ESC_Attr (Name) & """" &
                           Class & ">" & Title & "</option>" & NL & NL);
                  end;
               end loop;
               Echo (TAB & "</optgroup>" & NL & NL);
            else
               declare
                  Class : String := (if "edit" = Key
                                     then " class=""hide-if-no-js""" else "");
               begin
                  Echo (TAB & "<option value=""" & ESC_Attr (Key) & """" & Class &
                        ">" & Value & "</option>" & NL & NL);
               end;
            end if;
         end;
      end loop;

      Echo ("</select>" & NL & NL);

      Adi_Templates.Submit_Button (abs "Apply", "action", "", False,
                                   To_Array ((1 => Build ("id", "doactiontwo"))));
      Echo (NL & NL);
   end Bulk_Actions;

--         --
--         -- Gets the current action selected from the bulk actions dropdown.
--         --
--         -- @since 3.1.0
--         --
--         -- @return string|false The action name. False if no action was selected.
--         --
--         public function current_action() then
--                 if ( isset( _REQUEST["filter_action"] ) && ! empty( _REQUEST["filter_action"] ) ) then
--                         return false;
--                 end;

--                 if ( isset( _REQUEST["action"] ) && -1 != _REQUEST["action"] ) then
--                         return _REQUEST["action"];
--                 end;

--                 return false;
--         end;

--         --
--         -- Generates the required HTML for a list of row action links.
--         --
--         -- @since 3.1.0
--         --
--         -- @param string[] actions        An array of action links.
--         -- @param bool     always_visible Whether the actions should be always visible.
--         -- @return string The HTML for the row actions.
--         --
--         protected function row_actions( actions, always_visible = false ) then
--                 action_count = count( actions );

--                 if ( ! action_count ) then
--                         return "";
--                 end;

--                 mode = get_user_setting( "posts_list_mode", "list" );

--                 if ( "excerpt" === mode ) then
--                         always_visible = true;
--                 end;

--                 output = "<div class="" . ( always_visible ? "row-actions visible" : "row-actions" ) . "">";

--                 i = 0;

--                 foreach ( actions as action => link ) then
--                         ++i;

--                         separator = ( i < action_count ) ? " | " : "";

--                         output .= "<span class="action">thenlinkend;thenseparatorend;</span>";
--                 end;

--                 output .= "</div>";

--                 output .= "<button type="button" class="toggle-row"><span class="screen-reader-text">" . __( "Show more details" ) . "</span></button>";

--                 return output;
--         end;

--         --
--         -- Displays a dropdown for filtering items in the list table by month.
--         --
--         -- @since 3.1.0
--         --
--         -- @global wpdb      wpdb      WordPress database abstraction object.
--         -- @global WP_Locale wp_locale WordPress date and time locale object.
--         --
--         -- @param string post_type The post type.
--         --
--         protected function months_dropdown( post_type ) then
--                 global wpdb, wp_locale;

--                 --
--                 -- Filters whether to remove the "Months" drop-down from the post list table.
--                 --
--                 -- @since 4.2.0
--                 --
--                 -- @param bool   disable   Whether to disable the drop-down. Default false.
--                 -- @param string post_type The post type.
--                 --
--                 if ( apply_filters( "disable_months_dropdown", false, post_type ) ) then
--                         return;
--                 end;

--                 --
--                 -- Filters whether to short-circuit performing the months dropdown query.
--                 --
--                 -- @since 5.7.0
--                 --
--                 -- @param object[]|false months   "Months" drop-down results. Default false.
--                 -- @param string         post_type The post type.
--                 --
--                 months = apply_filters( "pre_months_dropdown_query", false, post_type );

--                 if ( ! is_array( months ) ) then
--                         extra_checks = "AND post_status != "auto-draft"";
--                         if ( ! isset( _GET["post_status"] ) || "trash" !== _GET["post_status"] ) then
--                                 extra_checks .= " AND post_status != "trash"";
--                         end; elseif ( isset( _GET["post_status"] ) ) then
--                                 extra_checks = wpdb.prepare( " AND post_status = %s", _GET["post_status"] );
--                         end;

--                         months = wpdb.get_results(
--                                 wpdb.prepare(
--                                         "
--                                 SELECT DISTINCT YEAR( post_date ) AS year, MONTH( post_date ) AS month
--                                 FROM wpdb.posts
--                                 WHERE post_type = %s
--                                 extra_checks
--                                 ORDER BY post_date DESC
--                         ",
--                                         post_type
--                                 )
--                         );
--                 end;

--                 --
--                 -- Filters the "Months" drop-down results.
--                 --
--                 -- @since 3.7.0
--                 --
--                 -- @param object[] months    Array of the months drop-down query results.
--                 -- @param string   post_type The post type.
--                 --
--                 months = apply_filters( "months_dropdown_results", months, post_type );

--                 month_count = count( months );

--                 if ( ! month_count || ( 1 == month_count && 0 == months[0].month ) ) then
--                         return;
--                 end;

--                 m = isset( _GET["m"] ) ? (int) _GET["m"] : 0;
--                 ?>
--                 <label for="filter-by-date" class="screen-reader-text"><?php echo get_post_type_object( post_type ).labels.filter_by_date; ?></label>
--                 <select name="m" id="filter-by-date">
--                         <option<?php selected( m, 0 ); ?> value="0"><?php _e( "All dates" ); ?></option>
--                 <?php
--                 foreach ( months as arc_row ) then
--                         if ( 0 == arc_row.year ) then
--                                 continue;
--                         end;

--                         month = zeroise( arc_row.month, 2 );
--                         year  = arc_row.year;

--                         printf(
--                                 "<option %s value="%s">%s</option>\n",
--                                 selected( m, year . month, false ),
--                                 esc_attr( arc_row.year . month ),
--                                 /* translators: 1: Month name, 2: 4-digit year.--
--                                 sprintf( __( "%1s %2d" ), wp_locale.get_month( month ), year )
--                         );
--                 end;
--                 ?>
--                 </select>
--                 <?php
--         end;

--         --
--         -- Displays a view switcher.
--         --
--         -- @since 3.1.0
--         --
--         -- @param string current_mode
--         --
--         protected function view_switcher( current_mode ) then
--                 ?>
--                 <input type="hidden" name="mode" value="<?php echo esc_attr( current_mode ); ?>" />
--                 <div class="view-switch">
--                 <?php
--                 foreach ( this.modes as mode => title ) then
--                         classes      = array( "view-" . mode );
--                         aria_current = "";

--                         if ( current_mode === mode ) then
--                                 classes[]    = "current";
--                                 aria_current = " aria-current="page"";
--                         end;

--                         printf(
--                                 "<a href="%s" class="%s" id="view-switch-mode"aria_current><span class="screen-reader-text">%s</span></a>\n",
--                                 esc_url( remove_query_arg( "attachment-filter", add_query_arg( "mode", mode ) ) ),
--                                 implode( " ", classes ),
--                                 title
--                         );
--                 end;
--                 ?>
--                 </div>
--                 <?php
--         end;

--         --
--         -- Displays a comment count bubble.
--         --
--         -- @since 3.1.0
--         --
--         -- @param int post_id          The post ID.
--         -- @param int pending_comments Number of pending comments.
--         --
--         protected function comments_bubble( post_id, pending_comments ) then
--                 approved_comments = get_comments_number();

--                 approved_comments_number = number_format_i18n( approved_comments );
--                 pending_comments_number  = number_format_i18n( pending_comments );

--                 approved_only_phrase = sprintf(
--                         /* translators: %s: Number of comments.--
--                         _n( "%s comment", "%s comments", approved_comments ),
--                         approved_comments_number
--                 );

--                 approved_phrase = sprintf(
--                         /* translators: %s: Number of comments.--
--                         _n( "%s approved comment", "%s approved comments", approved_comments ),
--                         approved_comments_number
--                 );

--                 pending_phrase = sprintf(
--                         /* translators: %s: Number of comments.--
--                         _n( "%s pending comment", "%s pending comments", pending_comments ),
--                         pending_comments_number
--                 );

--                 post_object   = get_post( post_id );
--                 edit_post_cap = post_object ? "edit_post" : "edit_posts";
--                 if (
--                         current_user_can( edit_post_cap, post_id ) ||
--                         (
--                                 empty( post_object.post_password ) &&
--                                 current_user_can( "read_post", post_id )
--                         )
--                 ) then
--                         // The user has access to the post and thus can see comments
--                 end; else then
--                         return false;
--                 end;

--                 if ( ! approved_comments && ! pending_comments ) then
--                         // No comments at all.
--                         printf(
--                                 "<span aria-hidden="true">&#8212;</span><span class="screen-reader-text">%s</span>",
--                                 __( "No comments" )
--                         );
--                 end; elseif ( approved_comments && "trash" === get_post_status( post_id ) ) then
--                         // Don"t link the comment bubble for a trashed post.
--                         printf(
--                                 "<span class="post-com-count post-com-count-approved"><span class="comment-count-approved" aria-hidden="true">%s</span><span class="screen-reader-text">%s</span></span>",
--                                 approved_comments_number,
--                                 pending_comments ? approved_phrase : approved_only_phrase
--                         );
--                 end; elseif ( approved_comments ) then
--                         // Link the comment bubble to approved comments.
--                         printf(
--                                 "<a href="%s" class="post-com-count post-com-count-approved"><span class="comment-count-approved" aria-hidden="true">%s</span><span class="screen-reader-text">%s</span></a>",
--                                 esc_url(
--                                         add_query_arg(
--                                                 array(
--                                                         "p"              => post_id,
--                                                         "comment_status" => "approved",
--                                                 ),
--                                                 admin_url( "edit-comments.php" )
--                                         )
--                                 ),
--                                 approved_comments_number,
--                                 pending_comments ? approved_phrase : approved_only_phrase
--                         );
--                 end; else then
--                         // Don"t link the comment bubble when there are no approved comments.
--                         printf(
--                                 "<span class="post-com-count post-com-count-no-comments"><span class="comment-count comment-count-no-comments" aria-hidden="true">%s</span><span class="screen-reader-text">%s</span></span>",
--                                 approved_comments_number,
--                                 pending_comments ? __( "No approved comments" ) : __( "No comments" )
--                         );
--                 end;

--                 if ( pending_comments ) then
--                         printf(
--                                 "<a href="%s" class="post-com-count post-com-count-pending"><span class="comment-count-pending" aria-hidden="true">%s</span><span class="screen-reader-text">%s</span></a>",
--                                 esc_url(
--                                         add_query_arg(
--                                                 array(
--                                                         "p"              => post_id,
--                                                         "comment_status" => "moderated",
--                                                 ),
--                                                 admin_url( "edit-comments.php" )
--                                         )
--                                 ),
--                                 pending_comments_number,
--                                 pending_phrase
--                         );
--                 end; else then
--                         printf(
--                                 "<span class="post-com-count post-com-count-pending post-com-count-no-pending"><span class="comment-count comment-count-no-pending" aria-hidden="true">%s</span><span class="screen-reader-text">%s</span></span>",
--                                 pending_comments_number,
--                                 approved_comments ? __( "No pending comments" ) : __( "No comments" )
--                         );
--                 end;
--         end;

--         --
--         -- Gets the current page number.
--         --
--         -- @since 3.1.0
--         --
--         -- @return int
--         --
--         public function get_pagenum() then
--                 pagenum = isset( _REQUEST["paged"] ) ? absint( _REQUEST["paged"] ) : 0;

--                 if ( isset( this._pagination_args["total_pages"] ) && pagenum > this._pagination_args["total_pages"] ) then
--                         pagenum = this._pagination_args["total_pages"];
--                 end;

--                 return max( 1, pagenum );
--         end;

--         --
--         -- Gets the number of items to display on a single page.
--         --
--         -- @since 3.1.0
--         --
--         -- @param string option        User option name.
--         -- @param int    default_value Optional. The number of items to display. Default 20.
--         -- @return int
--         --
--         protected function get_items_per_page( option, default_value = 20 ) then
--                 per_page = (int) get_user_option( option );
--                 if ( empty( per_page ) || per_page < 1 ) then
--                         per_page = default_value;
--                 end;

--                 --
--                 -- Filters the number of items to be displayed on each page of the list table.
--                 --
--                 -- The dynamic hook name, `option`, refers to the `per_page` option depending
--                 -- on the type of list table in use. Possible filter names include:
--                 --
--                 --  - `edit_comments_per_page`
--                 --  - `sites_network_per_page`
--                 --  - `site_themes_network_per_page`
--                 --  - `themes_network_per_page"`
--                 --  - `users_network_per_page`
--                 --  - `edit_post_per_page`
--                 --  - `edit_page_per_page"`
--                 --  - `edit_thenpost_typeend;_per_page`
--                 --  - `edit_post_tag_per_page`
--                 --  - `edit_category_per_page`
--                 --  - `edit_thentaxonomyend;_per_page`
--                 --  - `site_users_network_per_page`
--                 --  - `users_per_page`
--                 --
--                 -- @since 2.9.0
--                 --
--                 -- @param int per_page Number of items to be displayed. Default 20.
--                 --
--                 return (int) apply_filters( "thenoptionend;", per_page );
--         end;

   ----------------
   -- Pagination --
   ----------------

   procedure Pagination (This  : in out Wp_List_Table;
                         Which : String)
   is
      use Binder;
      use UStrings;
      use Php;
      use Php.Echoing;
      use Php.Strings;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Link_Templates;
   begin
      if This.X_Pagination_Args.Is_Empty then
         return;
      end if;

      declare
         Total_Items : constant Natural :=
           As_Integer (Get (This.X_Pagination_Args, "total_items"));

         Total_Pages : constant Natural :=
           As_Integer (Get (This.X_Pagination_Args, "total_pages"));

         Infinite_Scroll : Boolean := False;
         Output  : UString;
         Current : Natural;
         Current_URL : UString;
         Page_Links  : UString; -- Array_Type;

         Total_Pages_Before : UString := +"<span class=""paging-input"">";
         Total_Pages_After  : constant UString := +"</span></span>";

         Removable_Query_Args : constant List_Type := Wp_Removable_Query_Args;

         Disable_First : Boolean := False;
         Disable_Last  : Boolean := False;
         Disable_Prev  : Boolean := False;
         Disable_Next  : Boolean := False;

         HTML_Current_Page : UString;
         HTML_Total_Pages  : UString;
      begin
         if Isset (This.X_Pagination_Args, "infinite_scroll") then
            Infinite_Scroll := As_Boolean (Get (This.X_Pagination_Args, "infinite_scroll"));
         end if;

         if "top" = Which and then Total_Pages > 1 then
            This.Screen.Render_Screen_Reader_Content ("heading_pagination");
         end if;

         Output := +"<span class=""displaying-num"">" & Sprintf (
                    -- translators: %s: Number of items.
                    X_N ("%s item", "%s items", Total_Items),
                    To_List (Number_Format_I18n (Float (Total_Items)))
                ) & "</span>";

         Current              := This.Get_Pagenum;
--       Removable_Query_Args := Wp_Removable_Query_Args;

         Current_URL :=
           +Set_URL_Scheme ("http://" &
           As_String (Get (X_SERVER, "HTTP_HOST")) &
           As_String (Get (X_SERVER, "REQUEST_URI")));

         Current_URL := +Remove_Query_Arg (Removable_Query_Args, -Current_URL);

--       Page_Links := Empty_Array;

--       Total_Pages_Before := +"<span class=""paging-input"">";
--       Total_Pages_After  := +"</span></span>";

         if 1 = Current then
            Disable_First := True;
            Disable_Prev  := True;
         end if;

         if Total_Pages = Current then
            Disable_Last := True;
            Disable_Next := True;
         end if;

         if Disable_First then
            Append (Page_Links, "<span class=""tablenav-pages-navspan button disabled"" aria-hidden=""true"">&laquo;</span>");
         else
            Append (Page_Links, Sprintf (
              "<a class=""first-page button"" href=""%s""><span class=""screen-reader-text"">%s</span><span aria-hidden=""true"">%s</span></a>",
              To_List (List => (
                1 => +ESC_URL (Remove_Query_Arg ("paged", -Current_URL)),
                2 => +abs "First page",
                3 => +"&laquo;"
            ))));
         end if;

         if Disable_Prev then
            Append (Page_Links, "<span class=""tablenav-pages-navspan button disabled"" aria-hidden=""true"">&lsaquo;</span>");
         else
            Append (Page_Links, Sprintf (
              "<a class=""prev-page button"" href=""%s""><span class=""screen-reader-text"">%s</span><span aria-hidden=""true"">%s</span></a>",
              To_List (List => (
                1 => +ESC_URL (
                         Add_Query_Arg ("paged",
                               Natural'Max (1, Current - 1)'Image,
                               -Current_URL)),
                2 => +abs "Previous page",
                3 => +"&lsaquo;"
            ))));
         end if;

         if "bottom" = Which then
            HTML_Current_Page  := +Current'Image;
            Total_Pages_Before := +"<span class=""screen-reader-text"">" &
              abs "Current Page" &
              "</span><span id=""table-paging"" class=""paging-input""><span class=""tablenav-paging-text"">";
         else
            HTML_Current_Page := +Sprintf (
              "%s<input class=""current-page"" id=""current-page-selector"" type=""text"" name=""paged"" value=""%s"" size=""%d"" aria-describedby=""table-paging"" /><span class=""tablenav-paging-text"">",
              To_List (List => (
              1 => +"<label for=""current-page-selector"" class=""screen-reader-text"">" & abs "Current Page" & "</label>",
              2 => +Current'Image,
              3 => +String'(Total_Pages'Image)'Length'Image
            )));
         end if;

         HTML_Total_Pages :=
           +Sprintf ("<span class=""total-pages"">%s</span>",
                     To_List (Number_Format_I18n (Float (Total_Pages))));

         Append (Page_Links, Total_Pages_Before & Sprintf (
           -- translators: 1: Current page, 2: Total pages.
           X_X ("%1s of %2s", "paging"),
           To_List (List => (
             1 => HTML_Current_Page,
             2 => HTML_Total_Pages
         ))) & Total_Pages_After);

         if Disable_Next then
            Append (Page_Links, "<span class=""tablenav-pages-navspan button disabled"" aria-hidden=""true"">&rsaquo;</span>");
         else
            Append (Page_Links, Sprintf (
              "<a class=""next-page button"" href=""%s""><span class=""screen-reader-text"">%s</span><span aria-hidden=""true"">%s</span></a>",
              To_List (List => (
                1 => +ESC_URL (
                          Add_Query_Arg ("paged",
                               Natural'Min (Total_Pages, Current + 1)'Image,
                               -Current_URL)),
                2 => +abs "Next page",
                3 => +"&rsaquo;"
            ))));
         end if;

         if Disable_Last then
            Append (Page_Links, "<span class=""tablenav-pages-navspan button disabled"" aria-hidden=""true"">&raquo;</span>");
         else
            Append (Page_Links, Sprintf (
              "<a class=""last-page button"" href=""%s""><span class=""screen-reader-text"">%s</span><span aria-hidden=""true"">%s</span></a>",
              To_List (List => (
                1 => +ESC_URL (Add_Query_Arg ("paged", Total_Pages'Image, -Current_URL)),
                2 => +abs "Last page",
                3 => +"&raquo;"
            ))));
         end if;

         declare
            Pagination_Links_Class : UString := +"pagination-links";
            Page_Class             : UString;
         begin
            if Infinite_Scroll then
--          if not Empty (Infinite_Scroll) then
               Append (Pagination_Links_Class, " hide-if-js");
            end if;

            Append (Output, "\n<span class=""" & Pagination_Links_Class & """>" &
                            Implode ("\n", -Page_Links) & "</span>");

            if Total_Pages /= 0 then
               Page_Class := +(if Total_Pages < 2 then " one-page" else "");
            else
               Page_Class := +" no-pages";
            end if;

            This.X_Pagination :=
              "<div class=""tablenav-pages" & Page_Class & ">output</div>";
         end;

         Echo (-This.X_Pagination);
      end;
   end Pagination;

   -----------------
   -- Get_Columns --
   -----------------

   function Get_Columns (This : Wp_List_Table)
                         return Array_Type
   is
      use Php.Errors;
   begin
      Die ("function WP_List_Table::get_columns() must be overridden in a subclass.");
      return Empty_Array;
   end Get_Columns;

   --------------------------
   -- Get_Sortable_Columns --
   --------------------------

   function Get_Sortable_Columns (This : Wp_List_Table)
                                  return Array_Type
   is
   begin
      return Empty_Array;
   end Get_Sortable_Columns;

   -------------------------------------
   -- Get_Default_Primary_Column_Name --
   -------------------------------------

   function Get_Default_Primary_Column_Name (This : Wp_List_Table)
                                             return String
   is
      use UStrings;

      Columns : constant Array_Type := This.Get_Columns;
      Column  : UString := +"";
   begin
      if Columns.Is_Empty then
         return -Column;
      end if;

      -- We need a primary defined so responsive views show something,
      -- so let's fall back to the first non-checkbox column.
      for A in Columns.Iterate loop
         declare
            Col         : constant String := Key (A);
--          Column_Name :          String := As_String (Get (Columns, Col));
            -- Array_Maps.Element (A);
         begin
            if "cb" = Col then
               goto Continue;
            end if;

            Column := +Col;
            exit; -- break;
         end;
         << Continue >>
      end loop;

      return -Column;
   end Get_Default_Primary_Column_Name;

--         --
--         -- Public wrapper for WP_List_Table::get_default_primary_column_name().
--         --
--         -- @since 4.4.0
--         --
--         -- @return string Name of the default primary column.
--         --
--         public function get_primary_column() then
--                 return this.get_primary_column_name();
--         end;

   -----------------------------
   -- Get_Primary_Column_Name --
   -----------------------------

   function Get_Primary_Column_Name (This : Wp_List_Table)
                                     return String
   is
      use Php.Strings;
      use UStrings;
      use Inc_Plugins;

      Columns   : constant Array_Type := Adi_Screens.Get_Column_Headers (This.Screen);
      Default_2 : constant String     := This.Get_Default_Primary_Column_Name;

      -- If the primary column doesn't exist,
      -- fall back to the first non-checkbox column.
      Default : constant String :=
        (if not Isset (Columns, Default_2)
         then This.Get_Default_Primary_Column_Name -- self::
         else Default_2);

      --
      -- Filters the name of the primary column for the current list table.
      --
      -- @since 4.3.0
      --
      -- @param string default Column name default for the specific list table, e.g.
      --                       "name".
      -- @param string context Screen ID for specific list table, e.g. "plugins".
      --
      Column_2 : constant String :=
         Apply_Filters ("list_table_primary_column", Default, -This.Screen.Id);

      Column : constant String :=
        (if Empty (Column_2) or else not Isset (Columns, Column_2)
         then Default
         else Column_2);
   begin
      return Column;
   end Get_Primary_Column_Name;

   ---------------------
   -- Get_Column_Info --
   ---------------------

   function Get_Column_Info (This : in out Wp_List_Table)
                             return Columns_Type
   is
      use UStrings;
      use Inc_Plugins;
   begin
      -- _column_headers is already set / cached.
--       if
--         Isset (This.X_Column_Headers) and then
--         Is_Array (This.X_Column_Headers)
--       then
--          --
--          -- Backward compatibility for `_column_headers` format prior to WordPress 4.3.
--          --
--          -- In WordPress 4.3 the primary column name was added as a fourth item in the
--          -- column headers property. This ensures the primary column name is included
--          -- in plugins setting the property directly in the three item format.
--          --
--          if 4 = This.X_Column_Headers.Length then
--             return This.X_Column_Headers;
--          end if;

--          declare
--             Column_Headers : Columns_Type :=
-- --            Arrays.To_Array ((List =>
--                                  (Empty_Array,
--                                   Empty_Array,
--                                   Empty_Array,
--                                   +This.Get_Primary_Column_Name); -- ));
--          begin
--             for A in This.X_Column_Headers.Iterate loop
--                declare
--                   Key   : String := Array_Maps.Key     (A);
--                   Value : String := Array_Maps.Element (A);
--                begin
--                   Column_Headers (Key) := Value;
--                end;
--             end loop;

--             This.X_Column_Headers := Column_Headers;
--          end;
--          return This.X_Column_Headers;
--       end if;

      declare
--       Columns : constant List_Type := Adi_Screens.Get_Column_Headers (This.Screen);
         Columns : constant Array_Type := Adi_Screens.Get_Column_Headers (This.Screen);
--       Hidden  : constant List_Type := Adi_Screens.Get_Hidden_Columns (This.Screen);
         Hidden  : constant Array_Type := Adi_Screens.Get_Hidden_Columns (This.Screen);

         Sortable_Columns : constant Array_Type := This.Get_Sortable_Columns; -- ()

         --
         -- Filters the list table sortable columns for a specific screen.
         --
         -- The dynamic portion of the hook name, `this.screen.id`, refers
         -- to the ID of the current screen.
         --
         -- @since 3.1.0
         --
         -- @param array sortable_columns An array of sortable columns.
         --
         X_Sortable : Array_Type :=
           Apply_Filters ("manage_" & (-This.Screen.Id) & "_sortable_columns",
                          Sortable_Columns);

--       Sortable : constant List_Type := Empty_List;
         Sortable : constant Array_Type := Empty_Array;
      begin
         -- for A in X_Sortable.Iterate loop --  as id => data ) then
         --    declare
         --       Id   : String := Array_Maps.Key     (A);
         --       Data : String := Array_Maps.Element (A);
         --    begin
         --       if Empty (Data) then
         --          goto Continue;
         --       end if;

         --       Data := Data; -- (array)
         --       if not Isset (Data (1)) then
         --          Data (1) := False;
         --       end if;

         --       Sortable (Id) := Data;
         --    end;
         --    << Continue >>
         -- end loop;

         declare
            Primary : constant String := This.Get_Primary_Column_Name;
         begin
            This.X_Column_Headers := (Columns, Hidden, Sortable, +Primary);
--          This.X_Column_Headers := To_Array (Columns, Hidden, Sortable, Primary);
         end;
      end;
      return This.X_Column_Headers;
   end Get_Column_Info;

   ----------------------
   -- Get_Column_Count --
   ----------------------

   function Get_Column_Count (This : in out Wp_List_Table)
                              return Natural
   is
      use type Ada.Containers.Count_Type;
--    use UStrings;
      use Php;
      use Php.Arrays;
      use Php.Lists;

      Column_Info : constant Columns_Type := This.Get_Column_Info;
--    Columns  : constant List_Type  := Column_Info.Columns;
      Columns  : constant Array_Type := Column_Info.Columns;
--    Hidden_2 : constant List_Type  := Column_Info.Hidden;
      Hidden_2 : constant Array_Type := Column_Info.Hidden;

      Hidden   : constant List_Type :=
        List_Intersect (Array_Keys (Columns), Array_Filter (Hidden_2));
   begin
      return Natural (Columns.Length - List_Vectors.Length (Hidden));
--    return Natural (Array_Maps.Length (Columns) - List_Vectors.Length (Hidden));
   end Get_Column_Count;

   Static_CB_Counter : Positive := 1;

   --------------------------
   -- Print_Column_Headers --
   --------------------------

   procedure Print_Column_Headers (This    : in out Wp_List_Table;
                                   With_Id : Boolean := True)
   is
      use Php.Arrays;
      use Php.Echoing;
      use Php.Lists;
      use Php.Misc;
      use Php.Strings;
      use Binder;
      use UStrings;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;

      Column_Info : constant Columns_Type := This.Get_Column_Info;

      Columns  :          Array_Type := Column_Info.Columns;
      Hidden   : constant Array_Type := Column_Info.Hidden;
      Sortable : constant Array_Type := Column_Info.Sortable;
      Primary  : constant String     := -Column_Info.Primary;

      HTTP_Host   : constant String := As_String (Get (X_SERVER, "HTTP_HOST"));
      Request_URI : constant String := As_String (Get (X_SERVER, "REQUEST_URI"));

      Current_URL_2 : constant String :=
        Inc_Link_Templates.Set_URL_Scheme
          ("http://" & HTTP_Host & Request_URI);

      Current_URL : constant String := Remove_Query_Arg ("paged", Current_URL_2);

      Current_Orderby : constant String :=
        (if Isset (XX_GET, "orderby")
         then Get_As_String (XX_GET, "orderby")
         else "");

      Current_Order : constant String :=
        (if Isset (XX_GET, "order") and then
            "desc" = Get_As_String (XX_GET, "order")
         then "desc"
         else "asc");

   begin
      if Isset (Columns, "cb") then
--       static cb_counter = 1;
         Set (Columns, "cb",
           From_String (
             "<label class=""screen-reader-text"" for=""cb-select-all-" &
             Static_CB_Counter'Image & """>" & abs "Select All" & "</label>" &
             "<input id=""cb-select-all-" & Static_CB_Counter'Image &
             """ type=""checkbox"" />"));

         Static_CB_Counter := Static_CB_Counter + 1;
      end if;

      for A in Columns.Iterate loop
         declare
--          use Array_Maps;
            use List_Vectors;
--          Column_Key          : constant Integer := -To_Index (A); -- Key (A);
            Column_Key          : constant String := Key (A);
--          Column_Display_Name : String := -Columns (Column_Key); -- Element (A);
            Column_Display_Name : String := As_String (Get (Columns, Column_Key));
            -- Array_Maps.Element (A);
            Class : List_Type := To_List (List => (+"manage-column",
                                                   +"column-column_key"));
         begin
            if In_Array (Column_Key, Hidden, True) then
               Class.Append (+"hidden");
            end if;

            if "cb" = Column_Key then
               Class.Append (+"check-column");
            elsif
               In_List (Column_Key, To_List (List => (+"posts",
                                                      +"comments",
                                                      +"links")), True)
            then
               Class.Append (+"num");
            end if;

            if Column_Key = Primary then
               Class.Append (+"column-primary");
            end if;

            if Isset (Sortable, Column_Key) then
               declare
                  Orderby : constant String :=
                    As_String (Get (Sortable, "orderby"));
--                  Get (Get_List (Sortable, Column_Key), "orderby");

                  Desc_First : constant String :=
                    As_String (Get (As_Array (Get (Sortable, Column_Key)), "desc_first"));

--                List (orderby, desc_first) := Sortable (Column_Key);
                  Order : UString;
               begin
                  if Current_Orderby = Orderby then
                     Order := +(if "asc" = Current_Order then "desc" else "asc");

                     Class.Append (+"sorted");
                     Class.Append (+Current_Order);
                  else
                     Order := +Php.Strings.Strtolower (Desc_First);

                     if
                       not In_List (-Order, To_List (List => (+"desc",
                                                              +"asc")), True)
                     then
                        Order := +(if Desc_First /= "" then "desc" else "asc");
                     end if;

                     Class.Append (+"sortable");
                     Class.Append (+(if "desc" = Order then "asc" else "desc"));
                  end if;

                  Column_Display_Name := Php.Strings.Sprintf (
                    "<a href=""%s""><span>%s</span><span class=""sorting-indicator""></span></a>",
                    To_List (List => (
                      1 => +ESC_URL (Add_Query_Arg (Compact ("orderby", "order"),
                                            Current_URL)),
                      2 => +Column_Display_Name
                  )));
               end;
            end if;

            declare
               Tag   : String := (if "cb" = Column_Key then "td" else "th");
               Scope : String := (if "th" = Tag then "scope=""col""" else "");
               Id    : String := (if With_Id then "id=""column_key""" else "");
               Class_2 : constant String :=
                 (if not Class.Is_Empty
                  then "class=""" & Implode (" ", Class) & """"
                  else "");
            begin
               -- if not Empty (Class) then
               --    Class_2 := +"class=""" & Php.Implode (" ", Class) & """";
               -- end if;

               Echo ("<tag " & Scope & " " & Id & " " & Class_2 & ">" &
                     Column_Display_Name & "</tag>" & NL);
            end;
         end;
      end loop;
   end Print_Column_Headers;

   -------------
   -- Display --
   -------------

   procedure Display (This : in out Wp_List_Table)
   is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;

      Singular : constant String := As_String (Get (This.X_Args, "singular"));
   begin
      This.Display_Tablenav ("top");
      This.Screen.Render_Screen_Reader_Content ("heading_list");

      Echo ("<table class=""wp-list-table " &
            Implode (" ", This.Get_Table_Classes) & ">" & NL);
      Echo ("  <thead>" & NL);
      Echo ("  <tr>" & NL);
      Echo ("    ");

      This.Print_Column_Headers;

      Echo ("  </tr>" & NL);
      Echo ("  </thead>" & NL);
      Echo (NL);
      Echo ("  <tbody id=""the-list""" & NL);

      if Singular /= "" then
         Echo (" data-wp-lists=""list:" & Singular & """");
      end if;
      Echo ("          >" & NL);
      Echo ("          ");
      This.Display_Rows_Or_Placeholder;

      Echo ("  </tbody>" & NL);
      Echo (NL);
      Echo ("  <tfoot>" & NL);
      Echo ("  <tr>" & NL);
      Echo ("    ");
      This.Print_Column_Headers (False);

      Echo ("  </tr>" & NL);
      Echo ("  </tfoot>" & NL);
      Echo (NL);
      Echo ("</table>" & NL);
      This.Display_Tablenav ("bottom");
   end Display;

   -----------------------
   -- Get_Table_Classes --
   -----------------------

   function Get_Table_Classes (This : Wp_List_Table)
                               return List_Type
   is
      use UStrings;
      use Inc_Formatting;
      use Inc_Options;

      Mode       : constant String :=
        As_String (Get_User_Setting ("posts_list_mode", "list"));

      Mode_Class : constant String := ESC_Attr ("table-view-" & Mode);
   begin
      return To_List (List => (+"widefat", +"fixed", +"striped",
                               +Mode_Class, +As_String (Get (This.X_Args, "plural"))));
   end Get_Table_Classes;

   ----------------------
   -- Display_Tablenav --
   ----------------------

   procedure Display_Tablenav (This  : in out Wp_List_Table;
                               Which : String)
   is
      use UStrings;
      use Php;
      use Php.Echoing;
      use Inc_Functions;
      use Inc_Formatting;

      Unused : UString;
   begin
      declare
         Unused : constant String := As_String (Get (This.X_Args, "plural"));
      begin
         null;
      end;

      if "top" = Which then
         Unused := +Wp_Nonce_Field ("bulk-" & As_String (Get (This.X_Args, "plural")));
      end if;

      Echo ("  <div class=""tablenav " & ESC_Attr (Which) & ">" & NL);
      Echo (NL);

      if This.Has_Items then
         Echo ("    <div class=""alignleft actions bulkactions"">" & NL);
         Echo ("      ");
         This.Bulk_Actions (Which);
         Echo ("    </div>" & NL);
      end if;

      This.Extra_Tablenav (Which);
      This.Pagination (Which);

      Echo (NL);
      Echo ("   <br class=""clear"" />" & NL);
      Echo ("  </div>" & NL);
   end Display_Tablenav;

   --------------------
   -- Extra_Tablenav --
   --------------------

   procedure Extra_Tablenav (This  : Wp_List_Table;
                             Which : String)
   is
   begin
      null;
   end Extra_Tablenav;

   ---------------------------------
   -- Display_Rows_Or_Placeholder --
   ---------------------------------

   procedure Display_Rows_Or_Placeholder (This : in out Wp_List_Table)
   is
      use UStrings;
      use Php;
      use Php.Echoing;
   begin
      if This.Has_Items then
         This.Display_Rows;
      else
         Echo ("<tr class=""no-items""><td class=""colspanchange"" colspan=""" &
               This.Get_Column_Count'Image & """>" & NL);
         This.No_Items;
         Echo ("</td></tr>" & NL);
      end if;
   end Display_Rows_Or_Placeholder;

   ------------------
   -- Display_Rows --
   ------------------

   procedure Display_Rows (This : in out Wp_List_Table)
   is
   begin
      for Item in This.Items.Iterate loop
         This.Single_Row (To_Array ((1 =>
                          Build (Key (Item), As_String (Get (This.Items, Key (Item)))) -- Element (Item))
                          )));
      end loop;
   end Display_Rows;

   ----------------
   -- Single_Row --
   ----------------

   procedure Single_Row (This : in out Wp_List_Table;
                         Item : Array_Type)
   is
      use UStrings;
      use Php;
      use Php.Echoing;
   begin
      Echo ("<tr>" & NL);
      This.Single_Row_Columns (Item);
      Echo ("</tr>" & NL);
   end Single_Row;

   --------------------
   -- Column_Default --
   --------------------

   procedure Column_Default (This        : Wp_List_Table;
                             Item        : Array_Type;
                             Column_Name : String)
   is
   begin
      null;
   end Column_Default;

   ---------------
   -- Column_CB --
   ---------------

   procedure Column_CB (This : Wp_List_Table;
                        Item : Array_Type)
   is
   begin
      null;
   end Column_CB;

   ------------------------
   -- Single_Row_Columns --
   ------------------------

   procedure Single_Row_Columns (This : in out Wp_List_Table;
                                 Item : Array_Type)
   is
      use UStrings;
      use Php;
      use Php.Arrays;
      use Php.Echoing;
      use Inc_Formatting;

      Column_Info : constant Columns_Type := This.Get_Column_Info;

      Columns  : constant Array_Type := Column_Info.Columns; -- Get_Array (Column_Info, "columns");
      Hidden   : constant Array_Type := Column_Info.Hidden; -- Get_Array (Column_Info, "hidden");
--    Sortable : Array_Type := Column_Info.Sortable; -- Get_Array (Column_Info, "sortable");
      Primary  : constant String     := -Column_Info.Primary; -- Get       (Column_Info, "primary");
   begin
      for A in Columns.Iterate loop
         declare
            Column_Name         : constant String := Key (A);
            Column_Display_Name : constant String := As_String (Get (Columns, Column_Name));
            -- Array_Maps.Element (A);

            Classes    : UString := +"column_name column-column_name";
            Data       : UString;
            Attributes : UString;
         begin
            if Primary = Column_Name then
               Append (Classes, " has-row-actions column-primary");
            end if;

            if In_Array (Column_Name, Hidden, True) then
               Append (Classes, " hidden");
            end if;

            -- Comments column uses HTML in the display name with screen reader text.
            -- Strip tags to get closer to a user-friendly string.
            Data :=
              +"data-colname=""" &
              ESC_Attr (Wp_Strip_All_Tags (Column_Display_Name)) & """";

            Attributes := +"class=""" & Classes & """" & Data;

            if "cb" = Column_Name then
               Echo ("<th scope=""row"" class=""check-column"">" & NL);
               This.Column_CB (Item);
               Echo ("</th>" & NL);
            -- elsif Method_Exists (This, "_column_" & Column_Name) then
            --    Echo (Call_User_Func (
            --            To_Array (This, "_column_" & Column_Name),
            --            Item,
            --            Classes,
            --            Data,
            --            Primary
            --         ) & NL);
            elsif True then -- Method_Exists (This, "column_" & Column_Name) then
               Echo ("<td " & (-Attributes) & ">" & NL);
--             Echo (Call_User_Func (To_Array (This, "column_" & Column_Name), Item) & NL);
               Echo (This.Handle_Row_Actions (Item, Column_Name, Primary) & NL);
               Echo ("</td>" & NL);
            else
               Echo ("<td " & (-Attributes) & ">" & NL);
               This.Column_Default (Item, Column_Name);
               Echo (This.Handle_Row_Actions (Item, Column_Name, Primary) & NL);
               Echo ("</td>" & NL);
            end if;
         end;
      end loop;
   end Single_Row_Columns;

   ------------------------
   -- Handle_Row_Actions --
   ------------------------

   function Handle_Row_Actions (This        : Wp_List_Table;
                                Item        : Array_Type;
                                Column_Name : String;
                                Primary     : String)
                                return String
   is
      use Inc_L10n;
   begin
      return
        (if Column_Name = Primary
         then "<button type=""button"" class=""toggle-row""><span class=""screen-reader-text"">" & abs "Show more details" & "</span></button>" else "");
   end Handle_Row_Actions;

--         --
--         -- Handles an incoming ajax request (called from admin-ajax.php)
--         --
--         -- @since 3.1.0
--         --
--         public function ajax_response() then
--                 this.prepare_items();

--                 ob_start();
--                 if ( ! empty( _REQUEST["no_placeholder"] ) ) then
--                         this.display_rows();
--                 end; else then
--                         this.display_rows_or_placeholder();
--                 end;

--                 rows = ob_get_clean();

--                 response = array( "rows" => rows );

--                 if ( isset( this._pagination_args["total_items"] ) ) then
--                         response["total_items_i18n"] = sprintf(
--                                 /* translators: Number of items.--
--                                 _n( "%s item", "%s items", this._pagination_args["total_items"] ),
--                                 number_format_i18n( this._pagination_args["total_items"] )
--                         );
--                 end;
--                 if ( isset( this._pagination_args["total_pages"] ) ) then
--                         response["total_pages"]      = this._pagination_args["total_pages"];
--                         response["total_pages_i18n"] = number_format_i18n( this._pagination_args["total_pages"] );
--                 end;

--                 die( wp_json_encode( response ) );
--         end;

--         --
--         -- Sends required variables to JavaScript land.
--         --
--         -- @since 3.1.0
--         --
--         public function _js_vars() then
--                 args = array(
--                         "class"  => get_class( this ),
--                         "screen" => array(
--                                 "id"   => this.screen.id,
--                                 "base" => this.screen.base,
--                         ),
--                 );

--                 printf( "<script type="text/javascript">list_args = %s;</script>\n", wp_json_encode( args ) );
--         end;
-- end;

end Adi_Class_Wp_List_Tables;
