--
-- WordPress Credits Administration API.
--
-- @package WordPress
-- @subpackage Administration
-- @since 4.4.0
--

with Arrays;
with UStrings;

package Adi_Credits
is
   use Arrays;

   subtype Credits_Type is Multi_Type
   with Dynamic_Predicate => Kind_Of (Credits_Type) in Kind_Null | Kind_Array;

   subtype Group_Data_Type is Array_Type
   with Dynamic_Predicate => True;

   --
   -- Retrieve the contributor credits.
   --
   -- @since 3.2.0
   -- @since 5.6.0 Added the `version` and `locale` parameters.
   --
   -- @param string version WordPress version. Defaults to the current version.
   -- @param string locale  WordPress locale. Defaults to the current user's locale.
   -- @return array|false A list of all of the contributors, or false on error.
   --
   function Wp_Credits (Version : String := "";
                        Locale  : String := "")
                        return Credits_Type;

   --
   -- Retrieve the link to a contributor's WordPress.org profile page.
   --
   -- @access private
   -- @since 3.2.0
   --
   -- @param string display_name  The contributor's display name (passed by reference).
   -- @param string username      The contributor's username.
   -- @param string profiles      URL to the contributor"s WordPress.org profile page.
   --
   procedure X_Wp_Credits_Add_Profile_Link
     (Display_Name : in out UStrings.UString;
      Username     : String;
      Profiles     : String);

   --
   -- Retrieve the link to an external library used in WordPress.
   --
   -- @access private
   -- @since 3.2.0
   --
   -- @param string data External library data (passed by reference).
   --
   function X_Wp_Credits_Build_Object_Link (Data : Multi_Type)
                                            return String;

   --
   -- Displays the title for a given group of contributors.
   --
   -- @since 5.3.0
   --
   -- @param array group_data The current contributor group.
   --
   procedure Wp_Credits_Section_Title (Group_Data : Group_Data_Type);

   --
   -- Displays a list of contributors for a given group.
   --
   -- @since 5.3.0
   --
   -- @param array  credits The credits groups returned from the API.
   -- @param string slug    The current group to display.
   --
   procedure Wp_Credits_Section_List (Credits : Group_Data_Type;
                                      Slug    : String := "");

end Adi_Credits;
