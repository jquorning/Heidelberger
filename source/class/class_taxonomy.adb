--
-- Taxonomy API: WP_Taxonomy class
--
-- @package WordPress
-- @subpackage Taxonomy
-- @since 4.7.0
--

with Php.Arrays;
with Php.Lists;

with Globals;
with UStrings;

with Class_Wp;
with Inc_Formatting;
with Inc_Functions;
with Inc_L10n;
with Inc_Load;
with Inc_Options;
with Inc_Plugins;
with Inc_Rewrites;
with Inc_Taxonomys;

package body Class_Taxonomy
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Taxonomy    : String;
                         Object_Type : List_Type;
                         Args        : Array_Type := Empty_Array)
                         return Wp_Taxonomy
   is
      use UStrings;

      This : Wp_Taxonomy;
   begin
      This.Name := +Taxonomy;

      This.Set_Props (Object_Type, Args);
      return This;
   end X_Construct;

   ---------------
   -- Set_Props --
   ---------------

   procedure Set_Props (This        : in out Wp_Taxonomy;
                        Object_Type : List_Type;
                        Args        : Array_Type)
   is
      use UStrings;
      use Php.Arrays;
      use Php.Lists;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Plugins;

      Args_2 : Array_Type := Wp_Parse_Args (Args);
   begin
      --
      -- Filters the arguments for registering a taxonomy.
      --
      -- @since 4.4.0
      --
      -- @param array    args        Array of arguments for registering a taxonomy.
      --                              See the register_taxonomy() function for
      --                              accepted arguments.
      -- @param string   taxonomy    Taxonomy key.
      -- @param string[] object_type Array of names of object types for the taxonomy.
      --
      Args_2 := Apply_Filters ("register_taxonomy_args", Args_2, -This.Name,
                               Object_Type); -- (array)

      Globals.Taxonomy := This.Name;

      --
      -- Filters the arguments for registering a specific taxonomy.
      --
      -- The dynamic portion of the filter name, `taxonomy`, refers to the taxonomy key.
      --
      -- Possible hook names include:
      --
      --  - `register_category_taxonomy_args`
      --  - `register_post_tag_taxonomy_args`
      --
      -- @since 6.0.0
      --
      -- @param array    args        Array of arguments for registering a taxonomy.
      --                              See the register_taxonomy() function for
      --                              accepted arguments.
      -- @param string   taxonomy    Taxonomy key.
      -- @param string[] object_type Array of names of object types for the taxonomy.
      --
      Args_2 := Apply_Filters ("register_" & (-Globals.Taxonomy) & "_taxonomy_args",
                               Args_2, -This.Name, Object_Type); -- (array)
      declare
         Defaults : constant Array_Type := To_Array (List => (
           Build ("labels",                Empty_Array),
           Build ("description",           ""),
           Build ("public",                True),
           Build ("publicly_queryable",    Null_Value),
           Build ("hierarchical",          False),
           Build ("show_ui",               Null_Value),
           Build ("show_in_menu",          Null_Value),
           Build ("show_in_nav_menus",     Null_Value),
           Build ("show_tagcloud",         Null_Value),
           Build ("show_in_quick_edit",    Null_Value),
           Build ("show_admin_column",     False),
           Build ("meta_box_cb",           Null_Value),
           Build ("meta_box_sanitize_cb",  Null_Value),
           Build ("capabilities",          Empty_Array),
           Build ("rewrite",               True),
           Build ("query_var",             -This.Name),
           Build ("update_count_callback", ""),
           Build ("show_in_rest",          False),
           Build ("rest_base",             False),
           Build ("rest_namespace",        False),
           Build ("rest_controller_class", False),
           Build ("default_term",          Null_Value),
           Build ("sort",                  Null_Value),
           Build ("args",                  Null_Value),
           Build ("_builtin",              False)
         ));
      begin
         Args_2 := Array_Merge (Defaults, Args_2);
      end;

      -- If not set, default to the setting for "public".
      if not Isset (Args_2, "publicly_queryable") then
--    if ( null === args["publicly_queryable"] ) then
         Set (Args_2, "publicly_queryable", Get (Args_2, "public"));
      end if;

      if
        As_String (Get (Args_2, "query_var")) /= "" and then
        (Inc_Load.Is_Admin or else As_Boolean (Get (Args_2, "publicly_queryable")))
      then
         if As_String (Get (Args_2, "query_var")) /= "" then
            Set (Args_2, "query_var", From_String (-This.Name));
         else
            Set (Args_2, "query_var",
                 From_String (
                   Sanitize_Title_With_Dashes (As_String (Get (Args_2, "query_var")))));
         end if;
      else
         -- Force "query_var" to false for non-public taxonomies.
         Set (Args_2, "query_var", From_Boolean (False));
      end if;

      if
        As_Boolean (Get (Args_2, "rewrite")) and then
        (Inc_Load.Is_Admin or else Inc_Options.Get_Option ("permalink_structure"))
      then
         Set (Args_2, "rewrite",
              From_Array (
                Wp_Parse_Args (
                  As_Boolean (Get (Args_2, "rewrite")),
                  To_Array (List => (
                    Build ("with_front",   True),
                    Build ("hierarchical", False) -- ,
--                  Build ("ep_mask",      Ep_None)
                  ))
              )));

         -- if Empty (Args_2 ("rewrite") ("slug")) then
         --    Args_2 ("rewrite") ("slug") := Sanitize_Title_With_Dashes (This.Name);
         -- end if;
      end if;

      -- If not set, default to the setting for "public".
      if Is_Null (Get (Args_2, "show_ui")) then
         Set (Args_2,
              Key   => "show_ui",
              Value => Get (Args_2, "public"));
      end if;

      -- If not set, default to the setting for "show_ui".
      if
        Is_Null (Get (Args_2, "show_in_menu")) or else
        not As_Boolean (Get (Args_2, "show_ui"))
      then
         Set (Args_2,
              Key   => "show_in_menu",
              Value => Get (Args_2, "show_ui"));
      end if;

      -- If not set, default to the setting for "public".
      if Is_Null (Get (Args_2, "show_in_nav_menus")) then
         Set (Args_2,
              Key   => "show_in_nav_menus",
              Value => Get (Args_2, "public"));
      end if;

      -- If not set, default to the setting for "show_ui".
      if Is_Null (Get (Args_2, "show_tagcloud")) then
         Set (Args_2,
              Key   => "show_tagcloud",
              Value => Get (Args_2, "show_ui"));
      end if;

      -- If not set, default to the setting for "show_ui".
      if Is_Null (Get (Args_2, "show_in_quick_edit")) then
         Set (Args_2,
              Key   => "show_in_quick_edit",
              Value => Get (Args_2, "show_ui"));
      end if;

      -- If not set, default rest_namespace to wp/v2 if show_in_rest is true.
      if
        not As_Boolean (Get (Args_2, "rest_namespace")) and then
        Isset (Args_2, "show_in_rest")
--      not Empty (Args_2 ("show_in_rest"))
      then
         Set (Args_2,
              Key   => "rest_namespace",
              Value => From_String ("wp/v2"));
      end if;

      declare
         Default_Caps : constant Array_Type := To_Array (List => (
           Build ("manage_terms", "manage_categories"),
           Build ("edit_terms",   "manage_categories"),
           Build ("delete_terms", "manage_categories"),
           Build ("assign_terms", "edit_posts")
         ));
      begin
         Set (Args_2,
              Key   => "cap",
              Value => From_Array (
                Array_Merge (Default_Caps, As_Array (Get (Args_2, "capabilities"))))); -- (object)
      end;
      Delete (Ref (Args_2, "capabilities"));
--    Unset (Args_2 ("capabilities"));

      Set (Args_2,
           Key   => "object_type",
           Value => From_List (List_Unique (Object_Type)));

      -- If not set, use the default meta box.
      if Is_Null (Get (Args_2, "meta_box_cb")) then
         if As_Boolean (Get (Args_2, "hierarchical")) then
            Set (Args_2,
                 Key   => "meta_box_cb",
                 Value => From_String ("post_categories_meta_box"));
         else
            Set (Args_2,
                 Key   => "meta_box_cb",
                 Value => From_String ("post_tags_meta_box"));
         end if;
      end if;

      Set (Args_2,
           Key   => "name",
           Value => From_String (-This.Name));

      -- Default meta box sanitization callback depends on the value of "meta_box_cb".
      if Is_Null (Get (Args_2, "meta_box_sanitize_cb")) then
         declare
            Arc : constant String := As_String (Get (Args_2, "meta_box_cb"));
         begin
            if Arc = "post_categories_meta_box" then
               Set (Args_2,
                    Key   => "meta_box_sanitize_cb",
                    Value => From_String ("taxonomy_meta_box_sanitize_cb_checkboxes"));
                                       --  break;

            else
               --  "post_tags_meta_box":
               --  default:
               Set (Args_2,
                    Key   => "meta_box_sanitize_cb",
                    Value => From_String ("taxonomy_meta_box_sanitize_cb_input"));
               -- break;
            end if;
         end;
      end if;

      -- Default taxonomy term.
      if not Empty (Args_2, "default_term") then
         -- if not Is_Array (Args_2, "default_term") then
         --    Set (Args_2, "default_term",
         --         To_Array (List => (1 =>
         --           Build ("name", Get (Args_2, "default_term")))));
         -- end if;
         Set (Args_2, "default_term",
              From_Array (
                Wp_Parse_Args (
                  False, -- Get_Array (Args_2, "default_term"),
                  To_Array (List => (
                    Build ("name",        ""),
                    Build ("slug",        ""),
                    Build ("description", "")
                  ))
              )));
      end if;

      for A in Args_2.Iterate loop
         declare
            Property_Name  : String     := Key (A);
            Property_Value : Multi_Type := Element (A);
         begin
            null;
            -- case Property_Value.Kind is
            -- when Is_String =>
            --    Set (This, Property_Name, -Property_Value.Str);
            -- when Is_Integer =>
            --    Set_Integer (This, Property_Name, Property_Value.Int);
            -- when Is_Array =>
            --    Set (This, Property_Name, Property_Value.Arry.all);
            -- when Is_Boolean =>
            --    Set (This, Property_Name, Property_Value.Bool);
            -- when Is_Callable =>
            --    null;
            -- when Is_Null =>
            --    null;
            -- end case;
         end;
      end loop;

      This.Labels := Inc_Taxonomys.Get_Taxonomy_Labels (This);
--    This.Label  := This.Labels.Name;
   end Set_Props;

   Wp : Class_Wp.Wp;

   -----------------------
   -- Add_Rewrite_Rules --
   -----------------------

   procedure Add_Rewrite_Rules (This : Wp_Taxonomy)
   is
      use UStrings;
      use Inc_Options;
--    use Inc_Plugins;
      use Inc_Rewrites;
--                 /* @var WP wp--
--                 global wp;
   begin
      -- Non-publicly queryable taxonomies should not register query vars, except
      -- in the admin.
      if "" /= This.Query_Var then -- and then Wp then
--    if False /= This.Query_Var and then wp then
         Wp.Add_Query_Var (-This.Query_Var);
      end if;

      if
        Empty_Array /= This.Rewrite and then
--      False /= This.Rewrite and then
        (Inc_Load.Is_Admin or else Get_Option ("permalink_structure"))
      then
         declare
            Tag : UString;
         begin
            if
              This.Hierarchical and then
              As_Boolean (Get (This.Rewrite, "hierarchical"))
            then
               Tag := +"(.+?)";
            else
               Tag := +"([^/]+)";
            end if;

            Add_Rewrite_Tag ("%" & (-This.Name) & "%", -Tag,
                             (if This.Query_Var /= ""
                              then (-This.Query_Var) & "="
                              else "taxonomy=" & (-This.Name) & "&term="));
            Add_Permastruct
              (-This.Name,
               As_String (Get (This.Rewrite, "slug")) & "/%" & (-This.Name) & "%",
               This.Rewrite);
         end;
      end if;
   end Add_Rewrite_Rules;

--         --
--         -- Removes any rewrite rules, permastructs, and rules for the taxonomy.
--         --
--         -- @since 4.7.0
--         --
--         -- @global WP wp Current WordPress environment instance.
--         --
--         public function remove_rewrite_rules() then
--                 /* @var WP wp--
--                 global wp;

--                 -- Remove query var.
--                 if ( false !== this.query_var ) then
--                         wp.remove_query_var( this.query_var );
--                 end;

--                 -- Remove rewrite tags and permastructs.
--                 if ( false !== this.rewrite ) then
--                         remove_rewrite_tag( "%this.name%" );
--                         remove_permastruct( this.name );
--                 end;
--         end;

   ---------------
   -- Add_Hooks --
   ---------------

   procedure Add_Hooks (This : Wp_Taxonomy)
   is
--    use UStrings;
--    use Inc_Plugins;
   begin
--    Add_Filter ("wp_ajax_add-" & (-This.Name), "_wp_ajax_add_hierarchical_term");
      null;
   end Add_Hooks;

--         --
--         -- Removes the ajax callback for the meta box.
--         --
--         -- @since 4.7.0
--         --
--         public function remove_hooks() then
--                 remove_filter( "wp_ajax_add-" . this.name, "_wp_ajax_add_hierarchical_term" );
--         end;

--         --
--         -- Gets the REST API controller for this taxonomy.
--         --
--         -- Will only instantiate the controller class once per request.
--         --
--         -- @since 5.5.0
--         --
--         -- @return WP_REST_Controller|null The controller instance, or null if the taxonomy
--         --                                 is set not to show in rest.
--         --
--         public function get_rest_controller() then
--                 if ( ! this.show_in_rest ) then
--                         return null;
--                 end;

--                 class = this.rest_controller_class ? this.rest_controller_class : WP_REST_Terms_Controller::class;

--                 if ( ! class_exists( class ) ) then
--                         return null;
--                 end;

--                 if ( ! is_subclass_of( class, WP_REST_Controller::class ) ) then
--                         return null;
--                 end;

--                 if ( ! this.rest_controller ) then
--                         this.rest_controller = new class( this.name );
--                 end;

--                 if ( ! ( this.rest_controller instanceof class ) ) then
--                         return null;
--                 end;

--                 return this.rest_controller;
--         end;

   ------------------------
   -- Get_Default_Lables --
   ------------------------

   function Get_Default_Labels
            return Array_Type
   is
      use Inc_L10n;

      -- if ( ! empty( self::default_labels ) ) then
      --    return self::default_labels;
      -- end if;

      Name_Field_Description   : constant String := abs "The name is how it appears on your site.";
      Slug_Field_Description   : constant String := abs "The &#8220;slug&#8221; is the URL-friendly version of the name. It is usually all lowercase and contains only letters, numbers, and hyphens.";
      Parent_Field_Description : constant String := abs "Assign a parent term to create a hierarchy. The term Jazz, for example, would be the parent of Bebop and Big Band.";
      Desc_Field_Description   : constant String := abs "The description is not prominent by default; however, some themes may show it.";
   begin
      Self_Default_Labels := To_Array (List => (
         Build ("name",                       To_Array ((1 => Build (X_X ("Tags", "taxonomy general name"), X_X ("Categories", "taxonomy general name"))))),
         Build ("singular_name",              To_Array ((1 => Build (X_X ("Tag", "taxonomy singular name"), X_X ("Category", "taxonomy singular name"))))),
         Build ("search_items",               To_Array ((1 => Build (abs "Search Tags", abs "Search Categories")))),
         Build ("popular_items",              To_Array ((1 => Build (abs "Popular Tags", "null")))),
         Build ("all_items",                  To_Array ((1 => Build (abs "All Tags", abs "All Categories")))),
         Build ("parent_item",                To_Array ((1 => Build ("null", abs "Parent Category")))),
         Build ("parent_item_colon",          To_Array ((1 => Build ("null", abs "Parent Category:")))),
         Build ("name_field_description",     To_Array ((1 => Build (Name_Field_Description, Name_Field_Description)))),
         Build ("slug_field_description",     To_Array ((1 => Build (Slug_Field_Description, Slug_Field_Description)))),
         Build ("parent_field_description",   To_Array ((1 => Build ("null", Parent_Field_Description)))),
         Build ("desc_field_description",     To_Array ((1 => Build (Desc_Field_Description, Desc_Field_Description)))),
         Build ("edit_item",                  To_Array ((1 => Build (abs "Edit Tag", abs "Edit Category")))),
         Build ("view_item",                  To_Array ((1 => Build (abs "View Tag", abs "View Category")))),
         Build ("update_item",                To_Array ((1 => Build (abs "Update Tag", abs "Update Category")))),
         Build ("add_new_item",               To_Array ((1 => Build (abs "Add New Tag", abs "Add New Category")))),
         Build ("new_item_name",              To_Array ((1 => Build (abs "New Tag Name", abs "New Category Name")))),
         Build ("separate_items_with_commas", To_Array ((1 => Build (abs "Separate tags with commas", "null")))),
         Build ("add_or_remove_items",        To_Array ((1 => Build (abs "Add or remove tags", "null")))),
         Build ("choose_from_most_used",      To_Array ((1 => Build (abs "Choose from the most used tags", "null")))),
         Build ("not_found",                  To_Array ((1 => Build (abs "No tags found.", abs "No categories found.")))),
         Build ("no_terms",                   To_Array ((1 => Build (abs "No tags", abs "No categories")))),
         Build ("filter_by_item",             To_Array ((1 => Build ("null", abs "Filter by category")))),
         Build ("items_list_navigation",      To_Array ((1 => Build (abs "Tags list navigation", abs "Categories list navigation")))),
         Build ("items_list",                 To_Array ((1 => Build (abs "Tags list", abs "Categories list")))),
         -- translators: Tab heading when selecting from the most used terms.
         Build ("most_used",                  To_Array ((1 => Build (X_X ("Most Used", "tags"), X_X ("Most Used", "categories"))))),
         Build ("back_to_items",              To_Array ((1 => Build (abs "&larr; Go to Tags", abs "&larr; Go to Categories")))),
         Build ("item_link",                  To_Array (List => (1 =>
                 Build (X_X ("Tag Link", "navigation link block title"),
                        X_X ("Category Link", "navigation link block title"))))
         ),
         Build ("item_link_description",      To_Array (List => (1 =>
                 Build (X_X ("A link to a tag.", "navigation link block description"),
                        X_X ("A link to a category.", "navigation link block description"))))
         )
      ));

      return Self_Default_Labels;
   end Get_Default_Labels;

   --------------------------
   -- Reset_Default_Labels --
   --------------------------

   procedure Reset_Default_Labels
   is
   begin
      Self_Default_Labels := Empty_Array;
   end Reset_Default_Labels;

end Class_Taxonomy;
