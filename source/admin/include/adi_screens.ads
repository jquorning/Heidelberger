--
-- WordPress Administration Screen API.
--
-- @package WordPress
-- @subpackage Administration
--

with Arrays;

with Adi_Class_Wp_Screens;

package Adi_Screens
is
   use Arrays;
--
-- Register and configure an admin screen option
--
-- @since 3.1.0
--
-- @param string option An option name.
-- @param mixed  args   Option-dependent arguments.
--
   procedure Add_Screen_Option (Option : String;
                                Args   : Array_Type := Empty_Array)
                                is null;

--
-- Get the current screen object
--
-- @since 3.1.0
--
-- @global WP_Screen current_screen WordPress current screen object.
--
-- @return WP_Screen|null Current screen object or null when screen not defined.
--
   function Get_Current_Screen
            return Adi_Class_Wp_Screens.Wp_Screen;

--
-- Set the current screen object
--
-- @since 3.0.0
--
-- @param string|WP_Screen hook_name Optional. The hook name (also known as the hook suffix) used to determine the screen,
--                                    or an existing screen object.
--
   procedure Set_Current_Screen (Hook_Name : String := "") is null;

end Adi_Screens;
