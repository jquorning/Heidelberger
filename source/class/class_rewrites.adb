--
-- Rewrite API: WP_Rewrite class
--
-- @package WordPress
-- @subpackage Rewrite
-- @since 1.5.0
--

with Php.Preg;
with Php.Strings;

package body Class_Rewrites
is

   ----------------------
   -- Using_Permalinks --
   ----------------------

   function Using_Permalinks (This : Wp_Rewrite)
                              return Boolean
   is
      use Php.Strings;
      use UStrings;
   begin
      return not Empty (-This.Permalink_Structure);
   end Using_Permalinks;

   ----------------------------
   -- Using_Index_Permalinks --
   ----------------------------

   function Using_Index_Permalinks (This : Wp_Rewrite)
                                    return Boolean
   is
      use Php.Preg;
      use Php.Strings;
      use UStrings;
   begin
      if Empty (-This.Permalink_Structure) then
         return False;
      end if;

      -- If the index is not in the permalink, we're using mod_rewrite.
      return Preg_Match ("#^/*" & (-This.Index) & "#", -This.Permalink_Structure);
   end Using_Index_Permalinks;

   ---------------------------
   -- Get_Extra_Permastruct --
   ---------------------------

   function Get_Extra_Permastruct (This : Wp_Rewrite;
                                   Name : String)
                                   return String
   is
      use Php.Strings;
      use UStrings;
   begin
      if Empty (-This.Permalink_Structure) then
         return ""; -- False;
      end if;

      if Isset (This.Extra_Permastructs, Name) then
         return As_String (Get (Ref_2 (This.Extra_Permastructs,
                                       Key_1 => Name,
                                       Key_2 => "struct")));
      end if;

      return ""; -- False;
   end Get_Extra_Permastruct;

   --------------------------
   -- Get_Page_Permastruct --
   --------------------------

   function Get_Page_Permastruct (This : in out Wp_Rewrite)
                                  return String
   is
      use Php.Strings;
      use UStrings;
   begin
      if Isset (-This.Page_Structure) then
         return -This.Page_Structure;
      end if;

      if Empty (-This.Permalink_Structure) then
         This.Page_Structure := Null_UString;
         return ""; -- False;
      end if;

      This.Page_Structure := This.Root & "%pagename%";

      return -This.Page_Structure;
   end Get_Page_Permastruct;

end Class_Rewrites;
