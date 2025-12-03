--
-- WP_Style_Engine_CSS_Rules_Store
--
-- A store for WP_Style_Engine_CSS_Rule objects.
--
-- @package WordPress
-- @subpackage StyleEngine
-- @since 6.1.0
--

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Strings.Unbounded;

-- with Arrays;

with Style_Class_Wp_Style_Engine_CSS_Rules;

package Style_Class_Wp_Style_Engine_CSS_Rules_Stores
is
   use Ada.Strings.Unbounded;
-- use Arrays;

   --
   -- Class WP_Style_Engine_CSS_Rules_Store.
   --
   -- Holds, sanitizes, processes and prints CSS declarations for the style engine.
   --
   -- @since 6.1.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Style_Engine_CSS_Rules_Store is tagged
      record
         --
         -- An array of named WP_Style_Engine_CSS_Rules_Store objects.
         --
         -- @static
         --
         -- @since 6.1.0
         -- @var WP_Style_Engine_CSS_Rules_Store[]
         --
         -- protected static stores = array();

         --
         -- The store name.
         --
         -- @since 6.1.0
         -- @var string
         --
         -- protected
         Name : Unbounded_String;

         --
         -- An array of CSS Rules objects assigned to the store.
         --
         -- @since 6.1.0
         -- @var WP_Style_Engine_CSS_Rule[]
         --
         -- protected
         Rules : Style_Class_Wp_Style_Engine_CSS_Rules.Rule_Arrays.Vector; -- Array_Type;
      end record;

   --
   -- Gets an instance of the store.
   --
   -- @since 6.1.0
   --
   -- @param string store_name The name of the store.
   --
   -- @return WP_Style_Engine_CSS_Rules_Store|void
   --
   -- public static
   function Get_Store (Store_Name : String := "default")
                       return Wp_Style_Engine_CSS_Rules_Store;
--                 if ( ! is_string( store_name ) || empty( store_name ) ) then
--                         return;
--                 end;
--                 if ( ! isset( static::stores[ store_name ] ) ) then
--                         static::stores[ store_name ] = new static();
--                         // Set the store name.
--                         static::stores[ store_name ].set_name( store_name );
--                 end;
--                 return static::stores[ store_name ];
--         end;

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

   --
   -- Sets the store name.
   --
   -- @since 6.1.0
   --
   -- @param string name The store name.
   --
   -- @return void
   --
   procedure Set_Name (This : in out Wp_Style_Engine_CSS_Rules_Store;
                       Name : String);
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

   --
   -- Gets an array of all rules.
   --
   -- @since 6.1.0
   --
   -- @return WP_Style_Engine_CSS_Rule[]
   --
   function Get_All_Rules (This : Wp_Style_Engine_CSS_Rules_Store)
            return Style_Class_Wp_Style_Engine_CSS_Rules.Rule_Arrays.Vector; -- Wp_Style_Engine_CSS_Rule; -- _Array;
--                 return this.rules;
--         end;

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

   package Store_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps
        (Key_Type     => String,
         Element_Type => Wp_Style_Engine_CSS_Rules_Store);
   --
   -- An array of named WP_Style_Engine_CSS_Rules_Store objects.
   --
   -- @static
   --
   -- @since 6.1.0
   -- @var WP_Style_Engine_CSS_Rules_Store[]
   --
   -- protected static
   Static_Stores : Store_Maps.Map;

   --
   -- Gets an array of all available stores.
   --
   -- @since 6.1.0
   --
   -- @return WP_Style_Engine_CSS_Rules_Store[]
   --
   -- public static
   function Get_Stores
            return Store_Maps.Map;
--                 return static::stores;
--         end;

end Style_Class_Wp_Style_Engine_CSS_Rules_Stores;
