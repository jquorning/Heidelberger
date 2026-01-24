--
-- WordPress Error API.
--
-- @package WordPress
--

with Php.Arrays;
with Php.Strings;

with Hb_Common;

with Inc_Plugins;

package body Inc_Class_Wp_Errors
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Code    : String := "";
                         Message : String := "";
                         Data    : String := "")
                         return Wp_Error
   is
      use Php.Strings;

      This : Wp_Error;
   begin
      if Empty (Code) then
         return Null_Wp_Error;
      end if;

      This.Add (Code, Message, Data);
      return This;
   end X_Construct;

   ---------------------
   -- Get_Error_Codes --
   ---------------------

   function Get_Error_Codes (This : Wp_Error)
                             return List_Type
   is
      use Php;
      use Php.Arrays;
   begin
      if not This.Has_Errors then
         return Empty_List;
      end if;

      return Array_Keys (This.Errors);
   end Get_Error_Codes;

   --------------------
   -- Get_Error_Code --
   --------------------

   function Get_Error_Code (This : Wp_Error)
                            return String
   is
      use Hb_Common;

      Codes : constant List_Type := This.Get_Error_Codes;
   begin
      if Codes.Is_Empty then
         return "";
      end if;

      return -Codes.First_Element;
   end Get_Error_Code;

   -----------------------
   -- Get_Error_Message --
   -----------------------

   function Get_Error_Messages (This : Wp_Error;
                                Code : String := "")
                                return List_Type
   is
      use Php.Strings;
      use Hb_Common;
   begin
      -- Return all messages if no code specified.
      if Empty (Code) then
         declare
            All_Messages : List_Type;
         begin
            for A in This.Errors.Iterate loop -- (array)
               declare
--                Code    : constant String := Key (A);
                  Message : constant String := As_String (Element (A));
               begin
                  All_Messages.Append (+Message);
--                All_Messages := array_merge( all_messages, messages );
               end;
            end loop;

            return All_Messages;
         end;
      end if;

      if Isset (This.Errors, Code) then
         declare
            Message : constant String := Get_As_String (This.Errors, Code);
         begin
            return To_List (Message);
         end;
      else
         return Empty_List;
      end if;
   end Get_Error_Messages;

   --------------------
   -- Get_Error_Data --
   --------------------

   function Get_Error_Data (This : Wp_Error;
                            Code : String := "")
                            return String
   is
      use Php.Strings;

      Code_2 : constant String :=
        (if Empty (Code)
         then This.Get_Error_Code
         else Code);
   begin
      if Isset (This.Error_Data, Code_2) then
         return Get_As_String (This.Error_Data, Code_2);
      end if;
      return "";
   end Get_Error_Data;

   ----------------
   -- Has_Errors --
   ----------------

   function Has_Errors (This : Wp_Error)
                        return Boolean
   is
   begin
      if not This.Errors.Is_Empty then
         return True;
      end if;
      return False;
   end Has_Errors;

   ---------
   -- Add --
   ---------

   procedure Add (This    : in out Wp_Error;
                  Code    : String;
                  Message : String;
                  Data    : String := "")
   is
      use Php.Strings;
      use Inc_Plugins;
   begin
      Set (This.Errors, Code, From_String (Message));
--    This.Errors [ code ][] := Message;

      if not Empty (Data) then
         This.Add_Data (Data, Code);
      end if;

      --
      -- Fires when an error is added to a WP_Error object.
      --
      -- @since 5.6.0
      --
      -- @param string|int code     Error code.
      -- @param string     message  Error message.
      -- @param mixed      data     Error data. Might be empty.
      -- @param WP_Error   wp_error The WP_Error object.
      --
      Do_Action ("wp_error_added", Code, Message, Data, This);
   end Add;

   --------------
   -- Add_Data --
   --------------

   procedure Add_Data (This : in out Wp_Error;
                       Data : String;
                       Code : String := "")
   is
      use Php.Strings;

      Code_2 : constant String := (if Empty (Code)
                                   then This.Get_Error_Code -- ();
                                   else Code);
   begin
      if Isset (This.Error_Data, Code_2) then
         Append (This.Additional_Data,
                 Key   => Code_2,
                 Value => Get (This.Error_Data, Code_2));
--       This.Additional_Data [ code ][] := Get (This.Error_Data, Code);
      end if;

      Set (This.Error_Data, Code_2, From_String (Data));
   end Add_Data;

end Inc_Class_Wp_Errors;
