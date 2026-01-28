--
--  Edit Posts Administration Screen.
--
--  @package Heidelberger
--  @subpackage Administration
--

with Ada.Containers;

with Php.Arrays;
with Php.Echoing;
with Php.Errors;
with Php.Numerics;
with Php.Preg;
with Php.Strings;
with Php.Types;

with Templates_Parser;

with Arrays;
with Binder;
with Globals;
with UStrings;
with Lists;
with Wp_Common;

with Adm_Admin;
with Adm_Admin_Header;
with Adm_Menu;

with Adi_Class_Wp_Posts_List_Tables;
with Adi_Class_Wp_Screens;
with Adi_List_Tables;
with Adi_Posts;
with Adi_Screens;

with Class_Posts;
with Class_Post_Type;
with Class_WpDB;
with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_Functions_Wp_Styles;
with Inc_General_Templates;
with Inc_L10n;
with Inc_Link_Templates;
with Inc_Plugins;
with Inc_Pluggables;
with Inc_Posts;

package body Adm_Edit
is
   use Arrays;
   use Lists;

   function Var_Bulk (Bulk_Messages : Array_Type;
                      Bulk_Counts   : Array_Type;
                      Post_Type     : String) return String;

   function Translation
      return Templates_Parser.Translate_Table;

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Php.Arrays;
      use Php.Echoing;
      use Php.Numerics;
      use Php.Preg;
      use Php.Strings;
      use Php.Types;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Class_Posts;
      use Class_Post_Type;
      use Class_WpDB;
      use Inc_Capabilities;
      use Inc_Functions_Wp_Scripts;
      use Inc_Functions_Wp_Styles;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Plugins;
      use Inc_Posts;
--
--  @global string       $post_type
--  @global WP_Post_Type $post_type_object
--
--  global $post_type, $post_type_object;

      Post_Type        : UString renames Globals.Post_Type;
      Post_Type_Object : Wp_Post_Type     renames Globals.Post_Type_Object;
--         := Inc_Posts.Get_Post_Type_Object (Post_Type);
   begin
      Adm_Admin.Run;
-- WordPress Administration Bootstrap
--  require_once __DIR__ . '/admin.php';

--
-- @global string $typenow The post type of the current screen.
--
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

      Post_Type        := Globals.Typenow;
      Post_Type_Object := Inc_Posts.Get_Post_Type_Object (-Post_Type);
--  if Post_Type_Object = 0   -- not
--   Wp_Die (abs  "Invalid post type.");
--  end if;

      if False then
--    if not Current_User_Can (Get (Post_Type_Object.Cap, "edit_posts")) then
         Inc_Functions.Wp_Die
           ("<h1>" & abs "You need a higher level of permission."  & "</h1>" &
            "<p>"  & abs "Sorry, you are not allowed to edit posts in this post type." &
            "</p>",
            Code => 403);
      end if;

      declare
         use Adi_Class_Wp_Posts_List_Tables;
         use Adi_List_Tables;

         X_Wp_List_Table : Wp_Posts_List_Table :=
            Wp_Posts_List_Table (X_Get_List_Table ("Wp_Posts_List_Table"));

         Pagenum         : constant Natural := X_Wp_List_Table.Get_Pagenum; -- ();
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
            use Adm_Menu;

            Doaction : String := X_Wp_List_Table.Current_Action; -- ();
         begin
            Parent_File :=
              +Slug_Type (if "post" = Post_Type then Slug_Type'("edit")
                          else "edit?post_type=" & (-Post_Type));

            Submenu_File :=
              +Slug_Type (if "post" = Post_Type then Slug_Type'("edit")
                          else "edit?post_type=" & (-Post_Type));

            Globals.Post_New_File := +(if "post" = Post_Type then "post-new"
                                       else "post-new?post_type=" & (-Post_Type));

            if Doaction = "" then   -- if doaction then
               Inc_Pluggables.Check_Admin_Referer ("bulk-posts");
                  declare
--                   use String_Vectors;
                     use Inc_Functions;

                     List_2 : constant List_Type :=
                       ["trashed", "untrashed", "deleted", "locked",  "ids"];

                     Sendback : UString
                       := +Remove_Query_Arg (List_2, Wp_Get_Referer);
                  begin
                     if Sendback = "" then   -- not
                        Sendback := +Admin_URL (String (-Parent_File));
                     end if;

                     Sendback := +Add_Query_Arg ("paged", Pagenum'Image, -Sendback);
                     if Strpos (-Sendback, "post.php") /= 0 then
                        Sendback := +Admin_URL (-Globals.Post_New_File);
                     end if;

                     declare
--                      use Array_Maps;

                        Post_Ids    : List_Type; --  := To_Array; -- ()
                        Post_Status : UString;
                     begin
                        if "delete_all" = Doaction then
                        -- Prepare for deletion of all posts with a specified post status
                        -- (i.e. Empty Trash).
                           Post_Status :=
                              +Preg_Replace (
                                 Pattern     => "/(^a-z0-9_-)+/i",
                                 Replacement => "",
                                 Subject     => As_String (Get (X_REQUEST,
                                                                "post_status")));

                           -- Validate the post status exists.
                           if
                             Inc_Posts.Get_Post_Status_Object (-Post_Status)
                                /= Null_Status
                           then
                              --
                              -- @global wpdb $wpdb WordPress database abstraction
                              -- object.
                              --
                              -- global $wpdb;
                              --
                              Post_Ids := Globals.WpDB.Get_Col (
                                 Globals.WpDB.Prepare (
                                   "SELECT ID FROM " & Statement_Type (-Post_Type) &
                                   " WHERE post_type=%s AND post_status = %s",
                                   [
                                     1 => -Post_Type,
                                     2 => -Post_Status
                                   ]
                                 ));
                           end if;
                           Doaction := "delete";

                        elsif Isset (X_REQUEST, "media") then
                           Post_Ids := As_List (Get (X_REQUEST, "media"));

                        elsif Isset (X_REQUEST, "ids") then
                           Post_Ids := Explode (",", Get_As_String (X_REQUEST, "ids"));

                        elsif not Empty (As_String (Get (X_REQUEST, "post"))) then
                           Post_Ids := List_Type'(
                             Array_Map (Intval'Access,
                                        As_Array (Get (X_REQUEST, "post"))));
                        end if;

                        if Post_Ids.Is_Empty then
                           Inc_Pluggables.Wp_Redirect (-Sendback);
                           return; -- exit;  -- redirect
                        end if;

                        if "trash" = Doaction then
--              when "trash" =>
                           declare
                              use Adi_Posts;

                              Trashed : Natural := 0;
                              Locked  : Natural := 0;
                           begin
                              for Post_Id of Post_Ids loop -- foreach (To_Array)
                                 if not Current_User_Can ("delete_post", Post_Id) then
                                    Inc_Functions.Wp_Die
                                      (abs "Sorry, you are not allowed to move this item to the Trash.");
                                 end if;

                                 if Wp_Check_Post_Lock (Post_Id) not in 0 then
                                    Locked := Locked + 1;
                                    goto Continue;
                                 end if;

                                 if not Wp_Trash_Post (Post_Id) then
                                    Inc_Functions.Wp_Die
                                      (abs "Error in moving the item to Trash.");
                                 end if;

                                 Trashed := Trashed + 1;
                                 <<Continue>>
                              end loop;

                              Sendback := +Add_Query_Arg (
                                To_Array (List => (
                                        Build ("trashed", Trashed'Image),
--                                        Build ("ids",     Implode (",", Post_Ids)),
                                        Build ("locked",  Locked'Image)
                                )),
                                -Sendback);
                           end;

                        elsif "untrash" = Doaction then
--              when "untrash" =>
                           declare
                              Untrashed : Natural := 0;
                           begin
                              if
                                Isset (As_String (Get (XX_GET, "doaction"))) and then
                                "undo" = As_String (Get (XX_GET, "doaction"))
                              then
                                 Add_Filter
                                   ("wp_untrash_post_status",
                                    Inc_Posts.Wp_Untrash_Post_Set_Previous_Status'Access,
                                    10, 3);
                              end if;

                              for Post_Id of Post_Ids loop
                                 if not Current_User_Can ("delete_post", Post_Id) then
                                    Inc_Functions.Wp_Die
                                      (abs "Sorry, you are not allowed to restore this item from the Trash.");
                                 end if;

                                 if not Inc_Posts.Wp_Untrash_Post (Post_Id) then
                                    Inc_Functions.Wp_Die
                                      (abs "Error in restoring the item from Trash.");
                                 end if;

                                 Untrashed := Untrashed + 1;
                              end loop;
                              Sendback := +Add_Query_Arg ("untrashed", Untrashed'Image, -Sendback);

                              Remove_Filter ("wp_untrash_post_status",
                                             "wp_untrash_post_set_previous_status", 10);
                           end;

                        elsif "delete" = Doaction then
--              when "delete" =>
                           declare
                              Deleted : Natural := 0;
                           begin
                              for Id of Post_Ids loop
                                 declare
                                    Post_Del : constant Wp_Post :=
                                      Inc_Posts.Get_Post (Post_Id'Value (Id));
                                 begin
                                    if not Current_User_Can ("delete_post", Id) then
                                       Inc_Functions.Wp_Die
                                          (abs "Sorry, you are not allowed to delete this item.");
                                    end if;

                                    if "attachment" = Post_Del.Post_Type then
                                       if Wp_Delete_Attachment (Integer'Value (Id)) = Null_Post then
                                          Inc_Functions.Wp_Die
                                             (abs "Error in deleting the attachment.");
                                       end if;
                                    else
                                       if Wp_Delete_Post (Integer'Value (Id)) = Null_Post then
                                          Inc_Functions.Wp_Die
                                            (abs "Error in deleting the item.");
                                       end if;
                                    end if;
                                    Deleted := Deleted + 1;
                                 end;
                              end loop;
                              Sendback := +Add_Query_Arg ("deleted", Deleted'Image, -Sendback);
                           end;

                        elsif "edit" = Doaction then
--              when "edit" =>
                           if Isset (As_String (Get (X_REQUEST, "bulk_edit"))) then
                              declare
                                 Done : Array_Type :=
                                    Adi_Posts.Bulk_Edit_Posts (
                                       As_Array (Get (X_REQUEST, "")));
                                 -- (item => ) added
                              begin
                                 if Is_Array (Done) then
                                    Set (Done, "updated",
                                         From_Integer (Get_As_String (Done, "updated")'Length));
                                    Set (Done, "skipped",
                                         From_Integer (Get_As_String (Done, "skipped")'Length));
                                    Set (Done, "locked",
                                         From_Integer (Get_As_String (Done, "locked")'Length));
                                    Sendback := +Add_Query_Arg (Done, -Sendback);
                                 end if;
                              end;
                           end if;

                        else
--              when others =>
                           declare
                              use Adi_Screens;

                              Screen : constant String := -Get_Current_Screen.Id;
--                              Screen : constant Screen_Id := -Get_Current_Screen.Id;
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
-- @param array  $items    The items to take the action on. Accepts an To_Array of IDs of posts,
--                            comments, terms, links, plugins, attachments, or users.
--
                              Sendback := +Apply_Filters
                                 (Hook_Name => "handle_bulk_actions-" & Screen,
                                  Value     => -Sendback,
                                  D         => Doaction,
                                  P         => Post_Ids);
                              -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
                           end;
                        end if; --      end case;

                        declare
                           List : constant List_Type :=
                             ["action", "action2", "tags_input", "post_author",
                              "comment_status", "ping_status", "_status", "post",
                              "bulk_edit", "post_view"];
                        begin
                           Sendback := +Remove_Query_Arg (List, -Sendback);
                        end;
                        Inc_Pluggables.Wp_Redirect (-Sendback);
                        return; -- exit;  -- redirect
                     end;
                  end;

            elsif Isset (X_REQUEST, "_wp_http_referer") then
--          elsif not Empty (String'(Get (X_REQUEST, "_wp_http_referer"))) then
               declare
                  use Inc_Formatting;
                  use Inc_Functions;
--                use String_Vectors;

                  List : constant List_Type :=
                    ["_wp_http_referer", "_wpnonce"];
               begin
                  Inc_Pluggables.Wp_Redirect
                            (Remove_Query_Arg
                             (List,
                              Wp_Unslash (As_String (Get (X_SERVER, "REQUEST_URI")))));
               end;
               return; -- exit;  -- redirect
            end if;

            X_Wp_List_Table.Prepare_Items; -- ();

            Wp_Enqueue_Script ("inline-edit-post");
            Wp_Enqueue_Script ("Heartbeat");

            if "wp_block" = Post_Type then
               Wp_Enqueue_Script ("wp-list-reusable-blocks");
               Wp_Enqueue_Style  ("wp-list-reusable-blocks");
            end if;

            declare
               use Adi_Screens;
            begin
               --  Used in the HTML title tag.
               Globals.Title := +Wp_Common.Get (Post_Type_Object, "labels.name");

               if "post" = Post_Type then
                  Get_Current_Screen.Add_Help_Tab ( -- ()
                        Arrays.To_Array (List => (
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

               Get_Current_Screen.Set_Screen_Reader_Content (
                  To_Array (List => (
                   Build ("heading_views",
                          Wp_Common.Get (Post_Type_Object, "labels.filter_items_list")),
                   Build ("heading_pagination",
                          Wp_Common.Get (Post_Type_Object, "labels.items_list_navigation")),
                   Build ("heading_list",
                          Wp_Common.Get (Post_Type_Object, "labels.items_list"))
               )));

               Add_Screen_Option (
                  "per_page",
                  To_Array (List => (
                     Build ("default", Natural'(20)'Image),
                     Build ("option",  "edit_" & (-Post_Type) & "_per_page")
               )));
            end;

            declare
               Bulk_Counts : Array_Type
                  := To_Array (List => (
        Build ("updated",   (if Isset (X_REQUEST, "updated")
                             then abs As_Integer (Get (X_REQUEST, "updated")) else 0)),
        Build ("locked",    (if Isset (X_REQUEST, "locked")
                             then abs As_Integer (Get (X_REQUEST, "locked")) else 0)),
        Build ("deleted",   (if Isset (X_REQUEST, "deleted")
                             then abs As_Integer (Get (X_REQUEST, "deleted")) else 0)),
        Build ("trashed",   (if Isset (X_REQUEST, "trashed")
                             then abs As_Integer (Get (X_REQUEST, "trashed")) else 0)),
        Build ("untrashed", (if Isset (X_REQUEST, "untrashed")
                             then abs As_Integer (Get (X_REQUEST, "untrashed")) else 0))
               ));
               Bulk_Messages    : Array_Type := Empty_Array; --          := To_Array; --  ();begin
            begin
               Set (Bulk_Messages, "post", From_Array (To_Array (List => (    --  abs added
        -- translators: %s: Number of posts.
        Build ("updated", X_N ("%s post updated.",
                               "%s posts updated.",
                               As_Integer (Get (Bulk_Counts, "updated")))),
        Build ("locked", (if 1 = As_Integer (Get (Bulk_Counts, "locked"))
                          then abs "1 post not updated, somebody is editing it."
                          -- translators: %s: Number of posts.
                          else X_N ("%s post not updated, somebody is editing it.",
                                    "%s posts not updated, somebody is editing them.",
                                    As_Integer (Get (Bulk_Counts, "locked"))))),
        -- translators: %s: Number of posts.
        Build ("deleted",   X_N ("%s post permanently deleted.",
                                 "%s posts permanently deleted.",
                                 As_Integer (Get (Bulk_Counts, "deleted")))),
        -- translators: %s: Number of posts.
        Build ("trashed",   X_N ("%s post moved to the Trash.",
                                 "%s posts moved to the Trash.",
                                 As_Integer (Get (Bulk_Counts, "trashed")))),
        -- translators: %s: Number of posts.
        Build ("untrashed", X_N ("%s post restored from the Trash.",
                                 "%s posts restored from the Trash.",
                                 As_Integer (Get (Bulk_Counts, "untrashed"))))
               ))));

               Set (Bulk_Messages, "page", From_Array (To_Array (List => (
        -- translators: %s: Number of pages.
        Build ("updated", X_N ("%s page updated.",
                               "%s pages updated.",
                               As_Integer (Get (Bulk_Counts, "updated")))),
        Build ("locked",  (if 1 = As_Integer (Get (Bulk_Counts, "locked"))
                           then abs "1 page not updated, somebody is editing it."
                           -- translators: %s: Number of pages.
                           else X_N ("%s page not updated, somebody is editing it.",
                                     "%s pages not updated, somebody is editing them.",
                                     As_Integer (Get (Bulk_Counts, "locked"))))),
        -- translators: %s: Number of pages.
        Build ("deleted", X_N ("%s page permanently deleted.",
                               "%s pages permanently deleted.",
                               As_Integer (Get (Bulk_Counts, "deleted")))),
        -- translators: %s: Number of pages.
        Build ("trashed", X_N ("%s page moved to the Trash.",
                               "%s pages moved to the Trash.",
                               As_Integer (Get (Bulk_Counts, "trashed")))),
        -- translators: %s: Number of pages. */
        Build ("untrashed", X_N ("%s page restored from the Trash.",
                                 "%s pages restored from the Trash.",
                                 As_Integer (Get (Bulk_Counts, "untrashed"))))
               ))));

               Set (Bulk_Messages, "wp_block", From_Array (To_Array (List => (
        -- translators: %s: Number of blocks.
        Build ("updated", X_N ("%s block updated.",
                               "%s blocks updated.",
                               As_Integer (Get (Bulk_Counts, "updated")))),
        Build ("locked",  (if 1 = As_Integer (Get (Bulk_Counts, "locked"))
                           then abs "1 block not updated, somebody is editing it."
                           -- translators: %s: Number of blocks.
                           else X_N ("%s block not updated, somebody is editing it.",
                                     "%s blocks not updated, somebody is editing them.",
                                     As_Integer (Get (Bulk_Counts, "locked"))))),
        -- translators: %s: Number of blocks.
        Build ("deleted",   X_N ("%s block permanently deleted.",
                                 "%s blocks permanently deleted.",
                                 As_Integer (Get (Bulk_Counts, "deleted")))),
        -- translators: %s: Number of blocks.
        Build ("trashed",   X_N ("%s block moved to the Trash.",
                                 "%s blocks moved to the Trash.",
                                  As_Integer (Get (Bulk_Counts, "trashed")))),
        -- translators: %s: Number of blocks.
        Build ("untrashed", X_N ("%s block restored from the Trash.",
                                 "%s blocks restored from the Trash.",
                                 As_Integer (Get (Bulk_Counts, "untrashed"))))
               ))));

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
               Bulk_Messages
                  := Apply_Filters (Hook_Name => "bulk_post_updated_messages",
                                    Value     => Bulk_Messages,
                                    Arg_3     => Bulk_Counts);  -- x => added
               Bulk_Counts   := Array_Filter  (Bulk_Counts);

               declare
--                use Ada.Text_IO;
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

                     procedure Set (Var : String; Value : String) is
                     begin
                        Insert (Translations, Assoc (Var, Value));
                     end Set;

                     use Inc_Formatting;
                  begin
                     if Var_Name = "VAR_page_edit_h1" then
                        Insert (Translations,
                                Assoc ("VAR_page_edit_h1",
                                       ESC_HTML (Wp_Common.Get (Post_Type_Object,
                                                      "labels.name"))));

                     elsif Var_Name = "VAR_page_edit_h1_sub" then
                        declare
                           URL  : constant String :=
                              ESC_URL  (Admin_URL (-Globals.Post_New_File));
                           HTML : constant String :=
                              ESC_HTML (String'(Wp_Common.Get (Post_Type_Object,
                                                     "labels.add_new")));
                        begin
                           if
                             False
--                           Current_User_Can (Get (Post_Type_Object.Cap,
--                                                  "create_posts"))
                           then
                              Set ("VAR_page_edit_h1_sub",
                                   " <a href=""" & URL &
                                   """ class=""page-title-action"">" & HTML &
                                   "</a>");
                           end if;
                        end;
                        if
                          Isset (X_REQUEST, "s") and then
--                        Isset (String'(Get (X_REQUEST, "s"))) and then
                          As_String (Get (X_REQUEST, "s"))'Length /= 0
                        then
                           declare
                              use Inc_General_Templates;

                              Buffer : constant String
                                 := "<span class=""subtitle"">" &
                                    Printf (
                                      -- translators: %s: Search query.
                                      abs "Search results for: %s",
                                      ["<strong>" & Get_Search_Query & "</strong>"]) &
                                      "</span>";
                           begin
                              Set ("VAR_page_edit_h1_sub", Buffer);
                           end;
                        end if;

                     elsif Var_Name = "VAR_page_edit_bulk" then
                        Set ("VAR_page_edit_bulk",
                             Var_Bulk (Bulk_Messages, Bulk_Counts, -Post_Type));

                     elsif Var_Name = "VAR_page_edit_views" then
                        Clear_Echo;
                        X_Wp_List_Table.Views;
                        Set ("VAR_page_edit_views", Get_Echo);

                     elsif Var_Name = "VAR_page_edit_search_box" then
                        Clear_Echo;
                        X_Wp_List_Table.Search_Box (
                          "XXX-794",
--                        String'(Get (Post_Type_Object.Labels,
--                                               "search_items")),
                           "post");
                        Set ("VAR_page_edit_search_box", Get_Echo);

                     elsif Var_Name = "VAR_page_edit_post_status" then
                        Set ("VAR_page_edit_post_status",
                            (if Isset (X_REQUEST, "post_status")
                             then ESC_Attr (As_String (Get (X_REQUEST, "post_status")))
                             else "all"));

                     elsif Var_Name = "VAR_page_edit_post_type" then
                        Set ("VAR_page_edit_post_type", -Post_Type);

                     elsif Var_Name = "VAR_page_edit_author" then
                        if Isset (X_REQUEST, "author") then
                           declare
                              Author : constant String :=
                                ESC_Attr (As_String (Get (X_REQUEST, "author")));
                           begin
                              Set
                                ("VAR_page_edit_author",
                                 "<input type=""hidden"" name=""author"" value=""" &
                                 Author & """ />");
                           end;
                        end if;

                     elsif Var_Name = "VAR_page_edit_show_sticky" then
                        if Isset (X_REQUEST, "show_sticky") then
                           Set ("VAR_page_edit_show_sticky",
                                "<input type=""hidden"" name=""show_sticky"" value=""1"" />");
                        end if;

                     elsif Var_Name = "VAR_page_edit_display" then
                        Clear_Echo;
                        X_Wp_List_Table.Display;
                        Set ("VAR_page_edit_display", Get_Echo);

                     elsif Var_Name = "VAR_page_edit_inline_edit" then
                        if X_Wp_List_Table.Has_Items then -- ()
                           X_Wp_List_Table.Inline_Edit;  -- ();
                           Set ("VAR_page_edit_inline_edit", "XXX-462");

                        end if;
                     end if;
                  end Value;

                  Lazy    : aliased My_Lazy;
                  Payload : constant UString
                     := Templates_Parser.Parse ("page/admin/edit.thtml",
                                                Translation,
                                                Lazy_Tag => Lazy'Unchecked_Access);
               begin
                  Clear_Echo;

                  Adm_Admin_Header.Run;
--  require_once ABSPATH . 'wp-admin/admin-header.php';

                  Echo (-Payload);
               end;
            end;
         end;
      end;
   exception
      when Php.Errors.Program_Termination =>
         null;
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
      use Ada.Containers;
      use Php.Preg;
      use Php.Strings;
      use Binder;
      use UStrings;
      use Inc_Capabilities;
      use Inc_L10n;

      Messages : UString;
      -- Messages := array();
   begin
      -- If we have a bulk message to issue:
      for X in Bulk_Counts.Iterate loop   -- foreach
         declare
            use Inc_Functions;
--          use Array_Maps;

            Count   : constant Natural := Natural'Value (Key (X));
            Message : constant String  := As_String (Get (Bulk_Counts, Key (X)));
            Message_Array : Array_Type renames As_Array (Get (Bulk_Messages, Post_Type));
            Post_Array    : Array_Type renames As_Array (Get (Bulk_Messages, Post_Type));
         begin
            if Isset (Message_Array, Message) then
--          if Isset (String'(Get (Bulk_Messages, Post_Type, Message))) then
               Append (Messages,
                       Sprintf (As_String (Get (Message_Array, Message)),
                                [Number_Format_I18n (Float (Count))]));
               -- Messages [] := Sprintf (Bulk_Messages [Post_Type] [Message],
               --                         Number_Format_I18n (Count));
            elsif Isset (Post_Array, Message) then
               Append (Messages,
                       Sprintf (As_String (Get (Post_Array, Message)),
                                [Number_Format_I18n (Float (Count))]));
               -- Messages [] := Sprintf (Bulk_Messages ["post"] [Message ],
               --                         Number_Format_I18n (Count));
            end if;

            if "trashed" = Message and then Isset (X_REQUEST, "ids") then
               declare
                  use Inc_Formatting;

                  Ids   : constant Integer :=
                    Preg_Replace ("/[^0-9,]/", "",
                      As_Array (Get (X_REQUEST, "ids")));

                  URL_2 : constant String :=
                     """edit?post_type=$post_type&doaction=undo&action=untrash&ids=" &
                     Ids'Image & """";

                  URL : constant String :=
                    ESC_URL (Wp_Nonce_URL (URL_2, "bulk-posts"));
               begin
                  Append (Messages, "<a href=""" & URL & """>" & abs "Undo" & "</a>");
               end;
               -- Messages [] := "<a href=""" & Esc_Url (Hb_Nonce_Url
               -- ("""edit?post_type=$post_type&doaction=undo&action=untrash&ids=$ids""",
               -- "bulk-posts" )) & """>" & abs "Undo" & "</a>";
            end if;

            if "untrashed" = Message and then Isset (X_REQUEST, "ids") then
               declare
                  use List_Vectors;

                  Ids : constant List_Type :=
                     Explode (",", Get_As_String (X_REQUEST, "ids"));
               begin
                  if
                    1 = Length (Ids) and then
                    Current_User_Can ("edit_post", Ids.First_Element) --  (Ids'First))
                  then
--                  if 1 = Count (Ids) and then Current_User_Can ("edit_post", Ids (0)) then
                     declare
                        use Inc_Formatting;
                        use Inc_Link_Templates;
                        use Class_Posts;

                        Id   : constant Post_Id := Post_Id'Value (Ids.First_Element);

                        URL  : constant String  :=
                           ESC_URL (Get_Edit_Post_Link (Integer (Id)));

                        Post : constant String  := -- Inc_Class_Posts.Wp_Post :=
                           Inc_Posts.Get_Post_Type (Id);

                        HTML : constant String := "XXX-251";
--                        ESC_HTML (Inc_Posts.Get_Post_Type_Object
--                                   (Get (A => Post, Key => "labels.edit_item")));
                     begin
                        Append (Messages,
                                Sprintf ("<a href=""%1$s"">%2$s</a>",
                                  [
                                    1 => URL,
                                    2 => HTML
                                  ]));
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
                         Implode (" ", -Messages) & "</p></div>"));
         -- echo "<div id=""message"" class=""updated notice is-dismissible""><p>" &
         -- Implode (" ", Messages) & "</p></div>";
      end if;
      -- unset( $messages );

      declare
         use Inc_Functions;
--       use String_Vectors;

         List : constant List_Type :=
           ["locked", "skipped", "updated", "deleted", "trashed", "untrashed"];
      begin
         Set (X_SERVER, "REQUEST_URI",
              From_String (
                Remove_Query_Arg (List, As_String (Get (X_SERVER, "REQUEST_URI")))));
      end;
      return "XXX-51";
   end Var_Bulk;

end Adm_Edit;
