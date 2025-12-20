--
--
--

package Adm_Install
is

   --
   -- Display installation header.
   --
   -- @since 2.5.0
   --
   -- @param string body_classes
   --
   procedure Display_Header (Body_Classes : String := "");

   --
   -- Displays installer setup form.
   --
   -- @since 2.8.0
   --
   -- @global wpdb $wpdb WordPress database abstraction object.
   --
   -- @param string|null $error
   --
   procedure Display_Setup_Form (Error : String := ""); -- null

   --
   --
   --
   procedure Run;

end Adm_Install;
