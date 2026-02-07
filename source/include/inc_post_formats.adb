--
-- Post format functions.
--
-- @package WordPress
-- @subpackage Post
--

with Php.Arrays;

with Array_Lists;

with Inc_L10n;

package body Inc_Post_Formats
is

   -----------------------------
   -- Get_Post_Format_Strings --
   -----------------------------

   function Get_Post_Format_Strings
            return Array_Type
   is
      use Array_Lists;
      use Inc_L10n;

      Strings : constant Array_Type := To_Array_Type ([
        Build ("standard", X_X ("Standard", "Post format")),
        -- Special case. Any value that evals to false will be considered standard.
        Build ("aside",    X_X ("Aside", "Post format")),
        Build ("chat",     X_X ("Chat", "Post format")),
        Build ("gallery",  X_X ("Gallery", "Post format")),
        Build ("link",     X_X ("Link", "Post format")),
        Build ("image",    X_X ("Image", "Post format")),
        Build ("quote",    X_X ("Quote", "Post format")),
        Build ("status",   X_X ("Status", "Post format")),
        Build ("video",    X_X ("Video", "Post format")),
        Build ("audio",    X_X ("Audio", "Post format"))
      ]);
   begin
      return Strings;
   end Get_Post_Format_Strings;

   ---------------------------
   -- Get_Post_Format_Slugs --
   ---------------------------

   function Get_Post_Format_Slugs
            return List_Type
   is
      use Php.Arrays;

      Slugs : constant List_Type :=
        Array_Keys (Get_Post_Format_Strings);
   begin
      return Slugs; -- Array_Combine (Slugs, Slugs);
   end Get_Post_Format_Slugs;

end Inc_Post_Formats;
