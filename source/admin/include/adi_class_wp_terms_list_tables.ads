--
-- List Table API: WP_Terms_List_Table class
--
-- @package WordPress
-- @subpackage Administration
-- @since 3.1.0
--

with Arrays;

with Adi_Class_Wp_List_Tables;

package Adi_Class_Wp_Terms_List_Tables
is
   use Arrays;

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
   -- Constructor.
   --
   -- @since 3.1.0
   --
   -- @see WP_List_Table::__construct() for more information on default arguments.
   --
   -- @global string post_type
   -- @global string taxonomy
   -- @global string action
   -- @global object tax
   --
   -- @param array args An associative array of arguments.
   --
   function X_Construct (Args : Array_Type := Empty_Array)
                         return Wp_Terms_List_Table;

   --
   -- Outputs the hidden row displayed when inline editing
   --
   -- @since 3.1.0
   --
   procedure Inline_Edit (This : Wp_Terms_List_Table)
                          is null;

end Adi_Class_Wp_Terms_List_Tables;
