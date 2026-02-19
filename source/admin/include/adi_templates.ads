--
--
--

with Arrays;
with Lists;

with Class_Posts;
with Class_Screens;

package Adi_Templates
is
   use Arrays;
   use Lists;

--
-- Category Checklists.
--

--
-- Outputs an unordered list of checkbox input elements labeled with category names.
--
-- @since 2.5.1
--
-- @see wp_terms_checklist()
--
-- @param int         $post_id              Optional. Post to generate a categories checklist for. Default 0.
--                                          $selected_cats must not be an array. Default 0.
-- @param int         $descendants_and_self Optional. ID of the category to output along with its descendants.
--                                          Default 0.
-- @param int[]|false $selected_cats        Optional. Array of category IDs to mark as checked. Default false.
-- @param int[]|false $popular_cats         Optional. Array of category IDs to receive the "popular-category" class.
--                                          Default false.
-- @param Walker      $walker               Optional. Walker object to use to build the output.
--                                          Default is a Walker_Category_Checklist instance.
-- @param bool        $checked_ontop        Optional. Whether to move checked items out of the hierarchy and to
--                                          the top of the list. Default true.
--

   type Walker_Type is access procedure;

   procedure Wp_Category_Checklist (Post_Id              : Integer     := 0;
                                    Descendants_And_Self : Integer     := 0;
                                    Selected_Cats        : Array_Type  := Empty_Array;
                                    Popular_Cats         : Array_Type  := Empty_Array;
                                    Walker               : Walker_Type := null;
                                    Checked_Ontop        : Boolean     := True);

--
-- Outputs an unordered list of checkbox input elements labelled with term names.
--
-- Taxonomy-independent version of wp_category_checklist().
--
-- @since 3.0.0
-- @since 4.4.0 Introduced the `echo` argument.
--
-- @param int          post_id Optional. Post ID. Default 0.
-- @param array|string args then
--     Optional. Array or string of arguments for generating a terms checklist. Default empty array.
--
--     @type int    descendants_and_self ID of the category to output along with its descendants.
--                                        Default 0.
--     @type int[]  selected_cats        Array of category IDs to mark as checked. Default false.
--     @type int[]  popular_cats         Array of category IDs to receive the "popular-category" class.
--                                        Default false.
--     @type Walker walker               Walker object to use to build the output. Default empty which
--                                        results in a Walker_Category_Checklist instance being used.
--     @type string taxonomy             Taxonomy to generate the checklist for. Default "category".
--     @type bool   checked_ontop        Whether to move checked items out of the hierarchy and to
--                                        the top of the list. Default true.
--     @type bool   echo                 Whether to echo the generated markup. False to return the markup instead
--                                        of echoing it. Default true.
-- end;
-- @return string HTML list of input elements.
--
   function Wp_Terms_Checklist (Post_Id : Integer := 0;
                                Args    : Array_Type) return String;

   function Get_Media_States (Post : Class_Posts.Wp_Post) return List_Type;

   -- package Term_Arrays is new
   --    Ada.Containers.Vectors (Index_Type   => Positive,
   --                            Element_Type => Inc_Class_Wp_Terms.Wp_Term,
   --                            "="          => Inc_Class_Wp_Terms."=");

   -- subtype Wp_Term_Array is Term_Arrays.Vector;

   -- Empty_Term_Array : constant Wp_Term_Array := Term_Arrays.Empty_Vector;

   --
   -- Adds a meta box to one or more screens.
   --
   -- @since 2.5.0
   -- @since 4.4.0 The `screen` parameter now accepts an array of screen IDs.
   --
   -- @global array wp_meta_boxes
   --
   -- @param string                 id            Meta box ID (used in the "id"
   --                                             attribute for the meta box).
   -- @param string                 title         Title of the meta box.
   -- @param callable               callback      Function that fills the box with
   --                                             the desired content. The function
   --                                             should echo its output.
   -- @param string|array|WP_Screen screen        Optional. The screen or screens on
   --                                             which to show the box (such as a
   --                                             post type, "link", or "comment").
   --                                             Accepts a single screen ID,
   --                                             WP_Screen object, or array of screen
   --                                             IDs. Default is the current screen.
   --                                             If you have used add_menu_page() or
   --                                             add_submenu_page() to create a new
   --                                             screen (and hence screen_id), make
   --                                             sure your menu slug conforms to the
   --                                             limits of sanitize_key() otherwise
   --                                             the "screen" menu may not correctly
   --                                             render on your page.
   -- @param string                 context       Optional. The context within the
   --                                             screen where the box should display.
   --                                             Available contexts vary from screen
   --                                             to screen. Post edit screen contexts
   --                                             include "normal", "side", and
   --                                             "advanced". Comments screen contexts
   --                                             include "normal" and "side". Menus
   --                                             meta boxes (accordion sections) all
   --                                             use the "side" context. Global
   --                                             default is "advanced".
   -- @param string                 priority      Optional. The priority within the
   --                                             context where the box should show.
   --                                             Accepts "high", "core", "default",
   --                                             or "low". Default "default".
   -- @param array                  callback_args Optional. Data that should be set
   --                                             as the args property of the box
   --                                             array (which is the second parameter
   --                                             passed to your callback). Default
   --                                             null.
   --

   type Callable_2 is access function (Data_Object : String;
                                       Box         : Array_Type)
                                       return Array_Type;

   procedure Add_Meta_Box (Id            : String;
                           Title         : String;
                           Callback      : Callable_2;
                           Screen        : Class_Screens.Wp_Screen;
                           Context       : String     := "advanced";
                           Priority      : String     := "default";
                           Callback_Args : Array_Type := Empty_Array);

   --
   -- Internal helper function to find the plugin from a meta box callback.
   --
   -- @since 5.0.0
   --
   -- @access private
   --
   -- @param callable callback The callback function to check.
   -- @return array|null The plugin that the callback belongs to, or null if it
   --                    Doesn't belong to a plugin.
   --
   function X_Get_Plugin_From_Callback (Callback : Callable)
                                        return Array_Type
                                        is (Empty_Array);

   --
   -- Meta-Box template function.
   --
   -- @since 2.5.0
   --
   -- @global array wp_meta_boxes
   --
   -- @param string|WP_Screen screen      The screen identifier. If you have used
   --                                     add_menu_page() or add_submenu_page() to
   --                                     create a new screen (and hence screen_id)
   --                                     make sure your menu slug conforms to the
   --                                     limits of sanitize_key()  otherwise the
   --                                     "screen" menu may not correctly render on
   --                                     your page.
   -- @param string           context     The screen context for which to display
   --                                     meta boxes.
   -- @param mixed            data_object Gets passed to the meta box callback
   --                                     function as the first parameter. Often this
   --                                     is the object That's the focus of the
   --                                     current screen, for example a `WP_Post` or
   --                                     `WP_Comment` object.
   -- @return int Number of meta_boxes.
   --
   function Do_Meta_Boxes (Screen      : String;
                           Context     : String;
                           Data_Object : Multi_Type)
                           return Natural;

   procedure Do_Meta_Boxes (Screen      : String;
                            Context     : String;
                            Data_Object : Multi_Type);

   --
   -- Echoes a submit button, with provided text and appropriate class(es).
   --
   -- @since 3.1.0
   --
   -- @see get_submit_button()
   --
   -- @param string       text             The text of the button (defaults to "Save Changes")
   -- @param string       type             Optional. The type and CSS class(es) of the button. Core values
   --                                       include "primary", "small", and "large". Default "primary".
   -- @param string       name             The HTML name of the submit button. Defaults to "submit". If no
   --                                       id attribute is given in other_attributes below, name will be
   --                                       used as the Button's id.
   -- @param bool         wrap             True if the output button should be wrapped in a paragraph tag,
   --                                       false otherwise. Defaults to true.
   -- @param array|string other_attributes Other attributes that should be output with the button, mapping
   --                                       attributes to their values, such as setting tabindex to 1, etc.
   --                                       These key/value attribute pairs will be output as attribute="value",
   --                                       where attribute is the key. Other attributes can also be provided
   --                                       as a string such as "tabindex="1"", though the array format is
   --                                       preferred. Default null.
   --
   procedure Submit_Button (Text             : String     := ""; -- null;
                            Typ              : String     := "primary";
                            Name             : String     := "submit";
                            Wrap             : Boolean    := True;
                            Other_Attributes : Array_Type := Empty_Array);

   --
   -- Displays the search query.
   --
   -- A simple wrapper to display the "s" parameter in a `GET` URI. This function
   -- should only be used when the_search_query() cannot.
   --
   -- @since 2.7.0
   --
   procedure X_Admin_Search_Query;

   --
   -- Returns a submit button, with provided text and appropriate class.
   --
   -- @since 3.1.0
   --
   -- @param string       text             Optional. The text of the button. Default "Save Changes".
   -- @param string       type             Optional. The type and CSS class(es) of the button. Core values
   --                                       include "primary", "small", and "large". Default "primary large".
   -- @param string       name             Optional. The HTML name of the submit button. Defaults to "submit".
   --                                       If no id attribute is given in other_attributes below, `name` will
   --                                       be used as the Button's id. Default "submit".
   -- @param bool         wrap             Optional. True if the output button should be wrapped in a paragraph
   --                                       tag, false otherwise. Default true.
   -- @param array|string other_attributes Optional. Other attributes that should be output with the button,
   --                                       mapping attributes to their values, such as `array ("tabindex" => "1")`.
   --                                       These attributes will be output as `attribute="value"`, such as
   --                                       `tabindex="1"`. Other attributes can also be provided as a string such
   --                                       as `tabindex="1"`, though the array format is typically cleaner.
   --                                       Default empty.
   -- @return string Submit button HTML.
   --
   function Get_Submit_Button (Text             : String     := "";
                               Typ              : String     := "primary large";
                               Name             : String     := "submit";
                               Wrap             : Boolean    := True;
                               Other_Attributes : Array_Type := Empty_Array)
                               return String;

   --
   -- Prints out the beginning of the admin HTML header.
   --
   -- @global bool is_IE
   --
   procedure X_Wp_Admin_HTML_Begin;

   --
   -- Converts a screen string to a screen object.
   --
   -- @since 3.0.0
   --
   -- @param string hook_name The hook name (also known as the hook suffix) used to
   --                          determine the screen.
   -- @return WP_Screen Screen object.
   --
   function Convert_To_Screen (Hook_Name : String)
                               return Class_Screens.Wp_Screen;

end Adi_Templates;
