package Inc_Script_Loader
is
   procedure Dummy;
--
-- Prints scripts (internal use only)
--
-- @ignore
--
-- @global WP_Scripts wp_scripts
-- @global bool       compress_scripts
--
   procedure X_Print_Scripts
             is null;

   --
   -- Returns the suffix that can be used for the scripts.
   --
   -- There are two suffix types, the normal one and the dev suffix.
   --
   -- @since 5.0.0
   --
   -- @param string type The type of suffix to retrieve.
   -- @return string The script suffix.
   --
   function Wp_Scripts_Get_Suffix (Typ : String := "")
                                   return String;

   --
   -- Loads classic theme styles on classic themes in the frontend.
   --
   -- This is needed for backwards compatibility for button blocks specifically.
   --
   -- @since 6.1.0
   --
   procedure Wp_Enqueue_Classic_Theme_Styles;

end Inc_Script_Loader;
