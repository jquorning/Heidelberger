--
-- Robots template functions.
--
-- @package WordPress
-- @subpackage Robots
-- @since 5.7.0
--

package body Inc_Robots_Templates
is

   ------------------------------
   -- Wp_Robots_Sensitive_Page --
   ------------------------------

   function Wp_Robots_Sensitive_Page (Robots : Array_Type)
                                      return Array_Type
   is
      Robots_2 : Array_Type := Robots;
   begin
      Set (Robots_2, "noindex", From_Boolean (True));
      Set (Robots_2, "noarchive", From_Boolean (True));
      return Robots_2;
   end Wp_Robots_Sensitive_Page;

end Inc_Robots_Templates;
