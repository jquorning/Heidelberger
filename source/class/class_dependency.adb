--
-- Dependencies API: _WP_Dependency class
--
-- @since 4.7.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Logging;

package body Class_Dependency
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Handle : String;
                         Src    : String;
                         Deps   : List_Type; -- String_Array;
                         Ver    : String;
                         Args   : String) -- Array_Type) --  ...args )
                         return X_Wp_Dependency
   is
      use UStrings;

      This : X_Wp_Dependency;
   begin
      Logging.Log ("class_dependency.x_construct", Src);
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
                      Data : List_Type) -- String)
                      return Boolean
   is
   begin
--      if not Is_Scalar (Name) then
--         return False;
--      end if;
      for A of Data loop
         This.Extra.Append (Name, From_String (A)); -- (Name)
      end loop;
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
      use UStrings;
   begin
--      if not Is_String (Domain) then
--         return False;
--      end if;
      This.Textdomain        := +Domain;
      This.Translations_Path := +Path;
      return True;
   end Set_Translations;

   ----------------
   -- Array_Keys --
   ----------------

   function Array_Keys (Arry : Class_Dependency.Dependency_Map)
                        return List_Type
   is
      use Class_Dependency.Dependency_Maps;

      Keys : List_Type;
   begin
      for A in Arry.Iterate loop
         Keys.Append (Key (A));
      end loop;
      return Keys;
   end Array_Keys;

end Class_Dependency;
