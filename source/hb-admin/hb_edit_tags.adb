
with Ada.Strings.Unbounded;

with Templates_Parser;

with L10n;

with HB_Common;

package body HB_Edit_Tags
is
   use Ada.Strings.Unbounded;
   use L10n;
   use HB_Common;

   function Translation
      return Templates_Parser.Translate_Table;

-- <?php
-- /**
-- * Edit Tags Administration Screen.
-- *
-- * @package WordPress
-- * @subpackage Administration
-- */
   function Render (Request : in AWS.Status.Data)
                    return AWS.Response.Data
   is
-- /** WordPress Administration Bootstrap */
-- require_once __DIR__ . '/admin.php';

-- if ( ! $taxnow ) {
--      wp_die( __( 'Invalid taxonomy.' ) );
-- }

      Tax : constant Tax_Rec := Get_Taxonomy (Taxnow);
      Taxonomy : constant String := ""; -- jq
   begin
--      if not Tax then
--         HB_Die (abs "Invalid taxonomy.");
--      end if;

      if
         not In_Array (-Tax.Name, Get_Taxonomies
                                   (To_Array (List => (1 => Build ("show_ui", "true")))), True)
      then
         HB_Die (abs "Sorry, you are not allowed to edit terms in this taxonomy.");
      end if;

      if not Current_User_Can (Tax.Cap.Manage_Terms) then
         HB_Die ("<h1>" & abs "You need a higher level of permission." & "</h1>" &
                 "<p>" & abs "Sorry, you are not allowed to manage terms in this taxonomy." &
                 "</p>",
                 403);
      end if;

--
-- $post_type is set when the WP_Terms_List_Table instance is created
--
-- @global string $post_type
--
--  global $post_type;
      Label_1 :
      declare
         Post_Type     : constant String := ""; -- jq
         HB_List_Table : List_Table := X_Get_List_Table ("WP_Terms_List_Table");
         Pagenum       : constant Natural    := HB_List_Table.Get_Pagenum;  -- ();

         Title : String := -Tax.Labels.Name;

         Parent_File  : String
            := (if "post" /= Post_Type then (if "attachment" = Post_Type
                                             then "upload.php"
                                             else "edit.php?post_type=post_type")
                elsif "link_category" = Tax.Name then "link-manager.php"
                else                                  "edit.php");

         Submenu_File : String
            := (if "post" /= Post_Type
                then "edit-tags.php?taxonomy=taxonomy&amp;post_type=post_type"
                elsif "link_category" = Tax.Name then "edit-tags.php?taxonomy=link_category"
                else                                  "edit-tags.php?taxonomy=taxonomy");
         Location : Unbounded_String;  -- jq
         Referer  : Unbounded_String;  -- jq
      begin
--         null;
--      end;
         Add_Screen_Option ("per_page",
                            To_Array (List => (Build ("default", "20"),
                                               Build ("option",  "edit_" & (-Tax.Name) &
                                                               "_per_page"))));

         Get_Current_Screen.Set_Screen_Reader_Content (
                  To_Array (List => (Build ("heading_pagination", -Tax.Labels.Items_List_Navigation),
                                     Build ("heading_list",       -Tax.Labels.Items_List))));

--               Location := False;
         Referer  := +HB_Get_Referer; -- ();
         if Referer = "" then -- For POST requests.  -- not
            Referer := +HB_Unslash (Get (X_SERVER, "REQUEST_URI"));
         end if;
         Referer := +Remove_Query_Arg (To_Array ((To_List ((+"_wp_http_referer", +"_wpnonce",
                                                            +"error", +"message", +"paged")))),
                                       -Referer);

-- case Hb_List_Table.Current_Action then

         if "add-tag" = HB_List_Table.Current_Action then
            Check_Admin_Referer ("add-tag", "_wpnonce_add-tag");

            if not Current_User_Can (Tax.Cap.Edit_Terms) then
               HB_Die ("<h1>" & abs "You need a higher level of permission." & "</h1>" &
                       "<p>" & abs "Sorry, you are not allowed to create terms in this taxonomy." & "</p>",
                       403);
            end if;

            declare
               Taxonomy : Unbounded_String;  --  Added by jq. Not declared anywhere
               Ret : constant Boolean := HB_Insert_Term (Get (X_POST, "tag-name"),
                                                         -Taxonomy, X_POST);
            begin
               if Ret and then not Is_HB_Error (Ret) then
                  Location := Add_Query_Arg ("message", 1, Referer);
               else
                  Location := Add_Query_Arg (
                                To_Array (List => (
                                        Build ("error", "true"),
                                        Build ("message", "4")
                                )),
                                Referer
                        );
               end if;
            end;

         elsif "delete" = HB_List_Table.Current_Action then
            if not Isset (String'(Get (X_REQUEST, "tag_ID"))) then
               goto  Break;
            end if;

            declare
               Taxonomy : Unbounded_String;  -- Added by jq
               Tag_ID   : constant Integer := Integer'Value (Get (X_REQUEST, "tag_ID"));
            begin
               Check_Admin_Referer ("delete-tag_" & Tag_ID'Image);

               if not Current_User_Can ("delete_term", Tag_ID) then
                  HB_Die ("<h1>" & abs "You need a higher level of permission." & "</h1>" &
                          "<p>" & abs "Sorry, you are not allowed to delete this item." & "</p>",
                          403);
               end if;

               HB_Delete_Term (Tag_ID, -Taxonomy);

               Location := Add_Query_Arg ("message", 2, Referer);

               -- When deleting a term, prevent the action from redirecting back to a term
               -- that no longer exists.
               Location := +Remove_Query_Arg (To_Array (List => (1 => Build ("tag_ID", "action"))),
                                              -Location);
            end;
            <<Break>>

         elsif "bulk-delete" = HB_List_Table.Current_Action then
            Check_Admin_Referer ("bulk-tags");

            if not Current_User_Can (Tax.Cap.Delete_Terms) then
               HB_Die ("<h1>" & abs "You need a higher level of permission." & "</h1>" &
                       "<p>" & abs "Sorry, you are not allowed to delete these items." & "</p>",
                       403);
            end if;

            declare
               Taxonomy : Unbounded_String;
               Tags : constant Array_Type := To_Array (Item => Get (X_REQUEST, "delete_tags"));
            begin
               for Tag_ID of Tags loop
                  HB_Delete_Term (Integer'Value (-Tag_ID.Key), -Taxonomy);  -- Added .key
               end loop;

               Location := Add_Query_Arg ("message", 6, Referer);
            end;

         elsif "edit" =  HB_List_Table.Current_Action then
            if not Isset (String'(Get (X_REQUEST, "tag_ID"))) then
               goto Break_2;
            end if;

            declare
               Taxonomy : Unbounded_String;
               Term_Id  : constant Integer   := Integer'Value (Get (X_REQUEST, "tag_ID"));
               Term     : Term_Type := Get_Term (Term_Id);
            begin
               if False then
--             if Term not in HB_Term then
--             if not term instanceof WP_Term then
                  HB_Die (abs "You attempted to edit an item that does not exist. Perhaps it was deleted?");
               end if;

               HB_Redirect (Sanitize_URL (Get_Edit_Term_Link (Term_Id, -Taxonomy, Post_Type)));
            end;
            goto Bailout; -- return; -- exit;

         <<Break_2>>

         elsif "editedtag" = HB_List_Table.Current_Action then
            declare
               Taxonomy : Unbounded_String;
               Tag_ID   : constant Integer := Integer'Value (Get (X_POST, "tag_ID"));
            begin
               Check_Admin_Referer ("update-tag_" & Tag_ID'Image);

               if not Current_User_Can ("edit_term", Tag_ID) then
                  HB_Die ("<h1>" & abs "You need a higher level of permission." & "</h1>" &
                          "<p>" & abs "Sorry, you are not allowed to edit this item." & "</p>",
                          403);
               end if;

               declare
                  Tag : constant Term_Type := Get_Term (Tag_ID, -Taxonomy);
               begin
                  if not Tag then
                     HB_Die (abs "You attempted to edit an item that does not exist. Perhaps it was deleted?");
                  end if;

                  declare
                     Ret : constant Boolean := HB_Update_Term (Tag_ID, -Taxonomy, X_POST);
                  begin
                     if Ret and then not Is_HB_Error (Ret) then
                        Location := Add_Query_Arg ("message", 3, Referer);
                     else
                        Location := Add_Query_Arg (
                                To_Array (List => (
                                        Build ("error", "true"),
                                        Build ("message", "5")
                                )),
                                Referer
                        );
                     end if;
                  end;
               end;
            end;

         else
            if "" = HB_List_Table.Current_Action or else  -- not
              not Isset (String'(Get (X_REQUEST, "delete_tags")))
            then
               goto Break_3;
            end if;
            Check_Admin_Referer ("bulk-tags");

            declare
               Screen : Screen_Id  := Get_Current_Screen.Id;
               Tags   : constant Array_Type := To_Array (Item => Get (X_REQUEST, "delete_tags"));
            begin
               -- This action is documented in wp-admin/edit.php
               Location := Apply_Filters ("handle_bulk_actions-thenscreenend;",
                                          Location, HB_List_Table.Current_Action, Tags);
               -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
            end;
            <<Break_3>>
         end if; -- end case;

         if "" = Location and then not Empty (Get (X_REQUEST, "_wp_http_referer")) then  -- not
            Location := +Remove_Query_Arg
                (To_Array (List => (1 => Build ("_wp_http_referer", "_wpnonce"))),
                                     HB_Unslash (Get (X_SERVER, "REQUEST_URI")));
         end if;

         if Location /= "" then
            if Pagenum > 1 then
               Location := Add_Query_Arg ("paged", Pagenum, Location);
               -- pagenum takes care of total_pages.
            end if;
            --
            -- Filters the taxonomy redirect destination URL.
            --
            -- @since 4.6.0
            --
            -- @param string      location The destination URL.
            -- @param WP_Taxonomy tax      The taxonomy object.
            --
            HB_Redirect (Apply_Filters ("redirect_term_location", -Location, -Tax.Name));  -- .name added
            goto Bailout; -- return;  --  exit;
         end if;

         HB_List_Table.Prepare_Items; -- ();

         declare
            Total_Pages : constant Natural := Get_Pagination_Arg (HB_List_Table, "total_pages");
         begin
            if Pagenum > Total_Pages and Total_Pages > 0 then
               HB_Redirect (Add_Query_Arg ("paged", Total_Pages'Image));
               goto Bailout; -- return;  -- exit;
            end if;
         end;

         HB_Enqueue_Script ("admin-tags");
         if Current_User_Can (Tax.Cap.Edit_Terms) then
            HB_Enqueue_Script ("inline-edit-tax");
         end if;

         Label_2 :
         declare
            Taxonomy : Unbounded_String;
            Help : Unbounded_String := Null_Unbounded_String;
         begin
            if
              "category" = Taxonomy or else
              "link_category" = Taxonomy or else
              "post_tag" = Taxonomy
            then

               if "category" = Taxonomy then
                  Set_Unbounded_String (Help, "<p>" & Sprintf (
                        -- translators: %s: URL to Writing Settings screen.
                        abs "You can use categories to define sections of your site and group related posts. The default category is &#8220;Uncategorized&#8221; until you change it in your <a href=""%s"">writing settings</a>.",
                        "options-writing.php"
               ) & "</p>");
               elsif "link_category" = Taxonomy then
                  Set_Unbounded_String (Help, "<p>" & abs "You can create groups of links by using Link Categories. Link Category names must be unique and Link Categories are separate from the categories you use for posts." & "</p>");
               else
                  Set_Unbounded_String (Help, "<p>" & abs "You can assign keywords to your posts using <strong>tags</strong>. Unlike categories, tags have no hierarchy, meaning there is no relationship from one tag to another." & "</p>");
               end if;

               if "link_category" = Taxonomy then
                  Help := Help & "<p>" & abs "You can delete Link Categories in the Bulk Action pull-down, but that action does not delete the links within the category. Instead, it moves them to the default Link Category." & "</p>";
               else
                  Help := Help & "<p>" & abs "What&#8217;s the difference between categories and tags? Normally, tags are ad-hoc keywords that identify important information in your post (names, subjects, etc) that may or may not recur in other posts, while categories are pre-determined sections. If you think of your site like a book, the categories are like the Table of Contents and the tags are like the terms in the index." & "</p>";
               end if;

               Get_Current_Screen.Add_Help_Tab (
                To_Array (List => (
                        Build ("id", "overview"),
                        Build ("title", abs ("Overview")),
                        Build ("content", -Help)
               )));

               if "category" = Taxonomy or else "post_tag" = Taxonomy then
                  if "category" = Taxonomy then
                     Set_Unbounded_String (Help, "<p>" & abs "When adding a new category on this screen, you&#8217;ll fill in the following fields:" & "</p>");
                  else
                     Set_Unbounded_String (Help, "<p>" & abs "When adding a new tag on this screen, you&#8217;ll fill in the following fields:" & "</p>");
                  end if;

                  Help := Help & "<ul>" &
                     "<li>" & abs "<strong>Name</strong> &mdash; The name is how it appears on your site." & "</li>";

                  Help := Help & "<li>" & abs "<strong>Slug</strong> &mdash; The &#8220;slug&#8221; is the URL-friendly version of the name. It is usually all lowercase and contains only letters, numbers, and hyphens." & "</li>";

                  if "category" = Taxonomy then
                     Help := Help & "<li>" & abs "<strong>Parent</strong> &mdash; Categories, unlike tags, can have a hierarchy. You might have a Jazz category, and under that have child categories for Bebop and Big Band. Totally optional. To create a subcategory, just choose another category from the Parent dropdown." & "</li>";
                  end if;

                  Help := Help & "<li>" & abs "<strong>Description</strong> &mdash; The description is not prominent by default; however, some themes may display it." & "</li>" &
                "</ul>" &
                "<p>" & abs "You can change the display of this screen using the Screen Options tab to set how many items are displayed per screen and to display/hide columns in the table." & "</p>";

                  Get_Current_Screen.Add_Help_Tab (
                        To_Array (List => (
                                Build ("id", "adding-terms"),
                                Build ("title", (if "category" = Taxonomy
                                                 then abs "Adding Categories"
                                                 else abs "Adding Tags")),
                                Build ("content", -Help)
                       )));
               end if;  -- ???

               Set_Unbounded_String (Help, "<p><strong>" & abs "For more information:" & "</strong></p>");

               if "category" = Taxonomy then
                  Help := Help & "<p>" & abs "<a href=""https://wordpress.org/support/article/posts-categories-screen/"">Documentation on Categories</a>" & "</p>";
               elsif "link_category" = Taxonomy then
                  Help := Help & "<p>" & abs "<a href=""https://codex.wordpress.org/Links_Link_Categories_Screen"">Documentation on Link Categories</a>" & "</p>";
               else
                  Help := Help & "<p>" & abs "<a href=""https://wordpress.org/support/article/posts-tags-screen/"">Documentation on Tags</a>" & "</p>";
               end if;

               Help := Help & "<p>" & abs "<a href=""https://wordpress.org/support/"">Support</a>" & "</p>";

               Get_Current_Screen.Set_Help_Sidebar (-Help);
--        unset (help);
            end if;  -- ???
         end Label_2;

    <<Bailout>>
         -- require_once ABSPATH . "wp-admin/admin-header.php";

         -- Also used by the Edit Tag form.
         -- require_once ABSPATH . "wp-admin/includes/edit-tag-messages.php";
         declare
            Class : String :=  (if Isset (String'(Get (X_REQUEST, "error")))
                                then "error" else "updated");
            Import_Link : Unbounded_String;
         begin
            if Is_Plugin_Active ("wpcat2tag-importer/wpcat2tag-importer.php") then
               Import_Link := To_Unbounded_String (Admin_URL ("admin.php?import=wpcat2tag"));
            else
               Import_Link := To_Unbounded_String (Admin_URL ("import.php"));
            end if;

            declare
               use Templates_Parser;

               type My_Lazy is new Dynamic.Lazy_Tag with null record;

               overriding
               procedure Value (Lazy_Tag     : access My_Lazy;
                                Var_Name     : in     String;
                                Translations : in out Translate_Set);

               overriding
               procedure Value (Lazy_Tag     : access My_Lazy;
                                Var_Name     : in     String;
                                Translations : in out Translate_Set)
               is
                  procedure Set (Var : String; Value : String);
                  procedure Set (Var : String; Value : Boolean);

                  procedure Set (Var : String; Value : String) is
                  begin
                     Insert (Translations, Assoc (Var, Value));
                  end Set;

                  procedure Set (Var : String; Value : Boolean) is
                  begin
                     Insert (Translations, Assoc (Var, Value));
                  end Set;

                  Message : constant String := "XXX-102";
                  --  Could not find message (jq)
               begin
                  if Var_Name = "VAR_edit_tags_add_form" then
                     if "category" = Taxonomy then
                        --
                        -- Fires at the end of the Edit Category form.
                        --
                        -- @since 2.1.0
                        -- @deprecated 3.0.0 Use then@see "thentaxonomyend;_add_form"end; instead.
                        --
                        -- @param object arg Optional arguments cast to an object.
                        --
                        Do_Action_Deprecated ("edit_category_form",
                           To_Array (List => To_Array (List => (1 => Build ("parent", "0")))),
                                              "3.0.0", "{taxonomy}_add_form");
                     elsif "link_category" = Taxonomy then
                        --
                        -- Fires at the end of the Edit Link form.
                        --
                        -- @since 2.3.0
                        -- @deprecated 3.0.0 Use then@see "thentaxonomyend;_add_form"end; instead.
                        --
                        -- @param object arg Optional arguments cast to an object.
                        --
                        Do_Action_Deprecated ("edit_link_category_form",
                         To_Array (List => To_Array (List => (1 => Build ("parent", "0")))),
                                      "3.0.0", "{taxonomy}_add_form");
                     else
                        --
                        -- Fires at the end of the Add Tag form.
                        --
                        -- @since 2.7.0
                        -- @deprecated 3.0.0 Use then@see "thentaxonomyend;_add_form"end; instead.
                        --
                        -- @param string taxonomy The taxonomy slug.
                        --
                        Do_Action_Deprecated ("add_tag_form", To_Array (Taxonomy),
                                      "3.0.0", "{taxonomy}_add_form");
                     end if;

                     --
                     -- Fires at the end of the Add Term form for all taxonomies.
                     --
                     -- The dynamic portion of the hook name, `taxonomy`, refers to the taxonomy slug.
                     --
                     -- Possible hook names include:
                     --
                     --  - `category_add_form`
                     --  - `post_tag_add_form`
                     --
                     -- @since 3.0.0
                     --
                     -- @param string taxonomy The taxonomy slug.
                     --
                     Do_Action ("{taxonomy}_add_form", Taxonomy);

                     Set ("VAR_edit_tags_add_form", "XXX-81");

                  elsif Var_Name = "VAR_edit_tags_add_new_item" then
                     Set ("VAR_edit_tags_add_new_item", -Tax.Labels.Add_New_Item);

                  elsif Var_Name = "VAR_edit_tags_add_tag" then
                     HB_Nonce_Field ("add-tag", "_wpnonce_add-tag");
                     Set ("VAR_edit_tags_add_tag", "XXX-82");

                  elsif Var_Name = "VAR_edit_tags_can_edit_terms" then
                     declare
                        Can_Edit_Terms : constant Boolean
                           := Current_User_Can (Tax.Cap.Edit_Terms);
                     begin
                        Set ("VAR_edit_tags_can_edit_terms", Can_Edit_Terms);
                     end;

                  elsif Var_Name = "VAR_edit_tags_category_help" then
                     Set ("VAR_edit_tags_category_help",
                          E_E ("Categories, unlike tags, can have a hierarchy. You might have a Jazz category, and under that have children categories for Bebop and Big Band. Totally optional."));

                  elsif Var_Name = "VAR_edit_tags_category_is_taxonomy" then
                     Set ("VAR_edit_tags_category_is_taxonomy", "category" = Taxonomy);

                  elsif Var_Name = "VAR_edit_tags_class" then
                     Set ("VAR_edit_tags_class", Class);

                  elsif Var_Name = "VAR_edit_tags_convert_help" then
                     declare
                        R : constant String := Printf (
                        -- translators: %s: URL to Categories to Tags Converter tool.
                        abs "Tags can be selectively converted to categories using the <a href=""%s"">tag to category converter</a>.",
                        ESC_URL (-Import_Link));
                     begin
                        Set ("VAR_edit_tags_convert_help", R);
                     end;

                  elsif Var_Name = "VAR_edit_tags_converter_help" then
                     declare
                        R : constant String := Printf (
                        -- translators: %s: URL to Categories to Tags Converter tool.
                        abs "Categories can be selectively converted to tags using the <a href=""%s"">category to tag converter</a>.",
                        ESC_URL (-Import_Link));
                     begin
                        Set ("VAR_edit_tags_converter_help", R);
                     end;

                  elsif Var_Name = "VAR_edit_tags_current_screen_id" then
                     Set ("VAR_edit_tags_current_screen_id", ESC_Attr (Get_Current_Screen.Id'Image));

                  elsif Var_Name = "VAR_edit_tags_delete_help" then
                     declare
                        R : constant String := Printf (
                        -- translators: %s: Default category.
                        abs "Deleting a category does not delete the posts in that category. Instead, posts that were only assigned to the deleted category are set to the default category %s. The default category cannot be deleted.",
                        -- This filter is documented in wp-includes/category-template.php
                        "<strong>" & Apply_Filters ("the_category", Get_Cat_Name (Get_Option ("default_category")), "", "") & "</strong>");
                     begin
                        Set ("VAR_edit_tags_delete_help", R);
                     end;

                  elsif Var_Name = "VAR_edit_tags_description" then
                     Set ("VAR_edit_tags_description", E_E ("Description"));

                  elsif Var_Name = "VAR_edit_tags_display" then
                     Set ("VAR_edit_tags_display", HB_List_Table.Display);

                  elsif Var_Name = "VAR_edit_tags_do_action_deprecated" then
                     if "category" = Taxonomy then
                        --
                        -- Fires before the Add Category form.
                        --
                        -- @since 2.1.0
                        -- @deprecated 3.0.0 Use then@see "thentaxonomyend;_pre_add_form"end; instead.
                        --
                        -- @param object arg Optional arguments cast to an object.
                        --
                        Do_Action_Deprecated ("add_category_form_pre",
                               To_Array (List => To_Array (List => (1 => Build ("parent", "0")))),
                               "3.0.0", "{taxonomy}_pre_add_form");
                     elsif "link_category" = Taxonomy then
                        --
                        -- Fires before the link category form.
                        --
                        -- @since 2.3.0
                        -- @deprecated 3.0.0 Use then@see "thentaxonomyend;_pre_add_form"end; instead.
                        --
                        -- @param object arg Optional arguments cast to an object.
                        --
                        Do_Action_Deprecated ("add_link_category_form_pre",
                                  To_Array (List => To_Array (List => (1 => Build ("parent", "0")))),
                                  "3.0.0", "{taxonomy}_pre_add_form");
                     else
                        --
                        -- Fires before the Add Tag form.
                        --
                        -- @since 2.5.0
                        -- @deprecated 3.0.0 Use then@see "thentaxonomyend;_pre_add_form"end; instead.
                        --
                        -- @param string taxonomy The taxonomy slug.
                        --
                        Do_Action_Deprecated ("add_tag_form_pre",
                                              To_Array (Taxonomy),
                                              "3.0.0", "{taxonomy}_pre_add_form");
                     end if;

                     --
                     -- Fires before the Add Term form for all taxonomies.
                     --
                     -- The dynamic portion of the hook name, `taxonomy`, refers to the taxonomy slug.
                     --
                     -- Possible hook names include:
                     --
                     --  - `category_pre_add_form`
                     --  - `post_tag_pre_add_form`
                     --
                     -- @since 3.0.0
                     --
                     -- @param string taxonomy The taxonomy slug.
                     --
                     Do_Action ("{taxonomy}_pre_add_form", Taxonomy);

                     Set ("VAR_edit_tags_do_action_deprecated", "XXX-83");

                  elsif Var_Name = "VAR_edit_tags_do_after_table" then
                     --
                     -- Fires after the taxonomy list table.
                     --
                     -- The dynamic portion of the hook name, `taxonomy`, refers to the taxonomy slug.
                     --
                     -- Possible hook names include:
                     --
                     --  - `after-category-table`
                     --  - `after-post_tag-table`
                     --
                     -- @since 3.0.0
                     --
                     -- @param string taxonomy The taxonomy name.
                     --
                     Do_Action ("after-{taxonomy}-table", Taxonomy);
                     -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
                     Set ("VAR_edit_tags_do_after_table", "XXX-84");

                  elsif Var_Name = "VAR_edit_tags_do_new_form" then
                     --
                     -- Fires inside the Add Tag form tag.
                     --
                     -- The dynamic portion of the hook name, `taxonomy`, refers to the taxonomy slug.
                     --
                     -- Possible hook names include:
                     --
                     --  - `category_term_new_form_tag`
                     --  - `post_tag_term_new_form_tag`
                     --
                     -- @since 3.7.0
                     --
                     Do_Action ("{taxonomy}_term_new_form_tag");
                     Set ("VAR_edit_tags_do_new_form", "XX-85");

                  elsif Var_Name = "VAR_edit_tags_do_tax_add_form_fields" then
                     if not Is_Taxonomy_Hierarchical (Taxonomy) then
                        --
                        -- Fires after the Add Tag form fields for non-hierarchical taxonomies.
                        --
                        -- @since 3.0.0
                        --
                        -- @param string taxonomy The taxonomy slug.
                        --
                        Do_Action ("add_tag_form_fields", Taxonomy);
                     end if;

                     --
                     -- Fires after the Add Term form fields.
                     --
                     -- The dynamic portion of the hook name, `taxonomy`, refers to the taxonomy slug.
                     --
                     -- Possible hook names include:
                     --
                     --  - `category_add_form_fields`
                     --  - `post_tag_add_form_fields`
                     --
                     -- @since 3.0.0
                     --
                     -- @param string taxonomy The taxonomy slug.
                     --
                     Do_Action ("{taxonomy}_add_form_fields", Taxonomy);

                     Set ("VAR_edit_tags_do_tax_add_form_fields", "XX-86");

                  elsif Var_Name = "VAR_edit_tags_dropdown" then
                     declare
                        Dropdown_Args : Array_Type := To_Array (List => (
                                      Build ("hide_empty",       "0"),
                                      Build ("hide_if_empty",    "false"),
                                      Build ("taxonomy",         Taxonomy),
                                      Build ("name",             "parent"),
                                      Build ("orderby",          "name"),
                                      Build ("hierarchical",     "true"),
                                      Build ("show_option_none", abs "None")
                                      ));

                        --
                        -- Filters the taxonomy parent drop-down on the Edit Term page.
                        --
                        -- @since 3.7.0
                        -- @since 4.2.0 Added `context` parameter.
                        --
                        -- @param array  dropdown_args then
                        --     An array of taxonomy parent drop-down arguments.
                        --
                        --     @type int|bool hide_empty       Whether to hide terms not attached to any posts. Default 0.
                        --     @type bool     hide_if_empty    Whether to hide the drop-down if no terms exist. Default false.
                        --     @type string   taxonomy         The taxonomy slug.
                        --     @type string   name             Value of the name attribute to use for the drop-down select element.
                        --                                      Default "parent".
                        --     @type string   orderby          The field to order by. Default "name".
                        --     @type bool     hierarchical     Whether the taxonomy is hierarchical. Default true.
                        --     @type string   show_option_none Label to display if there are no terms. Default "None".
                        -- end;
                        -- @param string taxonomy The taxonomy slug.
                        -- @param string context  Filter context. Accepts "new" or "edit".
                        --
                     begin
                        Dropdown_Args := Apply_Filters ("taxonomy_parent_dropdown_args",
                                                        Dropdown_Args, Taxonomy, "new");

                        Set (Dropdown_Args, "aria_describedby", "parent-description");
--                      Dropdown_Args ("aria_describedby") := "parent-description";

                        HB_Dropdown_Categories (Dropdown_Args);

                        Set ("VAR_edit_tags_dropdown", "XXX-87");
                     end;

                  elsif Var_Name = "VAR_edit_tags_h1_sub" then
                     declare
                        R : Unbounded_String;
                     begin
                        if
                          Isset (String'(Get (X_REQUEST, "s"))) and then
                          String'(Get (X_REQUEST, "s"))'Length /= 0
                        then
                           Append (R, "<span class=""subtitle"">");
                           Append (R, Printf (
                              -- translators: %s: Search query.
                              abs "Search results for: %s",
                              "<strong>" & ESC_HTML (HB_Unslash (Get (X_REQUEST, "s"))) & "</strong>"
                           ));
                           Append (R, "</span>");
                        end if;
                        Set ("VAR_edit_tags_h1_sub", -R);
                     end;

                  elsif Var_Name = "VAR_edit_tags_inline_edit" then
                     Set ("VAR_edit_tags_inline_edit", HB_List_Table.Inline_Edit);

                  elsif Var_Name = "VAR_edit_tags_is_tax_hierarchical" then
                     Set ("VAR_edit_tags_is_tax_hierarchical", Is_Taxonomy_Hierarchical (Taxonomy));

                  elsif Var_Name = "VAR_edit_tags_message" then
                     Set ("VAR_edit_tags_message", Message);

                  elsif Var_Name = "VAR_edit_tags_message_set" then
                     Set ("VAR_edit_tags_message_set", Message /= "");

                  elsif Var_Name = "VAR_edit_tags_name_field_description" then
                     Set ("VAR_edit_tags_name_field_description", -Tax.Labels.Name_Field_Description);

                  elsif Var_Name = "VAR_edit_tags_not_is_mobile" then
                     Set ("VAR_edit_tags_not_is_mobile", not HB_Is_Mobile);

                  elsif Var_Name = "VAR_edit_tags_post_tag_and_user_can_import" then
                     Set ("VAR_edit_tags_post_tag_and_user_can_import",
                          "post_tag" = Taxonomy and then Current_User_Can ("import"));

                  elsif Var_Name = "VAR_edit_tags_post_type" then
                     Set ("VAR_edit_tags_post_type", ESC_Attr (Post_Type));

                  elsif Var_Name = "VAR_edit_tags_remove_message_and_error" then
                     Set (X_SERVER, "REQUEST_URI",
                          Remove_Query_Arg (To_Array (List => (1 => Build ("message", "error"))),
                                                Get (X_SERVER, "REQUEST_URI")));
                     Set ("VAR_edit_tags_remove_message_and_error", "XXX-88");

                  elsif Var_Name = "VAR_edit_tags_search_box" then
                     declare
                        X : constant String
                           := Search_Box (HB_List_Table, -Tax.Labels.Search_Items, "tag");
                     begin
                        Set ("VAR_edit_tags_search_box", X);
                     end;

                  elsif Var_Name = "VAR_edit_tags_slug_field_description" then
                     Set ("VAR_edit_tags_slug_field_description", -Tax.Labels.Slug_Field_Description);

                  elsif Var_Name = "VAR_edit_tags_submit_button" then
                     Set ("VAR_edit_tags_submit_button",
                          Submit_Button (-Tax.Labels.Add_New_Item, "primary", "submit", False));

                  elsif Var_Name = "VAR_edit_tags_tax_field_description" then
                     Set ("VAR_edit_tags_tax_field_description", -Tax.Labels.Parent_Field_Description);

                  elsif Var_Name = "VAR_edit_tags_tax_parent_item" then
                     Set ("VAR_edit_tags_tax_parent_item", ESC_HTML (-Tax.Labels.Parent_Item));

                  elsif Var_Name = "VAR_edit_tags_taxonomy" then
                     Set ("VAR_edit_tags_taxonomy", ESC_Attr (Taxonomy));

                  elsif Var_Name = "VAR_edit_tags_term_name" then
                     Set ("VAR_edit_tags_term_name", Ex_Ex ("Name", "term name"));

                  elsif Var_Name = "VAR_edit_tags_user_can_import" then
                     Set ("VAR_edit_tags_user_can_import", Current_User_Can ("import"));

                  elsif Var_Name = "VAR_edit_tags_views" then
                     Set ("VAR_edit_tags_views", HB_List_Table.Views);
                  end if;
               end Value;

               Lazy    : aliased My_Lazy;
               Payload : constant Unbounded_String
                 := Templates_Parser.Parse ("page/hb-admin/edit.thtml",
                                             Translation,
                                             Lazy_Tag => Lazy'Unchecked_Access);
            begin
               return AWS.Response.Build ("text/html", Payload);
            end;
         end;
      end Label_1;
   end Render;

   ------------------
   -- Translations --
   ------------------

   function Translation
      return Templates_Parser.Translate_Table
   is
      use Templates_Parser;

      Table : constant Translate_Table :=
         (Assoc ("MANUAL_TOC",         "TOC"),
          Assoc ("MANUAL_INDEX",       "INDEX"),
          Assoc ("MANUAL_AUTH_SEARCH", "SEARCH"));
   begin
      return Table;
   end Translation;

end HB_Edit_Tags;
