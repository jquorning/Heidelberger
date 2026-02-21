--
-- Template loading functions.
--
-- @package WordPress
-- @subpackage Template
--

with Php.Files;
with Php.HTML;
with Php.Lists;
with Php.Preg;
with Php.Strings;

with Constants;
with Globals;
with Helpers;
with UStrings;
with Wp_Common;

with Class_Posts;
with Class_Post_Type;
with Class_Terms;
with Class_Users;

with Inc_Functions;
with Inc_Posts;
with Inc_Post_Formats;
with Inc_Post_Templates;
with Inc_Querys;

package body Inc_Templates
is

   ------------------------
   -- Get_Query_Template --
   ------------------------

   function Get_Query_Template (Typ       : String;
                                Templates : List_Type := Empty_List)
                                return String
   is
      use Php.Preg;
      use UStrings;
      use Wp_Common;

      Typ_2 : constant String := Preg_Replace ("|[^a-z0-9-]+|", "", Typ);

      Templates_2 : List_Type :=
        (if Templates.Is_Empty then List_Type'[Typ_2 & ".php"] else Templates);

      Template : UString;
   begin
      --
      -- Filters the list of template filenames that are searched for when retrieving
      -- a template to use.
      --
      -- The dynamic portion of the hook name, `type`, refers to the filename -- minus
      -- the file extension and any non-alphanumeric characters delimiting words --
      -- of the file to load. The last element in the array should always be the
      -- fallback template for this query type.
      --
      -- Possible hook names include:
      --
      --  - `404_template_hierarchy`
      --  - `archive_template_hierarchy`
      --  - `attachment_template_hierarchy`
      --  - `author_template_hierarchy`
      --  - `category_template_hierarchy`
      --  - `date_template_hierarchy`
      --  - `embed_template_hierarchy`
      --  - `frontpage_template_hierarchy`
      --  - `home_template_hierarchy`
      --  - `index_template_hierarchy`
      --  - `page_template_hierarchy`
      --  - `paged_template_hierarchy`
      --  - `privacypolicy_template_hierarchy`
      --  - `search_template_hierarchy`
      --  - `single_template_hierarchy`
      --  - `singular_template_hierarchy`
      --  - `tag_template_hierarchy`
      --  - `taxonomy_template_hierarchy`
      --
      -- @since 4.7.0
      --
      -- @param string[] templates A list of template candidates, in descending
      -- order of priority.
      --
      Templates_2 := Apply_Filters (Typ & "_template_hierarchy", Templates_2);

      Template := +Locate_Template (Templates_2);

--    Template := Locate_Block_Template (Template, Typ, Templates_2); -- XXX

      --
      -- Filters the path of the queried template by type.
      --
      -- The dynamic portion of the hook name, `type`, refers to the filename -- minus
      -- the file extension and any non-alphanumeric characters delimiting words -- of
      -- the file to load. This hook also applies to various types of files loaded as
      -- part of the Template Hierarchy.
      --
      -- Possible hook names include:
      --
      --  - `404_template`
      --  - `archive_template`
      --  - `attachment_template`
      --  - `author_template`
      --  - `category_template`
      --  - `date_template`
      --  - `embed_template`
      --  - `frontpage_template`
      --  - `home_template`
      --  - `index_template`
      --  - `page_template`
      --  - `paged_template`
      --  - `privacypolicy_template`
      --  - `search_template`
      --  - `single_template`
      --  - `singular_template`
      --  - `tag_template`
      --  - `taxonomy_template`
      --
      -- @since 1.5.0
      -- @since 4.8.0 The `type` and `templates` parameters were added.
      --
      -- @param string   template  Path to the template. See locate_template().
      -- @param string   type      Sanitized filename without extension.
      -- @param string[] templates A list of template candidates, in descending order
      --                           of priority.
      --
      return Apply_Filters (Typ & "_" & (-Template), -Template, Typ, Templates_2);
   end Get_Query_Template;

   ------------------------
   -- Get_Index_Template --
   ------------------------

   function Get_Index_Template
            return String
   is
   begin
      return Get_Query_Template ("index");
   end Get_Index_Template;

   ----------------------
   -- Get_404_Template --
   ----------------------

   function Get_404_Template
            return String
   is
   begin
      return Get_Query_Template ("404");
   end Get_404_Template;

   --------------------------
   -- Get_Archive_Template --
   --------------------------

   function Get_Archive_Template
            return String
   is
      use Php.Lists;
      use Inc_Querys;

      Post_Types : constant List_Type :=
        List_Filter ([Get_Query_Var ("post_type")]);

      Templates : List_Type;
   begin
      if Post_Types.Length in 1 then
         declare
            Post_Type : constant String :=
              Post_Types.First_Element; -- reset( post_types );
         begin
            Templates.Append ("archive-" & Post_Type & ".php");
         end;
      end if;
      Templates.Append ("archive.php");

      return Get_Query_Template ("archive", Templates);
   end Get_Archive_Template;

   ------------------------------------
   -- Get_Post_Type_Archive_Template --
   ------------------------------------

   function Get_Post_Type_Archive_Template
            return String
   is
      use Class_Post_Type;
      use Inc_Posts;
      use Inc_Querys;

      Post_Type : constant String := Get_Query_Var ("post_type");
   begin
      -- if Is_Array (Post_Type) then
      --    Post_Type := Post_Type.First_Element; --  = reset( post_type );
      -- end if;

      declare
         Obj : constant Wp_Post_Type := Get_Post_Type_Object (Post_Type);
      begin
         if not (Obj in Wp_Post_Type) or else not Obj.Has_Archive then -- instanceof
            return "";
         end if;
      end;
      return Get_Archive_Template;
   end Get_Post_Type_Archive_Template;

   -------------------------
   -- Get_Author_Template --
   -------------------------

   function Get_Author_Template
            return String
   is
      use UStrings;
      use Class_Users;
      use Inc_Querys;

      Author : constant Wp_User := Get_Queried_Object;
      Templates : List_Type; --  = array();
   begin
      if Author in Wp_User then -- instanceof
         Templates.Append ("author-" & (-Author.Prop.User_Nicename) & ".php");
         Templates.Append ("author-" & Image (Author.Id) & ".php");
      end if;
      Templates.Append ("author.php");

      return Get_Query_Template ("author", Templates);
   end Get_Author_Template;

   ---------------------------
   -- Get_Category_Template --
   ---------------------------

   function Get_Category_Template
            return String
   is
      use Php.HTML;
      use Php.Strings;
      use UStrings;
      use Class_Terms;
      use Inc_Querys;

      Category : constant Wp_Term := Get_Queried_Object;
      Templates : List_Type; -- = array();
   begin
      if not Empty (Category.Slug) then
         declare
            Slug_Decoded : constant String := URL_Decode (-Category.Slug);
         begin
            if Slug_Decoded /= Category.Slug then
               Templates.Append ("category-" & Slug_Decoded & ".php");
            end if;

            Templates.Append ("category-" & (-Category.Slug) & ".php");
            Templates.Append ("category-" & Helpers.Image (Category.Term_Id) & ".php");
         end;
      end if;
      Templates.Append ("category.php");

      return Get_Query_Template ("category", Templates);
   end Get_Category_Template;

   ----------------------
   -- Get_Tag_Template --
   ----------------------

   function Get_Tag_Template
            return String
   is
      use Php.HTML;
      use Php.Strings;
      use UStrings;
      use Class_Terms;
      use Inc_Querys;

      Tag       : constant Wp_Term := Get_Queried_Object;
      Templates : List_Type;
   begin
      if not Empty (Tag.Slug) then
         declare
            Slug_Decoded : constant String := URL_Decode (-Tag.Slug);
         begin
            if Slug_Decoded /= Tag.Slug then
               Templates.Append ("tag-" & Slug_Decoded & ".php");
            end if;
         end;
         Templates.Append ("tag-" & (-Tag.Slug) & ".php");
         Templates.Append ("tag-" & Helpers.Image (Tag.Term_Id) & ".php");
      end if;
      Templates.Append ("tag.php");

      return Get_Query_Template ("tag", Templates);
   end Get_Tag_Template;

   ---------------------------
   -- Get_Taxonomy_Template --
   ---------------------------

   function Get_Taxonomy_Template
            return String
   is
      use Php.HTML;
      use Php.Strings;
      use UStrings;
      use Class_Terms;
      use Inc_Querys;

      Term      : constant Wp_Term := Get_Queried_Object;
      Templates : List_Type;
   begin
      if not Empty (Term.Slug) then
         declare
            Taxonomy : constant String := -Term.Taxonomy;
            Slug_Decoded : constant String := URL_Decode (-Term.Slug);
         begin
            if Slug_Decoded /= Term.Slug then
               Templates.Append ("taxonomy-taxonomy-" & Slug_Decoded & ".php");
            end if;
         end;
         Templates.Append ("taxonomy-taxonomy-" & (-Term.Slug) & ".php");
         Templates.Append ("taxonomy-taxonomy.php");
      end if;
      Templates.Append ("taxonomy.php");

      return Get_Query_Template ("taxonomy", Templates);
   end Get_Taxonomy_Template;

   -----------------------
   -- Get_Date_Template --
   -----------------------

   function Get_Date_Template
            return String
   is
   begin
      return Get_Query_Template ("date");
   end Get_Date_Template;

   -----------------------
   -- Get_Home_Template --
   -----------------------

   function Get_Home_Template
            return String
   is
      Templates : constant List_Type := ["home.php", "index.php"];
   begin
      return Get_Query_Template ("home", Templates);
   end Get_Home_Template;

   -----------------------------
   -- Get_Front_Page_Template --
   -----------------------------

   function Get_Front_Page_Template
            return String
   is
      Templates : constant List_Type := ["front-page.php"];
   begin
      return Get_Query_Template ("frontpage", Templates);
   end Get_Front_Page_Template;

   ---------------------------------
   -- Get_Privacy_Policy_Template --
   ---------------------------------

   function Get_Privacy_Policy_Template
            return String
   is
      Templates : constant List_Type := ["privacy-policy.php"];
   begin
      return Get_Query_Template ("privacypolicy", Templates);
   end Get_Privacy_Policy_Template;

   -----------------------
   -- Get_Page_Template --
   -----------------------

   function Get_Page_Template
            return String
   is
      use Php.HTML;
      use UStrings;
      use Class_Posts;
      use Inc_Functions;
      use Inc_Post_Templates;
      use Inc_Querys;

      Id        : constant Post_Id_Type := Get_Queried_Object_Id;
      Template  : String := Get_Page_Template_Slug;
      Pagename  : String := Get_Query_Var ("pagename");
      Templates : List_Type;
   begin
      if Pagename = "" and then Id /= 0 then
         -- If a static page is set as the front page, pagename will not be set.
         -- Retrieve it from the queried object.
         declare
            Post : constant Wp_Post := Get_Queried_Object;
         begin
            if Post /= Null_Post then
               Pagename := -Post.Post_Name;
            end if;
         end;
      end if;

      if Template /= "" and then 0 = Validate_File (Template) then
         Templates.Append (Template);
      end if;

      if Pagename /= "" then
         declare
            Pagename_Decoded : constant String := URL_Decode (Pagename);
         begin
            if Pagename_Decoded /= Pagename then
               Templates.Append ("page-" & Pagename_Decoded & ".php");
            end if;
         end;
         Templates.Append ("page-" & Pagename & ".php");
      end if;

      if Id /= 0 then
         Templates.Append ("page-" & Image (Id) & ".php");
      end if;
      Templates.Append ("page.php");

      return Get_Query_Template ("page", Templates);
   end Get_Page_Template;

   -------------------------
   -- Get_Search_Template --
   -------------------------

   function Get_Search_Template
            return String
   is
   begin
      return Get_Query_Template ("search");
   end Get_Search_Template;

   -------------------------
   -- Get_Single_Template --
   -------------------------

   function Get_Single_Template
            return String
   is
      use Php.HTML;
      use Php.Strings;
      use UStrings;
      use Class_Posts;
      use Inc_Functions;
      use Inc_Post_Templates;
      use Inc_Querys;

      Object : constant Wp_Post := Get_Queried_Object;
      Templates : List_Type;
   begin
      if not Empty (Object.Post_Type) then
         declare
            Template : String := Get_Page_Template_Slug (Object);
         begin
            if Template /= "" and then 0 = Validate_File (Template) then
               Templates.Append (Template);
            end if;

            declare
               Name_Decoded : constant String := URL_Decode (-Object.Post_Name);
            begin
               if Name_Decoded /= Object.Post_Name then
                  Templates.Append ("single-" & (-Object.Post_Type) &
                                    "-" & Name_Decoded & ".php");
               end if;
            end;
         end;
         Templates.Append ("single-" & (-Object.Post_Type) &
                           "-" & (-Object.Post_Name) & ".php");
         Templates.Append ("single-" & (-Object.Post_Type) & ".php");
      end if;

      Templates.Append ("single.php");

      return Get_Query_Template ("single", Templates);
   end Get_Single_Template;

   ------------------------
   -- Get_Embed_Template --
   ------------------------

   function Get_Embed_Template
            return String
   is
      use Php.Strings;
      use UStrings;
      use Class_Posts;
      use Inc_Post_Formats;
      use Inc_Querys;

      Object : constant Wp_Post := Get_Queried_Object;
      Templates : List_Type;
   begin
      if not Empty (Object.Post_Type) then
         declare
            Post_Format : constant String := Get_Post_Format (Object);
         begin
            if Post_Format /= "" then
               Templates.Append ("embed-" & (-Object.Post_Type) &
                                 "-" & Post_Format & ".php");
            end if;
         end;
         Templates.Append ("embed-" & (-Object.Post_Type) & ".php");
      end if;

      Templates.Append ("embed.php");

      return Get_Query_Template ("embed", Templates);
   end Get_Embed_Template;

   ---------------------------
   -- Get_Singular_Template --
   ---------------------------

   function Get_Singular_Template
            return String
   is
   begin
      return Get_Query_Template ("singular");
   end Get_Singular_Template;

   -----------------------------
   -- Get_Attachment_Template --
   -----------------------------

   function Get_Attachment_Template
            return String
   is
      use Php.Strings;
      use UStrings;
      use Class_Posts;
      use Inc_Querys;

      Attachment : constant Wp_Post := Get_Queried_Object;
      Templates  : List_Type;
      Typ    : UString;
      Subtyp : UString;
   begin
      if Attachment /= Null_Post then
         if 0 /= Strpos (-Attachment.Post_Mime_Type, "/") then
            declare
               List : constant List_Type :=
                 Explode ("/", -Attachment.Post_Mime_Type);
            begin
               Typ    := +List (1);
               Subtyp := +List (2);
            end;
         else
            declare
               List : constant List_Type :=
                 [-Attachment.Post_Mime_Type, ""];
            begin
               Typ    := +List (1);
               Subtyp := +List (2);
            end;
         end if;

         if not Empty (-Subtyp) then
            Templates.Append ((-Typ) & "-" & (-Subtyp) & ".php");
            Templates.Append ((-Subtyp) & ".php");
         end if;
         Templates.Append ((-Typ) & ".php");
      end if;
      Templates.Append ("attachment.php");

      return Get_Query_Template ("attachment", Templates);
   end Get_Attachment_Template;

   ---------------------
   -- Locate_Template --
   ---------------------

   function Locate_Template (Template_Names : List_Type; -- String;
                             Load           : Boolean    := False;
                             Require_Once   : Boolean    := True;
                             Args           : Array_Type := Empty_Array)
                             return String
   is
      use Php.Files;
      use Constants;
      use Globals;
      use UStrings;

      Located : UString;
   begin
      for Template_Name of Template_Names loop
         if Template_Name = "" then
            goto Continue;
         end if;

         if File_Exists ((-STYLESHEETPATH) & "/" & Template_Name) then
            Located := (STYLESHEETPATH & "/" & Template_Name);
            exit;

         elsif File_Exists ((-TEMPLATEPATH) & "/" & Template_Name) then
            Located := (TEMPLATEPATH & "/" & Template_Name);
            exit;

         elsif File_Exists (-(ABSPATH & WPINC) & "/theme-compat/" & Template_Name) then
            Located := (ABSPATH & WPINC & "/theme-compat/" & Template_Name);
            exit;
         end if;
         << Continue >>
      end loop;

      if Load and then "" /= Located then
         Load_Template (-Located, Require_Once, Args);
      end if;

      return -Located;
   end Locate_Template;

end Inc_Templates;
