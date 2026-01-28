--
-- Core Taxonomy API
--
-- @package WordPress
-- @subpackage Taxonomy
--

with Ada.Containers;

with Php.Arrays;
with Php.Lists;
with Php.Numerics;
with Php.Strings;
with Php.Types;

with Helpers;
with UStrings;
with Wp_Common;

with Adi_Caches;

with Class_Posts;
with Inc_Formatting;
with Inc_Functions;
with Inc_Load;
with Inc_L10n;
with Inc_Options;
with Inc_Plugins;
with Inc_Posts;
with Inc_Themes;

package body Inc_Taxonomys
is

   --
   -- Taxonomy registration.
   --

   -------------------------------
   -- Create_Initial_Taxonomies --
   -------------------------------

   procedure Create_Initial_Taxonomies
   is
      use UStrings;
      use Wp_Common;
      use Class_Taxonomy;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Plugins;
--         global wp_rewrite;
      Rewrite          : Array_Type;
      Post_Format_Base : UString;
   begin
      Reset_Default_Labels; -- WP_Taxonomy::reset_default_labels();

      if not Did_Action ("init") then
         Rewrite := Arrays.To_Array ((
            Build ("category",    False),
            Build ("post_tag",    False),
            Build ("post_format", False)
         ));
      else
         --
         -- Filters the post formats rewrite base.
         --
         -- @since 3.1.0
         --
         -- @param string context Context of the rewrite base. Default "type".
         --
         Post_Format_Base := +Apply_Filters ("post_format_rewrite_base", "type");

         Rewrite          := Arrays.To_Array ((
            Build ("category",    Arrays.To_Array ((
               Build ("hierarchical", True),
               Build ("slug",         (if "" /= Get_Option ("category_base")
                                       then Get_Option ("category_base")
                                       else "category")) -- ,
--             Build ("with_front",   "" = Get_Option ("category_base") or else
--                                    Wp_Rewrite.Using_Index_Permalinks), -- ()
--             Build ("ep_mask",      Ep_Categories)
            ))),
            Build ("post_tag",    Arrays.To_Array ((
               Build ("hierarchical", False),
               Build ("slug",         (if "" /= Get_Option ("tag_base")
                                       then Get_Option ("tag_base") else "tag")) -- ,
--             Build ("with_front",   "" = Get_Option ("tag_base") or else
--                                    Wp_Rewrite.Using_Index_Permalinks),
--               Build ("ep_mask",      Ep_Tags)
            ))),
            Build ("post_format",
              (if Post_Format_Base /= ""
               then Arrays.To_Array ((1 => Build ("slug", -Post_Format_Base)))
               else Empty_Array)) -- False))
         ));
      end if;

      Register_Taxonomy (
         "category",
         ["post"],
         Arrays.To_Array ((
            Build ("hierarchical",          True),
            Build ("query_var",             "category_name"),
            Build ("rewrite",               Get (Rewrite, "category")),
            Build ("public",                True),
            Build ("show_ui",               True),
            Build ("show_admin_column",     True),
            Build ("_builtin",              True),
            Build ("capabilities",          Arrays.To_Array ((
               Build ("manage_terms", "manage_categories"),
               Build ("edit_terms",   "edit_categories"),
               Build ("delete_terms", "delete_categories"),
               Build ("assign_terms", "assign_categories")
            ))),
            Build ("show_in_rest",          True),
            Build ("rest_base",             "categories"),
            Build ("rest_controller_class", "WP_REST_Terms_Controller")
         ))
      );

      Register_Taxonomy (
         "post_tag",
         ["post"],
         Arrays.To_Array ((
            Build ("hierarchical",          False),
            Build ("query_var",             "tag"),
            Build ("rewrite",               Get (Rewrite, "post_tag")),
            Build ("public",                True),
            Build ("show_ui",               True),
            Build ("show_admin_column",     True),
            Build ("_builtin",              True),
            Build ("capabilities",          Arrays.To_Array ((
               Build ("manage_terms", "manage_post_tags"),
               Build ("edit_terms",   "edit_post_tags"),
               Build ("delete_terms", "delete_post_tags"),
               Build ("assign_terms", "assign_post_tags")
            ))),
            Build ("show_in_rest",          True),
            Build ("rest_base",             "tags"),
            Build ("rest_controller_class", "WP_REST_Terms_Controller")
         ))
      );

      Register_Taxonomy (
         "nav_menu",
         ["nav_menu_item"],
         Arrays.To_Array ((
            Build ("public",                False),
            Build ("hierarchical",          False),
            Build ("labels",                Arrays.To_Array ((
               Build ("name",          abs "Navigation Menus"),
               Build ("singular_name", abs "Navigation Menu")
            ))),
            Build ("query_var",             False),
            Build ("rewrite",               False),
            Build ("show_ui",               False),
            Build ("_builtin",              True),
            Build ("show_in_nav_menus",     False),
            Build ("capabilities",          Arrays.To_Array ((
               Build ("manage_terms", "edit_theme_options"),
               Build ("edit_terms",   "edit_theme_options"),
               Build ("delete_terms", "edit_theme_options"),
               Build ("assign_terms", "edit_theme_options")
            ))),
            Build ("show_in_rest",          True),
            Build ("rest_base",             "menus"),
            Build ("rest_controller_class", "WP_REST_Menus_Controller")
         ))
      );

      Register_Taxonomy (
         "link_category",
         ["link"],
         Arrays.To_Array ((
            Build ("hierarchical", False),
            Build ("labels",       Arrays.To_Array ((
               Build ("name",                       abs "Link Categories"),
               Build ("singular_name",              abs "Link Category"),
               Build ("search_items",               abs "Search Link Categories"),
               Build ("popular_items",              ""), -- null),
               Build ("all_items",                  abs "All Link Categories"),
               Build ("edit_item",                  abs "Edit Link Category"),
               Build ("update_item",                abs "Update Link Category"),
               Build ("add_new_item",               abs "Add New Link Category"),
               Build ("new_item_name",              abs "New Link Category Name"),
               Build ("separate_items_with_commas", ""), -- null),
               Build ("add_or_remove_items",        ""), -- null),
               Build ("choose_from_most_used",      ""), -- null),
               Build ("back_to_items",              abs "&larr; Go to Link Categories")
            ))),
            Build ("capabilities", Arrays.To_Array ((
               Build ("manage_terms", "manage_links"),
               Build ("edit_terms",   "manage_links"),
               Build ("delete_terms", "manage_links"),
               Build ("assign_terms", "manage_links")
            ))),
            Build ("query_var",    False),
            Build ("rewrite",      False),
            Build ("public",       False),
            Build ("show_ui",      True),
            Build ("_builtin",     True)
         ))
      );

      Register_Taxonomy (
         "post_format",
         ["post"],
         Arrays.To_Array ((
            Build ("public",            True),
            Build ("hierarchical",      False),
            Build ("labels",            Arrays.To_Array ((
               Build ("name",          X_X ("Formats", "post format")),
               Build ("singular_name", X_X ("Format", "post format"))
            ))),
            Build ("query_var",         True),
            Build ("rewrite",           Get (Rewrite, "post_format")),
            Build ("show_ui",           False),
            Build ("_builtin",          True),
            Build ("show_in_nav_menus",
                   Inc_Themes.Current_Theme_Supports ("post-formats"))
         ))
       );

      Register_Taxonomy (
         "wp_theme",
         ["wp_template", "wp_template_part", "wp_global_styles"],
         Arrays.To_Array ((
            Build ("public",            False),
            Build ("hierarchical",      False),
            Build ("labels",            Arrays.To_Array ((
               Build ("name",          abs "Themes"),
               Build ("singular_name", abs "Theme")
            ))),
            Build ("query_var",         False),
            Build ("rewrite",           False),
            Build ("show_ui",           False),
            Build ("_builtin",          True),
            Build ("show_in_nav_menus", False),
            Build ("show_in_rest",      False)
         ))
      );

      Register_Taxonomy (
         "wp_template_part_area",
         ["wp_template_part"],
         Arrays.To_Array ((
            Build ("public",            False),
            Build ("hierarchical",      False),
            Build ("labels",            Arrays.To_Array ((
               Build ("name",          abs "Template Part Areas"),
               Build ("singular_name", abs "Template Part Area")
            ))),
            Build ("query_var",         False),
            Build ("rewrite",           False),
            Build ("show_ui",           False),
            Build ("_builtin",          True),
            Build ("show_in_nav_menus", False),
            Build ("show_in_rest",      False)
         ))
      );
   end Create_Initial_Taxonomies;

--
-- Retrieves a list of registered taxonomy names or objects.
--
-- @since 3.0.0
--
-- @global WP_Taxonomy() wp_taxonomies The registered taxonomies.
--
-- @param array  args     Optional. An array of `key => value` arguments to match against the taxonomy objects.
--                         Default empty array.
-- @param string output   Optional. The type of output to return in the array. Accepts either taxonomy "names"
--                         or "objects". Default "names".
-- @param string operator Optional. The logical operation to perform. Accepts "and" or "or". "or" means only
--                         one element from the array needs to match; "and" means all elements must match.
--                         Default "and".
-- @return string()|WP_Taxonomy() An array of taxonomy names or objects.
--
-- function get_taxonomies (args = array(), output = "names", operator = "and") then
--         global wp_taxonomies;

--         field =  ("names" === output) ? "name" : false;

--         return wp_filter_object_list (wp_taxonomies, args, operator, field);
-- end;

--
-- Returns the names or objects of the taxonomies which are registered for the requested object or object type,
-- such as a post object or post type name.
--
-- Example:
--
--     taxonomies = get_object_taxonomies ("post");
--
-- This results in:
--
--     Array ("category", "post_tag")
--
-- @since 2.3.0
--
-- @global WP_Taxonomy() wp_taxonomies The registered taxonomies.
--
-- @param string|string()|WP_Post object Name of the type of taxonomy object, or an object (row from posts)
-- @param string                  output Optional. The type of output to return in the array. Accepts either
--                                        "names" or "objects". Default "names".
-- @return string()|WP_Taxonomy() The names or objects of all taxonomies of `object_type`.
--
-- function get_object_taxonomies (object, output = "names") then
--         global wp_taxonomies;

--         if  (is_object (object)) then
--                 if  ("attachment" === object.post_type) then
--                         return get_attachment_taxonomies (object, output);
--                 end;
--                 object = object.post_type;
--         end;

--         object = (array) object;

--         taxonomies = array();
--         foreach  ((array) wp_taxonomies as tax_name => tax_obj) then
--                 if  (array_intersect (object, (array) tax_obj.object_type)) then
--                         if  ("names" === output) then
--                                 taxonomies() = tax_name;
--                         end; else then
--                                 taxonomies (tax_name) = tax_obj;
--                         end;
--                 end;
--         end;

--         return taxonomies;
-- end;

   ------------------
   -- Get_Taxonomy --
   ------------------

   function Get_Taxonomy (Taxonomy : String)
                          return Class_Taxonomy.Wp_Taxonomy
   is
      use Taxonomy_Maps;
   begin
      if not Taxonomy_Exists (Taxonomy) then
         raise Taxonomy_Does_Not_Exist;
--       return False;
      end if;

      return Element (Taxonomy_Map.Find (Taxonomy));
   end Get_Taxonomy;

   ---------------------
   -- Taxonomy_Exists --
   ---------------------

   function Taxonomy_Exists (Taxonomy : String)
                                return Boolean
   is
      use Php.Types;
      use Taxonomy_Maps;
   begin
      return
        Is_String (Taxonomy) and then
        Has_Element (Taxonomy_Map.Find (Taxonomy));
--      Isset (Taxonomy_Map (Taxonomy));
   end Taxonomy_Exists;

--
-- Determines whether the taxonomy object is hierarchical.
--
-- Checks to make sure that the taxonomy is an object first. Then Gets the
-- object, and finally returns the hierarchical value in the object.
--
-- A false return value might also mean that the taxonomy does not exist.
--
-- For more information on this and similar theme functions, check out
-- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- Conditional Tags} article in the Theme Developer Handbook.
--
-- @since 2.3.0
--
-- @param string taxonomy Name of taxonomy object.
-- @return bool Whether the taxonomy is hierarchical.
--
-- function is_taxonomy_hierarchical (taxonomy) then
--         if  (! taxonomy_exists (taxonomy)) then
--                 return false;
--         end;

--         taxonomy = get_taxonomy (taxonomy);
--         return taxonomy.hierarchical;
-- end;

--
-- Creates or modifies a taxonomy object.
--
-- Note: Do not use before the {@see "init"} hook.
--
-- A simple function for creating or modifying a taxonomy object based on
-- the parameters given. If modifying an existing taxonomy object, note
-- that the `object_type` value from the original registration will be
-- overwritten.
--
-- @since 2.3.0
-- @since 4.2.0 Introduced `show_in_quick_edit` argument.
-- @since 4.4.0 The `show_ui` argument is now enforced on the term editing screen.
-- @since 4.4.0 The `public` argument now controls whether the taxonomy can be queried on the front end.
-- @since 4.5.0 Introduced `publicly_queryable` argument.
-- @since 4.7.0 Introduced `show_in_rest`, "rest_base" and "rest_controller_class"
--              arguments to register the taxonomy in REST API.
-- @since 5.1.0 Introduced `meta_box_sanitize_cb` argument.
-- @since 5.4.0 Added the registered taxonomy object as a return value.
-- @since 5.5.0 Introduced `default_term` argument.
-- @since 5.9.0 Introduced `rest_namespace` argument.
--
-- @global WP_Taxonomy() wp_taxonomies Registered taxonomies.
--
-- @param string       taxonomy    Taxonomy key, must not exceed 32 characters and may only contain lowercase alphanumeric
--                                  characters, dashes, and underscores. See sanitize_key().
-- @param array|string object_type Object type or array of object types with which the taxonomy should be associated.
-- @param array|string args        {
--     Optional. Array or query string of arguments for registering a taxonomy.
--
--     @type string()      labels                An array of labels for this taxonomy. By default, Tag labels are
--                                                used for non-hierarchical taxonomies, and Category labels are used
--                                                for hierarchical taxonomies. See accepted values in
--                                                get_taxonomy_labels(). Default empty array.
--     @type string        description           A short descriptive summary of what the taxonomy is for. Default empty.
--     @type bool          public                Whether a taxonomy is intended for use publicly either via
--                                                the admin interface or by front-end users. The default settings
--                                                of `publicly_queryable`, `show_ui`, and `show_in_nav_menus`
--                                                are inherited from `public`.
--     @type bool          publicly_queryable    Whether the taxonomy is publicly queryable.
--                                                If not set, the default is inherited from `public`
--     @type bool          hierarchical          Whether the taxonomy is hierarchical. Default false.
--     @type bool          show_ui               Whether to generate and allow a UI for managing terms in this taxonomy in
--                                                the admin. If not set, the default is inherited from `public`
--                                                (default true).
--     @type bool          show_in_menu          Whether to show the taxonomy in the admin menu. If true, the taxonomy is
--                                                shown as a submenu of the object type menu. If false, no menu is shown.
--                                                `show_ui` must be true. If not set, default is inherited from `show_ui`
--                                                (default true).
--     @type bool          show_in_nav_menus     Makes this taxonomy available for selection in navigation menus. If not
--                                                set, the default is inherited from `public` (default true).
--     @type bool          show_in_rest          Whether to include the taxonomy in the REST API. Set this to true
--                                                for the taxonomy to be available in the block editor.
--     @type string        rest_base             To change the base url of REST API route. Default is taxonomy.
--     @type string        rest_namespace        To change the namespace URL of REST API route. Default is wp/v2.
--     @type string        rest_controller_class REST API Controller class name. Default is "WP_REST_Terms_Controller".
--     @type bool          show_tagcloud         Whether to list the taxonomy in the Tag Cloud Widget controls. If not set,
--                                                the default is inherited from `show_ui` (default true).
--     @type bool          show_in_quick_edit    Whether to show the taxonomy in the quick/bulk edit panel. It not set,
--                                                the default is inherited from `show_ui` (default true).
--     @type bool          show_admin_column     Whether to display a column for the taxonomy on its post type listing
--                                                screens. Default false.
--     @type bool|callable meta_box_cb           Provide a callback function for the meta box display. If not set,
--                                                post_categories_meta_box() is used for hierarchical taxonomies, and
--                                                post_tags_meta_box() is used for non-hierarchical. If false, no meta
--                                                box is shown.
--     @type callable      meta_box_sanitize_cb  Callback function for sanitizing taxonomy data saved from a meta
--                                                box. If no callback is defined, an appropriate one is determined
--                                                based on the value of `meta_box_cb`.
--     @type string()      capabilities {
--         Array of capabilities for this taxonomy.
--
--         @type string manage_terms Default "manage_categories".
--         @type string edit_terms   Default "manage_categories".
--         @type string delete_terms Default "manage_categories".
--         @type string assign_terms Default "edit_posts".
--     }
--     @type bool|array    rewrite {
--         Triggers the handling of rewrites for this taxonomy. Default true, using taxonomy as slug. To prevent
--         rewrite, set to false. To specify rewrite rules, an array can be passed with any of these keys:
--
--         @type string slug         Customize the permastruct slug. Default `taxonomy` key.
--         @type bool   with_front   Should the permastruct be prepended with WP_Rewrite::front. Default true.
--         @type bool   hierarchical Either hierarchical rewrite tag or not. Default false.
--         @type int    ep_mask      Assign an endpoint mask. Default `EP_NONE`.
--     }
--     @type string|bool   query_var             Sets the query var key for this taxonomy. Default `taxonomy` key. If
--                                                false, a taxonomy cannot be loaded at `?thenquery_varend;=thenterm_slugend;`. If a
--                                                string, the query `?thenquery_varend;=thenterm_slugend;` will be valid.
--     @type callable      update_count_callback Works much like a hook, in that it will be called when the count is
--                                                updated. Default _update_post_term_count() for taxonomies attached
--                                                to post types, which confirms that the objects are published before
--                                                counting them. Default _update_generic_term_count() for taxonomies
--                                                attached to other object types, such as users.
--     @type string|array  default_term {
--         Default term to be used for the taxonomy.
--
--         @type string name         Name of default term.
--         @type string slug         Slug for default term. Default empty.
--         @type string description  Description for default term. Default empty.
--     }
--     @type bool          sort                  Whether terms in this taxonomy should be sorted in the order they are
--                                                provided to `wp_set_object_terms()`. Default null which equates to false.
--     @type array         args                  Array of arguments to automatically use inside `wp_get_object_terms()`
--                                                for this taxonomy.
--     @type bool          _builtin              This taxonomy is a "built-in" taxonomy. INTERNAL USE ONLY!
--                                                Default false.
-- }
-- @return WP_Taxonomy|WP_Error The registered taxonomy object on success, WP_Error object on failure.

   -- procedure Register_Taxonomy (Taxonomy    : String;
   --                              Object_Type : String;
   --                              Args        : Array_Type)
   -- is
   -- begin
   --    Register_Taxonomy (Taxonomy,
   --                       [Object_Type],
   --                       Args);
   -- end Register_Taxonomy;

-- Taxonomies : Array_Type;

   procedure Register_Taxonomy (Taxonomy    : String;
                                Object_Type : List_Type;
                                Args        : Array_Type)
   is
      use Class_Taxonomy;

      Unused : constant Wp_Taxonomy :=
         Register_Taxonomy (Taxonomy,
                            Object_Type,
                            Args);
   begin
      null;
   end Register_Taxonomy;
--
-- function register_taxonomy (taxonomy, object_type, args = array()) then
   function Register_Taxonomy (Taxonomy    : String;
                               Object_Type : List_Type;
                               Args        : Array_Type)
                               return Class_Taxonomy.Wp_Taxonomy
   is
      use Php.Arrays;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Class_Taxonomy;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Plugins;

--         global wp_taxonomies;
      Args_2 : Array_Type;
   begin
      -- if  (! is_array (wp_taxonomies)) then
      --         wp_taxonomies = array();
      -- end;

      Args_2 := Wp_Parse_Args (Args);

      if Empty (Taxonomy) or else Taxonomy'Length > 32 then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Taxonomy names must be between 1 and 32 characters in length.",
           "4.2.0");
         return Null_Taxonomy;
         -- return new WP_Error ("taxonomy_length_invalid", abs "Taxonomy names must be between 1 and 32 characters in length.");
      end if;

      declare
         Taxonomy_Object : constant Wp_Taxonomy :=
           X_Construct (Taxonomy, Object_Type, Args_2);
         -- new WP_Taxonomy (taxonomy, object_type, args);
      begin
         Taxonomy_Object.Add_Rewrite_Rules;

         Taxonomy_Map.Include (Key      => Taxonomy,
                               New_Item => Taxonomy_Object);
--       Set (Taxonomies, Taxonomy, Taxonomy_Object);
--       Wp_Taxonomies (Taxonomy) := Taxonomy_Object;

         Taxonomy_Object.Add_Hooks;

         -- Add default term.
         if not Empty (Taxonomy_Object.Default_Term) then
            declare
--             use Class_Terms;

               Term : Array_Type :=
                 Term_Exists (Get_As_String (Taxonomy_Object.Default_Term, "name"),
                              Taxonomy);
            begin
               if Term /= Empty_Array then
--             if Term then
                  Update_Option ("default_term_" & (-Taxonomy_Object.Name),
                                 Get (Term, "term_id"));
               else
                  Term :=
                    Wp_Insert_Term (
                      Get_As_String (Taxonomy_Object.Default_Term, "name"),
                      Taxonomy,
                      To_Array (List => (
                        Build ("slug",
                               Sanitize_Title (Get_As_String (Taxonomy_Object.Default_Term, "slug"))),
                        Build ("description",
                               Get_As_String (Taxonomy_Object.Default_Term, "description"))
                      ))
                    );

                  -- Update `term_id` in options.
--                if not Is_Wp_Error (Term) then
                     Update_Option ("default_term_" & (-Taxonomy_Object.Name),
                                    Get (Term, "term_id"));
--                end if;
               end if;
            end;
         end if;

         --
         -- Fires after a taxonomy is registered.
         --
         -- @since 3.3.0
         --
         -- @param string       taxonomy    Taxonomy slug.
         -- @param array|string object_type Object type or array of object types.
         -- @param array        args        Array of taxonomy registration arguments.
         --
         Do_Action ("registered_taxonomy", Taxonomy, Object_Type, Taxonomy_Object); -- (array)

         --
         -- Fires after a specific taxonomy is registered.
         --
         -- The dynamic portion of the filter name, `taxonomy`, refers to the
         -- taxonomy key.
         --
         -- Possible hook names include:
         --
         --  - `registered_taxonomy_category`
         --  - `registered_taxonomy_post_tag`
         --
         -- @since 6.0.0
         --
         -- @param string       taxonomy    Taxonomy slug.
         -- @param array|string object_type Object type or array of object types.
         -- @param array        args        Array of taxonomy registration arguments.
         --
         Do_Action ("registered_taxonomy_" & Taxonomy, Taxonomy, Object_Type, Taxonomy_Object); -- (array)

         return Taxonomy_Object;
      end;
   end Register_Taxonomy;

--
-- Unregisters a taxonomy.
--
-- Can not be used to unregister built-in taxonomies.
--
-- @since 4.5.0
--
-- @global WP            wp            Current WordPress environment instance.
-- @global WP_Taxonomy() wp_taxonomies List of taxonomies.
--
-- @param string taxonomy Taxonomy name.
-- @return true|WP_Error True on success, WP_Error on failure or if the taxonomy doesn"t exist.
--
-- function unregister_taxonomy (taxonomy) then
--         if  (! taxonomy_exists (taxonomy)) then
--                 return new WP_Error ("invalid_taxonomy", __ ("Invalid taxonomy."));
--         end;

--         taxonomy_object = get_taxonomy (taxonomy);

--         // Do not allow unregistering internal taxonomies.
--         if  (taxonomy_object._builtin) then
--                 return new WP_Error ("invalid_taxonomy", __ ("Unregistering a built-in taxonomy is not allowed."));
--         end;

--         global wp_taxonomies;

--         taxonomy_object.remove_rewrite_rules();
--         taxonomy_object.remove_hooks();

--         // Remove the taxonomy.
--         unset (wp_taxonomies (taxonomy));

--         --
--         -- Fires after a taxonomy is unregistered.
--         --
--         -- @since 4.5.0
--         --
--         -- @param string taxonomy Taxonomy name.
--         --
--         do_action ("unregistered_taxonomy", taxonomy);

--         return true;
-- end;

   -------------------------
   -- Get_Taxonomy_Labels --
   -------------------------

   function Get_Taxonomy_Labels (Tax : in out Class_Taxonomy.Wp_Taxonomy)
                                 return Array_Type
   is
      use Php.Arrays;
      use UStrings;
      use Wp_Common;
      use Inc_Plugins;
   begin
--    tax.labels = (array) tax.labels;

      -- if
      --   Isset (Tax.Helps) and then
      --   Empty (Tax.Labels ("separate_items_with_commas"))
      -- then
      --    Tax.Labels ("separate_items_with_commas") := Tax.Helps;
      -- end if;

      -- if
      --   Isset (Tax.No_Tagcloud) and then
      --   Empty (Tax.Labels ("not_found"))
      -- then
      --    Tax.Labels ("not_found") := Tax.No_Tagcloud;
      -- end if;

      declare
         Nohier_Vs_Hier_Defaults : Array_Type :=
           Class_Taxonomy.Get_Default_Labels;
--       Nohier_Vs_Hier_Defaults : Array_Type := WP_Taxonomy::Get_Default_Labels;
         Labels         : Array_Type;
         Default_Labels : Array_Type;
         Taxonomy       : UString;
      begin
         Set (Nohier_Vs_Hier_Defaults,
              Key   => "menu_name",
              Value => Get (Nohier_Vs_Hier_Defaults, "name"));

         Labels := Inc_Posts.X_Get_Custom_Object_Labels (Tax, Nohier_Vs_Hier_Defaults);

         Taxonomy := Tax.Name;

         Default_Labels := Labels; -- clone labels;

         --
         -- Filters the labels of a specific taxonomy.
         --
         -- The dynamic portion of the hook name, `taxonomy`, refers to the taxonomy
         -- slug.
         --
         -- Possible hook names include:
         --
         --  - `taxonomy_labels_category`
         --  - `taxonomy_labels_post_tag`
         --
         -- @since 4.4.0
         --
         -- @see get_taxonomy_labels() for the full list of taxonomy labels.
         --
         -- @param object labels Object with labels for the taxonomy as member
         --                      variables.
         --
         Labels := Apply_Filters ("taxonomy_labels_" & (-Taxonomy), Labels);

         -- Ensure that the filtered labels contain all required default values.
         Labels := Array_Merge (Default_Labels, Labels);
--       Labels := (object) Array_Merge ((array) Default_Labels, (array) Labels);

         return Labels;
      end;
   end Get_Taxonomy_Labels;

--
-- Adds an already registered taxonomy to an object type.
--
-- @since 3.0.0
--
-- @global WP_Taxonomy() wp_taxonomies The registered taxonomies.
--
-- @param string taxonomy    Name of taxonomy object.
-- @param string object_type Name of the object type.
-- @return bool True if successful, false if not.
--
-- function register_taxonomy_for_object_type (taxonomy, object_type) then
--         global wp_taxonomies;

--         if  (! isset (wp_taxonomies (taxonomy))) then
--                 return false;
--         end;

--         if  (! get_post_type_object (object_type)) then
--                 return false;
--         end;

--         if  (! in_array (object_type, wp_taxonomies (taxonomy).object_type, true)) then
--                 wp_taxonomies (taxonomy).object_type() = object_type;
--         end;

--         // Filter out empties.
--         wp_taxonomies (taxonomy).object_type = array_filter (wp_taxonomies (taxonomy).object_type);

--         --
--         -- Fires after a taxonomy is registered for an object type.
--         --
--         -- @since 5.1.0
--         --
--         -- @param string taxonomy    Taxonomy name.
--         -- @param string object_type Name of the object type.
--         --
--         do_action ("registered_taxonomy_for_object_type", taxonomy, object_type);

--         return true;
-- end;

--
-- Removes an already registered taxonomy from an object type.
--
-- @since 3.7.0
--
-- @global WP_Taxonomy() wp_taxonomies The registered taxonomies.
--
-- @param string taxonomy    Name of taxonomy object.
-- @param string object_type Name of the object type.
-- @return bool True if successful, false if not.
--
-- function unregister_taxonomy_for_object_type (taxonomy, object_type) then
--         global wp_taxonomies;

--         if  (! isset (wp_taxonomies (taxonomy))) then
--                 return false;
--         end;

--         if  (! get_post_type_object (object_type)) then
--                 return false;
--         end;

--         key = array_search (object_type, wp_taxonomies (taxonomy).object_type, true);
--         if  (false === key) then
--                 return false;
--         end;

--         unset (wp_taxonomies (taxonomy).object_type (key));

--         --
--         -- Fires after a taxonomy is unregistered for an object type.
--         --
--         -- @since 5.1.0
--         --
--         -- @param string taxonomy    Taxonomy name.
--         -- @param string object_type Name of the object type.
--         --
--         do_action ("unregistered_taxonomy_for_object_type", taxonomy, object_type);

--         return true;
-- end;

--
-- Term API.
--

--
-- Retrieves object IDs of valid taxonomy and term.
--
-- The strings of `taxonomies` must exist before this function will continue.
-- On failure of finding a valid taxonomy, it will return a WP_Error.
--
-- The `terms` aren"t checked the same as `taxonomies`, but still need to exist
-- for object IDs to be returned.
--
-- It is possible to change the order that object IDs are returned by using `args`
-- with either ASC or DESC array. The value should be in the key named "order".
--
-- @since 2.3.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int|int()       term_ids   Term ID or array of term IDs of terms that will be used.
-- @param string|string() taxonomies String of taxonomy name or Array of string values of taxonomy names.
-- @param array|string    args       Change the order of the object IDs, either ASC or DESC.
-- @return string()|WP_Error An array of object IDs as numeric strings on success,
--                           WP_Error if the taxonomy does not exist.
--
-- function get_objects_in_term (term_ids, taxonomies, args = array()) then
--         global wpdb;

--         if  (! is_array (term_ids)) then
--                 term_ids = array (term_ids);
--         end;
--         if  (! is_array (taxonomies)) then
--                 taxonomies = array (taxonomies);
--         end;
--         foreach  ((array) taxonomies as taxonomy) then
--                 if  (! taxonomy_exists (taxonomy)) then
--                         return new WP_Error ("invalid_taxonomy", __ ("Invalid taxonomy."));
--                 end;
--         end;

--         defaults = array ("order" => "ASC");
--         args     = wp_parse_args (args, defaults);

--         order =  ("desc" === strtolower (args("order"))) ? "DESC" : "ASC";

--         term_ids = array_map ("intval", term_ids);

--         taxonomies = """ . implode ("", "", array_map ("esc_sql", taxonomies)) . """;
--         term_ids   = """ . implode ("", "", term_ids) . """;

--         sql = "SELECT tr.object_id FROM wpdb.term_relationships AS tr INNER JOIN wpdb.term_taxonomy AS tt ON tr.term_taxonomy_id = tt.term_taxonomy_id WHERE tt.taxonomy IN (taxonomies) AND tt.term_id IN (term_ids) ORDER BY tr.object_id order";

--         last_changed = wp_cache_get_last_changed ("terms");
--         cache_key    = "get_objects_in_term:" . md5 (sql) . ":last_changed";
--         cache        = wp_cache_get (cache_key, "terms");
--         if  (false === cache) then
--                 object_ids = wpdb.get_col (sql);
--                 wp_cache_set (cache_key, object_ids, "terms");
--         end; else then
--                 object_ids = (array) cache;
--         end;

--         if  (! object_ids) then
--                 return array();
--         end;
--         return object_ids;
-- end;

--
-- Given a taxonomy query, generates SQL to be appended to a main query.
--
-- @since 3.1.0
--
-- @see WP_Tax_Query
--
-- @param array  tax_query         A compact tax query
-- @param string primary_table
-- @param string primary_id_column
-- @return string()
--
-- function get_tax_sql (tax_query, primary_table, primary_id_column) then
--         tax_query_obj = new WP_Tax_Query (tax_query);
--         return tax_query_obj.get_sql (primary_table, primary_id_column);
-- end;

--
-- Gets all term data from database by term ID.
--
-- The usage of the get_term function is to apply filters to a term object. It
-- is possible to get a term object from the database before applying the
-- filters.
--
-- term ID must be part of taxonomy, to get from the database. Failure, might
-- be able to be captured by the hooks. Failure would be the same value as wpdb
-- returns for the get_row method.
--
-- There are two hooks, one is specifically for each term, named "get_term", and
-- the second is for the taxonomy name, "term_taxonomy". Both hooks gets the
-- term object, and the taxonomy name as parameters. Both hooks are expected to
-- return a term object.
--
-- {@see "get_term"} hook - Takes two parameters the term Object and the taxonomy name.
-- Must return term object. Used in get_term() as a catch-all filter for every
-- term.
--
-- {@see "get_taxonomy"} hook - Takes two parameters the term Object and the taxonomy
-- name. Must return term object. taxonomy will be the taxonomy name, so for
-- example, if "category", it would be "get_category" as the filter name. Useful
-- for custom taxonomies or plugging into default taxonomies.
--
-- @todo Better formatting for DocBlock
--
-- @since 2.3.0
-- @since 4.4.0 Converted to return a WP_Term object if `output` is `OBJECT`.
--              The `taxonomy` parameter was made optional.
--
-- @see sanitize_term_field() The context param lists the available values for get_term_by() filter param.
--
-- @param int|WP_Term|object term     If integer, term data will be fetched from the database,
--                                     or from the cache if available.
--                                     If stdClass object (as in the results of a database query),
--                                     will apply filters and return a `WP_Term` object with the `term` data.
--                                     If `WP_Term`, will return `term`.
-- @param string             taxonomy Optional. Taxonomy name that `term` is part of.
-- @param string             output   Optional. The required return type. One of OBJECT, ARRAY_A, or ARRAY_N, which
--                                     correspond to a WP_Term object, an associative array, or a numeric array,
--                                     respectively. Default OBJECT.
-- @param string             filter   Optional. How to sanitize term fields. Default "raw".
-- @return WP_Term|array|WP_Error|null WP_Term instance (or array) on success, depending on the `output` value.
--                                     WP_Error if `taxonomy` does not exist. Null for miscellaneous failure.
--

   function Get_Term (Term     : Integer; -- Class_Terms.Wp_Term;
                      Taxonomy : String := "";
                      Output   : String := "OBJECT";
                      Filter   : String := "raw")
                      return Class_Terms.Wp_Term
   is
      T : Class_Terms.Wp_Term;
   begin
      return T;
   end Get_Term;

-- function get_term (term, taxonomy = "", output = OBJECT, filter = "raw") then
--         if  (empty (term)) then
--                 return new WP_Error ("invalid_term", __ ("Empty Term."));
--         end;

--         if  (taxonomy && ! taxonomy_exists (taxonomy)) then
--                 return new WP_Error ("invalid_taxonomy", __ ("Invalid taxonomy."));
--         end;

--         if  (term instanceof WP_Term) then
--                 _term = term;
--         end; elseif  (is_object (term)) then
--                 if  (empty (term.filter) || "raw" === term.filter) then
--                         _term = sanitize_term (term, taxonomy, "raw");
--                         _term = new WP_Term (_term);
--                 end; else then
--                         _term = WP_Term::get_instance (term.term_id);
--                 end;
--         end; else then
--                 _term = WP_Term::get_instance (term, taxonomy);
--         end;

--         if  (is_wp_error (_term)) then
--                 return _term;
--         end; elseif  (! _term) then
--                 return null;
--         end;

--         // Ensure for filters that this is not empty.
--         taxonomy = _term.taxonomy;

--         --
--         -- Filters a taxonomy term object.
--         --
--         -- The {@see "get_taxonomy"} hook is also available for targeting a specific
--         -- taxonomy.
--         --
--         -- @since 2.3.0
--         -- @since 4.4.0 `_term` is now a `WP_Term` object.
--         --
--         -- @param WP_Term _term    Term object.
--         -- @param string  taxonomy The taxonomy slug.
--         --
--         _term = apply_filters ("get_term", _term, taxonomy);

--         --
--         -- Filters a taxonomy term object.
--         --
--         -- The dynamic portion of the hook name, `taxonomy`, refers
--         -- to the slug of the term"s taxonomy.
--         --
--         -- Possible hook names include:
--         --
--         --  - `get_category`
--         --  - `get_post_tag`
--         --
--         -- @since 2.3.0
--         -- @since 4.4.0 `_term` is now a `WP_Term` object.
--         --
--         -- @param WP_Term _term    Term object.
--         -- @param string  taxonomy The taxonomy slug.
--         --
--         _term = apply_filters ("get_thentaxonomyend;", _term, taxonomy);

--         // Bail if a filter callback has changed the type of the `_term` object.
--         if  (!  (_term instanceof WP_Term)) then
--                 return _term;
--         end;

--         // Sanitize term, according to the specified filter.
--         _term.filter (filter);

--         if  (ARRAY_A === output) then
--                 return _term.to_array();
--         end; elseif  (ARRAY_N === output) then
--                 return array_values (_term.to_array());
--         end;

--         return _term;
-- end;

--
-- Gets all term data from database by term field and data.
--
-- Warning: value is not escaped for "name" field. You must do it yourself, if
-- required.
--
-- The default field is "id", therefore it is possible to also use null for
-- field, but not recommended that you do so.
--
-- If value does not exist, the return value will be false. If taxonomy exists
-- and field and value combinations exist, the term will be returned.
--
-- This function will always return the first term that matches the `field`-
-- `value`-`taxonomy` combination specified in the parameters. If your query
-- is likely to match more than one term (as is likely to be the case when
-- `field` is "name", for example), consider using get_terms() instead; that
-- way, you will get all matching terms, and can provide your own logic for
-- deciding which one was intended.
--
-- @todo Better formatting for DocBlock.
--
-- @since 2.3.0
-- @since 4.4.0 `taxonomy` is optional if `field` is "term_taxonomy_id". Converted to return
--              a WP_Term object if `output` is `OBJECT`.
-- @since 5.5.0 Added "ID" as an alias of "id" for the `field` parameter.
--
-- @see sanitize_term_field() The context param lists the available values for get_term_by() filter param.
--
-- @param string     field    Either "slug", "name", "term_id" (or "id", "ID"), or "term_taxonomy_id".
-- @param string|int value    Search for this term value.
-- @param string     taxonomy Taxonomy name. Optional, if `field` is "term_taxonomy_id".
-- @param string     output   Optional. The required return type. One of OBJECT, ARRAY_A, or ARRAY_N, which
--                             correspond to a WP_Term object, an associative array, or a numeric array,
--                             respectively. Default OBJECT.
-- @param string     filter   Optional. How to sanitize term fields. Default "raw".
-- @return WP_Term|array|false WP_Term instance (or array) on success, depending on the `output` value.
--                             False if `taxonomy` does not exist or `term` was not found.
--
-- function get_term_by (field, value, taxonomy = "", output = OBJECT, filter = "raw") then

--         // "term_taxonomy_id" lookups don"t require taxonomy checks.
--         if  ("term_taxonomy_id" !== field && ! taxonomy_exists (taxonomy)) then
--                 return false;
--         end;

--         // No need to perform a query for empty "slug" or "name".
--         if  ("slug" === field || "name" === field) then
--                 value = (string) value;

--                 if  (0 === strlen (value)) then
--                         return false;
--                 end;
--         end;

--         if  ("id" === field || "ID" === field || "term_id" === field) then
--                 term = get_term ((int) value, taxonomy, output, filter);
--                 if  (is_wp_error (term) || null === term) then
--                         term = false;
--                 end;
--                 return term;
--         end;

--         args = array(
--                 "get"                    => "all",
--                 "number"                 => 1,
--                 "taxonomy"               => taxonomy,
--                 "update_term_meta_cache" => false,
--                 "orderby"                => "none",
--                 "suppress_filter"        => true,
--        );

--         switch  (field) then
--                 case "slug":
--                         args("slug") = value;
--                         break;
--                 case "name":
--                         args("name") = value;
--                         break;
--                 case "term_taxonomy_id":
--                         args("term_taxonomy_id") = value;
--                         unset (args("taxonomy"));
--                         break;
--                 default:
--                         return false;
--         end;

--         terms = get_terms (args);
--         if  (is_wp_error (terms) || empty (terms)) then
--                 return false;
--         end;

--         term = array_shift (terms);

--         // In the case of "term_taxonomy_id", override the provided `taxonomy` with whatever we find in the DB.
--         if  ("term_taxonomy_id" === field) then
--                 taxonomy = term.taxonomy;
--         end;

--         return get_term (term, taxonomy, output, filter);
-- end;

--
-- Merges all term children into a single array of their IDs.
--
-- This recursive function will merge all of the children of term into the same
-- array of term IDs. Only useful for taxonomies which are hierarchical.
--
-- Will return an empty array if term does not exist in taxonomy.
--
-- @since 2.3.0
--
-- @param int    term_id  ID of term to get children.
-- @param string taxonomy Taxonomy name.
-- @return array|WP_Error List of term IDs. WP_Error returned if `taxonomy` does not exist.
--
-- function get_term_children (term_id, taxonomy) then
--         if  (! taxonomy_exists (taxonomy)) then
--                 return new WP_Error ("invalid_taxonomy", __ ("Invalid taxonomy."));
--         end;

--         term_id = (int) term_id;

--         terms = _get_term_hierarchy (taxonomy);

--         if  (! isset (terms (term_id))) then
--                 return array();
--         end;

--         children = terms (term_id);

--         foreach  ((array) terms (term_id) as child) then
--                 if  (term_id === child) then
--                         continue;
--                 end;

--                 if  (isset (terms (child))) then
--                         children = array_merge (children, get_term_children (child, taxonomy));
--                 end;
--         end;

--         return children;
-- end;

--
-- Gets sanitized term field.
--
-- The function is for contextual reasons and for simplicity of usage.
--
-- @since 2.3.0
-- @since 4.4.0 The `taxonomy` parameter was made optional. `term` can also now accept a WP_Term object.
--
-- @see sanitize_term_field()
--
-- @param string      field    Term field to fetch.
-- @param int|WP_Term term     Term ID or object.
-- @param string      taxonomy Optional. Taxonomy name. Default empty.
-- @param string      context  Optional. How to sanitize term fields. Look at sanitize_term_field() for available options.
--                              Default "display".
-- @return string|int|null|WP_Error Will return an empty string if term is not an object or if field is not set in term.
--
-- function get_term_field (field, term, taxonomy = "", context = "display") then
--         term = get_term (term, taxonomy);
--         if  (is_wp_error (term)) then
--                 return term;
--         end;

--         if  (! is_object (term)) then
--                 return "";
--         end;

--         if  (! isset (term.field)) then
--                 return "";
--         end;

--         return sanitize_term_field (field, term.field, term.term_id, term.taxonomy, context);
-- end;

--
-- Sanitizes term for editing.
--
-- Return value is sanitize_term() and usage is for sanitizing the term for
-- editing. Function is for contextual and simplicity.
--
-- @since 2.3.0
--
-- @param int|object id       Term ID or object.
-- @param string     taxonomy Taxonomy name.
-- @return string|int|null|WP_Error Will return empty string if term is not an object.
--
-- function get_term_to_edit (id, taxonomy) then
--         term = get_term (id, taxonomy);

--         if  (is_wp_error (term)) then
--                 return term;
--         end;

--         if  (! is_object (term)) then
--                 return "";
--         end;

--         return sanitize_term (term, taxonomy, "edit");
-- end;

--
-- Retrieves the terms in a given taxonomy or list of taxonomies.
--
-- You can fully inject any customizations to the query before it is sent, as
-- well as control the output with a filter.
--
-- The return type varies depending on the value passed to `args("fields")`. See
-- WP_Term_Query::get_terms() for details. In all cases, a `WP_Error` object will
-- be returned if an invalid taxonomy is requested.
--
-- The {@see "get_terms"} filter will be called when the cache has the term and will
-- pass the found term along with the array of taxonomies and array of args.
-- This filter is also called before the array of terms is passed and will pass
-- the array of terms, along with the taxonomies and args.
--
-- The {@see "list_terms_exclusions"} filter passes the compiled exclusions along with
-- the args.
--
-- The {@see "get_terms_orderby"} filter passes the `ORDER BY` clause for the query
-- along with the args array.
--
-- Prior to 4.5.0, the first parameter of `get_terms()` was a taxonomy or list of taxonomies:
--
--     terms = get_terms ("post_tag", array(
--         "hide_empty" => false,
--    ));
--
-- Since 4.5.0, taxonomies should be passed via the "taxonomy" argument in the `args` array:
--
--     terms = get_terms (array(
--         "taxonomy" => "post_tag",
--         "hide_empty" => false,
--    ));
--
-- @since 2.3.0
-- @since 4.2.0 Introduced "name" and "childless" parameters.
-- @since 4.4.0 Introduced the ability to pass "term_id" as an alias of "id" for the `orderby` parameter.
--              Introduced the "meta_query" and "update_term_meta_cache" parameters. Converted to return
--              a list of WP_Term objects.
-- @since 4.5.0 Changed the function signature so that the `args` array can be provided as the first parameter.
--              Introduced "meta_key" and "meta_value" parameters. Introduced the ability to order results by metadata.
-- @since 4.8.0 Introduced "suppress_filter" parameter.
--
-- @internal The `deprecated` parameter is parsed for backward compatibility only.
--
-- @param array|string args       Optional. Array or string of arguments. See WP_Term_Query::__construct()
--                                 for information on accepted arguments. Default empty array.
-- @param array|string deprecated Optional. Argument array, when using the legacy function parameter format.
--                                 If present, this parameter will be interpreted as `args`, and the first
--                                 function parameter will be parsed as a taxonomy or array of taxonomies.
--                                 Default empty.
-- @return WP_Term()|int()|string()|string|WP_Error Array of terms, a count thereof as a numeric string,
--                                                  or WP_Error if any of the taxonomies do not exist.
--                                                  See the function description for more information.
--
-- function get_terms (args = array(), deprecated = "") then
--         term_query = new WP_Term_Query();

--         defaults = array(
--                 "suppress_filter" => false,
--        );

--         /*
--         -- Legacy argument format (taxonomy, args) takes precedence.
--         --
--         -- We detect legacy argument format by checking if
--         -- (a) a second non-empty parameter is passed, or
--         -- (b) the first parameter shares no keys with the default array (ie, it"s a list of taxonomies)
--         --
--         _args          = wp_parse_args (args);
--         key_intersect  = array_intersect_key (term_query.query_var_defaults, (array) _args);
--         do_legacy_args = deprecated || empty (key_intersect);

--         if  (do_legacy_args) then
--                 taxonomies       = (array) args;
--                 args             = wp_parse_args (deprecated, defaults);
--                 args("taxonomy") = taxonomies;
--         end; else then
--                 args = wp_parse_args (args, defaults);
--                 if  (isset (args("taxonomy")) && null !== args("taxonomy")) then
--                         args("taxonomy") = (array) args("taxonomy");
--                 end;
--         end;

--         if  (! empty (args("taxonomy"))) then
--                 foreach  (args("taxonomy") as taxonomy) then
--                         if  (! taxonomy_exists (taxonomy)) then
--                                 return new WP_Error ("invalid_taxonomy", __ ("Invalid taxonomy."));
--                         end;
--                 end;
--         end;

--         // Don"t pass suppress_filter to WP_Term_Query.
--         suppress_filter = args("suppress_filter");
--         unset (args("suppress_filter"));

--         terms = term_query.query (args);

--         // Count queries are not filtered, for legacy reasons.
--         if  (! is_array (terms)) then
--                 return terms;
--         end;

--         if  (suppress_filter) then
--                 return terms;
--         end;

--         --
--         -- Filters the found terms.
--         --
--         -- @since 2.3.0
--         -- @since 4.6.0 Added the `term_query` parameter.
--         --
--         -- @param array         terms      Array of found terms.
--         -- @param array|null    taxonomies An array of taxonomies if known.
--         -- @param array         args       An array of get_terms() arguments.
--         -- @param WP_Term_Query term_query The WP_Term_Query object.
--         --
--         return apply_filters ("get_terms", terms, term_query.query_vars("taxonomy"), term_query.query_vars, term_query);
-- end;

--
-- Adds metadata to a term.
--
-- @since 4.4.0
--
-- @param int    term_id    Term ID.
-- @param string meta_key   Metadata name.
-- @param mixed  meta_value Metadata value. Must be serializable if non-scalar.
-- @param bool   unique     Optional. Whether the same key should not be added.
--                           Default false.
-- @return int|false|WP_Error Meta ID on success, false on failure.
--                            WP_Error when term_id is ambiguous between taxonomies.
--
-- function add_term_meta (term_id, meta_key, meta_value, unique = false) then
--         if  (wp_term_is_shared (term_id)) then
--                 return new WP_Error ("ambiguous_term_id", __ ("Term meta cannot be added to terms that are shared between taxonomies."), term_id);
--         end;

--         return add_metadata ("term", term_id, meta_key, meta_value, unique);
-- end;

--
-- Removes metadata matching criteria from a term.
--
-- @since 4.4.0
--
-- @param int    term_id    Term ID.
-- @param string meta_key   Metadata name.
-- @param mixed  meta_value Optional. Metadata value. If provided,
--                           rows will only be removed that match the value.
--                           Must be serializable if non-scalar. Default empty.
-- @return bool True on success, false on failure.
--
-- function delete_term_meta (term_id, meta_key, meta_value = "") then
--         return delete_metadata ("term", term_id, meta_key, meta_value);
-- end;

--
-- Retrieves metadata for a term.
--
-- @since 4.4.0
--
-- @param int    term_id Term ID.
-- @param string key     Optional. The meta key to retrieve. By default,
--                        returns data for all keys. Default empty.
-- @param bool   single  Optional. Whether to return a single value.
--                        This parameter has no effect if `key` is not specified.
--                        Default false.
-- @return mixed An array of values if `single` is false.
--               The value of the meta field if `single` is true.
--               False for an invalid `term_id` (non-numeric, zero, or negative value).
--               An empty string if a valid but non-existing term ID is passed.
--
-- function get_term_meta (term_id, key = "", single = false) then
--         return get_metadata ("term", term_id, key, single);
-- end;

--
-- Updates term metadata.
--
-- Use the `prev_value` parameter to differentiate between meta fields with the same key and term ID.
--
-- If the meta field for the term does not exist, it will be added.
--
-- @since 4.4.0
--
-- @param int    term_id    Term ID.
-- @param string meta_key   Metadata key.
-- @param mixed  meta_value Metadata value. Must be serializable if non-scalar.
-- @param mixed  prev_value Optional. Previous value to check before updating.
--                           If specified, only update existing metadata entries with
--                           this value. Otherwise, update all entries. Default empty.
-- @return int|bool|WP_Error Meta ID if the key didn"t exist. true on successful update,
--                           false on failure or if the value passed to the function
--                           is the same as the one that is already in the database.
--                           WP_Error when term_id is ambiguous between taxonomies.
--
-- function update_term_meta (term_id, meta_key, meta_value, prev_value = "") then
--         if  (wp_term_is_shared (term_id)) then
--                 return new WP_Error ("ambiguous_term_id", __ ("Term meta cannot be added to terms that are shared between taxonomies."), term_id);
--         end;

--         return update_metadata ("term", term_id, meta_key, meta_value, prev_value);
-- end;

--
-- Updates metadata cache for list of term IDs.
--
-- Performs SQL query to retrieve all metadata for the terms matching `term_ids` and stores them in the cache.
-- Subsequent calls to `get_term_meta()` will not need to query the database.
--
-- @since 4.4.0
--
-- @param array term_ids List of term IDs.
-- @return array|false An array of metadata on success, false if there is nothing to update.
--
-- function update_termmeta_cache (term_ids) then
--         return update_meta_cache ("term", term_ids);
-- end;

--
-- Gets all meta data, including meta IDs, for the given term ID.
--
-- @since 4.9.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int term_id Term ID.
-- @return array|false Array with meta data, or false when the meta table is not installed.
--
-- function has_term_meta (term_id) then
--         check = wp_check_term_meta_support_prefilter (null);
--         if  (null !== check) then
--                 return check;
--         end;

--         global wpdb;

--         return wpdb.get_results (wpdb.prepare ("SELECT meta_key, meta_value, meta_id, term_id FROM wpdb.termmeta WHERE term_id = %d ORDER BY meta_key,meta_id", term_id), ARRAY_A);
-- end;

--
-- Registers a meta key for terms.
--
-- @since 4.9.8
--
-- @param string taxonomy Taxonomy to register a meta key for. Pass an empty string
--                         to register the meta key across all existing taxonomies.
-- @param string meta_key The meta key to register.
-- @param array  args     Data used to describe the meta key when registered. See
--                         {@see register_meta()} for a list of supported arguments.
-- @return bool True if the meta key was successfully registered, false if not.
--
-- function register_term_meta (taxonomy, meta_key, array args) then
--         args("object_subtype") = taxonomy;

--         return register_meta ("term", meta_key, args);
-- end;

--
-- Unregisters a meta key for terms.
--
-- @since 4.9.8
--
-- @param string taxonomy Taxonomy the meta key is currently registered for. Pass
--                         an empty string if the meta key is registered across all
--                         existing taxonomies.
-- @param string meta_key The meta key to unregister.
-- @return bool True on success, false if the meta key was not previously registered.
--
-- function unregister_term_meta (taxonomy, meta_key) then
--         return unregister_meta_key ("term", meta_key, taxonomy);
-- end;

   X_Wp_Suspend_Cache_Invalidation : constant Boolean := False;

   -----------------
   -- Term_Exists --
   -----------------

   function Term_Exists (Term     : String;
                         Taxonomy : String  := "";
                         Parent   : Integer := 0) -- null
                         return Array_Type -- Integer
   is
      use Php.Strings;
      use Wp_Common;
      use Inc_Functions;
      use Inc_Plugins;

--         global _wp_suspend_cache_invalidation;
      Defaults : Array_Type := To_Array (List => (
        Build ("get",                    "all"),
        Build ("fields",                 "ids"),
        Build ("number",                 1),
        Build ("update_term_meta_cache", False),
        Build ("order",                  "ASC"),
        Build ("orderby",                "term_id"),
        Build ("suppress_filter",        True)
      ));

   begin
      -- if null === term then
      --    return null;
      -- end if;

      -- Ensure that while importing, queries are not cached.
      if X_Wp_Suspend_Cache_Invalidation then
--    if not Empty (X_Wp_Suspend_Cache_Invalidation) then
         -- @todo Disable caching once #52710 is merged.
         Set (Defaults, "cache_domain", From_String ("microtime"));
--       Defaults ("cache_domain") := Microtime;
      end if;

      if not Empty (Taxonomy) then
         Set (Defaults, "taxonomy", From_String (Taxonomy));
         Set (Defaults, "fields",   From_String ("all"));
      end if;

      --
      -- Filters default query arguments for checking if a term exists.
      --
      -- @since 6.0.0
      --
      -- @param array      defaults An array of arguments passed to get_terms().
      -- @param int|string term     The term to check. Accepts term ID, slug, or name.
      -- @param string     taxonomy The taxonomy name to use. An empty string indicates
      --                             the search is against all taxonomies.
      -- @param int|null   parent   ID of parent term under which to confine the
      --                             exists search. Null indicates the search is
      --                             unconfined.
      --
      Defaults := Apply_Filters ("term_exists_default_query_args", Defaults,
                                 Term, Taxonomy, Parent);

      declare
         use Class_Terms;
         use type Class_Terms.Wp_Term_Array;

         Args  : Array_Type;
         Terms : Wp_Term_Array; -- Array_Type;
      begin
         if False then -- Is_Int (Term) then
            -- if 0 = Term then
            --    return 0;
            -- end if;
            Args  := Wp_Parse_Args (
                       To_Array (List => (1 =>
                         Build ("include", Term))), -- To_Array (Term)))),
                       Defaults);
            Terms := Get_Terms (Args);
         else
            declare
               Term_2 : constant String := Trim (Inc_Formatting.Wp_Unslash (Term));
            begin
               if "" = Term_2 then
                  return Empty_Array; -- null;
               end if;

               if not Empty (Taxonomy) then -- and then Is_Numeric (Parent) then
                  Set (Defaults, "parent", From_Integer (Parent)); -- (int)
               end if;

               Args  :=
                 Wp_Parse_Args
                   (To_Array (List => (1 =>
                      Build ("slug", Inc_Formatting.Sanitize_Title (Term_2)))),
                    Defaults);
            end;

            Terms := Get_Terms (Args);
            if Terms = Empty_Term_Array then -- or else Is_Wp_Error (Terms) then
--          if Empty (Terms) then -- or else Is_Wp_Error (Terms) then
               Args  := Wp_Parse_Args (To_Array (List => (1 =>
                                         Build ("name", Term))),
                                       Defaults);
               Terms := Get_Terms (Args);
            end if;
         end if;

         if Terms = Empty_Term_Array then -- or else Is_Wp_Error (Terms) then
--       if Empty (Terms) then -- or else Is_Wp_Error (Terms) then
            return Empty_Array; -- null;
         end if;

--          declare
--             use Wp_Common;

--             X_Term : Wp_Term_Array := Array_Shift (Terms);
-- --          X_Term : Array_Type := Array_Shift (Terms);
--          begin
--             if not Empty (Taxonomy) then
--                return To_Array (List => (
--                        Build ("term_id",          X_Term.Term_Id),         -- (string)
--                        Build ("term_taxonomy_id", X_Term.Term_Taxonomy_Id)
--                       ));
--             end if;

--             return X_Term;  -- (string)
--          end;
         return Empty_Array;
      end;
   end Term_Exists;

--
-- Checks if a term is an ancestor of another term.
--
-- You can use either an ID or the term object for both parameters.
--
-- @since 3.4.0
--
-- @param int|object term1    ID or object to check if this is the parent term.
-- @param int|object term2    The child term.
-- @param string     taxonomy Taxonomy name that term1 and `term2` belong to.
-- @return bool Whether `term2` is a child of `term1`.
--
-- function term_is_ancestor_of (term1, term2, taxonomy) then
--         if  (! isset (term1.term_id)) then
--                 term1 = get_term (term1, taxonomy);
--         end;
--         if  (! isset (term2.parent)) then
--                 term2 = get_term (term2, taxonomy);
--         end;

--         if  (empty (term1.term_id) || empty (term2.parent)) then
--                 return false;
--         end;
--         if  (term2.parent === term1.term_id) then
--                 return true;
--         end;

--         return term_is_ancestor_of (term1, get_term (term2.parent, taxonomy), taxonomy);
-- end;

--
-- Sanitizes all term fields.
--
-- Relies on sanitize_term_field() to sanitize the term. The difference is that
-- this function will sanitize--*all** fields. The context is based
-- on sanitize_term_field().
--
-- The `term` is expected to be either an array or an object.
--
-- @since 2.3.0
--
-- @param array|object term     The term to check.
-- @param string       taxonomy The taxonomy name to use.
-- @param string       context  Optional. Context in which to sanitize the term.
--                               Accepts "raw", "edit", "db", "display", "rss",
--                               "attribute", or "js". Default "display".
-- @return array|object Term with all fields sanitized.
--
-- function sanitize_term (term, taxonomy, context = "display") then
--         fields = array ("term_id", "name", "description", "slug", "count", "parent", "term_group", "term_taxonomy_id", "object_id");

--         do_object = is_object (term);

--         term_id = do_object ? term.term_id :  (isset (term("term_id")) ? term("term_id") : 0);

--         foreach  ((array) fields as field) then
--                 if  (do_object) then
--                         if  (isset (term.field)) then
--                                 term.field = sanitize_term_field (field, term.field, term_id, taxonomy, context);
--                         end;
--                 end; else then
--                         if  (isset (term (field))) then
--                                 term (field) = sanitize_term_field (field, term (field), term_id, taxonomy, context);
--                         end;
--                 end;
--         end;

--         if  (do_object) then
--                 term.filter = context;
--         end; else then
--                 term("filter") = context;
--         end;

--         return term;
-- end;

--
-- Sanitizes the field value in the term based on the context.
--
-- Passing a term field value through the function should be assumed to have
-- cleansed the value for whatever context the term field is going to be used.
--
-- If no context or an unsupported context is given, then default filters will
-- be applied.
--
-- There are enough filters for each context to support a custom filtering
-- without creating your own filter function. Simply create a function that
-- hooks into the filter you need.
--
-- @since 2.3.0
--
-- @param string field    Term field to sanitize.
-- @param string value    Search for this term value.
-- @param int    term_id  Term ID.
-- @param string taxonomy Taxonomy name.
-- @param string context  Context in which to sanitize the term field.
--                         Accepts "raw", "edit", "db", "display", "rss",
--                         "attribute", or "js". Default "display".
-- @return mixed Sanitized field.
--
-- function sanitize_term_field (field, value, term_id, taxonomy, context) then
--         int_fields = array ("parent", "term_id", "count", "term_group", "term_taxonomy_id", "object_id");
--         if  (in_array (field, int_fields, true)) then
--                 value = (int) value;
--                 if  (value < 0) then
--                         value = 0;
--                 end;
--         end;

--         context = strtolower (context);

--         if  ("raw" === context) then
--                 return value;
--         end;

--         if  ("edit" === context) then

--                 --
--                 -- Filters a term field to edit before it is sanitized.
--                 --
--                 -- The dynamic portion of the hook name, `field`, refers to the term field.
--                 --
--                 -- @since 2.3.0
--                 --
--                 -- @param mixed value     Value of the term field.
--                 -- @param int   term_id   Term ID.
--                 -- @param string taxonomy Taxonomy slug.
--                 --
--                 value = apply_filters ("edit_term_thenfieldend;", value, term_id, taxonomy);

--                 --
--                 -- Filters the taxonomy field to edit before it is sanitized.
--                 --
--                 -- The dynamic portions of the filter name, `taxonomy` and `field`, refer
--                 -- to the taxonomy slug and taxonomy field, respectively.
--                 --
--                 -- @since 2.3.0
--                 --
--                 -- @param mixed value   Value of the taxonomy field to edit.
--                 -- @param int   term_id Term ID.
--                 --
--                 value = apply_filters ("edit_thentaxonomyend;_thenfieldend;", value, term_id);

--                 if  ("description" === field) then
--                         value = esc_html (value); // textarea_escaped
--                 end; else then
--                         value = esc_attr (value);
--                 end;
--         end; elseif  ("db" === context) then

--                 --
--                 -- Filters a term field value before it is sanitized.
--                 --
--                 -- The dynamic portion of the hook name, `field`, refers to the term field.
--                 --
--                 -- @since 2.3.0
--                 --
--                 -- @param mixed  value    Value of the term field.
--                 -- @param string taxonomy Taxonomy slug.
--                 --
--                 value = apply_filters ("pre_term_thenfieldend;", value, taxonomy);

--                 --
--                 -- Filters a taxonomy field before it is sanitized.
--                 --
--                 -- The dynamic portions of the filter name, `taxonomy` and `field`, refer
--                 -- to the taxonomy slug and field name, respectively.
--                 --
--                 -- @since 2.3.0
--                 --
--                 -- @param mixed value Value of the taxonomy field.
--                 --
--                 value = apply_filters ("pre_thentaxonomyend;_thenfieldend;", value);

--                 // Back compat filters.
--                 if  ("slug" === field) then
--                         --
--                         -- Filters the category nicename before it is sanitized.
--                         --
--                         -- Use the {@see "pre_taxonomy_field"} hook instead.
--                         --
--                         -- @since 2.0.3
--                         --
--                         -- @param string value The category nicename.
--                         --
--                         value = apply_filters ("pre_category_nicename", value);
--                 end;
--         end; elseif  ("rss" === context) then

--                 --
--                 -- Filters the term field for use in RSS.
--                 --
--                 -- The dynamic portion of the hook name, `field`, refers to the term field.
--                 --
--                 -- @since 2.3.0
--                 --
--                 -- @param mixed  value    Value of the term field.
--                 -- @param string taxonomy Taxonomy slug.
--                 --
--                 value = apply_filters ("term_thenfieldend;_rss", value, taxonomy);

--                 --
--                 -- Filters the taxonomy field for use in RSS.
--                 --
--                 -- The dynamic portions of the hook name, `taxonomy`, and `field`, refer
--                 -- to the taxonomy slug and field name, respectively.
--                 --
--                 -- @since 2.3.0
--                 --
--                 -- @param mixed value Value of the taxonomy field.
--                 --
--                 value = apply_filters ("thentaxonomyend;_thenfieldend;_rss", value);
--         end; else then
--                 // Use display filters by default.

--                 --
--                 -- Filters the term field sanitized for display.
--                 --
--                 -- The dynamic portion of the hook name, `field`, refers to the term field name.
--                 --
--                 -- @since 2.3.0
--                 --
--                 -- @param mixed  value    Value of the term field.
--                 -- @param int    term_id  Term ID.
--                 -- @param string taxonomy Taxonomy slug.
--                 -- @param string context  Context to retrieve the term field value.
--                 --
--                 value = apply_filters ("term_thenfieldend;", value, term_id, taxonomy, context);

--                 --
--                 -- Filters the taxonomy field sanitized for display.
--                 --
--                 -- The dynamic portions of the filter name, `taxonomy`, and `field`, refer
--                 -- to the taxonomy slug and taxonomy field, respectively.
--                 --
--                 -- @since 2.3.0
--                 --
--                 -- @param mixed  value   Value of the taxonomy field.
--                 -- @param int    term_id Term ID.
--                 -- @param string context Context to retrieve the taxonomy field value.
--                 --
--                 value = apply_filters ("thentaxonomyend;_thenfieldend;", value, term_id, context);
--         end;

--         if  ("attribute" === context) then
--                 value = esc_attr (value);
--         end; elseif  ("js" === context) then
--                 value = esc_js (value);
--         end;

--         // Restore the type for integer fields after esc_attr().
--         if  (in_array (field, int_fields, true)) then
--                 value = (int) value;
--         end;

--         return value;
-- end;

--
-- Counts how many terms are in taxonomy.
--
-- Default args is "hide_empty" which can be "hide_empty=true" or array("hide_empty" => true).
--
-- @since 2.3.0
-- @since 5.6.0 Changed the function signature so that the `args` array can be provided as the first parameter.
--
-- @internal The `deprecated` parameter is parsed for backward compatibility only.
--
-- @param array|string args       Optional. Array or string of arguments. See WP_Term_Query::__construct()
--                                 for information on accepted arguments. Default empty array.
-- @param array|string deprecated Optional. Argument array, when using the legacy function parameter format.
--                                 If present, this parameter will be interpreted as `args`, and the first
--                                 function parameter will be parsed as a taxonomy or array of taxonomies.
--                                 Default empty.
-- @return string|WP_Error Numeric string containing the number of terms in that
--                         taxonomy or WP_Error if the taxonomy does not exist.
--
-- function wp_count_terms (args = array(), deprecated = "") then
--         use_legacy_args = false;

--         // Check whether function is used with legacy signature: `taxonomy` and `args`.
--         if  (args
--                 &&  (is_string (args) && taxonomy_exists (args)
--                         || is_array (args) && wp_is_numeric_array (args))
--        ) then
--                 use_legacy_args = true;
--         end;

--         defaults = array ("hide_empty" => false);

--         if  (use_legacy_args) then
--                 defaults("taxonomy") = args;
--                 args                 = deprecated;
--         end;

--         args = wp_parse_args (args, defaults);

--         // Backward compatibility.
--         if  (isset (args("ignore_empty"))) then
--                 args("hide_empty") = args("ignore_empty");
--                 unset (args("ignore_empty"));
--         end;

--         args("fields") = "count";

--         return get_terms (args);
-- end;

--
-- Unlinks the object from the taxonomy or taxonomies.
--
-- Will remove all relationships between the object and any terms in
-- a particular taxonomy or taxonomies. Does not remove the term or
-- taxonomy itself.
--
-- @since 2.3.0
--
-- @param int          object_id  The term object ID that refers to the term.
-- @param string|array taxonomies List of taxonomy names or single taxonomy name.
--
-- function wp_delete_object_term_relationships (object_id, taxonomies) then
--         object_id = (int) object_id;

--         if  (! is_array (taxonomies)) then
--                 taxonomies = array (taxonomies);
--         end;

--         foreach  ((array) taxonomies as taxonomy) then
--                 term_ids = wp_get_object_terms (object_id, taxonomy, array ("fields" => "ids"));
--                 term_ids = array_map ("intval", term_ids);
--                 wp_remove_object_terms (object_id, term_ids, taxonomy);
--         end;
-- end;

--
-- Removes a term from the database.
--
-- If the term is a parent of other terms, then the children will be updated to
-- that term"s parent.
--
-- Metadata associated with the term will be deleted.
--
-- @since 2.3.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int          term     Term ID.
-- @param string       taxonomy Taxonomy name.
-- @param array|string args {
--     Optional. Array of arguments to override the default term ID. Default empty array.
--
--     @type int  default       The term ID to make the default term. This will only override
--                               the terms found if there is only one term found. Any other and
--                               the found terms are used.
--     @type bool force_default Optional. Whether to force the supplied term as default to be
--                               assigned even if the object was not going to be term-less.
--                               Default false.
-- }
-- @return bool|int|WP_Error True on success, false if term does not exist. Zero on attempted
--                           deletion of default Category. WP_Error if the taxonomy does not exist.
--
-- function wp_delete_term (term, taxonomy, args = array()) then
--         global wpdb;

--         term = (int) term;

--         ids = term_exists (term, taxonomy);
--         if  (! ids) then
--                 return false;
--         end;
--         if  (is_wp_error (ids)) then
--                 return ids;
--         end;

--         tt_id = ids("term_taxonomy_id");

--         defaults = array();

--         if  ("category" === taxonomy) then
--                 defaults("default") = (int) get_option ("default_category");
--                 if  (defaults("default") === term) then
--                         return 0; // Don"t delete the default category.
--                 end;
--         end;

--         // Don"t delete the default custom taxonomy term.
--         taxonomy_object = get_taxonomy (taxonomy);
--         if  (! empty (taxonomy_object.default_term)) then
--                 defaults("default") = (int) get_option ("default_term_" . taxonomy);
--                 if  (defaults("default") === term) then
--                         return 0;
--                 end;
--         end;

--         args = wp_parse_args (args, defaults);

--         if  (isset (args("default"))) then
--                 default = (int) args("default");
--                 if  (! term_exists (default, taxonomy)) then
--                         unset (default);
--                 end;
--         end;

--         if  (isset (args("force_default"))) then
--                 force_default = args("force_default");
--         end;

--         --
--         -- Fires when deleting a term, before any modifications are made to posts or terms.
--         --
--         -- @since 4.1.0
--         --
--         -- @param int    term     Term ID.
--         -- @param string taxonomy Taxonomy name.
--         --
--         do_action ("pre_delete_term", term, taxonomy);

--         // Update children to point to new parent.
--         if  (is_taxonomy_hierarchical (taxonomy)) then
--                 term_obj = get_term (term, taxonomy);
--                 if  (is_wp_error (term_obj)) then
--                         return term_obj;
--                 end;
--                 parent = term_obj.parent;

--                 edit_ids    = wpdb.get_results ("SELECT term_id, term_taxonomy_id FROM wpdb.term_taxonomy WHERE `parent` = " . (int) term_obj.term_id);
--                 edit_tt_ids = wp_list_pluck (edit_ids, "term_taxonomy_id");

--                 --
--                 -- Fires immediately before a term to delete"s children are reassigned a parent.
--                 --
--                 -- @since 2.9.0
--                 --
--                 -- @param array edit_tt_ids An array of term taxonomy IDs for the given term.
--                 --
--                 do_action ("edit_term_taxonomies", edit_tt_ids);

--                 wpdb.update (wpdb.term_taxonomy, compact ("parent"), array ("parent" => term_obj.term_id) + compact ("taxonomy"));

--                 // Clean the cache for all child terms.
--                 edit_term_ids = wp_list_pluck (edit_ids, "term_id");
--                 clean_term_cache (edit_term_ids, taxonomy);

--                 --
--                 -- Fires immediately after a term to delete"s children are reassigned a parent.
--                 --
--                 -- @since 2.9.0
--                 --
--                 -- @param array edit_tt_ids An array of term taxonomy IDs for the given term.
--                 --
--                 do_action ("edited_term_taxonomies", edit_tt_ids);
--         end;

--         // Get the term before deleting it or its term relationships so we can pass to actions below.
--         deleted_term = get_term (term, taxonomy);

--         object_ids = (array) wpdb.get_col (wpdb.prepare ("SELECT object_id FROM wpdb.term_relationships WHERE term_taxonomy_id = %d", tt_id));

--         foreach  (object_ids as object_id) then
--                 if  (! isset (default)) then
--                         wp_remove_object_terms (object_id, term, taxonomy);
--                         continue;
--                 end;

--                 terms = wp_get_object_terms(
--                         object_id,
--                         taxonomy,
--                         array(
--                                 "fields"  => "ids",
--                                 "orderby" => "none",
--                        )
--                );

--                 if  (1 === count (terms) && isset (default)) then
--                         terms = array (default);
--                 end; else then
--                         terms = array_diff (terms, array (term));
--                         if  (isset (default) && isset (force_default) && force_default) then
--                                 terms = array_merge (terms, array (default));
--                         end;
--                 end;

--                 terms = array_map ("intval", terms);
--                 wp_set_object_terms (object_id, terms, taxonomy);
--         end;

--         // Clean the relationship caches for all object types using this term.
--         tax_object = get_taxonomy (taxonomy);
--         foreach  (tax_object.object_type as object_type) then
--                 clean_object_term_cache (object_ids, object_type);
--         end;

--         term_meta_ids = wpdb.get_col (wpdb.prepare ("SELECT meta_id FROM wpdb.termmeta WHERE term_id = %d ", term));
--         foreach  (term_meta_ids as mid) then
--                 delete_metadata_by_mid ("term", mid);
--         end;

--         --
--         -- Fires immediately before a term taxonomy ID is deleted.
--         --
--         -- @since 2.9.0
--         --
--         -- @param int tt_id Term taxonomy ID.
--         --
--         do_action ("delete_term_taxonomy", tt_id);

--         wpdb.delete (wpdb.term_taxonomy, array ("term_taxonomy_id" => tt_id));

--         --
--         -- Fires immediately after a term taxonomy ID is deleted.
--         --
--         -- @since 2.9.0
--         --
--         -- @param int tt_id Term taxonomy ID.
--         --
--         do_action ("deleted_term_taxonomy", tt_id);

--         // Delete the term if no taxonomies use it.
--         if  (! wpdb.get_var (wpdb.prepare ("SELECT COUNT(*) FROM wpdb.term_taxonomy WHERE term_id = %d", term))) then
--                 wpdb.delete (wpdb.terms, array ("term_id" => term));
--         end;

--         clean_term_cache (term, taxonomy);

--         --
--         -- Fires after a term is deleted from the database and the cache is cleaned.
--         --
--         -- The {@see "delete_taxonomy"} hook is also available for targeting a specific
--         -- taxonomy.
--         --
--         -- @since 2.5.0
--         -- @since 4.5.0 Introduced the `object_ids` argument.
--         --
--         -- @param int     term         Term ID.
--         -- @param int     tt_id        Term taxonomy ID.
--         -- @param string  taxonomy     Taxonomy slug.
--         -- @param WP_Term deleted_term Copy of the already-deleted term.
--         -- @param array   object_ids   List of term object IDs.
--         --
--         do_action ("delete_term", term, tt_id, taxonomy, deleted_term, object_ids);

--         --
--         -- Fires after a term in a specific taxonomy is deleted.
--         --
--         -- The dynamic portion of the hook name, `taxonomy`, refers to the specific
--         -- taxonomy the term belonged to.
--         --
--         -- Possible hook names include:
--         --
--         --  - `delete_category`
--         --  - `delete_post_tag`
--         --
--         -- @since 2.3.0
--         -- @since 4.5.0 Introduced the `object_ids` argument.
--         --
--         -- @param int     term         Term ID.
--         -- @param int     tt_id        Term taxonomy ID.
--         -- @param WP_Term deleted_term Copy of the already-deleted term.
--         -- @param array   object_ids   List of term object IDs.
--         --
--         do_action ("delete_thentaxonomyend;", term, tt_id, deleted_term, object_ids);

--         return true;
-- end;

--
-- Deletes one existing category.
--
-- @since 2.0.0
--
-- @param int cat_ID Category term ID.
-- @return bool|int|WP_Error Returns true if completes delete action; false if term doesn"t exist;
--                           Zero on attempted deletion of default Category; WP_Error object is
--                           also a possibility.
--
-- function wp_delete_category (cat_ID) then
--         return wp_delete_term (cat_ID, "category");
-- end;

--
-- Retrieves the terms associated with the given object(s), in the supplied taxonomies.
--
-- @since 2.3.0
-- @since 4.2.0 Added support for "taxonomy", "parent", and "term_taxonomy_id" values of `orderby`.
--              Introduced `parent` argument.
-- @since 4.4.0 Introduced `meta_query` and `update_term_meta_cache` arguments. When `fields` is "all" or
--              "all_with_object_id", an array of `WP_Term` objects will be returned.
-- @since 4.7.0 Refactored to use WP_Term_Query, and to support any WP_Term_Query arguments.
--
-- @param int|int()       object_ids The ID(s) of the object(s) to retrieve.
-- @param string|string() taxonomies The taxonomy names to retrieve terms from.
-- @param array|string    args       See WP_Term_Query::__construct() for supported arguments.
-- @return WP_Term()|int()|string()|string|WP_Error Array of terms, a count thereof as a numeric string,
--                                                  or WP_Error if any of the taxonomies do not exist.
--                                                  See WP_Term_Query::get_terms() for more information.
--
-- function wp_get_object_terms (object_ids, taxonomies, args = array()) then

   function Wp_Get_Object_Terms (Object_Ids : Integer_Array;
                                 Taxonomies : Array_Type; -- String_Array;
                                 Args       : Array_Type := Empty_Array)
                                 return Class_Terms.Wp_Term_Array
   is
      use Ada.Containers;
      use Php.Arrays;
      use Php.Lists;
      use Php.Strings;
      use Php.Types;
      use Wp_Common;
--    use Adi_Templates;
      use Class_Terms;
      use Inc_Formatting;
      use Integer_Vectors;

      Object_Ids_3 : List_Type;
   begin
      if Length (Object_Ids) = 0 or else Length (Taxonomies) in 0 then
         return Empty_Term_Array;  -- )Inc_Taxonomys.Empty_Term_Array;
      end if;

--        if  (! is_array (taxonomies)) then
--                taxonomies = array (taxonomies);
--        end;

      for A in Taxonomies.Iterate loop
         declare
            Taxonomy : constant String := Get_As_String (Taxonomies, Key (A));
         begin
            if not Taxonomy_Exists (Taxonomy) then
               return Empty_Term_Array;
--            return new Wp_Error ("invalid_taxonomy",
--                                 abs "Invalid taxonomy.");
            end if;
         end;
      end loop;

--        if  (! is_array (object_ids)) then
--                object_ids = array (object_ids);
--        end;

      for Id of Object_Ids loop
         Append (Object_Ids_3, Helpers.Image (Id));
      end loop;

      declare
         use Php.Numerics;
         use Inc_Functions;

         Object_Ids_2 : constant List_Type  := List_Map (Intval'Access, Object_Ids_3);
         Args_2       : constant Array_Type := Wp_Parse_Args (Args);
         Taxonomies_2 : constant Array_Type := Taxonomies;

         --
         -- Filters arguments for retrieving object terms.
         --
         -- @since 4.9.0
         --
         -- @param array    args       An array of arguments for retrieving terms for
         --                             the given object(s).
         --                             See {@see wp_get_object_terms()} for details.
         -- @param int()    object_ids Array of object IDs.
         -- @param string() taxonomies Array of taxonomy names to retrieve terms from.
         --
         Args_3 : Array_Type :=
           Apply_Filters ("wp_get_object_terms_args", Args_2,
                          Object_Ids_2, Taxonomies_2);

         --
         -- When one or more queried taxonomies is registered with an "args" array,
         -- those params override the `args` passed to this function.
         --
         Terms : Wp_Term_Array;
         T     : Class_Taxonomy.Wp_Taxonomy;
      begin
         if Taxonomies_2.Length > 1 then
            for X in Taxonomies_2.Iterate loop
               declare
                  Index : constant String := Key (X);

                  Taxonomy : constant String :=
                    Get_As_String (Taxonomies_2, Index);
               begin
                  T := Get_Taxonomy (Taxonomy);
                  if
                    T.Args /= Empty_Array and then
--                     Isset (T.Args) and then
                    Is_Array (T.Args) and then
                    Array_Merge (Args, T.Args) /= Args
                  then
                     Delete (Ref (Taxonomies, Index));
--                      Unset (Taxonomies (Index));
--                        Terms := Terms &
--                                 Wp_Get_Object_Terms (Object_Ids_2, Taxonomy,
--                                                      Args & T.Args);
--                        Terms := Array_Merge (Terms,
--                                    Wp_Get_Object_Terms (Object_Ids_2, Taxonomy,
--                                            Array_Merge (Args, T.Args)));
                        null;
                  end if;
               end;
            end loop;
         else
            T := Get_Taxonomy (Taxonomies_2.First_Key); --  (1).Key);    -- 0
            if
              T.Args /= Empty_Array -- and then
--               Isset (T.Args) and then
--               Is_Array (T.Args)
            then
               Args_3 := Array_Merge (Args, T.Args);
            end if;
         end if;

         Set (Args_3, "taxonomy",   From_Array (Taxonomies_2));
         Set (Args_3, "object_ids", From_List (Object_Ids_2));

         declare
            use Class_Terms.Term_Vectors;

            Terms_From_Remaining_Taxonomies : Wp_Term_Array := Get_Terms (Args);
         begin
            -- Taxonomies registered without an "args" param are handled here.
            if not Empty (Taxonomies_2) then
               Terms_From_Remaining_Taxonomies := Get_Terms (Args);

               -- Array keys should be preserved for values of fields that use
               -- term_id for keys.
               if
                 not Empty (Get_As_String (Args_3, "fields")) and then
                 0 = Strpos (As_String  (Get (Args_3, "fields")), "id=>")
               then
                  Terms := Terms & Terms_From_Remaining_Taxonomies;
               else
                  Terms := Terms & Terms_From_Remaining_Taxonomies;
               end if;
            end if;
         end;
         --
         -- Filters the terms for a given object or objects.
         --
         -- @since 4.2.0
         --
         -- @param WP_Term()|int()|string()|string terms
         --                   Array of terms or a count thereof as a numeric string.
         -- @param int()      object_ids Array of object IDs for which terms were
         --                               retrieved.
         -- @param string()   taxonomies Array of taxonomy names from which terms were
         --                               retrieved.
         -- @param array      args       Array of arguments for retrieving terms for
         --                               the given object(s). See
         --                               wp_get_object_terms() for details.
         --
         Terms := Apply_Filters ("get_object_terms", Terms,
                                 Object_Ids_2, Taxonomies_2, Args_3);
         declare
            Object_Ids_3 : constant String := Implode (",", Object_Ids_2);
            Taxonomies_3 : constant String
               := """" &
                  Implode (", ", Array_Type'(Array_Map (ESC_SQL'Access,
                                                        Taxonomies_2))) &
                  """";
         begin
            --
            -- Filters the terms for a given object or objects.
            --
            -- The `taxonomies` parameter passed to this filter is formatted as a SQL
            -- fragment. The {@see "get_object_terms"} filter is recommended as an
            -- alternative.
            --
            -- @since 2.8.0
            --
            -- @param WP_Term()|int()|string()|string terms
            --                  Array of terms or a count thereof as a numeric string.
            -- @param string    object_ids Comma separated list of object IDs for
            --                              which terms were retrieved.
            -- @param string    taxonomies SQL fragment of taxonomy names from which
            --                              terms were retrieved.
            -- @param array     args       Array of arguments for retrieving terms for
            --                              the given object(s). See
            --                              wp_get_object_terms() for details.
            --
            return Apply_Filters ("wp_get_object_terms", Terms,
                                  Object_Ids_3, Taxonomies_3, Args_3);
         end;
      end;
   end Wp_Get_Object_Terms;

--
-- Adds a new term to the database.
--
-- A non-existent term is inserted in the following sequence:
-- 1. The term is added to the term table, then related to the taxonomy.
-- 2. If everything is correct, several actions are fired.
-- 3. The "term_id_filter" is evaluated.
-- 4. The term cache is cleaned.
-- 5. Several more actions are fired.
-- 6. An array is returned containing the `term_id` and `term_taxonomy_id`.
--
-- If the "slug" argument is not empty, then it is checked to see if the term
-- is invalid. If it is not a valid, existing term, it is added and the term_id
-- is given.
--
-- If the taxonomy is hierarchical, and the "parent" argument is not empty,
-- the term is inserted and the term_id will be given.
--
-- Error handling:
-- If `taxonomy` does not exist or `term` is empty,
-- a WP_Error object will be returned.
--
-- If the term already exists on the same hierarchical level,
-- or the term slug and name are not unique, a WP_Error object will be returned.
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @since 2.3.0
--
-- @param string       term     The term name to add.
-- @param string       taxonomy The taxonomy to which to add the term.
-- @param array|string args then
--     Optional. Array or query string of arguments for inserting a term.
--
--     @type string alias_of    Slug of the term to make this term an alias of.
--                               Default empty string. Accepts a term slug.
--     @type string description The term description. Default empty string.
--     @type int    parent      The id of the parent term. Default 0.
--     @type string slug        The term slug to use. Default empty string.
-- end;
-- @return array|WP_Error then
--     An array of the new term data, WP_Error otherwise.
--
--     @type int        term_id          The new term ID.
--     @type int|string term_taxonomy_id The new term taxonomy ID. Can be a numeric string.
-- end;
--
-- function wp_insert_term (term, taxonomy, args = array()) then
--         global wpdb;

--         if  (! taxonomy_exists (taxonomy)) then
--                 return new WP_Error ("invalid_taxonomy", __ ("Invalid taxonomy."));
--         end;

--         --
--         -- Filters a term before it is sanitized and inserted into the database.
--         --
--         -- @since 3.0.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param string|WP_Error term     The term name to add, or a WP_Error object if there"s an error.
--         -- @param string          taxonomy Taxonomy slug.
--         -- @param array|string    args     Array or query string of arguments passed to wp_insert_term().
--         --
--         term = apply_filters ("pre_insert_term", term, taxonomy, args);

--         if  (is_wp_error (term)) then
--                 return term;
--         end;

--         if  (is_int (term) && 0 === term) then
--                 return new WP_Error ("invalid_term_id", __ ("Invalid term ID."));
--         end;

--         if  ("" === trim (term)) then
--                 return new WP_Error ("empty_term_name", __ ("A name is required for this term."));
--         end;

--         defaults = array(
--                 "alias_of"    => "",
--                 "description" => "",
--                 "parent"      => 0,
--                 "slug"        => "",
--        );
--         args     = wp_parse_args (args, defaults);

--         if  ((int) args("parent") > 0 && ! term_exists ((int) args("parent"))) then
--                 return new WP_Error ("missing_parent", __ ("Parent term does not exist."));
--         end;

--         args("name")     = term;
--         args("taxonomy") = taxonomy;

--         // Coerce null description to strings, to avoid database errors.
--         args("description") = (string) args("description");

--         args = sanitize_term (args, taxonomy, "db");

--         // expected_slashed (name)
--         name        = wp_unslash (args("name"));
--         description = wp_unslash (args("description"));
--         parent      = (int) args("parent");

--         slug_provided = ! empty (args("slug"));
--         if  (! slug_provided) then
--                 slug = sanitize_title (name);
--         end; else then
--                 slug = args("slug");
--         end;

--         term_group = 0;
--         if  (args("alias_of")) then
--                 alias = get_term_by ("slug", args("alias_of"), taxonomy);
--                 if  (! empty (alias.term_group)) then
--                         // The alias we want is already in a group, so let"s use that one.
--                         term_group = alias.term_group;
--                 end; elseif  (! empty (alias.term_id)) then
--                         /*
--                         -- The alias is not in a group, so we create a new one
--                         -- and add the alias to it.
--                         --
--                         term_group = wpdb.get_var ("SELECT MAX(term_group) FROM wpdb.terms") + 1;

--                         wp_update_term(
--                                 alias.term_id,
--                                 taxonomy,
--                                 array(
--                                         "term_group" => term_group,
--                                )
--                        );
--                 end;
--         end;

--         /*
--         -- Prevent the creation of terms with duplicate names at the same level of a taxonomy hierarchy,
--         -- unless a unique slug has been explicitly provided.
--         --
--         name_matches = get_terms(
--                 array(
--                         "taxonomy"               => taxonomy,
--                         "name"                   => name,
--                         "hide_empty"             => false,
--                         "parent"                 => args("parent"),
--                         "update_term_meta_cache" => false,
--                )
--        );

--         /*
--         -- The `name` match in `get_terms()` doesn"t differentiate accented characters,
--         -- so we do a stricter comparison here.
--         --
--         name_match = null;
--         if  (name_matches) then
--                 foreach  (name_matches as _match) then
--                         if  (strtolower (name) === strtolower (_match.name)) then
--                                 name_match = _match;
--                                 break;
--                         end;
--                 end;
--         end;

--         if  (name_match) then
--                 slug_match = get_term_by ("slug", slug, taxonomy);
--                 if  (! slug_provided || name_match.slug === slug || slug_match) then
--                         if  (is_taxonomy_hierarchical (taxonomy)) then
--                                 siblings = get_terms(
--                                         array(
--                                                 "taxonomy"               => taxonomy,
--                                                 "get"                    => "all",
--                                                 "parent"                 => parent,
--                                                 "update_term_meta_cache" => false,
--                                        )
--                                );

--                                 existing_term = null;
--                                 sibling_names = wp_list_pluck (siblings, "name");
--                                 sibling_slugs = wp_list_pluck (siblings, "slug");

--                                 if  ( (! slug_provided || name_match.slug === slug) && in_array (name, sibling_names, true)) then
--                                         existing_term = name_match;
--                                 end; elseif  (slug_match && in_array (slug, sibling_slugs, true)) then
--                                         existing_term = slug_match;
--                                 end;

--                                 if  (existing_term) then
--                                         return new WP_Error ("term_exists", __ ("A term with the name provided already exists with this parent."), existing_term.term_id);
--                                 end;
--                         end; else then
--                                 return new WP_Error ("term_exists", __ ("A term with the name provided already exists in this taxonomy."), name_match.term_id);
--                         end;
--                 end;
--         end;

--         slug = wp_unique_term_slug (slug, (object) args);

--         data = compact ("name", "slug", "term_group");

--         --
--         -- Filters term data before it is inserted into the database.
--         --
--         -- @since 4.7.0
--         --
--         -- @param array  data     Term data to be inserted.
--         -- @param string taxonomy Taxonomy slug.
--         -- @param array  args     Arguments passed to wp_insert_term().
--         --
--         data = apply_filters ("wp_insert_term_data", data, taxonomy, args);

--         if  (false === wpdb.insert (wpdb.terms, data)) then
--                 return new WP_Error ("db_insert_error", __ ("Could not insert term into the database."), wpdb.last_error);
--         end;

--         term_id = (int) wpdb.insert_id;

--         // Seems unreachable. However, is used in the case that a term name is provided, which sanitizes to an empty string.
--         if  (empty (slug)) then
--                 slug = sanitize_title (slug, term_id);

--                 -- This action is documented in wp-includes/taxonomy.php--
--                 do_action ("edit_terms", term_id, taxonomy);
--                 wpdb.update (wpdb.terms, compact ("slug"), compact ("term_id"));

--                 -- This action is documented in wp-includes/taxonomy.php--
--                 do_action ("edited_terms", term_id, taxonomy);
--         end;

--         tt_id = wpdb.get_var (wpdb.prepare ("SELECT tt.term_taxonomy_id FROM wpdb.term_taxonomy AS tt INNER JOIN wpdb.terms AS t ON tt.term_id = t.term_id WHERE tt.taxonomy = %s AND t.term_id = %d", taxonomy, term_id));

--         if  (! empty (tt_id)) then
--                 return array(
--                         "term_id"          => term_id,
--                         "term_taxonomy_id" => tt_id,
--                );
--         end;

--         if  (false === wpdb.insert (wpdb.term_taxonomy, compact ("term_id", "taxonomy", "description", "parent") + array ("count" => 0))) then
--                 return new WP_Error ("db_insert_error", __ ("Could not insert term taxonomy into the database."), wpdb.last_error);
--         end;

--         tt_id = (int) wpdb.insert_id;

--         /*
--         -- Sanity check: if we just created a term with the same parent + taxonomy + slug but a higher term_id than
--         -- an existing term, then we have unwittingly created a duplicate term. Delete the dupe, and use the term_id
--         -- and term_taxonomy_id of the older term instead. Then return out of the function so that the "create" hooks
--         -- are not fired.
--         --
--         duplicate_term = wpdb.get_row (wpdb.prepare ("SELECT t.term_id, t.slug, tt.term_taxonomy_id, tt.taxonomy FROM wpdb.terms AS t INNER JOIN wpdb.term_taxonomy AS tt ON  (tt.term_id = t.term_id) WHERE t.slug = %s AND tt.parent = %d AND tt.taxonomy = %s AND t.term_id < %d AND tt.term_taxonomy_id != %d", slug, parent, taxonomy, term_id, tt_id));

--         --
--         -- Filters the duplicate term check that takes place during term creation.
--         --
--         -- Term parent + taxonomy + slug combinations are meant to be unique, and wp_insert_term()
--         -- performs a last-minute confirmation of this uniqueness before allowing a new term
--         -- to be created. Plugins with different uniqueness requirements may use this filter
--         -- to bypass or modify the duplicate-term check.
--         --
--         -- @since 5.1.0
--         --
--         -- @param object duplicate_term Duplicate term row from terms table, if found.
--         -- @param string term           Term being inserted.
--         -- @param string taxonomy       Taxonomy name.
--         -- @param array  args           Arguments passed to wp_insert_term().
--         -- @param int    tt_id          term_taxonomy_id for the newly created term.
--         --
--         duplicate_term = apply_filters ("wp_insert_term_duplicate_term_check", duplicate_term, term, taxonomy, args, tt_id);

--         if  (duplicate_term) then
--                 wpdb.delete (wpdb.terms, array ("term_id" => term_id));
--                 wpdb.delete (wpdb.term_taxonomy, array ("term_taxonomy_id" => tt_id));

--                 term_id = (int) duplicate_term.term_id;
--                 tt_id   = (int) duplicate_term.term_taxonomy_id;

--                 clean_term_cache (term_id, taxonomy);
--                 return array(
--                         "term_id"          => term_id,
--                         "term_taxonomy_id" => tt_id,
--                );
--         end;

--         --
--         -- Fires immediately after a new term is created, before the term cache is cleaned.
--         --
--         -- The {@see "create_taxonomy"} hook is also available for targeting a specific
--         -- taxonomy.
--         --
--         -- @since 2.3.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int    term_id  Term ID.
--         -- @param int    tt_id    Term taxonomy ID.
--         -- @param string taxonomy Taxonomy slug.
--         -- @param array  args     Arguments passed to wp_insert_term().
--         --
--         do_action ("create_term", term_id, tt_id, taxonomy, args);

--         --
--         -- Fires after a new term is created for a specific taxonomy.
--         --
--         -- The dynamic portion of the hook name, `taxonomy`, refers
--         -- to the slug of the taxonomy the term was created for.
--         --
--         -- Possible hook names include:
--         --
--         --  - `create_category`
--         --  - `create_post_tag`
--         --
--         -- @since 2.3.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int   term_id Term ID.
--         -- @param int   tt_id   Term taxonomy ID.
--         -- @param array args    Arguments passed to wp_insert_term().
--         --
--         do_action ("create_thentaxonomyend;", term_id, tt_id, args);

--         --
--         -- Filters the term ID after a new term is created.
--         --
--         -- @since 2.3.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int   term_id Term ID.
--         -- @param int   tt_id   Term taxonomy ID.
--         -- @param array args    Arguments passed to wp_insert_term().
--         --
--         term_id = apply_filters ("term_id_filter", term_id, tt_id, args);

--         clean_term_cache (term_id, taxonomy);

--         --
--         -- Fires after a new term is created, and after the term cache has been cleaned.
--         --
--         -- The {@see "created_taxonomy"} hook is also available for targeting a specific
--         -- taxonomy.
--         --
--         -- @since 2.3.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int    term_id  Term ID.
--         -- @param int    tt_id    Term taxonomy ID.
--         -- @param string taxonomy Taxonomy slug.
--         -- @param array  args     Arguments passed to wp_insert_term().
--         --
--         do_action ("created_term", term_id, tt_id, taxonomy, args);

--         --
--         -- Fires after a new term in a specific taxonomy is created, and after the term
--         -- cache has been cleaned.
--         --
--         -- The dynamic portion of the hook name, `taxonomy`, refers to the taxonomy slug.
--         --
--         -- Possible hook names include:
--         --
--         --  - `created_category`
--         --  - `created_post_tag`
--         --
--         -- @since 2.3.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int   term_id Term ID.
--         -- @param int   tt_id   Term taxonomy ID.
--         -- @param array args    Arguments passed to wp_insert_term().
--         --
--         do_action ("created_thentaxonomyend;", term_id, tt_id, args);

--         --
--         -- Fires after a term has been saved, and the term cache has been cleared.
--         --
--         -- The {@see "saved_taxonomy"} hook is also available for targeting a specific
--         -- taxonomy.
--         --
--         -- @since 5.5.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int    term_id  Term ID.
--         -- @param int    tt_id    Term taxonomy ID.
--         -- @param string taxonomy Taxonomy slug.
--         -- @param bool   update   Whether this is an existing term being updated.
--         -- @param array  args     Arguments passed to wp_insert_term().
--         --
--         do_action ("saved_term", term_id, tt_id, taxonomy, false, args);

--         --
--         -- Fires after a term in a specific taxonomy has been saved, and the term
--         -- cache has been cleared.
--         --
--         -- The dynamic portion of the hook name, `taxonomy`, refers to the taxonomy slug.
--         --
--         -- Possible hook names include:
--         --
--         --  - `saved_category`
--         --  - `saved_post_tag`
--         --
--         -- @since 5.5.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int   term_id Term ID.
--         -- @param int   tt_id   Term taxonomy ID.
--         -- @param bool  update  Whether this is an existing term being updated.
--         -- @param array args    Arguments passed to wp_insert_term().
--         --
--         do_action ("saved_thentaxonomyend;", term_id, tt_id, false, args);

--         return array(
--                 "term_id"          => term_id,
--                 "term_taxonomy_id" => tt_id,
--        );
-- end;

--
-- Creates term and taxonomy relationships.
--
-- Relates an object (post, link, etc.) to a term and taxonomy type. Creates the
-- term and taxonomy relationship if it doesn"t already exist. Creates a term if
-- it doesn"t exist (using the slug).
--
-- A relationship means that the term is grouped in or belongs to the taxonomy.
-- A term has no meaning until it is given context by defining which taxonomy it
-- exists under.
--
-- @since 2.3.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int              object_id The object to relate to.
-- @param string|int|array terms     A single term slug, single term ID, or array of either term slugs or IDs.
--                                    Will replace all existing related terms in this taxonomy. Passing an
--                                    empty value will remove all related terms.
-- @param string           taxonomy  The context in which to relate the term to the object.
-- @param bool             append    Optional. If false will delete difference of terms. Default false.
-- @return array|WP_Error Term taxonomy IDs of the affected terms or WP_Error on failure.
--
-- function wp_set_object_terms (object_id, terms, taxonomy, append = false) then
--         global wpdb;

--         object_id = (int) object_id;

--         if  (! taxonomy_exists (taxonomy)) then
--                 return new WP_Error ("invalid_taxonomy", __ ("Invalid taxonomy."));
--         end;

--         if  (! is_array (terms)) then
--                 terms = array (terms);
--         end;

--         if  (! append) then
--                 old_tt_ids = wp_get_object_terms(
--                         object_id,
--                         taxonomy,
--                         array(
--                                 "fields"                 => "tt_ids",
--                                 "orderby"                => "none",
--                                 "update_term_meta_cache" => false,
--                        )
--                );
--         end; else then
--                 old_tt_ids = array();
--         end;

--         tt_ids     = array();
--         term_ids   = array();
--         new_tt_ids = array();

--         foreach  ((array) terms as term) then
--                 if  ("" === trim (term)) then
--                         continue;
--                 end;

--                 term_info = term_exists (term, taxonomy);

--                 if  (! term_info) then
--                         // Skip if a non-existent term ID is passed.
--                         if  (is_int (term)) then
--                                 continue;
--                         end;

--                         term_info = wp_insert_term (term, taxonomy);
--                 end;

--                 if  (is_wp_error (term_info)) then
--                         return term_info;
--                 end;

--                 term_ids() = term_info("term_id");
--                 tt_id      = term_info("term_taxonomy_id");
--                 tt_ids()   = tt_id;

--                 if  (wpdb.get_var (wpdb.prepare ("SELECT term_taxonomy_id FROM wpdb.term_relationships WHERE object_id = %d AND term_taxonomy_id = %d", object_id, tt_id))) then
--                         continue;
--                 end;

--                 --
--                 -- Fires immediately before an object-term relationship is added.
--                 --
--                 -- @since 2.9.0
--                 -- @since 4.7.0 Added the `taxonomy` parameter.
--                 --
--                 -- @param int    object_id Object ID.
--                 -- @param int    tt_id     Term taxonomy ID.
--                 -- @param string taxonomy  Taxonomy slug.
--                 --
--                 do_action ("add_term_relationship", object_id, tt_id, taxonomy);

--                 wpdb.insert(
--                         wpdb.term_relationships,
--                         array(
--                                 "object_id"        => object_id,
--                                 "term_taxonomy_id" => tt_id,
--                        )
--                );

--                 --
--                 -- Fires immediately after an object-term relationship is added.
--                 --
--                 -- @since 2.9.0
--                 -- @since 4.7.0 Added the `taxonomy` parameter.
--                 --
--                 -- @param int    object_id Object ID.
--                 -- @param int    tt_id     Term taxonomy ID.
--                 -- @param string taxonomy  Taxonomy slug.
--                 --
--                 do_action ("added_term_relationship", object_id, tt_id, taxonomy);

--                 new_tt_ids() = tt_id;
--         end;

--         if  (new_tt_ids) then
--                 wp_update_term_count (new_tt_ids, taxonomy);
--         end;

--         if  (! append) then
--                 delete_tt_ids = array_diff (old_tt_ids, tt_ids);

--                 if  (delete_tt_ids) then
--                         in_delete_tt_ids = """ . implode ("", "", delete_tt_ids) . """;
--                         delete_term_ids  = wpdb.get_col (wpdb.prepare ("SELECT tt.term_id FROM wpdb.term_taxonomy AS tt WHERE tt.taxonomy = %s AND tt.term_taxonomy_id IN (in_delete_tt_ids)", taxonomy));
--                         delete_term_ids  = array_map ("intval", delete_term_ids);

--                         remove = wp_remove_object_terms (object_id, delete_term_ids, taxonomy);
--                         if  (is_wp_error (remove)) then
--                                 return remove;
--                         end;
--                 end;
--         end;

--         t = get_taxonomy (taxonomy);

--         if  (! append && isset (t.sort) && t.sort) then
--                 values     = array();
--                 term_order = 0;

--                 final_tt_ids = wp_get_object_terms(
--                         object_id,
--                         taxonomy,
--                         array(
--                                 "fields"                 => "tt_ids",
--                                 "update_term_meta_cache" => false,
--                        )
--                );

--                 foreach  (tt_ids as tt_id) then
--                         if  (in_array ((int) tt_id, final_tt_ids, true)) then
--                                 values() = wpdb.prepare ("(%d, %d, %d)", object_id, tt_id, ++term_order);
--                         end;
--                 end;

--                 if  (values) then
--                         if  (false === wpdb.query ("INSERT INTO wpdb.term_relationships (object_id, term_taxonomy_id, term_order) VALUES " . implode (",", values) . " ON DUPLICATE KEY UPDATE term_order = VALUES(term_order)")) then
--                                 return new WP_Error ("db_insert_error", __ ("Could not insert term relationship into the database."), wpdb.last_error);
--                         end;
--                 end;
--         end;

--         wp_cache_delete (object_id, taxonomy . "_relationships");
--         wp_cache_delete ("last_changed", "terms");

--         --
--         -- Fires after an object"s terms have been set.
--         --
--         -- @since 2.8.0
--         --
--         -- @param int    object_id  Object ID.
--         -- @param array  terms      An array of object term IDs or slugs.
--         -- @param array  tt_ids     An array of term taxonomy IDs.
--         -- @param string taxonomy   Taxonomy slug.
--         -- @param bool   append     Whether to append new terms to the old terms.
--         -- @param array  old_tt_ids Old array of term taxonomy IDs.
--         --
--         do_action ("set_object_terms", object_id, terms, tt_ids, taxonomy, append, old_tt_ids);

--         return tt_ids;
-- end;

--
-- Adds term(s) associated with a given object.
--
-- @since 3.6.0
--
-- @param int              object_id The ID of the object to which the terms will be added.
-- @param string|int|array terms     The slug(s) or ID(s) of the term(s) to add.
-- @param array|string     taxonomy  Taxonomy name.
-- @return array|WP_Error Term taxonomy IDs of the affected terms.
--
-- function wp_add_object_terms (object_id, terms, taxonomy) then
--         return wp_set_object_terms (object_id, terms, taxonomy, true);
-- end;

--
-- Removes term(s) associated with a given object.
--
-- @since 3.6.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int              object_id The ID of the object from which the terms will be removed.
-- @param string|int|array terms     The slug(s) or ID(s) of the term(s) to remove.
-- @param string           taxonomy  Taxonomy name.
-- @return bool|WP_Error True on success, false or WP_Error on failure.
--
-- function wp_remove_object_terms (object_id, terms, taxonomy) then
--         global wpdb;

--         object_id = (int) object_id;

--         if  (! taxonomy_exists (taxonomy)) then
--                 return new WP_Error ("invalid_taxonomy", __ ("Invalid taxonomy."));
--         end;

--         if  (! is_array (terms)) then
--                 terms = array (terms);
--         end;

--         tt_ids = array();

--         foreach  ((array) terms as term) then
--                 if  ("" === trim (term)) then
--                         continue;
--                 end;

--                 term_info = term_exists (term, taxonomy);
--                 if  (! term_info) then
--                         // Skip if a non-existent term ID is passed.
--                         if  (is_int (term)) then
--                                 continue;
--                         end;
--                 end;

--                 if  (is_wp_error (term_info)) then
--                         return term_info;
--                 end;

--                 tt_ids() = term_info("term_taxonomy_id");
--         end;

--         if  (tt_ids) then
--                 in_tt_ids = """ . implode ("", "", tt_ids) . """;

--                 --
--                 -- Fires immediately before an object-term relationship is deleted.
--                 --
--                 -- @since 2.9.0
--                 -- @since 4.7.0 Added the `taxonomy` parameter.
--                 --
--                 -- @param int    object_id Object ID.
--                 -- @param array  tt_ids    An array of term taxonomy IDs.
--                 -- @param string taxonomy  Taxonomy slug.
--                 --
--                 do_action ("delete_term_relationships", object_id, tt_ids, taxonomy);

--                 deleted = wpdb.query (wpdb.prepare ("DELETE FROM wpdb.term_relationships WHERE object_id = %d AND term_taxonomy_id IN (in_tt_ids)", object_id));

--                 wp_cache_delete (object_id, taxonomy . "_relationships");
--                 wp_cache_delete ("last_changed", "terms");

--                 --
--                 -- Fires immediately after an object-term relationship is deleted.
--                 --
--                 -- @since 2.9.0
--                 -- @since 4.7.0 Added the `taxonomy` parameter.
--                 --
--                 -- @param int    object_id Object ID.
--                 -- @param array  tt_ids    An array of term taxonomy IDs.
--                 -- @param string taxonomy  Taxonomy slug.
--                 --
--                 do_action ("deleted_term_relationships", object_id, tt_ids, taxonomy);

--                 wp_update_term_count (tt_ids, taxonomy);

--                 return (bool) deleted;
--         end;

--         return false;
-- end;

--
-- Makes term slug unique, if it isn"t already.
--
-- The `slug` has to be unique global to every taxonomy, meaning that one
-- taxonomy term can"t have a matching slug with another taxonomy term. Each
-- slug has to be globally unique for every taxonomy.
--
-- The way this works is that if the taxonomy that the term belongs to is
-- hierarchical and has a parent, it will append that parent to the slug.
--
-- If that still doesn"t return a unique slug, then it tries to append a number
-- until it finds a number that is truly unique.
--
-- The only purpose for `term` is for appending a parent, if one exists.
--
-- @since 2.3.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param string slug The string that will be tried for a unique slug.
-- @param object term The term object that the `slug` will belong to.
-- @return string Will return a true unique slug.
--
-- function wp_unique_term_slug (slug, term) then
--         global wpdb;

--         needs_suffix  = true;
--         original_slug = slug;

--         // As of 4.1, duplicate slugs are allowed as long as they"re in different taxonomies.
--         if  (! term_exists (slug) || get_option ("db_version") >= 30133 && ! get_term_by ("slug", slug, term.taxonomy)) then
--                 needs_suffix = false;
--         end;

--         /*
--         -- If the taxonomy supports hierarchy and the term has a parent, make the slug unique
--         -- by incorporating parent slugs.
--         --
--         parent_suffix = "";
--         if  (needs_suffix && is_taxonomy_hierarchical (term.taxonomy) && ! empty (term.parent)) then
--                 the_parent = term.parent;
--                 while  (! empty (the_parent)) then
--                         parent_term = get_term (the_parent, term.taxonomy);
--                         if  (is_wp_error (parent_term) || empty (parent_term)) then
--                                 break;
--                         end;
--                         parent_suffix .= "-" . parent_term.slug;
--                         if  (! term_exists (slug . parent_suffix)) then
--                                 break;
--                         end;

--                         if  (empty (parent_term.parent)) then
--                                 break;
--                         end;
--                         the_parent = parent_term.parent;
--                 end;
--         end;

--         // If we didn"t get a unique slug, try appending a number to make it unique.

--         --
--         -- Filters whether the proposed unique term slug is bad.
--         --
--         -- @since 4.3.0
--         --
--         -- @param bool   needs_suffix Whether the slug needs to be made unique with a suffix.
--         -- @param string slug         The slug.
--         -- @param object term         Term object.
--         --
--         if  (apply_filters ("wp_unique_term_slug_is_bad_slug", needs_suffix, slug, term)) then
--                 if  (parent_suffix) then
--                         slug .= parent_suffix;
--                 end;

--                 if  (! empty (term.term_id)) then
--                         query = wpdb.prepare ("SELECT slug FROM wpdb.terms WHERE slug = %s AND term_id != %d", slug, term.term_id);
--                 end; else then
--                         query = wpdb.prepare ("SELECT slug FROM wpdb.terms WHERE slug = %s", slug);
--                 end;

--                 if  (wpdb.get_var (query)) then // phpcs:ignore WordPress.DB.PreparedSQL.NotPrepared
--                         num = 2;
--                         do then
--                                 alt_slug = slug . "-num";
--                                 num++;
--                                 slug_check = wpdb.get_var (wpdb.prepare ("SELECT slug FROM wpdb.terms WHERE slug = %s", alt_slug));
--                         end; while  (slug_check);
--                         slug = alt_slug;
--                 end;
--         end;

--         --
--         -- Filters the unique term slug.
--         --
--         -- @since 4.3.0
--         --
--         -- @param string slug          Unique term slug.
--         -- @param object term          Term object.
--         -- @param string original_slug Slug originally passed to the function for testing.
--         --
--         return apply_filters ("wp_unique_term_slug", slug, term, original_slug);
-- end;

--
-- Updates term based on arguments provided.
--
-- The `args` will indiscriminately override all values with the same field name.
-- Care must be taken to not override important information need to update or
-- update will fail (or perhaps create a new term, neither would be acceptable).
--
-- Defaults will set "alias_of", "description", "parent", and "slug" if not
-- defined in `args` already.
--
-- "alias_of" will create a term group, if it doesn"t already exist, and
-- update it for the `term`.
--
-- If the "slug" argument in `args` is missing, then the "name" will be used.
-- If you set "slug" and it isn"t unique, then a WP_Error is returned.
-- If you don"t pass any slug, then a unique one will be created.
--
-- @since 2.3.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int          term_id  The ID of the term.
-- @param string       taxonomy The taxonomy of the term.
-- @param array        args then
--     Optional. Array of arguments for updating a term.
--
--     @type string alias_of    Slug of the term to make this term an alias of.
--                               Default empty string. Accepts a term slug.
--     @type string description The term description. Default empty string.
--     @type int    parent      The id of the parent term. Default 0.
--     @type string slug        The term slug to use. Default empty string.
-- end;
-- @return array|WP_Error An array containing the `term_id` and `term_taxonomy_id`,
--                        WP_Error otherwise.
--
-- function wp_update_term (term_id, taxonomy, args = array()) then
--         global wpdb;

--         if  (! taxonomy_exists (taxonomy)) then
--                 return new WP_Error ("invalid_taxonomy", __ ("Invalid taxonomy."));
--         end;

--         term_id = (int) term_id;

--         // First, get all of the original args.
--         term = get_term (term_id, taxonomy);

--         if  (is_wp_error (term)) then
--                 return term;
--         end;

--         if  (! term) then
--                 return new WP_Error ("invalid_term", __ ("Empty Term."));
--         end;

--         term = (array) term.data;

--         // Escape data pulled from DB.
--         term = wp_slash (term);

--         // Merge old and new args with new args overwriting old ones.
--         args = array_merge (term, args);

--         defaults    = array(
--                 "alias_of"    => "",
--                 "description" => "",
--                 "parent"      => 0,
--                 "slug"        => "",
--        );
--         args        = wp_parse_args (args, defaults);
--         args        = sanitize_term (args, taxonomy, "db");
--         parsed_args = args;

--         // expected_slashed (name)
--         name        = wp_unslash (args("name"));
--         description = wp_unslash (args("description"));

--         parsed_args("name")        = name;
--         parsed_args("description") = description;

--         if  ("" === trim (name)) then
--                 return new WP_Error ("empty_term_name", __ ("A name is required for this term."));
--         end;

--         if  ((int) parsed_args("parent") > 0 && ! term_exists ((int) parsed_args("parent"))) then
--                 return new WP_Error ("missing_parent", __ ("Parent term does not exist."));
--         end;

--         empty_slug = false;
--         if  (empty (args("slug"))) then
--                 empty_slug = true;
--                 slug       = sanitize_title (name);
--         end; else then
--                 slug = args("slug");
--         end;

--         parsed_args("slug") = slug;

--         term_group = isset (parsed_args("term_group")) ? parsed_args("term_group") : 0;
--         if  (args("alias_of")) then
--                 alias = get_term_by ("slug", args("alias_of"), taxonomy);
--                 if  (! empty (alias.term_group)) then
--                         // The alias we want is already in a group, so let"s use that one.
--                         term_group = alias.term_group;
--                 end; elseif  (! empty (alias.term_id)) then
--                         /*
--                         -- The alias is not in a group, so we create a new one
--                         -- and add the alias to it.
--                         --
--                         term_group = wpdb.get_var ("SELECT MAX(term_group) FROM wpdb.terms") + 1;

--                         wp_update_term(
--                                 alias.term_id,
--                                 taxonomy,
--                                 array(
--                                         "term_group" => term_group,
--                                )
--                        );
--                 end;

--                 parsed_args("term_group") = term_group;
--         end;

--         --
--         -- Filters the term parent.
--         --
--         -- Hook to this filter to see if it will cause a hierarchy loop.
--         --
--         -- @since 3.1.0
--         --
--         -- @param int    parent      ID of the parent term.
--         -- @param int    term_id     Term ID.
--         -- @param string taxonomy    Taxonomy slug.
--         -- @param array  parsed_args An array of potentially altered update arguments for the given term.
--         -- @param array  args        Arguments passed to wp_update_term().
--         --
--         parent = (int) apply_filters ("wp_update_term_parent", args("parent"), term_id, taxonomy, parsed_args, args);

--         // Check for duplicate slug.
--         duplicate = get_term_by ("slug", slug, taxonomy);
--         if  (duplicate && duplicate.term_id !== term_id) then
--                 // If an empty slug was passed or the parent changed, reset the slug to something unique.
--                 // Otherwise, bail.
--                 if  (empty_slug ||  (parent !== (int) term("parent"))) then
--                         slug = wp_unique_term_slug (slug, (object) args);
--                 end; else then
--                         /* translators: %s: Taxonomy term slug.--
--                         return new WP_Error ("duplicate_term_slug", sprintf (__ ("The slug &#8220;%s&#8221; is already in use by another term."), slug));
--                 end;
--         end;

--         tt_id = (int) wpdb.get_var (wpdb.prepare ("SELECT tt.term_taxonomy_id FROM wpdb.term_taxonomy AS tt INNER JOIN wpdb.terms AS t ON tt.term_id = t.term_id WHERE tt.taxonomy = %s AND t.term_id = %d", taxonomy, term_id));

--         // Check whether this is a shared term that needs splitting.
--         _term_id = _split_shared_term (term_id, tt_id);
--         if  (! is_wp_error (_term_id)) then
--                 term_id = _term_id;
--         end;

--         --
--         -- Fires immediately before the given terms are edited.
--         --
--         -- @since 2.9.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int    term_id  Term ID.
--         -- @param string taxonomy Taxonomy slug.
--         -- @param array  args     Arguments passed to wp_update_term().
--         --
--         do_action ("edit_terms", term_id, taxonomy, args);

--         data = compact ("name", "slug", "term_group");

--         --
--         -- Filters term data before it is updated in the database.
--         --
--         -- @since 4.7.0
--         --
--         -- @param array  data     Term data to be updated.
--         -- @param int    term_id  Term ID.
--         -- @param string taxonomy Taxonomy slug.
--         -- @param array  args     Arguments passed to wp_update_term().
--         --
--         data = apply_filters ("wp_update_term_data", data, term_id, taxonomy, args);

--         wpdb.update (wpdb.terms, data, compact ("term_id"));

--         if  (empty (slug)) then
--                 slug = sanitize_title (name, term_id);
--                 wpdb.update (wpdb.terms, compact ("slug"), compact ("term_id"));
--         end;

--         --
--         -- Fires immediately after a term is updated in the database, but before its
--         -- term-taxonomy relationship is updated.
--         --
--         -- @since 2.9.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int    term_id  Term ID.
--         -- @param string taxonomy Taxonomy slug.
--         -- @param array  args     Arguments passed to wp_update_term().
--         --
--         do_action ("edited_terms", term_id, taxonomy, args);

--         --
--         -- Fires immediate before a term-taxonomy relationship is updated.
--         --
--         -- @since 2.9.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int    tt_id    Term taxonomy ID.
--         -- @param string taxonomy Taxonomy slug.
--         -- @param array  args     Arguments passed to wp_update_term().
--         --
--         do_action ("edit_term_taxonomy", tt_id, taxonomy, args);

--         wpdb.update (wpdb.term_taxonomy, compact ("term_id", "taxonomy", "description", "parent"), array ("term_taxonomy_id" => tt_id));

--         --
--         -- Fires immediately after a term-taxonomy relationship is updated.
--         --
--         -- @since 2.9.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int    tt_id    Term taxonomy ID.
--         -- @param string taxonomy Taxonomy slug.
--         -- @param array  args     Arguments passed to wp_update_term().
--         --
--         do_action ("edited_term_taxonomy", tt_id, taxonomy, args);

--         --
--         -- Fires after a term has been updated, but before the term cache has been cleaned.
--         --
--         -- The {@see "edit_taxonomy"} hook is also available for targeting a specific
--         -- taxonomy.
--         --
--         -- @since 2.3.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int    term_id  Term ID.
--         -- @param int    tt_id    Term taxonomy ID.
--         -- @param string taxonomy Taxonomy slug.
--         -- @param array  args     Arguments passed to wp_update_term().
--         --
--         do_action ("edit_term", term_id, tt_id, taxonomy, args);

--         --
--         -- Fires after a term in a specific taxonomy has been updated, but before the term
--         -- cache has been cleaned.
--         --
--         -- The dynamic portion of the hook name, `taxonomy`, refers to the taxonomy slug.
--         --
--         -- Possible hook names include:
--         --
--         --  - `edit_category`
--         --  - `edit_post_tag`
--         --
--         -- @since 2.3.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int   term_id Term ID.
--         -- @param int   tt_id   Term taxonomy ID.
--         -- @param array args    Arguments passed to wp_update_term().
--         --
--         do_action ("edit_thentaxonomyend;", term_id, tt_id, args);

--         -- This filter is documented in wp-includes/taxonomy.php--
--         term_id = apply_filters ("term_id_filter", term_id, tt_id);

--         clean_term_cache (term_id, taxonomy);

--         --
--         -- Fires after a term has been updated, and the term cache has been cleaned.
--         --
--         -- The {@see "edited_taxonomy"} hook is also available for targeting a specific
--         -- taxonomy.
--         --
--         -- @since 2.3.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int    term_id  Term ID.
--         -- @param int    tt_id    Term taxonomy ID.
--         -- @param string taxonomy Taxonomy slug.
--         -- @param array  args     Arguments passed to wp_update_term().
--         --
--         do_action ("edited_term", term_id, tt_id, taxonomy, args);

--         --
--         -- Fires after a term for a specific taxonomy has been updated, and the term
--         -- cache has been cleaned.
--         --
--         -- The dynamic portion of the hook name, `taxonomy`, refers to the taxonomy slug.
--         --
--         -- Possible hook names include:
--         --
--         --  - `edited_category`
--         --  - `edited_post_tag`
--         --
--         -- @since 2.3.0
--         -- @since 6.1.0 The `args` parameter was added.
--         --
--         -- @param int   term_id Term ID.
--         -- @param int   tt_id   Term taxonomy ID.
--         -- @param array args    Arguments passed to wp_update_term().
--         --
--         do_action ("edited_thentaxonomyend;", term_id, tt_id, args);

--         -- This action is documented in wp-includes/taxonomy.php--
--         do_action ("saved_term", term_id, tt_id, taxonomy, true, args);

--         -- This action is documented in wp-includes/taxonomy.php--
--         do_action ("saved_thentaxonomyend;", term_id, tt_id, true, args);

--         return array(
--                 "term_id"          => term_id,
--                 "term_taxonomy_id" => tt_id,
--        );
-- end;

--
-- Enables or disables term counting.
--
-- @since 2.5.0
--
-- @param bool defer Optional. Enable if true, disable if false.
-- @return bool Whether term counting is enabled or disabled.
--
-- function wp_defer_term_counting (defer = null) then
--         static _defer = false;

--         if  (is_bool (defer)) then
--                 _defer = defer;
--                 // Flush any deferred counts.
--                 if  (! defer) then
--                         wp_update_term_count (null, null, true);
--                 end;
--         end;

--         return _defer;
-- end;

--
-- Updates the amount of terms in taxonomy.
--
-- If there is a taxonomy callback applied, then it will be called for updating
-- the count.
--
-- The default action is to count what the amount of terms have the relationship
-- of term ID. Once that is done, then update the database.
--
-- @since 2.3.0
--
-- @param int|array terms       The term_taxonomy_id of the terms.
-- @param string    taxonomy    The context of the term.
-- @param bool      do_deferred Whether to flush the deferred term counts too. Default false.
-- @return bool If no terms will return false, and if successful will return true.
--
-- function wp_update_term_count (terms, taxonomy, do_deferred = false) then
--         static _deferred = array();

--         if  (do_deferred) then
--                 foreach  ((array) array_keys (_deferred) as tax) then
--                         wp_update_term_count_now (_deferred (tax), tax);
--                         unset (_deferred (tax));
--                 end;
--         end;

--         if  (empty (terms)) then
--                 return false;
--         end;

--         if  (! is_array (terms)) then
--                 terms = array (terms);
--         end;

--         if  (wp_defer_term_counting()) then
--                 if  (! isset (_deferred (taxonomy))) then
--                         _deferred (taxonomy) = array();
--                 end;
--                 _deferred (taxonomy) = array_unique (array_merge (_deferred (taxonomy), terms));
--                 return true;
--         end;

--         return wp_update_term_count_now (terms, taxonomy);
-- end;

--
-- Performs term count update immediately.
--
-- @since 2.5.0
--
-- @param array  terms    The term_taxonomy_id of terms to update.
-- @param string taxonomy The context of the term.
-- @return true Always true when complete.
--
-- function wp_update_term_count_now (terms, taxonomy) then
--         terms = array_map ("intval", terms);

--         taxonomy = get_taxonomy (taxonomy);
--         if  (! empty (taxonomy.update_count_callback)) then
--                 call_user_func (taxonomy.update_count_callback, terms, taxonomy);
--         end; else then
--                 object_types = (array) taxonomy.object_type;
--                 foreach  (object_types as &object_type) then
--                         if  (0 === strpos (object_type, "attachment:")) then
--                                 list (object_type) = explode (":", object_type);
--                         end;
--                 end;

--                 if  (array_filter (object_types, "post_type_exists") == object_types) then
--                         // Only post types are attached to this taxonomy.
--                         _update_post_term_count (terms, taxonomy);
--                 end; else then
--                         // Default count updater.
--                         _update_generic_term_count (terms, taxonomy);
--                 end;
--         end;

--         clean_term_cache (terms, "", false);

--         return true;
-- end;

--
-- Cache.
--

--
-- Removes the taxonomy relationship to terms from the cache.
--
-- Will remove the entire taxonomy relationship containing term `object_id`. The
-- term IDs have to exist within the taxonomy `object_type` for the deletion to
-- take place.
--
-- @since 2.3.0
--
-- @global bool _wp_suspend_cache_invalidation
--
-- @see get_object_taxonomies() for more on object_type.
--
-- @param int|array    object_ids  Single or list of term object ID(s).
-- @param array|string object_type The taxonomy object type.
--
-- function clean_object_term_cache (object_ids, object_type) then
--         global _wp_suspend_cache_invalidation;

--         if  (! empty (_wp_suspend_cache_invalidation)) then
--                 return;
--         end;

--         if  (! is_array (object_ids)) then
--                 object_ids = array (object_ids);
--         end;

--         taxonomies = get_object_taxonomies (object_type);

--         foreach  (taxonomies as taxonomy) then
--                 wp_cache_delete_multiple (object_ids, "thentaxonomyend;_relationships");
--         end;

--         wp_cache_delete ("last_changed", "terms");

--         --
--         -- Fires after the object term cache has been cleaned.
--         --
--         -- @since 2.5.0
--         --
--         -- @param array  object_ids An array of object IDs.
--         -- @param string object_type Object type.
--         --
--         do_action ("clean_object_term_cache", object_ids, object_type);
-- end;

--
-- Removes all of the term IDs from the cache.
--
-- @since 2.3.0
--
-- @global wpdb wpdb                           WordPress database abstraction object.
-- @global bool _wp_suspend_cache_invalidation
--
-- @param int|int() ids            Single or array of term IDs.
-- @param string    taxonomy       Optional. Taxonomy slug. Can be empty, in which case the taxonomies of the passed
--                                  term IDs will be used. Default empty.
-- @param bool      clean_taxonomy Optional. Whether to clean taxonomy wide caches (true), or just individual
--                                  term object caches (false). Default true.
--
-- function clean_term_cache (ids, taxonomy = "", clean_taxonomy = true) then
--         global wpdb, _wp_suspend_cache_invalidation;

--         if  (! empty (_wp_suspend_cache_invalidation)) then
--                 return;
--         end;

--         if  (! is_array (ids)) then
--                 ids = array (ids);
--         end;

--         taxonomies = array();
--         // If no taxonomy, assume tt_ids.
--         if  (empty (taxonomy)) then
--                 tt_ids = array_map ("intval", ids);
--                 tt_ids = implode (", ", tt_ids);
--                 terms  = wpdb.get_results ("SELECT term_id, taxonomy FROM wpdb.term_taxonomy WHERE term_taxonomy_id IN (tt_ids)");
--                 ids    = array();

--                 foreach  ((array) terms as term) then
--                         taxonomies() = term.taxonomy;
--                         ids()        = term.term_id;
--                 end;
--                 wp_cache_delete_multiple (ids, "terms");
--                 taxonomies = array_unique (taxonomies);
--         end; else then
--                 wp_cache_delete_multiple (ids, "terms");
--                 taxonomies = array (taxonomy);
--         end;

--         foreach  (taxonomies as taxonomy) then
--                 if  (clean_taxonomy) then
--                         clean_taxonomy_cache (taxonomy);
--                 end;

--                 --
--                 -- Fires once after each taxonomy"s term cache has been cleaned.
--                 --
--                 -- @since 2.5.0
--                 -- @since 4.5.0 Added the `clean_taxonomy` parameter.
--                 --
--                 -- @param array  ids            An array of term IDs.
--                 -- @param string taxonomy       Taxonomy slug.
--                 -- @param bool   clean_taxonomy Whether or not to clean taxonomy-wide caches
--                 --
--                 do_action ("clean_term_cache", ids, taxonomy, clean_taxonomy);
--         end;

--         wp_cache_set ("last_changed", microtime(), "terms");
-- end;

--
-- Cleans the caches for a taxonomy.
--
-- @since 4.9.0
--
-- @param string taxonomy Taxonomy slug.
--
-- function clean_taxonomy_cache (taxonomy) then
--         wp_cache_delete ("all_ids", taxonomy);
--         wp_cache_delete ("get", taxonomy);
--         wp_cache_delete ("last_changed", "terms");

--         // Regenerate cached hierarchy.
--         delete_option ("thentaxonomyend;_children");
--         _get_term_hierarchy (taxonomy);

--         --
--         -- Fires after a taxonomy"s caches have been cleaned.
--         --
--         -- @since 4.9.0
--         --
--         -- @param string taxonomy Taxonomy slug.
--         --
--         do_action ("clean_taxonomy_cache", taxonomy);
-- end;

--
-- Retrieves the cached term objects for the given object ID.
--
-- Upstream functions (like get_the_terms() and is_object_in_term()) are
-- responsible for populating the object-term relationship cache. The current
-- function only fetches relationship data that is already in the cache.
--
-- @since 2.3.0
-- @since 4.7.0 Returns a `WP_Error` object if there"s an error with
--              any of the matched terms.
--
-- @param int    id       Term object ID, for example a post, comment, or user ID.
-- @param string taxonomy Taxonomy name.
-- @return bool|WP_Term()|WP_Error Array of `WP_Term` objects, if cached.
--                                 False if cache is empty for `taxonomy` and `id`.
--                                 WP_Error if get_term() returns an error object for any term.
--

   ---------------------------
   -- Get_Object_Term_Cache --
   ---------------------------
-- function get_object_term_cache (id, taxonomy) then

   function Get_Object_Term_Cache (Id       : Integer;
                                   Taxonomy : String)
                                   return Class_Terms.Wp_Term_Array
   is
      use Ada.Containers;
      use Adi_Caches;
      use Class_Terms;
--    use Array_Maps;

      Unused_Hit : Boolean;
      X_Term_Ids : Array_Type;
      Term_Ids   : Array_Type;
   begin
      Wp_Cache_Get (Key   => Id,
                   Group  => Taxonomy & "_relationships",
                   Result => X_Term_Ids,
                   Hit    => Unused_Hit);

      -- We leave the priming of relationship caches to upstream functions.
      if Length (X_Term_Ids) = 0 then  -- false =
         return (Empty_Term_Array);
      end if;

      -- Backward compatibility for if a plugin is putting objects into the
      -- cache, rather than IDs.
-- declare
--         term_ids = array();
-- begin
--         for Term_Id of X_Term_Ids loop
--                 if Is_Numeric (Term_Id) then
--                         term_ids() = (int) term_id;
--                 elsif isset (term_id.term_id) then
--                         term_ids() = (int) term_id.term_id;
--                 end if;
--         end loop;
-- end;
      Term_Ids := X_Term_Ids;

      -- Fill the term objects.
      X_Prime_Term_Caches (Term_Ids);

      declare
--       use Inc_Taxonomys;

         Terms : Wp_Term_Array;
      begin
         for A in Term_Ids.Iterate loop
            declare
               Term_Id : constant String := Key (A);
               Term    : constant Wp_Term
                  := Get_Term (Integer'Value (Term_Id), Taxonomy);
            begin
--               if Is_Wp_Error (Term) then
--                  return Term;
--               end if;

               Terms.Append (Term);
            end;
         end loop;

         return Terms;
      end;
   end Get_Object_Term_Cache;

--
-- Updates the cache for the given term object ID(s).
--
-- Note: Due to performance concerns, great care should be taken to only update
-- term caches when necessary. Processing time can increase exponentially depending
-- on both the number of passed term IDs and the number of taxonomies those terms
-- belong to.
--
-- Caches will only be updated for terms not already cached.
--
-- @since 2.3.0
--
-- @param string|int()    object_ids  Comma-separated list or array of term object IDs.
-- @param string|string() object_type The taxonomy object type or array of the same.
-- @return void|false Void on success or if the `object_ids` parameter is empty,
--                    false if all of the terms in `object_ids` are already cached.
--
-- function update_object_term_cache (object_ids, object_type) then
--         if  (empty (object_ids)) then
--                 return;
--         end;

--         if  (! is_array (object_ids)) then
--                 object_ids = explode (",", object_ids);
--         end;

--         object_ids     = array_map ("intval", object_ids);
--         non_cached_ids = array();

--         taxonomies = get_object_taxonomies (object_type);

--         foreach  (taxonomies as taxonomy) then
--                 cache_values = wp_cache_get_multiple ((array) object_ids, "thentaxonomyend;_relationships");

--                 foreach  (cache_values as id => value) then
--                         if  (false === value) then
--                                 non_cached_ids() = id;
--                         end;
--                 end;
--         end;

--         if  (empty (non_cached_ids)) then
--                 return false;
--         end;

--         non_cached_ids = array_unique (non_cached_ids);

--         terms = wp_get_object_terms(
--                 non_cached_ids,
--                 taxonomies,
--                 array(
--                         "fields"                 => "all_with_object_id",
--                         "orderby"                => "name",
--                         "update_term_meta_cache" => false,
--                )
--        );

--         object_terms = array();
--         foreach  ((array) terms as term) then
--                 object_terms (term.object_id) (term.taxonomy)() = term.term_id;
--         end;

--         foreach  (non_cached_ids as id) then
--                 foreach  (taxonomies as taxonomy) then
--                         if  (! isset (object_terms (id) (taxonomy))) then
--                                 if  (! isset (object_terms (id))) then
--                                         object_terms (id) = array();
--                                 end;
--                                 object_terms (id) (taxonomy) = array();
--                         end;
--                 end;
--         end;

--         cache_values = array();
--         foreach  (object_terms as id => value) then
--                 foreach  (value as taxonomy => terms) then
--                         cache_values (taxonomy) (id) = terms;
--                 end;
--         end;
--         foreach  (cache_values as taxonomy => data) then
--                 wp_cache_add_multiple (data, "thentaxonomyend;_relationships");
--         end;
-- end;

--
-- Updates terms in cache.
--
-- @since 2.3.0
--
-- @param WP_Term() terms    Array of term objects to change.
-- @param string    taxonomy Not used.
--
-- function update_term_cache (terms, taxonomy = "") then
--         data = array();
--         foreach  ((array) terms as term) then
--                 // Create a copy in case the array was passed by reference.
--                 _term = clone term;

--                 // Object ID should not be cached.
--                 unset (_term.object_id);

--                 data (term.term_id) = _term;
--         end;
--         wp_cache_add_multiple (data, "terms");
-- end;

--
-- Private.
--

--
-- Retrieves children of taxonomy as term IDs.
--
-- @access private
-- @since 2.3.0
--
-- @param string taxonomy Taxonomy name.
-- @return array Empty if taxonomy isn"t hierarchical or returns children as term IDs.
--
-- function _get_term_hierarchy (taxonomy) then
--         if  (! is_taxonomy_hierarchical (taxonomy)) then
--                 return array();
--         end;
--         children = get_option ("thentaxonomyend;_children");

--         if  (is_array (children)) then
--                 return children;
--         end;
--         children = array();
--         terms    = get_terms(
--                 array(
--                         "taxonomy"               => taxonomy,
--                         "get"                    => "all",
--                         "orderby"                => "id",
--                         "fields"                 => "id=>parent",
--                         "update_term_meta_cache" => false,
--                )
--        );
--         foreach  (terms as term_id => parent) then
--                 if  (parent > 0) then
--                         children (parent)() = term_id;
--                 end;
--         end;
--         update_option ("thentaxonomyend;_children", children);

--         return children;
-- end;

--
-- Gets the subset of terms that are descendants of term_id.
--
-- If `terms` is an array of objects, then _get_term_children() returns an array of objects.
-- If `terms` is an array of IDs, then _get_term_children() returns an array of IDs.
--
-- @access private
-- @since 2.3.0
--
-- @param int    term_id   The ancestor term: all returned terms should be descendants of `term_id`.
-- @param array  terms     The set of terms - either an array of term objects or term IDs - from which those that
--                          are descendants of term_id will be chosen.
-- @param string taxonomy  The taxonomy which determines the hierarchy of the terms.
-- @param array  ancestors Optional. Term ancestors that have already been identified. Passed by reference, to keep
--                          track of found terms when recursing the hierarchy. The array of located ancestors is used
--                          to prevent infinite recursion loops. For performance, `term_ids` are used as array keys,
--                          with 1 as value. Default empty array.
-- @return array|WP_Error The subset of terms that are descendants of term_id.
--
-- function _get_term_children (term_id, terms, taxonomy, &ancestors = array()) then
--         empty_array = array();
--         if  (empty (terms)) then
--                 return empty_array;
--         end;

--         term_id      = (int) term_id;
--         term_list    = array();
--         has_children = _get_term_hierarchy (taxonomy);

--         if  (term_id && ! isset (has_children (term_id))) then
--                 return empty_array;
--         end;

--         // Include the term itself in the ancestors array, so we can properly detect when a loop has occurred.
--         if  (empty (ancestors)) then
--                 ancestors (term_id) = 1;
--         end;

--         foreach  ((array) terms as term) then
--                 use_id = false;
--                 if  (! is_object (term)) then
--                         term = get_term (term, taxonomy);
--                         if  (is_wp_error (term)) then
--                                 return term;
--                         end;
--                         use_id = true;
--                 end;

--                 // Don"t recurse if we"ve already identified the term as a child - this indicates a loop.
--                 if  (isset (ancestors (term.term_id))) then
--                         continue;
--                 end;

--                 if  ((int) term.parent === term_id) then
--                         if  (use_id) then
--                                 term_list() = term.term_id;
--                         end; else then
--                                 term_list() = term;
--                         end;

--                         if  (! isset (has_children (term.term_id))) then
--                                 continue;
--                         end;

--                         ancestors (term.term_id) = 1;

--                         children = _get_term_children (term.term_id, terms, taxonomy, ancestors);
--                         if  (children) then
--                                 term_list = array_merge (term_list, children);
--                         end;
--                 end;
--         end;

--         return term_list;
-- end;

--
-- Adds count of children to parent count.
--
-- Recalculates term counts by including items from child terms. Assumes all
-- relevant children are already in the terms argument.
--
-- @access private
-- @since 2.3.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param object()|WP_Term() terms    List of term objects (passed by reference).
-- @param string             taxonomy Term context.
--
-- function _pad_term_counts (&terms, taxonomy) then
--         global wpdb;

--         // This function only works for hierarchical taxonomies like post categories.
--         if  (! is_taxonomy_hierarchical (taxonomy)) then
--                 return;
--         end;

--         term_hier = _get_term_hierarchy (taxonomy);

--         if  (empty (term_hier)) then
--                 return;
--         end;

--         term_items  = array();
--         terms_by_id = array();
--         term_ids    = array();

--         foreach  ((array) terms as key => term) then
--                 terms_by_id (term.term_id)       = & terms (key);
--                 term_ids (term.term_taxonomy_id) = term.term_id;
--         end;

--         // Get the object and term IDs and stick them in a lookup table.
--         tax_obj      = get_taxonomy (taxonomy);
--         object_types = esc_sql (tax_obj.object_type);
--         results      = wpdb.get_results ("SELECT object_id, term_taxonomy_id FROM wpdb.term_relationships INNER JOIN wpdb.posts ON object_id = ID WHERE term_taxonomy_id IN (" . implode (",", array_keys (term_ids)) . ") AND post_type IN ("" . implode ("", "", object_types) . "") AND post_status = "publish"");

--         foreach  (results as row) then
--                 id = term_ids (row.term_taxonomy_id);

--                 term_items (id) (row.object_id) = isset (term_items (id) (row.object_id)) ? ++term_items (id) (row.object_id) : 1;
--         end;

--         // Touch every ancestor"s lookup row for each post in each term.
--         foreach  (term_ids as term_id) then
--                 child     = term_id;
--                 ancestors = array();
--                 while  (! empty (terms_by_id (child)) && parent = terms_by_id (child).parent) then
--                         ancestors() = child;

--                         if  (! empty (term_items (term_id))) then
--                                 foreach  (term_items (term_id) as item_id => touches) then
--                                         term_items (parent) (item_id) = isset (term_items (parent) (item_id)) ? ++term_items (parent) (item_id) : 1;
--                                 end;
--                         end;

--                         child = parent;

--                         if  (in_array (parent, ancestors, true)) then
--                                 break;
--                         end;
--                 end;
--         end;

--         // Transfer the touched cells.
--         foreach  ((array) term_items as id => items) then
--                 if  (isset (terms_by_id (id))) then
--                         terms_by_id (id).count = count (items);
--                 end;
--         end;
-- end;

--
-- Adds any terms from the given IDs to the cache that do not already exist in cache.
--
-- @since 4.6.0
-- @since 6.1.0 This function is no longer marked as "private".
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param array term_ids          Array of term IDs.
-- @param bool  update_meta_cache Optional. Whether to update the meta cache. Default true.
--
-- function _prime_term_caches (term_ids, update_meta_cache = true) then
--         global wpdb;

--         non_cached_ids = _get_non_cached_ids (term_ids, "terms");
--         if  (! empty (non_cached_ids)) then
--                 fresh_terms = wpdb.get_results (sprintf ("SELECT t.*, tt.* FROM wpdb.terms AS t INNER JOIN wpdb.term_taxonomy AS tt ON t.term_id = tt.term_id WHERE t.term_id IN (%s)", implode (",", array_map ("intval", non_cached_ids))));

--                 update_term_cache (fresh_terms);

--                 if  (update_meta_cache) then
--                         update_termmeta_cache (non_cached_ids);
--                 end;
--         end;
-- end;

--
-- Default callbacks.
--

--
-- Updates term count based on object types of the current taxonomy.
--
-- Private function for the default callback for post_tag and category
-- taxonomies.
--
-- @access private
-- @since 2.3.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int()       terms    List of term taxonomy IDs.
-- @param WP_Taxonomy taxonomy Current taxonomy object of terms.
--
-- function _update_post_term_count (terms, taxonomy) then
--         global wpdb;

--         object_types = (array) taxonomy.object_type;

--         foreach  (object_types as &object_type) then
--                 list (object_type) = explode (":", object_type);
--         end;

--         object_types = array_unique (object_types);

--         check_attachments = array_search ("attachment", object_types, true);
--         if  (false !== check_attachments) then
--                 unset (object_types (check_attachments));
--                 check_attachments = true;
--         end;

--         if  (object_types) then
--                 object_types = esc_sql (array_filter (object_types, "post_type_exists"));
--         end;

--         post_statuses = array ("publish");

--         --
--         -- Filters the post statuses for updating the term count.
--         --
--         -- @since 5.7.0
--         --
--         -- @param string()    post_statuses List of post statuses to include in the count. Default is "publish".
--         -- @param WP_Taxonomy taxonomy      Current taxonomy object.
--         --
--         post_statuses = esc_sql (apply_filters ("update_post_term_count_statuses", post_statuses, taxonomy));

--         foreach  ((array) terms as term) then
--                 count = 0;

--                 // Attachments can be "inherit" status, we need to base count off the parent"s status if so.
--                 if  (check_attachments) then
--                         // phpcs:ignore WordPress.DB.PreparedSQLPlaceholders.QuotedDynamicPlaceholderGeneration
--                         count += (int) wpdb.get_var (wpdb.prepare ("SELECT COUNT(*) FROM wpdb.term_relationships, wpdb.posts p1 WHERE p1.ID = wpdb.term_relationships.object_id AND  (post_status IN ("" . implode ("", "", post_statuses) . "") OR  (post_status = "inherit" AND post_parent > 0 AND  (SELECT post_status FROM wpdb.posts WHERE ID = p1.post_parent) IN ("" . implode ("", "", post_statuses) . ""))) AND post_type = "attachment" AND term_taxonomy_id = %d", term));
--                 end;

--                 if  (object_types) then
--                         // phpcs:ignore WordPress.DB.PreparedSQLPlaceholders.QuotedDynamicPlaceholderGeneration
--                         count += (int) wpdb.get_var (wpdb.prepare ("SELECT COUNT(*) FROM wpdb.term_relationships, wpdb.posts WHERE wpdb.posts.ID = wpdb.term_relationships.object_id AND post_status IN ("" . implode ("", "", post_statuses) . "") AND post_type IN ("" . implode ("", "", object_types) . "") AND term_taxonomy_id = %d", term));
--                 end;

--                 -- This action is documented in wp-includes/taxonomy.php--
--                 do_action ("edit_term_taxonomy", term, taxonomy.name);
--                 wpdb.update (wpdb.term_taxonomy, compact ("count"), array ("term_taxonomy_id" => term));

--                 -- This action is documented in wp-includes/taxonomy.php--
--                 do_action ("edited_term_taxonomy", term, taxonomy.name);
--         end;
-- end;

--
-- Updates term count based on number of objects.
--
-- Default callback for the "link_category" taxonomy.
--
-- @since 3.3.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int()       terms    List of term taxonomy IDs.
-- @param WP_Taxonomy taxonomy Current taxonomy object of terms.
--
-- function _update_generic_term_count (terms, taxonomy) then
--         global wpdb;

--         foreach  ((array) terms as term) then
--                 count = wpdb.get_var (wpdb.prepare ("SELECT COUNT(*) FROM wpdb.term_relationships WHERE term_taxonomy_id = %d", term));

--                 -- This action is documented in wp-includes/taxonomy.php--
--                 do_action ("edit_term_taxonomy", term, taxonomy.name);
--                 wpdb.update (wpdb.term_taxonomy, compact ("count"), array ("term_taxonomy_id" => term));

--                 -- This action is documented in wp-includes/taxonomy.php--
--                 do_action ("edited_term_taxonomy", term, taxonomy.name);
--         end;
-- end;

--
-- Creates a new term for a term_taxonomy item that currently shares its term
-- with another term_taxonomy.
--
-- @ignore
-- @since 4.2.0
-- @since 4.3.0 Introduced `record` parameter. Also, `term_id` and
--              `term_taxonomy_id` can now accept objects.
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int|object term_id          ID of the shared term, or the shared term object.
-- @param int|object term_taxonomy_id ID of the term_taxonomy item to receive a new term, or the term_taxonomy object
--                                     (corresponding to a row from the term_taxonomy table).
-- @param bool       record           Whether to record data about the split term in the options table. The recording
--                                     process has the potential to be resource-intensive, so during batch operations
--                                     it can be beneficial to skip inline recording and do it just once, after the
--                                     batch is processed. Only set this to `false` if you know what you are doing.
--                                     Default: true.
-- @return int|WP_Error When the current term does not need to be split (or cannot be split on the current
--                      database schema), `term_id` is returned. When the term is successfully split, the
--                      new term_id is returned. A WP_Error is returned for miscellaneous errors.
--
-- function _split_shared_term (term_id, term_taxonomy_id, record = true) then
--         global wpdb;

--         if  (is_object (term_id)) then
--                 shared_term = term_id;
--                 term_id     = (int) shared_term.term_id;
--         end;

--         if  (is_object (term_taxonomy_id)) then
--                 term_taxonomy    = term_taxonomy_id;
--                 term_taxonomy_id = (int) term_taxonomy.term_taxonomy_id;
--         end;

--         // If there are no shared term_taxonomy rows, there"s nothing to do here.
--         shared_tt_count = (int) wpdb.get_var (wpdb.prepare ("SELECT COUNT(*) FROM wpdb.term_taxonomy tt WHERE tt.term_id = %d AND tt.term_taxonomy_id != %d", term_id, term_taxonomy_id));

--         if  (! shared_tt_count) then
--                 return term_id;
--         end;

--         /*
--         -- Verify that the term_taxonomy_id passed to the function is actually associated with the term_id.
--         -- If there"s a mismatch, it may mean that the term is already split. Return the actual term_id from the db.
--         --
--         check_term_id = (int) wpdb.get_var (wpdb.prepare ("SELECT term_id FROM wpdb.term_taxonomy WHERE term_taxonomy_id = %d", term_taxonomy_id));
--         if  (check_term_id !== term_id) then
--                 return check_term_id;
--         end;

--         // Pull up data about the currently shared slug, which we"ll use to populate the new one.
--         if  (empty (shared_term)) then
--                 shared_term = wpdb.get_row (wpdb.prepare ("SELECT t.* FROM wpdb.terms t WHERE t.term_id = %d", term_id));
--         end;

--         new_term_data = array(
--                 "name"       => shared_term.name,
--                 "slug"       => shared_term.slug,
--                 "term_group" => shared_term.term_group,
--        );

--         if  (false === wpdb.insert (wpdb.terms, new_term_data)) then
--                 return new WP_Error ("db_insert_error", __ ("Could not split shared term."), wpdb.last_error);
--         end;

--         new_term_id = (int) wpdb.insert_id;

--         // Update the existing term_taxonomy to point to the newly created term.
--         wpdb.update(
--                 wpdb.term_taxonomy,
--                 array ("term_id" => new_term_id),
--                 array ("term_taxonomy_id" => term_taxonomy_id)
--        );

--         // Reassign child terms to the new parent.
--         if  (empty (term_taxonomy)) then
--                 term_taxonomy = wpdb.get_row (wpdb.prepare ("SELECT-- FROM wpdb.term_taxonomy WHERE term_taxonomy_id = %d", term_taxonomy_id));
--         end;

--         children_tt_ids = wpdb.get_col (wpdb.prepare ("SELECT term_taxonomy_id FROM wpdb.term_taxonomy WHERE parent = %d AND taxonomy = %s", term_id, term_taxonomy.taxonomy));
--         if  (! empty (children_tt_ids)) then
--                 foreach  (children_tt_ids as child_tt_id) then
--                         wpdb.update(
--                                 wpdb.term_taxonomy,
--                                 array ("parent" => new_term_id),
--                                 array ("term_taxonomy_id" => child_tt_id)
--                        );
--                         clean_term_cache ((int) child_tt_id, "", false);
--                 end;
--         end; else then
--                 // If the term has no children, we must force its taxonomy cache to be rebuilt separately.
--                 clean_term_cache (new_term_id, term_taxonomy.taxonomy, false);
--         end;

--         clean_term_cache (term_id, term_taxonomy.taxonomy, false);

--         /*
--         -- Taxonomy cache clearing is delayed to avoid race conditions that may occur when
--         -- regenerating the taxonomy"s hierarchy tree.
--         --
--         taxonomies_to_clean = array (term_taxonomy.taxonomy);

--         // Clean the cache for term taxonomies formerly shared with the current term.
--         shared_term_taxonomies = wpdb.get_col (wpdb.prepare ("SELECT taxonomy FROM wpdb.term_taxonomy WHERE term_id = %d", term_id));
--         taxonomies_to_clean    = array_merge (taxonomies_to_clean, shared_term_taxonomies);

--         foreach  (taxonomies_to_clean as taxonomy_to_clean) then
--                 clean_taxonomy_cache (taxonomy_to_clean);
--         end;

--         // Keep a record of term_ids that have been split, keyed by old term_id. See wp_get_split_term().
--         if  (record) then
--                 split_term_data = get_option ("_split_terms", array());
--                 if  (! isset (split_term_data (term_id))) then
--                         split_term_data (term_id) = array();
--                 end;

--                 split_term_data (term_id) (term_taxonomy.taxonomy) = new_term_id;
--                 update_option ("_split_terms", split_term_data);
--         end;

--         // If we"ve just split the final shared term, set the "finished" flag.
--         shared_terms_exist = wpdb.get_results(
--                 "SELECT tt.term_id, t.*, count(*) as term_tt_count FROM thenwpdb.term_taxonomyend; tt
--                  LEFT JOIN thenwpdb.termsend; t ON t.term_id = tt.term_id
--                  GROUP BY t.term_id
--                  HAVING term_tt_count > 1
--                  LIMIT 1"
--        );
--         if  (! shared_terms_exist) then
--                 update_option ("finished_splitting_shared_terms", true);
--         end;

--         --
--         -- Fires after a previously shared taxonomy term is split into two separate terms.
--         --
--         -- @since 4.2.0
--         --
--         -- @param int    term_id          ID of the formerly shared term.
--         -- @param int    new_term_id      ID of the new term created for the term_taxonomy_id.
--         -- @param int    term_taxonomy_id ID for the term_taxonomy row affected by the split.
--         -- @param string taxonomy         Taxonomy for the split term.
--         --
--         do_action ("split_shared_term", term_id, new_term_id, term_taxonomy_id, term_taxonomy.taxonomy);

--         return new_term_id;
-- end;

--
-- Splits a batch of shared taxonomy terms.
--
-- @since 4.3.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- function _wp_batch_split_terms() then
--         global wpdb;

--         lock_name = "term_split.lock";

--         // Try to lock.
--         lock_result = wpdb.query (wpdb.prepare ("INSERT IGNORE INTO `wpdb.options`  (`option_name`, `option_value`, `autoload`) VALUES (%s, %s, "no") /* LOCK--", lock_name, time()));

--         if  (! lock_result) then
--                 lock_result = get_option (lock_name);

--                 // Bail if we were unable to create a lock, or if the existing lock is still valid.
--                 if  (! lock_result ||  (lock_result >  (time() - HOUR_IN_SECONDS))) then
--                         wp_schedule_single_event (time() +  (5-- MINUTE_IN_SECONDS), "wp_split_shared_term_batch");
--                         return;
--                 end;
--         end;

--         // Update the lock, as by this point we"ve definitely got a lock, just need to fire the actions.
--         update_option (lock_name, time());

--         // Get a list of shared terms (those with more than one associated row in term_taxonomy).
--         shared_terms = wpdb.get_results(
--                 "SELECT tt.term_id, t.*, count(*) as term_tt_count FROM thenwpdb.term_taxonomyend; tt
--                  LEFT JOIN thenwpdb.termsend; t ON t.term_id = tt.term_id
--                  GROUP BY t.term_id
--                  HAVING term_tt_count > 1
--                  LIMIT 10"
--        );

--         // No more terms, we"re done here.
--         if  (! shared_terms) then
--                 update_option ("finished_splitting_shared_terms", true);
--                 delete_option (lock_name);
--                 return;
--         end;

--         // Shared terms found? We"ll need to run this script again.
--         wp_schedule_single_event (time() +  (2-- MINUTE_IN_SECONDS), "wp_split_shared_term_batch");

--         // Rekey shared term array for faster lookups.
--         _shared_terms = array();
--         foreach  (shared_terms as shared_term) then
--                 term_id                   = (int) shared_term.term_id;
--                 _shared_terms (term_id) = shared_term;
--         end;
--         shared_terms = _shared_terms;

--         // Get term taxonomy data for all shared terms.
--         shared_term_ids = implode (",", array_keys (shared_terms));
--         shared_tts      = wpdb.get_results ("SELECT-- FROM thenwpdb.term_taxonomyend; WHERE `term_id` IN (thenshared_term_idsend;)");

--         // Split term data recording is slow, so we do it just once, outside the loop.
--         split_term_data    = get_option ("_split_terms", array());
--         skipped_first_term = array();
--         taxonomies         = array();
--         foreach  (shared_tts as shared_tt) then
--                 term_id = (int) shared_tt.term_id;

--                 // Don"t split the first tt belonging to a given term_id.
--                 if  (! isset (skipped_first_term (term_id))) then
--                         skipped_first_term (term_id) = 1;
--                         continue;
--                 end;

--                 if  (! isset (split_term_data (term_id))) then
--                         split_term_data (term_id) = array();
--                 end;

--                 // Keep track of taxonomies whose hierarchies need flushing.
--                 if  (! isset (taxonomies (shared_tt.taxonomy))) then
--                         taxonomies (shared_tt.taxonomy) = 1;
--                 end;

--                 // Split the term.
--                 split_term_data (term_id) (shared_tt.taxonomy) = _split_shared_term (shared_terms (term_id), shared_tt, false);
--         end;

--         // Rebuild the cached hierarchy for each affected taxonomy.
--         foreach  (array_keys (taxonomies) as tax) then
--                 delete_option ("thentaxend;_children");
--                 _get_term_hierarchy (tax);
--         end;

--         update_option ("_split_terms", split_term_data);

--         delete_option (lock_name);
-- end;

--
-- In order to avoid the _wp_batch_split_terms() job being accidentally removed,
-- checks that it"s still scheduled while we haven"t finished splitting terms.
--
-- @ignore
-- @since 4.3.0
--
-- function _wp_check_for_scheduled_split_terms() then
--         if  (! get_option ("finished_splitting_shared_terms") && ! wp_next_scheduled ("wp_split_shared_term_batch")) then
--                 wp_schedule_single_event (time() + MINUTE_IN_SECONDS, "wp_split_shared_term_batch");
--         end;
-- end;

--
-- Checks default categories when a term gets split to see if any of them need to be updated.
--
-- @ignore
-- @since 4.2.0
--
-- @param int    term_id          ID of the formerly shared term.
-- @param int    new_term_id      ID of the new term created for the term_taxonomy_id.
-- @param int    term_taxonomy_id ID for the term_taxonomy row affected by the split.
-- @param string taxonomy         Taxonomy for the split term.
--
-- function _wp_check_split_default_terms (term_id, new_term_id, term_taxonomy_id, taxonomy) then
--         if  ("category" !== taxonomy) then
--                 return;
--         end;

--         foreach  (array ("default_category", "default_link_category", "default_email_category") as option) then
--                 if  ((int) get_option (option, -1) === term_id) then
--                         update_option (option, new_term_id);
--                 end;
--         end;
-- end;

--
-- Checks menu items when a term gets split to see if any of them need to be updated.
--
-- @ignore
-- @since 4.2.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int    term_id          ID of the formerly shared term.
-- @param int    new_term_id      ID of the new term created for the term_taxonomy_id.
-- @param int    term_taxonomy_id ID for the term_taxonomy row affected by the split.
-- @param string taxonomy         Taxonomy for the split term.
--
-- function _wp_check_split_terms_in_menus (term_id, new_term_id, term_taxonomy_id, taxonomy) then
--         global wpdb;
--         post_ids = wpdb.get_col(
--                 wpdb.prepare(
--                         "SELECT m1.post_id
--                 FROM thenwpdb.postmetaend; AS m1
--                         INNER JOIN thenwpdb.postmetaend; AS m2 ON  (m2.post_id = m1.post_id)
--                         INNER JOIN thenwpdb.postmetaend; AS m3 ON  (m3.post_id = m1.post_id)
--                 WHERE  (m1.meta_key = "_menu_item_type" AND m1.meta_value = "taxonomy")
--                         AND  (m2.meta_key = "_menu_item_object" AND m2.meta_value = %s)
--                         AND  (m3.meta_key = "_menu_item_object_id" AND m3.meta_value = %d)",
--                         taxonomy,
--                         term_id
--                )
--        );

--         if  (post_ids) then
--                 foreach  (post_ids as post_id) then
--                         update_post_meta (post_id, "_menu_item_object_id", new_term_id, term_id);
--                 end;
--         end;
-- end;

--
-- If the term being split is a nav_menu, changes associations.
--
-- @ignore
-- @since 4.3.0
--
-- @param int    term_id          ID of the formerly shared term.
-- @param int    new_term_id      ID of the new term created for the term_taxonomy_id.
-- @param int    term_taxonomy_id ID for the term_taxonomy row affected by the split.
-- @param string taxonomy         Taxonomy for the split term.
--
-- function _wp_check_split_nav_menu_terms (term_id, new_term_id, term_taxonomy_id, taxonomy) then
--         if  ("nav_menu" !== taxonomy) then
--                 return;
--         end;

--         // Update menu locations.
--         locations = get_nav_menu_locations();
--         foreach  (locations as location => menu_id) then
--                 if  (term_id === menu_id) then
--                         locations (location) = new_term_id;
--                 end;
--         end;
--         set_theme_mod ("nav_menu_locations", locations);
-- end;

--
-- Gets data about terms that previously shared a single term_id, but have since been split.
--
-- @since 4.2.0
--
-- @param int old_term_id Term ID. This is the old, pre-split term ID.
-- @return array Array of new term IDs, keyed by taxonomy.
--
-- function wp_get_split_terms (old_term_id) then
--         split_terms = get_option ("_split_terms", array());

--         terms = array();
--         if  (isset (split_terms (old_term_id))) then
--                 terms = split_terms (old_term_id);
--         end;

--         return terms;
-- end;

--
-- Gets the new term ID corresponding to a previously split term.
--
-- @since 4.2.0
--
-- @param int    old_term_id Term ID. This is the old, pre-split term ID.
-- @param string taxonomy    Taxonomy that the term belongs to.
-- @return int|false If a previously split term is found corresponding to the old term_id and taxonomy,
--                   the new term_id will be returned. If no previously split term is found matching
--                   the parameters, returns false.
--
-- function wp_get_split_term (old_term_id, taxonomy) then
--         split_terms = wp_get_split_terms (old_term_id);

--         term_id = false;
--         if  (isset (split_terms (taxonomy))) then
--                 term_id = (int) split_terms (taxonomy);
--         end;

--         return term_id;
-- end;

--
-- Determines whether a term is shared between multiple taxonomies.
--
-- Shared taxonomy terms began to be split in 4.3, but failed cron tasks or
-- other delays in upgrade routines may cause shared terms to remain.
--
-- @since 4.4.0
--
-- @param int term_id Term ID.
-- @return bool Returns false if a term is not shared between multiple taxonomies or
--              if splitting shared taxonomy terms is finished.
--
-- function wp_term_is_shared (term_id) then
--         global wpdb;

--         if  (get_option ("finished_splitting_shared_terms")) then
--                 return false;
--         end;

--         tt_count = wpdb.get_var (wpdb.prepare ("SELECT COUNT(*) FROM wpdb.term_taxonomy WHERE term_id = %d", term_id));

--         return tt_count > 1;
-- end;

--
-- Generates a permalink for a taxonomy term archive.
--
-- @since 2.5.0
--
-- @global WP_Rewrite wp_rewrite WordPress rewrite component.
--
-- @param WP_Term|int|string term     The term object, ID, or slug whose link will be retrieved.
-- @param string             taxonomy Optional. Taxonomy. Default empty.
-- @return string|WP_Error URL of the taxonomy term archive on success, WP_Error if term does not exist.
--
-- function get_term_link (term, taxonomy = "") then
--         global wp_rewrite;

--         if  (! is_object (term)) then
--                 if  (is_int (term)) then
--                         term = get_term (term, taxonomy);
--                 end; else then
--                         term = get_term_by ("slug", term, taxonomy);
--                 end;
--         end;

--         if  (! is_object (term)) then
--                 term = new WP_Error ("invalid_term", __ ("Empty Term."));
--         end;

--         if  (is_wp_error (term)) then
--                 return term;
--         end;

--         taxonomy = term.taxonomy;

--         termlink = wp_rewrite.get_extra_permastruct (taxonomy);

--         --
--         -- Filters the permalink structure for a term before token replacement occurs.
--         --
--         -- @since 4.9.0
--         --
--         -- @param string  termlink The permalink structure for the term"s taxonomy.
--         -- @param WP_Term term     The term object.
--         --
--         termlink = apply_filters ("pre_term_link", termlink, term);

--         slug = term.slug;
--         t    = get_taxonomy (taxonomy);

--         if  (empty (termlink)) then
--                 if  ("category" === taxonomy) then
--                         termlink = "?cat=" . term.term_id;
--                 end; elseif  (t.query_var) then
--                         termlink = "?t.query_var=slug";
--                 end; else then
--                         termlink = "?taxonomy=taxonomy&term=slug";
--                 end;
--                 termlink = home_url (termlink);
--         end; else then
--                 if  (! empty (t.rewrite("hierarchical"))) then
--                         hierarchical_slugs = array();
--                         ancestors          = get_ancestors (term.term_id, taxonomy, "taxonomy");
--                         foreach  ((array) ancestors as ancestor) then
--                                 ancestor_term        = get_term (ancestor, taxonomy);
--                                 hierarchical_slugs() = ancestor_term.slug;
--                         end;
--                         hierarchical_slugs   = array_reverse (hierarchical_slugs);
--                         hierarchical_slugs() = slug;
--                         termlink             = str_replace ("%taxonomy%", implode ("/", hierarchical_slugs), termlink);
--                 end; else then
--                         termlink = str_replace ("%taxonomy%", slug, termlink);
--                 end;
--                 termlink = home_url (user_trailingslashit (termlink, "category"));
--         end;

--         // Back compat filters.
--         if  ("post_tag" === taxonomy) then

--                 --
--                 -- Filters the tag link.
--                 --
--                 -- @since 2.3.0
--                 -- @since 2.5.0 Deprecated in favor of {@see "term_link"} filter.
--                 -- @since 5.4.1 Restored (un-deprecated).
--                 --
--                 -- @param string termlink Tag link URL.
--                 -- @param int    term_id  Term ID.
--                 --
--                 termlink = apply_filters ("tag_link", termlink, term.term_id);
--         end; elseif  ("category" === taxonomy) then

--                 --
--                 -- Filters the category link.
--                 --
--                 -- @since 1.5.0
--                 -- @since 2.5.0 Deprecated in favor of {@see "term_link"} filter.
--                 -- @since 5.4.1 Restored (un-deprecated).
--                 --
--                 -- @param string termlink Category link URL.
--                 -- @param int    term_id  Term ID.
--                 --
--                 termlink = apply_filters ("category_link", termlink, term.term_id);
--         end;

--         --
--         -- Filters the term link.
--         --
--         -- @since 2.5.0
--         --
--         -- @param string  termlink Term link URL.
--         -- @param WP_Term term     Term object.
--         -- @param string  taxonomy Taxonomy slug.
--         --
--         return apply_filters ("term_link", termlink, term, taxonomy);
-- end;

--
-- Displays the taxonomies of a post with available options.
--
-- This function can be used within the loop to display the taxonomies for a
-- post without specifying the Post ID. You can also use it outside the Loop to
-- display the taxonomies for a specific post.
--
-- @since 2.5.0
--
-- @param array args then
--     Arguments about which post to use and how to format the output. Shares all of the arguments
--     supported by get_the_taxonomies(), in addition to the following.
--
--     @type int|WP_Post post   Post ID or object to get taxonomies of. Default current post.
--     @type string      before Displays before the taxonomies. Default empty string.
--     @type string      sep    Separates each taxonomy. Default is a space.
--     @type string      after  Displays after the taxonomies. Default empty string.
-- end;
--
-- function the_taxonomies (args = array()) then
--         defaults = array(
--                 "post"   => 0,
--                 "before" => "",
--                 "sep"    => " ",
--                 "after"  => "",
--        );

--         parsed_args = wp_parse_args (args, defaults);

--         echo parsed_args("before") . implode (parsed_args("sep"), get_the_taxonomies (parsed_args("post"), parsed_args)) . parsed_args("after");
-- end;

--
-- Retrieves all taxonomies associated with a post.
--
-- This function can be used within the loop. It will also return an array of
-- the taxonomies with links to the taxonomy and name.
--
-- @since 2.5.0
--
-- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is global post.
-- @param array       args then
--           Optional. Arguments about how to format the list of taxonomies. Default empty array.
--
--     @type string template      Template for displaying a taxonomy label and list of terms.
--                                 Default is "Label: Terms."
--     @type string term_template Template for displaying a single term in the list. Default is the term name
--                                 linked to its archive.
-- end;
-- @return string() List of taxonomies.
--
-- function get_the_taxonomies (post = 0, args = array()) then
--         post = get_post (post);

--         args = wp_parse_args(
--                 args,
--                 array(
--                         /* translators: %s: Taxonomy label, %l: List of terms formatted as per term_template.--
--                         "template"      => __ ("%s: %l."),
--                         "term_template" => "<a href="%1s">%2s</a>",
--                )
--        );

--         taxonomies = array();

--         if  (! post) then
--                 return taxonomies;
--         end;

--         foreach  (get_object_taxonomies (post) as taxonomy) then
--                 t = (array) get_taxonomy (taxonomy);
--                 if  (empty (t("label"))) then
--                         t("label") = taxonomy;
--                 end;
--                 if  (empty (t("args"))) then
--                         t("args") = array();
--                 end;
--                 if  (empty (t("template"))) then
--                         t("template") = args("template");
--                 end;
--                 if  (empty (t("term_template"))) then
--                         t("term_template") = args("term_template");
--                 end;

--                 terms = get_object_term_cache (post.ID, taxonomy);
--                 if  (false === terms) then
--                         terms = wp_get_object_terms (post.ID, taxonomy, t("args"));
--                 end;
--                 links = array();

--                 foreach  (terms as term) then
--                         links() = wp_sprintf (t("term_template"), esc_attr (get_term_link (term)), term.name);
--                 end;
--                 if  (links) then
--                         taxonomies (taxonomy) = wp_sprintf (t("template"), t("label"), links, terms);
--                 end;
--         end;
--         return taxonomies;
-- end;

--
-- Retrieves all taxonomy names for the given post.
--
-- @since 2.5.0
--
-- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is global post.
-- @return string() An array of all taxonomy names for the given post.
--
-- function get_post_taxonomies (post = 0) then
--         post = get_post (post);

--         return get_object_taxonomies (post);
-- end;

--
-- Determines if the given object is associated with any of the given terms.
--
-- The given terms are checked against the object"s terms" term_ids, names and slugs.
-- Terms given as integers will only be checked against the object"s terms" term_ids.
-- If no terms are given, determines if object is associated with any terms in the given taxonomy.
--
-- @since 2.7.0
--
-- @param int                       object_id ID of the object (post ID, link ID, ...).
-- @param string                    taxonomy  Single taxonomy name.
-- @param int|string|int()|string() terms     Optional. Term ID, name, slug, or array of such
--                                             to check against. Default null.
-- @return bool|WP_Error WP_Error on input error.
--
-- function is_object_in_term (object_id, taxonomy, terms = null) then
--         object_id = (int) object_id;
--         if  (! object_id) then
--                 return new WP_Error ("invalid_object", __ ("Invalid object ID."));
--         end;

--         object_terms = get_object_term_cache (object_id, taxonomy);
--         if  (false === object_terms) then
--                 object_terms = wp_get_object_terms (object_id, taxonomy, array ("update_term_meta_cache" => false));
--                 if  (is_wp_error (object_terms)) then
--                         return object_terms;
--                 end;

--                 wp_cache_set (object_id, wp_list_pluck (object_terms, "term_id"), "thentaxonomyend;_relationships");
--         end;

--         if  (is_wp_error (object_terms)) then
--                 return object_terms;
--         end;
--         if  (empty (object_terms)) then
--                 return false;
--         end;
--         if  (empty (terms)) then
--                 return  (! empty (object_terms));
--         end;

--         terms = (array) terms;

--         ints = array_filter (terms, "is_int");
--         if  (ints) then
--                 strs = array_diff (terms, ints);
--         end; else then
--                 strs =& terms;
--         end;

--         foreach  (object_terms as object_term) then
--                 // If term is an int, check against term_ids only.
--                 if  (ints && in_array (object_term.term_id, ints, true)) then
--                         return true;
--                 end;

--                 if  (strs) then
--                         // Only check numeric strings against term_id, to avoid false matches due to type juggling.
--                         numeric_strs = array_map ("intval", array_filter (strs, "is_numeric"));
--                         if  (in_array (object_term.term_id, numeric_strs, true)) then
--                                 return true;
--                         end;

--                         if  (in_array (object_term.name, strs, true)) then
--                                 return true;
--                         end;
--                         if  (in_array (object_term.slug, strs, true)) then
--                                 return true;
--                         end;
--                 end;
--         end;

--         return false;
-- end;

--
-- Determines if the given object type is associated with the given taxonomy.
--
-- @since 3.0.0
--
-- @param string object_type Object type string.
-- @param string taxonomy    Single taxonomy name.
-- @return bool True if object is associated with the taxonomy, otherwise false.
--
-- function is_object_in_taxonomy (object_type, taxonomy) then

   function Is_Object_In_Taxonomy (Object_Type : String;
                                   Taxonomy    : String)
                                   return Boolean
   is
      use Wp_Common;
      use Taxonomy_Vectors;

      Taxonomies : constant Taxonomy_Array := Get_Object_Taxonomies (Object_Type);
   begin
      if Is_Empty (Taxonomies) then
         return False;
      end if;
      return In_Array (Taxonomy, Taxonomies, True);
   end Is_Object_In_Taxonomy;

   -------------------
   -- Get_Ancestors --
   -------------------

   function Get_Ancestors (Object_Id     : Integer := 0;
                           Object_Type   : String  := "";
                           Resource_Type : String  := "")
                           return Class_Taxonomy.Int_Arrays.Vector
--                            return Int_Arrays.Vector -- ;Int_Array
   is
--    use Php.Arrays;
      use UStrings;
      use Wp_Common;
      use Class_Taxonomy;
      use Class_Terms;
      use Inc_Load;
      use Inc_Posts;

--        object_id = (int) object_id;
      Ancestors       : Int_Arrays.Vector; -- Array_Type; -- array();
      Resource_Type_2 : UString := +Resource_Type;
   begin
      if Object_Id = 0 then
--    if Empty (Object_Id) then
         -- This filter is documented in wp-includes/taxonomy.php
         return Apply_Filters ("get_ancestors", Ancestors, Object_Id,
                               Object_Type, -Resource_Type_2);
      end if;

      if Resource_Type_2 = "" then
         if  Is_Taxonomy_Hierarchical (Object_Type) then
            Resource_Type_2 := +"taxonomy";
         elsif Post_Type_Exists (Object_Type) then
            Resource_Type_2 := +"post_type";
         end if;
      end if;

      if "taxonomy" = Resource_Type_2 then
         declare
            Term : Wp_Term := Get_Term (Object_Id, Object_Type);
         begin
            while
              not Is_Wp_Error (Term) and then
              Term.Parent /= 0 and then
--            not Empty (Term.Parent) and then
              not In_Array (Term.Parent, Ancestors, True)
            loop
               Ancestors.Append (Term.Parent); -- (int)
               Term := Get_Term (Term.Parent, Object_Type);
            end loop;
         end;
      elsif "post_type" = Resource_Type_2 then
         Ancestors := Get_Post_Ancestors (Class_Posts.Post_Id (Object_Id));
      end if;

      --
      -- Filters a given object's ancestors.
      --
      -- @since 3.1.0
      -- @since 4.1.1 Introduced the `resource_type` parameter.
      --
      -- @param int()  ancestors     An array of IDs of object ancestors.
      -- @param int    object_id     Object ID.
      -- @param string object_type   Type of object.
      -- @param string resource_type Type of resource object_type is.
      --
      return Apply_Filters ("get_ancestors", Ancestors,
                            Object_Id, Object_Type, -Resource_Type_2);
   end Get_Ancestors;

--
-- Returns the term"s parent"s term ID.
--
-- @since 3.1.0
--
-- @param int    term_id  Term ID.
-- @param string taxonomy Taxonomy name.
-- @return int|false Parent term ID on success, false on failure.
--
-- function wp_get_term_taxonomy_parent_id (term_id, taxonomy) then
--         term = get_term (term_id, taxonomy);
--         if  (! term || is_wp_error (term)) then
--                 return false;
--         end;
--         return (int) term.parent;
-- end;

--
-- Checks the given subset of the term hierarchy for hierarchy loops.
-- Prevents loops from forming and breaks those that it finds.
--
-- Attached to the {@see "wp_update_term_parent"} filter.
--
-- @since 3.1.0
--
-- @param int    parent   `term_id` of the parent for the term we"re checking.
-- @param int    term_id  The term we"re checking.
-- @param string taxonomy The taxonomy of the term we"re checking.
-- @return int The new parent for the term.
--
-- function wp_check_term_hierarchy_for_loops (parent, term_id, taxonomy) then
--         // Nothing fancy here - bail.
--         if  (! parent) then
--                 return 0;
--         end;

--         // Can"t be its own parent.
--         if  (parent === term_id) then
--                 return 0;
--         end;

--         // Now look for larger loops.
--         loop = wp_find_hierarchy_loop ("wp_get_term_taxonomy_parent_id", term_id, parent, array (taxonomy));
--         if  (! loop) then
--                 return parent; // No loop.
--         end;

--         // Setting parent to the given value causes a loop.
--         if  (isset (loop (term_id))) then
--                 return 0;
--         end;

--         // There"s a loop, but it doesn"t contain term_id. Break the loop.
--         foreach  (array_keys (loop) as loop_member) then
--                 wp_update_term (loop_member, taxonomy, array ("parent" => 0));
--         end;

--         return parent;
-- end;

--
-- Determines whether a taxonomy is considered "viewable".
--
-- @since 5.1.0
--
-- @param string|WP_Taxonomy taxonomy Taxonomy name or object.
-- @return bool Whether the taxonomy should be considered viewable.
--
-- function is_taxonomy_viewable (taxonomy) then
--         if  (is_scalar (taxonomy)) then
--                 taxonomy = get_taxonomy (taxonomy);
--                 if  (! taxonomy) then
--                         return false;
--                 end;
--         end;

--         return taxonomy.publicly_queryable;
-- end;

--
-- Determines whether a term is publicly viewable.
--
-- A term is considered publicly viewable if its taxonomy is viewable.
--
-- @since 6.1.0
--
-- @param int|WP_Term term Term ID or term object.
-- @return bool Whether the term is publicly viewable.
--
-- function is_term_publicly_viewable (term) then
--         term = get_term (term);

--         if  (! term) then
--                 return false;
--         end;

--         return is_taxonomy_viewable (term.taxonomy);
-- end;

--
-- Sets the last changed time for the "terms" cache group.
--
-- @since 5.0.0
--
-- function wp_cache_set_terms_last_changed() then
--         wp_cache_set ("last_changed", microtime(), "terms");
-- end;

--
-- Aborts calls to term meta if it is not supported.
--
-- @since 5.0.0
--
-- @param mixed check Skip-value for whether to proceed term meta function execution.
-- @return mixed Original value of check, or false if term meta is not supported.
--
-- function wp_check_term_meta_support_prefilter (check) then
--         if  (get_option ("db_version") < 34370) then
--                 return false;
--         end;

--         return check;
-- end;

end Inc_Taxonomys;
