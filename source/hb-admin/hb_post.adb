
with Ada.Strings.Unbounded;
with Ada.Strings.Fixed;

--  with Templates_Parser;

with L10n;

with HB_Common;
--
-- Edit post administration panel.
--
-- Manage Post actions: post, edit, delete, etc.
--
-- @package WordPress
-- @subpackage Administration
--

-- WordPress Administration Bootstrap
-- require_once __DIR__ . '/admin.php';

package body HB_Post
is
   use Ada.Strings.Unbounded;
   use L10n;
   use HB_Common;

   function Render (Request : in AWS.Status.Data)
                    return AWS.Response.Data
   is
      Parent_File   : Unbounded_String := +"edit.php";
      Submenu_File  : Unbounded_String := +"edit.php";
      Post_New_File : Unbounded_String;
   begin

      HB_Reset_Vars (To_Array ("action"));
      declare
         Post_Id : String := "test"; -- Integer; -- test added
      begin
         if
           Isset (String'(Get (X_GET, "post"))) and then
           Isset (String'(Get (X_POST, "post_ID"))) and then
           Integer'Value (String'(Get (X_GET, "post"))) /=
           Integer'Value (String'(Get (X_POST, "post_ID")))
         then
            HB_Die (abs "A post ID mismatch has been detected.",
                    abs "Sorry, you are not allowed to edit this item.", 400);
         elsif Isset (String'(Get (X_GET, "post"))) then
            Post_Id := String'(Get (X_GET, "post"));
         elsif (Isset (String'(Get (X_POST, "post_ID")))) then
            Post_Id := String'(Get (X_POST, "post_ID"));
         else
            Post_Id := "";
         end if;
--  post_ID := Post_Id;

--
-- @global string  post_type
-- @global object  post_type_object
-- @global WP_Post post             Global post object.
--
-- global post_type, post_type_object, post;
      declare
         Post_Type        : String := "";
         Post_Type_Object : Post_Rec;
         Post             : HB_Post_2;
         Action   : Unbounded_String;
         Sendback : Unbounded_String;
      begin
         if Post_Id /= "" then
            Post := Get_Post (Post_Id);
         end if;

--       if Post then
         Post_Type        := -Post.Post_Type;
         Post_Type_Object := Get_Post_Type_Object (Post_Type);
--       end if;

         if
           Isset (String'(Get (X_POST, "post_type"))) and then
--         Post and then
           Post_Type /= Get (X_POST, "post_type")
         then
            HB_Die (abs "A post type mismatch has been detected.",
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

            Sendback := +HB_Get_Referer;  -- ();
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
               Sendback := +Remove_Query_Arg (To_Array (To_List ((+"trashed",
                                                                  +"untrashed",
                                                                  +"deleted",
                                                                  +"ids"))),
                                              -Sendback);
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

                  if not HB_Verify_Nonce (Nonce, "add-post") then
                     Error_Msg := +abs "Unable to submit this form, please refresh and try again.";
                  end if;

                  if not Current_User_Can (Get_Post_Type_Object ("post").Cap.Create_Posts) then
                     goto Bailout; -- return;  -- exit;
                  end if;

                  if Error_Msg /= "" then
                    goto Bailout; -- return; -- HB_Dashboard_Quick_Press (-Error_Msg);
                  end if;
               end;
               Post := Get_Post (Get (X_REQUEST, "post_ID"));
               Check_Admin_Referer ("add-" & (-Post.Post_Type));

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
                                Str_Replace (To_Array (To_List ((+"\r\n", +"\r", +"\n"))),
                                             "<br />",
                                              Get (X_POST, "content"))
                        ));
               end if;

               declare
                  Unused_1 : String := Edit_Post;   -- ();
                  Unused_2 : String := HB_Dashboard_Quick_Press; -- ();
               begin
                  null;
               end;
               goto Bailout; -- return;  -- exit;

            elsif Action = "post" or Action = "postajaxpost" then
               Check_Admin_Referer ("add-" & Post_Type);
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
                  if Empty (Post_Id) then -- .key added
                     HB_Redirect (Admin_URL ("post.php"));
                     goto Bailout; -- return; -- exit;
                  end if;

                  if not Post then
                     HB_Die (abs "You attempted to edit an item that does not exist. Perhaps it was deleted?");
                  end if;

                  if not Post_Type_Object then
                     HB_Die (abs "Invalid post type.");
                  end if;

                  if
                    not In_Array (Item => Typenow,
                                  Tax  => Get_Post_Types
                                          (To_Array (List => (1 => Build ("show_ui", "true")))),
                                  V    => True)
                  then
                     HB_Die (abs "Sorry, you are not allowed to edit posts in this post type.");
                  end if;

                  if not Current_User_Can ("edit_post", Post_Id) then
                     HB_Die (abs "Sorry, you are not allowed to edit this item.");
                  end if;

                  if "trash" = Post.Post_Status then
                     HB_Die (abs "You cannot edit this item because it is in the Trash. Please restore it and try again.");
                  end if;

                  if not Empty (String'(Get (X_GET, "get-post-lock"))) then
                     Check_Admin_Referer ("lock-post_" & Post_Id);
                     declare
                        Unused : Lock_Type := HB_Set_Post_Lock (Post_Id);
                     begin
                        HB_Redirect (Get_Edit_Post_Link (Build (Post_Id, "url")));
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
                       Isset (Post_Type_Object) and then
                       Post_Type_Object.Show_In_Menu and then
                       True /= Post_Type_Object.Show_In_Menu
                     then
                        Parent_File := +(Post_Type_Object.Show_In_Menu'Image);
                     else
                        Parent_File := +"edit.php?post_type=post_type";
                     end if;
                     Submenu_File  := +"edit.php?post_type=post_type";
                     Post_New_File := +"post-new.php?post_type=post_type";
                  end if;

                  declare
                     Title : String := -Post_Type_Object.Labels.Edit_Item;
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

                  if 0 = HB_Check_Post_Lock (-Post.ID) then
                     declare
                        Active_Post_Lock : Lock_Type := HB_Set_Post_Lock (-Post.ID);
                     begin
                        if "attachment" /= Post_Type then
                           HB_Enqueue_Script ("autosave");
                        end if;
                     end;
                  end if;

                  Post := Get_Post (Post_Id, OBJECT, "edit");

                  if Post_Type_Supports (Post_Type, "comments") then
                     HB_Enqueue_Script ("admin-comments");
                     Enqueue_Comment_Hotkeys_JS; --();
                  end if;
               end;
--                require ABSPATH . "wp-admin/edit-form-advanced.php";
               <<Label_1>>

            elsif Action = "editattachment" then
               Check_Admin_Referer ("update-post_" & Post_Id);

               -- Don"t let these be changed.
               Unset (Get (X_POST, "guid"));
               Set (X_POST, "post_type", "attachment");

               -- Update the thumbnail filename.
               declare
                  Newmeta : Array_Type := HB_Get_Attachment_Metadata (Post_Id, True);
               begin
                  Set (Newmeta, "thumb", HB_Basename (Get (X_POST, "thumb")));

                  HB_Update_Attachment_Metadata (Post_Id, Newmeta);
               end;
               -- Intentional fall-through to trigger the edit_post() call.

            elsif Action = "editpost" then
               Check_Admin_Referer ("update-post_" & Post_Id);

               Post_Id := Edit_Post; --();

               -- Session cookie flag that the post was saved.
               if
                 Isset (String'(Get (X_COOKIE, "wp-saving-post"))) -- and then
               then
                  Set (X_COOKIE, "wp-saving-post", Post_Id & "-check");
--                Setcookie ("wp-saving-post", Post_Id'Image & "-saved", time + DAY_IN_SECONDS, ADMIN_COOKIE_PATH, COOKIE_DOMAIN, Is_Ssl); -- ssl());
               end if;

               Redirect_Post (Post_Id); -- Send user on their way while we keep working.

               goto Bailout; -- return; -- exit;

            elsif Action = "trash" then
               Check_Admin_Referer ("trash-post_" & Post_Id);

               if not Post then
                  HB_Die (abs "The item you are trying to move to the Trash no longer exists.");
               end if;

               if not Post_Type_Object then
                  HB_Die (abs "Invalid post type.");
               end if;

               if not Current_User_Can ("delete_post", Post_Id) then
                  HB_Die (abs "Sorry, you are not allowed to move this item to the Trash.");
               end if;

               declare
                  User_Id : constant Integer := HB_Check_Post_Lock (Post_Id);
               begin
                  if User_Id /= 0 then
                     declare
                        User : constant User_Type := Get_Userdata (User_Id);
                     begin
                        -- translators: %s: User"s display name.
                        HB_Die (Sprintf (abs "You cannot move this item to the Trash. %s is currently editing.", -User.Display_Name));
                     end;
                  end if;

                  if not HB_Trash_Post (Post_Id) then
                     HB_Die (abs "Error in moving the item to Trash.");
                  end if;

                  HB_Redirect (
                        -Add_Query_Arg (
                                To_Array (List => (
                                        Build ("trashed", "1"),
                                        Build ("ids",     Post_Id)
                                )),
                                Sendback
                        )
                  );
               end;
               goto Bailout; -- return; --  exit;

            elsif Action = "untrash" then
               Check_Admin_Referer ("untrash-post_" & Post_Id);

               if not Post then
                  HB_Die (abs "The item you are trying to restore from the Trash no longer exists.");
               end if;

               if not Post_Type_Object then
                  HB_Die (abs "Invalid post type.");
               end if;

               if not Current_User_Can ("delete_post", Post) then
                  HB_Die (abs "Sorry, you are not allowed to restore this item from the Trash.");
               end if;

               if not HB_Untrash_Post (Post) then
                  HB_Die (abs "Error in restoring the item from Trash.");
               end if;

               Sendback := Add_Query_Arg (
                        To_Array (List => (
                                Build ("untrashed", "1"),
                                Build ("ids",       Post_Id)
                        )),
                        Sendback
               );
               HB_Redirect (-Sendback);
               goto Bailout; -- return; -- exit;

            elsif Action = "delete" then
               Check_Admin_Referer ("delete-post_" & Post_Id);

               if not Post then
                  HB_Die (abs "This item has already been deleted.");
               end if;

               if not Post_Type_Object then
                  HB_Die (abs "Invalid post type.");
               end if;

               if not Current_User_Can ("delete_post", Post_Id) then
                  HB_Die (abs "Sorry, you are not allowed to delete this item.");
               end if;

               if "attachment" = Post.Post_Type then
                  declare
                     Force : constant Boolean := not MEDIA_TRASH;
                  begin
                     if not HB_Delete_Attachment (Post_Id, Force) then
                        HB_Die (abs "Error in deleting the attachment.");
                     end if;
                  end;
               else
                  if not HB_Delete_Post (Post_Id, True) then
                     HB_Die (abs "Error in deleting the item.");
                  end if;
               end if;

               HB_Redirect (-Add_Query_Arg ("deleted", 1, Sendback));
               goto Bailout; -- return; -- exit;

            elsif Action = "preview" then
               Check_Admin_Referer ("update-post_" & Post_Id);
               declare
                  URL : constant String := Post_Preview; -- ();
               begin
                  HB_Redirect (URL);
               end;
               goto Bailout; -- return; -- exit;

            elsif Action = "toggle-custom-fields" then
               Check_Admin_Referer ("toggle-custom-fields",
                                    "toggle-custom-fields-nonce");
               declare
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
               HB_Safe_Redirect (HB_Get_Referer); -- ()
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
               Do_Action ("post_action_{action}", Post_Id);

               HB_Redirect (Admin_URL ("edit.php"));
               goto Bailout; -- return; -- exit;
            end if; -- End switch.
         end;
      end;

--  require_once ABSPATH . "wp-admin/admin-footer.php";

<<Bailout>>

      return AWS.Response.Build ("text/html", "");

   end Render;

end HB_Post;
