
with Ada.Strings.Unbounded;

with Templates_Parser;

with L10n;

with HB_Common;

package body HB_Edit is

   use Ada.Strings.Unbounded;
   use L10n;
   use HB_Common;

   function Var_Bulk (Bulk_Messages : Array_Type;
                      Bulk_Counts   : Array_Type;
                      Post_Type     : String) return String;

   function Translation
      return Templates_Parser.Translate_Table;

--  <?php
--
--  Edit Posts Administration Screen.
--
--  @package Heidelberger
--  @subpackage Administration
--

--  /** WordPress Administration Bootstrap */
--  require_once __DIR__ . '/admin.php';

--  /**
--  * @global string $typenow The post type of the current screen.
--  */
--  global $typenow;

--  if ( ! $typenow ) {
--      wp_die( __( 'Invalid post type.' ) );
--  }

--  if ( ! in_array( $typenow, get_post_types( array( 'show_ui' => true ) ), true ) ) {
--      wp_die( __( 'Sorry, you are not allowed to edit posts in this post type.' ) );
--  }

--  if ( 'attachment' === $typenow ) {
--      if ( wp_redirect( admin_url( 'upload.php' ) ) ) {
--              exit;
--      }
--  }

   function Render (Request : in AWS.Status.Data)
                    return AWS.Response.Data
   is
--
--  @global string       $post_type
--  @global WP_Post_Type $post_type_object
--
--  global $post_type, $post_type_object;

      Post_Type        : constant String    := Typenow;
      Post_Type_Object : constant Post_Rec  := Post_Rec'(Get_Post_Type_Object (Post_Type));
   begin
--  if Post_Type_Object = 0 then  -- not
--   HB_Die (abs  "Invalid post type.");
--  end if;

      if not Current_User_Can (Post_Type_Object.Cap.Edit_Posts) then
         HB_Die
           ("<h1>" & abs "You need a higher level of permission."  & "</h1>" &
            "<p>"  & abs "Sorry, you are not allowed to edit posts in this post type." &
            "</p>",
            403);
      end if;

      declare
         HB_List_Table : List_Table       := X_Get_List_Table ("HB_Posts_List_Table");
         Pagenum       : constant Natural := HB_List_Table.Get_Pagenum; -- ();
      begin
-- // Back-compat for viewing comments of an entry.
-- foreach ( array( 'p', 'attachment_id', 'page_id' ) as $_redirect ) {
--      if ( ! empty( $_REQUEST[ $_redirect ] ) ) {
--              wp_redirect( admin_url( 'edit-comments.php?p=' . absint( $_REQUEST[ $_redirect ] )
-- ) );
--              exit;
--      }
-- }

-- unset( $_redirect );

         declare
            Parent_File   : String := (if "post" = Post_Type then "edit"
                                       else "edit?post_type=" & Post_Type);
            Submenu_File  : String := (if "post" = Post_Type then "edit"
                                       else "edit?post_type=" & Post_Type);
            Post_New_File : String := (if "post" = Post_Type then "post-new"
                                       else "post-new?post_type=" & Post_Type);
-- if "post" /= Post_Type then
--    Parent_File   := "edit?post_type=" & Post_Type;
--    Submenu_File  := "edit?post_type=" & Post_Type;
--    Post_New_File := "post-new?post_type=" & Post_Type;
-- else
--    Parent_File   := "edit";
--    Submenu_File  := "edit";
--    Post_New_File := "post-new";
-- end if;
            Doaction : String := HB_List_Table.Current_Action; -- ();
         begin

            if Doaction = "" then   -- if doaction then
               Check_Admin_Referer ("bulk-posts");
                  declare
                     Sendback : Unbounded_String
                       := +Remove_Query_Arg (To_Array (List => To_List ((+"trashed", +"untrashed",
                                                                         +"deleted",
                                                                         +"locked", +"ids"))),
                                             HB_Get_Referer);  -- () );
                  begin
                     if Sendback = "" then   -- not
                        Sendback := To_Unbounded_String (Admin_URL (Parent_File));
                     end if;

                     Sendback := Add_Query_Arg ("paged", Pagenum, Sendback);
                     if Index (Sendback, "post") /= 0 then
                        Sendback := To_Unbounded_String (Admin_URL (Post_New_File));
                     end if;

                     declare
                        Post_Ids : Array_Access; -- Type; --  := To_Array; -- ()
                        Post_Status : Integer;
                     begin
                        if "delete_all" = Doaction then
                        -- Prepare for deletion of all posts with a specified post status
                        -- (i.e. Empty Trash).
                           Post_Status := Preg_Replace ("/(^a-z0-9_-)+/i', '",
                                                        Get (X_REQUEST, "post_status"));

                           -- Validate the post status exists.
                           if Get_Post_Status_Object (Post_Status) then
                              --
                              -- @global wpdb $wpdb WordPress database abstraction object.
                              --
                              -- global $wpdb;

                              Post_Ids := new Array_Type'(Wpdb.Get_Col (Wpdb.Prepare ("SELECT ID FROM $wpdb->posts WHERE post_type=%s AND post_status = %s", Post_Type, Post_Status'Image)));
                           end if;
                           Doaction := "delete";
                        elsif Isset (String'(Get (X_REQUEST, "media"))) then
                           Post_Ids := new Array_Type'(Get (X_REQUEST, "media"));
                        elsif Isset (String'(Get (X_REQUEST, "ids"))) then
                           Post_Ids := new Array_Type'(Explode (",", Get (X_REQUEST, "ids")));
                        elsif not Empty (Get (X_REQUEST, "post")) then
                           Post_Ids := new Array_Type'(Array_Map ("intval", Get (X_REQUEST, "post")));
                        end if;

                        if Empty (Post_Ids.all) then
                           HB_Redirect (-Sendback);
                           return AWS.Response.URL (""); -- exit;  -- redirect
                        end if;

                        if "trash" = Doaction then
--              when "trash" =>
                           declare
                              Trashed : Natural := 0;
                              Locked  : Natural := 0;
                           begin
                              for Post_Id of Post_Ids.all loop -- foreach (To_Array)
                                 if not Current_User_Can ("delete_post", Post_Id) then
                                    HB_Die (abs "Sorry, you are not allowed to move this item to the Trash.");
                                 end if;

                                 if HB_Check_Post_Lock (Post_Id) then
                                    Locked := Locked + 1;
                                    goto Continue;
                                 end if;

                                 if not HB_Trash_Post (Post_Id) then
                                    HB_Die (abs "Error in moving the item to Trash.");
                                 end if;

                                 Trashed := Trashed + 1;
                                 <<Continue>>
                              end loop;

                              Sendback := Add_Query_Arg (
                                To_Array (List => (
                                        Build ("trashed", Trashed'Image),
                                        Build ("ids",     Implode (",", Post_Ids.all)),
                                        Build ("locked",  Locked'Image)
                                )),
                                Sendback);
                           end;

                        elsif "untrash" = Doaction then
--              when "untrash" =>
                           declare
                              Untrashed : Natural := 0;
                           begin
                              if
                                Isset (String'(Get (X_GET, "doaction"))) and
                                "undo" = String'(Get (X_GET, "doaction"))
                              then
                                 Add_Filter ("wp_untrash_post_status",
                                             "wp_untrash_post_set_previous_status",
                                             10, 3);
                              end if;

                              for Post_Id of Post_Ids.all loop
                                 if not Current_User_Can ("delete_post", Post_Id) then
                                    HB_Die (abs "Sorry, you are not allowed to restore this item from the Trash.");
                                 end if;

                                 if not HB_Untrash_Post (Post_Id) then
                                    HB_Die (abs "Error in restoring the item from Trash.");
                                 end if;

                                 Untrashed := Untrashed + 1;
                              end loop;
                              Sendback := Add_Query_Arg ("untrashed", Untrashed, Sendback);

                              Remove_Filter ("wp_untrash_post_status",
                                             "wp_untrash_post_set_previous_status", 10);
                           end;

                        elsif "delete" = Doaction then
--              when "delete" =>
                           declare
                              Deleted : Natural := 0;
                           begin
                              for Post_Id of Post_Ids.all loop
                                 declare
                                    Post_Del : constant Post_Rec := Get_Post (Post_Id);
                                 begin
                                    if not Current_User_Can ("delete_post", Post_Id) then
                                       HB_Die (abs "Sorry, you are not allowed to delete this item.");
                                    end if;

                                    if "attachment" = Post_Del.Post_Type then
                                       if not HB_Delete_Attachment (Post_Id) then
                                          HB_Die (abs "Error in deleting the attachment.");
                                       end if;
                                    else
                                       if not HB_Delete_Post (Post_Id) then
                                          HB_Die (abs "Error in deleting the item.");
                                       end if;
                                    end if;
                                    Deleted := Deleted + 1;
                                 end;
                              end loop;
                              Sendback := Add_Query_Arg ("deleted", Deleted, Sendback);
                           end;

                        elsif "edit" = Doaction then
--              when "edit" =>
                           if Isset (String'(Get (X_REQUEST, "bulk_edit"))) then
                              declare
                                 Done : Array_Type := Bulk_Edit_Posts (Get (X_REQUEST, ""));
                                 -- (item => ) added
                              begin
                                 if Is_Array (Done) then
                                    Set (Done, "updated", Count (Get (Done, "updated")));
                                    Set (Done, "skipped", Count (Get (Done, "skipped")));
                                    -- Done ("skipped") := Count (Done ("skipped"));
                                    Set (Done, "locked",  Count (Get (Done, "locked")));
                                    Sendback := Add_Query_Arg (Done, Sendback);
                                 end if;
                              end;
                           end if;

                        else
--              when others =>
                           declare
                              Screen : Screen_Id := Get_Current_Screen.Id;  -- ()
                           begin
--
-- Fires when a custom bulk action should be handled.
--
-- The redirect link should be modified with success or failure feedback
-- from the action to be used to display feedback to the user.
--
-- The dynamic portion of the hook name, `$screen`, refers to the current screen ID.
--
-- @since 4.7.0
--
-- @param string $sendback The redirect URL.
-- @param string $doaction The action being taken.
-- @param To_Array  $items    The items to take the action on. Accepts an To_Array of IDs of posts,
--                            comments, terms, links, plugins, attachments, or users.
--
                              Sendback := Apply_Filters ("handle_bulk_actions-{$screen}",
                                                         Sendback, Doaction, Post_Ids.all);
                              -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
                           end;
                        end if; --      end case;

                        Sendback := +Remove_Query_Arg
                           (To_Array (To_List ((+"action", +"action2", +"tags_input",
                                                +"post_author", +"comment_status", +"ping_status",
                                                +"_status", +"post", +"bulk_edit", +"post_view"))),
                            -Sendback);

                        HB_Redirect (-Sendback);
                        return AWS.Response.URL (""); -- exit;  -- redirect
                     end;
                  end;

            elsif not Empty (Get (X_REQUEST, "_wp_http_referer")) then
               HB_Redirect (Remove_Query_Arg
                             (To_Array (To_List ((+"_wp_http_referer", +"_wpnonce"))),
                              HB_Unslash (Get (X_SERVER, "REQUEST_URI"))));
               return AWS.Response.URL (""); -- exit;  -- redirect
            end if;

            HB_List_Table.Prepare_Items; -- ();

            HB_Enqueue_Script ("inline-edit-post");
            HB_Enqueue_Script ("Heartbeat");

            if "wp_block" = Post_Type then
               HB_Enqueue_Script ("wp-list-reusable-blocks");
               HB_Enqueue_Style  ("wp-list-reusable-blocks");
            end if;

            declare
               --  Used in the HTML title tag.
               Title : String := -Post_Type_Object.Labels.Name;
            begin
               if "post" = Post_Type then
                  Get_Current_Screen.Add_Help_Tab ( -- ()
                        To_Array (List => (
                        Build ("id",    "overview"),
                        Build ("title", abs "Overview"),
                        Build ("content",
                               "<p>" & abs "This screen provides access to all of your posts. You can customize the display of this screen to suit your workflow." & "</p>") -- ,?
                        )));

                  Get_Current_Screen.Add_Help_Tab (
                        To_Array (List => (
                        Build ("id",    "screen-content"),
                        Build ("title", abs "Screen Content"),
                        Build ("content",
                               "<p>" & abs "You can customize the display of this screen&#8217;s contents in a number of ways:" & "</p>" &
                               "<ul>" &
                               "<li>" & abs "You can hide/display columns based on your needs and decide how many posts to list per screen using the Screen Options tab." & "</li>" &
                               "<li>" & abs "You can filter the list of posts by post status using the text links above the posts list to only show posts with that status. The default view is to show all posts." & "</li>" &
                               "<li>" & abs "You can view posts in a simple title list or with an excerpt using the Screen Options tab." & "</li>" &
                               "<li>" & abs "You can refine the list to show only posts in a specific category or from a specific month by using the dropdown menus above the posts list. Click the Filter button after making your selection. You also can refine the list by clicking on the post author, category or tag in the posts list." & "</li>" &
                                "</ul>")
                        )));

                  Get_Current_Screen.Add_Help_Tab (
                        To_Array (List => (
                         Build ("id",    "action-links"),
                         Build ("title", abs "Available Actions"),
                        Build ("content",
                               "<p>" & abs "Hovering over a row in the posts list will display action links that allow you to manage your post. You can perform the following actions:" & "</p>" &
                               "<ul>" &
                               "<li>" & abs "<strong>Edit</strong> takes you to the editing screen for that post. You can also reach that screen by clicking on the post title." & "</li>" &
                               "<li>" & abs "<strong>Quick Edit</strong> provides inline access to the metadata of your post, allowing you to update post details without leaving this screen." & "</li>" &
                               "<li>" & abs "<strong>Trash</strong> removes your post from this list and places it in the Trash, from which you can permanently delete it." & "</li>" &
                               "<li>" & abs "<strong>Preview</strong> will show you what your draft post will look like if you publish it. View will take you to your live site to view the post. Which link is available depends on your post&#8217;s status." & "</li>" &
                               "</ul>")
                        )));

                  Get_Current_Screen.Add_Help_Tab (
                        To_Array (List => (
                        Build ("id",    "bulk-actions"),
                        Build ("title", abs "Bulk actions"),
                        Build ("conten",
                               "<p>" & abs "You can also edit or move multiple posts to the Trash at once. Select the posts you want to act on using the checkboxes, then select the action you want to take from the Bulk actions menu and click Apply." & "</p>" &
                               "<p>" & abs "When using Bulk Edit, you can change the metadata (categories, author, etc.) for all selected posts at once. To remove a post from the grouping, just click the x next to its name in the Bulk Edit area that appears." & "</p>")
                        )));

                  Get_Current_Screen.Set_Help_Sidebar (
                "<p><strong>" & abs "For more information:" & "</strong></p>" &
                "<p>" & abs "<a href=""https://wordpress.org/support/article/posts-screen/"">Documentation on Managing Posts</a>" & "</p>" &
                "<p>" & abs "<a href=""https://wordpress.org/support/"">Support</a>" & "</p>"
                     );

               elsif "page" = Post_Type then
                  Get_Current_Screen.Add_Help_Tab (
                     To_Array (List => (
                        Build ("id",    "overview"),
                        Build ("title", abs "Overview"),
                        Build ("content",
                               "<p>" & abs "Pages are similar to posts in that they have a title, body text, and associated metadata, but they are different in that they are not part of the chronological blog stream, kind of like permanent posts. Pages are not categorized or tagged, but can have a hierarchy. You can nest pages under other pages by making one the &#8220;Parent&#8221; of the other, creating a group of pages." & "</p>")
                  )));

                  Get_Current_Screen.Add_Help_Tab (
                     To_Array (List => (
                        Build ("id",    "managing-pages"),
                        Build ("title", abs "Managing Pages"),
                        Build ("content",
                               "<p>" & abs "Managing pages is very similar to managing posts, and the screens can be customized in the same way." & "</p>" &
                               "<p>" & abs "You can also perform the same types of actions, including narrowing the list by using the filters, acting on a page using the action links that appear when you hover over a row, or using the Bulk actions menu to edit the metadata for multiple pages at once." & "</p>")
                  )));

                  Get_Current_Screen.Set_Help_Sidebar (
                "<p><strong>" & abs "For more information:" & "</strong></p>" &
                "<p>" & abs "<a href=""https://wordpress.org/support/article/pages-screen/"">Documentation on Managing Pages</a>" & "</p>" &
                "<p>" & abs "<a href=""https://wordpress.org/support/"">Support</a>" & "</p>"
                  );
               end if;
            end;

            Get_Current_Screen.Set_Screen_Reader_Content (
               To_Array (List => (
                Build ("heading_views",      -Post_Type_Object.Labels.Filter_Items_List),
                Build ("heading_pagination", -Post_Type_Object.Labels.Items_List_Navigation),
                Build ("heading_list",       -Post_Type_Object.Labels.Items_List)
            )));

            Add_Screen_Option (
               "per_page",
               To_Array (List => (
                  Build ("default", Natural'(20)'Image),
                  Build ("option",  "edit_" & Post_Type & "_per_page")
            )));

            declare
               Bulk_Counts : Array_Type
                  := To_Array (List => (
        Build ("updated",   (if Isset (String'(Get (X_REQUEST, "updated")))
                             then Absint (Get (X_REQUEST, "updated"))   else "0")),
        Build ("locked",    (if Isset (String'(Get (X_REQUEST, "locked")))
                             then Absint (Get (X_REQUEST, "locked"))    else "0")),
        Build ("deleted",   (if Isset (String'(Get (X_REQUEST, "deleted")))
                             then Absint (Get (X_REQUEST, "deleted"))   else "0")),
        Build ("trashed",   (if Isset (String'(Get (X_REQUEST, "trashed")))
                             then Absint (Get (X_REQUEST, "trashed"))   else "0")),
        Build ("untrashed", (if Isset (String'(Get (X_REQUEST, "untrashed")))
                             then Absint (Get (X_REQUEST, "untrashed")) else "0"))
               ));
               Bulk_Messages    : Array_Type := (1 .. 0 => <>); --          := To_Array; --  ();begin
            begin
               Set (Bulk_Messages, "post", abs To_Array (List => (    --  abs added
        -- translators: %s: Number of posts.
        Build ("updated", Plural ("%s post updated.",
                                     "%s posts updated.", Get (Bulk_Counts, "updated"))),
        Build ("locked", (if "1" = Get (Bulk_Counts, "locked")   --  1 -> "1"
                          then abs "1 post not updated, somebody is editing it."
                          -- translators: %s: Number of posts.
                          else Plural ("%s post not updated, somebody is editing it.",
                                       "%s posts not updated, somebody is editing them.",
                                        Get (Bulk_Counts, "locked")))),
        -- translators: %s: Number of posts.
        Build ("deleted",   Plural ("%s post permanently deleted.",
                                    "%s posts permanently deleted.",
                                    Get (Bulk_Counts, "deleted"))),
        -- translators: %s: Number of posts.
        Build ("trashed",   Plural ("%s post moved to the Trash.",
                                    "%s posts moved to the Trash.",
                                    Get (Bulk_Counts, "trashed"))),
        -- translators: %s: Number of posts.
        Build ("untrashed", Plural ("%s post restored from the Trash.",
                                    "%s posts restored from the Trash.",
                                    Get (Bulk_Counts, "untrashed")))
               )));

               Set (Bulk_Messages, "page", abs To_Array (List => (
        -- translators: %s: Number of pages.
        Build ("updated", Plural ("%s page updated.", "%s pages updated.", Get (Bulk_Counts, "updated"))),
        Build ("locked",  (if "1" = Get (Bulk_Counts, "locked")
                           then abs "1 page not updated, somebody is editing it."
                           -- translators: %s: Number of pages.
                           else Plural ("%s page not updated, somebody is editing it.",
                                        "%s pages not updated, somebody is editing them.",
                                        Get (Bulk_Counts, "locked")))),
        -- translators: %s: Number of pages.
        Build ("deleted", Plural ("%s page permanently deleted.",
                                  "%s pages permanently deleted.",
                                  Get (Bulk_Counts, "deleted"))),
        -- translators: %s: Number of pages.
        Build ("trashed", Plural ("%s page moved to the Trash.",
                                  "%s pages moved to the Trash.",
                                  Get (Bulk_Counts, "trashed"))),
        -- translators: %s: Number of pages. */
        Build ("untrashed", Plural ("%s page restored from the Trash.",
                                    "%s pages restored from the Trash.",
                                    Get (Bulk_Counts, "untrashed")))
               )));

               Set (Bulk_Messages, "wp_block", abs To_Array (List => (
        -- translators: %s: Number of blocks.
        Build ("updated", Plural ("%s block updated.",
                                  "%s blocks updated.",
                                  Get (Bulk_Counts, "updated"))),
        Build ("locked",  (if "1" = Get (Bulk_Counts, "locked")
                           then abs "1 block not updated, somebody is editing it."
                           -- translators: %s: Number of blocks.
                           else Plural ("%s block not updated, somebody is editing it.",
                                        "%s blocks not updated, somebody is editing them.",
                                        Get (Bulk_Counts, "locked")))),
        -- translators: %s: Number of blocks.
        Build ("deleted",   Plural ("%s block permanently deleted.",
                                    "%s blocks permanently deleted.",
                                    Get (Bulk_Counts, "deleted"))),
        -- translators: %s: Number of blocks.
        Build ("trashed",   Plural ("%s block moved to the Trash.",
                                    "%s blocks moved to the Trash.",
                                    Get (Bulk_Counts, "trashed"))),
        -- translators: %s: Number of blocks.
        Build ("untrashed", Plural ("%s block restored from the Trash.",
                                    "%s blocks restored from the Trash.",
                                    Get (Bulk_Counts, "untrashed")))
               )));

               --
               -- Filters the bulk action updated messages.
               --
               -- By default, custom post types use the messages for the 'post' post type.
               --
               -- @since 3.7.0
               --
               -- @param array $bulk_messages To_Arrays of messages, each keyed by the corresponding post type. Messages are
               --                               keyed with 'updated', 'locked', 'deleted', 'trashed', and 'untrashed'.
               -- @param int()   $bulk_counts   To_Array of item counts for each message, used to build internationalized strings.
               --
               Bulk_Messages := Apply_Filters ("bulk_post_updated_messages", Bulk_Messages, Bulk_Counts);  -- x => added
               Bulk_Counts   := Array_Filter  (Bulk_Counts);

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
                  begin
                     if Var_Name = "VAR_page_edit_h1" then
                        Insert (Translations, Assoc ("VAR_page_edit_h1",
                                                     ESC_HTML (-Post_Type_Object.Labels.Name)));

                     elsif Var_Name = "VAR_page_edit_h1_sub" then
                        declare
                           URL  : constant String := ESC_URL  (Admin_URL (Post_New_File));
                           HTML : constant String := ESC_HTML (-Post_Type_Object.Labels.Add_New);
                        begin
                           if Current_User_Can (Post_Type_Object.Cap.Create_Posts) then
                              Insert (Translations, Assoc ("VAR_page_edit_h1_sub",
                                                           " <a href=""" & URL & """ class=""page-title-action"">" & HTML & "</a>"));

                           end if;
                        end;

                        if
                          Isset (String'(Get (X_REQUEST, "s"))) and then
                          String'(Get (X_REQUEST, "s"))'Length /= 0
                        then
                           declare
                              Buffer : constant String
                                 := "<span class=""subtitle"">" &
                                    Printf (
                                            -- translators: %s: Search query.
                                            abs "Search results for: %s",
                                            "<strong>" & Get_Search_Query & "</strong>") & -- ()
                                    "</span>";
                           begin
                              Insert (Translations, Assoc ("VAR_page_edit_h1_sub", Buffer));
                           end;
                        end if;

                     elsif Var_Name = "VAR_page_edit_bulk" then
                        Insert (Translations, Assoc ("VAR_page_edit_bulk",
                                                     Var_Bulk (Bulk_Messages,
                                                               Bulk_Counts,
                                                               Post_Type)));

                     elsif Var_Name = "VAR_page_edit_views" then
                        Insert (Translations, Assoc ("VAR_page_edit_views",
                                                     HB_List_Table.Views)); -- ()

                     elsif Var_Name = "VAR_page_edit_search_box" then
                        Insert (Translations,
                           Assoc ("VAR_page_edit_search_box",
                                  HB_List_Table.Search_Box (-Post_Type_Object.Labels.Search_Items,
                                                            "post")));

                     elsif Var_Name = "VAR_page_edit_post_status" then
                        Insert (Translations,
                                Assoc ("VAR_page_edit_post_status",
                                       (if not Empty (Get (X_REQUEST, "post_status"))
                                        then ESC_Attr (String'(Get (X_REQUEST, "post_status")))
                                        else "all")));

                     elsif Var_Name = "VAR_page_edit_post_type" then
                        Insert (Translations, Assoc ("VAR_page_edit_post_status",
                                                     Post_Type));

                     elsif Var_Name = "VAR_page_edit_author" then
                        if not Empty (Get (X_REQUEST, "author")) then
                           declare
                              Author : constant String := ESC_Attrl (Get (X_REQUEST, "author"));
                           begin
                              Insert (Translations, Assoc ("VAR_page_edit_author",
                                                           "<input type=""hidden"" name=""author"" value=""" & Author & """ />"));
                           end;
                        end if;

                     elsif Var_Name = "VAR_page_edit_show_sticky" then
                        if not Empty (Get (X_REQUEST, "show_sticky")) then
                           Insert (Translations, Assoc ("VAR_page_edit_show_sticky",
                                                        "<input type=""hidden"" name=""show_sticky"" value=""1"" />"));
                        end if;

                     elsif Var_Name = "VAR_page_edit_display" then
                        Insert (Translations, Assoc ("VAR_page_edit_display",
                                                     HB_List_Table.Display));  -- ()

                     elsif Var_Name = "VAR_page_edit_inline_edit" then
                        if HB_List_Table.Has_Items then -- ()
                           Insert (Translations, Assoc ("VAR_page_edit_inline_edit",
                                                        HB_List_Table.Inline_Edit));  -- ();
                        end if;
                     end if;
                  end Value;

                  Lazy    : aliased My_Lazy;
                  Payload : constant Unbounded_String
                     := Templates_Parser.Parse ("page/hb-admin/edit.thtml",
                                                Translation,
                                                Lazy_Tag => Lazy'Unchecked_Access);
               begin
                  return AWS.Response.Build ("text/html", Payload); -- JQ
               end;
            end;
         end;
      end;
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

   --------------
   -- Var_Bulk --
   --------------

   function Var_Bulk (Bulk_Messages : Array_Type;
                      Bulk_Counts   : Array_Type;
                      Post_Type     : String) return String
   is
      Messages : Unbounded_String;
      -- Messages := array();
   begin
      -- If we have a bulk message to issue:
      for X of Bulk_Counts loop   -- foreach
--            for (Message, Count) of Bulk_Counts loop   -- foreach
         declare
            Count   : constant Natural := Natural'Value (-X.Key);   -- Count;
            Message : constant String  := -X.Value; -- Message;
         begin
            if Isset (String'(Get (Bulk_Messages, Post_Type, Message))) then
               Append (Messages, Sprintf (Get (Bulk_Messages, Post_Type, Message),
                                          Number_Format_I18n (Count)));
               -- Messages [] := Sprintf (Bulk_Messages [Post_Type] [Message],
               --                         Number_Format_I18n (Count));
            elsif Isset (String'(Get (Bulk_Messages, "post", Message))) then
               Append (Messages, Sprintf (Get (Bulk_Messages, "post", Message),
                                          Number_Format_I18n (Count)));
               -- Messages [] := Sprintf (Bulk_Messages ["post"] [Message ],
               --                         Number_Format_I18n (Count));
            end if;

            if "trashed" = Message and then Isset (String'(Get (X_REQUEST, "ids"))) then
               declare
                  Ids   : constant Integer := Preg_Replace ("/[^0-9,]/", "",
                                                            Get (X_REQUEST, "ids"));
                  URL_2 : constant String
                     := """edit?post_type=$post_type&doaction=undo&action=untrash&ids=" &
                        Ids'Image & """";
                  URL   : constant String  := ESC_URL (HB_Nonce_URL (URL_2, "bulk-posts"));
               begin
                  Append (Messages, "<a href=""" & URL & """>" & abs "Undo" & "</a>");
               end;
               -- Messages [] := "<a href=""" & Esc_Url (Hb_Nonce_Url
               -- ("""edit?post_type=$post_type&doaction=undo&action=untrash&ids=$ids""",
               -- "bulk-posts" )) & """>" & abs "Undo" & "</a>";
            end if;

            if "untrashed" = Message and then Isset (String'(Get (X_REQUEST, "ids"))) then
               declare
                  Ids : constant Assoc_List := Explode (",", Get (X_REQUEST, "ids"));
               begin
                  if 1 = Ids'Length and then Current_User_Can ("edit_post", Ids (0)) then
--                  if 1 = Count (Ids) and then Current_User_Can ("edit_post", Ids (0)) then
                     declare
                        Id   : constant Assoc_Type := Ids (Ids'First);
                        URL  : constant String     := ESC_URL (Get_Edit_Post_Link (Id));
                        Post : constant Post_Rec   := Get_Post_Type (Id);
                        HTML : constant String
                          := ESC_HTML (Get_Post_Type_Object (-Post.Labels.Edit_Item));
                     begin
                        Append (Messages, "<a href=""" & URL & "$s"">" & HTML & "$s</a>");
                     end;
                     -- Messages [] := Sprintf (
                     --               "<a href=""%1$s"">%2$s</a>",
                     --               Esc_Url  (Get_Edit_Post_Link ( Ids (0))),
                     --               Esc_Html (Get_Post_Type_Object (Get_Post_Type (Ids (0) ))
                     --                                               .Labels.Edit_Item)
                     --       );
                  end if;
               end;
            end if;
         end;
      end loop;

      if Messages /= "" then
         Append (Messages,
                 String'("<div id=""message"" class=""updated notice is-dismissible""><p>" &
                         Implode (" ", Messages) & "</p></div>"));
         -- echo "<div id=""message"" class=""updated notice is-dismissible""><p>" &
         -- Implode (" ", Messages) & "</p></div>";
      end if;
      -- unset( $messages );

      Set (X_SERVER, "REQUEST_URI",
           Remove_Query_Arg (To_Array (To_List ((+"locked", +"skipped",
                                         +"updated", +"deleted",
                                         +"trashed", +"untrashed"))),
                              Get (X_SERVER, "REQUEST_URI")));
      return "XXX-51";
   end Var_Bulk;

--  require_once ABSPATH . 'wp-admin/admin-header.php';
-- ?>

end HB_Edit;
