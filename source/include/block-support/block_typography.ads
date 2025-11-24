--
-- Typography block support flag.
--
-- @package WordPress
-- @since 5.6.0
--

with Arrays;

package Block_Typography
is
   use Arrays;
-- --
-- -- Registers the style and typography block attributes for block types that support it.
-- --
-- -- @since 5.6.0
-- -- @access private
-- --
-- -- @param WP_Block_Type block_type Block Type.
-- --
-- function wp_register_typography_support( block_type ) then
--         if ( ! property_exists( block_type, "supports" ) ) then
--                 return;
--         end;

--         typography_supports = _wp_array_get( block_type->supports, array( "typography" ), false );
--         if ( ! typography_supports ) then
--                 return;
--         end;

--         has_font_family_support     = _wp_array_get( typography_supports, array( "__experimentalFontFamily" ), false );
--         has_font_size_support       = _wp_array_get( typography_supports, array( "fontSize" ), false );
--         has_font_style_support      = _wp_array_get( typography_supports, array( "__experimentalFontStyle" ), false );
--         has_font_weight_support     = _wp_array_get( typography_supports, array( "__experimentalFontWeight" ), false );
--         has_letter_spacing_support  = _wp_array_get( typography_supports, array( "__experimentalLetterSpacing" ), false );
--         has_line_height_support     = _wp_array_get( typography_supports, array( "lineHeight" ), false );
--         has_text_decoration_support = _wp_array_get( typography_supports, array( "__experimentalTextDecoration" ), false );
--         has_text_transform_support  = _wp_array_get( typography_supports, array( "__experimentalTextTransform" ), false );

--         has_typography_support = has_font_family_support
--                 || has_font_size_support
--                 || has_font_style_support
--                 || has_font_weight_support
--                 || has_letter_spacing_support
--                 || has_line_height_support
--                 || has_text_decoration_support
--                 || has_text_transform_support;

--         if ( ! block_type->attributes ) then
--                 block_type->attributes = array();
--         end;

--         if ( has_typography_support && ! array_key_exists( "style", block_type->attributes ) ) then
--                 block_type->attributes["style"] = array(
--                         "type" => "object",
--                 );
--         end;

--         if ( has_font_size_support && ! array_key_exists( "fontSize", block_type->attributes ) ) then
--                 block_type->attributes["fontSize"] = array(
--                         "type" => "string",
--                 );
--         end;

--         if ( has_font_family_support && ! array_key_exists( "fontFamily", block_type->attributes ) ) then
--                 block_type->attributes["fontFamily"] = array(
--                         "type" => "string",
--                 );
--         end;
-- end;

-- --
-- -- Adds CSS classes and inline styles for typography features such as font sizes
-- -- to the incoming attributes array. This will be applied to the block markup in
-- -- the front-end.
-- --
-- -- @since 5.6.0
-- -- @since 6.1.0 Used the style engine to generate CSS and classnames.
-- -- @access private
-- --
-- -- @param WP_Block_Type block_type       Block type.
-- -- @param array         block_attributes Block attributes.
-- -- @return array Typography CSS classes and inline styles.
-- --
-- function wp_apply_typography_support( block_type, block_attributes ) then
--         if ( ! property_exists( block_type, "supports" ) ) then
--                 return array();
--         end;

--         typography_supports = _wp_array_get( block_type->supports, array( "typography" ), false );
--         if ( ! typography_supports ) then
--                 return array();
--         end;

--         if ( wp_should_skip_block_supports_serialization( block_type, "typography" ) ) then
--                 return array();
--         end;

--         has_font_family_support     = _wp_array_get( typography_supports, array( "__experimentalFontFamily" ), false );
--         has_font_size_support       = _wp_array_get( typography_supports, array( "fontSize" ), false );
--         has_font_style_support      = _wp_array_get( typography_supports, array( "__experimentalFontStyle" ), false );
--         has_font_weight_support     = _wp_array_get( typography_supports, array( "__experimentalFontWeight" ), false );
--         has_letter_spacing_support  = _wp_array_get( typography_supports, array( "__experimentalLetterSpacing" ), false );
--         has_line_height_support     = _wp_array_get( typography_supports, array( "lineHeight" ), false );
--         has_text_decoration_support = _wp_array_get( typography_supports, array( "__experimentalTextDecoration" ), false );
--         has_text_transform_support  = _wp_array_get( typography_supports, array( "__experimentalTextTransform" ), false );

--         // Whether to skip individual block support features.
--         should_skip_font_size       = wp_should_skip_block_supports_serialization( block_type, "typography", "fontSize" );
--         should_skip_font_family     = wp_should_skip_block_supports_serialization( block_type, "typography", "fontFamily" );
--         should_skip_font_style      = wp_should_skip_block_supports_serialization( block_type, "typography", "fontStyle" );
--         should_skip_font_weight     = wp_should_skip_block_supports_serialization( block_type, "typography", "fontWeight" );
--         should_skip_line_height     = wp_should_skip_block_supports_serialization( block_type, "typography", "lineHeight" );
--         should_skip_text_decoration = wp_should_skip_block_supports_serialization( block_type, "typography", "textDecoration" );
--         should_skip_text_transform  = wp_should_skip_block_supports_serialization( block_type, "typography", "textTransform" );
--         should_skip_letter_spacing  = wp_should_skip_block_supports_serialization( block_type, "typography", "letterSpacing" );

--         typography_block_styles = array();
--         if ( has_font_size_support && ! should_skip_font_size ) then
--                 preset_font_size                    = array_key_exists( "fontSize", block_attributes )
--                         ? "var:preset|font-size|thenblock_attributes["fontSize"]end;"
--                         : null;
--                 custom_font_size                    = isset( block_attributes["style"]["typography"]["fontSize"] )
--                         ? block_attributes["style"]["typography"]["fontSize"]
--                         : null;
--                 typography_block_styles["fontSize"] = preset_font_size ? preset_font_size : wp_get_typography_font_size_value(
--                         array(
--                                 "size" => custom_font_size,
--                         )
--                 );
--         end;

--         if ( has_font_family_support && ! should_skip_font_family ) then
--                 preset_font_family                    = array_key_exists( "fontFamily", block_attributes )
--                         ? "var:preset|font-family|thenblock_attributes["fontFamily"]end;"
--                         : null;
--                 custom_font_family                    = isset( block_attributes["style"]["typography"]["fontFamily"] )
--                         ? wp_typography_get_preset_inline_style_value( block_attributes["style"]["typography"]["fontFamily"], "font-family" )
--                         : null;
--                 typography_block_styles["fontFamily"] = preset_font_family ? preset_font_family : custom_font_family;
--         end;

--         if (
--                 has_font_style_support &&
--                 ! should_skip_font_style &&
--                 isset( block_attributes["style"]["typography"]["fontStyle"] )
--         ) then
--                 typography_block_styles["fontStyle"] = wp_typography_get_preset_inline_style_value(
--                         block_attributes["style"]["typography"]["fontStyle"],
--                         "font-style"
--                 );
--         end;

--         if (
--                 has_font_weight_support &&
--                 ! should_skip_font_weight &&
--                 isset( block_attributes["style"]["typography"]["fontWeight"] )
--         ) then
--                 typography_block_styles["fontWeight"] = wp_typography_get_preset_inline_style_value(
--                         block_attributes["style"]["typography"]["fontWeight"],
--                         "font-weight"
--                 );
--         end;

--         if ( has_line_height_support && ! should_skip_line_height ) then
--                 typography_block_styles["lineHeight"] = _wp_array_get( block_attributes, array( "style", "typography", "lineHeight" ) );
--         end;

--         if (
--                 has_text_decoration_support &&
--                 ! should_skip_text_decoration &&
--                 isset( block_attributes["style"]["typography"]["textDecoration"] )
--         ) then
--                 typography_block_styles["textDecoration"] = wp_typography_get_preset_inline_style_value(
--                         block_attributes["style"]["typography"]["textDecoration"],
--                         "text-decoration"
--                 );
--         end;

--         if (
--                 has_text_transform_support &&
--                 ! should_skip_text_transform &&
--                 isset( block_attributes["style"]["typography"]["textTransform"] )
--         ) then
--                 typography_block_styles["textTransform"] = wp_typography_get_preset_inline_style_value(
--                         block_attributes["style"]["typography"]["textTransform"],
--                         "text-transform"
--                 );
--         end;

--         if (
--                 has_letter_spacing_support &&
--                 ! should_skip_letter_spacing &&
--                 isset( block_attributes["style"]["typography"]["letterSpacing"] )
--         ) then
--                 typography_block_styles["letterSpacing"] = wp_typography_get_preset_inline_style_value(
--                         block_attributes["style"]["typography"]["letterSpacing"],
--                         "letter-spacing"
--                 );
--         end;

--         attributes = array();
--         styles     = wp_style_engine_get_styles(
--                 array( "typography" => typography_block_styles ),
--                 array( "convert_vars_to_classnames" => true )
--         );

--         if ( ! empty( styles["classnames"] ) ) then
--                 attributes["class"] = styles["classnames"];
--         end;

--         if ( ! empty( styles["css"] ) ) then
--                 attributes["style"] = styles["css"];
--         end;

--         return attributes;
-- end;

-- --
-- -- Generates an inline style value for a typography feature e.g. text decoration,
-- -- text transform, and font style.
-- --
-- -- Note: This function is for backwards compatibility.
-- ---- It is necessary to parse older blocks whose typography styles contain presets.
-- ---- It mostly replaces the deprecated `wp_typography_get_css_variable_inline_style()`,
-- --   but skips compiling a CSS declaration as the style engine takes over this role.
-- -- @link https://github.com/wordpress/gutenberg/pull/27555
-- --
-- -- @since 6.1.0
-- --
-- -- @param string style_value  A raw style value for a single typography feature from a block"s style attribute.
-- -- @param string css_property Slug for the CSS property the inline style sets.
-- -- @return string A CSS inline style value.
-- --
-- function wp_typography_get_preset_inline_style_value( style_value, css_property ) then
--         // If the style value is not a preset CSS variable go no further.
--         if ( empty( style_value ) || ! str_contains( style_value, "var:preset|thencss_propertyend;|" ) ) then
--                 return style_value;
--         end;

--         /*
--         -- For backwards compatibility.
--         -- Presets were removed in WordPress/gutenberg#27555.
--         -- A preset CSS variable is the style.
--         -- Gets the style value from the string and return CSS style.
--         --
--         index_to_splice = strrpos( style_value, "|" ) + 1;
--         slug            = _wp_to_kebab_case( substr( style_value, index_to_splice ) );

--         // Return the actual CSS inline style value,
--         // e.g. `var(--wp--preset--text-decoration--underline);`.
--         return sprintf( "var(--wp--preset--%s--%s);", css_property, slug );
-- end;

-- --
-- -- Renders typography styles/content to the block wrapper.
-- --
-- -- @since 6.1.0
-- --
-- -- @param string block_content Rendered block content.
-- -- @param array  block         Block object.
-- -- @return string Filtered block content.
-- --
-- function wp_render_typography_support( block_content, block ) then
--         if ( ! isset( block["attrs"]["style"]["typography"]["fontSize"] ) ) then
--                 return block_content;
--         end;

--         custom_font_size = block["attrs"]["style"]["typography"]["fontSize"];
--         fluid_font_size  = wp_get_typography_font_size_value( array( "size" => custom_font_size ) );

--         /*
--         -- Checks that fluid_font_size does not match custom_font_size,
--         -- which means it"s been mutated by the fluid font size functions.
--         --
--         if ( ! empty( fluid_font_size ) && fluid_font_size !== custom_font_size ) then
--                 // Replaces the first instance of `font-size:custom_font_size` with `font-size:fluid_font_size`.
--                 return preg_replace( "/font-size\s*:\s*" . preg_quote( custom_font_size, "/" ) . "\s*;?/", "font-size:" . esc_attr( fluid_font_size ) . ";", block_content, 1 );
--         end;

--         return block_content;
-- end;

   --
   -- Checks a string for a unit and value and returns an array
   -- consisting of `"value"` and `"unit"`, e.g. array( "42", "rem" ).
   --
   -- @since 6.1.0
   --
   -- @param string|int|float raw_value Raw size value from theme.json.
   -- @param array            options   {
   --     Optional. An associative array of options. Default is empty array.
   --
   --     @type string   coerce_to        Coerce the value to rem or px. Default
   --                                      `"rem"`.
   --     @type int      root_size_value  Value of root font size for rem|em <-> px
   --                                      conversion. Default `16`.
   --     @type string[] acceptable_units An array of font size units. Default
   --                                      `array( "rem", "px", "em" )`;
   -- }
   -- @return array|null An array consisting of `"value"` and `"unit"` properties on
   --                    success. `null` on failure.
   --
   function Wp_Get_Typography_Value_And_Unit
              (Raw_Value : Multi_Type;
               Options   : Array_Type := Empty_Array)
               return Array_Type;

   --
   -- Internal implementation of CSS clamp() based on available min/max viewport
   -- width and min/max font sizes.
   --
   -- @since 6.1.0
   -- @access private
   --
   -- @param array args {
   --     Optional. An associative array of values to calculate a fluid formula
   --     for font size. Default is empty array.
   --
   --     @type string maximum_viewport_width Maximum size up to which type will have
   --                                          fluidity.
   --     @type string minimum_viewport_width Minimum viewport size from which type
   --                                          will have fluidity.
   --     @type string maximum_font_size      Maximum font size for any clamp()
   --                                          calculation.
   --     @type string minimum_font_size      Minimum font size for any clamp()
   --                                          calculation.
   --     @type int    scale_factor           A scale factor to determine how fast a
   --                                          font scales within boundaries.
   -- }
   -- @return string|null A font-size value using clamp() on success, otherwise null.
   --
   function Wp_Get_Computed_Fluid_Typography_Value
               (Args : Array_Type := Empty_Array)
               return String;
--         maximum_viewport_width_raw = isset( args["maximum_viewport_width"] ) ? args["maximum_viewport_width"] : null;
--         minimum_viewport_width_raw = isset( args["minimum_viewport_width"] ) ? args["minimum_viewport_width"] : null;
--         maximum_font_size_raw      = isset( args["maximum_font_size"] ) ? args["maximum_font_size"] : null;
--         minimum_font_size_raw      = isset( args["minimum_font_size"] ) ? args["minimum_font_size"] : null;
--         scale_factor               = isset( args["scale_factor"] ) ? args["scale_factor"] : null;

--         // Normalizes the minimum font size in order to use the value for calculations.
--         minimum_font_size = wp_get_typography_value_and_unit( minimum_font_size_raw );

--         /*
--         -- We get a "preferred" unit to keep units consistent when calculating,
--         -- otherwise the result will not be accurate.
--         --
--         font_size_unit = isset( minimum_font_size["unit"] ) ? minimum_font_size["unit"] : "rem";

--         // Normalizes the maximum font size in order to use the value for calculations.
--         maximum_font_size = wp_get_typography_value_and_unit(
--                 maximum_font_size_raw,
--                 array(
--                         "coerce_to" => font_size_unit,
--                 )
--         );

--         // Checks for mandatory min and max sizes, and protects against unsupported units.
--         if ( ! maximum_font_size || ! minimum_font_size ) then
--                 return null;
--         end;

--         // Uses rem for accessible fluid target font scaling.
--         minimum_font_size_rem = wp_get_typography_value_and_unit(
--                 minimum_font_size_raw,
--                 array(
--                         "coerce_to" => "rem",
--                 )
--         );

--         // Viewport widths defined for fluid typography. Normalize units.
--         maximum_viewport_width = wp_get_typography_value_and_unit(
--                 maximum_viewport_width_raw,
--                 array(
--                         "coerce_to" => font_size_unit,
--                 )
--         );
--         minimum_viewport_width = wp_get_typography_value_and_unit(
--                 minimum_viewport_width_raw,
--                 array(
--                         "coerce_to" => font_size_unit,
--                 )
--         );

--         /*
--         -- Build CSS rule.
--         -- Borrowed from https://websemantics.uk/tools/responsive-font-calculator/.
--         --
--         view_port_width_offset = round( minimum_viewport_width["value"] / 100, 3 ) . font_size_unit;
--         linear_factor          = 100-- ( ( maximum_font_size["value"] - minimum_font_size["value"] ) / ( maximum_viewport_width["value"] - minimum_viewport_width["value"] ) );
--         linear_factor_scaled   = round( linear_factor-- scale_factor, 3 );
--         linear_factor_scaled   = empty( linear_factor_scaled ) ? 1 : linear_factor_scaled;
--         fluid_target_font_size = implode( "", minimum_font_size_rem ) . " + ((1vw - view_port_width_offset)-- linear_factor_scaled)";

--         return "clamp(minimum_font_size_raw, fluid_target_font_size, maximum_font_size_raw)";
-- end;

   --
   -- Returns a font-size value based on a given font-size preset.
   -- Takes into account fluid typography parameters and attempts to return a CSS
   -- formula depending on available, valid values.
   --
   -- @since 6.1.0
   -- @since 6.1.1 Adjusted rules for min and max font sizes.
   --
   -- @param array preset                     {
   --     Required. fontSizes preset value as seen in theme.json.
   --
   --     @type string           name Name of the font size preset.
   --     @type string           slug Kebab-case, unique identifier for the font size
   --                            preset.
   --     @type string|int|float size CSS font-size value, including units if
   --                            applicable.
   -- }
   -- @param bool  should_use_fluid_typography An override to switch fluid typography
   --                                            "on". Can be used for unit testing.
   --                                            Default is false.
   -- @return string|null Font-size value or null if a size is not passed in preset.
   --
   function Wp_Get_Typography_Font_Size_Value
              (Preset : Array_Type;
               Should_Use_Fluid_Typography : Boolean := False)
               return String;

-- // Register the block support.
-- WP_Block_Supports::get_instance()->register(
--         "typography",
--         array(
--                 "register_attribute" => "wp_register_typography_support",
--                 "apply"              => "wp_apply_typography_support",
--         )
-- );

end Block_Typography;
