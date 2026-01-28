--
-- Core User Role & Capabilities API
--
-- @package WordPress
-- @subpackage Users
--

with Php.Lists;
with Php.Strings;
with Php.Types;

with Constants;
with UStrings;
with Wp_Common;

with Class_Comments;
with Class_Post_Type;
with Class_Taxonomy;
with Class_Terms;
with Inc_Comments;
with Inc_Functions;
with Inc_Load;
with Inc_L10n;
with Inc_Taxonomys;
with Inc_Meta;
with Inc_Options;
with Inc_Pluggables;
with Inc_Plugins;
with Inc_Posts;
with Inc_Roles;

package body Inc_Capabilities
is

   Global_Super_Admins        : List_Type;
   Global_Post_Type_Meta_Caps : Array_Type;

   ------------------
   -- Map_Meta_Cap --
   ------------------

   function Map_Meta_Cap (Cap     : String;
                          User_Id : Class_Users.User_Id_Type;
                          Args    : Args_Type := Null_Args_Type)
                          return List_Type
   is
      use Php.Lists;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Class_Posts;
      use Class_Post_Type;
      use Class_Users;
      use Inc_Functions;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Plugins;
      use Inc_Posts;

      Caps  : List_Type;
      Cap_2 : UString;

      Publish_Future : constant List_Type :=
        ["publish", "future"];
   begin
      -- switch ( cap ) then
      if Cap in "remove_user" then
         -- In multisite the user must be a super admin to remove themselves.
         if
           Args.User_Id /= 0 and then
           User_Id = Args.User_Id and then
           not Is_Super_Admin (User_Id)
         then
            Append (Caps, "do_not_allow");
         else
            Append (Caps, "remove_users");
         end if;

      elsif Cap in "promote_user" |
                   "add_users"
      then
         Append (Caps, "promote_users");

      elsif Cap in "edit_user" |
                   "edit_users"
      then
         -- Allow user to edit themselves.
         if
           "edit_user" = Cap and then
           Args.User_Id /= 0 and then
           User_Id = Args.User_Id
         then
            goto Break_1;
         end if;

         -- In multisite the user must have manage_network_users caps. If editing a
         -- super admin, the user must be a super admin.
         if
           Is_Multisite and then
           ((not Is_Super_Admin (User_Id) and then
             "edit_user" = Cap and then
             Is_Super_Admin (Args.User_Id)) or else
           not User_Can (User_Id, "manage_network_users"))
         then
            Append (Caps, "do_not_allow");
         else
            Append (Caps, "edit_users"); -- edit_user maps to edit_users.
         end if;
         << Break_1 >>

      elsif Cap in "delete_post" |
                   "delete_page"
      then
         if Args.Post_Id = 0 then
            declare
               Message : UString;
            begin
               if "delete_post" = Cap then
                  -- translators: %s: Capability name.
                  Message := +abs "When checking for the %s capability, you must always check it against a specific post.";
               else
                  -- translators: %s: Capability name.
                  Message := +abs "When checking for the %s capability, you must always check it against a specific page.";
               end if;

               X_Doing_It_Wrong (
                 "__FUNCTION__",
                 Sprintf (-Message,
                          [1 => "<code>" & Cap & "</code>"]),
                 "6.1.0"
               );
            end;
            Append (Caps, "do_not_allow");
            goto Break_2;
         end if;

         declare
            Post      : Wp_Post      := Null_Post;
            Post_Type : Wp_Post_Type := Null_Post_Type;
            Message   : UString;
         begin
            Post := Get_Post (Args.Post_Id);
            if Post = Null_Post then
               Append (Caps, "do_not_allow");
               goto Break_2;
            end if;

            if "revision" = Post.Post_Type then
               Append (Caps, "do_not_allow");
               goto Break_2;
            end if;

            if
              (Get_Option ("page_for_posts") = Integer (Post.Id)) or else
              (Get_Option ("page_on_front")  = Integer (Post.Id))
            then
               Append (Caps, "manage_options");
               goto Break_2;
            end if;

            Post_Type := Get_Post_Type_Object (-Post.Post_Type);
            if Post_Type = Null_Post_Type then
               -- translators: 1: Post type, 2: Capability name.
               Message := +abs "The post type %1s is not registered, so it may not be reliable to check the capability %2s against a post of that type.";

               X_Doing_It_Wrong (
                 "__FUNCTION__",
                 Sprintf (
                   -Message, [
                     1 => "<code>" & (-Post.Post_Type) & "</code>",
                     2 => "<code>" & Cap & "</code>"
                   ]
                 ),
                 "4.4.0"
               );

               Append (Caps, "edit_others_posts");
               goto Break_2;
            end if;

            if not Post_Type.Map_Meta_Cap then
               Append (Caps, Get_As_String (Post_Type.Cap, "cap"));
               -- Prior to 3.1 we would re-call map_meta_cap here.
               if "delete_post" = Cap then
                  Cap_2 := +Get_As_String (Post_Type.Cap, "cap");
               end if;
               goto Break_2;
            end if;

            -- If the post author is set and the user is the author...
            if Post.Post_Author /= 0 and then User_Id = Post.Post_Author then
               -- If the post is published or scheduled...
               if In_List (-Post.Post_Status, Publish_Future, True) then
                  Append (Caps,
                          Get_As_String (
                            Post_Type.Cap, "delete_published_posts"));
               elsif "trash" = Post.Post_Status then
                  declare
                     Status : constant String :=
                       Get_Post_Meta (Post.Id, "_wp_trash_meta_status", True);
                  begin
                     if In_List (Status, Publish_Future, True) then
                        Append (Caps,
                                Get_As_String (
                                  Post_Type.Cap, "delete_published_posts"));
                     else
                        Append (Caps,
                                Get_As_String (
                                  Post_Type.Cap, "delete_posts"));
                     end if;
                  end;
               else
                  -- If the post is draft...
                  Append (Caps,
                          Get_As_String (
                            Post_Type.Cap, "delete_posts"));
               end if;
            else
               -- The user is trying to edit someone else"s post.
               Append (Caps,
                       Get_As_String (
                         Post_Type.Cap, "delete_others_posts"));
               -- The post is published or scheduled, extra cap required.
               if
                 In_List (-Post.Post_Status, Publish_Future, True)
               then
                  Append (Caps,
                          Get_As_String (
                            Post_Type.Cap, "delete_published_posts"));
               elsif "private" = Post.Post_Status then
                  Append (Caps,
                          Get_As_String (
                            Post_Type.Cap, "delete_private_posts"));
               end if;
            end if;

            --
            -- Setting the privacy policy page requires `manage_privacy_options`,
            -- so deleting it should require that too.
            --
            if Get_Option ("wp_page_for_privacy_policy") = Integer (Post.Id) then
               Caps :=
                 List_Merge (Caps, Map_Meta_Cap ("manage_privacy_options", User_Id));
            end if;
         end;
         << Break_2 >>

      -- edit_post breaks down to edit_posts, edit_published_posts, or
      -- edit_others_posts.
      elsif Cap in "edit_post" |
                   "edit_page"
      then
         if Args.Post_Id = 0 then
            declare
               Message : UString;
            begin
               if "edit_post" = Cap then
                  -- translators: %s: Capability name.
                  Message := +abs "When checking for the %s capability, you must always check it against a specific post.";
               else
                  -- translators: %s: Capability name.
                  Message := +abs "When checking for the %s capability, you must always check it against a specific page.";
               end if;

               X_Doing_It_Wrong (
                 "__FUNCTION__",
                 Sprintf (-Message,
                          [1 => "<code>" & Cap & "</code>"]),
                 "6.1.0"
               );
            end;
            Append (Caps, "do_not_allow");
            goto Break_3;
         end if;

         declare
            Post      : Wp_Post      := Null_Post;
            Post_Type : Wp_Post_Type := Null_Post_Type;
            Message   : UString;
         begin
            Post := Get_Post (Args.Post_Id);
            if Post = Null_Post then
               Append (Caps, "do_not_allow");
               goto Break_3;
            end if;

            if "revision" = Post.Post_Type then
               Post := Get_Post (Post.Post_Parent);
               if Post = Null_Post then
                  Append (Caps, "do_not_allow");
                  goto Break_3;
               end if;
            end if;

            Post_Type := Get_Post_Type_Object (-Post.Post_Type);
            if Post_Type = Null_Post_Type then
               -- translators: 1: Post type, 2: Capability name.
               Message := +abs "The post type %1s is not registered, so it may not be reliable to check the capability %2s against a post of that type.";

               X_Doing_It_Wrong (
                 "__FUNCTION__",
                 Sprintf (
                   -Message, [
                     1 => "<code>" & (-Post.Post_Type) & "</code>",
                     2 => "<code>" & Cap & "</code>"
                   ]
                 ),
                 "4.4.0"
               );

               Append (Caps, "edit_others_posts");
               goto Break_3;
            end if;

            if not Post_Type.Map_Meta_Cap then
               Append (Caps, Get_As_String (Post_Type.Cap, "cap"));
               -- Prior to 3.1 we would re-call map_meta_cap here.
               if "edit_post" = Cap then
                  Cap_2 := +Get_As_String (Post_Type.Cap, "cap");
               end if;
               goto Break_3;
            end if;

            -- If the post author is set and the user is the author...
            if Post.Post_Author /= 0 and then User_Id = Post.Post_Author then
               -- If the post is published or scheduled...
               if In_List (-Post.Post_Status, Publish_Future, True) then
                  Append (Caps,
                          Get_As_String (
                            Post_Type.Cap, "edit_published_posts"));

               elsif "trash" = Post.Post_Status then
                  declare
                     Status : constant String :=
                       Get_Post_Meta (Post.Id, "_wp_trash_meta_status", True);
                  begin
                     if In_List (Status, Publish_Future, True) then
                        Append (Caps,
                                Get_As_String (
                                  Post_Type.Cap, "edit_published_posts"));
                     else
                        Append (Caps,
                                Get_As_String (
                                  Post_Type.Cap, "edit_posts"));
                     end if;
                  end;
               else
                  -- If the post is draft...
                  Append (Caps,
                          Get_As_String (
                            Post_Type.Cap, "edit_posts"));
               end if;
            else
               -- The user is trying to edit someone else"s post.
               Append (Caps, Get_As_String (Post_Type.Cap, "edit_others_posts"));
               -- The post is published or scheduled, extra cap required.
               if In_List (-Post.Post_Status, Publish_Future, True) then
                  Append (Caps,
                          Get_As_String (
                            Post_Type.Cap, "edit_published_posts"));
               elsif "private" = Post.Post_Status then
                  Append (Caps,
                          Get_As_String (
                            Post_Type.Cap, "edit_private_posts"));
               end if;
            end if;

            --
            -- Setting the privacy policy page requires `manage_privacy_options`,
            -- so editing it should require that too.
            --
            if Get_Option ("wp_page_for_privacy_policy") = Integer (Post.Id) then
               Caps :=
                 List_Merge (Caps, Map_Meta_Cap ("manage_privacy_options", User_Id));
            end if;
         end;
         << Break_3 >>

      elsif Cap in "read_post" |
                   "read_page"
      then
         if Args.Post_Id = 0 then
            declare
               Message : UString;
            begin
               if "read_post" = Cap then
                  -- translators: %s: Capability name.
                  Message := +abs "When checking for the %s capability, you must always check it against a specific post.";
               else
                  -- translators: %s: Capability name.
                  Message := +abs "When checking for the %s capability, you must always check it against a specific page.";
               end if;

               X_Doing_It_Wrong (
                 "__FUNCTION__",
                 Sprintf (-Message, [1 => "<code>" & Cap & "</code>"]),
                 "6.1.0"
               );
            end;

            Append (Caps, "do_not_allow");
            goto Break_4;
         end if;

         declare
            Post       : Wp_Post      := Null_Post;
            Post_Type  : Wp_Post_Type := Null_Post_Type;
            Status_Obj : Status_Type; -- Array_Type;
         begin
            Post := Get_Post (Args.Post_Id);
            if Post = Null_Post then
               Append (Caps, "do_not_allow");
               goto Break_4;
            end if;

            if "revision" = Post.Post_Type then
               Post := Get_Post (Post.Post_Parent);
               if Post = Null_Post then
                  Append (Caps, "do_not_allow");
                  goto Break_4;
               end if;
            end if;

            Post_Type := Get_Post_Type_Object (-Post.Post_Type);
            if Post_Type = Null_Post_Type then
               declare
                  -- translators: 1: Post type, 2: Capability name.
                  Message : constant String := abs "The post type %1s is not registered, so it may not be reliable to check the capability %2s against a post of that type.";
               begin
                  X_Doing_It_Wrong (
                    "__FUNCTION__",
                    Sprintf (
                      Message, [
                        1 => "<code>" & (-Post.Post_Type) & "</code>",
                        2 => "<code>" & Cap & "</code>"
                      ]
                      ),
                      "4.4.0"
                    );
               end;
               Append (Caps, "edit_others_posts");
               goto Break_4;
            end if;

            if not Post_Type.Map_Meta_Cap then
               Append (Caps, Get_As_String (Post_Type.Cap, "cap"));
               -- Prior to 3.1 we would re-call map_meta_cap here.
               if "read_post" = Cap then
                  Cap_2 := +Get_As_String (Post_Type.Cap, "cap");
               end if;
               goto Break_4;
            end if;

            Status_Obj := Get_Post_Status_Object (Get_Post_Status (Post));
            if Status_Obj = Null_Status then
               declare
                  -- translators: 1: Post status, 2: Capability name.
                  Message : constant String := abs "The post status %1s is not registered, so it may not be reliable to check the capability %2s against a post with that status.";
               begin
                  X_Doing_It_Wrong (
                    "__FUNCTION__",
                    Sprintf (
                      Message, [
                        1 => "<code>" & Get_Post_Status (Post) & "</code>",
                        2 => "<code>" & Cap & "</code>"
                      ]
                    ),
                    "5.4.0"
                  );
               end;

               Append (Caps, "edit_others_posts");
               goto Break_4;
            end if;

            if Status_Obj.Public then
               Append (Caps, Get_As_String (Post_Type.Cap, "read"));
               goto Break_4;
            end if;

            if Post.Post_Author /= 0 and then User_Id = Post.Post_Author then
               Append (Caps, Get_As_String (Post_Type.Cap, "read"));
            elsif Status_Obj.Privat then
               Append (Caps, Get_As_String (Post_Type.Cap, "read_private_posts"));
            else
               Caps := Map_Meta_Cap ("edit_post", User_Id, (Post_Id  => Post.Id,
                                                            Meta_Key => False,
                                                            User_Id  => 0,
                                                            others   => 0));
            end if;
         end;
         << Break_4 >>

      elsif Cap in "publish_post" then
         if Args.Post_Id = 0 then
            declare
               -- translators: %s: Capability name.
               Message : constant String := abs "When checking for the %s capability, you must always check it against a specific post.";
            begin
               X_Doing_It_Wrong (
                 "__FUNCTION__",
                 Sprintf (Message, [1 => "<code>" & Cap & "</code>"]),
                 "6.1.0"
               );
            end;
            Append (Caps, "do_not_allow");
            goto Break_5;
         end if;

         declare
            Post      : Wp_Post      := Null_Post;
            Post_Type : Wp_Post_Type := Null_Post_Type;
         begin
            Post := Get_Post (Args.Post_Id);
            if Post = Null_Post then
               Append (Caps, "do_not_allow");
               goto Break_5;
            end if;

            Post_Type := Get_Post_Type_Object (-Post.Post_Type);
            if Post_Type = Null_Post_Type then
               declare
                  -- translators: 1: Post type, 2: Capability name.
                  Message : constant String := abs "The post type %1s is not registered, so it may not be reliable to check the capability %2s against a post of that type.";
               begin
                  X_Doing_It_Wrong (
                    "__FUNCTION__",
                    Sprintf (
                      Message, [
                        1 => "<code>" & (-Post.Post_Type) & "</code>",
                        2 => "<code>" & Cap & "</code>"
                      ]
                    ),
                    "4.4.0"
                  );
               end;
               Append (Caps, "edit_others_posts");
               goto Break_5;
            end if;

            Append (Caps, Get_As_String (Post_Type.Cap, "publish_posts"));
         end;
         << Break_5 >>

      elsif Cap in "edit_post_meta"
                | "delete_post_meta"
                | "add_post_meta"
                | "edit_comment_meta"
                | "delete_comment_meta"
                | "add_comment_meta"
                | "edit_term_meta"
                | "delete_term_meta"
                | "add_term_meta"
                | "edit_user_meta"
                | "delete_user_meta"
                | "add_user_meta"
      then
         declare
            Expl_Cap    : constant List_Type := Explode ("_", Cap);
            Object_Type : constant String    := Expl_Cap (2); -- [1]
            Message     : UString;
         begin
            if Args.Object_Id = 0 then
               if "post" = Object_Type then
                  -- translators: %s: Capability name.
                  Message := +abs "When checking for the %s capability, you must always check it against a specific post.";
               elsif "comment" = Object_Type then
                  -- translators: %s: Capability name.
                  Message := +abs "When checking for the %s capability, you must always check it against a specific comment.";
               elsif  "term" = Object_Type then
                  -- translators: %s: Capability name.
                  Message := +abs "When checking for the %s capability, you must always check it against a specific term.";
               else
                  -- translators: %s: Capability name.
                  Message := +abs "When checking for the %s capability, you must always check it against a specific user.";
               end if;

               X_Doing_It_Wrong (
                 "__FUNCTION__",
                 Sprintf (-Message, ["<code>" & Cap & "</code>"]),
                 "6.1.0"
               );

               Append (Caps, "do_not_allow");
               goto Break_7;
            end if;

            declare
               use Inc_Meta;

               Object_Id : constant Integer := Args.Object_Id; -- (int)

               Object_Subtype : constant String :=
                 Get_Object_Subtype (Object_Type, Object_Id);

               Meta_Key : UString;
               Allowed  : Boolean;
            begin
               if Empty (Object_Subtype) then
                  Append (Caps, "do_not_allow");
                  goto Break_7;
               end if;

               Caps := Map_Meta_Cap ("edit_" & Object_Type, User_Id,
                                     (Object_Id => Object_Id,
                                      Meta_Key  => False,
                                      Post_Id   => 0,
                                      User_Id   => 0,
                                      others    => 0));

               Meta_Key :=
                 +Boolean'(if Args.Meta_Key then Args.Meta_Key else False)'Image;

               if Meta_Key /= "" then
                  Allowed := not Is_Protected_Meta (-Meta_Key, Object_Type);

                  if
                    not Empty (Object_Subtype) and then
                    Has_Filter ("auth_{object_type}_meta_{meta_key}_for_{object_subtype}")
                  then
                     --
                     -- Filters whether the user is allowed to edit a specific meta key of a specific object type and subtype.
                     --
                     -- The dynamic portions of the hook name, `object_type`, `meta_key`,
                     -- and `object_subtype`, refer to the metadata object type (comment, post, term or user),
                     -- the meta key value, and the object subtype respectively.
                     --
                     -- @since 4.9.8
                     --
                     -- @param bool     allowed   Whether the user can add the object meta. Default false.
                     -- @param string   meta_key  The meta key.
                     -- @param int      object_id Object ID.
                     -- @param int      user_id   User ID.
                     -- @param string   cap       Capability name.
                     -- @param string[] caps      Array of the user"s capabilities.
                     --
                     Allowed := Apply_Filters ("auth_{object_type}_meta_{meta_key}_for_{object_subtype}", Allowed, -Meta_Key, Object_Id, Integer (User_Id), Cap, Caps);
                  else

                     --
                     -- Filters whether the user is allowed to edit a specific meta key of a specific object type.
                     --
                     -- Return true to have the mapped meta caps from `edit_thenobject_typeend;` apply.
                     --
                     -- The dynamic portion of the hook name, `object_type` refers to the object type being filtered.
                     -- The dynamic portion of the hook name, `meta_key`, refers to the meta key passed to map_meta_cap().
                     --
                     -- @since 3.3.0 As `auth_post_meta_thenmeta_keyend;`.
                     -- @since 4.6.0
                     --
                     -- @param bool     allowed   Whether the user can add the object meta. Default false.
                     -- @param string   meta_key  The meta key.
                     -- @param int      object_id Object ID.
                     -- @param int      user_id   User ID.
                     -- @param string   cap       Capability name.
                     -- @param string[] caps      Array of the user"s capabilities.
                     --
                     Allowed := Apply_Filters ("auth_{object_type}_meta_{meta_key}", Allowed, -Meta_Key, Object_Id, Integer (User_Id), Cap, Caps);
                  end if;

                  -- if not Empty (Object_Subtype) then

                  --    --
                  --    -- Filters whether the user is allowed to edit meta for specific object types/subtypes.
                  --    --
                  --    -- Return true to have the mapped meta caps from `edit_thenobject_typeend;` apply.
                  --    --
                  --    -- The dynamic portion of the hook name, `object_type` refers to the object type being filtered.
                  --    -- The dynamic portion of the hook name, `object_subtype` refers to the object subtype being filtered.
                  --    -- The dynamic portion of the hook name, `meta_key`, refers to the meta key passed to map_meta_cap().
                  --    --
                  --    -- @since 4.6.0 As `auth_post_thenpost_typeend;_meta_thenmeta_keyend;`.
                  --    -- @since 4.7.0 Renamed from `auth_post_thenpost_typeend;_meta_thenmeta_keyend;` to
                  --    --              `auth_thenobject_typeend;_thenobject_subtypeend;_meta_thenmeta_keyend;`.
                  --    -- @deprecated 4.9.8 Use {@see "auth_thenobject_type}_meta_thenmeta_keyend;_for_thenobject_subtypeend;"end; instead.
                  --    --
                  --    -- @param bool     allowed   Whether the user can add the object meta. Default false.
                  --    -- @param string   meta_key  The meta key.
                  --    -- @param int      object_id Object ID.
                  --    -- @param int      user_id   User ID.
                  --    -- @param string   cap       Capability name.
                  --    -- @param string[] caps      Array of the user"s capabilities.
                  --    --
                  --    Allowed := Apply_Filters_Deprecated (
                  --      "auth_{object_type}_{object_subtype}_meta_{meta_key}",
                  --      [Allowed, Meta_Key, Object_Id, User_Id, Cap, Caps],
                  --      "4.9.8",
                  --      "auth_{object_type}_meta_{meta_key}_for_{object_subtype}"
                  --    );
                  -- end if;

                  if not Allowed then
                     Append (Caps, Cap);
                  end if;
               end if;
            end;
         end;
         << Break_7 >>

      elsif Cap in "edit_comment" then
         if Args.Comment_Id = 0 then
            declare
               -- translators: %s: Capability name.
               Message : constant String := abs "When checking for the %s capability, you must always check it against a specific comment.";
            begin
               X_Doing_It_Wrong (
                 "__FUNCTION__",
                 Sprintf (Message, [1 => "<code>" & Cap & "</code>"]),
                 "6.1.0"
               );
            end;
            Append (Caps, "do_not_allow");
            goto Break_8;
         end if;

         declare
            use Class_Comments;
            use Inc_Comments;

            Comment : constant Wp_Comment := Get_Comment (Args.Comment_Id);
            Post    : Wp_Post    := Null_Post;
         begin
            if Comment = Null_Comment then
               Append (Caps, "do_not_allow");
               goto Break_8;
            end if;

            Post := Get_Post (Comment.Comment_Post_Id);

            --
            -- If the post doesn"t exist, we have an orphaned comment.
            -- Fall back to the edit_posts capability, instead.
            --
            if Post /= Null_Post then
               Caps := Map_Meta_Cap ("edit_post", User_Id, (Post_Id  => Post.Id,
                                                            Meta_Key => False,
                                                            User_Id  => 0,
                                                            others   => 0));
            else
               Caps := Map_Meta_Cap ("edit_posts", User_Id);
            end if;
         end;
         << Break_8 >>

      elsif Cap in "unfiltered_upload" then
         if
           Constants.ALLOW_UNFILTERED_UPLOADS and then
           (not Is_Multisite or else
            Is_Super_Admin (User_Id))
         then
            Append (Caps, Cap);
         else
            Append (Caps, "do_not_allow");
         end if;

      elsif Cap in "edit_css"
                 | "unfiltered_html"
      then
         -- Disallow unfiltered_html for all users, even admins and super admins.
         if Constants.DISALLOW_UNFILTERED_HTML then
            Append (Caps, "do_not_allow");
         elsif Is_Multisite and then not Is_Super_Admin (User_Id) then
            Append (Caps, "do_not_allow");
         else
            Append (Caps, "unfiltered_html");
         end if;

      elsif Cap in "edit_files"
                 | "edit_plugins"
                 | "edit_themes"
      then
         -- Disallow the file editors.
         if Constants.DISALLOW_FILE_EDIT then
            Append (Caps, "do_not_allow");
         elsif Wp_Is_File_Mod_Allowed ("capability_edit_themes") then
            Append (Caps, "do_not_allow");
         elsif Is_Multisite and then not Is_Super_Admin (User_Id) then
            Append (Caps, "do_not_allow");
         else
            Append (Caps, Cap);
         end if;

      elsif Cap in "update_plugins"
                 | "delete_plugins"
                 | "install_plugins"
                 | "upload_plugins"
                 | "update_themes"
                 | "delete_themes"
                 | "install_themes"
                 | "upload_themes"
                 | "update_core"
      then
         -- Disallow anything that creates, deletes, or updates core, plugin, or theme files.
         -- Files in uploads are excepted.
         if not Wp_Is_File_Mod_Allowed ("capability_update_core") then
            Append (Caps, "do_not_allow");
         elsif Is_Multisite and then not Is_Super_Admin (User_Id) then
            Append (Caps, "do_not_allow");
         elsif "upload_themes" = Cap then
            Append (Caps, "install_themes");
         elsif "upload_plugins" = Cap then
            Append (Caps, "install_plugins");
         else
            Append (Caps, Cap);
         end if;

      elsif Cap in "install_languages"
                 | "update_languages"
      then
         if not Wp_Is_File_Mod_Allowed ("can_install_language_pack") then
            Append (Caps, "do_not_allow");
         elsif Is_Multisite and then not Is_Super_Admin (User_Id) then
            Append (Caps, "do_not_allow");
         else
            Append (Caps, "install_languages");
         end if;

      elsif Cap in "activate_plugins"
                 | "deactivate_plugins"
                 | "activate_plugin"
                 | "deactivate_plugin"
      then
         Append (Caps, "activate_plugins");
         if Is_Multisite then
            declare
               -- update_, install_, and delete_ are handled above with
               -- is_super_admin().
               Menu_Perms : constant Array_Type :=
                 As_Array (Get_Site_Option ("menu_items", From_List ([])));
            begin
               if Empty (Menu_Perms, "plugins") then
                  Append (Caps, "manage_network_plugins");
               end if;
            end;
         end if;

      elsif Cap in "resume_plugin" then
         Append (Caps, "resume_plugins");

      elsif Cap in "resume_theme" then
         Append (Caps, "resume_themes");

      elsif Cap in "delete_user"
                 | "delete_users"
      then
         -- If multisite only super admins can delete users.
         if Is_Multisite and then not Is_Super_Admin (User_Id) then
            Append (Caps, "do_not_allow");
         else
            Append (Caps, "delete_users"); -- delete_user maps to delete_users.
         end if;

      elsif Cap in "create_users" then
         if not Is_Multisite  then
            Append (Caps, Cap);
         elsif
           Is_Super_Admin (User_Id) or else
           As_Boolean (Get_Site_Option ("add_new_users"))
         then
            Append (Caps, Cap);
         else
            Append (Caps, "do_not_allow");
         end if;

      elsif Cap in "manage_links" then
         if Get_Option ("link_manager_enabled") then
            Append (Caps, Cap);
         else
            Append (Caps, "do_not_allow");
         end if;

      elsif Cap in "customize" then
         Append (Caps, "edit_theme_options");

      elsif Cap in "delete_site" then
         if Is_Multisite then
            Append (Caps, "manage_options");
         else
            Append (Caps, "do_not_allow");
         end if;

      elsif Cap in "edit_term"
                 | "delete_term"
                 | "assign_term"
      then
         if Args.Term_Id = 0 then
            declare
               -- translators: %s: Capability name.
               Message : constant String := abs "When checking for the %s capability, you must always check it against a specific term.";
            begin
               X_Doing_It_Wrong (
                 "__FUNCTION__",
                 Sprintf (Message, [1 => "<code>" & Cap & "</code>"]),
                 "6.1.0"
               );
            end;
            Append (Caps, "do_not_allow");
            goto Break_9;
         end if;

         declare
            use Class_Taxonomy;
            use Class_Terms;
            use Inc_Taxonomys;

            Term_Id  : constant Integer := Args.Term_Id;
            Term     : constant Wp_Term := Get_Term (Term_Id);
            Tax      : Wp_Taxonomy := Null_Taxonomy;
            Taxo_Cap : UString;
         begin
            if Term = Null_Term or else Is_Wp_Error (Term) then
               Append (Caps, "do_not_allow");
               goto Break_9;
            end if;

            Tax := Get_Taxonomy (-Term.Taxonomy);
            if Tax = Null_Taxonomy then
               Append (Caps, "do_not_allow");
               goto Break_9;
            end if;

            if
              "delete_term" = Cap and then
              (Get_Option ("default_" & (-Term.Taxonomy)) = Term.Term_Id or else
               Get_Option ("default_term_" & (-Term.Taxonomy)) = Term.Term_Id)
            then
               Append (Caps, "do_not_allow");
               goto Break_9;
            end if;

            Taxo_Cap := +Cap & "s";

            Caps := Map_Meta_Cap (Get_As_String (Tax.Cap, "taxo_cap"),
                                  User_Id, (Term_Id  => Term_Id,
                                            Meta_Key => False,
                                            Post_Id  => 0,
                                            User_Id  => 0,
                                            others   => 0));
         end;
         << Break_9 >>

      elsif Cap in "manage_post_tags"
                 | "edit_categories"
                 | "edit_post_tags"
                 | "delete_categories"
                 | "delete_post_tags"
      then
         Append (Caps, "manage_categories");

      elsif Cap in "assign_categories"
                 | "assign_post_tags"
      then
         Append (Caps, "edit_posts");

      elsif Cap in "create_sites"
                 | "delete_sites"
                 | "manage_network"
                 | "manage_sites"
                 | "manage_network_users"
                 | "manage_network_plugins"
                 | "manage_network_themes"
                 | "manage_network_options"
                 | "upgrade_network"
      then
         Append (Caps, Cap);

      elsif Cap in "setup_network" then
         if Is_Multisite then
            Append (Caps, "manage_network_options");
         else
            Append (Caps, "manage_options");
         end if;

      elsif Cap in "update_php" then
         if Is_Multisite and then not Is_Super_Admin (User_Id) then
            Append (Caps, "do_not_allow");
         else
            Append (Caps, "update_core");
         end if;

      elsif Cap in "update_https" then
         if Is_Multisite and then not Is_Super_Admin (User_Id) then
            Append (Caps, "do_not_allow");
         else
            Append (Caps, "manage_options");
            Append (Caps, "update_core");
         end if;

      elsif Cap in "export_others_personal_data"
                 | "erase_others_personal_data"
                 | "manage_privacy_options"
      then
         Append (Caps, (if Is_Multisite
                        then "manage_network"
                        else "manage_options"));

      elsif Cap in "create_app_password"
                 | "list_app_passwords"
                 | "read_app_password"
                 | "edit_app_password"
                 | "delete_app_passwords"
                 | "delete_app_password"
      then
         Caps := Map_Meta_Cap ("edit_user", User_Id, (User_Id  => Args.User_Id,
                                                      Meta_Key => False,
                                                      Post_Id  => 0,
                                                      others   => 0));

      else -- default
         -- Handle meta capabilities for custom post types.
         if Isset (Global_Post_Type_Meta_Caps, Cap) then
            return
              Map_Meta_Cap (
                Get_As_String (Global_Post_Type_Meta_Caps, Cap),
                User_Id, Args);
         end if;

         declare
            -- Block capabilities map to their post equivalent.
            Block_Caps : constant List_Type :=
              [
                "edit_blocks",
                "edit_others_blocks",
                "publish_blocks",
                "read_private_blocks",
                "delete_blocks",
                "delete_private_blocks",
                "delete_published_blocks",
                "delete_others_blocks",
                "edit_private_blocks",
                "edit_published_blocks"
              ];
         begin
            if In_List (Cap, Block_Caps, True) then
               Cap_2 := +Str_Replace ("_blocks", "_posts", Cap);
            end if;
         end;
         -- If no meta caps match, return the original cap.
         Append (Caps, -Cap_2);
      end if; -- switch

      --
      -- Filters the primitive capabilities required of the given user to satisfy the
      -- capability being checked.
      --
      -- @since 2.8.0
      --
      -- @param string[] caps    Primitive capabilities required of the user.
      -- @param string   cap     Capability being checked.
      -- @param int      user_id The user ID.
      -- @param array    args    Adds context to the capability check, typically
      --                          starting with an object ID.
      --
      return Apply_Filters ("map_meta_cap", Caps, -Cap_2, Integer (User_Id), Args);
   end Map_Meta_Cap;

-- --
-- -- Returns whether the current user has the specified capability.
-- --
-- -- This function also accepts an ID of an object to check against if the capability is a meta capability. Meta
-- -- capabilities such as `edit_post` and `edit_user` are capabilities used by the `map_meta_cap()` function to
-- -- map to primitive capabilities that a user or role has, such as `edit_posts` and `edit_others_posts`.
-- --
-- -- Example usage:
-- --
-- --     current_user_can( "edit_posts" );
-- --     current_user_can( "edit_post", post.ID );
-- --     current_user_can( "edit_post_meta", post.ID, meta_key );
-- --
-- -- While checking against particular roles in place of a capability is supported
-- -- in part, this practice is discouraged as it may produce unreliable results.
-- --
-- -- Note: Will always return true if the current user is a super admin, unless specifically denied.
-- --
-- -- @since 2.0.0
-- -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
-- --              by adding it to the function signature.
-- -- @since 5.8.0 Converted to wrapper for the user_can() function.
-- --
-- -- @see WP_User::has_cap()
-- -- @see map_meta_cap()
-- --
-- -- @param string capability Capability name.
-- -- @param mixed  ...args    Optional further parameters, typically starting with an object ID.
-- -- @return bool Whether the current user has the given capability. If `capability` is a meta cap and `object_id` is
-- --              passed, whether the current user has the given meta capability for the given object.
-- --
-- function current_user_can( capability, ...args ) then
--         return user_can( wp_get_current_user(), capability, ...args );
-- end;

-- --
-- -- Returns whether the current user has the specified capability for a given site.
-- --
-- -- This function also accepts an ID of an object to check against if the capability is a meta capability. Meta
-- -- capabilities such as `edit_post` and `edit_user` are capabilities used by the `map_meta_cap()` function to
-- -- map to primitive capabilities that a user or role has, such as `edit_posts` and `edit_others_posts`.
-- --
-- -- Example usage:
-- --
-- --     current_user_can_for_blog( blog_id, "edit_posts" );
-- --     current_user_can_for_blog( blog_id, "edit_post", post.ID );
-- --     current_user_can_for_blog( blog_id, "edit_post_meta", post.ID, meta_key );
-- --
-- -- @since 3.0.0
-- -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
-- --              by adding it to the function signature.
-- -- @since 5.8.0 Wraps current_user_can() after switching to blog.
-- --
-- -- @param int    blog_id    Site ID.
-- -- @param string capability Capability name.
-- -- @param mixed  ...args    Optional further parameters, typically starting with an object ID.
-- -- @return bool Whether the user has the given capability.
-- --
-- function current_user_can_for_blog( blog_id, capability, ...args ) then
--         switched = is_multisite() ? switch_to_blog( blog_id ) : false;

--         can = current_user_can( capability, ...args );

--         if ( switched ) then
--                 restore_current_blog();
--         end;

--         return can;
-- end;

-- --
-- -- Returns whether the author of the supplied post has the specified capability.
-- --
-- -- This function also accepts an ID of an object to check against if the capability is a meta capability. Meta
-- -- capabilities such as `edit_post` and `edit_user` are capabilities used by the `map_meta_cap()` function to
-- -- map to primitive capabilities that a user or role has, such as `edit_posts` and `edit_others_posts`.
-- --
-- -- Example usage:
-- --
-- --     author_can( post, "edit_posts" );
-- --     author_can( post, "edit_post", post.ID );
-- --     author_can( post, "edit_post_meta", post.ID, meta_key );
-- --
-- -- @since 2.9.0
-- -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
-- --              by adding it to the function signature.
-- --
-- -- @param int|WP_Post post       Post ID or post object.
-- -- @param string      capability Capability name.
-- -- @param mixed       ...args    Optional further parameters, typically starting with an object ID.
-- -- @return bool Whether the post author has the given capability.
-- --
-- function author_can( post, capability, ...args ) then
--         post = get_post( post );
--         if ( ! post ) then
--                 return false;
--         end;

--         author = get_userdata( post.post_author );

--         if ( ! author ) then
--                 return false;
--         end;

--         return author.has_cap( capability, ...args );
-- end;

   --------------
   -- User_Can --
   --------------

   function User_Can (User       : Class_Users.Wp_User;
                      Capability : String)
                      -- , ...args)
                      return Boolean
   is
   begin
      -- if ( ! is_object( user ) ) then
      --    user = get_userdata( user );
      -- end if;

      -- if ( empty( user ) ) then
      --    -- User is logged out, create anonymous user object.
      --    user = new WP_User( 0 );
      --    user.init( new stdClass );
      -- end if;

      return User.Has_Cap (Capability); -- , ...args );
   end User_Can;

   --------------
   -- User_Can --
   --------------

   function User_Can (User       : Class_Users.User_Id_Type;
                      Capability : String)
                      -- , ...args)
                      return Boolean
   is
      use Class_Users;
      use Inc_Pluggables;

      User_2 : constant Wp_User := Get_Userdata (User);
   begin
      return User_Can (User_2, Capability);
   end User_Can;

   ----------------
   -- Wp_Roles_X --
   ----------------

   function Wp_Roles_X -- _X added
            return Class_Roles.Wp_Roles
   is
      use Class_Roles;
      use Inc_Roles;
   begin
      -- if not Isset (Global_Wp_Roles) then
      --    Global_Wp_Roles := new WP_Roles();
      -- end if;
      return Global_Wp_Roles;
   end Wp_Roles_X;

   --------------
   -- Get_Role --
   --------------

   function Get_Role (Role : String)
                      return Class_Role.Wp_Role
   is
   begin
      return Wp_Roles_X.Get_Role (Role);
--    return wp_roles().Get_Role (Role);
   end Get_Role;

   --------------
   -- Add_Role --
   --------------

   procedure Add_Role (Role         : String;
                       Display_Name : String;
                       Capabilities : Array_Type := Empty_Array)
   is
      use Php.Strings;
      use Class_Role;
      use Class_Roles;
      use Inc_Roles;

      Unused : Wp_Role;
   begin
      if Empty (Role) then
         return;
      end if;

      Unused := Global_Wp_Roles.Add_Role (Role, Display_Name, Capabilities);
--    return Wp_Roles_X.Add_Role (Role, Display_Name, Capabilities);
   end Add_Role;

-- --
-- -- Removes a role, if it exists.
-- --
-- -- @since 2.0.0
-- --
-- -- @param string role Role name.
-- --
-- function remove_role( role ) then
--         wp_roles().remove_role( role );
-- end;

   ----------------------
   -- Get_Super_Admins --
   ----------------------

   function Get_Super_Admins
            return List_Type
   is
      use Inc_Options;
   begin
      if not Global_Super_Admins.Is_Empty then
--    if Isset (Global_Super_Admins) then
         return Global_Super_Admins;
      else
         return As_List (
           Get_Site_Option ("site_admins", From_List (["admin"])));
      end if;
   end Get_Super_Admins;

   --------------------
   -- Is_Super_Admin --
   --------------------

   function Is_Super_Admin (User_Id : Class_Users.User_Id_Type := 0) -- false
                            return Boolean
   is
      use Php.Lists;
      use Php.Types;
      use UStrings;
      use Class_Users;
      use Inc_Load;
      use Inc_Pluggables;

      User : Wp_User := (if User_Id = 0
                         then Wp_Get_Current_User -- ()
                         else Get_Userdata (User_Id));
   begin
      if User = Null_User or else not User.Exists then -- ()
         return False;
      end if;

      if Is_Multisite then
         declare
            Super_Admins : constant List_Type := Get_Super_Admins; -- ()
         begin
            if
              Is_Array (Super_Admins) and then
              In_List (-User.Prop.User_Login, Super_Admins, True)
            then
               return True;
            end if;
         end;
      else
         if User.Has_Cap ("delete_users") then
            return True;
         end if;
      end if;

      return False;
   end Is_Super_Admin;

-- --
-- -- Grants Super Admin privileges.
-- --
-- -- @since 3.0.0
-- --
-- -- @global array super_admins
-- --
-- -- @param int user_id ID of the user to be granted Super Admin privileges.
-- -- @return bool True on success, false on failure. This can fail when the user is
-- --              already a super admin or when the `super_admins` global is defined.
-- --
-- function grant_super_admin( user_id ) then
--         -- If global super_admins override is defined, there is nothing to do here.
--         if ( isset( GLOBALS["super_admins"] ) || ! is_multisite() ) then
--                 return false;
--         end;

--         --
--         -- Fires before the user is granted Super Admin privileges.
--         --
--         -- @since 3.0.0
--         --
--         -- @param int user_id ID of the user that is about to be granted Super Admin privileges.
--         --
--         do_action( "grant_super_admin", user_id );

--         -- Directly fetch site_admins instead of using get_super_admins().
--         super_admins = get_site_option( "site_admins", array( "admin" ) );

--         user = get_userdata( user_id );
--         if ( user && ! in_array( user.user_login, super_admins, true ) ) then
--                 super_admins[] = user.user_login;
--                 update_site_option( "site_admins", super_admins );

--                 --
--                 -- Fires after the user is granted Super Admin privileges.
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param int user_id ID of the user that was granted Super Admin privileges.
--                 --
--                 do_action( "granted_super_admin", user_id );
--                 return true;
--         end;
--         return false;
-- end;

-- --
-- -- Revokes Super Admin privileges.
-- --
-- -- @since 3.0.0
-- --
-- -- @global array super_admins
-- --
-- -- @param int user_id ID of the user Super Admin privileges to be revoked from.
-- -- @return bool True on success, false on failure. This can fail when the user"s email
-- --              is the network admin email or when the `super_admins` global is defined.
-- --
-- function revoke_super_admin( user_id ) then
--         -- If global super_admins override is defined, there is nothing to do here.
--         if ( isset( GLOBALS["super_admins"] ) || ! is_multisite() ) then
--                 return false;
--         end;

--         --
--         -- Fires before the user"s Super Admin privileges are revoked.
--         --
--         -- @since 3.0.0
--         --
--         -- @param int user_id ID of the user Super Admin privileges are being revoked from.
--         --
--         do_action( "revoke_super_admin", user_id );

--         -- Directly fetch site_admins instead of using get_super_admins().
--         super_admins = get_site_option( "site_admins", array( "admin" ) );

--         user = get_userdata( user_id );
--         if ( user && 0 !== strcasecmp( user.user_email, get_site_option( "admin_email" ) ) ) then
--                 key = array_search( user.user_login, super_admins, true );
--                 if ( false !== key ) then
--                         unset( super_admins[ key ] );
--                         update_site_option( "site_admins", super_admins );

--                         --
--                         -- Fires after the user"s Super Admin privileges are revoked.
--                         --
--                         -- @since 3.0.0
--                         --
--                         -- @param int user_id ID of the user Super Admin privileges were revoked from.
--                         --
--                         do_action( "revoked_super_admin", user_id );
--                         return true;
--                 end;
--         end;
--         return false;
-- end;

-- --
-- -- Filters the user capabilities to grant the "install_languages" capability as necessary.
-- --
-- -- A user must have at least one out of the "update_core", "install_plugins", and
-- -- "install_themes" capabilities to qualify for "install_languages".
-- --
-- -- @since 4.9.0
-- --
-- -- @param bool[] allcaps An array of all the user"s capabilities.
-- -- @return bool[] Filtered array of the user"s capabilities.
-- --
-- function wp_maybe_grant_install_languages_cap( allcaps ) then
--         if ( ! empty( allcaps["update_core"] ) || ! empty( allcaps["install_plugins"] ) || ! empty( allcaps["install_themes"] ) ) then
--                 allcaps["install_languages"] = true;
--         end;

--         return allcaps;
-- end;

-- --
-- -- Filters the user capabilities to grant the "resume_plugins" and "resume_themes" capabilities as necessary.
-- --
-- -- @since 5.2.0
-- --
-- -- @param bool[] allcaps An array of all the user"s capabilities.
-- -- @return bool[] Filtered array of the user"s capabilities.
-- --
-- function wp_maybe_grant_resume_extensions_caps( allcaps ) then
--         -- Even in a multisite, regular administrators should be able to resume plugins.
--         if ( ! empty( allcaps["activate_plugins"] ) ) then
--                 allcaps["resume_plugins"] = true;
--         end;

--         -- Even in a multisite, regular administrators should be able to resume themes.
--         if ( ! empty( allcaps["switch_themes"] ) ) then
--                 allcaps["resume_themes"] = true;
--         end;

--         return allcaps;
-- end;

-- --
-- -- Filters the user capabilities to grant the "view_site_health_checks" capabilities as necessary.
-- --
-- -- @since 5.2.2
-- --
-- -- @param bool[]   allcaps An array of all the user"s capabilities.
-- -- @param string[] caps    Required primitive capabilities for the requested capability.
-- -- @param array    args then
-- --     Arguments that accompany the requested capability check.
-- --
-- --     @type string    0 Requested capability.
-- --     @type int       1 Concerned user ID.
-- --     @type mixed  ...2 Optional second and further parameters, typically object ID.
-- -- end;
-- -- @param WP_User  user    The user object.
-- -- @return bool[] Filtered array of the user"s capabilities.
-- --
-- function wp_maybe_grant_site_health_caps( allcaps, caps, args, user ) then
--         if ( ! empty( allcaps["install_plugins"] ) && ( ! is_multisite() || is_super_admin( user.ID ) ) ) then
--                 allcaps["view_site_health_checks"] = true;
--         end;

--         return allcaps;
-- end;

-- return;

-- -- Dummy gettext calls to get strings in the catalog.
-- /* translators: User role for administrators.--
-- _x( "Administrator", "User role" );
-- /* translators: User role for editors.--
-- _x( "Editor", "User role" );
-- /* translators: User role for authors.--
-- _x( "Author", "User role" );
-- /* translators: User role for contributors.--
-- _x( "Contributor", "User role" );
-- /* translators: User role for subscribers.--
-- _x( "Subscriber", "User role" );

end Inc_Capabilities;
