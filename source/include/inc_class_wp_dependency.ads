--
-- Dependencies API: _WP_Dependency class
--
-- @since 4.7.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

with Lists;

package Inc_Class_Wp_Dependency
is
   use Ada.Strings.Unbounded;
   use Lists;

   package String_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => String);
   subtype String_Map is String_Maps.Map;

   --
   -- Class _WP_Dependency
   --
   -- Helper class to register a handle and associated data.
   --
   -- @access private
   -- @since 2.6.0
   --
   -- #[AllowDynamicProperties]
   type X_Wp_Dependency is tagged
      record
        --
        -- The handle name.
        --
        -- @since 2.6.0
        -- @var string
        --
        Handle : Unbounded_String;

        --
        -- The handle source.
        --
        -- @since 2.6.0
        -- @var string
        --
        Src : Unbounded_String;

        --
        -- An array of handle dependencies.
        --
        -- @since 2.6.0
        -- @var string[]
        --
        Deps : List_Type; -- String_Array; --  = array();

        --
        -- The handle version.
        --
        -- Used for cache-busting.
        --
        -- @since 2.6.0
        -- @var bool|string
        --
        Ver : Unbounded_String; --  = false;

        --
        -- Additional arguments for the handle.
        --
        -- @since 2.6.0
        -- @var array
        --
        Args : String_Map; -- Array_Type; -- = null;  -- Custom property, such as in_footer or media.

        --
        -- Extra data to supply to the handle.
        --
        -- @since 2.6.0
        -- @var array
        --
        Extra : String_Map; -- Array_Type; --  = array();

        --
        -- Translation textdomain set for this dependency.
        --
        -- @since 5.0.0
        -- @var string
        --
        Textdomain : Unbounded_String;

        --
        -- Translation path set for this dependency.
        --
        -- @since 5.0.0
        -- @var string
        --
        Translations_Path : Unbounded_String;

      end record;

   --
   -- Setup dependencies.
   --
   -- @since 2.6.0
   -- @since 5.3.0 Formalized the existing `...args` parameter by adding it
   --              to the function signature.
   --
   -- @param mixed ...args Dependency information.
   --
   function X_Construct (Handle : String;
                         Src    : String;
                         Deps   : List_Type; -- String_Array;
                         Ver    : String;
                         Args   : String) -- Array_Type) --  ...args )
                         return X_Wp_Dependency;

   --
   -- Add handle data.
   --
   -- @since 2.6.0
   --
   -- @param string name The data key to add.
   -- @param mixed  data The data value to add.
   -- @return bool False if not scalar, true otherwise.
   --
   function Add_Data (This : in out X_Wp_Dependency;
                      Name : String;
                      Data : String) -- Boolean)
                      return Boolean;

   --
   -- Sets the translation domain for this dependency.
   --
   -- @since 5.0.0
   --
   -- @param string domain The translation textdomain.
   -- @param string path   Optional. The full file path to the directory containing translation files.
   -- @return bool False if domain is not a string, true otherwise.
   --
   function Set_Translations (This   : in out X_Wp_Dependency;
                              Domain : String;
                              Path   : String := "")
                              return Boolean;

   package Dependency_Vectors is new
      Ada.Containers.Vectors (Index_Type   => Positive,
                              Element_Type => X_Wp_Dependency);

   subtype Dependency_Array is Dependency_Vectors.Vector;

   Empty_Dependency_Array : constant Dependency_Array :=
      Dependency_Vectors.Empty_Vector;

   package Dependency_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => X_Wp_Dependency);

   subtype Dependency_Map is Dependency_Maps.Map;
end Inc_Class_Wp_Dependency;
