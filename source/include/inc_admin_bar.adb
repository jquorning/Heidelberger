--
-- Toolbar API: Top-level Toolbar functionality
--
-- @package WordPress
-- @subpackage Toolbar
-- @since 3.1.0
--

with Ada.Containers.Indefinite_Ordered_Maps;

with Php.Echoing;
with Php.HTML;
with Php.Misc;
with Php.Preg;
with Php.Strings;

with Array_Lists;
with Binder;
with Constants;
with Helpers;
with Helpers_3;
with Lists;
with Wp_Common;

with Adi_Class_Wp_Screens;
with Adi_Screens;

with Class_Post_Type;
with Class_Recovery_Mode;
with Class_Sites;
with Class_Taxonomy;
with Inc_Author_Templates;
with Inc_Comments;
with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_General_Templates;
with Inc_L10n;
with Inc_Link_Templates;
with Inc_Load;
with Inc_Media;
with Inc_Ms_Blogs;
with Inc_Ms_Networks;
with Inc_Options;
with Inc_Pluggables;
with Inc_Plugins;
with Inc_Posts;
with Inc_Taxonomys;
with Inc_Themes;
with Inc_Updates;
with Inc_Users;

package body Inc_Admin_Bar
is
   use Lists;

   -- static
   Rendered : Boolean := False;

   -------------------------
   -- X_Wp_Admin_Bar_Init --
   -------------------------

   function X_Wp_Admin_Bar_Init
            return Boolean
   is
--    global wp_admin_bar;
   begin
      if not Is_Admin_Bar_Showing then
         return False;
      end if;

      -- Load the admin bar class code ready for instantiation
--    require_once ABSPATH . WPINC . "/class-wp-admin-bar.php";

      -- Instantiate the admin bar

      --
      -- Filters the admin bar class to instantiate.
      --
      -- @since 3.1.0
      --
      -- @param string wp_admin_bar_class Admin bar class to use. Default
      --                                  "WP_Admin_Bar".
      --

      -- admin_bar_class = apply_filters( "wp_admin_bar_class", "WP_Admin_Bar" );
      -- if ( class_exists( admin_bar_class ) ) then
      --         wp_admin_bar = new admin_bar_class;
      -- end; else then
      --         return false;
      -- end;

      X_Wp_Admin_Bar.Initialize;
      X_Wp_Admin_Bar.Add_Menus;

      return True;
   end X_Wp_Admin_Bar_Init;

   -------------------------
   -- X_Wp_Admin_Bar_Init --
   -------------------------

   function X_Wp_Admin_Bar_Init
              (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Array_Type
   is
      pragma Unreferenced (Arry);
      Unused : constant Boolean := X_Wp_Admin_Bar_Init;
   begin
      return Empty_Array;
   end X_Wp_Admin_Bar_Init;

   -------------------------
   -- Wp_Admin_Bar_Render --
   -------------------------

   procedure Wp_Admin_Bar_Render
   is
      use Helpers_3;
      use Wp_Common;
      use Inc_Plugins;
--    global wp_admin_bar;
   begin
      if Rendered then
         return;
      end if;

      if not Is_Admin_Bar_Showing or else not Is_Object (X_Wp_Admin_Bar) then
         return;
      end if;

      --
      -- Loads all necessary admin bar items.
      --
      -- This is the hook used to add, remove, or manipulate admin bar items.
      --
      -- @since 3.1.0
      --
      -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance, passed by
      --                                  reference.
      --
      Do_Action_Ref_Array ("admin_bar_menu", X_Wp_Admin_Bar); -- &

      --
      -- Fires before the admin bar is rendered.
      --
      -- @since 3.1.0
      --
      Do_Action ("wp_before_admin_bar_render");

      X_Wp_Admin_Bar.Render;

      --
      -- Fires after the admin bar is rendered.
      --
      -- @since 3.1.0
      --
      Do_Action ("wp_after_admin_bar_render");

      Rendered := True;
   end Wp_Admin_Bar_Render;

   --------------------------
   -- Wp_Admin_Bar_Wp_Menu --
   --------------------------

   procedure Wp_Admin_Bar_Wp_Menu
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use Array_Lists;
      use UStrings;
      use Class_Admin_Bar;
      use Inc_Capabilities;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Link_Templates;
      use Inc_Users;

      About_URL : UString;
   begin
      if Current_User_Can ("read") then
         About_URL := +Self_Admin_URL ("about.php");
      elsif Is_Multisite then
         About_URL := +Get_Dashboard_URL (Get_Current_User_Id, "about.php");
      else
         About_URL := Null_UString; -- false;
      end if;

      declare
         Wp_Logo_Menu_Args : Node_Args; --  := X_Construct;
       -- Wp_Logo_Menu_Args : Array_Type := To_Array_Type ([
       --          Build ("id",    "wp-logo"),
       --          Build ("title", "<span class=""ab-icon"" aria-hidden=""true""></span><span class=""screen-reader-text"">" & abs "About WordPress" & "</span>"),
       --          Build ("href",  -About_Url)
       -- ]);
      begin
         Wp_Logo_Menu_Args.Id    := +"wp-logo";
         Wp_Logo_Menu_Args.Title := +"<span class=""ab-icon"" aria-hidden=""true""></span><span class=""screen-reader-text"">" & abs "About WordPress" & "</span>";
         Wp_Logo_Menu_Args.Href  := About_URL;

         -- Set tabindex="0" to make sub menus accessible when no URL is available.
         if About_URL /= "" then
            Wp_Logo_Menu_Args.Meta := To_Array_Type ([
                                         Build ("tabindex", 0)]);
         end if;

         Admin_Bar.Add_Node (Wp_Logo_Menu_Args);
      end;

      if About_URL /= "" then
         -- Add "About WordPress" link.
         declare
            Node : Node_Args; -- :=  X_Construct;
         begin
            Node.Parent := +"wp-logo";
            Node.Id     := +"about";
            Node.Title  := +abs "About WordPress";
            Node.Href   := About_URL;

            Admin_Bar.Add_Node (Node);
         end;
      end if;

      -- Add WordPress.org link.
      declare
         Node : Node_Args;
      begin
         Node.Parent := +"wp-logo-external";
         Node.Id     := +"wporg";
         Node.Title  := +abs "WordPress.org";
         Node.Href   := +abs "https://wordpress.org/";

         Admin_Bar.Add_Node (Node);
      end;

      -- Add documentation link.
      declare
         Node : Node_Args;
      begin
         Node.Parent := +"wp-logo-external";
         Node.Id     := +"documentation";
         Node.Title  := +abs "Documentation";
         Node.Href   := +abs "https://wordpress.org/support/";

         Admin_Bar.Add_Node (Node);
      end;

      -- Add forums link.
      declare
         Node : Node_Args;
      begin
         Node.Parent := +"wp-logo-external";
         Node.Id     := +"support-forums";
         Node.Title  := +abs "Support";
         Node.Href   := +abs "https://wordpress.org/support/forums/";

         Admin_Bar.Add_Node (Node);
      end;

      -- Add feedback link.
      declare
         Node : Node_Args;
      begin
         Node.Parent := +"wp-logo-external";
         Node.Id     := +"feedback";
         Node.Title  := +abs "Feedback";
         Node.Href   := +abs "https://wordpress.org/support/forum/requests-and-feedback";
         Admin_Bar.Add_Node (Node);
      end;
   end Wp_Admin_Bar_Wp_Menu;

   ---------------------------------
   -- Wp_Admin_Bar_Sidebar_Toggle --
   ---------------------------------

   procedure Wp_Admin_Bar_Sidebar_Toggle
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use UStrings;
      use Class_Admin_Bar;
      use Inc_Load;
      use Inc_L10n;
   begin
      if Is_Admin then
         declare
            Node : Node_Args;
         begin
            Node.Id     := +"menu-toggle";
            Node.Title  := +"<span class=""ab-icon"" aria-hidden=""true""></span><span class=""screen-reader-text"">" & abs "Menu" & "</span>";
            Node.Href   := +"#";

            Admin_Bar.Add_Node (Node);
         end;
      end if;
   end Wp_Admin_Bar_Sidebar_Toggle;

   ----------------------------------
   -- Wp_Admin_Bar_My_Account_Item --
   ----------------------------------

   procedure Wp_Admin_Bar_My_Account_Item
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Class_Admin_Bar;
      use Class_Users;
      use Inc_Capabilities;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Pluggables;
      use Inc_Users;

      User_Id      : constant User_Id_Type := Get_Current_User_Id;
      Current_User : constant Wp_User      := Wp_Get_Current_User;
      Profile_Url  : UString;
   begin
      if User_Id = 0 then
         return;
      end if;

      if Current_User_Can ("read") then
         Profile_Url := +Get_Edit_Profile_URL (User_Id);
      elsif Is_Multisite then
         Profile_Url := +Get_Dashboard_URL (User_Id, "profile.php");
      else
         Profile_Url := Null_UString; -- false;
      end if;

      declare
         Avatar : constant String :=
           Get_Avatar (Helpers.Image (Integer (User_Id)), 26);

         -- translators: %s: Current user"s display name.
         Howdy : constant String :=
            Sprintf (abs "Howdy, %s",
                     [1 => "<span class=""display-name"">"  &
                           (-Current_User.Prop.Display_Name) &
                           "</span>"]);

         Class : String := (if Empty (Avatar) then "" else "with-avatar");
         Node  : Node_Args;
      begin
         Node.Id     := +"my-account";
         Node.Parent := +"top-secondary";
         Node.Title  := +Howdy & Avatar;
         Node.Href   := Profile_Url;
         Node.Meta   := To_Array_Type ([Build ("class", Class)]);

         Admin_Bar.Add_Node (Node);
      end;
   end Wp_Admin_Bar_My_Account_Item;

   ----------------------------------
   -- Wp_Admin_Bar_My_Account_Menu --
   ----------------------------------

   procedure Wp_Admin_Bar_My_Account_Menu
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use Array_Lists;
      use UStrings;
      use Class_Admin_Bar;
      use Class_Users;
      use Inc_Capabilities;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Pluggables;
      use Inc_Users;

      User_Id      : constant User_Id_Type := Get_Current_User_Id;
      Current_User : constant Wp_User      := Wp_Get_Current_User;
      Profile_Url  : UString;
      User_Info    : UString;
   begin
      if User_Id = 0 then
         return;
      end if;

      if Current_User_Can ("read") then
         Profile_Url := +Get_Edit_Profile_URL (User_Id);
      elsif Is_Multisite then
         Profile_Url := +Get_Dashboard_URL (User_Id, "profile.php");
      else
         Profile_Url := Null_UString; -- false;
      end if;

      declare
         Node : Node_Args;
      begin
         Node.Parent := +"my-account";
         Node.Id     := +"user-actions";

         Admin_Bar.Add_Group (Node);
      end;

      User_Info := +Get_Avatar (Helpers.Image (Integer (User_Id)), 64);
      User_Info := User_Info & "<span class=""display-name"">" &
                               Current_User.Prop.Display_Name & "</span>";

      if Current_User.Prop.Display_Name /= Current_User.Prop.User_Login then
         User_Info := User_Info & "<span class=""username"">" &
                      Current_User.Prop.User_Login & "</span>";
      end if;

      declare
         Node : Node_Args;
      begin
         Node.Parent := +"user-actions";
         Node.Id     := +"user-info";
         Node.Title  := User_Info;
         Node.Href   := Profile_Url;
         Node.Meta   := To_Array_Type ([Build ("tabindex", -1)]);

         Admin_Bar.Add_Node (Node);
      end;

      if "" /= Profile_Url then
         declare
            Node : Node_Args;
         begin
            Node.Parent := +"user-actions";
            Node.Id     := +"edit-profile";
            Node.Title  := +abs "Edit Profile";
            Node.Href   := Profile_Url;

            Admin_Bar.Add_Node (Node);
         end;
      end if;

      declare
         Node : Node_Args;
      begin
         Node.Parent := +"user-actions";
         Node.Id     := +"logout";
         Node.Title  := +abs "Log Out";
         Node.Href   := +Wp_Logout_URL;

         Admin_Bar.Add_Node (Node);
      end;
   end Wp_Admin_Bar_My_Account_Menu;

   ----------------------------
   -- Wp_Admin_Bar_Site_Menu --
   ----------------------------

   procedure Wp_Admin_Bar_Site_Menu
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use Php.Preg;
      use Php.Strings;
      use UStrings;
      use Class_Admin_Bar;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Pluggables;
      use Inc_Users;
      use Inc_Ms_Networks;

      Blogname : UString;
   begin
      -- Don"t show for logged out users.
      if not Is_User_Logged_In then
         return;
      end if;

      -- Show only when the user is a member of this site, or they"re a super admin.
      if
        not Is_User_Member_Of_Blog and then
        not Current_User_Can ("manage_network")
      then
         return;
      end if;

      Blogname := +Get_Bloginfo ("name");

      if Blogname = "" then
         Blogname := +Preg_Replace ("#^(https?://)?(www.)?#", "", Get_Home_URL);
      end if;

      if Is_Network_Admin then
         -- translators: %s: Site title.
         Blogname := +Sprintf (abs "Network Admin: %s",
                               [1 => ESC_HTML (-Get_Network.Site_Name)]);
      elsif Is_User_Admin then
         -- translators: %s: Site title.
         Blogname := +Sprintf (abs "User Dashboard: %s",
                               [1 => ESC_HTML (-Get_Network.Site_Name)]);
      end if;

      declare
         Title : constant String := Wp_HTML_Excerpt (-Blogname, 40, "&hellip;");
         Node  : Node_Args;
      begin
         Node.Id    := +"site-name";
         Node.Title := +Title;
         Node.Href  := +(if Is_Admin or else not Current_User_Can ("read")
                         then Home_URL ("/") else Admin_URL);

         Admin_Bar.Add_Node (Node);
      end;

      -- Create submenu items.
      if Is_Admin then
         -- Add an option to visit the site.
         declare
            Node : Node_Args;
         begin
            Node.Parent := +"site-name";
            Node.Id     := +"view-site";
            Node.Title  := +abs "Visit Site";
            Node.Href   := +Home_URL ("/");

            Admin_Bar.Add_Node (Node);
         end;

         if
           Is_Blog_Admin and then
           Is_Multisite and then
           Current_User_Can ("manage_sites")
         then
            declare
               Node : Node_Args;
            begin
               Node.Parent := +"site-name";
               Node.Id     := +"edit-site";
               Node.Title  := +abs "Edit Site";
               Node.Href   := +Network_Admin_URL
                                 ("site-info.php?id=" &
                                  Helpers.Image (Get_Current_Blog_Id));
               Admin_Bar.Add_Node (Node);
            end;
         end if;

      elsif Current_User_Can ("read") then
         -- We"re on the front end, link to the Dashboard.
         declare
            Node : Node_Args;
         begin
            Node.Parent := +"site-name";
            Node.Id     := +"dashboard";
            Node.Title  := +abs "Dashboard";
            Node.Href   := +Admin_URL;

            Admin_Bar.Add_Node (Node);
         end;

         -- Add the appearance submenu items.
         Wp_Admin_Bar_Appearance_Menu (X_Wp_Admin_Bar);
      end if;
   end Wp_Admin_Bar_Site_Menu;

   ---------------------------------
   -- Wp_Admin_Bar_Edit_Site_Menu --
   ---------------------------------

   procedure Wp_Admin_Bar_Edit_Site_Menu
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use UStrings;
      use Class_Admin_Bar;
      use Inc_Capabilities;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Themes;
   begin
      -- Don't show if a block theme is not activated.
      if not Wp_Is_Block_Theme then
         return;
      end if;

      -- Don"t show for users who can"t edit theme options or when in the admin.
      if not Current_User_Can ("edit_theme_options") or else Is_Admin then
         return;
      end if;

      declare
         Node : Node_Args;
      begin
         Node.Id    := +"site-editor";
         Node.Title := +abs "Edit site";
         Node.Href  := +Admin_URL ("site-editor.php");

         Admin_Bar.Add_Node (Node);
      end;
   end Wp_Admin_Bar_Edit_Site_Menu;

   ---------------------------------
   -- Wp_Admin_Bar_Customize_Menu --
   ---------------------------------

   procedure Wp_Admin_Bar_Customize_Menu
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use Php.HTML;
      use Array_Lists;
      use Binder;
      use UStrings;
      use Class_Admin_Bar;
      use Inc_Capabilities;
      use Inc_Functions;
      use Inc_Load;
      use Inc_L10n;
--    use Inc_Pluggables;
      use Inc_Plugins;
      use Inc_Posts;
      use Inc_Themes;
--    use Globals;

--    global wp_customize;
      Current_URL   : UString;
      Customize_URL : UString;
   begin
      -- Don't show if a block theme is activated and no plugins use the customizer.
      if Wp_Is_Block_Theme and then not Has_Action ("customize_register") then
         return;
      end if;

      -- Don't show for users who can"t access the customizer or when in the admin.
      if not Current_User_Can ("customize") or else Is_Admin then
         return;
      end if;

      -- Don't show if the user cannot edit a given customize_changeset post
      -- currently being previewed.
      if
        Is_Customize_Preview and then
        Wp_Customize.Changeset_Post_Id not in 0 and then
        not Current_User_Can
             (Get_As_String (Get_Post_Type_Object ("customize_changeset").Cap,
                                                   "edit_post"),
              Integer (Wp_Customize.Changeset_Post_Id))
      then
         return;
      end if;

      Current_URL := +(if Is_SSL then "https://" else "http://") &
                       Get_As_String (X_SERVER, "HTTP_HOST") &
                       Get_As_String (X_SERVER, "REQUEST_URI");

      if
        Is_Customize_Preview and then
        Wp_Customize.X_Changeset_UUID /= ""
      then
         Current_URL := +Remove_Query_Arg ("customize_changeset_uuid", -Current_URL);
      end if;

      Customize_URL := +Add_Query_Arg ("url", URL_Encode (-Current_URL),
                                       Wp_Customize_URL);
      if Is_Customize_Preview then
         Customize_URL :=
            +Add_Query_Arg (To_Array_Type ([
               Build ("changeset_uuid", -Wp_Customize.X_Changeset_UUID)]),
                           -Customize_URL);
      end if;

      declare
         Node : Node_Args;
      begin
         Node.Id    := +"customize";
         Node.Title := +abs "Customize";
         Node.Href  := Customize_URL;
         Node.Meta  := To_Array_Type ([
                          Build ("class", "hide-if-no-customize")]);

         Admin_Bar.Add_Node (Node);
      end;

      Add_Action ("wp_before_admin_bar_render",
                  Wp_Customize_Support_Script'Access);
   end Wp_Admin_Bar_Customize_Menu;

   --------------------------------
   -- Wp_Admin_Bar_My_Sites_Menu --
   --------------------------------

   procedure Wp_Admin_Bar_My_Sites_Menu
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use Ada.Containers;
      use Php.Preg;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Wp_Common;
      use Class_Admin_Bar;
      use Class_Sites;
      use Inc_Capabilities;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Pluggables;
      use Inc_Posts;
      use Blog_Vectors;

      My_Sites_Url : UString;
      Unused       : Boolean;
   begin
      -- Don"t show for logged out users or single site mode.
      if not Is_User_Logged_In or else not Is_Multisite then
         return;
      end if;

      -- Show only when the user has at least one site, or they"re a super admin.
      if
        Length (Admin_Bar.User.Blogs) < 1 and then
        not Current_User_Can ("manage_network")
      then
         return;
      end if;

      if Admin_Bar.User.Active_Blog /= Null_Site then -- "" then
         My_Sites_Url := +Get_Admin_URL (Admin_Bar.User.Active_Blog.Blog_Id,
                                         "my-sites.php");
      else
         My_Sites_Url := +Admin_URL ("my-sites.php");
      end if;

      declare
         Node : Node_Args;
      begin
         Node.Id    := +"my-sites";
         Node.Title := +abs "My Sites";
         Node.Href  := My_Sites_Url;

         Admin_Bar.Add_Node (Node);
      end;

      if Current_User_Can ("manage_network") then
         declare
            Node : Node_Args;
         begin
            Node.Parent := +"my-sites";
            Node.Id     := +"my-sites-super-admin";

            Admin_Bar.Add_Group (Node);
         end;

         declare
            Node : Node_Args;
         begin
            Node.Parent := +"my-sites-super-admin";
            Node.Id     := +"network-admin";
            Node.Title  := +abs "Network Admin";
            Node.Href   := +Network_Admin_URL;

            Admin_Bar.Add_Node (Node);
         end;

         declare
            Node : Node_Args;
         begin
            Node.Parent := +"network-admin";
            Node.Id     := +"network-admin-d";
            Node.Title  := +abs "Dashboard";
            Node.Href   := +Network_Admin_URL;

            Admin_Bar.Add_Node (Node);
         end;

         if Current_User_Can ("manage_sites") then
            declare
               Node : Node_Args;
            begin
               Node.Parent := +"network-admin";
               Node.Id     := +"network-admin-s";
               Node.Title  := +abs "Sites";
               Node.Href   := +Network_Admin_URL ("sites.php");

               Admin_Bar.Add_Node (Node);
            end;
         end if;

         if Current_User_Can ("manage_network_users") then
            declare
               Node : Node_Args;
            begin
               Node.Parent := +"network-admin";
               Node.Id     := +"network-admin-u";
               Node.Title  := +abs "Users";
               Node.Href   := +Network_Admin_URL ("users.php");

               Admin_Bar.Add_Node (Node);
            end;
         end if;

         if Current_User_Can ("manage_network_themes") then
            declare
               Node : Node_Args;
            begin
               Node.Parent := +"network-admin";
               Node.Id     := +"network-admin-t";
               Node.Title  := +abs "Themes";
               Node.Href   := +Network_Admin_URL ("themes.php");

               Admin_Bar.Add_Node (Node);
            end;
         end if;

         if Current_User_Can ("manage_network_plugins") then
            declare
               Node : Node_Args;
            begin
               Node.Parent := +"network-admin";
               Node.Id     := +"network-admin-p";
               Node.Title  := +abs "Plugins";
               Node.Href   := +Network_Admin_URL ("plugins.php");

               Admin_Bar.Add_Node (Node);
            end;
         end if;

         if Current_User_Can ("manage_network_options") then
            declare
               Node : Node_Args;
            begin
               Node.Parent := +"network-admin";
               Node.Id     := +"network-admin-o";
               Node.Title  := +abs "Settings";
               Node.Href   := +Network_Admin_URL ("settings.php");

               Admin_Bar.Add_Node (Node);
            end;
         end if;
      end if;

      -- Add site links.
      declare
         Node : Node_Args;
      begin
         Node.Parent := +"my-sites";
         Node.Id     := +"my-sites-list";
         Node.Meta   :=
            To_Array_Type ([Build ("class",
                           (if Current_User_Can ("manage_network")
                            then "ab-sub-secondary" else ""))]);
         Admin_Bar.Add_Group (Node);
      end;

      --
      -- Filters whether to show the site icons in toolbar.
      --
      -- Returning false to this hook is the recommended way to hide site icons in
      -- the toolbar.
      -- A truthy return may have negative performance impact on large multisites.
      --
      -- @since 6.0.0
      --
      -- @param bool show_site_icons Whether site icons should be shown in the
      --                             toolbar. Default true.
      --
      declare
         use Inc_Formatting;

         Show_Site_Icons : constant Boolean :=
            Apply_Filters ("wp_admin_bar_show_site_icons", True);
      begin

         for Blog of Admin_Bar.User.Blogs loop -- (array)
            declare
               use Inc_General_Templates;
               use Inc_Media;
               use Inc_Ms_Blogs;

               Blavatar : UString;
               Blogname : UString;
               Unused   : Boolean;
            begin
               Unused := Switch_To_Blog (Blog.Userblog_Id);

               if True = Show_Site_Icons and then Has_Site_Icon then
                  Blavatar :=
                    +Sprintf (
                      "<img class=""blavatar"" src=""%s"" srcset=""%s 2x"" alt="""" width=""16"" height=""16""%s />",
                      [
                        1 => ESC_URL (Get_Site_Icon_URL (16)),
                        2 => ESC_URL (Get_Site_Icon_URL (32)),
                        3 => (if Wp_Lazy_Loading_Enabled ("img", "site_icon_in_toolbar") then " loading=""lazy""" else "")
                      ]
                    );
               else
                  Blavatar := +"<div class=""blavatar""></div>";
               end if;

               Blogname := Blog.Blogname;

               if Blogname = "" then
                  Blogname := +Preg_Replace ("#^(https?:--)?(www.)?#", "",
                                             Get_Home_URL);
               end if;

               declare
                  Menu_Id : constant String :=
                     "blog-" & Helpers.Image (Blog.Userblog_Id);
               begin
                  if Current_User_Can ("read") then
                     declare
                        Node : Node_Args;
                     begin
                        Node.Parent := +"my-sites-list";
                        Node.Id     := +Menu_Id;
                        Node.Title  := Blavatar & Blogname;
                        Node.Href   := +Admin_URL;

                        Admin_Bar.Add_Node (Node);
                     end;

                     declare
                        Node : Node_Args;
                     begin
                        Node.Parent := +Menu_Id;
                        Node.Id     := +Menu_Id & "-d";
                        Node.Title  := +abs "Dashboard";
                        Node.Href   := +Admin_URL;

                        Admin_Bar.Add_Node (Node);
                     end;
                  else
                     declare
                        Node : Node_Args;
                     begin
                        Node.Parent := +"my-sites-list";
                        Node.Id     := +Menu_Id;
                        Node.Title  := Blavatar & Blogname;
                        Node.Href   := +Home_URL;

                        Admin_Bar.Add_Node (Node);
                     end;
                  end if;

                  if
                    Current_User_Can (Get_As_String (Get_Post_Type_Object ("post").Cap,
                                                      "create_posts"))
                  then
                     declare
                        Node : Node_Args;
                     begin
                        Node.Parent := +Menu_Id;
                        Node.Id     := +Menu_Id & "-n";
                        Node.Title  := +Get_As_String (Get_Post_Type_Object ("post").Labels,
                                                        "new_item");
                        Node.Href   := +Admin_URL ("post-new.php");

                        Admin_Bar.Add_Node (Node);
                     end;
                  end if;

                  if Current_User_Can ("edit_posts") then
                     declare
                        Node : Node_Args;
                     begin
                        Node.Parent := +Menu_Id;
                        Node.Id     := +Menu_Id & "-c";
                        Node.Title  := +abs "Manage Comments";
                        Node.Href   := +Admin_URL ("edit-comments.php");

                        Admin_Bar.Add_Node (Node);
                     end;
                  end if;

                  declare
                     Node : Node_Args;
                  begin
                     Node.Parent := +Menu_Id;
                     Node.Id     := +Menu_Id & "-v";
                     Node.Title  := +abs "Visit Site";
                     Node.Href   := +Home_URL ("/");

                     Admin_Bar.Add_Node (Node);
                  end;
               end;
            end;

            declare
               use Inc_Ms_Blogs;

               Unused : Boolean;
            begin
               Unused := Restore_Current_Blog;
            end;
         end loop;
      end;
   end Wp_Admin_Bar_My_Sites_Menu;

   ---------------------------------
   -- Wp_Admin_Bar_Shortlink_Menu --
   ---------------------------------

   procedure Wp_Admin_Bar_Shortlink_Menu
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Class_Admin_Bar;
      use Inc_Formatting;
      use Inc_Link_Templates;
      use Inc_L10n;

      Short : constant String := Wp_Get_Shortlink (0, "query");
      Id    : constant String := "get-shortlink";
      Html  : UString;
   begin
      if Empty (Short) then
         return;
      end if;

      Html :=
         +"<input class=""shortlink-input"" type=""text"" readonly=""readonly"" value=""" & ESC_Attr (Short) & """ aria-label=""" & abs "Shortlink" & """ />";

      declare
         Node : Node_Args;
      begin
         Node.Id    := +Id;
         Node.Title := +abs "Shortlink";
         Node.Href  := +Short;
         Node.Meta  := To_Array_Type ([Build ("html", -Html)]);

         Admin_Bar.Add_Node (Node);
      end;
   end Wp_Admin_Bar_Shortlink_Menu;

   ----------------------------
   -- Wp_Admin_Bar_Edit_Menu --
   ----------------------------

   procedure Wp_Admin_Bar_Edit_Menu
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Class_Admin_Bar;
      use Adi_Class_Wp_Screens;
      use Adi_Screens;
      use Class_Posts;
      use Class_Post_Type;
      use Class_Users;
      use Class_Terms;
      use Inc_Capabilities;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Posts;
      use Inc_Taxonomys;

--    global tag, wp_the_query, user_id, post_id;
   begin
      if Is_Admin then
         declare
            Current_Screen   : constant Wp_Screen := Get_Current_Screen;
            Post             : Wp_Post   := Get_Post;
            Post_Type_Object : Wp_Post_Type; -- = null;
         begin
            if "post" = Current_Screen.Base then
               Post_Type_Object := Get_Post_Type_Object (-Post.Post_Type);
            elsif "edit" = Current_Screen.Base then
               Post_Type_Object := Get_Post_Type_Object (-Current_Screen.Post_Type);
            elsif "edit-comments" = Current_Screen.Base and then Id_Of_Post /= 0 then
               Post := Get_Post (Id_Of_Post);
               if Post = Null_Post then
                  Post_Type_Object := Get_Post_Type_Object (-Post.Post_Type);
               end if;
            end if;

            if ("post" = Current_Screen.Base or else
                "edit-comments" = Current_Screen.Base)
                  or else "add" /= Current_Screen.Action
                  or else (Post_Type_Object /= Null_Post_Type)
                  or else Current_User_Can ("read_post", Integer (Post.Id))
                  or else (Post_Type_Object.Public)
                  or else Post_Type_Object.Show_In_Admin_Bar
            then
               if "draft" = Post.Post_Status then
                  declare
                     use Inc_Formatting;

                     Preview_Link : constant String := Get_Preview_Post_Link (Post);
                     Node : Node_Args;
                  begin
                     Node.Id    := +"preview";
                     Node.Title := +Get_As_String (Post_Type_Object.Labels, "view_item");
                     Node.Href  := +ESC_URL (Preview_Link);
                     Node.Meta  :=
                        To_Array_Type ([
                           Build ("target",
                                  "wp-preview-" & "XXX-451")]); --"Image (Post_Id) (Post.Id))));

                     Admin_Bar.Add_Node (Node);
                  end;
               else
                  declare
                     Node : Node_Args;
                  begin
                     Node.Id    := +"view";
                     Node.Title := +Get_As_String (Post_Type_Object.Labels, "view_item");
                     Node.Href  := +Get_Permalink (Post.Id);

                     Admin_Bar.Add_Node (Node);
                  end;
               end if;
            elsif
              "edit" = Current_Screen.Base
              or else (Post_Type_Object /= Null_Post_Type)
              or else (Post_Type_Object.Public)
              or else (Post_Type_Object.Show_In_Admin_Bar)
              or else (Get_Post_Type_Archive_Link (-Post_Type_Object.Name) /= "")
              or else not ("post" = Post_Type_Object.Name or else
                           "posts" = Get_Option ("show_on_front"))
            then
               declare
                  Node : Node_Args;
               begin
                  Node.Id    := +"archive";
                  Node.Title := +Get_As_String (Post_Type_Object.Labels, "view_items");
                  Node.Href  :=
                    +Get_Post_Type_Archive_Link (-Current_Screen.Post_Type);

                  Admin_Bar.Add_Node (Node);
               end;

            elsif
               "term" = Current_Screen.Base or else
               Tag /= Null_Term -- or else
--             Is_Object (Tag) or else
--             not Is_Wp_Error (Tag)
            then
               declare
                  use Class_Taxonomy;

                  Tax : constant Wp_Taxonomy := Get_Taxonomy (-Tag.Taxonomy);
               begin
                  if Is_Term_Publicly_Viewable (Tag) then
                     declare
                        Node : Node_Args;
                     begin
                        Node.Id    := +"view";
                        Node.Title := +Get_As_String (Tax.Labels, "view_item");
                        Node.Href  := +Get_Term_Link (Tag);

                        Admin_Bar.Add_Node (Node);
                     end;
                  end if;
               end;

            elsif "user-edit" = Current_Screen.Base or else User_Id not in 0 then
               declare
                  use Inc_Author_Templates;
                  use Inc_Pluggables;

                  User_Object : constant Wp_User := Get_Userdata (User_Id);

                  View_Link   : constant String :=
                     Get_Author_Posts_Url (Integer (User_Object.Id));
               begin
                  if User_Object.Exists or else View_Link /= "" then
                     declare
                        Node : Node_Args;
                     begin
                        Node.Id    := +"view";
                        Node.Title := +abs "View User";
                        Node.Href  := +View_Link;

                        Admin_Bar.Add_Node (Node);
                     end;
                  end if;
               end;
            end if;
         end;
      else
         declare
            Current_Object : constant Wp_Post := Wp_The_Query.Get_Queried_Object;
         begin
            if Current_Object = Null_Post then
--          if Empty (Current_Object) then
               return;
            end if;

            if not Empty (Current_Object.Post_Type) then
               declare
                  Post_Type_Object : constant Wp_Post_Type :=
                     Get_Post_Type_Object (-Current_Object.Post_Type);

                  Edit_Post_Link : constant String :=
                     Get_Edit_Post_Link (Current_Object.Id);
               begin
                  if Post_Type_Object /= Null_Post_Type
                    or else Edit_Post_Link /= ""
                    or else Current_User_Can ("edit_post", Integer (Current_Object.Id))
                    or else Post_Type_Object.Show_In_Admin_Bar
                  then
                     declare
                        Node : Node_Args;
                     begin
                        Node.Id    := +"edit";
                        Node.Title := +Get_As_String (Post_Type_Object.Labels, "edit_item");
                        Node.Href  := +Edit_Post_Link;

                        Admin_Bar.Add_Node (Node);
                     end;
                  end if;
               end;

            elsif Current_Object.Props.Taxonomy /= "" then
               declare
                  use Class_Taxonomy;

                  Tax : constant Wp_Taxonomy :=
                     Get_Taxonomy (-Current_Object.Props.Taxonomy);

                  Edit_Term_Link : constant String :=
                     Get_Edit_Term_Link (Current_Object.Props.Term_Id,
                                         -Current_Object.Props.Taxonomy);
               begin
                  if
                    Tax /= Null_Taxonomy or else
                    Edit_Term_Link /= "" or else
                    Current_User_Can ("edit_term", Current_Object.Props.Term_Id)
                  then
                     declare
                        Node : Node_Args;
                     begin
                        Node.Id    := +"edit";
                        Node.Title := +Get_As_String (Tax.Labels, "edit_item");
                        Node.Href  := +Edit_Term_Link;

                        Admin_Bar.Add_Node (Node);
                     end;
                  end if;
               end;
            elsif
--            Is_A (Current_Object, "WP_User") or else
              Current_User_Can ("edit_user", Integer (Current_Object.Id))
            then
               declare
                  Edit_User_Link : constant String :=
                     Get_Edit_User_Link (User_Id_Type (Current_Object.Id)); -- ???
               begin
                  if Edit_User_Link /= "" then
                     declare
                        Node : Node_Args;
                     begin
                        Node.Id    := +"edit";
                        Node.Title := +abs "Edit User";
                        Node.Href  := +Edit_User_Link;

                        Admin_Bar.Add_Node (Node);
                     end;
                  end if;
               end;
            end if;
         end;
      end if;
   end Wp_Admin_Bar_Edit_Menu;

   -----------------------------------
   -- Wp_Admin_Bar_New_Content_Menu --
   -----------------------------------

   procedure Wp_Admin_Bar_New_Content_Menu
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use Array_Lists;
      use UStrings;
      use Class_Admin_Bar;
      use Inc_Capabilities;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Posts;
      use Class_Post_Type;
      use Class_Post_Type.Post_Type_Maps;

      package Action_Maps is new
         Ada.Containers.Indefinite_Ordered_Maps
           (Key_Type     => String,
            Element_Type => Array_Type,
            "="          => Arrays."="); -- Array_Maps."=");

      function Array_Keys (Map : Action_Maps.Map)
                           return List_Type;

      function Array_Keys (Map : Action_Maps.Map)
                           return List_Type
      is
         Result : List_Type;
      begin
         for A in Map.Iterate loop
            Result.Append (Action_Maps.Key (A));
         end loop;
         return Result;
      end Array_Keys;

      Actions : Action_Maps.Map; -- Array_Type;
      Cpts    : Wp_Post_Type_Array :=
         Get_Post_Types (To_Array_Type ([Build ("show_in_admin_bar", "true")]),
                         "objects"); -- (array)
   begin
      if
        Has_Element (Cpts.Find ("post")) or else
--      Isset (cpts ("post")) or else
        Current_User_Can (Get_As_String (Cpts ("post").Cap, "create_posts"))
      then
         Actions ("post-new.php") :=
            To_Array_Type ([
               Build (Get_As_String (Cpts ("post").Labels, "name_admin_bar"), "new-post")]);
      end if;

      if
        Has_Element (Cpts.Find ("attachment")) or else
        Current_User_Can ("upload_files")
      then
         Actions ("media-new.php") :=
            To_Array_Type ([
               Build (Get_As_String (Cpts ("attachment").Labels, "name_admin_bar"),
                      "new-media")]);
      end if;

      if Current_User_Can ("manage_links") then
         Actions ("link-add.php") :=
            To_Array_Type ([
               Build (X_X ("Link", "add new from admin bar"), "new-link")]);
      end if;

      if
        Has_Element (Cpts.Find ("page")) or else
        Current_User_Can (Get_As_String (Cpts ("page").Cap, "create_posts"))
      then
         Actions ("post-new.php?post_type=page") :=
            To_Array_Type ([
               Build (Get_As_String (Cpts ("page").Labels, "name_admin_bar"),
                      "new-page")]);
      end if;

      Cpts.Delete ("post");
      Cpts.Delete ("page");
      Cpts.Delete ("attachment");
      -- Unset (cpts ("post"));
      -- Unset (cpts ("page"));
      -- Unset (cpts ("attachment"));

      -- Add any additional custom post types.
      for Cpt of Cpts loop
         if not Current_User_Can (Get_As_String (Cpt.Cap, "create_posts")) then
            goto Continue;
         end if;

         declare
            Key : constant String := "post-new.php?post_type=" & (-Cpt.Name);
         begin
            Actions (Key) :=
               To_Array_Type ([
                  Build (Get_As_String (Cpt.Labels, "name_admin_bar"),
                         "new-" & (-Cpt.Name))]);
         end;
         << Continue >>
      end loop;

      -- Avoid clash with parent node and a "content" post type.
--      if Isset (actions ("post-new.php?post_type=content")) then
--         actions ("post-new.php?post_type=content") (1) := "add-new-content";
--      end if;

      if
        Current_User_Can ("create_users") or else
        Is_Multisite or else
        Current_User_Can ("promote_users")
      then
         Actions ("user-new.php") :=
            To_Array_Type ([Build (X_X ("User", "add new from admin bar"),
                                   "new-user")]);
      end if;

      if Actions.Is_Empty then
         return;
      end if;

      declare
         use Php.Misc;

         Title : constant String :=
            "<span class=""ab-icon"" aria-hidden=""true""></span><span class=""ab-label"">" & X_X ("New", "admin bar menu group label") & "</span>";

         Node  : Node_Args;

--       Arry  : constant Array_Type :=
--          Action_Maps.Element (Actions.Find ("user-new.php"));

--       Value : constant String := Arry.First_Key;
      begin
         Node.Id    := +"new-content";
         Node.Title := +Title;
         Node.Href  := +Admin_URL (Current (Array_Keys (Actions)));

         Admin_Bar.Add_Node (Node);

         for A in Actions.Iterate loop
            declare
               Link   : constant String     := Action_Maps.Key (A);
               Action : constant Array_Type := Action_Maps.Element (A);
               Title  : constant String     := Action.First_Key;
               -- Title; -- list()
               Id     : constant String     := As_String (Action.First_Element); -- Id;

               Node : Node_Args;
            begin
               Node.Parent := +"new-content";
               Node.Id     := +Id;
               Node.Title  := +Title;
               Node.Href   := +Admin_URL (Link);

               Admin_Bar.Add_Node (Node);
            end;
         end loop;
      end;
   end Wp_Admin_Bar_New_Content_Menu;

   --------------------------------
   -- Wp_Admin_Bar_Comments_Menu --
   --------------------------------

   procedure Wp_Admin_Bar_Comments_Menu
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use Php.Strings;
      use UStrings;
      use Class_Admin_Bar;
      use Inc_Capabilities;
      use Inc_Comments;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_L10n;

      Counts        : constant Comment_Counts := Wp_Count_Comments;
      Awaiting_Mod  : constant Natural := Counts.Moderated;
      Awaiting_Text : constant String  :=
         Sprintf (
                  -- translators: %s: Number of comments.
                  X_N ("%s Comment in moderation",
                       "%s Comments in moderation", Awaiting_Mod),
                  [1 => Number_Format_I18n (Float (Awaiting_Mod))]);
      Icon  : UString;
      Title : UString;
      Node  : Node_Args;
   begin
      if not Current_User_Can ("edit_posts") then
         return;
      end if;

      Icon  := +"<span class=""ab-icon"" aria-hidden=""true""></span>";
      Title := +"<span class=""ab-label awaiting-mod pending-count count-" &
                Helpers.Image (Awaiting_Mod) & """ aria-hidden=""true"">" &
                Number_Format_I18n (Float (Awaiting_Mod)) & "</span>";
      Title := Title &
               "<span class=""screen-reader-text comments-in-moderation-text"">" &
               Awaiting_Text & "</span>";

      Node.Id    := +"comments";
      Node.Title := Icon & Title;
      Node.Href  := +Admin_URL ("edit-comments.php");

      Admin_Bar.Add_Node (Node);
   end Wp_Admin_Bar_Comments_Menu;

   ----------------------------------
   -- Wp_Admin_Bar_Appearance_Menu --
   ----------------------------------

   procedure Wp_Admin_Bar_Appearance_Menu
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use UStrings;
      use Array_Lists;
      use Class_Admin_Bar;
      use Inc_Capabilities;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Themes;
   begin
      declare
         Node : Node_Args;
      begin
         Node.Parent := +"site-name";
         Node.Id     := +"appearance";

         Admin_Bar.Add_Group (Node);
      end;

      if Current_User_Can ("switch_themes") then
         declare
            Node : Node_Args;
         begin
            Node.Parent := +"appearance";
            Node.Id     := +"themes";
            Node.Title  := +abs "Themes";
            Node.Href   := +Admin_URL ("themes.php");

            Admin_Bar.Add_Node (Node);
         end;
      end if;

      if not Current_User_Can ("edit_theme_options") then
         return;
      end if;

      if Current_Theme_Supports ("widgets") then
         declare
            Node : Node_Args;
         begin
            Node.Parent := +"appearance";
            Node.Id     := +"widgets";
            Node.Title  := +abs "Widgets";
            Node.Href   := +Admin_URL ("widgets.php");

            Admin_Bar.Add_Node (Node);
         end;
      end if;

      if
        Current_Theme_Supports ("menus") or else
        Current_Theme_Supports ("widgets")
      then
         declare
            Node : Node_Args;
         begin
            Node.Parent := +"appearance";
            Node.Id     := +"menus";
            Node.Title  := +abs "Menus";
            Node.Href   := +Admin_URL ("nav-menus.php");

            Admin_Bar.Add_Node (Node);
         end;
      end if;

      if Current_Theme_Supports ("custom-background") then
         declare
            Node : Node_Args;
         begin
            Node.Parent := +"appearance";
            Node.Id     := +"background";
            Node.Title  := +abs "Background";
            Node.Href   := +Admin_URL ("themes.php?page=custom-background");
            Node.Meta   :=
               To_Array_Type ([Build ("class", "hide-if-customize")]);

            Admin_Bar.Add_Node (Node);
         end;
      end if;

      if Current_Theme_Supports ("custom-header") then
         declare
            Node : Node_Args;
         begin
            Node.Parent := +"appearance";
            Node.Id     := +"header";
            Node.Title  := +abs "Header";
            Node.Href   := +Admin_URL ("themes.php?page=custom-header");
            Node.Meta   :=
               To_Array_Type ([Build ("class", "hide-if-customize")]);

            Admin_Bar.Add_Node (Node);
         end;
      end if;
   end Wp_Admin_Bar_Appearance_Menu;

   -------------------------------
   -- Wp_Admin_Bar_Updates_Menu --
   -------------------------------

   procedure Wp_Admin_Bar_Updates_Menu
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use Php.Strings;
      use UStrings;
      use Class_Admin_Bar;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Updates;

      Update_Data  : constant Update_Counts := Wp_Get_Update_Data;
      Counts_Total : constant Integer       := Update_Data.Total;
      -- ("counts") ("total");
      Updates_Text : UString;
      Icon         : UString;
      Title        : UString;
   begin
      if Counts_Total = 0 then -- not update_data ("counts") ("total")
         return;
      end if;

      Updates_Text := +Sprintf (
                -- translators: %s: Total number of updates available.
                X_N ("%s update available", "%s updates available",
                     Counts_Total),
                [1 => Number_Format_I18n (Float (Counts_Total))]);

      Icon  := +"<span class=""ab-icon"" aria-hidden=""true""></span>";
      Title := +"<span class=""ab-label"" aria-hidden=""true"">" &
               Number_Format_I18n (Float (Counts_Total)) & "</span>";
      Title := Title &
               "<span class=""screen-reader-text updates-available-text"">" &
               Updates_Text & "</span>";

      declare
         Node : Node_Args;
      begin
         Node.Id    := +"updates";
         Node.Title := Icon & Title;
         Node.Href  := +Network_Admin_URL ("update-core.php");

         Admin_Bar.Add_Node (Node);
      end;
   end Wp_Admin_Bar_Updates_Menu;

   ------------------------------
   -- Wp_Admin_Bar_Search_Menu --
   ------------------------------

   procedure Wp_Admin_Bar_Search_Menu
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use Array_Lists;
      use UStrings;
      use Class_Admin_Bar;
      use Inc_Formatting;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;

      Form : UString;
   begin
      if Is_Admin then
         return;
      end if;

      Form := +"<form action=""" & ESC_URL (Home_URL ("/")) & """ method=""get"" id=""adminbarsearch"">";
      Form := Form & "<input class=""adminbar-input"" name=""s"" id=""adminbar-search"" type=""text"" value="""" maxlength=""150"" />";
      Form := Form & "<label for=""adminbar-search"" class=""screen-reader-text"">" & abs "Search" & "</label>";
      Form := Form & "<input type=""submit"" class=""adminbar-button"" value=""" & abs "Search" & """ />";
      Form := Form & "</form>";

      declare
         Node : Node_Args;
      begin
         Node.Parent := +"top-secondary";
         Node.Id     := +"search";
         Node.Title  := Form;
         Node.Meta   := To_Array_Type ([
                           Build ("class",    "admin-bar-search"),
                           Build ("tabindex", -1)]);

         Admin_Bar.Add_Node (Node);
      end;
   end Wp_Admin_Bar_Search_Menu;

   -------------------------------------
   -- Wp_Admin_Bar_Recovery_Mode_Menu --
   -------------------------------------

   procedure Wp_Admin_Bar_Recovery_Mode_Menu
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use UStrings;
      use Class_Admin_Bar;
      use Class_Recovery_Mode;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_Load;
      use Inc_L10n;
   begin
      if not Wp_Is_Recovery_Mode then
         return;
      end if;

      declare
         URL_3 : constant String := Wp_Login_URL;
         URL_2 : constant String := Add_Query_Arg ("action", EXIT_ACTION, URL_3);
         URL   : constant String := Wp_Nonce_URL (URL_2, EXIT_ACTION);

         Node : Node_Args;
      begin
         Node.Parent := +"top-secondary";
         Node.Id     := +"recovery-mode";
         Node.Title  := +abs "Exit Recovery Mode";
         Node.Href   := +URL;

         Admin_Bar.Add_Node (Node);
      end;
   end Wp_Admin_Bar_Recovery_Mode_Menu;

   ---------------------------------------
   -- Wp_Admin_Bar_Add_Secondary_Groups --
   ---------------------------------------

   procedure Wp_Admin_Bar_Add_Secondary_Groups
               (Admin_Bar : in out Class_Admin_Bar.Wp_Admin_Bar)
   is
      use Array_Lists;
      use UStrings;
      use Class_Admin_Bar;
   begin
      declare
         Node : Node_Args;
      begin
         Node.Id   := +"top-secondary";
         Node.Meta := To_Array_Type ([Build ("class", "ab-top-secondary")]);

         Admin_Bar.Add_Group (Node);
      end;

      declare
         Node : Node_Args;
      begin
         Node.Parent := +"wp-logo";
         Node.Id     := +"wp-logo-external";
         Node.Meta   := To_Array_Type ([Build ("class", "ab-sub-secondary")]);

         Admin_Bar.Add_Group (Node);
      end;
   end Wp_Admin_Bar_Add_Secondary_Groups;

   -------------------------
   -- Wp_Admin_Bar_Header --
   -------------------------

   procedure Wp_Admin_Bar_Header
   is
      use Php.Echoing;
      use Inc_Themes;

      Type_Attr : constant String :=
        (if Current_Theme_Supports ("html5", "style")
         then "" else " type=""text/css""");
   begin
      Echo ("<style" & Type_Attr &
            " media=""print"">#wpadminbar { display:none; }</style>");
   end Wp_Admin_Bar_Header;

   -------------------------
   -- X_Admin_Bar_Bump_Cb --
   -------------------------

   procedure X_Admin_Bar_Bump_Cb
   is
      use Php.Echoing;
      use UStrings;
      use Inc_Themes;

      Type_Attr : constant String :=
        (if Current_Theme_Supports ("html5", "style")
         then "" else " type=""text/css""");
   begin
      Echo ("<style" & Type_Attr & " media=""screen"">" & NL);
      Echo ("   html { margin-top: 32px !important; }" & NL);
      Echo ("   @media screen and (max-width: 782px) {" & NL);
      Echo ("       html { margin-top: 46px !important; }" & NL);
      Echo ("   }" & NL);
      Echo ("</style>" & NL);
   end X_Admin_Bar_Bump_Cb;

   --------------------
   -- Show_Admin_Bar --
   --------------------

   procedure Show_Admin_Bar (Show : Boolean)
   is
--    global show_admin_bar;
   begin
      X_Show_Admin_Bar := Show; -- (bool)
   end Show_Admin_Bar;

   --------------------------
   -- Is_Admin_Bar_Showing --
   --------------------------

   function Is_Admin_Bar_Showing
            return Boolean
   is
      use Constants;
      use UStrings;
      use Wp_Common;
      use Inc_Load;
      use Inc_Pluggables;

--    global show_admin_bar, pagenow;
   begin
      -- For all these types of requests, we never want an admin bar.
      if
        XMLRPC_REQUEST or else DOING_AJAX or else
        IFRAME_REQUEST or else Wp_Is_JSON_Request
      then
         return False;
      end if;

--        if Is_Embed then
--                return False;
--        end if;

      -- Integrated into the admin.
      if Is_Admin then
         return True;
      end if;

      if True then -- not Isset (X_Show_Admin_Bar) then
         if not Is_User_Logged_In or else "wp-login.php" = Pagenow then
            X_Show_Admin_Bar := False;
         else
            X_Show_Admin_Bar := X_Get_Admin_Bar_Pref;
         end if;
      end if;

      --
      -- Filters whether to show the admin bar.
      --
      -- Returning false to this hook is the recommended way to hide the admin bar.
      -- The user"s display preference is used for logged in users.
      --
      -- @since 3.1.0
      --
      -- @param bool show_admin_bar Whether the admin bar should be shown. Default false.
      --
      X_Show_Admin_Bar := Apply_Filters ("show_admin_bar", X_Show_Admin_Bar);

      return X_Show_Admin_Bar;
   end Is_Admin_Bar_Showing;

   --------------------------
   -- X_Get_Admin_Bar_Pref --
   --------------------------

   function X_Get_Admin_Bar_Pref (Context : String                   := "front";
                                  User    : Class_Users.User_Id_Type := 0)
                                  return Boolean
   is
      use Inc_Users;

      Pref : constant Boolean := Get_User_Option ("show_admin_bar_" & Context, User);
   begin
      if not Pref then -- False = Pref then
         return True;
      end if;

      return Pref;
   end X_Get_Admin_Bar_Pref;

end Inc_Admin_Bar;
