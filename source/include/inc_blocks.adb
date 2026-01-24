--
-- Functions related to registering and parsing blocks.
--
-- @package WordPress
-- @subpackage Blocks
-- @since 5.0.0
--

with Arrays;

with Inc_Functions;

package body Inc_Blocks
is
   use Arrays;

   -----------------------
   -- Block_Has_Support --
   -----------------------

   function Block_Has_Support (Block_Type : Class_Block_Type.Wp_Block_Type;
                               Feature    : List_Type;
                               Default    : Boolean := False)
                               return Boolean
   is
      use Class_Block_Type;
      use Inc_Functions;

      Block_Support : Multi_Type := From_Boolean (Default); -- Boolean := Default;
   begin
      if
        Block_Type /= Null_Wp_Block_Type and then
        True -- Property_Exists (Block_Type, "supports")
      then
         Block_Support := X_Wp_Array_Get (Block_Type.Supports, Feature, From_Boolean (Default));
      end if;

      return
        True = As_Boolean (Block_Support) or else
        Kind_Of (Block_Support) = Kind_Array; -- Is_Array (Block_Support);

   end Block_Has_Support;

end Inc_Blocks;
