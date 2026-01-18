--
-- Main WordPress API
--
-- @package WordPress
--

with Ada.Containers;
with Ada.Strings.Unbounded;
with Ada.Text_IO;

with Php.Arrays;
with Php.Echoing;
with Php.Errors;
with Php.Files;
with Php.HTML;
with Php.Ini;
with Php.JSON;
with Php.Lists;
with Php.Misc;
with Php.Multibyte;
with Php.Numerics;
with Php.Preg;
with Php.Strings;
with Php.Types;

with Binder;
with Globals;
with Hb_Common;
with Helpers;
with Wp_Common;

with Inc_Caches;
with Inc_Capabilities;
with Inc_Class_Wpdb;
with Inc_Class_Wp_List_Util;
with Inc_Class_Wp_Networks;
with Inc_Formatting;
with Inc_General_Templates;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Ms_Networks;
with Inc_Options;
with Inc_Plugins;
with Inc_Pluggables;

package body Inc_Functions
is
   use Ada.Strings.Unbounded;

--
-- Converts given MySQL date string into a different format.
--
--  - `format` should be a PHP date format string.
--  - "U" and "G" formats will return an integer sum of timestamp with timezone offset.
--  - `date` is expected to be local time in MySQL format (`Y-m-d H:i:s`).
--
-- Historically UTC time could be passed to the function to produce Unix timestamp.
--
-- If `translate` is true then the given date and format string will
-- be passed to `wp_date()` for translation.
--
-- @since 0.71
--
-- @param string format    Format of the date to return.
-- @param string date      Date string to convert.
-- @param bool   translate Whether the return date should be translated. Default true.
-- @return string|int|false Integer if `format` is "U" or "G", string otherwise.
--                          False on failure.
--
-- function mysql2date( format, date, translate = true ) then
--         if ( empty( date ) ) then
--                 return false;
--         end;

--         datetime = date_create( date, wp_timezone() );

--         if ( false === datetime ) then
--                 return false;
--         end;

--         // Returns a sum of timestamp with timezone offset. Ideally should never be used.
--         if ( "G" === format || "U" === format ) then
--                 return datetime->getTimestamp() + datetime->getOffset();
--         end;

--         if ( translate ) then
--                 return wp_date( format, datetime->getTimestamp() );
--         end;

--         return datetime->format( format );
-- end;

--
-- Retrieves the current time based on specified type.
--
--  - The "mysql" type will return the time in the format for MySQL DATETIME field.
--  - The "timestamp" or "U" types will return the current timestamp or a sum of timestamp
--    and timezone offset, depending on `gmt`.
--  - Other strings will be interpreted as PHP date formats (e.g. "Y-m-d").
--
-- If `gmt` is a truthy value then both types will use GMT time, otherwise the
-- output is adjusted with the GMT offset for the site.
--
-- @since 1.0.0
-- @since 5.3.0 Now returns an integer if `type` is "U". Previously a string was returned.
--
-- @param string   type Type of time to retrieve. Accepts "mysql", "timestamp", "U",
--                       or PHP date format string (e.g. "Y-m-d").
-- @param int|bool gmt  Optional. Whether to use GMT timezone. Default false.
-- @return int|string Integer if `type` is "timestamp" or "U", string otherwise.
--
-- function current_time( type, gmt = 0 ) then
--         // Don"t use non-GMT timestamp, unless you know the difference and really need to.
--         if ( "timestamp" === type || "U" === type ) then
--                 return gmt ? time() : time() + (int) ( get_option( "gmt_offset" )-- HOUR_IN_SECONDS );
--         end;

--         if ( "mysql" === type ) then
--                 type = "Y-m-d H:i:s";
--         end;

--         timezone = gmt ? new DateTimeZone( "UTC" ) : wp_timezone();
--         datetime = new DateTime( "now", timezone );

--         return datetime->format( type );
-- end;

--
-- Retrieves the current time as an object using the site"s timezone.
--
-- @since 5.3.0
--
-- @return DateTimeImmutable Date and time object.
--
-- function current_datetime() then
--         return new DateTimeImmutable( "now", wp_timezone() );
-- end;

   ------------------------
   -- Wp_Timezone_String --
   ------------------------

   function Wp_Timezone_String
            return String
   is
   begin
      raise Program_Error with "not implemented";
      return "";
   end Wp_Timezone_String;
--         timezone_string = get_option( "timezone_string" );

--         if ( timezone_string ) then
--                 return timezone_string;
--         end;

--         offset  = (float) get_option( "gmt_offset" );
--         hours   = (int) offset;
--         minutes = ( offset - hours );

--         sign      = ( offset < 0 ) ? "-" : "+";
--         abs_hour  = abs( hours );
--         abs_mins  = abs( minutes-- 60 );
--         tz_offset = sprintf( "%s%02d:%02d", sign, abs_hour, abs_mins );

--         return tz_offset;
-- end;

   -----------------
   -- Wp_Timezone --
   -----------------

   function Wp_Timezone
            return Php.Calendar.Date_Time_Zone
   is
      use Php.Calendar;
   begin
      return X_Construct (Wp_Timezone_String);
--    return new DateTimeZone( wp_timezone_string() );
   end Wp_Timezone;

--
-- Retrieves the date in localized format, based on a sum of Unix timestamp and
-- timezone offset in seconds.
--
-- If the locale specifies the locale month and weekday, then the locale will
-- take over the format for the date. If it isn"t, then the date format string
-- will be used instead.
--
-- Note that due to the way WP typically generates a sum of timestamp and offset
-- with `strtotime()`, it implies offset added at a _current_ time, not at the time
-- the timestamp represents. Storing such timestamps or calculating them differently
-- will lead to invalid output.
--
-- @since 0.71
-- @since 5.3.0 Converted into a wrapper for wp_date().
--
-- @global WP_Locale wp_locale WordPress date and time locale object.
--
-- @param string   format                Format to display the date.
-- @param int|bool timestamp_with_offset Optional. A sum of Unix timestamp and timezone offset
--                                        in seconds. Default false.
-- @param bool     gmt                   Optional. Whether to use GMT timezone. Only applies
--                                        if timestamp is not provided. Default false.
-- @return string The date, translated if locale specifies it.
--
-- function date_i18n( format, timestamp_with_offset = false, gmt = false ) then
--         timestamp = timestamp_with_offset;

--         // If timestamp is omitted it should be current time (summed with offset, unless `gmt` is true).
--         if ( ! is_numeric( timestamp ) ) then
--                 // phpcs:ignore WordPress.DateTime.CurrentTimeTimestamp.Requested
--                 timestamp = current_time( "timestamp", gmt );
--         end;

--         /*
--         -- This is a legacy implementation quirk that the returned timestamp is also with offset.
--         -- Ideally this function should never be used to produce a timestamp.
--         --
--         if ( "U" === format ) then
--                 date = timestamp;
--         end; elseif ( gmt && false === timestamp_with_offset ) then // Current time in UTC.
--                 date = wp_date( format, null, new DateTimeZone( "UTC" ) );
--         end; elseif ( false === timestamp_with_offset ) then // Current time in site"s timezone.
--                 date = wp_date( format );
--         end; else then
--                 /*
--                 -- Timestamp with offset is typically produced by a UTC `strtotime()` call on an input without timezone.
--                 -- This is the best attempt to reverse that operation into a local time to use.
--                 --
--                 local_time = gmdate( "Y-m-d H:i:s", timestamp );
--                 timezone   = wp_timezone();
--                 datetime   = date_create( local_time, timezone );
--                 date       = wp_date( format, datetime->getTimestamp(), timezone );
--         end;

--         --
--         -- Filters the date formatted based on the locale.
--         --
--         -- @since 2.8.0
--         --
--         -- @param string date      Formatted date string.
--         -- @param string format    Format to display the date.
--         -- @param int    timestamp A sum of Unix timestamp and timezone offset in seconds.
--         --                          Might be without offset if input omitted timestamp but requested GMT.
--         -- @param bool   gmt       Whether to use GMT timezone. Only applies if timestamp was not provided.
--         --                          Default false.
--         --
--         date = apply_filters( "date_i18n", date, format, timestamp, gmt );

--         return date;
-- end;

   -------------
   -- Wp_Date --
   -------------

   function Wp_Date (Format    : String;
                     Timestamp : Php.Calendar.Time_Type; -- null
                     Timezone  : Php.Calendar.Date_Time_Zone) -- = null
                     return String
   is
   begin
      raise Program_Error with "not implemented";
      return "";
   end Wp_Date;

--         global wp_locale;

--         if ( null === timestamp ) then
--                 timestamp = time();
--         end; elseif ( ! is_numeric( timestamp ) ) then
--                 return false;
--         end;

--         if ( ! timezone ) then
--                 timezone = wp_timezone();
--         end;

--         datetime = date_create( "@" . timestamp );
--         datetime->setTimezone( timezone );

--         if ( empty( wp_locale->month ) || empty( wp_locale->weekday ) ) then
--                 date = datetime->format( format );
--         end; else then
--                 // We need to unpack shorthand `r` format because it has parts that might be localized.
--                 format = preg_replace( "/(?<!\\\\)r/", DATE_RFC2822, format );

--                 new_format    = "";
--                 format_length = strlen( format );
--                 month         = wp_locale->get_month( datetime->format( "m" ) );
--                 weekday       = wp_locale->get_weekday( datetime->format( "w" ) );

--                 for ( i = 0; i < format_length; i ++ ) then
--                         switch ( format[ i ] ) then
--                                 case "D":
--                                         new_format .= addcslashes( wp_locale->get_weekday_abbrev( weekday ), "\\A..Za..z" );
--                                         break;
--                                 case "F":
--                                         new_format .= addcslashes( month, "\\A..Za..z" );
--                                         break;
--                                 case "l":
--                                         new_format .= addcslashes( weekday, "\\A..Za..z" );
--                                         break;
--                                 case "M":
--                                         new_format .= addcslashes( wp_locale->get_month_abbrev( month ), "\\A..Za..z" );
--                                         break;
--                                 case "a":
--                                         new_format .= addcslashes( wp_locale->get_meridiem( datetime->format( "a" ) ), "\\A..Za..z" );
--                                         break;
--                                 case "A":
--                                         new_format .= addcslashes( wp_locale->get_meridiem( datetime->format( "A" ) ), "\\A..Za..z" );
--                                         break;
--                                 case "\\":
--                                         new_format .= format[ i ];

--                                         // If character follows a slash, we add it without translating.
--                                         if ( i < format_length ) then
--                                                 new_format .= format[ ++i ];
--                                         end;
--                                         break;
--                                 default:
--                                         new_format .= format[ i ];
--                                         break;
--                         end;
--                 end;

--                 date = datetime->format( new_format );
--                 date = wp_maybe_decline_date( date, format );
--         end;

--         --
--         -- Filters the date formatted based on the locale.
--         --
--         -- @since 5.3.0
--         --
--         -- @param string       date      Formatted date string.
--         -- @param string       format    Format to display the date.
--         -- @param int          timestamp Unix timestamp.
--         -- @param DateTimeZone timezone  Timezone.
--         --
--         date = apply_filters( "wp_date", date, format, timestamp, timezone );

--         return date;
-- end;

--
-- Determines if the date should be declined.
--
-- If the locale specifies that month names require a genitive case in certain
-- formats (like "j F Y"), the month name will be replaced with a correct form.
--
-- @since 4.4.0
-- @since 5.4.0 The `format` parameter was added.
--
-- @global WP_Locale wp_locale WordPress date and time locale object.
--
-- @param string date   Formatted date string.
-- @param string format Optional. Date format to check. Default empty string.
-- @return string The date, declined if locale specifies it.
--
-- function wp_maybe_decline_date( date, format = "" ) then
--         global wp_locale;

--         // i18n functions are not available in SHORTINIT mode.
--         if ( ! function_exists( "_x" ) ) then
--                 return date;
--         end;

--         /*
--         -- translators: If months in your language require a genitive case,
--         -- translate this to "on". Do not translate into your own language.
--         --
--         if ( "on" === _x( "off", "decline months names: on or off" ) ) then

--                 months          = wp_locale->month;
--                 months_genitive = wp_locale->month_genitive;

--                 /*
--                 -- Match a format like "j F Y" or "j. F" (day of the month, followed by month name)
--                 -- and decline the month.
--                 --
--                 if ( format ) then
--                         decline = preg_match( "#[dj]\.? F#", format );
--                 end; else then
--                         // If the format is not passed, try to guess it from the date string.
--                         decline = preg_match( "#\b\dthen1,2end;\.? [^\d ]+\b#u", date );
--                 end;

--                 if ( decline ) then
--                         foreach ( months as key => month ) then
--                                 months[ key ] = "# " . preg_quote( month, "#" ) . "\b#u";
--                         end;

--                         foreach ( months_genitive as key => month ) then
--                                 months_genitive[ key ] = " " . month;
--                         end;

--                         date = preg_replace( months, months_genitive, date );
--                 end;

--                 /*
--                 -- Match a format like "F jS" or "F j" (month name, followed by day with an optional ordinal suffix)
--                 -- and change it to declined "j F".
--                 --
--                 if ( format ) then
--                         decline = preg_match( "#F [dj]#", format );
--                 end; else then
--                         // If the format is not passed, try to guess it from the date string.
--                         decline = preg_match( "#\b[^\d ]+ \dthen1,2end;(st|nd|rd|th)?\b#u", trim( date ) );
--                 end;

--                 if ( decline ) then
--                         foreach ( months as key => month ) then
--                                 months[ key ] = "#\b" . preg_quote( month, "#" ) . " (\dthen1,2end;)(st|nd|rd|th)?([-–]\dthen1,2end;)?(st|nd|rd|th)?\b#u";
--                         end;

--                         foreach ( months_genitive as key => month ) then
--                                 months_genitive[ key ] = "13 " . month;
--                         end;

--                         date = preg_replace( months, months_genitive, date );
--                 end;
--         end;

--         // Used for locale-specific rules.
--         locale = get_locale();

--         if ( "ca" === locale ) then
--                 // " de abril| de agost| de octubre..." -> " d"abril| d"agost| d"octubre..."
--                 date = preg_replace( "# de ([ao])#i", " d"\\1", date );
--         end;

--         return date;
-- end;

   ------------------------
   -- Number_Format_I18n --
   ------------------------

   function Number_Format_I18n (Number   : Float;
                                Decimals : Integer := 0)
                                return String
   is
      use Php.Numerics;
      use Wp_Common;
--    use Inc_Plugins;
--    global wp_locale;

      Formatted : constant String :=
        (if True -- Isset (Globals.Wp_Locale)
         then Number_Format
                (Number, abs Decimals,
                 Get_As_String (Globals.Wp_Locale.Number_Format, "decimal_point"),
                 Get_As_String (Globals.Wp_Locale.Number_Format, "thousands_sep"))
         else Number_Format (Number, abs Decimals));
   begin
      --
      -- Filters the number formatted based on the locale.
      --
      -- @since 2.8.0
      -- @since 4.9.0 The `number` and `decimals` parameters were added.
      --
      -- @param string formatted Converted number in string format.
      -- @param float  number    The number to convert based on locale.
      -- @param int    decimals  Precision of the number of decimal places.
      --
      return Apply_Filters ("number_format_i18n", Formatted, Number, Decimals);
   end Number_Format_I18n;

--
-- Converts a number of bytes to the largest unit the bytes will fit into.
--
-- It is easier to read 1 KB than 1024 bytes and 1 MB than 1048576 bytes. Converts
-- number of bytes to human readable number by taking the number of that unit
-- that the bytes will go into it. Supports YB value.
--
-- Please note that integers in PHP are limited to 32 bits, unless they are on
-- 64 bit architecture, then they have 64 bit size. If you need to place the
-- larger size then what PHP integer type will hold, then use a string. It will
-- be converted to a double, which should always have 64 bit length.
--
-- Technically the correct unit names for powers of 1024 are KiB, MiB etc.
--
-- @since 2.3.0
-- @since 6.0.0 Support for PB, EB, ZB, and YB was added.
--
-- @param int|string bytes    Number of bytes. Note max integer size for integers.
-- @param int        decimals Optional. Precision of number of decimal places. Default 0.
-- @return string|false Number string on success, false on failure.
--
-- function size_format( bytes, decimals = 0 ) then
--         quant = array(
--                 /* translators: Unit symbol for yottabyte.--
--                 _x( "YB", "unit symbol" ) => YB_IN_BYTES,
--                 /* translators: Unit symbol for zettabyte.--
--                 _x( "ZB", "unit symbol" ) => ZB_IN_BYTES,
--                 /* translators: Unit symbol for exabyte.--
--                 _x( "EB", "unit symbol" ) => EB_IN_BYTES,
--                 /* translators: Unit symbol for petabyte.--
--                 _x( "PB", "unit symbol" ) => PB_IN_BYTES,
--                 /* translators: Unit symbol for terabyte.--
--                 _x( "TB", "unit symbol" ) => TB_IN_BYTES,
--                 /* translators: Unit symbol for gigabyte.--
--                 _x( "GB", "unit symbol" ) => GB_IN_BYTES,
--                 /* translators: Unit symbol for megabyte.--
--                 _x( "MB", "unit symbol" ) => MB_IN_BYTES,
--                 /* translators: Unit symbol for kilobyte.--
--                 _x( "KB", "unit symbol" ) => KB_IN_BYTES,
--                 /* translators: Unit symbol for byte.--
--                 _x( "B", "unit symbol" )  => 1,
--         );

--         if ( 0 === bytes ) then
--                 /* translators: Unit symbol for byte.--
--                 return number_format_i18n( 0, decimals ) . " " . _x( "B", "unit symbol" );
--         end;

--         foreach ( quant as unit => mag ) then
--                 if ( (float) bytes >= mag ) then
--                         return number_format_i18n( bytes / mag, decimals ) . " " . unit;
--                 end;
--         end;

--         return false;
-- end;

--
-- Converts a duration to human readable format.
--
-- @since 5.1.0
--
-- @param string duration Duration will be in string format (HH:ii:ss) OR (ii:ss),
--                         with a possible prepended negative sign (-).
-- @return string|false A human readable duration string, false on failure.
--
-- function human_readable_duration( duration = "" ) then
--         if ( ( empty( duration ) || ! is_string( duration ) ) ) then
--                 return false;
--         end;

--         duration = trim( duration );

--         // Remove prepended negative sign.
--         if ( "-" === substr( duration, 0, 1 ) ) then
--                 duration = substr( duration, 1 );
--         end;

--         // Extract duration parts.
--         duration_parts = array_reverse( explode( ":", duration ) );
--         duration_count = count( duration_parts );

--         hour   = null;
--         minute = null;
--         second = null;

--         if ( 3 === duration_count ) then
--                 // Validate HH:ii:ss duration format.
--                 if ( ! ( (bool) preg_match( "/^([0-9]+):([0-5]?[0-9]):([0-5]?[0-9])/", duration ) ) ) then
--                         return false;
--                 end;
--                 // Three parts: hours, minutes & seconds.
--                 list( second, minute, hour ) = duration_parts;
--         end; elseif ( 2 === duration_count ) then
--                 // Validate ii:ss duration format.
--                 if ( ! ( (bool) preg_match( "/^([0-5]?[0-9]):([0-5]?[0-9])/", duration ) ) ) then
--                         return false;
--                 end;
--                 // Two parts: minutes & seconds.
--                 list( second, minute ) = duration_parts;
--         end; else then
--                 return false;
--         end;

--         human_readable_duration = array();

--         // Add the hour part to the string.
--         if ( is_numeric( hour ) ) then
--                 /* translators: %s: Time duration in hour or hours.--
--                 human_readable_duration[] = sprintf( _n( "%s hour", "%s hours", hour ), (int) hour );
--         end;

--         // Add the minute part to the string.
--         if ( is_numeric( minute ) ) then
--                 /* translators: %s: Time duration in minute or minutes.--
--                 human_readable_duration[] = sprintf( _n( "%s minute", "%s minutes", minute ), (int) minute );
--         end;

--         // Add the second part to the string.
--         if ( is_numeric( second ) ) then
--                 /* translators: %s: Time duration in second or seconds.--
--                 human_readable_duration[] = sprintf( _n( "%s second", "%s seconds", second ), (int) second );
--         end;

--         return implode( ", ", human_readable_duration );
-- end;

--
-- Gets the week start and end from the datetime or date string from MySQL.
--
-- @since 0.71
--
-- @param string     mysqlstring   Date or datetime field type from MySQL.
-- @param int|string start_of_week Optional. Start of the week as an integer. Default empty string.
-- @return int[] then
--     Week start and end dates as Unix timestamps.
--
--     @type int start The week start date as a Unix timestamp.
--     @type int end   The week end date as a Unix timestamp.
-- end;
--
-- function get_weekstartend( mysqlstring, start_of_week = "" ) then
--         // MySQL string year.
--         my = substr( mysqlstring, 0, 4 );

--         // MySQL string month.
--         mm = substr( mysqlstring, 8, 2 );

--         // MySQL string day.
--         md = substr( mysqlstring, 5, 2 );

--         // The timestamp for MySQL string day.
--         day = mktime( 0, 0, 0, md, mm, my );

--         // The day of the week from the timestamp.
--         weekday = gmdate( "w", day );

--         if ( ! is_numeric( start_of_week ) ) then
--                 start_of_week = get_option( "start_of_week" );
--         end;

--         if ( weekday < start_of_week ) then
--                 weekday += 7;
--         end;

--         // The most recent week start day on or before day.
--         start = day - DAY_IN_SECONDS-- ( weekday - start_of_week );

--         // start + 1 week - 1 second.
--         end = start + WEEK_IN_SECONDS - 1;
--         return compact( "start", "end" );
-- end;

   ---------------------
   -- Maybe_Serialize --
   ---------------------

   function Maybe_Serialize (Data : String)
                             return Multi_Type
   is
      use Php.JSON;
   begin
      -- if Is_Array (Data) or else Is_Object (Data) then
      --    return Serialize (Data);
      -- end if;

      --
      -- Double serialization is required for backward compatibility.
      -- See https://core.trac.wordpress.org/ticket/12930
      -- Also the world will end. See WP 3.6.1.
      --
      if Is_Serialized (Data, False) then
         return From_String (Serialize (From_String (Data)));
      end if;

      return From_String (Data);
   end Maybe_Serialize;

   -----------------------
   -- Maybe_Unserialize --
   -----------------------

   function Maybe_Unserialize (Data : String)
                               return Multi_Type
   is
      use Php.JSON;
      use Php.Strings;
   begin
      -- Don't attempt to unserialize data that wasn't serialized going in.
      if Is_Serialized (Data) then
         return Unserialize (Trim (Data)); -- @
      end if;

      return From_String (Data);
   end Maybe_Unserialize;

   -------------------
   -- Is_Serialized --
   -------------------

   function Is_Serialized (Data   : String;
                           Strict : Boolean := True)
                           return Boolean
   is
      use Php.Preg;
      use Php.Strings;
      use Php.Types;
   begin
      -- If it isn't a string, it isn't serialized.
      if not Is_String (Data) then
         return False;
      end if;

--    data := trim (data);
      if "N;" = Data then
         return True;
      end if;

      if Strlen (Data) < 4 then
         return False;
      end if;

      if ':' /= Data (Data'First + 1) then -- (2) ?
         return False;
      end if;

      if Strict then
         declare
            Last_C : constant String := Substr (Data, -1);
         begin
            if ";" /= Last_C and then "}" /= Last_C then
               return False;
            end if;
         end;
      else
         declare
            Semicolon : constant Natural := Strpos (Data, ";");
            Brace     : constant Natural := Strpos (Data, "}");
         begin
            -- Either ; or end; must exist.
            if 0 = Semicolon and then 0 = Brace then -- 2x false
               return False;
            end if;

            -- But neither must be in the first X characters.
            if 0 /= Semicolon and then Semicolon < 3 then
               return False;
            end if;

            if 0 /= Brace and Brace < 4 then
               return False;
            end if;
         end;
      end if;

      declare
         type S_Result is (Fail, Pass);

         function When_S return S_Result;

         function When_S return S_Result is
         begin
            if Strict then
               if """" /= Substr (Data, -2, 1) then
                  return Fail;
               end if;
            elsif 0 = Strpos (Data, """") then
               return Fail;
            end if;
            return Pass;
         end When_S;

         Token : constant Character := Data (Data'First); -- [0];
      begin
         case Token is

         when 's' =>
            if When_S = Fail then
               return False;
            end if;                              -- Or else fall through.
            return Preg_Match ("/^" & Token & ":[0-9]+:/s", Data);

         when 'a' | 'O' | 'E' =>
            return Preg_Match ("/^" & Token & ":[0-9]+:/s", Data);

         when 'b' | 'i' | 'd' =>
            declare
               Endd : String := (if Strict then "" else "");
            begin
               return
                 Preg_Match ("/^" & Token & ":[0-9.E+-]+;" & Endd & "/", Data);
            end;

         when others => null;
         end case;
      end;
      return False;
   end Is_Serialized;

--
-- Checks whether serialized data is of string type.
--
-- @since 2.0.5
--
-- @param string data Serialized data.
-- @return bool False if not a serialized string, true if it is.
--
-- function is_serialized_string( data ) then
--         // if it isn"t a string, it isn"t a serialized string.
--         if ( ! is_string( data ) ) then
--                 return false;
--         end;
--         data = trim( data );
--         if ( strlen( data ) < 4 ) then
--                 return false;
--         end; elseif ( ":" !== data[1] ) then
--                 return false;
--         end; elseif ( ";" !== substr( data, -1 ) ) then
--                 return false;
--         end; elseif ( "s" !== data[0] ) then
--                 return false;
--         end; elseif ( """ !== substr( data, -2, 1 ) ) then
--                 return false;
--         end; else then
--                 return true;
--         end;
-- end;

--
-- Retrieves post title from XMLRPC XML.
--
-- If the title element is not part of the XML, then the default post title from
-- the post_default_title will be used instead.
--
-- @since 0.71
--
-- @global string post_default_title Default XML-RPC post title.
--
-- @param string content XMLRPC XML Request content
-- @return string Post title
--
-- function xmlrpc_getposttitle( content ) then
--         global post_default_title;
--         if ( preg_match( "/<title>(.+?)<\/title>/is", content, matchtitle ) ) then
--                 post_title = matchtitle[1];
--         end; else then
--                 post_title = post_default_title;
--         end;
--         return post_title;
-- end;

--
-- Retrieves the post category or categories from XMLRPC XML.
--
-- If the category element is not found, then the default post category will be
-- used. The return type then would be what post_default_category. If the
-- category is found, then it will always be an array.
--
-- @since 0.71
--
-- @global string post_default_category Default XML-RPC post category.
--
-- @param string content XMLRPC XML Request content
-- @return string|array List of categories or category name.
--
-- function xmlrpc_getpostcategory( content ) then
--         global post_default_category;
--         if ( preg_match( "/<category>(.+?)<\/category>/is", content, matchcat ) ) then
--                 post_category = trim( matchcat[1], "," );
--                 post_category = explode( ",", post_category );
--         end; else then
--                 post_category = post_default_category;
--         end;
--         return post_category;
-- end;

--
-- XMLRPC XML content without title and category elements.
--
-- @since 0.71
--
-- @param string content XML-RPC XML Request content.
-- @return string XMLRPC XML Request content without title and category elements.
--
-- function xmlrpc_removepostdata( content ) then
--         content = preg_replace( "/<title>(.+?)<\/title>/si", "", content );
--         content = preg_replace( "/<category>(.+?)<\/category>/si", "", content );
--         content = trim( content );
--         return content;
-- end;

--
-- Uses RegEx to extract URLs from arbitrary content.
--
-- @since 3.7.0
-- @since 6.0.0 Fixes support for HTML entities (Trac 30580).
--
-- @param string content Content to extract URLs from.
-- @return string[] Array of URLs found in passed string.
--
-- function wp_extract_urls( content ) then
--         preg_match_all(
--                 "#([\""]?)("
--                         . "(?:([\w-]+:)?//?)"
--                         . "[^\s()<>]+"
--                         . "[.]"
--                         . "(?:"
--                                 . "\([\w\d]+\)|"
--                                 . "(?:"
--                                         . "[^`!()\[\]thenend;:"\".,<>«»“”‘’\s]|"
--                                         . "(?:[:]\d+)?/?"
--                                 . ")+"
--                         . ")"
--                 . ")\\1#",
--                 content,
--                 post_links
--         );

--         post_links = array_unique(
--                 array_map(
--                         static function( link ) then
--                                 // Decode to replace valid entities, like &amp;.
--                                 link = html_entity_decode( link );
--                                 // Maintain backward compatibility by removing extraneous semi-colons (`;`).
--                                 return str_replace( ";", "", link );
--                         end;,
--                         post_links[2]
--                 )
--         );

--         return array_values( post_links );
-- end;

--
-- Checks content for video and audio links to add as enclosures.
--
-- Will not add enclosures that have already been added and will
-- remove enclosures that are no longer in the post. This is called as
-- pingbacks and trackbacks.
--
-- @since 1.5.0
-- @since 5.3.0 The `content` parameter was made optional, and the `post` parameter was
--              updated to accept a post ID or a WP_Post object.
-- @since 5.6.0 The `content` parameter is no longer optional, but passing `null` to skip it
--              is still supported.
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param string|null content Post content. If `null`, the `post_content` field from `post` is used.
-- @param int|WP_Post post    Post ID or post object.
-- @return void|false Void on success, false if the post is not found.
--
-- function do_enclose( content, post ) then
--         global wpdb;

--         // @todo Tidy this code and make the debug code optional.
--         include_once ABSPATH . WPINC . "/class-IXR.php";

--         post = get_post( post );
--         if ( ! post ) then
--                 return false;
--         end;

--         if ( null === content ) then
--                 content = post->post_content;
--         end;

--         post_links = array();

--         pung = get_enclosed( post->ID );

--         post_links_temp = wp_extract_urls( content );

--         foreach ( pung as link_test ) then
--                 // Link is no longer in post.
--                 if ( ! in_array( link_test, post_links_temp, true ) ) then
--                         mids = wpdb->get_col( wpdb->prepare( "SELECT meta_id FROM wpdb->postmeta WHERE post_id = %d AND meta_key = "enclosure" AND meta_value LIKE %s", post->ID, wpdb->esc_like( link_test ) . "%" ) );
--                         foreach ( mids as mid ) then
--                                 delete_metadata_by_mid( "post", mid );
--                         end;
--                 end;
--         end;

--         foreach ( (array) post_links_temp as link_test ) then
--                 // If we haven"t pung it already.
--                 if ( ! in_array( link_test, pung, true ) ) then
--                         test = parse_url( link_test );
--                         if ( false === test ) then
--                                 continue;
--                         end;
--                         if ( isset( test["query"] ) ) then
--                                 post_links[] = link_test;
--                         end; elseif ( isset( test["path"] ) && ( "/" !== test["path"] ) && ( "" !== test["path"] ) ) then
--                                 post_links[] = link_test;
--                         end;
--                 end;
--         end;

--         --
--         -- Filters the list of enclosure links before querying the database.
--         --
--         -- Allows for the addition and/or removal of potential enclosures to save
--         -- to postmeta before checking the database for existing enclosures.
--         --
--         -- @since 4.4.0
--         --
--         -- @param string[] post_links An array of enclosure links.
--         -- @param int      post_ID    Post ID.
--         --
--         post_links = apply_filters( "enclosure_links", post_links, post->ID );

--         foreach ( (array) post_links as url ) then
--                 url = strip_fragment_from_url( url );

--                 if ( "" !== url && ! wpdb->get_var( wpdb->prepare( "SELECT post_id FROM wpdb->postmeta WHERE post_id = %d AND meta_key = "enclosure" AND meta_value LIKE %s", post->ID, wpdb->esc_like( url ) . "%" ) ) ) then

--                         headers = wp_get_http_headers( url );
--                         if ( headers ) then
--                                 len           = isset( headers["content-length"] ) ? (int) headers["content-length"] : 0;
--                                 type          = isset( headers["content-type"] ) ? headers["content-type"] : "";
--                                 allowed_types = array( "video", "audio" );

--                                 // Check to see if we can figure out the mime type from the extension.
--                                 url_parts = parse_url( url );
--                                 if ( false !== url_parts && ! empty( url_parts["path"] ) ) then
--                                         extension = pathinfo( url_parts["path"], PATHINFO_EXTENSION );
--                                         if ( ! empty( extension ) ) then
--                                                 foreach ( wp_get_mime_types() as exts => mime ) then
--                                                         if ( preg_match( "!^(" . exts . ")!i", extension ) ) then
--                                                                 type = mime;
--                                                                 break;
--                                                         end;
--                                                 end;
--                                         end;
--                                 end;

--                                 if ( in_array( substr( type, 0, strpos( type, "/" ) ), allowed_types, true ) ) then
--                                         add_post_meta( post->ID, "enclosure", "url\nlen\nmime\n" );
--                                 end;
--                         end;
--                 end;
--         end;
-- end;

--
-- Retrieves HTTP Headers from URL.
--
-- @since 1.5.1
--
-- @param string url        URL to retrieve HTTP headers from.
-- @param bool   deprecated Not Used.
-- @return \Requests_Utility_CaseInsensitiveDictionary|false Headers on success, false on failure.
--
-- function wp_get_http_headers( url, deprecated = false ) then
--         if ( ! empty( deprecated ) ) then
--                 _deprecated_argument( __FUNCTION__, "2.7.0" );
--         end;

--         response = wp_safe_remote_head( url );

--         if ( is_wp_error( response ) ) then
--                 return false;
--         end;

--         return wp_remote_retrieve_headers( response );
-- end;

--
-- Determines whether the publish date of the current post in the loop is different
-- from the publish date of the previous post in the loop.
--
-- For more information on this and similar theme functions, check out
-- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- Conditional Tags} article in the Theme Developer Handbook.
--
-- @since 0.71
--
-- @global string currentday  The day of the current post in the loop.
-- @global string previousday The day of the previous post in the loop.
--
-- @return int 1 when new day, 0 if not a new day.
--
-- function is_new_day() then
--         global currentday, previousday;

--         if ( currentday !== previousday ) then
--                 return 1;
--         end; else then
--                 return 0;
--         end;
-- end;

   -----------------
   -- Build_Query --
   -----------------

   function Build_Query (Data : Array_Type)
                         return String
   is
   begin
      return X_HTTP_Build_Query (Data, "", "&", "", False); -- First "" was null
   end Build_Query;

   ------------------------
   -- X_HTTP_Build_Query --
   ------------------------

   function X_HTTP_Build_Query (Data      : Array_Type;
                                Prefix    : String := ""; -- null
                                Sep       : String := ""; -- null
                                Key       : String := "";
                                URLencode : Boolean := True)
                                return String
   is
      use Php.Arrays;
      use Php.Ini;
      use Php.Strings;
      use Php.Types;
      use Hb_Common;

      Ret : Array_Type;
   begin
      for A in Data.Iterate loop
         declare
            K   : Unbounded_String    := +Arrays.Key (A);
            V   : constant Multi_Type := Arrays.Element (A);
            V_2 : Unbounded_String    := +As_String (V);
         begin
            if URLencode then
               K := +Php.HTML.URL_Encode (-K);
            end if;

--          if K.Is_Integer and then "" /= Prefix then
            if Is_Numeric (-K) and then "" /= Prefix then
               K := +Prefix & Integer'Value (-K)'Image;
            end if;

            if not Empty (Key) then
               K := +Key & "%5B" & K & "%5D";
            end if;

            if Kind_Of (V) = Kind_Null then
--          if "" = V then
               goto Continue;
            elsif Kind_Of (V) = Kind_Boolean and then As_Boolean (V) = False then
--          elsif false = V then
               V_2 := +"0";
            end if;

            if Kind_Of (V) = Kind_Array then -- (V) or else Is_Object (V) then
--          if Is_Array (V) or else Is_Object (V) then
               Array_Push (Ret, X_HTTP_Build_Query
                  (As_Array (V), "", Sep, -K, URLencode));

            elsif URLencode then
               Array_Push (Ret, -(K & "=" & Php.HTML.URL_Encode (-V_2)));

            else
               Array_Push (Ret, -(K & "=" & (-V_2)));
            end if;
         end;
         << Continue >>
      end loop;

      declare
         Sep_2 : constant String :=
           (if Sep = "" then Ini_Get ("arg_separator.output") else Sep);
      begin
         return Implode (Sep_2, Ret);
      end;
   end X_HTTP_Build_Query;

   -------------------
   -- Add_Query_Arg --
   -------------------

   function Add_Query_Arg (Key   : List_Type;
                           Value : String;
                           URL   : String := "")
                           return String
   is
      use Ada.Text_IO;
      use Php.Preg;
      use Php.Strings;
      use Hb_Common;
      use Inc_Formatting;

      Protocol : Unbounded_String;
      Frag     : Unbounded_String;
      Base     : Unbounded_String;
      Querys   : Array_Type;

        -- if is_array( args[0] ) then
        --         if count( args ) < 2 || false === args[1] then
        --                 uri = _SERVER["REQUEST_URI"];
        --         else
        --                 uri = args[1];
        --         end if;
        -- else
        --         if count( args ) < 3 || false === args[2] then
        --                 uri = _SERVER["REQUEST_URI"];
        --         else
        --                 uri = args[2];
        --         end if;
        -- end if;
      URI   : constant String  := As_String (Get (Binder.X_SERVER, "REQUEST_URI"));
      URI_2 : Unbounded_String := +URI;
   begin
      Put_Line ("add_query_arg: " & URI);

      Frag := +Strstr (URI, "#");
      if Frag = "" then
         URI_2 := +Substr (URI, 0, -Strlen (-Frag));
      else
         Frag := +"";
      end if;

      if 1 = Stripos (-URI_2, "http://") then
         Protocol := +"http://";
         URI_2    := +Substr (-URI_2, 7);

      elsif 1 = Stripos (-URI_2, "https://") then
         Protocol := +"https://";
         URI_2    := +Substr (-URI_2, 8);

      else
         Protocol := +"";
      end if;

      Put_Line ("add_query_arg: " & (-URI_2));

      declare
         URI_3 : constant String := -URI_2;
         Query : Unbounded_String;
      begin
         if Strpos (URI_3, "?") /= 0 then
            declare
               List : constant List_Type := Explode ("?", URI_3, 2);
            begin
               Base  := List (1);
               Query := List (2);
            end;
            Append (Base, "?");

         elsif Protocol /= "" or else Strpos (URI_3, "=") = 0 then
            Base  := +URI_3 & "?";
            Query := +"";

         else
            Base  := +"";
            Query := +URI_3;
         end if;

         Wp_Parse_Str (-Query, Querys);
         Querys := As_Array (URL_Encode_Deep (From_Array (Querys)));
      end;
      -- This re-URL-encodes things that were already in the query string.

      -- if is_array( args[0] ) then
      --    for ( args[0] as k => v ) loop
      --       qs[ k ] = v;
      --    end loop;
      -- else
      --    qs[ args[0] ] = args[1];
      -- end if;

      -- for ( qs as k => v ) loop
      --    if ( false === v ) then
      --       unset( qs[ k ] );
      --    end if;
      -- end loop;

      declare
         Ret_6 : constant String := Build_Query (Querys);
         Ret_5 : constant String := Trim (Ret_6, "?");
         Ret_4 : constant String := Preg_Replace ("#=(&|)#", "$1", Ret_5);
         Ret_3 : constant String := (-Protocol) & (-Base) & Ret_4 & (-Frag);
         Ret_2 : constant String := Rtrim (Ret_3, "?");
         Ret_1 : constant String := Str_Replace ("?#", "#", Ret_2);
      begin
         return Ret_1;
      end;
   end Add_Query_Arg;

   -------------------
   -- Add_Query_Arg --
   -------------------

   function Add_Query_Arg (Key   : String;
                           Value : String;
                           URL   : String := "")
                           return String
   is (Add_Query_Arg (To_List (Key), Value, URL));

   -------------------
   -- Add_Query_Arg --
   -------------------

   function Add_Query_Arg (Key   : Array_Type;
                           Value : String;
                           URL   : String := "")
                           return String
   is
      use Hb_Common;

      Res : Unbounded_String := +URL;
   begin
      for A in Key.Iterate loop
         Res := +Add_Query_Arg (Arrays.Key (A), As_String (Element (A)), -Res);
      end loop;
      return -Res;
   end Add_Query_Arg;

   ----------------------
   -- Remove_Query_Arg --
   ----------------------

   function Remove_Query_Arg (Key   : List_Type;
                              Query : String := "")
                              return String
   is
      use Hb_Common;

      Query_2 : Unbounded_String := +Query;
   begin
      for K of Key loop
         Query_2 := +Add_Query_Arg (-K, "", -Query_2); -- "" was False
      end loop;
      return -Query_2;
   end Remove_Query_Arg;

   ----------------------
   -- Remove_Query_Arg --
   ----------------------

   function Remove_Query_Arg (Key   : String;
                              Query : String := "")
                              return String
   is (Remove_Query_Arg (To_List (Key), Query));

--
-- Returns an array of single-use query variable names that can be removed from a URL.
--
-- @since 4.4.0
--
-- @return string[] An array of query variable names to remove from the URL.
--
-- function wp_removable_query_args() then
--         removable_query_args = array(
--                 "activate",
--                 "activated",
--                 "admin_email_remind_later",
--                 "approved",
--                 "core-major-auto-updates-saved",
--                 "deactivate",
--                 "delete_count",
--                 "deleted",
--                 "disabled",
--                 "doing_wp_cron",
--                 "enabled",
--                 "error",
--                 "hotkeys_highlight_first",
--                 "hotkeys_highlight_last",
--                 "ids",
--                 "locked",
--                 "message",
--                 "same",
--                 "saved",
--                 "settings-updated",
--                 "skipped",
--                 "spammed",
--                 "trashed",
--                 "unspammed",
--                 "untrashed",
--                 "update",
--                 "updated",
--                 "wp-post-new-reload",
--         );

--         --
--         -- Filters the list of query variable names to remove.
--         --
--         -- @since 4.2.0
--         --
--         -- @param string[] removable_query_args An array of query variable names to remove from a URL.
--         --
--         return apply_filters( "removable_query_args", removable_query_args );
-- end;

   ----------------------
   -- Add_Magic_Quotes --
   ----------------------

   function Add_Magic_Quotes (Arry : Array_Type)
            return Array_Type
   is
--    use Hb_Common;
      use Php;
      use Php.Strings;

      Array_2 : Array_Type := Arry;
   begin
      for A in Array_2.Iterate loop -- ( (array) array as k => v ) then
         declare
--          use Arrays.Array_Maps;

            K : constant String := Key (A);
            V : constant String := As_String (Get (Array_2, K));
         begin
            Set (Array_2, Key => K,
                 Value => From_String (Add_Slashes (V)));
            -- if Is_Array (V) then
            --    Array_2 (K) := Add_Magic_Quotes (V);
            -- elsif Is_String (V) then
            --    Array_2 (K) := Addslashes (V);
            -- else
            --    goto Continue;
            -- end if;
         end;
--       << Continue >>
      end loop;

      return Array_2;
   end Add_Magic_Quotes;

--
-- HTTP request for URI to retrieve content.
--
-- @since 1.5.1
--
-- @see wp_safe_remote_get()
--
-- @param string uri URI/URL of web page to retrieve.
-- @return string|false HTTP content. False on failure.
--
-- function wp_remote_fopen( uri ) then
--         parsed_url = parse_url( uri );

--         if ( ! parsed_url || ! is_array( parsed_url ) ) then
--                 return false;
--         end;

--         options            = array();
--         options["timeout"] = 10;

--         response = wp_safe_remote_get( uri, options );

--         if ( is_wp_error( response ) ) then
--                 return false;
--         end;

--         return wp_remote_retrieve_body( response );
-- end;

--
-- Sets up the WordPress query.
--
-- @since 2.0.0
--
-- @global WP       wp           Current WordPress environment instance.
-- @global WP_Query wp_query     WordPress Query object.
-- @global WP_Query wp_the_query Copy of the WordPress Query object.
--
-- @param string|array query_vars Default WP_Query arguments.
--
-- function wp( query_vars = "" ) then
--         global wp, wp_query, wp_the_query;

--         wp->main( query_vars );

--         if ( ! isset( wp_the_query ) ) then
--                 wp_the_query = wp_query;
--         end;
-- end;

   ----------------------------
   -- Get_Status_Header_Desc --
   ----------------------------

   function Get_Status_Header_Desc (Code : Integer)
                                    return String
   is
      use Hb_Common;
--        global wp_header_to_desc;

--        code = absint( code );

--        if ( ! isset( wp_header_to_desc ) ) then
      type List_Entry is record
         Code : Integer;
         Desc : Unbounded_String;
      end record;

--    Array_Type := To_Array (List => (
      Wp_Header_To_Desc : constant array (Positive range <>) of List_Entry :=
        (
          (100, +"Continue"),
          (101, +"Switching Protocols"),
          (102, +"Processing"),
          (103, +"Early Hints"),

          (200, +"OK"),
          (201, +"Created"),
          (202, +"Accepted"),
          (203, +"Non-Authoritative Information"),
          (204, +"No Content"),
          (205, +"Reset Content"),
          (206, +"Partial Content"),
          (207, +"Multi-Status"),
          (226, +"IM Used"),

          (300, +"Multiple Choices"),
          (301, +"Moved Permanently"),
          (302, +"Found"),
          (303, +"See Other"),
          (304, +"Not Modified"),
          (305, +"Use Proxy"),
          (306, +"Reserved"),
          (307, +"Temporary Redirect"),
          (308, +"Permanent Redirect"),

          (400, +"Bad Request"),
          (401, +"Unauthorized"),
          (402, +"Payment Required"),
          (403, +"Forbidden"),
          (404, +"Not Found"),
          (405, +"Method Not Allowed"),
          (406, +"Not Acceptable"),
          (407, +"Proxy Authentication Required"),
          (408, +"Request Timeout"),
          (409, +"Conflict"),
          (410, +"Gone"),
          (411, +"Length Required"),
          (412, +"Precondition Failed"),
          (413, +"Request Entity Too Large"),
          (414, +"Request-URI Too Long"),
          (415, +"Unsupported Media Type"),
          (416, +"Requested Range Not Satisfiable"),
          (417, +"Expectation Failed"),
          (418, +"I\'m a teapot"),
          (421, +"Misdirected Request"),
          (422, +"Unprocessable Entity"),
          (423, +"Locked"),
          (424, +"Failed Dependency"),
          (426, +"Upgrade Required"),
          (428, +"Precondition Required"),
          (429, +"Too Many Requests"),
          (431, +"Request Header Fields Too Large"),
          (451, +"Unavailable For Legal Reasons"),

          (500, +"Internal Server Error"),
          (501, +"Not Implemented"),
          (502, +"Bad Gateway"),
          (503, +"Service Unavailable"),
          (504, +"Gateway Timeout"),
          (505, +"HTTP Version Not Supported"),
          (506, +"Variant Also Negotiates"),
          (507, +"Insufficient Storage"),
          (510, +"Not Extended"),
          (511, +"Network Authentication Required")
        );
--        end;
   begin
      for A of Wp_Header_To_Desc loop
         if Code = A.Code then
            return -A.Desc;
         end if;
      end loop;
      return "";
        -- if ( isset( wp_header_to_desc[ code ] ) ) then
        --         return wp_header_to_desc[ code ];
        -- end; else then
        --         return "";
        -- end;
   end Get_Status_Header_Desc;

   -------------------
   -- Status_Header --
   -------------------

   procedure Status_Header (Code        : Integer;
                            Description : String := "")
   is
      use Php.HTML;
      use Php.Strings;
      use Wp_Common;
      use Inc_Load;
--    use Inc_Plugins;

      Description_2 : constant String :=
        (if Description = ""
         then Get_Status_Header_Desc (Code)
         else Description);
   begin
      if Empty (Description_2) then
         return;
      end if;

      declare
         Protocol      : constant String := Wp_Get_Server_Protocol;
         Status_Header : constant String := "protocol code description";

-- if ( function_exists( "apply_filters" ) ) then
         --
         -- Filters an HTTP status header.
         --
         -- @since 2.2.0
         --
         -- @param string status_header HTTP status header.
         -- @param int    code          HTTP status code.
         -- @param string description   Description for the status code.
         -- @param string protocol      Server protocol.
         --
         Status_Header_2 : constant String :=
           Apply_Filters ("status_header", Status_Header, Code,
                          Description_2, Protocol);
-- end;
      begin
         if not Headers_Sent then
            Header (Status_Header_2, True, Code);
         end if;
      end;
   end Status_Header;

   ----------------------------
   -- Wp_Get_Nocache_Headers --
   ----------------------------

   function Wp_Get_Nocache_Headers
            return Array_Type
   is
      use Inc_Plugins;

      Headers : constant Array_Type := To_Array (List => (
        Build ("Expires",       "Wed, 11 Jan 1984 05:00:00 GMT"),
        Build ("Cache-Control", "no-cache, must-revalidate, max-age=0")
      ));

--    if ( function_exists( "apply_filters" ) ) then
                --
                -- Filters the cache-controlling headers.
                --
                -- @since 2.8.0
                --
                -- @see wp_get_nocache_headers()
                --
                -- @param array headers Header names and field values.
                --
      Headers_2 : Array_Type :=
        Apply_Filters ("nocache_headers", Headers);
--    end if;
   begin
      Set (Headers_2, "Last-Modified", From_Boolean (False));
      return Headers_2;
   end Wp_Get_Nocache_Headers;

   ---------------------
   -- Nocache_Headers --
   ---------------------

   procedure Nocache_Headers
   is
      use Php.HTML;
   begin
      if Headers_Sent then
         return;
      end if;

      declare
         Headers : constant Array_Type := Wp_Get_Nocache_Headers;
      begin
         Delete (Ref (Headers, "Last-Modified"));

         Header_Remove ("Last-Modified");

         for A in Headers.Iterate loop
            declare
               Name        : constant String := Key (A);
               Field_Value : constant String := As_String (Element (A));
            begin
               Header (Name & ": " & Field_Value);
            end;
         end loop;
      end;
   end Nocache_Headers;

--
-- Sets the headers for caching for 10 days with JavaScript content type.
--
-- @since 2.1.0
--
-- function cache_javascript_headers() then
--         expiresOffset = 10-- DAY_IN_SECONDS;

--         header( "Content-Type: text/javascript; charset=" . get_bloginfo( "charset" ) );
--         header( "Vary: Accept-Encoding" ); // Handle proxies.
--         header( "Expires: " . gmdate( "D, d M Y H:i:s", time() + expiresOffset ) . " GMT" );
-- end;

--
-- Retrieves the number of database queries during the WordPress execution.
--
-- @since 2.0.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @return int Number of database queries.
--
-- function get_num_queries() then
--         global wpdb;
--         return wpdb->num_queries;
-- end;

--
-- Determines whether input is yes or no.
--
-- Must be "y" to be true.
--
-- @since 1.0.0
--
-- @param string yn Character string containing either "y" (yes) or "n" (no).
-- @return bool True if "y", false on anything else.
--
-- function bool_from_yn( yn ) then
--         return ( "y" === strtolower( yn ) );
-- end;

--
-- Loads the feed template from the use of an action hook.
--
-- If the feed action does not have a hook, then the function will die with a
-- message telling the visitor that the feed is not valid.
--
-- It is better to only have one hook for each feed.
--
-- @since 2.1.0
--
-- @global WP_Query wp_query WordPress Query object.
--
-- function do_feed() then
--         global wp_query;

--         feed = get_query_var( "feed" );

--         // Remove the pad, if present.
--         feed = preg_replace( "/^_+/", "", feed );

--         if ( "" === feed || "feed" === feed ) then
--                 feed = get_default_feed();
--         end;

--         if ( ! has_action( "do_feed_thenfeedend;" ) ) then
--                 wp_die( __( "<strong>Error:</strong> This is not a valid feed template." ), "", array( "response" => 404 ) );
--         end;

--         --
--         -- Fires once the given feed is loaded.
--         --
--         -- The dynamic portion of the hook name, `feed`, refers to the feed template name.
--         --
--         -- Possible hook names include:
--         --
--         --  - `do_feed_atom`
--         --  - `do_feed_rdf`
--         --  - `do_feed_rss`
--         --  - `do_feed_rss2`
--         --
--         -- @since 2.1.0
--         -- @since 4.4.0 The `feed` parameter was added.
--         --
--         -- @param bool   is_comment_feed Whether the feed is a comment feed.
--         -- @param string feed            The feed name.
--         --
--         do_action( "do_feed_thenfeedend;", wp_query->is_comment_feed, feed );
-- end;

--
-- Loads the RDF RSS 0.91 Feed template.
--
-- @since 2.1.0
--
-- @see load_template()
--
-- function do_feed_rdf() then
--         load_template( ABSPATH . WPINC . "/feed-rdf.php" );
-- end;

--
-- Loads the RSS 1.0 Feed Template.
--
-- @since 2.1.0
--
-- @see load_template()
--
-- function do_feed_rss() then
--         load_template( ABSPATH . WPINC . "/feed-rss.php" );
-- end;

--
-- Loads either the RSS2 comment feed or the RSS2 posts feed.
--
-- @since 2.1.0
--
-- @see load_template()
--
-- @param bool for_comments True for the comment feed, false for normal feed.
--
-- function do_feed_rss2( for_comments ) then
--         if ( for_comments ) then
--                 load_template( ABSPATH . WPINC . "/feed-rss2-comments.php" );
--         end; else then
--                 load_template( ABSPATH . WPINC . "/feed-rss2.php" );
--         end;
-- end;

--
-- Loads either Atom comment feed or Atom posts feed.
--
-- @since 2.1.0
--
-- @see load_template()
--
-- @param bool for_comments True for the comment feed, false for normal feed.
--
-- function do_feed_atom( for_comments ) then
--         if ( for_comments ) then
--                 load_template( ABSPATH . WPINC . "/feed-atom-comments.php" );
--         end; else then
--                 load_template( ABSPATH . WPINC . "/feed-atom.php" );
--         end;
-- end;

--
-- Displays the default robots.txt file content.
--
-- @since 2.1.0
-- @since 5.3.0 Remove the "Disallow: /" output if search engine visiblity is
--              discouraged in favor of robots meta HTML tag via wp_robots_no_robots()
--              filter callback.
--
-- function do_robots() then
--         header( "Content-Type: text/plain; charset=utf-8" );

--         --
--         -- Fires when displaying the robots.txt file.
--         --
--         -- @since 2.1.0
--         --
--         do_action( "do_robotstxt" );

--         output = "User-agent:--\n";
--         public = get_option( "blog_public" );

--         site_url = parse_url( site_url() );
--         path     = ( ! empty( site_url["path"] ) ) ? site_url["path"] : "";
--         output  .= "Disallow: path/wp-admin/\n";
--         output  .= "Allow: path/wp-admin/admin-ajax.php\n";

--         --
--         -- Filters the robots.txt output.
--         --
--         -- @since 3.0.0
--         --
--         -- @param string output The robots.txt output.
--         -- @param bool   public Whether the site is considered "public".
--         --
--         echo apply_filters( "robots_txt", output, public );
-- end;

--
-- Displays the favicon.ico file content.
--
-- @since 5.4.0
--
-- function do_favicon() then
--         --
--         -- Fires when serving the favicon.ico file.
--         --
--         -- @since 5.4.0
--         --
--         do_action( "do_faviconico" );

--         wp_redirect( get_site_icon_url( 32, includes_url( "images/w-logo-blue-white-bg.png" ) ) );
--         exit;
-- end;

   -----------------------
   -- Is_Blog_Installed --
   -----------------------

   function Is_Blog_Installed
            return Boolean
   is
      use Php.Strings;
      use Php.Types;
      use Hb_Common;
      use Inc_Caches;
      use Inc_Class_Wpdb;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;

      Found : Boolean;
   begin
      --
      -- Check cache first. If options table goes away and we have true
      -- cached, oh well.
      --
      if Wp_Cache_Get ("is_blog_installed", Found => Found) then
         return True;
      end if;

      declare
         Suppress : constant Boolean := Globals.WpDB.Suppress_Errors;

         All_Options : constant Array_Type :=
           (if not Wp_Installing
            then Wp_Load_Alloptions
            else Empty_Array);

         Installed_Site : Unbounded_String;
         Installed      : Boolean;
      begin
         -- If siteurl is not set to autoload, check it specifically.
         if not Isset (All_Options, "siteurl") then
            Installed_Site := +Globals.WpDB.Get_Var
              (Statement_Type ("SELECT option_value FROM " &
                               (-Globals.WpDB.Options) &
                               " WHERE option_name = 'siteurl'"));
         else
            Installed_Site := +Get_As_String (All_Options, "siteurl");
         end if;
         Globals.WpDB.Suppress_Errors (Suppress);

         Installed := not Empty (-Installed_Site);
         Wp_Cache_Set ("is_blog_installed", Installed);

         if Installed then
            return True;
         end if;
      end;

      -- If visiting repair.php, return true and let it take over.
      if Globals.WP_REPAIRING then
         return True;
      end if;

      declare
         Suppress  : constant Boolean    := Globals.WpDB.Suppress_Errors;
         Wp_Tables : constant Array_Type := Globals.WpDB.Tables;
      begin
         --
         -- Loop over the WP tables. If none exist, then scratch installation is
         -- allowed. If one or more exist, suggest table repair since we got here
         -- because the options table could not be accessed.
         --
         for Table_0 in Wp_Tables.Iterate loop
            declare
               Table : constant String := Key (Table_0);
            begin
               -- The existence of custom user tables Shouldn't suggest an unwise
               -- state or prevent a clean installation.
               if Globals.CUSTOM_USER_TABLE = Table then
                  goto Continue;
               end if;

               if Globals.CUSTOM_USER_META_TABLE = Table then
                  goto Continue;
               end if;

               declare
                  Described_Table : constant Array_Type :=
                    Globals.WpDB.Get_Results ("DESCRIBE table;");
               begin
                  if
                    (Described_Table = Empty_Array and then
                     Empty (-Globals.WpDB.Last_Error))
                    or else
                    (Is_Array (Described_Table) and then
                     0 = Count (Described_Table))
                  then
                     goto Continue;
                  end if;
               end;

               -- One or more tables exist. This is not good.
               Wp_Load_Translations_Early;

               -- Die with a DB error.
               Globals.WpDB.Error :=
                 +Sprintf (
                    -- translators: %s: Database repair URL.
                    abs "One or more database tables are unavailable. The database may need to be <a href=""%s"">repaired</a>.",
                    To_List ("maint/repair.php?referrer=is_blog_installed")
                  );

               Dead_DB;
            end;
            << Continue >>
         end loop;

         Globals.WpDB.Suppress_Errors (Suppress);
      end;

      Wp_Cache_Set ("is_blog_installed", False);

      return False;
   end Is_Blog_Installed;

   ------------------
   -- Wp_Nonce_URL --
   ------------------

   function Wp_Nonce_URL (Action_URL : String;
                          Action     : String := "-1";
                          Name       : String := "_wpnonce")
                          return String
   is
      use Php.Strings;
      use Inc_Formatting;
      use Inc_Pluggables;

      Action_URL_2 : constant String := Str_Replace ("&amp;", "&", Action_URL);
   begin
      return ESC_HTML (Add_Query_Arg (Name, Wp_Create_Nonce (Action), Action_URL_2));
   end Wp_Nonce_URL;

   --------------------
   -- Wp_Nonce_Field --
   --------------------

   function Wp_Nonce_Field (Action  : String  := "-1"; -- = -1
                            Name    : String  := "_wpnonce";
                            Referer : Boolean := True;
                            Echo    : Boolean := True)
                            return String
   is
      use Inc_Formatting;
      use Inc_Pluggables;
      use Hb_Common;

      Name_2 : constant String := ESC_Attr (Name);
      Nonce_Field : Unbounded_String :=
        +"<input type=""hidden"" id=""" & Name_2 & """ name=""" & Name_2 &
        """ value=""" & "XXX-864" & """ />";
--      """ value=""" & Wp_Create_Nonce (Action) & """ />";
   begin
      if Referer then
         Append (Nonce_Field, Wp_Referer_Field (False));
      end if;

      if Echo then
         Php.Echoing.Echo (-Nonce_Field);
      end if;

      return -Nonce_Field;
   end Wp_Nonce_Field;

   ----------------------
   -- Wp_Referer_Field --
   ----------------------

   function Wp_Referer_Field (Echo : Boolean := True)
                              return String
   is
      use Inc_Formatting;

      Request_URL   : constant String := Remove_Query_Arg ("_wp_http_referer");
      Referer_Field : constant String :=
        "<input type=""hidden"" name=""_wp_http_referer"" value=""" &
        ESC_URL (Request_URL) & """ />";
   begin
      if Echo then
         Php.Echoing.Echo (Referer_Field);
      end if;

      return Referer_Field;
   end Wp_Referer_Field;

--
-- Retrieves or displays original referer hidden field for forms.
--
-- The input name is "_wp_original_http_referer" and will be either the same
-- value of wp_referer_field(), if that was posted already or it will be the
-- current page, if it doesn"t exist.
--
-- @since 2.0.4
--
-- @param bool   echo         Optional. Whether to echo the original http referer. Default true.
-- @param string jump_back_to Optional. Can be "previous" or page you want to jump back to.
--                             Default "current".
-- @return string Original referer field.
--
-- function wp_original_referer_field( echo = true, jump_back_to = "current" ) then
--         ref = wp_get_original_referer();

--         if ( ! ref ) then
--                 ref = ( "previous" === jump_back_to ) ? wp_get_referer() : wp_unslash( _SERVER["REQUEST_URI"] );
--         end;

--         orig_referer_field = "<input type="hidden" name="_wp_original_http_referer" value="" . esc_attr( ref ) . "" />";

--         if ( echo ) then
--                 echo orig_referer_field;
--         end;

--         return orig_referer_field;
-- end;

   --------------------
   -- Wp_Get_Referer --
   --------------------

   function Wp_Get_Referer
            return String
   is
      use Php.Misc;
      use Binder;
      use Inc_Formatting;
      use Inc_Link_Templates;
      use Inc_Pluggables;
   begin
      if not Function_Exists ("wp_validate_redirect") then
         return ""; -- false
      end if;

      declare
         Ref : constant String := Wp_Get_Raw_Referer;
      begin
         if
           Ref /= "" and then
           Wp_Unslash (Get_As_String (X_SERVER, "REQUEST_URI")) /= Ref and then
           Home_URL & Wp_Unslash (Get_As_String (X_SERVER, "REQUEST_URI")) /= Ref
         then
            return Wp_Validate_Redirect (Ref, ""); -- False
         end if;
      end;
      return ""; -- false
   end Wp_Get_Referer;

   ------------------------
   -- Wp_Get_Raw_Referer --
   ------------------------

   function Wp_Get_Raw_Referer
            return String
   is
      use Binder;
      use Inc_Formatting;
   begin
      if not Empty (X_REQUEST, "_wp_http_referer") then
         return Wp_Unslash (Get_As_String (X_REQUEST, "_wp_http_referer"));

      elsif not Empty (X_SERVER, "HTTP_REFERER") then
         return Wp_Unslash (Get_As_String (X_SERVER, "HTTP_REFERER"));
      end if;

      return ""; -- false
   end Wp_Get_Raw_Referer;

--
-- Retrieves original referer that was posted, if it exists.
--
-- @since 2.0.4
--
-- @return string|false Original referer URL on success, false on failure.
--
-- function wp_get_original_referer() then
--         if ( ! empty( _REQUEST["_wp_original_http_referer"] ) && function_exists( "wp_validate_redirect" ) ) then
--                 return wp_validate_redirect( wp_unslash( _REQUEST["_wp_original_http_referer"] ), false );
--         end;

--         return false;
-- end;

--
-- Recursive directory creation based on full path.
--
-- Will attempt to set permissions on folders.
--
-- @since 2.0.1
--
-- @param string target Full path to attempt to create.
-- @return bool Whether the path was created. True if path already exists.
--
-- function wp_mkdir_p( target ) then
--         wrapper = null;

--         // Strip the protocol.
--         if ( wp_is_stream( target ) ) then
--                 list( wrapper, target ) = explode( "://", target, 2 );
--         end;

--         // From php.net/mkdir user contributed notes.
--         target = str_replace( "//", "/", target );

--         // Put the wrapper back on the target.
--         if ( null !== wrapper ) then
--                 target = wrapper . "://" . target;
--         end;

--         /*
--         -- Safe mode fails with a trailing slash under certain PHP versions.
--         -- Use rtrim() instead of untrailingslashit to avoid formatting.php dependency.
--         --
--         target = rtrim( target, "/" );
--         if ( empty( target ) ) then
--                 target = "/";
--         end;

--         if ( file_exists( target ) ) then
--                 return @is_dir( target );
--         end;

--         // Do not allow path traversals.
--         if ( false !== strpos( target, "../" ) || false !== strpos( target, ".." . DIRECTORY_SEPARATOR ) ) then
--                 return false;
--         end;

--         // We need to find the permissions of the parent folder that exists and inherit that.
--         target_parent = dirname( target );
--         while ( "." !== target_parent && ! is_dir( target_parent ) && dirname( target_parent ) !== target_parent ) then
--                 target_parent = dirname( target_parent );
--         end;

--         // Get the permission bits.
--         stat = @stat( target_parent );
--         if ( stat ) then
--                 dir_perms = stat["mode"] & 0007777;
--         end; else then
--                 dir_perms = 0777;
--         end;

--         if ( @mkdir( target, dir_perms, true ) ) then

--                 /*
--                 -- If a umask is set that modifies dir_perms, we"ll have to re-set
--                 -- the dir_perms correctly with chmod()
--                 --
--                 if ( ( dir_perms & ~umask() ) != dir_perms ) then
--                         folder_parts = explode( "/", substr( target, strlen( target_parent ) + 1 ) );
--                         for ( i = 1, c = count( folder_parts ); i <= c; i++ ) then
--                                 chmod( target_parent . "/" . implode( "/", array_slice( folder_parts, 0, i ) ), dir_perms );
--                         end;
--                 end;

--                 return true;
--         end;

--         return false;
-- end;

--
-- Tests if a given filesystem path is absolute.
--
-- For example, "/foo/bar", or "c:\windows".
--
-- @since 2.5.0
--
-- @param string path File path.
-- @return bool True if path is absolute, false is not absolute.
--
-- function path_is_absolute( path ) then
--         /*
--         -- Check to see if the path is a stream and check to see if its an actual
--         -- path or file as realpath() does not support stream wrappers.
--         --
--         if ( wp_is_stream( path ) && ( is_dir( path ) || is_file( path ) ) ) then
--                 return true;
--         end;

--         /*
--         -- This is definitive if true but fails if path does not exist or contains
--         -- a symbolic link.
--         --
--         if ( realpath( path ) === path ) then
--                 return true;
--         end;

--         if ( strlen( path ) === 0 || "." === path[0] ) then
--                 return false;
--         end;

--         // Windows allows absolute paths like this.
--         if ( preg_match( "#^[a-zA-Z]:\\\\#", path ) ) then
--                 return true;
--         end;

--         // A path starting with / or \ is absolute; anything else is relative.
--         return ( "/" === path[0] || "\\" === path[0] );
-- end;

--
-- Joins two filesystem paths together.
--
-- For example, "give me path relative to base". If the path is absolute,
-- then it the full path is returned.
--
-- @since 2.5.0
--
-- @param string base Base path.
-- @param string path Path relative to base.
-- @return string The path with the base or absolute path.
--
-- function path_join( base, path ) then
--         if ( path_is_absolute( path ) ) then
--                 return path;
--         end;

--         return rtrim( base, "/" ) . "/" . path;
-- end;

   -----------------------
   -- Wp_Normalize_Path --
   -----------------------

   function Wp_Normalize_Path (Path : String)
                               return String
   is
      use Hb_Common;
      use Php;
      use Php.Preg;
      use Php.Strings;

      Path_2  : Unbounded_String := +Path;
      Wrapper : Unbounded_String;
   begin
      if Wp_Is_Stream (-Path_2) then
         declare
            E : constant List_Type := Explode ("://", -Path_2, 2);
         begin
            Wrapper := E (E.First_Index + 0);
            Path_2  := E (E.First_Index + 1);
         end;
         Append (Wrapper, "://");
      end if;

      declare
         -- Standardize all paths to use "/".
         Path_3 : constant String := Str_Replace ("\\", "/", -Path_2);

         -- Replace multiple slashes down to a singular, allowing for network shares
         -- having two slashes.
         Path_4 : constant String := Preg_Replace ("|(?<=.)/+|", "/", Path_3);

         -- Windows paths should uppercase the drive letter.
         Path_5 : constant String := (if ":" = Substr (Path_4, 1, 1)
                                      then UC_First (Path_4)
                                      else Path_4);
      begin
         return (-Wrapper) & Path_5;
      end;
   end Wp_Normalize_Path;

   ------------------
   -- Get_Temp_Dir --
   ------------------

   Static_Temp : Unbounded_String;

   function Get_Temp_Dir
            return String
   is
      use Php.Files;
      use Php.Ini;
      use Php.Misc;
      use Hb_Common;
      use Inc_Formatting;
   begin
      if Globals.WP_TEMP_DIR /= "" then
--    if Defined ("WP_TEMP_DIR") then
         return Trailing_Slash_It (-Globals.WP_TEMP_DIR);
      end if;

      if Static_Temp /= "" then
         return Trailing_Slash_It (-Static_Temp);
      end if;

      if Function_Exists ("sys_get_temp_dir") then
         Static_Temp := +Sys_Get_Temp_Dir;
         if Is_Dir (-Static_Temp) and then Wp_Is_Writable (-Static_Temp) then -- @
            return Trailing_Slash_It (-Static_Temp);
         end if;
      end if;

      Static_Temp := +Ini_Get ("upload_tmp_dir");
      if Is_Dir (-Static_Temp) and then Wp_Is_Writable (-Static_Temp) then -- @
         return Trailing_Slash_It (-Static_Temp);
      end if;

      Static_Temp := Globals.WP_CONTENT_DIR & "/";
      if Is_Dir (-Static_Temp) and then Wp_Is_Writable (-Static_Temp) then
         return -Static_Temp;
      end if;

      return "/tmp/";
   end Get_Temp_Dir;

   --------------------
   -- Wp_Is_Writable --
   --------------------

   function Wp_Is_Writable (Path : String)
                            return Boolean
   is
      use Php.Files;
   begin
--    if ( "WIN" === strtoupper( substr( PHP_OS, 0, 3 ) ) ) then
--       return win_is_writable( path );
--    else
         return Is_Writable (Path); -- @
--    end if;
   end Wp_Is_Writable;

--
-- Workaround for Windows bug in is_writable() function
--
-- PHP has issues with Windows ACL"s for determine if a
-- directory is writable or not, this works around them by
-- checking the ability to open files rather than relying
-- upon PHP to interprate the OS ACL.
--
-- @since 2.8.0
--
-- @see https://bugs.php.net/bug.php?id=27609
-- @see https://bugs.php.net/bug.php?id=30931
--
-- @param string path Windows path to check for write-ability.
-- @return bool Whether the path is writable.
--
-- function win_is_writable( path ) then
--         if ( "/" === path[ strlen( path ) - 1 ] ) then
--                 // If it looks like a directory, check a random file within the directory.
--                 return win_is_writable( path . uniqid( mt_rand() ) . ".tmp" );
--         end; elseif ( is_dir( path ) ) then
--                 // If it"s a directory (and not a file), check a random file within the directory.
--                 return win_is_writable( path . "/" . uniqid( mt_rand() ) . ".tmp" );
--         end;

--         // Check tmp file for read/write capabilities.
--         should_delete_tmp_file = ! file_exists( path );

--         f = @fopen( path, "a" );
--         if ( false === f ) then
--                 return false;
--         end;
--         fclose( f );

--         if ( should_delete_tmp_file ) then
--                 unlink( path );
--         end;

--         return true;
-- end;

--
-- Retrieves uploads directory information.
--
-- Same as wp_upload_dir() but "light weight" as it doesn"t attempt to create the uploads directory.
-- Intended for use in themes, when only "basedir" and "baseurl" are needed, generally in all cases
-- when not uploading files.
--
-- @since 4.5.0
--
-- @see wp_upload_dir()
--
-- @return array See wp_upload_dir() for description.
--
-- function wp_get_upload_dir() then
--         return wp_upload_dir( null, false );
-- end;

--
-- Returns an array containing the current upload directory"s path and URL.
--
-- Checks the "upload_path" option, which should be from the web root folder,
-- and if it isn"t empty it will be used. If it is empty, then the path will be
-- "WP_CONTENT_DIR/uploads". If the "UPLOADS" constant is defined, then it will
-- override the "upload_path" option and "WP_CONTENT_DIR/uploads" path.
--
-- The upload URL path is set either by the "upload_url_path" option or by using
-- the "WP_CONTENT_URL" constant and appending "/uploads" to the path.
--
-- If the "uploads_use_yearmonth_folders" is set to true (checkbox if checked in
-- the administration settings panel), then the time will be used. The format
-- will be year first and then month.
--
-- If the path couldn"t be created, then an error will be returned with the key
-- "error" containing the error message. The error suggests that the parent
-- directory is not writable by the server.
--
-- @since 2.0.0
-- @uses _wp_upload_dir()
--
-- @param string time Optional. Time formatted in "yyyy/mm". Default null.
-- @param bool   create_dir Optional. Whether to check and create the uploads directory.
--                           Default true for backward compatibility.
-- @param bool   refresh_cache Optional. Whether to refresh the cache. Default false.
-- @return array then
--     Array of information about the upload directory.
--
--     @type string       path    Base directory and subdirectory or full path to upload directory.
--     @type string       url     Base URL and subdirectory or absolute URL to upload directory.
--     @type string       subdir  Subdirectory if uploads use year/month folders option is on.
--     @type string       basedir Path without subdir.
--     @type string       baseurl URL path without subdir.
--     @type string|false error   False or error message.
-- end;
--
-- function wp_upload_dir( time = null, create_dir = true, refresh_cache = false ) then
--         static cache = array(), tested_paths = array();

--         key = sprintf( "%d-%s", get_current_blog_id(), (string) time );

--         if ( refresh_cache || empty( cache[ key ] ) ) then
--                 cache[ key ] = _wp_upload_dir( time );
--         end;

--         --
--         -- Filters the uploads directory data.
--         --
--         -- @since 2.0.0
--         --
--         -- @param array uploads then
--         --     Array of information about the upload directory.
--         --
--         --     @type string       path    Base directory and subdirectory or full path to upload directory.
--         --     @type string       url     Base URL and subdirectory or absolute URL to upload directory.
--         --     @type string       subdir  Subdirectory if uploads use year/month folders option is on.
--         --     @type string       basedir Path without subdir.
--         --     @type string       baseurl URL path without subdir.
--         --     @type string|false error   False or error message.
--         -- end;
--         --
--         uploads = apply_filters( "upload_dir", cache[ key ] );

--         if ( create_dir ) then
--                 path = uploads["path"];

--                 if ( array_key_exists( path, tested_paths ) ) then
--                         uploads["error"] = tested_paths[ path ];
--                 end; else then
--                         if ( ! wp_mkdir_p( path ) ) then
--                                 if ( 0 === strpos( uploads["basedir"], ABSPATH ) ) then
--                                         error_path = str_replace( ABSPATH, "", uploads["basedir"] ) . uploads["subdir"];
--                                 end; else then
--                                         error_path = wp_basename( uploads["basedir"] ) . uploads["subdir"];
--                                 end;

--                                 uploads["error"] = sprintf(
--                                         /* translators: %s: Directory path.--
--                                         __( "Unable to create directory %s. Is its parent directory writable by the server?" ),
--                                         esc_html( error_path )
--                                 );
--                         end;

--                         tested_paths[ path ] = uploads["error"];
--                 end;
--         end;

--         return uploads;
-- end;

--
-- A non-filtered, non-cached version of wp_upload_dir() that doesn"t check the path.
--
-- @since 4.5.0
-- @access private
--
-- @param string time Optional. Time formatted in "yyyy/mm". Default null.
-- @return array See wp_upload_dir()
--
-- function _wp_upload_dir( time = null ) then
--         siteurl     = get_option( "siteurl" );
--         upload_path = trim( get_option( "upload_path" ) );

--         if ( empty( upload_path ) || "wp-content/uploads" === upload_path ) then
--                 dir = WP_CONTENT_DIR . "/uploads";
--         end; elseif ( 0 !== strpos( upload_path, ABSPATH ) ) then
--                 // dir is absolute, upload_path is (maybe) relative to ABSPATH.
--                 dir = path_join( ABSPATH, upload_path );
--         end; else then
--                 dir = upload_path;
--         end;

--         url = get_option( "upload_url_path" );
--         if ( ! url ) then
--                 if ( empty( upload_path ) || ( "wp-content/uploads" === upload_path ) || ( upload_path == dir ) ) then
--                         url = WP_CONTENT_URL . "/uploads";
--                 end; else then
--                         url = trailingslashit( siteurl ) . upload_path;
--                 end;
--         end;

--         /*
--         -- Honor the value of UPLOADS. This happens as long as ms-files rewriting is disabled.
--         -- We also sometimes obey UPLOADS when rewriting is enabled -- see the next block.
--         --
--         if ( defined( "UPLOADS" ) && ! ( is_multisite() && get_site_option( "ms_files_rewriting" ) ) ) then
--                 dir = ABSPATH . UPLOADS;
--                 url = trailingslashit( siteurl ) . UPLOADS;
--         end;

--         // If multisite (and if not the main site in a post-MU network).
--         if ( is_multisite() && ! ( is_main_network() && is_main_site() && defined( "MULTISITE" ) ) ) then

--                 if ( ! get_site_option( "ms_files_rewriting" ) ) then
--                         /*
--                         -- If ms-files rewriting is disabled (networks created post-3.5), it is fairly
--                         -- straightforward: Append sites/%d if we"re not on the main site (for post-MU
--                         -- networks). (The extra directory prevents a four-digit ID from conflicting with
--                         -- a year-based directory for the main site. But if a MU-era network has disabled
--                         -- ms-files rewriting manually, they don"t need the extra directory, as they never
--                         -- had wp-content/uploads for the main site.)
--                         --

--                         if ( defined( "MULTISITE" ) ) then
--                                 ms_dir = "/sites/" . get_current_blog_id();
--                         end; else then
--                                 ms_dir = "/" . get_current_blog_id();
--                         end;

--                         dir .= ms_dir;
--                         url .= ms_dir;

--                 end; elseif ( defined( "UPLOADS" ) && ! ms_is_switched() ) then
--                         /*
--                         -- Handle the old-form ms-files.php rewriting if the network still has that enabled.
--                         -- When ms-files rewriting is enabled, then we only listen to UPLOADS when:
--                         -- 1) We are not on the main site in a post-MU network, as wp-content/uploads is used
--                         --    there, and
--                         -- 2) We are not switched, as ms_upload_constants() hardcodes these constants to reflect
--                         --    the original blog ID.
--                         --
--                         -- Rather than UPLOADS, we actually use BLOGUPLOADDIR if it is set, as it is absolute.
--                         -- (And it will be set, see ms_upload_constants().) Otherwise, UPLOADS can be used, as
--                         -- as it is relative to ABSPATH. For the final piece: when UPLOADS is used with ms-files
--                         -- rewriting in multisite, the resulting URL is /files. (#WP22702 for background.)
--                         --

--                         if ( defined( "BLOGUPLOADDIR" ) ) then
--                                 dir = untrailingslashit( BLOGUPLOADDIR );
--                         end; else then
--                                 dir = ABSPATH . UPLOADS;
--                         end;
--                         url = trailingslashit( siteurl ) . "files";
--                 end;
--         end;

--         basedir = dir;
--         baseurl = url;

--         subdir = "";
--         if ( get_option( "uploads_use_yearmonth_folders" ) ) then
--                 // Generate the yearly and monthly directories.
--                 if ( ! time ) then
--                         time = current_time( "mysql" );
--                 end;
--                 y      = substr( time, 0, 4 );
--                 m      = substr( time, 5, 2 );
--                 subdir = "/y/m";
--         end;

--         dir .= subdir;
--         url .= subdir;

--         return array(
--                 "path"    => dir,
--                 "url"     => url,
--                 "subdir"  => subdir,
--                 "basedir" => basedir,
--                 "baseurl" => baseurl,
--                 "error"   => false,
--         );
-- end;

--
-- Gets a filename that is sanitized and unique for the given directory.
--
-- If the filename is not unique, then a number will be added to the filename
-- before the extension, and will continue adding numbers until the filename
-- is unique.
--
-- The callback function allows the caller to use their own method to create
-- unique file names. If defined, the callback should take three arguments:
-- - directory, base filename, and extension - and return a unique filename.
--
-- @since 2.5.0
--
-- @param string   dir                      Directory.
-- @param string   filename                 File name.
-- @param callable unique_filename_callback Callback. Default null.
-- @return string New filename, if given wasn"t unique.
--
-- function wp_unique_filename( dir, filename, unique_filename_callback = null ) then
--         // Sanitize the file name before we begin processing.
--         filename = sanitize_file_name( filename );
--         ext2     = null;

--         // Initialize vars used in the wp_unique_filename filter.
--         number        = "";
--         alt_filenames = array();

--         // Separate the filename into a name and extension.
--         ext  = pathinfo( filename, PATHINFO_EXTENSION );
--         name = pathinfo( filename, PATHINFO_BASENAME );

--         if ( ext ) then
--                 ext = "." . ext;
--         end;

--         // Edge case: if file is named ".ext", treat as an empty name.
--         if ( name === ext ) then
--                 name = "";
--         end;

--         /*
--         -- Increment the file number until we have a unique file to save in dir.
--         -- Use callback if supplied.
--         --
--         if ( unique_filename_callback && is_callable( unique_filename_callback ) ) then
--                 filename = call_user_func( unique_filename_callback, dir, name, ext );
--         end; else then
--                 fname = pathinfo( filename, PATHINFO_FILENAME );

--                 // Always append a number to file names that can potentially match image sub-size file names.
--                 if ( fname && preg_match( "/-(?:\d+x\d+|scaled|rotated)/", fname ) ) then
--                         number = 1;

--                         // At this point the file name may not be unique. This is tested below and the number is incremented.
--                         filename = str_replace( "thenfnameend;thenextend;", "thenfnameend;-thennumberend;thenextend;", filename );
--                 end;

--                 /*
--                 -- Get the mime type. Uploaded files were already checked with wp_check_filetype_and_ext()
--                 -- in _wp_handle_upload(). Using wp_check_filetype() would be sufficient here.
--                 --
--                 file_type = wp_check_filetype( filename );
--                 mime_type = file_type["type"];

--                 is_image    = ( ! empty( mime_type ) && 0 === strpos( mime_type, "image/" ) );
--                 upload_dir  = wp_get_upload_dir();
--                 lc_filename = null;

--                 lc_ext = strtolower( ext );
--                 _dir   = trailingslashit( dir );

--                 /*
--                 -- If the extension is uppercase add an alternate file name with lowercase extension.
--                 -- Both need to be tested for uniqueness as the extension will be changed to lowercase
--                 -- for better compatibility with different filesystems. Fixes an inconsistency in WP < 2.9
--                 -- where uppercase extensions were allowed but image sub-sizes were created with
--                 -- lowercase extensions.
--                 --
--                 if ( ext && lc_ext !== ext ) then
--                         lc_filename = preg_replace( "|" . preg_quote( ext ) . "|", lc_ext, filename );
--                 end;

--                 /*
--                 -- Increment the number added to the file name if there are any files in dir
--                 -- whose names match one of the possible name variations.
--                 --
--                 while ( file_exists( _dir . filename ) || ( lc_filename && file_exists( _dir . lc_filename ) ) ) then
--                         new_number = (int) number + 1;

--                         if ( lc_filename ) then
--                                 lc_filename = str_replace(
--                                         array( "-thennumberend;thenlc_extend;", "thennumberend;thenlc_extend;" ),
--                                         "-thennew_numberend;thenlc_extend;",
--                                         lc_filename
--                                 );
--                         end;

--                         if ( "" === "thennumberend;thenextend;" ) then
--                                 filename = "thenfilenameend;-thennew_numberend;";
--                         end; else then
--                                 filename = str_replace(
--                                         array( "-thennumberend;thenextend;", "thennumberend;thenextend;" ),
--                                         "-thennew_numberend;thenextend;",
--                                         filename
--                                 );
--                         end;

--                         number = new_number;
--                 end;

--                 // Change the extension to lowercase if needed.
--                 if ( lc_filename ) then
--                         filename = lc_filename;
--                 end;

--                 /*
--                 -- Prevent collisions with existing file names that contain dimension-like strings
--                 -- (whether they are subsizes or originals uploaded prior to #42437).
--                 --

--                 files = array();
--                 count = 10000;

--                 // The (resized) image files would have name and extension, and will be in the uploads dir.
--                 if ( name && ext && @is_dir( dir ) && false !== strpos( dir, upload_dir["basedir"] ) ) then
--                         --
--                         -- Filters the file list used for calculating a unique filename for a newly added file.
--                         --
--                         -- Returning an array from the filter will effectively short-circuit retrieval
--                         -- from the filesystem and return the passed value instead.
--                         --
--                         -- @since 5.5.0
--                         --
--                         -- @param array|null files    The list of files to use for filename comparisons.
--                         --                             Default null (to retrieve the list from the filesystem).
--                         -- @param string     dir      The directory for the new file.
--                         -- @param string     filename The proposed filename for the new file.
--                         --
--                         files = apply_filters( "pre_wp_unique_filename_file_list", null, dir, filename );

--                         if ( null === files ) then
--                                 // List of all files and directories contained in dir.
--                                 files = @scandir( dir );
--                         end;

--                         if ( ! empty( files ) ) then
--                                 // Remove "dot" dirs.
--                                 files = array_diff( files, array( ".", ".." ) );
--                         end;

--                         if ( ! empty( files ) ) then
--                                 count = count( files );

--                                 /*
--                                 -- Ensure this never goes into infinite loop as it uses pathinfo() and regex in the check,
--                                 -- but string replacement for the changes.
--                                 --
--                                 i = 0;

--                                 while ( i <= count && _wp_check_existing_file_names( filename, files ) ) then
--                                         new_number = (int) number + 1;

--                                         // If ext is uppercase it was replaced with the lowercase version after the previous loop.
--                                         filename = str_replace(
--                                                 array( "-thennumberend;thenlc_extend;", "thennumberend;thenlc_extend;" ),
--                                                 "-thennew_numberend;thenlc_extend;",
--                                                 filename
--                                         );

--                                         number = new_number;
--                                         i++;
--                                 end;
--                         end;
--                 end;

--                 /*
--                 -- Check if an image will be converted after uploading or some existing image sub-size file names may conflict
--                 -- when regenerated. If yes, ensure the new file name will be unique and will produce unique sub-sizes.
--                 --
--                 if ( is_image ) then
--                         -- This filter is documented in wp-includes/class-wp-image-editor.php--
--                         output_formats = apply_filters( "image_editor_output_format", array(), _dir . filename, mime_type );
--                         alt_types      = array();

--                         if ( ! empty( output_formats[ mime_type ] ) ) then
--                                 // The image will be converted to this format/mime type.
--                                 alt_mime_type = output_formats[ mime_type ];

--                                 // Other types of images whose names may conflict if their sub-sizes are regenerated.
--                                 alt_types   = array_keys( array_intersect( output_formats, array( mime_type, alt_mime_type ) ) );
--                                 alt_types[] = alt_mime_type;
--                         end; elseif ( ! empty( output_formats ) ) then
--                                 alt_types = array_keys( array_intersect( output_formats, array( mime_type ) ) );
--                         end;

--                         // Remove duplicates and the original mime type. It will be added later if needed.
--                         alt_types = array_unique( array_diff( alt_types, array( mime_type ) ) );

--                         foreach ( alt_types as alt_type ) then
--                                 alt_ext = wp_get_default_extension_for_mime_type( alt_type );

--                                 if ( ! alt_ext ) then
--                                         continue;
--                                 end;

--                                 alt_ext      = ".thenalt_extend;";
--                                 alt_filename = preg_replace( "|" . preg_quote( lc_ext ) . "|", alt_ext, filename );

--                                 alt_filenames[ alt_ext ] = alt_filename;
--                         end;

--                         if ( ! empty( alt_filenames ) ) then
--                                 /*
--                                 -- Add the original filename. It needs to be checked again
--                                 -- together with the alternate filenames when number is incremented.
--                                 --
--                                 alt_filenames[ lc_ext ] = filename;

--                                 // Ensure no infinite loop.
--                                 i = 0;

--                                 while ( i <= count && _wp_check_alternate_file_names( alt_filenames, _dir, files ) ) then
--                                         new_number = (int) number + 1;

--                                         foreach ( alt_filenames as alt_ext => alt_filename ) then
--                                                 alt_filenames[ alt_ext ] = str_replace(
--                                                         array( "-thennumberend;thenalt_extend;", "thennumberend;thenalt_extend;" ),
--                                                         "-thennew_numberend;thenalt_extend;",
--                                                         alt_filename
--                                                 );
--                                         end;

--                                         /*
--                                         -- Also update the number in (the output) filename.
--                                         -- If the extension was uppercase it was already replaced with the lowercase version.
--                                         --
--                                         filename = str_replace(
--                                                 array( "-thennumberend;thenlc_extend;", "thennumberend;thenlc_extend;" ),
--                                                 "-thennew_numberend;thenlc_extend;",
--                                                 filename
--                                         );

--                                         number = new_number;
--                                         i++;
--                                 end;
--                         end;
--                 end;
--         end;

--         --
--         -- Filters the result when generating a unique file name.
--         --
--         -- @since 4.5.0
--         -- @since 5.8.1 The `alt_filenames` and `number` parameters were added.
--         --
--         -- @param string        filename                 Unique file name.
--         -- @param string        ext                      File extension. Example: ".png".
--         -- @param string        dir                      Directory path.
--         -- @param callable|null unique_filename_callback Callback function that generates the unique file name.
--         -- @param string[]      alt_filenames            Array of alternate file names that were checked for collisions.
--         -- @param int|string    number                   The highest number that was used to make the file name unique
--         --                                                or an empty string if unused.
--         --
--         return apply_filters( "wp_unique_filename", filename, ext, dir, unique_filename_callback, alt_filenames, number );
-- end;

--
-- Helper function to test if each of an array of file names could conflict with existing files.
--
-- @since 5.8.1
-- @access private
--
-- @param string[] filenames Array of file names to check.
-- @param string   dir       The directory containing the files.
-- @param array    files     An array of existing files in the directory. May be empty.
-- @return bool True if the tested file name could match an existing file, false otherwise.
--
-- function _wp_check_alternate_file_names( filenames, dir, files ) then
--         foreach ( filenames as filename ) then
--                 if ( file_exists( dir . filename ) ) then
--                         return true;
--                 end;

--                 if ( ! empty( files ) && _wp_check_existing_file_names( filename, files ) ) then
--                         return true;
--                 end;
--         end;

--         return false;
-- end;

--
-- Helper function to check if a file name could match an existing image sub-size file name.
--
-- @since 5.3.1
-- @access private
--
-- @param string filename The file name to check.
-- @param array  files    An array of existing files in the directory.
-- @return bool True if the tested file name could match an existing file, false otherwise.
--
-- function _wp_check_existing_file_names( filename, files ) then
--         fname = pathinfo( filename, PATHINFO_FILENAME );
--         ext   = pathinfo( filename, PATHINFO_EXTENSION );

--         // Edge case, file names like `.ext`.
--         if ( empty( fname ) ) then
--                 return false;
--         end;

--         if ( ext ) then
--                 ext = ".ext";
--         end;

--         regex = "/^" . preg_quote( fname ) . "-(?:\d+x\d+|scaled|rotated)" . preg_quote( ext ) . "/i";

--         foreach ( files as file ) then
--                 if ( preg_match( regex, file ) ) then
--                         return true;
--                 end;
--         end;

--         return false;
-- end;

--
-- Creates a file in the upload folder with given content.
--
-- If there is an error, then the key "error" will exist with the error message.
-- If success, then the key "file" will have the unique file path, the "url" key
-- will have the link to the new file. and the "error" key will be set to false.
--
-- This function will not move an uploaded file to the upload folder. It will
-- create a new file with the content in bits parameter. If you move the upload
-- file, read the content of the uploaded file, and then you can give the
-- filename and content to this function, which will add it to the upload
-- folder.
--
-- The permissions will be set on the new file automatically by this function.
--
-- @since 2.0.0
--
-- @param string      name       Filename.
-- @param null|string deprecated Never used. Set to null.
-- @param string      bits       File content
-- @param string      time       Optional. Time formatted in "yyyy/mm". Default null.
-- @return array then
--     Information about the newly-uploaded file.
--
--     @type string       file  Filename of the newly-uploaded file.
--     @type string       url   URL of the uploaded file.
--     @type string       type  File type.
--     @type string|false error Error message, if there has been an error.
-- end;
--
-- function wp_upload_bits( name, deprecated, bits, time = null ) then
--         if ( ! empty( deprecated ) ) then
--                 _deprecated_argument( __FUNCTION__, "2.0.0" );
--         end;

--         if ( empty( name ) ) then
--                 return array( "error" => __( "Empty filename" ) );
--         end;

--         wp_filetype = wp_check_filetype( name );
--         if ( ! wp_filetype["ext"] && ! current_user_can( "unfiltered_upload" ) ) then
--                 return array( "error" => __( "Sorry, you are not allowed to upload this file type." ) );
--         end;

--         upload = wp_upload_dir( time );

--         if ( false !== upload["error"] ) then
--                 return upload;
--         end;

--         --
--         -- Filters whether to treat the upload bits as an error.
--         --
--         -- Returning a non-array from the filter will effectively short-circuit preparing the upload bits
--         -- and return that value instead. An error message should be returned as a string.
--         --
--         -- @since 3.0.0
--         --
--         -- @param array|string upload_bits_error An array of upload bits data, or error message to return.
--         --
--         upload_bits_error = apply_filters(
--                 "wp_upload_bits",
--                 array(
--                         "name" => name,
--                         "bits" => bits,
--                         "time" => time,
--                 )
--         );
--         if ( ! is_array( upload_bits_error ) ) then
--                 upload["error"] = upload_bits_error;
--                 return upload;
--         end;

--         filename = wp_unique_filename( upload["path"], name );

--         new_file = upload["path"] . "/filename";
--         if ( ! wp_mkdir_p( dirname( new_file ) ) ) then
--                 if ( 0 === strpos( upload["basedir"], ABSPATH ) ) then
--                         error_path = str_replace( ABSPATH, "", upload["basedir"] ) . upload["subdir"];
--                 end; else then
--                         error_path = wp_basename( upload["basedir"] ) . upload["subdir"];
--                 end;

--                 message = sprintf(
--                         /* translators: %s: Directory path.--
--                         __( "Unable to create directory %s. Is its parent directory writable by the server?" ),
--                         error_path
--                 );
--                 return array( "error" => message );
--         end;

--         ifp = @fopen( new_file, "wb" );
--         if ( ! ifp ) then
--                 return array(
--                         /* translators: %s: File name.--
--                         "error" => sprintf( __( "Could not write file %s" ), new_file ),
--                 );
--         end;

--         fwrite( ifp, bits );
--         fclose( ifp );
--         clearstatcache();

--         // Set correct file permissions.
--         stat  = @ stat( dirname( new_file ) );
--         perms = stat["mode"] & 0007777;
--         perms = perms & 0000666;
--         chmod( new_file, perms );
--         clearstatcache();

--         // Compute the URL.
--         url = upload["url"] . "/filename";

--         if ( is_multisite() ) then
--                 clean_dirsize_cache( new_file );
--         end;

--         -- This filter is documented in wp-admin/includes/file.php--
--         return apply_filters(
--                 "wp_handle_upload",
--                 array(
--                         "file"  => new_file,
--                         "url"   => url,
--                         "type"  => wp_filetype["type"],
--                         "error" => false,
--                 ),
--                 "sideload"
--         );
-- end;

--
-- Retrieves the file type based on the extension name.
--
-- @since 2.5.0
--
-- @param string ext The extension to search.
-- @return string|void The file type, example: audio, video, document, spreadsheet, etc.
--
-- function wp_ext2type( ext ) then
--         ext = strtolower( ext );

--         ext2type = wp_get_ext_types();
--         foreach ( ext2type as type => exts ) then
--                 if ( in_array( ext, exts, true ) ) then
--                         return type;
--                 end;
--         end;
-- end;

--
-- Returns first matched extension for the mime-type,
-- as mapped from wp_get_mime_types().
--
-- @since 5.8.1
--
-- @param string mime_type
--
-- @return string|false
--
-- function wp_get_default_extension_for_mime_type( mime_type ) then
--         extensions = explode( "|", array_search( mime_type, wp_get_mime_types(), true ) );

--         if ( empty( extensions[0] ) ) then
--                 return false;
--         end;

--         return extensions[0];
-- end;

--
-- Retrieves the file type from the file name.
--
-- You can optionally define the mime array, if needed.
--
-- @since 2.0.4
--
-- @param string   filename File name or path.
-- @param string[] mimes    Optional. Array of allowed mime types keyed by their file extension regex.
-- @return array then
--     Values for the extension and mime type.
--
--     @type string|false ext  File extension, or false if the file doesn"t match a mime type.
--     @type string|false type File mime type, or false if the file doesn"t match a mime type.
-- end;
--
-- function wp_check_filetype( filename, mimes = null ) then
--         if ( empty( mimes ) ) then
--                 mimes = get_allowed_mime_types();
--         end;
--         type = false;
--         ext  = false;

--         foreach ( mimes as ext_preg => mime_match ) then
--                 ext_preg = "!\.(" . ext_preg . ")!i";
--                 if ( preg_match( ext_preg, filename, ext_matches ) ) then
--                         type = mime_match;
--                         ext  = ext_matches[1];
--                         break;
--                 end;
--         end;

--         return compact( "ext", "type" );
-- end;

--
-- Attempts to determine the real file type of a file.
--
-- If unable to, the file name extension will be used to determine type.
--
-- If it"s determined that the extension does not match the file"s real type,
-- then the "proper_filename" value will be set with a proper filename and extension.
--
-- Currently this function only supports renaming images validated via wp_get_image_mime().
--
-- @since 3.0.0
--
-- @param string   file     Full path to the file.
-- @param string   filename The name of the file (may differ from file due to file being
--                           in a tmp directory).
-- @param string[] mimes    Optional. Array of allowed mime types keyed by their file extension regex.
-- @return array then
--     Values for the extension, mime type, and corrected filename.
--
--     @type string|false ext             File extension, or false if the file doesn"t match a mime type.
--     @type string|false type            File mime type, or false if the file doesn"t match a mime type.
--     @type string|false proper_filename File name with its correct extension, or false if it cannot be determined.
-- end;
--
-- function wp_check_filetype_and_ext( file, filename, mimes = null ) then
--         proper_filename = false;

--         // Do basic extension validation and MIME mapping.
--         wp_filetype = wp_check_filetype( filename, mimes );
--         ext         = wp_filetype["ext"];
--         type        = wp_filetype["type"];

--         // We can"t do any further validation without a file to work with.
--         if ( ! file_exists( file ) ) then
--                 return compact( "ext", "type", "proper_filename" );
--         end;

--         real_mime = false;

--         // Validate image types.
--         if ( type && 0 === strpos( type, "image/" ) ) then

--                 // Attempt to figure out what type of image it actually is.
--                 real_mime = wp_get_image_mime( file );

--                 if ( real_mime && real_mime != type ) then
--                         --
--                         -- Filters the list mapping image mime types to their respective extensions.
--                         --
--                         -- @since 3.0.0
--                         --
--                         -- @param array mime_to_ext Array of image mime types and their matching extensions.
--                         --
--                         mime_to_ext = apply_filters(
--                                 "getimagesize_mimes_to_exts",
--                                 array(
--                                         "image/jpeg" => "jpg",
--                                         "image/png"  => "png",
--                                         "image/gif"  => "gif",
--                                         "image/bmp"  => "bmp",
--                                         "image/tiff" => "tif",
--                                         "image/webp" => "webp",
--                                 )
--                         );

--                         // Replace whatever is after the last period in the filename with the correct extension.
--                         if ( ! empty( mime_to_ext[ real_mime ] ) ) then
--                                 filename_parts = explode( ".", filename );
--                                 array_pop( filename_parts );
--                                 filename_parts[] = mime_to_ext[ real_mime ];
--                                 new_filename     = implode( ".", filename_parts );

--                                 if ( new_filename != filename ) then
--                                         proper_filename = new_filename; // Mark that it changed.
--                                 end;
--                                 // Redefine the extension / MIME.
--                                 wp_filetype = wp_check_filetype( new_filename, mimes );
--                                 ext         = wp_filetype["ext"];
--                                 type        = wp_filetype["type"];
--                         end; else then
--                                 // Reset real_mime and try validating again.
--                                 real_mime = false;
--                         end;
--                 end;
--         end;

--         // Validate files that didn"t get validated during previous checks.
--         if ( type && ! real_mime && extension_loaded( "fileinfo" ) ) then
--                 finfo     = finfo_open( FILEINFO_MIME_TYPE );
--                 real_mime = finfo_file( finfo, file );
--                 finfo_close( finfo );

--                 // fileinfo often misidentifies obscure files as one of these types.
--                 nonspecific_types = array(
--                         "application/octet-stream",
--                         "application/encrypted",
--                         "application/CDFV2-encrypted",
--                         "application/zip",
--                 );

--                 /*
--                 -- If real_mime doesn"t match the content type we"re expecting from the file"s extension,
--                 -- we need to do some additional vetting. Media types and those listed in nonspecific_types are
--                 -- allowed some leeway, but anything else must exactly match the real content type.
--                 --
--                 if ( in_array( real_mime, nonspecific_types, true ) ) then
--                         // File is a non-specific binary type. That"s ok if it"s a type that generally tends to be binary.
--                         if ( ! in_array( substr( type, 0, strcspn( type, "/" ) ), array( "application", "video", "audio" ), true ) ) then
--                                 type = false;
--                                 ext  = false;
--                         end;
--                 end; elseif ( 0 === strpos( real_mime, "video/" ) || 0 === strpos( real_mime, "audio/" ) ) then
--                         /*
--                         -- For these types, only the major type must match the real value.
--                         -- This means that common mismatches are forgiven: application/vnd.apple.numbers is often misidentified as application/zip,
--                         -- and some media files are commonly named with the wrong extension (.mov instead of .mp4)
--                         --
--                         if ( substr( real_mime, 0, strcspn( real_mime, "/" ) ) !== substr( type, 0, strcspn( type, "/" ) ) ) then
--                                 type = false;
--                                 ext  = false;
--                         end;
--                 end; elseif ( "text/plain" === real_mime ) then
--                         // A few common file types are occasionally detected as text/plain; allow those.
--                         if ( ! in_array(
--                                 type,
--                                 array(
--                                         "text/plain",
--                                         "text/csv",
--                                         "application/csv",
--                                         "text/richtext",
--                                         "text/tsv",
--                                         "text/vtt",
--                                 ),
--                                 true
--                         )
--                         ) then
--                                 type = false;
--                                 ext  = false;
--                         end;
--                 end; elseif ( "application/csv" === real_mime ) then
--                         // Special casing for CSV files.
--                         if ( ! in_array(
--                                 type,
--                                 array(
--                                         "text/csv",
--                                         "text/plain",
--                                         "application/csv",
--                                 ),
--                                 true
--                         )
--                         ) then
--                                 type = false;
--                                 ext  = false;
--                         end;
--                 end; elseif ( "text/rtf" === real_mime ) then
--                         // Special casing for RTF files.
--                         if ( ! in_array(
--                                 type,
--                                 array(
--                                         "text/rtf",
--                                         "text/plain",
--                                         "application/rtf",
--                                 ),
--                                 true
--                         )
--                         ) then
--                                 type = false;
--                                 ext  = false;
--                         end;
--                 end; else then
--                         if ( type !== real_mime ) then
--                                 /*
--                                 -- Everything else including image/* and application/*:
--                                 -- If the real content type doesn"t match the file extension, assume it"s dangerous.
--                                 --
--                                 type = false;
--                                 ext  = false;
--                         end;
--                 end;
--         end;

--         // The mime type must be allowed.
--         if ( type ) then
--                 allowed = get_allowed_mime_types();

--                 if ( ! in_array( type, allowed, true ) ) then
--                         type = false;
--                         ext  = false;
--                 end;
--         end;

--         --
--         -- Filters the "real" file type of the given file.
--         --
--         -- @since 3.0.0
--         -- @since 5.1.0 The real_mime parameter was added.
--         --
--         -- @param array        wp_check_filetype_and_ext then
--         --     Values for the extension, mime type, and corrected filename.
--         --
--         --     @type string|false ext             File extension, or false if the file doesn"t match a mime type.
--         --     @type string|false type            File mime type, or false if the file doesn"t match a mime type.
--         --     @type string|false proper_filename File name with its correct extension, or false if it cannot be determined.
--         -- end;
--         -- @param string       file                      Full path to the file.
--         -- @param string       filename                  The name of the file (may differ from file due to
--         --                                                file being in a tmp directory).
--         -- @param string[]     mimes                     Array of mime types keyed by their file extension regex.
--         -- @param string|false real_mime                 The actual mime type or false if the type cannot be determined.
--         --
--         return apply_filters( "wp_check_filetype_and_ext", compact( "ext", "type", "proper_filename" ), file, filename, mimes, real_mime );
-- end;

--
-- Returns the real mime type of an image file.
--
-- This depends on exif_imagetype() or getimagesize() to determine real mime types.
--
-- @since 4.7.1
-- @since 5.8.0 Added support for WebP images.
--
-- @param string file Full path to the file.
-- @return string|false The actual mime type or false if the type cannot be determined.
--
-- function wp_get_image_mime( file ) then
--         /*
--         -- Use exif_imagetype() to check the mimetype if available or fall back to
--         -- getimagesize() if exif isn"t available. If either function throws an Exception
--         -- we assume the file could not be validated.
--         --
--         try then
--                 if ( is_callable( "exif_imagetype" ) ) then
--                         imagetype = exif_imagetype( file );
--                         mime      = ( imagetype ) ? image_type_to_mime_type( imagetype ) : false;
--                 end; elseif ( function_exists( "getimagesize" ) ) then
--                         // Don"t silence errors when in debug mode, unless running unit tests.
--                         if ( defined( "WP_DEBUG" ) && WP_DEBUG
--                                 && ! defined( "WP_RUN_CORE_TESTS" )
--                         ) then
--                                 // Not using wp_getimagesize() here to avoid an infinite loop.
--                                 imagesize = getimagesize( file );
--                         end; else then
--                                 // phpcs:ignore WordPress.PHP.NoSilencedErrors
--                                 imagesize = @getimagesize( file );
--                         end;

--                         mime = ( isset( imagesize["mime"] ) ) ? imagesize["mime"] : false;
--                 end; else then
--                         mime = false;
--                 end;

--                 if ( false !== mime ) then
--                         return mime;
--                 end;

--                 magic = file_get_contents( file, false, null, 0, 12 );

--                 if ( false === magic ) then
--                         return false;
--                 end;

--                 /*
--                 -- Add WebP fallback detection when image library doesn"t support WebP.
--                 -- Note: detection values come from LibWebP, see
--                 -- https://github.com/webmproject/libwebp/blob/master/imageio/image_dec.c#L30
--                 --
--                 magic = bin2hex( magic );
--                 if (
--                         // RIFF.
--                         ( 0 === strpos( magic, "52494646" ) ) &&
--                         // WEBP.
--                         ( 16 === strpos( magic, "57454250" ) )
--                 ) then
--                         mime = "image/webp";
--                 end;
--         end; catch ( Exception e ) then
--                 mime = false;
--         end;

--         return mime;
-- end;

   -----------------------
   -- Wp_Get_MIME_Types --
   -----------------------

   function Wp_Get_MIME_Types
            return Array_Type
   is
      use Inc_Plugins;
   begin
      --
      -- Filters the list of mime types and file extensions.
      --
      -- This filter should be used to add, not remove, mime types. To remove
      -- mime types, use the {@see "upload_mimes"} filter.
      --
      -- @since 3.5.0
      --
      -- @param string[] wp_get_mime_types Mime types keyed by the file extension regex
      --                                 corresponding to those types.
      --
      return
        Apply_Filters (
          "mime_types",
          To_Array (List => (
            -- Image formats.
            Build ("jpg|jpeg|jpe",                 "image/jpeg"),
            Build ("gif",                          "image/gif"),
            Build ("png",                          "image/png"),
            Build ("bmp",                          "image/bmp"),
            Build ("tiff|tif",                     "image/tiff"),
            Build ("webp",                         "image/webp"),
            Build ("ico",                          "image/x-icon"),
            Build ("heic",                         "image/heic"),
            -- Video formats.
            Build ("asf|asx",                      "video/x-ms-asf"),
            Build ("wmv",                          "video/x-ms-wmv"),
            Build ("wmx",                          "video/x-ms-wmx"),
            Build ("wm",                           "video/x-ms-wm"),
            Build ("avi",                          "video/avi"),
            Build ("divx",                         "video/divx"),
            Build ("flv",                          "video/x-flv"),
            Build ("mov|qt",                       "video/quicktime"),
            Build ("mpeg|mpg|mpe",                 "video/mpeg"),
            Build ("mp4|m4v",                      "video/mp4"),
            Build ("ogv",                          "video/ogg"),
            Build ("webm",                         "video/webm"),
            Build ("mkv",                          "video/x-matroska"),
            Build ("3gp|3gpp",                     "video/3gpp"),
            -- Can also be Audio.
            Build ("3g2|3gp2",                     "video/3gpp2"),
            -- Can also be Audio.
            -- Text formats.
            Build ("txt|asc|c|cc|h|srt",           "text/plain"),
            Build ("csv",                          "text/csv"),
            Build ("tsv",                          "text/tab-separated-values"),
            Build ("ics",                          "text/calendar"),
            Build ("rtx",                          "text/richtext"),
            Build ("css",                          "text/css"),
            Build ("htm|html",                     "text/html"),
            Build ("vtt",                          "text/vtt"),
            Build ("dfxp",                         "application/ttaf+xml"),
            -- Audio formats.
            Build ("mp3|m4a|m4b",                  "audio/mpeg"),
            Build ("aac",                          "audio/aac"),
            Build ("ra|ram",                       "audio/x-realaudio"),
            Build ("wav",                          "audio/wav"),
            Build ("ogg|oga",                      "audio/ogg"),
            Build ("flac",                         "audio/flac"),
            Build ("mid|midi",                     "audio/midi"),
            Build ("wma",                          "audio/x-ms-wma"),
            Build ("wax",                          "audio/x-ms-wax"),
            Build ("mka",                          "audio/x-matroska"),
            -- Misc application formats.
            Build ("rtf",                          "application/rtf"),
            Build ("js",                           "application/javascript"),
            Build ("pdf",                          "application/pdf"),
            Build ("swf",                          "application/x-shockwave-flash"),
            Build ("class",                        "application/java"),
            Build ("tar",                          "application/x-tar"),
            Build ("zip",                          "application/zip"),
            Build ("gz|gzip",                      "application/x-gzip"),
            Build ("rar",                          "application/rar"),
            Build ("7z",                           "application/x-7z-compressed"),
            Build ("exe",                          "application/x-msdownload"),
            Build ("psd",                          "application/octet-stream"),
            Build ("xcf",                          "application/octet-stream"),
            -- MS Office formats.
            Build ("doc",                          "application/msword"),
            Build ("pot|pps|ppt",                  "application/vnd.ms-powerpoint"),
            Build ("wri",                          "application/vnd.ms-write"),
            Build ("xla|xls|xlt|xlw",              "application/vnd.ms-excel"),
            Build ("mdb",                          "application/vnd.ms-access"),
            Build ("mpp",                          "application/vnd.ms-project"),
            Build ("docx",                         "application/vnd.openxmlformats-officedocument.wordprocessingml.document"),
            Build ("docm",                         "application/vnd.ms-word.document.macroEnabled.12"),
            Build ("dotx",                         "application/vnd.openxmlformats-officedocument.wordprocessingml.template"),
            Build ("dotm",                         "application/vnd.ms-word.template.macroEnabled.12"),
            Build ("xlsx",                         "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"),
            Build ("xlsm",                         "application/vnd.ms-excel.sheet.macroEnabled.12"),
            Build ("xlsb",                         "application/vnd.ms-excel.sheet.binary.macroEnabled.12"),
            Build ("xltx",                         "application/vnd.openxmlformats-officedocument.spreadsheetml.template"),
            Build ("xltm",                         "application/vnd.ms-excel.template.macroEnabled.12"),
            Build ("xlam",                         "application/vnd.ms-excel.addin.macroEnabled.12"),
            Build ("pptx",                         "application/vnd.openxmlformats-officedocument.presentationml.presentation"),
            Build ("pptm",                         "application/vnd.ms-powerpoint.presentation.macroEnabled.12"),
            Build ("ppsx",                         "application/vnd.openxmlformats-officedocument.presentationml.slideshow"),
            Build ("ppsm",                         "application/vnd.ms-powerpoint.slideshow.macroEnabled.12"),
            Build ("potx",                         "application/vnd.openxmlformats-officedocument.presentationml.template"),
            Build ("potm",                         "application/vnd.ms-powerpoint.template.macroEnabled.12"),
            Build ("ppam",                         "application/vnd.ms-powerpoint.addin.macroEnabled.12"),
            Build ("sldx",                         "application/vnd.openxmlformats-officedocument.presentationml.slide"),
            Build ("sldm",                         "application/vnd.ms-powerpoint.slide.macroEnabled.12"),
            Build ("onetoc|onetoc2|onetmp|onepkg", "application/onenote"),
            Build ("oxps",                         "application/oxps"),
            Build ("xps",                          "application/vnd.ms-xpsdocument"),
            -- OpenOffice formats.
            Build ("odt",                          "application/vnd.oasis.opendocument.text"),
            Build ("odp",                          "application/vnd.oasis.opendocument.presentation"),
            Build ("ods",                          "application/vnd.oasis.opendocument.spreadsheet"),
            Build ("odg",                          "application/vnd.oasis.opendocument.graphics"),
            Build ("odc",                          "application/vnd.oasis.opendocument.chart"),
            Build ("odb",                          "application/vnd.oasis.opendocument.database"),
            Build ("odf",                          "application/vnd.oasis.opendocument.formula"),
            -- WordPerfect formats.
            Build ("wp|wpd",                       "application/wordperfect"),
            -- iWork formats.
            Build ("key",                          "application/vnd.apple.keynote"),
            Build ("numbers",                      "application/vnd.apple.numbers"),
            Build ("pages",                        "application/vnd.apple.pages")
          ))
       );
   end Wp_Get_MIME_Types;

--
-- Retrieves the list of common file extensions and their types.
--
-- @since 4.6.0
--
-- @return array[] Multi-dimensional array of file extensions types keyed by the type of file.
--
-- function wp_get_ext_types() then

--         --
--         -- Filters file type based on the extension name.
--         --
--         -- @since 2.5.0
--         --
--         -- @see wp_ext2type()
--         --
--         -- @param array[] ext2type Multi-dimensional array of file extensions types keyed by the type of file.
--         --
--         return apply_filters(
--                 "ext2type",
--                 array(
--                         "image"       => array( "jpg", "jpeg", "jpe", "gif", "png", "bmp", "tif", "tiff", "ico", "heic", "webp" ),
--                         "audio"       => array( "aac", "ac3", "aif", "aiff", "flac", "m3a", "m4a", "m4b", "mka", "mp1", "mp2", "mp3", "ogg", "oga", "ram", "wav", "wma" ),
--                         "video"       => array( "3g2", "3gp", "3gpp", "asf", "avi", "divx", "dv", "flv", "m4v", "mkv", "mov", "mp4", "mpeg", "mpg", "mpv", "ogm", "ogv", "qt", "rm", "vob", "wmv" ),
--                         "document"    => array( "doc", "docx", "docm", "dotm", "odt", "pages", "pdf", "xps", "oxps", "rtf", "wp", "wpd", "psd", "xcf" ),
--                         "spreadsheet" => array( "numbers", "ods", "xls", "xlsx", "xlsm", "xlsb" ),
--                         "interactive" => array( "swf", "key", "ppt", "pptx", "pptm", "pps", "ppsx", "ppsm", "sldx", "sldm", "odp" ),
--                         "text"        => array( "asc", "csv", "tsv", "txt" ),
--                         "archive"     => array( "bz2", "cab", "dmg", "gz", "rar", "sea", "sit", "sqx", "tar", "tgz", "zip", "7z" ),
--                         "code"        => array( "css", "htm", "html", "php", "js" ),
--                 )
--         );
-- end;

--
-- Wrapper for PHP filesize with filters and casting the result as an integer.
--
-- @since 6.0.0
--
-- @link https://www.php.net/manual/en/function.filesize.php
--
-- @param string path Path to the file.
-- @return int The size of the file in bytes, or 0 in the event of an error.
--
-- function wp_filesize( path ) then
--         --
--         -- Filters the result of wp_filesize before the PHP function is run.
--         --
--         -- @since 6.0.0
--         --
--         -- @param null|int size The unfiltered value. Returning an int from the callback bypasses the filesize call.
--         -- @param string   path Path to the file.
--         --
--         size = apply_filters( "pre_wp_filesize", null, path );

--         if ( is_int( size ) ) then
--                 return size;
--         end;

--         size = file_exists( path ) ? (int) filesize( path ) : 0;

--         --
--         -- Filters the size of the file.
--         --
--         -- @since 6.0.0
--         --
--         -- @param int    size The result of PHP filesize on the file.
--         -- @param string path Path to the file.
--         --
--         return (int) apply_filters( "wp_filesize", size, path );
-- end;

   ----------------------------
   -- Get_Allowed_MIME_Types --
   ----------------------------

   function Get_Allowed_MIME_Types
     (User : Inc_Class_Wp_Users.Wp_User := Inc_Class_Wp_Users.Null_User)
      return Array_Type
   is
      use Php.Misc;
      use Wp_Common;
      use Inc_Capabilities;
      use Inc_Class_Wp_Users;

      T : constant Array_Type := Wp_Get_MIME_Types; -- ()

      Unfiltered : Boolean := False;
   begin
      Delete (Ref (T, "swf"));
      Delete (Ref (T, "exe"));

      if Function_Exists ("current_user_can") then
         Unfiltered :=
           (if User /= Null_User
            then User_Can (User, "unfiltered_html")
            else Current_User_Can ("unfiltered_html"));
      end if;

      if not Unfiltered then
--    if Empty (Unfiltered) then
         Delete (Ref (T, "htm|html"));
         Delete (Ref (T, "js"));
      end if;

      --
      -- Filters the list of allowed mime types and file extensions.
      --
      -- @since 2.0.0
      --
      -- @param array            t    Mime types keyed by the file extension regex
      --                               corresponding to those types.
      -- @param int|WP_User|null user User ID, User object or null if not provided
      --                               (indicates current user).
      --
      return Apply_Filters ("upload_mimes", T, User);
   end Get_Allowed_MIME_Types;

   ------------------
   -- Wp_Nonce_AYS --
   ------------------

   procedure Wp_Nonce_AYS (Action : String)
   is
      use Php.Strings;
      use Binder;
      use Hb_Common;
      use Inc_Formatting;
      use Inc_General_Templates;
      use Inc_L10n;
      use Inc_Pluggables;

      -- Default title and response code.
      Title         : Unbounded_String := +abs "Something went wrong.";
      Response_Code : constant Integer := 403;
      HTML          : Unbounded_String;
   begin
      if "log-out" = Action then
         Title := +Sprintf (
           -- translators: %s: Site title.
           abs "You are attempting to log out of %s",
           To_List (Get_Bloginfo ("name"))
         );
         HTML        := Title;
         Append (HTML, "</p><p>");

         declare
            Redirect_To : constant String :=
              (if Isset (X_REQUEST, "redirect_to")
               then Get_As_String (X_REQUEST, "redirect_to") else "");
         begin
            Append (HTML,
                    Sprintf (
                      -- translators: %s: Logout URL.
                      abs "Do you really want to <a href=""%s"">log out</a>?",
                      To_List (Wp_Logout_URL (Redirect_To))
                   ));
         end;
      else
         HTML := +abs "The link you followed has expired.";
         if Wp_Get_Referer /= "" then
            declare
               Wp_HTTP_Referer_2 : constant String :=
                 Remove_Query_Arg ("updated", Wp_Get_Referer);

               Wp_HTTP_Referer : constant String :=
                 Wp_Validate_Redirect (ESC_URL_Raw (Wp_HTTP_Referer_2));
            begin
               Append (HTML, "</p><p>");
               Append (HTML,
                       Sprintf (
                         "<a href=""%s"">%s</a>",
                         To_List (List => (
                           1 => +ESC_URL (Wp_HTTP_Referer),
                           2 => +abs "Please try again."
                         ))
                      ));
            end;
         end if;
      end if;

      Wp_Die (-HTML, -Title, Response_Code);
   end Wp_Nonce_AYS;

--
-- Kills WordPress execution and displays HTML page with an error message.
--
-- This function complements the `die()` PHP function. The difference is that
-- HTML will be displayed to the user. It is recommended to use this function
-- only when the execution should not continue any further. It is not recommended
-- to call this function very often, and try to handle as many errors as possible
-- silently or more gracefully.
--
-- As a shorthand, the desired HTTP response code may be passed as an integer to
-- the `title` parameter (the default title would apply) or the `args` parameter.
--
-- @since 2.0.4
-- @since 4.1.0 The `title` and `args` parameters were changed to optionally accept
--              an integer to be used as the response code.
-- @since 5.1.0 The `link_url`, `link_text`, and `exit` arguments were added.
-- @since 5.3.0 The `charset` argument was added.
-- @since 5.5.0 The `text_direction` argument has a priority over get_language_attributes()
--              in the default handler.
--
-- @global WP_Query wp_query WordPress Query object.
--
-- @param string|WP_Error  message Optional. Error message. If this is a WP_Error object,
--                                  and not an Ajax or XML-RPC request, the error"s messages are used.
--                                  Default empty.
-- @param string|int       title   Optional. Error title. If `message` is a `WP_Error` object,
--                                  error data with the key "title" may be used to specify the title.
--                                  If `title` is an integer, then it is treated as the response
--                                  code. Default empty.
-- @param string|array|int args then
--     Optional. Arguments to control behavior. If `args` is an integer, then it is treated
--     as the response code. Default empty array.
--
--     @type int    response       The HTTP response code. Default 200 for Ajax requests, 500 otherwise.
--     @type string link_url       A URL to include a link to. Only works in combination with link_text.
--                                  Default empty string.
--     @type string link_text      A label for the link to include. Only works in combination with link_url.
--                                  Default empty string.
--     @type bool   back_link      Whether to include a link to go back. Default false.
--     @type string text_direction The text direction. This is only useful internally, when WordPress is still
--                                  loading and the site"s locale is not set up yet. Accepts "rtl" and "ltr".
--                                  Default is the value of is_rtl().
--     @type string charset        Character set of the HTML output. Default "utf-8".
--     @type string code           Error code to use. Default is "wp_die", or the main error code if message
--                                  is a WP_Error.
--     @type bool   exit           Whether to exit the process after completion. Default true.
-- end;
--
-- function wp_die( message = "", title = "", args = array() ) then
   procedure Wp_Die (Message : String  := "";
                     Title   : String  := "";
                     Code    : Integer := 0) -- , args = array()
   is
   begin
      raise Program_Die
        with Title & " " & Message & " " & Integer'Image (Code);
   end Wp_Die;
--         global wp_query;

--         if ( is_int( args ) ) then
--                 args = array( "response" => args );
--         end; elseif ( is_int( title ) ) then
--                 args  = array( "response" => title );
--                 title = "";
--         end;

--         if ( wp_doing_ajax() ) then
--                 --
--                 -- Filters the callback for killing WordPress execution for Ajax requests.
--                 --
--                 -- @since 3.4.0
--                 --
--                 -- @param callable callback Callback function name.
--                 --
--                 callback = apply_filters( "wp_die_ajax_handler", "_ajax_wp_die_handler" );
--         end; elseif ( wp_is_json_request() ) then
--                 --
--                 -- Filters the callback for killing WordPress execution for JSON requests.
--                 --
--                 -- @since 5.1.0
--                 --
--                 -- @param callable callback Callback function name.
--                 --
--                 callback = apply_filters( "wp_die_json_handler", "_json_wp_die_handler" );
--         end; elseif ( defined( "REST_REQUEST" ) && REST_REQUEST && wp_is_jsonp_request() ) then
--                 --
--                 -- Filters the callback for killing WordPress execution for JSONP REST requests.
--                 --
--                 -- @since 5.2.0
--                 --
--                 -- @param callable callback Callback function name.
--                 --
--                 callback = apply_filters( "wp_die_jsonp_handler", "_jsonp_wp_die_handler" );
--         end; elseif ( defined( "XMLRPC_REQUEST" ) && XMLRPC_REQUEST ) then
--                 --
--                 -- Filters the callback for killing WordPress execution for XML-RPC requests.
--                 --
--                 -- @since 3.4.0
--                 --
--                 -- @param callable callback Callback function name.
--                 --
--                 callback = apply_filters( "wp_die_xmlrpc_handler", "_xmlrpc_wp_die_handler" );
--         end; elseif ( wp_is_xml_request()
--                 || isset( wp_query ) &&
--                         ( function_exists( "is_feed" ) && is_feed()
--                         || function_exists( "is_comment_feed" ) && is_comment_feed()
--                         || function_exists( "is_trackback" ) && is_trackback() ) ) then
--                 --
--                 -- Filters the callback for killing WordPress execution for XML requests.
--                 --
--                 -- @since 5.2.0
--                 --
--                 -- @param callable callback Callback function name.
--                 --
--                 callback = apply_filters( "wp_die_xml_handler", "_xml_wp_die_handler" );
--         end; else then
--                 --
--                 -- Filters the callback for killing WordPress execution for all non-Ajax, non-JSON, non-XML requests.
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param callable callback Callback function name.
--                 --
--                 callback = apply_filters( "wp_die_handler", "_default_wp_die_handler" );
--         end;

--         call_user_func( callback, message, title, args );
-- end;

--
-- Kills WordPress execution and displays HTML page with an error message.
--
-- This is the default handler for wp_die(). If you want a custom one,
-- you can override this using the {@see "wp_die_handler"} filter in wp_die().
--
-- @since 3.0.0
-- @access private
--
-- @param string|WP_Error message Error message or WP_Error object.
-- @param string          title   Optional. Error title. Default empty.
-- @param string|array    args    Optional. Arguments to control behavior. Default empty array.
--
-- function _default_wp_die_handler( message, title = "", args = array() ) then
--         list( message, title, parsed_args ) = _wp_die_process_input( message, title, args );

--         if ( is_string( message ) ) then
--                 if ( ! empty( parsed_args["additional_errors"] ) ) then
--                         message = array_merge(
--                                 array( message ),
--                                 wp_list_pluck( parsed_args["additional_errors"], "message" )
--                         );
--                         message = "<ul>\n\t\t<li>" . implode( "</li>\n\t\t<li>", message ) . "</li>\n\t</ul>";
--                 end;

--                 message = sprintf(
--                         "<div class="wp-die-message">%s</div>",
--                         message
--                 );
--         end;

--         have_gettext = function_exists( "__" );

--         if ( ! empty( parsed_args["link_url"] ) && ! empty( parsed_args["link_text"] ) ) then
--                 link_url = parsed_args["link_url"];
--                 if ( function_exists( "esc_url" ) ) then
--                         link_url = esc_url( link_url );
--                 end;
--                 link_text = parsed_args["link_text"];
--                 message  .= "\n<p><a href="thenlink_urlend;">thenlink_textend;</a></p>";
--         end;

--         if ( isset( parsed_args["back_link"] ) && parsed_args["back_link"] ) then
--                 back_text = have_gettext ? __( "&laquo; Back" ) : "&laquo; Back";
--                 message  .= "\n<p><a href="javascript:history.back()">back_text</a></p>";
--         end;

--         if ( ! did_action( "admin_head" ) ) :
--                 if ( ! headers_sent() ) then
--                         header( "Content-Type: text/html; charset=thenparsed_args["charset"]end;" );
--                         status_header( parsed_args["response"] );
--                         nocache_headers();
--                 end;

--                 text_direction = parsed_args["text_direction"];
--                 dir_attr       = "dir="text_direction"";

--                 // If `text_direction` was not explicitly passed,
--                 // use get_language_attributes() if available.
--                 if ( empty( args["text_direction"] )
--                         && function_exists( "language_attributes" ) && function_exists( "is_rtl" )
--                 ) then
--                         dir_attr = get_language_attributes();
--                 end;
--                 ?>
-- <!DOCTYPE html>
-- <html <?php echo dir_attr; ?>>
-- <head>
--         <meta http-equiv="Content-Type" content="text/html; charset=<?php echo parsed_args["charset"]; ?>" />
--         <meta name="viewport" content="width=device-width">
--                 <?php
--                 if ( function_exists( "wp_robots" ) && function_exists( "wp_robots_no_robots" ) && function_exists( "add_filter" ) ) then
--                         add_filter( "wp_robots", "wp_robots_no_robots" );
--                         wp_robots();
--                 end;
--                 ?>
--         <title><?php echo title; ?></title>
--         <style type="text/css">
--                 html then
--                         background: #f1f1f1;
--                 end;
--                 body then
--                         background: #fff;
--                         border: 1px solid #ccd0d4;
--                         color: #444;
--                         font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif;
--                         margin: 2em auto;
--                         padding: 1em 2em;
--                         max-width: 700px;
--                         -webkit-box-shadow: 0 1px 1px rgba(0, 0, 0, .04);
--                         box-shadow: 0 1px 1px rgba(0, 0, 0, .04);
--                 end;
--                 h1 then
--                         border-bottom: 1px solid #dadada;
--                         clear: both;
--                         color: #666;
--                         font-size: 24px;
--                         margin: 30px 0 0 0;
--                         padding: 0;
--                         padding-bottom: 7px;
--                 end;
--                 #error-page then
--                         margin-top: 50px;
--                 end;
--                 #error-page p,
--                 #error-page .wp-die-message then
--                         font-size: 14px;
--                         line-height: 1.5;
--                         margin: 25px 0 20px;
--                 end;
--                 #error-page code then
--                         font-family: Consolas, Monaco, monospace;
--                 end;
--                 ul li then
--                         margin-bottom: 10px;
--                         font-size: 14px ;
--                 end;
--                 a then
--                         color: #0073aa;
--                 end;
--                 a:hover,
--                 a:active then
--                         color: #006799;
--                 end;
--                 a:focus then
--                         color: #124964;
--                         -webkit-box-shadow:
--                                 0 0 0 1px #5b9dd9,
--                                 0 0 2px 1px rgba(30, 140, 190, 0.8);
--                         box-shadow:
--                                 0 0 0 1px #5b9dd9,
--                                 0 0 2px 1px rgba(30, 140, 190, 0.8);
--                         outline: none;
--                 end;
--                 .button then
--                         background: #f3f5f6;
--                         border: 1px solid #016087;
--                         color: #016087;
--                         display: inline-block;
--                         text-decoration: none;
--                         font-size: 13px;
--                         line-height: 2;
--                         height: 28px;
--                         margin: 0;
--                         padding: 0 10px 1px;
--                         cursor: pointer;
--                         -webkit-border-radius: 3px;
--                         -webkit-appearance: none;
--                         border-radius: 3px;
--                         white-space: nowrap;
--                         -webkit-box-sizing: border-box;
--                         -moz-box-sizing:    border-box;
--                         box-sizing:         border-box;

--                         vertical-align: top;
--                 end;

--                 .button.button-large then
--                         line-height: 2.30769231;
--                         min-height: 32px;
--                         padding: 0 12px;
--                 end;

--                 .button:hover,
--                 .button:focus then
--                         background: #f1f1f1;
--                 end;

--                 .button:focus then
--                         background: #f3f5f6;
--                         border-color: #007cba;
--                         -webkit-box-shadow: 0 0 0 1px #007cba;
--                         box-shadow: 0 0 0 1px #007cba;
--                         color: #016087;
--                         outline: 2px solid transparent;
--                         outline-offset: 0;
--                 end;

--                 .button:active then
--                         background: #f3f5f6;
--                         border-color: #7e8993;
--                         -webkit-box-shadow: none;
--                         box-shadow: none;
--                 end;

--                 <?php
--                 if ( "rtl" === text_direction ) then
--                         echo "body then font-family: Tahoma, Arial; end;";
--                 end;
--                 ?>
--         </style>
-- </head>
-- <body id="error-page">
-- <?php endif; // ! did_action( "admin_head" ) ?>
--         <?php echo message; ?>
-- </body>
-- </html>
--         <?php
--         if ( parsed_args["exit"] ) then
--                 die();
--         end;
-- end;

--
-- Kills WordPress execution and displays Ajax response with an error message.
--
-- This is the handler for wp_die() when processing Ajax requests.
--
-- @since 3.4.0
-- @access private
--
-- @param string       message Error message.
-- @param string       title   Optional. Error title (unused). Default empty.
-- @param string|array args    Optional. Arguments to control behavior. Default empty array.
--
-- function _ajax_wp_die_handler( message, title = "", args = array() ) then
--         // Set default "response" to 200 for Ajax requests.
--         args = wp_parse_args(
--                 args,
--                 array( "response" => 200 )
--         );

--         list( message, title, parsed_args ) = _wp_die_process_input( message, title, args );

--         if ( ! headers_sent() ) then
--                 // This is intentional. For backward-compatibility, support passing null here.
--                 if ( null !== args["response"] ) then
--                         status_header( parsed_args["response"] );
--                 end;
--                 nocache_headers();
--         end;

--         if ( is_scalar( message ) ) then
--                 message = (string) message;
--         end; else then
--                 message = "0";
--         end;

--         if ( parsed_args["exit"] ) then
--                 die( message );
--         end;

--         echo message;
-- end;

--
-- Kills WordPress execution and displays JSON response with an error message.
--
-- This is the handler for wp_die() when processing JSON requests.
--
-- @since 5.1.0
-- @access private
--
-- @param string       message Error message.
-- @param string       title   Optional. Error title. Default empty.
-- @param string|array args    Optional. Arguments to control behavior. Default empty array.
--
-- function _json_wp_die_handler( message, title = "", args = array() ) then
--         list( message, title, parsed_args ) = _wp_die_process_input( message, title, args );

--         data = array(
--                 "code"              => parsed_args["code"],
--                 "message"           => message,
--                 "data"              => array(
--                         "status" => parsed_args["response"],
--                 ),
--                 "additional_errors" => parsed_args["additional_errors"],
--         );

--         if ( ! headers_sent() ) then
--                 header( "Content-Type: application/json; charset=thenparsed_args["charset"]end;" );
--                 if ( null !== parsed_args["response"] ) then
--                         status_header( parsed_args["response"] );
--                 end;
--                 nocache_headers();
--         end;

--         echo wp_json_encode( data );
--         if ( parsed_args["exit"] ) then
--                 die();
--         end;
-- end;

--
-- Kills WordPress execution and displays JSONP response with an error message.
--
-- This is the handler for wp_die() when processing JSONP requests.
--
-- @since 5.2.0
-- @access private
--
-- @param string       message Error message.
-- @param string       title   Optional. Error title. Default empty.
-- @param string|array args    Optional. Arguments to control behavior. Default empty array.
--
-- function _jsonp_wp_die_handler( message, title = "", args = array() ) then
--         list( message, title, parsed_args ) = _wp_die_process_input( message, title, args );

--         data = array(
--                 "code"              => parsed_args["code"],
--                 "message"           => message,
--                 "data"              => array(
--                         "status" => parsed_args["response"],
--                 ),
--                 "additional_errors" => parsed_args["additional_errors"],
--         );

--         if ( ! headers_sent() ) then
--                 header( "Content-Type: application/javascript; charset=thenparsed_args["charset"]end;" );
--                 header( "X-Content-Type-Options: nosniff" );
--                 header( "X-Robots-Tag: noindex" );
--                 if ( null !== parsed_args["response"] ) then
--                         status_header( parsed_args["response"] );
--                 end;
--                 nocache_headers();
--         end;

--         result         = wp_json_encode( data );
--         jsonp_callback = _GET["_jsonp"];
--         echo "--" . jsonp_callback . "(" . result . ")";
--         if ( parsed_args["exit"] ) then
--                 die();
--         end;
-- end;

--
-- Kills WordPress execution and displays XML response with an error message.
--
-- This is the handler for wp_die() when processing XMLRPC requests.
--
-- @since 3.2.0
-- @access private
--
-- @global wp_xmlrpc_server wp_xmlrpc_server
--
-- @param string       message Error message.
-- @param string       title   Optional. Error title. Default empty.
-- @param string|array args    Optional. Arguments to control behavior. Default empty array.
--
-- function _xmlrpc_wp_die_handler( message, title = "", args = array() ) then
--         global wp_xmlrpc_server;

--         list( message, title, parsed_args ) = _wp_die_process_input( message, title, args );

--         if ( ! headers_sent() ) then
--                 nocache_headers();
--         end;

--         if ( wp_xmlrpc_server ) then
--                 error = new IXR_Error( parsed_args["response"], message );
--                 wp_xmlrpc_server->output( error->getXml() );
--         end;
--         if ( parsed_args["exit"] ) then
--                 die();
--         end;
-- end;

--
-- Kills WordPress execution and displays XML response with an error message.
--
-- This is the handler for wp_die() when processing XML requests.
--
-- @since 5.2.0
-- @access private
--
-- @param string       message Error message.
-- @param string       title   Optional. Error title. Default empty.
-- @param string|array args    Optional. Arguments to control behavior. Default empty array.
--
-- function _xml_wp_die_handler( message, title = "", args = array() ) then
--         list( message, title, parsed_args ) = _wp_die_process_input( message, title, args );

--         message = htmlspecialchars( message );
--         title   = htmlspecialchars( title );

--         xml = <<<EOD
-- <error>
--     <code>thenparsed_args["code"]end;</code>
--     <title><![CDATA[thentitleend;]]></title>
--     <message><![CDATA[thenmessageend;]]></message>
--     <data>
--         <status>thenparsed_args["response"]end;</status>
--     </data>
-- </error>

-- EOD;

--         if ( ! headers_sent() ) then
--                 header( "Content-Type: text/xml; charset=thenparsed_args["charset"]end;" );
--                 if ( null !== parsed_args["response"] ) then
--                         status_header( parsed_args["response"] );
--                 end;
--                 nocache_headers();
--         end;

--         echo xml;
--         if ( parsed_args["exit"] ) then
--                 die();
--         end;
-- end;

--
-- Kills WordPress execution and displays an error message.
--
-- This is the handler for wp_die() when processing APP requests.
--
-- @since 3.4.0
-- @since 5.1.0 Added the title and args parameters.
-- @access private
--
-- @param string       message Optional. Response to print. Default empty.
-- @param string       title   Optional. Error title (unused). Default empty.
-- @param string|array args    Optional. Arguments to control behavior. Default empty array.
--
-- function _scalar_wp_die_handler( message = "", title = "", args = array() ) then
--         list( message, title, parsed_args ) = _wp_die_process_input( message, title, args );

--         if ( parsed_args["exit"] ) then
--                 if ( is_scalar( message ) ) then
--                         die( (string) message );
--                 end;
--                 die();
--         end;

--         if ( is_scalar( message ) ) then
--                 echo (string) message;
--         end;
-- end;

--
-- Processes arguments passed to wp_die() consistently for its handlers.
--
-- @since 5.1.0
-- @access private
--
-- @param string|WP_Error message Error message or WP_Error object.
-- @param string          title   Optional. Error title. Default empty.
-- @param string|array    args    Optional. Arguments to control behavior. Default empty array.
-- @return array then
--     Processed arguments.
--
--     @type string 0 Error message.
--     @type string 1 Error title.
--     @type array  2 Arguments to control behavior.
-- end;
--
-- function _wp_die_process_input( message, title = "", args = array() ) then
--         defaults = array(
--                 "response"          => 0,
--                 "code"              => "",
--                 "exit"              => true,
--                 "back_link"         => false,
--                 "link_url"          => "",
--                 "link_text"         => "",
--                 "text_direction"    => "",
--                 "charset"           => "utf-8",
--                 "additional_errors" => array(),
--         );

--         args = wp_parse_args( args, defaults );

--         if ( function_exists( "is_wp_error" ) && is_wp_error( message ) ) then
--                 if ( ! empty( message->errors ) ) then
--                         errors = array();
--                         foreach ( (array) message->errors as error_code => error_messages ) then
--                                 foreach ( (array) error_messages as error_message ) then
--                                         errors[] = array(
--                                                 "code"    => error_code,
--                                                 "message" => error_message,
--                                                 "data"    => message->get_error_data( error_code ),
--                                         );
--                                 end;
--                         end;

--                         message = errors[0]["message"];
--                         if ( empty( args["code"] ) ) then
--                                 args["code"] = errors[0]["code"];
--                         end;
--                         if ( empty( args["response"] ) && is_array( errors[0]["data"] ) && ! empty( errors[0]["data"]["status"] ) ) then
--                                 args["response"] = errors[0]["data"]["status"];
--                         end;
--                         if ( empty( title ) && is_array( errors[0]["data"] ) && ! empty( errors[0]["data"]["title"] ) ) then
--                                 title = errors[0]["data"]["title"];
--                         end;

--                         unset( errors[0] );
--                         args["additional_errors"] = array_values( errors );
--                 end; else then
--                         message = "";
--                 end;
--         end;

--         have_gettext = function_exists( "__" );

--         // The title and these specific args must always have a non-empty value.
--         if ( empty( args["code"] ) ) then
--                 args["code"] = "wp_die";
--         end;
--         if ( empty( args["response"] ) ) then
--                 args["response"] = 500;
--         end;
--         if ( empty( title ) ) then
--                 title = have_gettext ? __( "WordPress &rsaquo; Error" ) : "WordPress &rsaquo; Error";
--         end;
--         if ( empty( args["text_direction"] ) || ! in_array( args["text_direction"], array( "ltr", "rtl" ), true ) ) then
--                 args["text_direction"] = "ltr";
--                 if ( function_exists( "is_rtl" ) && is_rtl() ) then
--                         args["text_direction"] = "rtl";
--                 end;
--         end;

--         if ( ! empty( args["charset"] ) ) then
--                 args["charset"] = _canonical_charset( args["charset"] );
--         end;

--         return array( message, title, args );
-- end;

   --------------------
   -- Wp_JSON_Encode --
   --------------------

   function Wp_JSON_Encode (Data    : Multi_Type;
                            Options : Integer := 0;
                            Depth   : Integer := 512)
                            return String
   is
      use Php.JSON;

      JSON : constant String := JSON_Encode (Data, Options, Depth);
   begin
      -- If json_encode() was successful, no need to do more sanity checking.
      if "" = JSON then -- false /=
         return JSON;
      end if;

      declare
         Data_2 : Multi_Type := Data;
      begin
         Data_2 := X_Wp_JSON_Sanity_Check (Data_2, Depth);
         return JSON_Encode (Data_2, Options, Depth);
      exception
         when others =>
            return ""; -- False;
      end;
   end Wp_JSON_Encode;

   ----------------------------
   -- X_Wp_JSON_Sanity_Check --
   ----------------------------

   function X_Wp_JSON_Sanity_Check (Data  : Multi_Type;
                                    Depth : Integer)
                                    return Multi_Type
   is
      use Php.Types;
   begin
      if Depth < 0 then
         raise Constraint_Error with "Reached depth limit";
      end if;

      case Kind_Of (Data) is

      when Kind_Array =>
         declare
            Output : Array_Type;
         begin
            for A in As_Array (Data).Iterate loop
               declare
                  Id : constant String := Key (A);
                  El : constant Multi_Type := Element (A);

                  -- Don't forget to sanitize the ID!
                  Clean_Id : String :=
                    (if Is_String (Id)
                     then X_Wp_JSON_Convert_String (Id)
                     else Id);
               begin
                  -- Check the element type, so that we're only recursing if we
                  -- really have to.
                  case Kind_Of (El) is
                  when Kind_Array => -- | Kind_Object => -- is_object (el)
                     Set (Output, Clean_Id,
                          X_Wp_JSON_Sanity_Check (El, Depth - 1));
                  when Kind_String =>
                     Set (Output, Clean_Id, From_String (
                          X_Wp_JSON_Convert_String (As_String (El))));
                  when others =>
                     Set (Output, Clean_Id, El);
                  end case;
               end;
            end loop;
            return From_Array (Output);
         end;

      -- elsif ( is_object( data ) ) then
      --           output = new stdClass;
      --           foreach ( data as id => el ) then
      --                   if ( is_string( id ) ) then
      --                           clean_id = _wp_json_convert_string( id );
      --                   end; else then
      --                           clean_id = id;
      --                   end;

      --                   if ( is_array( el ) || is_object( el ) ) then
      --                           output->clean_id = _wp_json_sanity_check( el, depth - 1 );
      --                   end; elseif ( is_string( el ) ) then
      --                           output->clean_id = _wp_json_convert_string( el );
      --                   end; else then
      --                           output->clean_id = el;
      --                   end;
      --           end;

      when Kind_String =>
         return From_String (X_Wp_JSON_Convert_String (As_String (Data)));

      when others =>
         return Data;
      end case;

--    return Output;
   end X_Wp_JSON_Sanity_Check;

   ------------------------------
   -- X_Wp_JSON_Convert_String --
   ------------------------------

   Static_Use_MB : constant Boolean := True; -- = null;

   function X_Wp_JSON_Convert_String (Item : String)
                                      return String
   is
      use Php.Multibyte;
      use Inc_Formatting;
   begin
      -- if ( is_null( use_mb ) ) then
      --    use_mb = function_exists( "mb_convert_encoding" );
      -- end if;

      if Static_Use_MB then
         declare
            Encoding : constant String :=
              MB_Detect_Encoding (Item, MB_Detect_Order, True);
         begin
            if Encoding /= "" then
               return MB_Convert_Encoding (Item, "UTF-8", Encoding);
            else
               return MB_Convert_Encoding (Item, "UTF-8", "UTF-8");
            end if;
         end;
      else
         return Wp_Check_Invalid_UTF8 (Item, True);
      end if;
   end X_Wp_JSON_Convert_String;

--
-- Prepares response data to be serialized to JSON.
--
-- This supports the JsonSerializable interface for PHP 5.2-5.3 as well.
--
-- @ignore
-- @since 4.4.0
-- @deprecated 5.3.0 This function is no longer needed as support for PHP 5.2-5.3
--                   has been dropped.
-- @access private
--
-- @param mixed data Native representation.
-- @return bool|int|float|null|string|array Data ready for `json_encode()`.
--
-- function _wp_json_prepare_data( data ) then
--         _deprecated_function( __FUNCTION__, "5.3.0" );
--         return data;
-- end;

--
-- Sends a JSON response back to an Ajax request.
--
-- @since 3.5.0
-- @since 4.7.0 The `status_code` parameter was added.
-- @since 5.6.0 The `options` parameter was added.
--
-- @param mixed response    Variable (usually an array or object) to encode as JSON,
--                           then print and die.
-- @param int   status_code Optional. The HTTP status code to output. Default null.
-- @param int   options     Optional. Options to be passed to json_encode(). Default 0.
--
-- function wp_send_json( response, status_code = null, options = 0 ) then
--         if ( defined( "REST_REQUEST" ) && REST_REQUEST ) then
--                 _doing_it_wrong(
--                         __FUNCTION__,
--                         sprintf(
--                                 /* translators: 1: WP_REST_Response, 2: WP_Error--
--                                 __( "Return a %1s or %2s object from your callback when using the REST API." ),
--                                 "WP_REST_Response",
--                                 "WP_Error"
--                         ),
--                         "5.5.0"
--                 );
--         end;

--         if ( ! headers_sent() ) then
--                 header( "Content-Type: application/json; charset=" . get_option( "blog_charset" ) );
--                 if ( null !== status_code ) then
--                         status_header( status_code );
--                 end;
--         end;

--         echo wp_json_encode( response, options );

--         if ( wp_doing_ajax() ) then
--                 wp_die(
--                         "",
--                         "",
--                         array(
--                                 "response" => null,
--                         )
--                 );
--         end; else then
--                 die;
--         end;
-- end;

--
-- Sends a JSON response back to an Ajax request, indicating success.
--
-- @since 3.5.0
-- @since 4.7.0 The `status_code` parameter was added.
-- @since 5.6.0 The `options` parameter was added.
--
-- @param mixed data        Optional. Data to encode as JSON, then print and die. Default null.
-- @param int   status_code Optional. The HTTP status code to output. Default null.
-- @param int   options     Optional. Options to be passed to json_encode(). Default 0.
--
-- function wp_send_json_success( data = null, status_code = null, options = 0 ) then
--         response = array( "success" => true );

--         if ( isset( data ) ) then
--                 response["data"] = data;
--         end;

--         wp_send_json( response, status_code, options );
-- end;

--
-- Sends a JSON response back to an Ajax request, indicating failure.
--
-- If the `data` parameter is a WP_Error object, the errors
-- within the object are processed and output as an array of error
-- codes and corresponding messages. All other types are output
-- without further processing.
--
-- @since 3.5.0
-- @since 4.1.0 The `data` parameter is now processed if a WP_Error object is passed in.
-- @since 4.7.0 The `status_code` parameter was added.
-- @since 5.6.0 The `options` parameter was added.
--
-- @param mixed data        Optional. Data to encode as JSON, then print and die. Default null.
-- @param int   status_code Optional. The HTTP status code to output. Default null.
-- @param int   options     Optional. Options to be passed to json_encode(). Default 0.
--
-- function wp_send_json_error( data = null, status_code = null, options = 0 ) then
--         response = array( "success" => false );

--         if ( isset( data ) ) then
--                 if ( is_wp_error( data ) ) then
--                         result = array();
--                         foreach ( data->errors as code => messages ) then
--                                 foreach ( messages as message ) then
--                                         result[] = array(
--                                                 "code"    => code,
--                                                 "message" => message,
--                                         );
--                                 end;
--                         end;

--                         response["data"] = result;
--                 end; else then
--                         response["data"] = data;
--                 end;
--         end;

--         wp_send_json( response, status_code, options );
-- end;

--
-- Checks that a JSONP callback is a valid JavaScript callback name.
--
-- Only allows alphanumeric characters and the dot character in callback
-- function names. This helps to mitigate XSS attacks caused by directly
-- outputting user input.
--
-- @since 4.6.0
--
-- @param string callback Supplied JSONP callback function name.
-- @return bool Whether the callback function name is valid.
--
-- function wp_check_jsonp_callback( callback ) then
--         if ( ! is_string( callback ) ) then
--                 return false;
--         end;

--         preg_replace( "/[^\w\.]/", "", callback, -1, illegal_char_count );

--         return 0 === illegal_char_count;
-- end;

   -------------------------
   -- Wp_JSON_File_Decode --
   -------------------------

   function Wp_JSON_File_Decode (Filename : String;
                                 Options  : Array_Type := Empty_Array)
                                 return Array_Type
   is
      use Hb_Common;
      use Php;
      use Php.Errors;
      use Php.Files;
      use Php.JSON;
      use Php.Strings;
      use Inc_L10n;

      Result     : Array_Type;
      Filename_2 : constant String := Wp_Normalize_Path (Realpath (Filename));
   begin
      if Filename_2 = "" then
         Trigger_Error (
           Sprintf (
              -- translators: %s: Path to the JSON file.
              abs "File %s doesn't exist!",
              To_List (Filename_2)
           )
         );
         return Result;
      end if;

      declare
         Options_2    : constant Array_Type :=
           Wp_Parse_Args (Options, To_Array (List => (1 =>
                          Build ("associative", False))));

         Decoded_File : constant Array_Type :=
           JSON_Decode (File_Get_Contents (Filename_2),
                        As_Boolean (Get (Options_2, "associative")));
      begin
         if JSON_ERROR_NONE /= JSON_Last_Error then
            Trigger_Error (
              Sprintf (
                -- translators: 1: Path to the JSON file, 2: Error message.
                abs "Error when decoding a JSON file at path %1s: %2s",
                To_List (List => (
                  1 => +Filename_2,
                  2 => +JSON_Last_Error_Msg))
              )
            );
            return Result;
         end if;

         return Decoded_File;
      end;
   end Wp_JSON_File_Decode;

--
-- Retrieves the WordPress home page URL.
--
-- If the constant named "WP_HOME" exists, then it will be used and returned
-- by the function. This can be used to counter the redirection on your local
-- development environment.
--
-- @since 2.2.0
-- @access private
--
-- @see WP_HOME
--
-- @param string url URL for the home location.
-- @return string Homepage location.
--
-- function _config_wp_home( url = "" ) then
--         if ( defined( "WP_HOME" ) ) then
--                 return untrailingslashit( WP_HOME );
--         end;
--         return url;
-- end;

--
-- Retrieves the WordPress site URL.
--
-- If the constant named "WP_SITEURL" is defined, then the value in that
-- constant will always be returned. This can be used for debugging a site
-- on your localhost while not having to change the database to your URL.
--
-- @since 2.2.0
-- @access private
--
-- @see WP_SITEURL
--
-- @param string url URL to set the WordPress site location.
-- @return string The WordPress site URL.
--
-- function _config_wp_siteurl( url = "" ) then
--         if ( defined( "WP_SITEURL" ) ) then
--                 return untrailingslashit( WP_SITEURL );
--         end;
--         return url;
-- end;

--
-- Deletes the fresh site option.
--
-- @since 4.7.0
-- @access private
--
-- function _delete_option_fresh_site() then
--         update_option( "fresh_site", "0" );
-- end;

--
-- Sets the localized direction for MCE plugin.
--
-- Will only set the direction to "rtl", if the WordPress locale has
-- the text direction set to "rtl".
--
-- Fills in the "directionality" setting, enables the "directionality"
-- plugin, and adds the "ltr" button to "toolbar1", formerly
-- "theme_advanced_buttons1" array keys. These keys are then returned
-- in the mce_init (TinyMCE settings) array.
--
-- @since 2.1.0
-- @access private
--
-- @param array mce_init MCE settings array.
-- @return array Direction set for "rtl", if needed by locale.
--
-- function _mce_set_direction( mce_init ) then
--         if ( is_rtl() ) then
--                 mce_init["directionality"] = "rtl";
--                 mce_init["rtl_ui"]         = true;

--                 if ( ! empty( mce_init["plugins"] ) && strpos( mce_init["plugins"], "directionality" ) === false ) then
--                         mce_init["plugins"] .= ",directionality";
--                 end;

--                 if ( ! empty( mce_init["toolbar1"] ) && ! preg_match( "/\bltr\b/", mce_init["toolbar1"] ) ) then
--                         mce_init["toolbar1"] .= ",ltr";
--                 end;
--         end;

--         return mce_init;
-- end;

--
-- Converts smiley code to the icon graphic file equivalent.
--
-- You can turn off smilies, by going to the write setting screen and unchecking
-- the box, or by setting "use_smilies" option to false or removing the option.
--
-- Plugins may override the default smiley list by setting the wpsmiliestrans
-- to an array, with the key the code the blogger types in and the value the
-- image file.
--
-- The wp_smiliessearch global is for the regular expression and is set each
-- time the function is called.
--
-- The full list of smilies can be found in the function and won"t be listed in
-- the description. Probably should create a Codex page for it, so that it is
-- available.
--
-- @global array wpsmiliestrans
-- @global array wp_smiliessearch
--
-- @since 2.2.0
--
-- function smilies_init() then
--         global wpsmiliestrans, wp_smiliessearch;

--         // Don"t bother setting up smilies if they are disabled.
--         if ( ! get_option( "use_smilies" ) ) then
--                 return;
--         end;

--         if ( ! isset( wpsmiliestrans ) ) then
--                 wpsmiliestrans = array(
--                         ":mrgreen:" => "mrgreen.png",
--                         ":neutral:" => "\xf0\x9f\x98\x90",
--                         ":twisted:" => "\xf0\x9f\x98\x88",
--                         ":arrow:"   => "\xe2\x9e\xa1",
--                         ":shock:"   => "\xf0\x9f\x98\xaf",
--                         ":smile:"   => "\xf0\x9f\x99\x82",
--                         ":???:"     => "\xf0\x9f\x98\x95",
--                         ":cool:"    => "\xf0\x9f\x98\x8e",
--                         ":evil:"    => "\xf0\x9f\x91\xbf",
--                         ":grin:"    => "\xf0\x9f\x98\x80",
--                         ":idea:"    => "\xf0\x9f\x92\xa1",
--                         ":oops:"    => "\xf0\x9f\x98\xb3",
--                         ":razz:"    => "\xf0\x9f\x98\x9b",
--                         ":roll:"    => "\xf0\x9f\x99\x84",
--                         ":wink:"    => "\xf0\x9f\x98\x89",
--                         ":cry:"     => "\xf0\x9f\x98\xa5",
--                         ":eek:"     => "\xf0\x9f\x98\xae",
--                         ":lol:"     => "\xf0\x9f\x98\x86",
--                         ":mad:"     => "\xf0\x9f\x98\xa1",
--                         ":sad:"     => "\xf0\x9f\x99\x81",
--                         "8-)"       => "\xf0\x9f\x98\x8e",
--                         "8-O"       => "\xf0\x9f\x98\xaf",
--                         ":-("       => "\xf0\x9f\x99\x81",
--                         ":-)"       => "\xf0\x9f\x99\x82",
--                         ":-?"       => "\xf0\x9f\x98\x95",
--                         ":-D"       => "\xf0\x9f\x98\x80",
--                         ":-P"       => "\xf0\x9f\x98\x9b",
--                         ":-o"       => "\xf0\x9f\x98\xae",
--                         ":-x"       => "\xf0\x9f\x98\xa1",
--                         ":-|"       => "\xf0\x9f\x98\x90",
--                         ";-)"       => "\xf0\x9f\x98\x89",
--                         // This one transformation breaks regular text with frequency.
--                         //     "8)" => "\xf0\x9f\x98\x8e",
--                         "8O"        => "\xf0\x9f\x98\xaf",
--                         ":("        => "\xf0\x9f\x99\x81",
--                         ":)"        => "\xf0\x9f\x99\x82",
--                         ":?"        => "\xf0\x9f\x98\x95",
--                         ":D"        => "\xf0\x9f\x98\x80",
--                         ":P"        => "\xf0\x9f\x98\x9b",
--                         ":o"        => "\xf0\x9f\x98\xae",
--                         ":x"        => "\xf0\x9f\x98\xa1",
--                         ":|"        => "\xf0\x9f\x98\x90",
--                         ";)"        => "\xf0\x9f\x98\x89",
--                         ":!:"       => "\xe2\x9d\x97",
--                         ":?:"       => "\xe2\x9d\x93",
--                 );
--         end;

--         --
--         -- Filters all the smilies.
--         --
--         -- This filter must be added before `smilies_init` is run, as
--         -- it is normally only run once to setup the smilies regex.
--         --
--         -- @since 4.7.0
--         --
--         -- @param string[] wpsmiliestrans List of the smilies" hexadecimal representations, keyed by their smily code.
--         --
--         wpsmiliestrans = apply_filters( "smilies", wpsmiliestrans );

--         if ( count( wpsmiliestrans ) == 0 ) then
--                 return;
--         end;

--         /*
--         -- NOTE: we sort the smilies in reverse key order. This is to make sure
--         -- we match the longest possible smilie (:???: vs :?) as the regular
--         -- expression used below is first-match
--         --
--         krsort( wpsmiliestrans );

--         spaces = wp_spaces_regexp();

--         // Begin first "subpattern".
--         wp_smiliessearch = "/(?<=" . spaces . "|^)";

--         subchar = "";
--         foreach ( (array) wpsmiliestrans as smiley => img ) then
--                 firstchar = substr( smiley, 0, 1 );
--                 rest      = substr( smiley, 1 );

--                 // New subpattern?
--                 if ( firstchar != subchar ) then
--                         if ( "" !== subchar ) then
--                                 wp_smiliessearch .= ")(?=" . spaces . "|)";  // End previous "subpattern".
--                                 wp_smiliessearch .= "|(?<=" . spaces . "|^)"; // Begin another "subpattern".
--                         end;
--                         subchar           = firstchar;
--                         wp_smiliessearch .= preg_quote( firstchar, "/" ) . "(?:";
--                 end; else then
--                         wp_smiliessearch .= "|";
--                 end;
--                 wp_smiliessearch .= preg_quote( rest, "/" );
--         end;

--         wp_smiliessearch .= ")(?=" . spaces . "|)/m";

-- end;

--
-- Merges user defined arguments into defaults array.
--
-- This function is used throughout WordPress to allow for both string or array
-- to be merged into another array.
--
-- @since 2.2.0
-- @since 2.3.0 `args` can now also be an object.
--
-- @param string|array|object args     Value to merge with defaults.
-- @param array               defaults Optional. Array that serves as the defaults.
--                                      Default empty array.
-- @return array Merged user defined values with defaults.
--
-- function wp_parse_args( args, defaults = array() ) then

   function Wp_Parse_Args (Args     : String;
                           Defaults : Array_Type := Empty_Array)
                           return Array_Type
   is
      use Php;
      use Php.Arrays;

      Parsed_Args : Array_Type;
   begin
      Inc_Formatting.Wp_Parse_Str (Args, Parsed_Args);

      return Array_Merge (Defaults, Parsed_Args);
   end Wp_Parse_Args;

   function Wp_Parse_Args (Args     : Array_Type;
                           Defaults : Array_Type := Empty_Array)
                           return Array_Type
   is
      use Php;
      use Php.Arrays;
      use Php.Misc;
      use Php.Types;
      use Inc_Formatting;

      Parsed_Args : Array_Type;
   begin
      if Is_Object (Args) then
         Parsed_Args := Get_Object_Vars (Args);
--    elsif Is_Array (Args) then
--       Array_Vectors.Include (Parsed_Args, New_Item => "args"); -- Args);
      else
         Wp_Parse_Str ("Args", Parsed_Args); -- args ???
      end if;

      if Is_Array (Defaults) and then not Defaults.Is_Empty then
         return Array_Merge (Defaults, Parsed_Args);
      end if;
      return Parsed_Args;
   end Wp_Parse_Args;

   -------------------
   -- Wp_Parse_Args --
   -------------------

   function Wp_Parse_Args (Args     : Boolean;
                           Defaults : Array_Type := Empty_Array)
                           return Array_Type
   is
      use Php.Arrays;

      Parsed_Args : Array_Type;
   begin
--    Parsed_Args := Get_Object_Vars (Args);

      return Array_Merge (Defaults, Parsed_Args);
   end Wp_Parse_Args;

   -------------------
   -- Wp_Parse_List --
   -------------------

   function Wp_Parse_List (List : List_Type)
                           return List_Type
   is
   begin
--    if not Is_Array (List) then
--       return Preg_Split ("/[\s,]+/", list, -1, PREG_SPLIT_NO_EMPTY);
--    end if;

      -- Validate all entries of the list are scalar.
--    list := Array_Filter (list, "is_scalar");

      return List;
   end Wp_Parse_List;

   ----------------------
   -- Wp_Parse_Id_List --
   ----------------------

   function Wp_Parse_Id_List (List : List_Type)
                              return List_Type
   is
      use Php.Lists;
      use Php.Numerics;

      List_2 : constant List_Type := Wp_Parse_List (List);
   begin
      return List_Unique (List_Map (Absint'Access, List_2));
   end Wp_Parse_Id_List;

--
-- Cleans up an array, comma- or space-separated list of slugs.
--
-- @since 4.7.0
-- @since 5.1.0 Refactored to use wp_parse_list().
--
-- @param array|string list List of slugs.
-- @return string[] Sanitized array of slugs.
--
-- function wp_parse_slug_list( list ) then
--         list = wp_parse_list( list );

--         return array_unique( array_map( "sanitize_title", list ) );
-- end;

   --------------------------
   -- Wp_Array_Slize_Assoc --
   --------------------------

   function Wp_Array_Slice_Assoc (Arry : Array_Type;
                                  Keys : List_Type)
                                  return Array_Type
   is
      use Hb_Common;

      Slice : Array_Type;
   begin
      for Key of Keys loop
         if Isset (Arry, -Key) then
            Set (Slice, -Key, Get (Arry, -Key));
         end if;
      end loop;

      return Slice;
   end Wp_Array_Slice_Assoc;

   --------------------
   -- X_Wp_Array_Get --
   --------------------

   function X_Wp_Array_Get (Arry    : Array_Type;
                            Path    : List_Type;
                            Default : Multi_Type := Null_Multi_Type)
                            return Multi_Type
   is
      use Ada.Containers;
      use Hb_Common;
      use Php;
      use Php.Arrays;
      use Php.Types;

      Arry_2 : Array_Type := Arry;
   begin
      -- Confirm path is valid.
      if not Is_Array (Path) or else 0 = Path.Length then
         return Default;
      end if;

      for Path_Element of Path loop
         if
           not Is_Array (Arry_2) or else
           (not Is_String (-Path_Element)  and then
--          not Is_Integer (Path_Element) and then
--          not Is_Null (Path_Element)
            True
           ) or else
           not Array_Key_Exists (-Path_Element, Arry_2)
         then
            return Default;
         end if;
         Arry_2 := As_Array (Get (Arry_2, -Path_Element));
      end loop;

      return From_Array (Arry_2);
   end X_Wp_Array_Get;

   --------------------
   -- X_Wp_Array_Set --
   --------------------

   procedure X_Wp_Array_Set (Arry  : in out Array_Type;
                             Path  : List_Type;
                             Value : Multi_Type)
   is
      use Hb_Common;
      use Php;
      use Php.Arrays;

      Arry_2 : Array_Type := Arry;

      Path_Length : constant Natural := Natural (Path.Length);
      I_2 : Natural;
   begin
      -- -- Confirm array is valid.
      -- if not is_array( array ) then
      --    return;
      -- end if;

      -- -- Confirm path is valid.
      -- if not is_array( path ) then
      --    return;
      -- end if;

      if 0 = Path_Length then
         return;
      end if;

      -- for Path_Element of Path loop
      --    if
      --      ! is_string( path_element ) && ! is_integer( path_element ) &&
      --      ! is_null( path_element )
      --    then
      --       return;
      --    end if;
      -- end loop;

      for I in 0 .. Path_Length - 1 loop
         declare
            Path_Element : constant String := -Path (I);
         begin
            if
              not Array_Key_Exists (Path_Element, Arry_2) or else
              Kind_Of (Get (Arry_2, Path_Element)) /= Kind_Array
            then
               Set (Arry_2, Path_Element, From_Array (Empty_Array));
            end if;
            Arry_2 := As_Array (Get (Arry_2, Path_Element));
            -- phpcs:ignore VariableAnalysis.CodeAnalysis.VariableAnalysis.VariableRedeclaration
         end;
         I_2 := I;
      end loop;

      Set (Arry_2, -Path (I_2), Value);
   end X_Wp_Array_Set;

   ------------------------
   -- X_Wp_To_Kebab_Case --
   ------------------------

   function X_Wp_To_Kebab_Case (Item : String)
                                return String
   is
      use Hb_Common;
      use Php;
      use Php.Preg;
      use Php.Strings;

      -- phpcs:disable WordPress.NamingConventions.ValidVariableName.VariableNotSnakeCase
      -- ignore the camelCase names for variables so the names are the same as lodash
      -- so comparing and porting new changes is easier.

      --
      -- Some notable things we"ve removed compared to the lodash version are:
      --
      -- - non-alphanumeric characters: rsAstralRange, rsEmoji, etc
      -- - the groups that processed the apostrophe, as it"s removed before passing
      --   the string to preg_match: rsApos, rsOptContrLower, and rsOptContrUpper
      --
      --

      -- Used to compose unicode character classes.
      Rs_Lower_Range       : constant String := "a-z\\xdf-\\xf6\\xf8-\\xff";
      Rs_Non_Char_Range    : constant String := "\\x00-\\x2f\\x3a-\\x40\\x5b-\\x60\\x7b-\\xbf";
      Rs_Punctuation_Range : constant String := "\\x{2000}-\\x{206f}";
      Rs_Space_Range       : constant String := " \\t\\x0b\\f\\xa0\\x{feff}\\n\\r\\x{2028}\\x{2029}\\x{1680}\\x{180e}\\x{2000}\\x{2001}\\x{2002}\\x{2003}\\x{2004}\\x{2005}\\x{2006}\\x{2007}\\x{2008}\\x{2009}\\x{200a}\\x{202f}\\x{205f}\\x{3000}";
      Rs_Upper_Range       : constant String := "A-Z\\xc0-\\xd6\\xd8-\\xde";
      Rs_Break_Range       : constant String := Rs_Non_Char_Range & Rs_Punctuation_Range & Rs_Space_Range;

      -- Used to compose unicode capture groups.
      Rs_Break  : constant String := "[" & Rs_Break_Range & "]";
      Rs_Digits : constant String := "\\d+";
      -- The last lodash version in GitHub uses a single digit here and expands it when in use.
      Rs_Lower  : constant String := "[" & Rs_Lower_Range & "]";
      Rs_Misc   : constant String := "[^" & Rs_Break_Range & Rs_Digits & Rs_Lower_Range & Rs_Upper_Range & "]";
      Rs_Upper  : constant String := "[" & Rs_Upper_Range & "]";

      -- Used to compose unicode regexes.--
      Rs_Misc_Lower : constant String := "(?:" & Rs_Lower & "|" & Rs_Misc & ")";
      Rs_Misc_Upper : constant String := "(?:" & Rs_Upper & "|" & Rs_Misc & ")";
      Rs_Ord_Lower  : constant String := "\\d*(?:1st|2nd|3rd|(?![123])\\dth)(?=\\b|[A-Z_])";
      Rs_Ord_Upper  : constant String := "\\d*(?:1ST|2ND|3RD|(?![123])\\dTH)(?=\\b|[a-z_])";

      Regexp : constant String := "/" & Implode (
                "|",
                To_List (List => (
                        +(Rs_Upper & "?" & Rs_Lower & "+" & "(?=" & Implode ("|", To_List (List => (+Rs_Break, +Rs_Upper, +""))) & ")"),
                        +(Rs_Misc_Upper & "+" & "(?=" & Implode ("|", To_List (List => (+Rs_Break, +(Rs_Upper & Rs_Misc_Lower), +""))) & ")"),
                        +(Rs_Upper & "?" & Rs_Misc_Lower & "+"),
                        +(Rs_Upper & "+"),
                        +Rs_Ord_Upper,
                        +Rs_Ord_Lower,
                        +Rs_Digits
                ))
      ) & "/u";

      Matches : Array_Type;
      Unused  : Integer;
   begin
      Unused := Preg_Match_All (Regexp, Str_Replace ("'", "", Item), Matches);
      return Strtolower (Implode ("-", As_String (Matches.First_Element)));
      -- phpcs:enable WordPress.NamingConventions.ValidVariableName.VariableNotSnakeCase
   end X_Wp_To_Kebab_Case;

--
-- Determines if the variable is a numeric-indexed array.
--
-- @since 4.4.0
--
-- @param mixed data Variable to check.
-- @return bool Whether the variable is a list.
--
-- function wp_is_numeric_array( data ) then
--         if ( ! is_array( data ) ) then
--                 return false;
--         end;

--         keys        = array_keys( data );
--         string_keys = array_filter( keys, "is_string" );

--         return count( string_keys ) === 0;
-- end;

--
-- Filters a list of objects, based on a set of key => value arguments.
--
-- Retrieves the objects from the list that match the given arguments.
-- Key represents property name, and value represents property value.
--
-- If an object has more properties than those specified in arguments,
-- that will not disqualify it. When using the "AND" operator,
-- any missing properties will disqualify it.
--
-- When using the `field` argument, this function can also retrieve
-- a particular field from all matching objects, whereas wp_list_filter()
-- only does the filtering.
--
-- @since 3.0.0
-- @since 4.7.0 Uses `WP_List_Util` class.
--
-- @param array       list     An array of objects to filter.
-- @param array       args     Optional. An array of key => value arguments to match
--                              against each object. Default empty array.
-- @param string      operator Optional. The logical operation to perform. "AND" means
--                              all elements from the array must match. "OR" means only
--                              one element needs to match. "NOT" means no elements may
--                              match. Default "AND".
-- @param bool|string field    Optional. A field from the object to place instead
--                              of the entire object. Default false.
-- @return array A list of objects or object fields.
--
-- function wp_filter_object_list( list, args = array(), operator = "and", field = false ) then
--         if ( ! is_array( list ) ) then
--                 return array();
--         end;

--         util = new WP_List_Util( list );

--         util->filter( args, operator );

--         if ( field ) then
--                 util->pluck( field );
--         end;

--         return util->get_output();
-- end;

--
-- Filters a list of objects, based on a set of key => value arguments.
--
-- Retrieves the objects from the list that match the given arguments.
-- Key represents property name, and value represents property value.
--
-- If an object has more properties than those specified in arguments,
-- that will not disqualify it. When using the "AND" operator,
-- any missing properties will disqualify it.
--
-- If you want to retrieve a particular field from all matching objects,
-- use wp_filter_object_list() instead.
--
-- @since 3.1.0
-- @since 4.7.0 Uses `WP_List_Util` class.
-- @since 5.9.0 Converted into a wrapper for `wp_filter_object_list()`.
--
-- @param array  list     An array of objects to filter.
-- @param array  args     Optional. An array of key => value arguments to match
--                         against each object. Default empty array.
-- @param string operator Optional. The logical operation to perform. "AND" means
--                         all elements from the array must match. "OR" means only
--                         one element needs to match. "NOT" means no elements may
--                         match. Default "AND".
-- @return array Array of found values.
--
-- function wp_list_filter( list, args = array(), operator = "AND" ) then
--         return wp_filter_object_list( list, args, operator );
-- end;

--
-- Plucks a certain field out of each object or array in an array.
--
-- This has the same functionality and prototype of
-- array_column() (PHP 5.5) but also supports objects.
--
-- @since 3.1.0
-- @since 4.0.0 index_key parameter added.
-- @since 4.7.0 Uses `WP_List_Util` class.
--
-- @param array      list      List of objects or arrays.
-- @param int|string field     Field from the object to place instead of the entire object.
-- @param int|string index_key Optional. Field from the object to use as keys for the new array.
--                              Default null.
-- @return array Array of found values. If `index_key` is set, an array of found values with keys
--               corresponding to `index_key`. If `index_key` is null, array keys from the original
--               `list` will be preserved in the results.
--
-- function wp_list_pluck( list, field, index_key = null ) then

   function Wp_List_Pluck (List      : Array_Type;
                           Field     : String;
                           Index_Key : String := "")  -- null)
                           return Array_Type
   is
   begin
 --     if not Is_Array (List) then
 --        return Empty_Array;
 --     end if;

      declare
         use Inc_Class_Wp_List_Util;

         Util : constant Wp_List_Util := X_Construct (List);
         -- = new WP_List_Util( list );
      begin
         return Util.Pluck (Field, Index_Key);
      end;
   end Wp_List_Pluck;

   ------------------
   -- Wp_List_Sort --
   ------------------

   function Wp_List_Sort (List          : List_Type;
                          Orderby       : String := ""; -- = array(),
                          Order         : String := "ASC";
                          Preserve_Keys : Boolean := False)
                          return List_Type
   is
   begin
      raise Program_Error with "not implemented";
      return Empty_List;
      -- if not Is_Array (List) then
      --    return Empty_List;
      -- end if;

      -- util = new WP_List_Util( list );

      -- return util->sort( orderby, order, preserve_keys );
   end Wp_List_Sort;

--
-- Determines if Widgets library should be loaded.
--
-- Checks to make sure that the widgets library hasn"t already been loaded.
-- If it hasn"t, then it will load the widgets library and run an action hook.
--
-- @since 2.2.0
--
-- function wp_maybe_load_widgets() then
--         --
--         -- Filters whether to load the Widgets library.
--         --
--         -- Returning a falsey value from the filter will effectively short-circuit
--         -- the Widgets library from loading.
--         --
--         -- @since 2.8.0
--         --
--         -- @param bool wp_maybe_load_widgets Whether to load the Widgets library.
--         --                                    Default true.
--         --
--         if ( ! apply_filters( "load_default_widgets", true ) ) then
--                 return;
--         end;

--         require_once ABSPATH . WPINC . "/default-widgets.php";

--         add_action( "_admin_menu", "wp_widgets_add_menu" );
-- end;

--
-- Appends the Widgets menu to the themes main menu.
--
-- @since 2.2.0
-- @since 5.9.3 Don"t specify menu order when the active theme is a block theme.
--
-- @global array submenu
--
-- function wp_widgets_add_menu() then
--         global submenu;

--         if ( ! current_theme_supports( "widgets" ) ) then
--                 return;
--         end;

--         menu_name = __( "Widgets" );
--         if ( wp_is_block_theme() || current_theme_supports( "block-template-parts" ) ) then
--                 submenu["themes.php"][] = array( menu_name, "edit_theme_options", "widgets.php" );
--         end; else then
--                 submenu["themes.php"][7] = array( menu_name, "edit_theme_options", "widgets.php" );
--         end;

--         ksort( submenu["themes.php"], SORT_NUMERIC );
-- end;

--
-- Flushes all output buffers for PHP 5.2.
--
-- Make sure all output buffers are flushed before our singletons are destroyed.
--
-- @since 2.2.0
--
-- function wp_ob_end_flush_all() then
--         levels = ob_get_level();
--         for ( i = 0; i < levels; i++ ) then
--                 ob_end_flush();
--         end;
-- end;

   -------------
   -- Dead_DB --
   -------------

   procedure Dead_Db
   is null;
--         global wpdb;

--         wp_load_translations_early();

--         // Load custom DB error template, if present.
--         if ( file_exists( WP_CONTENT_DIR . "/db-error.php" ) ) then
--                 require_once WP_CONTENT_DIR . "/db-error.php";
--                 die();
--         end;

--         // If installing or in the admin, provide the verbose message.
--         if ( wp_installing() || defined( "WP_ADMIN" ) ) then
--                 wp_die( wpdb->error );
--         end;

--         // Otherwise, be terse.
--         wp_die( "<h1>" . __( "Error establishing a database connection" ) . "</h1>", __( "Database Error" ) );
-- end;

--
-- Converts a value to non-negative integer.
--
-- @since 2.5.0
--
-- @param mixed maybeint Data you wish to have converted to a non-negative integer.
-- @return int A non-negative integer.
--
-- function absint( maybeint ) then
--         return abs( (int) maybeint );
-- end;

--
-- Marks a function as deprecated and inform when it has been used.
--
-- There is a hook {@see "deprecated_function_run"} that will be called that can be used
-- to get the backtrace up to what file and function called the deprecated
-- function.
--
-- The current behavior is to trigger a user error if `WP_DEBUG` is true.
--
-- This function is to be used in every function that is deprecated.
--
-- @since 2.5.0
-- @since 5.4.0 This function is no longer marked as "private".
-- @since 5.4.0 The error type is now classified as E_USER_DEPRECATED (used to default to E_USER_NOTICE).
--
-- @param string function    The function that was called.
-- @param string version     The version of WordPress that deprecated the function.
-- @param string replacement Optional. The function that should have been called. Default empty.
--
-- function _deprecated_function( function, version, replacement = "" ) then

--         --
--         -- Fires when a deprecated function is called.
--         --
--         -- @since 2.5.0
--         --
--         -- @param string function    The function that was called.
--         -- @param string replacement The function that should have been called.
--         -- @param string version     The version of WordPress that deprecated the function.
--         --
--         do_action( "deprecated_function_run", function, replacement, version );

--         --
--         -- Filters whether to trigger an error for deprecated functions.
--         --
--         -- @since 2.5.0
--         --
--         -- @param bool trigger Whether to trigger the error for deprecated functions. Default true.
--         --
--         if ( WP_DEBUG && apply_filters( "deprecated_function_trigger_error", true ) ) then
--                 if ( function_exists( "__" ) ) then
--                         if ( replacement ) then
--                                 trigger_error(
--                                         sprintf(
--                                                 /* translators: 1: PHP function name, 2: Version number, 3: Alternative function name.--
--                                                 __( "Function %1s is <strong>deprecated</strong> since version %2s! Use %3s instead." ),
--                                                 function,
--                                                 version,
--                                                 replacement
--                                         ),
--                                         E_USER_DEPRECATED
--                                 );
--                         end; else then
--                                 trigger_error(
--                                         sprintf(
--                                                 /* translators: 1: PHP function name, 2: Version number.--
--                                                 __( "Function %1s is <strong>deprecated</strong> since version %2s with no alternative available." ),
--                                                 function,
--                                                 version
--                                         ),
--                                         E_USER_DEPRECATED
--                                 );
--                         end;
--                 end; else then
--                         if ( replacement ) then
--                                 trigger_error(
--                                         sprintf(
--                                                 "Function %1s is <strong>deprecated</strong> since version %2s! Use %3s instead.",
--                                                 function,
--                                                 version,
--                                                 replacement
--                                         ),
--                                         E_USER_DEPRECATED
--                                 );
--                         end; else then
--                                 trigger_error(
--                                         sprintf(
--                                                 "Function %1s is <strong>deprecated</strong> since version %2s with no alternative available.",
--                                                 function,
--                                                 version
--                                         ),
--                                         E_USER_DEPRECATED
--                                 );
--                         end;
--                 end;
--         end;
-- end;

--
-- Marks a constructor as deprecated and informs when it has been used.
--
-- Similar to _deprecated_function(), but with different strings. Used to
-- remove PHP4 style constructors.
--
-- The current behavior is to trigger a user error if `WP_DEBUG` is true.
--
-- This function is to be used in every PHP4 style constructor method that is deprecated.
--
-- @since 4.3.0
-- @since 4.5.0 Added the `parent_class` parameter.
-- @since 5.4.0 This function is no longer marked as "private".
-- @since 5.4.0 The error type is now classified as E_USER_DEPRECATED (used to default to E_USER_NOTICE).
--
-- @param string class        The class containing the deprecated constructor.
-- @param string version      The version of WordPress that deprecated the function.
-- @param string parent_class Optional. The parent class calling the deprecated constructor.
--                             Default empty string.
--
-- function _deprecated_constructor( class, version, parent_class = "" ) then

--         --
--         -- Fires when a deprecated constructor is called.
--         --
--         -- @since 4.3.0
--         -- @since 4.5.0 Added the `parent_class` parameter.
--         --
--         -- @param string class        The class containing the deprecated constructor.
--         -- @param string version      The version of WordPress that deprecated the function.
--         -- @param string parent_class The parent class calling the deprecated constructor.
--         --
--         do_action( "deprecated_constructor_run", class, version, parent_class );

--         --
--         -- Filters whether to trigger an error for deprecated functions.
--         --
--         -- `WP_DEBUG` must be true in addition to the filter evaluating to true.
--         --
--         -- @since 4.3.0
--         --
--         -- @param bool trigger Whether to trigger the error for deprecated functions. Default true.
--         --
--         if ( WP_DEBUG && apply_filters( "deprecated_constructor_trigger_error", true ) ) then
--                 if ( function_exists( "__" ) ) then
--                         if ( parent_class ) then
--                                 trigger_error(
--                                         sprintf(
--                                                 /* translators: 1: PHP class name, 2: PHP parent class name, 3: Version number, 4: __construct() method.--
--                                                 __( "The called constructor method for %1s class in %2s is <strong>deprecated</strong> since version %3s! Use %4s instead." ),
--                                                 class,
--                                                 parent_class,
--                                                 version,
--                                                 "<code>__construct()</code>"
--                                         ),
--                                         E_USER_DEPRECATED
--                                 );
--                         end; else then
--                                 trigger_error(
--                                         sprintf(
--                                                 /* translators: 1: PHP class name, 2: Version number, 3: __construct() method.--
--                                                 __( "The called constructor method for %1s class is <strong>deprecated</strong> since version %2s! Use %3s instead." ),
--                                                 class,
--                                                 version,
--                                                 "<code>__construct()</code>"
--                                         ),
--                                         E_USER_DEPRECATED
--                                 );
--                         end;
--                 end; else then
--                         if ( parent_class ) then
--                                 trigger_error(
--                                         sprintf(
--                                                 "The called constructor method for %1s class in %2s is <strong>deprecated</strong> since version %3s! Use %4s instead.",
--                                                 class,
--                                                 parent_class,
--                                                 version,
--                                                 "<code>__construct()</code>"
--                                         ),
--                                         E_USER_DEPRECATED
--                                 );
--                         end; else then
--                                 trigger_error(
--                                         sprintf(
--                                                 "The called constructor method for %1s class is <strong>deprecated</strong> since version %2s! Use %3s instead.",
--                                                 class,
--                                                 version,
--                                                 "<code>__construct()</code>"
--                                         ),
--                                         E_USER_DEPRECATED
--                                 );
--                         end;
--                 end;
--         end;

-- end;

--
-- Marks a file as deprecated and inform when it has been used.
--
-- There is a hook {@see "deprecated_file_included"} that will be called that can be used
-- to get the backtrace up to what file and function included the deprecated
-- file.
--
-- The current behavior is to trigger a user error if `WP_DEBUG` is true.
--
-- This function is to be used in every file that is deprecated.
--
-- @since 2.5.0
-- @since 5.4.0 This function is no longer marked as "private".
-- @since 5.4.0 The error type is now classified as E_USER_DEPRECATED (used to default to E_USER_NOTICE).
--
-- @param string file        The file that was included.
-- @param string version     The version of WordPress that deprecated the file.
-- @param string replacement Optional. The file that should have been included based on ABSPATH.
--                            Default empty.
-- @param string message     Optional. A message regarding the change. Default empty.
--
-- function _deprecated_file( file, version, replacement = "", message = "" ) then

--         --
--         -- Fires when a deprecated file is called.
--         --
--         -- @since 2.5.0
--         --
--         -- @param string file        The file that was called.
--         -- @param string replacement The file that should have been included based on ABSPATH.
--         -- @param string version     The version of WordPress that deprecated the file.
--         -- @param string message     A message regarding the change.
--         --
--         do_action( "deprecated_file_included", file, replacement, version, message );

--         --
--         -- Filters whether to trigger an error for deprecated files.
--         --
--         -- @since 2.5.0
--         --
--         -- @param bool trigger Whether to trigger the error for deprecated files. Default true.
--         --
--         if ( WP_DEBUG && apply_filters( "deprecated_file_trigger_error", true ) ) then
--                 message = empty( message ) ? "" : " " . message;

--                 if ( function_exists( "__" ) ) then
--                         if ( replacement ) then
--                                 trigger_error(
--                                         sprintf(
--                                                 /* translators: 1: PHP file name, 2: Version number, 3: Alternative file name.--
--                                                 __( "File %1s is <strong>deprecated</strong> since version %2s! Use %3s instead." ),
--                                                 file,
--                                                 version,
--                                                 replacement
--                                         ) . message,
--                                         E_USER_DEPRECATED
--                                 );
--                         end; else then
--                                 trigger_error(
--                                         sprintf(
--                                                 /* translators: 1: PHP file name, 2: Version number.--
--                                                 __( "File %1s is <strong>deprecated</strong> since version %2s with no alternative available." ),
--                                                 file,
--                                                 version
--                                         ) . message,
--                                         E_USER_DEPRECATED
--                                 );
--                         end;
--                 end; else then
--                         if ( replacement ) then
--                                 trigger_error(
--                                         sprintf(
--                                                 "File %1s is <strong>deprecated</strong> since version %2s! Use %3s instead.",
--                                                 file,
--                                                 version,
--                                                 replacement
--                                         ) . message,
--                                         E_USER_DEPRECATED
--                                 );
--                         end; else then
--                                 trigger_error(
--                                         sprintf(
--                                                 "File %1s is <strong>deprecated</strong> since version %2s with no alternative available.",
--                                                 file,
--                                                 version
--                                         ) . message,
--                                         E_USER_DEPRECATED
--                                 );
--                         end;
--                 end;
--         end;
-- end;

--
-- Marks a function argument as deprecated and inform when it has been used.
--
-- This function is to be used whenever a deprecated function argument is used.
-- Before this function is called, the argument must be checked for whether it was
-- used by comparing it to its default value or evaluating whether it is empty.
-- For example:
--
--     if ( ! empty( deprecated ) ) then
--         _deprecated_argument( __FUNCTION__, "3.0.0" );
--     end;
--
-- There is a hook deprecated_argument_run that will be called that can be used
-- to get the backtrace up to what file and function used the deprecated
-- argument.
--
-- The current behavior is to trigger a user error if WP_DEBUG is true.
--
-- @since 3.0.0
-- @since 5.4.0 This function is no longer marked as "private".
-- @since 5.4.0 The error type is now classified as E_USER_DEPRECATED (used to default to E_USER_NOTICE).
--
-- @param string function The function that was called.
-- @param string version  The version of WordPress that deprecated the argument used.
-- @param string message  Optional. A message regarding the change. Default empty.
--
-- function _deprecated_argument( function, version, message = "" ) then

--         --
--         -- Fires when a deprecated argument is called.
--         --
--         -- @since 3.0.0
--         --
--         -- @param string function The function that was called.
--         -- @param string message  A message regarding the change.
--         -- @param string version  The version of WordPress that deprecated the argument used.
--         --
--         do_action( "deprecated_argument_run", function, message, version );

--         --
--         -- Filters whether to trigger an error for deprecated arguments.
--         --
--         -- @since 3.0.0
--         --
--         -- @param bool trigger Whether to trigger the error for deprecated arguments. Default true.
--         --
--         if ( WP_DEBUG && apply_filters( "deprecated_argument_trigger_error", true ) ) then
--                 if ( function_exists( "__" ) ) then
--                         if ( message ) then
--                                 trigger_error(
--                                         sprintf(
--                                                 /* translators: 1: PHP function name, 2: Version number, 3: Optional message regarding the change.--
--                                                 __( "Function %1s was called with an argument that is <strong>deprecated</strong> since version %2s! %3s" ),
--                                                 function,
--                                                 version,
--                                                 message
--                                         ),
--                                         E_USER_DEPRECATED
--                                 );
--                         end; else then
--                                 trigger_error(
--                                         sprintf(
--                                                 /* translators: 1: PHP function name, 2: Version number.--
--                                                 __( "Function %1s was called with an argument that is <strong>deprecated</strong> since version %2s with no alternative available." ),
--                                                 function,
--                                                 version
--                                         ),
--                                         E_USER_DEPRECATED
--                                 );
--                         end;
--                 end; else then
--                         if ( message ) then
--                                 trigger_error(
--                                         sprintf(
--                                                 "Function %1s was called with an argument that is <strong>deprecated</strong> since version %2s! %3s",
--                                                 function,
--                                                 version,
--                                                 message
--                                         ),
--                                         E_USER_DEPRECATED
--                                 );
--                         end; else then
--                                 trigger_error(
--                                         sprintf(
--                                                 "Function %1s was called with an argument that is <strong>deprecated</strong> since version %2s with no alternative available.",
--                                                 function,
--                                                 version
--                                         ),
--                                         E_USER_DEPRECATED
--                                 );
--                         end;
--                 end;
--         end;
-- end;

--
-- Marks a deprecated action or filter hook as deprecated and throws a notice.
--
-- Use the {@see "deprecated_hook_run"} action to get the backtrace describing where
-- the deprecated hook was called.
--
-- Default behavior is to trigger a user error if `WP_DEBUG` is true.
--
-- This function is called by the do_action_deprecated() and apply_filters_deprecated()
-- functions, and so generally does not need to be called directly.
--
-- @since 4.6.0
-- @since 5.4.0 The error type is now classified as E_USER_DEPRECATED (used to default to E_USER_NOTICE).
-- @access private
--
-- @param string hook        The hook that was used.
-- @param string version     The version of WordPress that deprecated the hook.
-- @param string replacement Optional. The hook that should have been used. Default empty.
-- @param string message     Optional. A message regarding the change. Default empty.
--
-- function _deprecated_hook( hook, version, replacement = "", message = "" ) then
--         --
--         -- Fires when a deprecated hook is called.
--         --
--         -- @since 4.6.0
--         --
--         -- @param string hook        The hook that was called.
--         -- @param string replacement The hook that should be used as a replacement.
--         -- @param string version     The version of WordPress that deprecated the argument used.
--         -- @param string message     A message regarding the change.
--         --
--         do_action( "deprecated_hook_run", hook, replacement, version, message );

--         --
--         -- Filters whether to trigger deprecated hook errors.
--         --
--         -- @since 4.6.0
--         --
--         -- @param bool trigger Whether to trigger deprecated hook errors. Requires
--         --                      `WP_DEBUG` to be defined true.
--         --
--         if ( WP_DEBUG && apply_filters( "deprecated_hook_trigger_error", true ) ) then
--                 message = empty( message ) ? "" : " " . message;

--                 if ( replacement ) then
--                         trigger_error(
--                                 sprintf(
--                                         /* translators: 1: WordPress hook name, 2: Version number, 3: Alternative hook name.--
--                                         __( "Hook %1s is <strong>deprecated</strong> since version %2s! Use %3s instead." ),
--                                         hook,
--                                         version,
--                                         replacement
--                                 ) . message,
--                                 E_USER_DEPRECATED
--                         );
--                 end; else then
--                         trigger_error(
--                                 sprintf(
--                                         /* translators: 1: WordPress hook name, 2: Version number.--
--                                         __( "Hook %1s is <strong>deprecated</strong> since version %2s with no alternative available." ),
--                                         hook,
--                                         version
--                                 ) . message,
--                                 E_USER_DEPRECATED
--                         );
--                 end;
--         end;
-- end;

   ----------------------
   -- X_Doing_It_Wrong --
   ----------------------

   procedure X_Doing_It_Wrong (Funct   : String;
                               Message : String;
                               Version : String)
   is
      use Php.Errors;
      use Php.Misc;
      use Php.Strings;
      use Hb_Common;
      use Wp_Common;
      use Inc_L10n;
      use Inc_Plugins;

      Message_2 : Unbounded_String := +Message;
      Version_2 : Unbounded_String := +Version;
   begin
      --
      -- Fires when the given function is being used incorrectly.
      --
      -- @since 3.1.0
      --
      -- @param string function The function that was called.
      -- @param string message  A message explaining what has been done incorrectly.
      -- @param string version  The version of WordPress where the message was added.
      --
      Do_Action ("doing_it_wrong_run", Funct, -Message_2, -Version_2);

      --
      -- Filters whether to trigger an error for _doing_it_wrong() calls.
      --
      -- @since 3.1.0
      -- @since 5.1.0 Added the function, message and version parameters.
      --
      -- @param bool   trigger  Whether to trigger the error for _doing_it_wrong()
      --                        calls. Default true.
      -- @param string function The function that was called.
      -- @param string message  A message explaining what has been done incorrectly.
      -- @param string version  The version of WordPress where the message was added.
      --
      if
        Globals.WP_DEBUG and then
        Apply_Filters ("doing_it_wrong_trigger_error", True,
                       Funct, -Message_2, -Version_2)
      then
         if Function_Exists ("__") then
            if Version_2 /= "" then
               -- translators: %s: Version number.
               Version_2 := +Sprintf (abs "(This message was added in version %s.)",
                                      To_List (-Version_2));
            end if;

            Append (Message_2, " " & Sprintf (
               -- translators: %s: Documentation URL.
               abs "Please see <a href=""%s"">Debugging in WordPress</a> for more information.",
               To_List (abs "https://wordpress.org/support/article/debugging-in-wordpress/")
            ));

            Trigger_Error (
              Sprintf (
                -- translators: Developer debugging message. 1: PHP function name, 2: Explanatory message, 3: WordPress version number.
                abs "Function %1s was called <strong>incorrectly</strong>. %2s %3s",
                To_List (List => (
                  1 => +Funct,
                  2 => Message_2,
                  3 => Version_2
                ))
              ),
              E_USER_NOTICE
            );
         else
            if Version_2 /= "" then
               Version_2 := +Sprintf ("(This message was added in version %s.)",
                                      To_List (-Version_2));
            end if;

            Append (Message_2, Sprintf (
              " Please see <a href=""%s"">Debugging in WordPress</a> for more information.",
              To_List ("https://wordpress.org/support/article/debugging-in-wordpress/")
            ));

            Trigger_Error (
              Sprintf (
                "Function %1s was called <strong>incorrectly</strong>. %2s %3s",
                To_List (List => (
                  1 => +Funct,
                  2 => Message_2,
                  3 => Version_2
                ))
              ),
              E_USER_NOTICE
            );
         end if;
      end if;
   end X_Doing_It_Wrong;

--
-- Determines whether the server is running an earlier than 1.5.0 version of lighttpd.
--
-- @since 2.5.0
--
-- @return bool Whether the server is running lighttpd < 1.5.0.
--
-- function is_lighttpd_before_150() then
--         server_parts    = explode( "/", isset( _SERVER["SERVER_SOFTWARE"] ) ? _SERVER["SERVER_SOFTWARE"] : "" );
--         server_parts[1] = isset( server_parts[1] ) ? server_parts[1] : "";

--         return ( "lighttpd" === server_parts[0] && -1 == version_compare( server_parts[1], "1.5.0" ) );
-- end;

--
-- Determines whether the specified module exist in the Apache config.
--
-- @since 2.5.0
--
-- @global bool is_apache
--
-- @param string mod     The module, e.g. mod_rewrite.
-- @param bool   default Optional. The default return value if the module is not found. Default false.
-- @return bool Whether the specified module is loaded.
--
-- function apache_mod_loaded( mod, default = false ) then
--         global is_apache;

--         if ( ! is_apache ) then
--                 return false;
--         end;

--         loaded_mods = array();

--         if ( function_exists( "apache_get_modules" ) ) then
--                 loaded_mods = apache_get_modules();

--                 if ( in_array( mod, loaded_mods, true ) ) then
--                         return true;
--                 end;
--         end;

--         if ( empty( loaded_mods )
--                 && function_exists( "phpinfo" )
--                 && false === strpos( ini_get( "disable_functions" ), "phpinfo" )
--         ) then
--                 ob_start();
--                 phpinfo( INFO_MODULES );
--                 phpinfo = ob_get_clean();

--                 if ( false !== strpos( phpinfo, mod ) ) then
--                         return true;
--                 end;
--         end;

--         return default;
-- end;

--
-- Checks if IIS 7+ supports pretty permalinks.
--
-- @since 2.8.0
--
-- @global bool is_iis7
--
-- @return bool Whether IIS7 supports permalinks.
--
-- function iis7_supports_permalinks() then
--         global is_iis7;

--         supports_permalinks = false;
--         if ( is_iis7 ) then
--                 /* First we check if the DOMDocument class exists. If it does not exist, then we cannot
--                 -- easily update the xml configuration file, hence we just bail out and tell user that
--                 -- pretty permalinks cannot be used.
--                 --
--                 -- Next we check if the URL Rewrite Module 1.1 is loaded and enabled for the web site. When
--                 -- URL Rewrite 1.1 is loaded it always sets a server variable called "IIS_UrlRewriteModule".
--                 -- Lastly we make sure that PHP is running via FastCGI. This is important because if it runs
--                 -- via ISAPI then pretty permalinks will not work.
--                 --
--                 supports_permalinks = class_exists( "DOMDocument", false ) && isset( _SERVER["IIS_UrlRewriteModule"] ) && ( "cgi-fcgi" === PHP_SAPI );
--         end;

--         --
--         -- Filters whether IIS 7+ supports pretty permalinks.
--         --
--         -- @since 2.8.0
--         --
--         -- @param bool supports_permalinks Whether IIS7 supports permalinks. Default false.
--         --
--         return apply_filters( "iis7_supports_permalinks", supports_permalinks );
-- end;

   -------------------
   -- Validate_File --
   -------------------

   function Validate_File (File          : String;
                           Allowed_Files : Array_Type := Empty_Array)
                           return Integer
   is (raise Program_Error with "not implemented");
--         if ( ! is_scalar( file ) || "" === file ) then
--                 return 0;
--         end;

--         // `../` on its own is not allowed:
--         if ( "../" === file ) then
--                 return 1;
--         end;

--         // More than one occurrence of `../` is not allowed:
--         if ( preg_match_all( "#\.\./#", file, matches, PREG_SET_ORDER ) && ( count( matches ) > 1 ) ) then
--                 return 1;
--         end;

--         // `../` which does not occur at the end of the path is not allowed:
--         if ( false !== strpos( file, "../" ) && "../" !== mb_substr( file, -3, 3 ) ) then
--                 return 1;
--         end;

--         // Files not in the allowed file list are not allowed:
--         if ( ! empty( allowed_files ) && ! in_array( file, allowed_files, true ) ) then
--                 return 3;
--         end;

--         // Absolute Windows drive paths are not allowed:
--         if ( ":" === substr( file, 1, 1 ) ) then
--                 return 2;
--         end;

--         return 0;
-- end;

   ---------------------
   -- Force_SSL_Admin --
   ---------------------
   Static_Forced : Boolean := False;

   function Force_SSL_Admin (Force : Boolean := False) -- = null )
                             return Boolean
   is
   begin
      if Force then -- not Is_Null (Force) then
         declare
            Old_Forced : constant Boolean := Static_Forced;
         begin
            Static_Forced := Force;
            return Old_Forced;
         end;
      end if;

      return Static_Forced;
   end Force_SSL_Admin;

   ------------------
   -- Wp_Guess_URL --
   ------------------

   function Wp_Guess_URL
            return String
   is
      use Hb_Common;
      use Php;
      use Php.Strings;

      URL : Unbounded_String;
   begin
      if -- defined( "WP_SITEURL" ) and then
        "" /= Globals.WP_SITEURL
      then
         URL := +Globals.WP_SITEURL;
      else
         null;
--                 abspath_fix         = str_replace( "\\", "/", ABSPATH );
--                 script_filename_dir = dirname( _SERVER["SCRIPT_FILENAME"] );

--                 // The request is for the admin.
--                 if ( strpos( _SERVER["REQUEST_URI"], "wp-admin" ) !== false || strpos( _SERVER["REQUEST_URI"], "wp-login.php" ) !== false ) then
--                         path = preg_replace( "#/(wp-admin/?.*|wp-login\.php.*)#i", "", _SERVER["REQUEST_URI"] );

--                         // The request is for a file in ABSPATH.
--                 end; elseif ( script_filename_dir . "/" === abspath_fix ) then
--                         // Strip off any file/query params in the path.
--                         path = preg_replace( "#/[^/]*#i", "", _SERVER["PHP_SELF"] );

--                 end; else then
--                         if ( false !== strpos( _SERVER["SCRIPT_FILENAME"], abspath_fix ) ) then
--                                 // Request is hitting a file inside ABSPATH.
--                                 directory = str_replace( ABSPATH, "", script_filename_dir );
--                                 // Strip off the subdirectory, and any file/query params.
--                                 path = preg_replace( "#/" . preg_quote( directory, "#" ) . "/[^/]*#i", "", _SERVER["REQUEST_URI"] );
--                         end; elseif ( false !== strpos( abspath_fix, script_filename_dir ) ) then
--                                 // Request is hitting a file above ABSPATH.
--                                 subdirectory = substr( abspath_fix, strpos( abspath_fix, script_filename_dir ) + strlen( script_filename_dir ) );
--                                 // Strip off any file/query params from the path, appending the subdirectory to the installation.
--                                 path = preg_replace( "#/[^/]*#i", "", _SERVER["REQUEST_URI"] ) . subdirectory;
--                         end; else then
--                                 path = _SERVER["REQUEST_URI"];
--                         end;
--                 end;

--                 schema = is_ssl() ? "https://" : "http://"; // set_url_scheme() is not defined yet.
--                 url    = schema . _SERVER["HTTP_HOST"] . path;
      end if;

      return Rtrim (-URL, "/");
   end Wp_Guess_URL;

   -------------------------------
   -- Wp_Suspend_Cache_Addition --
   -------------------------------

   Static_Cache_Suspend : Boolean := False;

   function Wp_Suspend_Cache_Addition (Suspend : Boolean := False)
                                       return Boolean
   is
   begin
      if Suspend then
         Static_Cache_Suspend := Suspend;
      end if;

      return Static_Cache_Suspend;
   end Wp_Suspend_Cache_Addition;

--
-- Suspends cache invalidation.
--
-- Turns cache invalidation on and off. Useful during imports where you don"t want to do
-- invalidations every time a post is inserted. Callers must be sure that what they are
-- doing won"t lead to an inconsistent cache when invalidation is suspended.
--
-- @since 2.7.0
--
-- @global bool _wp_suspend_cache_invalidation
--
-- @param bool suspend Optional. Whether to suspend or enable cache invalidation. Default true.
-- @return bool The current suspend setting.
--
-- function wp_suspend_cache_invalidation( suspend = true ) then
--         global _wp_suspend_cache_invalidation;

--         current_suspend                = _wp_suspend_cache_invalidation;
--         _wp_suspend_cache_invalidation = suspend;
--         return current_suspend;
-- end;

   ------------------
   -- Is_Main_Site --
   ------------------

   function Is_Main_Site (Site_Id    : Integer := 0; -- = null,
                          Network_Id : Integer := 0) -- = null
                          return Boolean
   is
      use Inc_Load;
   begin
      if not Is_Multisite then
         return True;
      end if;

      declare
         Site_Id_2 : constant Integer :=
           (if Site_Id = 0 -- not
            then Get_Current_Blog_Id
            else Site_Id);
      begin
--       site_id = (int) site_id;
         return Get_Main_Site_Id (Network_Id) = Site_Id_2;
      end;
   end Is_Main_Site;

   ----------------------
   -- Get_Main_Site_Id --
   ----------------------

   function Get_Main_Site_Id (Network_Id : Integer := 0) -- null
                              return Integer
   is
      use Inc_Class_Wp_Networks;
      use Inc_Load;
      use Inc_Ms_Networks;
   begin
      if not Is_Multisite then
         return Get_Current_Blog_Id;
      end if;

      declare
         Network : constant Wp_Network := Get_Network (Network_Id);
      begin
         if Network = Null_Network then -- not
            return 0;
         end if;

         return Network.Prop.Site_Id;
      end;
   end Get_Main_Site_Id;

   ---------------------
   -- Is_Main_Network --
   ---------------------

   function Is_Main_Network (Network_Id : Integer := 0)
                             return Boolean
   is
      use Inc_Load;
   begin
      if not Is_Multisite then
         return True;
      end if;

      declare
         Network_Id_2 : constant Integer :=
           (if 0 = Network_Id
            then Get_Current_Network_Id
            else Network_Id);
      begin
         return Get_Main_Network_Id = Network_Id_2;
      end;
   end Is_Main_Network;

   -------------------------
   -- Get_Main_Network_Id --
   -------------------------

   function Get_Main_Network_Id
            return Integer
   is
      use Inc_Ms_Networks;
      use Inc_Class_Wp_Networks;
      use Inc_Load;
      use Inc_Plugins;

      Main_Network_Id : Integer;
   begin
      if not Is_Multisite then
         return 1;
      end if;

      declare
         Current_Network : constant Wp_Network := Get_Network;
      begin
--       if ( defined( "PRIMARY_NETWORK_ID" ) ) then
--          Main_Network_Id := PRIMARY_NETWORK_ID;
--       elsif
         if
           Current_Network.Id /= 0 and then
--         Isset (Current_Network.Id) and then
           1 = Current_Network.Id   -- (int)
         then
            -- If the current network has an ID of 1, assume it is the main network.
            Main_Network_Id := 1;
         else
            declare
               X_Networks : constant Network_List :=
                 Get_Networks (
                   To_Array (List => (
                     Build ("fields", "ids"),
                     Build ("number", 1)
                   ))
                 );
            begin
               Main_Network_Id := X_Networks.First_Element.Id;
--             Main_Network_Id := Array_Shift (X_Networks);
            end;
         end if;

         --
         -- Filters the main network ID.
         --
         -- @since 4.3.0
         --
         -- @param int main_network_id The ID of the main network.
         --
         return Apply_Filters ("get_main_network_id", Main_Network_Id); -- (int)
      end;
   end Get_Main_Network_Id;

--
-- Determines whether site meta is enabled.
--
-- This function checks whether the "blogmeta" database table exists. The result is saved as
-- a setting for the main network, making it essentially a global setting. Subsequent requests
-- will refer to this setting instead of running the query.
--
-- @since 5.1.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @return bool True if site meta is supported, false otherwise.
--
-- function is_site_meta_supported() then
--         global wpdb;

--         if ( ! is_multisite() ) then
--                 return false;
--         end;

--         network_id = get_main_network_id();

--         supported = get_network_option( network_id, "site_meta_supported", false );
--         if ( false === supported ) then
--                 supported = wpdb->get_var( "SHOW TABLES LIKE "thenwpdb->blogmetaend;"" ) ? 1 : 0;

--                 update_network_option( network_id, "site_meta_supported", supported );
--         end;

--         return (bool) supported;
-- end;

--
-- Modifies gmt_offset for smart timezone handling.
--
-- Overrides the gmt_offset option if we have a timezone_string available.
--
-- @since 2.8.0
--
-- @return float|false Timezone GMT offset, false otherwise.
--
-- function wp_timezone_override_offset() then
--         timezone_string = get_option( "timezone_string" );
--         if ( ! timezone_string ) then
--                 return false;
--         end;

--         timezone_object = timezone_open( timezone_string );
--         datetime_object = date_create();
--         if ( false === timezone_object || false === datetime_object ) then
--                 return false;
--         end;
--         return round( timezone_offset_get( timezone_object, datetime_object ) / HOUR_IN_SECONDS, 2 );
-- end;

--
-- Sort-helper for timezones.
--
-- @since 2.9.0
-- @access private
--
-- @param array a
-- @param array b
-- @return int
--
-- function _wp_timezone_choice_usort_callback( a, b ) then
--         // Don"t use translated versions of Etc.
--         if ( "Etc" === a["continent"] && "Etc" === b["continent"] ) then
--                 // Make the order of these more like the old dropdown.
--                 if ( "GMT+" === substr( a["city"], 0, 4 ) && "GMT+" === substr( b["city"], 0, 4 ) ) then
--                         return -1-- ( strnatcasecmp( a["city"], b["city"] ) );
--                 end;
--                 if ( "UTC" === a["city"] ) then
--                         if ( "GMT+" === substr( b["city"], 0, 4 ) ) then
--                                 return 1;
--                         end;
--                         return -1;
--                 end;
--                 if ( "UTC" === b["city"] ) then
--                         if ( "GMT+" === substr( a["city"], 0, 4 ) ) then
--                                 return -1;
--                         end;
--                         return 1;
--                 end;
--                 return strnatcasecmp( a["city"], b["city"] );
--         end;
--         if ( a["t_continent"] == b["t_continent"] ) then
--                 if ( a["t_city"] == b["t_city"] ) then
--                         return strnatcasecmp( a["t_subcity"], b["t_subcity"] );
--                 end;
--                 return strnatcasecmp( a["t_city"], b["t_city"] );
--         end; else then
--                 // Force Etc to the bottom of the list.
--                 if ( "Etc" === a["continent"] ) then
--                         return 1;
--                 end;
--                 if ( "Etc" === b["continent"] ) then
--                         return -1;
--                 end;
--                 return strnatcasecmp( a["t_continent"], b["t_continent"] );
--         end;
-- end;

--
-- Gives a nicely-formatted list of timezone strings.
--
-- @since 2.9.0
-- @since 4.7.0 Added the `locale` parameter.
--
-- @param string selected_zone Selected timezone.
-- @param string locale        Optional. Locale to load the timezones in. Default current site locale.
-- @return string
--
-- function wp_timezone_choice( selected_zone, locale = null ) then
--         static mo_loaded = false, locale_loaded = null;

--         continents = array( "Africa", "America", "Antarctica", "Arctic", "Asia", "Atlantic", "Australia", "Europe", "Indian", "Pacific" );

--         // Load translations for continents and cities.
--         if ( ! mo_loaded || locale !== locale_loaded ) then
--                 locale_loaded = locale ? locale : get_locale();
--                 mofile        = WP_LANG_DIR . "/continents-cities-" . locale_loaded . ".mo";
--                 unload_textdomain( "continents-cities" );
--                 load_textdomain( "continents-cities", mofile, locale_loaded );
--                 mo_loaded = true;
--         end;

--         tz_identifiers = timezone_identifiers_list();
--         zonen          = array();

--         foreach ( tz_identifiers as zone ) then
--                 zone = explode( "/", zone );
--                 if ( ! in_array( zone[0], continents, true ) ) then
--                         continue;
--                 end;

--                 // This determines what gets set and translated - we don"t translate Etc/* strings here, they are done later.
--                 exists    = array(
--                         0 => ( isset( zone[0] ) && zone[0] ),
--                         1 => ( isset( zone[1] ) && zone[1] ),
--                         2 => ( isset( zone[2] ) && zone[2] ),
--                 );
--                 exists[3] = ( exists[0] && "Etc" !== zone[0] );
--                 exists[4] = ( exists[1] && exists[3] );
--                 exists[5] = ( exists[2] && exists[3] );

--                 // phpcs:disable WordPress.WP.I18n.LowLevelTranslationFunction,WordPress.WP.I18n.NonSingularStringLiteralText
--                 zonen[] = array(
--                         "continent"   => ( exists[0] ? zone[0] : "" ),
--                         "city"        => ( exists[1] ? zone[1] : "" ),
--                         "subcity"     => ( exists[2] ? zone[2] : "" ),
--                         "t_continent" => ( exists[3] ? translate( str_replace( "_", " ", zone[0] ), "continents-cities" ) : "" ),
--                         "t_city"      => ( exists[4] ? translate( str_replace( "_", " ", zone[1] ), "continents-cities" ) : "" ),
--                         "t_subcity"   => ( exists[5] ? translate( str_replace( "_", " ", zone[2] ), "continents-cities" ) : "" ),
--                 );
--                 // phpcs:enable
--         end;
--         usort( zonen, "_wp_timezone_choice_usort_callback" );

--         structure = array();

--         if ( empty( selected_zone ) ) then
--                 structure[] = "<option selected="selected" value="">" . __( "Select a city" ) . "</option>";
--         end;

--         // If this is a deprecated, but valid, timezone string, display it at the top of the list as-is.
--         if ( in_array( selected_zone, tz_identifiers, true ) === false
--                 && in_array( selected_zone, timezone_identifiers_list( DateTimeZone::ALL_WITH_BC ), true )
--         ) then
--                 structure[] = "<option selected="selected" value="" . esc_attr( selected_zone ) . "">" . esc_html( selected_zone ) . "</option>";
--         end;

--         foreach ( zonen as key => zone ) then
--                 // Build value in an array to join later.
--                 value = array( zone["continent"] );

--                 if ( empty( zone["city"] ) ) then
--                         // It"s at the continent level (generally won"t happen).
--                         display = zone["t_continent"];
--                 end; else then
--                         // It"s inside a continent group.

--                         // Continent optgroup.
--                         if ( ! isset( zonen[ key - 1 ] ) || zonen[ key - 1 ]["continent"] !== zone["continent"] ) then
--                                 label       = zone["t_continent"];
--                                 structure[] = "<optgroup label="" . esc_attr( label ) . "">";
--                         end;

--                         // Add the city to the value.
--                         value[] = zone["city"];

--                         display = zone["t_city"];
--                         if ( ! empty( zone["subcity"] ) ) then
--                                 // Add the subcity to the value.
--                                 value[]  = zone["subcity"];
--                                 display .= " - " . zone["t_subcity"];
--                         end;
--                 end;

--                 // Build the value.
--                 value    = implode( "/", value );
--                 selected = "";
--                 if ( value === selected_zone ) then
--                         selected = "selected="selected" ";
--                 end;
--                 structure[] = "<option " . selected . "value="" . esc_attr( value ) . "">" . esc_html( display ) . "</option>";

--                 // Close continent optgroup.
--                 if ( ! empty( zone["city"] ) && ( ! isset( zonen[ key + 1 ] ) || ( isset( zonen[ key + 1 ] ) && zonen[ key + 1 ]["continent"] !== zone["continent"] ) ) ) then
--                         structure[] = "</optgroup>";
--                 end;
--         end;

--         // Do UTC.
--         structure[] = "<optgroup label="" . esc_attr__( "UTC" ) . "">";
--         selected    = "";
--         if ( "UTC" === selected_zone ) then
--                 selected = "selected="selected" ";
--         end;
--         structure[] = "<option " . selected . "value="" . esc_attr( "UTC" ) . "">" . __( "UTC" ) . "</option>";
--         structure[] = "</optgroup>";

--         // Do manual UTC offsets.
--         structure[]  = "<optgroup label="" . esc_attr__( "Manual Offsets" ) . "">";
--         offset_range = array(
--                 -12,
--                 -11.5,
--                 -11,
--                 -10.5,
--                 -10,
--                 -9.5,
--                 -9,
--                 -8.5,
--                 -8,
--                 -7.5,
--                 -7,
--                 -6.5,
--                 -6,
--                 -5.5,
--                 -5,
--                 -4.5,
--                 -4,
--                 -3.5,
--                 -3,
--                 -2.5,
--                 -2,
--                 -1.5,
--                 -1,
--                 -0.5,
--                 0,
--                 0.5,
--                 1,
--                 1.5,
--                 2,
--                 2.5,
--                 3,
--                 3.5,
--                 4,
--                 4.5,
--                 5,
--                 5.5,
--                 5.75,
--                 6,
--                 6.5,
--                 7,
--                 7.5,
--                 8,
--                 8.5,
--                 8.75,
--                 9,
--                 9.5,
--                 10,
--                 10.5,
--                 11,
--                 11.5,
--                 12,
--                 12.75,
--                 13,
--                 13.75,
--                 14,
--         );
--         foreach ( offset_range as offset ) then
--                 if ( 0 <= offset ) then
--                         offset_name = "+" . offset;
--                 end; else then
--                         offset_name = (string) offset;
--                 end;

--                 offset_value = offset_name;
--                 offset_name  = str_replace( array( ".25", ".5", ".75" ), array( ":15", ":30", ":45" ), offset_name );
--                 offset_name  = "UTC" . offset_name;
--                 offset_value = "UTC" . offset_value;
--                 selected     = "";
--                 if ( offset_value === selected_zone ) then
--                         selected = "selected="selected" ";
--                 end;
--                 structure[] = "<option " . selected . "value="" . esc_attr( offset_value ) . "">" . esc_html( offset_name ) . "</option>";

--         end;
--         structure[] = "</optgroup>";

--         return implode( "\n", structure );
-- end;

   ------------------------------
   -- X_Cleanup_Header_Comment --
   ------------------------------

   function X_Cleanup_Header_Comment (Str : String)
                                      return String
   is
      use Php;
      use Php.Preg;
      use Php.Strings;
   begin
      return Trim (Preg_Replace ("/\s*(?:\*\/|\?>).*/", "", Str));
   end X_Cleanup_Header_Comment;

--
-- Permanently deletes comments or posts of any type that have held a status
-- of "trash" for the number of days defined in EMPTY_TRASH_DAYS.
--
-- The default value of `EMPTY_TRASH_DAYS` is 30 (days).
--
-- @since 2.9.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- function wp_scheduled_delete() then
--         global wpdb;

--         delete_timestamp = time() - ( DAY_IN_SECONDS-- EMPTY_TRASH_DAYS );

--         posts_to_delete = wpdb->get_results( wpdb->prepare( "SELECT post_id FROM wpdb->postmeta WHERE meta_key = "_wp_trash_meta_time" AND meta_value < %d", delete_timestamp ), ARRAY_A );

--         foreach ( (array) posts_to_delete as post ) then
--                 post_id = (int) post["post_id"];
--                 if ( ! post_id ) then
--                         continue;
--                 end;

--                 del_post = get_post( post_id );

--                 if ( ! del_post || "trash" !== del_post->post_status ) then
--                         delete_post_meta( post_id, "_wp_trash_meta_status" );
--                         delete_post_meta( post_id, "_wp_trash_meta_time" );
--                 end; else then
--                         wp_delete_post( post_id );
--                 end;
--         end;

--         comments_to_delete = wpdb->get_results( wpdb->prepare( "SELECT comment_id FROM wpdb->commentmeta WHERE meta_key = "_wp_trash_meta_time" AND meta_value < %d", delete_timestamp ), ARRAY_A );

--         foreach ( (array) comments_to_delete as comment ) then
--                 comment_id = (int) comment["comment_id"];
--                 if ( ! comment_id ) then
--                         continue;
--                 end;

--                 del_comment = get_comment( comment_id );

--                 if ( ! del_comment || "trash" !== del_comment->comment_approved ) then
--                         delete_comment_meta( comment_id, "_wp_trash_meta_time" );
--                         delete_comment_meta( comment_id, "_wp_trash_meta_status" );
--                 end; else then
--                         wp_delete_comment( del_comment );
--                 end;
--         end;
-- end;

   -------------------
   -- Get_File_Data --
   -------------------

   function Get_File_Data (File            : String;
                           Default_Headers : Array_Type;
                           Context         : String := "")
                           return Array_Type
   is
      use Hb_Common;
      use Php;
      use Php.Arrays;
      use Php.Files;
      use Php.Preg;
      use Php.Strings;
      use Inc_Plugins;

      -- Pull only the first 8 KB of the file in.
      File_Data_2 : constant String :=
        File_Get_Contents (File, False, null, 0, 8 * Globals.KB_IN_BYTES);

      -- if ( false === file_data ) then
      --         file_data = "";
      -- end;

      -- Make sure we catch CR-only line endings.
      File_Data : constant String := Str_Replace ("\r", "\n", File_Data_2);

      --
      -- Filters extra file headers by context.
      --
      -- The dynamic portion of the hook name, `context`, refers to
      -- the context where extra headers might be loaded.
      --
      -- @since 2.9.0
      --
      -- @param array extra_context_headers Empty array by default.
      --
      Extra_Headers : Array_Type :=
        (if Context /= ""
         then Apply_Filters ("extra_" & Context & "_headers", Empty_Array)
         else Empty_Array);

      All_Headers : Array_Type;
   begin
      if not Extra_Headers.Is_Empty then
         Extra_Headers := Array_Combine (Extra_Headers, Extra_Headers);
         -- Keys equal values.
         All_Headers   := Array_Merge (Extra_Headers, Default_Headers); -- (array)
      else
         All_Headers := Default_Headers;
      end if;

      for A in All_Headers.Iterate loop
         declare
            Field : constant String := Key (A);
            Regex : constant String := As_String (Element (A));
            Match : List_Type;
            Res   : constant Natural :=
              Preg_Match ("/^(?:[ \t]*<\?php)?[ \t\/*#@]*" &
                          Preg_Quote (Regex, "/") &
                          ":(.*)/mi", File_Data, Match);
         begin
            if
              Res /= 0 and then
              Match (1) /= ""
            then
               Set (All_Headers, Field,
                    From_String (X_Cleanup_Header_Comment (-Match (1))));
            else
               Set (All_Headers, Field,
                    From_String (""));
            end if;
         end;
      end loop;

      return All_Headers;
   end Get_File_Data;

   -------------------
   -- X_Return_True --
   -------------------

   function X_Return_True
            return Boolean
            is (True);
   -- phpcs:ignore WordPress.NamingConventions.ValidFunctionName.FunctionDoubleUnderscore,PHPCompatibility.FunctionNameRestrictions.ReservedFunctionNames.FunctionDoubleUnderscore

   --------------------
   -- X_Return_False --
   --------------------

   function X_Return_False
            return Boolean
            is (False);
   -- phpcs:ignore WordPress.NamingConventions.ValidFunctionName.FunctionDoubleUnderscore,PHPCompatibility.FunctionNameRestrictions.ReservedFunctionNames.FunctionDoubleUnderscore

   --------------------
   -- X_Returns_Zero --
   --------------------

   function X_Return_Zero
            return Integer
            is (0);
   -- phpcs:ignore WordPress.NamingConventions.ValidFunctionName.FunctionDoubleUnderscore,PHPCompatibility.FunctionNameRestrictions.ReservedFunctionNames.FunctionDoubleUnderscore

   --------------------------
   -- X_Return_Empty_Array --
   --------------------------

   function X_Return_Empty_Array
            return Array_Type
            is (Empty_Array);
   -- phpcs:ignore WordPress.NamingConventions.ValidFunctionName.FunctionDoubleUnderscore,PHPCompatibility.FunctionNameRestrictions.ReservedFunctionNames.FunctionDoubleUnderscore

--
-- Returns null.
--
-- Useful for returning null to filters easily.
--
-- @since 3.4.0
--
-- @return null Null value.
--
-- function __return_null() then // phpcs:ignore WordPress.NamingConventions.ValidFunctionName.FunctionDoubleUnderscore,PHPCompatibility.FunctionNameRestrictions.ReservedFunctionNames.FunctionDoubleUnderscore
--         return null;
-- end;

--
-- Returns an empty string.
--
-- Useful for returning an empty string to filters easily.
--
-- @since 3.7.0
--
-- @see __return_null()
--
-- @return string Empty string.
--
-- function __return_empty_string() then // phpcs:ignore WordPress.NamingConventions.ValidFunctionName.FunctionDoubleUnderscore,PHPCompatibility.FunctionNameRestrictions.ReservedFunctionNames.FunctionDoubleUnderscore
--         return "";
-- end;

--
-- Sends a HTTP header to disable content type sniffing in browsers which support it.
--
-- @since 3.0.0
--
-- @see https://blogs.msdn.com/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
-- @see https://src.chromium.org/viewvc/chrome?view=rev&revision=6985
--
-- function send_nosniff_header() then
--         header( "X-Content-Type-Options: nosniff" );
-- end;

--
-- Returns a MySQL expression for selecting the week number based on the start_of_week option.
--
-- @ignore
-- @since 3.0.0
--
-- @param string column Database column.
-- @return string SQL clause.
--
-- function _wp_mysql_week( column ) then
--         start_of_week = (int) get_option( "start_of_week" );
--         switch ( start_of_week ) then
--                 case 1:
--                         return "WEEK( column, 1 )";
--                 case 2:
--                 case 3:
--                 case 4:
--                 case 5:
--                 case 6:
--                         return "WEEK( DATE_SUB( column, INTERVAL start_of_week DAY ), 0 )";
--                 case 0:
--                 default:
--                         return "WEEK( column, 0 )";
--         end;
-- end;

--
-- Finds hierarchy loops using a callback function that maps object IDs to parent IDs.
--
-- @since 3.1.0
-- @access private
--
-- @param callable callback      Function that accepts ( ID, callback_args ) and outputs parent_ID.
-- @param int      start         The ID to start the loop check at.
-- @param int      start_parent  The parent_ID of start to use instead of calling callback( start ).
--                                Use null to always use callback
-- @param array    callback_args Optional. Additional arguments to send to callback.
-- @return array IDs of all members of loop.
--
-- function wp_find_hierarchy_loop( callback, start, start_parent, callback_args = array() ) then
--         override = is_null( start_parent ) ? array() : array( start => start_parent );

--         arbitrary_loop_member = wp_find_hierarchy_loop_tortoise_hare( callback, start, override, callback_args );
--         if ( ! arbitrary_loop_member ) then
--                 return array();
--         end;

--         return wp_find_hierarchy_loop_tortoise_hare( callback, arbitrary_loop_member, override, callback_args, true );
-- end;

--
-- Uses the "The Tortoise and the Hare" algorithm to detect loops.
--
-- For every step of the algorithm, the hare takes two steps and the tortoise one.
-- If the hare ever laps the tortoise, there must be a loop.
--
-- @since 3.1.0
-- @access private
--
-- @param callable callback      Function that accepts ( ID, callback_arg, ... ) and outputs parent_ID.
-- @param int      start         The ID to start the loop check at.
-- @param array    override      Optional. An array of ( ID => parent_ID, ... ) to use instead of callback.
--                                Default empty array.
-- @param array    callback_args Optional. Additional arguments to send to callback. Default empty array.
-- @param bool     _return_loop  Optional. Return loop members or just detect presence of loop? Only set
--                                to true if you already know the given start is part of a loop (otherwise
--                                the returned array might include branches). Default false.
-- @return mixed Scalar ID of some arbitrary member of the loop, or array of IDs of all members of loop if
--               _return_loop
--
-- function wp_find_hierarchy_loop_tortoise_hare( callback, start, override = array(), callback_args = array(), _return_loop = false ) then
--         tortoise        = start;
--         hare            = start;
--         evanescent_hare = start;
--         return          = array();

--         // Set evanescent_hare to one past hare.
--         // Increment hare two steps.
--         while (
--                 tortoise
--         &&
--                 ( evanescent_hare = isset( override[ hare ] ) ? override[ hare ] : call_user_func_array( callback, array_merge( array( hare ), callback_args ) ) )
--         &&
--                 ( hare = isset( override[ evanescent_hare ] ) ? override[ evanescent_hare ] : call_user_func_array( callback, array_merge( array( evanescent_hare ), callback_args ) ) )
--         ) then
--                 if ( _return_loop ) then
--                         return[ tortoise ]        = true;
--                         return[ evanescent_hare ] = true;
--                         return[ hare ]            = true;
--                 end;

--                 // Tortoise got lapped - must be a loop.
--                 if ( tortoise == evanescent_hare || tortoise == hare ) then
--                         return _return_loop ? return : tortoise;
--                 end;

--                 // Increment tortoise by one step.
--                 tortoise = isset( override[ tortoise ] ) ? override[ tortoise ] : call_user_func_array( callback, array_merge( array( tortoise ), callback_args ) );
--         end;

--         return false;
-- end;

--
-- Sends a HTTP header to limit rendering of pages to same origin iframes.
--
-- @since 3.1.3
--
-- @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
--
-- function send_frame_options_header() then
--         header( "X-Frame-Options: SAMEORIGIN" );
-- end;

   Static_Protocols : List_Type;

   --------------------------
   -- Wp_Allowed_Protocols --
   --------------------------

   function Wp_Allowed_Protocols
            return List_Type
   is
      use Php.Lists;
      use Hb_Common;
      use Inc_Plugins;
   begin
      if Static_Protocols.Is_Empty then
         Static_Protocols :=
                      To_List (List => (+"http", +"https", +"ftp", +"ftps", +"mailto",
                                        +"news", +"irc", +"irc6", +"ircs", +"gopher",
                                        +"nntp", +"feed", +"telnet", +"mms", +"rtsp",
                                        +"sms", +"svn", +"tel", +"fax", +"xmpp",
                                        +"webcal", +"urn"));
      end if;

      if not Did_Action ("wp_loaded") then
         --
         -- Filters the list of protocols allowed in HTML attributes.
         --
         -- @since 3.0.0
         --
         -- @param string[] protocols Array of allowed protocols e.g. "http", "ftp",
         --                            "tel", and more.
         --
         Static_Protocols :=
           List_Unique (Apply_Filters ("kses_allowed_protocols", Static_Protocols));
      end if;

      return Static_Protocols;
   end Wp_Allowed_Protocols;

--
-- Returns a comma-separated string or array of functions that have been called to get
-- to the current point in code.
--
-- @since 3.4.0
--
-- @see https://core.trac.wordpress.org/ticket/19589
--
-- @param string ignore_class Optional. A class to ignore all function calls within - useful
--                             when you want to just give info about the callee. Default null.
-- @param int    skip_frames  Optional. A number of stack frames to skip - useful for unwinding
--                             back to the source of the issue. Default 0.
-- @param bool   pretty       Optional. Whether you want a comma separated string instead of
--                             the raw array returned. Default true.
-- @return string|array Either a string containing a reversed comma separated trace or an array
--                      of individual calls.
--
-- function wp_debug_backtrace_summary( ignore_class = null, skip_frames = 0, pretty = true ) then
--         static truncate_paths;

--         trace       = debug_backtrace( false );
--         caller      = array();
--         check_class = ! is_null( ignore_class );
--         skip_frames++; // Skip this function.

--         if ( ! isset( truncate_paths ) ) then
--                 truncate_paths = array(
--                         wp_normalize_path( WP_CONTENT_DIR ),
--                         wp_normalize_path( ABSPATH ),
--                 );
--         end;

--         foreach ( trace as call ) then
--                 if ( skip_frames > 0 ) then
--                         skip_frames--;
--                 end; elseif ( isset( call["class"] ) ) then
--                         if ( check_class && ignore_class == call["class"] ) then
--                                 continue; // Filter out calls.
--                         end;

--                         caller[] = "thencall["class"]end;thencall["type"]end;thencall["function"]end;";
--                 end; else then
--                         if ( in_array( call["function"], array( "do_action", "apply_filters", "do_action_ref_array", "apply_filters_ref_array" ), true ) ) then
--                                 caller[] = "thencall["function"]end;("thencall["args"][0]end;")";
--                         end; elseif ( in_array( call["function"], array( "include", "include_once", "require", "require_once" ), true ) ) then
--                                 filename = isset( call["args"][0] ) ? call["args"][0] : "";
--                                 caller[] = call["function"] . "("" . str_replace( truncate_paths, "", wp_normalize_path( filename ) ) . "")";
--                         end; else then
--                                 caller[] = call["function"];
--                         end;
--                 end;
--         end;
--         if ( pretty ) then
--                 return implode( ", ", array_reverse( caller ) );
--         end; else then
--                 return caller;
--         end;
-- end;

--
-- Retrieves IDs that are not already present in the cache.
--
-- @since 3.4.0
-- @since 6.1.0 This function is no longer marked as "private".
--
-- @param int[]  object_ids Array of IDs.
-- @param string cache_key  The cache bucket to check against.
-- @return int[] Array of IDs not present in the cache.
--
-- function _get_non_cached_ids( object_ids, cache_key ) then
--         non_cached_ids = array();
--         cache_values   = wp_cache_get_multiple( object_ids, cache_key );

--         foreach ( cache_values as id => value ) then
--                 if ( ! value ) then
--                         non_cached_ids[] = (int) id;
--                 end;
--         end;

--         return non_cached_ids;
-- end;

--
-- Tests if the current device has the capability to upload files.
--
-- @since 3.4.0
-- @access private
--
-- @return bool Whether the device is able to upload files.
--
-- function _device_can_upload() then
--         if ( ! wp_is_mobile() ) then
--                 return true;
--         end;

--         ua = _SERVER["HTTP_USER_AGENT"];

--         if ( strpos( ua, "iPhone" ) !== false
--                 || strpos( ua, "iPad" ) !== false
--                 || strpos( ua, "iPod" ) !== false ) then
--                         return preg_match( "#OS ([\d_]+) like Mac OS X#", ua, version ) && version_compare( version[1], "6", ">=" );
--         end;

--         return true;
-- end;

   ------------------
   -- Wp_Is_Stream --
   ------------------

   function Wp_Is_Stream (Path : String)
                          return Boolean
   is
      use Php;
      use Php.Lists;
      use Php.Misc;
      use Php.Strings;

      Scheme_Separator : constant Integer := Strpos (Path, "://");
   begin
      if 0 = Scheme_Separator then
         -- path isn"t a stream.
         return False;
      end if;

      declare
         Stream : constant String := Substr (Path, 0, Scheme_Separator);
      begin
         return In_List (Stream, Stream_Get_Wrappers, True);
      end;
   end Wp_Is_Stream;

--
-- Tests if the supplied date is valid for the Gregorian calendar.
--
-- @since 3.5.0
--
-- @link https://www.php.net/manual/en/function.checkdate.php
--
-- @param int    month       Month number.
-- @param int    day         Day number.
-- @param int    year        Year number.
-- @param string source_date The date to filter.
-- @return bool True if valid date, false if not valid date.
--
-- function wp_checkdate( month, day, year, source_date ) then
--         --
--         -- Filters whether the given date is valid for the Gregorian calendar.
--         --
--         -- @since 3.5.0
--         --
--         -- @param bool   checkdate   Whether the given date is valid.
--         -- @param string source_date Date to check.
--         --
--         return apply_filters( "wp_checkdate", checkdate( month, day, year ), source_date );
-- end;

--
-- Loads the auth check for monitoring whether the user is still logged in.
--
-- Can be disabled with remove_action( "admin_enqueue_scripts", "wp_auth_check_load" );
--
-- This is disabled for certain screens where a login screen could cause an
-- inconvenient interruption. A filter called {@see "wp_auth_check_load"} can be used
-- for fine-grained control.
--
-- @since 3.6.0
--
-- function wp_auth_check_load() then
--         if ( ! is_admin() && ! is_user_logged_in() ) then
--                 return;
--         end;

--         if ( defined( "IFRAME_REQUEST" ) ) then
--                 return;
--         end;

--         screen = get_current_screen();
--         hidden = array( "update", "update-network", "update-core", "update-core-network", "upgrade", "upgrade-network", "network" );
--         show   = ! in_array( screen->id, hidden, true );

--         --
--         -- Filters whether to load the authentication check.
--         --
--         -- Returning a falsey value from the filter will effectively short-circuit
--         -- loading the authentication check.
--         --
--         -- @since 3.6.0
--         --
--         -- @param bool      show   Whether to load the authentication check.
--         -- @param WP_Screen screen The current screen object.
--         --
--         if ( apply_filters( "wp_auth_check_load", show, screen ) ) then
--                 wp_enqueue_style( "wp-auth-check" );
--                 wp_enqueue_script( "wp-auth-check" );

--                 add_action( "admin_print_footer_scripts", "wp_auth_check_html", 5 );
--                 add_action( "wp_print_footer_scripts", "wp_auth_check_html", 5 );
--         end;
-- end;

--
-- Outputs the HTML that shows the wp-login dialog when the user is no longer logged in.
--
-- @since 3.6.0
--
-- function wp_auth_check_html() then
--         login_url      = wp_login_url();
--         current_domain = ( is_ssl() ? "https://" : "http://" ) . _SERVER["HTTP_HOST"];
--         same_domain    = ( strpos( login_url, current_domain ) === 0 );

--         --
--         -- Filters whether the authentication check originated at the same domain.
--         --
--         -- @since 3.6.0
--         --
--         -- @param bool same_domain Whether the authentication check originated at the same domain.
--         --
--         same_domain = apply_filters( "wp_auth_check_same_domain", same_domain );
--         wrap_class  = same_domain ? "hidden" : "hidden fallback";

--         ?>
--         <div id="wp-auth-check-wrap" class="<?php echo wrap_class; ?>">
--         <div id="wp-auth-check-bg"></div>
--         <div id="wp-auth-check">
--         <button type="button" class="wp-auth-check-close button-link"><span class="screen-reader-text"><?php _e( "Close dialog" ); ?></span></button>
--         <?php

--         if ( same_domain ) then
--                 login_src = add_query_arg(
--                         array(
--                                 "interim-login" => "1",
--                                 "wp_lang"       => get_user_locale(),
--                         ),
--                         login_url
--                 );
--                 ?>
--                 <div id="wp-auth-check-form" class="loading" data-src="<?php echo esc_url( login_src ); ?>"></div>
--                 <?php
--         end;

--         ?>
--         <div class="wp-auth-fallback">
--                 <p><b class="wp-auth-fallback-expired" tabindex="0"><?php _e( "Session expired" ); ?></b></p>
--                 <p><a href="<?php echo esc_url( login_url ); ?>" target="_blank"><?php _e( "Please log in again." ); ?></a>
--                 <?php _e( "The login page will open in a new tab. After logging in you can close it and return to this page." ); ?></p>
--         </div>
--         </div>
--         </div>
--         <?php
-- end;

--
-- Checks whether a user is still logged in, for the heartbeat.
--
-- Send a result that shows a log-in box if the user is no longer logged in,
-- or if their cookie is within the grace period.
--
-- @since 3.6.0
--
-- @global int login_grace_period
--
-- @param array response  The Heartbeat response.
-- @return array The Heartbeat response with "wp-auth-check" value set.
--
-- function wp_auth_check( response ) then
--         response["wp-auth-check"] = is_user_logged_in() && empty( GLOBALS["login_grace_period"] );
--         return response;
-- end;

--
-- Returns RegEx body to liberally match an opening HTML tag.
--
-- Matches an opening HTML tag that:
-- 1. Is self-closing or
-- 2. Has no body but has a closing tag of the same name or
-- 3. Contains a body and a closing tag of the same name
--
-- Note: this RegEx does not balance inner tags and does not attempt
-- to produce valid HTML
--
-- @since 3.6.0
--
-- @param string tag An HTML tag name. Example: "video".
-- @return string Tag RegEx.
--
-- function get_tag_regex( tag ) then
--         if ( empty( tag ) ) then
--                 return "";
--         end;
--         return sprintf( "<%1s[^<]*(?:>[\s\S]*<\/%1s>|\s*\/>)", tag_escape( tag ) );
-- end;

--
-- Retrieves a canonical form of the provided charset appropriate for passing to PHP
-- functions such as htmlspecialchars() and charset HTML attributes.
--
-- @since 3.6.0
-- @access private
--
-- @see https://core.trac.wordpress.org/ticket/23688
--
-- @param string charset A charset name.
-- @return string The canonical form of the charset.
--
-- function _canonical_charset( charset ) then
--         if ( "utf-8" === strtolower( charset ) || "utf8" === strtolower( charset ) ) then

--                 return "UTF-8";
--         end;

--         if ( "iso-8859-1" === strtolower( charset ) || "iso8859-1" === strtolower( charset ) ) then

--                 return "ISO-8859-1";
--         end;

--         return charset;
-- end;

   ------------------------------------
   -- MB_String_Binary_Safe_Encoding --
   ------------------------------------
   Static_Encodings       : List_Type; -- Array_Type;
   Static_Overloaded_Bool : Boolean := False;
   Static_Overloaded      : Boolean := False; -- null;

   procedure MB_String_Binary_Safe_Encoding (Reset : Boolean := False)
   is
      use Php.Ini;
      use Php.Lists;
      use Php.Multibyte;
      use Hb_Common;
   begin
      if not Static_Overloaded_Bool then -- is_null
         Static_Overloaded_Bool := True;
         if
--         Function_Exists ("mb_internal_encoding") and then
           Integer'(Ini_Get ("mbstring.func_overload")) mod 2 = 1
           -- phpcs:ignore PHPCompatibility.IniDirectives.RemovedIniDirectives.mbstring_func_overloadDeprecated
         then
            Static_Overloaded := True;
         else
            Static_Overloaded := False;
         end if;
      end if;

      if False = Static_Overloaded then
         return;
      end if;

      if not Reset then
         declare
            Encoding : constant String := MB_Internal_Encoding;
         begin
            Static_Encodings.Append (+Encoding);
--          Array_Push (Static_Encodings, Encoding);
            MB_Internal_Encoding ("ISO-8859-1");
         end;
      end if;

      if Reset and then not Static_Encodings.Is_Empty then
         declare
            Encoding : constant String := List_Pop (Static_Encodings);
         begin
            MB_Internal_Encoding (Encoding);
         end;
      end if;
   end MB_String_Binary_Safe_Encoding;

   ------------------------------
   -- Reset_MB_String_Encoding --
   ------------------------------

   procedure Reset_MB_String_Encoding
   is
   begin
      MB_String_Binary_Safe_Encoding (True);
   end Reset_MB_String_Encoding;

   -------------------------
   -- Wp_Validate_Boolean --
   -------------------------

   function Wp_Validate_Boolean (Var : Multi_Type)
                                 return Boolean
   is
      use Php.Strings;
   begin
      -- if Is_Bool (Var) then
      --    return Var;
      -- end if;

      -- if Is_String (Var) and then "false" = Strtolower (Var) then
      --    return False;
      -- end if;

      -- return (bool) var;
      case Kind_Of (Var) is

      when Kind_Boolean =>
         return As_Boolean (Var);

      when Kind_String =>
         if Strtolower (As_String (Var)) = "false" then
            return False;
         end if;

      when others => null;

      end case;

      return As_Boolean (Var);
   end Wp_Validate_Boolean;

--
-- Deletes a file.
--
-- @since 4.2.0
--
-- @param string file The path to the file to delete.
--
-- function wp_delete_file( file ) then
--         --
--         -- Filters the path of the file to delete.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string file Path to the file to delete.
--         --
--         delete = apply_filters( "wp_delete_file", file );
--         if ( ! empty( delete ) ) then
--                 @unlink( delete );
--         end;
-- end;

--
-- Deletes a file if its path is within the given directory.
--
-- @since 4.9.7
--
-- @param string file      Absolute path to the file to delete.
-- @param string directory Absolute path to a directory.
-- @return bool True on success, false on failure.
--
-- function wp_delete_file_from_directory( file, directory ) then
--         if ( wp_is_stream( file ) ) then
--                 real_file      = file;
--                 real_directory = directory;
--         end; else then
--                 real_file      = realpath( wp_normalize_path( file ) );
--                 real_directory = realpath( wp_normalize_path( directory ) );
--         end;

--         if ( false !== real_file ) then
--                 real_file = wp_normalize_path( real_file );
--         end;

--         if ( false !== real_directory ) then
--                 real_directory = wp_normalize_path( real_directory );
--         end;

--         if ( false === real_file || false === real_directory || strpos( real_file, trailingslashit( real_directory ) ) !== 0 ) then
--                 return false;
--         end;

--         wp_delete_file( file );

--         return true;
-- end;

--
-- Outputs a small JS snippet on preview tabs/windows to remove `window.name` on unload.
--
-- This prevents reusing the same tab for a preview when the user has navigated away.
--
-- @since 4.3.0
--
-- @global WP_Post post Global post object.
--
-- function wp_post_preview_js() then
--         global post;

--         if ( ! is_preview() || empty( post ) ) then
--                 return;
--         end;

--         // Has to match the window name used in post_submit_meta_box().
--         name = "wp-preview-" . (int) post->ID;

--         ?>
--         <script>
--         ( function() then
--                 var query = document.location.search;

--                 if ( query && query.indexOf( "preview=true" ) !== -1 ) then
--                         window.name = "<?php echo name; ?>";
--                 end;

--                 if ( window.addEventListener ) then
--                         window.addEventListener( "unload", function() then window.name = ""; end;, false );
--                 end;
--         end;());
--         </script>
--         <?php
-- end;

--
-- Parses and formats a MySQL datetime (Y-m-d H:i:s) for ISO8601 (Y-m-d\TH:i:s).
--
-- Explicitly strips timezones, as datetimes are not saved with any timezone
-- information. Including any information on the offset could be misleading.
--
-- Despite historical function name, the output does not conform to RFC3339 format,
-- which must contain timezone.
--
-- @since 4.4.0
--
-- @param string date_string Date string to parse and format.
-- @return string Date formatted for ISO8601 without time zone.
--
-- function mysql_to_rfc3339( date_string ) then
--         return mysql2date( "Y-m-d\TH:i:s", date_string, false );
-- end;

   ---------------------------
   -- Wp_Raise_Memory_Limit --
   ---------------------------

   function Wp_Raise_Memory_Limit (Context : String := "admin")
                                   return Integer
                                   is (0);
--         // Exit early if the limit cannot be changed.
--         if ( false === wp_is_ini_value_changeable( "memory_limit" ) ) then
--                 return false;
--         end;

--         current_limit     = ini_get( "memory_limit" );
--         current_limit_int = wp_convert_hr_to_bytes( current_limit );

--         if ( -1 === current_limit_int ) then
--                 return false;
--         end;

--         wp_max_limit     = WP_MAX_MEMORY_LIMIT;
--         wp_max_limit_int = wp_convert_hr_to_bytes( wp_max_limit );
--         filtered_limit   = wp_max_limit;

--         switch ( context ) then
--                 case "admin":
--                         --
--                         -- Filters the maximum memory limit available for administration screens.
--                         --
--                         -- This only applies to administrators, who may require more memory for tasks
--                         -- like updates. Memory limits when processing images (uploaded or edited by
--                         -- users of any role) are handled separately.
--                         --
--                         -- The `WP_MAX_MEMORY_LIMIT` constant specifically defines the maximum memory
--                         -- limit available when in the administration back end. The default is 256M
--                         -- (256 megabytes of memory) or the original `memory_limit` php.ini value if
--                         -- this is higher.
--                         --
--                         -- @since 3.0.0
--                         -- @since 4.6.0 The default now takes the original `memory_limit` into account.
--                         --
--                         -- @param int|string filtered_limit The maximum WordPress memory limit. Accepts an integer
--                         --                                   (bytes), or a shorthand string notation, such as "256M".
--                         --
--                         filtered_limit = apply_filters( "admin_memory_limit", filtered_limit );
--                         break;

--                 case "image":
--                         --
--                         -- Filters the memory limit allocated for image manipulation.
--                         --
--                         -- @since 3.5.0
--                         -- @since 4.6.0 The default now takes the original `memory_limit` into account.
--                         --
--                         -- @param int|string filtered_limit Maximum memory limit to allocate for images.
--                         --                                   Default `WP_MAX_MEMORY_LIMIT` or the original
--                         --                                   php.ini `memory_limit`, whichever is higher.
--                         --                                   Accepts an integer (bytes), or a shorthand string
--                         --                                   notation, such as "256M".
--                         --
--                         filtered_limit = apply_filters( "image_memory_limit", filtered_limit );
--                         break;

--                 default:
--                         --
--                         -- Filters the memory limit allocated for arbitrary contexts.
--                         --
--                         -- The dynamic portion of the hook name, `context`, refers to an arbitrary
--                         -- context passed on calling the function. This allows for plugins to define
--                         -- their own contexts for raising the memory limit.
--                         --
--                         -- @since 4.6.0
--                         --
--                         -- @param int|string filtered_limit Maximum memory limit to allocate for images.
--                         --                                   Default "256M" or the original php.ini `memory_limit`,
--                         --                                   whichever is higher. Accepts an integer (bytes), or a
--                         --                                   shorthand string notation, such as "256M".
--                         --
--                         filtered_limit = apply_filters( "thencontextend;_memory_limit", filtered_limit );
--                         break;
--         end;

--         filtered_limit_int = wp_convert_hr_to_bytes( filtered_limit );

--         if ( -1 === filtered_limit_int || ( filtered_limit_int > wp_max_limit_int && filtered_limit_int > current_limit_int ) ) then
--                 if ( false !== ini_set( "memory_limit", filtered_limit ) ) then
--                         return filtered_limit;
--                 end; else then
--                         return false;
--                 end;
--         end; elseif ( -1 === wp_max_limit_int || wp_max_limit_int > current_limit_int ) then
--                 if ( false !== ini_set( "memory_limit", wp_max_limit ) ) then
--                         return wp_max_limit;
--                 end; else then
--                         return false;
--                 end;
--         end;

--         return false;
-- end;

   -----------------------
   -- Wp_Generate_UUID4 --
   -----------------------

   function Wp_Generate_UUID4
            return String
   is
      use Helpers;
      use Hb_Common;
      use Php;
      use Php.Numerics;
      use Php.Strings;
   begin
      return
        Sprintf (
          "%04x%04x-%04x-%04x-%04x-%04x%04x%04x",
          To_List (List => (
            1 => +Image_Hex_4 (MT_Rand (0, 16#FFFF#)),
            2 => +Image_Hex_4 (MT_Rand (0, 16#FFFF#)),
            3 => +Image_Hex_4 (MT_Rand (0, 16#FFFF#)),
            4 => +Image_Hex_4 (MT_Rand (0, 16#0FFF#) + 16#4000#),
            5 => +Image_Hex_4 (MT_Rand (0, 16#3FFF#) + 16#8000#),
            6 => +Image_Hex_4 (MT_Rand (0, 16#FFFF#)),
            7 => +Image_Hex_4 (MT_Rand (0, 16#FFFF#)),
            8 => +Image_Hex_4 (MT_Rand (0, 16#FFFF#))
        )));
   end Wp_Generate_UUID4;

   ----------------
   -- Wp_Is_UUID --
   ----------------

   function Wp_Is_UUID (UUID    : String;
                        Version : Integer := 0) -- null
                        return Boolean
   is
      use Php;
      use Php.Preg;
      use Php.Types;
      use Inc_L10n;
   begin
      if not Is_String (UUID) then
         return False;
      end if;

      if True then -- Is_Numeric (Version) then
         if 4 /= Version then -- (int)
            X_Doing_It_Wrong (
              "__FUNCTION__",
              abs "Only UUID V4 is supported at this time.",
              "4.9.0");
            return False;
         end if;

         return
           Preg_Match (
             "/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/",
             UUID);
      else
         return
           Preg_Match (
             "/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/",
             UUID);
      end if;

--      return (bool) preg_match( regex, uuid );
   end Wp_Is_UUID;

--
-- Gets unique ID.
--
-- This is a PHP implementation of Underscore"s uniqueId method. A static variable
-- contains an integer that is incremented with each call. This number is returned
-- with the optional prefix. As such the returned value is not universally unique,
-- but it is unique across the life of the PHP process.
--
-- @since 5.0.3
--
-- @param string prefix Prefix for the returned ID.
-- @return string Unique ID.
--
-- function wp_unique_id( prefix = "" ) then
--         static id_counter = 0;
--         return prefix . (string) ++id_counter;
-- end;

   -------------------------------
   -- Wp_Cache_Get_Last_Changed --
   -------------------------------

   function Wp_Cache_Get_Last_Changed (Group : String)
                                       return String
   is
      use Php.Misc;
      use Inc_Caches;

      Found : Boolean;

      Last_Changed : String :=
        Wp_Cache_Get ("last_changed", Group, Found => Found);
   begin
      if Last_Changed = "" then -- not
         Last_Changed := Microtime;
         Wp_Cache_Set ("last_changed", Last_Changed, Group);
      end if;

      return Last_Changed;
   end Wp_Cache_Get_Last_Changed;

--
-- Sends an email to the old site admin email address when the site admin email address changes.
--
-- @since 4.9.0
--
-- @param string old_email   The old site admin email address.
-- @param string new_email   The new site admin email address.
-- @param string option_name The relevant database option name.
--
-- function wp_site_admin_email_change_notification( old_email, new_email, option_name ) then
--         send = true;

--         // Don"t send the notification to the default "admin_email" value.
--         if ( "you@example.com" === old_email ) then
--                 send = false;
--         end;

--         --
--         -- Filters whether to send the site admin email change notification email.
--         --
--         -- @since 4.9.0
--         --
--         -- @param bool   send      Whether to send the email notification.
--         -- @param string old_email The old site admin email address.
--         -- @param string new_email The new site admin email address.
--         --
--         send = apply_filters( "send_site_admin_email_change_email", send, old_email, new_email );

--         if ( ! send ) then
--                 return;
--         end;

--         /* translators: Do not translate OLD_EMAIL, NEW_EMAIL, SITENAME, SITEURL: those are placeholders.--
--         email_change_text = __(
--                 "Hi,

-- This notice confirms that the admin email address was changed on ###SITENAME###.

-- The new admin email address is ###NEW_EMAIL###.

-- This email has been sent to ###OLD_EMAIL###

-- Regards,
-- All at ###SITENAME###
-- ###SITEURL###"
--         );

--         email_change_email = array(
--                 "to"      => old_email,
--                 /* translators: Site admin email change notification email subject. %s: Site title.--
--                 "subject" => __( "[%s] Admin Email Changed" ),
--                 "message" => email_change_text,
--                 "headers" => "",
--         );

--         // Get site name.
--         site_name = wp_specialchars_decode( get_option( "blogname" ), ENT_QUOTES );

--         --
--         -- Filters the contents of the email notification sent when the site admin email address is changed.
--         --
--         -- @since 4.9.0
--         --
--         -- @param array email_change_email then
--         --     Used to build wp_mail().
--         --
--         --     @type string to      The intended recipient.
--         --     @type string subject The subject of the email.
--         --     @type string message The content of the email.
--         --         The following strings have a special meaning and will get replaced dynamically:
--         --         - ###OLD_EMAIL### The old site admin email address.
--         --         - ###NEW_EMAIL### The new site admin email address.
--         --         - ###SITENAME###  The name of the site.
--         --         - ###SITEURL###   The URL to the site.
--         --     @type string headers Headers.
--         -- end;
--         -- @param string old_email The old site admin email address.
--         -- @param string new_email The new site admin email address.
--         --
--         email_change_email = apply_filters( "site_admin_email_change_email", email_change_email, old_email, new_email );

--         email_change_email["message"] = str_replace( "###OLD_EMAIL###", old_email, email_change_email["message"] );
--         email_change_email["message"] = str_replace( "###NEW_EMAIL###", new_email, email_change_email["message"] );
--         email_change_email["message"] = str_replace( "###SITENAME###", site_name, email_change_email["message"] );
--         email_change_email["message"] = str_replace( "###SITEURL###", home_url(), email_change_email["message"] );

--         wp_mail(
--                 email_change_email["to"],
--                 sprintf(
--                         email_change_email["subject"],
--                         site_name
--                 ),
--                 email_change_email["message"],
--                 email_change_email["headers"]
--         );
-- end;

--
-- Returns an anonymized IPv4 or IPv6 address.
--
-- @since 4.9.6 Abstracted from `WP_Community_Events::get_unsafe_client_ip()`.
--
-- @param string ip_addr       The IPv4 or IPv6 address to be anonymized.
-- @param bool   ipv6_fallback Optional. Whether to return the original IPv6 address if the needed functions
--                              to anonymize it are not present. Default false, return `::` (unspecified address).
-- @return string  The anonymized IP address.
--
-- function wp_privacy_anonymize_ip( ip_addr, ipv6_fallback = false ) then
--         if ( empty( ip_addr ) ) then
--                 return "0.0.0.0";
--         end;

--         // Detect what kind of IP address this is.
--         ip_prefix = "";
--         is_ipv6   = substr_count( ip_addr, ":" ) > 1;
--         is_ipv4   = ( 3 === substr_count( ip_addr, "." ) );

--         if ( is_ipv6 && is_ipv4 ) then
--                 // IPv6 compatibility mode, temporarily strip the IPv6 part, and treat it like IPv4.
--                 ip_prefix = "::ffff:";
--                 ip_addr   = preg_replace( "/^\[?[0-9a-f:]*:/i", "", ip_addr );
--                 ip_addr   = str_replace( "]", "", ip_addr );
--                 is_ipv6   = false;
--         end;

--         if ( is_ipv6 ) then
--                 // IPv6 addresses will always be enclosed in [] if there"s a port.
--                 left_bracket  = strpos( ip_addr, "[" );
--                 right_bracket = strpos( ip_addr, "]" );
--                 percent       = strpos( ip_addr, "%" );
--                 netmask       = "ffff:ffff:ffff:ffff:0000:0000:0000:0000";

--                 // Strip the port (and [] from IPv6 addresses), if they exist.
--                 if ( false !== left_bracket && false !== right_bracket ) then
--                         ip_addr = substr( ip_addr, left_bracket + 1, right_bracket - left_bracket - 1 );
--                 end; elseif ( false !== left_bracket || false !== right_bracket ) then
--                         // The IP has one bracket, but not both, so it"s malformed.
--                         return "::";
--                 end;

--                 // Strip the reachability scope.
--                 if ( false !== percent ) then
--                         ip_addr = substr( ip_addr, 0, percent );
--                 end;

--                 // No invalid characters should be left.
--                 if ( preg_match( "/[^0-9a-f:]/i", ip_addr ) ) then
--                         return "::";
--                 end;

--                 // Partially anonymize the IP by reducing it to the corresponding network ID.
--                 if ( function_exists( "inet_pton" ) && function_exists( "inet_ntop" ) ) then
--                         ip_addr = inet_ntop( inet_pton( ip_addr ) & inet_pton( netmask ) );
--                         if ( false === ip_addr ) then
--                                 return "::";
--                         end;
--                 end; elseif ( ! ipv6_fallback ) then
--                         return "::";
--                 end;
--         end; elseif ( is_ipv4 ) then
--                 // Strip any port and partially anonymize the IP.
--                 last_octet_position = strrpos( ip_addr, "." );
--                 ip_addr             = substr( ip_addr, 0, last_octet_position ) . ".0";
--         end; else then
--                 return "0.0.0.0";
--         end;

--         // Restore the IPv6 prefix to compatibility mode addresses.
--         return ip_prefix . ip_addr;
-- end;

--
-- Returns uniform "anonymous" data by type.
--
-- @since 4.9.6
--
-- @param string type The type of data to be anonymized.
-- @param string data Optional The data to be anonymized.
-- @return string The anonymous data for the requested type.
--
-- function wp_privacy_anonymize_data( type, data = "" ) then

--         switch ( type ) then
--                 case "email":
--                         anonymous = "deleted@site.invalid";
--                         break;
--                 case "url":
--                         anonymous = "https://site.invalid";
--                         break;
--                 case "ip":
--                         anonymous = wp_privacy_anonymize_ip( data );
--                         break;
--                 case "date":
--                         anonymous = "0000-00-00 00:00:00";
--                         break;
--                 case "text":
--                         /* translators: Deleted text.--
--                         anonymous = __( "[deleted]" );
--                         break;
--                 case "longtext":
--                         /* translators: Deleted long text.--
--                         anonymous = __( "This content was deleted by the author." );
--                         break;
--                 default:
--                         anonymous = "";
--                         break;
--         end;

--         --
--         -- Filters the anonymous data for each type.
--         --
--         -- @since 4.9.6
--         --
--         -- @param string anonymous Anonymized data.
--         -- @param string type      Type of the data.
--         -- @param string data      Original data.
--         --
--         return apply_filters( "wp_privacy_anonymize_data", anonymous, type, data );
-- end;

--
-- Returns the directory used to store personal data export files.
--
-- @since 4.9.6
--
-- @see wp_privacy_exports_url
--
-- @return string Exports directory.
--
-- function wp_privacy_exports_dir() then
--         upload_dir  = wp_upload_dir();
--         exports_dir = trailingslashit( upload_dir["basedir"] ) . "wp-personal-data-exports/";

--         --
--         -- Filters the directory used to store personal data export files.
--         --
--         -- @since 4.9.6
--         -- @since 5.5.0 Exports now use relative paths, so changes to the directory
--         --              via this filter should be reflected on the server.
--         --
--         -- @param string exports_dir Exports directory.
--         --
--         return apply_filters( "wp_privacy_exports_dir", exports_dir );
-- end;

--
-- Returns the URL of the directory used to store personal data export files.
--
-- @since 4.9.6
--
-- @see wp_privacy_exports_dir
--
-- @return string Exports directory URL.
--
-- function wp_privacy_exports_url() then
--         upload_dir  = wp_upload_dir();
--         exports_url = trailingslashit( upload_dir["baseurl"] ) . "wp-personal-data-exports/";

--         --
--         -- Filters the URL of the directory used to store personal data export files.
--         --
--         -- @since 4.9.6
--         -- @since 5.5.0 Exports now use relative paths, so changes to the directory URL
--         --              via this filter should be reflected on the server.
--         --
--         -- @param string exports_url Exports directory URL.
--         --
--         return apply_filters( "wp_privacy_exports_url", exports_url );
-- end;

--
-- Schedules a `WP_Cron` job to delete expired export files.
--
-- @since 4.9.6
--
-- function wp_schedule_delete_old_privacy_export_files() then
--         if ( wp_installing() ) then
--                 return;
--         end;

--         if ( ! wp_next_scheduled( "wp_privacy_delete_old_export_files" ) ) then
--                 wp_schedule_event( time(), "hourly", "wp_privacy_delete_old_export_files" );
--         end;
-- end;

--
-- Cleans up export files older than three days old.
--
-- The export files are stored in `wp-content/uploads`, and are therefore publicly
-- accessible. A CSPRN is appended to the filename to mitigate the risk of an
-- unauthorized person downloading the file, but it is still possible. Deleting
-- the file after the data subject has had a chance to delete it adds an additional
-- layer of protection.
--
-- @since 4.9.6
--
-- function wp_privacy_delete_old_export_files() then
--         exports_dir = wp_privacy_exports_dir();
--         if ( ! is_dir( exports_dir ) ) then
--                 return;
--         end;

--         require_once ABSPATH . "wp-admin/includes/file.php";
--         export_files = list_files( exports_dir, 100, array( "index.php" ) );

--         --
--         -- Filters the lifetime, in seconds, of a personal data export file.
--         --
--         -- By default, the lifetime is 3 days. Once the file reaches that age, it will automatically
--         -- be deleted by a cron job.
--         --
--         -- @since 4.9.6
--         --
--         -- @param int expiration The expiration age of the export, in seconds.
--         --
--         expiration = apply_filters( "wp_privacy_export_expiration", 3-- DAY_IN_SECONDS );

--         foreach ( (array) export_files as export_file ) then
--                 file_age_in_seconds = time() - filemtime( export_file );

--                 if ( expiration < file_age_in_seconds ) then
--                         unlink( export_file );
--                 end;
--         end;
-- end;

   ---------------------------
   -- Wp_Get_Update_PHP_URL --
   ---------------------------

   function Wp_Get_Update_PHP_URL
            return String
   is
      use Php.Misc;
      use Php.Strings;
      use Hb_Common;
      use Inc_Plugins;

      Default_URL : constant String := Wp_Get_Default_Update_PHP_URL;
      Update_URL  : Unbounded_String := +Default_URL;
   begin
      if Env_Exists ("WP_UPDATE_PHP_URL") then
         Update_URL := +Get_Env ("WP_UPDATE_PHP_URL");
      end if;

      --
      -- Filters the URL to learn more about updating the PHP version the site is
      -- running on.
      --
      -- Providing an empty string is not allowed and will result in the default
      -- URL being used. Furthermorethe page the URL links to should preferably be
      -- localized in the site language.
      --
      -- @since 5.1.0
      --
      -- @param string update_url URL to learn more about updating PHP.
      --
      Update_URL := +Apply_Filters ("wp_update_php_url", -Update_URL);

      if Empty (-Update_URL) then
         Update_URL := +Default_URL;
      end if;

      return -Update_URL;
   end Wp_Get_Update_PHP_URL;

   -----------------------------------
   -- Wp_Get_Default_Update_PHP_URL --
   -----------------------------------

   function Wp_Get_Default_Update_PHP_URL
            return String
   is
      use Inc_L10n;
   begin
      return X_X ("https://wordpress.org/support/update-php/",
                  "localized PHP upgrade information page");
   end Wp_Get_Default_Update_PHP_URL;

--
-- Prints the default annotation for the web host altering the "Update PHP" page URL.
--
-- This function is to be used after {@see wp_get_update_php_url()} to display a consistent
-- annotation if the web host has altered the default "Update PHP" page URL.
--
-- @since 5.1.0
-- @since 5.2.0 Added the `before` and `after` parameters.
--
-- @param string before Markup to output before the annotation. Default `<p class="description">`.
-- @param string after  Markup to output after the annotation. Default `</p>`.
--
-- function wp_update_php_annotation( before = "<p class="description">", after = "</p>" ) then
--         annotation = wp_get_update_php_annotation();

--         if ( annotation ) then
--                 echo before . annotation . after;
--         end;
-- end;

   ----------------------------------
   -- Wp_Get_Update_PHP_Annotation --
   ----------------------------------

   function Wp_Get_Update_PHP_Annotation
            return String
   is
      use Php.Strings;
      use Inc_Formatting;
      use Inc_L10n;

      Update_URL  : constant String := Wp_Get_Update_PHP_URL;
      Default_URL : constant String := Wp_Get_Default_Update_PHP_URL;
   begin
      if Update_URL = Default_URL then
         return "";
      end if;

      declare
         Annotation : constant String :=
           Sprintf (
             -- translators: %s: Default Update PHP page URL.
             abs "This resource is provided by your web host, and is specific to your site. For more information, <a href=""%s"" target=""_blank"">see the official WordPress documentation</a>.",
             To_List (ESC_URL (Default_URL))
           );
      begin
         return Annotation;
      end;
   end Wp_Get_Update_PHP_Annotation;

--
-- Gets the URL for directly updating the PHP version the site is running on.
--
-- A URL will only be returned if the `WP_DIRECT_UPDATE_PHP_URL` environment variable is specified or
-- by using the {@see "wp_direct_php_update_url"} filter. This allows hosts to send users directly to
-- the page where they can update PHP to a newer version.
--
-- @since 5.1.1
--
-- @return string URL for directly updating PHP or empty string.
--
-- function wp_get_direct_php_update_url() then
--         direct_update_url = "";

--         if ( false !== getenv( "WP_DIRECT_UPDATE_PHP_URL" ) ) then
--                 direct_update_url = getenv( "WP_DIRECT_UPDATE_PHP_URL" );
--         end;

--         --
--         -- Filters the URL for directly updating the PHP version the site is running on from the host.
--         --
--         -- @since 5.1.1
--         --
--         -- @param string direct_update_url URL for directly updating PHP.
--         --
--         direct_update_url = apply_filters( "wp_direct_php_update_url", direct_update_url );

--         return direct_update_url;
-- end;

--
-- Displays a button directly linking to a PHP update process.
--
-- This provides hosts with a way for users to be sent directly to their PHP update process.
--
-- The button is only displayed if a URL is returned by `wp_get_direct_php_update_url()`.
--
-- @since 5.1.1
--
-- function wp_direct_php_update_button() then
--         direct_update_url = wp_get_direct_php_update_url();

--         if ( empty( direct_update_url ) ) then
--                 return;
--         end;

--         echo "<p class="button-container">";
--         printf(
--                 "<a class="button button-primary" href="%1s" target="_blank" rel="noopener">%2s <span class="screen-reader-text">%3s</span><span aria-hidden="true" class="dashicons dashicons-external"></span></a>",
--                 esc_url( direct_update_url ),
--                 __( "Update PHP" ),
--                 /* translators: Accessibility text.--
--                 __( "(opens in a new tab)" )
--         );
--         echo "</p>";
-- end;

--
-- Gets the URL to learn more about updating the site to use HTTPS.
--
-- This URL can be overridden by specifying an environment variable `WP_UPDATE_HTTPS_URL` or by using the
-- {@see "wp_update_https_url"} filter. Providing an empty string is not allowed and will result in the
-- default URL being used. Furthermore the page the URL links to should preferably be localized in the
-- site language.
--
-- @since 5.7.0
--
-- @return string URL to learn more about updating to HTTPS.
--
-- function wp_get_update_https_url() then
--         default_url = wp_get_default_update_https_url();

--         update_url = default_url;
--         if ( false !== getenv( "WP_UPDATE_HTTPS_URL" ) ) then
--                 update_url = getenv( "WP_UPDATE_HTTPS_URL" );
--         end;

--         --
--         -- Filters the URL to learn more about updating the HTTPS version the site is running on.
--         --
--         -- Providing an empty string is not allowed and will result in the default URL being used. Furthermore
--         -- the page the URL links to should preferably be localized in the site language.
--         --
--         -- @since 5.7.0
--         --
--         -- @param string update_url URL to learn more about updating HTTPS.
--         --
--         update_url = apply_filters( "wp_update_https_url", update_url );
--         if ( empty( update_url ) ) then
--                 update_url = default_url;
--         end;

--         return update_url;
-- end;

--
-- Gets the default URL to learn more about updating the site to use HTTPS.
--
-- Do not use this function to retrieve this URL. Instead, use {@see wp_get_update_https_url()} when relying on the URL.
-- This function does not allow modifying the returned URL, and is only used to compare the actually used URL with the
-- default one.
--
-- @since 5.7.0
-- @access private
--
-- @return string Default URL to learn more about updating to HTTPS.
--
-- function wp_get_default_update_https_url() then
--         /* translators: Documentation explaining HTTPS and why it should be used.--
--         return __( "https://wordpress.org/support/article/why-should-i-use-https/" );
-- end;

--
-- Gets the URL for directly updating the site to use HTTPS.
--
-- A URL will only be returned if the `WP_DIRECT_UPDATE_HTTPS_URL` environment variable is specified or
-- by using the {@see "wp_direct_update_https_url"} filter. This allows hosts to send users directly to
-- the page where they can update their site to use HTTPS.
--
-- @since 5.7.0
--
-- @return string URL for directly updating to HTTPS or empty string.
--
-- function wp_get_direct_update_https_url() then
--         direct_update_url = "";

--         if ( false !== getenv( "WP_DIRECT_UPDATE_HTTPS_URL" ) ) then
--                 direct_update_url = getenv( "WP_DIRECT_UPDATE_HTTPS_URL" );
--         end;

--         --
--         -- Filters the URL for directly updating the PHP version the site is running on from the host.
--         --
--         -- @since 5.7.0
--         --
--         -- @param string direct_update_url URL for directly updating PHP.
--         --
--         direct_update_url = apply_filters( "wp_direct_update_https_url", direct_update_url );

--         return direct_update_url;
-- end;

--
-- Gets the size of a directory.
--
-- A helper function that is used primarily to check whether
-- a blog has exceeded its allowed upload space.
--
-- @since MU (3.0.0)
-- @since 5.2.0 max_execution_time parameter added.
--
-- @param string directory Full path of a directory.
-- @param int    max_execution_time Maximum time to run before giving up. In seconds.
--                                   The timeout is global and is measured from the moment WordPress started to load.
-- @return int|false|null Size in bytes if a valid directory. False if not. Null if timeout.
--
-- function get_dirsize( directory, max_execution_time = null ) then

--         // Exclude individual site directories from the total when checking the main site of a network,
--         // as they are subdirectories and should not be counted.
--         if ( is_multisite() && is_main_site() ) then
--                 size = recurse_dirsize( directory, directory . "/sites", max_execution_time );
--         end; else then
--                 size = recurse_dirsize( directory, null, max_execution_time );
--         end;

--         return size;
-- end;

--
-- Gets the size of a directory recursively.
--
-- Used by get_dirsize() to get a directory size when it contains other directories.
--
-- @since MU (3.0.0)
-- @since 4.3.0 The `exclude` parameter was added.
-- @since 5.2.0 The `max_execution_time` parameter was added.
-- @since 5.6.0 The `directory_cache` parameter was added.
--
-- @param string          directory          Full path of a directory.
-- @param string|string[] exclude            Optional. Full path of a subdirectory to exclude from the total,
--                                            or array of paths. Expected without trailing slash(es).
-- @param int             max_execution_time Optional. Maximum time to run before giving up. In seconds.
--                                            The timeout is global and is measured from the moment
--                                            WordPress started to load.
-- @param array           directory_cache    Optional. Array of cached directory paths.
-- @return int|false|null Size in bytes if a valid directory. False if not. Null if timeout.
--
-- function recurse_dirsize( directory, exclude = null, max_execution_time = null, &directory_cache = null ) then
--         directory  = untrailingslashit( directory );
--         save_cache = false;

--         if ( ! isset( directory_cache ) ) then
--                 directory_cache = get_transient( "dirsize_cache" );
--                 save_cache      = true;
--         end;

--         if ( isset( directory_cache[ directory ] ) && is_int( directory_cache[ directory ] ) ) then
--                 return directory_cache[ directory ];
--         end;

--         if ( ! file_exists( directory ) || ! is_dir( directory ) || ! is_readable( directory ) ) then
--                 return false;
--         end;

--         if (
--                 ( is_string( exclude ) && directory === exclude ) ||
--                 ( is_array( exclude ) && in_array( directory, exclude, true ) )
--         ) then
--                 return false;
--         end;

--         if ( null === max_execution_time ) then
--                 // Keep the previous behavior but attempt to prevent fatal errors from timeout if possible.
--                 if ( function_exists( "ini_get" ) ) then
--                         max_execution_time = ini_get( "max_execution_time" );
--                 end; else then
--                         // Disable...
--                         max_execution_time = 0;
--                 end;

--                 // Leave 1 second "buffer" for other operations if max_execution_time has reasonable value.
--                 if ( max_execution_time > 10 ) then
--                         max_execution_time -= 1;
--                 end;
--         end;

--         --
--         -- Filters the amount of storage space used by one directory and all its children, in megabytes.
--         --
--         -- Return the actual used space to short-circuit the recursive PHP file size calculation
--         -- and use something else, like a CDN API or native operating system tools for better performance.
--         --
--         -- @since 5.6.0
--         --
--         -- @param int|false            space_used         The amount of used space, in bytes. Default false.
--         -- @param string               directory          Full path of a directory.
--         -- @param string|string[]|null exclude            Full path of a subdirectory to exclude from the total,
--         --                                                 or array of paths.
--         -- @param int                  max_execution_time Maximum time to run before giving up. In seconds.
--         -- @param array                directory_cache    Array of cached directory paths.
--         --
--         size = apply_filters( "pre_recurse_dirsize", false, directory, exclude, max_execution_time, directory_cache );

--         if ( false === size ) then
--                 size = 0;

--                 handle = opendir( directory );
--                 if ( handle ) then
--                         while ( ( file = readdir( handle ) ) !== false ) then
--                                 path = directory . "/" . file;
--                                 if ( "." !== file && ".." !== file ) then
--                                         if ( is_file( path ) ) then
--                                                 size += filesize( path );
--                                         end; elseif ( is_dir( path ) ) then
--                                                 handlesize = recurse_dirsize( path, exclude, max_execution_time, directory_cache );
--                                                 if ( handlesize > 0 ) then
--                                                         size += handlesize;
--                                                 end;
--                                         end;

--                                         if ( max_execution_time > 0 &&
--                                                 ( microtime( true ) - WP_START_TIMESTAMP ) > max_execution_time
--                                         ) then
--                                                 // Time exceeded. Give up instead of risking a fatal timeout.
--                                                 size = null;
--                                                 break;
--                                         end;
--                                 end;
--                         end;
--                         closedir( handle );
--                 end;
--         end;

--         if ( ! is_array( directory_cache ) ) then
--                 directory_cache = array();
--         end;

--         directory_cache[ directory ] = size;

--         // Only write the transient on the top level call and not on recursive calls.
--         if ( save_cache ) then
--                 set_transient( "dirsize_cache", directory_cache );
--         end;

--         return size;
-- end;

--
-- Cleans directory size cache used by recurse_dirsize().
--
-- Removes the current directory and all parent directories from the `dirsize_cache` transient.
--
-- @since 5.6.0
-- @since 5.9.0 Added input validation with a notice for invalid input.
--
-- @param string path Full path of a directory or file.
--
-- function clean_dirsize_cache( path ) then
--         if ( ! is_string( path ) || empty( path ) ) then
--                 trigger_error(
--                         sprintf(
--                                 /* translators: 1: Function name, 2: A variable type, like "boolean" or "integer".--
--                                 __( "%1s only accepts a non-empty path string, received %2s." ),
--                                 "<code>clean_dirsize_cache()</code>",
--                                 "<code>" . gettype( path ) . "</code>"
--                         )
--                 );
--                 return;
--         end;

--         directory_cache = get_transient( "dirsize_cache" );

--         if ( empty( directory_cache ) ) then
--                 return;
--         end;

--         if (
--                 strpos( path, "/" ) === false &&
--                 strpos( path, "\\" ) === false
--         ) then
--                 unset( directory_cache[ path ] );
--                 set_transient( "dirsize_cache", directory_cache );
--                 return;
--         end;

--         last_path = null;
--         path      = untrailingslashit( path );
--         unset( directory_cache[ path ] );

--         while (
--                 last_path !== path &&
--                 DIRECTORY_SEPARATOR !== path &&
--                 "." !== path &&
--                 ".." !== path
--         ) then
--                 last_path = path;
--                 path      = dirname( path );
--                 unset( directory_cache[ path ] );
--         end;

--         set_transient( "dirsize_cache", directory_cache );
-- end;

--
-- Checks compatibility with the current WordPress version.
--
-- @since 5.2.0
--
-- @global string wp_version The WordPress version string.
--
-- @param string required Minimum required WordPress version.
-- @return bool True if required version is compatible or empty, false if not.
--
-- function is_wp_version_compatible( required ) then
--         global wp_version;

--         // Strip off any -alpha, -RC, -beta, -src suffixes.
--         list( version ) = explode( "-", wp_version );

--         return empty( required ) || version_compare( version, required, ">=" );
-- end;

--
-- Checks compatibility with the current PHP version.
--
-- @since 5.2.0
--
-- @param string required Minimum required PHP version.
-- @return bool True if required version is compatible or empty, false if not.
--
-- function is_php_version_compatible( required ) then
--         return empty( required ) || version_compare( PHP_VERSION, required, ">=" );
-- end;

--
-- Checks if two numbers are nearly the same.
--
-- This is similar to using `round()` but the precision is more fine-grained.
--
-- @since 5.3.0
--
-- @param int|float expected  The expected value.
-- @param int|float actual    The actual number.
-- @param int|float precision The allowed variation.
-- @return bool Whether the numbers match within the specified precision.
--
-- function wp_fuzzy_number_match( expected, actual, precision = 1 ) then
--         return abs( (float) expected - (float) actual ) <= precision;
-- end;

--
-- Sorts the keys of an array alphabetically.
-- The array is passed by reference so it doesn't get returned
-- which mimics the behaviour of ksort.
--
-- @since 6.0.0
--
-- @param array array The array to sort, passed by reference.
--
-- function wp_recursive_ksort( &array ) then
--         foreach ( array as &value ) then
--                 if ( is_array( value ) ) then
--                         wp_recursive_ksort( value );
--                 end;
--         end;
--         ksort( array );
-- end;

end Inc_Functions;
