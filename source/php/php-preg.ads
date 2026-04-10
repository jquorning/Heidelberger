--
--
--

with Arrays;
with Lists;

package Php.Preg
is
   use Arrays;
   use Lists;

   type Limit_Type is range 0 .. Integer'Last;
   No_Limit : constant Limit_Type := Limit_Type'Last;

   type Flag_Type is record
      PREG_SPLIT_DELIM_CAPTURE : Boolean;
      PREG_SPLIT_NO_EMPTY      : Boolean;
   end record;
   No_Flags : constant Flag_Type := (others => False);

   procedure Preg_Replace
     (Pattern     : List_Type;
      Replacement : List_Type;
      Subject     : List_Type;
      Limit       : Limit_Type := No_Limit;
      Count       : out Natural;
      Result      : out List_Type);

   function Preg_Replace
     (Pattern     : String;
      Replacement : String;
      Subject     : String;
      Limit       : Limit_Type := No_Limit;
      Count       : out Natural) return String;

   function Preg_Replace
     (Pattern     : List_Type;
      Replacement : List_Type;
      Subject     : String) return String;

   function Preg_Replace
     (Pattern     : String;
      Replacement : String;
      Subject     : String) return String;

   function Preg_Match
     (Pattern : String;
      Subject : String;
      Matches : out List_Type;
      Flags   : Integer := 0;
      Offset  : Integer := 0) return Integer;

   function Preg_Match
     (Pattern : String;
      Subject : String;
      Matches : out Array_Type;
      Flags   : Integer := 0;
      Offset  : Integer := 0) return Integer;

   function Preg_Match
     (Pattern : String;
      Subject : String;
      Flags   : Integer := 0;
      Offset  : Integer := 0) return Boolean;

   function Preg_Match
     (Pattern : String;
      Subject : String;
      Flags   : Integer := 0;
      Offset  : Integer := 0) return Integer;

   procedure Preg_Match
     (Pattern : String;
      Subject : String;
      Matches : out List_Type;
      Flags   : Integer := 0;
      Offset  : Integer := 0);

   procedure Preg_Match
     (Pattern : String;
      Subject : String;
      Matches : out Array_Type;
      Flags   : Integer := 0;
      Offset  : Integer := 0);

   procedure Preg_Match_All
     (Pattern : String;
      Subject : String;
      Matches : out Array_Type;
      Flags   : Flag_Type := No_Flags;
      Count   : out Natural);

   procedure Preg_Match_All
     (Pattern : String;
      Subject : String;
      Matches : out List_Type;
      Flags   : Flag_Type := No_Flags;
      Offset  : Integer   := 0);

   function Preg_Match_All
     (Pattern : String;
      Subject : String;
      Matches : out Array_Type;
      Flags   : Flag_Type := No_Flags;
      Offset  : Integer   := 0) return Integer;

   function Preg_Split
     (Pattern : String;
      Subject : String;
      Limit   : Limit_Type := No_Limit;
      Flags   : Flag_Type  := No_Flags) return List_Type;

   function Preg_Quote (Str : String; Delimiter : String := "") return String;

   type Callable_10 is access function (Item : List_Type) return String;

   function Preg_Replace_Callback
     (Pattern : String; Callback : Callable_10; Subject : String)
      return String;

end Php.Preg;
