--
-- Block Editor API.
--
-- @package WordPress
-- @subpackage Editor
-- @since 5.8.0
--

with Arrays;
with Array_Lists;
with Lists;

with Class_Block_Editor_Contexts;

package Inc_Block_Editors
is
   use Arrays;
   use Lists;

   --
   -- Returns the list of default categories for block types.
   --
   -- @since 5.8.0
   --
   -- @return array[] Array of categories for block types.
   --
   function Get_Default_Block_Categories
            return Array_Lists.Array_List;

   --
   -- Returns all the categories for block types that will be shown in the block
   -- editor.
   --
   -- @since 5.0.0
   -- @since 5.8.0 It is possible to pass the block editor context as param.
   --
   -- @param WP_Post|WP_Block_Editor_Context post_or_block_editor_context
   --           The current post object or the block editor context.
   --
   -- @return array[] Array of categories for block types.
   --
   function Get_Block_Categories
              (Post_Or_Block_Editor_Context :
                 Class_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return Array_Lists.Array_List;

   --
   -- Gets the list of allowed block types to use in the block editor.
   --
   -- @since 5.8.0
   --
   -- @param WP_Block_Editor_Context block_editor_context The current block editor
   --                                                      context.
   --
   -- @return bool|string[] Array of block type slugs, or boolean to enable/disable
   --                        all.
   --
   function Get_Allowed_Block_Types
              (Block_Editor_Context :
                 Class_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return List_Type;

   --
   -- Returns the default block editor settings.
   --
   -- @since 5.8.0
   --
   -- @return array The default block editor settings.
   --
   function Get_Default_Block_Editor_Settings
            return Array_Type;

   --
   -- Returns the block editor settings needed to use the Legacy Widget block which
   -- is not registered by default.
   --
   -- @since 5.8.0
   --
   -- @return array Settings to be used with get_block_editor_settings().
   --

   function Get_Legacy_Widget_Block_Editor_Settings
            return Array_Type;

   --
   -- Collect the block editor assets that need to be loaded into the editor's iframe.
   --
   -- @since 6.0.0
   -- @access private
   --
   -- @global string pagenow The filename of the current screen.
   --
   -- @return array {
   --     The block editor assets.
   --
   --     @type string|false styles  String containing the HTML for styles.
   --     @type string|false scripts String containing the HTML for scripts.
   -- }
   --
   function X_Wp_Get_Iframed_Editor_Assets
            return Array_Type;

   --
   -- Returns the contextualized block editor settings for a selected editor context.
   --
   -- @since 5.8.0
   --
   -- @param array                   custom_settings      Custom settings to use with
   --                                                      the given editor type.
   -- @param WP_Block_Editor_Context block_editor_context The current block editor
   --                                                      context.
   --
   -- @return array The contextualized block editor settings.
   --
   function Get_Block_Editor_Settings
              (Custom_Settings      : Array_Type;
               Block_Editor_Context :
                 Class_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return Array_Type;

   --
   -- Creates an array of theme styles to load into the block editor.
   --
   -- @since 5.8.0
   --
   -- @global array editor_styles
   --
   -- @return array An array of theme styles for the block editor.
   --
   function Get_Block_Editor_Theme_Styles
            return Array_Lists.Array_List;

end Inc_Block_Editors;
