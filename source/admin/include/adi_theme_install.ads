--
-- WordPress Theme Installation Administration API
--
-- @package WordPress
-- @subpackage Administration
--

with Arrays;
with Array_Lists;

package Adi_Theme_Install
is
   use Arrays;

   Themes_Allowedtags : Array_Type :=
     Array_Lists.To_Array_Type
       ([Build
           ("a",
            Array_Lists.To_Array_Type
              ([Build ("href", Empty_Array),
                Build ("title", Empty_Array),
                Build ("target", Empty_Array)])),
         Build
           ("abbr",
            Array_Lists.To_Array_Type ([Build ("title", Empty_Array)])),
         Build
           ("acronym",
            Array_Lists.To_Array_Type ([Build ("title", Empty_Array)])),
         Build ("code", Empty_Array),
         Build ("pre", Empty_Array),
         Build ("em", Empty_Array),
         Build ("strong", Empty_Array),
         Build ("div", Empty_Array),
         Build ("p", Empty_Array),
         Build ("ul", Empty_Array),
         Build ("ol", Empty_Array),
         Build ("li", Empty_Array),
         Build ("h1", Empty_Array),
         Build ("h2", Empty_Array),
         Build ("h3", Empty_Array),
         Build ("h4", Empty_Array),
         Build ("h5", Empty_Array),
         Build ("h6", Empty_Array),
         Build
           ("img",
            Array_Lists.To_Array_Type
              ([Build ("src", Empty_Array),
                Build ("class", Empty_Array),
                Build ("alt", Empty_Array)]))]);

   Theme_Field_Defaults : Array_Type :=
     Array_Lists.To_Array_Type
       ([Build ("description", True),
         Build ("sections", False),
         Build ("tested", True),
         Build ("requires", True),
         Build ("rating", True),
         Build ("downloaded", True),
         Build ("downloadlink", True),
         Build ("last_updated", True),
         Build ("homepage", True),
         Build ("tags", True),
         Build ("num_ratings", True)]);

   --
   -- Retrieves the list of WordPress theme features (aka theme tags).
   --
   -- @since 2.8.0
   --
   -- @deprecated 3.1.0 Use get_theme_feature_list() instead.
   --
   -- @return array
   --
   -- function Install_Themes_Feature_List return Array_Type;

   --
   -- Displays search form for searching themes.
   --
   -- @since 2.8.0
   --
   -- @param bool type_selector
   --
   procedure Install_Theme_Search_Form (Type_Selector : Boolean := True);

   --
   -- Displays tags filter for themes.
   --
   -- @since 2.8.0
   --
   procedure Install_Themes_Dashboard;

   --
   -- Displays a form to upload themes from zip files.
   --
   -- @since 2.8.0
   --
   procedure Install_Themes_Upload;

   --
   -- Prints a theme on the Install Themes pages.
   --
   -- @deprecated 3.4.0
   --
   -- @global WP_Theme_Install_List_Table wp_list_table
   --
   -- @param object theme
   --
   subtype Object is Array_Type;
   procedure Display_Theme (Theme : Object);

   --
   -- Displays theme content based on theme list.
   --
   -- @since 2.8.0
   --
   -- @global WP_Theme_Install_List_Table wp_list_table
   --
   procedure Display_Themes;

   --
   -- Displays theme information in dialog box form.
   --
   -- @since 2.8.0
   --
   -- @global WP_Theme_Install_List_Table wp_list_table
   --
   procedure Install_Theme_Information;

end Adi_Theme_Install;
