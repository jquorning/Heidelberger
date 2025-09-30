
--
-- Template WordPress Administration API.
--
-- A Big Mess. Also some neat functions that are nicely written.
--
-- @package WordPress
-- @subpackage Administration
--
with Ada.Containers;
with Ada.Strings.Unbounded;

with Wp_Common;
with Php;

with Inc_Admin_Bar;
with Inc_Capabilities;
with Inc_Class_Wp_Taxonomy;
with Inc_Formatting;
with Inc_Functions;
with Inc_General_Templates;
with Inc_L10n;
with Inc_Options;
with Inc_Plugins;
with Inc_Posts;
with Inc_Taxonomys;
with Inc_Themes;
with Inc_Vars;

package body Adi_Templates
is
   use Ada.Containers;
   use Ada.Strings.Unbounded;
   use Inc_L10n;
   use Php;
   use Wp_Common;
-- -- Walker_Category_Checklist class
-- -- require_once ABSPATH . 'wp-admin/includes/class-walker-category-checklist.php';

-- -- WP_Internal_Pointers class
-- -- require_once ABSPATH . 'wp-admin/includes/class-wp-internal-pointers.php';

--
-- Category Checklists.
--

--
-- Outputs an unordered list of checkbox input elements labeled with category names.
--
-- @since 2.5.1
--
-- @see wp_terms_checklist()
--
-- @param int         $post_id              Optional. Post to generate a categories checklist for. Default 0.
--                                          $selected_cats must not be an array. Default 0.
-- @param int         $descendants_and_self Optional. ID of the category to output along with its descendants.
--                                          Default 0.
-- @param int[]|false $selected_cats        Optional. Array of category IDs to mark as checked. Default false.
-- @param int[]|false $popular_cats         Optional. Array of category IDs to receive the "popular-category" class.
--                                          Default false.
-- @param Walker      $walker               Optional. Walker object to use to build the output.
--                                          Default is a Walker_Category_Checklist instance.
-- @param bool        $checked_ontop        Optional. Whether to move checked items out of the hierarchy and to
--                                          the top of the list. Default true.
--
   procedure Wp_Category_Checklist (Post_Id              : Integer     := 0;
                                    Descendants_And_Self : Integer     := 0;
                                    Selected_Cats        : Array_Type  := Empty_Array;
                                    Popular_Cats         : Array_Type  := Empty_Array;
                                    Walker               : Walker_Type := null;
                                    Checked_Ontop        : Boolean     := True)
   is
      Unused : String := Wp_Terms_Checklist (
                Post_Id,
                To_Array (Assoc_List'(
                        Build ("taxonomy",             "category"),
                        Build ("descendants_and_self", Descendants_And_Self'Image),
--                        Build ("selected_cats",        Selected_Cats),
--                        Build ("popular_cats",         Popular_Cats),
--                        Build ("walker",               Walker),
                        Build ("checked_ontop",        Checked_Ontop'Image)
               ))
       );
   begin
      null;
   end Wp_Category_Checklist;

--
-- Outputs an unordered list of checkbox input elements labelled with term names.
--
-- Taxonomy-independent version of wp_category_checklist().
--
-- @since 3.0.0
-- @since 4.4.0 Introduced the `echo` argument.
--
-- @param int          post_id Optional. Post ID. Default 0.
-- @param array|string args then
--     Optional. Array or string of arguments for generating a terms checklist. Default empty array.
--
--     @type int    descendants_and_self ID of the category to output along with its descendants.
--                                        Default 0.
--     @type int[]  selected_cats        Array of category IDs to mark as checked. Default false.
--     @type int[]  popular_cats         Array of category IDs to receive the "popular-category" class.
--                                        Default false.
--     @type Walker walker               Walker object to use to build the output. Default empty which
--                                        results in a Walker_Category_Checklist instance being used.
--     @type string taxonomy             Taxonomy to generate the checklist for. Default "category".
--     @type bool   checked_ontop        Whether to move checked items out of the hierarchy and to
--                                        the top of the list. Default true.
--     @type bool   echo                 Whether to echo the generated markup. False to return the markup instead
--                                        of echoing it. Default true.
-- end;
-- @return string HTML list of input elements.
--
   function Wp_Terms_Checklist (Post_Id : Integer := 0;
                                Args    : Array_Type) return String
   is
      use Inc_Plugins;

      Output : Unbounded_String;

      Defaults : constant Array_Type := To_Array (Assoc_List'(
                Build ("descendants_and_self", "0"),
                Build ("selected_cats",        "false"),
                Build ("popular_cats",         "false"),
                Build ("walker",               "null"),
                Build ("taxonomy",             "category"),
                Build ("checked_ontop",        "true"),
                Build ("echo",                 "true")
      ));
      --
      -- Filters the taxonomy terms checklist arguments.
      --
      -- @since 3.4.0
      --
      -- @see wp_terms_checklist()
      --
      -- @param array|string args    An array or string of arguments.
      -- @param int          post_id The post ID.
      --
      Params : constant Array_Type := Apply_Filters ("wp_terms_checklist_args",
                                                     Args, Post_Id);

      Parsed_Args : constant Array_Type
         := Inc_Functions.Wp_Parse_Args (Params, Defaults);
   begin
      if
        Empty (Parsed_Args, Key => "walker") -- or else
--           not (Parsed_Args ("walker") in Walker)  -- instanceof
      then
         null;
--                Walker := new Walker_Category_Checklist;
      else
         null;
--                Walker := Parsed_Args ("walker");
      end if;

      declare
         use Inc_Capabilities;
         use Inc_Class_Wp_Taxonomy;
         use Inc_Class_Wp_Terms;
         use Inc_Class_Wp_Terms.Term_Vectors;
         use Inc_Taxonomys;

         Taxonomy             : constant String  := Get (Parsed_Args, "taxonomy");
         Descendants_And_Self : constant Integer
            := Integer'Value (Get (Parsed_Args, "descendants_and_self"));
         Args_2 : Array_Type := To_Array (List => (1 =>
                                   Build ("taxonomy", Taxonomy)));
         Tax        : constant Wp_Taxonomy := Inc_Taxonomys.Get_Taxonomy (Taxonomy);
         Categories : Wp_Term_Array;  -- Array_Type;
      begin
         Set (Args_2, "disabled",
              Boolean'Image (not Current_User_Can (Get (Tax.Cap, "assign_terms"))));

         Set (Args_2, "list_only",
              Boolean'Image (not Empty (Parsed_Args, "list_only")));

         if Is_Array (Get_Array  (Parsed_Args, "selected_cats")) then
            Set (Args_2, "selected_cats",
                 Array_Map ("intval", Get_Array (Parsed_Args, "selected_cats")));
         elsif Post_Id /= 0 then
            null;
--                Set (Args_2, "selected_cats",
--                     Wp_Get_Object_Terms (Empty_Term_Array & Post_Id'Image, Taxonomy,
--                                          Array_Merge (Args, To_array (List => (1 => Build ("fields", "ids"))))));
         else
            Set (Args_2, "selected_cats", Empty_Array);
         end if;

         if Is_Array (Get_Array (Parsed_Args, "popular_cats")) then
            Set (Args_2, "popular_cats",
                 Array_Map ("intval", Get_Array (Parsed_Args, "popular_cats")));
         else
            Set (Args_2, "popular_cats",
                     Get_Terms (
                        To_Array (Assoc_List'(
                                Build ("taxonomy",     Taxonomy),
                                Build ("fields",       "ids"),
                                Build ("orderby",      "count"),
                                Build ("order",        "DESC"),
                                Build ("number",       "10"),
                                Build ("hierarchical", "False")
                       ))
            ));
         end if;

         if Descendants_And_Self /= 0 then
            Categories := Get_Terms (  -- (array)
                        To_Array (Assoc_List'(
                                Build ("taxonomy",     Taxonomy),
                                Build ("child_of",     Descendants_And_Self'Image),
                                Build ("hierarchical", "0"),
                                Build ("hide_empty",   "0")
                       ))
            );
            declare
               Self : constant Wp_Term := Get_Term (Descendants_And_Self, Taxonomy);
            begin
               Array_Unshift (Categories, Self);
            end;
         else
            Categories := Get_Terms ( -- (array)
                        To_Array (Assoc_List'(
                                Build ("taxonomy", Taxonomy),
                                Build ("get",      "all")
                       ))
            );
         end if;

--        Output := "";

         if Exists (Parsed_Args, "checked_ontop") then
            -- Post-process categories rather than adding an exclude to the
            -- get_terms() query
            -- to keep the query the same across all posts (for any query cache).
            declare
               Checked_Categories : Array_Type          := Empty_Array;
               Keys               : constant List_Type  := Array_Keys (Categories);
            begin
               for K of Keys loop
                  if In_Array (Get_Term_Array (Categories, -K).Term_Id,
                               Get_Array (Args_2, "selected_cats"), True)
                  then
                     Checked_Categories := Get_Array (Categories, -K); -- ()
--                   Unset (Categories (K));
                  end if;
               end loop;
            end;
            -- Put checked categories on top.
--          Append (Output, Walker.Walk (Checked_Categories, 0, Args_2));
         end if;
         -- Then the rest of them.
--       Append (Output, Walker.Walk (Categories, 0, Args_2));

         if Exists (Parsed_Args, "echo") then
            Echo (-Output);
         end if;
      end;
      return -Output;
   end Wp_Terms_Checklist;

-- --
-- -- Retrieves a list of the most popular terms from the specified taxonomy.
-- --
-- -- If the `display` argument is true then the elements for a list of checkbox
-- -- `<input>` elements labelled with the names of the selected terms is output.
-- -- If the `post_ID` global is not empty then the terms associated with that
-- -- post will be marked as checked.
-- --
-- -- @since 2.5.0
-- --
-- -- @param string taxonomy     Taxonomy to retrieve terms from.
-- -- @param int    default_term Optional. Not used.
-- -- @param int    number       Optional. Number of terms to retrieve. Default 10.
-- -- @param bool   display      Optional. Whether to display the list as well. Default true.
-- -- @return int[] Array of popular term IDs.
-- --
-- function Hb_Popular_Terms_Checklist (Taxonomy     : String;
--                                      Default_Term : Integer := 0;
--                                      Number       : Integer := 10;
--                                      Display      : Boolean := True)
--                                      return Array_Type
-- is
--         Post : Hb_Post_2 := Get_Post; -- ();
--         Checked_Terms : Array_Type := Empty_Array;
-- begin
-- --        if Post and then Post.ID then
-- --                Checked_Terms := Hb_Get_Object_Terms (Post.ID, Taxonomy, To_array ((Build ("fields", "ids"))));
-- --        else
-- --                Checked_Terms := Empty_Array;
-- --        end if;
-- declare
--         Terms : Array_Type := Get_Terms (
--                 To_Array ((
--                         Build ("taxonomy",     Taxonomy),
--                         Build ("orderby",      "count"),
--                         Build ("order",        "DESC"),
--                         Build ("number",       Integer'Image (Number)),
--                         Build ("hierarchical", "false")
--                ))
--        );

--         Tax : Tax_Rec := Get_Taxonomy (Taxonomy);

--         Popular_Ids : Array_Type := Empty_Array;
-- begin
--         for Term of Terms loop  --  ((array) terms as term) loop
--                 if not display then -- Hack for Ajax use.
--                         goto continue;
--                 end if;
-- declare
--                 Popular_Ids : Integer := Term.Term_Id;  -- ()

--                 Id      : String := "popular-taxonomy-term->term_id";
--                 Checked : String := (if In_Array (Term.Term_Id, Checked_Terms, True)
--                                      then "checked=""checked""" else "");
-- begin
--                 -- ?>

--                 -- <li id="<?php echo id; ?>" class="popular-category">
--                 --         <label class="selectit">
--                 --                 <input id="in-<?php echo id; ?>" type="checkbox" <?php echo checked; ?> value="<?php echo (int) term->term_id; ?>" <?php disabled (! current_user_can (tax->cap->assign_terms)); ?> />
--                 --                 <?php
--                                 -- This filter is documented in wp-includes/category-template.php
--                                 echo (ESC_HTML (Apply_Filters ("the_category", Term.Name, "", "")));
--                 --                 ?>
--                 --         </label>
--                 -- </li>

--                 -- <?php

-- end;
--                 <<Continue>>
--         end loop;
-- end;
--         return Popular_Ids;
-- end Hb_Popular_Terms_Checklist;

-- --
-- -- Outputs a link category checklist element.
-- --
-- -- @since 2.5.1
-- --
-- -- @param int link_id
-- --
-- procedure Hb_Link_Category_Checklist (Link_Id : Integer := 0)
-- is
--         Default : Integer := 1;

--         Checked_Categories : Array_Type := Empty_Array;
-- begin
--         if Link_Id /= 0 then
--                 Checked_Categories := Hb_Get_Link_Cats (Link_Id);
--                 -- No selected categories, strange.
--                 if 0 = Count (Checked_Categories) then
--                         Checked_Categories := Default;  -- []
--                 end if;
--         else
--                 Checked_Categories := Default; -- ()
--         end if;

--         Categories := Get_Terms (
--                 To_Array ((
--                         Build ("taxonomy",   "link_category"),
--                         Build ("orderby",    "name"),
--                         Build ("hide_empty", "0")
--                ))
--        );

--         if Empty (Categories) then
--                 return;
--         end if;

--         for Category of Categories loop
-- declare
--                 Cat_Id : String := Category.Term_Id;

--                 -- This filter is documented in wp-includes/category-template.php
--                 Name    : String := ESC_HTML (Apply_Filters ("the_category", Category.name, "", ""));
--                 Checked : String := (if In_Array (Cat_Id, Checked_Categories, True)
--                             then " checked=""checked""" else "");
-- begin
--                 Echo ("<li id=""link-category-"", cat_id, ""><label for=""in-link-category-" & Cat_Id & """ class=""selectit""><input value=""" & Cat_Id & """ type=""checkbox"" name=""link_category[]"" id=""in-link-category-" & Cat_Id & "" & Checked & "/> " & Name & "</label></li>");
-- end;
--         end loop;
-- end Hb_Link_Category_Checklist;

-- --
-- -- Adds hidden fields with the data for use in the inline editor for posts and pages.
-- --
-- -- @since 2.7.0
-- --
-- -- @param WP_Post post Post object.
-- --
-- procedure Get_Inline_Data (Post : Hb_Post_2)
-- is
--         Title : Unbounded_String;

--         Post_Type_Object : Post_Rec := Get_Post_Type_Object (-Post.Post_Type);
-- begin
--         if not Current_User_Can ("edit_post", -Post.ID) then
--                 return;
--         end if;

--         Title := Esc_Textarea (Trim (-Post.Post_Title));

--         Echo (
--         "<div class=""hidden"" id=""inline_""" & Post.ID & """>"                  &
--         "<div class=""post_title"">" & Title & "</div>"""                         &
--         -- This filter is documented in wp-admin/edit-tag-form.php
--         "<div class=""post_name"">" & Apply_Filters ("editable_slug", Post.Post_Name, Post) & "</div>"""                                                                   &
--         "<div class=""post_author"">" & Post.Post_Author & "</div>"                  &
--         "<div class=""comment_status"">" & ESC_HTML (Post.Comment_Status) & "</div>" &
--         "<div class=""ping_status"">" & ESC_HTML (Post.Ping_Status) & "</div>"    &
--         "<div class=""_status"">" & ESC_HTML (-Post.Post_Status) & "</div>"        &
--         "<div class=""jj"">" & mysql2date ("d", Post.Post_Date, False) & "</div>" &
--         "<div class=""mm"">" & mysql2date ("m", Post.Post_Date, False) & "</div>" &
--         "<div class=""aa"">" & mysql2date ("Y", Post.Post_Date, False) & "</div>" &
--         "<div class=""hh"">" & mysql2date ("H", Post.Post_Date, False) & "</div>" &
--         "<div class=""mn"">" & mysql2date ("i", Post.Post_Date, False) & "</div>" &
--         "<div class=""ss"">" & mysql2date ("s", Post.Post_Date, False) & "</div>" &
--         "<div class=""post_password"">" & ESC_HTML (-Post.Post_Password) & "</div>");

--         if  Post_Type_Object.Hierarchical then
--                 echo ("<div class=""post_parent"">" & (-Post.Post_Parent) & "</div>");
--         end if;

--         echo ("<div class=""page_template"">" &  (if Post.Page_Template /= ""
--                                                   then ESC_HTML (-Post.Page_Template)
--                                                   else "default") & "</div>");

--         if Post_Type_Supports (-Post.Post_Type, "page-attributes") then
--                 echo ("<div class=""menu_order"">" & (-Post.Menu_Order) & "</div>");
--         end if;
-- declare
--         Taxonomy_Names : List_Type := Get_Object_Taxonomies (Post.Post_Type);
-- begin
--         for Taxonomy_Name of Taxonomy_Names loop
-- declare
--                 Taxonomy : Tax_Rec := Get_Taxonomy (-Taxonomy_Name);
-- begin
--                 if not Taxonomy.Show_In_Quick_Edit then
--                         goto Continue_2;
--                 end if;

--                 if Taxonomy.Hierarchical then

--                         Terms := Get_Object_Term_Cache (Post.ID, Taxonomy_Name);
--                         if False = Terms then
--                                 Terms := Hb_Get_Object_Terms (Post.ID, Taxonomy_Name);
--                                 Hb_Cache_Add (Post.ID, Hb_List_Pluck (Terms, "term_id"), Taxonomy_Name & "_relationships");
--                         end if;
--                         Term_Ids := (if Empty (Terms) then Empty_Array else Hb_List_Pluck (Terms, "term_id"));

--                         echo ("<div class=""post_category"" id=""" & (-Taxonomy_Name) & "_" & Post.ID & """>" & Implode (",", Term_Ids) & "</div>");

--                 else

--                         Terms_To_Edit := Get_Terms_To_Edit (Post.ID, Taxonomy_Name);
--                         if not Is_String (Terms_To_Edit) then
--                                 Terms_To_Edit := "";
--                         end if;

--                         Echo ("<div class=""tags_input"" id=""" & (-Taxonomy_Name) &
--                               "_" & (-Post.Id) & """>" &
--                               ESC_HTML (Str_Replace (",", ", ", Terms_To_Edit)) &
--                               "</div>");
--                 end if;
--                 end;
-- <<Continue_2>>
--         end loop;
-- end;
--         if not Post_Type_Object.Hierarchical then
--                 echo ("<div class=""sticky"">" &  (if Is_Sticky (Post.ID) then "sticky" else "") & "</div>");
--         end if;

--         if Post_Type_Supports (-Post.Post_Type, "post-formats") then
--                 echo ("<div class=""post_format"">" & ESC_HTML (Get_Post_Format (Post.ID)) & "</div>");
--         end if;

--         --
--         -- Fires after outputting the fields for the inline editor for posts and pages.
--         --
--         -- @since 4.9.8
--         --
--         -- @param WP_Post      post             The current post object.
--         -- @param WP_Post_Type post_type_object The current Post's post type object.
--         --/
--         do_action ("add_inline_data", post, post_type_object);

--         echo ("</div>");
-- end Get_Inline_Data;

-- --
-- -- Outputs the in-line comment reply-to form in the Comments list table.
-- --
-- -- @since 2.7.0
-- --
-- -- @global WP_List_Table wp_list_table
-- --
-- -- @param int    position
-- -- @param bool   checkbox
-- -- @param string mode
-- -- @param bool   table_row
-- --
-- procedure Hb_Comment_Reply (Position : Integer := 1;
--                            Checkbox  : Boolean := False;
--                            Mode      : String  := "single";
--                            Table_Row : Boolean := True)
-- is
-- --        global wp_list_table;
--         --
--         -- Filters the in-line comment reply-to form output in the Comments
--         -- list table.
--         --
--         -- Returning a non-empty value here will short-circuit display
--         -- of the in-line comment-reply form in the Comments list table,
--         -- echoing the returned value instead.
--         --
--         -- @since 2.7.0
--         --
--         -- @see wp_comment_reply()
--         --
--         -- @param string content The reply-to form content.
--         -- @param array  args    An array of default args.
--         --
--         Content : String := Apply_Filters (
--                 "wp_comment_reply",
--                 "",
--                 To_Array ((
--                         Build ("position", Position),
--                         Build ("checkbox", Checkbox),
--                         Build ("mode",     Mode)
--                ))
--        );
-- begin
--         if not Empty (Content) then
--                 echo (Content);
--                 return;
--         end if;

--         if not Hb_List_Table then
--                 if "single" = Mode then
--                         Hb_List_Table := X_Get_List_Table ("WP_Post_Comments_List_Table");
--                 else
--                         Hb_List_Table := X_Get_List_Table ("WP_Comments_List_Table");
--                 end if;
--         end if;

-- --         ?>
-- -- <form method="get">
-- --         <?php if  (table_row) : ?>
-- -- <table style="display:none;"><tbody id="com-reply"><tr id="replyrow" class="inline-edit-row" style="display:none;"><td colspan="<?php echo wp_list_table->get_column_count(); ?>" class="colspanchange">
-- -- <?php else : ?>
-- -- <div id="com-reply" style="display:none;"><div id="replyrow" style="display:none;">
-- -- <?php endif; ?>
-- --         <fieldset class="comment-reply">
-- --         <legend>
-- --                 <span class="hidden" id="editlegend"><?php _e ("Edit Comment"); ?></span>
-- --                 <span class="hidden" id="replyhead"><?php _e ("Reply to Comment"); ?></span>
-- --                 <span class="hidden" id="addhead"><?php _e ("Add new Comment"); ?></span>
-- --         </legend>

-- --         <div id="replycontainer">
-- --         <label for="replycontent" class="screen-reader-text"><?php _e ("Comment"); ?></label>
-- --         <?php
--         Quicktags_Settings := To_array ((1 =>
--            Build ("buttons", "strong,em,link,block,del,ins,img,ul,ol,li,code,close")));
--         hb_Editor (
--                 "",
--                 "replycontent",
--                 To_Array ((
--                         Build ("media_buttons", False),
--                         Build ("tinymce",       False),
--                         Build ("quicktags",     Quicktags_Settings)
--                ))
--        );
--         -- ?>
--         -- </div>

--         -- <div id="edithead" style="display:none;">
--         --         <div class="inside">
--         --         <label for="author-name"><?php _e ("Name"); ?></label>
--         --         <input type="text" name="newcomment_author" size="50" value="" id="author-name" />
--         --         </div>

--         --         <div class="inside">
--         --         <label for="author-email"><?php _e ("Email"); ?></label>
--         --         <input type="text" name="newcomment_author_email" size="50" value="" id="author-email" />
--         --         </div>

--         --         <div class="inside">
--         --         <label for="author-url"><?php _e ("URL"); ?></label>
--         --         <input type="text" id="author-url" name="newcomment_author_url" class="code" size="103" value="" />
--         --         </div>
--         -- </div>

--         -- <div id="replysubmit" class="submit">
--         --         <p class="reply-submit-buttons">
--         --                 <button type="button" class="save button button-primary">
--         --                         <span id="addbtn" style="display: none;"><?php _e ("Add Comment"); ?></span>
--         --                         <span id="savebtn" style="display: none;"><?php _e ("Update Comment"); ?></span>
--         --                         <span id="replybtn" style="display: none;"><?php _e ("Submit Reply"); ?></span>
--         --                 </button>
--         --                 <button type="button" class="cancel button"><?php _e ("Cancel"); ?></button>
--         --                 <span class="waiting spinner"></span>
--         --         </p>
--         --         <div class="notice notice-error notice-alt inline hidden">
--         --                 <p class="error"></p>
--         --         </div>
--         -- </div>

--         -- <input type="hidden" name="action" id="action" value="" />
--         -- <input type="hidden" name="comment_ID" id="comment_ID" value="" />
--         -- <input type="hidden" name="comment_post_ID" id="comment_post_ID" value="" />
--         -- <input type="hidden" name="status" id="status" value="" />
--         -- <input type="hidden" name="position" id="position" value="<?php echo position; ?>" />
--         -- <input type="hidden" name="checkbox" id="checkbox" value="<?php echo checkbox ? 1 : 0; ?>" />
--         -- <input type="hidden" name="mode" id="mode" value="<?php echo esc_attr (mode); ?>" />
--         -- <?php
--                 Hb_Nonce_Field ("replyto-comment", "_ajax_nonce-replyto-comment", False);
--         if Current_User_Can ("unfiltered_html") then
--                 Hb_Nonce_Field ("unfiltered-html-comment", "_wp_unfiltered_html_comment", False);
--         end if;
-- --         ?>
-- --         </fieldset>
-- --         <?php if  (table_row) : ?>
-- -- </td></tr></tbody></table>
-- --         <?php else : ?>
-- -- </div></div>
-- --         <?php endif; ?>
-- -- </form>
-- --         <?php
-- end Hb_Comment_Reply;

-- --
-- -- Outputs "undo move to Trash" text for comments.
-- --
-- -- @since 2.9.0
-- --/
-- procedure Hb_Comment_Trashnotice is
-- begin
-- --         ?>
-- -- <div class="hidden" id="trash-undo-holder">
-- --         <div class="trash-undo-inside">
-- --                 <?php
-- --                 /* translators: %s: Comment author, filled by Ajax.--/
-- --                 printf (__ ("Comment by %s moved to the Trash."), "<strong></strong>");
-- --                 ?>
-- --                 <span class="undo untrash"><a href="#"><?php _e ("Undo"); ?></a></span>
-- --         </div>
-- -- </div>
-- -- <div class="hidden" id="spam-undo-holder">
-- --         <div class="spam-undo-inside">
-- --                 <?php
--                 -- translators: %s: Comment author, filled by Ajax.
--                 printf (abs "Comment by %s marked as spam.", "<strong></strong>");
-- --                 ?>
-- --                 <span class="undo unspam"><a href="#"><?php _e ("Undo"); ?></a></span>
-- --         </div>
-- -- </div>
-- --         <?php
-- end Hb_Comment_Trashnotice;

-- --
-- -- Outputs a Post's public meta data in the Custom Fields meta box.
-- --
-- -- @since 1.2.0
-- --
-- -- @param array meta
-- --
-- procedure List_Meta (Meta : Array_Type)
-- is
--           Count : Natural := 0;
-- begin
--         -- Exit if no meta.
--         if Is_Empty (Meta) then
--                 Echo (
-- "<table id=""list-table"" style=""display: none;"">"                         &
-- "        <thead>"                                                            &
-- "        <tr>"                                                               &
-- "                <th class=""left"">" & X_X ("Name", "meta name") & "</th>"  &
-- "                <th>" & abs "Value" & "</th>"                               &
-- "        </tr>"                                                              &
-- "        </thead>"                                                           &
-- "        <tbody id=""the-list"" data-wp-lists=""list:meta"">"                &
-- "        <tr><td></td></tr>"                                                 &
-- "        </tbody>"                                                           &
-- "</table>"); -- TBODY needed for list-manipulation JS.
--                 return;
--         end if;
--         Count := 0;
-- --         ?>
-- -- <table id="list-table">
-- --         <thead>
-- --         <tr>
-- --                 <th class="left"><?php _ex ("Name", "meta name"); ?></th>
-- --                 <th><?php _e ("Value"); ?></th>
-- --         </tr>
-- --         </thead>
-- --         <tbody id="the-list" data-wp-lists="list:meta">
-- --         <?php
--         for Entr of Meta loop
--                 Echo (X_List_Meta_Row (Entr, Count));
--         end loop;
-- --        ?>
-- --        </tbody>
-- -- </table>
-- --        <?php
-- end List_Meta;

-- --
-- -- Outputs a single row of public meta data in the Custom Fields meta box.
-- --
-- -- @since 2.5.0
-- --
-- -- @param array entry
-- -- @param int   count
-- -- @return string
-- --/
-- function X_List_Meta_Row (Entr  : Array_Type;
--                           Count : Integer) return String
-- is
--             R : Unbounded_String;
--                           Count_2 : Natural := Count;
-- begin
-- --        static Update_Nonce := "";

--         if Is_Protected_Meta (Get (Entr, "meta_key"), "post") then
--                 return "";
--         end if;

--         if not Update_Nonce then
--                 Update_Nonce := Hb_Create_Nonce ("add-meta");
--         end if;

-- --        R := "";
--         Count := Count + 1;

--         if is_serialized (Entr ("meta_value")) then
--                 if Is_Serialized_String (Entr ("meta_value")) then
--                         -- This is a serialized string, so we should display it.
--                         Set (Entr, "meta_value",
--                              Maybe_Unserialize (Get (Entr, "meta_value")));
--                 else
--                         -- This is a serialized array/object so we should NOT display it.
--                         Count := Count - 1;
--                         return "";
--                 end if;
--         end if;

--         Set (Entr, "meta_key",   Esc_Attr     (Get (Entr, "meta_key")));
--         Set (Entr, "meta_value", Esc_Textarea (Get (Entr, "meta_value"))); -- Using a <textarea />.
--         Set (Entr, "meta_id",    Integer      (Get (Entr, "meta_id")));

--         Delete_Nonce := Hb_Create_Nonce ("delete-meta_" & Get (Entr, "meta_id"));

--         Append (R, "\n\t<tr id=""meta-" & Get (Entr, "meta_id") & ">");
-- --        R := R & "\n\t\t<td class=""left""><label class=""screen-reader-text"" for=""meta-" & Entr ("meta_id") & "-key"">" & abs "Key" & "</label><input name=""" & Meta (Entr ("meta_id") (Key) & " id=""meta-" & Entr ("meta_id") & "-key"" type=""text"" size=""20"" value=""" & Entr ("meta_key") & " />";

-- --        R := R & "\n\t\t<div class=""submit"">";
-- --        R := R & Get_Submit_Button (abs "Delete", "deletemeta small", "deletemeta[thenentry["meta_id"]end;]", false, array ("data-wp-lists" => "delete:the-list:meta-thenentry["meta_id"]end;::_ajax_nonce=delete_nonce"));
-- --        R .= "\n\t\t";
-- --        R .= get_submit_button (__ ("Update"), "updatemeta small", "meta-thenentry["meta_id"]end;-submit", false, array ("data-wp-lists" => "add:the-list:meta-thenentry["meta_id"]end;::_ajax_nonce-add-meta=update_nonce"));
-- --        R .= "</div>";
-- --        R .= wp_nonce_field ("change-meta", "_ajax_nonce", false, false);
--         Append (R, "</td>");

-- --        R := R & "\n\t\t<td><label class=""screen-reader-text"" for=""meta-thenentry["meta_id"]end;-value">" . __ ("Value") . "</label><textarea name="meta[thenentry["meta_id"]end;][value]" id="meta-thenentry["meta_id"]end;-value" rows="2" cols="30">thenentry["meta_value"]end;</textarea></td>\n\t</tr>";
--         return -R;
-- end X_List_Meta_Row;

-- --
-- -- Prints the form in the Custom Fields meta box.
-- --
-- -- @since 1.2.0
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param WP_Post post Optional. The post being edited.
-- --
-- procedure Meta_Form (Post : Hb_Post_2 := null) is
-- --        global wpdb;
--         Post : Integer := Get_Post (Post);

--         --
--         -- Filters values for the meta key dropdown in the Custom Fields meta box.
--         --
--         -- Returning a non-null value will effectively short-circuit and avoid a
--         -- potentially expensive query against postmeta.
--         --
--         -- @since 4.4.0
--         --
--         -- @param array|null keys Pre-defined meta keys to be used in place of a postmeta query. Default null.
--         -- @param WP_Post    post The current post object.
--         --
--         Keys : Integer := Apply_Filters ("postmeta_form_keys", null, Post);
-- begin
--         if null = Keys then
--                 --
--                 -- Filters the number of custom fields to retrieve for the drop-down
--                 -- in the Custom Fields meta box.
--                 --
--                 -- @since 2.1.0
--                 --
--                 -- @param int limit Number of custom fields to retrieve. Default 30.
--                 --
--                 Limit := Apply_Filters ("postmeta_form_limit", 30);

--                 Keys := Wpdb.Get_Col (
--                         Wpdb.Prepare (
--                                 "SELECT DISTINCT meta_key"                      &
--                                 " FROM wpdb->Postmeta"                          &
--                                 " WHERE meta_key NOT BETWEEN ""_"" AND ""_z"""  &
--                                 " HAVING meta_key NOT LIKE %S"                  &
--                                 " ORDER BY meta_key"                            &
--                                 " LIMIT %d"","""                                &
--                                 " Wpdb.esc_like (""_"") . ""%"","               &
--                                 " Limit"
--                        )
--                );
--         end if;

--         if Keys then
--                 Natcasesort (Keys);
--                 Meta_Key_Input_Id := "metakeyselect";
--         else
--                 Meta_Key_Input_Id := "metakeyinput";
--         end if;
-- --         ?>
-- -- <p><strong><?php _e ("Add New Custom Field:"); ?></strong></p>
-- -- <table id="newmeta">
-- -- <thead>
-- -- <tr>
-- -- <th class="left"><label for="<?php echo meta_key_input_id; ?>"><?php _ex ("Name", "meta name"); ?></label></th>
-- -- <th><label for="metavalue"><?php _e ("Value"); ?></label></th>
-- -- </tr>
-- -- </thead>

-- -- <tbody>
-- -- <tr>
-- -- <td id="newmetaleft" class="left">
-- --         <?php if  (keys) then ?>
-- -- <select id="metakeyselect" name="metakeyselect">
-- -- <option value="#NONE#"><?php _e ("&mdash; Select &mdash;"); ?></option>
-- --                 <?php
--                 for Key of Keys loop
--                         if Is_Protected_Meta (Key, "post") or else not Current_User_Can ("add_post_meta", Post.ID, Key) then
--                                 goto continue;
--                         end if;
--                         echo ("\n<option value=""" & Esc_Attr (Key) & """>" & ESC_HTML (Key) & "</option>");
--                 end loop;
-- --                 ?>
-- -- </select>
-- -- <input class="hide-if-js" type="text" id="metakeyinput" name="metakeyinput" value="" />
-- -- <a href="#postcustomstuff" class="hide-if-no-js" onclick="jQuery("#metakeyinput, #metakeyselect, #enternew, #cancelnew").toggle();return false;">
-- -- <span id="enternew"><?php _e ("Enter new"); ?></span>
-- -- <span id="cancelnew" class="hidden"><?php _e ("Cancel"); ?></span></a>
-- -- <?php end; else then ?>
-- -- <input type="text" id="metakeyinput" name="metakeyinput" value="" />
-- -- <?php end; ?>
-- -- </td>
-- -- <td><textarea id="metavalue" name="metavalue" rows="2" cols="25"></textarea></td>
-- -- </tr>

-- -- <tr><td colspan="2">
-- -- <div class="submit">
-- --         <?php
--         Submit_Button (
--                 abs "Add Custom Field",
--                 "",
--                 "addmeta",
--                 False,
--                 To_Array ((
--                         Build ("id",            "newmeta-submit"),
--                         Build ("data-wp-lists", "add:the-list:newmeta")
--                ))
--        );
-- --         ?>
-- -- </div>
-- --         <?php wp_nonce_field ("add-meta", "_ajax_nonce-add-meta", false); ?>
-- -- </td></tr>
-- -- </tbody>
-- -- </table>
-- --         <?php

-- end Meta_Form;

-- --
-- -- Prints out HTML form date elements for editing post or comment publish date.
-- --
-- -- @since 0.71
-- -- @since 4.4.0 Converted to use get_comment() instead of the global `comment`.
-- --
-- -- @global WP_Locale wp_locale WordPress date and time locale object.
-- --
-- -- @param int|bool edit      Accepts 1|true for editing the date, 0|false for adding the date.
-- -- @param int|bool for_post  Accepts 1|true for applying the date to a post, 0|false for a comment.
-- -- @param int      tab_index The tabindex attribute to add. Default 0.
-- -- @param int|bool multi     Optional. Whether the additional fields and buttons should be added.
-- --                            Default 0|false.
-- --
-- procedure Touch_Time (Edit      : Integer := 1;
--                       For_Post  : Integer := 1;
--                       Tab_Index : Integer := 0;
--                       Multi     : Integer := 0)
-- is
-- --        global wp_locale;
--         Post : Integer := Get_Post; -- ();
-- begin

--         if For_Post then
--                 Edit := not (in_array (Post.Post_Status, To_array ("draft", "pending"), True) and then
--                        (not Post.Post_Date_GMT or else "0000-00-00 00:00:00" = Post.Post_Date_Gmt));
--         end if;

--         Tab_Index_Attribute := "";
--         if Tab_Index > 0 then  -- (int)
--                 Tab_Index_Attribute := " tabindex=""tab_index""";  -- \"
--         end if;

--         -- @todo Remove this?
--         -- echo "<label for="timestamp" style="display: block;"><input type="checkbox" class="checkbox" name="edit_date" value="1" id="timestamp"".tab_index_attribute." /> ".__ ("Edit timestamp")."</label><br />";
-- declare
--         Post_Date : Integer :=  (if For_Post then Post.Post_Date else Get_Comment.Comment_Date);
--         jj        : String :=  (if edit then mysql2date ("d", post_date, false)
--                                         else current_time ("d"));
--         mm        : String :=  (if edit then mysql2date ("m", post_date, false)
--                                         else current_time ("m"));
--         aa        : String :=  (if edit then mysql2date ("Y", post_date, false)
--                                         else current_time ("Y"));
--         hh        : String :=  (if edit then mysql2date ("H", post_date, false)
--                                         else current_time ("H"));
--         mn        : String :=  (if edit then mysql2date ("i", post_date, false)
--                                         else current_time ("i"));
--         ss        : String :=  (if edit then mysql2date ("s", post_date, false)
--                                          else current_time ("s"));

--         cur_jj : String := current_time ("d");
--         cur_mm : String := current_time ("m");
--         cur_aa : String := current_time ("Y");
--         cur_hh : String := current_time ("H");
--         cur_mn : String := current_time ("i");

--         Month : String := "<label><span class=""screen-reader-text"">" & abs "Month" & "</span><select class=""form-required"" " &
--                 (if multi then "" else "id=""mm"" ") & "name=""mm""" & Tab_Index_Attribute & ">\n";
-- begin
--         for i in 1 .. 12 loop
--                 Monthnum  := Zeroise (I, 2);
--                 Monthtext := Hb_Locale.Get_Month_Abbrev (Hb_Locale.Get_Month (i));
--                 Month     := Month & "\t\t\t" & "<option value=""" & Monthnum & """ data-text=""" & monthtext & """ """ & Selected (Monthnum, mm, False) & ">";
--                 -- translators: 1: Month number (01, 02, etc.), 2: Month abbreviation.
--                 Month := Month & Sprintf (abs "%1s-%2s", Monthnum, Monthtext) & "</option>\n";
--         end loop;
--         Month := Month & "</select></label>";

--         Day    := "<label><span class=""screen-reader-text"">" & abs "Day" & "</span><input type=""text"" " &  (if Multi then "" else "id=""jj"" ") &
--                   "name=""jj"" value=""" & jj & """ size=""2"" maxlength=""2""" & Tab_Index_Attribute & " autocomplete=""off"" class=""form-required"" /></label>";
--         Year   := "<label><span class=""screen-reader-text"">" & abs "Year" & "</span><input type=""text"" """ & (if Multi then "" else "id=""aa"" ") &
--                   "name=""aa"" value=""" & aa & """ size=""4"" maxlength=""4""" & Tab_Index_Attribute & " autocomplete=""off"" class=""form-required"" /></label>";
--         Hour   := "<label><span class=""screen-reader-text"">" & abs "Hour" & "</span><input type=""text"" """ & (if Multi then "" else "id=""hh"" ") &
--                   "name=""hh"" value=""" & hh & """ size=""2"" maxlength=""2""" & Tab_Index_Attribute & " autocomplete=""off"" class=""form-required"" /></label>";
--         Minute := "<label><span class=""screen-reader-text"">" & abs "Minute" & "</span><input type=""text"" """ & (if Multi then "" else "id=""mn"" ") &
--                   "name=""mn"" value=""" & mn & """ size=""2"" maxlength=""2""" & Tab_Index_Attribute & " autocomplete=""off"" class=""form-required"" /></label>";

--         echo ("<div class=""timestamp-wrap"">");
--         -- translators: 1: Month, 2: Day, 3: Year, 4: Hour, 5: Minute.
--         printf (abs "%1s %2s, %3s at %4s:%5s", month, day, year, hour, minute);

--         echo ("</div><input type=""hidden"" id=""ss"" name=""ss"" value=""""" & ss & " />");

--         if Multi then
--                 return;
--         end if;

--         echo ("\n\n");

--         Map := To_Array ((
--                 Build ("mm", To_Array (mm, cur_mm)),
--                 Build ("jj", To_Array (jj, cur_jj)),
--                 Build ("aa", To_Array (aa, cur_aa)),
--                 Build ("hh", To_Array (hh, cur_hh)),
--                 Build ("mn", To_Array (mn, cur_mn))
--        ));

--         for A of Map loop
--                 Timeunit := A.Key;
--                 Value    := A.Value;

--                 List (unit, curr) := Value;

--                 echo ("<input type=""hidden"" id=""hidden_""" & timeunit & """ name=""hidden_""" & timeunit & """ value=""" & Unit & """ />" & "\n");
--                 Cur_Timeunit := "cur_" & Timeunit;
--                 echo ("<input type=""hidden"" id=""""" & Cur_Timeunit & """ name=""""" & cur_timeunit & """ value=""" & Curr &  """ />" & "\n");
--         end loop;
-- --         ?>

-- -- <p>
-- -- <a href="#edit_timestamp" class="save-timestamp hide-if-no-js button"><?php _e ("OK"); ?></a>
-- -- <a href="#edit_timestamp" class="cancel-timestamp hide-if-no-js button-cancel"><?php _e ("Cancel"); ?></a>
-- -- </p>
-- --         <?php
-- end;
-- end Touch_Time;

-- --
-- -- Prints out option HTML elements for the page templates drop-down.
-- --
-- -- @since 1.5.0
-- -- @since 4.7.0 Added the `post_type` parameter.
-- --
-- -- @param string default_template Optional. The template file name. Default empty.
-- -- @param string post_type        Optional. Post type to get templates for. Default "post".
-- --
-- procedure Page_Template_Dropdown (Default_Template : String := "";
--                                   Post_Type        : String := "page")
-- is
-- begin
--         Templates := Get_Page_Templates (null, Post_Type);

--         Ksort (Templates);

--         for Template of Array_Keys (Templates) loop
--                 Selected := selected (Default_Template, Templates (Template), False);
--                 echo ("\n\t<option value=""" & Esc_Attr (Templates (Template)) & """ selected>" & Esc_Html (Template) & "</option>");
--         end loop;
-- end Page_Template_Dropdown;

-- --
-- -- Prints out option HTML elements for the page parents drop-down.
-- --
-- -- @since 1.5.0
-- -- @since 4.4.0 `post` argument was added.
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param int         default_page Optional. The default page ID to be pre-selected. Default 0.
-- -- @param int         parent_page  Optional. The parent page ID. Default 0.
-- -- @param int         level        Optional. Page depth level. Default 0.
-- -- @param int|WP_Post post         Post ID or WP_Post object.
-- -- @return void|false Void on success, false if the page has no children.
-- --
-- function Parent_Dropdown (Default_Page : Integer := 0;
--                           Parent_Page  : Integer := 0;
--                           Level        : integer := 0;
--                           Post         : Hp_Post_2 := null) return Boolean
-- is
-- begin
-- --        global wpdb;

--         Post  := Get_Post (Post);
--         Items := Wpdb.Get_Results (
--                 Wpdb.Prepare (
--                         "SELECT ID, post_parent, post_title"            &
--                         " FROM wpdb->Posts"                             &
--                         " WHERE post_parent = %d AND post_type = ""page""" &
--                         " ORDER BY menu_order",
--                         Parent_Page
--                )
--        );

--         if Items then
--                 for Item of Items loop
--                         -- A page cannot be its own parent.
--                         if Post and then Post.ID and then Integer (Item.ID = Post.ID) then
--                                 goto continue;
--                         end if;

--                         Pad      := Str_Repeat ("&nbsp;", Level * 3);
--                         Selected := Selected (Default_Page, Item.ID, False);

--                         echo ("\n\t<option class=""level-level"" value=""" & Item.Id & " selected>pad " & Esc_Html (Item.Post_Title) & "</option>");
--                         Parent_Dropdown (Default_Page, Item.ID, Level + 1);
--                 end loop;
--         else
--                 return false;
--         end if;
-- end Parent_Dropdown;

--    --
--    -- Prints out option HTML elements for role selectors.
--    --
--    -- @since 2.1.0
--    --
--    -- @param string selected Slug for the role that should be already selected.
--    --
--    procedure Wp_Dropdown_Roles (Selected : String := "")
--    is
--       R : Unbounded_String;

--       Editable_Roles : Array_Type := Array_Reverse (Get_Editable_Roles);  -- ()
--    begin
--       for A of Editable_Roles loop
--          declare
--             Role    : Key_Type   := A.Key;
--             Details : Value_Type := A.Value;
--             Name    : String     := Translate_User_Role (Details ("name"));
--          begin
--             -- Preselect specified role.
--             if Selected = Role then
--                Append (R, "\n\t<option selected=""selected"" value=""" &
--                           Esc_Attr (Role) & """>name</option>");
--             else
--                Append (R, "\n\t<option value=""" & Esc_Attr (Role) &
--                           """>name</option>");
--             end if;
--          end;
--       end loop;

--       echo (-R);
--    end Hb_Dropdown_Roles;

-- --
-- -- Outputs the form used by the importers to accept the data to be imported.
-- --
-- -- @since 2.0.0
-- --
-- -- @param string action The action attribute for the form.
-- --
-- function Hb_Import_Upload_Form (Action : String) return String
-- is
-- begin
--         --
--         -- Filters the maximum allowed upload size for import files.
--         --
--         -- @since 2.3.0
--         --
--         -- @see wp_max_upload_size()
--         --
--         -- @param int max_upload_size Allowed upload size. Default 1 MB.
--         --
--         Bytes      := Apply_Filters ("import_upload_size_limit", Hb_Max_Upload_Size); -- ());
--         Size       := Size_Format (Bytes);
--         Upload_Dir := Hb_Upload_Dir; -- ();
--         if not Empty (Upload_Dir ("error")) then -- :
-- null;
--                 -- ?>
--                 -- <div class="error"><p><?php _e ("Before you can upload your import file, you will need to fix the following error:"); ?></p>
--                 -- <p><strong><?php echo upload_dir["error"]; ?></strong></p></div>
--                 -- <?php
--         else --:
-- --                 ?>
-- -- <form enctype="multipart/form-data" id="import-upload-form" method="post" class="wp-upload-form" action="<?php echo esc_url (wp_nonce_url (action, "import-upload")); ?>">
-- -- <p>
-- --                 <?php
--                 Printf (
--                         "<label for=""upload"">%s</label> (%s)",
--                         abs "Choose a file from your computer:",
--                         -- translators: %s: Maximum allowed file size.
--                         Sprintf (abs "Maximum size: %s", Size)
--                );
-- --                 ?>
-- -- <input type="file" id="upload" name="import" size="25" />
-- -- <input type="hidden" name="action" value="save" />
-- -- <input type="hidden" name="max_file_size" value="<?php echo bytes; ?>" />
-- -- </p>
-- --                 <?php submit_button (__ ("Upload file and import"), "primary"); ?>
-- -- </form>
-- --                 <?php
--         end if;
-- end Hb_Import_Upload_Form;

-- --
-- -- Adds a meta box to one or more screens.
-- --
-- -- @since 2.5.0
-- -- @since 4.4.0 The `screen` parameter now accepts an array of screen IDs.
-- --
-- -- @global array wp_meta_boxes
-- --
-- -- @param string                 id            Meta box ID (used in the "id" attribute for the meta box).
-- -- @param string                 title         Title of the meta box.
-- -- @param callable               callback      Function that fills the box with the desired content.
-- --                                              The function should echo its output.
-- -- @param string|array|WP_Screen screen        Optional. The screen or screens on which to show the box
-- --                                              (such as a post type, "link", or "comment"). Accepts a single
-- --                                              screen ID, WP_Screen object, or array of screen IDs. Default
-- --                                              is the current screen.  If you have used add_menu_page() or
-- --                                              add_submenu_page() to create a new screen (and hence screen_id),
-- --                                              make sure your menu slug conforms to the limits of sanitize_key()
-- --                                              otherwise the "screen" menu may not correctly render on your page.
-- -- @param string                 context       Optional. The context within the screen where the box
-- --                                              should display. Available contexts vary from screen to
-- --                                              screen. Post edit screen contexts include "normal", "side",
-- --                                              and "advanced". Comments screen contexts include "normal"
-- --                                              and "side". Menus meta boxes (accordion sections) all use
-- --                                              the "side" context. Global default is "advanced".
-- -- @param string                 priority      Optional. The priority within the context where the box should show.
-- --                                              Accepts "high", "core", "default", or "low". Default "default".
-- -- @param array                  callback_args Optional. Data that should be set as the args property
-- --                                              of the box array (which is the second parameter passed
-- --                                              to your callback). Default null.
-- --/
-- procedure Add_Meta_Box (Id : String;
--                         Title : String;
--                         Callback : Callable;
--                         Screen   : Array_type      := null;
--                         Context  : String          := "advanced";
--                         Priority : String          := "default";
--                         Callback_Args : Array_Type := null)
-- is
-- begin
-- --        global wp_meta_boxes;

--         if Empty (Screen) then
--                 Screen := Get_Current_Screen; -- ();
--         elsif Is_String (Screen) then
--                 Screen := Convert_To_Screen (Screen);
--         elsif Is_Array (Screen) then
--                 for Single_Screen of Screen loop
--                         Add_Meta_Box (Id, Title, Callback, Single_Screen, Context, Priority, Callback_Args);
--                 end loop;
--         end if;

--         if not isset (Screen.id) then
--                 return;
--         end if;

--         Page := Screen.Id;

--         if not isset (hb_meta_boxes) then
--                 Hb_Meta_Boxes := Empty_Array;
--         end if;
--         if not isset (Hb_Meta_Boxes (page)) then
--                 Hb_Meta_Boxes (Page) := Empty_Array;
--         end if;
--         if isset (Hb_Meta_Boxes (Page) (context)) then
--                 Hb_Meta_Boxes (Page) (Context) := Empty_Array;
--         end if;

--         for A_Context of Array_Keys (Hb_Meta_Boxes (Page)) loop
--                 for A_Priority of To_array ("high", "core", "default", "low") loop
--                         if not isset (Hb_Meta_Boxes (Page) (A_Context) (A_Priority) (id)) then
--                                 goto Continue_4;
--                         end if;

--                         -- If a core box was previously removed, don't add.
--                         if ("core" = priority or "sorted" = priority)
--                                 and then false = Hb_Meta_Boxes (Page) (A_Context) (A_Priority) (Id)
--                         then
--                                 return;
--                         end if;

--                         -- If a core box was previously added by a plugin, don't add.
--                         if "core" = priority then
--                                 --
--                                 -- If the box was added with default priority, give it core priority
--                                 -- to maintain sort order.
--                                 --
--                                 if "default" = A_Priority then
--                                         Hb_Meta_Boxes (Page) (A_Context) ("core") (Id)
--                                            := Hb_Meta_Boxes (Page) (A_Context) ("default") (Id);
--                                         Unset (Hb_Meta_Boxes (Page) (A_Context) ("default") (Id));
--                                 end if;
--                                 return;
--                         end if;

--                         -- If no priority given and ID already present, use existing priority.
--                         if Empty (Priority) then
--                                 Priority := A_Priority;
--                                 --
--                                 -- Else, if we"re adding to the sorted priority, we don"t know the title
--                                 -- or callback. Grab them from the previously added context/priority.
--                                 --
--                         elsif "sorted" = Priority then
--                                 Title         := Hb_Meta_Boxes (Page) (A_Context) (A_Priority) (Id) ("title");
--                                 Callback      := Hb_Meta_Boxes (Page) (A_Context) (A_Priority) (Id) ("callback");
--                                 Callback_Args := Hb_Meta_Boxes (Page) (A_Context) (A_Priority) (Id) ("args");
--                         end if;

--                         -- An ID can be in only one priority and one context.
--                         if Priority /= A_Priority or else Context /= A_Context then
--                                 Unset (Hb_Meta_Boxes (Page) (A_Context) (A_Priority) (Id));
--                         end if;
--                         << Continue_4 >>
--                 end loop;
--         end loop;

--         if Empty (Priority) then
--                 Priority := "low";
--         end if;

--         if not isset (Hb_Meta_Boxes (Page) (Context) (Priority)) then
--                 Hb_Meta_Boxes (Page) (Context) (Priority) := Empty_Array;
--         end if;

--         Hb_Meta_Boxes (Page) (Context) (Priority) (Id) := To_Array ((
--                 Build ("id",       Id),
--                 Build ("title",    Title),
--                 Build ("callback", Callback),
--                 Build ("args",     Callback_Args)
--        ));
-- end Add_Meta_Box;

-- --
-- -- Renders a "fake" meta box with an information message,
-- -- shown on the block editor, when an incompatible meta box is found.
-- --
-- -- @since 5.0.0
-- --
-- -- @param mixed data_object The data object being rendered on this screen.
-- -- @param array box         {
-- --     Custom formats meta box arguments.
-- --
-- --     @type string   id           Meta box "id" attribute.
-- --     @type string   title        Meta box title.
-- --     @type callable old_callback The original callback for this meta box.
-- --     @type array    args         Extra meta box arguments.
-- -- }
-- --
-- procedure Do_Block_Editor_Incompatible_Meta_Box (Data_Object : Mixed;
--                                                  Box         : Array_Type)
-- is
-- begin
--         Plugin  := X_Get_Plugin_From_Callback (Box ("old_callback"));
--         Plugins := Get_Plugins; -- ();
--         echo ("<p>");
--         if Plugin then
--                 -- translators: %s: The name of the plugin that generated this meta box.
--                 printf (abs "This meta box, from the %s plugin, is not compatible with the block editor.", "<strong>{plugin (""Name"")}</strong>");
--         else
--                 E_E ("This meta box is not compatible with the block editor.");
--         end if;
--         echo ("</p>");

--         if Empty (Plugins ("classic-editor/classic-editor.php")) then
--                 if Current_User_Can ("install_plugins") then
--                         Install_Url := Hb_Nonce_Url (
--                                 Self_Admin_Url ("plugin-install.php?tab=favorites&user=wordpressdotorg&save=0"),
--                                 "save_wporg_username_" & Get_Current_User_Id -- ()
--                        );

--                         echo ("<p>");
--                         -- translators: %s: A link to install the Classic Editor plugin.
--                         printf (abs "Please install the <a href=""%s"">Classic Editor plugin</a> to use this meta box.", ESC_URL (Install_Url));
--                         echo ("</p>");
--                 end if;
--         elsif Is_Plugin_Inactive ("classic-editor/classic-editor.php") then
--                 if Current_User_Can ("activate_plugins") then
--                         Activate_Url := Hb_Nonce_Url (
--                                 Self_Admin_Url ("plugins.php?action=activate&plugin=classic-editor/classic-editor.php"),
--                                 "activate-plugin_classic-editor/classic-editor.php"
--                        );

--                         echo ("<p>");
--                         -- translators: %s: A link to activate the Classic Editor plugin.
--                         printf (abs "Please activate the <a href=""%s"">Classic Editor plugin</a> to use this meta box.", ESC_URL (Activate_Url));
--                         echo ("</p>");
--                 end if;
--         elsif Data_Object in WP_Post then  -- instanceof
--                 Edit_Url := Add_Query_Arg (
--                         To_Array ((
--                                 Build ("classic-editor",         ""),
--                                 Build ("classic-editor__forget", "")
--                        )),
--                         +Get_Edit_Post_Link (Data_Object)
--                );
--                 echo ("<p>");
--                 -- translators: %s: A link to use the Classic Editor plugin.
--                 printf (abs "Please open the <a href=""%s"">classic editor</a> to use this meta box.", ESC_URL (Edit_Url));
--                 echo ("</p>");
--         end if;
-- end Do_Block_Editor_Incompatible_Meta_Box;

-- --
-- -- Internal helper function to find the plugin from a meta box callback.
-- --
-- -- @since 5.0.0
-- --
-- -- @access private
-- --
-- -- @param callable callback The callback function to check.
-- -- @return array|null The plugin that the callback belongs to, or null if it Doesn't belong to a plugin.
-- --
-- function X_Get_Plugin_From_Callback (Callback : Priv) return Array_Type
-- is
-- begin
-- --        try then
--           begin
--                 if Is_Array (Callback) then
--                         Reflection := new ReflectionMethod (Callback (0), Callback (x1));
--                 elsif Is_String (Callback) and then False /= Strpos (Callback, "::") then
--                         Reflection := new ReflectionMethod (Callback);
--                 else
--                         Reflection := new ReflectionFunction (Callback);
--                 end if;
--         exception
--            when ReflectionException =>
--                 -- We could not properly reflect on the callable, so we abort here.
--                 return null;
--         end;

--         -- Don't show an error if it's an internal PHP function.
--         if not Reflection.isInternal then -- ()

--                 -- Only show errors if the meta box was registered by a plugin.
--                 Filename   := Hb_Normalize_Path (Reflection.Getfilename);
--                 Plugin_Dir := Hb_Normalize_Path (HB_PLUGIN_DIR);

--                 if Strpos (Filename, Plugin_Dir) = 0 then
--                         Filename := Str_Replace (Plugin_Dir, "", Filename);
--                         Filename := Preg_Replace ("|^/([^/)*/).*|", "\\1", Filename);

--                         Plugins := Get_Plugins;  -- ();

--                         for A of Plugins loop
--                                 Name   := A.Key;
--                                 Plugin := A.Value;

--                                 if Strpos (Name, Filename) = 0 then
--                                         return Plugin;
--                                 end if;
--                         end loop;
--                 end if;
--         end if;

--         return null;
-- end X_Get_Plugin_From_Callback;

-- --
-- -- Meta-Box template function.
-- --
-- -- @since 2.5.0
-- --
-- -- @global array wp_meta_boxes
-- --
-- -- @param string|WP_Screen screen      The screen identifier. If you have used add_menu_page() or
-- --                                      add_submenu_page() to create a new screen (and hence screen_id)
-- --                                      make sure your menu slug conforms to the limits of sanitize_key()
-- --                                      otherwise the "screen" menu may not correctly render on your page.
-- -- @param string           context     The screen context for which to display meta boxes.
-- -- @param mixed            data_object Gets passed to the meta box callback function as the first parameter.
-- --                                      Often this is the object That's the focus of the current screen,
-- --                                      for example a `WP_Post` or `WP_Comment` object.
-- -- @return int Number of meta_boxes.
-- --
-- function Do_Meta_Boxes (Screen      : String;
--                         Context     : String;
--                         Data_Object : Mixed) return Integer
-- is
--    I : Natural := 0;
-- begin
-- --        global wp_meta_boxes;
-- --        static Already_Sorted := False;

--         if Empty (Screen) then
--                 Screen := Get_Current_Screen;  -- ();
--         elsif Is_String (Screen) then
--                 Screen := Convert_To_Screen (Screen);
--         end if;

--         Page := Screen.Id;

--         Hidden := Get_Hidden_Meta_Boxes (Screen);

--         printf ("<div id=""%s-sortables"" class=""meta-box-sortables"">", Esc_Attr (Context));

--         -- Grab the ones the user has manually sorted.
--         -- Pull them out of their previous context/priority and into the one the user chose.
--         Sorted := Get_User_Option ("meta-box-order_page");

--         if not Already_Sorted and then Sorted then
--                 for A of Sorted loop
--                         Box_Context := A.Key;
--                         Ids         := A.Value;

--                         for Id of Explode (",", Ids) loop
--                                 if Id and then "dashboard_browser_nag" /= Id then
--                                         Add_Meta_Box (Id, null, null, Screen, Box_Context, "sorted");
--                                 end if;
--                         end loop;
--                 end loop;
--         end if;

--         Already_Sorted := True;

--         I := 0;

--         if Isset (Hb_Meta_Boxes (page) (context)) then
--                 for Priority of To_array ("high", "sorted", "core", "default", "low") loop
--                         if Is_set (Hb_Meta_Boxes (page) (context) (priority)) then
--                                 for Box of Hb_Meta_Boxes (page) (Context) (Priority) loop  -- (array)
--                                         if False = Box or else not Box ("title") then
--                                                 goto Continue;
--                                         end if;

--                                         Block_Compatible := True;
--                                         if Is_Array (Box ("args")) then
--                                                 -- If a meta box is just here for back compat, Don't show it in the block editor.
--                                                 if
--                                                   Screen.Is_Block_Editor and then Isset (Box ("args") ("__back_compat_meta_box")) and then
--                                                   Box ("args") ("__back_compat_meta_box")
--                                                 then
--                                                         goto Continue;
--                                                 end if;

--                                                 if isset (Box ("args") ("__block_editor_compatible_meta_box")) then
--                                                         Block_Compatible := Boolean'Value (Box ("args") ("__block_editor_compatible_meta_box"));
--                                                         Unset (Box ("args") ("__block_editor_compatible_meta_box"));
--                                                 end if;

--                                                 -- If the meta box is declared as incompatible with the block editor, override the callback function.
--                                                 if not Block_Compatible and then Screen.Is_Block_Editor then
--                                                         Box ("old_callback") := Box ("callback");
--                                                         Box ("callback")     := "do_block_editor_incompatible_meta_box";
--                                                 end if;

--                                                 if isset (Box ("args") ("__back_compat_meta_box")) then
--                                                         Block_Compatible := Block_Compatible or else Boolean'Value (Box ("args") ("__back_compat_meta_box"));
--                                                         Unset (Box ("args") ("__back_compat_meta_box"));
--                                                 end if;
--                                         end if;

--                                         I := I + 1;
--                                         -- get_hidden_meta_boxes() doesn't apply in the block editor.
--                                         Hidden_Class :=  (if not Screen.Is_Block_Editor and then In_Array (Box ("id"), hidden, true) then " hide-if-js" else "");
--                                         echo ("<div id=""" & Box ("id") & """ class=""postbox " & Postbox_Classes (Box ("id"), Page) & Hidden_Class & """ """ & ">" & "\n");

--                                         echo ("<div class=""postbox-header"">");
--                                         echo ("<h2 class=""hndle"">");
--                                         if "dashboard_php_nag" = Box ("id") then
--                                                 echo ("<span aria-hidden=""true"" class=""dashicons dashicons-warning""></span>");
--                                                 echo ("<span class=""screen-reader-text"">" & abs "Warning:" & " </span>");
--                                         end if;
--                                         echo (Box ("title"));
--                                         echo ("</h2>\n");

--                                         if "dashboard_browser_nag" /= Box ("id") then
--                                                 Widget_Title := Box ("title");

--                                                 if Is_Array (Box ("args")) and then Isset (Box ("args") ("__widget_basename")) then
--                                                         Widget_Title := Box ("args") ("__widget_basename");
--                                                         -- Do not pass this parameter to the user callback function.
--                                                         Unset (Box ("args") ("__widget_basename"));
--                                                 end if;

--                                                 echo ("<div class=""handle-actions hide-if-no-js"">");

--                                                 echo ("<button type=""button"" class=""handle-order-higher"" aria-disabled=""false"" aria-describedby=""" & Box ("id") & "-handle-order-higher-description"">");
--                                                 echo ("<span class=""screen-reader-text"">" & abs "Move up" & "</span>");
--                                                 echo ("<span class=""order-higher-indicator"" aria-hidden=""true""></span>");
--                                                 echo ("</button>");
--                                                 echo ("<span class=""hidden"" id=""""" & Box ("id") & "-handle-order-higher-description"">" & Sprintf (
--                                                         -- translators: %s: Meta box title.
--                                                         abs "Move %s box up",
--                                                         Widget_Title
--                                                ) & "</span>");

--                                                 echo ("<button type=""button"" class=""handle-order-lower"" aria-disabled=""false"" aria-describedby=""""" & Box ("id") & "-handle-order-lower-description"">");
--                                                 echo ("<span class=""screen-reader-text"">" & abs "Move down" & "</span>");
--                                                 echo ("<span class=""order-lower-indicator"" aria-hidden=""true""></span>");
--                                                 echo ("</button>");
--                                                 echo ("<span class=""hidden"" id=""""" & Box ("id") & "-handle-order-lower-description"">" & Sprintf (
--                                                         -- translators: %s: Meta box title.
--                                                         abs "Move %s box down",
--                                                         Widget_Title
--                                                ) & "</span>");

--                                                 echo ("<button type=""button"" class=""handlediv"" aria-expanded=""true"">");
--                                                 echo ("<span class=""screen-reader-text"">" & Sprintf (
--                                                         -- translators: %s: Meta box title.
--                                                         abs "Toggle panel: %s",
--                                                         Widget_Title
--                                                ) & "</span>");
--                                                 echo ("<span class=""toggle-indicator"" aria-hidden=""true""></span>");
--                                                 echo ("</button>");

--                                                 echo ("</div>");
--                                         end if;
--                                         echo ("</div>");

--                                         echo ("<div class=""inside"">" & "\n");

--                                         if
--                                           HB_DEBUG and then
--                                           not Block_Compatible and then
--                                           "edit" = Screen.Parent_Base and then
--                                           not Screen.Is_Block_Editor and then
--                                           not Isset (X_GET ("meta-box-loader"))
--                                         then
--                                                 Plugin := X_Get_Plugin_From_Callback (Box ("callback"));
--                                                 if Plugin then
-- --                                                        ?>
-- --                                                        <div class="error inline">
-- --                                                                <p>
-- --                                                                        <?php
--                                                                                 -- translators: %s: The name of the plugin that generated this meta box.
--                                                                                 printf (abs "This meta box, from the %s plugin, is not compatible with the block editor.", "<strong>" & Plugin ("Name") & "</strong>");
-- --                                                                        ?>
-- --                                                                </p>
-- --                                                        </div>
-- --                                                        <?php
--                                                 end if;
--                                         end if;

--                                         Call_User_Func (Box ("callback"), Data_Object, Box);
--                                         echo ("</div>\n");
--                                         echo ("</div>\n");
--                                 end loop;
--                         end if;
--                 end loop;
--         end if;

--         echo ("</div>");

--         return I;

-- end Do_Meta_Boxes;

-- --
-- -- Removes a meta box from one or more screens.
-- --
-- -- @since 2.6.0
-- -- @since 4.4.0 The `screen` parameter now accepts an array of screen IDs.
-- --
-- -- @global array wp_meta_boxes
-- --
-- -- @param string                 id      Meta box ID (used in the "id" attribute for the meta box).
-- -- @param string|array|WP_Screen screen  The screen or screens on which the meta box is shown (such as a
-- --                                        post type, "link", or "comment"). Accepts a single screen ID,
-- --                                        WP_Screen object, or array of screen IDs.
-- -- @param string                 context The context within the screen where the box is set to display.
-- --                                        Contexts vary from screen to screen. Post edit screen contexts
-- --                                        include "normal", "side", and "advanced". Comments screen contexts
-- --                                        include "normal" and "side". Menus meta boxes (accordion sections)
-- --                                        all use the "side" context.
-- --
-- procedure Remove_Meta_Box (Id      : String;
--                            Screen  : Array_Type;
--                            Context : String)
-- is
-- begin
-- --        global hp_meta_boxes;

--         if Empty (Screen) then
--                 Screen := Get_Current_Screen; -- ();
--         elsif Is_String (Screen) then
--                 Screen := Convert_To_Screen (Screen);
--         elsif Is_Array (Screen) then
--                 for Sinle_Screen of Screen loop
--                         Remove_Meta_Box (Id, Single_Screen, Context);
--                 end loop;
--         end if;

--         if not Isset (Screen.Id) then
--                 return;
--         end if;

--         Page := Screen.Id;

--         if not isset (Hb_Meta_Boxes) then
--                 Hb_Meta_Boxes := Empty_Array;
--         end if;
--         if not isset (Hb_Meta_Boxes (Page)) then
--                 Hb_Meta_Boxes (Page) := Empty_Array;
--         end if;
--         if not Isset (Hb_Meta_Boxes (Page) (Context)) then
--                 Hb_Meta_Boxes (Page) (Context) := Empty_Array;
--         end if;

--         for Priority of To_array ("high", "core", "default", "low") loop
--                 Hb_Meta_Boxes (Page) (Context) (Priority) (Id) := false;
--         end loop;
-- end Remove_Meta_Box;

-- --
-- -- Meta Box Accordion Template Function.
-- --
-- -- Largely made up of abstracted code from do_meta_boxes(), this
-- -- function serves to build meta boxes as list items for display as
-- -- a collapsible accordion.
-- --
-- -- @since 3.6.0
-- --
-- -- @uses global wp_meta_boxes Used to retrieve registered meta boxes.
-- --
-- -- @param string|object screen      The screen identifier.
-- -- @param string        context     The screen context for which to display accordion sections.
-- -- @param mixed         data_object Gets passed to the section callback function as the first parameter.
-- -- @return int Number of meta boxes as accordion sections.
-- --
-- function Do_Accordion_Sections (Screen     : Integer;
--                                Context     : String;
--                                Data_Object : Mixed) return Natural
-- is
-- First_Open : Boolean := False;
-- I : Natural := 0;
-- begin
--         global (Hb_Meta_Boxes);

--         Hb_Enqueue_Script ("accordion");

--         if Empty (Screen) then
--                 Screen := Get_Current_Screen; -- ();
--         elsif Is_String (Screen) then
--                 Screen := Convert_To_Screen (Screen);
--         end if;

--         Page := Screen.Id;

--         Hidden := Get_Hidden_Meta_Boxes (Screen);
-- --        ?>
-- --        <div id="side-sortables" class="accordion-container">
-- --                <ul class="outer-border">
-- --        <?php

-- --        I          := 0;
-- --        First_Open := False;

--         if isset (Hb_Meta_Boxes (page) (context)) then
--                 for Priority of To_array ("high", "core", "default", "low") loop
--                         if Isset (Hb_Meta_Boxes (Page) (Context) (Priority)) then
--                                 for Box of Hp_Meta_Boxes (Page) (Context) (Priority) loop
--                                         if False = Box or else not Box ("title") then
--                                                goto Continue;
--                                         end if;

--                                         I := I + 1;
--                                         Hidden_Class := (if In_Array (Box ("id"), Hidden, True) then "hide-if-js" else "");

--                                         Open_Class := "";
--                                         if not First_Open and then Empty (Hidden_Class) then
--                                                 First_Open := True;
--                                                 Open_Class := "open";
--                                         end if;
--                                         -- ?>
--                                         -- <li class="control-section accordion-section <?php echo hidden_class; ?> <?php echo open_class; ?> <?php echo esc_attr (box["id")); ?>" id="<?php echo esc_attr (box["id")); ?>">
--                                         --         <h3 class="accordion-section-title hndle" tabindex="0">
--                                         --                 <?php echo esc_html (box["title")); ?>
--                                         --                 <span class="screen-reader-text"><?php _e ("Press return or enter to open this section"); ?></span>
--                                         --         </h3>
--                                         --         <div class="accordion-section-content <?php postbox_classes (box["id"), page); ?>">
--                                         --                 <div class="inside">
--                                         --                         <?php call_user_func (box["callback"), data_object, box); ?>
--                                         --                 </div><!-- .inside -->
--                                         --         </div><!-- .accordion-section-content -->
--                                         -- </li><!-- .accordion-section -->
--                                         -- <?php
--                                 end loop;
--                         end if;
--                 end loop;
--         end if;
-- --        ?>
-- --                </ul><!-- .outer-border -->
-- --        </div><!-- .accordion-container -->
-- --        <?php
--         return I;
-- end Do_Accordion_Sections;

-- --
-- -- Adds a new section to a settings page.
-- --
-- -- Part of the Settings API. Use this to define new settings sections for an admin page.
-- -- Show settings sections in your admin page callback function with do_settings_sections().
-- -- Add settings fields to your section with add_settings_field().
-- --
-- -- The callback argument should be the name of a function that echoes out any
-- -- content you want to show at the top of the settings section before the actual
-- -- fields. It can output nothing if you want.
-- --
-- -- @since 2.7.0
-- -- @since 6.1.0 Added an `args` parameter for the section's HTML wrapper and class name.
-- --
-- -- @global array wp_settings_sections Storage array of all settings sections added to admin pages.
-- --
-- -- @param string   id       Slug-name to identify the section. Used in the "id" attribute of tags.
-- -- @param string   title    Formatted title of the section. Shown as the heading for the section.
-- -- @param callable callback Function that echos out any content at the top of the section (between heading and fields).
-- -- @param string   page     The slug-name of the settings page on which to show the section. Built-in pages include
-- --                           "general", "reading", "writing", "discussion", "media", etc. Create your own using
-- --                           add_options_page();
-- -- @param array    args     {
-- --     Arguments used to create the settings section.
-- --
-- --     @type string before_section HTML content to prepend to the Section's HTML output.
-- --                                  Receives the section's class name as `%s`. Default empty.
-- --     @type string after_section  HTML content to append to the section's HTML output. Default empty.
-- --     @type string section_class  The class name to use for the section. Default empty.
-- -- }
-- --
-- procedure Add_Settings_Section (Id       : String;
--                                 Title    : String;
--                                 Callback : Callable;
--                                 Page     : String;
--                                 Args     : Array_Type := Empty_Array)
-- is
-- begin
--         global (Hb_Settings_Sections);

--         Defaults := To_Array ((
--                 Build ("id",             Id),
--                 Build ("title",          Title),
--                 Build ("callback",       Callback),
--                 Build ("before_section", ""),
--                 Build ("after_section",  ""),
--                 Build ("section_class",  "")
--        ));

--         Section := Hb_Parse_Args (Args, Defaults);

--         if "misc" = Page then
--                 X_Deprecated_Argument (
--                         X_FUNCTION_X,
--                         "3.0.0",
--                         Sprintf (
--                                 -- translators: %s: misc
--                                 abs "The ""%s"" options group has been removed. Use another settings group.",
--                                 "misc"
--                        )
--                );
--                 Page := "general";
--         end if;

--         if "privacy" = Page then
--                 X_Deprecated_Argument (
--                         X_FUNCTION_X,
--                         "3.5.0",
--                         Sprintf (
--                                 -- translators: %s: privacy
--                                 abs "The ""%s"" options group has been removed. Use another settings group.",
--                                 "privacy"
--                        )
--                );
--                 Page := "reading";
--         end if;

--         Hp_Settings_Sections (Page) (Id) := Section;
-- end Add_Settings_Section;

-- --
-- -- Adds a new field to a section of a settings page.
-- --
-- -- Part of the Settings API. Use this to define a settings field that will show
-- -- as part of a settings section inside a settings page. The fields are shown using
-- -- do_settings_fields() in do_settings_sections().
-- --
-- -- The callback argument should be the name of a function that echoes out the
-- -- HTML input tags for this setting field. Use get_option() to retrieve existing
-- -- values to show.
-- --
-- -- @since 2.7.0
-- -- @since 4.2.0 The `class` argument was added.
-- --
-- -- @global array wp_settings_fields Storage array of settings fields and info about their pages/sections.
-- --
-- -- @param string   id       Slug-name to identify the field. Used in the "id" attribute of tags.
-- -- @param string   title    Formatted title of the field. Shown as the label for the field
-- --                           during output.
-- -- @param callable callback Function that fills the field with the desired form inputs. The
-- --                           function should echo its output.
-- -- @param string   page     The slug-name of the settings page on which to show the section
-- --                           (general, reading, writing, ...).
-- -- @param string   section  Optional. The slug-name of the section of the settings page
-- --                           in which to show the box. Default "default".
-- -- @param array    args then
-- --     Optional. Extra arguments that get passed to the callback function.
-- --
-- --     @type string label_for When supplied, the setting title will be wrapped
-- --                             in a `<label>` element, its `for` attribute populated
-- --                             with this value.
-- --     @type string class     CSS Class to be added to the `<tr>` element when the
-- --                             field is output.
-- -- end;
-- --
-- procedure Add_Settings_Field (Id      : String;
--                              Title    : String;
--                              Callback : Callable;
--                              Page     : String;
--                              Section  : String     := "default";
--                              Args     : Array_Type := Empty_Array)
-- is
-- begin
--         global (Hp_Settings_Fields);

--         if "misc" = Page then
--                 X_Deprecated_Argument (
--                         X_FUNCTION_X,
--                         "3.0.0",
--                         Sprintf (
--                                 -- translators: %s: misc--
--                                 abs "The ""%s"" options group has been removed. Use another settings group.",
--                                 "misc"
--                        )
--                );
--                 Page := "general";
--         end if;

--         if "privacy" = Page then
--                 X_Deprecated_Argument (
--                         X_FUNCTION_X,
--                         "3.5.0",
--                         Sprintf (
--                                 -- translators: %s: privacy
--                                 abs "The ""%s"" options group has been removed. Use another settings group.",
--                                 "privacy"
--                        )
--                );
--                 Page := "reading";
--         end if;

--         Wp_settings_fields (Page) (Section) (Id) := To_Array ((
--                 Build ("id",       Id),
--                 Build ("title",    Title),
--                 Build ("callback", Callback),
--                 Build ("args",     Args)
--        ));
-- end Add_Settings_Field;

-- --
-- -- Prints out all settings sections added to a particular settings page.
-- --
-- -- Part of the Settings API. Use this in a settings page callback function
-- -- to output all the sections and fields that were added to that page with
-- -- add_settings_section() and add_settings_field()
-- --
-- -- @global array wp_settings_sections Storage array of all settings sections added to admin pages.
-- -- @global array wp_settings_fields Storage array of settings fields and info about their pages/sections.
-- -- @since 2.7.0
-- --
-- -- @param string page The slug name of the page whose settings sections you want to output.
-- --
-- procedure Do_Settings_Sections (Page : String)
-- is
-- begin
--         global (Hb_Settings_Sections, Hb_Settings_Fields);

--         if not Isset (Hb_Settings_Sections (page)) then
--                 return;
--         end if;

--         for Section of Hb_Settings_Sections (Page) loop  --  (array)
--                 if "" /= Section ("before_section") then
--                         if  "" /= Section ("section_class") then
--                                 echo (Wp_Kses_Post (sprintf (Section ("before_section"), esc_attr (Section ("section_class")))));
--                         else
--                                 echo (Wp_Kses_Post (Section ("before_section")));
--                         end if;
--                 end if;

--                 if Section ("title") then
--                         echo ("<h2>" & Section ("title") & "</h2>\n");
--                 end if;

--                 if Section ("callback") then
--                         Call_User_Func (Section ("callback"), Section);
--                 end if;

--                 if
--                   not Isset (Hb_Settings_Fields) or else
--                   not Isset (Hb_Settings_Fields (Page)) or else
--                   not isset (Hb_Settings_Fields (Page) (Section ("id")))
--                 then
--                         goto Continue;
--                 end if;
--                 echo ("<table class=""form-table"" role=""presentation"">");
--                 Do_Settings_Fields (Page, Section ("id"));
--                 echo ("</table>");

--                 if "" /= Section ("after_section") then
--                         echo (hb_Kses_Post (Section ("after_section")));
--                 end if;
--         end loop;
-- end Do_Settings_Sections;

-- --
-- -- Prints out the settings fields for a particular settings section.
-- --
-- -- Part of the Settings API. Use this in a settings page to output
-- -- a specific section. Should normally be called by do_settings_sections()
-- -- rather than directly.
-- --
-- -- @global array wp_settings_fields Storage array of settings fields and their pages/sections.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string page Slug title of the admin page whose settings fields you want to show.
-- -- @param string section Slug title of the settings section whose fields you want to show.
-- --
-- procedure Do_Settings_Fields (Page    : String;
--                               Section : String)
-- is
-- begin
--         global (Hb_Settings_Fields);

--         if not Isset (Hb_Settings_Fields (Page) (Section)) then
--                 return;
--         end if;

--         for Field of Hb_Settings_Fields (Page) (Section) loop
--                 Class := "";

--                 if not Empty (Field ("args") ("class")) then
--                         Class := " class=""" & Esc_Attr (Field ("args") ("class")) & """";
--                 end if;

--                 echo ("<tr" & Class & ">");

--                 if not Empty (Field ("args") ("label_for")) then
--                         Echo ("<th scope=""row""><label for=""" &
--                               Esc_Attr (Field ("args") ("label_for")) & """>" &
--                               Field ("title") & "</label></th>");
--                 else
--                         Echo ("<th scope=""row"">" & Field ("title") & "</th>");
--                 end if;

--                 echo ("<td>");
--                 Call_User_Func (Field ("callback"), Field ("args"));
--                 echo ("</td>");
--                 echo ("</tr>");
--         end loop;
-- end Do_Settings_Fields;

-- --
-- -- Registers a settings error to be displayed to the user.
-- --
-- -- Part of the Settings API. Use this to show messages to users about settings validation
-- -- problems, missing settings or anything else.
-- --
-- -- Settings errors should be added inside the sanitize_callback function defined in
-- -- register_setting() for a given setting to give feedback about the submission.
-- --
-- -- By default messages will show immediately after the submission that generated the error.
-- -- Additional calls to settings_errors() can be used to show errors even when the settings
-- -- page is first accessed.
-- --
-- -- @since 3.0.0
-- -- @since 5.3.0 Added `warning` and `info` as possible values for `type`.
-- --
-- -- @global array[) wp_settings_errors Storage array of errors registered during this pageload
-- --
-- -- @param string setting Slug title of the setting to which this error applies.
-- -- @param string code    Slug-name to identify the error. Used as part of "id" attribute in HTML output.
-- -- @param string message The formatted message text to display to the user (will be shown inside styled
-- --                        `<div>` and `<p>` tags).
-- -- @param string type    Optional. Message type, controls HTML class. Possible values include "error",
-- --                        "success", "warning", "info". Default "error".
-- --
-- procedure Add_Settings_Error (Setting : String;
--                               Code    : String;
--                               Message : String;
--                               Typ     : String := "error")
-- is
-- begin
--         global (Hb_Settings_Errors);

--         hb_Settings_Errors := To_Array ((  -- ()
--                 Build ("setting", Setting),
--                 Build ("code",    Code),
--                 Build ("message", Message),
--                 Build ("type",    Typ)
--        ));
-- end Add_Settings_Error;

-- --
-- -- Fetches settings errors registered by add_settings_error().
-- --
-- -- Checks the wp_settings_errors array for any errors declared during the current
-- -- pageload and returns them.
-- --
-- -- If changes were just submitted (_GET["settings-updated")) and settings errors were saved
-- -- to the "settings_errors" transient then those errors will be returned instead. This
-- -- is used to pass errors back across pageloads.
-- --
-- -- Use the sanitize argument to manually re-sanitize the option before returning errors.
-- -- This is useful if you have errors or notices you want to show even when the user
-- -- hasn't submitted data (i.e. when they first load an options page, or in the {@see "admin_notices"}
-- -- action hook).
-- --
-- -- @since 3.0.0
-- --
-- -- @global array[) wp_settings_errors Storage array of errors registered during this pageload
-- --
-- -- @param string setting  Optional. Slug title of a specific setting whose errors you want.
-- -- @param bool   sanitize Optional. Whether to re-sanitize the setting value before returning errors.
-- -- @return array then
-- --     Array of settings errors.
-- --
-- --     @type string setting Slug title of the setting to which this error applies.
-- --     @type string code    Slug-name to identify the error. Used as part of "id" attribute in HTML output.
-- --     @type string message The formatted message text to display to the user (will be shown inside styled
-- --                           `<div>` and `<p>` tags).
-- --     @type string type    Optional. Message type, controls HTML class. Possible values include "error",
-- --                           "success", "warning", "info". Default "error".
-- -- end;
-- --/
-- function Get_Settings_Errors (Setting  : String  := "";
--                               Sanitize : Boolean := False) return Array_Type
-- is
-- begin
--         global (Hb_Settings_Errors);

--         --
--         -- If sanitize is true, manually re-run the sanitization for this option
--         -- This allows the sanitize_callback from register_setting() to run, adding
--         -- any settings errors you want to show by default.
--         --
--         if Sanitize then
--                 Sanitize_Option (Setting, Get_Option (Setting));
--         end if;

--         -- If settings were passed back from options.php then use them.
--         if isset (X_GET ("settings-updated")) and then X_GET ("settings-updated") and then Get_Transient ("settings_errors") then
--                 Hb_Settings_Errors := Array_Merge (Hb_Settings_Errors, Get_Transient ("settings_errors"));
--                 Delete_Transient ("settings_errors");
--         end if;

--         -- Check global in case errors have been added on this pageload.
--         if empty (hb_settings_errors) then
--                 return Empty_Array;
--         end if;

--         -- Filter the results to those of a specific setting if one was set.
--         if Setting then
--                 Setting_Errors := Empty_Array;

--                 for A of Hb_Settings_Errors loop
--                         Key     := A.Key;
--                         Details := A.Value;

--                         if Setting = Details ("setting") then
--                                 Setting_Errors := hb_settings_errors (Key); -- ()
--                         end if;
--                 end loop;

--                 return Setting_Errors;
--         end if;

--         return Hb_Settings_Errors;
-- end Get_Settings_Errors;

--    --
--    -- Displays settings errors registered by add_settings_error().
--    --
--    -- Part of the Settings API. Outputs a div for each error retrieved by
--    -- get_settings_errors().
--    --
--    -- This is called automatically after a settings page based on the
--    -- Settings API is submitted. Errors should be added during the validation
--    -- callback function for a setting defined in register_setting().
--    --
--    -- The sanitize option is passed into get_settings_errors() and will
--    -- re-run the setting sanitization
--    -- on its current value.
--    --
--    -- The hide_on_update option will cause errors to only show when the settings
--    -- page is first loaded. if the user has already saved new values it will be
--    -- hidden to avoid repeating messages already shown in the default error
--    -- reporting after submission. This is useful to show general errors like
--    -- missing settings when the user arrives at the settings page.
--    --
--    -- @since 3.0.0
--    -- @since 5.3.0 Legacy `error` and `updated` CSS classes are mapped to
--    --              `notice-error` and `notice-success`.
--    --
--    -- @param string setting        Optional slug title of a specific setting whose errors you want.
--    -- @param bool   sanitize       Whether to re-sanitize the setting value before returning errors.
--    -- @param bool   hide_on_update If set to true errors will not be shown if the settings page has
--    --                               already been submitted.
--    --
--    procedure Settings_Errors (Setting        : String  := "";
--                               Sanitize       : Boolean := False;
--                               Hide_On_Update : Boolean := False)
--    is
--       Output : Unbounded_String;

--       Settings_Errors : Array_Type;
--    begin
--       if Hide_On_Update and then not Empty (X_GET ("settings-updated")) then
--          return;
--       end if;

--       Settings_Errors := Get_Settings_Errors (Setting, Sanitize);

--       if Empty (Settings_Errors) then
--          return;
--       end if;

--       for A of Settings_Errors loop
--          declare
--              Key     : Key_Type   := A.Key;
--              Details : Value_Type := A.Value;
--          begin
--            if "updated" = Details ("type") then
--               Details ("type") := "success";
--            end if;

--             if In_Array (Details ("type"), To_array ("error", "success", "warning", "info"), True) then
--                Details ("type") := "notice-" & Details ("type");
--             end if;

--             Css_Id    := Sprintf (
--                         "setting-error-%s",
--                         Esc_Attr (Details ("code"))
--                 );
--             Css_Class := Sprintf (
--                         "notice %s settings-error is-dismissible",
--                         Esc_Attr (Details ("type"))
--                );

--             Append (Output, "<div id=""css_id"" class=""css_class""> \n");
--             Append (Output, "<p><strong>{details (""message"")}</strong></p>");
--             Append (Output, "</div> \n");
--          end;
--       end loop;

--       echo (-Output);
--    end Settings_Errors;

-- --
-- -- Outputs the modal window used for attaching media to posts or pages in the media-listing screen.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string found_action
-- --
-- procedure Find_Posts_Div (Found_Action : String := "")
-- is
-- begin
--    null;
--         -- ?>
--         -- <div id="find-posts" class="find-box" style="display: none;">
--         --         <div id="find-posts-head" class="find-box-head">
--         --                 <?php _e ("Attach to existing content"); ?>
--         --                 <button type="button" id="find-posts-close"><span class="screen-reader-text"><?php _e ("Close media attachment panel"); ?></span></button>
--         --         </div>
--         --         <div class="find-box-inside">
--         --                 <div class="find-box-search">
--         --                         <?php if  (found_action) then ?>
--         --                                 <input type="hidden" name="found_action" value="<?php echo esc_attr (found_action); ?>" />
--         --                         <?php end; ?>
--         --                         <input type="hidden" name="affected" id="affected" value="" />
--         --                         <?php wp_nonce_field ("find-posts", "_ajax_nonce", false); ?>
--         --                         <label class="screen-reader-text" for="find-posts-input"><?php _e ("Search"); ?></label>
--         --                         <input type="text" id="find-posts-input" name="ps" value="" />
--         --                         <span class="spinner"></span>
--         --                         <input type="button" id="find-posts-search" value="<?php esc_attr_e ("Search"); ?>" class="button" />
--         --                         <div class="clear"></div>
--         --                 </div>
--         --                 <div id="find-posts-response"></div>
--         --         </div>
--         --         <div class="find-box-buttons">
--         --                 <?php submit_button (__ ("Select"), "primary alignright", "find-posts-submit", false); ?>
--         --                 <div class="clear"></div>
--         --         </div>
--         -- </div>
--         -- <?php
-- end Find_Posts_Div;

--    --
--    -- Displays the post password.
--    --
--    -- The password is passed through esc_attr() to ensure that it is safe for
--    -- placing in an HTML attribute.
--    --
--    -- @since 2.7.0
--    --
--    procedure The_Post_Password
--    is
--       Post : Post_Rec := Get_Post; -- ();
--    begin
--       if Isset (Post.Post_Password) then
--          Echo (Esc_Attr (Post.Post_Password));
--       end if;
--    end The_Post_Password;

--    --
--    -- Gets the post title.
--    --
--    -- The post title is fetched and if it is blank then a default string is
--    -- returned.
--    --
--    -- @since 2.7.0
--    --
--    -- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is
--    --                         global post.
--    -- @return string The post title if set.
--    --
--    function X_Draft_Or_Post_Title (Post : Integer := 0) return String
--    is
--       Title : Unbounded_String := +Get_The_Title (Post);
--    begin
--       if Empty (Title) then
--          Title := +abs "(no title)";
--       end if;
--       return ESC_HTML (-Title);
--    end X_Draft_Or_Post_Title;

-- --
-- -- Displays the search query.
-- --
-- -- A simple wrapper to display the "s" parameter in a `GET` URI. This function
-- -- should only be used when the_search_query() cannot.
-- --
-- -- @since 2.7.0
-- --/
-- procedure X_Admin_Search_Query
-- is
-- begin
--         Echo (if Isset (X_REQUEST ("s")) then Esc_Attr (Hb_Unslash (X_REQUEST ("s"))) else "");
-- end X_Admin_Search_Query;

-- --
-- -- Generic Iframe header for use with Thickbox.
-- --
-- -- @since 2.7.0
-- --
-- -- @global string    hook_suffix
-- -- @global string    admin_body_class
-- -- @global WP_Locale wp_locale        WordPress date and time locale object.
-- --
-- -- @param string title      Optional. Title of the Iframe page. Default empty.
-- -- @param bool   deprecated Not used.
-- --
-- procedure Iframe_Header (Title      : String  := "";
--                          Deprecated : Boolean := false)
-- is
-- begin
--         Show_Admin_Bar (False);
--         global (Hook_Suffix, Admin_Body_Class, Hb_Locale);
--         Admin_Body_Class := Preg_Replace ("/[^a-z0-9_-)+/i", "-", Hook_Suffix);

--         Current_Screen := Get_Current_Screen; -- ();

--         Header ("Content-Type: " & Get_Option ("html_type") & "; charset=" & Get_Option ("blog_charset"));
--         X_Hb_Admin_Html_Begin; -- ();
-- --        ?>
-- -- <title><?php bloginfo ("name"); ?> &rsaquo; <?php echo title; ?> &#8212; <?php _e ("WordPress"); ?></title>
-- --        <?php
--         Hb_Enqueue_Style ("colors");
-- --        ?>
-- -- <script type="text/javascript">
-- -- addLoadEvent = function(func)thenif(typeof jQuery!=="undefined")jQuery(function()thenfunc();end;);else if(typeof wpOnload!=="function")thenwpOnload=func;end;elsethenvar oldonload=wpOnload;wpOnload=function()thenoldonload();func();end;end;end;;
-- -- function tb_close()thenvar win=window.dialogArguments||opener||parent||top;win.tb_remove();end;
-- -- var ajaxurl = "<?php echo esc_js (admin_url ("admin-ajax.php", "relative")); ?>",
-- --        pagenow = "<?php echo esc_js (current_screen->id); ?>",
-- --        typenow = "<?php echo esc_js (current_screen->post_type); ?>",
-- --        adminpage = "<?php echo esc_js (admin_body_class); ?>",
-- --        thousandsSeparator = "<?php echo esc_js (wp_locale->number_format["thousands_sep")); ?>",
-- --        decimalPoint = "<?php echo esc_js (wp_locale->number_format["decimal_point")); ?>",
-- --        isRtl = <?php echo (int) is_rtl(); ?>;
-- -- </script>
-- --        <?php
--         -- This action is documented in wp-admin/admin-header.php
--         Do_Action ("admin_enqueue_scripts", Hook_Suffix);

--         -- This action is documented in wp-admin/admin-header.php
--         Do_Action ("admin_print_styles-{hook_suffix}");
--         -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

--         -- This action is documented in wp-admin/admin-header.php
--         Do_Action ("admin_print_styles");

--         -- This action is documented in wp-admin/admin-header.php
--         Do_Action ("admin_print_scripts-{hook_suffix}");
--         -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

--         -- This action is documented in wp-admin/admin-header.php
--         Do_Action ("admin_print_scripts");

--         -- This action is documented in wp-admin/admin-header.php
--         Do_Action ("admin_head-{hook_suffix}");
--         -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

--         -- This action is documented in wp-admin/admin-header.php
--         Do_Action ("admin_head");

--         Admin_Body_Class := Admin_Body_Class & " locale-" & Sanitize_Html_Class (Strtolower (Str_Replace ("_", "-", Get_User_Locale)));

--         if Is_Rtl then -- ()
--                 Admin_Body_Class := Admin_Body_Class & " rtl";
--         end if;

-- --        ?>
-- -- </head>
-- --        <?php
--         --
--         -- @global string body_id
--         --
--         Admin_Body_Id := (if Isset (GLOBALS ("body_id")) then "id=""" & GLOBALS ("body_id") & """ " else "");

--         -- This filter is documented in wp-admin/admin-header.php
--         Admin_Body_Classes := Apply_Filters ("admin_body_class", "");
--         Admin_Body_Classes := Ltrim (Admin_Body_Classes & " " & Admin_Body_Class);
-- --        ?>
-- -- <body <?php echo admin_body_id; ?>class="wp-admin wp-core-ui no-js iframe <?php echo admin_body_classes; ?>">
-- -- <script type="text/javascript">
-- -- (function()then
-- -- var c = document.body.className;
-- -- c = c.replace(/no-js/, "js");
-- -- document.body.className = c;
-- -- end;)();
-- -- </script>
-- --        <?php
-- end Iframe_Header;

-- --
-- -- Generic Iframe footer for use with Thickbox.
-- --
-- -- @since 2.7.0
-- --
-- procedure Iframe_Footer
-- is
-- begin
--         --
--         -- We're going to hide any footer output on iFrame pages,
--         -- but run the hooks anyway since they output JavaScript
--         -- or other needed content.
--         --

--         --
--         -- @global string hook_suffix
--         --
--         global (Hook_Suffix);
-- --        ?>
-- --        <div class="hidden">
-- --        <?php
--         -- This action is documented in wp-admin/admin-footer.php
--         Do_Action ("admin_footer", Hook_Suffix);

--         -- This action is documented in wp-admin/admin-footer.php
--         Do_Action ("admin_print_footer_scripts-{hook_suffix}");
--         -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

--         -- This action is documented in wp-admin/admin-footer.php
--         Do_Action ("admin_print_footer_scripts");
-- --        ?>
-- --        </div>
-- -- <script type="text/javascript">if(typeof wpOnload==="function")wpOnload();</script>
-- -- </body>
-- -- </html>
-- --        <?php
-- end Iframe_Footer;

-- --
-- -- Echoes or returns the post states as HTML.
-- --
-- -- @since 2.7.0
-- -- @since 5.3.0 Added the `display` parameter and a return value.
-- --
-- -- @see get_post_states()
-- --
-- -- @param WP_Post post    The post to retrieve states for.
-- -- @param bool    display Optional. Whether to display the post states as an HTML string.
-- --                         Default true.
-- -- @return string Post states string.
-- --
-- function X_Post_States (Post    : Hb_Post_2;
--                         Display : Boolean := True) return String
-- is
--     Post_States_String : Unbounded_String;

--     State_Count : Natural;
--     I           : Natural := 0;
-- begin
--         Post_States        := Get_Post_States (Post);
-- --        Post_States_String := "";

--         if Empty (Post_States) then
--                 State_Count := Count (Post_States);

--                 I := 0;

--                 Append (Post_States_String, " &mdash; ");

--                 for State of Post_States loop
--                         I := I + 1;

--                         Separator := (if I < State_Count then ", " else "");

--                         Append (Post_States_String, "<span class=""post-state"">" &                                                        State & Separator & "</span>");
--                 end loop;
--         end if;

--         if Display then
--                 echo (-Post_States_String);
--         end if;

--         return -Post_States_String;
-- end X_Post_States;

-- --
-- -- Retrieves an array of post states from a post.
-- --
-- -- @since 5.3.0
-- --
-- -- @param WP_Post post The post to retrieve states for.
-- -- @return string() Array of post state labels keyed by their state.
-- --
-- function Get_Post_States (Post : Hb_Post_2) return String
-- is
-- begin
--         Post_States := Empty_Array;

--         if Isset (X_REQUEST ("post_status")) then
--                 Post_Status := X_REQUEST ("post_status");
--         else
--                 Post_Status := "";
--         end if;

--         if not Empty (-Post.Post_Password) then
--                 Set (Post_States, "protected",
--                      X_X ("Password protected", "post status"));
--         end if;

--         if "private" = Post.Post_Status and then "private" /= post_status then
--                 Set (Post_States, "private", X_X ("Private", "post status"));
--         end if;

--         if "draft" = Post.Post_Status then
--                 if Get_Post_Meta (Post.ID, "_customize_changeset_uuid", True) then
--                         Post_States := abs "Customization Draft"; -- ()
--                 elsif "draft" /= Post_Status then
--                         Set (Post_States, "draft", X_X ("Draft", "post status"));
--                 end if;
--         elsif
--           "trash" = Post.Post_Status and then
--           Get_Post_Meta (Post.ID, "_customize_changeset_uuid", True)
--         then
--                 Post_States := X_X ("Customization Draft", "post status");
--         end if;

--         if "pending" = Post.Post_Status and then "pending" /= Post_Status then
--                 Set (Post_States, "pending", X_X ("Pending", "post status"));
--         end if;

--         if Is_Sticky (Post.ID) then
--                 Set (Post_States, "sticky", X_X ("Sticky", "post status"));
--         end if;

--         if "future" = Post.Post_Status then
--                 Set (Post_States, "scheduled", X_X ("Scheduled", "post status"));
--         end if;

--         if "page" = Get_Option ("show_on_front") then
--                 if Integer'Value (Get_Option ("page_on_front")) = Post.ID then
--                         Set (Post_States, "page_on_front",
--                              X_X ("Front Page", "page label"));
--                 end if;

--                 if Integer'Value (Get_Option ("page_for_posts")) = Post.ID then
--                         Set (Post_States, "page_for_posts",
--                              X_X ("Posts Page", "page label"));
--                 end if;
--         end if;

--         if Integer'Value (Get_Option ("wp_page_for_privacy_policy")) = Post.ID then
--                 Set (Post_States, "page_for_privacy_policy",
--                      X_X ("Privacy Policy Page", "page label"));
--         end if;

--         --
--         -- Filters the default post display states used in the posts list table.
--         --
--         -- @since 2.8.0
--         -- @since 3.6.0 Added the `post` parameter.
--         -- @since 5.5.0 Also applied in the Customizer context. If any admin functions
--         --              are used within the filter, their existence should be checked
--         --              with `function_exists()` before being used.
--         --
--         -- @param string() post_states An array of post display states.
--         -- @param WP_Post  post        The current post object.
--         --
--         return Apply_Filters ("display_post_states", Post_States, Post);
-- end Get_Post_States;

--    --
--    -- Outputs the attachment media states as HTML.
--    --
--    -- @since 3.2.0
--    -- @since 5.6.0 Added the `display` parameter and a return value.
--    --
--    -- @param WP_Post post    The attachment post to retrieve states for.
--    -- @param bool    display Optional. Whether to display the post states as an
--    --                        HTML string.
--    --                         Default true.
--    -- @return string Media states string.
--    --
--    function X_Media_States (Post    : Hb_Post_2;
--                             Display : Boolean := True) return String
--    is
--       Media_States_String : Unbounded_String;

--       State_Count  : Natural;
--       I            : Natural   := 0;
--       Media_States : List_Type := Get_Media_States (Post);
--    begin
--       if not Empty (Media_States) then
--          State_Count := Count (Media_States);

--          Append (Media_States_String, " &mdash; ");

--          for State of Media_States loop
--             I := I + 1;
--             declare
--                Separator : String :=  (if i < State_Count then ", " else "");
--             begin
--                Append (Media_States_String, "<span class=""post-state"">" &
--                                             (-State) & Separator & "</span>");
--             end;
--          end loop;
--       end if;

--       if Display then
--          Echo (-Media_States_String);
--       end if;

--       return -Media_States_String;
--    end X_Media_States;

--
-- Retrieves an array of media states from an attachment.
--
-- @since 5.6.0
--
-- @param WP_Post post The attachment to retrieve states for.
-- @return string() Array of media state labels keyed by their state.
--
   Header_Images : Array_Type; -- Unbounded_String;  -- static

   function Get_Media_States (Post : Inc_Class_Wp_Posts.Wp_Post)
                              return List_Type
   is
--    static (Header_Images);

      use Inc_Themes;
      use Inc_Posts;
      use Array_Vectors;
      use Inc_Class_Wp_Posts;

      Media_States : Unbounded_String; -- Array_Type := Empty_Array;
      Stylesheet   : constant Array_Type := Inc_Options.Get_Option ("stylesheet");
   begin
      if Current_Theme_Supports ("custom-header") then
         declare
            Meta_Header : constant Array_Type
               := Get_Post_Meta (Post.Id, "_wp_attachment_is_custom_header", True);
         begin
            if Is_Random_Header_Image then  -- ()
               if Length (Header_Images) = 0 then -- isset
                  Header_Images
                     := Inc_Functions.Wp_List_Pluck
                          (Get_Uploaded_Header_Images, "attachment_id");
               end if;

               if
                 Meta_Header = Stylesheet and then
                 In_Array (Integer (Post.Id), Header_Images, Strict => True)
               then
                  Media_States := +abs "Header Image";
               end if;
            else
               declare
                  Header_Image : constant Unbounded_String := +Get_Header_Image; -- ();
               begin
                  -- Display "Header Image" if the image was ever used as a
                  -- header image.
                  if
                    not Empty (Meta_Header) and then
                    Meta_Header = Stylesheet and then
                    Wp_Get_Attachment_Url (Integer (Post.Id)) /= Header_Image
                  then
                     Media_States := +abs "Header Image";
                  end if;

                  -- Display "Current Header Image" if the image is currently
                  -- the header image.
                  if
                    Header_Image /= "" and then
                    Wp_Get_Attachment_Url (Integer (Post.Id)) = Header_Image
                  then
                     Media_States := +abs "Current Header Image";
                  end if;
               end;
            end if;
         end;
         if
           not Get_Theme_Support ("custom-header", "video").Is_Empty and then
           Has_Header_Video
         then
            declare
               Mods : constant Array_Type := Get_Theme_Mods;  -- ();
            begin
               if
                 Isset (String'(Get (Mods, "header_video"))) and then
                 Post.Id'Image = Get (Mods, "header_video")
               then
                  Media_States := +abs "Current Header Video";
               end if;
            end;
         end if;
      end if;

      if Current_Theme_Supports ("custom-background") then
         declare
            Meta_Background : constant Array_Type
               := Get_Post_Meta (Post.Id, "_wp_attachment_is_custom_background", True);
         begin
            if not Empty (Meta_Background) and then Meta_Background = Stylesheet then
               Media_States := +abs "Background Image";
               declare
                  Background_Image : constant String := Get_Background_Image;  -- ();
               begin
                  if
                    Background_Image /= "" and then
                    Wp_Get_Attachment_Url (Integer (Post.Id)) = Background_Image
                  then
                     Media_States := +abs "Current Background Image";
                  end if;
               end;
            end if;
         end;
      end if;

      if Inc_Options.Get_Option ("site_icon") = Integer (Post.Id) then
         Media_States := +abs "Site Icon";
      end if;

      if Get_Theme_Mod ("custom_logo") = Integer (Post.Id) then
         Media_States := +abs "Logo";
      end if;

      --
      -- Filters the default media display states for items in the Media list table.
      --
      -- @since 3.2.0
      -- @since 4.8.0 Added the `post` parameter.
      --
      -- @param string () media_states An array of media states. Default "Header Image",
      --                               "Background Image", "Site Icon", "Logo".
      -- @param WP_Post  post         The current attachment object.
      --
      return Apply_Filters ("display_media_states", -Media_States, Post);
   end Get_Media_States;

-- --
-- -- Tests support for compressing JavaScript from PHP.
-- --
-- -- Outputs JavaScript that tests if compression from PHP works as expected
-- -- and sets an option with the result. Has no effect when the current user
-- -- is not an administrator. To run the test again the option "can_compress_scripts"
-- -- has to be deleted.
-- --
-- -- @since 2.8.0
-- --
-- procedure Compression_Test
-- is
-- begin
--    null;
--         -- ?>
--         -- <script type="text/javascript">
--         -- var compressionNonce = <?php echo wp_json_encode (wp_create_nonce ("update_can_compress_scripts")); ?>;
--         -- var testCompression = then
--         --         get : function(test) then
--         --                 var x;
--         --                 if  (window.XMLHttpRequest) then
--         --                         x = new XMLHttpRequest();
--         --                 end; else then
--         --                         trythenx=new ActiveXObject("Msxml2.XMLHTTP");end;catch(e)thentrythenx=new ActiveXObject("Microsoft.XMLHTTP");end;catch(e)thenend;;end;
--         --                 end;

--         --                 if (x) then
--         --                         x.onreadystatechange = function() then
--         --                                 var r, h;
--         --                                 if  (x.readyState == 4) then
--         --                                         r = x.responseText.substr(0, 18);
--         --                                         h = x.getResponseHeader("Content-Encoding");
--         --                                         testCompression.check(r, h, test);
--         --                                 end;
--         --                         end;;

--         --                         x.open("GET", ajaxurl + "?action=wp-compression-test&test="+test+"&_ajax_nonce="+compressionNonce+"&"+(new Date()).getTime(), true);
--         --                         x.send("");
--         --                 end;
--         --         end;,

--         --         check : function(r, h, test) then
--         --                 if  (! r && ! test)
--         --                         this.get(1);

--         --                 if  (1 == test) then
--         --                         if  (h &&  (h.match(/deflate/i) || h.match(/gzip/i)))
--         --                                 this.get("no");
--         --                         else
--         --                                 this.get(2);

--         --                         return;
--         --                 end;

--         --                 if  (2 == test) then
--         --                         if  ("wpCompressionTest" = r)
--         --                                 this.get("yes");
--         --                         else
--         --                                 this.get("no");
--         --                 end;
--         --         end;
--         -- end;;
--         -- testCompression.check();
--         -- </script>
--         -- <?php
-- end Compression_Test;

   -------------------
   -- Submit_Button --
   -------------------

   procedure Submit_Button (Text             : String     := ""; -- null;
                            Typ              : String     := "primary";
                            Name             : String     := "submit";
                            Wrap             : Boolean    := True;
                            Other_Attributes : Array_Type := Empty_Array)
   is
   begin
      Echo (Get_Submit_Button (Text, Typ, Name, Wrap, Other_Attributes));
   end Submit_Button;

   -----------------------
   -- Get_Submit_Button --
   -----------------------

   function Get_Submit_Button (Text             : String     := "";
                               Typ              : String     := "primary large";
                               Name             : String     := "submit";
                               Wrap             : Boolean    := True;
                               Other_Attributes : Array_Type := Empty_Array)
                                return String
   is
      use Inc_Formatting;

      Typ_2            : List_Type;

      Button_Shorthand : constant List_Type :=
         To_List ((+"primary", +"small", +"large"));

      Classes          : List_Type := To_List ((1 => +"button"));
   begin
--      if not Is_Array (Typ) then
         Typ_2 := Explode (" ", Typ);
--      end if;

      for T of Typ_2 loop
         if "secondary" = T or else "button-secondary" = T then
            goto Continue_3;
         end if;

         Classes.Append ((if In_Array (-T, Button_Shorthand, True)
                          then "button-" & T else T)); -- ()
         <<Continue_3>>
      end loop;

      declare
         -- Remove empty items, remove duplicate items, and finally build a string.
         Class  : constant String :=
            Implode (" ", List_Type'(Array_Unique (Array_Filter (Classes))));

         Text_2 : String := (if Text /= "" then Text else abs "Save Changes");
         -- Default the id attribute to name unless an id was specifically
         -- provided in other_attributes.
         Id : Unbounded_String := +Name;
      begin
         if Is_Array (Other_Attributes) and then Isset (Other_Attributes, "id") then
            Id := +Get (Other_Attributes, "id");
--          Other_Attributes.Delete (Other_Attributes.Find (Item => "id"));
--          Unset (Other_Attributes ("id"));
         end if;

         declare
            Attributes : Unbounded_String;
         begin
            if Is_Array (Other_Attributes) then
               for A of Other_Attributes loop
                  declare
                     Attribute : constant Key_Type   := A.Key;
                     Value     : constant Value_Type := A.Value;
                  begin
                     Attributes := Attributes & Attribute & "=""" &
                                   ESC_Attr (-Value) & """ ";
                     -- Trailing space is important.
                  end;
               end loop;
--          elsif not Empty (Other_Attributes) then -- Attributes provided as a string.
--             Attributes := +Other_Attributes;
            end if;

            declare
               -- Don't output empty name and id attributes.
               Name_Attr : String := (if Name /= ""
                                      then " name=""" & ESC_Attr (Name) & """"
                                      else """");
               Id_Attr   : String := (if Id /= ""
                                      then " id="""   & ESC_Attr (-Id)   & """"
                                      else """");

               Button : Unbounded_String;
            begin
               Append (Button, "<input type=""submit""" & Name_Attr & Id_Attr &
                               " class=""" & ESC_Attr (Class));
               Append (Button, """ value=""" & ESC_Attr (Text_2) & """ " & Attributes &
                               " />");

               if Wrap then
                  Button := To_Unbounded_String ("<p class=""submit"">" & (-Button) &
                                                 "</p>");
               end if;
               return -Button;
            end;
         end;
      end;
   end Get_Submit_Button;

   ---------------------------
   -- X_Wp_Admin_Html_Begin --
   ---------------------------

   procedure X_Wp_Admin_Html_Begin
   is
      use Inc_Options;

      Admin_Html_Class : constant String :=
        (if Inc_Admin_Bar.Is_Admin_Bar_Showing then "wp-toolbar" else "");
   begin
      if Inc_Vars.Is_IE then
         Header ("X-UA-Compatible: IE=edge");
      end if;

--         ?>
      Echo ("<!DOCTYPE html>" & NL);
      Echo ("<html class=""" & Admin_Html_Class & """" & NL);
--         <?php
      --
      -- Fires inside the HTML tag in the admin header.
      --
      -- @since 2.2.0
      --
      Inc_Plugins.Do_Action ("admin_xml_ns" & NL);

      Inc_General_Templates.Language_Attributes; -- ()
--         ?>
      Echo (">" & NL);
      Echo ("<head>" & NL);
      Echo ("<meta http-equiv=""Content-Type"" content=""" &
            Inc_General_Templates.Get_Bloginfo ("html_type") & "; charset=" &
            Get_Option ("blog_charset") & """ />" & NL);
--         <?php
   end X_Wp_Admin_Html_Begin;

-- --
-- -- Converts a screen string to a screen object.
-- --
-- -- @since 3.0.0
-- --
-- -- @param string hook_name The hook name (also known as the hook suffix) used to determine the screen.
-- -- @return WP_Screen Screen object.
-- --
-- function Convert_To_Screen (Hook_Name : String) return Hb_Screen
-- is
-- begin
--         if not Class_Exists ("WP_Screen") then
--                 X_Doing_It_Wrong (
--                         "convert_to_screen(), add_meta_box()",
--                         Sprintf (
--                                 -- translators: 1: wp-admin/includes/template.php, 2: add_meta_box(), 3: add_meta_boxes
--                                 abs "Likely direct inclusion of %1s in order to use %2s. This is very wrong. Hook the %2s call into the %3s action instead.",
--                                 "<code>wp-admin/includes/template.php</code>",
--                                 "<code>add_meta_box()</code>",
--                                 "<code>add_meta_boxes</code>"
--                        ),
--                         "3.3.0"
--                );
--                 return To_array ((
--                         Build ("id",   "_invalid"),
--                         Build ("base", "_are_belong_to_us")
--                ));
--         end if;

--         return Wp_Screen.get (Hook_Name); -- ::
-- end Convert_To_Screen;

-- --
-- -- Outputs the HTML for restoring the post data from DOM storage
-- --
-- -- @since 3.6.0
-- -- @access private
-- --
-- procedure X_Local_Storage_Notice
-- is
-- begin
-- null;
--         -- ?>
--         -- <div id="local-storage-notice" class="hidden notice is-dismissible">
--         -- <p class="local-restore">
--         --         <?php _e ("The backup of this post in your browser is different from the version below."); ?>
--         --         <button type="button" class="button restore-backup"><?php _e ("Restore the backup"); ?></button>
--         -- </p>
--         -- <p class="help">
--         --         <?php _e ("This will replace the current editor content with the last backup version. You can use undo and redo in the editor to get the old content back or to return to the restored version."); ?>
--         -- </p>
--         -- </div>
--         -- <?php
-- end X_Local_Storage_Notice;

-- --
-- -- Outputs a HTML element with a star rating for a given rating.
-- --
-- -- Outputs a HTML element with the star rating exposed on a 0..5 scale in
-- -- half star increments (ie. 1, 1.5, 2 stars). Optionally, if specified, the
-- -- number of ratings may also be displayed by passing the number parameter.
-- --
-- -- @since 3.8.0
-- -- @since 4.4.0 Introduced the `echo` parameter.
-- --
-- -- @param array args {
-- --     Optional. Array of star ratings arguments.
-- --
-- --     @type int|float rating The rating to display, expressed in either a 0.5 rating increment,
-- --                             or percentage. Default 0.
-- --     @type string    type   Format that the rating is in. Valid values are "rating" (default),
-- --                             or, "percent". Default "rating".
-- --     @type int       number The number of ratings that makes up this rating. Default 0.
-- --     @type bool      echo   Whether to echo the generated markup. False to return the markup instead
-- --                             of echoing it. Default true.
-- -- }
-- -- @return string Star rating HTML.
-- --
-- function Hb_Star_Rating (Args : Array_Type := Empty_Array) return String
-- is
--          Output : Unbounded_String;
--          Title  : Unbounded_String;
--          Format : Unbounded_String;

--          Rating      : Float;
--          Full_Stars  : Natural;
--          Half_Stars  : Natural;
--          Empty_Stars : Natural;

--         Defaults : Array_Type   := To_Array ((
--                 Build ("rating", "0"),
--                 Build ("type",   "rating"),
--                 Build ("number", "0"),
--                 Build ("echo",   "true")
--        ));
--         Parsed_Args : Array_Type := HB_Parse_Args (Args, Defaults);

--         -- Non-English decimal places when the rating is coming from a string.
--         Rating : Float := Float'Value (Str_Replace (",", ".", Parsed_Args ("rating")));

-- begin
--         -- Convert percentage to star rating, 0..5 in .5 increments.
--         if "percent" = Parsed_Args ("type") then
--                 Rating := Float'Round (Rating / 10.0, 0) / 2.0;
--         end if;
-- declare
--         -- Calculate the number of each type of star needed.
--         Full_Stars  : Natural := Natural (Float'Floor (Rating));
--         Half_Stars  : Natural := Natural (Float'Ceiling (Rating - Float (Full_Stars)));
--         Empty_Stars : Natural := Natural (5 - Full_Stars - Half_Stars);
-- begin
--         if Parsed_Args ("number") then
--             -- translators: 1: The rating, 2: The number of ratings.
--             Format := N_N ("%1s rating based on %2s rating",
--                            "%1s rating based on %2s ratings", Parsed_Args ("number"));
--             Title  := Sprintf (Format, Number_Format_I18n (Rating, 1),
--                                Number_Format_I18n (Parsed_Args ("number")));
--         else
--                 -- translators: %s: The rating.
--                 Title := Sprintf (abs "%s rating", Number_Format_I18n (Rating, 1));
--         end if;

--         Append (Output, "<div class=""star-rating"">");
--         Append (Output, "<span class=""screen-reader-text"">" & Title & "</span>");
--         Append (Output, Full_Stars  *
--                 "<div class=""star star-full"" aria-hidden=""true""></div>");
--         Append (Output, Half_Stars  *
--                 "<div class=""star star-half"" aria-hidden=""true""></div>");
--         Append (Output, Empty_Stars *
--                 "<div class=""star star-empty"" aria-hidden=""true""></div>");
--         Append (Output, "</div>");
-- end;
--         if Parsed_Args ("echo") then
--                 Echo (-Output);
--         end if;

--         return -Output;
-- end Hb_Star_Rating;

-- --
-- -- Outputs a notice when editing the page for posts (internal use only).
-- --
-- -- @ignore
-- -- @since 4.2.0
-- --
-- procedure X_hb_Posts_Page_Notice
-- is
-- begin
--         Printf (
--                 "<div class=""notice notice-warning inline""><p>%s</p></div>",
--                 abs "You are currently editing the page that shows your latest posts."
--        );
-- end X_Hb_Posts_Page_Notice;

-- --
-- -- Outputs a notice when editing the page for posts in the block editor (internal use only).
-- --
-- -- @ignore
-- -- @since 5.8.0
-- --
-- procedure X_Hb_Block_Editor_Posts_Page_Notice
-- is
-- begin
--         hb_Add_Inline_Script (
--                 "wp-notices",
--                 Sprintf (
--                         "wp.data.dispatch (""core/notices"").createWarningNotice (""%s"", then isDismissible: false end;)",
--                         abs "You are currently editing the page that shows your latest posts."
--                ),
--                 "after"
--        );
-- end X_Hb_Block_Editor_Posts_Page_Notice;

end Adi_Templates;
