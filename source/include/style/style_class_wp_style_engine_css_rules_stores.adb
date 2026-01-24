--
-- WP_Style_Engine_CSS_Rules_Store
--
-- A store for WP_Style_Engine_CSS_Rule objects.
--
-- @package WordPress
-- @subpackage StyleEngine
-- @since 6.1.0
--

with UStrings;

package body Style_Class_Wp_Style_Engine_CSS_Rules_Stores
is

   ---------------
   -- Get_Store --
   ---------------

   function Get_Store (Store_Name : String := "default")
                       return Wp_Style_Engine_CSS_Rules_Store
   is
      use Store_Maps;
   begin
--    if ( ! is_string( store_name ) || empty( store_name ) ) then
--       return;
--    end if;

      if not Has_Element (Static_Stores.Find (Store_Name)) then
--    if not Isset (Static_Stores, Store_Name) then
         declare
            Store : Wp_Style_Engine_CSS_Rules_Store;
         begin
            -- Set the store name.
            Store.Set_Name (Store_Name);
            Static_Stores.Include (Key => Store_Name, New_Item => Store);
         end;
      end if;
      return Static_Stores (Store_Name);
   end Get_Store;

   --------------
   -- Set_Name --
   --------------

   procedure Set_Name (This : in out Wp_Style_Engine_CSS_Rules_Store;
                       Name : String)
   is
      use UStrings;
   begin
      This.Name := +Name;
   end Set_Name;

   ----------------
   -- Get_Stores --
   ----------------

   function Get_Stores
            return Store_Maps.Map
   is
   begin
      return Static_Stores;
   end Get_Stores;

--         --
--         -- Clears all stores from static::stores.
--         --
--         -- @since 6.1.0
--         --
--         -- @return void
--         --
--         public static function remove_all_stores() then
--                 static::stores = array();
--         end;

--         --
--         -- Sets the store name.
--         --
--         -- @since 6.1.0
--         --
--         -- @param string name The store name.
--         --
--         -- @return void
--         --
--         public function set_name( name ) then
--                 this.name = name;
--         end;

--         --
--         -- Gets the store name.
--         --
--         -- @since 6.1.0
--         --
--         -- @return string
--         --
--         public function get_name() then
--                 return this.name;
--         end;

   -------------------
   -- Get_All_Rules --
   -------------------

   function Get_All_Rules (This : Wp_Style_Engine_CSS_Rules_Store)
            return Style_Class_Wp_Style_Engine_CSS_Rules.Rule_Arrays.Vector
   is
   begin
      return This.Rules;
   end Get_All_Rules;

--         --
--         -- Gets a WP_Style_Engine_CSS_Rule object by its selector.
--         -- If the rule does not exist, it will be created.
--         --
--         -- @since 6.1.0
--         --
--         -- @param string selector The CSS selector.
--         --
--         -- @return WP_Style_Engine_CSS_Rule|void Returns a WP_Style_Engine_CSS_Rule object, or null if the selector is empty.
--         --
--         public function add_rule( selector ) then
--                 selector = trim( selector );

--                 // Bail early if there is no selector.
--                 if ( empty( selector ) ) then
--                         return;
--                 end;

--                 // Create the rule if it doesn't exist.
--                 if ( empty( this.rules[ selector ] ) ) then
--                         this.rules[ selector ] = new WP_Style_Engine_CSS_Rule( selector );
--                 end;

--                 return this.rules[ selector ];
--         end;

--         --
--         -- Removes a selector from the store.
--         --
--         -- @since 6.1.0
--         --
--         -- @param string selector The CSS selector.
--         --
--         -- @return void
--         --
--         public function remove_rule( selector ) then
--                 unset( this.rules[ selector ] );
--         end;
end Style_Class_Wp_Style_Engine_CSS_Rules_Stores;
