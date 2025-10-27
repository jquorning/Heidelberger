
package body Inc_Elab_Plugins
is

   ---------------------------------
   -- X_Wp_Filter_Build_Unique_Id --
   ---------------------------------

   function X_Wp_Filter_Build_Unique_Id (Hook_Name : String;
                                         Callback  : Arrays.Callable;
                                         Priority  : Integer)
                                         return String
   is
   begin
--        if ( is_string( callback ) ) then
--                return callback;
--        end if;

        -- if Is_Object (callback) then
        --         Closures are currently implemented as objects.
        --         callback = array( callback, '' );
        -- else
        --         callback = (array) callback;
        -- end if;

        -- if is_object( callback[0] ) then
        --         Object class calling.
        --         return spl_object_hash( callback[0] ) . callback[1];
        -- elsif is_string( callback[0] ) then
        --         Static calling.
        --         return callback[0] . '::' . callback[1];
        -- end if;
      return "XXX-610-" & Hook_Name;
   end X_Wp_Filter_Build_Unique_Id;

end Inc_Elab_Plugins;
