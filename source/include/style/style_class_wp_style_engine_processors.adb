--
-- WP_Style_Engine_Processor
--
-- Compiles styles from stores or collection of CSS rules.
--
-- @package WordPress
-- @subpackage StyleEngine
-- @since 6.1.0
--

with Ada.Containers;
with Ada.Strings.Unbounded;

with Globals;
with Hb_Common;
with Lists;
with Php;

with Inc_Functions;

with Style_Class_Wp_Style_Engine_CSS_Declarations;
with Style_Class_Wp_Style_Engine_CSS_Rules_Stores;

package body Style_Class_Wp_Style_Engine_Processors
is
   use Lists;

   ---------------
   -- Add_Rules --
   ---------------

   function Add_Rules (This      : in out Wp_Style_Engine_Processor;
                       CSS_Rules : Style_Class_Wp_Style_Engine_CSS_Rules.Rule_Arrays.Vector)
                       return Wp_Style_Engine_Processor
   is
      use Rule_Maps;
   begin
--    if ( ! is_array( css_rules ) ) then
--       css_rules = array( css_rules );
--    end if;

      for Rule of CSS_Rules loop
         declare
            Selector : constant String := Rule.Get_Selector; -- ();
         begin
            if Has_Element (This.CSS_Rules.Find (Selector)) then
--          if Isset (This.CSS_Rules, Selector) then
               This.CSS_Rules (Selector).Add_Declarations (Rule.Get_Declarations); -- () );
               goto Continue;
            end if;
         end;
         This.CSS_Rules (Rule.Get_Selector) := Rule;
         << Continue >>
      end loop;

      return This;
   end Add_Rules;

   ---------------
   -- Add_Rules --
   ---------------

   procedure Add_Rules (This      : in out Wp_Style_Engine_Processor;
                        CSS_Rules : Style_Class_Wp_Style_Engine_CSS_Rules.Rule_Arrays.Vector)
   is
      Unused : Wp_Style_Engine_Processor;
   begin
      Unused := Add_Rules (This, CSS_Rules);
   end Add_Rules;

   -------------
   -- Get_CSS --
   -------------

   function Get_CSS (This    : in out Wp_Style_Engine_Processor;
                     Options : Array_Type := Empty_Array)
                     return String
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Inc_Functions;
      use Style_Class_Wp_Style_Engine_CSS_Rules_Stores;

      Defaults : constant Array_Type := To_Array (List => (
        Build ("optimize", True),
        Build ("prettify", Globals.SCRIPT_DEBUG)
        -- defined( "SCRIPT_DEBUG" ) &&
      ));
      Options_2 : constant Array_Type := Wp_Parse_Args (Options, Defaults);
   begin
      -- If we have stores, get the rules from them.
      for A in This.Stores.Iterate loop
         declare
--          Store : String := Arrays.Key (A);
            Store : Wp_Style_Engine_CSS_Rules_Store;
         begin
            This.Add_Rules (Store.Get_All_Rules);
         end;
      end loop;

      -- Combine CSS selectors that have identical declarations.
      if True = As_Boolean (Get (Options_2, "optimize")) then
         This.Combine_Rules_Selectors;
      end if;

      -- Build the CSS.
      declare
         CSS : Unbounded_String;
      begin
         for Rule of This.CSS_Rules loop
            Append (CSS, Rule.Get_CSS (As_Boolean (Get (Options_2, "prettify"))));
            Append (CSS, (if As_Boolean (Get (Options_2, "prettify"))
                          then "\n" else ""));
         end loop;
         return -CSS;
      end;
   end Get_CSS;

   -----------------------------
   -- Combine_Rules_Selectors --
   -----------------------------

   procedure Combine_Rules_Selectors (This : in out Wp_Style_Engine_Processor)
   is
      use Ada.Containers;
      use Hb_Common;
      use Php;
      use Inc_Functions;
      use Style_Class_Wp_Style_Engine_CSS_Declarations;

      Selectors_JSON : Array_Type;
   begin
      -- Build an array of selectors along with the JSON-ified styles to make
      -- comparisons easier.
      for Rule of This.CSS_Rules loop
         declare
            Declarations : Array_Type :=
              Rule.Get_Declarations.Get_Declarations; -- 2x()
         begin
            Ksort (Declarations);
            Append (Selectors_JSON,
                    Key   => Rule.Get_Selector,
                    Value => From_String (Wp_JSON_Encode (Declarations)));
         end;
      end loop;

      -- Combine selectors that have the same styles.
      for A in Selectors_JSON.Iterate loop
         declare
            Selector : constant String     := Key (A);
            JSON     : constant Multi_Type := Element (A);

            -- Get selectors that use the same styles.
            Duplicates : constant List_Type :=
              Array_Keys (Selectors_JSON, As_String (JSON), True);

            Declarations : constant Wp_Style_Engine_CSS_Declarations :=
              This.CSS_Rules (Selector).Get_Declarations;
         begin
            -- Skip if there are no duplicates.
            if 1 >= Duplicates.Length then
               goto Continue;
            end if;

            for Key of Duplicates loop
               -- Unset the duplicates from the selectors_json array to avoid looping
               -- through them as well.
               Delete (Ref (Selectors_JSON, -Key));

               -- Remove the rules from the rules collection.
               This.CSS_Rules.Delete (-Key);
            end loop;

            -- Create a new rule with the combined selectors.
            declare
               Duplicate_Selectors : constant String := Implode (",", Duplicates);
            begin
               This.CSS_Rules.Include
                 (Key      => Duplicate_Selectors,
                  New_Item => Style_Class_Wp_Style_Engine_CSS_Rules.X_Construct
                                (Duplicate_Selectors, Declarations.Get_Declarations));
               -- Get_Declarations added
            end;
         end;
         << Continue >>
      end loop;
   end Combine_Rules_Selectors;

end Style_Class_Wp_Style_Engine_Processors;
