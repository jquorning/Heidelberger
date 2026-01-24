--
-- WordPress environment setup class.
--
-- @package WordPress
-- @since 2.0.0
--

with Ada.Strings.Unbounded;

with Arrays;
with Hb_Common;
with Lists;

package Class_Wp
is
   use Ada.Strings.Unbounded;
   use Arrays;
   use Hb_Common;
   use Lists;

   procedure Dummy;

-- #[AllowDynamicProperties]
   type Wp is tagged
      record
         --
         -- Public query variables.
         --
         -- Long list of public query variables.
         --
         -- @since 2.0.0
         -- @var string[]
         --
         Public_Query_Vars : List_Type := To_List (List => (+"m", +"p", +"posts", +"w", +"cat", +"withcomments", +"withoutcomments", +"s", +"search", +"exact", +"sentence", +"calendar", +"page", +"paged", +"more", +"tb", +"pb", +"author", +"order", +"orderby", +"year", +"monthnum", +"day", +"hour", +"minute", +"second", +"name", +"category_name", +"tag", +"feed", +"author_name", +"pagename", +"page_id", +"error", +"attachment", +"attachment_id", +"subpost", +"subpost_id", +"preview", +"robots", +"favicon", +"taxonomy", +"term", +"cpage", +"post_type", +"embed"));

         --
         -- Private query variables.
         --
         -- Long list of private query variables.
         --
         -- @since 2.0.0
         -- @var string[]
         --
         Private_Query_Vars : List_Type := To_List (List => (+"offset", +"posts_per_page", +"posts_per_archive_page", +"showposts", +"nopaging", +"post_type", +"post_status", +"category__in", +"category__not_in", +"category__and", +"tag__in", +"tag__not_in", +"tag__and", +"tag_slug__in", +"tag_slug__and", +"tag_id", +"post_mime_type", +"perm", +"comments_per_page", +"post__in", +"post__not_in", +"post_parent", +"post_parent__in", +"post_parent__not_in", +"title", +"fields"));

         --
         -- Extra query variables set by the user.
         --
         -- @since 2.1.0
         -- @var array
         --
         Extra_Query_Vars : Array_Type;

         --
         -- Query variables for setting up the WordPress Query Loop.
         --
         -- @since 2.0.0
         -- @var array
         --
         Query_Vars : Array_Type;

         --
         -- String parsed to set the query variables.
         --
         -- @since 2.0.0
         -- @var string
         --
         Query_String : Unbounded_String;

         --
         -- The request path, e.g. 2015/05/06.
         --
         -- @since 2.0.0
         -- @var string
         --
         Request : Unbounded_String;

         --
         -- Rewrite rule the request matched.
         --
         -- @since 2.0.0
         -- @var string
         --
         Matched_Rule : Array_Type;

         --
         -- Rewrite query the request matched.
         --
         -- @since 2.0.0
         -- @var string
         --
         Matched_Query : Unbounded_String;

         --
         -- Whether already did the permalink.
         --
         -- @since 2.0.0
         -- @var bool
         --
         Did_Permalink : Boolean := False;

      end record;

   --
   -- Adds a query variable to the list of public query variables.
   --
   -- @since 2.1.0
   --
   -- @param string $qv Query variable name.
   --
   procedure Add_Query_Var (This : Wp;
                            Qv   : String)
                            is null;

end Class_Wp;
