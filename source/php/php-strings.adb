--
--
--

with Ada.Characters.Handling;
with Ada.Strings.Fixed;
with Ada.Strings.Equal_Case_Insensitive;
with Ada.Strings.Less_Case_Insensitive;
with Ada.Strings.Maps;
with Ada.Strings.Unbounded;

with Logging;

package body Php.Strings
is

   -----------
   -- Isset --
   -----------

   function Isset (Item : String)
                   return Boolean
   is
   begin
      return Item /= "";
   end Isset;

   ------------
   -- Strstr --
   ------------

   function Strstr (Haystack      : String;
                    Needle        : String;
                    Before_Needle : Boolean := False)
                    return String
   is
      use Ada.Strings.Fixed;

      Haystack_2 : constant String :=
        (if Haystack = "" then "(uri)" else Haystack);

      Pos : constant Natural := Index (Needle, Haystack_2); -- XXX
   begin
      if Haystack = "" then
         Logging.Log ("strstr", "Haystack can not be empty - replaced - warning");
      end if;

      if Pos = 0 then
         return Haystack;
      else
         if Before_Needle then
            return Haystack (Haystack'First .. Pos - 1);
         else
            return Haystack (Pos .. Haystack'Last);
         end if;
      end if;
   end Strstr;

   ------------
   -- Strpos --
   ------------

   function Strpos (Item    : String;
                    Pattern : String)
                    return Natural
   is
      use Ada.Strings.Fixed;
   begin
      return Index (Source  => Item,
                    Pattern => Pattern);
   end Strpos;

   -------------
   -- Strrpos --
   -------------

   function Strrpos (Haystack : String;
                     Needle   : String)
                     return Natural
   is
      use Ada.Strings;
   begin
      return Fixed.Index (Source  => Haystack,
                          Pattern => Needle,
                          Going   => Backward);
   end Strrpos;

   -------------
   -- Stripos --
   -------------

   function Stripos (Haystack : String;
                     Needle   : String)
                     return Natural
   is
      use Ada.Strings.Fixed;

      Haystack_2 : constant String := Strtolower (Haystack);
      Needle_2   : constant String := Strtolower (Needle);
   begin
      return Index (Source  => Haystack_2,
                    Pattern => Needle_2);
   end Stripos;

   ------------------
   -- Substr_Count --
   ------------------

   function Substr_Count (Haystack : String;
                          Needle   : String)
                          return Natural
   is
   begin
      return
        Ada.Strings.Fixed.Count (Source  => Haystack,
                                 Pattern => Needle);
   end Substr_Count;

   --------------------
   -- Substr_Replace --
   --------------------

   function Substr_Replace (Item    : String;
                            Replace : String;
                            Offset  : Natural;
                            Length  : Natural)
                            return String
   is
      Pre  : constant String := Item (Item'First      .. Offset);
      Post : constant String := Item (Offset + Length .. Item'Last);
   begin
      return Pre & Replace & Post;
   end Substr_Replace;

   -------------
   -- Str_Pad --
   -------------

   function Str_Pad (Item       : String;
                     Length     : Integer;
                     Pad_String : Character := ' ';
                     Pad_Type   : Integer   := STR_PAD_RIGHT)
                     return String
   is
      use Ada.Strings.Fixed;

      Target : String (1 .. Length);
   begin
      if Pad_Type = STR_PAD_LEFT then
         Move (Source  => Item,
               Target  => Target,
               Justify => Ada.Strings.Right,
               Pad     => Pad_String);

      elsif Pad_Type = STR_PAD_RIGHT then
         Move (Source  => Item,
               Target  => Target,
               Justify => Ada.Strings.Left,
               Pad     => Pad_String);
      else
         pragma Assert (False);
      end if;
      return Target;
   end Str_Pad;

   -----------------
   -- Str_Replace --
   -----------------

   function Str_Replace (Search  : String;
                         Replace : String;
                         Subject : String)
                         return String
   is
      use Ada.Strings.Fixed;

      Pos : constant Natural := Index (Source  => Subject,
                                       Pattern => Search);
   begin
      if Pos = 0 then
         return Subject;
      else
         return
           Subject (Subject'First .. Pos - 1) &
           Replace &
           Str_Replace (Search, Replace,
                        Subject => Subject (Pos + Search'Length .. Subject'Last));
      end if;
   end Str_Replace;

   -----------------
   -- Str_Replace --
   -----------------

   function Str_Replace (Search  : List_Type;
                         Replace : String;
                         Subject : String)
                         return String
   is
      Unused_Count : Natural;
   begin
      return
        Str_Replace (Search, Replace, Subject,
                     Count => Unused_Count);
   end Str_Replace;

   -----------------
   -- Str_Replace --
   -----------------

   function Str_Replace (Search  : List_Type;
                         Replace : List_Type;
                         Subject : String)
                         return String
   is
      use UStrings;

      Result : UString;
      First  : Natural := Subject'First;
   begin
      while First <= Subject'Last loop
         declare
            B : Natural := Natural'Last;
            I : Natural;
            E : Natural;
         begin
            for A in Search.First_Index .. Search.Last_Index loop
               E := Ada.Strings.Unbounded.Index
                      (Source  => +Subject (First .. Subject'Last),
                       Pattern => Search (A));
               if E /= 0 and then E < B then
                  B := E;
                  I := A;
               end if;
            end loop;

            if E = Natural'Last then
               UStrings.Append (Result, Subject);
               exit;
            else
               UStrings.Append (Result, Subject (First .. B - 1));
               UStrings.Append (Result, Replace (I));
               First := First + Ada.Strings.Unbounded.Length (+Search (I));
            end if;
         end;
      end loop;
      return -Result;
   end Str_Replace;

   -----------------
   -- Str_Replace --
   -----------------

   function Str_Replace (Search  : List_Type;
                         Replace : String;
                         Subject : String;
                         Count   : out Natural)
                         return String
   is
      use UStrings;

      Result : UString;
      First  : Natural := Subject'First;
   begin
      Logging.Log ("str_replace", "");

      Count := 0;
      while First <= Subject'Last loop
         declare
            Found_Position : Natural := Natural'Last;
            Found_Index    : Natural;
            Position       : Natural;
         begin
            for Search_Index in Search.First_Index .. Search.Last_Index loop

               Position :=
                 Ada.Strings.Fixed.Index (Source  => Subject,
                                          Pattern => Search (Search_Index),
                                          From    => First);

               if Position = 0 then
                  Append (Result, Subject);
--                Count := Count + 1;
                  return -Result;
               end if;

               if Position /= 0 and then Position < Found_Position then
                  Found_Position := Position;
                  Found_Index    := Search_Index;
               end if;

            end loop;

            if Position = Natural'Last then
               Append (Result, Subject);
               Count := Count + 1;
               exit;
            else
               Append (Result, Subject (First .. Found_Position - 1));
               Append (Result, Replace);
               Count := Count + 1;
               First := Position + Ada.Strings.Unbounded.Length (+Search (Found_Index));
            end if;
         end;
      end loop;
      return -Result;
   end Str_Replace;

   ----------------
   -- Str_Repeat --
   ----------------

   function Str_Repeat (Item  : String;
                        Times : Natural)
                        return String
   is
      use Ada.Strings.Fixed;
   begin
      return Times * Item;
   end Str_Repeat;

   ------------
   -- Substr --
   ------------

   function Substr (Item   : String;
                    Offset : Integer;
                    Length : Integer := Integer'First)
                    return String
   is
   begin
      if Offset < 0 then
         return "XXX-931";
      end if;

      if Length = 0 then
         return "";
      elsif Length > 0 then
         declare
            First : constant Natural := Item'First + Offset;
            Last  : constant Natural := Item'First + Offset + Length - 1;
         begin
            if First not in Item'Range or Last not in Item'Range then
               return "";
            else
               return Item (First .. Last);
            end if;
         end;
      elsif Length = Integer'First then
         return Item (Item'First + Offset .. Item'Last);
      else
         raise Program_Error with "not implemented";
      end if;
   end Substr;

   ------------
   -- Strlen --
   ------------

   function Strlen (Item : String)
                    return Natural
   is (Item'Length);

   ---------------------
   -- Str_Starts_With --
   ---------------------

   function Str_Starts_With (Haystack : String;
                             Needle   : String)
                             return Boolean
   is
   begin
      if Needle'Length > Haystack'Length then
         return False;
      end if;
      return Haystack (Needle'Range) = Needle;
   end Str_Starts_With;

   ------------------
   -- Str_Contains --
   ------------------

   function Str_Contains (Haystack : String;
                          Needle   : String)
                          return Boolean
   is
      use Ada.Strings.Fixed;
   begin
      return Index (Haystack, Needle) /= 0;
   end Str_Contains;

   ----------------
   -- Strtoupper --
   ----------------

   function Strtoupper (Item : String)
                        return String
   is
      use Ada.Characters.Handling;
   begin
      return To_Upper (Item);
   end Strtoupper;

   ----------------
   -- Strtolower --
   ----------------

   function Strtolower (Item : String)
                        return String
   is
      use Ada.Characters.Handling;
   begin
      return To_Lower (Item);
   end Strtolower;

   --------------
   -- UC_First --
   --------------

   function UC_First (Item : String)
                      return String
   is
      use Ada.Characters.Handling;

      Copy : String := Item;
   begin
      Copy (Copy'First) := To_Upper (Copy (Copy'First));
      return Copy;
   end UC_First;

   ------------
   -- Strcmp --
   ------------

   function Strcmp (Left  : String;
                    Right : String)
                    return Integer
   is
   begin
      if Left < Right then
         return -1;
      elsif Right > Left then
         return 1;
      else
         return 0;
      end if;
   end Strcmp;

   -------------
   -- Strncmp --
   -------------

   function Strncmp (Left   : String;
                     Right  : String;
                     Length : Integer)
                     return Integer
   is
      Left_2  : constant String := Left  (Left'First  .. Left'First  + Length - 1);
      Right_2 : constant String := Right (Right'First .. Right'First + Length - 1);
   begin
      if Left_2 < Right_2 then
         return -1;
      elsif Left_2 > Right_2 then
         return 1;
      else
         return 0;
      end if;
   end Strncmp;

   -------------------
   -- Strnatcasecmp --
   -------------------

   function Strnatcasecmp (Left, Right : String)
                           return Integer
   is
      use Ada.Strings;

      EQ : constant Boolean := Equal_Case_Insensitive (Left, Right);
      LT : constant Boolean := Less_Case_Insensitive (Left, Right);
   begin
      return (case LT is
              when False => (case EQ is
                             when False => 1,
                             when True  => 0),
              when True  => -1);
   end Strnatcasecmp;

   -----------
   -- Ltrim --
   -----------

   function Ltrim (Item       : String;
                   Characters : String := Default_Characters)
                   return String
   is
      use Ada.Strings.Fixed;

      First : Natural := Item'First;
   begin
      for Idx in Item'Range loop
         if Index (Characters, "" & Item (Idx)) = 0 then
            First := Idx;
            exit;
         end if;
      end loop;
      return Item (First .. Item'Last);
   end Ltrim;

   -----------
   -- Rtrim --
   -----------

   function Rtrim (Item       : String;
                   Characters : String := Default_Characters)
                   return String
   is
      use Ada.Strings.Fixed;

      Last : Natural := Item'Last;
   begin
      for Idx in reverse Item'Range loop
         if Index (Characters, "" & Item (Idx)) = 0 then
            Last := Idx;
            exit;
         end if;
      end loop;
      return Item (Item'First .. Last);
   end Rtrim;

   ----------
   -- Trim --
   ----------

   function Trim (Item       : String;
                  Characters : String := Default_Characters)
                  return String
   is
   begin
      return Ltrim (Rtrim (Item, Characters),
                    Characters);
   end Trim;

   -- ----------
   -- -- Trim --
   -- ----------

   -- function Trim (Item : String)
   --                return String
   -- is
   -- begin
   --    return Ltrim (Rtrim (Item, Default_Characters),
   --                  Default_Characters);
   -- end Trim;

   ------------
   -- Strtok --
   ------------

   function Strtok (Item  : String;
                    Token : String)
                    return String
   is
      use Ada.Strings;

      Tokens : constant Maps.Character_Set := Maps.To_Set (Token);
      First  : Positive;
      Last   : Natural;
   begin
      Fixed.Find_Token (Source => Item,
                        Set    => Tokens,
                        Test   => Inside,
                        First  => First,
                        Last   => Last);
      return Item (First .. Last);
   end Strtok;

   -------------
   -- Strpbrk --
   -------------

   function Strpbrk (Item       : String;
                     Characters : String)
                     return String
   is
      use Ada.Strings.Fixed;

      Pos : constant Natural := Index (Item, Characters);
   begin
      if Pos = 0 then
         return "";
      end if;
      return Item (Pos .. Item'Last);
   end Strpbrk;

   ---------------
   -- Str_Split --
   ---------------

   function Str_Split (Item   : String;
                       Length : Natural := 1)
                       return Array_Type
   is (Empty_Array);

   -------------
   -- Stristr --
   -------------

   function Stristr (Haystack      : String;
                     Needle        : String;
                     Before_Needle : Boolean := False)
                     return Boolean
   is (raise Program_Error with "False");

   ----------------
   -- Strip_Tags --
   ----------------

   function Strip_Tags (Item         : String;
                        Allowed_Tags : Array_Type := Empty_Array)
                        return String
   is
   begin
      Logging.Log ("strip_tags", Item);
      return Item;
   end Strip_Tags;

   -----------------
   -- Add_Slashes --
   -----------------

   function Add_Slashes (Item : String)
            return String
   is
      use Ada.Strings;
      use Ada.Strings.Maps;

      Needles : constant Character_Set :=
         To_Set (''') and To_Set ('"') and To_Set ('\') and To_Set (ASCII.NUL);
      First : Positive;
      Last  : Natural;
   begin
      Fixed.Find_Token (Source => Item,
                        Set    => Needles,
                        Test   => Inside,
                        First  => First,
                        Last   => Last);
      if Last = 0 then
         return Item;
      else
         return
           Item (Item'First .. First - 1) & "\" & Item (First) &
           Add_Slashes (Item (Last + 1 .. Item'Last));
      end if;
   end Add_Slashes;

   -------------------
   -- Add_C_Slashes --
   -------------------

   function Add_C_Slashes (Item       : String;
                           Characters : String)
                           return String
   is
   begin
      Logging.Log ("add_c_slashes", "not implemented");
      Logging.Log ("add_c_slashes", "  item : " & Item);
      Logging.Log ("add_c_stashes", "  chars: " & Characters);

      return Item;
   end Add_C_Slashes;

   -------------------
   -- Strip_Slashes --
   -------------------

   function Strip_Slashes (Item : String)
                          return String
   is
      use UStrings;

      Result : UString;
   begin
      for A of Item loop
         if A = '/' then
            null;
         else
            Append (Result, A);
         end if;
      end loop;
      return -Result;
   end Strip_Slashes;

   ------------
   -- Printf --
   ------------

   function Printf (Format : String;
                    Args   : List_Type)
                    return String
   is
      use UStrings;

      Buffer : UString;
      A : Natural := Format'First;
      B : Natural := Args.First_Index;
   begin
      while A <= Format'Last loop
         if Format (A) = '%' then
            if Format (A + 1) in 's' | 'd' then
               Append (Buffer, Args (B));
               B := B + 1;
               A := A + 2;
            elsif Format (A + 2) in 's' | 'd' then
               Append (Buffer, Args (B));
               B := B + 1;
               A := A + 3;
            elsif Format (A + 3) in 's' | 'd' then
               Append (Buffer, Args (B));
               B := B + 1;
               A := A + 4;
            elsif Format (A + 1) in '%' then
               Append (Buffer, '%');
               A := A + 2;
            else
               raise Constraint_Error with "bad format";
            end if;
         else
            Append (Buffer, Format (A));
            A := A + 1;
         end if;
      end loop;
      return To_String (Buffer);
   end Printf;

   -------------
   -- Sprintf --
   -------------

   function Sprintf (Format : String;
                     Args   : List_Type)
                     return String
   is (Printf (Format, Args));

   --------------
   -- Vsprintf --
   --------------

   function Vsprintf (Format : String;
                      Args   : List_Type)
                      return String
   is (Printf (Format, Args));

   -------------
   -- Implode --
   -------------

   function Implode (Separator : String;
                     Arry      : Array_Type)
                     return String
   is
      use UStrings;

      Ret   : UString;
      First : Boolean := True;
   begin
      for A in Arry.Iterate loop
         if not First then
            Append (Ret, Separator);
         end if;
         Append (Ret, Key (A));
         First := False;
      end loop;
      return -Ret;
   end Implode;

   -------------
   -- Implode --
   -------------

   function Implode (Separator : String;
                     Arry      : String)
                     return String
   is
   begin
      Logging.Log ("implode", "(should this exist)");
      Logging.Log ("implode", "  separator: " & Separator);
      Logging.Log ("implode", "  item     : " & Arry);

      return "XXX-968";
   end Implode;

   -------------
   -- Implode --
   -------------

   function Implode (Separator : String;
                     List      : List_Type)
                     return String
   is
      use UStrings;

      Buffer : UString;
      First  : Boolean := True;
   begin
      for A of List loop
         if not First then
            Append (Buffer, Separator);
         end if;
         First := False;
         Append (Buffer, A);
      end loop;
      return -Buffer;
   end Implode;

   -------------
   -- Explode --
   -------------

   function Explode (Separator : String;
                     Item      : String;
                     Limit     : Integer := Integer'Last)
                     return List_Type
   is
      use Ada.Strings.Fixed;

      Count : Natural := 0;
      First : Natural := Item'First;
      Pos   : Natural;
      List  : List_Type;
   begin
      while Count < Limit loop
         Pos := Index (Source  => Item,
                       Pattern => Separator,
                       From    => First);
         exit when Pos = 0;
         List.Append (Item (First .. Pos - 1));
         Count := Count + 1;
         First := Pos + Separator'Length;
      end loop;

      List.Append (Item (First .. Item'Last));
      return List;
   end Explode;

   -------------
   -- Explode --
   -------------

   function Explode (Separator : String;
                     Item      : String;
                     Limit     : Integer := Integer'Last)
                     return Array_Type
   is
      List : constant List_Type := Explode (Separator, Item, Limit);
      Result : Array_Type;
   begin
      for A of List loop
         Result.Append (Key   => A,
                        Value => From_String (""));
      end loop;
      return Result;
   end Explode;

end Php.Strings;
