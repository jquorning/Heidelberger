--
-- Site API
--
-- @package WordPress
-- @subpackage Multisite
-- @since 5.1.0
--

with Inc_Meta;

package body Inc_Ms_Sites
is

   ----------------------
   -- Update_Site_Meta --
   ----------------------

   function Update_Site_Meta (Site_Id    : Integer;
                              Meta_Key   : String;
                              Meta_Value : Multi_Type;
                              Prev_Value : Multi_Type := From_String (""))
                              return Integer
   is
      use Inc_Meta;
   begin
      return
        Update_Metadata ( -- "blog" -- ???,
          Site_Id, "blog", Meta_Key, Meta_Value, Prev_Value);
   end Update_Site_Meta;

   ----------------------
   -- Update_Site_Meta --
   ----------------------

   procedure Update_Site_Meta (Site_Id    : Integer;
                               Meta_Key   : String;
                               Meta_Value : Multi_Type;
                               Prev_Value : Multi_Type := From_String (""))
   is
      Unused : constant Integer :=
        Update_Site_Meta (Site_Id, Meta_Key, Meta_Value, Prev_Value);
   begin
      null;
   end Update_Site_Meta;

end Inc_Ms_Sites;
