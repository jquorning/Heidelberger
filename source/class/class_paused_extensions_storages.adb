--
-- Error Protection API: WP_Paused_Extensions_Storage class
--
-- @package WordPress
-- @since 5.2.0
--

with Php.Strings;

with Inc_Error_Protection;
with Inc_Options;

package body Class_Paused_Extensions_Storages
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Extension_Type : String)
                         return Wp_Paused_Extensions_Storage
   is
      use UStrings;

      This : Wp_Paused_Extensions_Storage;
   begin
      This.Typ := +Extension_Type;
      return This;
   end X_Construct;

   ---------
   -- Get --
   ---------

   function Get (This      : Wp_Paused_Extensions_Storage;
                 Extension : String)
            return Array_Type
   is
   begin
      if not This.Is_API_Loaded then
         return Empty_Array; -- null;
      end if;

      declare
         Paused_Extensions : constant Array_Type := This.Get_All;
      begin
         if not Isset (Paused_Extensions, Extension) then
            return Empty_Array; -- null;
         end if;

         return As_Array (Get (Paused_Extensions, Extension));
      end;
   end Get;

   -------------
   -- Get_All --
   -------------

   function Get_All (This : Wp_Paused_Extensions_Storage)
                     return Array_Type
   is
      use UStrings;
      use Inc_Options;
   begin
      if not This.Is_API_Loaded then
         return Empty_Array;
      end if;

      declare
         Option_Name : constant String := This.Get_Option_Name;
      begin
         if Option_Name = "" then
            return Empty_Array;
         end if;

         declare
            Paused_Extensions : constant Array_Type :=
              Get_Option (Option_Name, Empty_Array);     -- (array)
         begin
            return (if Isset (Paused_Extensions, -This.Typ)
                    then As_Array (Get (Paused_Extensions, -This.Typ))
                    else Empty_Array);
         end;
      end;
   end Get_All;

   -------------------
   -- Is_API_Loaded --
   -------------------

   function Is_API_Loaded (This : Wp_Paused_Extensions_Storage)
                           return Boolean
   is
   begin
      return True; -- Function_Exists ("get_option");
   end Is_API_Loaded;

   ----------------------
   -- Get_Options_Name --
   ----------------------

   function Get_Option_Name (This : Wp_Paused_Extensions_Storage)
                             return String
   is
      use Php.Strings;
      use UStrings;
      use Inc_Error_Protection;
   begin
      if not X_Wp_Recovery_Mode.Is_Active then
         return "";
      end if;

      declare
         Session_Id : constant String := X_Wp_Recovery_Mode.Get_Session_Id;
      begin
         if Empty (Session_Id) then
            return "";
         end if;

         return Session_Id & "_paused_extensions";
      end;
   end Get_Option_Name;

end Class_Paused_Extensions_Storages;
