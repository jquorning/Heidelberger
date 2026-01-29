--
-- Dependencies API: WP_Styles class
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Inc_Themes;
with Inc_Load;
with Inc_Plugins;

package body Class_Styles
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct
      return Wp_Styles
   is
      use UStrings;
      use Inc_Load;
      use Inc_Themes;
      use Inc_Plugins;

      This : Wp_Styles;
   begin
      if
--      function_exists( "is_admin" ) and then
        not Is_Admin and then
--      function_exists( "current_theme_supports" ) and then
        not Current_Theme_Supports ("html5", "style")
      then
         This.Type_Attr := +" type=""text/css""";
      end if;

      --
      -- Fires when the WP_Styles instance is initialized.
      --
      -- @since 2.6.0
      --
      -- @param WP_Styles wp_styles WP_Styles instance (passed by reference).
      --
      Do_Action_Ref_Array ("wp_default_styles", This);
      return This;
   end X_Construct;

--         --
--         -- Processes a style dependency.
--         --
--         -- @since 2.6.0
--         -- @since 5.5.0 Added the `group` parameter.
--         --
--         -- @see WP_Dependencies::do_item()
--         --
--         -- @param string    handle The style"s registered handle.
--         -- @param int|false group  Optional. Group level: level (int), no groups (false).
--         --                          Default false.
--         -- @return bool True on success, false on failure.
--         --
--         public function do_item( handle, group = false ) then
--                 if ( not parent::do_item( handle ) ) then
--                         return false;
--                 end;

--                 obj = this.registered[ handle ];

--                 if ( null === obj.ver ) then
--                         ver = "";
--                 end; else then
--                         ver = obj.ver ? obj.ver : this.default_version;
--                 end;

--                 if ( isset( this.args[ handle ] ) ) then
--                         ver = ver ? ver . "&amp;" . this.args[ handle ] : this.args[ handle ];
--                 end;

--                 src         = obj.src;
--                 cond_before = "";
--                 cond_after  = "";
--                 conditional = isset( obj.extra["conditional"] ) ? obj.extra["conditional"] : "";

--                 if ( conditional ) then
--                         cond_before = "<!--[if thenconditionalend;]>\n";
--                         cond_after  = "<![endif]-.\n";
--                 end;

--                 inline_style = this.print_inline_style( handle, false );

--                 if ( inline_style ) then
--                         inline_style_tag = sprintf(
--                                 "<style id="%s-inline-css"%s>\n%s\n</style>\n",
--                                 esc_attr( handle ),
--                                 this.type_attr,
--                                 inline_style
--                         );
--                 end; else then
--                         inline_style_tag = "";
--                 end;

--                 if ( this.do_concat ) then
--                         if ( this.in_default_dir( src ) and then not conditional and then not isset( obj.extra["alt"] ) ) then
--                                 this.concat         .= "handle,";
--                                 this.concat_version .= "handlever";

--                                 this.print_code .= inline_style;

--                                 return true;
--                         end;
--                 end;

--                 if ( isset( obj.args ) ) then
--                         media = esc_attr( obj.args );
--                 end; else then
--                         media = "all";
--                 end;

--                 // A single item may alias a set of items, by having dependencies, but no source.
--                 if ( not src ) then
--                         if ( inline_style_tag ) then
--                                 if ( this.do_concat ) then
--                                         this.print_html .= inline_style_tag;
--                                 end; else then
--                                         echo inline_style_tag;
--                                 end;
--                         end;

--                         return true;
--                 end;

--                 href = this._css_href( src, ver, handle );
--                 if ( not href ) then
--                         return true;
--                 end;

--                 rel   = isset( obj.extra["alt"] ) and then obj.extra["alt"] ? "alternate stylesheet" : "stylesheet";
--                 title = isset( obj.extra["title"] ) ? sprintf( " title="%s"", esc_attr( obj.extra["title"] ) ) : "";

--                 tag = sprintf(
--                         "<link rel="%s" id="%s-css"%s href="%s"%s media="%s" />\n",
--                         rel,
--                         handle,
--                         title,
--                         href,
--                         this.type_attr,
--                         media
--                 );

--                 --
--                 -- Filters the HTML link tag of an enqueued style.
--                 --
--                 -- @since 2.6.0
--                 -- @since 4.3.0 Introduced the `href` parameter.
--                 -- @since 4.5.0 Introduced the `media` parameter.
--                 --
--                 -- @param string tag    The link tag for the enqueued style.
--                 -- @param string handle The style"s registered handle.
--                 -- @param string href   The stylesheet"s source URL.
--                 -- @param string media  The stylesheet"s media attribute.
--                 --
--                 tag = apply_filters( "style_loader_tag", tag, handle, href, media );

--                 if ( "rtl" === this.text_direction and then isset( obj.extra["rtl"] ) and then obj.extra["rtl"] ) then
--                         if ( is_bool( obj.extra["rtl"] ) || "replace" === obj.extra["rtl"] ) then
--                                 suffix   = isset( obj.extra["suffix"] ) ? obj.extra["suffix"] : "";
--                                 rtl_href = str_replace( "thensuffixend;.css", "-rtlthensuffixend;.css", this._css_href( src, ver, "handle-rtl" ) );
--                         end; else then
--                                 rtl_href = this._css_href( obj.extra["rtl"], ver, "handle-rtl" );
--                         end;

--                         rtl_tag = sprintf(
--                                 "<link rel="%s" id="%s-rtl-css"%s href="%s"%s media="%s" />\n",
--                                 rel,
--                                 handle,
--                                 title,
--                                 rtl_href,
--                                 this.type_attr,
--                                 media
--                         );

--                         -- This filter is documented in wp-includes/class-wp-styles.php--
--                         rtl_tag = apply_filters( "style_loader_tag", rtl_tag, handle, rtl_href, media );

--                         if ( "replace" === obj.extra["rtl"] ) then
--                                 tag = rtl_tag;
--                         end; else then
--                                 tag .= rtl_tag;
--                         end;
--                 end;

--                 if ( this.do_concat ) then
--                         this.print_html .= cond_before;
--                         this.print_html .= tag;
--                         if ( inline_style_tag ) then
--                                 this.print_html .= inline_style_tag;
--                         end;
--                         this.print_html .= cond_after;
--                 end; else then
--                         echo cond_before;
--                         echo tag;
--                         this.print_inline_style( handle );
--                         echo cond_after;
--                 end;

--                 return true;
--         end;

   ----------------------
   -- Add_Inline_Style --
   ----------------------

   function Add_Inline_Style (This   : in out Wp_Styles;
                              Handle : String;
                              Code   : String)
                              return Boolean
   is
      use Lists.List_Vectors;

      After : List_Type;
   begin
      if Code = "" then
         return False;
      end if;

      After := This.Get_Data (Handle, "after");
      if After.Is_Empty then
--    if not After then
         After := []; -- Empty_Array;
      end if;

      After.Append (Code);

      return This.Add_Data (Handle, "after", After);
   end Add_Inline_Style;

--         --
--         -- Prints extra CSS styles of a registered stylesheet.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string handle  The style"s registered handle.
--         -- @param bool   display Optional. Whether to print the inline style
--         --                        instead of just returning it. Default true.
--         -- @return string|bool False if no data exists, inline styles if `display` is true,
--         --                     true otherwise.
--         --
--         public function print_inline_style( handle, display = true ) then
--                 output = this.get_data( handle, "after" );

--                 if ( empty( output ) ) then
--                         return false;
--                 end;

--                 output = implode( "\n", output );

--                 if ( not display ) then
--                         return output;
--                 end;

--                 printf(
--                         "<style id="%s-inline-css"%s>\n%s\n</style>\n",
--                         esc_attr( handle ),
--                         this.type_attr,
--                         output
--                 );

--                 return true;
--         end;

--         --
--         -- Determines style dependencies.
--         --
--         -- @since 2.6.0
--         --
--         -- @see WP_Dependencies::all_deps()
--         --
--         -- @param string|string[] handles   Item handle (string) or item handles (array of strings).
--         -- @param bool            recursion Optional. Internal flag that function is calling itself.
--         --                                   Default false.
--         -- @param int|false       group     Optional. Group level: level (int), no groups (false).
--         --                                   Default false.
--         -- @return bool True on success, false on failure.
--         --
--         public function all_deps( handles, recursion = false, group = false ) then
--                 r = parent::all_deps( handles, recursion, group );
--                 if ( not recursion ) then
--                         --
--                         -- Filters the array of enqueued styles before processing for output.
--                         --
--                         -- @since 2.6.0
--                         --
--                         -- @param string[] to_do The list of enqueued style handles about to be processed.
--                         --
--                         this.to_do = apply_filters( "print_styles_array", this.to_do );
--                 end;
--                 return r;
--         end;

--         --
--         -- Generates an enqueued style"s fully-qualified URL.
--         --
--         -- @since 2.6.0
--         --
--         -- @param string src    The source of the enqueued style.
--         -- @param string ver    The version of the enqueued style.
--         -- @param string handle The style"s registered handle.
--         -- @return string Style"s fully-qualified URL.
--         --
--         public function _css_href( src, ver, handle ) then
--                 if ( not is_bool( src ) and then not preg_match( "|^(https?:)?//|", src ) and then not ( this.content_url and then 0 === strpos( src, this.content_url ) ) ) then
--                         src = this.base_url . src;
--                 end;

--                 if ( not empty( ver ) ) then
--                         src = add_query_arg( "ver", ver, src );
--                 end;

--                 --
--                 -- Filters an enqueued style"s fully-qualified URL.
--                 --
--                 -- @since 2.6.0
--                 --
--                 -- @param string src    The source URL of the enqueued style.
--                 -- @param string handle The style"s registered handle.
--                 --
--                 src = apply_filters( "style_loader_src", src, handle );
--                 return esc_url( src );
--         end;

--         --
--         -- Whether a handle"s source is in a default directory.
--         --
--         -- @since 2.8.0
--         --
--         -- @param string src The source of the enqueued style.
--         -- @return bool True if found, false if not.
--         --
--         public function in_default_dir( src ) then
--                 if ( not this.default_dirs ) then
--                         return true;
--                 end;

--                 foreach ( (array) this.default_dirs as test ) then
--                         if ( 0 === strpos( src, test ) ) then
--                                 return true;
--                         end;
--                 end;
--                 return false;
--         end;

   ---------------------
   -- Do_Footer_Items --
   ---------------------

   procedure Do_Footer_Items (This : in out Wp_Styles)
   is
      Unused : constant List_Type :=
         Do_Footer_Items (This);
   begin
      null;
   end Do_Footer_Items;

   function Do_Footer_Items (This : in out Wp_Styles)
            return List_Type
   is
   begin
      This.Do_Items (False, 1);
      return This.Done;
   end Do_Footer_Items;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : in out Wp_Styles)
   is
      use UStrings;
   begin
      This.Do_Concat      := False;
      This.Concat         := +"";
      This.Concat_Version := +"";
      This.Print_HTML     := +"";
   end Reset;

end Class_Styles;
