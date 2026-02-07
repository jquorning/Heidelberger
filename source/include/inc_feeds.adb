--
-- WordPress Feed API
--
-- Many of the functions used in here belong in The Loop, or The Loop for the
-- Feeds.
--
-- @package WordPress
-- @subpackage Feed
-- @since 2.1.0
--

with Php.Strings;

with Arrays;
with Array_Lists;
with Wp_Common;

package body Inc_Feeds
is
   use Arrays;

   ----------------------
   -- Get_Default_Feed --
   ----------------------

   function Get_Default_Feed
            return String
   is
      use Wp_Common;

      --
      -- Filters the default feed type.
      --
      -- @since 2.5.0
      --
      -- @param string feed_type Type of default feed. Possible values include
      --                         'rss2', 'atom'. Default 'rss2'.
      --
      Default_Feed : constant String :=
        Apply_Filters ("default_feed", "rss2");
   begin
      return (if "rss" = Default_Feed then "rss2" else Default_Feed);
   end Get_Default_Feed;

   -----------------------
   -- Feed_Content_Type --
   -----------------------

   function Feed_Content_Type (Typ : String := "")
                               return String
   is
      use Php.Strings;
      use Array_Lists;
      use Wp_Common;

      Type_2 : constant String :=
        (if Empty (Typ) then Get_Default_Feed else Typ);

      Types : constant Array_Type :=
        To_Array_Type ([
          Build ("rss",      "application/rss+xml"),
          Build ("rss2",     "application/rss+xml"),
          Build ("rss-http", "text/xml"),
          Build ("atom",     "application/atom+xml"),
          Build ("rdf",      "application/rdf+xml")
        ]);

      Content_Type : constant String :=
        (if not Empty (Get_As_String (Types, Type_2))
         then Get_As_String (Types, Type_2)
         else "application/octet-stream");
   begin
      --
      -- Filters the content type for a specific feed type.
      --
      -- @since 2.8.0
      --
      -- @param string content_type Content type indicating the type of data that a
      --                            feed contains.
      -- @param string type         Type of feed. Possible values include "rss",
      --                            "rss2", "atom", and "rdf".
      --
      return Apply_Filters ("feed_content_type", Content_Type, Type_2);
   end Feed_Content_Type;

end Inc_Feeds;
