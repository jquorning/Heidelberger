--
--
--

-- with Php.Arrays;
with Php.Echoing;
with Php.Errors;
with Php.HTML;
with Php.Lists;
with Php.Misc;
with Php.Preg;
with Php.Strings;

with Arrays;
with Binder;
with Constants;
with Globals;
with Helpers;
with Lists;
with UStrings;

with Class_Dependency;
with Class_Styles;

with Adi_Noop;

with Inc_Script_Loader;
-- with Inc_Versions;
-- require ABSPATH . 'wp-admin/includes/noop.php';
-- require ABSPATH . WPINC . '/theme.php';
-- require ABSPATH . WPINC . '/class-wp-theme-json-resolver.php';
-- require ABSPATH . WPINC . '/global-styles-and-settings.php';
-- require ABSPATH . WPINC . '/script-loader.php';
-- require ABSPATH . WPINC . '/version.php';

package body Adm_Load_Styles
is
   use Arrays;
   use Lists;

   function Load_As_String (Load : Multi_Type) return String;

   --------------------
   -- Load_As_String --
   --------------------

   function Load_As_String (Load : Multi_Type) return String is
      use Php.Strings;
   begin
      if Kind_Of (Load) = Kind_Array then
         declare
            Arry : constant Array_Type := As_Array (Load);
         begin
            -- ksort (arry);
            return Implode ("", Arry);
         end;
      else
         return As_String (Load);
      end if;
   end Load_As_String;

   ---------
   -- Run --
   ---------

   procedure Run is
--    use Php.Arrays;
      use Php.Echoing;
      use Php.Errors;
      use Php.HTML;
      use Php.Lists;
      use Php.Misc;
      use Php.Preg;
      use Php.Strings;
      use Binder;
      use Globals;
      use Constants;
      use Helpers;
      use UStrings;
      use Class_Dependency;
   begin
      -- --
      -- -- Disable error reporting.
      -- --
      -- -- Set this to error_reporting( -1 ) for debugging.
      -- --
      -- error_reporting( 0 );

      -- -- Set ABSPATH for execution.
      -- if ( ! defined( 'ABSPATH' ) ) {
      --         define( 'ABSPATH', dirname( __DIR__ ) . '/' );
      -- }

      WPINC := +"wp-includes";
      WP_CONTENT_DIR := +ABSPATH & "wp-content";

      declare
         Protocol_2 : constant String :=
           Get_As_String (X_SERVER, "SERVER_PROTOCOL");

         Protocol : constant String :=
           (if In_List
                 (Protocol_2,
                  List_Type'["HTTP/1.1", "HTTP/2", "HTTP/2.0", "HTTP/3"],
                  True)
            then Protocol_2
            else "HTTP/1.0");

         Load_3 : constant String := Load_As_String (Get (XX_GET, "load"));

         Load : constant String :=
           Preg_Replace ("/[^a-z0-9,_-]+/i", "", Load_3);

         Load_2 : constant List_Type := List_Unique (Explode (",", Load));
      begin
         if Load_2.Is_Empty then
            Header (Protocol & " 400 Bad Request");
            Die;
         end if;

         declare
            RTL : constant Boolean :=
              Isset (XX_GET, "dir")
              and then "rtl" = Get_As_String (XX_GET, "dir");

            Expires_Offset : constant Natural := 31_536_000; -- 1 year.

            Outt : UString;

            Wp_Styles : Class_Styles.Wp_Styles := Class_Styles.X_Construct;
         begin
            Inc_Script_Loader.Wp_Default_Styles (Wp_Styles);
            declare
               Etag : constant String := "XXX-888";
               -- Wp_Styles.Get_Etag (Load_2);
            begin
               if Isset (X_SERVER, "HTTP_IF_NONE_MATCH")
                 and then Strip_Slashes
                            (Get_As_String (X_SERVER, "HTTP_IF_NONE_MATCH"))
                          = Etag
               then
                  Header (Protocol & " 304 Not Modified");
                  Die;
               end if;

               for Handle of Load_2 loop
                  declare
                     use Dependency_Maps;

                     Style : X_Wp_Dependency renames
                       Wp_Styles.Registered (Handle);
                  begin

                     if not Has_Element (Wp_Styles.Registered.Find (Handle))
                     then
                        -- if not Array_Key_Exists (Handle, Wp_Styles.Registered)
                        -- then
                        goto Continue;
                     end if;

                     if Empty (-Style.Src) then
                        goto Continue;
                     end if;

                     declare
                        Path_2 : constant String := -(ABSPATH & Style.Src);

                        Path : constant String :=
                          (if RTL and then not Empty (Style.Extra, "rtl")
                           then
                             -- All default styles have fully independent
                             -- RTL files.
                             Str_Replace (".min.css", "-rtl.min.css", Path_2)
                           else Path_2);

                        Content : constant String :=
                          Adi_Noop.Get_File (Path) & NL;
                     begin
                        if Strpos (-Style.Src, "/" & (-WPINC) & "/css/") = 0
                        then
                           declare
                              Content_2 : constant String :=
                                Str_Replace
                                  ("../images/",
                                   "../" & (-WPINC) & "/images/",
                                   Content);

                              Content_3 : constant String :=
                                Str_Replace
                                  ("../js/tinymce/",
                                   "../" & (-WPINC) & "/js/tinymce/",
                                   Content_2);

                              Content_4 : constant String :=
                                Str_Replace
                                  ("../fonts/",
                                   "../" & (-WPINC) & "/fonts/",
                                   Content_3);
                           begin
                              Append (Outt, Content_4);
                           end;
                        else
                           Append
                             (Outt,
                              Str_Replace ("../images/", "images/", Content));
                        end if;
                     end;
                  end;
                  <<Continue>>
               end loop;

               Header ("Etag: " & Etag);
               Header ("Content-Type: text/css; charset=UTF-8");
               Header
                 ("Expires: "
                  & GMdate ("D, d M Y H:i:s", Time + Expires_Offset)
                  & " GMT");
               Header
                 ("Cache-Control: public, max-age=" & Image (Expires_Offset));

               Echo (-Outt);
            end;
         end;
      end;
   end Run;

end Adm_Load_Styles;
