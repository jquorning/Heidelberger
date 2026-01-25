--
-- WP_Style_Engine_CSS_Declarations
--
-- Holds, sanitizes and prints CSS rules declarations
--
-- @package WordPress
-- @subpackage StyleEngine
-- @since 6.1.0
--

with UStrings;
with Php.Strings;

with Inc_Formatting;
with Inc_KSES;

package body Style_Class_Wp_Style_Engine_CSS_Declarations
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Declarations : Array_Type)
                         return Wp_Style_Engine_CSS_Declarations
   is
      This : Wp_Style_Engine_CSS_Declarations;
   begin
      This.Add_Declarations (Declarations);
      return This;
   end X_Construct;

   ---------------------
   -- Add_Declaration --
   ---------------------

   function Add_Declaration (This     : in out Wp_Style_Engine_CSS_Declarations;
                             Property : String;
                             Value    : String)
                             return Wp_Style_Engine_CSS_Declarations
   is
      use UStrings;
      use Php;
      use Php.Strings;

      -- Sanitizes the property.
      Property_2 : String := This.Sanitize_Property (Property);
   begin
      -- Bails early if the property is empty.
      if Empty (Property) then
         return This;
      end if;

      -- Trims the value. If empty, bail early.
      declare
         Value_2 : String := Trim (Value);
      begin
         if "" = Value then
            return This;
         end if;

         -- Adds the declaration property/value pair.
         This.Declarations.Append (Key   => Property,
                                   Value => From_String (Value));
      end;

      return This;
   end Add_Declaration;

   ---------------------
   -- Add_Declaration --
   ---------------------

   procedure Add_Declaration (This     : in out Wp_Style_Engine_CSS_Declarations;
                              Property : String;
                              Value    : String)
   is
      Unused : Wp_Style_Engine_CSS_Declarations;
   begin
      Unused := Add_Declaration (This, Property, Value);
   end Add_Declaration;

   ----------------------
   -- Add_Declarations --
   ----------------------

   function Add_Declarations (This         : in out Wp_Style_Engine_CSS_Declarations;
                              Declarations : Array_Type)
                              return Wp_Style_Engine_CSS_Declarations
   is
   begin
      for A in Declarations.Iterate loop
         declare
            Property : constant String := Key (A);
            Value    : constant String := As_String (Element (A));
         begin
            This.Add_Declaration (Property, Value);
         end;
      end loop;
      return This;
   end Add_Declarations;

   ----------------------
   -- Add_Declarations --
   ----------------------

   procedure Add_Declarations (This         : in out Wp_Style_Engine_CSS_Declarations;
                               Declarations : Array_Type)
   is
      Unused : Wp_Style_Engine_CSS_Declarations;
   begin
      Unused := Add_Declarations (This, Declarations);
   end Add_Declarations;

   ----------------------
   -- Get_Declarations --
   ----------------------

   function Get_Declarations (This : Wp_Style_Engine_CSS_Declarations)
                              return Array_Type
   is
   begin
      return This.Declarations;
   end Get_Declarations;

   ------------------------
   -- Filter_Declaration --
   ------------------------

   function Filter_Declaration (Property : String;
                                Value    : String;
                                Spacer   : String := "")
                                return String
   is
      use Inc_Formatting;
      use Inc_KSES;

      Filtered_Value : constant String := Wp_Strip_All_Tags (Value, True);
   begin
      if "" /= Filtered_Value then
         return SafeCSS_Filter_Attr (Property & ":" & Spacer & Filtered_Value);
      end if;
      return "";
   end Filter_Declaration;

   -----------------------------
   -- Get_Declarations_String --
   -----------------------------

   function Get_Declarations_String
              (This             : Wp_Style_Engine_CSS_Declarations;
               Should_Prettify : Boolean := False;
               Indent_Count    : Natural := 0)
               return String
   is
      use UStrings;
      use Php.Strings;

      Declarations_Array  : constant Array_Type := This.Get_Declarations;
      Declarations_Output : UString;

      Indent : constant String :=
        (if Should_Prettify then Str_Repeat ("\t", Indent_Count) else "");

      Suffix_2 : constant String := (if Should_Prettify then " " else "");

      Suffix : constant String :=
        (if Should_Prettify and Indent_Count > 0 then "\n" else Suffix_2);

      Spacer : constant String := (if Should_Prettify then " " else "");
   begin
      for A in Declarations_Array.Iterate loop
         declare
            Property : constant String := Key (A);
            Value    : constant String := As_String (Element (A));

            Filtered_Declaration : constant String :=
              Filter_Declaration (Property, Value, Spacer); -- static::
         begin
            if Filtered_Declaration /= "" then
               Append (Declarations_Output,
                       Indent & Filtered_Declaration & ";" & Suffix);
            end if;
         end;
      end loop;
      return Rtrim (-Declarations_Output);
   end Get_Declarations_String;

   -----------------------
   -- Sanitize_Property --
   -----------------------

   function Sanitize_Property (This     : Wp_Style_Engine_CSS_Declarations;
                               Property : String)
                               return String
   is
      use Inc_Formatting;
   begin
      return Sanitize_Key (Property);
   end Sanitize_Property;

end Style_Class_Wp_Style_Engine_CSS_Declarations;
