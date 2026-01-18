--
--
--

package body Php.Calendar
is

   --------------------
   -- Date_Time_Zone --
   --------------------

   function X_Construct (Timezone : String)
                         return Date_Time_Zone
   is (raise Program_Error with "not implemented");

   ---------------
   -- Date_Time --
   ---------------

   function X_Construct (Datetime : String := "now")
                         return Date_Time
   is (raise Program_Error with "not implemented");

   function Get_Timestamp (Datetime : Date_Time)
                           return Time_Type
   is (raise Program_Error with "not implemented");

   function Get_Offset (Datetime : Date_Time)
                        return Time_Type
   is (raise Program_Error with "not implemented");

   function Set_Time_Zone (Datetime : Date_Time;
                           Timezone : Date_Time_Zone)
                           return Date_Time
   is (raise Program_Error with "not implemented");

   function Format (Datetime : Date_Time;
                    Format   : String)
                    return String
   is (raise Program_Error with "not implemented");

   -------------------------
   -- Date_Time_Immutable --
   -------------------------

   function Get_Timestamp (Datetime : Date_Time_Immutable)
                           return Time_Type
   is (raise Program_Error with "not implemented");

   function Get_Offset (Datetime : Date_Time_Immutable)
                        return Time_Type
   is (raise Program_Error with "not implemented");

   function Format (Datetime : Date_Time_Immutable;
                    Format   : String)
                    return String
   is (raise Program_Error with "not implemented");

   function Set_Time_Zone (Datetime : Date_Time_Immutable;
                           Timezone : Date_Time_Zone)
                           return Date_Time_Immutable
   is (raise Program_Error with "not implemented");

   function "=" (Left  : Boolean;
                 Right : Date_Time_Immutable)
                 return Boolean
   is (raise Program_Error with "not implemented");

   function Date_Create_Immutable_From_Format (Format   : String;
                                               Datetime : String; -- Date_Time;
                                               Timezone : Date_Time_Zone)
                                               return Date_Time_Immutable
   is (raise Program_Error with "not implemented");

end Php.Calendar;
