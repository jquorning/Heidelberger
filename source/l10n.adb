package body L10n is

   function "abs" (Item : String) return String is (Item);

   function Plural (Single : String; Plural : String; Argument : String) return String
   is
   begin
      return Single;
   end Plural;

   function Gettext (Item : String) return String is (Item);

end L10n;
