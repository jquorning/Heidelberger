--
-- WordPress Administration Screen API.
--
-- @package WordPress
-- @subpackage Administration
--
package body Adi_Screens
is
   Current_Screen : Adi_Class_Wp_Screens.Wp_Screen;

-- --
-- -- Get the column headers for a screen
-- --
-- -- @since 2.7.0
-- --
-- -- @param string|WP_Screen screen The screen you want the headers for
-- -- @return string[] The column header labels keyed by column ID.
-- --
-- function get_column_headers( screen ) then
--         static column_headers = array();

--         if ( is_string( screen ) ) then
--                 screen = convert_to_screen( screen );
--         end;

--         if ( ! isset( column_headers[ screen.id ] ) ) then
--                 --
--                 -- Filters the column headers for a list table on a specific screen.
--                 --
--                 -- The dynamic portion of the hook name, `screen.id`, refers to the
--                 -- ID of a specific screen. For example, the screen ID for the Posts
--                 -- list table is edit-post, so the filter for that screen would be
--                 -- manage_edit-post_columns.
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param string[] columns The column header labels keyed by column ID.
--                 --
--                 column_headers[ screen.id ] = apply_filters( "manage_thenscreen.idend;_columns", array() );
--         end;

--         return column_headers[ screen.id ];
-- end;

-- --
-- -- Get a list of hidden columns.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string|WP_Screen screen The screen you want the hidden columns for
-- -- @return string[] Array of IDs of hidden columns.
-- --
-- function get_hidden_columns( screen ) then
--         if ( is_string( screen ) ) then
--                 screen = convert_to_screen( screen );
--         end;

--         hidden = get_user_option( 'manage' . screen.id . 'columnshidden' );

--         use_defaults = ! is_array( hidden );

--         if ( use_defaults ) then
--                 hidden = array();

--                 --
--                 -- Filters the default list of hidden columns.
--                 --
--                 -- @since 4.4.0
--                 --
--                 -- @param string[]  hidden Array of IDs of columns hidden by default.
--                 -- @param WP_Screen screen WP_Screen object of the current screen.
--                 --
--                 hidden = apply_filters( 'default_hidden_columns', hidden, screen );
--         end;

--         --
--         -- Filters the list of hidden columns.
--         --
--         -- @since 4.4.0
--         -- @since 4.4.1 Added the `use_defaults` parameter.
--         --
--         -- @param string[]  hidden       Array of IDs of hidden columns.
--         -- @param WP_Screen screen       WP_Screen object of the current screen.
--         -- @param bool      use_defaults Whether to show the default columns.
--         --
--         return apply_filters( 'hidden_columns', hidden, screen, use_defaults );
-- end;

-- --
-- -- Prints the meta box preferences for screen meta.
-- --
-- -- @since 2.7.0
-- --
-- -- @global array wp_meta_boxes
-- --
-- -- @param WP_Screen screen
-- --
-- function meta_box_prefs( screen ) then
--         global wp_meta_boxes;

--         if ( is_string( screen ) ) then
--                 screen = convert_to_screen( screen );
--         end;

--         if ( empty( wp_meta_boxes[ screen.id ] ) ) then
--                 return;
--         end;

--         hidden = get_hidden_meta_boxes( screen );

--         foreach ( array_keys( wp_meta_boxes[ screen.id ] ) as context ) then
--                 foreach ( array( 'high', 'core', 'default', 'low' ) as priority ) then
--                         if ( ! isset( wp_meta_boxes[ screen.id ][ context ][ priority ] ) ) then
--                                 continue;
--                         end;

--                         foreach ( wp_meta_boxes[ screen.id ][ context ][ priority ] as box ) then
--                                 if ( false === box || ! box['title'] ) then
--                                         continue;
--                                 end;

--                                 // Submit box cannot be hidden.
--                                 if ( 'submitdiv' === box['id'] || 'linksubmitdiv' === box['id'] ) then
--                                         continue;
--                                 end;

--                                 widget_title = box['title'];

--                                 if ( is_array( box['args'] ) && isset( box['args']['__widget_basename'] ) ) then
--                                         widget_title = box['args']['__widget_basename'];
--                                 end;

--                                 is_hidden = in_array( box['id'], hidden, true );

--                                 printf(
--                                         '<label for="%1s-hide"><input class="hide-postbox-tog" name="%1s-hide" type="checkbox" id="%1s-hide" value="%1s" %2s />%3s</label>',
--                                         esc_attr( box['id'] ),
--                                         checked( is_hidden, false, false ),
--                                         widget_title
--                                 );
--                         end;
--                 end;
--         end;
-- end;

-- --
-- -- Gets an array of IDs of hidden meta boxes.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string|WP_Screen screen Screen identifier
-- -- @return string[] IDs of hidden meta boxes.
-- --
-- function get_hidden_meta_boxes( screen ) then
--         if ( is_string( screen ) ) then
--                 screen = convert_to_screen( screen );
--         end;

--         hidden = get_user_option( "metaboxhidden_thenscreen.idend;" );

--         use_defaults = ! is_array( hidden );

--         // Hide slug boxes by default.
--         if ( use_defaults ) then
--                 hidden = array();

--                 if ( 'post' === screen.base ) then
--                         if ( in_array( screen.post_type, array( 'post', 'page', 'attachment' ), true ) ) then
--                                 hidden = array( 'slugdiv', 'trackbacksdiv', 'postcustom', 'postexcerpt', 'commentstatusdiv', 'commentsdiv', 'authordiv', 'revisionsdiv' );
--                         end; else then
--                                 hidden = array( 'slugdiv' );
--                         end;
--                 end;

--                 --
--                 -- Filters the default list of hidden meta boxes.
--                 --
--                 -- @since 3.1.0
--                 --
--                 -- @param string[]  hidden An array of IDs of meta boxes hidden by default.
--                 -- @param WP_Screen screen WP_Screen object of the current screen.
--                 --
--                 hidden = apply_filters( 'default_hidden_meta_boxes', hidden, screen );
--         end;

--         --
--         -- Filters the list of hidden meta boxes.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string[]  hidden       An array of IDs of hidden meta boxes.
--         -- @param WP_Screen screen       WP_Screen object of the current screen.
--         -- @param bool      use_defaults Whether to show the default meta boxes.
--         --                                Default true.
--         --
--         return apply_filters( 'hidden_meta_boxes', hidden, screen, use_defaults );
-- end;

-- --
-- -- Register and configure an admin screen option
-- --
-- -- @since 3.1.0
-- --
-- -- @param string option An option name.
-- -- @param mixed  args   Option-dependent arguments.
-- --
-- function add_screen_option( option, args = array() ) then
--         current_screen = get_current_screen();

--         if ( ! current_screen ) then
--                 return;
--         end;

--         current_screen.add_option( option, args );
-- end;

   ------------------------
   -- Get_Current_Screen --
   ------------------------

   function Get_Current_Screen
            return Adi_Class_Wp_Screens.Wp_Screen
   is
--         global current_screen;
   begin
--         if ( ! isset( current_screen ) ) then
--                 return null;
--         end;

      return Current_Screen;
   end Get_Current_Screen;

-- --
-- -- Set the current screen object
-- --
-- -- @since 3.0.0
-- --
-- -- @param string|WP_Screen hook_name Optional. The hook name (also known as the hook suffix) used to determine the screen,
-- --                                    or an existing screen object.
-- --
-- function set_current_screen( hook_name = '' ) then
--         WP_Screen::get( hook_name ).set_current_screen();
-- end;

end Adi_Screens;
