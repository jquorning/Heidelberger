--
-- WP_Style_Engine_Processor
--
-- Compiles styles from stores or collection of CSS rules.
--
-- @package WordPress
-- @subpackage StyleEngine
-- @since 6.1.0
--

with Ada.Containers.Indefinite_Ordered_Maps;

with Arrays;

with Style_Class_Wp_Style_Engine_CSS_Rules;

package Style_Class_Wp_Style_Engine_Processors
is
   use Arrays;

   package Rules renames Style_Class_Wp_Style_Engine_CSS_Rules;

   package Rule_Maps is new
     Ada.Containers.Indefinite_Ordered_Maps
       (Key_Type     => String,
        Element_Type => Rules.Wp_Style_Engine_CSS_Rule,
        "="          => Rules."=");
   --
   -- Class WP_Style_Engine_Processor.
   --
   -- Compiles styles from stores or collection of CSS rules.
   --
   -- @since 6.1.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Style_Engine_Processor is tagged
      record
         --
         -- A collection of Style Engine Store objects.
         --
         -- @since 6.1.0
         -- @var WP_Style_Engine_CSS_Rules_Store[]
         --
--        protected
         Stores : Array_Type;

         --
         -- The set of CSS rules that this processor will work on.
         --
         -- @since 6.1.0
         -- @var WP_Style_Engine_CSS_Rule[]
         --
         -- protected
         CSS_Rules : Rule_Maps.Map; -- Style_Class_Wp_Style_Engine_CSS_Rules.Rule_Arrays.Vector; -- = array();
      end record;

        -- --
        -- -- Adds a store to the processor.
        -- --
        -- -- @since 6.1.0
        -- --
        -- -- @param WP_Style_Engine_CSS_Rules_Store store The store to add.
        -- --
        -- -- @return WP_Style_Engine_Processor Returns the object to allow chaining methods.
        -- --
        -- public function add_store( store ) then
        --         if ( ! store instanceof WP_Style_Engine_CSS_Rules_Store ) then
        --                 _doing_it_wrong(
        --                         __METHOD__,
        --                         __( "store must be an instance of WP_Style_Engine_CSS_Rules_Store" ),
        --                         "6.1.0"
        --                 );
        --                 return this;
        --         end;

        --         this.stores[ store.get_name() ] = store;

        --         return this;
        -- end;

   --
   -- Adds rules to be processed.
   --
   -- @since 6.1.0
   --
   -- @param WP_Style_Engine_CSS_Rule|WP_Style_Engine_CSS_Rule[] css_rules A single,
   --   or an array of, WP_Style_Engine_CSS_Rule objects from a store or otherwise.
   --
   -- @return WP_Style_Engine_Processor Returns the object to allow chaining methods.
   --
   function Add_Rules (This      : in out Wp_Style_Engine_Processor;
                       CSS_Rules : Style_Class_Wp_Style_Engine_CSS_Rules.Rule_Arrays.Vector) -- Wp_Style_Engine_CSS_Rule)
                       return Wp_Style_Engine_Processor;
   procedure Add_Rules (This      : in out Wp_Style_Engine_Processor;
                        CSS_Rules : Style_Class_Wp_Style_Engine_CSS_Rules.Rule_Arrays.Vector); -- Wp_Style_Engine_CSS_Rule);

        --         if ( ! is_array( css_rules ) ) then
        --                 css_rules = array( css_rules );
        --         end;

        --         foreach ( css_rules as rule ) then
        --                 selector = rule.get_selector();
        --                 if ( isset( this.css_rules[ selector ] ) ) then
        --                         this.css_rules[ selector ].add_declarations( rule.get_declarations() );
        --                         continue;
        --                 end;
        --                 this.css_rules[ rule.get_selector() ] = rule;
        --         end;

        --         return this;
        -- end;

   --
   -- Gets the CSS rules as a string.
   --
   -- @since 6.1.0
   --
   -- @param array options   {
   --     Optional. An array of options. Default empty array.
   --
   --     @type bool optimize Whether to optimize the CSS output, e.g., combine rules.
   --                          Default is `false`.
   --     @type bool prettify Whether to add new lines and indents to output. Default
   --                          is the test of whether the global constant
   --                          `SCRIPT_DEBUG` is defined.
   -- }
   --
   -- @return string The computed CSS.
   --
   function Get_CSS (This    : in out Wp_Style_Engine_Processor;
                     Options : Array_Type := Empty_Array)
                     return String;
        --         defaults = array(
        --                 "optimize" => true,
        --                 "prettify" => defined( "SCRIPT_DEBUG" ) && SCRIPT_DEBUG,
        --         );
        --         options  = wp_parse_args( options, defaults );

        --         // If we have stores, get the rules from them.
        --         foreach ( this.stores as store ) then
        --                 this.add_rules( store.get_all_rules() );
        --         end;

        --         // Combine CSS selectors that have identical declarations.
        --         if ( true === options["optimize"] ) then
        --                 this.combine_rules_selectors();
        --         end;

        --         // Build the CSS.
        --         css = "";
        --         foreach ( this.css_rules as rule ) then
        --                 css .= rule.get_css( options["prettify"] );
        --                 css .= options["prettify"] ? "\n" : "";
        --         end;
        --         return css;
        -- end;

   --
   -- Combines selectors from the rules store when they have the same styles.
   --
   -- @since 6.1.0
   --
   -- @return void
   --
   -- private
   procedure Combine_Rules_Selectors (This : in out Wp_Style_Engine_Processor);
        --         // Build an array of selectors along with the JSON-ified styles to make comparisons easier.
        --         selectors_json = array();
        --         foreach ( this.css_rules as rule ) then
        --                 declarations = rule.get_declarations().get_declarations();
        --                 ksort( declarations );
        --                 selectors_json[ rule.get_selector() ] = wp_json_encode( declarations );
        --         end;

        --         // Combine selectors that have the same styles.
        --         foreach ( selectors_json as selector => json ) then
        --                 // Get selectors that use the same styles.
        --                 duplicates = array_keys( selectors_json, json, true );
        --                 // Skip if there are no duplicates.
        --                 if ( 1 >= count( duplicates ) ) then
        --                         continue;
        --                 end;

        --                 declarations = this.css_rules[ selector ].get_declarations();

        --                 foreach ( duplicates as key ) then
        --                         // Unset the duplicates from the selectors_json array to avoid looping through them as well.
        --                         unset( selectors_json[ key ] );
        --                         // Remove the rules from the rules collection.
        --                         unset( this.css_rules[ key ] );
        --                 end;
        --                 // Create a new rule with the combined selectors.
        --                 duplicate_selectors                     = implode( ",", duplicates );
        --                 this.css_rules[ duplicate_selectors ] = new WP_Style_Engine_CSS_Rule( duplicate_selectors, declarations );
        --         end;
        -- end;

end Style_Class_Wp_Style_Engine_Processors;
