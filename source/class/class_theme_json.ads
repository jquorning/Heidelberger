--
-- WP_Theme_JSON class
--
-- @package WordPress
-- @subpackage Theme
-- @since 5.8.0
--

with Arrays;
with Array_Lists;
with Lists;

package Class_Theme_JSON
is
   use Arrays;
   use Lists;

--   function To_UString (Item : String) return UStrings.UString
--     renames UStrings.To_UString;

   --
   -- Class that encapsulates the processing of structures that adhere to the theme.json spec.
   --
   -- This class is for internal core usage and is not supposed to be used by extenders (plugins and/or themes).
   -- This is a low-level API that may need to do breaking changes. Please,
   -- use get_global_settings, get_global_styles, and get_global_stylesheet instead.
   --
   -- @access private
   --
   -- #[AllowDynamicProperties]
   type Wp_Theme_JSON is tagged
      record

         --
         -- Container of data in theme.json format.
         --
         -- @since 5.8.0
         -- @var array
         --
         -- protected
         Theme_JSON : Array_Type; --  = null;

      end record; -- probably misplaced

   --
   -- The CSS selector for the top-level styles.
   --
   -- @since 5.8.0
   -- @var string
   --
   ROOT_BLOCK_SELECTOR : constant String := "body";

   --
   -- Holds block metadata extracted from block.json
   -- to be shared among all instances so we don't
   -- process it twice.
   --
   -- @since 5.8.0
   -- @since 6.1.0 Initialize as an empty array.
   -- @var array
   --
   -- protected static
   Blocks_Metadata : Array_Type;

   --
   -- The sources of data this object can represent.
   --
   -- @since 5.8.0
   -- @since 6.1.0 Added "blocks".
   -- @var string[]
   --
   VALID_ORIGINS : constant List_Type :=
     ["DEFAULT", "blocks", "theme", "custom"];

   --
   -- Presets are a set of values that serve
   -- to bootstrap some styles: colors, font sizes, etc.
   --
   -- They are a unkeyed array of values such as:
   --
   -- ```php
   -- array(
   --   array(
   --     "slug"      => "unique-name-within-the-set",
   --     "name"      => "Name for the UI",
   --     <value_key> => "value"
   --   ),
   -- )
   -- ```
   --
   -- This contains the necessary metadata to process them:
   --
   -- - path             => Where to find the preset within the settings section.
   -- - prevent_override => Disables override of default presets by theme presets.
   --                       The relationship between whether to override the defaults
   --                       and whether the defaults are enabled is inverse:
   --                         - If defaults are enabled  => theme presets should not
   --                           be overriden
   --                         - If defaults are disabled => theme presets should be
   --                           overriden
   --                       For example, a theme sets defaultPalette to false,
   --                       making the default palette hidden from the user.
   --                       In that case, we want all the theme presets to be present,
   --                       so they should override the defaults by setting this false.
   -- - use_default_names => whether to use the default names
   -- - value_key        => the key that represents the value
   -- - value_func       => optionally, instead of value_key, a function to generate
   --                       the value that takes a preset as an argument
   --                       (either value_key or value_func should be present)
   -- - css_vars         => template string to use in generating the CSS Custom
   --                       Property.
   --                       Example output: "--wp--preset--duotone--blue: <value>"
   --                       will generate as many CSS Custom Properties as presets
   --                       defined substituting the $slug for the slug's value for
   --                       each preset value.
   -- - classes          => array containing a structure with the classes to
   --                       generate for the presets, where for each array item
   --                       the key is the class name and the value the property name.
   --                       The "$slug" substring will be replaced by the slug of
   --                       each preset.
   --                       For example:
   --                       "classes" => array(
   --                         ".has-$slug-color"            => "color",
   --                         ".has-$slug-background-color" => "background-color",
   --                         ".has-$slug-border-color"     => "border-color",
   --                       )
   -- - properties       => array of CSS properties to be used by kses to
   --                       validate the content of each preset
   --                       by means of the remove_insecure_properties method.
   --
   -- @since 5.8.0
   -- @since 5.9.0 Added the `color.duotone` and `typography.fontFamilies` presets,
   --              `use_default_names` preset key, and simplified the metadata
   --              structure.
   -- @since 6.0.0 Replaced `override` with `prevent_override` and updated the
   --              `prevent_overried` value for `color.duotone` to use
   --              `color.defaultDuotone`.
   -- @var array
   --
   PRESETS_METADATA : constant Array_Lists.Array_List :=
     [
       Array_Lists.To_Array_Type ([
         Build ("path",              List_Type'["color", "palette"]),
         Build ("prevent_override",  List_Type'["color", "defaultPalette"]),
         Build ("use_default_names", False),
         Build ("value_key",         "color"),
         Build ("css_vars",          "--wp--preset--color--$slug"),
         Build ("classes",           Array_Lists.To_Array_Type ([
           Build (".has-$slug-color",            "color"),
           Build (".has-$slug-background-color", "background-color"),
           Build (".has-$slug-border-color",     "border-color")
         ])),
         Build ("properties",
                List_Type'["color", "background-color", "border-color"])
       ]),
       Array_Lists.To_Array_Type ([
         Build ("path",              List_Type'["color", "gradients"]),
         Build ("prevent_override",  List_Type'["color", "defaultGradients"]),
         Build ("use_default_names", False),
         Build ("value_key",         "gradient"),
         Build ("css_vars",          "--wp--preset--gradient--$slug"),
         Build ("classes",           Array_Lists.To_Array_Type ([
           Build (".has-$slug-gradient-background", "background")])),
         Build ("properties",        List_Type'["background"])
       ]),
       Array_Lists.To_Array_Type ([
         Build ("path",              List_Type'["color", "duotone"]),
         Build ("prevent_override",  List_Type'["color", "defaultDuotone"]),
         Build ("use_default_names", False),
         Build ("value_func",        "wp_get_duotone_filter_property"),
         Build ("css_vars",          "--wp--preset--duotone--$slug"),
         Build ("classes",           Empty_Array),
         Build ("properties",        List_Type'["filter"])
       ]),
       Array_Lists.To_Array_Type ([
         Build ("path",              List_Type'["typography", "fontSizes"]),
         Build ("prevent_override",  False),
         Build ("use_default_names", True),
         Build ("value_func",        "wp_get_typography_font_size_value"),
         Build ("css_vars",          "--wp--preset--font-size--$slug"),
         Build ("classes",           Array_Lists.To_Array_Type ([
           Build (".has-$slug-font-size", "font-size")])),
         Build ("properties",        List_Type'["font-size"])
       ]),
       Array_Lists.To_Array_Type ([
         Build ("path",              List_Type'["typography", "fontFamilies"]),
         Build ("prevent_override",  False),
         Build ("use_default_names", False),
         Build ("value_key",         "fontFamily"),
         Build ("css_vars",          "--wp--preset--font-family--$slug"),
         Build ("classes",           Array_Lists.To_Array_Type ([
           Build (".has-$slug-font-family", "font-family")])),
         Build ("properties",        List_Type'["font-family"])
       ]),
       Array_Lists.To_Array_Type ([
         Build ("path",              List_Type'["spacing", "spacingSizes"]),
         Build ("prevent_override",  False),
         Build ("use_default_names", True),
         Build ("value_key",         "size"),
         Build ("css_vars",          "--wp--preset--spacing--$slug"),
         Build ("classes",           Empty_Array),
         Build ("properties",        List_Type'["padding", "margin"])
       ])
     ];

   --
   -- Metadata for style properties.
   --
   -- Each element is a direct mapping from the CSS property name to the
   -- path to the value in theme.json & block attributes.
   --
   -- @since 5.8.0
   -- @since 5.9.0 Added the `border-*`, `font-family`, `font-style`, `font-weight`,
   --              `letter-spacing`, `margin-*`, `padding-*`, `--wp--style--block-gap`,
   --              `text-decoration`, `text-transform`, and `filter` properties,
   --              simplified the metadata structure.
   -- @since 6.1.0 Added the `border-*-color`, `border-*-width`, `border-*-style`,
   --              `--wp--style--root--padding-*`, and `box-shadow` properties,
   --              removed the `--wp--style--block-gap` property.
   -- @var array
   --
   PROPERTIES_METADATA : constant Array_Type := Array_Lists.To_Array_Type ([
     Build ("background",                        List_Type'["color", "gradient"]),
     Build ("background-color",                  List_Type'["color", "background"]),
     Build ("border-radius",                     List_Type'["border", "radius"]),
     Build ("border-top-left-radius",            List_Type'["border", "radius", "topLeft"]),
     Build ("border-top-right-radius",           List_Type'["border", "radius", "topRight"]),
     Build ("border-bottom-left-radius",         List_Type'["border", "radius", "bottomLeft"]),
     Build ("border-bottom-right-radius",        List_Type'["border", "radius", "bottomRight"]),
     Build ("border-color",                      List_Type'["border", "color"]),
     Build ("border-width",                      List_Type'["border", "width"]),
     Build ("border-style",                      List_Type'["border", "style"]),
     Build ("border-top-color",                  List_Type'["border", "top", "color"]),
     Build ("border-top-width",                  List_Type'["border", "top", "width"]),
     Build ("border-top-style",                  List_Type'["border", "top", "style"]),
     Build ("border-right-color",                List_Type'["border", "right", "color"]),
     Build ("border-right-width",                List_Type'["border", "right", "width"]),
     Build ("border-right-style",                List_Type'["border", "right", "style"]),
     Build ("border-bottom-color",               List_Type'["border", "bottom", "color"]),
     Build ("border-bottom-width",               List_Type'["border", "bottom", "width"]),
     Build ("border-bottom-style",               List_Type'["border", "bottom", "style"]),
     Build ("border-left-color",                 List_Type'["border", "left", "color"]),
     Build ("border-left-width",                 List_Type'["border", "left", "width"]),
     Build ("border-left-style",                 List_Type'["border", "left", "style"]),
     Build ("color",                             List_Type'["color", "text"]),
     Build ("font-family",                       List_Type'["typography", "fontFamily"]),
     Build ("font-size",                         List_Type'["typography", "fontSize"]),
     Build ("font-style",                        List_Type'["typography", "fontStyle"]),
     Build ("font-weight",                       List_Type'["typography", "fontWeight"]),
     Build ("letter-spacing",                    List_Type'["typography", "letterSpacing"]),
     Build ("line-height",                       List_Type'["typography", "lineHeight"]),
     Build ("margin",                            List_Type'["spacing", "margin"]),
     Build ("margin-top",                        List_Type'["spacing", "margin", "top"]),
     Build ("margin-right",                      List_Type'["spacing", "margin", "right"]),
     Build ("margin-bottom",                     List_Type'["spacing", "margin", "bottom"]),
     Build ("margin-left",                       List_Type'["spacing", "margin", "left"]),
     Build ("padding",                           List_Type'["spacing", "padding"]),
     Build ("padding-top",                       List_Type'["spacing", "padding", "top"]),
     Build ("padding-right",                     List_Type'["spacing", "padding", "right"]),
     Build ("padding-bottom",                    List_Type'["spacing", "padding", "bottom"]),
     Build ("padding-left",                      List_Type'["spacing", "padding", "left"]),
     Build ("--wp--style--root--padding",        List_Type'["spacing", "padding"]),
     Build ("--wp--style--root--padding-top",    List_Type'["spacing", "padding", "top"]),
     Build ("--wp--style--root--padding-right",  List_Type'["spacing", "padding", "right"]),
     Build ("--wp--style--root--padding-bottom", List_Type'["spacing", "padding", "bottom"]),
     Build ("--wp--style--root--padding-left",   List_Type'["spacing", "padding", "left"]),
     Build ("text-decoration",                   List_Type'["typography", "textDecoration"]),
     Build ("text-transform",                    List_Type'["typography", "textTransform"]),
     Build ("filter",                            List_Type'["filter", "duotone"]),
     Build ("box-shadow",                        List_Type'["shadow"])
  ]);

   --
   -- Protected style properties.
   --
   -- These style properties are only rendered if a setting enables it
   -- via a value other than `null`.
   --
   -- Each element maps the style property to the corresponding theme.json
   -- setting key.
   --
   -- @since 5.9.0
   --
   PROTECTED_PROPERTIES : constant Array_Type := Array_Lists.To_Array_Type ([
     Build ("spacing.blockGap", List_Type'["spacing", "blockGap"])
   ]);

   --
   -- The top-level keys a theme.json can have.
   --
   -- @since 5.8.0 As `ALLOWED_TOP_LEVEL_KEYS`.
   -- @since 5.9.0 Renamed from `ALLOWED_TOP_LEVEL_KEYS` to `VALID_TOP_LEVEL_KEYS`,
   --              added the `customTemplates` and `templateParts` values.
   -- @var string[]
   --
   VALID_TOP_LEVEL_KEYS : constant List_Type := List_Type'[
     "customTemplates",
     "patterns",
     "settings",
     "styles",
     "templateParts",
     "version",
     "title"
   ];

   --
   -- The valid properties under the settings key.
   --
   -- @since 5.8.0 As `ALLOWED_SETTINGS`.
   -- @since 5.9.0 Renamed from `ALLOWED_SETTINGS` to `VALID_SETTINGS`,
   --              added new properties for `border`, `color`, `spacing`,
   --              and `typography`, and renamed others according to the new schema.
   -- @since 6.0.0 Added `color.defaultDuotone`.
   -- @since 6.1.0 Added `layout.definitions` and `useRootPaddingAwareAlignments`.
   -- @var array
   --
   VALID_SETTINGS : constant Array_Type := Array_Lists.To_Array_Type ([
                Build ("appearanceTools",               Null_Value),
                Build ("useRootPaddingAwareAlignments", Null_Value),
                Build ("border",                        Array_Lists.To_Array_Type ([
                        Build ("color",  Null_Value),
                        Build ("radius", Null_Value),
                        Build ("style",  Null_Value),
                        Build ("width",  Null_Value)
                ])),
                Build ("color",                         Array_Lists.To_Array_Type ([
                        Build ("background",       Null_Value),
                        Build ("custom",           Null_Value),
                        Build ("customDuotone",    Null_Value),
                        Build ("customGradient",   Null_Value),
                        Build ("defaultDuotone",   Null_Value),
                        Build ("defaultGradients", Null_Value),
                        Build ("defaultPalette",   Null_Value),
                        Build ("duotone",          Null_Value),
                        Build ("gradients",        Null_Value),
                        Build ("link",             Null_Value),
                        Build ("palette",          Null_Value),
                        Build ("text",             Null_Value)
                ])),
                Build ("custom",                        Null_Value),
                Build ("layout",                        Array_Lists.To_Array_Type ([
                        Build ("contentSize", Null_Value),
                        Build ("definitions", Null_Value),
                        Build ("wideSize",    Null_Value)
                ])),
                Build ("spacing",                       Array_Lists.To_Array_Type ([
                        Build ("customSpacingSize", Null_Value),
                        Build ("spacingSizes",      Null_Value),
                        Build ("spacingScale",      Null_Value),
                        Build ("blockGap",          Null_Value),
                        Build ("margin",            Null_Value),
                        Build ("padding",           Null_Value),
                        Build ("units",             Null_Value)
                ])),
                Build ("typography",                    Array_Lists.To_Array_Type ([
                        Build ("fluid",          Null_Value),
                        Build ("customFontSize", Null_Value),
                        Build ("dropCap",        Null_Value),
                        Build ("fontFamilies",   Null_Value),
                        Build ("fontSizes",      Null_Value),
                        Build ("fontStyle",      Null_Value),
                        Build ("fontWeight",     Null_Value),
                        Build ("letterSpacing",  Null_Value),
                        Build ("lineHeight",     Null_Value),
                        Build ("textDecoration", Null_Value),
                        Build ("textTransform",  Null_Value)
                ]))
        ]);

   --
   -- The valid properties under the styles key.
   --
   -- @since 5.8.0 As `ALLOWED_STYLES`.
   -- @since 5.9.0 Renamed from `ALLOWED_STYLES` to `VALID_STYLES`,
   --              added new properties for `border`, `filter`, `spacing`,
   --              and `typography`.
   -- @since 6.1.0 Added new side properties for `border`,
   --              added new property `shadow`,
   --              updated `blockGap` to be allowed at any level.
   -- @var array
   --
   VALID_STYLES : constant Array_Type := Array_Lists.To_Array_Type ([
                Build ("border",     Array_Lists.To_Array_Type ([
                        Build ("color",  Null_Value),
                        Build ("radius", Null_Value),
                        Build ("style",  Null_Value),
                        Build ("width",  Null_Value),
                        Build ("top",    Null_Value),
                        Build ("right",  Null_Value),
                        Build ("bottom", Null_Value),
                        Build ("left",   Null_Value)
                ])),
                Build ("color",      Array_Lists.To_Array_Type ([
                        Build ("background", Null_Value),
                        Build ("gradient",   Null_Value),
                        Build ("text",       Null_Value)
                ])),
                Build ("filter",     Array_Lists.To_Array_Type ([
                        Build ("duotone", Null_Value)
                ])),
                Build ("shadow",     Null_Value),
                Build ("spacing",    Array_Lists.To_Array_Type ([
                        Build ("margin",   Null_Value),
                        Build ("padding",  Null_Value),
                        Build ("blockGap", Null_Value)
                ])),
                Build ("typography", Array_Lists.To_Array_Type ([
                        Build ("fontFamily",     Null_Value),
                        Build ("fontSize",       Null_Value),
                        Build ("fontStyle",      Null_Value),
                        Build ("fontWeight",     Null_Value),
                        Build ("letterSpacing",  Null_Value),
                        Build ("lineHeight",     Null_Value),
                        Build ("textDecoration", Null_Value),
                        Build ("textTransform",  Null_Value)
                ]))
        ]);

   --
   -- Defines which pseudo selectors are enabled for which elements.
   --
   -- The order of the selectors should be: visited, hover, focus, active.
   -- This is to ensure that "visited" has the lowest specificity
   -- and the other selectors can always overwrite it.
   --
   -- See https://core.trac.wordpress.org/ticket/56928.
   -- Note: this will affect both top-level and block-level elements.
   --
   -- @since 6.1.0
   --
   VALID_ELEMENT_PSEUDO_SELECTORS : constant Array_Type :=
     Array_Lists.To_Array_Type ([
       Build ("link",   List_Type'[":visited", ":hover", ":focus", ":active"]),
       Build ("button", List_Type'[":visited", ":hover", ":focus", ":active"])
     ]);

   --
   -- The valid elements that can be found under styles.
   --
   -- @since 5.8.0
   -- @since 6.1.0 Added `heading`, `button`. and `caption` elements.
   -- @var string[]
   --
   ELEMENTS : constant Array_Type := Array_Lists.To_Array_Type ([
     Build ("link",    "a:where(:not(.wp-element-button))"),
     -- The `where` is needed to lower the specificity.
     Build ("heading", "h1, h2, h3, h4, h5, h6"),
     Build ("h1",      "h1"),
     Build ("h2",      "h2"),
     Build ("h3",      "h3"),
     Build ("h4",      "h4"),
     Build ("h5",      "h5"),
     Build ("h6",      "h6"),
     -- We have the .wp-block-button__link class so that this will target older
     -- buttons that have been serialized.
     Build ("button",  ".wp-element-button, .wp-block-button__link"),
     -- The block classes are necessary to target older content that won't use the
     -- new class names.
     Build ("caption", ".wp-element-caption, .wp-block-audio figcaption, .wp-block-embed figcaption, .wp-block-gallery figcaption, .wp-block-image figcaption, .wp-block-table figcaption, .wp-block-video figcaption"),
     Build ("cite",    "cite")
   ]);

--         const __EXPERIMENTAL_ELEMENT_CLASS_NAMES = array(
--                 "button"  => "wp-element-button",
--                 "caption" => "wp-element-caption",
--         );

   --
   -- List of block support features that can have their related styles
   -- generated under their own feature level selector rather than the block"s.
   --
   -- @since 6.1.0
   -- @var string[]
   --
   BLOCK_SUPPORT_FEATURE_LEVEL_SELECTORS : constant Array_Type :=
     Array_Lists.To_Array_Type ([
       Build ("__experimentalBorder", "border"),
       Build ("color",                "color"),
       Build ("spacing",              "spacing"),
       Build ("typography",           "typography")
     ]);

--         --
--         -- Returns a class name by an element name.
--         --
--         -- @since 6.1.0
--         --
--         -- @param string $element The name of the element.
--         -- @return string The name of the class.
--         --
--         public static function get_element_class_name( $element ) then
--                 $class_name = "";

--                 -- TODO: Replace array_key_exists() with isset() check once WordPress drops
--                 -- support for PHP 5.6. See https://core.trac.wordpress.org/ticket/57067.
--                 if ( array_key_exists( $element, static::__EXPERIMENTAL_ELEMENT_CLASS_NAMES ) ) then
--                         $class_name = static::__EXPERIMENTAL_ELEMENT_CLASS_NAMES[ $element ];
--                 end;

--                 return $class_name;
--         end;

--         --
--         -- Options that settings.appearanceTools enables.
--         --
--         -- @since 6.0.0
--         -- @var array
--         --
--         const APPEARANCE_TOOLS_OPT_INS = array(
--                 array( "border", "color" ),
--                 array( "border", "radius" ),
--                 array( "border", "style" ),
--                 array( "border", "width" ),
--                 array( "color", "link" ),
--                 array( "spacing", "blockGap" ),
--                 array( "spacing", "margin" ),
--                 array( "spacing", "padding" ),
--                 array( "typography", "lineHeight" ),
--         );

--         --
--         -- The latest version of the schema in use.
--         --
--         -- @since 5.8.0
--         -- @since 5.9.0 Changed value from 1 to 2.
--         -- @var int
--         --
   LATEST_SCHEMA : constant Integer := 2;

   --
   -- Constructor.
   --
   -- @since 5.8.0
   --
   -- @param array  $theme_json A structure that follows the theme.json schema.
   -- @param string $origin     Optional. What source of data this object represents.
   --                           One of "default", "theme", or "custom". Default
   --                           "theme".
   --
   function X_Construct (Theme_JSON : Array_Type := Empty_Array;
                         Origin     : String     := "theme")
                         return Wp_Theme_JSON;

   --
   -- Enables some opt-in settings if theme declared support.
   --
   -- @since 5.9.0
   --
   -- @param array $theme_json A theme.json structure to modify.
   -- @return array The modified theme.json structure.
   --
   -- protected static
   function Maybe_Opt_In_Into_Settings (Theme_JSON : Array_Type)
                                        return Array_Type;

--         --
--         -- Enables some settings.
--         --
--         -- @since 5.9.0
--         --
--         -- @param array $context The context to which the settings belong.
--         --
--         protected static function do_opt_in_into_settings( &$context ) then
--                 foreach ( static::APPEARANCE_TOOLS_OPT_INS as $path ) then
--                         -- Use "unset prop" as a marker instead of "null" because
--                         -- "null" can be a valid value for some props (e.g. blockGap).
--                         if ( "unset prop" === _wp_array_get( $context, $path, "unset prop" ) ) then
--                                 _wp_array_set( $context, $path, true );
--                         end;
--                 end;

--                 unset( $context["appearanceTools"] );
--         end;

   --
   -- Sanitizes the input according to the schemas.
   --
   -- @since 5.8.0
   -- @since 5.9.0 Added the `$valid_block_names` and `$valid_element_name` parameters.
   --
   -- @param array $input               Structure to sanitize.
   -- @param array $valid_block_names   List of valid block names.
   -- @param array $valid_element_names List of valid element names.
   -- @return array The sanitized output.
   --
   -- protected static
   function Sanitize (Input               : Array_Type;
                      Valid_Block_Names   : List_Type;
                      Valid_Element_Names : List_Type)
                      return Array_Type;

   --
   -- Appends a sub-selector to an existing one.
   --
   -- Given the compounded $selector "h1, h2, h3"
   -- and the $to_append selector ".some-class" the result will be
   -- "h1.some-class, h2.some-class, h3.some-class".
   --
   -- @since 5.8.0
   -- @since 6.1.0 Added append position.
   --
   -- @param string $selector  Original selector.
   -- @param string $to_append Selector to append.
   -- @param string $position  A position sub-selector should be appended.
   --                          Default "right".
   -- @return string The new selector.
   --
   -- protected static
   function Append_To_Selector (Selector  : String;
                                To_Append : String;
                                Position  : String := "right")
                                return String;

   --
   -- Returns the metadata for each block.
   --
   -- Example:
   --
   --     then
   --       "core/paragraph": then
   --         "selector": "p",
   --         "elements": then
   --           "link" => "link selector",
   --           "etc"  => "element selector"
   --         end;
   --       end;,
   --       "core/heading": then
   --         "selector": "h1",
   --         "elements": thenend;
   --       end;,
   --       "core/image": then
   --         "selector": ".wp-block-image",
   --         "duotone": "img",
   --         "elements": thenend;
   --       end;
   --     end;
   --
   -- @since 5.8.0
   -- @since 5.9.0 Added `duotone` key with CSS selector.
   -- @since 6.1.0 Added `features` key with block support feature level selectors.
   --
   -- @return array Block metadata.
   --
   -- protected static
   function Get_Blocks_Metadata
            return Array_Type;

   --
   -- Given a tree, removes the keys that are not present in the schema.
   --
   -- It is recursive and modifies the input in-place.
   --
   -- @since 5.8.0
   --
   -- @param array $tree   Input to process.
   -- @param array $schema Schema to adhere to.
   -- @return array The modified $tree.
   --
   -- protected static
   function Remove_Keys_Not_In_Schema (Tree   : Array_Type;
                                       Schema : Array_Type)
                                       return Array_Type;

   --
   -- Returns the existing settings for each block.
   --
   -- Example:
   --
   --     {
   --       "root": {
   --         "color": {
   --           "custom": true
   --         }
   --       },
   --       "core/paragraph": {
   --         "spacing": {
   --           "customPadding": true
   --         }
   --       }
   --     }
   --
   -- @since 5.8.0
   --
   -- @return array Settings per block.
   --
   function Get_Settings (This : Wp_Theme_JSON)
                          return Multi_Type;

   --
   -- Returns the stylesheet that results of processing
   -- the theme.json structure this object represents.
   --
   -- @since 5.8.0
   -- @since 5.9.0 Removed the `$type` parameter`, added the `$types` and `$origins`
   --              parameters.
   --
   -- @param array $types   Types of styles to load. Will load all by default. It
   --                       accepts:
   --                        - `variables`: only the CSS Custom Properties for presets
   --                         & custom ones.
   --                       - `styles`: only the styles section in theme.json.
   --                       - `presets`: only the classes for the presets.
   -- @param array $origins A list of origins to include. By default it includes
   --                       VALID_ORIGINS.
   -- @return string The resulting stylesheet.
   --

   Variables_Styles_Present : constant List_Type :=
     ["variables", "styles", "presets"];

   function Get_Stylesheet
              (This    : Wp_Theme_JSON;
               Types   : List_Type := Variables_Styles_Present;
               Origins : List_Type := Empty_List) -- null
               return String;

--         --
--         -- Returns the page templates of the active theme.
--         --
--         -- @since 5.9.0
--         --
--         -- @return array
--         --
--         public function get_custom_templates() then
--                 $custom_templates = array();
--                 if ( ! isset( $this->theme_json["customTemplates"] ) || ! is_array( $this->theme_json["customTemplates"] ) ) then
--                         return $custom_templates;
--                 end;

--                 foreach ( $this->theme_json["customTemplates"] as $item ) then
--                         if ( isset( $item["name"] ) ) then
--                                 $custom_templates[ $item["name"] ] = array(
--                                         "title"     => isset( $item["title"] ) ? $item["title"] : "",
--                                         "postTypes" => isset( $item["postTypes"] ) ? $item["postTypes"] : array( "page" ),
--                                 );
--                         end;
--                 end;
--                 return $custom_templates;
--         end;

--         --
--         -- Returns the template part data of active theme.
--         --
--         -- @since 5.9.0
--         --
--         -- @return array
--         --
--         public function get_template_parts() then
--                 $template_parts = array();
--                 if ( ! isset( $this->theme_json["templateParts"] ) || ! is_array( $this->theme_json["templateParts"] ) ) then
--                         return $template_parts;
--                 end;

--                 foreach ( $this->theme_json["templateParts"] as $item ) then
--                         if ( isset( $item["name"] ) ) then
--                                 $template_parts[ $item["name"] ] = array(
--                                         "title" => isset( $item["title"] ) ? $item["title"] : "",
--                                         "area"  => isset( $item["area"] ) ? $item["area"] : "",
--                                 );
--                         end;
--                 end;
--                 return $template_parts;
--         end;

   --
   -- Converts each style section into a list of rulesets
   -- containing the block styles to be appended to the stylesheet.
   --
   -- See glossary at https://developer.mozilla.org/en-US/docs/Web/CSS/Syntax
   --
   -- For each section this creates a new ruleset such as:
   --
   --   block-selector {
   --     style-property-one: value;
   --   }
   --
   -- @since 5.8.0 As `get_block_styles()`.
   -- @since 5.9.0 Renamed from `get_block_styles()` to `get_block_classes()`
   --              and no longer returns preset classes.
   --              Removed the `$setting_nodes` parameter.
   -- @since 6.1.0 Moved most internal logic to `get_styles_for_block()`.
   --
   -- @param array $style_nodes Nodes with styles.
   -- @return string The new stylesheet.
   --
   -- protected
   function Get_Block_Classes (This        : Wp_Theme_JSON;
                               Style_Nodes : Array_Lists.Array_List)
                               return String;

   --
   -- Gets the CSS layout rules for a particular block from theme.json layout
   -- definitions.
   --
   -- @since 6.1.0
   --
   -- @param array $block_metadata Metadata about the block to get styles for.
   -- @return string Layout styles for the block.
   --
   -- protected
   function Get_Layout_Styles (This           : Wp_Theme_JSON;
                               Block_Metadata : Array_Type)
                               return String;

   --
   -- Creates new rulesets as classes for each preset value such as:
   --
   --   .has-value-color {
   --     color: value;
   --   }
   --
   --   .has-value-background-color {
   --     background-color: value;
   --   }
   --
   --   .has-value-font-size {
   --     font-size: value;
   --   }
   --
   --   .has-value-gradient-background {
   --     background: value;
   --   }
   --
   --   p.has-value-gradient-background {
   --     background: value;
   --   }
   --
   -- @since 5.9.0
   --
   -- @param array $setting_nodes Nodes with settings.
   -- @param array $origins       List of origins to process presets from.
   -- @return string The new stylesheet.
   --
   -- protected
   function Get_Preset_Classes (This          : Wp_Theme_JSON;
                                Setting_Nodes : Array_Lists.Array_List;
                                Origins       : List_Type)
                                return String;

   --
   -- Converts each styles section into a list of rulesets
   -- to be appended to the stylesheet.
   -- These rulesets contain all the css variables (custom variables and preset
   -- variables).
   --
   -- See glossary at https://developer.mozilla.org/en-US/docs/Web/CSS/Syntax
   --
   -- For each section this creates a new ruleset such as:
   --
   --     block-selector {
   --       --wp--preset--category--slug: value;
   --       --wp--custom--variable: value;
   --     }
   --
   -- @since 5.8.0
   -- @since 5.9.0 Added the `$origins` parameter.
   --
   -- @param array $nodes   Nodes with settings.
   -- @param array $origins List of origins to process.
   -- @return string The new stylesheet.
   --
   -- protected
   function Get_CSS_Variables (This    : Wp_Theme_JSON;
                               Nodes   : Array_Lists.Array_List;
                               Origins : List_Type)
                               return String;

   --
   -- Given a selector and a declaration list,
   -- creates the corresponding ruleset.
   --
   -- @since 5.8.0
   --
   -- @param string $selector     CSS selector.
   -- @param array  $declarations List of declarations.
   -- @return string The resulting CSS ruleset.
   --
   -- protected static
   function To_Ruleset (Selector     : String;
                        Declarations : Array_Type)
                        return String;

   --
   -- Given a settings array, returns the generated rulesets
   -- for the preset classes.
   --
   -- @since 5.8.0
   -- @since 5.9.0 Added the `$origins` parameter.
   --
   -- @param array  $settings Settings to process.
   -- @param string $selector Selector wrapping the classes.
   -- @param array  $origins  List of origins to process.
   -- @return string The result of processing the presets.
   --
   -- protected static
   function Compute_Preset_Classes (Settings : Array_Type;
                                    Selector : String;
                                    Origins  : List_Type)
                                    return String;

   --
   -- Function that scopes a selector with another one. This works a bit like
   -- SCSS nesting except the `&` operator isn"t supported.
   --
   -- <code>
   -- $scope = ".a, .b .c";
   -- $selector = "> .x, .y";
   -- $merged = scope_selector( $scope, $selector );
   -- -- $merged is ".a > .x, .a .y, .b .c > .x, .b .c .y"
   -- </code>
   --
   -- @since 5.9.0
   --
   -- @param string $scope    Selector to scope to.
   -- @param string $selector Original selector.
   -- @return string Scoped selector.
   --
   -- protected static
   function Scope_Selector (Scope    : String;
                            Selector : String)
                            return String;

   --
   -- Gets preset values keyed by slugs based on settings and metadata.
   --
   -- <code>
   -- $settings = array(
   --     "typography" => array(
   --         "fontFamilies" => array(
   --             array(
   --                 "slug"       => "sansSerif",
   --                 "fontFamily" => ""Helvetica Neue", sans-serif",
   --             ),
   --             array(
   --                 "slug"   => "serif",
   --                 "colors" => "Georgia, serif",
   --             )
   --         ),
   --     ),
   -- );
   -- $meta = array(
   --    "path"      => array( "typography", "fontFamilies" ),
   --    "value_key" => "fontFamily",
   -- );
   -- $values_by_slug = get_settings_values_by_slug();
   -- -- $values_by_slug === array(
   -- --   "sans-serif" => ""Helvetica Neue", sans-serif",
   -- --   "serif"      => "Georgia, serif",
   -- -- );
   -- </code>
   --
   -- @since 5.9.0
   --
   -- @param array $settings        Settings to process.
   -- @param array $preset_metadata One of the PRESETS_METADATA values.
   -- @param array $origins         List of origins to process.
   -- @return array Array of presets where each key is a slug and each value is the
   --               preset value.
   --
   -- protected static
   function Get_Settings_Values_By_Slug (Settings        : Array_Type;
                                         Preset_Metadata : Array_Type;
                                         Origins         : List_Type)
                                         return Array_Type;

   --
   -- Similar to get_settings_values_by_slug, but doesn"t compute the value.
   --
   -- @since 5.9.0
   --
   -- @param array $settings        Settings to process.
   -- @param array $preset_metadata One of the PRESETS_METADATA values.
   -- @param array $origins         List of origins to process.
   -- @return array Array of presets where the key and value are both the slug.
   --
   -- protected static
   function Get_Settings_Slugs (Settings        : Array_Type;
                                Preset_Metadata : Array_Type;
                                Origins         : List_Type := Empty_List) -- null
                                return Array_Type;

   --
   -- Transforms a slug into a CSS Custom Property.
   --
   -- @since 5.9.0
   --
   -- @param string $input String to replace.
   -- @param string $slug  The slug value to use to generate the custom property.
   -- @return string The CSS Custom Property. Something along the lines of
   --                `--wp--preset--color--black`.
   --
   -- protected static
   function Replace_Slug_In_String (Input : String;
                                    Slug  : String)
                                    return String;

   --
   -- Given the block settings, extracts the CSS Custom Properties
   -- for the presets and adds them to the $declarations array
   -- following the format:
   --
   --     array(
   --       "name"  => "property_name",
   --       "value" => "property_value,
   --     )
   --
   -- @since 5.8.0
   -- @since 5.9.0 Added the `$origins` parameter.
   --
   -- @param array $settings Settings to process.
   -- @param array $origins  List of origins to process.
   -- @return array The modified $declarations.
   --
   -- protected static
   function Compute_Preset_Vars (Settings : Array_Type;
                                 Origins  : List_Type)
                                 return Array_Type;

   --
   -- Given an array of settings, extracts the CSS Custom Properties
   -- for the custom values and adds them to the $declarations
   -- array following the format:
   --
   --     array(
   --       "name"  => "property_name",
   --       "value" => "property_value,
   --     )
   --
   -- @since 5.8.0
   --
   -- @param array $settings Settings to process.
   -- @return array The modified $declarations.
   --
   -- protected static
   function Compute_Theme_Vars (Settings : Array_Type)
                                return Array_Type;

   --
   -- Given a tree, it creates a flattened one
   -- by merging the keys and binding the leaf values
   -- to the new keys.
   --
   -- It also transforms camelCase names into kebab-case
   -- and substitutes "/" by "-".
   --
   -- This is thought to be useful to generate
   -- CSS Custom Properties from a tree,
   -- although there"s nothing in the implementation
   -- of this function that requires that format.
   --
   -- For example, assuming the given prefix is "--wp"
   -- and the token is "--", for this input tree:
   --
   --     {
   --       "some/property": "value",
   --       "nestedProperty": {
   --         "sub-property": "value"
   --       }
   --     }
   --
   -- it"ll return this output:
   --
   --     {
   --       "--wp--some-property": "value",
   --       "--wp--nested-property--sub-property": "value"
   --     }
   --
   -- @since 5.8.0
   --
   -- @param array  $tree   Input tree to process.
   -- @param string $prefix Optional. Prefix to prepend to each variable. Default
   --                       empty string.
   -- @param string $token  Optional. Token to use between levels. Default "--".
   -- @return array The flattened tree.
   --
   -- protected static
   function Flatten_Tree (Tree   : Array_Type;
                          Prefix : String := "";
                          Token  : String := "--")
                          return Array_Type;

   --
   -- Given a styles array, it extracts the style properties
   -- and adds them to the $declarations array following the format:
   --
   --     array(
   --       "name"  => "property_name",
   --       "value" => "property_value,
   --     )
   --
   -- @since 5.8.0
   -- @since 5.9.0 Added the `$settings` and `$properties` parameters.
   -- @since 6.1.0 Added `$theme_json`, `$selector`, and `$use_root_padding` parameters.
   --
   -- @param array   $styles Styles to process.
   -- @param array   $settings Theme settings.
   -- @param array   $properties Properties metadata.
   -- @param array   $theme_json Theme JSON array.
   -- @param string  $selector The style block selector.
   -- @param boolean $use_root_padding Whether to add custom properties at root level.
   -- @return array  Returns the modified $declarations.
   --
   -- protected static
   function Compute_Style_Properties
              (Styles           : Array_Type;
               Settings         : Array_Type := Empty_Array;
               Properties       : Array_Type := Empty_Array; -- null
               Theme_JSON       : Array_Type := Empty_Array; -- null
               Selector         : String     := "";          -- null
               Use_Root_Padding : Boolean    := False)       -- null
               return Array_Type;

   --
   -- Returns the style property for the given path.
   --
   -- It also converts CSS Custom Property stored as
   -- "var:preset|color|secondary" to the form
   -- "--wp--preset--color--secondary".
   --
   -- It also converts references to a path to the value
   -- stored at that location, e.g.
   -- then "ref": "style.color.background" end; => "#fff".
   --
   -- @since 5.8.0
   -- @since 5.9.0 Added support for values of array type, which are returned as is.
   -- @since 6.1.0 Added the `$theme_json` parameter.
   --
   -- @param array $styles Styles subtree.
   -- @param array $path   Which property to process.
   -- @param array $theme_json Theme JSON array.
   -- @return string|array Style property value.
   --
   -- protected static
   function Get_Property_Value (Styles     : Array_Type;
                                Path       : List_Type;
                                Theme_JSON : Array_Type := Empty_Array) -- null
                                return Multi_Type;

   --
   -- Builds metadata for the setting nodes, which returns in the form of:
   --
   --     [
   --       [
   --         "path"     => ["path", "to", "some", "node" ],
   --         "selector" => "CSS selector for some node"
   --       ],
   --       [
   --         "path"     => [ "path", "to", "other", "node" ],
   --         "selector" => "CSS selector for other node"
   --       ],
   --     ]
   --
   -- @since 5.8.0
   --
   -- @param array $theme_json The tree to extract setting nodes from.
   -- @param array $selectors  List of selectors per block.
   -- @return array An array of setting nodes metadata.
   --
   -- protected static
   function Get_Setting_Nodes (Theme_JSON : Array_Type;
                               Selectors  : Array_Type := Empty_Array)
                               return Array_Lists.Array_List;

   --
   -- Builds metadata for the style nodes, which returns in the form of:
   --
   --     [
   --       [
   --         "path"     => [ "path", "to", "some", "node" ],
   --         "selector" => "CSS selector for some node",
   --         "duotone"  => "CSS selector for duotone for some node"
   --       ],
   --       [
   --         "path"     => ["path", "to", "other", "node" ],
   --         "selector" => "CSS selector for other node",
   --         "duotone"  => null
   --       ],
   --     ]
   --
   -- @since 5.8.0
   --
   -- @param array $theme_json The tree to extract style nodes from.
   -- @param array $selectors  List of selectors per block.
   -- @return array An array of style nodes metadata.
   --
   -- protected static
   function Get_Style_Nodes (Theme_JSON : Array_Type;
                             Selectors  : Array_Type := Empty_Array)
                             return Array_Lists.Array_List;

   --
   -- A public helper to get the block nodes from a theme.json file.
   --
   -- @since 6.1.0
   --
   -- @return array The block nodes in theme.json.
   --
   function Get_Styles_Block_Nodes (This : Wp_Theme_JSON)
                                    return Array_Lists.Array_List;

   --
   -- Returns a filtered declarations array if there is a separator block with only
   -- a background style defined in theme.json by adding a color attribute to reflect
   -- the changes in the front.
   --
   -- @since 6.1.1
   --
   -- @param array $declarations List of declarations.
   -- @return array $declarations List of declarations filtered.
   --
   -- private static
   function Update_Separator_Declarations (Declarations : Array_Type)
                                           return Array_Type;

   --
   -- An internal method to get the block nodes from a theme.json file.
   --
   -- @since 6.1.0
   --
   -- @param array $theme_json The theme.json converted to an array.
   -- @return array The block nodes in theme.json.
   --
   -- private static
   function Get_Block_Nodes (Theme_JSON : Array_Type)
                             return Array_Lists.Array_List;

   --
   -- Gets the CSS rules for a particular block from theme.json.
   --
   -- @since 6.1.0
   --
   -- @param array $block_metadata Metadata about the block to get styles for.
   --
   -- @return string Styles for the block.
   --
   function Get_Styles_For_Block (This           : Wp_Theme_JSON;
                                  Block_Metadata : Array_Type)
                                  return String;

   --
   -- Outputs the CSS for layout rules on the root.
   --
   -- @since 6.1.0
   --
   -- @param string $selector The root node selector.
   -- @param array  $block_metadata The metadata for the root block.
   -- @return string The additional root rules CSS.
   --
   function Get_Root_Layout_Rules (This           : Wp_Theme_JSON;
                                   Selector       : String;
                                   Block_Metadata : Array_Type)
                                   return String;

   --
   -- For metadata values that can either be booleans or paths to booleans, gets
   -- the value.
   --
   -- ```php
   -- $data = array(
   --   "color" => array(
   --     "defaultPalette" => true
   --   )
   -- );
   --
   -- static::get_metadata_boolean( $data, false );
   -- -- => false
   --
   -- static::get_metadata_boolean( $data, array( "color", "defaultPalette" ) );
   -- -- => true
   -- ```
   --
   -- @since 6.0.0
   --
   -- @param array      $data    The data to inspect.
   -- @param bool|array $path    Boolean or path to a boolean.
   -- @param bool       $default Default value if the referenced path is missing.
   --                            Default false.
   -- @return bool Value of boolean metadata.
   --
   -- protected static
   function Get_Metadata_Boolean (Data    : Array_Type;
                                  Path    : List_Type;
                                  Default : Boolean := False)
                                  return Boolean;

   --
   -- Merges new incoming data.
   --
   -- @since 5.8.0
   -- @since 5.9.0 Duotone preset also has origins.
   --
   -- @param WP_Theme_JSON $incoming Data to merge.
   --
   procedure Merge (This     : in out Wp_Theme_JSON;
                    Incoming : Wp_Theme_JSON);

--         --
--         -- Converts all filter (duotone) presets into SVGs.
--         --
--         -- @since 5.9.1
--         --
--         -- @param array $origins List of origins to process.
--         -- @return string SVG filters.
--         --
--         public function get_svg_filters( $origins ) then
--                 $blocks_metadata = static::get_blocks_metadata();
--                 $setting_nodes   = static::get_setting_nodes( $this->theme_json, $blocks_metadata );

--                 $filters = "";
--                 foreach ( $setting_nodes as $metadata ) then
--                         $node = _wp_array_get( $this->theme_json, $metadata["path"], array() );
--                         if ( empty( $node["color"]["duotone"] ) ) then
--                                 continue;
--                         end;

--                         $duotone_presets = $node["color"]["duotone"];

--                         foreach ( $origins as $origin ) then
--                                 if ( ! isset( $duotone_presets[ $origin ] ) ) then
--                                         continue;
--                                 end;
--                                 foreach ( $duotone_presets[ $origin ] as $duotone_preset ) then
--                                         $filters .= wp_get_duotone_filter_svg( $duotone_preset );
--                                 end;
--                         end;
--                 end;

--                 return $filters;
--         end;

--         --
--         -- Determines whether a presets should be overridden or not.
--         --
--         -- @since 5.9.0
--         -- @deprecated 6.0.0 Use then@see "get_metadata_boolean"end; instead.
--         --
--         -- @param array      $theme_json The theme.json like structure to inspect.
--         -- @param array      $path       Path to inspect.
--         -- @param bool|array $override   Data to compute whether to override the preset.
--         -- @return boolean
--         --
--         protected static function should_override_preset( $theme_json, $path, $override ) then
--                 _deprecated_function( __METHOD__, "6.0.0", "get_metadata_boolean" );

--                 if ( is_bool( $override ) ) then
--                         return $override;
--                 end;

--                 /*
--                 -- The relationship between whether to override the defaults
--                 -- and whether the defaults are enabled is inverse:
--                 --
--                 -- - If defaults are enabled  => theme presets should not be overridden
--                 -- - If defaults are disabled => theme presets should be overridden
--                 --
--                 -- For example, a theme sets defaultPalette to false,
--                 -- making the default palette hidden from the user.
--                 -- In that case, we want all the theme presets to be present,
--                 -- so they should override the defaults.
--                 --
--                 if ( is_array( $override ) ) then
--                         $value = _wp_array_get( $theme_json, array_merge( $path, $override ) );
--                         if ( isset( $value ) ) then
--                                 return ! $value;
--                         end;

--                         -- Search the top-level key if none was found for this node.
--                         $value = _wp_array_get( $theme_json, array_merge( array( "settings" ), $override ) );
--                         if ( isset( $value ) ) then
--                                 return ! $value;
--                         end;

--                         return true;
--                 end;
--         end;

   --
   -- Returns the default slugs for all the presets in an associative array
   -- whose keys are the preset paths and the leafs is the list of slugs.
   --
   -- For example:
   --
   --  array(
   --   "color" => array(
   --     "palette"   => array( "slug-1", "slug-2" ),
   --     "gradients" => array( "slug-3", "slug-4" ),
   --   ),
   -- )
   --
   -- @since 5.9.0
   --
   -- @param array $data      A theme.json like structure.
   -- @param array $node_path The path to inspect. It's "settings" by default.
   -- @return array
   --
   -- protected static
   function Get_Default_Slugs (Data      : Array_Type;
                               Node_Path : List_Type)
                               return Array_Type;

   --
   -- Gets a `default`"s preset name by a provided slug.
   --
   -- @since 5.9.0
   --
   -- @param string $slug The slug we want to find a match from default presets.
   -- @param array  $base_path The path to inspect. It's "settings" by default.
   -- @return string|null
   --
   -- protected
   function Get_Name_From_Defaults (This      : Wp_Theme_JSON;
                                    Slug      : String;
                                    Base_Path : List_Type)
                                    return String;

   --
   -- Removes the preset values whose slug is equal to any of given slugs.
   --
   -- @since 5.9.0
   --
   -- @param array $node  The node with the presets to validate.
   -- @param array $slugs The slugs that should not be overridden.
   -- @return array The new node.
   --
   -- protected static
   function Filter_Slugs (Node  : Array_Type;
                          Slugs : Array_Type)
                          return List_Type; -- Array_Type;

--         --
--         -- Removes insecure data from theme.json.
--         --
--         -- @since 5.9.0
--         --
--         -- @param array $theme_json Structure to sanitize.
--         -- @return array Sanitized structure.
--         --
--         public static function remove_insecure_properties( $theme_json ) then
--                 $sanitized = array();

--                 $theme_json = WP_Theme_JSON_Schema::migrate( $theme_json );

--                 $valid_block_names   = array_keys( static::get_blocks_metadata() );
--                 $valid_element_names = array_keys( static::ELEMENTS );

--                 $theme_json = static::sanitize( $theme_json, $valid_block_names, $valid_element_names );

--                 $blocks_metadata = static::get_blocks_metadata();
--                 $style_nodes     = static::get_style_nodes( $theme_json, $blocks_metadata );

--                 foreach ( $style_nodes as $metadata ) then
--                         $input = _wp_array_get( $theme_json, $metadata["path"], array() );
--                         if ( empty( $input ) ) then
--                                 continue;
--                         end;

--                         $output = static::remove_insecure_styles( $input );

--                         /*
--                         -- Get a reference to element name from path.
--                         -- $metadata["path"] = array( "styles", "elements", "link" );
--                         --
--                         $current_element = $metadata["path"][ count( $metadata["path"] ) - 1 ];

--                         /*
--                         -- $output is stripped of pseudo selectors. Re-add and process them
--                         -- or insecure styles here.
--                         --
--                         -- TODO: Replace array_key_exists() with isset() check once WordPress drops
--                         -- support for PHP 5.6. See https://core.trac.wordpress.org/ticket/57067.
--                         if ( array_key_exists( $current_element, static::VALID_ELEMENT_PSEUDO_SELECTORS ) ) then
--                                 foreach ( static::VALID_ELEMENT_PSEUDO_SELECTORS[ $current_element ] as $pseudo_selector ) then
--                                         if ( isset( $input[ $pseudo_selector ] ) ) then
--                                                 $output[ $pseudo_selector ] = static::remove_insecure_styles( $input[ $pseudo_selector ] );
--                                         end;
--                                 end;
--                         end;

--                         if ( ! empty( $output ) ) then
--                                 _wp_array_set( $sanitized, $metadata["path"], $output );
--                         end;
--                 end;

--                 $setting_nodes = static::get_setting_nodes( $theme_json );
--                 foreach ( $setting_nodes as $metadata ) then
--                         $input = _wp_array_get( $theme_json, $metadata["path"], array() );
--                         if ( empty( $input ) ) then
--                                 continue;
--                         end;

--                         $output = static::remove_insecure_settings( $input );
--                         if ( ! empty( $output ) ) then
--                                 _wp_array_set( $sanitized, $metadata["path"], $output );
--                         end;
--                 end;

--                 if ( empty( $sanitized["styles"] ) ) then
--                         unset( $theme_json["styles"] );
--                 end; else then
--                         $theme_json["styles"] = $sanitized["styles"];
--                 end;

--                 if ( empty( $sanitized["settings"] ) ) then
--                         unset( $theme_json["settings"] );
--                 end; else then
--                         $theme_json["settings"] = $sanitized["settings"];
--                 end;

--                 return $theme_json;
--         end;

--         --
--         -- Processes a setting node and returns the same node
--         -- without the insecure settings.
--         --
--         -- @since 5.9.0
--         --
--         -- @param array $input Node to process.
--         -- @return array
--         --
--         protected static function remove_insecure_settings( $input ) then
--                 $output = array();
--                 foreach ( static::PRESETS_METADATA as $preset_metadata ) then
--                         foreach ( static::VALID_ORIGINS as $origin ) then
--                                 $path_with_origin   = $preset_metadata["path"];
--                                 $path_with_origin[] = $origin;
--                                 $presets            = _wp_array_get( $input, $path_with_origin, null );
--                                 if ( null === $presets ) then
--                                         continue;
--                                 end;

--                                 $escaped_preset = array();
--                                 foreach ( $presets as $preset ) then
--                                         if (
--                                                 esc_attr( esc_html( $preset["name"] ) ) === $preset["name"] &&
--                                                 sanitize_html_class( $preset["slug"] ) === $preset["slug"]
--                                         ) then
--                                                 $value = null;
--                                                 if ( isset( $preset_metadata["value_key"], $preset[ $preset_metadata["value_key"] ] ) ) then
--                                                         $value = $preset[ $preset_metadata["value_key"] ];
--                                                 end; elseif (
--                                                         isset( $preset_metadata["value_func"] ) &&
--                                                         is_callable( $preset_metadata["value_func"] )
--                                                 ) then
--                                                         $value = call_user_func( $preset_metadata["value_func"], $preset );
--                                                 end;

--                                                 $preset_is_valid = true;
--                                                 foreach ( $preset_metadata["properties"] as $property ) then
--                                                         if ( ! static::is_safe_css_declaration( $property, $value ) ) then
--                                                                 $preset_is_valid = false;
--                                                                 break;
--                                                         end;
--                                                 end;

--                                                 if ( $preset_is_valid ) then
--                                                         $escaped_preset[] = $preset;
--                                                 end;
--                                         end;
--                                 end;

--                                 if ( ! empty( $escaped_preset ) ) then
--                                         _wp_array_set( $output, $path_with_origin, $escaped_preset );
--                                 end;
--                         end;
--                 end;
--                 return $output;
--         end;

--         --
--         -- Processes a style node and returns the same node
--         -- without the insecure styles.
--         --
--         -- @since 5.9.0
--         --
--         -- @param array $input Node to process.
--         -- @return array
--         --
--         protected static function remove_insecure_styles( $input ) then
--                 $output       = array();
--                 $declarations = static::compute_style_properties( $input );

--                 foreach ( $declarations as $declaration ) then
--                         if ( static::is_safe_css_declaration( $declaration["name"], $declaration["value"] ) ) then
--                                 $path = static::PROPERTIES_METADATA[ $declaration["name"] ];

--                                 -- Check the value isn"t an array before adding so as to not
--                                 -- double up shorthand and longhand styles.
--                                 $value = _wp_array_get( $input, $path, array() );
--                                 if ( ! is_array( $value ) ) then
--                                         _wp_array_set( $output, $path, $value );
--                                 end;
--                         end;
--                 end;
--                 return $output;
--         end;

   --
   -- Checks that a declaration provided by the user is safe.
   --
   -- @since 5.9.0
   --
   -- @param string $property_name  Property name in a CSS declaration, i.e. the `color` in
   --                               `color: red`.
   -- @param string $property_value Value in a CSS declaration, i.e. the `red` in `color: red`.
   -- @return bool
   --
   -- protected static
   function Is_Safe_CSS_Declaration (Property_Name  : String;
                                     Property_Value : String)
                                     return Boolean;

   --
   -- Returns the raw data.
   --
   -- @since 5.8.0
   --
   -- @return array Raw data.
   --
   function Get_Raw_Data (This : Wp_Theme_JSON)
                          return Array_Type;

   --
   -- Transforms the given editor settings according the
   -- add_theme_support format to the theme.json format.
   --
   -- @since 5.8.0
   --
   -- @param array $settings Existing editor settings.
   -- @return array Config that adheres to the theme.json schema.
   --
   -- public static
   function Get_From_Editor_Settings (Settings : Array_Type)
                                      return Array_Type;
--                 $theme_settings = array(
--                         "version"  => static::LATEST_SCHEMA,
--                         "settings" => array(),
--                 );

--                 -- Deprecated theme supports.
--                 if ( isset( $settings["disableCustomColors"] ) ) then
--                         if ( ! isset( $theme_settings["settings"]["color"] ) ) then
--                                 $theme_settings["settings"]["color"] = array();
--                         end;
--                         $theme_settings["settings"]["color"]["custom"] = ! $settings["disableCustomColors"];
--                 end;

--                 if ( isset( $settings["disableCustomGradients"] ) ) then
--                         if ( ! isset( $theme_settings["settings"]["color"] ) ) then
--                                 $theme_settings["settings"]["color"] = array();
--                         end;
--                         $theme_settings["settings"]["color"]["customGradient"] = ! $settings["disableCustomGradients"];
--                 end;

--                 if ( isset( $settings["disableCustomFontSizes"] ) ) then
--                         if ( ! isset( $theme_settings["settings"]["typography"] ) ) then
--                                 $theme_settings["settings"]["typography"] = array();
--                         end;
--                         $theme_settings["settings"]["typography"]["customFontSize"] = ! $settings["disableCustomFontSizes"];
--                 end;

--                 if ( isset( $settings["enableCustomLineHeight"] ) ) then
--                         if ( ! isset( $theme_settings["settings"]["typography"] ) ) then
--                                 $theme_settings["settings"]["typography"] = array();
--                         end;
--                         $theme_settings["settings"]["typography"]["lineHeight"] = $settings["enableCustomLineHeight"];
--                 end;

--                 if ( isset( $settings["enableCustomUnits"] ) ) then
--                         if ( ! isset( $theme_settings["settings"]["spacing"] ) ) then
--                                 $theme_settings["settings"]["spacing"] = array();
--                         end;
--                         $theme_settings["settings"]["spacing"]["units"] = ( true === $settings["enableCustomUnits"] ) ?
--                                 array( "px", "em", "rem", "vh", "vw", "%" ) :
--                                 $settings["enableCustomUnits"];
--                 end;

--                 if ( isset( $settings["colors"] ) ) then
--                         if ( ! isset( $theme_settings["settings"]["color"] ) ) then
--                                 $theme_settings["settings"]["color"] = array();
--                         end;
--                         $theme_settings["settings"]["color"]["palette"] = $settings["colors"];
--                 end;

--                 if ( isset( $settings["gradients"] ) ) then
--                         if ( ! isset( $theme_settings["settings"]["color"] ) ) then
--                                 $theme_settings["settings"]["color"] = array();
--                         end;
--                         $theme_settings["settings"]["color"]["gradients"] = $settings["gradients"];
--                 end;

--                 if ( isset( $settings["fontSizes"] ) ) then
--                         $font_sizes = $settings["fontSizes"];
--                         -- Back-compatibility for presets without units.
--                         foreach ( $font_sizes as $key => $font_size ) then
--                                 if ( is_numeric( $font_size["size"] ) ) then
--                                         $font_sizes[ $key ]["size"] = $font_size["size"] . "px";
--                                 end;
--                         end;
--                         if ( ! isset( $theme_settings["settings"]["typography"] ) ) then
--                                 $theme_settings["settings"]["typography"] = array();
--                         end;
--                         $theme_settings["settings"]["typography"]["fontSizes"] = $font_sizes;
--                 end;

--                 if ( isset( $settings["enableCustomSpacing"] ) ) then
--                         if ( ! isset( $theme_settings["settings"]["spacing"] ) ) then
--                                 $theme_settings["settings"]["spacing"] = array();
--                         end;
--                         $theme_settings["settings"]["spacing"]["padding"] = $settings["enableCustomSpacing"];
--                 end;

--                 return $theme_settings;
--         end;

--         --
--         -- Returns the current theme"s wanted patterns(slugs) to be
--         -- registered from Pattern Directory.
--         --
--         -- @since 6.0.0
--         --
--         -- @return string[]
--         --
--         public function get_patterns() then
--                 if ( isset( $this->theme_json["patterns"] ) && is_array( $this->theme_json["patterns"] ) ) then
--                         return $this->theme_json["patterns"];
--                 end;
--                 return array();
--         end;

--         --
--         -- Returns a valid theme.json as provided by a theme.
--         --
--         -- Unlike get_raw_data() this returns the presets flattened, as provided by a theme.
--         -- This also uses appearanceTools instead of their opt-ins if all of them are true.
--         --
--         -- @since 6.0.0
--         --
--         -- @return array
--         --
--         public function get_data() then
--                 $output = $this->theme_json;
--                 $nodes  = static::get_setting_nodes( $output );

--                 --
--                 -- Flatten the theme & custom origins into a single one.
--                 --
--                 -- For example, the following:
--                 --
--                 -- then
--                 --   "settings": then
--                 --     "color": then
--                 --       "palette": then
--                 --         "theme": [ thenend; ],
--                 --         "custom": [ thenend; ]
--                 --       end;
--                 --     end;
--                 --   end;
--                 -- end;
--                 --
--                 -- will be converted to:
--                 --
--                 -- then
--                 --   "settings": then
--                 --     "color": then
--                 --       "palette": [ thenend; ]
--                 --     end;
--                 --   end;
--                 -- end;
--                 --
--                 foreach ( $nodes as $node ) then
--                         foreach ( static::PRESETS_METADATA as $preset_metadata ) then
--                                 $path = $node["path"];
--                                 foreach ( $preset_metadata["path"] as $preset_metadata_path ) then
--                                         $path[] = $preset_metadata_path;
--                                 end;
--                                 $preset = _wp_array_get( $output, $path, null );
--                                 if ( null === $preset ) then
--                                         continue;
--                                 end;

--                                 $items = array();
--                                 if ( isset( $preset["theme"] ) ) then
--                                         foreach ( $preset["theme"] as $item ) then
--                                                 $slug = $item["slug"];
--                                                 unset( $item["slug"] );
--                                                 $items[ $slug ] = $item;
--                                         end;
--                                 end;
--                                 if ( isset( $preset["custom"] ) ) then
--                                         foreach ( $preset["custom"] as $item ) then
--                                                 $slug = $item["slug"];
--                                                 unset( $item["slug"] );
--                                                 $items[ $slug ] = $item;
--                                         end;
--                                 end;
--                                 $flattened_preset = array();
--                                 foreach ( $items as $slug => $value ) then
--                                         $flattened_preset[] = array_merge( array( "slug" => (string) $slug ), $value );
--                                 end;
--                                 _wp_array_set( $output, $path, $flattened_preset );
--                         end;
--                 end;

--                 -- If all of the static::APPEARANCE_TOOLS_OPT_INS are true,
--                 -- this code unsets them and sets "appearanceTools" instead.
--                 foreach ( $nodes as $node ) then
--                         $all_opt_ins_are_set = true;
--                         foreach ( static::APPEARANCE_TOOLS_OPT_INS as $opt_in_path ) then
--                                 $full_path = $node["path"];
--                                 foreach ( $opt_in_path as $opt_in_path_item ) then
--                                         $full_path[] = $opt_in_path_item;
--                                 end;
--                                 -- Use "unset prop" as a marker instead of "null" because
--                                 -- "null" can be a valid value for some props (e.g. blockGap).
--                                 $opt_in_value = _wp_array_get( $output, $full_path, "unset prop" );
--                                 if ( "unset prop" === $opt_in_value ) then
--                                         $all_opt_ins_are_set = false;
--                                         break;
--                                 end;
--                         end;

--                         if ( $all_opt_ins_are_set ) then
--                                 $node_path_with_appearance_tools   = $node["path"];
--                                 $node_path_with_appearance_tools[] = "appearanceTools";
--                                 _wp_array_set( $output, $node_path_with_appearance_tools, true );
--                                 foreach ( static::APPEARANCE_TOOLS_OPT_INS as $opt_in_path ) then
--                                         $full_path = $node["path"];
--                                         foreach ( $opt_in_path as $opt_in_path_item ) then
--                                                 $full_path[] = $opt_in_path_item;
--                                         end;
--                                         -- Use "unset prop" as a marker instead of "null" because
--                                         -- "null" can be a valid value for some props (e.g. blockGap).
--                                         $opt_in_value = _wp_array_get( $output, $full_path, "unset prop" );
--                                         if ( true !== $opt_in_value ) then
--                                                 continue;
--                                         end;

--                                         -- The following could be improved to be path independent.
--                                         -- At the moment it relies on a couple of assumptions:
--                                         //
--                                         -- - all opt-ins having a path of size 2.
--                                         -- - there"s two sources of settings: the top-level and the block-level.
--                                         if (
--                                                 ( 1 === count( $node["path"] ) ) &&
--                                                 ( "settings" === $node["path"][0] )
--                                         ) then
--                                                 -- Top-level settings.
--                                                 unset( $output["settings"][ $opt_in_path[0] ][ $opt_in_path[1] ] );
--                                                 if ( empty( $output["settings"][ $opt_in_path[0] ] ) ) then
--                                                         unset( $output["settings"][ $opt_in_path[0] ] );
--                                                 end;
--                                         end; elseif (
--                                                 ( 3 === count( $node["path"] ) ) &&
--                                                 ( "settings" === $node["path"][0] ) &&
--                                                 ( "blocks" === $node["path"][1] )
--                                         ) then
--                                                 -- Block-level settings.
--                                                 $block_name = $node["path"][2];
--                                                 unset( $output["settings"]["blocks"][ $block_name ][ $opt_in_path[0] ][ $opt_in_path[1] ] );
--                                                 if ( empty( $output["settings"]["blocks"][ $block_name ][ $opt_in_path[0] ] ) ) then
--                                                         unset( $output["settings"]["blocks"][ $block_name ][ $opt_in_path[0] ] );
--                                                 end;
--                                         end;
--                                 end;
--                         end;
--                 end;

--                 wp_recursive_ksort( $output );

--                 return $output;
--         end;

   --
   -- Sets the spacingSizes array based on the spacingScale values from theme.json.
   --
   -- @since 6.1.0
   --
   -- @return null|void
   --
   procedure Set_Spacing_Sizes (This : in out Wp_Theme_JSON);

   Null_Theme_JSON : constant Wp_Theme_JSON :=
     (others => Empty_Array);

end Class_Theme_JSON;
