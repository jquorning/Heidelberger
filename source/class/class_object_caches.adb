--
-- Object Cache API: WP_Object_Cache class
--
-- @package WordPress
-- @subpackage Cache
-- @since 5.4.0
--

with Php.Arrays;
with Php.Strings;
with Php.Types;

with Logging;

with Inc_Functions;
with Inc_L10n;

package body Class_Object_Caches
is

   ------------------
   -- Is_Valid_Key --
   ------------------

   function Is_Valid_Key
     (This : Wp_Object_Cache; Key : Key_Type) return Boolean
   is
      use Php.Types;
      use Php.Strings;
      use Inc_Functions;
      use Inc_L10n;
   begin
      if Is_Numeric (String (Key)) then
         --    if Is_Int (Key) then
         return True;
      end if;

      if Is_String (String (Key)) and then Trim (String (Key)) /= "" then
         return True;
      end if;

      declare
         --       Typ : String := Gettype (Key);

         --         if ( ! function_exists( "__" ) ) then
         --            wp_load_translations_early();
         --         end;
         Message : constant String :=
           (if Is_String (String (Key))
            then abs "Cache key must not be an empty string."
            -- translators: %s: The type of the given cache key.
            else
              Sprintf
                (abs "Cache key must be integer or non-empty string, %s given.",
                 [1 => "Typ"]));
      begin
         X_Doing_It_Wrong
           (Sprintf
              ("%s::%s",
               [1 => "inc_class_wp_object_caches", 2 => "is_valid_key"]),
            --         "__CLASS__",
            --         "Debug_Backtrace (DEBUG_BACKTRACE_IGNORE_ARGS, 2 )[1][""function""]"),
            Message,
            "6.1.0");
      end;
      return False;
   end Is_Valid_Key;

   --------------
   -- X_Exists --
   --------------

   function X_Exists
     (This : Wp_Object_Cache; Key : Key_Type; Group : Group_Type)
      return Boolean
   is
      use Php.Arrays;
   begin
      return
        Isset (This.Cache, String (Group))
        and then (Isset_2 (This.Cache, String (Group), String (Key))
                  or else Array_Key_Exists
                            (String (Key),
                             As_Array (Get (This.Cache, String (Group)))));
   end X_Exists;

   ---------
   -- Add --
   ---------

   procedure Add
     (This    : in out Wp_Object_Cache;
      Key     : Key_Type;
      Data    : Multi_Type;
      Group   : Group_Type := "default";
      Expire  : Natural := 0;
      Success : out Boolean)
   is
      use UStrings;
      use Inc_Functions;
   begin
      Success := False;

      if Wp_Suspend_Cache_Addition then
         return;
      end if;

      if not This.Is_Valid_Key (Key) then
         return;
      end if;

      declare
         Group_2 : constant Group_Type :=
           (if Group = "" then "default" else Group);

         Id : constant Key_Type :=
           (if This.Multisite
              and then not Isset (This.Global_Groups, String (Group_2))
            then Key_Type (-This.Blog_Prefix) & Key
            else Key);
      begin
         if This.X_Exists (Id, Group_2) then
            return;
         end if;

         This.Set (Key, Data, Group_2, Expire, Success => Success);
      end;
   end Add;

   ---------
   -- Set --
   ---------

   procedure Set
     (This    : in out Wp_Object_Cache;
      Key     : Key_Type;
      Data    : Multi_Type;
      Group   : Group_Type := "default";
      Expire  : Natural := 0;
      Success : out Boolean)
   is
      use UStrings;
   begin
      Success := False;

      if not This.Is_Valid_Key (Key) then
         return;
      end if;

      declare
         Group_2 : constant Group_Type :=
           (if Group = "" then "default" else Group);

         Key_2 : constant Key_Type :=
           (if This.Multisite
              and then not Isset (This.Global_Groups, String (Group))
            then Key_Type (-This.Blog_Prefix) & Key
            else Key);
      begin
         --       if ( is_object( data ) ) then
         --          data = clone data;
         --       end if;

         Set_2
           (This.Cache,
            Key_1 => String (Group_2),
            Key_2 => String (Key_2),
            Value => Data);
         Success := True;
      end;
   end Set;

   ---------
   -- Get --
   ---------

   function Get
     (This  : in out Wp_Object_Cache;
      Key   : Key_Type;
      Group : Group_Type := "default";
      Force : Boolean := False;
      Found : out Boolean) return Multi_Type
   is
      use UStrings;
   begin
      Logging.Log ("class_object_caches.get", String (Key));
      Found := False;

      if not This.Is_Valid_Key (Key) then
         Logging.Log ("class_object_caches.get", "invaid key");
         return From_Null;
      end if;

      declare
         Group_2 : constant Group_Type :=
           (if Group = "" then "default" else Group);

         Key_2 : constant Key_Type :=
           (if This.Multisite
              and then not Isset (This.Global_Groups, String (Group))
            then Key_Type (-This.Blog_Prefix) & Key
            else Key);
      begin

         if This.X_Exists (Key_2, Group_2) then
            Logging.Log ("class_object_caches.get", "found");
            Found := True;
            This.Cache_Hits := This.Cache_Hits + 1;
            --          if ( is_object( this->cache[ group ][ key ] ) ) then
            --             return clone this->cache[ group ][ key ];
            --          else
            return Get (Ref_2 (This.Cache, String (Group_2), String (Key_2)));
         --          end if;

         end if;

         Found := False;
         This.Cache_Misses := This.Cache_Misses + 1;
         Logging.Log ("class_object_caches.get", "return null");
         return From_Null;
      end;
   end Get;

   ------------
   -- Delete --
   ------------

   function Delete
     (This       : in out Wp_Object_Cache;
      Key        : Key_Type;
      Group      : Group_Type := "default";
      Deprecated : Boolean := False) return Boolean
   is
      use UStrings;
   begin
      if not This.Is_Valid_Key (Key) then
         return False;
      end if;

      declare
         Group_2 : constant Group_Type :=
           (if Group = "" then "default" else Group);

         Key_2 : constant Key_Type :=
           (if This.Multisite
              and then not Isset (This.Global_Groups, String (Group))
            then Key_Type (-This.Blog_Prefix) & Key
            else Key);
      begin
         if not This.X_Exists (Key_2, Group_2) then
            return False;
         end if;

         Delete (Ref_2 (This.Cache, String (Group_2), String (Key_2)));
      end;
      return True;
   end Delete;

   ------------
   -- Delete --
   ------------

   procedure Delete
     (This       : in out Wp_Object_Cache;
      Key        : Key_Type;
      Group      : Group_Type := "default";
      Deprecated : Boolean := False)
   is
      Unused : constant Boolean := This.Delete (Key, Group, Deprecated);
   begin
      null;
   end Delete;

   ---------------------
   -- Delete_Multiple --
   ---------------------

   function Delete_Multiple (This  : in out Wp_Object_Cache;
                             Keys  : List_Type;
                             Group : Group_Type := "")
                             return Array_Type
   is
      Values      : Array_Type;
      Unused_Done : Boolean;
   begin
      for Key of Keys loop
         Set (Values, Key,
              From_Boolean (
                This.Delete (Key_Type (Key), Group)));
      end loop;

      return Values;
   end Delete_Multiple;

   -----------
   -- Flush --
   -----------

   procedure Flush (This : in out Wp_Object_Cache)
   is
   begin
      This.Cache := Empty_Array;

--    return true;
   end Flush;

end Class_Object_Caches;
