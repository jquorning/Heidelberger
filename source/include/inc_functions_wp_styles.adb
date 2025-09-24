--
-- Dependencies API: Styles functions
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Inc_Class_Wp_Dependencies;
with Inc_Class_Wp_Styles;
with Inc_Functions_Wp_Scripts;

with Hb_Common;
with Php;

package body Inc_Functions_Wp_Styles
is
   use Inc_Class_Wp_Styles;
   use Hb_Common;
   use Php;
-- --
-- -- Initialize wp_styles if it has not been set.
-- --
-- -- @global WP_Styles wp_styles
-- --
-- -- @since 4.2.0
-- --
-- -- @return WP_Styles WP_Styles instance.
-- --
-- function wp_styles() then
--         global wp_styles;

--         if ( ! ( wp_styles instanceof WP_Styles ) ) then
--                 wp_styles = new WP_Styles();
--         end;

--         return wp_styles;
-- end;

-- --
-- -- Display styles that are in the handles queue.
-- --
-- -- Passing an empty array to handles prints the queue,
-- -- passing an array with one string prints that style,
-- -- and passing an array of strings prints those styles.
-- --
-- -- @global WP_Styles wp_styles The WP_Styles object for printing styles.
-- --
-- -- @since 2.6.0
-- --
-- -- @param string|bool|array handles Styles to be printed. Default 'false'.
-- -- @return string[] On success, an array of handles of processed WP_Dependencies items; otherwise, an empty array.
-- --
-- function wp_print_styles( handles = false ) then
--         global wp_styles;

--         if ( '' === handles ) then // For 'wp_head'.
--                 handles = false;
--         end;

--         if ( ! handles ) then
--                 --
--                 -- Fires before styles in the handles queue are printed.
--                 --
--                 -- @since 2.6.0
--                 --
--                 do_action( 'wp_print_styles' );
--         end;

--         _wp_scripts_maybe_doing_it_wrong( __FUNCTION__ );

--         if ( ! ( wp_styles instanceof WP_Styles ) ) then
--                 if ( ! handles ) then
--                         return array(); // No need to instantiate if nothing is there.
--                 end;
--         end;

--         return wp_styles().do_items( handles );
-- end;

-- --
-- -- Add extra CSS styles to a registered stylesheet.
-- --
-- -- Styles will only be added if the stylesheet is already in the queue.
-- -- Accepts a string data containing the CSS. If two or more CSS code blocks
-- -- are added to the same stylesheet handle, they will be printed in the order
-- -- they were added, i.e. the latter added styles can redeclare the previous.
-- --
-- -- @see WP_Styles::add_inline_style()
-- --
-- -- @since 3.3.0
-- --
-- -- @param string handle Name of the stylesheet to add the extra styles to.
-- -- @param string data   String containing the CSS styles to be added.
-- -- @return bool True on success, false on failure.
-- --
-- function wp_add_inline_style( handle, data ) then
--         _wp_scripts_maybe_doing_it_wrong( __FUNCTION__, handle );

--         if ( false !== stripos( data, '</style>' ) ) then
--                 _doing_it_wrong(
--                         __FUNCTION__,
--                         sprintf(
--                                 /* translators: 1: <style>, 2: wp_add_inline_style()--
--                                 __( 'Do not pass %1s tags to %2s.' ),
--                                 '<code>&lt;style&gt;</code>',
--                                 '<code>wp_add_inline_style()</code>'
--                         ),
--                         '3.7.0'
--                 );
--                 data = trim( preg_replace( '#<style[^>]*>(.*)</style>#is', '1', data ) );
--         end;

--         return wp_styles().add_inline_style( handle, data );
-- end;

-- --
-- -- Register a CSS stylesheet.
-- --
-- -- @see WP_Dependencies::add()
-- -- @link https://www.w3.org/TR/CSS2/media.html#media-types List of CSS media types.
-- --
-- -- @since 2.6.0
-- -- @since 4.3.0 A return value was added.
-- --
-- -- @param string           handle Name of the stylesheet. Should be unique.
-- -- @param string|false     src    Full URL of the stylesheet, or path of the stylesheet relative to the WordPress root directory.
-- --                                 If source is set to false, stylesheet is an alias of other stylesheets it depends on.
-- -- @param string[]         deps   Optional. An array of registered stylesheet handles this stylesheet depends on. Default empty array.
-- -- @param string|bool|null ver    Optional. String specifying stylesheet version number, if it has one, which is added to the URL
-- --                                 as a query string for cache busting purposes. If version is set to false, a version
-- --                                 number is automatically added equal to current installed WordPress version.
-- --                                 If set to null, no version is added.
-- -- @param string           media  Optional. The media for which this stylesheet has been defined.
-- --                                 Default 'all'. Accepts media types like 'all', 'print' and 'screen', or media queries like
-- --                                 '(orientation: portrait)' and '(max-width: 640px)'.
-- -- @return bool Whether the style has been registered. True on success, false on failure.
-- --
-- function wp_register_style( handle, src, deps = array(), ver = false, media = 'all' ) then
--         _wp_scripts_maybe_doing_it_wrong( __FUNCTION__, handle );

--         return wp_styles().add( handle, src, deps, ver, media );
-- end;

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

-- function wp_enqueue_style( handle, src = '', deps = array(), ver = false, media = 'all' ) then
   procedure Wp_Enqueue_Style (Handle : String;
                               Src    : String       := "";
                               Deps   : String_Array := Empty_String_Array;
                               Ver    : String       := ""; -- Boolean      := False;
                               Media  : String       := "all")
   is
      use Inc_Class_Wp_Dependencies;
      use Inc_Functions_Wp_Scripts;
      use String_Vectors;
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
                Unused := Inc_Class_Wp_dependencies.Add
                  (Wp_Dependencies (Styles),
                   -(X_Handle.First_Element), Src, Deps, Ver, Media);
            end;
         end if;

         Styles.Enqueue (To_Vector (New_Item => Handle,
                                    Length   => 1));
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
