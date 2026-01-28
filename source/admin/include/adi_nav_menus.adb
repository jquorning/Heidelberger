--
-- Core Navigation Menu API
--
-- @package WordPress
-- @subpackage Nav_Menus
-- @since 3.0.0
--

-- Walker_Nav_Menu_Edit class
-- require_once ABSPATH . "wp-admin/includes/class-walker-nav-menu-edit.php";

-- Walker_Nav_Menu_Checklist class
-- require_once ABSPATH . "wp-admin/includes/class-walker-nav-menu-checklist.php";

with Ada.Containers;

with Binder;
with Globals;
with Helpers;
with UStrings;
with Wp_Common;

with Adi_Templates;

-- with Class_Post_Type;
with Class_Taxonomy;
with Class_Terms;
with Class_Users;
with Class_Querys;
with Inc_Formatting;
with Inc_Functions;
with Inc_General_Templates;
with Inc_L10n;
with Inc_Nav_Menus;
with Inc_Nav_Menu_Templates;
with Inc_Options;
with Inc_Plugins;
with Inc_Pluggables;
with Inc_Post_Templates;
with Inc_Taxonomys;
with Inc_Posts;
with Inc_Users;

package body Adi_Nav_Menus
is

   ---------------------------------
   -- X_Wp_Ajax_Menu_Quick_Search --
   ---------------------------------

   procedure X_Wp_Ajax_Menu_Quick_Search (Request : Array_Type := Empty_Array)
   is
      Args : constant Array_Type := Empty_Array;

      Typ         : String := (if Isset (Request, "type")
                               then Get_As_String ((Request, "type")) else "");

      Object_Type : String := (if Isset (Request, "object_type")
                               then Get_As_String ((Request, "object_type")) else "");

      Query       : String := (if Isset (Request, "q")
                               then Get_As_String ((Request, "q")) else "");

      Response_Format : UString :=
         +(if Isset (Request, "response-format")
           then Get_As_String ((Request, "response-format")) else "");

      Matches : List_Type;
   begin
      if "" = Response_Format or else -Response_Format not in "json" | "markup" then
         Response_Format := +"json";
      end if;

      -- if "markup" = Response_Format then
      --         Set (Args, "walker", new Walker_Nav_Menu_Checklist);
      -- end if;

      if "get-post-item" = Typ then
         if Inc_Posts.Post_Type_Exists (Object_Type) then
            if Isset (Request, "ID") then
               declare
                  Object_Id : constant Integer := As_Integer (Get (Request, "ID"));
               begin
                  if "markup" = Response_Format then
                     null;
--                                        echo (Walk_Nav_Menu_Tree (Array_Map ("wp_setup_nav_menu_item",
--                                              To_array (Get_Post (Object_Id))), 0, Args)); -- (object)
                  elsif "json" = Response_Format then
                     Echo (Inc_Functions.Wp_JSON_Encode (
                        Arrays.To_Array ((
                           Build ("ID",         Object_Id),
                           Build ("post_title",
                                  Inc_Post_Templates.Get_The_Title (Object_Id)),
                           Build ("post_type",
                                  Inc_Posts.Get_Post_Type (Post_Id (Object_Id)))
                           ))
                        ));
                        Echo ("\n");
                  end if;
               end;
            end if;

         elsif Inc_Taxonomys.Taxonomy_Exists (Object_Type) then
            if Isset (Request, "ID") then
               declare
                  Object_Id : constant Integer := As_Integer (Get (Request, "ID"));
               begin
                  if "markup" = Response_Format then
                     null;
--                                        Echo (Walk_Nav_Menu_Tree (Array_Map ("wp_setup_nav_menu_item",
--                                              To_Array (Inc_Taxonomys.Get_Term (Object_Id, Object_Type))), 0, Args)); -- (object)
                  elsif "json" = Response_Format then
                     declare
                        use Class_Terms;
                        use Inc_Taxonomys;

                        Post_Obj : constant Wp_Term :=
                          Get_Term (Object_Id, Object_Type);
                     begin
                        Echo (Inc_Functions.Wp_JSON_Encode (
                           Arrays.To_Array ((
                              Build ("ID",         Object_Id),
                              Build ("post_title", -Post_Obj.Name),
                              Build ("post_type",  Object_Type)
                           ))
                        ));
                        Echo ("\n");
                     end;
                  end if;
               end;
            end if;
         end if;
      elsif
        0 /= Preg_Match ("/quick-search-(posttype|taxonomy)-((a-zA-Z_-)*\b)/",
                         Typ, Matches)
      then
         if
           "posttype" = Matches (1) and then
           Inc_Posts.Get_Post_Type_Object (-Matches (2))
         then
            declare
               use Class_Post_Type;

               Post_Type_Obj : Wp_Post := -- Array_Type :=
                  X_Wp_Nav_Menu_Meta_Box_Object
                    (Wp_Post_Type'(Inc_Posts.Get_Post_Type_Object (-Matches (2))));

                  Args_2 : constant Array_Type := Array_Merge (
                     Args,
                     Arrays.To_Array ((
                        Build ("no_found_rows",          "true"),
                        Build ("update_post_meta_cache", "false"),
                        Build ("update_post_term_cache", "false"),
                        Build ("posts_per_page",         "10"),
                        Build ("post_type",              -Matches (2)),
                        Build ("s",                      Query)
                     ))
                  );
            begin
               -- if Isset (Post_Type_Obj.X_Default_Query) then
               --    Args_2 := Array_Merge (Args_2,
               --                           To_array (Post_Type_Obj.X_Default_Query));
               -- end if;

               declare
                  use Class_Querys;

                  Search_Results_Query : Wp_Query; -- := new WP_Query (Args_2);
               begin
                  if not Search_Results_Query.Have_Posts then -- ()
                     return;
                  end if;

                  while Search_Results_Query.Have_Posts loop -- ()
                     declare
--                      use Inc_Class_Wp_Posts;

                        Post : constant Wp_Post := Search_Results_Query.Next_Post;
                     begin
                        if "markup" = Response_Format then
                           declare
                              use Inc_Nav_Menu_Templates;

                              Var_By_Ref : constant Post_Id := Post.Id;
                           begin
                              Echo (
                                Walk_Nav_Menu_Tree (
                                  Array_Map ("wp_setup_nav_menu_item",
                                    To_Array (
                                      Inc_Posts.Get_Post (Var_By_Ref))), 0, Args_2)); -- (object)
                           end;
                        elsif "json" = Response_Format then
                           Echo (Inc_Functions.Wp_JSON_Encode (
                              Arrays.To_Array ((
                                 Build ("ID",         Integer (Post.Id)),
                                 Build ("post_title",
                                        Inc_Post_Templates.Get_The_Title
                                           (Integer (Post.Id))),
                                 Build ("post_type",  -Matches (2))
                              ))
                           ));
                           Echo ("\n");
                        end if;
                     end;
                  end loop;
               end;
            end;
         elsif "taxonomy" = Matches (1) then
            declare
               use Class_Terms;
               use Inc_Nav_Menu_Templates;

               Terms : constant Wp_Term_Array :=
                  Inc_Taxonomys.Get_Terms (
                     Arrays.To_Array ((
                        Build ("taxonomy",   -Matches (2)),
                        Build ("name__like", Query),
                        Build ("number",     "10"),
                        Build ("hide_empty", "false")
                     )));
            begin
               if
                 False
--                 Empty (Terms) or else
--                 Is_Wp_Error (Terms)
               then
                  return;
               end if;

               for Term of Terms loop -- To_Array (Terms) loop
                  if "markup" = Response_Format then
                     null;
--                   Echo (Walk_Nav_Menu_Tree (Array_Map ("wp_setup_nav_menu_item",
--                         Arrays.To_Array ((1 => Build (Term, "")))), 0, Args)); -- (object)

                  elsif "json" = Response_Format then
                     Echo (Inc_Functions.Wp_JSON_Encode (
                        Arrays.To_Array ((
                           Build ("ID",         Term.Term_Id),
                           Build ("post_title", -Term.Name),
                           Build ("post_type",  -Matches (2))
                        ))
                     ));
                     Echo ("\n");
                  end if;
               end loop;
            end;
         end if;
      end if;
   end X_Wp_Ajax_Menu_Quick_Search;

   -----------------------
   -- Wp_Nav_Menu_Setup --
   -----------------------

   procedure Wp_Nav_Menu_Setup
   is
      use Adi_Templates;
      use Inc_Plugins;
   begin
      -- Register meta boxes.
      Wp_Nav_Menu_Post_Type_Meta_Boxes;  -- ();
      Add_Meta_Box ("add-custom-links", abs "Custom Links",
                    Wp_Nav_Menu_Item_Link_Meta_Box'Access, "nav-menus",
                    "side", "default");
      Wp_Nav_Menu_Taxonomy_Meta_Boxes; -- ();

      -- Register advanced menu items (columns).
      Add_Filter ("manage_nav-menus_columns", Wp_Nav_Menu_Manage_Columns'Access);

      -- If first time editing, disable advanced items by default.
      if False = Inc_Users.Get_User_Option ("managenav-menuscolumnshidden") then
         declare
            use Inc_Pluggables;
            use Class_Users;
            use Inc_Users;

            User : constant Wp_User := Wp_Get_Current_User; -- ();
         begin
            Update_User_Meta (
                        User.Id,
                        "managenav-menuscolumnshidden",
                        Arrays.To_Array ((
                           Build ("0", "link-target"),  -- "0" was 0
                           Build ("1", "css-classes"),
                           Build ("2", "xfn"),
                           Build ("3", "description"),
                           Build ("4", "title-attribute")
                        )));
         end;
      end if;
   end Wp_Nav_Menu_Setup;

   ------------------------------------
   -- Wp_Initial_Nav_Menu_Meta_Boxes --
   ------------------------------------

   procedure Wp_Initial_Nav_Menu_Meta_Boxes
   is
--        global (Wp_Meta_Boxes);
   begin
      if
        Inc_Users.Get_User_Option ("metaboxhidden_nav-menus") /= False -- or else
--      not Is_Array (Wp_Meta_Boxes)
      then
         return;
      end if;

      declare
         Initial_Meta_Boxes : List_Type :=
            ["add-post-type-page", "add-post-type-post",
             "add-custom-links",   "add-category"];

         Hidden_Meta_Boxes : constant Array_Type := Empty_Array;
      begin
         for Context of Wp_Meta_Boxes ("nav-menus") loop
--       for Context of Array_Keys (Get (Wp_Meta_Boxes, "nav-menus")) loop
            for Priority of Context loop -- Wp_Meta_Boxes ("nav-menus") (Context)
--            Priority of Array_Keys (Get_2 (Wp_Meta_Boxes, "nav-menus", -Context))
--          loop
               for Box in Priority.Iterate loop
--             for Box of Wp_Meta_Boxes ("nav-menus") (Context) (Priority) loop
                  null;
                  -- if In_Array (Get (Box, "id"), Initial_Meta_Boxes, True) then
                  --    Unset (Box ("id"));
                  -- else
                  --    Set (Hidden_Meta_Boxes, Get (Box, "id")); -- ()
                  -- end if;
               end loop;
            end loop;
         end loop;

         declare
            use Class_Users;
            use Inc_Pluggables;
            use Inc_Users;

            User : constant Wp_User := Wp_Get_Current_User; -- ();
         begin
            Update_User_Meta (User.Id, "metaboxhidden_nav-menus", Hidden_Meta_Boxes);
         end;
      end;
   end Wp_Initial_Nav_Menu_Meta_Boxes;

   --------------------------------------
   -- Wp_Nav_Menu_Post_Type_Meta_Boxes --
   --------------------------------------

   procedure Wp_Nav_Menu_Post_Type_Meta_Boxes
   is
      use Class_Post_Type;
      use Inc_Posts;
--    use String_Vectors;
      use Ada.Containers;
      use Wp_Common;

      Post_Types : constant Wp_Post_Type_Array :=
         Get_Post_Types (Arrays.To_Array ((1 => Build ("show_in_nav_menus", "true"))),
                         "object");
   begin
      if Post_Types.Is_Empty then -- not Post_Types then
         return;
      end if;

      for Post_Type of Post_Types loop
         --
         -- Filters whether a menu items meta box will be added for the current
         -- object type.
         --
         -- If a falsey value is returned instead of an object, the menu items
         -- meta box for the current meta box object will not be added.
         --
         -- @since 3.0.0
         --
         -- @param WP_Post_Type|false post_type The current object to add a menu items
         --                                      meta box for.
         --
         declare
            Post_Type_2 : constant Wp_Post_Type := Post_Type;
--               Apply_Filters ("nav_menu_meta_box_object", Post_Type);
         begin
--            if Post_Type_2 then
               declare
                  use Adi_Templates;

                  Id : constant String := -Post_Type.Name;
                  -- Give pages a higher priority.
                  Priority : String :=  (if "page" = Post_Type_2.Name
                                         then "core" else "default");
               begin
                  Add_Meta_Box ("add-post-type-" & Id,
                                Get (Post_Type_2, "labels.name"),
                                Wp_Nav_Menu_Item_Post_Type_Meta_Box'Access,
                                "nav-menus", "side", Priority); -- , Post_Type_2);
               end;
--            end if;
         end;
      end loop;
   end Wp_Nav_Menu_Post_Type_Meta_Boxes;

   -------------------------------------
   -- Wp_Nav_Menu_Taxonomy_Meta_Boxes --
   -------------------------------------

   procedure Wp_Nav_Menu_Taxonomy_Meta_Boxes
   is
      use Ada.Containers;
      use Adi_Templates;
      use Inc_Taxonomys;
      use Class_Taxonomy;
      use Taxonomy_Vectors;

      Taxonomies : constant Taxonomy_Array :=
         Get_Taxonomies (Arrays.To_Array ((1 => Build ("show_in_nav_menus", "true"))),
                         "object");
   begin
      if Length (Taxonomies) = 0 then -- not Taxonomies then
         return;
      end if;

      for Tax of Taxonomies loop
         declare
            -- This filter is documented in wp-admin/includes/nav-menu.php--
            Tax_2 : constant Wp_Taxonomy := Tax;
               -- Apply_Filters ("nav_menu_meta_box_object", Tax);
         begin
--            if Tax_2 then
               declare
                  Id : constant String := -Tax_2.Name;
               begin
                  Add_Meta_Box ("add-" & Id, Get_As_String ((Tax_2.Labels, "name")),
                                Wp_Nav_Menu_Item_Taxonomy_Meta_Box'Access,
                                "nav-menus", "side", "default"); -- , Tax_2);
               end;
--            end if;
         end;
      end loop;
   end Wp_Nav_Menu_Taxonomy_Meta_Boxes;

   ---------------------------------
   -- Wp_Nav_Menu_Disabled_Check --
   ---------------------------------

   function Wp_Nav_Menu_Disabled_Check (Nav_Menu_Selected_Id : String;
                                        Display              : Boolean := True)
                                        return String
   is
      use Inc_General_Templates;
--        global (One_Theme_Location_No_Menus);
   begin
      if One_Theme_Location_No_Menus then
         return ""; -- False;
      end if;

      return Disabled (Nav_Menu_Selected_Id, 0, Display);
   end Wp_Nav_Menu_Disabled_Check;

   ------------------------------------
   -- Wp_Nav_Menu_Item_Link_Meta_Box --
   ------------------------------------

   procedure Wp_Nav_Menu_Item_Link_Meta_Box
   is
--        global (x_nav_menu_placeholder, Nav_Menu_Selected_Id);
   begin
      X_Nav_Menu_Placeholder := (if 0 > X_Nav_Menu_Placeholder
                                 then X_Nav_Menu_Placeholder - 1 else -1);

        -- ?>
        -- <div class="customlinkdiv" id="customlinkdiv">
        --         <input type="hidden" value="custom" name="menu-item(<?php echo _nav_menu_placeholder; ?>)(menu-item-type)" />
        --         <p id="menu-item-url-wrap" class="wp-clearfix">
        --                 <label class="howto" for="custom-menu-item-url"><?php _e ("URL"); ?></label>
        --                 <input id="custom-menu-item-url" name="menu-item(<?php echo _nav_menu_placeholder; ?>)(menu-item-url)" type="text"<?php wp_nav_menu_disabled_check (nav_menu_selected_id); ?> class="code menu-item-textbox form-required" placeholder="https: *" />
        --         </p>

        --         <p id="menu-item-name-wrap" class="wp-clearfix">
        --                 <label class="howto" for="custom-menu-item-name"><?php _e ("Link Text"); ?></label>
        --                 <input id="custom-menu-item-name" name="menu-item(<?php echo _nav_menu_placeholder; ?>)(menu-item-title)" type="text"<?php wp_nav_menu_disabled_check (nav_menu_selected_id); ?> class="regular-text menu-item-textbox" />
        --         </p>

        --         <p class="button-controls wp-clearfix">
        --                 <span class="add-to-menu">
        --                         <input type="submit"<?php wp_nav_menu_disabled_check (nav_menu_selected_id); ?> class="button submit-add-to-menu right" value="<?php esc_attr_e ("Add to Menu"); ?>" name="add-custom-menu-item" id="submit-customlinkdiv" />
        --                         <span class="spinner"></span>
        --                 </span>
        --         </p>

        -- </div><!-- /.customlinkdiv -->
        -- <?php
   end Wp_Nav_Menu_Item_Link_Meta_Box;

   -----------------------------------------
   -- Wp_Nav_Menu_Item_Post_Type_Meta_Box --
   -----------------------------------------

   function Wp_Nav_Menu_Item_Post_Type_Meta_Box (Data_Object : String;
                                                 Box         : Array_Type)
                                                 return Array_Type
   is
--        global (x_nav_menu_placeholder, Nav_Menu_Selected_Id);
      use Class_Post_Type;
      use Inc_Formatting;
      use Inc_Posts;
      use Inc_Options;

      Post_Type_Name : constant String       := "XXX-615"; -- -Get (Box, "args").Name;
      Post_Type      : constant Wp_Post_Type := Get_Post_Type_Object (Post_Type_Name);
      Tab_Name       : constant String       := Post_Type_Name & "-tab";

      -- Paginate browsing for large numbers of post objects.
      Per_Page : constant Natural := 50;

      Pagenum  : constant Natural :=
        (if
           Isset (X_REQUEST, Tab_Name) and then
           Isset (X_REQUEST, "paged")
         then abs As_Integer (Get (X_REQUEST, "paged")) else 1);
--       then Absint (Get_Integer (X_REQUEST, "paged")) else 1);

      Offset : constant Natural := (if 0 < Pagenum
                                    then Per_Page * (Pagenum - 1) else 0);

      Args : Array_Type := Arrays.To_Array ((
              Build ("offset",                 Offset),
              Build ("order",                  "ASC"),
              Build ("orderby",                "title"),
              Build ("posts_per_page",         Per_Page),
              Build ("post_type",              Post_Type_Name),
              Build ("suppress_filters",       "true"),
              Build ("update_post_term_cache", "false"),
              Build ("update_post_meta_cache", "false")
      ));

      --
      -- If we"re dealing with pages, let's prioritize the Front Page,
      -- Posts Page and Privacy Policy Page at the top of the list.
      --
      Important_Pages   : constant List_Type  := []; -- List_Array;
      Suppress_Page_Ids : Array_Type := Empty_Array;
      Front_Page        : Post_Id    := 0;
      Front_Page_Obj    : Wp_Post;
   begin
--    if Isset (Box ("args").X_Default_Query) then
--       Args := Array_Merge (Args, To_Array (Box ("args").X_Default_Query));
--    end if;

--        Important_Pages := Empty_Array;
      if "page" = Post_Type_Name then
         Suppress_Page_Ids := Empty_Array;

         -- Insert Front Page or custom Home link.
         Front_Page :=
           (if "page" = Get_Option ("show_on_front")
            then Post_Id'Value (Get_Option ("page_on_front")) else 0); -- (int)

         Front_Page_Obj := Null_Post; -- null;

         if Front_Page = 0 then
--         if not Empty (Front_Page) then
            Front_Page_Obj               := Get_Post (Front_Page);
--          Front_Page_Obj.Front_Or_Home := True;

--          Set (Important_Pages,   Front_Page_Obj);    -- ()
--          Set (Suppress_Page_Ids, Front_Page_Obj.ID); -- ()
         else
            X_Nav_Menu_Placeholder :=  (if 0 > X_Nav_Menu_Placeholder
                                        then X_Nav_Menu_Placeholder - 1 else -1); -- (int)
            -- Front_Page_Obj := Arrays.To_Array ((  -- (object)
            --    Build ("front_or_home", "true"),
            --    Build ("ID",            "0"),
            --    Build ("object_id",     X_Nav_Menu_Placeholder),
            --    Build ("post_content",  ""),
            --    Build ("post_excerpt",  ""),
            --    Build ("post_parent",   ""),
            --    Build ("post_title",    x_x ("Home", "nav menu home label")),
            --    Build ("post_type",     "nav_menu_item"),
            --    Build ("type",          "custom"),
            --    Build ("url",           Home_Url ("/"))
            -- ));

--            Set (Important_Pages, Front_Page_Obj);  -- ()
         end if;

         -- Insert Posts Page.
         declare
            Posts_Page : constant Post_Id :=
              (if "page" = Get_Option ("show_on_front")
               then Post_Id (Integer'(Get_Option ("page_for_posts"))) else 0);

            Posts_Page_Obj : Wp_Post;
         begin
            if Posts_Page /= 0 then
--          if not Empty (Posts_Page) then
               Posts_Page_Obj            := Get_Post (Posts_Page);
--             Posts_Page_Obj.Posts_Page := True;

--             Set (Important_Pages,  Posts_Page_Obj);    -- ()
--             Set (Suppress_Page_Id, Posts_Page_Obj.Id); -- ()
            end if;
         end;

         -- Insert Privacy Policy Page.
         declare
            Privacy_Policy_Page_Id : constant Post_Id :=
              Post_Id (Integer'(Get_Option ("wp_page_for_privacy_policy")));
         begin
            if Privacy_Policy_Page_Id /= 0 then
--          if not Empty (Privacy_Policy_Page_Id) then
               declare
                  Privacy_Policy_Page : constant Wp_Post :=
                    Get_Post (Privacy_Policy_Page_Id);
               begin
                  if
                    Privacy_Policy_Page in Wp_Post and then    -- instanceof
                    "publish" = Privacy_Policy_Page.Post_Status
                  then
                     null;
--                   Privacy_Policy_Page.Privacy_Policy_Page := True;

--                   Set (Important_Pages,   Privacy_Policy_Page);    -- ()
--                   Set (Suppress_Page_Ids, Privacy_Policy_Page.Id); -- ()
                  end if;
               end;
            end if;
         end;

         -- Add suppression array to arguments for WP_Query.
         if not Empty (Suppress_Page_Ids) then
            Set (Args, "post__not_in", From_Array (Suppress_Page_Ids));
         end if;
      end if;

      -- @todo Transient caching of these results with proper invalidation on
      -- updating of a post of this type.
      declare
         use Class_Querys;

         Get_Posts : Wp_Query; -- := new WP_Query;
         Posts     : Array_Type; --  := Get_Posts.Query (Args);
      begin
         -- Only suppress and insert when more than just suppression pages available.
         if 0 = Get_Posts.Post_Count then
--       if not Get_Posts.Post_Count then
            if not Empty (Suppress_Page_Ids) then
               null;
--             Unset (Args ("post__not_in"));
--             Get_Posts := new WP_Query;
--             Posts     := Get_Posts.Query (Args);
            else
               Echo ("<p>" & abs "No items." & "</p>");
               return Empty_Array;
            end if;

         elsif Important_Pages.Is_Empty then
--       elsif not Empty (Important_Pages) then
            null;
--          Posts := Array_Merge (Important_Pages, Posts);
         end if;

         declare
            use Inc_General_Templates;

            Num_Pages : constant Natural := Get_Posts.Max_Num_Pages;

            Page_Links : String := Paginate_Links (
               Arrays.To_Array ((
               -- Build ("base", Add_Query_Arg (To_Array ((
               --                Build (Tab_Name,     "all"),
               --                Build ("paged",       "%#%"),
               --                Build ("item-type",   "post_type"),
               --                Build ("item-object", Post_Type_Name))))),
               Build ("format",             ""),

               Build ("prev_text",          "<span aria-label=""" &
                  Esc_Attr_X ("Previous page") & """>" & abs "&laquo;" & "</span>"),

               Build ("next_text",          "<span aria-label=""" &
                  Esc_Attr_X ("Next page") & """>" & abs "&raquo;" & "</span>"),

               Build ("before_page_number", "<span class=""screen-reader-text"">" &
                  abs "Page" & "</span> "),

               Build ("total",              Num_Pages),
               Build ("current",            Pagenum))));
         begin
            null;
         end;
      end;

      declare
         DB_Fields : Array_Type; -- Boolean := False;
      begin
         if Is_Post_Type_Hierarchical (Post_Type_Name) then
            DB_Fields := Arrays.To_Array ((
               Build ("parent", "post_parent"),
               Build ("id",     "ID")));
         end if;

--      Walker := new Walker_Nav_Menu_Checklist (Db_Fields);
      end;

      declare
         Current_Tab : UString := +"most-recent";
      begin
         if
           Isset (X_REQUEST, Tab_Name) -- and then
--         In_Array (X_REQUEST (Tab_Name), To_array ("all", "search"), true)
         then
            Current_Tab := +Get_As_String ((X_REQUEST, Tab_Name));
         end if;

         if not Empty (X_REQUEST, "quick-search-posttype-" & Post_Type_Name) then
            Current_Tab := +"search";
         end if;

         declare
            use Inc_Functions;

            Removed_Args : constant List_Type :=
              ["action",
               "customlink-tab",
               "edit-menu-item",
               "menu-item",
               "page-tab",
               "_wpnonce"
              ];

            Most_Recent_URL : UString;
            View_All_URL    : UString;
            Search_URL      : UString;
         begin
            if Nav_Menu_Selected_Id then
               Most_Recent_URL := +ESC_URL (Add_Query_Arg (Tab_Name, "most-recent",
                                     Remove_Query_Arg (Removed_Args)));
               View_All_URL    := +ESC_URL (Add_Query_Arg (Tab_Name, "all",
                                     Remove_Query_Arg (Removed_Args)));
               Search_URL      := +ESC_URL (Add_Query_Arg (Tab_Name, "search",
                                     Remove_Query_Arg (Removed_Args)));
            end if;
            pragma Style_Checks (Off);

      Echo ("<div id=""posttype-" & Post_Type_Name & """ class=""posttypediv"">" & NL);
      Echo ("        <ul id=""posttype-" & Post_Type_Name & "-tabs"" class=""posttype-tabs add-menu-item-tabs"">" & NL);
      Echo ("                <li " & (if "most-recent" = Current_Tab then " class=""tabs""" else "") & ">" & NL);
      Echo ("                        <a class=""nav-tab-link"" data-type=""tabs-panel-posttype-" & Esc_Attr (post_type_name) & "-most-recent"" href=""" &
            (-Most_Recent_Url) & "#tabs-panel-posttype-" & Post_Type_Name & "-most-recent"">" & NL);
      Echo ("                                ");
      X_E ("Most Recent");
      Echo (NL);
      Echo ("                        </a>" & NL);
      Echo ("                </li>" & NL);
      Echo ("                <li " & (if "all" = current_tab then " class=""tabs""" else "") & ">" & NL);
      Echo ("                        <a class=""nav-tab-link"" data-type=""" & Esc_Attr (post_type_name) & "-all"" href=""" & (-View_All_Url) & "#" &
           Post_Type_Name & "-all"">" & NL);
      Echo ("                                ");
      X_E ("View All");
      Echo (NL);
      Echo ("                        </a>" & NL);
      Echo ("                </li>" & NL);
      Echo ("                <li " & (if "search" = Current_Tab then " class=""tabs""" else "") & ">" & NL);
      Echo ("                        <a class=""nav-tab-link"" data-type=""tabs-panel-posttype-" & Esc_Attr (Post_Type_Name) & "-search"" href=""" &
            (-Search_URL) & "#tabs-panel-posttype-" & Post_Type_Name & "-search"">" & NL);
      Echo ("                                ");
      X_E ("Search");
      Echo (NL);
      Echo ("                        </a>" & NL);
      Echo ("                </li>" & NL);
      Echo ("        </ul><!-- .posttype-tabs -->" & NL);

      Echo ("        <div id=""tabs-panel-posttype-" & Post_Type_Name & "-most-recent"" class=""tabs-panel " &
            (if "most-recent" = current_tab then "tabs-panel-active" else "tabs-panel-inactive") & " role=""region"" aria-label=""");
      X_E ("Most Recent");
      Echo (""" tabindex=""0"">" & NL);
      Echo ("                <ul id=""" & Post_Type_Name & "checklist-most-recent"" class=""categorychecklist form-no-clear"">" & NL);

      pragma Style_Checks (On);

            declare
               Recent_Args : Array_Type := Array_Merge (
                  Args,
                  Arrays.To_Array ((
                     Build ("orderby",        "post_date"),
                     Build ("order",          "DESC"),
                     Build ("posts_per_page", "15")
                  )));

               Most_Recent : Array_Type;
            begin
               null;
--       Most_Recent     := Get_Posts.Query (Recent_Args);
--       Args ("walker") := Walker;

         --
         -- Filters the posts displayed in the "Most Recent" tab of the current
         -- post type"s menu items meta box.
         --
         -- The dynamic portion of the hook name, `post_type_name`, refers to the post
         -- type name.
         --
         -- Possible hook names include:
         --
         --  - `nav_menu_items_post_recent`
         --  - `nav_menu_items_page_recent`
         --
         -- @since 4.3.0
         -- @since 4.9.0 Added the `recent_args` parameter.
         --
         -- @param WP_Post() most_recent An array of post objects being listed.
         -- @param array     args        An array of `WP_Query` arguments for the
         --                              meta box.
         -- @param array     box         Arguments passed to
         --                              `wp_nav_menu_item_post_type_meta_box()`.
         -- @param array     recent_args An array of `WP_Query` arguments for
         --                              'Most Recent' tab.
         --
--       Most_Recent := Apply_Filters ("nav_menu_items_" & Post_Type_Name & "_recent",
--                                     Most_Recent, Args, Box, Recent_Args);

--       Echo (Walk_Nav_Menu_Tree (Array_Map ("wp_setup_nav_menu_item", Most_Recent),
--                                 0, Args));  -- (object)
            end;
            pragma Style_Checks (Off);

      Echo ("        </ul>" & NL);
      Echo ("</div><!-- /.tabs-panel -->" & NL);

      Echo ("<div class=""tabs-panel " &
            (if "search" = Current_Tab then "tabs-panel-active" else "tabs-panel-inactive") &
            " id=""tabs-panel-posttype-" & Post_Type_Name &
            "-search"" role=""region"" aria-label=""" &
            "XXX-621" & " tabindex=""0"">" & NL);
--          Post_Type.Labels.Search_Items & " tabindex=""0"">" & NL);

            pragma Style_Checks (On);

            declare
               Searched       : UString;
               Search_Results : Array_Type;
            begin
               if Isset (X_REQUEST, "quick-search-posttype-" & Post_Type_Name) then
                  Searched := +ESC_Attr (Get_As_String ((X_REQUEST, "quick-search-posttype-" &
                                         Post_Type_Name)));
--            Search_Results := Get_Posts (
--               To_Array ((
--                  Build ("s",         Searched),
--                  Build ("post_type", Post_Type_Name),
--                  Build ("fields",    "all"),
--                  Build ("order",     "DESC")
--               )));
               else
                  Searched       := +"";
                  Search_Results := Empty_Array;
               end if;
               pragma Style_Checks (Off);

      Echo ("        <p class=""quick-search-wrap"">" & Nl);
      Echo ("                <label for=""quick-search-posttype-" & Post_Type_Name & """ class=""screen-reader-text"">");
      X_E ("Search");
      Echo ("</label>" & NL);
      Echo ("                <input type=""search""" &
            Wp_Nav_Menu_Disabled_Check (Helpers.Image (Nav_Menu_Selected_Id)) &
            """ class=""quick-search"" value=""" & (-Searched) &
            """ name=""quick-search-posttype-" & Post_Type_Name &
            """ id=""quick-search-posttype-" & Post_Type_Name &
            """ />" & Nl);
      Echo ("                <span class=""spinner""></span>" & Nl);
      -- Echo ("                " &
      --       Adi_Templates.Submit_Button (abs "Search",
      --                      "small quick-search-submit hide-if-js",
      --                      "submit", False,
      --                      To_array ((1 => Build ("id", "submit-quick-search-posttype-" & Post_Type_Name)))) &  "" & Nl);
      Echo ("        </p>" & Nl);

      Echo ("        <ul id=""" & Post_Type_Name &
            "-search-checklist"" data-wp-lists=""list:" & Post_Type_Name &
            " class=""categorychecklist form-no-clear"">" & Nl);
      if
        not Empty (Search_Results) -- and then
        --  not Is_Wp_Error (search_results)
      then
--                      args("walker") = walker;
--                      echo walk_nav_menu_tree (array_map ("wp_setup_nav_menu_item", search_results), 0, (object) args);
         Echo ("                " & NL); -- ?>
--    elsif Is_Wp_Error (Search_Results) then
--      Echo ("                <li>" & Search_Results.Get_Error_Message & "</li>" & Nl);
      elsif not Empty (-Searched) then
         Echo ("                <li>");
         X_E ("No results found.");
         Echo ("</li>" & NL);
      end if;
      Echo ("        </ul>" & Nl);
      Echo ("</div><!-- /.tabs-panel -->" & Nl);

      Echo ("<div id=""" & Post_Type_Name &
            "-all"" class=""tabs-panel tabs-panel-view-all " &
           (if "all" = current_tab then "tabs-panel-active" else "tabs-panel-inactive") &
           """ role=""region"" aria-label=""" & -- Post_Type.Labels.All_Items &
           """ tabindex=""0"">" & Nl);
--    if not empty (Page_Links) then
      Echo ("                <div class=""add-menu-item-pagelinks"">" & Nl);
--    Echo ("                        " & Page_Links & "" & Nl);
      Echo ("                </div>" & Nl);
--    end if;
      Echo ("        <ul id=""" & Post_Type_Name &
            "checklist"" data-wp-lists=""list:" & Post_Type_Name &
            " class=""categorychecklist form-no-clear"">" & Nl);

               pragma Style_Checks (On);
            end;
         end;
--       Args ("walker") := Walker;

         if Post_Type.Has_Archive then
            X_Nav_Menu_Placeholder :=  (if 0 > X_Nav_Menu_Placeholder
                                       then X_Nav_Menu_Placeholder - 1 else -1);
            -- Array_Unshift (
            --    Posts,
            --    To_Array (( -- (object)
            --       Build ("ID",           "0"),
            --       Build ("object_id",    X_Nav_Menu_Placeholder),
            --       Build ("object",       Post_Type_Name),
            --       Build ("post_content", ""),
            --       Build ("post_excerpt", ""),
            --       Build ("post_title",   Post_Type.Labels.Archives),
            --       Build ("post_type",    "nav_menu_item"),
            --       Build ("type",         "post_type_archive"),
            --       Build ("url",          Get_Post_Type_Archive_Link (Post_Type_Name))
            --    )));
         end if;

         --
         -- Filters the posts displayed in the "View All" tab of the current
         -- post type"s menu items meta box.
         --
         -- The dynamic portion of the hook name, `post_type_name`, refers
         -- to the slug of the current post type.
         --
         -- Possible hook names include:
         --
         --  - `nav_menu_items_post`
         --  - `nav_menu_items_page`
         --
         -- @since 3.2.0
         -- @since 4.6.0 Converted the `post_type` parameter to accept a WP_Post_Type
         --              object.
         --
         -- @see WP_Query::query()
         --
         -- @param object()     posts     The posts for the current post type. Mostly
         --                               `WP_Post` objects, but can also contain
         --                               "fake" post objects to represent other menu
         --                               items.
         -- @param array        args      An array of `WP_Query` arguments.
         -- @param WP_Post_Type post_type The current post type object for this menu
         --                               item meta box.
         --
--       Posts := Apply_Filters ("nav_menu_items_" & Post_Type_Name,
--                               Posts, Args, Post_Type);

--       Checkbox_Items := Walk_Nav_Menu_Tree
--         (Array_Map ("wp_setup_nav_menu_item", Posts), 0, Args); -- (object)

--       Echo (Checkbox_Items);
         pragma Style_Checks (Off);
Echo ("                </ul>" & NL);
--      if not empty (Page_Links) then
Echo ("                        <div class=""add-menu-item-pagelinks"">" & NL);
-- Echo ("                                " & Page_Links & "" & NL);
Echo ("                        </div>" & NL);
--     end if;
Echo ("        </div><!-- /.tabs-panel -->" & NL);

Echo ("        <p class=""button-controls wp-clearfix"" data-items-type=""posttype-" &
      Esc_Attr (post_type_name) & """>" & NL);
Echo ("                <span class=""list-controls hide-if-no-js"">" & NL);
Echo ("                        <input type=""checkbox""" &
--    Wp_Nav_Menu_Disabled_Check (Nav_Menu_Selected_Id) & " id=""" &
      Esc_Attr (Tab_Name) & " class=""select-all"" />" & NL);
Echo ("                        <label for=""" & esc_attr (tab_name) &
      """>");
X_E ("Select All");
Echo ("</label>" & NL);
Echo ("                </span>" & nl);

Echo ("                <span class=""add-to-menu"">" & NL);
Echo ("                        <input type=""submit""" &
--    Wp_Nav_Menu_Disabled_Check (Nav_Menu_Selected_Id) &
      " class=""button submit-add-to-menu right"" value=""");
Esc_Attr_E ("Add to Menu");
Echo (""" name=""add-post-type-menu-item"" id=""" &
      Esc_Attr ("submit-posttype-" & Post_Type_Name) & " />" & NL);
Echo ("                        <span class=""spinner""></span>" & NL);
Echo ("                </span>" & NL);
Echo ("        </p>" & NL);

Echo ("</div><!-- /.posttypediv -->" & NL);
         pragma Style_Checks (On);
      end;
      return Empty_Array;
   end Wp_Nav_Menu_Item_Post_Type_Meta_Box;

   ----------------------------------------
   -- Wp_Nav_Menu_Item_Taxonomy_Meta_Box --
   ----------------------------------------

   procedure Wp_Nav_Menu_Item_Taxonomy_Meta_Box (Data_Object : String;
                                                 Box         : Array_Type)
   is
      use Inc_Formatting;
      use Class_Taxonomy;
      use Class_Terms;
      use Inc_Taxonomys;
      use Inc_General_Templates;

--        global nav_menu_selected_id;

      Taxonomy_Name : constant String := "XXX-622"; -- Box ("args").Name;
      Taxonomy      : Wp_Taxonomy := Get_Taxonomy (Taxonomy_Name);
      Tab_Name      : constant String      := Taxonomy_Name & "-tab";

      -- Paginate browsing for large numbers of objects.
      Per_Page : constant Natural := 50;
      Pagenum  : constant Natural :=
         (if
            Isset (X_REQUEST, Tab_Name) and then
            Isset (X_REQUEST, "paged")
          then abs As_Integer (Get (X_REQUEST, "paged")) else 1);

      Offset   : constant Natural :=
        (if 0 < Pagenum then Per_Page * (Pagenum - 1) else 0);

      Args : constant Array_Type := Arrays.To_Array ((
                Build ("taxonomy",     Taxonomy_Name),
                Build ("child_of",     "0"),
                Build ("exclude",      ""),
                Build ("hide_empty",   "false"),
                Build ("hierarchical", "1"),
                Build ("include",      ""),
                Build ("number",       Per_Page),
                Build ("offset",       Offset),
                Build ("order",        "ASC"),
                Build ("orderby",      "name"),
                Build ("pad_counts",   "false")
      ));

      Terms       : Wp_Term; --  := Get_Terms (Args);
      Num_Pages   : Natural;
      Page_Links  : UString;
      Current_Tab : UString;
   begin
      if Terms = Null_Term then -- or else Is_Wp_Error (Terms) then
         Echo ("<p>" & abs "No items." & "</p>");
         return;
      end if;

      Num_Pages := Natural (Float'Ceiling (
                Float (Wp_Count_Terms (
                   Array_Merge (
                      Args,
                      Arrays.To_Array ((
                         Build ("number", ""),
                         Build ("offset", "")
                      ))
                   )
               )) / Float (Per_Page)));

      Page_Links :=
         +Paginate_Links (
            Arrays.To_Array ((
               -- Build ("base",               Add_Query_Arg (
               --    To_Array ((
               --       Build (Tab_Name,      "all"),
               --       Build ("paged",       "%#%"),
               --       Build ("item-type",   "taxonomy"),
               --       Build ("item-object", Taxonomy_Name)
               -- )))),
            Build ("format",             ""),
            Build ("prev_text",
                   "<span aria-label=""" & Esc_Attr_X ("Previous page") & """>" &
                   abs "&laquo;" & "</span>"),
            Build ("next_text",
                   "<span aria-label=""" & Esc_Attr_X ("Next page") & """>" &
                   abs "&raquo;" & "</span>"),
            Build ("before_page_number",
                   "<span class=""screen-reader-text"">" & abs "Page" & "</span> "),
            Build ("total",              Num_Pages),
            Build ("current",            Pagenum)
         )));

      -- DB_Fields := False;
      -- if Is_Taxonomy_Hierarchical (Taxonomy_Name) then
      --    Db_Fields := To_Array ((
      --                   Build ("parent", "parent"),
      --                   Build ("id",     "term_id")
      --    ));
      -- end if;

      -- Walker := new Walker_Nav_Menu_Checklist (db_fields);

      Current_Tab := +"most-used";

      if
        Isset (X_REQUEST, Tab_Name) -- and then
--      In_Array (X_REQUEST, Tab_Name,
--                ["all", "most-used", "search"], True)
      then
         Current_Tab := +Get_As_String ((X_REQUEST, Tab_Name));
      end if;

      -- if not Empty (X_REQUEST ("quick-search-taxonomy-" & Taxonomy_Name)) then
      --    Current_Tab := +"search";
      -- end if;

      declare
         use Inc_Functions;

         Removed_Args : constant List_Type :=
           ["action",
            "customlink-tab",
            "edit-menu-item",
            "menu-item",
            "page-tab",
            "_wpnonce"
           ];

         Most_Used_URL : UString;
         View_All_URL  : UString;
         Search_URL    : UString;
      begin
         if Nav_Menu_Selected_Id then
            Most_Used_URL := +ESC_URL (Add_Query_Arg (Tab_Name, "most-used",
                                          Remove_Query_Arg (Removed_Args)));
            View_All_URL  := +ESC_URL (Add_Query_Arg (Tab_Name, "all",
                                          Remove_Query_Arg (Removed_Args)));
            Search_URL    := +ESC_URL (Add_Query_Arg (Tab_Name, "search",
                                          Remove_Query_Arg (Removed_Args)));
         end if;
         pragma Style_Checks (Off);

Echo ("<div id=""taxonomy-" & Taxonomy_Name & """ class=""taxonomydiv"">" & NL);
Echo ("        <ul id=""taxonomy-" & Taxonomy_Name &
      "-tabs"" class=""taxonomy-tabs add-menu-item-tabs"">" & NL);
Echo ("                <li " &
      (if "most-used" = Current_Tab then " class=""tabs""" else "") & ">" & NL);
Echo ("                        <a class=""nav-tab-link"" data-type=""tabs-panel-" &
      Esc_Attr (Taxonomy_Name) & "-pop"" href=""" & (-Most_Used_Url) & "#tabs-panel-" &
      Taxonomy_Name & "-pop"">" & NL);
-- Echo ("                                " &
--      Esc_Html (Taxonomy.Labels.most_used) & "" & NL);
Echo ("                        </a>" & NL);
Echo ("                </li>" & NL);
Echo ("                <li " &
      (if "all" = Current_Tab then " class=""tabs""" else "") & ">" & NL);
Echo ("                        <a class=""nav-tab-link"" data-type=""tabs-panel-" &
      Esc_Attr (Taxonomy_Name) & "-all"" href=""" & (-View_All_URL) & "#tabs-panel-" &
      Taxonomy_Name & "-all"">" & NL);
Echo ("                                ");
X_E ("View All");
Echo ("""" & NL);
Echo ("                        </a>" & NL);
Echo ("                </li>" & NL);
Echo ("                <li " &
      (if "search" = Current_Tab then " class=""tabs""" else "") & ">" & NL);
Echo ("                        <a class=""nav-tab-link"" data-type=""tabs-panel-search-taxonomy-" &
      Esc_Attr (Taxonomy_Name) & """ href=""" & (-Search_URL) &
      "#tabs-panel-search-taxonomy-" & Taxonomy_Name & """>" & NL);
Echo ("                                ");
X_E ("Search");
Echo ("""" & NL);
Echo ("                        </a>" & NL);
Echo ("                </li>" & NL);
Echo ("        </ul><!-- .taxonomy-tabs -->" & NL);

Echo ("        <div id=""tabs-panel-" & Taxonomy_Name &
      "-pop"" class=""tabs-panel " &
      (if "most-used" = Current_Tab then "tabs-panel-active"
       else "tabs-panel-inactive") &
      """ role=""region"" aria-label=""" & -- Taxonomy.Labels.Most_Used &
      """ tabindex=""0"">" & NL);
Echo ("                <ul id=""" & Taxonomy_Name &
      "checklist-pop"" class=""categorychecklist form-no-clear"" >" & NL);
      pragma Style_Checks (On);
      end;

      -- Popular_Terms := Get_Terms (
      --                    To_Array ((
      --                       Build ("taxonomy",     Taxonomy_Name),
      --                       Build ("orderby",      "count"),
      --                       Build ("order",        "DESC"),
      --                       Build ("number",       "10"),
      --                       Build ("hierarchical", "false")
      --                    ))
      --                 );
      -- Args ("walker") := Walker;
      -- Echo (Walk_Nav_Menu_Tree (Array_Map ("wp_setup_nav_menu_item", Popular_Terms),
      --       0, Args));  -- (object)

      --                 ?>
      --         </ul>
      -- </div><!-- /.tabs-panel -->

      -- <div id="tabs-panel-<?php echo taxonomy_name; ?>-all" class="tabs-panel tabs-panel-view-all <?php echo  ("all" === current_tab ? "tabs-panel-active" : "tabs-panel-inactive"); ?>" role="region" aria-label="<?php echo taxonomy->labels->all_items; ?>" tabindex="0">
      --         <?php if  (! empty (page_links)) : ?>
      --                 <div class="add-menu-item-pagelinks">
      --                         <?php echo page_links; ?>
      --                 </div>
      --         <?php endif; ?>
      --         <ul id="<?php echo taxonomy_name; ?>checklist" data-wp-lists="list:<?php echo taxonomy_name; ?>" class="categorychecklist form-no-clear">
      --                 <?php
      --                 args("walker") = walker;
      --                 echo walk_nav_menu_tree (array_map ("wp_setup_nav_menu_item", terms), 0, (object) args);
      --                 ?>
      --         </ul>
      --         <?php if  (! empty (page_links)) : ?>
      --                 <div class="add-menu-item-pagelinks">
      --                         <?php echo page_links; ?>
      --                 </div>
      --         <?php endif; ?>
      -- </div><!-- /.tabs-panel -->

      -- <div class="tabs-panel <?php echo  ("search" === current_tab ? "tabs-panel-active" : "tabs-panel-inactive"); ?>" id="tabs-panel-search-taxonomy-<?php echo taxonomy_name; ?>" role="region" aria-label="<?php echo taxonomy->labels->search_items; ?>" tabindex="0">
      --         <?php
      -- if Isset (X_REQUEST, "quick-search-taxonomy-" & Taxonomy_Name)) then
      --    Searched := Esc_Attr (X_REQUEST ("quick-search-taxonomy-" & Taxonomy_Name));

      --    Search_Results := Get_Terms (
      --                         To_Array ((
      --                            Build ("taxonomy",     Taxonomy_Name),
      --                            Build ("name__like",   Searched),
      --                            Build ("fields",       "all"),
      --                            Build ("orderby",      "count"),
      --                            Build ("order",        "DESC"),
      --                            Build ("hierarchical", "false")
      --                         ))
      --                      );
      -- else
      --    Searched       := "";
      --    Search_Results := Emptt_Array;
      -- end if;
      --                 ?>
      --                 <p class="quick-search-wrap">
      --                         <label for="quick-search-taxonomy-<?php echo taxonomy_name; ?>" class="screen-reader-text"><?php _e ("Search"); ?></label>
      --                         <input type="search" class="quick-search" value="<?php echo searched; ?>" name="quick-search-taxonomy-<?php echo taxonomy_name; ?>" id="quick-search-taxonomy-<?php echo taxonomy_name; ?>" />
      --                         <span class="spinner"></span>
      --                         <?php submit_button (__ ("Search"), "small quick-search-submit hide-if-js", "submit", false, array ("id" => "submit-quick-search-taxonomy-" . taxonomy_name)); ?>
      --                 </p>
      --                 <ul id="<?php echo taxonomy_name; ?>-search-checklist" data-wp-lists="list:<?php echo taxonomy_name; ?>" class="categorychecklist form-no-clear">
      --                 <?php if  (! empty (search_results) && ! is_wp_error (search_results)) : ?>
      --                         <?php
      --                         args("walker") = walker;
      --                         echo walk_nav_menu_tree (array_map ("wp_setup_nav_menu_item", search_results), 0, (object) args);
      --                         ?>
      --                 <?php elseif  (is_wp_error (search_results)) : ?>
      --                         <li><?php echo search_results->get_error_message(); ?></li>
      --                 <?php elseif  (! empty (searched)) : ?>
      --                         <li><?php _e ("No results found."); ?></li>
      --                 <?php endif; ?>
      --                 </ul>
      --         </div><!-- /.tabs-panel -->

      --         <p class="button-controls wp-clearfix" data-items-type="taxonomy-<?php echo esc_attr (taxonomy_name); ?>">
      --                 <span class="list-controls hide-if-no-js">
      --                         <input type="checkbox"<?php wp_nav_menu_disabled_check (nav_menu_selected_id); ?> id="<?php echo esc_attr (tab_name); ?>" class="select-all" />
      --                         <label for="<?php echo esc_attr (tab_name); ?>"><?php _e ("Select All"); ?></label>
      --                 </span>

      --                 <span class="add-to-menu">
      --                         <input type="submit"<?php wp_nav_menu_disabled_check (nav_menu_selected_id); ?> class="button submit-add-to-menu right" value="<?php esc_attr_e ("Add to Menu"); ?>" name="add-taxonomy-menu-item" id="<?php echo esc_attr ("submit-taxonomy-" . taxonomy_name); ?>" />
      --                         <span class="spinner"></span>
      --                 </span>
      --         </p>

      -- </div><!-- /.taxonomydiv -->
      -- <?php
   end Wp_Nav_Menu_Item_Taxonomy_Meta_Box;

   ----------------------------
   -- Wp_Save_Nav_Menu_Items --
   ----------------------------

   function Wp_Save_Nav_Menu_Items (Menu_Id   : Integer    := 0;
                                    Menu_Data : Array_Type := Empty_Array)
                                    return Integer -- (_Array)
   is
      use Inc_Nav_Menus;

--    Menu_Id     := (int) menu_id;
      Items_Saved : Array_Type := Empty_Array;
   begin
      if 0 = Menu_Id or else Is_Nav_Menu (Menu_Id) then

         -- Loop through all the menu items" POST values.
         for A in Menu_Data.Iterate loop -- (array)
            declare
--             use Array_Maps;

               X_Possible_Db_Id   : String := Key (A);
               X_Item_Object_Data : String := Get_As_String ((Menu_Data, Key (A)));
               -- Element (A); -- -A.Value;
               Args : Array_Type;
            begin
--                if
--                  -- Checkbox is not checked.
--                  Empty (Get (X_Item_Object_Data, "menu-item-object-id")) and then
--                  (
--                   -- And item type either isn"t set.
-- --                not Isset (X_Item_Object_Data, "menu-item-type") or else
--                   -- Or URL is the default.
-- --                  In_Array (X_Item_Object_Data ("menu-item-url"), To_array ("https://", "http://", ""), true) or else
--                   -- Or it"s not a custom menu item (but not the custom home page).
--                   (not "custom" = X_Item_Object_Data ("menu-item-type") and then not isset (X_Item_Object_Data ("menu-item-db-id"))) or else
--                    -- Or it--is* a custom menu item that already exists.
--                    not Empty (X_Item_Object_Data ("menu-item-db-id"))
--                   )
--                then
--                   -- Then this potential menu item is not getting added to this menu.
--                  goto Continue_1;
--                end if;

               -- If this possible menu item doesn"t actually have a menu database
               -- ID yet.
               -- if
               --   Empty (X_Item_Object_Data ("menu-item-db-id")) or else
               --   0 > X_Possible_Db_Id or else
               --   X_Possible_Db_Id /= X_Item_Object_Data ("menu-item-db-id")
               -- then
               --    X_Actual_Db_Id := 0;
               -- else
               --    X_Actual_Db_Id := X_Item_Object_Data ("menu-item-db-id"); -- (int)
               -- end if;

               -- Args := Arrays.To_Array ((
               --    Build ("menu-item-db-id",
               --           (if isset (X_Item_Object_Data ("menu-item-db-id"))
               --            then X_Item_Object_Data ("menu-item-db-id") else "")),

               --    Build ("menu-item-object-id",
               --           (if isset (X_Item_Object_Data ("menu-item-object-id"))
               --            then X_Item_Object_Data ("menu-item-object-id") else "")),

               --    Build ("menu-item-object",
               --           (if isset (X_Item_Object_Data ("menu-item-object"))
               --            then X_Item_Object_Data ("menu-item-object") else "")),
               --    Build ("menu-item-parent-id",
               --           (if isset (X_Item_Object_Data ("menu-item-parent-id"))
               --            then X_Item_Object_Data ("menu-item-parent-id") else "")),
               --    Build ("menu-item-position",
               --           (if isset (X_Item_Object_Data ("menu-item-position"))
               --            then X_Item_Object_Data ("menu-item-position") else "")),
               --    Build ("menu-item-type",
               --           (if isset (X_Item_Object_Data ("menu-item-type"))
               --            then X_Item_Object_Data ("menu-item-type") else "")),
               --    Build ("menu-item-title",
               --           (if isset (X_Item_Object_Data ("menu-item-title"))
               --            then X_Item_Object_Data ("menu-item-title") else "")),
               --    Build ("menu-item-url",
               --           (if isset (X_Item_Object_Data ("menu-item-url"))
               --            then X_Item_Object_Data ("menu-item-url") else "")),
               --    Build ("menu-item-description",
               --           (if isset (X_Item_Object_Data ("menu-item-description"))
               --            then X_Item_Object_Data ("menu-item-description") else "")),
               --    Build ("menu-item-attr-title",
               --           (if isset (X_Item_Object_Data ("menu-item-attr-title"))
               --            then X_Item_Object_Data ("menu-item-attr-title") else "")),
               --    Build ("menu-item-target",
               --           (if isset (X_Item_Object_Data ("menu-item-target"))
               --            then X_Item_Object_Data ("menu-item-target") else "")),
               --    Build ("menu-item-classes",
               --           (if isset (X_Item_Object_Data ("menu-item-classes"))
               --            then X_Item_Object_Data ("menu-item-classes") else "")),
               --    Build ("menu-item-xfn",
               --           (if isset (X_Item_Object_Data ("menu-item-xfn"))
               --            then X_Item_Object_Data ("menu-item-xfn") else ""))
               -- ));

--             Set (Items_Saved,       -- ()
--             Wp_Update_Nav_Menu_Item (Menu_Id, X_Actual_Db_Id, Args));
               null;
            end;
         end loop;
      end if;
      return 0; -- Items_Saved;
   end Wp_Save_Nav_Menu_Items;

   -----------------------------------
   -- X_Wp_Nav_Menu_Meta_Box_Object --
   ------------------------------------

   function X_Wp_Nav_Menu_Meta_Box_Object (Data_Object : Array_Type) -- := null)
                                           return Array_Type
   is
   begin
      -- if Isset (Data_Object.Name) then

      --    if "page" = Data_Object.Name then
      --       Data_Object.X_Default_Query := To_Array ((
      --          Build ("orderby",     "menu_order title"),
      --          Build ("post_status", "publish")
      --       ));

      --       -- Posts should show only published items.
      --    elsif "post" = Data_Object.Name then
      --       Data_Object.X_Default_Query := To_Array ((
      --          Build ("post_status", "publish")
      --       ));

      --    -- Categories should be in reverse chronological order.
      --    elsif "category" = Data_Object.Name then
      --       Data_Object.X_Default_Query := To_Array ((
      --          Build ("orderby", "id"),
      --          Build ("order",   "DESC")
      --       ));

      --    -- Custom post types should show only published items.
      --    else
      --       Data_Object.X_Default_Query := To_Array ((
      --          Build ("post_status", "publish")
      --       ));
      --    end if;
      -- end if;

      -- return Data_Object;
      return Empty_Array;
   end X_Wp_Nav_Menu_Meta_Box_Object;

   -----------------------------
   -- Wp_Get_Nav_Menu_To_Edit --
   -----------------------------

   function Wp_Get_Nav_Menu_To_Edit (Menu_Id : Integer := 0)
                                     return String
   is
      use Inc_Nav_Menus;

      Menu       : constant Integer := Wp_Get_Nav_Menu_Object (Menu_Id);
--      Menu_Items : Array_Type;
      Result     : UString;
   begin
      -- If the menu exists, get its items.
      if Is_Nav_Menu (Menu) then
         declare
            Menu_Items : constant Menu_Item_Array :=
               Wp_Get_Nav_Menu_Items ("XXX-623", -- Menu.Term_Id,
                                      Arrays.To_Array ((1 =>
                                         Build ("post_status", "any"))));
         begin
            Result := +"<div id=""menu-instructions"" class=""post-body-plain""";

            Append (Result, (if Menu_Items'Length /= 0
                             then " menu-instructions-inactive"">" else """>"));
            Append (Result, "<p>" & abs "Add menu items from the column on the left." &
                            "</p>");
            Append (Result, "</div>");

            if Menu_Items'Length = 0 then
               return (-Result) & " <ul class=""menu"" id=""menu-to-edit""> </ul>";
            end if;

            --
            -- Filters the Walker class used when adding nav menu items.
            --
            -- @since 3.0.0
            --
            -- @param string class   The walker class to use. Default
            --                       "Walker_Nav_Menu_Edit".
            -- @param int    menu_id ID of the menu being rendered.
            --
--       Walker_Class_Name := Apply_Filters ("wp_edit_nav_menu_walker",
--                                           "Walker_Nav_Menu_Edit", Menu_Id);

         -- if Class_Exists (Walker_Class_Name) then
         --    Walker := new Walker_Class_Name;
         -- else
         --    return new Wp_Error (
         --       "menu_walker_not_exist",
         --        Sprintf (
         --           -- translators: %s: Walker class name.
         --           abs "The Walker class named %s does not exist.",
         --           "<strong>" & Walker_Class_Name & "</strong>"
         --        ));
         -- end if;

            declare
               Some_Pending_Menu_Items : Boolean := False;
               Some_Invalid_Menu_Items : Boolean := False;
            begin
               for Menu_Item of Menu_Items loop
                  if
                    Menu_Item.Post_Status /= "" and then
                    "draft" = Menu_Item.Post_Status
                  then
                     Some_Pending_Menu_Items := True;
                  end if;

                  if Menu_Item.X_Invalid then
--                if not Empty (Menu_Item.X_Invalid) then
                     Some_Invalid_Menu_Items := True;
                  end if;
               end loop;

               if Some_Pending_Menu_Items then
                  Append (Result,
                          "<div class=""notice notice-info notice-alt inline""><p>" &
                          abs "Click Save Menu to make pending menu items public." &
                          "</p></div>");
               end if;

               if Some_Invalid_Menu_Items then
                  Append
                    (Result,
                     "<div class=""notice notice-error notice-alt inline""><p>" &
                     abs "There are some invalid menu items. Please check or delete them." &
                     "</p></div>");
               end if;
            end;

            Append (Result, "<ul class=""menu"" id=""menu-to-edit""> ");
--          Append (Result, Walk_Nav_Menu_Tree (
--                             Array_Map ("wp_setup_nav_menu_item", Menu_Items),
--                                        0, To_array ((Build ("walker", Walker))))); -- (object)
            Append (Result, " </ul> ");
            return -Result;
         end;

--    elsif Is_Wp_Error (Menu) then
--       return Menu;
      end if;
      return "";
   end Wp_Get_Nav_Menu_To_Edit;

   --------------------------------
   -- Wp_Nav_Menu_Manage_Columns --
   --------------------------------

   function Wp_Nav_Menu_Manage_Columns
            return Array_Type
   is
   begin
      return Arrays.To_Array ((
         Build ("_title",          abs "Show advanced menu properties"),
         Build ("cb",              "<input type=""checkbox"" />"),
         Build ("link-target",     abs "Link Target"),
         Build ("title-attribute", abs "Title Attribute"),
         Build ("css-classes",     abs "CSS Classes"),
         Build ("xfn",             abs "Link Relationship (XFN)"),
         Build ("description",     abs "Description")
      ));
   end Wp_Nav_Menu_Manage_Columns;

   -------------------------------------------
   -- X_Wp_Delete_Orphaned_Draft_Menu_Items --
   -------------------------------------------

   procedure X_Wp_Delete_Orphaned_Draft_Menu_Items
   is
      use Inc_Posts;

--    Delete_Timestamp : Time := time - (DAY_IN_SECONDS * EMPTY_TRASH_DAYS); -- ()
      Delete_Timestamp : constant String := "XXX-631";
   begin
      -- Delete orphaned draft menu items.
      declare
         SQL : constant String :=
           "SELECT ID FROM wpdb->posts AS p " &
           "LEFT JOIN wpdb->postmeta AS m "   &
           "ON p.ID = m.post_id "             &
           "WHERE post_type = ""nav_menu_item"" "    &
           "AND post_status = ""draft"" "            &
           "AND meta_key = ""_menu_item_orphaned"" " &
           "AND meta_value < &d";

         Menu_Items_To_Delete : constant List_Type :=
            WpDB.Get_Col (WpDB.Prepare (SQL, Delete_Timestamp));
         Unused : Wp_Post;
      begin
         for Menu_Item_Id of Menu_Items_To_Delete loop
            Unused := Wp_Delete_Post (Integer'Value (-Menu_Item_Id), True);
         end loop;
      end;
   end X_Wp_Delete_Orphaned_Draft_Menu_Items;

   -----------------------------------
   -- Wp_Nav_Menu_Update_Menu_Items --
   -----------------------------------

   function Wp_Nav_Menu_Update_Menu_Items (Nav_Menu_Selected_Id    : String;
                                           Nav_Menu_Selected_Title : String)
                                           return Array_Type
   is
      use Inc_Nav_Menus;
      use Inc_Options;
      use Inc_Plugins;
      use Inc_Posts;

      Unsorted_Menu_Items : constant Menu_Item_Array := -- Array_Type :=
         Inc_Nav_Menus.Wp_Get_Nav_Menu_Items (
            Nav_Menu_Selected_Id,
            Arrays.To_Array ((
               Build ("orderby",     "ID"),
               Build ("output",      "ARRAY_A"),  -- "" added
               Build ("output_key",  "ID"),
               Build ("post_status", "draft,publish")
            )));

      Messages   : UString; -- Array_Type := Empty_Array;
      Menu_Items : Array_Type;       -- := Empty_Array;

      Post_Fields : constant List_Type :=
         ["menu-item-db-id",
          "menu-item-object-id",
          "menu-item-object",
          "menu-item-parent-id",
          "menu-item-position",
          "menu-item-type",
          "menu-item-title",
          "menu-item-url",
          "menu-item-description",
          "menu-item-attr-title",
          "menu-item-target",
          "menu-item-classes",
          "menu-item-xfn"];

      Unused : Boolean;
   begin
      -- Index menu items by DB ID.
      for X_Item of Unsorted_Menu_Items loop
         null; -- Set (Menu_Items, -X_Item.DB_Id, X_Item);
      end loop;

      Unused := Inc_Taxonomys.Wp_Defer_Term_Counting (True);

      -- Loop through all the menu items" POST variables.
      if Get_As_String ((X_POST, "menu-item-db-id")) /= "" then
--    if not Empty (Get (X_POST, "menu-item-db-id")) then
         declare
            Arry : constant Array_Type := As_Array (Get (X_POST, "menu-item-db-id"));
         begin
            for A in Arry.Iterate loop
               declare
--                use Array_Maps;

                  X_Key : constant String := Key (A);
                  K     : constant String := Get_As_String ((Arry, Key (A)));
               begin
                  null;

               -- Menu item title can"t be blank.
               -- if
               --   not Isset (X_POST, "menu-item-title") (X_Key) or else
               --   "" = X_POST ("menu-item-title") (K_Key)
               -- then
               --    goto Continue_2;
               -- end if;

               -- Args := Empty_Array;
               -- for Field of Post_Fields loop
               --     Args (Field) := (if Isset (X_POST (field) (x_key))
               --                      then X_POST (field) (x_key) else "");
               -- end loop;

               -- Menu_Item_Db_Id :=
               --    Wp_Update_Nav_Menu_Item (Nav_Menu_Selected_Id,
               --       (if X_POST ("menu-item-db-id") (X_key) /= X_key
               --        then 0 else X_key), Args);

               -- if Is_Wp_Error (Menu_Item_Db_Id) then
               --    Set (Messages, "<div id=""message"" class=""error""><p>" &
               --         Menu_Item_Db_Id.Get_Error_Message & "</p></div>");  -- ()
               -- else
               --    Unset (Menu_Items (Menu_Item_Db_Id));
               -- end if;
               end;
            end loop;
         end;
      end if;

      -- Remove menu items from the menu that weren"t in _POST.
      if not Empty (Menu_Items) then
         for Menu_Item_Id of List_Type'(Array_Keys (Menu_Items)) loop
            declare
               Unused : Wp_Post;
            begin
--          if X_Nav_Menu_Item (Menu_Item_Id) then
               Unused := Wp_Delete_Post (Integer'Value (-Menu_Item_Id));
--          end if;
            end;
         end loop;
      end if;

      -- Store "auto-add" pages.
      declare
         Auto_Add        : constant Boolean := "" /= Get_As_String ((X_POST, "auto-add-pages"));
         Nav_Menu_Option : Array_Type       := Get_Option ("nav_menu_options");
         -- (array)
      begin

         if not Isset (Nav_Menu_Option, "auto_add") then
            Set (Nav_Menu_Option, "auto_add", From_Array (Empty_Array));
         end if;

         if Auto_Add then
            if
              not In_Array (Nav_Menu_Selected_Id,
                            As_Array (Get (Nav_Menu_Option, "auto_add")), True)
            then
               Set (Nav_Menu_Option, "auto_add", From_String (Nav_Menu_Selected_Id));
            end if;
         else
            declare
               Key : constant String :=
                  Array_Search (Nav_Menu_Selected_Id,
                                As_Array (Get (Nav_Menu_Option, "auto_add")), True);
            begin
               if "" /= Key then -- False
                  Delete (Ref_2 (Nav_Menu_Option, "auto_add", Key));
--                Unset (Nav_Menu_Option ("auto_add") (key));
               end if;
            end;
         end if;

         -- Remove non-existent/deleted menus.
         -- Set (Nav_Menu_Option, "auto_add",
         --      Array_Intersect (Get (Nav_Menu_Option, "auto_add"),
         --         Wp_Get_Nav_Menus (To_array ((1 => Build ("fields", "ids"))))));
         Update_Option ("nav_menu_options", Nav_Menu_Option);
      end;

      Unused := Inc_Taxonomys.Wp_Defer_Term_Counting (False);

      -- This action is documented in wp-includes/nav-menu.php--
      Do_Action ("wp_update_nav_menu", Nav_Menu_Selected_Id);

      Messages :=  -- ()
         +"<div id=""message"" class=""updated notice is-dismissible""><p>" &
           Sprintf (
             -- translators: %s: Nav menu title.
             abs "%s has been updated.",
             [1 => "<strong>" & Nav_Menu_Selected_Title & "</strong>"]
           ) & "</p></div>";

--    Unset (Menu_Items);
--    Unset (Unsorted_Menu_Items);

      return Arrays.To_Array ((1 => Build (-Messages, "")));
   end Wp_Nav_Menu_Update_Menu_Items;

   ------------------------------------
   -- X_Wp_Expand_Nav_Menu_Post_Data --
   ------------------------------------

   procedure X_Wp_Expand_Nav_Menu_Post_Data
   is
      use Inc_Formatting;
   begin
      if not Isset (X_POST, "nav-menu-data") then
         return;
      end if;

      declare
         Data : constant Array_Type :=
            JSON_Decode (Stripslashes (Get_As_String ((X_POST, "nav-menu-data"))));
      begin

--       if not Is_Null (Data) and then Data then
            for Post_Input_Data in Data.Iterate loop
               declare
--                use Array_Maps;

                  Matches : List_Type;
                  Unused  : Integer;
               begin
                  -- For input names that are arrays (e.g. `menu-item-db-id(3)(4)(5)`),
                  -- derive the array path keys via regex and set the value in _POST.
                  Unused := Preg_Match ("#((^\()*)(\((.+)\))?#",
                                        Key (Post_Input_Data), -- Post_Input_Data.Name,
                                        Matches);
                  declare
                     Array_Bits    : List_Type  :=
                        [-Matches (1)];
--                   Array_Bits    : List_Type  := [1 => Matches (1)]);
                     New_Post_Data : Array_Type := Empty_Array;
                  begin

                     if Isset (-Matches (3)) then
--                   if Isset (Matches (3)) then
                        Array_Bits :=
                           Array_Merge (Array_Bits,
                              Explode (")(", -Matches (3)));
--                         Array_Merge (Array_Bits, Explode (")(", Matches (3)));
                     end if;

                     -- Build the new array value from leaf to trunk.
                     for
                       I in reverse Array_Bits.First_Index .. Array_Bits.Last_Index
                     loop
--                   for I in reverse 0 .. Count (Array_Bits) - 1 loop
                        if I = Array_Bits.Last_Index then
--                      if Count (Array_Bits) - 1 = I then
                           Set (New_Post_Data, -Array_Bits (I),
                                From_String (Wp_Slash (As_String (Element (Post_Input_Data)))));
--                              Wp_Slash (-Element (Post_Input_Data).Str));
--                         New_Post_Data (Array_Bits (I)) :=
--                           Wp_Slash (Post_Input_Data.Value);
                        else
                           null;
--                New_Post_Data := To_array (Array_Bits (I) => New_Post_Data);
                        end if;
                     end loop;

                     X_POST := Array_Replace_Recursive (X_POST, New_Post_Data);
                  end;
               end;
            end loop;
--       end if;
      end;
   end X_Wp_Expand_Nav_Menu_Post_Data;

end Adi_Nav_Menus;
