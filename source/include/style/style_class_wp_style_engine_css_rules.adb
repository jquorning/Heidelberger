--
-- WP_Style_Engine_CSS_Rule
--
-- An object for CSS rules.
--
-- @package WordPress
-- @subpackage StyleEngine
-- @since 6.1.0
--

with UStrings;
with Php.Strings;

package body Style_Class_Wp_Style_Engine_CSS_Rules
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Selector     : String := "";
                         Declarations : Array_Type)
                         return Wp_Style_Engine_CSS_Rule
   is
      This : Wp_Style_Engine_CSS_Rule;
   begin
      This.Set_Selector (Selector);
      This.Add_Declarations (Declarations);
      return This;
   end X_Construct;

   ------------------
   -- Set_Selector --
   ------------------

   procedure Set_Selector (This     : in out Wp_Style_Engine_CSS_Rule;
                           Selector : String)
   is
      use UStrings;
   begin
      This.Selector := +Selector;
--    return This;
   end Set_Selector;

   ----------------------
   -- Add_Declarations --
   ----------------------

   function Add_Declarations (This         : in out Wp_Style_Engine_CSS_Rule;
                              Declarations : Array_Type) -- Decls.Wp_Style_Engine_CSS_Declarations)
                              return Wp_Style_Engine_CSS_Rule
   is
      Is_Declarations_Object : constant Boolean := True; -- ! is_array( declarations );
--    Declarations_Array     := is_declarations_object ? declarations.get_declarations() : declarations;
      Declarations_Array     : constant Array_Type := Declarations; -- Declarations.Get_Declarations;
   begin
--      if Empty_Array = This.Declarations then
--    if null = This.Declarations then
         -- if Is_Declarations_Object then
         --    This.Declarations := Declarations;
         --    return This;
         -- end if;
         This.Declarations :=
           Style_Class_Wp_Style_Engine_CSS_Declarations.X_Construct
             (Declarations_Array);
--       This.Declarations := new Wp_Style_Engine_CSS_Declarations (Declarations_Array);
--      end if;
      This.Declarations.Add_Declarations (Declarations_Array);

      return This;
   end Add_Declarations;

   ----------------------
   -- Add_Declarations --
   ----------------------

   procedure Add_Declarations (This         : in out Wp_Style_Engine_CSS_Rule;
                               Declarations : Decls.Wp_Style_Engine_CSS_Declarations)
   is
      Unused : Wp_Style_Engine_CSS_Rule;
   begin
      Unused := Add_Declarations (This, Declarations.Get_Declarations);
   end Add_Declarations;

   ----------------------
   -- Add_Declarations --
   ----------------------

   procedure Add_Declarations (This         : in out Wp_Style_Engine_CSS_Rule;
                               Declarations : Array_Type)
   is
      Unused : Wp_Style_Engine_CSS_Rule;
   begin
      Unused := Add_Declarations (This, Declarations);
   end Add_Declarations;

   ----------------------
   -- Get_Declarations --
   ----------------------

   function Get_Declarations (This : Wp_Style_Engine_CSS_Rule)
                              return Decls.Wp_Style_Engine_CSS_Declarations
   is
   begin
      return This.Declarations;
   end Get_Declarations;

   ------------------
   -- Get_Selector --
   ------------------

   function Get_Selector (This : Wp_Style_Engine_CSS_Rule)
                          return String
   is
      use UStrings;
   begin
      return -This.Selector;
   end Get_Selector;

   -------------
   -- Get_CSS --
   -------------

   function Get_CSS (This            : Wp_Style_Engine_CSS_Rule;
                     Should_Prettify : Boolean := False;
                     Indent_Count    : Natural := 0)
                     return String
   is
      use UStrings;
      use Php;
      use Php.Strings;

      Rule_Indent : constant String :=
        (if Should_Prettify then Str_Repeat ("\t", Indent_Count) else "");

      Declarations_Indent : constant Natural :=
        (if Should_Prettify then Indent_Count + 1 else 0);

      Suffix : constant String :=
        (if Should_Prettify then "\n" else "");

      Spacer : constant String :=
        (if Should_Prettify then " " else "");

      Selector : constant String :=
        (if Should_Prettify
         then Str_Replace (",", ",\n", This.Get_Selector)
         else This.Get_Selector);

      CSS_Declarations : constant String :=
        This.Declarations.Get_Declarations_String
          (Should_Prettify, Declarations_Indent);
   begin
      if Empty (CSS_Declarations) then
         return "";
      end if;

      return Rule_Indent & Selector & Spacer &
        "{" & Suffix & CSS_Declarations & Suffix & Rule_Indent & "}";
   end Get_CSS;

end Style_Class_Wp_Style_Engine_CSS_Rules;
