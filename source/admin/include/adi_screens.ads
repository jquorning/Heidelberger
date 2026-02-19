--
-- WordPress Administration Screen API.
--
-- @package WordPress
-- @subpackage Administration
--

with Arrays;
with Lists;

with Class_Screens;

package Adi_Screens
is
   use Arrays;
   use Lists;

   --
   -- Get the column headers for a screen
   --
   -- @since 2.7.0
   --
   -- @param string|WP_Screen screen The screen you want the headers for
   -- @return string[] The column header labels keyed by column ID.
   --
   function Get_Column_Headers (Screen : Class_Screens.Wp_Screen)
                                return Array_Type;

   --
   -- Get a list of hidden columns.
   --
   -- @since 2.7.0
   --
   -- @param string|WP_Screen screen The screen you want the hidden columns for
   -- @return string[] Array of IDs of hidden columns.
   --
   function Get_Hidden_Columns (Screen : Class_Screens.Wp_Screen)
                                return Array_Type;

   --
   -- Gets an array of IDs of hidden meta boxes.
   --
   -- @since 2.7.0
   --
   -- @param string|WP_Screen screen Screen identifier
   -- @return string[] IDs of hidden meta boxes.
   --
   function Get_Hidden_Meta_Boxes (Screen : Class_Screens.Wp_Screen)
                                   return List_Type;

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
            return Class_Screens.Wp_Screen;

   --
   -- Set the current screen object
   --
   -- @since 3.0.0
   --
   -- @param string|WP_Screen hook_name Optional. The hook name (also known as the
   --                                    hook suffix) used to determine the screen,
   --                                    or an existing screen object.
   --
   procedure Set_Current_Screen (Hook_Name : String := "") is null;

end Adi_Screens;
