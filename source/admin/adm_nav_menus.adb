--
-- WordPress Administration for Navigation Menus
-- Interface functions
--
-- @version 2.0.0
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Strings.Unbounded;

with Arrays;
with Binder;
with Hb_Common;
with Php;
with Globals;

with Adi_Nav_Menus;

with Inc_Capabilities;
with Inc_Class_Wp_Posts;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_L10n;
with Inc_Nav_Menus;
with Inc_Pluggables;
with Inc_Posts;
with Inc_Taxonomys;
with Inc_Themes;
with Inc_Vars;

package body Adm_Nav_Menus
is
   use Ada.Strings.Unbounded;
   use Arrays;
   use Hb_Common;
   use Inc_L10n;
   use Php;
   use Globals;
-- -- Load WordPress Administration Bootstrap
-- require_once __DIR__ . '/admin.php';

-- -- Load all the nav menu interface functions.
-- require_once ABSPATH . 'wp-admin/includes/nav-menu.php';

   procedure Run
   is
      use Binder;
      use Inc_Themes;
      use Inc_Nav_Menus;
      use Inc_Capabilities;
   begin

      if
        not Current_Theme_Supports ("menus") and then
        not Current_Theme_Supports ("widgets")
      then
         Inc_Functions.Wp_Die
           (abs "Your theme does not support navigation menus or widgets.");
      end if;

      -- Permissions check.
      if not Current_User_Can ("edit_theme_options") then
         Inc_Functions.Wp_Die
           ("<h1>" & abs "You need a higher level of permission." & "</h1>" & "<p>" &
            abs "Sorry, you are not allowed to edit theme options on this site." &
            "</p>",
            Code => 403
           );
      end if;

      Inc_Functions_Wp_Scripts.Wp_Enqueue_Script ("nav-menu");

      if Inc_Vars.Wp_Is_Mobile then
         Inc_Functions_Wp_Scripts.Wp_Enqueue_Script ("jquery-touch-punch");
      end if;

      declare
         -- Container for any messages displayed to the user.
         Messages : Array_Type := Empty_Array;

         -- Container that stores the name of the active menu.
         Nav_Menu_Selected_Title : Unbounded_String;

         -- The menu id of the current menu being edited.
         Nav_Menu_Selected_Id : constant Integer :=
            (if Isset (X_REQUEST, "menu")
             then Integer'Value (Get (X_REQUEST, "menu"))
             else 0);

         -- Get existing menu locations assignments.
         Locations      : constant String_Array  := Get_Registered_Nav_Menus; -- ();
         Menu_Locations : constant Integer_Array := Get_Nav_Menu_Locations;   -- ();
         Num_Locations  : constant Integer       := Integer (Locations.Length);
--         Num_Locations  : Integer       := Count (Array_Keys (Locations));

         -- Allowed actions: add, update, delete.
         Action : constant String := (if Isset (X_REQUEST, "action")
                                      then Get (X_REQUEST, "action") else "edit");

         Unused   : Integer;
         Unused_2 : Boolean;
      begin
         --
         -- If a JSON blob of navigation menu data is found, expand it and inject it
         -- into `_POST` to avoid PHP `max_input_vars` limitations. See #14134.
         --
         Adi_Nav_Menus.X_Wp_Expand_Nav_Menu_Post_Data; -- ();

-- switch ( action ) then
--         case "add-menu-item":
         if Action = "add-menu-item" then
            Inc_Pluggables.Check_Admin_Referer ("add-menu_item",
                                               "menu-settings-column-nonce");

            if Isset (X_REQUEST, "nav-menu-locations") then
               Unused_2 := Set_Theme_Mod ("nav_menu_locations",
                             Array_Map ("absint",
                               Get_Array (X_REQUEST, "menu-locations")));

            elsif Isset (X_REQUEST, "menu-item") then
               Unused := Adi_Nav_Menus.Wp_Save_Nav_Menu_Items
                           (Nav_Menu_Selected_Id,
                            Get_Array (X_REQUEST, "menu-item"));
            end if;

--        case "move-down-menu-item":
         elsif Action = "move-down-menu-item" then
            -- Moving down a menu item is the same as moving up the next in order.
            Inc_Pluggables.Check_Admin_Referer ("move-menu_item");
            declare
               Menu_Item_Id : constant Integer :=
                 (if Isset (X_REQUEST, "menu-item")
                  then Get_Integer (X_REQUEST, "menu-item")
                  else 0);
            begin
               if Is_Nav_Menu_Item (Menu_Item_Id) then
                  declare
                     Menus : Array_Type :=
                       (if Isset (X_REQUEST, "menu")
                        then Empty_Array
                        -- Arrays.To_Array ((1 => Build (X_REQUEST, "menu")))
                        else Inc_Taxonomys.Wp_Get_Object_Terms (Menu_Item_Id,
                                                                "nav_menu",
                                To_List (List => (+"fields", +"ids"))));
                  begin
                     if
--                     not Is_Wp_Error (Menus) and then
                       Menus.First_Element.Str /= "" --  (0)
                     then
                        declare
                           Menu_Id : constant String :=
                             -Menus.First_Element.Str; -- (0)

                           Ordered_Menu_Items : constant Menu_Item_Array := -- Array_Type :=
                              Wp_Get_Nav_Menu_Items (Menu_Id);

                           Menu_Item_Data : Array_Type :=  -- (array)
                              Wp_Setup_Nav_Menu_Item
                                 (Inc_Posts.Get_Post (Menu_Item_Id));

                           -- Set up the data we need in one pass through the array
                           -- of menu items.
                           Dbids_To_Orders : Array_Type; -- = array();
                           Orders_To_Dbids : Array_Type; -- = array();
                        begin
                           for
                             Ordered_Menu_Item_Object of Ordered_Menu_Items -- (array)
                           loop
                              null;
                              -- if Isset (Ordered_Menu_Item_Object, "id") then
                              --    if Isset (Ordered_Menu_Item_Object, "menu_order") then

                              --       Dbids_To_Orders (Ordered_Menu_Item_Object.ID) :=
                              --          Ordered_Menu_Item_Object.Menu_Order;

                              --       Orders_To_Dbids
                              --          (Ordered_Menu_Item_Object.Menu_Order) :=
                              --             Ordered_Menu_Item_Object.Id;
                              --    end if;
                              -- end if;
                           end loop;

                           -- Get next in order.
                           if True
--                           Isset (Orders_To_Dbids
--                             (Dbids_To_Orders (Menu_Item_Id) + 1))
                           then
                              declare
                                 use Inc_Posts;

                                 Next_Item_Id   : String := "XXX-611";
--                                  Orders_To_Dbids (Dbids_To_Orders
--                                     (Menu_Item_Id) + 1);

                                 Next_Item_Data : Array_Type := Empty_Array;
--                                  Wp_Setup_Nav_Menu_Item (Get_Post (Next_Item_Id));
                              begin
                                 -- If not siblings of same parent, bubble menu item
                                 -- up but keep order.
                                 if 0 /= Get_Integer (Menu_Item_Data,
                                                     "menu_item_parent")
--                               if not Empty (Get_Integer (Menu_Item_Data,
--                                                  "menu_item_parent"))
                                    and then (Empty (String'(Get (Next_Item_Data,
                                                                  "menu_item_parent")))
                                      or else Get_Integer (Next_Item_Data,
                                                           "menu_item_parent")  -- (int)
                                           /= Get_Integer (Menu_Item_Data,
                                                           "menu_item_parent")) -- (int)
                                 then
                                    declare
                                       use Inc_Class_Wp_Posts;

                                       Parent_Db_Id : constant Integer :=
                                          (if True -- In_Array (Menu_Item_Data
                                                   --       ("menu_item_parent"),
                                                   --     Orders_To_Dbids, True)
                                           then Get_Integer (Menu_Item_Data, "menu_item_parent")
                                           else 0);

                                       Parent_Object : Wp_Post; -- :=
--                                        Wp_Setup_Nav_Menu_Item (Get_Post
--                                                                  (Parent_Db_Id));
                                    begin
                                       if True then
--                                     if not Is_Wp_Error (Parent_Object) then
                                          declare
                                             Unused : Integer;
                                             Parent_Data : Wp_Post := Parent_Object;
--                                           Parent_Data : Array_Type := Parent_Object;
                                          begin
                                             null;
--                                           Set (Menu_Item_Data, "menu_item_parent",
--                                              Get_Integer (Empty_Array, -- Parent_Data,
--                                                           "menu_item_parent"));

--                                           Unused := Update_Post_Meta
--                                              (Get_Integer (Menu_Item_Data, "ID"),
--                                               "_menu_item_menu_item_parent",
--                                               String'(Get (Menu_Item_Data,
--                                                            "menu_item_parent")));
                                          end;
                                       end if;
                                    end;

                                 -- Make menu item a child of its next sibling.
                                 else
                                    Set_Integer (Next_Item_Data, "menu_order",
                                       Get_Integer (Next_Item_Data, "menu_order") - 1);

                                    Set_Integer (Menu_Item_Data, "menu_order",
                                       Get_Integer (Menu_Item_Data, "menu_order") + 1);

                                    Set (Menu_Item_Data, "menu_item_parent",
                                       String'(Get (Next_Item_Data, "ID")));

                                    declare
                                       Unused : Integer;
                                    begin
--                                     Unused :=
--                                        Update_Post_Meta (Get (Menu_Item_Data, "ID"),
--                                            "_menu_item_menu_item_parent",
--                                            Get (Menu_Item_Data, "menu_item_parent"));
                                       Unused :=
                                          Inc_Posts.Wp_Update_Post (Menu_Item_Data);
                                       Unused :=
                                          Inc_Posts.Wp_Update_Post (Next_Item_Data);
                                    end;
                                 end if;
                              end;

                           -- The item is last but still has a parent, so bubble up.
                           elsif
                             not Empty (String'(Get (Menu_Item_Data,
                                                     "menu_item_parent")))
                             and then In_Array (Get (Menu_Item_Data,
                                                     "menu_item_parent"), -- (int)
                                                Orders_To_Dbids, True)
                           then
                              Set (Menu_Item_Data, "menu_item_parent",
                                 Inc_Posts.Get_Post_Meta
                                    (Inc_Class_Wp_Posts.Post_Id (Get_Integer (Menu_Item_Data,
                                                           "menu_item_parent")),
                                                     "_menu_item_menu_item_parent",
                                                     True));
                              declare
                                 Unused : Integer;
                              begin
                                 Unused :=
                                   Inc_Posts.Update_Post_Meta (
                                     Get_Integer (Menu_Item_Data, "ID"),
                                                  "_menu_item_menu_item_parent",
                                     Get_Array (Menu_Item_Data, "menu_item_parent")); -- (int)
                              end;
                           end if;
                        end;
                     end if;
                  end;
               end if;
            end;
         end if; -- jq
      end;       -- jq
   end Run;      -- jq
--         case "move-up-menu-item":
--                 check_admin_referer( "move-menu_item" );

--                 menu_item_id = isset( _REQUEST("menu-item") ) ? (int) _REQUEST("menu-item") : 0;

--                 if ( is_nav_menu_item( menu_item_id ) ) then
--                         if ( isset( _REQUEST("menu") ) ) then
--                                 menus = array( (int) _REQUEST("menu") );
--                         end; else then
--                                 menus = wp_get_object_terms( menu_item_id, "nav_menu", array( "fields" => "ids" ) );
--                         end;

--                         if ( not is_wp_error( menus ) and then not empty( menus(0) ) ) then
--                                 menu_id            = (int) menus(0);
--                                 ordered_menu_items = wp_get_nav_menu_items( menu_id );
--                                 menu_item_data     = (array) wp_setup_nav_menu_item( get_post( menu_item_id ) );

--                                 -- Set up the data we need in one pass through the array of menu items.
--                                 dbids_to_orders = array();
--                                 orders_to_dbids = array();

--                                 foreach ( (array) ordered_menu_items as ordered_menu_item_object ) then
--                                         if ( isset( ordered_menu_item_object->ID ) ) then
--                                                 if ( isset( ordered_menu_item_object->menu_order ) ) then
--                                                         dbids_to_orders( ordered_menu_item_object->ID )         = ordered_menu_item_object->menu_order;
--                                                         orders_to_dbids( ordered_menu_item_object->menu_order ) = ordered_menu_item_object->ID;
--                                                 end;
--                                         end;
--                                 end;

--                                 -- If this menu item is not first.
--                                 if ( not empty( dbids_to_orders( menu_item_id ) )
--                                         and then not empty( orders_to_dbids( dbids_to_orders( menu_item_id ) - 1 ) )
--                                 ) then

--                                         -- If this menu item is a child of the previous.
--                                         if ( not empty( menu_item_data("menu_item_parent") )
--                                                 and then in_array( (int) menu_item_data("menu_item_parent"), array_keys( dbids_to_orders ), true )
--                                                 and then isset( orders_to_dbids( dbids_to_orders( menu_item_id ) - 1 ) )
--                                                 and then ( (int) menu_item_data("menu_item_parent") === orders_to_dbids( dbids_to_orders( menu_item_id ) - 1 ) )
--                                         ) then
--                                                 if ( in_array( (int) menu_item_data("menu_item_parent"), orders_to_dbids, true ) ) then
--                                                         parent_db_id = (int) menu_item_data("menu_item_parent");
--                                                 end; else then
--                                                         parent_db_id = 0;
--                                                 end;

--                                                 parent_object = wp_setup_nav_menu_item( get_post( parent_db_id ) );

--                                                 if ( not is_wp_error( parent_object ) ) then
--                                                         parent_data = (array) parent_object;

--                                                         /*
--                                                         -- If there is something before the parent and parent a child of it,
--                                                         -- make menu item a child also of it.
--                                                         --
--                                                         if ( not empty( dbids_to_orders( parent_db_id ) )
--                                                                 and then not empty( orders_to_dbids( dbids_to_orders( parent_db_id ) - 1 ) )
--                                                                 and then not empty( parent_data("menu_item_parent") )
--                                                         ) then
--                                                                 menu_item_data("menu_item_parent") = parent_data("menu_item_parent");

--                                                                 /*
--                                                                -- Else if there is something before parent and parent not a child of it,
--                                                                -- make menu item a child of that something"s parent
--                                                                --
--                                                         end; elseif ( not empty( dbids_to_orders( parent_db_id ) )
--                                                                 and then not empty( orders_to_dbids( dbids_to_orders( parent_db_id ) - 1 ) )
--                                                         ) then
--                                                                 _possible_parent_id = (int) get_post_meta( orders_to_dbids( dbids_to_orders( parent_db_id ) - 1 ), "_menu_item_menu_item_parent", true );

--                                                                 if ( in_array( _possible_parent_id, array_keys( dbids_to_orders ), true ) ) then
--                                                                         menu_item_data("menu_item_parent") = _possible_parent_id;
--                                                                 end; else then
--                                                                         menu_item_data("menu_item_parent") = 0;
--                                                                 end;

--                                                                 -- Else there isn"t something before the parent.
--                                                         end; else then
--                                                                 menu_item_data("menu_item_parent") = 0;
--                                                         end;

--                                                         -- Set former parent"s (menu_order) to that of menu-item"s.
--                                                         parent_data("menu_order") = parent_data("menu_order") + 1;

--                                                         -- Set menu-item"s (menu_order) to that of former parent.
--                                                         menu_item_data("menu_order") = menu_item_data("menu_order") - 1;

--                                                         -- Save changes.
--                                                         update_post_meta( menu_item_data("ID"), "_menu_item_menu_item_parent", (int) menu_item_data("menu_item_parent") );
--                                                         wp_update_post( menu_item_data );
--                                                         wp_update_post( parent_data );
--                                                 end;

--                                                 -- Else this menu item is not a child of the previous.
--                                         end; elseif ( empty( menu_item_data("menu_order") )
--                                                 || empty( menu_item_data("menu_item_parent") )
--                                                 || not in_array( (int) menu_item_data("menu_item_parent"), array_keys( dbids_to_orders ), true )
--                                                 || empty( orders_to_dbids( dbids_to_orders( menu_item_id ) - 1 ) )
--                                                 || orders_to_dbids( dbids_to_orders( menu_item_id ) - 1 ) !== (int) menu_item_data("menu_item_parent")
--                                         ) then
--                                                 -- Just make it a child of the previous; keep the order.
--                                                 menu_item_data("menu_item_parent") = (int) orders_to_dbids( dbids_to_orders( menu_item_id ) - 1 );
--                                                 update_post_meta( menu_item_data("ID"), "_menu_item_menu_item_parent", (int) menu_item_data("menu_item_parent") );
--                                                 wp_update_post( menu_item_data );
--                                         end;
--                                 end;
--                         end;
--                 end;

--                 break;

--         case "delete-menu-item":
--                 menu_item_id = (int) _REQUEST("menu-item");

--                 check_admin_referer( "delete-menu_item_" . menu_item_id );

--                 if ( is_nav_menu_item( menu_item_id ) and then wp_delete_post( menu_item_id, true ) ) then
--                         messages() = "<div id="message" class="updated notice is-dismissible"><p>" . abs( "The menu item has been successfully deleted." ) . "</p></div>";
--                 end;

--                 break;

--         case "delete":
--                 check_admin_referer( "delete-nav_menu-" . nav_menu_selected_id );

--                 if ( is_nav_menu( nav_menu_selected_id ) ) then
--                         deletion = wp_delete_nav_menu( nav_menu_selected_id );
--                 end; else then
--                         -- Reset the selected menu.
--                         nav_menu_selected_id = 0;
--                         unset( _REQUEST("menu") );
--                 end;

--                 if ( not isset( deletion ) ) then
--                         break;
--                 end;

--                 if ( is_wp_error( deletion ) ) then
--                         messages() = "<div id="message" class="error notice is-dismissible"><p>" . deletion->get_error_message() . "</p></div>";
--                 end; else then
--                         messages() = "<div id="message" class="updated notice is-dismissible"><p>" . abs( "The menu has been successfully deleted." ) . "</p></div>";
--                 end;

--                 break;

--         case "delete_menus":
--                 check_admin_referer( "nav_menus_bulk_actions" );

--                 foreach ( _REQUEST("delete_menus") as menu_id_to_delete ) then
--                         if ( not is_nav_menu( menu_id_to_delete ) ) then
--                                 continue;
--                         end;

--                         deletion = wp_delete_nav_menu( menu_id_to_delete );

--                         if ( is_wp_error( deletion ) ) then
--                                 messages()     = "<div id="message" class="error notice is-dismissible"><p>" . deletion->get_error_message() . "</p></div>";
--                                 deletion_error = true;
--                         end;
--                 end;

--                 if ( empty( deletion_error ) ) then
--                         messages() = "<div id="message" class="updated notice is-dismissible"><p>" . abs( "Selected menus have been successfully deleted." ) . "</p></div>";
--                 end;

--                 break;

--         case "update":
--                 check_admin_referer( "update-nav_menu", "update-nav-menu-nonce" );

--                 -- Merge new and existing menu locations if any new ones are set.
--                 new_menu_locations = array();
--                 if ( isset( _POST("menu-locations") ) ) then
--                         new_menu_locations = array_map( "absint", _POST("menu-locations") );
--                         menu_locations     = array_merge( menu_locations, new_menu_locations );
--                 end;

--                 -- Add Menu.
--                 if ( 0 === nav_menu_selected_id ) then
--                         new_menu_title = trim( esc_html( _POST("menu-name") ) );

--                         if ( new_menu_title ) then
--                                 _nav_menu_selected_id = wp_update_nav_menu_object( 0, array( "menu-name" => new_menu_title ) );

--                                 if ( is_wp_error( _nav_menu_selected_id ) ) then
--                                         messages() = "<div id="message" class="error notice is-dismissible"><p>" . _nav_menu_selected_id->get_error_message() . "</p></div>";
--                                 end; else then
--                                         _menu_object            = wp_get_nav_menu_object( _nav_menu_selected_id );
--                                         nav_menu_selected_id    = _nav_menu_selected_id;
--                                         nav_menu_selected_title = _menu_object->name;

--                                         if ( isset( _REQUEST("menu-item") ) ) then
--                                                 wp_save_nav_menu_items( nav_menu_selected_id, absint( _REQUEST("menu-item") ) );
--                                         end;

--                                         if ( isset( _REQUEST("zero-menu-state") ) || not empty( _POST("auto-add-pages") ) ) then
--                                                 -- If there are menu items, add them.
--                                                 wp_nav_menu_update_menu_items( nav_menu_selected_id, nav_menu_selected_title );
--                                         end;

--                                         if ( isset( _REQUEST("zero-menu-state") ) ) then
--                                                 -- Auto-save nav_menu_locations.
--                                                 locations = get_nav_menu_locations();

--                                                 foreach ( locations as location => menu_id ) then
--                                                                 locations( location ) = nav_menu_selected_id;
--                                                                 break; -- There should only be 1.
--                                                 end;

--                                                 set_theme_mod( "nav_menu_locations", locations );
--                                         end; elseif ( count( new_menu_locations ) > 0 ) then
--                                                 -- If locations have been selected for the new menu, save those.
--                                                 locations = get_nav_menu_locations();

--                                                 foreach ( array_keys( new_menu_locations ) as location ) then
--                                                         locations( location ) = nav_menu_selected_id;
--                                                 end;

--                                                 set_theme_mod( "nav_menu_locations", locations );
--                                         end;

--                                         if ( isset( _REQUEST("use-location") ) ) then
--                                                 locations      = get_registered_nav_menus();
--                                                 menu_locations = get_nav_menu_locations();

--                                                 if ( isset( locations( _REQUEST("use-location") ) ) ) then
--                                                         menu_locations( _REQUEST("use-location") ) = nav_menu_selected_id;
--                                                 end;

--                                                 set_theme_mod( "nav_menu_locations", menu_locations );
--                                         end;

--                                         wp_redirect( admin_url( "nav-menus.php?menu=" . _nav_menu_selected_id ) );
--                                         exit;
--                                 end;
--                         end; else then
--                                 messages() = "<div id="message" class="error notice is-dismissible"><p>" . abs( "Please enter a valid menu name." ) . "</p></div>";
--                         end;

--                         -- Update existing menu.
--                 end; else then
--                         -- Remove menu locations that have been unchecked.
--                         foreach ( locations as location => description ) then
--                                 if ( ( empty( _POST("menu-locations") ) || empty( _POST("menu-locations")( location ) ) )
--                                         and then isset( menu_locations( location ) ) and then menu_locations( location ) === nav_menu_selected_id
--                                 ) then
--                                         unset( menu_locations( location ) );
--                                 end;
--                         end;

--                         -- Set menu locations.
--                         set_theme_mod( "nav_menu_locations", menu_locations );

--                         _menu_object = wp_get_nav_menu_object( nav_menu_selected_id );

--                         menu_title = trim( esc_html( _POST("menu-name") ) );

--                         if ( not menu_title ) then
--                                 messages() = "<div id="message" class="error notice is-dismissible"><p>" . abs( "Please enter a valid menu name." ) . "</p></div>";
--                                 menu_title = _menu_object->name;
--                         end;

--                         if ( not is_wp_error( _menu_object ) ) then
--                                 _nav_menu_selected_id = wp_update_nav_menu_object( nav_menu_selected_id, array( "menu-name" => menu_title ) );

--                                 if ( is_wp_error( _nav_menu_selected_id ) ) then
--                                         _menu_object = _nav_menu_selected_id;
--                                         messages()   = "<div id="message" class="error notice is-dismissible"><p>" . _nav_menu_selected_id->get_error_message() . "</p></div>";
--                                 end; else then
--                                         _menu_object            = wp_get_nav_menu_object( _nav_menu_selected_id );
--                                         nav_menu_selected_title = _menu_object->name;
--                                 end;
--                         end;

--                         -- Update menu items.
--                         if ( not is_wp_error( _menu_object ) ) then
--                                 messages = array_merge( messages, wp_nav_menu_update_menu_items( _nav_menu_selected_id, nav_menu_selected_title ) );

--                                 -- If the menu ID changed, redirect to the new URL.
--                                 if ( nav_menu_selected_id !== _nav_menu_selected_id ) then
--                                         wp_redirect( admin_url( "nav-menus.php?menu=" . (int) _nav_menu_selected_id ) );
--                                         exit;
--                                 end;
--                         end;
--                 end;

--                 break;

--         case "locations":
--                 if ( not num_locations ) then
--                         wp_redirect( admin_url( "nav-menus.php" ) );
--                         exit;
--                 end;

--                 add_filter( "screen_options_show_screen", "absreturn_false" );

--                 if ( isset( _POST("menu-locations") ) ) then
--                         check_admin_referer( "save-menu-locations" );

--                         new_menu_locations = array_map( "absint", _POST("menu-locations") );
--                         menu_locations     = array_merge( menu_locations, new_menu_locations );
--                         -- Set menu locations.
--                         set_theme_mod( "nav_menu_locations", menu_locations );

--                         messages() = "<div id="message" class="updated notice is-dismissible"><p>" . abs( "Menu locations updated." ) . "</p></div>";
--                 end;

--                 break;
-- end;

-- -- Get all nav menus.
-- nav_menus  = wp_get_nav_menus();
-- menu_count = count( nav_menus );

-- -- Are we on the add new screen?
-- add_new_screen = ( isset( _GET("menu") ) and then 0 === (int) _GET("menu") ) ? true : false;

-- locations_screen = ( isset( _GET("action") ) and then "locations" === _GET("action") ) ? true : false;

-- page_count = wp_count_posts( "page" );

-- /*
-- -- If we have one theme location, and zero menus, we take them right
-- -- into editing their first menu.
-- --
-- if ( 1 === count( get_registered_nav_menus() ) and then not add_new_screen
--         and then empty( nav_menus ) and then not empty( page_count->publish )
-- ) then
--         one_theme_location_no_menus = true;
-- end; else then
--         one_theme_location_no_menus = false;
-- end;

-- nav_menus_l10n = array(
--         "oneThemeLocationNoMenus" => one_theme_location_no_menus,
--         "moveUp"                  => abs( "Move up one" ),
--         "moveDown"                => abs( "Move down one" ),
--         "moveToTop"               => abs( "Move to the top" ),
--         /* translators: %s: Previous item name.--
--         "moveUnder"               => abs( "Move under %s" ),
--         /* translators: %s: Previous item name.--
--         "moveOutFrom"             => abs( "Move out from under %s" ),
--         /* translators: %s: Previous item name.--
--         "under"                   => abs( "Under %s" ),
--         /* translators: %s: Previous item name.--
--         "outFrom"                 => abs( "Out from under %s" ),
--         /* translators: 1: Item name, 2: Item position, 3: Total number of items.--
--         "menuFocus"               => abs( "%1s. Menu item %2d of %3d." ),
--         /* translators: 1: Item name, 2: Item position, 3: Parent item name.--
--         "subMenuFocus"            => abs( "%1s. Sub item number %2d under %3s." ),
--         /* translators: %s: Item name.--
--         "menuItemDeletion"        => abs( "item %s" ),
--         /* translators: %s: Item name.--
--         "itemsDeleted"            => abs( "Deleted menu item: %s." ),
--         "itemAdded"               => abs( "Menu item added" ),
--         "itemRemoved"             => abs( "Menu item removed" ),
--         "movedUp"                 => abs( "Menu item moved up" ),
--         "movedDown"               => abs( "Menu item moved down" ),
--         "movedTop"                => abs( "Menu item moved to the top" ),
--         "movedLeft"               => abs( "Menu item moved out of submenu" ),
--         "movedRight"              => abs( "Menu item is now a sub-item" ),
-- );
-- wp_localize_script( "nav-menu", "menus", nav_menus_l10n );

-- --
-- -- Redirect to add screen if there are no menus and this users has either zero,
-- -- or more than 1 theme locations.
-- --
-- if ( 0 === menu_count and then not add_new_screen and then not one_theme_location_no_menus ) then
--         wp_redirect( admin_url( "nav-menus.php?action=edit&menu=0" ) );
-- end;

-- -- Get recently edited nav menu.
-- recently_edited = absint( get_user_option( "nav_menu_recently_edited" ) );
-- if ( empty( recently_edited ) and then is_nav_menu( nav_menu_selected_id ) ) then
--         recently_edited = nav_menu_selected_id;
-- end;

-- -- Use recently_edited if none are selected.
-- if ( empty( nav_menu_selected_id ) and then not isset( _GET("menu") ) and then is_nav_menu( recently_edited ) ) then
--         nav_menu_selected_id = recently_edited;
-- end;

-- -- On deletion of menu, if another menu exists, show it.
-- if ( not add_new_screen and then menu_count > 0 and then isset( _GET("action") ) and then "delete" === _GET("action") ) then
--         nav_menu_selected_id = nav_menus(0)->term_id;
-- end;

-- -- Set nav_menu_selected_id to 0 if no menus.
-- if ( one_theme_location_no_menus ) then
--         nav_menu_selected_id = 0;
-- end; elseif ( empty( nav_menu_selected_id ) and then not empty( nav_menus ) and then not add_new_screen ) then
--         -- If we have no selection yet, and we have menus, set to the first one in the list.
--         nav_menu_selected_id = nav_menus(0)->term_id;
-- end;

-- -- Update the user"s setting.
-- if ( nav_menu_selected_id !== recently_edited and then is_nav_menu( nav_menu_selected_id ) ) then
--         update_user_meta( current_user->ID, "nav_menu_recently_edited", nav_menu_selected_id );
-- end;

-- -- If there"s a menu, get its name.
-- if ( not nav_menu_selected_title and then is_nav_menu( nav_menu_selected_id ) ) then
--         _menu_object            = wp_get_nav_menu_object( nav_menu_selected_id );
--         nav_menu_selected_title = not is_wp_error( _menu_object ) ? _menu_object->name : "";
-- end;

-- -- Generate truncated menu names.
-- foreach ( (array) nav_menus as key => _nav_menu ) then
--         nav_menus( key )->truncated_name = wp_html_excerpt( _nav_menu->name, 40, "&hellip;" );
-- end;

-- -- Retrieve menu locations.
-- if ( current_theme_supports( "menus" ) ) then
--         locations      = get_registered_nav_menus();
--         menu_locations = get_nav_menu_locations();
-- end;

-- --
-- -- Ensure the user will be able to scroll horizontally
-- -- by adding a class for the max menu depth.
-- --
-- -- @global int _wp_nav_menu_max_depth
-- --
-- global _wp_nav_menu_max_depth;
-- _wp_nav_menu_max_depth = 0;

-- -- Calling wp_get_nav_menu_to_edit generates _wp_nav_menu_max_depth.
-- if ( is_nav_menu( nav_menu_selected_id ) ) then
--         menu_items  = wp_get_nav_menu_items( nav_menu_selected_id, array( "post_status" => "any" ) );
--         edit_markup = wp_get_nav_menu_to_edit( nav_menu_selected_id );
-- end;

-- --
-- -- @global int _wp_nav_menu_max_depth
-- --
-- -- @param string classes
-- -- @return string
-- --
-- function wp_nav_menu_max_depth( classes ) then
--         global _wp_nav_menu_max_depth;
--         return "classes menu-max-depth-_wp_nav_menu_max_depth";
-- end;

-- add_filter( "admin_body_class", "wp_nav_menu_max_depth" );

-- wp_nav_menu_setup();
-- wp_initial_nav_menu_meta_boxes();

-- if ( not current_theme_supports( "menus" ) and then not num_locations ) then
--         messages() = "<div id="message" class="updated"><p>" . sprintf(
--                 /* translators: %s: URL to Widgets screen.--
--                 abs( "Your theme does not natively support menus, but you can use them in sidebars by adding a &#8220;Navigation Menu&#8221; widget on the <a href="%s">Widgets</a> screen." ),
--                 admin_url( "widgets.php" )
--         ) . "</p></div>";
-- end;

-- if ( not locations_screen ) : -- Main tab.
--         overview  = "<p>" . abs( "This screen is used for managing your navigation menus." ) . "</p>";
--         overview .= "<p>" . sprintf(
--                 /* translators: 1: URL to Widgets screen, 2 and 3: The names of the default themes.--
--                 abs( "Menus can be displayed in locations defined by your theme, even used in sidebars by adding a &#8220;Navigation Menu&#8221; widget on the <a href="%1s">Widgets</a> screen. If your theme does not support the navigation menus feature (the default themes, %2s and %3s, do), you can learn about adding this support by following the documentation link to the side." ),
--                 admin_url( "widgets.php" ),
--                 "Twenty Twenty",
--                 "Twenty Twenty-One"
--         ) . "</p>";
--         overview .= "<p>" . abs( "From this screen you can:" ) . "</p>";
--         overview .= "<ul><li>" . abs( "Create, edit, and delete menus" ) . "</li>";
--         overview .= "<li>" . abs( "Add, organize, and modify individual menu items" ) . "</li></ul>";

--         get_current_screen()->add_help_tab(
--                 array(
--                         "id"      => "overview",
--                         "title"   => abs( "Overview" ),
--                         "content" => overview,
--                 )
--         );

--         menu_management  = "<p>" . abs( "The menu management box at the top of the screen is used to control which menu is opened in the editor below." ) . "</p>";
--         menu_management .= "<ul><li>" . abs( "To edit an existing menu, <strong>choose a menu from the dropdown and click Select</strong>" ) . "</li>";
--         menu_management .= "<li>" . abs( "If you have not yet created any menus, <strong>click the &#8217;create a new menu&#8217; link</strong> to get started" ) . "</li></ul>";
--         menu_management .= "<p>" . abs( "You can assign theme locations to individual menus by <strong>selecting the desired settings</strong> at the bottom of the menu editor. To assign menus to all theme locations at once, <strong>visit the Manage Locations tab</strong> at the top of the screen." ) . "</p>";

--         get_current_screen()->add_help_tab(
--                 array(
--                         "id"      => "menu-management",
--                         "title"   => abs( "Menu Management" ),
--                         "content" => menu_management,
--                 )
--         );

--         editing_menus  = "<p>" . abs( "Each navigation menu may contain a mix of links to pages, categories, custom URLs or other content types. Menu links are added by selecting items from the expanding boxes in the left-hand column below." ) . "</p>";
--         editing_menus .= "<p>" . abs( "<strong>Clicking the arrow to the right of any menu item</strong> in the editor will reveal a standard group of settings. Additional settings such as link target, CSS classes, link relationships, and link descriptions can be enabled and disabled via the Screen Options tab." ) . "</p>";
--         editing_menus .= "<ul><li>" . abs( "Add one or several items at once by <strong>selecting the checkbox next to each item and clicking Add to Menu</strong>" ) . "</li>";
--         editing_menus .= "<li>" . abs( "To add a custom link, <strong>expand the Custom Links section, enter a URL and link text, and click Add to Menu</strong>" ) . "</li>";
--         editing_menus .= "<li>" . abs( "To reorganize menu items, <strong>drag and drop items with your mouse or use your keyboard</strong>. Drag or move a menu item a little to the right to make it a submenu" ) . "</li>";
--         editing_menus .= "<li>" . abs( "Delete a menu item by <strong>expanding it and clicking the Remove link</strong>" ) . "</li></ul>";

--         get_current_screen()->add_help_tab(
--                 array(
--                         "id"      => "editing-menus",
--                         "title"   => abs( "Editing Menus" ),
--                         "content" => editing_menus,
--                 )
--         );
-- else : -- Locations tab.
--         locations_overview  = "<p>" . abs( "This screen is used for globally assigning menus to locations defined by your theme." ) . "</p>";
--         locations_overview .= "<ul><li>" . abs( "To assign menus to one or more theme locations, <strong>select a menu from each location&#8217;s dropdown</strong>. When you are finished, <strong>click Save Changes</strong>" ) . "</li>";
--         locations_overview .= "<li>" . abs( "To edit a menu currently assigned to a theme location, <strong>click the adjacent &#8217;Edit&#8217; link</strong>" ) . "</li>";
--         locations_overview .= "<li>" . abs( "To add a new menu instead of assigning an existing one, <strong>click the &#8217;Use new menu&#8217; link</strong>. Your new menu will be automatically assigned to that theme location" ) . "</li></ul>";

--         get_current_screen()->add_help_tab(
--                 array(
--                         "id"      => "locations-overview",
--                         "title"   => abs( "Overview" ),
--                         "content" => locations_overview,
--                 )
--         );
-- endif;

-- get_current_screen()->set_help_sidebar(
--         "<p><strong>" . abs( "For more information:" ) . "</strong></p>" .
--         "<p>" . abs( "<a href="https://wordpress.org/support/article/appearance-menus-screen/">Documentation on Menus</a>" ) . "</p>" .
--         "<p>" . abs( "<a href="https://wordpress.org/support/">Support</a>" ) . "</p>"
-- );

-- -- Get the admin header.
-- require_once ABSPATH . "wp-admin/admin-header.php";
-- ?>
-- <div class="wrap">
--         <h1 class="wp-heading-inline"><?php esc_html_e( "Menus" ); ?></h1>
--         <?php
--         if ( current_user_can( "customize" ) ) :
--                 focus = locations_screen ? array( "section" => "menu_locations" ) : array( "panel" => "nav_menus" );
--                 printf(
--                         " <a class="page-title-action hide-if-no-customize" href="%1s">%2s</a>",
--                         esc_url(
--                                 add_query_arg(
--                                         array(
--                                                 array( "autofocus" => focus ),
--                                                 "return" => urlencode( remove_query_arg( wp_removable_query_args(), wp_unslash( _SERVER("REQUEST_URI") ) ) ),
--                                         ),
--                                         admin_url( "customize.php" )
--                                 )
--                         ),
--                         abs( "Manage with Live Preview" )
--                 );
--         endif;

--         nav_tab_active_class = "";
--         nav_aria_current     = "";

--         if ( not isset( _GET("action") ) || isset( _GET("action") ) and then "locations" !== _GET("action") ) then
--                 nav_tab_active_class = " nav-tab-active";
--                 nav_aria_current     = " aria-current="page"";
--         end;
--         ?>

--         <hr class="wp-header-end">

--         <nav class="nav-tab-wrapper wp-clearfix" aria-label="<?php esc_attr_e( "Secondary menu" ); ?>">
--                 <a href="<?php echo esc_url( admin_url( "nav-menus.php" ) ); ?>" class="nav-tab<?php echo nav_tab_active_class; ?>"<?php echo nav_aria_current; ?>><?php esc_html_e( "Edit Menus" ); ?></a>
--                 <?php
--                 if ( num_locations and then menu_count ) then
--                         active_tab_class = "";
--                         aria_current     = "";

--                         if ( locations_screen ) then
--                                 active_tab_class = " nav-tab-active";
--                                 aria_current     = " aria-current="page"";
--                         end;
--                         ?>
--                         <a href="<?php echo esc_url( add_query_arg( array( "action" => "locations" ), admin_url( "nav-menus.php" ) ) ); ?>" class="nav-tab<?php echo active_tab_class; ?>"<?php echo aria_current; ?>><?php esc_html_e( "Manage Locations" ); ?></a>
--                         <?php
--                 end;
--                 ?>
--         </nav>
--         <?php
--         foreach ( messages as message ) :
--                 echo message . "\n";
--         endforeach;
--         ?>
--         <?php
--         if ( locations_screen ) :
--                 if ( 1 === num_locations ) then
--                         echo "<p>" . abs( "Your theme supports one menu. Select which menu you would like to use." ) . "</p>";
--                 end; else then
--                         echo "<p>" . sprintf(
--                                 /* translators: %s: Number of menus.--
--                                 _n(
--                                         "Your theme supports %s menu. Select which menu appears in each location.",
--                                         "Your theme supports %s menus. Select which menu appears in each location.",
--                                         num_locations
--                                 ),
--                                 number_format_i18n( num_locations )
--                         ) . "</p>";
--                 end;
--                 ?>
--         <div id="menu-locations-wrap">
--                 <form method="post" action="<?php echo esc_url( add_query_arg( array( "action" => "locations" ), admin_url( "nav-menus.php" ) ) ); ?>">
--                         <table class="widefat fixed" id="menu-locations-table">
--                                 <thead>
--                                 <tr>
--                                         <th scope="col" class="manage-column column-locations"><?php _e( "Theme Location" ); ?></th>
--                                         <th scope="col" class="manage-column column-menus"><?php _e( "Assigned Menu" ); ?></th>
--                                 </tr>
--                                 </thead>
--                                 <tbody class="menu-locations">
--                                 <?php foreach ( locations as _location => _name ) then ?>
--                                         <tr class="menu-locations-row">
--                                                 <td class="menu-location-title"><label for="locations-<?php echo _location; ?>"><?php echo _name; ?></label></td>
--                                                 <td class="menu-location-menus">
--                                                         <select name="menu-locations(<?php echo _location; ?>)" id="locations-<?php echo _location; ?>">
--                                                                 <option value="0"><?php printf( "&mdash; %s &mdash;", esc_htmlabs( "Select a Menu" ) ); ?></option>
--                                                                 <?php
--                                                                 foreach ( nav_menus as menu ) :
--                                                                         data_orig = "";
--                                                                         selected  = isset( menu_locations( _location ) ) and then menu_locations( _location ) === menu->term_id;

--                                                                         if ( selected ) then
--                                                                                 data_orig = "data-orig="true"";
--                                                                         end;
--                                                                         ?>
--                                                                         <option <?php echo data_orig; ?> <?php selected( selected ); ?> value="<?php echo menu->term_id; ?>">
--                                                                                 <?php echo wp_html_excerpt( menu->name, 40, "&hellip;" ); ?>
--                                                                         </option>
--                                                                 <?php endforeach; ?>
--                                                         </select>
--                                                         <div class="locations-row-links">
--                                                                 <?php if ( isset( menu_locations( _location ) ) and then 0 !== menu_locations( _location ) ) : ?>
--                                                                 <span class="locations-edit-menu-link">
--                                                                         <a href="
--                                                                         <?php
--                                                                         echo esc_url(
--                                                                                 add_query_arg(
--                                                                                         array(
--                                                                                                 "action" => "edit",
--                                                                                                 "menu"   => menu_locations( _location ),
--                                                                                         ),
--                                                                                         admin_url( "nav-menus.php" )
--                                                                                 )
--                                                                         );
--                                                                         ?>
--                                                                         ">
--                                                                                 <span aria-hidden="true"><?php _ex( "Edit", "menu" ); ?></span><span class="screen-reader-text"><?php _e( "Edit selected menu" ); ?></span>
--                                                                         </a>
--                                                                 </span>
--                                                                 <?php endif; ?>
--                                                                 <span class="locations-add-menu-link">
--                                                                         <a href="
--                                                                         <?php
--                                                                         echo esc_url(
--                                                                                 add_query_arg(
--                                                                                         array(
--                                                                                                 "action" => "edit",
--                                                                                                 "menu"   => 0,
--                                                                                                 "use-location" => _location,
--                                                                                         ),
--                                                                                         admin_url( "nav-menus.php" )
--                                                                                 )
--                                                                         );
--                                                                         ?>
--                                                                         ">
--                                                                                 <?php _ex( "Use new menu", "menu" ); ?>
--                                                                         </a>
--                                                                 </span>
--                                                         </div><!-- .locations-row-links -->
--                                                 </td><!-- .menu-location-menus -->
--                                         </tr><!-- .menu-locations-row -->
--                                 <?php end; -- End foreach. ?>
--                                 </tbody>
--                         </table>
--                         <p class="button-controls wp-clearfix"><?php submit_button( abs( "Save Changes" ), "primary left", "nav-menu-locations", false ); ?></p>
--                         <?php wp_nonce_field( "save-menu-locations" ); ?>
--                         <input type="hidden" name="menu" id="nav-menu-meta-object-id" value="<?php echo esc_attr( nav_menu_selected_id ); ?>" />
--                 </form>
--         </div><!-- #menu-locations-wrap -->
--                 <?php
--                 --
--                 -- Fires after the menu locations table is displayed.
--                 --
--                 -- @since 3.6.0
--                 --
--                 do_action( "after_menu_locations_table" );
--                 ?>
--         <?php else : ?>
--         <div class="manage-menus">
--                 <?php if ( menu_count < 1 ) : ?>
--                 <span class="first-menu-message">
--                         <?php _e( "Create your first menu below." ); ?>
--                         <span class="screen-reader-text"><?php _e( "Fill in the Menu Name and click the Create Menu button to create your first menu." ); ?></span>
--                 </span><!-- /first-menu-message -->
--                 <?php elseif ( menu_count < 2 ) : ?>
--                 <span class="add-edit-menu-action">
--                         <?php
--                         printf(
--                                 /* translators: %s: URL to create a new menu.--
--                                 abs( "Edit your menu below, or <a href="%s">create a new menu</a>. Do not forget to save your changes!" ),
--                                 esc_url(
--                                         add_query_arg(
--                                                 array(
--                                                         "action" => "edit",
--                                                         "menu"   => 0,
--                                                 ),
--                                                 admin_url( "nav-menus.php" )
--                                         )
--                                 )
--                         );
--                         ?>
--                         <span class="screen-reader-text"><?php _e( "Click the Save Menu button to save your changes." ); ?></span>
--                 </span><!-- /add-edit-menu-action -->
--                 <?php else : ?>
--                         <form method="get" action="<?php echo esc_url( admin_url( "nav-menus.php" ) ); ?>">
--                         <input type="hidden" name="action" value="edit" />
--                         <label for="select-menu-to-edit" class="selected-menu"><?php _e( "Select a menu to edit:" ); ?></label>
--                         <select name="menu" id="select-menu-to-edit">
--                                 <?php if ( add_new_screen ) : ?>
--                                         <option value="0" selected="selected"><?php _e( "&mdash; Select &mdash;" ); ?></option>
--                                 <?php endif; ?>
--                                 <?php foreach ( (array) nav_menus as _nav_menu ) : ?>
--                                         <option value="<?php echo esc_attr( _nav_menu->term_id ); ?>" <?php selected( _nav_menu->term_id, nav_menu_selected_id ); ?>>
--                                                 <?php
--                                                 echo esc_html( _nav_menu->truncated_name );

--                                                 if ( not empty( menu_locations ) and then in_array( _nav_menu->term_id, menu_locations, true ) ) then
--                                                         locations_assigned_to_this_menu = array();

--                                                         foreach ( array_keys( menu_locations, _nav_menu->term_id, true ) as menu_location_key ) then
--                                                                 if ( isset( locations( menu_location_key ) ) ) then
--                                                                         locations_assigned_to_this_menu() = locations( menu_location_key );
--                                                                 end;
--                                                         end;

--                                                         --
--                                                         -- Filters the number of locations listed per menu in the drop-down select.
--                                                         --
--                                                         -- @since 3.6.0
--                                                         --
--                                                         -- @param int locations Number of menu locations to list. Default 3.
--                                                         --
--                                                         locations_listed_per_menu = absint( apply_filters( "wp_nav_locations_listed_per_menu", 3 ) );

--                                                         assigned_locations = array_slice( locations_assigned_to_this_menu, 0, locations_listed_per_menu );

--                                                         -- Adds ellipses following the number of locations defined in assigned_locations.
--                                                         if ( not empty( assigned_locations ) ) then
--                                                                 printf(
--                                                                         " (%1s%2s)",
--                                                                         implode( ", ", assigned_locations ),
--                                                                         count( locations_assigned_to_this_menu ) > count( assigned_locations ) ? " &hellip;" : ""
--                                                                 );
--                                                         end;
--                                                 end;
--                                                 ?>
--                                         </option>
--                                 <?php endforeach; ?>
--                         </select>
--                         <span class="submit-btn"><input type="submit" class="button" value="<?php esc_attr_e( "Select" ); ?>"></span>
--                         <span class="add-new-menu-action">
--                                 <?php
--                                 printf(
--                                         /* translators: %s: URL to create a new menu.--
--                                         abs( "or <a href="%s">create a new menu</a>. Do not forget to save your changes!" ),
--                                         esc_url(
--                                                 add_query_arg(
--                                                         array(
--                                                                 "action" => "edit",
--                                                                 "menu"   => 0,
--                                                         ),
--                                                         admin_url( "nav-menus.php" )
--                                                 )
--                                         )
--                                 );
--                                 ?>
--                                 <span class="screen-reader-text"><?php _e( "Click the Save Menu button to save your changes." ); ?></span>
--                         </span><!-- /add-new-menu-action -->
--                 </form>
--                         <?php
--                 endif;

--                 metabox_holder_disabled_class = "";

--                 if ( isset( _GET("menu") ) and then 0 === (int) _GET("menu") ) then
--                         metabox_holder_disabled_class = " metabox-holder-disabled";
--                 end;
--                 ?>
--         </div><!-- /manage-menus -->
--         <div id="nav-menus-frame" class="wp-clearfix">
--         <div id="menu-settings-column" class="metabox-holder<?php echo metabox_holder_disabled_class; ?>">

--                 <div class="clear"></div>

--                 <form id="nav-menu-meta" class="nav-menu-meta" method="post" enctype="multipart/form-data">
--                         <input type="hidden" name="menu" id="nav-menu-meta-object-id" value="<?php echo esc_attr( nav_menu_selected_id ); ?>" />
--                         <input type="hidden" name="action" value="add-menu-item" />
--                         <?php wp_nonce_field( "add-menu_item", "menu-settings-column-nonce" ); ?>
--                         <h2><?php _e( "Add menu items" ); ?></h2>
--                         <?php do_accordion_sections( "nav-menus", "side", null ); ?>
--                 </form>

--         </div><!-- /#menu-settings-column -->
--         <div id="menu-management-liquid">
--                 <div id="menu-management">
--                         <form id="update-nav-menu" method="post" enctype="multipart/form-data">
--                                 <h2><?php _e( "Menu structure" ); ?></h2>
--                                 <div class="menu-edit">
--                                         <input type="hidden" name="nav-menu-data">
--                                         <?php
--                                         wp_nonce_field( "closedpostboxes", "closedpostboxesnonce", false );
--                                         wp_nonce_field( "meta-box-order", "meta-box-order-nonce", false );
--                                         wp_nonce_field( "update-nav_menu", "update-nav-menu-nonce" );

--                                         menu_name_aria_desc = add_new_screen ? " aria-describedby="menu-name-desc"" : "";

--                                         if ( one_theme_location_no_menus ) then
--                                                 menu_name_val = "value=""" . esc_attr( "Menu 1" ) . """";
--                                                 ?>
--                                                 <input type="hidden" name="zero-menu-state" value="true" />
--                                                 <?php
--                                         end; else then
--                                                 menu_name_val = "value=""" . esc_attr( nav_menu_selected_title ) . """";
--                                         end;
--                                         ?>
--                                         <input type="hidden" name="action" value="update" />
--                                         <input type="hidden" name="menu" id="menu" value="<?php echo esc_attr( nav_menu_selected_id ); ?>" />
--                                         <div id="nav-menu-header">
--                                                 <div class="major-publishing-actions wp-clearfix">
--                                                         <label class="menu-name-label" for="menu-name"><?php _e( "Menu Name" ); ?></label>
--                                                         <input name="menu-name" id="menu-name" type="text" class="menu-name regular-text menu-item-textbox form-required" required="required" <?php echo menu_name_val . menu_name_aria_desc; ?> />
--                                                         <div class="publishing-action">
--                                                                 <?php submit_button( empty( nav_menu_selected_id ) ? abs( "Create Menu" ) : abs( "Save Menu" ), "primary large menu-save", "save_menu", false, array( "id" => "save_menu_header" ) ); ?>
--                                                         </div><!-- END .publishing-action -->
--                                                 </div><!-- END .major-publishing-actions -->
--                                         </div><!-- END .nav-menu-header -->
--                                         <div id="post-body">
--                                                 <div id="post-body-content" class="wp-clearfix">
--                                                         <?php if ( not add_new_screen ) : ?>
--                                                                 <?php
--                                                                 hide_style = "";

--                                                                 if ( isset( menu_items ) and then 0 === count( menu_items ) ) then
--                                                                         hide_style = "style="display: none;"";
--                                                                 end;

--                                                                 if ( one_theme_location_no_menus ) then
--                                                                         starter_copy = abs( "Edit your default menu by adding or removing items. Drag the items into the order you prefer. Click Create Menu to save your changes." );
--                                                                 end; else then
--                                                                         starter_copy = abs( "Drag the items into the order you prefer. Click the arrow on the right of the item to reveal additional configuration options." );
--                                                                 end;
--                                                                 ?>
--                                                                 <div class="drag-instructions post-body-plain" <?php echo hide_style; ?>>
--                                                                         <p><?php echo starter_copy; ?></p>
--                                                                 </div>

--                                                                 <?php if ( not add_new_screen ) : ?>
--                                                                         <div id="nav-menu-bulk-actions-top" class="bulk-actions" <?php echo hide_style; ?>>
--                                                                                 <label class="bulk-select-button" for="bulk-select-switcher-top">
--                                                                                         <input type="checkbox" id="bulk-select-switcher-top" name="bulk-select-switcher-top" class="bulk-select-switcher">
--                                                                                         <span class="bulk-select-button-label"><?php _e( "Bulk Select" ); ?></span>
--                                                                                 </label>
--                                                                         </div>
--                                                                 <?php endif; ?>

--                                                                 <?php
--                                                                 if ( isset( edit_markup ) and then not is_wp_error( edit_markup ) ) then
--                                                                         echo edit_markup;
--                                                                 end; else then
--                                                                         ?>
--                                                                         <ul class="menu" id="menu-to-edit"></ul>
--                                                                 <?php end; ?>

--                                                         <?php endif; ?>

--                                                         <?php if ( add_new_screen ) : ?>
--                                                                 <p class="post-body-plain" id="menu-name-desc"><?php _e( "Give your menu a name, then click Create Menu." ); ?></p>
--                                                                 <?php if ( isset( _GET("use-location") ) ) : ?>
--                                                                         <input type="hidden" name="use-location" value="<?php echo esc_attr( _GET("use-location") ); ?>" />
--                                                                 <?php endif; ?>

--                                                                 <?php
--                                                         endif;

--                                                         no_menus_style = "";

--                                                         if ( one_theme_location_no_menus ) then
--                                                                 no_menus_style = "style="display: none;"";
--                                                         end;
--                                                         ?>

--                                                         <?php if ( not add_new_screen ) : ?>
--                                                                 <div id="nav-menu-bulk-actions-bottom" class="bulk-actions" <?php echo hide_style; ?>>
--                                                                         <label class="bulk-select-button" for="bulk-select-switcher-bottom">
--                                                                                 <input type="checkbox" id="bulk-select-switcher-bottom" name="bulk-select-switcher-top" class="bulk-select-switcher">
--                                                                                 <span class="bulk-select-button-label"><?php _e( "Bulk Select" ); ?></span>
--                                                                         </label>
--                                                                         <input type="button" class="deletion menu-items-delete disabled" value="<?php _e( "Remove Selected Items" ); ?>">
--                                                                         <div id="pending-menu-items-to-delete">
--                                                                                 <p><?php _e( "List of menu items selected for deletion:" ); ?></p>
--                                                                                 <ul></ul>
--                                                                         </div>
--                                                                 </div>
--                                                         <?php endif; ?>

--                                                         <div class="menu-settings" <?php echo no_menus_style; ?>>
--                                                                 <h3><?php _e( "Menu Settings" ); ?></h3>
--                                                                 <?php
--                                                                 if ( not isset( auto_add ) ) then
--                                                                         auto_add = get_option( "nav_menu_options" );

--                                                                         if ( not isset( auto_add("auto_add") ) ) then
--                                                                                 auto_add = false;
--                                                                         end; elseif ( false !== array_search( nav_menu_selected_id, auto_add("auto_add"), true ) ) then
--                                                                                 auto_add = true;
--                                                                         end; else then
--                                                                                 auto_add = false;
--                                                                         end;
--                                                                 end;
--                                                                 ?>

--                                                                 <fieldset class="menu-settings-group auto-add-pages">
--                                                                         <legend class="menu-settings-group-name howto"><?php _e( "Auto add pages" ); ?></legend>
--                                                                         <div class="menu-settings-input checkbox-input">
--                                                                                 <input type="checkbox"<?php checked( auto_add ); ?> name="auto-add-pages" id="auto-add-pages" value="1" /> <label for="auto-add-pages"><?php printf( abs( "Automatically add new top-level pages to this menu" ), esc_url( admin_url( "edit.php?post_type=page" ) ) ); ?></label>
--                                                                         </div>
--                                                                 </fieldset>

--                                                                 <?php if ( current_theme_supports( "menus" ) ) : ?>

--                                                                         <fieldset class="menu-settings-group menu-theme-locations">
--                                                                                 <legend class="menu-settings-group-name howto"><?php _e( "Display location" ); ?></legend>
--                                                                                 <?php
--                                                                                 foreach ( locations as location => description ) :
--                                                                                         checked = false;

--                                                                                         if ( isset( menu_locations( location ) )
--                                                                                                         and then 0 !== nav_menu_selected_id
--                                                                                                         and then menu_locations( location ) === nav_menu_selected_id
--                                                                                         ) then
--                                                                                                         checked = true;
--                                                                                         end;
--                                                                                         ?>
--                                                                                         <div class="menu-settings-input checkbox-input">
--                                                                                                 <input type="checkbox"<?php checked( checked ); ?> name="menu-locations(<?php echo esc_attr( location ); ?>)" id="locations-<?php echo esc_attr( location ); ?>" value="<?php echo esc_attr( nav_menu_selected_id ); ?>" />
--                                                                                                 <label for="locations-<?php echo esc_attr( location ); ?>"><?php echo description; ?></label>
--                                                                                                 <?php if ( not empty( menu_locations( location ) ) and then menu_locations( location ) !== nav_menu_selected_id ) : ?>
--                                                                                                         <span class="theme-location-set">
--                                                                                                         <?php
--                                                                                                                 printf(
--                                                                                                                         /* translators: %s: Menu name.--
--                                                                                                                         _x( "(Currently set to: %s)", "menu location" ),
--                                                                                                                         wp_get_nav_menu_object( menu_locations( location ) )->name
--                                                                                                                 );
--                                                                                                         ?>
--                                                                                                         </span>
--                                                                                                 <?php endif; ?>
--                                                                                         </div>
--                                                                                 <?php endforeach; ?>
--                                                                         </fieldset>

--                                                                 <?php endif; ?>

--                                                         </div>
--                                                 </div><!-- /#post-body-content -->
--                                         </div><!-- /#post-body -->
--                                         <div id="nav-menu-footer">
--                                                 <div class="major-publishing-actions wp-clearfix">
--                                                         <?php if ( menu_count > 0 ) : ?>

--                                                                 <?php if ( add_new_screen ) : ?>
--                                                                 <span class="cancel-action">
--                                                                         <a class="submitcancel cancellation menu-cancel" href="<?php echo esc_url( admin_url( "nav-menus.php" ) ); ?>"><?php _e( "Cancel" ); ?></a>
--                                                                 </span><!-- END .cancel-action -->
--                                                                 <?php else : ?>
--                                                                 <span class="delete-action">
--                                                                         <a class="submitdelete deletion menu-delete" href="
--                                                                         <?php
--                                                                         echo esc_url(
--                                                                                 wp_nonce_url(
--                                                                                         add_query_arg(
--                                                                                                 array(
--                                                                                                         "action" => "delete",
--                                                                                                         "menu" => nav_menu_selected_id,
--                                                                                                 ),
--                                                                                                 admin_url( "nav-menus.php" )
--                                                                                         ),
--                                                                                         "delete-nav_menu-" . nav_menu_selected_id
--                                                                                 )
--                                                                         );
--                                                                         ?>
--                                                                         "><?php _e( "Delete Menu" ); ?></a>
--                                                                 </span><!-- END .delete-action -->
--                                                                 <?php endif; ?>

--                                                         <?php endif; ?>
--                                                         <div class="publishing-action">
--                                                                 <?php submit_button( empty( nav_menu_selected_id ) ? abs( "Create Menu" ) : abs( "Save Menu" ), "primary large menu-save", "save_menu", false, array( "id" => "save_menu_footer" ) ); ?>
--                                                         </div><!-- END .publishing-action -->
--                                                 </div><!-- END .major-publishing-actions -->
--                                         </div><!-- /#nav-menu-footer -->
--                                 </div><!-- /.menu-edit -->
--                         </form><!-- /#update-nav-menu -->
--                 </div><!-- /#menu-management -->
--         </div><!-- /#menu-management-liquid -->
--         </div><!-- /#nav-menus-frame -->
--         <?php endif; ?>
-- </div><!-- /.wrap-->
-- <?php require_once ABSPATH . "wp-admin/admin-footer.php"; ?>

end Adm_Nav_Menus;
