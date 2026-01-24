--
-- HTTP API: WP_HTTP_Requests_Response class
--
-- @package WordPress
-- @subpackage HTTP
-- @since 4.6.0
--

with UStrings;

with Inc_Functions;

package body Class_HTTP_Requests_Responses
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Response : Req_Responses.Requests_Response;
                         Filename : String := "")
                         return Wp_HTTP_Requests_Response
   is
      use UStrings;

      This : Wp_HTTP_Requests_Response;
   begin
      This.Response := Response;
      This.Filename := +Filename;
      return This;
   end X_Construct;

   -----------------
   -- Get_Headers --
   -----------------

   function Get_Headers (This : Wp_HTTP_Requests_Response)
                         return String
   is
      -- Ensure headers remain case-insensitive.
--    Converted : := new Requests_Utility_CaseInsensitiveDictionary();
   begin
      -- for ( this.response.headers.getAll() as key => value ) then
      --    if ( count( value ) === 1 ) then
      --       converted[ key ] = value[0];
      --    else
      --       converted[ key ] = value;
      --    end if;
      -- end loop;

      -- return Converted;
      return "XXX-978";
   end Get_Headers;

   ----------------
   -- Get_Status --
   ----------------

   function Get_Status (This : Wp_HTTP_Requests_Response)
                        return Integer
   is
   begin
      return This.Response.Status_Code;
   end Get_Status;

   --------------
   -- Get_Data --
   --------------

   function Get_Data (This : Wp_HTTP_Requests_Response)
                      return String
   is
      use UStrings;
   begin
      return -This.Response.Bodi;
   end Get_Data;

   -----------------
   -- Get_Cookies --
   -----------------

   function Get_Cookies (This : Wp_HTTP_Requests_Response)
                         return List_Type
                         is (Empty_List);
        --         cookies = array();
        --         foreach ( this.response.cookies as cookie ) then
        --                 cookies[] = new WP_Http_Cookie(
        --                         array(
        --                                 "name"      => cookie.name,
        --                                 "value"     => urldecode( cookie.value ),
        --                                 "expires"   => isset( cookie.attributes["expires"] ) ? cookie.attributes["expires"] : null,
        --                                 "path"      => isset( cookie.attributes["path"] ) ? cookie.attributes["path"] : null,
        --                                 "domain"    => isset( cookie.attributes["domain"] ) ? cookie.attributes["domain"] : null,
        --                                 "host_only" => isset( cookie.flags["host-only"] ) ? cookie.flags["host-only"] : null,
        --                         )
        --                 );
        --         end;

        --         return cookies;
        -- end;

   --------------
   -- To_Array --
   --------------

   function To_Array (This : Wp_HTTP_Requests_Response)
                      return Array_Type
   is
      use UStrings;
      use Inc_Functions;
   begin
      return
        To_Array (List => (
          Build ("headers",  This.Get_Headers),
          Build ("body",     This.Get_Data),
          Build ("response", To_Array (List => (
            Build ("code",    This.Get_Status),
            Build ("message", Get_Status_Header_Desc (This.Get_Status))
          ))),
          Build ("cookies",  This.Get_Cookies),
          Build ("filename", -This.Filename)
        ));
   end To_Array;

end Class_HTTP_Requests_Responses;
