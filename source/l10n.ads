package L10n is

   function "abs" (Item : String) return String;
   function Plural (Single : String; Plural : String; Argument : String) return String;
   function Gettext (Item : String) return String;
   function E_E (Item : String) return String is ("XXX-103");
   function Ex_Ex (Item : String; Arg : String := "") return String is ("XXX-104");

end L10n;
