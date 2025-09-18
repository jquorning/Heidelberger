--
-- Dependencies API: Scripts functions
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Arrays;

package Inc_Function_Wp_Scripts
is
   use Arrays;
--
-- Enqueue a script.
--
-- Registers the script if src provided (does NOT overwrite), and enqueues it.
--
-- @see WP_Dependencies::add()
-- @see WP_Dependencies::add_data()
-- @see WP_Dependencies::enqueue()
--
-- @since 2.1.0
--
-- @param string           handle    Name of the script. Should be unique.
-- @param string           src       Full URL of the script, or path of the script relative to the WordPress root directory.
--                                    Default empty.
-- @param string[]         deps      Optional. An array of registered script handles this script depends on. Default empty array.
-- @param string|bool|null ver       Optional. String specifying script version number, if it has one, which is added to the URL
--                                    as a query string for cache busting purposes. If version is set to false, a version
--                                    number is automatically added equal to current installed WordPress version.
--                                    If set to null, no version is added.
-- @param bool             in_footer Optional. Whether to enqueue the script before `</body>` instead of in the `<head>`.
--                                    Default 'false'.
--
-- function wp_enqueue_script( handle, src = '', deps = array(), ver = false, in_footer = false ) then
   procedure Wp_Enqueue_Script (Handle    : String;
                                Src       : String       := "";
                                Deps      : String_Array := Empty_String_Array;
                                Ver       : String       := ""; -- Boolean   := False;
                                In_Footer : Boolean      := False);

end Inc_Function_Wp_Scripts;
