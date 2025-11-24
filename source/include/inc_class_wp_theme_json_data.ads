--
-- WP_Theme_JSON_Data class
--
-- @package WordPress
-- @subpackage Theme
-- @since 6.1.0
--

with Ada.Strings.Unbounded;

with Arrays;

with Inc_Class_Wp_Theme_JSON;

package Inc_Class_Wp_Theme_JSON_Data
is
   use Ada.Strings.Unbounded;
   use Arrays;

   --
   -- Class to provide access to update a theme.json structure.
   --
   -- #[AllowDynamicProperties]
   type Wp_Theme_JSON_Data is tagged
      record
         --
         -- Container of the data to update.
         --
         -- @since 6.1.0
         -- @var WP_Theme_JSON
         --
         -- private
         Theme_JSON : Inc_Class_Wp_Theme_JSON.Wp_Theme_JSON := -- null
           Inc_Class_Wp_Theme_JSON.Null_Theme_JSON;
         --
         -- The origin of the data: default, theme, user, etc.
         --
         -- @since 6.1.0
         -- @var string
         --
         -- private
         Origin : Unbounded_String;

      end record;

   --
   -- Constructor.
   --
   -- @since 6.1.0
   --
   -- @link https://developer.wordpress.org/block-editor/reference-guides/theme-json-reference/
   --
   -- @param array  $data   Array following the theme.json specification.
   -- @param string $origin The origin of the data: default, theme, user.
   --
   function X_Construct (Data   : Array_Type := Empty_Array;
                         Origin : String     := "theme")
                         return Wp_Theme_JSON_Data;

--         --
--         -- Updates the theme.json with the the given data.
--         --
--         -- @since 6.1.0
--         --
--         -- @param array $new_data Array following the theme.json specification.
--         --
--         -- @return WP_Theme_JSON_Data The own instance with access to the modified data.
--         --
--         public function update_with( $new_data ) then
--                 $this->theme_json->merge( new WP_Theme_JSON( $new_data, $this->origin ) );
--                 return $this;
--         end;

   --
   -- Returns an array containing the underlying data
   -- following the theme.json specification.
   --
   -- @since 6.1.0
   --
   -- @return array
   --
   function Get_Data (This : Wp_Theme_JSON_Data)
                      return Array_Type;
--                 return $this->theme_json->get_raw_data();
--         end;

end Inc_Class_Wp_Theme_JSON_Data;
