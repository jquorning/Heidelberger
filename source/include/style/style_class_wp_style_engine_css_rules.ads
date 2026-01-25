--
-- WP_Style_Engine_CSS_Rule
--
-- An object for CSS rules.
--
-- @package WordPress
-- @subpackage StyleEngine
-- @since 6.1.0
--

with Ada.Containers.Vectors;

with Arrays;
with UStrings;

with Style_Class_Wp_Style_Engine_CSS_Declarations;

package Style_Class_Wp_Style_Engine_CSS_Rules
is
   use Arrays;

   package Decls renames Style_Class_Wp_Style_Engine_CSS_Declarations;

   --
   -- Class WP_Style_Engine_CSS_Rule.
   --
   -- Holds, sanitizes, processes and prints CSS declarations for the style engine.
   --
   -- @since 6.1.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Style_Engine_CSS_Rule is tagged
      record
         --
         -- The selector.
         --
         -- @since 6.1.0
         -- @var string
         --
         -- protected
         Selector : UStrings.UString;

         --
         -- The selector declarations.
         --
         -- Contains a WP_Style_Engine_CSS_Declarations object.
         --
         -- @since 6.1.0
         -- @var WP_Style_Engine_CSS_Declarations
         --
         -- protected
         Declarations : Decls.Wp_Style_Engine_CSS_Declarations;

      end record;

   --
   -- Constructor
   --
   -- @since 6.1.0
   --
   -- @param string                                    selector     The CSS selector.
   -- @param string[]|WP_Style_Engine_CSS_Declarations declarations An associative
   --   array of CSS definitions, e.g., array( "property" => "value",
   --                                          "property" => "value" ),
   --   or a WP_Style_Engine_CSS_Declarations object.
   --
   function X_Construct (Selector     : String := "";
                         Declarations : Array_Type)
                         return Wp_Style_Engine_CSS_Rule;

   --
   -- Sets the selector.
   --
   -- @since 6.1.0
   --
   -- @param string selector The CSS selector.
   --
   -- @return WP_Style_Engine_CSS_Rule Returns the object to allow chaining of methods.
   --
   procedure Set_Selector (This     : in out Wp_Style_Engine_CSS_Rule;
                           Selector : String);

   --
   -- Sets the declarations.
   --
   -- @since 6.1.0
   --
   -- @param array|WP_Style_Engine_CSS_Declarations declarations An array of
   --        declarations (property => value pairs), or a
   --        WP_Style_Engine_CSS_Declarations object.
   --
   -- @return WP_Style_Engine_CSS_Rule Returns the object to allow chaining of methods.
   --
   function Add_Declarations (This         : in out Wp_Style_Engine_CSS_Rule;
                              Declarations : Array_Type) -- Decls.Wp_Style_Engine_CSS_Declarations)
                              return Wp_Style_Engine_CSS_Rule;
   procedure Add_Declarations (This         : in out Wp_Style_Engine_CSS_Rule;
                               Declarations : Decls.Wp_Style_Engine_CSS_Declarations);
   procedure Add_Declarations (This         : in out Wp_Style_Engine_CSS_Rule;
                               Declarations : Array_Type);

   --
   -- Gets the declarations object.
   --
   -- @since 6.1.0
   --
   -- @return WP_Style_Engine_CSS_Declarations The declarations object.
   --
   function Get_Declarations (This : Wp_Style_Engine_CSS_Rule)
                              return Decls.Wp_Style_Engine_CSS_Declarations;

   --
   -- Gets the full selector.
   --
   -- @since 6.1.0
   --
   -- @return string
   --
   function Get_Selector (This : Wp_Style_Engine_CSS_Rule)
                          return String;

   --
   -- Gets the CSS.
   --
   -- @since 6.1.0
   --
   -- @param bool   should_prettify Whether to add spacing, new lines and indents.
   -- @param number indent_count    The number of tab indents to apply to the rule.
   --                                Applies if `prettify` is `true`.
   --
   -- @return string
   --
   function Get_CSS (This            : Wp_Style_Engine_CSS_Rule;
                     Should_Prettify : Boolean := False;
                     Indent_Count    : Natural := 0)
                     return String;
        --         rule_indent         = should_prettify ? str_repeat( "\t", indent_count ) : '';
        --         declarations_indent = should_prettify ? indent_count + 1 : 0;
        --         suffix              = should_prettify ? "\n" : '';
        --         spacer              = should_prettify ? ' ' : '';
        --         selector            = should_prettify ? str_replace( ',', ",\n", this.get_selector() ) : this.get_selector();
        --         css_declarations    = this.declarations.get_declarations_string( should_prettify, declarations_indent );

        --         if ( empty( css_declarations ) ) then
        --                 return '';
        --         end;

        --         return "thenrule_indentend;thenselectorend;thenspacerend;thenthensuffixend;thencss_declarationsend;thensuffixend;thenrule_indentend;end;";
        -- end;

   package Rule_Arrays is new
      Ada.Containers.Vectors (Index_Type   => Positive,
                              Element_Type => Wp_Style_Engine_CSS_Rule);

end Style_Class_Wp_Style_Engine_CSS_Rules;
