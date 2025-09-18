--
-- Dependencies API: Styles functions
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Arrays;

package Inc_Function_Wp_Styles
is
   use Arrays;
--
-- Enqueue a CSS stylesheet.
--
-- Registers the style if source provided (does NOT overwrite) and enqueues.
--
-- @see WP_Dependencies::add()
-- @see WP_Dependencies::enqueue()
-- @link https://www.w3.org/TR/CSS2/media.html#media-types List of CSS media types.
--
-- @since 2.6.0
--
-- @param string           handle Name of the stylesheet. Should be unique.
-- @param string           src    Full URL of the stylesheet, or path of the stylesheet relative to the WordPress root directory.
--                                 Default empty.
-- @param string[]         deps   Optional. An array of registered stylesheet handles this stylesheet depends on. Default empty array.
-- @param string|bool|null ver    Optional. String specifying stylesheet version number, if it has one, which is added to the URL
--                                 as a query string for cache busting purposes. If version is set to false, a version
--                                 number is automatically added equal to current installed WordPress version.
--                                 If set to null, no version is added.
-- @param string           media  Optional. The media for which this stylesheet has been defined.
--                                 Default 'all'. Accepts media types like 'all', 'print' and 'screen', or media queries like
--                                 '(orientation: portrait)' and '(max-width: 640px)'.
--
-- function wp_enqueue_style( handle, src = '', deps = array(), ver = false, media = 'all' ) then
   procedure Wp_Enqueue_Style (Handle : String;
                               Src    : String       := "";
                               Deps   : String_Array := Empty_String_Array;
                               Ver    : String       := ""; -- Boolean      := False;
                               Media  : String       := "all");

end Inc_Function_Wp_Styles;
