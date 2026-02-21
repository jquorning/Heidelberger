--
-- Loads the correct template based on the visitor"s url
--
-- @package WordPress
--

with Php.Errors;

with Arrays;
with Binder;
with Logging;
with Wp_Common;
with UStrings;

with Class_Errors;
with Class_Themes;

with Inc_Capabilities;
with Inc_Functions;
with Inc_Load;
with Inc_Templates;
with Inc_Plugins;
with Inc_Themes;
with Inc_Querys;

with Wp_Trackback;

package body Inc_Template_Loader
is
   use Arrays;

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Php.Errors;
      use Binder;
      use Wp_Common;
      use UStrings;
      use Class_Errors;
      use Class_Themes;
      use Inc_Capabilities;
      use Inc_Functions;
      use Inc_Load;
      use Inc_Plugins;
      use Inc_Templates;
      use Inc_Themes;
      use Inc_Querys;
   begin
      if Wp_Using_Themes then
         --
         -- Fires before determining which template to load.
         --
         -- @since 1.5.0
         --
         Do_Action ("template_redirect");
      end if;

      --
      -- Filters whether to allow "HEAD" requests to generate content.
      --
      -- Provides a significant performance bump by exiting before the page
      -- content loads for "HEAD" requests. See #14348.
      --
      -- @since 3.5.0
      --
      -- @param bool exit Whether to exit without generating any content for "HEAD"
      -- requests. Default true.
      --
      if
        "HEAD" = Get_As_String (X_SERVER, "REQUEST_METHOD") and then
        Apply_Filters ("exit_on_http_head", True)
      then
         Die; -- exit;
      end if;

      -- Process feeds and trackbacks even if not using themes.
      if Is_Robots then
         --
         -- Fired when the template loader determines a robots.txt request.
         --
         -- @since 2.1.0
         --
         Do_Action ("do_robots");
         return;

      elsif Is_Favicon then
         --
         -- Fired when the template loader determines a favicon.ico request.
         --
         -- @since 5.4.0
         --
         Do_Action ("do_favicon");
         return;

      elsif Is_Feed then
         Do_Feed;
         return;

      elsif Is_Trackback then
         Wp_Trackback.Render;
         return;
      end if;

      if Wp_Using_Themes then
         declare
            type Tag_Function      is not null access function return Boolean;
            type Template_Function is not null access function return String;

            type Tag_Record is record
               Tag      : Tag_Function;
               Template : Template_Function;
            end record;

            Tag_Templates : constant array (Positive range <>) of Tag_Record :=
              (
                (Is_Embed'Access,             Get_Embed_Template'Access),
                (Is_404'Access,               Get_404_Template'Access),
                (Is_Search'Access,            Get_Search_Template'Access),
                (Is_Front_Page'Access,        Get_Front_Page_Template'Access),
                (Is_Home'Access,              Get_Home_Template'Access),
                (Is_Privacy_Policy'Access,    Get_Privacy_Policy_Template'Access),
                (Is_Post_Type_Archive'Access, Get_Post_Type_Archive_Template'Access),
                (Is_Tax'Access,               Get_Taxonomy_Template'Access),
                (Is_Attachment'Access,        Get_Attachment_Template'Access),
                (Is_Single'Access,            Get_Single_Template'Access),
                (Is_Page'Access,              Get_Page_Template'Access),
                (Is_Singular'Access,          Get_Singular_Template'Access),
                (Is_Category'Access,          Get_Category_Template'Access),
                (Is_Tag'Access,               Get_Tag_Template'Access),
                (Is_Author'Access,            Get_Author_Template'Access),
                (Is_Date'Access,              Get_Date_Template'Access),
                (Is_Archive'Access,           Get_Archive_Template'Access)
              );

            -- Tag_Templates : Array_Type := To_Array_Type ([
            --     Build ("is_embed",             "get_embed_template"),
            --     Build ("is_404",               "get_404_template"),
            --     Build ("is_search",            "get_search_template"),
            --     Build ("is_front_page",        "get_front_page_template"),
            --     Build ("is_home",              "get_home_template"),
            --     Build ("is_privacy_policy",    "get_privacy_policy_template"),
            --     Build ("is_post_type_archive", "get_post_type_archive_template"),
            --     Build ("is_tax",               "get_taxonomy_template"),
            --     Build ("is_attachment",        "get_attachment_template"),
            --     Build ("is_single",            "get_single_template"),
            --     Build ("is_page",              "get_page_template"),
            --     Build ("is_singular",          "get_singular_template"),
            --     Build ("is_category",          "get_category_template"),
            --     Build ("is_tag",               "get_tag_template"),
            --     Build ("is_author",            "get_author_template"),
            --     Build ("is_date",              "get_date_template"),
            --     Build ("is_archive",           "get_archive_template")
            -- ]);

            Template : UString; -- Boolean := False;
         begin
            -- Loop through each of the template conditionals, and find the
            -- appropriate template file.
            for A of Tag_Templates loop
--          for A in Tag_Templates.Iterate loop
               declare
--                Tag : String := Key (A);
--                Template_Getter : Multi_Type := Element (A);
               begin
                  if A.Tag.all then
--                if Call_User_Func (Tag) then
                     Template := +A.Template.all;

--                   Template := Call_User_Func (Template_Getter);
                  end if;

                  if Template /= "" then
                     if Is_Attachment'Access = A.Tag then
--                   if "is_attachment" = Tag then
                        Remove_Filter ("the_content", "prepend_attachment");
                     end if;

                     exit; -- break;
                  end if;
               end;
            end loop;

            declare
               Template_2 : constant String :=
                 (if Template = "" then Get_Index_Template else Template'Image);

               --
               -- Filters the path of the current template before including it.
               --
               -- @since 3.0.0
               --
               -- @param string template The path of the template to include.
               --
               Template_3 : constant String :=
                 Apply_Filters ("template_include", Template_2);
            begin
               if Template_3 /= "" then
                  Logging.Log ("inc_template_loader.render", "no include");
--                Include (Template_3);
               elsif Current_User_Can ("switch_themes") then
                  declare
                     Theme : constant Wp_Theme := Wp_Get_Theme;
                  begin
                     if Theme.Errors /= Null_Wp_Error then
                        Wp_Die (Code => 999); -- Theme.Errors);
                     end if;
                  end;
               end if;
            end;
         end;
         return;
      end if;
   end Render;

end Inc_Template_Loader;
