--
-- WordPress Query API
--
-- The query API attempts to get which part of WordPress the user is on. It
-- also provides functionality for getting URL query information.
--
-- @link https://developer.wordpress.org/themes/basics/the-loop/ More information on The Loop.
--
-- @package WordPress
-- @subpackage Query
--

with Inc_Class_Wp_Querys;

package Inc_Querys
is

   Wp_Query : Inc_Class_Wp_Querys.Wp_Query :=
     Inc_Class_Wp_Querys.Null_Query;

   --
   -- Retrieves the value of a query variable in the WP_Query class.
   --
   -- @since 1.5.0
   -- @since 3.9.0 The `default` argument was introduced.
   --
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @param string var       The variable key to retrieve.
   -- @param mixed  default   Optional. Value to return if the query variable is not
   --                          set. Default empty.
   -- @return mixed Contents of the query variable.
   --
   function Get_Query_Var (Var     : String;
                           Default : String := "")
                           return String;

   function Get_Query_Var (Var     : String;
                           Default : String := "")
                           return Integer
                           is (0);

   --
   -- Determines whether the query is for an existing category archive page.
   --
   -- If the category parameter is specified, this function will additionally
   -- check if the query is for one of the categories specified.
   --
   -- For more information on this and similar theme functions, check out
   -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tags} article in the Theme Developer Handbook.
   --
   -- @since 1.5.0
   --
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @param int|string|int[]|string[] category Optional. Category ID, name, slug,
   --                                            or array of such to check against.
   --                                            Default empty.
   -- @return bool Whether the query is for an existing category archive page.
   --
   function Is_Category (Category : String := "")
                         return Boolean;

end Inc_Querys;
