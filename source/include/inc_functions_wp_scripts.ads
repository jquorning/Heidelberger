--
-- Dependencies API: Scripts functions
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Lists;

package Inc_Functions_Wp_Scripts
is
   use Lists;

   --
   -- Initialize wp_scripts if it has not been set.
   --
   -- @global WP_Scripts wp_scripts
   --
   -- @since 4.2.0
   --
   -- @return WP_Scripts WP_Scripts instance.
   --
-- function Wp_Scripts_X
--          return Class_Scripts.Wp_Scripts;

   --
   -- Prints scripts in document head that are in the handles queue.
   --
   -- Called by admin-header.php and {@see "wp_head"} hook. Since it is called by
   -- wp_head on every page load, the function does not instantiate the WP_Scripts
   -- object unless script names are explicitly passed. Makes use of
   -- already-instantiated wp_scripts global if present. Use provided
   -- {@see "wp_print_scripts"} hook to register/enqueue new scripts.
   --
   -- @see WP_Scripts::do_item()
   -- @global WP_Scripts wp_scripts The WP_Scripts object for printing scripts.
   --
   -- @since 2.1.0
   --
   -- @param string|bool|array handles Optional. Scripts to be printed. Default
   --                                   "false".
   -- @return string[] On success, an array of handles of processed WP_Dependencies
   --                   items; otherwise, an empty array.
   --
   function Wp_Print_Scripts (Handles : List_Type := Empty_List)
                              return List_Type;

   procedure Wp_Print_Scripts (Handles : List_Type := Empty_List); -- false

   --
   -- Helper function to output a _doing_it_wrong message when applicable.
   --
   -- @ignore
   -- @since 4.2.0
   -- @since 5.5.0 Added the `handle` parameter.
   --
   -- @param string function Function name.
   -- @param string handle   Optional. Name of the script or stylesheet that was
   --                         registered or enqueued too early. Default empty.
   --
   procedure X_Wp_Scripts_Maybe_Doing_It_Wrong (Funct  : String;
                                                Handle : String := "");

   --
   -- Adds extra code to a registered script.
   --
   -- Code will only be added if the script is already in the queue.
   -- Accepts a string data containing the Code. If two or more code blocks
   -- are added to the same script handle, they will be printed in the order
   -- they were added, i.e. the latter added code can redeclare the previous.
   --
   -- @since 4.5.0
   --
   -- @see WP_Scripts::add_inline_script()
   --
   -- @param string handle   Name of the script to add the inline script to.
   -- @param string data     String containing the JavaScript to be added.
   -- @param string position Optional. Whether to add the inline script before the
   --                         handle or after. Default "after".
   -- @return bool True on success, false on failure.
   --
   function Wp_Add_Inline_Script (Handle   : String;
                                  Data     : String;
                                  Position : String := "after")
                                  return Boolean;

   procedure Wp_Add_Inline_Script (Handle   : String;
                                   Data     : String;
                                   Position : String := "after");

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
   -- @param string           src       Full URL of the script, or path of the script
   --                                    relative to the WordPress root directory.
   --                                    Default empty.
   -- @param string[]         deps      Optional. An array of registered script
   --                                    handles this script depends on. Default empty
   --                                    array.
   -- @param string|bool|null ver       Optional. String specifying script version
   --                                    number, if it has one, which is added to the
   --                                    URL as a query string for cache busting
   --                                    purposes. If version is set to false, a
   --                                    version number is automatically added equal
   --                                    to current installed WordPress version.
   --                                    If set to null, no version is added.
   -- @param bool             in_footer Optional. Whether to enqueue the script before
   --                                    `</body>` instead of in the `<head>`.
   --                                    Default 'false'.
   --
   procedure Wp_Enqueue_Script (Handle    : String;
                                Src       : String    := "";
                                Deps      : List_Type := Empty_List;
                                Ver       : String    := ""; -- Boolean   := False;
                                In_Footer : Boolean   := False);

end Inc_Functions_Wp_Scripts;
