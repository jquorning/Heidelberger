--
-- Edit post administration panel.
--
-- Manage Post actions: post, edit, delete, etc.
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Strings.Fixed;

with Php.Arrays;
with Php.Strings;

with Arrays;
with Array_Lists;
with Binder;
with Constants;
with Globals;
with Helpers_3;
with Lists;
with UStrings;
with Wp_Common;

with Adm_Menu;

with Adi_Comments;
with Adi_Dashboard;
with Adi_Misc;
with Adi_Posts;

with Inc_Capabilities;
with Inc_Comments;
with Inc_Formatting;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Class_Posts;
with Class_Post_Type;
with Class_Users;
with Inc_L10n;
with Inc_Link_Templates;
with Inc_Pluggables;
with Inc_Posts;
with Inc_Users;

package body Adm_Post
is
   use Arrays;
   use Lists;

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Php.Arrays;
      use Php.Strings;
      use Array_Lists;
      use Binder;
      use Constants;
      use Globals;
      use Helpers_3;
      use UStrings;
      use Wp_Common;
      use Adm_Menu;
      use Adi_Posts;
      use Class_Posts;
      use Class_Users;
      use Inc_Capabilities;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_L10n;
      use Inc_Pluggables;
      use Inc_Posts;

      Post_New_File : UString;
      pragma Unreferenced (Post_New_File);
   begin
      Parent_File   := +Slug_Type'("edit.php");
      Submenu_File  := +"edit.php";

      Adi_Misc.Wp_Reset_Vars (["action"]);
      declare
         Id : Post_Id_Type;
      begin
         if
           Isset (XX_GET, "post")    and then
           Isset (X_POST, "post_ID") and then
           Integer'Value (Get_As_String (XX_GET, "post")) /=
           Integer'Value (Get_As_String (X_POST, "post_ID"))
         then
            Wp_Die
               (abs "A post ID mismatch has been detected.",
                abs "Sorry, you are not allowed to edit this item.", 400);

         elsif Isset (XX_GET, "post") then
            Id := Post_Id_Type (As_Integer (Get (XX_GET, "post")));

         elsif Isset (X_POST, "post_ID") then
            Id := Post_Id_Type (As_Integer (Get (X_POST, "post_ID")));

         else
            Id := 0;
         end if;
--  post_ID := Post_Id;

--
-- @global string  post_type
-- @global object  post_type_object
-- @global WP_Post post             Global post object.
--
-- global post_type, post_type_object, post;
         declare
            use Class_Post_Type;
            use Inc_Comments;
            use Inc_Link_Templates;

            Action   : UString;
            Sendback : UString;
         begin
            if Id /= 0 then
               Global_Post := Inc_Posts.Get_Post (Id);
            end if;

   --       if Post then
            Post_Type        := Global_Post.Post_Type;
            Post_Type_Object := Inc_Posts.Get_Post_Type_Object (-Post_Type);
   --       end if;

            if
              Isset (X_POST, "post_type") and then
   --         Post and then
              Post_Type /= Get_As_String (X_POST, "post_type")
            then
               Wp_Die
                  (abs "A post type mismatch has been detected.",
                   abs "Sorry, you are not allowed to edit this item.", 400);
            end if;

               if Isset (X_POST, "deletepost") then
                  Action := +"delete";
               elsif
                 Isset (X_POST, "wp-preview") and then
                 "dopreview" = Get_As_String (X_POST, "wp-preview")
               then
                  Action := +"preview";
               end if;

               Sendback := +Wp_Get_Referer;
               if
                 Sendback = "" or else
                 Ada.Strings.Fixed.Index (-Sendback, "post.php") = 0 or else
                 Ada.Strings.Fixed.Index (-Sendback, "post-new.php") = 0
               then
                  if "attachment" = Post_Type then
                     Sendback := +Admin_URL ("upload.php");
                  else
                     Sendback := +Admin_URL ("edit.php");
                     if not Empty (-Post_Type) then
                        Sendback := +Add_Query_Arg ("post_type",
                                                    -Post_Type, -Sendback);
                     end if;
                  end if;
               else
                  declare
                     List : constant List_Type :=
                       ["trashed", "untrashed", "deleted", "ids"];
                  begin
                     Sendback := +Remove_Query_Arg (List, -Sendback);
                  end;
               end if;

   -- switch (action) then
               if "post-quickdraft-save" = Action then
                  declare
                     -- Check nonce and capabilities.
                     Nonce     : constant String  := Get_As_String (X_REQUEST, "_wpnonce");
                     Error_Msg : UString; -- Boolean := false;
                  begin
                     -- For output of the Quick Draft dashboard widget.
   --                require_once ABSPATH . "wp-admin/includes/dashboard.php";

                     if Wp_Verify_Nonce (Nonce, "add-post") = 0 then
                        Error_Msg := +abs "Unable to submit this form, please refresh and try again.";
                     end if;

                     if
                       not Current_User_Can (Get_As_String (Inc_Posts.Get_Post_Type_Object ("post").Cap, "create_posts"))
                     then
                        goto Bailout;
                     end if;

                     if Error_Msg /= "" then
                        goto Bailout; -- return; -- Wp_Dashboard_Quick_Press (-Error_Msg);
                     end if;
                  end;

                  Global_Post :=
                    Inc_Posts.Get_Post (Post_Id_Type (As_Integer (Get (X_REQUEST, "post_ID"))));

                  Check_Admin_Referer ("add-" & (-Global_Post.Post_Type));

                  Set (X_POST, "comment_status",
                       From_String (Get_Default_Comment_Status (-Global_Post.Post_Type)));
                  Set (X_POST, "ping_status",
                       From_String (Get_Default_Comment_Status (-Global_Post.Post_Type, "pingback")));

                  -- Wrap Quick Draft content in the Paragraph block.
                  if Ada.Strings.Fixed.Index (Get_As_String (X_POST, "content"),
                                              "<!-- wp:paragraph -->") = 0
                  then
                     declare
                        Value_2 : constant String :=
                          Get_As_String (X_POST, "content");

                        Needle  : constant List_Type :=
                          ["\r\n", "\r", "\n"];

                        Value : constant String :=
                          Sprintf (
                             "<!-- wp:paragraph -->%s<!-- /wp:paragraph -->",
                              [1 => Str_Replace (Needle, "<br />", Value_2)]
                          );
                     begin
                        Set (X_POST, "content", From_String (Value));
                     end;
                  end if;

                  declare
                     use Adi_Dashboard;

                     Unused : Integer := Edit_Post;
                  begin
                     Wp_Dashboard_Quick_Press;
                  end;

                  goto Bailout;

               elsif Action = "post" or Action = "postajaxpost" then
                  Check_Admin_Referer ("add-" & (-Post_Type));
                  declare
                     Post_Id : constant Integer := (if "postajaxpost" = Action
                                                    then Edit_Post else Write_Post);
                  begin
                     Redirect_Post (Post_Id);
                  end;
                  goto Bailout;

               elsif Action = "edit" then
                  if Id = 0 then -- .key added
                     Wp_Redirect (Admin_URL ("post.php"));
                     goto Bailout;
                  end if;

                  if Global_Post = Null_Post then
                     Wp_Die
                       (abs "You attempted to edit an item that does not exist. Perhaps it was deleted?");
                  end if;

                  if Post_Type_Object = Null_Post_Type then
                     Wp_Die (abs "Invalid post type.");
                  end if;

                  if
                    not In_Array (-Globals.Global_Typenow,
                                  Inc_Posts.Get_Post_Types
                                    (To_Array_Type ([Build ("show_ui", "true")])),
                                  True)
                  then
                     Wp_Die
                       (abs "Sorry, you are not allowed to edit posts in this post type.");
                  end if;

                  if not Current_User_Can ("edit_post", Integer (Id)) then
                     Wp_Die
                       (abs "Sorry, you are not allowed to edit this item.");
                  end if;

                  if "trash" = Global_Post.Post_Status then
                     Wp_Die
                        (abs "You cannot edit this item because it is in the Trash. Please restore it and try again.");
                  end if;

                  if not Empty (Get_As_String (XX_GET, "get-post-lock")) then
                     Check_Admin_Referer ("lock-post_" & Image (Id));
                     declare
                        Unused : Array_Type := Wp_Set_Post_Lock (Integer (Id));
                     begin
                        Wp_Redirect
                           (Get_Edit_Post_Link (Id, "url"));
--                         (Get_Edit_Post_Link (Build (image (Post_Id), "url")));
                     end;
                     goto Bailout;
                  end if;

                  Post_Type := Global_Post.Post_Type;
                  if "post" = Post_Type then
                     Parent_File   := +"edit.php";
                     Submenu_File  := +"edit.php";
                     Post_New_File := +"post-new.php";
                  elsif "attachment" = Post_Type then
                     Parent_File   := +"upload.php";
                     Submenu_File  := +"upload.php";
                     Post_New_File := +"media-new.php";
                  else
                     if
--                     Isset (Post_Type_Object) and then
--                     Post_Type_Object.Show_In_Menu_Bool and then
                       True /= Post_Type_Object.Show_In_Menu_Bool
                     then
                        Parent_File :=
                          Unbounded_Slug (Post_Type_Object.Show_In_Menu);
                     else
                        Parent_File := +"edit.php?post_type=post_type";
                     end if;
                     Submenu_File  := +"edit.php?post_type=post_type";
                     Post_New_File := +"post-new.php?post_type=post_type";
                  end if;

                  Globals.Global_Title :=
                    +Get (Post_Type_Object, "labels.edit_item");

                  --
                  -- Allows replacement of the editor.
                  --
                  -- @since 4.9.0
                  --
                  -- @param bool    replace Whether to replace the editor. Default
                  --                false.
                  -- @param WP_Post post    Post object.
                  --
                  if
                    True = Apply_Filters ("replace_editor", "false", Global_Post)
                  then -- false
                     goto Label_1; -- break;
                  end if;

                  if Use_Block_Editor_For_Post (Global_Post) then
--                        require ABSPATH . "wp-admin/edit-form-blocks.php";
                     goto Label_1; -- break;
                  end if;

                  if 0 = Wp_Check_Post_Lock (Image (Global_Post.Id)) then
                     declare
                        Active_Post_Lock : Array_Type :=
                           Wp_Set_Post_Lock (Integer (Global_Post.Id));
                        pragma Unreferenced (Active_Post_Lock);
                     begin
                        if "attachment" /= Post_Type then
                           Wp_Enqueue_Script ("autosave");
                        end if;
                     end;
                  end if;

                  Global_Post := Inc_Posts.Get_Post (Id, "OBJECT", "edit");

                  if Post_Type_Supports (-Post_Type, "comments") then
                     Wp_Enqueue_Script ("admin-comments");
                     Adi_Comments.Enqueue_Comment_Hotkeys_Js;
                  end if;
--                require ABSPATH . "wp-admin/edit-form-advanced.php";
                  <<Label_1>>

               elsif Action = "editattachment" then
                  Check_Admin_Referer ("update-post_" & Image (Id));

                  -- Don't let these be changed.
                  Delete (Ref (X_POST, "guid"));
                  Set (X_POST, "post_type", From_String ("attachment"));

                  -- Update the thumbnail filename.
                  declare
                     use Inc_Formatting;

                     Unused  : Integer;
                     Newmeta : Array_Type :=
                        Wp_Get_Attachment_Metadata (Id, True);
                  begin
                     Set (Newmeta, "thumb",
                          From_String (Wp_Basename (Get_As_String (X_POST, "thumb"))));

                     Unused := Wp_Update_Attachment_Metadata (Id, Newmeta);
                  end;
                  -- Intentional fall-through to trigger the edit_post() call.

               elsif Action = "editpost" then
                  Check_Admin_Referer ("update-post_" & Image (Id));

                  Id := Post_Id_Type (Edit_Post); --();

                  -- Session cookie flag that the post was saved.
                  if
                    Isset (Get_As_String (X_COOKIE, "wp-saving-post")) -- and then
                  then
                     Set (X_COOKIE, "wp-saving-post",
                          From_String (Image (Id) & "-check"));
--                  Setcookie ("wp-saving-post", Image (Post_Id) & "-saved", time + DAY_IN_SECONDS, ADMIN_COOKIE_PATH, COOKIE_DOMAIN, Is_Ssl); -- ssl());
                  end if;

                  Redirect_Post (Integer (Id));
                  -- Send user on their way while we keep working.

                  goto Bailout;

               elsif Action = "trash" then
                  Check_Admin_Referer ("trash-post_" & Image (Id));

                  if Global_Post = Null_Post then
                     Wp_Die
                        (abs "The item you are trying to move to the Trash no longer exists.");
                  end if;

                  if Post_Type_Object = Null_Post_Type then
                     Wp_Die (abs "Invalid post type.");
                  end if;

                  if not Current_User_Can ("delete_post", Integer (Id)) then
                     Wp_Die
                       (abs "Sorry, you are not allowed to move this item to the Trash.");
                  end if;

                  declare
                     User_Id : constant User_Id_Type :=
                       Wp_Check_Post_Lock (Image (Id));
                  begin
                     if User_Id /= 0 then
                        declare
                           User : constant Wp_User := Get_Userdata (User_Id);
                        begin
                           -- translators: %s: User"s display name.
                           Wp_Die (
                             Sprintf (
                               abs "You cannot move this item to the Trash. %s is currently editing.",
                               [1 => -User.Prop.Display_Name]));
                        end;
                     end if;

                     if not Wp_Trash_Post (Image (Id)) then
                        Wp_Die
                           (abs "Error in moving the item to Trash.");
                     end if;

                     Wp_Redirect (
                        Add_Query_Arg (
                          To_Array_Type ([
                            Build ("trashed", "1"),
                            Build ("ids",     Image (Id))
                          ]),
                          -Sendback));
                  end;
                  goto Bailout;

               elsif Action = "untrash" then
                  Check_Admin_Referer ("untrash-post_" & Image (Id));

                  if Global_Post = Null_Post then
                     Wp_Die
                       (abs "The item you are trying to restore from the Trash no longer exists.");
                  end if;

                  if Post_Type_Object = Null_Post_Type then
                     Wp_Die (abs "Invalid post type.");
                  end if;

                  if not Current_User_Can ("delete_post", Global_Post) then
                     Wp_Die (abs "Sorry, you are not allowed to restore this item from the Trash.");
                  end if;

                  if not Inc_Posts.Wp_Untrash_Post (Global_Post) then
                     Wp_Die
                        (abs "Error in restoring the item from Trash.");
                  end if;

                  Sendback := +Add_Query_Arg (
                           To_Array_Type ([
                              Build ("untrashed", "1"),
                              Build ("ids",       Image (Id))
                           ]),
                           -Sendback);
                  Wp_Redirect (-Sendback);
                  goto Bailout;

               elsif Action = "delete" then
                  Check_Admin_Referer ("delete-post_" & Image (Id));

                  if Global_Post = Null_Post then
                     Wp_Die (abs "This item has already been deleted.");
                  end if;

                  if Post_Type_Object = Null_Post_Type then
                     Wp_Die (abs "Invalid post type.");
                  end if;

                  if not Current_User_Can ("delete_post", Integer (Id)) then
                     Wp_Die
                        (abs "Sorry, you are not allowed to delete this item.");
                  end if;

                  if "attachment" = Global_Post.Post_Type then
                     declare
                        Force : constant Boolean := not MEDIA_TRASH;
                     begin
                        if Wp_Delete_Attachment (Id, Force) = Null_Post then
                           Wp_Die
                              (abs "Error in deleting the attachment.");
                        end if;
                     end;
                  else
                     if Wp_Delete_Post (Id, True) = Null_Post then
                        Wp_Die (abs "Error in deleting the item.");
                     end if;
                  end if;

                  Wp_Redirect (
                    Add_Query_Arg ("deleted", "1", -Sendback));
                  goto Bailout;

               elsif Action = "preview" then
                  Check_Admin_Referer ("update-post_" & Image (Id));
                  declare
                     URL : constant String := Post_Preview;
                  begin
                     Wp_Redirect (URL);
                  end;
                  goto Bailout;

               elsif Action = "toggle-custom-fields" then
                  Check_Admin_Referer ("toggle-custom-fields",
                                       "toggle-custom-fields-nonce");
                  declare
                     use Inc_Users;

                     Unused   : Boolean;
                     Unused_2 : Integer;

                     Current_User_Id : constant Class_Users.User_Id_Type :=
                       Get_Current_User_Id;
                  begin
                     if Current_User_Id not in 0 then
                        declare
                           Enable_Custom_Fields : constant Boolean
                              := Get_User_Meta (Current_User_Id,
                                                "enable_custom_fields", True);
                        begin
                           Unused_2 := Update_User_Meta (Current_User_Id,
                                                         "enable_custom_fields",
                                                         not Enable_Custom_Fields);
                        end;
                     end if;
                     Unused := Wp_Safe_Redirect (Wp_Get_Referer);
                  end;
                  goto Bailout;

               else
                  --
                  -- Fires for a given custom post action request.
                  --
                  -- The dynamic portion of the hook name, `action`, refers to the
                  -- custom post action.
                  --
                  -- @since 4.6.0
                  --
                  -- @param int post_id Post ID sent with the request.
                  --
                  Do_Action ("post_action_" & (-Action), Image (Id));

                  Wp_Redirect (Admin_URL ("edit.php"));
                  goto Bailout;
               end if;
         end;
      end;

--  require_once ABSPATH . "wp-admin/admin-footer.php";

      <<Bailout>>

--    Clear_Echo;
   end Render;

end Adm_Post;
