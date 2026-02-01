--
-- Post revision functions.
--
-- @package WordPress
-- @subpackage Post_Revisions
--

with UStrings;

with Inc_Posts;

package body Inc_Revisions
is

   -------------------------
   -- Wp_Is_Post_Revision --
   -------------------------

   function Wp_Is_Post_Revision (Post : Integer)
                                 return Integer
   is
      use Class_Posts;

      Post_2 : Integer := Post;

      Post_3 : constant Wp_Post := Wp_Get_Post_Revision (Post_2);
   begin
      if Post_3 = Null_Post then
--    if not Post_3 then
         return 0; -- False;
      end if;

      return Integer (Post_3.Post_Parent); -- (int)
   end Wp_Is_Post_Revision;

   --------------------------
   -- Wp_Get_Post_Revision --
   --------------------------

   function Wp_Get_Post_Revision (Post   : in out Integer; -- &
                                  Output : String := "OBJECT";
                                  Filter : String := "raw")
                                  return Class_Posts.Wp_Post
   is
      use UStrings;
      use Class_Posts;
      use Inc_Posts;

      Revision : constant Wp_Post :=
        Get_Post (Post_Id_Type (Post), "OBJECT", Filter);
   begin
      if Revision = Null_Post then
         return Revision;
      end if;

      if "revision" /= Revision.Post_Type then
         return Null_Post; -- null;
      end if;

      if "OBJECT" = Output then
         return Revision;
      -- elsif "ARRAY_A" = Output then
      --    _revision = get_object_vars( revision );
      --    return _revision;
      -- elsif "ARRAY_N" = Output then
      --    _revision = array_values( get_object_vars( revision ) );
      --    return _revision;
      end if;

      return Revision;
   end Wp_Get_Post_Revision;

end Inc_Revisions;
