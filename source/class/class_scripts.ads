--
-- Dependencies API: WP_Scripts class
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Arrays;
with Lists;
with UStrings;

with Class_Dependencies;

package Class_Scripts
is
   use Arrays;
   use Lists;

   --
   -- Core class used to register scripts.
   --
   -- @since 2.1.0
   --
   -- @see WP_Dependencies
   --
   type Wp_Scripts is new Class_Dependencies.Wp_Dependencies
      with record
        --
        -- Base URL for scripts.
        --
        -- Full URL with trailing slash.
        --
        -- @since 2.6.0
        -- @var string
        --
        Base_URL : UStrings.UString;

        --
        -- URL of the content directory.
        --
        -- @since 2.8.0
        -- @var string
        --
        Content_URL : UStrings.UString;

        --
        -- Default version string for scripts.
        --
        -- @since 2.6.0
        -- @var string
        --
        Default_Version : UStrings.UString;

        --
        -- Holds handles of scripts which are enqueued in footer.
        --
        -- @since 2.8.0
        -- @var array
        --
        In_Footer : List_Type; -- Array_Type;

        --
        -- Holds a list of script handles which will be concatenated.
        --
        -- @since 2.8.0
        -- @var string
        --
        Concat : UStrings.UString;

        --
        -- Holds a string which contains script handles and their version.
        --
        -- @since 2.8.0
        -- @deprecated 3.4.0
        -- @var string
        --
        Concat_Version : UStrings.UString;

        --
        -- Whether to perform concatenation.
        --
        -- @since 2.8.0
        -- @var bool
        --
        Do_Concat : Boolean := False;

        --
        -- Holds HTML markup of scripts and additional data if concatenation
        -- is enabled.
        --
        -- @since 2.8.0
        -- @var string
        --
        Print_HTML : UStrings.UString;

        --
        -- Holds inline code if concatenation is enabled.
        --
        -- @since 2.8.0
        -- @var string
        --
        Print_Code : UStrings.UString;

        --
        -- Holds a list of script handles which are not in the default directory
        -- if concatenation is enabled.
        --
        -- Unused in core.
        --
        -- @since 2.8.0
        -- @var string
        --
        Ext_Handles : UStrings.UString;

        --
        -- Holds a string which contains handles and versions of scripts which
        -- are not in the default directory if concatenation is enabled.
        --
        -- Unused in core.
        --
        -- @since 2.8.0
        -- @var string
        --
        Ext_Version : UStrings.UString;

        --
        -- List of default directories.
        --
        -- @since 2.8.0
        -- @var array
        --
        Default_Dirs : List_Type;

        --
        -- Holds a string which contains the type attribute for script tag.
        --
        -- If the active theme does not declare HTML5 support for "script",
        -- then it initializes as `type="text/javascript"`.
        --
        -- @since 5.3.0
        -- @var string
        --
        -- private
        Type_Attr : UStrings.UString;

      end record;

   --
   -- Constructor.
   --
   -- @since 2.6.0
   --
   function X_Construct
            return Wp_Scripts;

   --
   -- Initialize the class.
   --
   -- @since 3.4.0
   --
   procedure Init (This : in out Wp_Scripts);

   --
   -- Prints scripts.
   --
   -- Prints the scripts passed to it or the print queue. Also prints all necessary
   -- dependencies.
   --
   -- @since 2.1.0
   -- @since 2.8.0 Added the `group` parameter.
   --
   -- @param string|string[]|false handles Optional. Scripts to be printed: queue
   --                                      (false), single script (string), or
   --                                      multiple scripts (array of strings).
   --                                      Default false.
   -- @param int|false             group   Optional. Group level: level (int), no
   --                                      groups (false).
   --                                      Default false.
   -- @return string[] Handles of scripts that have been printed.
   --
   function Print_Scripts (This    : in out Wp_Scripts;
                           Handles : List_Type := Empty_List;
                           Group   : Integer   := 0) -- False
                           return List_Type
                           with Side_Effects;

   --
   -- Prints extra scripts of a registered script.
   --
   -- @since 2.1.0
   -- @since 2.8.0 Added the `display` parameter.
   -- @deprecated 3.3.0
   --
   -- @see print_extra_script()
   --
   -- @param string handle  The script"s registered handle.
   -- @param bool   display Optional. Whether to print the extra script
   --                        instead of just returning it. Default true.
   -- @return bool|string|void Void if no data exists, extra scripts if `display`
   --                          is true, true otherwise.
   --
   function Print_Scripts_L10n (This    : Wp_Scripts;
                                Handle  : String;
                                Display : Boolean := True)
                                return String;

   --
   -- Prints extra scripts of a registered script.
   --
   -- @since 3.3.0
   --
   -- @param string handle  The script"s registered handle.
   -- @param bool   display Optional. Whether to print the extra script
   --                        instead of just returning it. Default true.
   -- @return bool|string|void Void if no data exists, extra scripts if `display`
   --                          is true, true otherwise.
   --
   function Print_Extra_Script (This    : Wp_Scripts;
                                Handle  : String;
                                Display : Boolean := True)
                                return String;

   --
   -- Processes a script dependency.
   --
   -- @since 2.6.0
   -- @since 2.8.0 Added the `group` parameter.
   --
   -- @see WP_Dependencies::do_item()
   --
   -- @param string    handle The script"s registered handle.
   -- @param int|false group  Optional. Group level: level (int), no groups (false).
   --                          Default false.
   -- @return bool True on success, false on failure.
   --
   overriding
   function Do_Item (This   : in out Wp_Scripts;
                     Handle : String;
                     Group  : Integer := 0) -- Boolean := False)
                     return Boolean;

   --
   -- Adds extra code to a registered script.
   --
   -- @since 4.5.0
   --
   -- @param string handle   Name of the script to add the inline script to.
   --                         Must be lowercase.
   -- @param string data     String containing the JavaScript to be added.
   -- @param string position Optional. Whether to add the inline script
   --                         before the handle or after. Default "after".
   -- @return bool True on success, false on failure.
   --
   function Add_Inline_Script (This     : in out Wp_Scripts;
                               Handle   : String;
                               Data     : String;
                               Position : String := "after")
                               return Boolean
                               with Side_Effects;

   procedure Add_Inline_Script (This     : in out Wp_Scripts;
                                Handle   : String;
                                Data     : String;
                                Position : String := "after");

   --
   -- Prints inline scripts registered for a specific handle.
   --
   -- @since 4.5.0
   --
   -- @param string handle   Name of the script to add the inline script to.
   --                         Must be lowercase.
   -- @param string position Optional. Whether to add the inline script
   --                         before the handle or after. Default "after".
   -- @param bool   display  Optional. Whether to print the script
   --                         instead of just returning it. Default true.
   -- @return string|false Script on success, false otherwise.
   --
   function Print_Inline_Script (This     : Wp_Scripts;
                                 Handle   : String;
                                 Position : String  := "after";
                                 Display  : Boolean := True)
                                 return String;

   --
   -- Localizes a script, only if the script has already been added.
   --
   -- @since 2.1.0
   --
   -- @param string handle      Name of the script to attach data to.
   -- @param string object_name Name of the variable that will contain the data.
   -- @param array  l10n        Array of data to localize.
   -- @return bool True on success, false on failure.
   --
   function Localize (This        : in out Wp_Scripts;
                      Handle      : String;
                      Object_Name : String;
                      L10n        : Array_Type)
                      return Boolean
                      with Side_Effects;

   procedure Localize (This        : in out Wp_Scripts;
                       Handle      : String;
                       Object_Name : String;
                       L10n        : Array_Type);

   --
   -- Sets handle group.
   --
   -- @since 2.8.0
   --
   -- @see WP_Dependencies::set_group()
   --
   -- @param string    handle    Name of the item. Should be unique.
   -- @param bool      recursion Internal flag that calling function was called
   --                            recursively.
   -- @param int|false group     Optional. Group level: level (int), no groups (false).
   --                             Default false.
   -- @return bool Not already in the group or a lower group.
   --
   function Set_Group (This      : in out Wp_Scripts;
                       Handle    : String;
                       Recursion : Boolean;
                       Group     : Integer := 0) -- Boolean := False)
                       return Boolean
                       with Side_Effects;

   --
   -- Sets a translation textdomain.
   --
   -- @since 5.0.0
   -- @since 5.1.0 The `domain` parameter was made optional.
   --
   -- @param string handle Name of the script to register a translation domain to.
   -- @param string domain Optional. Text domain. Default "default".
   -- @param string path   Optional. The full file path to the directory containing
   --                      translation files.
   -- @return bool True if the text domain was registered, false if not.
   --
   function Set_Translations (This   : Wp_Scripts;
                              Handle : String;
                              Domain : String := "default";
                              Path   : String := "")
                              return Boolean;

   procedure Set_Translations (This   : Wp_Scripts;
                               Handle : String;
                               Domain : String := "default";
                               Path   : String := "");

   --
   -- Prints translations set for a specific handle.
   --
   -- @since 5.0.0
   --
   -- @param string handle  Name of the script to add the inline script to.
   --                        Must be lowercase.
   -- @param bool   display Optional. Whether to print the script
   --                        instead of just returning it. Default true.
   -- @return string|false Script on success, false otherwise.
   --
   function Print_Translations (This    : Wp_Scripts;
                                Handle  : String;
                                Display : Boolean := True)
                                return String;

   --
   -- Determines script dependencies.
   --
   -- @since 2.1.0
   --
   -- @see WP_Dependencies::all_deps()
   --
   -- @param string|string() handles   Item handle (string) or item handles (array of
   --                                  strings).
   -- @param bool            recursion Optional. Internal flag that function is
   --                                  calling itself. Default false.
   -- @param int|false       group     Optional. Group level: level (int), no groups
   --                                 (false).
   --                                   Default false.
   -- @return bool True on success, false on failure.
   --
   function All_Deps (This      : in out Wp_Scripts;
                      Handles   : String;
                      Recursion : Boolean := False;
                      Group     : Integer := 0) -- False
                      return Boolean
                      with Side_Effects;

   --
   -- Processes items and dependencies for the head group.
   --
   -- @since 2.8.0
   --
   -- @see WP_Dependencies::do_items()
   --
   -- @return string() Handles of items that have been processed.
   --
   function Do_Head_Items (This : in out Wp_Scripts)
                           return List_Type
                           with Side_Effects;

   procedure Do_Head_Items (This : in out Wp_Scripts);

   --
   -- Processes items and dependencies for the footer group.
   --
   -- @since 2.8.0
   --
   -- @see WP_Dependencies::do_items()
   --
   -- @return string() Handles of items that have been processed.
   --
   function Do_Footer_Items (This : in out Wp_Scripts)
                             return List_Type
                             with Side_Effects;

   --
   -- Whether a handle"s source is in a default directory.
   --
   -- @since 2.8.0
   --
   -- @param string src The source of the enqueued script.
   -- @return bool True if found, false if not.
   --
   function In_Default_Dir (This : Wp_Scripts;
                            Src  : String)
                            return Boolean;

   --
   -- Resets class properties.
   --
   -- @since 2.8.0
   --
   procedure Reset (This : in out Wp_Scripts);

end Class_Scripts;
