package L10n is

   function "abs" (Item : String) return String;
   function Plural (Single : String; Plural : String; Argument : String) return String;
   function Gettext (Item : String) return String;

end L10n;
