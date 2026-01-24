--
-- Dependencies API: Styles functions
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Ada.Strings.Unbounded;

with Hb_Common;
with Php.Preg;
with Php.Strings;

with Class_Dependencies;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_L10n;

package body Inc_Functions_Wp_Styles
is
   use Hb_Common;
   use Php;

--    function Wp_Styles_X
--             return Wp_Styles
--    is
-- --    global wp_styles;
--    begin
--       -- if ( ! ( wp_styles instanceof WP_Styles ) ) then
--       --         wp_styles = new WP_Styles();
--       -- end if;

--       return Adm_Load_Styles.Styles; -- Wp_styles
--    end Wp_Styles_X;

   ---------------------
   -- Wp_Print_Styles --
   ---------------------

   function Wp_Print_Styles (Handles : String)  -- = false
                             return List_Type
   is
      use Inc_Functions_Wp_Scripts;
--    global wp_styles;
   begin
      -- if "" = handles then -- For 'wp_head'.
      --    Handles := False;
      -- end if;

      -- if not Handles then
      --    --
      --    -- Fires before styles in the handles queue are printed.
      --    --
      --    -- @since 2.6.0
      --    --
      --    Do_Action ("wp_print_styles");
      -- end if;

      X_Wp_Scripts_Maybe_Doing_It_Wrong ("__FUNCTION__");

      -- if not ( wp_styles instanceof WP_Styles ) then -- instanceof
      --    if ( ! handles ) then
      --       return array(); -- No need to instantiate if nothing is there.
      --    end if;
      -- end if;

      return Wp_Styles_X.Do_Items (To_List (Handles)); -- to_list added
   end Wp_Print_Styles;

   procedure Wp_Print_Styles (Handles : String)
   is
      Unused : constant List_Type := Wp_Print_Styles (Handles);
   begin
      null;
   end Wp_Print_Styles;

   -------------------------
   -- Wp_Add_Inline_Style --
   -------------------------

   function Wp_Add_Inline_Style (Handle : String;
                                 Data   : String)
                                 return Boolean
   is
      use Ada.Strings.Unbounded;
      use Php.Preg;
      use Php.Strings;
      use Adm_Load_Styles;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_L10n;

      Data_2 : Unbounded_String := +Data;
   begin
      X_Wp_Scripts_Maybe_Doing_It_Wrong ("__FUNCTION__", Handle);

      if 0 /= Stripos (Data, "</style>") then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           Sprintf (
             -- translators: 1: <style>, 2: wp_add_inline_style()
             abs "Do not pass %1s tags to %2s.",
             To_List (List => (
               1 => +"<code>&lt;style&gt;</code>",
               2 => +"<code>wp_add_inline_style()</code>"
             ))
           ),
           "3.7.0"
         );
         Data_2 := +Trim (Preg_Replace ("#<style[^>]*>(.*)</style>#is", "1", Data));
      end if;

      return Styles.Add_Inline_Style (Handle, -Data_2);
   end Wp_Add_Inline_Style;

   procedure Wp_Add_Inline_Style (Handle : String;
                                  Data   : String)
   is
      Unused : Boolean;
   begin
      Unused := Wp_Add_Inline_Style (Handle, Data);
   end Wp_Add_Inline_Style;

   -----------------------
   -- Wp_Register_Style --
   -----------------------

   function Wp_Register_Style (Handle : String;
                               Src    : String;
                               Deps   : List_Type := Empty_List;
                               -- Array_Type := Empty_Array;
                               Ver    : String    := ""; -- Boolean   := False;
                               Media  : String    := "all")
                               return Boolean
   is
      use Adm_Load_Styles;
      use Inc_Functions_Wp_Scripts;
   begin
      X_Wp_Scripts_Maybe_Doing_It_Wrong ("__FUNCTION__", Handle);

      return Styles.Add (Handle, Src, Deps, Ver, Media);
--    return Wp_Styles_X.Add (Handle, Src, Deps, Ver, Media);
   end Wp_Register_Style;

   procedure Wp_Register_Style (Handle : String;
                                Src    : Boolean;
                                Deps   : List_Type := Empty_List;
                                Ver    : Boolean   := False;
                                Media  : Boolean   := False)
   is
      Unused : Boolean;
   begin
      Unused := Wp_Register_Style (Handle,
                                   Boolean'Image (Src),
                                   Deps,
                                   Boolean'Image (Ver),
                                   Boolean'Image (Media));
   end Wp_Register_Style;

-- --
-- -- Remove a registered stylesheet.
-- --
-- -- @see WP_Dependencies::remove()
-- --
-- -- @since 2.1.0
-- --
-- -- @param string handle Name of the stylesheet to be removed.
-- --
-- function wp_deregister_style( handle ) then
--         _wp_scripts_maybe_doing_it_wrong( __FUNCTION__, handle );

--         wp_styles().remove( handle );
-- end;

   ----------------------
   -- Wp_Enqueue_Style --
   ----------------------

   procedure Wp_Enqueue_Style (Handle : String;
                               Src    : String    := "";
                               Deps   : List_Type := Empty_List;
                               Ver    : String    := "";
                               Media  : String    := "all")
   is
      use Php.Strings;
      use Class_Dependencies;
      use Inc_Functions_Wp_Scripts;
   begin
      X_Wp_Scripts_Maybe_Doing_It_Wrong ("__FUNCTION__", Handle);
      declare
         Styles : Wp_Styles := X_Construct;
         Unused : Boolean;
      begin
         if Src /= "" then
            declare
               X_Handle : constant List_Type := Explode ("?", Handle);
            begin
               Unused := Class_Dependencies.Add
                 (Wp_Dependencies (Styles),
                  -(X_Handle.First_Element), Src, Deps, Ver, Media);
            end;
         end if;

         Styles.Enqueue (To_List (Handle));
      end;
   end Wp_Enqueue_Style;

-- --
-- -- Remove a previously enqueued CSS stylesheet.
-- --
-- -- @see WP_Dependencies::dequeue()
-- --
-- -- @since 3.1.0
-- --
-- -- @param string handle Name of the stylesheet to be removed.
-- --
-- function wp_dequeue_style( handle ) then
--         _wp_scripts_maybe_doing_it_wrong( __FUNCTION__, handle );

--         wp_styles().dequeue( handle );
-- end;

-- --
-- -- Check whether a CSS stylesheet has been added to the queue.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string handle Name of the stylesheet.
-- -- @param string list   Optional. Status of the stylesheet to check. Default 'enqueued'.
-- --                       Accepts 'enqueued', 'registered', 'queue', 'to_do', and 'done'.
-- -- @return bool Whether style is queued.
-- --
-- function wp_style_is( handle, list = 'enqueued' ) then
--         _wp_scripts_maybe_doing_it_wrong( __FUNCTION__, handle );

--         return (bool) wp_styles().query( handle, list );
-- end;

-- --
-- -- Add metadata to a CSS stylesheet.
-- --
-- -- Works only if the stylesheet has already been registered.
-- --
-- -- Possible values for key and value:
-- -- 'conditional' string      Comments for IE 6, lte IE 7 etc.
-- -- 'rtl'         bool|string To declare an RTL stylesheet.
-- -- 'suffix'      string      Optional suffix, used in combination with RTL.
-- -- 'alt'         bool        For rel="alternate stylesheet".
-- -- 'title'       string      For preferred/alternate stylesheets.
-- -- 'path'        string      The absolute path to a stylesheet. Stylesheet will
-- --                           load inline when 'path'' is set.
-- --
-- -- @see WP_Dependencies::add_data()
-- --
-- -- @since 3.6.0
-- -- @since 5.8.0 Added 'path' as an official value for key.
-- --              See {@see wp_maybe_inline_styles()}.
-- --
-- -- @param string handle Name of the stylesheet.
-- -- @param string key    Name of data point for which we're storing a value.
-- --                       Accepts 'conditional', 'rtl' and 'suffix', 'alt', 'title' and 'path'.
-- -- @param mixed  value  String containing the CSS data to be added.
-- -- @return bool True on success, false on failure.
-- --
-- function wp_style_add_data( handle, key, value ) then
--         return wp_styles().add_data( handle, key, value );
-- end;

end Inc_Functions_Wp_Styles;
