with Hb_Common;
with Php;

package body Inc_Elab_Hooks
is
   use Arrays;

   --------------------------------
   -- Build_Preinitialized_Hooks --
   --------------------------------

   function Build_Preinitialized_Hooks (Filters : Array_Type)
                                        return Hook_Maps.Map
   is
      use Hb_Common;
      use Php;

      -- @var WP_Hook[] normalized
      Normalized : Hook_Maps.Map; -- Array_Type;
   begin
      for A in Filters.Iterate loop
         declare
            Hook_Name       : constant String     := Array_Maps.Key     (A);
            Callback_Groups : constant Array_Type := Array_Maps.Element (A).Arry.all;
         begin
            if True
--            Is_Object (Callback_Groups) and then
--            Callback_Groups in Wp_Hook
--            Callback_Groups instanceof WP_Hook
            then
--             Normalized.Include (Key      => Hook_Name,
--                                 New_Item => Callback_Groups);
               goto Continue;
            end if;

            declare
               use Inc_Class_Wp_Hooks;

               Hook : Wp_Hook; -- = new WP_Hook();
            begin
               -- Loop through callback groups.
               for B in Callback_Groups.Iterate loop
                  declare
                     Priority  : constant String := Array_Maps.Key (B);

                     Callbacks : constant Array_Type :=
                       Array_Maps.Element (B).Arry.all;
                  begin
                     -- Loop through callbacks.
                     for CB of Callbacks loop
                        Hook.Add_Filter (Hook_Name,
                                         Get_Func (CB.Arry.all, "function"),
                                         Priority_Type'Value (Priority),
                                         Get_Integer (CB.Arry.all, "accepted_args"));
                     end loop;
                  end;
               end loop;

               Normalized.Include (Key      => Hook_Name,
                                   New_Item => Hook);
            end;
            << Continue >>
         end;
      end loop;

      return Normalized;
   end Build_Preinitialized_Hooks;

end Inc_Elab_Hooks;
