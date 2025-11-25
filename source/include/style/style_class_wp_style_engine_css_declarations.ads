--
-- WP_Style_Engine_CSS_Declarations
--
-- Holds, sanitizes and prints CSS rules declarations
--
-- @package WordPress
-- @subpackage StyleEngine
-- @since 6.1.0
--

with Arrays;

package Style_Class_Wp_Style_Engine_CSS_Declarations
is
   use Arrays;

   --
   -- Class WP_Style_Engine_CSS_Declarations.
   --
   -- Holds, sanitizes, processes and prints CSS declarations for the style engine.
   --
   -- @since 6.1.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Style_Engine_CSS_Declarations is tagged
      record
         --
         -- An array of CSS declarations (property => value pairs).
         --
         -- @since 6.1.0
         --
         -- @var array
         --
         -- protected
         Declarations : Array_Type;

      end record;

   --
   -- Constructor for this object.
   --
   -- If a `declarations` array is passed, it will be used to populate
   -- the initial declarations prop of the object by calling add_declarations().
   --
   -- @since 6.1.0
   --
   -- @param string[] declarations An associative array of CSS definitions, e.g.,
   --        array( "property" => "value", "property" => "value" ).
   --
   function X_Construct (Declarations : Array_Type)
                         return Wp_Style_Engine_CSS_Declarations;

   --
   -- Adds a single declaration.
   --
   -- @since 6.1.0
   --
   -- @param string property The CSS property.
   -- @param string value    The CSS value.
   --
   -- @return WP_Style_Engine_CSS_Declarations Returns the object to allow chaining
   --                                           methods.
   --
   function Add_Declaration (This     : in out Wp_Style_Engine_CSS_Declarations;
                             Property : String;
                             Value    : String)
                             return Wp_Style_Engine_CSS_Declarations;
   procedure Add_Declaration (This     : in out Wp_Style_Engine_CSS_Declarations;
                              Property : String;
                              Value    : String);

        -- --
        -- -- Removes a single declaration.
        -- --
        -- -- @since 6.1.0
        -- --
        -- -- @param string property The CSS property.
        -- --
        -- -- @return WP_Style_Engine_CSS_Declarations Returns the object to allow chaining methods.
        -- --
        -- public function remove_declaration( property ) then
        --         unset( this.declarations[ property ] );
        --         return this;
        -- end;

   --
   -- Adds multiple declarations.
   --
   -- @since 6.1.0
   --
   -- @param array declarations An array of declarations.
   --
   -- @return WP_Style_Engine_CSS_Declarations Returns the object to allow chaining
   --                                           methods.
   --
   function Add_Declarations (This         : in out Wp_Style_Engine_CSS_Declarations;
                              Declarations : Array_Type)
                              return Wp_Style_Engine_CSS_Declarations;
   procedure Add_Declarations (This         : in out Wp_Style_Engine_CSS_Declarations;
                               Declarations : Array_Type);

        -- --
        -- -- Removes multiple declarations.
        -- --
        -- -- @since 6.1.0
        -- --
        -- -- @param array properties An array of properties.
        -- --
        -- -- @return WP_Style_Engine_CSS_Declarations Returns the object to allow chaining methods.
        -- --
        -- public function remove_declarations( properties = array() ) then
        --         foreach ( properties as property ) then
        --                 this.remove_declaration( property );
        --         end;
        --         return this;
        -- end;

   --
   -- Gets the declarations array.
   --
   -- @since 6.1.0
   --
   -- @return array
   --
   function Get_Declarations (This : Wp_Style_Engine_CSS_Declarations)
                              return Array_Type;

   --
   -- Filters a CSS property + value pair.
   --
   -- @since 6.1.0
   --
   -- @param string property The CSS property.
   -- @param string value    The value to be filtered.
   -- @param string spacer   The spacer between the colon and the value. Defaults to
   --                         an empty string.
   --
   -- @return string The filtered declaration or an empty string.
   --
   -- protected static
   function Filter_Declaration (Property : String;
                                Value    : String;
                                Spacer   : String := "")
                                return String;

   --
   -- Filters and compiles the CSS declarations.
   --
   -- @since 6.1.0
   --
   -- @param bool   should_prettify Whether to add spacing, new lines and indents.
   -- @param number indent_count    The number of tab indents to apply to the rule.
   --                                Applies if `prettify` is `true`.
   --
   -- @return string The CSS declarations.
   --
   function Get_Declarations_String
              (This             : Wp_Style_Engine_CSS_Declarations;
               Should_Prettify : Boolean := False;
               Indent_Count    : Natural := 0)
               return String;

   --
   -- Sanitizes property names.
   --
   -- @since 6.1.0
   --
   -- @param string property The CSS property.
   --
   -- @return string The sanitized property name.
   --
   -- protected
   function Sanitize_Property (This     : Wp_Style_Engine_CSS_Declarations;
                               Property : String)
                               return String;

end Style_Class_Wp_Style_Engine_CSS_Declarations;
