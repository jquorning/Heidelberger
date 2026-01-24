-- with UStrings;
-- with Php;

package body Inc_Elab_Hooks
is
   use Arrays;

   --------------------------------
   -- Build_Preinitialized_Hooks --
   --------------------------------

   function Build_Preinitialized_Hooks (Filters : Array_Type)
                                        return Hook_Maps.Map
   is
--    use UStrings;
--    use Php;

      -- @var WP_Hook[] normalized
      Normalized : Hook_Maps.Map;
   begin
      for A in Filters.Iterate loop
         declare
            Hook_Name       : constant String     := Key (A);
            Callback_Groups : constant Array_Type := As_Array (Arrays.Element (A));
         begin
--             if True
-- --            Is_Object (Callback_Groups) and then
-- --            Callback_Groups in Wp_Hook
-- --            Callback_Groups instanceof WP_Hook
--             then
--                Hook_Maps.Include (Normalized,
--                                   Key      => Hook_Name,
--                                   New_Item => Callback_Groups);
--                goto Continue;
--             end if;

            declare
               use Class_Hooks;

               Hook : Wp_Hook; -- = new WP_Hook();
            begin
               -- Loop through callback groups.
               for B in Callback_Groups.Iterate loop
                  declare
                     Priority  : constant String := Key (B);

                     Callbacks : constant Array_Type :=
                       As_Array (Arrays.Element (B));
                  begin
                     -- Loop through callbacks.
                     for CB_2 in Callbacks.Iterate loop
                        declare
                           CB   : constant Multi_Type := Element (CB_2);
                           Arry : constant Array_Type := As_Array (CB);
                        begin
                           Hook.Add_Filter (Hook_Name,
                                            As_Callable (Get (Arry, "function")),
                                            Priority_Type'Value (Priority),
                                            As_Integer (Get (Arry, "accepted_args")));
                        end;
                     end loop;
                  end;
               end loop;

               Normalized.Include (Key      => Hook_Name,
                                   New_Item => Hook);
            end;
--          << Continue >>
         end;
      end loop;

      return Normalized;
   end Build_Preinitialized_Hooks;

end Inc_Elab_Hooks;
