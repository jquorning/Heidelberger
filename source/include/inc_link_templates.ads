--
-- WordPress Link Template Functions
--
-- @package WordPress
-- @subpackage Template
--

package Inc_Link_Templates
is
   procedure Dummy;

--
-- Retrieves the URL for a given site where the front end is accessible.
--
-- Returns the "home" option with the appropriate protocol. The protocol will be "https"
-- if is_ssl() evaluates to true; otherwise, it will be the same as the "home" option.
-- If `scheme` is "http" or "https", is_ssl() is overridden.
--
-- @since 3.0.0
--
-- @param int|null    blog_id Optional. Site ID. Default null (current site).
-- @param string      path    Optional. Path relative to the home URL. Default empty.
-- @param string|null scheme  Optional. Scheme to give the home URL context. Accepts
--                             "http", "https", "relative", "rest", or null. Default null.
-- @return string Home URL link with optional path appended.
--
   function Get_Home_Url (Blog_Id : Integer := 0; --  = null,
                          Path    : String  := "";
                          Scheme  : String  := "") -- = null
                          return String
                          is ("XXX-325");

--
-- Retrieves the URL to the admin area for the current user.
--
-- @since 3.0.0
--
-- @param string path   Optional. Path relative to the admin URL. Default empty.
-- @param string scheme Optional. The scheme to use. Default is "admin", which obeys force_ssl_admin()
--                       and is_ssl(). "http" or "https" can be passed to force those schemes.
-- @return string Admin URL link with optional path appended.
--
   function User_Admin_Url (Path   : String := "";
                            Scheme : String := "admin")
                            return String
                            is ("XXX-342");

--
-- Retrieves the URL for the current site where the front end is accessible.
--
-- Returns the "home" option with the appropriate protocol. The protocol will be "https"
-- if is_ssl() evaluates to true; otherwise, it will be the same as the "home" option.
-- If `scheme` is "http" or "https", is_ssl() is overridden.
--
-- @since 3.0.0
--
-- @param string      path   Optional. Path relative to the home URL. Default empty.
-- @param string|null scheme Optional. Scheme to give the home URL context. Accepts
--                            "http", "https", "relative", "rest", or null. Default null.
-- @return string Home URL link with optional path appended.
--
   function Home_Url (Path   : String := "";
                      Scheme : String := "") --  = null
                      return String
                      is ("XXX-344");

end Inc_Link_Templates;
