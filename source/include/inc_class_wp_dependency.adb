--
-- Dependencies API: _WP_Dependency class
--
-- @since 4.7.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Hb_Common;

package body Inc_Class_Wp_Dependency
is
   use Hb_Common;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Handle : String;
                         Src    : String;
                         Deps   : String_Array;
                         Ver    : String;
                         Args   : String) -- Array_Type) --  ...args )
                         return X_Wp_Dependency
   is
      This : X_Wp_Dependency;
   begin
      -- list ()
      This.Handle := +Handle;
      This.Src    := +Src;
      This.Deps   := Deps;
      This.Ver    := +Ver;
--      this.Args   := Args;
--      if not Is_Array (This.Deps) then
--         This.Deps := Empty_Array;
--      end if;
      return This;
   end X_Construct;

   --------------
   -- Add_Data --
   --------------

   function Add_Data (This : in out X_Wp_Dependency;
                      Name : String;
                      Data : String)
                      return Boolean
   is
--    use Array_Vectors;
   begin
--      if not Is_Scalar (Name) then
--         return False;
--      end if;
      This.Extra.Insert (Name, Data); -- (Name)
      return True;
   end Add_Data;

   ----------------------
   -- Set_Translations --
   ----------------------

   function Set_Translations (This   : in out X_Wp_Dependency;
                              Domain : String;
                              Path   : String := "")
                              return Boolean
   is
   begin
--      if not Is_String (Domain) then
--         return False;
--      end if;
      This.Textdomain        := +Domain;
      This.Translations_Path := +Path;
      return True;
   end Set_Translations;

end Inc_Class_Wp_Dependency;
