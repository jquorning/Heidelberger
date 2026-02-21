--
--
--

package Php.Calendar
is

   type Time_Type is new Integer;

   type Date_Time_Zone is private;

   Null_Date_Time_Zone : constant Date_Time_Zone;

   function X_Construct (Timezone : String)
                         return Date_Time_Zone;

   type Date_Time is tagged private;

   function X_Construct (Datetime : String := "now";
                         Timezone : Date_Time_Zone := Null_Date_Time_Zone)
                         return Date_Time;

   function Get_Timestamp (Datetime : Date_Time)
                           return Time_Type;

   function Get_Offset (Datetime : Date_Time)
                        return Time_Type;

   function Set_Time_Zone (Datetime : Date_Time;
                           Timezone : Date_Time_Zone)
                           return Date_Time;

   function Format (Datetime : Date_Time;
                    Format   : String)
                    return String;

   type Date_Time_Immutable is tagged private;

   function X_Construct (Datetime : String := "now";
                         Timezone : Date_Time_Zone := Null_Date_Time_Zone)
                         return Date_Time_Immutable;

   function Get_Timestamp (Datetime : Date_Time_Immutable)
                           return Time_Type;

   function Get_Offset (Datetime : Date_Time_Immutable)
                        return Time_Type;

   function Format (Datetime : Date_Time_Immutable;
                    Format   : String)
                    return String;

   function Modify (Datetime : Date_Time_Immutable;
                    Modifier : String)
                    return Date_Time_Immutable;

   function Set_Time_Zone (Datetime : Date_Time_Immutable;
                           Timezone : Date_Time_Zone)
                           return Date_Time_Immutable;

   function "=" (Left  : Boolean;
                 Right : Date_Time_Immutable)
                 return Boolean;

   function Date_Create_Immutable_From_Format (Format   : String;
                                               Datetime : String; -- Date_Time;
                                               Timezone : Date_Time_Zone)
                                               return Date_Time_Immutable;

private

   type Date_Time is tagged null record;
   type Date_Time_Zone is null record;

   Null_Date_Time_Zone : constant Date_Time_Zone := (null record);

   type Date_Time_Immutable is tagged null record;

end Php.Calendar;
