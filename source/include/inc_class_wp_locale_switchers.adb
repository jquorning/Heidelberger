--
-- Locale API: WP_Locale_Switcher class
--
-- @package WordPress
-- @subpackage i18n
-- @since 4.7.0
--

with Hb_Common;
with Php.Lists;

with Inc_Class_Wp_Locale;
with Inc_L10n;
with Inc_Plugins;

package body Inc_Class_Wp_Locale_Switchers
is

   Global_Wp_Locale : Inc_Class_Wp_Locale.Wp_Locale;

   ----------------------
   -- Switch_To_Locale --
   ----------------------

   function Switch_To_Locale (This   : in out Wp_Locale_Switcher;
                              Locale : String)
                              return Boolean
   is
      use Hb_Common;
      use Php;
      use Inc_L10n;
      use Inc_Plugins;

      Current_Locale : constant String := Determine_Locale; -- ()
   begin
      if Current_Locale = Locale then
         return False;
      end if;

      if not In_Array (Locale, This.Available_Languages, True) then
         return False;
      end if;

      This.Locales.Append (+Locale);

      This.Change_Locale (Locale);

      --
      -- Fires when the locale is switched.
      --
      -- @since 4.7.0
      --
      -- @param string locale The new locale.
      --
      Do_Action ("switch_locale", Locale);

      return True;
   end Switch_To_Locale;

   -----------------------------
   -- Restore_Previous_Locale --
   -----------------------------

   function Restore_Previous_Locale (This : Wp_Locale_Switcher)
                                     return String
   is
      use Hb_Common;
      use Php;
      use Php.Lists;
      use Inc_Plugins;

      Previous_Locale : constant String := Array_Pop (This.Locales);
   begin
      if "" = Previous_Locale then -- null
         -- The stack is empty, bail.
         return ""; -- false
      end if;

      declare
         Locale : Unbounded_String;
      begin
         Locale := +Endd (This.Locales);

         if Locale = "" then -- not
            -- There's nothing left in the stack: go back to the original locale.
            Locale := This.Original_Locale;
         end if;

         This.Change_Locale (-Locale);

         --
         -- Fires when the locale is restored to the previous one.
         --
         -- @since 4.7.0
         --
         -- @param string locale          The new locale.
         -- @param string previous_locale The previous locale.
         --
         Do_Action ("restore_previous_locale", -Locale, Previous_Locale);

         return -Locale;
      end;
   end Restore_Previous_Locale;

   -----------------------
   -- Load_Translations --
   -----------------------

   procedure Load_Translations (This   : Wp_Locale_Switcher;
                                Locale : String)
   is
      use Hb_Common;
--    use Php;
      use Inc_L10n;

      Domains : constant List_Type := (if L10n.Is_Empty
                                       then Array_Keys (L10n)
                                       else Empty_List);
   begin
      Load_Default_Textdomain (Locale);

      for Domain of Domains loop
         -- The default text domain is handled by `load_default_textdomain()`.
         if "default" = Domain then
            goto Continue;
         end if;

         -- Unload current text domain but allow them to be reloaded
         -- after switching back or to another locale.
         Unload_Textdomain (-Domain, True);
         Get_Translations_For_Domain (-Domain);
         << Continue >>
      end loop;
   end Load_Translations;

   -------------------
   -- Change_Locale --
   -------------------

   procedure Change_Locale (This   : Wp_Locale_Switcher;
                            Locale : String)
   is
      use Inc_Plugins;
   begin
      This.Load_Translations (Locale);

      Global_Wp_Locale := Inc_Class_Wp_Locale.X_Construct; -- ()

      --
      -- Fires when the locale is switched to or restored.
      --
      -- @since 4.7.0
      --
      -- @param string locale The new locale.
      --
      Do_Action ("change_locale", Locale);
   end Change_Locale;

end Inc_Class_Wp_Locale_Switchers;
