--
-- StyleEngine: WP_Style_Engine class
--
-- This is the main class integrating all other WP_Style_Engine_* classes.
--
-- @package WordPress
-- @subpackage StyleEngine
-- @since 6.1.0
--

with Style_Class_Wp_Style_Engine_Processors;

package body Style_Class_Wp_Style_Engines
is

   ---------------
   -- Get_Store --
   ---------------

   function Get_Store (Store_Name : String)
            return Style_Class_Wp_Style_Engine_CSS_Rules_Stores.Wp_Style_Engine_CSS_Rules_Store
   is
   begin
      return Style_Class_Wp_Style_Engine_CSS_Rules_Stores.Get_Store (Store_Name); -- WP_Style_Engine_CSS_Rules_Store::
   end Get_Store;

   ---------------------------------------
   -- Compile_Stylesheet_From_CSS_Rules --
   ---------------------------------------

   function Compile_Stylesheet_From_CSS_Rules
              (CSS_Rules : Style_Class_Wp_Style_Engine_CSS_Rules.Rule_Arrays.Vector; -- Wp_Style_Engine_CSS_Rule; -- Array_Type;
               Options   : Array_Type := Empty_Array)
               return String
   is
      use Style_Class_Wp_Style_Engine_Processors;

      Processor : Wp_Style_Engine_Processor; -- ();
   begin
      Processor.Add_Rules (CSS_Rules);
      return Processor.Get_CSS (Options);
   end Compile_Stylesheet_From_CSS_Rules;

end Style_Class_Wp_Style_Engines;
