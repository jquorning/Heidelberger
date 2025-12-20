--
-- Upgrade API: Language_Pack_Upgrader class
--
-- @package WordPress
-- @subpackage Upgrader
-- @since 4.6.0
--

with Php.Types;

package body Adi_Class_Language_Pack_Upgraders
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Skin : Adi_Class_Wp_Upgrader_Skins.Wp_Upgrader_Skin)
                         return Language_Pack_Upgrader
   is
      This : Language_Pack_Upgrader;
   begin
      return This;
   end X_Construct;

   -------------
   -- Upgrade --
   -------------

   function Upgrade (This   : Language_Pack_Upgrader;
                     Update : String     := ""; -- false
                     Args   : Array_Type := Empty_Array)
                     return Array_Type
   is
      use Php.Types;
      Update_2 : Array_Type;
   begin
      if Update /= "" then
         Update_2 := To_Array (List => (1 => Build (Update, "")));
      end if;

      declare
         Results : constant Array_Type :=
           This.Bulk_Upgrade (Update_2, Args);
      begin
         if not Is_Array (Results) then
            return Results;
         end if;

         return As_Array (Results.First_Element);
--       return results[0];
      end;
   end Upgrade;

   ------------------
   -- Bulk_Upgrade --
   ------------------

   function Bulk_Upgrade (This             : Language_Pack_Upgrader;
                          Language_Updates : Array_Type;
                          Args             : Array_Type)
                          return Array_Type
   is (raise Program_Error with "not implemented");

end Adi_Class_Language_Pack_Upgraders;
