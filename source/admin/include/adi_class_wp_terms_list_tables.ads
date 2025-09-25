--
-- List Table API: WP_Terms_List_Table class
--
-- @package WordPress
-- @subpackage Administration
-- @since 3.1.0
--

with Adi_Class_Wp_List_Tables;

package Adi_Class_Wp_Terms_List_Tables
is
   procedure Dummy;

   --
   -- Core class used to implement displaying terms in a list table.
   --
   -- @since 3.1.0
   --
   -- @see WP_List_Table
   --
   type Wp_Terms_List_Table is new Adi_Class_Wp_List_Tables.Wp_List_Table with
      record

--        public callback_args;

--       private
         Level : Integer;  -- ?

      end record;

   --
   -- Outputs the hidden row displayed when inline editing
   --
   -- @since 3.1.0
   --
   procedure Inline_Edit (This : Wp_Terms_List_Table)
                          is null;

end Adi_Class_Wp_Terms_List_Tables;
