--
-- Edit post administration panel.
--
-- Manage Post actions: post, edit, delete, etc.
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Strings.Unbounded;
with Ada.Strings.Fixed;

--  with Templates_Parser;

with L10n;
with Arrays;
with Globals;
with Php;
with HB_Common;

with Adi_Posts;
with Inc_Capabilities;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_Class_Wp_Posts;
with Inc_Class_Wp_Post_Type;
with Inc_Class_Wp_Users;
with Inc_Link_Templates;
with Inc_Pluggables;
with Inc_Posts;
with Inc_Users;

-- WordPress Administration Bootstrap
-- require_once __DIR__ . '/admin.php';

package body Adm_Post
is
   use Ada.Strings.Unbounded;
   use Arrays;
   use L10n;
   use HB_Common;
   use Php;
   use Globals;

   function Render (Request : in AWS.Status.Data)
                    return AWS.Response.Data
   is
      use Adi_Posts;
      use Inc_Capabilities;
      use Inc_Functions_Wp_Scripts;
      use Inc_Posts;

      Parent_File   : Unbounded_String := +"edit.php";
      Submenu_File  : Unbounded_String := +"edit.php";
      Post_New_File : Unbounded_String;
   begin

      Wp_Reset_Vars (To_Array ("action"));
      declare
         Post_Id : Integer; -- String := "test"; -- Integer; -- test added
      begin
         if
           Isset (String'(Get (XX_GET, "post"))) and then
           Isset (String'(Get (X_POST, "post_ID"))) and then
           Integer'Value (String'(Get (XX_GET, "post"))) /=
           Integer'Value (String'(Get (X_POST, "post_ID")))
         then
            Inc_Functions.Wp_Die
               (abs "A post ID mismatch has been detected.",
                abs "Sorry, you are not allowed to edit this item.", 400);
         elsif Isset (String'(Get (XX_GET, "post"))) then
            Post_Id := Get_Integer (XX_GET, "post");
         elsif (Isset (String'(Get (X_POST, "post_ID")))) then
            Post_Id := Get_Integer (X_POST, "post_ID");
         else
            Post_Id := 0; -- "    ";
         end if;
--  post_ID := Post_Id;

--
-- @global string  post_type
-- @global object  post_type_object
-- @global WP_Post post             Global post object.
--
-- global post_type, post_type_object, post;
      declare
         use Inc_Class_Wp_Posts;
         use Inc_Class_Wp_Post_Type;
         use Inc_Link_Templates;

         Post_Type        : String := "";
         Post_Type_Object : Inc_Class_Wp_Post_Type.Wp_Post_Type;
         Post             : Inc_Class_Wp_Posts.Wp_Post;
         Action   : Unbounded_String;
         Sendback : Unbounded_String;
      begin
         if Post_Id /= 0 then  -- "    " then
            Post := Inc_Posts.Get_Post (Post_Id);
         end if;

--       if Post then
         Post_Type        := -Post.Post_Type;
         Post_Type_Object := Inc_Posts.Get_Post_Type_Object (Post_Type);
--       end if;

         if
           Isset (String'(Get (X_POST, "post_type"))) and then
--         Post and then
           Post_Type /= Get (X_POST, "post_type")
         then
            Inc_Functions.Wp_Die
               (abs "A post type mismatch has been detected.",
                abs "Sorry, you are not allowed to edit this item.", 400);
            end if;

            if Isset (String'(Get (X_POST, "deletepost"))) then
               Action := +"delete";
            elsif
              Isset (String'(Get (X_POST, "wp-preview"))) and then
              "dopreview" = String'(Get (X_POST, "wp-preview"))
            then
               Action := +"preview";
            end if;

            Sendback := +Inc_Functions.Wp_Get_Referer;  -- ();
            if
              Sendback = "" or else
              Ada.Strings.Fixed.Index (-Sendback, "post.php") = 0 or else
              Ada.Strings.Fixed.Index (-Sendback, "post-new.php") = 0
            then
               if "attachment" = Post_Type then
                  Sendback := +Admin_URL ("upload.php");
               else
                  Sendback := +Admin_URL ("edit.php");
                  if not Empty (Post_Type) then
                     Sendback := +Add_Query_Arg ("post_type",
                                                 Post_Type, -Sendback);
                  end if;
               end if;
            else
               declare
                  use String_Vectors;
                  use Inc_Functions;

                  Arg : constant String_Array := Empty_String_Array &
                                                 "trashed"   &
                                                 "untrashed" &
                                                 "deleted"   &
                                                 "ids";
               begin
                  Sendback := +Remove_Query_Arg (Arg, -Sendback);
               end;
            end if;

-- switch (action) then
            if "post-quickdraft-save" = Action then
               declare
                  -- Check nonce and capabilities.
                  Nonce     : constant String  := Get (X_REQUEST, "_wpnonce");
                  Error_Msg : Unbounded_String; -- Boolean := false;
               begin
                  -- For output of the Quick Draft dashboard widget.
--                require_once ABSPATH . "wp-admin/includes/dashboard.php";

                  if not Wp_Verify_Nonce (Nonce, "add-post") then
                     Error_Msg := +abs "Unable to submit this form, please refresh and try again.";
                  end if;

                  if
                    not Current_User_Can (Get (Inc_Posts.Get_Post_Type_Object ("post").Cap, "create_posts"))
                  then
                     goto Bailout; -- return;  -- exit;
                  end if;

                  if Error_Msg /= "" then
                    goto Bailout; -- return; -- Wp_Dashboard_Quick_Press (-Error_Msg);
                  end if;
               end;
               Post := Inc_Posts.Get_Post (Get_Integer (X_REQUEST, "post_ID"));
               Inc_Pluggables.Check_Admin_Referer ("add-" & (-Post.Post_Type));

               Set (X_POST, "comment_status",
                    Get_Default_Comment_Status (-Post.Post_Type));
               Set (X_POST, "ping_status",
                    Get_Default_Comment_Status (-Post.Post_Type, "pingback"));

               -- Wrap Quick Draft content in the Paragraph block.
               if Ada.Strings.Fixed.Index (Get (X_POST, "content"),
                                           "<!-- wp:paragraph -->") = 0
               then
                  Set (X_POST, "content",
                       Sprintf (
                                "<!-- wp:paragraph -->%s<!-- /wp:paragraph -->",
                                Str_Replace (To_List ((+"\r\n",
                                                       +"\r",
                                                       +"\n")),
                                             "<br />",
                                              Get (X_POST, "content"))
                        ));
               end if;

               declare
                  Unused_1 : String := Edit_Post;   -- ();
                  Unused_2 : String := Wp_Dashboard_Quick_Press; -- ();
               begin
                  null;
               end;
               goto Bailout; -- return;  -- exit;

            elsif Action = "post" or Action = "postajaxpost" then
               Inc_Pluggables.Check_Admin_Referer ("add-" & Post_Type);
               declare
                  Post_Id : String := (if "postajaxpost" = Action
                                       then Edit_Post else Write_Post);
               begin
                  Redirect_Post (Post_Id);
               end;
               goto Bailout; -- return; -- exit;

            elsif Action = "edit" then
               declare
                  Editing : Boolean := True;
               begin
                  if Post_Id = 0 then -- .key added
                     Inc_Pluggables.Wp_Redirect (Admin_URL ("post.php"));
                     goto Bailout; -- return; -- exit;
                  end if;

                  if Post = Null_Post then
                     Inc_Functions.Wp_Die
                       (abs "You attempted to edit an item that does not exist. Perhaps it was deleted?");
                  end if;

                  if Post_Type_Object = Null_Post_Type then
                     Inc_Functions.Wp_Die (abs "Invalid post type.");
                  end if;

                  if
                    not In_Array (-Globals.Typenow,
                                  Inc_Posts.Get_Post_Types
                                    (To_Array (List => (1 => Build ("show_ui", "true")))),
                                  True)
                  then
                     Inc_Functions.Wp_Die
                       (abs "Sorry, you are not allowed to edit posts in this post type.");
                  end if;

                  if not Current_User_Can ("edit_post", Post_Id) then
                     Inc_Functions.Wp_Die
                       (abs "Sorry, you are not allowed to edit this item.");
                  end if;

                  if "trash" = Post.Post_Status then
                     Inc_Functions.Wp_Die
                        (abs "You cannot edit this item because it is in the Trash. Please restore it and try again.");
                  end if;

                  if not Empty (String'(Get (XX_GET, "get-post-lock"))) then
                     Inc_Pluggables.Check_Admin_Referer ("lock-post_" & Post_Id'Image);
                     declare
                        Unused : Array_Type := Wp_Set_Post_Lock (Post_Id);
                     begin
                        Inc_Pluggables.Wp_Redirect
                           (Get_Edit_Post_Link (Build (Post_Id'Image, "url")));
                     end;
                     goto Bailout; -- return; -- exit;
                  end if;

                  Post_Type := -Post.Post_Type;
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
--                       Isset (Post_Type_Object) and then
--                       Post_Type_Object.Show_In_Menu_Bool and then
                       True /= Post_Type_Object.Show_In_Menu_Bool
                     then
                        Parent_File := Post_Type_Object.Show_In_Menu;
                     else
                        Parent_File := +"edit.php?post_type=post_type";
                     end if;
                     Submenu_File  := +"edit.php?post_type=post_type";
                     Post_New_File := +"post-new.php?post_type=post_type";
                  end if;

                  declare
                     Title : String := Get (Post_Type_Object, "labels.edit_item");
                  begin
                     null;
                  end;

                  --
                  -- Allows replacement of the editor.
                  --
                  -- @since 4.9.0
                  --
                  -- @param bool    replace Whether to replace the editor. Default false.
                  -- @param WP_Post post    Post object.
                  --
                  if True = Apply_Filters ("replace_editor", "false", Post) then -- false
                     goto Label_1; -- break;
                  end if;

                  if Use_Block_Editor_For_Post (Post) then
--                        require ABSPATH . "wp-admin/edit-form-blocks.php";
                    goto Label_1; -- break;
                  end if;

                  if 0 = Wp_Check_Post_Lock (Post.Id'Image) then
                     declare
                        Active_Post_Lock : array_Type :=
                           Wp_Set_Post_Lock (Integer (Post.Id));
                     begin
                        if "attachment" /= Post_Type then
                           Wp_Enqueue_Script ("autosave");
                        end if;
                     end;
                  end if;

                  Post := Inc_Posts.Get_Post (Post_Id, "OBJECT", "edit");

                  if Post_Type_Supports (Post_Type, "comments") then
                     Wp_Enqueue_Script ("admin-comments");
                     Enqueue_Comment_Hotkeys_JS; --();
                  end if;
               end;
--                require ABSPATH . "wp-admin/edit-form-advanced.php";
               <<Label_1>>

            elsif Action = "editattachment" then
               Inc_Pluggables.Check_Admin_Referer ("update-post_" & Post_Id'Image);

               -- Don"t let these be changed.
               Unset (Get (X_POST, "guid"));
               Set (X_POST, "post_type", "attachment");

               -- Update the thumbnail filename.
               declare
                  Newmeta : Array_Type :=
                     Wp_Get_Attachment_Metadata (Post_Id'Image, True);
               begin
                  Set (Newmeta, "thumb", Wp_Basename (Get (X_POST, "thumb")));

                  Wp_Update_Attachment_Metadata (Post_Id'Image, Newmeta);
               end;
               -- Intentional fall-through to trigger the edit_post() call.

            elsif Action = "editpost" then
               Inc_Pluggables.Check_Admin_Referer ("update-post_" & Post_Id'Image);

               Post_Id := Integer'Value (Edit_Post); --();

               -- Session cookie flag that the post was saved.
               if
                 Isset (String'(Get (X_COOKIE, "wp-saving-post"))) -- and then
               then
                  Set (X_COOKIE, "wp-saving-post", Post_Id'Image & "-check");
--                Setcookie ("wp-saving-post", Post_Id'Image & "-saved", time + DAY_IN_SECONDS, ADMIN_COOKIE_PATH, COOKIE_DOMAIN, Is_Ssl); -- ssl());
               end if;

               Redirect_Post (Post_Id'Image);
               -- Send user on their way while we keep working.

               goto Bailout; -- return; -- exit;

            elsif Action = "trash" then
               Inc_Pluggables.Check_Admin_Referer ("trash-post_" & Post_Id'Image);

               if Post = Null_Post then
                  Inc_Functions.Wp_Die
                     (abs "The item you are trying to move to the Trash no longer exists.");
               end if;

               if Post_Type_Object = Null_Post_Type then
                  Inc_Functions.Wp_Die (abs "Invalid post type.");
               end if;

               if not Current_User_Can ("delete_post", Post_Id) then
                  Inc_Functions.Wp_Die
                    (abs "Sorry, you are not allowed to move this item to the Trash.");
               end if;

               declare
                  use Inc_Pluggables;

                  User_Id : constant Integer := Wp_Check_Post_Lock (Post_Id'Image);
               begin
                  if User_Id /= 0 then
                     declare
                        use Inc_Class_Wp_Users;

                        User : constant Wp_User := Get_Userdata (User_Id);
                     begin
                        -- translators: %s: User"s display name.
                        Inc_Functions.Wp_Die
                           (Sprintf (abs "You cannot move this item to the Trash. %s is currently editing.", "XXX-362")); -- -User.Display_Name));
                     end;
                  end if;

                  if not Wp_Trash_Post (Post_Id'Image) then
                     Inc_Functions.Wp_Die (abs "Error in moving the item to Trash.");
                  end if;

                  Inc_Pluggables.Wp_Redirect (
                        -Add_Query_Arg (
                                To_Array (List => (
                                        Build ("trashed", "1"),
                                        Build ("ids",     Post_Id'Image)
                                )),
                                Sendback
                        )
                  );
               end;
               goto Bailout; -- return; --  exit;

            elsif Action = "untrash" then
               Inc_Pluggables.Check_Admin_Referer ("untrash-post_" & Post_Id'Image);

               if Post = Null_Post then
                  Inc_Functions.Wp_Die
                    (abs "The item you are trying to restore from the Trash no longer exists.");
               end if;

               if Post_Type_Object = Null_Post_Type then
                  Inc_Functions.Wp_Die (abs "Invalid post type.");
               end if;

               if not Current_User_Can ("delete_post", Post) then
                  Inc_Functions.Wp_Die (abs "Sorry, you are not allowed to restore this item from the Trash.");
               end if;

               if not Inc_Posts.Wp_Untrash_Post (Post) then
                  Inc_Functions.Wp_Die (abs "Error in restoring the item from Trash.");
               end if;

               Sendback := Add_Query_Arg (
                        To_Array (List => (
                                Build ("untrashed", "1"),
                                Build ("ids",       Post_Id'Image)
                        )),
                        Sendback
               );
               Inc_Pluggables.Wp_Redirect (-Sendback);
               goto Bailout; -- return; -- exit;

            elsif Action = "delete" then
               Inc_Pluggables.Check_Admin_Referer ("delete-post_" & Post_Id'Image);

               if Post = Null_Post then
                  Inc_Functions.Wp_Die (abs "This item has already been deleted.");
               end if;

               if Post_Type_Object = Null_Post_Type then
                  Inc_Functions.Wp_Die (abs "Invalid post type.");
               end if;

               if not Current_User_Can ("delete_post", Post_Id) then
                  Inc_Functions.Wp_Die (abs "Sorry, you are not allowed to delete this item.");
               end if;

               if "attachment" = Post.Post_Type then
                  declare
                     Force : constant Boolean := not MEDIA_TRASH;
                  begin
                     if Wp_Delete_Attachment (Post_Id, Force) = Null_Post then
                        Inc_Functions.Wp_Die (abs "Error in deleting the attachment.");
                     end if;
                  end;
               else
                  if Wp_Delete_Post (Post_Id, True) = Null_Post then
                     Inc_Functions.Wp_Die (abs "Error in deleting the item.");
                  end if;
               end if;

               Inc_Pluggables.Wp_Redirect (-Add_Query_Arg ("deleted", 1, Sendback));
               goto Bailout; -- return; -- exit;

            elsif Action = "preview" then
               Inc_Pluggables.Check_Admin_Referer ("update-post_" & Post_Id'Image);
               declare
                  URL : constant String := Post_Preview; -- ();
               begin
                  Inc_Pluggables.Wp_Redirect (URL);
               end;
               goto Bailout; -- return; -- exit;

            elsif Action = "toggle-custom-fields" then
               Inc_Pluggables.Check_Admin_Referer ("toggle-custom-fields",
                                                   "toggle-custom-fields-nonce");
               declare
                  use Inc_Users;

                  Current_User_Id : constant Integer := Get_Current_User_Id; -- ();
               begin
                  if 0 /= Current_User_Id then
                     declare
                        Enable_Custom_Fields : constant Boolean
                           := Get_User_Meta (Current_User_Id,
                                             "enable_custom_fields", True);
                     begin
                        Update_User_Meta (Current_User_Id, "enable_custom_fields",
                                          not Enable_Custom_Fields);
                     end;
                  end if;
               end;
               Wp_Safe_Redirect (Inc_Functions.Wp_Get_Referer); -- ()
               goto Bailout; -- return; -- exit;

            else
               --
               -- Fires for a given custom post action request.
               --
               -- The dynamic portion of the hook name, `action`, refers to the custom post action.
               --
               -- @since 4.6.0
               --
               -- @param int post_id Post ID sent with the request.
               --
               Do_Action ("post_action_" & (-Action), Post_Id'Image);

               Inc_Pluggables.Wp_Redirect (Admin_URL ("edit.php"));
               goto Bailout; -- return; -- exit;
            end if; -- End switch.
         end;
      end;

--  require_once ABSPATH . "wp-admin/admin-footer.php";

<<Bailout>>

      return AWS.Response.Build ("text/html", "");

   end Render;

end Adm_Post;
