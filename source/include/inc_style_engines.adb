--
-- Style engine: Public functions
--
-- This file contains a variety of public functions developers can use to interact with
-- the Style Engine API.
--
-- @package WordPress
-- @subpackage StyleEngine
-- @since 6.1.0
--

with Style_Class_Wp_Style_Engines;

package body Inc_Style_Engines
is

   -------------------------------------------------
   -- Wp_Style_Engine_Get_Stylesheet_From_Context --
   -------------------------------------------------

   function Wp_Style_Engine_Get_Stylesheet_From_Context
              (Context : String;
               Options : Array_Type := Empty_Array)
               return String
   is
      use Style_Class_Wp_Style_Engines;
   begin
      return
        Compile_Stylesheet_From_CSS_Rules -- WP_Style_Engine::
          (Get_Store (Context).Get_All_Rules, --  (),       -- WP_Style_Engine::
           Options);
   end Wp_Style_Engine_Get_Stylesheet_From_Context;

end Inc_Style_Engines;
