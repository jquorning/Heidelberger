--
-- Robots template functions.
--
-- @package WordPress
-- @subpackage Robots
-- @since 5.7.0
--

with Php.Echoing;
with Php.Strings;

with Lists;
with UStrings;
with Wp_Common;

with Inc_Formatting;
with Inc_Options;

package body Inc_Robots_Templates
is
   use Lists;

   ---------------
   -- Wp_Robots --
   ---------------

   procedure Wp_Robots
   is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;
      --
      -- Filters the directives to be included in the "robots" meta tag.
      --
      -- The meta tag will only be included as necessary.
      --
      -- @since 5.7.0
      --
      -- @param array robots Associative array of directives. Every key must be the
      --                     name of the directive, and the corresponding value must
      --                     either be a string to provide as value for the directive
      --                     or a boolean `true` if it is a boolean directive, i.e.
      --                     without a value.
      --
      Robots : constant Array_Type :=
        Apply_Filters ("wp_robots", Empty_Array);

      Robots_Strings : List_Type;
   begin
      for A in Robots.Iterate loop
         declare
            Directive : constant String     := Key (A);
            Value     : constant Multi_Type := Element (A);
         begin
            if Kind_Of (Value) = Kind_String then
               -- If a string value, include it as value for the directive.
               Robots_Strings.Append (Directive & ":" & As_String (Value));
            else
            -- elsif ( value ) then
               -- Otherwise, include the directive if it is truthy.
               Robots_Strings.Append (Directive);
            end if;
         end;
      end loop;

      if Robots_Strings.Is_Empty then
         return;
      end if;

      Echo ("<meta name=""robots"" content=""" &
            ESC_Attr (Implode (", ", Robots_Strings)) & """ />" & NL);
   end Wp_Robots;

   ------------------------------
   -- Wp_Robots_Sensitive_Page --
   ------------------------------

   function Wp_Robots_Sensitive_Page (Robots : Array_Type)
                                      return Array_Type
   is
      Robots_2 : Array_Type := Robots;
   begin
      Set (Robots_2, "noindex", From_Boolean (True));
      Set (Robots_2, "noarchive", From_Boolean (True));
      return Robots_2;
   end Wp_Robots_Sensitive_Page;

   ------------------------------
   -- Wp_Robots_Sensitive_Page --
   ------------------------------

   procedure Wp_Robots_Sensitive_Page
   is
      Unused : constant Array_Type :=
        Wp_Robots_Sensitive_Page (Empty_Array);
   begin
      null;
   end Wp_Robots_Sensitive_Page;

   ---------------------------------------
   -- Wp_Robots_Max_Image_Preview_Large --
   ---------------------------------------

   function Wp_Robots_Max_Image_Preview_Large (Robots : Array_Type)
                                               return Array_Type
   is
      use Inc_Options;

      Robots_2 : Array_Type := Robots;
   begin
      if Get_Option ("blog_public") then
         Set (Robots_2, "max-image-preview", From_String ("large"));
      end if;
      return Robots_2;
   end Wp_Robots_Max_Image_Preview_Large;

   ---------------------------------------
   -- Wp_Robots_Max_Image_Preview_Large --
   ---------------------------------------

   procedure Wp_Robots_Max_Image_Preview_Large
   is
      Unused : constant Array_Type :=
        Wp_Robots_Max_Image_Preview_Large (Empty_Array);
   begin
      null;
   end Wp_Robots_Max_Image_Preview_Large;

end Inc_Robots_Templates;
