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

with UStrings;
with Lists;

with Inc_Functions;
with Inc_L10n;

package body Class_Object_Caches
is
   use Lists;

   ------------------
   -- Is_Valid_Key --
   ------------------

   function Is_Valid_Key (This : Wp_Object_Cache;
                          Key  : String)
                          return Boolean
   is
      use Php.Types;
      use Php.Strings;
      use UStrings;
      use Inc_Functions;
      use Inc_L10n;
   begin
      if Is_Numeric (Key) then
--    if Is_Int (Key) then
         return True;
      end if;

      if Is_String (Key) and then Trim (Key) /= "" then
         return True;
      end if;

      declare
--       Typ : String := Gettype (Key);

--         if ( ! function_exists( "__" ) ) then
--            wp_load_translations_early();
--         end;
         Message : constant String :=
           (if Is_String (Key)
            then abs "Cache key must not be an empty string."
            -- translators: %s: The type of the given cache key.
            else Sprintf (
              abs "Cache key must be integer or non-empty string, %s given.",
              To_List ("Typ")));
      begin
         X_Doing_It_Wrong (
           Sprintf (
             "%s::%s",
             To_List (List => (
               1 => +"inc_class_wp_object_caches",
               2 => +"is_valid_key"
             ))
           ),
--         "__CLASS__",
--         "Debug_Backtrace (DEBUG_BACKTRACE_IGNORE_ARGS, 2 )[1][""function""]"),
           Message,
           "6.1.0"
         );
      end;
      return False;
   end Is_Valid_Key;

   --------------
   -- X_Exists --
   --------------

   function X_Exists (This  : Wp_Object_Cache;
                      Key   : String;
                      Group : String)
                      return Boolean
   is
      use Php.Arrays;
   begin
      return
        Isset (This.Cache, Group) and then
        (Isset_2 (This.Cache, Group, Key) or else
         Array_Key_Exists (Key, As_Array (Get (This.Cache, Group))));
   end X_Exists;

   ---------
   -- Add --
   ---------

   procedure Add (This    : in out Wp_Object_Cache;
                  Key     : String;
                  Data    : Multi_Type;
                  Group   : String  := "default";
                  Expire  : Natural := 0;
                  Success : out Boolean)
   is
      use Php.Strings;
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
         Group_2 : constant String := (if Empty (Group)
                                       then "default"
                                       else Group);

         Id : Unbounded_String := +Key;
      begin
         if
           This.Multisite and then
           not Isset (This.Global_Groups, Group_2)
         then
            Id := This.Blog_Prefix & Key;
         end if;

         if This.X_Exists (-Id, Group_2) then
            return;
         end if;

         This.Set (Key, Data, Group_2, Expire, Success => Success);
      end;
   end Add;

   ---------
   -- Set --
   ---------

   procedure Set (This    : in out Wp_Object_Cache;
                  Key     : String;
                  Data    : Multi_Type;
                  Group   : String  := "default";
                  Expire  : Natural := 0;
                  Success : out Boolean)
   is
      use Php.Strings;
      use UStrings;
   begin
      Success := False;

      if not This.Is_Valid_Key (Key) then
         return;
      end if;

      declare
         Group_2 : constant String := (if Empty (Group)
                                       then "default"
                                       else Group);
         Key_2 : Unbounded_String := +Key;
      begin
         if
           This.Multisite and then
           not Isset (This.Global_Groups, Group)
         then
            Key_2 := This.Blog_Prefix & Key;
         end if;

--       if ( is_object( data ) ) then
--          data = clone data;
--       end if;

         Set_2 (This.Cache, Group_2, -Key_2, Value => Data);
         Success := True;
      end;
   end Set;

   ---------
   -- Get --
   ---------

   function Get (This  : in out Wp_Object_Cache;
                 Key   : String;
                 Group : String  := "default";
                 Force : Boolean := False;
                 Found : out Boolean)
                 return Multi_Type
   is
      use Php.Strings;
      use UStrings;
   begin
      Found := False;

      if not This.Is_Valid_Key (Key) then
         return From_Null;
      end if;

      declare
         Group_2 : constant String := (if Empty (Group)
                                       then "default"
                                       else Group);

         Key_2 : Unbounded_String := +Key;
      begin
         if
           This.Multisite and then
           not Isset (This.Global_Groups, Group)
         then
            Key_2 := This.Blog_Prefix & Key;
         end if;

         if This.X_Exists (-Key_2, Group_2) then
            Found           := True;
            This.Cache_Hits := This.Cache_Hits + 1;
--          if ( is_object( this->cache[ group ][ key ] ) ) then
--             return clone this->cache[ group ][ key ];
--          else
            return Get (Ref_2 (This.Cache, Group_2, -Key_2));
--          end if;
         end if;

         Found             := False;
         This.Cache_Misses := This.Cache_Misses + 1;
         return From_Null;
      end;
   end Get;

   ------------
   -- Delete --
   ------------

   procedure Delete (This       : in out Wp_Object_Cache;
                     Key        : String;
                     Group      : String := "default";
                     Deprecated : Boolean := False;
                     Done       : out Boolean)
   is
      use Php.Strings;
      use UStrings;

      Key_2   : Unbounded_String := +Key;
      Group_2 : Unbounded_String := +Group;
   begin
      if not This.Is_Valid_Key (Key) then
         Done := False;
         return;
      end if;

      if Empty (Group) then
         Group_2 := +"default";
      else
         Group_2 := +Group;
      end if;

      if
        This.Multisite and then
        not Isset (This.Global_Groups, Group)
      then
         Key_2 := This.Blog_Prefix & Key;
      else
         Key_2 := +Key;
      end if;

      if not This.X_Exists (-Key_2, -Group_2) then
         Done := False;
         return;
      end if;

      Delete (Ref_2 (This.Cache, -Group_2, -Key_2));
      Done := True;
   end Delete;

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
