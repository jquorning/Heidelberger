--
-- WordPress Dashboard Widget Administration Screen API
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Containers.Vectors;

with Php.Arrays;
with Php.Echoing;
with Php.Errors;
with Php.JSON;
with Php.Misc;
with Php.Lists;
with Php.Strings;

with Array_Lists;
with Arrayable_Interfaces;
with Binder;
with Constants;
with Globals;
with Helpers;
with Helpers_2;
with Logging;
with UStrings;
with Wp_Common;

with Class_Admin_Bar;
with Class_Screens;
with Class_Posts;
with Class_Post_Type;
with Class_Querys;
with Class_Users;

with Adi_List_Tables;
with Adi_Misc;
with Adi_Screens;
with Adi_Posts;
with Adi_Templates;
with Adi_Update;

with Inc_Capabilities;
with Inc_Comments;
with Inc_Formatting;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_Functions_Wp_Styles;
with Inc_General_Templates;
with Inc_HTTP;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Ms_Functions;
with Inc_Options;
with Inc_Plugins;
with Inc_Pluggables;
with Inc_Posts;
with Inc_Post_Templates;
with Inc_Querys;
with Inc_Users;
with Inc_Vars;
with Inc_Versions;

package body Adi_Dashboard
is

   package Callable_Vectors is new
      Ada.Containers.Vectors (Index_Type   => Positive,
                              Element_Type => Callable);

   Wp_Registered_Widgets          : Array_Type;
   Wp_Registered_Widget_Controls  : Array_Type;
   Wp_Dashboard_Control_Callbacks : Callable_Vectors.Vector;

   function Wp_Dashboard_Browser_Nag is
     new Helpers_2.Generic_Call_Procedure (Wp_Dashboard_Browser_Nag);

   function Wp_Dashboard_PHP_Nag is
     new Helpers_2.Generic_Call_Procedure (Wp_Dashboard_PHP_Nag);

   function Wp_Dashboard_Site_Health is
     new Helpers_2.Generic_Call_Procedure (Wp_Dashboard_Site_Health);

   function Wp_Dashboard_Right_Now is
     new Helpers_2.Generic_Call_Procedure (Wp_Dashboard_Right_Now);

   function Wp_Network_Dashboard_Right_Now is
     new Helpers_2.Generic_Call_Procedure (Wp_Network_Dashboard_Right_Now);

   function Wp_Dashboard_Site_Activity is
     new Helpers_2.Generic_Call_Procedure (Wp_Dashboard_Site_Activity);

   function Dashboard_Browser_Nag_Class is
     new Helpers_2.Generic_Call_Procedure_2 (Dashboard_Browser_Nag_Class);

   function Dashboard_PHP_Nag_Class is
     new Helpers_2.Generic_Call_Procedure_2 (Dashboard_PHP_Nag_Class);

   function Wp_Dashboard_Events_News is
     new Helpers_2.Generic_Call_Procedure (Wp_Dashboard_Events_News);

   function Wp_Dashboard_Quick_Press is
     new Helpers_2.Generic_Call_Procedure_3 (Wp_Dashboard_Quick_Press);

   function X_Wp_Dashboard_Control_Callback
              (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Arrays.Array_Type;

   function X_Wp_Dashboard_Control_Callback
              (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Arrays.Array_Type
   is
   begin
      X_Wp_Dashboard_Control_Callback (Dashboard => From_Null,
                                       Meta_Box  => Empty_Array);
      return Empty_Array;
   end X_Wp_Dashboard_Control_Callback;

   function Array_Keys (Blogs : Class_Admin_Bar.Blog_List)
                        return List_Type;

   function Array_Keys (Blogs : Class_Admin_Bar.Blog_List)
                        return List_Type
   is
      Result : List_Type;
   begin
      for A in Blogs.First_Index .. Blogs.Last_Index loop
         Result.Append (Helpers.Image (A));
      end loop;
      return Result;
   end Array_Keys;

   ------------------------
   -- Wp_Dashboard_Setup --
   ------------------------

   procedure Wp_Dashboard_Setup
   is
      use Php.Echoing;
      use Php.Errors;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Class_Screens;
      use Adi_Misc;
      use Adi_Screens;
      use Inc_Capabilities;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_Functions_Wp_Styles;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Plugins;
      use Inc_Pluggables;
      use Inc_Posts;

--    global wp_registered_widgets;
--    global wp_registered_widget_controls;
--    global wp_dashboard_control_callbacks;

      Screen : constant Wp_Screen := Get_Current_Screen;

      Dashboard_Widgets : List_Type;
   begin
      -- Register Widgets and Controls
      Wp_Dashboard_Control_Callbacks := Callable_Vectors.Empty_Vector;

      -- Browser version
      declare
         Check_Browser : constant Array_Type := Wp_Check_Browser_Version;
      begin
         if
           Check_Browser /= Empty_Array and then
           As_Boolean (Get (Check_Browser, "upgrade"))
         then
            Add_Filter ("postbox_classes_dashboard_dashboard_browser_nag",
                        Dashboard_Browser_Nag_Class'Access);

            if As_Boolean (Get (Check_Browser, "insecure")) then
               Wp_Add_Dashboard_Widget ("dashboard_browser_nag",
                                        abs "You are using an insecure browser!",
                                        Wp_Dashboard_Browser_Nag'Access);
            else
               Wp_Add_Dashboard_Widget ("dashboard_browser_nag",
                                        abs "Your browser is out of date!",
                                        Wp_Dashboard_Browser_Nag'Access);
            end if;
         end if;
      end;

      -- PHP Version.
      declare
         Check_PHP : constant Array_Type := Wp_Check_PHP_Version;
      begin
         if
           Check_PHP /= Empty_Array and then
           Current_User_Can ("update_php")
         then
            -- If "not acceptable" the widget will be shown.
            if
              Isset (Check_PHP, "is_acceptable") and then
              not As_Boolean (Get (Check_PHP, "is_acceptable"))
            then
               Add_Filter ("postbox_classes_dashboard_dashboard_php_nag",
                           Dashboard_PHP_Nag_Class'Access);

               if As_Boolean (Get (Check_PHP, "is_lower_than_future_minimum")) then
                  Wp_Add_Dashboard_Widget ("dashboard_php_nag",
                                           abs "PHP Update Required",
                                           Wp_Dashboard_Php_Nag'Access);
               else
                  Wp_Add_Dashboard_Widget ("dashboard_php_nag",
                                           abs "PHP Update Recommended",
                                           Wp_Dashboard_Php_Nag'Access);
               end if;
            end if;
         end if;
      end;

      -- Site Health.
      if
        Current_User_Can ("view_site_health_checks") and then
        not Is_Network_Admin
      then
--       if not Class_Exists ("WP_Site_Health") then
--          require_once ABSPATH & "wp-admin/includes/class-wp-site-health.php";
--       end if;

--       WP_Site_Health::get_instance();

         Wp_Enqueue_Style  ("site-health");
         Wp_Enqueue_Script ("site-health");

         Wp_Add_Dashboard_Widget ("dashboard_site_health",
                                  abs "Site Health Status",
                                  Wp_Dashboard_Site_Health'Access);
      end if;

      -- Right Now.
      if Is_Blog_Admin and then Current_User_Can ("edit_posts") then
         Wp_Add_Dashboard_Widget ("dashboard_right_now",
                                  abs "At a Glance",
                                  Wp_Dashboard_Right_Now'Access);
      end if;

      if Is_Network_Admin then
         Wp_Add_Dashboard_Widget ("network_dashboard_right_now",
                                  abs "Right Now",
                                  Wp_Network_Dashboard_Right_Now'Access);
      end if;

      -- Activity Widget.
      if Is_Blog_Admin then
         Wp_Add_Dashboard_Widget ("dashboard_activity",
                                  abs "Activity",
                                  Wp_Dashboard_Site_Activity'Access);
      end if;

      -- QuickPress Widget.
      if
        Is_Blog_Admin and then
        Current_User_Can (Get_As_String (
          Get_Post_Type_Object ("post").Cap, "create_posts"))
      then
         declare
            Quick_Draft_Title : constant String :=
              Sprintf (
                "<span class=""hide-if-no-js"">%1s</span> <span class=""hide-if-js"">%2s</span>",
                [
                  1 => abs "Quick Draft",
                  2 => abs "Your Recent Drafts"
                ]);
         begin
            Wp_Add_Dashboard_Widget ("dashboard_quick_press",
                                     Quick_Draft_Title,
                                     Wp_Dashboard_Quick_Press'Access);
         end;
      end if;

      -- WordPress Events and News.
      Wp_Add_Dashboard_Widget ("dashboard_primary",
                               abs "WordPress Events and News",
                               Wp_Dashboard_Events_News'Access);

      if Is_Network_Admin then
         --
         -- Fires after core widgets for the Network Admin dashboard have been
         -- registered.
         --
         -- @since 3.1.0
         --
         Do_Action ("wp_network_dashboard_setup");

         --
         -- Filters the list of widgets to load for the Network Admin dashboard.
         --
         -- @since 3.1.0
         --
         -- @param string[] dashboard_widgets An array of dashboard widget IDs.
         --
         Dashboard_Widgets :=
           Apply_Filters ("wp_network_dashboard_widgets", Empty_List);

      elsif Is_User_Admin then
         --
         -- Fires after core widgets for the User Admin dashboard have been registered.
         --
         -- @since 3.1.0
         --
         Do_Action ("wp_user_dashboard_setup");

         --
         -- Filters the list of widgets to load for the User Admin dashboard.
         --
         -- @since 3.1.0
         --
         -- @param string[] dashboard_widgets An array of dashboard widget IDs.
         --
         Dashboard_Widgets :=
           Apply_Filters ("wp_user_dashboard_widgets", Empty_List);

      else
         --
         -- Fires after core widgets for the admin dashboard have been registered.
         --
         -- @since 2.5.0
         --
         Do_Action ("wp_dashboard_setup");

         --
         -- Filters the list of widgets to load for the admin dashboard.
         --
         -- @since 2.5.0
         --
         -- @param string[] dashboard_widgets An array of dashboard widget IDs.
         --
         Dashboard_Widgets :=
           Apply_Filters ("wp_dashboard_widgets", Empty_List);
      end if;

      for Widget_Id of Dashboard_Widgets loop
         declare
            Widget_All_Link : constant String :=
              As_String (Get (Ref_2 (Wp_Registered_Widgets, Widget_Id, "all_link")));

            Widget_Name : constant String :=
              As_String (Get (Ref_2 (Wp_Registered_Widgets, Widget_Id, "name")));

            Name : constant String :=
              (if Empty (Widget_All_Link) then Widget_Name
               else Widget_Name & " <a href=""" & Widget_All_Link &
                 """ class=""edit-box open-box"">" & abs "View all" & "</a>");
         begin
            Wp_Add_Dashboard_Widget
              (Widget_Id, Name,
               As_Callable (Get (Ref_2 (Wp_Registered_Widgets,
                                        Widget_Id, "callback"))),
               As_Callable (Get (Ref_2 (Wp_Registered_Widget_Controls,
                                        Widget_Id, "callback"))));
         end;
      end loop;

      if
        "POST" = Get_As_String (Binder.X_SERVER, "REQUEST_METHOD") and then
        Isset (Binder.X_POST, "widget_id")
      then
         Check_Admin_Referer ("edit-dashboard-widget_" &
                              Get_As_String (Binder.X_POST, "widget_id"),
                              "dashboard-widget-nonce");

         OB_Start; -- Hack - but the same hack wp-admin/widgets.php uses.
         Wp_Dashboard_Trigger_Widget_Control
           (Get_As_String (Binder.X_POST, "widget_id"));
         OB_End_Clean;
         Wp_Redirect (Remove_Query_Arg ("edit"));
         Die; -- exit;
      end if;

      -- This action is documented in wp-admin/includes/meta-boxes.php
      Do_Action ("do_meta_boxes", -Screen.Id, "normal", "");

      -- This action is documented in wp-admin/includes/meta-boxes.php
      Do_Action ("do_meta_boxes", -Screen.Id, "side", "");
   end Wp_Dashboard_Setup;

   -----------------------------
   -- Wp_Add_Dashboard_Widget --
   -----------------------------

   procedure Wp_Add_Dashboard_Widget
               (Widget_Id        : String;
                Widget_Name      : String;
                Callback         : Callable;
                Control_Callback : Callable   := null;
                Callback_Args    : Array_Type := Empty_Array; -- null;
                Context          : String     := "normal";
                Priority         : String     := "core")
   is
      use Php.Arrays;
      use Php.Lists;
      use Php.Strings;
      use Array_Lists;
      use Binder;
      use UStrings;
      use Class_Screens;
      use Adi_Screens;
      use Adi_Templates;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;

--    global wp_dashboard_control_callbacks;

      Screen : constant Wp_Screen := Get_Current_Screen;

      Callback_Args_2 : Array_Type := Callback_Args;

      Private_Callback_Args : constant Array_Type :=
        To_Array_Type ([Build ("__widget_basename", Widget_Name)]);

      Widget_Name_2 : UString := +Widget_Name;

      Callback_2 : Arrays.Callable := Callback;
   begin
      -- if ( is_null( callback_args ) ) then
      --    callback_args = private_callback_args;
      -- elsif
      -- if Is_Array (Callback_Args_2) then
      Array_Merge (Callback_Args_2, Private_Callback_Args);
      -- end if;

      if
        Control_Callback /= null and then
--      Is_Callable (Control_Callback) and then
        Current_User_Can ("edit_dashboard")
      then
         -- Set (Wp_Dashboard_Control_Callbacks, Widget_Id, -- XXX
         --      Control_Callback);

         if
           Isset (XX_GET, "edit") and then
           Widget_Id = Get_As_String (XX_GET, "edit")
         then
            declare
               List : constant List_Type :=
                 Explode ("#", Add_Query_Arg ("edit", "(false)"), 2);

               URL : constant String := List (1);
            begin
               Append (Widget_Name_2,
                       " <span class=""postbox-title-action""><a href=""" &
                       ESC_URL (URL) & """>" & abs "Cancel" & "</a></span>");
               Callback_2 := X_Wp_Dashboard_Control_Callback'Access;
            end;
         else
            declare
               List : constant List_Type :=
                 Explode ("#", Add_Query_Arg ("edit", Widget_Id), 2);

               URL : constant String := List (1);
            begin
               Append (Widget_Name_2,
                       " <span class=""postbox-title-action""><a href=""" &
                       ESC_URL (URL & "#" & Widget_Id) &
                       """ class=""edit-box open-box"">" & abs "Configure" &
                       "</a></span>");
            end;
         end if;
      end if;

      declare
         Side_Widgets : constant List_Type :=
           ["dashboard_quick_press", "dashboard_primary"];

         High_Priority_Widgets : constant List_Type :=
           ["dashboard_browser_nag", "dashboard_php_nag"];

         Context_2  : UString := +Context;
         Priority_2 : UString := +Priority;
         Callback_3 : constant Callable_2 := null; -- XXX
      begin
         if In_List (Widget_Id, Side_Widgets, True) then
            Context_2 := +"side";
         end if;

         if In_List (Widget_Id, High_Priority_Widgets, True) then
            Priority_2 := +"high";
         end if;

         if Empty (Context_2) then
            Context_2 := +"normal";
         end if;

         if Empty (Priority_2) then
            Priority_2 := +"core";
         end if;

         Add_Meta_Box (Widget_Id, -Widget_Name_2, Callback_3, Screen,
                       -Context_2, -Priority_2, Callback_Args);
      end;
   end Wp_Add_Dashboard_Widget;

   -------------------------------------
   -- X_Wp_Dashboard_Control_Callback --
   -------------------------------------

   procedure X_Wp_Dashboard_Control_Callback (Dashboard : Multi_Type;
                                              Meta_Box  : Array_Type)
   is
      use Php.Echoing;
      use Adi_Templates;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;
   begin
      Echo ("<form method=""post"" " &
            "class=""dashboard-widget-control-form wp-clearfix"">");
      Wp_Dashboard_Trigger_Widget_Control (Get_As_String (Meta_Box, "id"));
      Wp_Nonce_Field ("edit-dashboard-widget_" & Get_As_String (Meta_Box, "id"),
                      "dashboard-widget-nonce");
      Echo ("<input type=""hidden"" name=""widget_id"" value=""" &
            ESC_Attr (Get_As_String (Meta_Box, "id")) & """ />");
      Submit_Button (abs "Save Changes");
      Echo ("</form>");
   end X_Wp_Dashboard_Control_Callback;

   ------------------
   -- Wp_Dashboard --
   ------------------

   procedure Wp_Dashboard
   is
      use Php.Echoing;
      use UStrings;
      use Class_Screens;
      use Adi_Screens;
      use Adi_Templates;
      use Inc_Functions;

      Screen  : constant Wp_Screen := Get_Current_Screen;
      Columns : constant Natural   := abs Screen.Get_Columns;

      Columns_CSS : constant String :=
        (if Columns /= 0 then " columns-columns" else "");
   begin
      Echo ("<div id=""dashboard-widgets"" class=""metabox-holder" &
            Columns_CSS & ">");
      Echo ("    <div id=""postbox-container-1"" class=""postbox-container"">");
      Echo ("    ");  Do_Meta_Boxes (-Screen.Id, "normal", From_String (""));
      Echo ("    </div>");
      Echo ("    <div id=""postbox-container-2"" class=""postbox-container"">");
      Echo ("    ");  Do_Meta_Boxes (-Screen.Id, "side", From_String (""));
      Echo ("    </div>");
      Echo ("    <div id=""postbox-container-3"" class=""postbox-container"">");
      Echo ("    ");  Do_Meta_Boxes (-Screen.Id, "column3", From_String (""));
      Echo ("    </div>");
      Echo ("    <div id=""postbox-container-4"" class=""postbox-container"">");
      Echo ("    ");  Do_Meta_Boxes (-Screen.Id, "column4", From_String (""));
      Echo ("    </div>");
      Echo ("</div>");

      Wp_Nonce_Field ("closedpostboxes", "closedpostboxesnonce", False);
      Wp_Nonce_Field ("meta-box-order",  "meta-box-order-nonce", False);
   end Wp_Dashboard;

   ----------------------------
   -- Wp_Dashboard_Right_Now --
   ----------------------------

   procedure Wp_Dashboard_Right_Now
   is
      use Php.Echoing;
      use Php.Strings;
      use Wp_Common;
      use UStrings;
      use Class_Post_Type;
      use Adi_Update;
      use Inc_Capabilities;
      use Inc_Comments;
      use Inc_Functions;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Posts;
   begin
      Echo ("<div class=""main"">");
      Echo ("<ul>");

      -- Posts and Pages.
      for Post_Type of List_Type'["post", "page"] loop
         declare
            Num_Posts : constant Post_Counts_Type :=
              Wp_Count_Posts (Post_Type);
         begin
            if
              Num_Posts /= Null_Post_Counts and then
              Num_Posts.Publish /= 0
            then
               declare
                  Text_2 : constant String :=
                    (if "post" = Post_Type
                     -- translators: %s: Number of posts.
                     then X_N ("%s Post", "%s Posts", Num_Posts.Publish)
                     -- translators: %s: Number of pages.
                     else X_N ("%s Page", "%s Pages", Num_Posts.Publish));

                  Text : constant String :=
                    Sprintf (Text_2,
                             [1 => Number_Format_I18n (Float (Num_Posts.Publish))]);

                  Post_Type_Object : constant Wp_Post_Type :=
                    Get_Post_Type_Object (Post_Type);
               begin
                  if
                    Post_Type_Object /= Null_Post_Type and then
                    Current_User_Can (Get_As_String (
                      Post_Type_Object.Cap, "edit_posts"))
                  then
                     Printf ("<li class=""%1s-count""><a href=""edit.php?post_type=%1s"">%2s</a></li>",
                             [1 => Post_Type, 2 => Text]);
                  else
                     Printf ("<li class=""%1s-count""><span>%2s</span></li>",
                             [1 => Post_Type, 2 => Text]);
                  end if;
               end;
            end if;
         end;
      end loop;

      -- Comments.
      declare
         Num_Comm : constant Comment_Counts_Type := Wp_Count_Comments;
      begin
         if
           Num_Comm /= Null_Comment_Counts and then
           (Num_Comm.Approved /= 0 or Num_Comm.Moderated /= 0)
         then
            declare
               -- translators: %s: Number of comments.
               Text : constant String :=
                 Sprintf (X_N ("%s Comment", "%s Comments", Num_Comm.Approved),
                          [1 => Number_Format_I18n (Float (Num_Comm.Approved))]);
            begin
               Echo ("<li class=""comment-count"">");
               Echo ("    <a href=""edit-comments.php"">" & Text & "</a>");
               Echo ("</li>");
            end;

            declare
               Moderated_Comments_Count_I18n : constant String :=
                 Number_Format_I18n (Float (Num_Comm.Moderated));

               -- translators: %s: Number of comments.--
               Text : constant String :=
                 Sprintf (X_N ("%s Comment in moderation",
                               "%s Comments in moderation",
                               Num_Comm.Moderated),
                          [1 => Moderated_Comments_Count_I18n]);
            begin
               Echo ("<li class=""comment-mod-count" &
                     (if Num_Comm.Moderated = 0 then " hidden" else "") & ">");
               Echo ("    <a href=""edit-comments.php?comment_status=moderated"" " &
                     "class=""comments-in-moderation-text"">" & Text & "</a>");
               Echo ("</li>");
            end;
         end if;
      end;

      --
      -- Filters the array of extra elements to list in the "At a Glance"
      -- dashboard widget.
      --
      -- Prior to 3.8.0, the widget was named "Right Now". Each element
      -- is wrapped in list-item tags on output.
      --
      -- @since 3.8.0
      --
      -- @param string[] items Array of extra "At a Glance" widget items.
      --
      declare
         Elements : constant List_Type :=
           Apply_Filters ("dashboard_glance_items", Empty_List);
      begin
         if not Elements.Is_Empty then
            Echo ("<li>" & Implode ("</li>" & NL & "<li>", Elements) & "</li>" & NL);
         end if;
      end;

      Echo ("</ul>");

      Update_Right_Now_Message;

      -- Check if search engines are asked not to index this site.
      if
        not Is_Network_Admin and then
        not Is_User_Admin    and then
        Current_User_Can ("manage_options") and then
        not Get_Option ("blog_public")
      then
         --
         -- Filters the link title attribute for the "Search engines discouraged"
         -- message displayed in the "At a Glance" dashboard widget.
         --
         -- Prior to 3.8.0, the widget was named "Right Now".
         --
         -- @since 3.0.0
         -- @since 4.5.0 The default for `title` was updated to an empty string.
         --
         -- @param string title Default attribute text.
         --
         declare
            Title : constant String :=
              Apply_Filters ("privacy_on_link_title", "");

            --
            -- Filters the link label for the "Search engines discouraged" message
            -- displayed in the "At a Glance" dashboard widget.
            --
            -- Prior to 3.8.0, the widget was named "Right Now".
            --
            -- @since 3.0.0
            --
            -- @param string content Default text.
            --
            Content : constant String :=
              Apply_Filters ("privacy_on_link_text", abs "Search engines discouraged");

            Title_Attr : constant String :=
              (if "" = Title then "" else " title=""title""");
         begin
            Echo ("<p class=""search-engines-info""><a href=""options-reading.php""" &
                  Title_Attr & ">" & Content & "</a></p>");
         end;
      end if;

      Echo ("</div>");

      --
      -- activity_box_end has a core action, but only prints content when multisite.
      -- Using an output buffer is the only way to really check if anything's
      -- displayed here.
      --
      OB_Start;

      --
      -- Fires at the end of the "At a Glance" dashboard widget.
      --
      -- Prior to 3.8.0, the widget was named "Right Now".
      --
      -- @since 2.5.0
      --
      Do_Action ("rightnow_end");

      --
      -- Fires at the end of the "At a Glance" dashboard widget.
      --
      -- Prior to 3.8.0, the widget was named "Right Now".
      --
      -- @since 2.0.0
      --
      Do_Action ("activity_box_end");

      declare
         Actions : constant String := OB_Get_Clean;
      begin
         if not Empty (Actions) then
            Echo ("<div class=""sub"">");
            Echo (Actions);
            Echo ("</div>");
         end if;
      end;
   end Wp_Dashboard_Right_Now;

   ------------------------------------
   -- Wp_Network_Dashboard_Right_Now --
   ------------------------------------

   procedure Wp_Network_Dashboard_Right_Now
   is
      use Php.Echoing;
      use Php.Strings;
      use Wp_Common;
      use Array_Lists;
      use UStrings;
      use Adi_Templates;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Ms_Functions;
      use Inc_Users;

      Actions : Array_Type;
   begin
      if Current_User_Can ("create_sites") then
         Set (Actions, "create-site", From_String (
              "<a href=""" & Network_Admin_URL ("site-new.php") & """>" &
              abs "Create a New Site" & "</a>"));
      end if;

      if Current_User_Can ("create_users") then
         Set (Actions, "create-user", From_String (
              "<a href=""" & Network_Admin_URL ("user-new.php") & """>" &
              abs "Create a New User" & "</a>"));
      end if;

      declare
         C_Users : constant Natural := Get_User_Count;
         C_Blogs : constant Natural := Get_Blog_Count;

         User_Text : constant String :=
           -- translators: %s: Number of users on the network.
           Sprintf (X_N ("%s user", "%s users", C_Users),
                    [1 => Number_Format_I18n (Float (C_Users))]);

         Blog_Text : constant String :=
           -- translators: %s: Number of sites on the network.
           Sprintf (X_N ("%s site", "%s sites", C_Blogs),
                    [1 => Number_Format_I18n (Float (C_Blogs))]);

         -- translators: 1: Text indicating the number of sites on the network,
         -- translators: 2: Text indicating the number of users on the network.
         Sentence : constant String :=
           Sprintf (abs "You have %1s and %2s.",
                    [Blog_Text, User_Text]);
      begin
         if Actions /= Empty_Array then
            Echo ("<ul class=""subsubsub"">");
            for A in Actions.Iterate loop
               declare
                  Class  : constant String := Key (A);
                  Action : constant String := As_String (Element (A));
               begin
                  Set (Actions, Class, From_String (
                       TAB & "<li class=""" & Class & """>" & Action));
               end;
            end loop;
            Echo (Implode (" |</li>" & NL, Actions) & "</li>" & NL);
            Echo ("</ul>");
         end if;

         Echo ("<br class=""clear"" />");

         Echo ("<p class=""youhave"">" & Sentence & "</p>");
      end;

      --
      -- Fires in the Network Admin "Right Now" dashboard widget
      -- just before the user and site search form fields.
      --
      -- @since MU (3.0.0)
      --
      Do_Action ("wpmuadminresult");

      Echo ("<form action=""" & ESC_URL (Network_Admin_URL ("users.php")) &
            """ method=""get"">");
      Echo ("<p>");
      Echo ("    <label class=""screen-reader-text"" for=""search-users"">");
      X_E ("Search Users");
      Echo ("</label>");
      Echo ("    <input type=""search"" name=""s"" value="""" size=""30"" " &
            "autocomplete=""off"" id=""search-users"" />");
      Submit_Button (abs "Search Users", "", "(false)", False,
                     To_Array_Type ([Build ("id", "submit_users")]));
      Echo ("</p>");
      Echo ("</form>");

      Echo ("<form action=""" & ESC_URL (Network_Admin_URL ("sites.php")) &
            """ method=""get"">");
      Echo ("<p>");
      Echo ("    <label class=""screen-reader-text"" for=""search-sites"">");
      X_E ("Search Sites");
      Echo ("</label>");
      Echo ("    <input type=""search"" name=""s"" value="""" size=""30"" " &
            "autocomplete=""off"" id=""search-sites"" />");
      Submit_Button (abs "Search Sites", "", "(false)", False,
                     To_Array_Type ([Build ("id", "submit_sites")]));
      Echo ("</p>");
      Echo ("</form>");

      --
      -- Fires at the end of the "Right Now" widget in the Network Admin dashboard.
      --
      -- @since MU (3.0.0)
      --
      Do_Action ("mu_rightnow_end");

      --
      -- Fires at the end of the "Right Now" widget in the Network Admin dashboard.
      --
      -- @since MU (3.0.0)
      --
      Do_Action ("mu_activity_box_end");
   end Wp_Network_Dashboard_Right_Now;

   ------------------------------
   -- Wp_Dashboard_Quick_Press --
   ------------------------------

   procedure Wp_Dashboard_Quick_Press (Error_Msg : String := "")
   is
      use Php.Echoing;
      use Php.Lists;
      use Array_Lists;
      use Wp_Common;
      use UStrings;
      use Class_Posts;
      use Class_Users;
      use Adi_Posts;
      use Adi_Templates;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Posts;
      use Inc_Users;
--    global post_ID;

      Post : Wp_Post;
   begin
      if not Current_User_Can ("edit_posts") then
         return;
      end if;

      -- Check if a new auto-draft (= no new post_ID) is needed or if the old can
      -- be used.
      declare
         Last_Post_Id : constant Integer :=
           Get_User_Option ("dashboard_quick_press_last_post_id");
         -- Get the last post_ID.
      begin
         if Last_Post_Id /= 0 then
            Post := Get_Post (Post_Id_Type (Last_Post_Id));
            if
              Post = Null_Post or else
--            Empty (Post) or else
              "auto-draft" /= Post.Post_Status  -- auto-draft doesn't exist anymore.
            then
               Post := Get_Default_Post_To_Edit ("post", True);

               Update_User_Option (Get_Current_User_Id,
                                   "dashboard_quick_press_last_post_id",
                                   From_Integer (Integer (Post.Id)));
                                   -- (int) -- Save post_ID.
            else
               Post.Post_Title := +""; -- Remove the auto draft title.
            end if;

         else
            Post := Get_Default_Post_To_Edit ("post", True);
            declare
               User_Id : constant User_Id_Type := Get_Current_User_Id;
            begin
               -- Don't create an option if this is a super admin who does not
               -- belong to this site.
               if
                 In_List (Helpers.Image (Get_Current_Blog_Id),
                          Array_Keys (Get_Blogs_Of_User (User_Id)), True)
               then
                  Update_User_Option (User_Id, "dashboard_quick_press_last_post_id",
                                      From_Integer (Integer (Post.Id)));
                                      -- (int) -- Save post_ID.
               end if;
            end;
         end if;
      end;

      Globals.Global_Post_Id := Post.Id; -- (int)

      Echo ("<form name=""post"" action=""" & ESC_URL (Admin_URL ("post.php")) &
            """ method=""post"" id=""quick-press"" " &
            "class=""initial-form hide-if-no-js"">");

      if Error_Msg /= "" then
         Echo ("<div class=""error"">" & Error_Msg & "</div>");
      end if;

      Echo ("<div class=""input-text-wrap"" id=""title-wrap"">");
      Echo ("    <label for=""title"">");

      -- This filter is documented in wp-admin/edit-form-advanced.php
      Echo (Apply_Filters ("enter_title_here", abs "Title", Post));

      Echo ("    </label>");
      Echo ("    <input type=""text"" name=""post_title"" " &
            "id=""title"" autocomplete=""off"" />");
      Echo ("</div>");

      Echo ("<div class=""textarea-wrap"" id=""description-wrap"">");
      Echo ("    <label for=""content"">");
      X_E ("Content");
      Echo ("</label>");
      Echo ("    <textarea name=""content"" id=""content"" placeholder=""");
      ESC_Attr_E ("What&#8217;s on your mind?");
      Echo (""" class=""mceEditor"" rows=""3"" cols=""15"" autocomplete=""off"">" &
            "</textarea>");
      Echo ("</div>");

      Echo ("<p class=""submit"">");
      Echo ("   <input type=""hidden"" name=""action"" id=""quickpost-action"" " &
            "value=""post-quickdraft-save"" />");
      Echo ("   <input type=""hidden"" name=""Post_ID"" value=""" &
            Image (Globals.Global_Post_Id) & """ />");
      Echo ("   <input type=""hidden"" name=""post_type"" value=""post"" />");
      Wp_Nonce_Field ("add-post");
      Submit_Button (abs "Save Draft", "primary", "save", False,
                     To_Array_Type ([Build ("id", "save-post")]));
      Echo ("   <br class=""clear"" />");
      Echo ("</p>");

      Echo ("</form>");

      Wp_Dashboard_Recent_Drafts;
   end Wp_Dashboard_Quick_Press;

-- --
-- -- Show recent drafts of the user on the dashboard.
-- --
-- -- @since 2.7.0
-- --
-- -- @param WP_Post[]|false drafts Optional. Array of posts to display. Default false.
-- --
-- function wp_dashboard_recent_drafts( drafts = false ) then
--         if ( ! drafts ) then
--                 query_args = array(
--                         "post_type"      => "post",
--                         "post_status"    => "draft",
--                         "author"         => get_current_user_id(),
--                         "posts_per_page" => 4,
--                         "orderby"        => "modified",
--                         "order"          => "DESC",
--                 );

--                 --
--                 -- Filters the post query arguments for the "Recent Drafts" dashboard widget.
--                 --
--                 -- @since 4.4.0
--                 --
--                 -- @param array query_args The query arguments for the "Recent Drafts" dashboard widget.
--                 --
--                 query_args = apply_filters( "dashboard_recent_drafts_query_args", query_args );

--                 drafts = get_posts( query_args );
--                 if ( ! drafts ) then
--                         return;
--                 end;
--         end;

--         echo "<div class="drafts">";

--         if ( count( drafts ) > 3 ) then
--                 printf(
--                         "<p class="view-all"><a href="%s">%s</a></p>" . "\n",
--                         esc_url( admin_url( "edit.php?post_status=draft" ) ),
--                         __( "View all drafts" )
--                 );
--         end;

--         echo "<h2 class="hide-if-no-js">" . __( "Your Recent Drafts" ) . "</h2>\n";
--         echo "<ul>";

--         -- translators: Maximum number of words used in a preview of a draft on the dashboard.--
--         draft_length = (int) _x( "10", "draft_length" );

--         drafts = array_slice( drafts, 0, 3 );
--         foreach ( drafts as draft ) then
--                 url   = get_edit_post_link( draft->ID );
--                 title = _draft_or_post_title( draft->ID );

--                 echo "<li>\n";
--                 printf(
--                         "<div class="draft-title"><a href="%s" aria-label="%s">%s</a><time datetime="%s">%s</time></div>",
--                         esc_url( url ),
--                         -- translators: %s: Post title.--
--                         esc_attr( sprintf( __( "Edit &#8220;%s&#8221;" ), title ) ),
--                         esc_html( title ),
--                         get_the_time( "c", draft ),
--                         get_the_time( __( "F j, Y" ), draft )
--                 );

--                 the_content = wp_trim_words( draft->post_content, draft_length );

--                 if ( the_content ) then
--                         echo "<p>" . the_content . "</p>";
--                 end;
--                 echo "</li>\n";
--         end;

--         echo "</ul>\n";
--         echo "</div>";
-- end;

-- --
-- -- Outputs a row for the Recent Comments widget.
-- --
-- -- @access private
-- -- @since 2.7.0
-- --
-- -- @global WP_Comment comment Global comment object.
-- --
-- -- @param WP_Comment comment   The current comment.
-- -- @param bool       show_date Optional. Whether to display the date.
-- --
-- function _wp_dashboard_recent_comments_row( &comment, show_date = true ) then
   procedure X_Wp_Dashboard_Recent_Comments_Row
               (Comment   : in out Class_Comments.Wp_Comment;
                Show_Date : Boolean := True)
   is
   begin
      Logging.Log ("x_wp_dashboard_recent_comments_row", "not implemented");
   end X_Wp_Dashboard_Recent_Comments_Row;

--         GLOBALS["comment"] = clone comment;

--         if ( comment->comment_post_ID > 0 ) then
--                 comment_post_title = _draft_or_post_title( comment->comment_post_ID );
--                 comment_post_url   = get_the_permalink( comment->comment_post_ID );
--                 comment_post_link  = "<a href="" . esc_url( comment_post_url ) . "">" . comment_post_title . "</a>";
--         end; else then
--                 comment_post_link = "";
--         end;

--         actions_string = "";
--         if ( current_user_can( "edit_comment", comment->comment_ID ) ) then
--                 -- Pre-order it: Approve | Reply | Edit | Spam | Trash.
--                 actions = array(
--                         "approve"   => "",
--                         "unapprove" => "",
--                         "reply"     => "",
--                         "edit"      => "",
--                         "spam"      => "",
--                         "trash"     => "",
--                         "delete"    => "",
--                         "view"      => "",
--                 );

--                 del_nonce     = esc_html( "_wpnonce=" . wp_create_nonce( "delete-comment_comment->comment_ID" ) );
--                 approve_nonce = esc_html( "_wpnonce=" . wp_create_nonce( "approve-comment_comment->comment_ID" ) );

--                 approve_url   = esc_url( "comment.php?action=approvecomment&p=comment->comment_post_ID&c=comment->comment_ID&approve_nonce" );
--                 unapprove_url = esc_url( "comment.php?action=unapprovecomment&p=comment->comment_post_ID&c=comment->comment_ID&approve_nonce" );
--                 spam_url      = esc_url( "comment.php?action=spamcomment&p=comment->comment_post_ID&c=comment->comment_ID&del_nonce" );
--                 trash_url     = esc_url( "comment.php?action=trashcomment&p=comment->comment_post_ID&c=comment->comment_ID&del_nonce" );
--                 delete_url    = esc_url( "comment.php?action=deletecomment&p=comment->comment_post_ID&c=comment->comment_ID&del_nonce" );

--                 actions["approve"] = sprintf(
--                         "<a href="%s" data-wp-lists="%s" class="vim-a aria-button-if-js" aria-label="%s">%s</a>",
--                         approve_url,
--                         "dim:the-comment-list:comment-thencomment->comment_IDend;:unapproved:e7e7d3:e7e7d3:new=approved",
--                         esc_attr__( "Approve this comment" ),
--                         __( "Approve" )
--                 );

--                 actions["unapprove"] = sprintf(
--                         "<a href="%s" data-wp-lists="%s" class="vim-u aria-button-if-js" aria-label="%s">%s</a>",
--                         unapprove_url,
--                         "dim:the-comment-list:comment-thencomment->comment_IDend;:unapproved:e7e7d3:e7e7d3:new=unapproved",
--                         esc_attr__( "Unapprove this comment" ),
--                         __( "Unapprove" )
--                 );

--                 actions["edit"] = sprintf(
--                         "<a href="%s" aria-label="%s">%s</a>",
--                         "comment.php?action=editcomment&amp;c=thencomment->comment_IDend;",
--                         esc_attr__( "Edit this comment" ),
--                         __( "Edit" )
--                 );

--                 actions["reply"] = sprintf(
--                         "<button type="button" onclick="window.commentReply && commentReply.open(\"%s\",\"%s\");" class="vim-r button-link hide-if-no-js" aria-label="%s">%s</button>",
--                         comment->comment_ID,
--                         comment->comment_post_ID,
--                         esc_attr__( "Reply to this comment" ),
--                         __( "Reply" )
--                 );

--                 actions["spam"] = sprintf(
--                         "<a href="%s" data-wp-lists="%s" class="vim-s vim-destructive aria-button-if-js" aria-label="%s">%s</a>",
--                         spam_url,
--                         "delete:the-comment-list:comment-thencomment->comment_IDend;::spam=1",
--                         esc_attr__( "Mark this comment as spam" ),
--                         -- translators: "Mark as spam" link.--
--                         _x( "Spam", "verb" )
--                 );

--                 if ( ! EMPTY_TRASH_DAYS ) then
--                         actions["delete"] = sprintf(
--                                 "<a href="%s" data-wp-lists="%s" class="delete vim-d vim-destructive aria-button-if-js" aria-label="%s">%s</a>",
--                                 delete_url,
--                                 "delete:the-comment-list:comment-thencomment->comment_IDend;::trash=1",
--                                 esc_attr__( "Delete this comment permanently" ),
--                                 __( "Delete Permanently" )
--                         );
--                 end; else then
--                         actions["trash"] = sprintf(
--                                 "<a href="%s" data-wp-lists="%s" class="delete vim-d vim-destructive aria-button-if-js" aria-label="%s">%s</a>",
--                                 trash_url,
--                                 "delete:the-comment-list:comment-thencomment->comment_IDend;::trash=1",
--                                 esc_attr__( "Move this comment to the Trash" ),
--                                 _x( "Trash", "verb" )
--                         );
--                 end;

--                 actions["view"] = sprintf(
--                         "<a class="comment-link" href="%s" aria-label="%s">%s</a>",
--                         esc_url( get_comment_link( comment ) ),
--                         esc_attr__( "View this comment" ),
--                         __( "View" )
--                 );

--                 --
--                 -- Filters the action links displayed for each comment in the "Recent Comments"
--                 -- dashboard widget.
--                 --
--                 -- @since 2.6.0
--                 --
--                 -- @param string[]   actions An array of comment actions. Default actions include:
--                 --                            "Approve", "Unapprove", "Edit", "Reply", "Spam",
--                 --                            "Delete", and "Trash".
--                 -- @param WP_Comment comment The comment object.
--                 --
--                 actions = apply_filters( "comment_row_actions", array_filter( actions ), comment );

--                 i = 0;

--                 foreach ( actions as action => link ) then
--                         ++i;

--                         if ( ( ( "approve" === action || "unapprove" === action ) && 2 === i )
--                                 || 1 === i
--                         ) then
--                                 separator = "";
--                         end; else then
--                                 separator = " | ";
--                         end;

--                         -- Reply and quickedit need a hide-if-no-js span.
--                         if ( "reply" === action || "quickedit" === action ) then
--                                 action .= " hide-if-no-js";
--                         end;

--                         if ( "view" === action && "1" !== comment->comment_approved ) then
--                                 action .= " hidden";
--                         end;

--                         actions_string .= "<span class="action">thenseparatorend;thenlinkend;</span>";
--                 end;
--         end;
--         ?>

--                 <li id="comment-<?php echo comment->comment_ID; ?>" <?php comment_class( array( "comment-item", wp_get_comment_status( comment ) ), comment ); ?>>

--                         <?php
--                         comment_row_class = "";

--                         if ( get_option( "show_avatars" ) ) then
--                                 echo get_avatar( comment, 50, "mystery" );
--                                 comment_row_class .= " has-avatar";
--                         end;
--                         ?>

--                         <?php if ( ! comment->comment_type || "comment" === comment->comment_type ) : ?>

--                         <div class="dashboard-comment-wrap has-row-actions <?php echo comment_row_class; ?>">
--                         <p class="comment-meta">
--                                 <?php
--                                 -- Comments might not have a post they relate to, e.g. programmatically created ones.
--                                 if ( comment_post_link ) then
--                                         printf(
--                                                 -- translators: 1: Comment author, 2: Post link, 3: Notification if the comment is pending.--
--                                                 __( "From %1s on %2s %3s" ),
--                                                 "<cite class="comment-author">" . get_comment_author_link( comment ) . "</cite>",
--                                                 comment_post_link,
--                                                 "<span class="approve">" . __( "[Pending]" ) . "</span>"
--                                         );
--                                 end; else then
--                                         printf(
--                                                 -- translators: 1: Comment author, 2: Notification if the comment is pending.--
--                                                 __( "From %1s %2s" ),
--                                                 "<cite class="comment-author">" . get_comment_author_link( comment ) . "</cite>",
--                                                 "<span class="approve">" . __( "[Pending]" ) . "</span>"
--                                         );
--                                 end;
--                                 ?>
--                         </p>

--                                 <?php
--                         else :
--                                 switch ( comment->comment_type ) then
--                                         case "pingback":
--                                                 type = __( "Pingback" );
--                                                 break;
--                                         case "trackback":
--                                                 type = __( "Trackback" );
--                                                 break;
--                                         default:
--                                                 type = ucwords( comment->comment_type );
--                                 end;
--                                 type = esc_html( type );
--                                 ?>
--                         <div class="dashboard-comment-wrap has-row-actions">
--                         <p class="comment-meta">
--                                 <?php
--                                 -- Pingbacks, Trackbacks or custom comment types might not have a post they relate to, e.g. programmatically created ones.
--                                 if ( comment_post_link ) then
--                                         printf(
--                                                 -- translators: 1: Type of comment, 2: Post link, 3: Notification if the comment is pending.--
--                                                 _x( "%1s on %2s %3s", "dashboard" ),
--                                                 "<strong>type</strong>",
--                                                 comment_post_link,
--                                                 "<span class="approve">" . __( "[Pending]" ) . "</span>"
--                                         );
--                                 end; else then
--                                         printf(
--                                                 -- translators: 1: Type of comment, 2: Notification if the comment is pending.--
--                                                 _x( "%1s %2s", "dashboard" ),
--                                                 "<strong>type</strong>",
--                                                 "<span class="approve">" . __( "[Pending]" ) . "</span>"
--                                         );
--                                 end;
--                                 ?>
--                         </p>
--                         <p class="comment-author"><?php comment_author_link( comment ); ?></p>

--                         <?php endif; -- comment_type ?>
--                         <blockquote><p><?php comment_excerpt( comment ); ?></p></blockquote>
--                         <?php if ( actions_string ) : ?>
--                         <p class="row-actions"><?php echo actions_string; ?></p>
--                         <?php endif; ?>
--                         </div>
--                 </li>
--         <?php
--         GLOBALS["comment"] = null;
-- end;

   --------------------------------
   -- Wp_Dashboard_Site_Activity --
   --------------------------------

   procedure Wp_Dashboard_Site_Activity
   is
      use Php.Echoing;
      use Array_Lists;
      use Inc_L10n;
   begin
      Echo ("<div id=""activity-widget"">");

      declare
         Future_Posts : constant Boolean := Wp_Dashboard_Recent_Posts (
           To_Array_Type ([
             Build ("max",    5),
             Build ("status", "future"),
             Build ("order",  "ASC"),
             Build ("title",  abs "Publishing Soon"),
             Build ("id",     "future-posts")
           ])
         );

         Recent_Posts : constant Boolean := Wp_Dashboard_Recent_Posts (
           To_Array_Type ([
             Build ("max",    5),
             Build ("status", "publish"),
             Build ("order",  "DESC"),
             Build ("title",  abs "Recently Published"),
             Build ("id",     "published-posts")
           ])
         );

         Recent_Comments : constant Boolean := Wp_Dashboard_Recent_Comments;
      begin
         if not Future_Posts and not Recent_Posts and not Recent_Comments then
            Echo ("<div class=""no-activity"">");
            Echo ("<p>" & abs "No activity yet!" & "</p>");
            Echo ("</div>");
         end if;

         Echo ("</div>");
      end;
   end Wp_Dashboard_Site_Activity;

   -------------------------------
   -- Wp_Dashboard_Recent_Posts --
   -------------------------------

   function Wp_Dashboard_Recent_Posts (Args : Array_Type)
                                       return Boolean
   is
      use Php.Echoing;
      use Php.Misc;
      use Php.Strings;
      use Array_Lists;
      use Wp_Common;
      use Class_Querys;
      use Adi_Templates;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Post_Templates;
      use Inc_Querys;

      Query_Args_2 : constant Array_Type := To_Array_Type ([
        Build ("post_type",      "post"),
        Build ("post_status",    Get_As_String (Args, "status")),
        Build ("orderby",        "date"),
        Build ("order",          Get_As_String (Args, "order")),
        Build ("posts_per_page", As_Integer (Get (Args, "max"))),
        Build ("no_found_rows",  True),
        Build ("cache_results",  False),
        Build ("perm",
               (if "future" = Get_As_String (Args, "status")
                then "editable" else "readable"))
      ]);

      --
      -- Filters the query arguments used for the Recent Posts widget.
      --
      -- @since 4.2.0
      --
      -- @param array query_args The arguments passed to WP_Query to produce the
      --                         list of posts.
      --
      Query_Args : constant Array_Type :=
        Apply_Filters ("dashboard_recent_posts_query_args", Query_Args_2);

      Posts : Wp_Query := X_Construct (Query_Args);
   begin
      if Posts.Have_Posts then

         Echo ("<div id=""" & Get_As_String (Args, "id") &
               """ class=""activity-block"">");

         Echo ("<h3>" & Get_As_String (Args, "title") & "</h3>");

         Echo ("<ul>");

         declare
            Today : constant String := Current_Time ("Y-m-d");

            Tomorrow : constant String :=
              Current_Datetime.Modify ("+1 day").Format ("Y-m-d");

            Year : constant String := Current_Time ("Y");
         begin
            while Posts.Have_Posts loop
               Posts.The_Post;
               declare
                  Time : constant Integer := Get_The_Time ("U");

                  Relative : constant String :=
                    (if GMdate ("Y-m-d", Time) = Today then abs "Today"
                     elsif GMdate ("Y-m-d", Time) = Tomorrow then abs "Tomorrow"
                     elsif GMdate ("Y", Time) /= Year
                     -- translators: Date and time format for recent posts on the
                     -- translators: dashboard, from a different calendar year, see
                     -- translators: https://www.php.net/manual/datetime.format.php
                     then Date_I18n (abs "M jS Y", Time)
                     -- translators: Date and time format for recent posts on the
                     -- translators: dashboard, see
                     -- translators: https://www.php.net/manual/datetime.format.php
                     else Date_I18n (abs "M jS", Time));

                  -- Use the post edit link for those who can edit, the permalink
                  -- otherwise.
                  Recent_Post_Link : constant String :=
                    (if Current_User_Can ("edit_post", Integer (Get_The_Id))
                     then Get_Edit_Post_Link else Get_Permalink);

                  Draft_Or_Post_Title : constant String := X_Draft_Or_Post_Title;
               begin
                  Printf (
                    "<li><span>%1s</span> <a href=""%2s"" aria-label=""%3s"">%4s</a></li>",
                    [
                      -- translators: 1: Relative date, 2: Time.
                      1 => Sprintf (X_X ("%1s, %2s", "dashboard"),
                                    [Relative, Get_The_Time]),
                      2 => Recent_Post_Link,
                      -- translators: %s: Post title.
                      3 => ESC_Attr (Sprintf (abs "Edit &#8220;%s&#8221;",
                                     [1 => Draft_Or_Post_Title])),
                      4 => Draft_Or_Post_Title
                    ]
                  );
               end;
            end loop;
         end;

         Echo ("</ul>");
         Echo ("</div>");
      else
         return False;
      end if;

      Wp_Reset_Postdata;

      return True;
   end Wp_Dashboard_Recent_Posts;

   ----------------------------------
   -- Wp_Dashboard_Recent_Comments --
   ----------------------------------

   function Wp_Dashboard_Recent_Comments (Total_Items : Natural := 5)
                                          return Boolean
   is
      use Php.Echoing;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Class_Comments;
      use Class_Comments.Comments_Vectors;
      use Class_Posts;
      use Adi_List_Tables;
      use Adi_Templates;
      use Inc_Capabilities;
      use Inc_Comments;
      use Inc_L10n;
      use Inc_Posts;

      -- Select all comment types and filter out spam later for better query
      -- performance.
      Comments : Comments_List; -- List_Type; -- Array_Type;

      Comments_Query : Array_Type := To_Array_Type ([
        Build ("number", Total_Items * 5),
        Build ("offset", 0)
      ]);

      Possible : Comments_List; -- Integer_Array;
   begin
      if not Current_User_Can ("edit_posts") then
         Set (Comments_Query, "status", From_String ("approve"));
      end if;

      Possible := Get_Comments (Comments_Query);

      Outer :
      while
        Natural (Comments.Length) < Total_Items and then
        not Possible.Is_Empty
      loop
         -- if not Is_Array (Possible) then
         --    exit Outer;
         -- end if;

         for Comment of Possible loop
            if
              not Current_User_Can ("read_post",
                                    Integer (Comment.Comment_Post_Id))
            then
               goto Continue;
            end if;

            Comments.Append (Comment);

            if Natural (Comments.Length) = Total_Items then
               exit Outer; -- break 2;
            end if;
            << Continue >>
         end loop;

         Set (Comments_Query, "offset", From_Integer (
              As_Integer (Get (Comments_Query, "offset")) +
              As_Integer (Get (Comments_Query, "number"))));

         Set (Comments_Query, "number", From_Integer (Total_Items * 10));
      end loop Outer;

      if not Comments.Is_Empty then
         Echo ("<div id=""latest-comments"" " &
               "class=""activity-block table-view-list"">");
         Echo ("<h3>" & abs "Recent Comments" & "</h3>");

         Echo ("<ul id=""the-comment-list"" data-wp-lists=""list:comment"">");
         for Comment of Comments loop
            declare
               Comment_Post : constant Wp_Post :=
                 Get_Post (Comment.Comment_Post_Id);
            begin
               if
                 Current_User_Can ("edit_post", Integer (Comment.Comment_Post_Id)) or else
                 (Empty (-Comment_Post.Post_Password) and then
                  Current_User_Can ("read_post", Integer (Comment.Comment_Post_Id)))
               then
                  X_Wp_Dashboard_Recent_Comments_Row (Comment);
               end if;
            end;
         end loop;
         Echo ("</ul>");

         if Current_User_Can ("edit_posts") then
            Echo ("<h3 class=""screen-reader-text"">" &
                  abs "View more comments" & "</h3>");
            X_Get_List_Table ("WP_Comments_List_Table").Views;
         end if;

         Wp_Comment_Reply (-1, False, "dashboard", False);
         Wp_Comment_Trashnotice;

         Echo ("</div>");
      else
         return False;
      end if;
      return True;
   end Wp_Dashboard_Recent_Comments;

-- --
-- -- Display generic dashboard RSS widget feed.
-- --
-- -- @since 2.5.0
-- --
-- -- @param string widget_id
-- --
-- function wp_dashboard_rss_output( widget_id ) then
--         widgets = get_option( "dashboard_widget_options" );
--         echo "<div class="rss-widget">";
--         wp_widget_rss_output( widgets[ widget_id ] );
--         echo "</div>";
-- end;

-- --
-- -- Checks to see if all of the feed url in check_urls are cached.
-- --
-- -- If check_urls is empty, look for the rss feed url found in the dashboard
-- -- widget options of widget_id. If cached, call callback, a function that
-- -- echoes out output for this widget. If not cache, echo a "Loading..." stub
-- -- which is later replaced by Ajax call (see top of /wp-admin/index.php)
-- --
-- -- @since 2.5.0
-- -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
-- --              by adding it to the function signature.
-- --
-- -- @param string   widget_id  The widget ID.
-- -- @param callable callback   The callback function used to display each feed.
-- -- @param array    check_urls RSS feeds.
-- -- @param mixed    ...args    Optional additional parameters to pass to the callback function.
-- -- @return bool True on success, false on failure.
-- --
-- function wp_dashboard_cached_rss_widget( widget_id, callback, check_urls = array(), ...args ) then
--         loading    = "<p class="widget-loading hide-if-no-js">" . __( "Loading&hellip;" ) . "</p><div class="hide-if-js notice notice-error inline"><p>" . __( "This widget requires JavaScript." ) . "</p></div>";
--         doing_ajax = wp_doing_ajax();

--         if ( empty( check_urls ) ) then
--                 widgets = get_option( "dashboard_widget_options" );

--                 if ( empty( widgets[ widget_id ]["url"] ) && ! doing_ajax ) then
--                         echo loading;
--                         return false;
--                 end;

--                 check_urls = array( widgets[ widget_id ]["url"] );
--         end;

--         locale    = get_user_locale();
--         cache_key = "dash_v2_" . md5( widget_id . "_" . locale );
--         output    = get_transient( cache_key );

--         if ( false !== output ) then
--                 echo output;
--                 return true;
--         end;

--         if ( ! doing_ajax ) then
--                 echo loading;
--                 return false;
--         end;

--         if ( callback && is_callable( callback ) ) then
--                 array_unshift( args, widget_id, check_urls );
--                 ob_start();
--                 call_user_func_array( callback, args );
--                 -- Default lifetime in cache of 12 hours (same as the feeds).
--                 set_transient( cache_key, ob_get_flush(), 12-- HOUR_IN_SECONDS );
--         end;

--         return true;
-- end;

-- --
-- -- Dashboard Widgets Controls.
-- --

   -----------------------------------------
   -- Wp_Dashboard_Trigger_Widget_Control --
   -----------------------------------------

   procedure Wp_Dashboard_Trigger_Widget_Control
               (Widget_Control_Id : String := "")  -- Integer := 0); -- false
   is
--    global wp_dashboard_control_callbacks;
   begin
      Logging.Log ("wp_dashboard_control_callbacks", "not implemented");
   end Wp_Dashboard_Trigger_Widget_Control;

   --      if ( is_scalar( widget_control_id ) && widget_control_id
   --              && isset( wp_dashboard_control_callbacks[ widget_control_id ] )
   --              && is_callable( wp_dashboard_control_callbacks[ widget_control_id ] )
   --      ) then
   --              call_user_func(
   --                      wp_dashboard_control_callbacks[ widget_control_id ],
   --                      "",
   --                      array(
   --                              "id"       => widget_control_id,
   --                              "callback" => wp_dashboard_control_callbacks[ widget_control_id ],
   --                      )
   --              );
   --      end;
   -- end Wp_Dashboard_Control_Callbacks;

-- --
-- -- The RSS dashboard widget control.
-- --
-- -- Sets up args to be used as input to wp_widget_rss_form(). Handles POST data
-- -- from RSS-type widgets.
-- --
-- -- @since 2.5.0
-- --
-- -- @param string widget_id
-- -- @param array  form_inputs
-- --
-- function wp_dashboard_rss_control( widget_id, form_inputs = array() ) then
--         widget_options = get_option( "dashboard_widget_options" );

--         if ( ! widget_options ) then
--                 widget_options = array();
--         end;

--         if ( ! isset( widget_options[ widget_id ] ) ) then
--                 widget_options[ widget_id ] = array();
--         end;

--         number = 1; -- Hack to use wp_widget_rss_form().

--         widget_options[ widget_id ]["number"] = number;

--         if ( "POST" === _SERVER["REQUEST_METHOD"] && isset( _POST["widget-rss"][ number ] ) ) then
--                 _POST["widget-rss"][ number ]         = wp_unslash( _POST["widget-rss"][ number ] );
--                 widget_options[ widget_id ]           = wp_widget_rss_process( _POST["widget-rss"][ number ] );
--                 widget_options[ widget_id ]["number"] = number;

--                 -- Title is optional. If black, fill it if possible.
--                 if ( ! widget_options[ widget_id ]["title"] && isset( _POST["widget-rss"][ number ]["title"] ) ) then
--                         rss = fetch_feed( widget_options[ widget_id ]["url"] );
--                         if ( is_wp_error( rss ) ) then
--                                 widget_options[ widget_id ]["title"] = htmlentities( __( "Unknown Feed" ) );
--                         end; else then
--                                 widget_options[ widget_id ]["title"] = htmlentities( strip_tags( rss->get_title() ) );
--                                 rss->__destruct();
--                                 unset( rss );
--                         end;
--                 end;

--                 update_option( "dashboard_widget_options", widget_options );

--                 locale    = get_user_locale();
--                 cache_key = "dash_v2_" . md5( widget_id . "_" . locale );
--                 delete_transient( cache_key );
--         end;

--         wp_widget_rss_form( widget_options[ widget_id ], form_inputs );
-- end;

   ------------------------------
   -- Wp_Dashboard_Events_News --
   ------------------------------

   procedure Wp_Dashboard_Events_News
   is
   begin
      Logging.Log ("wp_dashboard_events_news", "not implemented");
   end Wp_Dashboard_Events_News;
--         wp_print_community_events_markup();

--         ?>

--         <div class="wordpress-news hide-if-no-js">
--                 <?php wp_dashboard_primary(); ?>
--         </div>

--         <p class="community-events-footer">
--                 <?php
--                         printf(
--                                 "<a href="%1s" target="_blank">%2s <span class="screen-reader-text">%3s</span><span aria-hidden="true" class="dashicons dashicons-external"></span></a>",
--                                 "https://make.wordpress.org/community/meetups-landing-page",
--                                 __( "Meetups" ),
--                                 -- translators: Accessibility text.--
--                                 __( "(opens in a new tab)" )
--                         );
--                 ?>

--                 |

--                 <?php
--                         printf(
--                                 "<a href="%1s" target="_blank">%2s <span class="screen-reader-text">%3s</span><span aria-hidden="true" class="dashicons dashicons-external"></span></a>",
--                                 "https://central.wordcamp.org/schedule/",
--                                 __( "WordCamps" ),
--                                 -- translators: Accessibility text.--
--                                 __( "(opens in a new tab)" )
--                         );
--                 ?>

--                 |

--                 <?php
--                         printf(
--                                 "<a href="%1s" target="_blank">%2s <span class="screen-reader-text">%3s</span><span aria-hidden="true" class="dashicons dashicons-external"></span></a>",
--                                 -- translators: If a Rosetta site exists (e.g. https://es.wordpress.org/news/), then use that. Otherwise, leave untranslated.--
--                                 esc_url( _x( "https://wordpress.org/news/", "Events and News dashboard widget" ) ),
--                                 __( "News" ),
--                                 -- translators: Accessibility text.--
--                                 __( "(opens in a new tab)" )
--                         );
--                 ?>
--         </p>

--         <?php
-- end;

-- --
-- -- Prints the markup for the Community Events section of the Events and News Dashboard widget.
-- --
-- -- @since 4.8.0
-- --
-- function wp_print_community_events_markup() then
--         ?>

--         <div class="community-events-errors notice notice-error inline hide-if-js">
--                 <p class="hide-if-js">
--                         <?php _e( "This widget requires JavaScript." ); ?>
--                 </p>

--                 <p class="community-events-error-occurred" aria-hidden="true">
--                         <?php _e( "An error occurred. Please try again." ); ?>
--                 </p>

--                 <p class="community-events-could-not-locate" aria-hidden="true"></p>
--         </div>

--         <div class="community-events-loading hide-if-no-js">
--                 <?php _e( "Loading&hellip;" ); ?>
--         </div>

--         <?php
--         --
--         -- Hide the main element when the page first loads, because the content
--         -- won"t be ready until wp.communityEvents.renderEventsTemplate() has run.
--         --
--         ?>
--         <div id="community-events" class="community-events" aria-hidden="true">
--                 <div class="activity-block">
--                         <p>
--                                 <span id="community-events-location-message"></span>

--                                 <button class="button-link community-events-toggle-location" aria-expanded="false">
--                                         <span class="dashicons dashicons-location" aria-hidden="true"></span>
--                                         <span class="community-events-location-edit"><?php _e( "Select location" ); ?></span>
--                                 </button>
--                         </p>

--                         <form class="community-events-form" aria-hidden="true" action="<?php echo esc_url( admin_url( "admin-ajax.php" ) ); ?>" method="post">
--                                 <label for="community-events-location">
--                                         <?php _e( "City:" ); ?>
--                                 </label>
--                                 <?php
--                                 -- translators: Replace with a city related to your locale.
--                                 -- Test that it matches the expected location and has upcoming
--                                 -- events before including it. If no cities related to your
--                                 -- locale have events, then use a city related to your locale
--                                 -- that would be recognizable to most users. Use only the city
--                                 -- name itself, without any region or country. Use the endonym
--                                 -- (native locale name) instead of the English name if possible.
--                                 --
--                                 ?>
--                                 <input id="community-events-location" class="regular-text" type="text" name="community-events-location" placeholder="<?php esc_attr_e( "Cincinnati" ); ?>" />

--                                 <?php submit_button( __( "Submit" ), "secondary", "community-events-submit", false ); ?>

--                                 <button class="community-events-cancel button-link" type="button" aria-expanded="false">
--                                         <?php _e( "Cancel" ); ?>
--                                 </button>

--                                 <span class="spinner"></span>
--                         </form>
--                 </div>

--                 <ul class="community-events-results activity-block last"></ul>
--         </div>

--         <?php
-- end;

   -----------------------------------------
   -- Wp_Print_Community_Events_Templates --
   -----------------------------------------

   procedure Wp_Print_Community_Events_Templates
   is
      use Php.Echoing;
      use Inc_L10n;
   begin

      Echo ("<script id=""tmpl-community-events-attend-event-near"" type=""text/template"">");
      Printf (
        -- translators: %s: The name of a city.
        abs "Attend an upcoming event near %s.",
        [1 => "<strong>thenthen data.location.description end;end;</strong>"]
      );
      Echo ("</script>");

      Echo ("<script id=""tmpl-community-events-could-not-locate"" type=""text/template"">");
      Printf (
        -- translators: %s is the name of the city we couldn't locate.
        -- Replace the examples with cities in your locale, but test
        -- that they match the expected location before including them.
        -- Use endonyms (native locale names) whenever possible.
        --
        abs "%s could not be located. Please try another nearby city. For example: Kansas City; Springfield; Portland.",
        [1 => "<em>thenthendata.unknownCityend;end;</em>"]
      );
      Echo ("</script>");

      Echo ("<script id=""tmpl-community-events-event-list"" type=""text/template"">");
      Echo ("    <# _.each( data.events, function( event ) { #>");
      Echo ("        <li class=""event event-{{ event.type }} wp-clearfix"">");
      Echo ("            <div class=""event-info"">");
      Echo ("                <div class=""dashicons event-icon"" aria-hidden=""true""></div>");
      Echo ("                    <div class=""event-info-inner"">");
      Echo ("                        <a class=""event-title"" href=""{{ event.url }}"">{{ event.title }}</a>");
      Echo ("                        <span class=""event-city"">{{ event.location.location }}</span>");
      Echo ("                    </div>");
      Echo ("                </div>");

      Echo ("                <div class=""event-date-time"">");
      Echo ("                    <span class=""event-date"">{{ event.user_formatted_date }}</span>");
      Echo ("                        <# if ( ""meetup"" === event.type ) then #>");
      Echo ("                           <span class=""event-time"">");
      Echo ("                               {{ event.user_formatted_time }} {{ event.timeZoneAbbreviation }}");
      Echo ("                           </span>");
      Echo ("                        <# end; #>");
      Echo ("                </div>");
      Echo ("        </li>");
      Echo ("    <# end; ) #>");

      Echo ("    <# if ( data.events.length <= 2 ) { #>");
      Echo ("        <li class=""event-none"">");
      Printf (
        -- translators: %s: Localized meetup organization documentation URL.
        abs "Want more events? <a href=""%s"">Help organize the next one</a>!",
        [1 => abs "https://make.wordpress.org/community/organize-event-landing-page/"]
      );
      Echo ("        </li>");
      Echo ("    <# end; #>");
      Echo ("</script>");

      Echo ("<script id=""tmpl-community-events-no-upcoming-events"" type=""text/template"">");
      Echo ("    <li class=""event-none"">");
      Echo ("        <# if ( data.location.description ) then #>");
      Printf (
        -- translators: 1: The city the user searched for, 2: Meetup organization documentation URL.
        abs "There are no events scheduled near %1s at the moment. Would you like to <a href=""%2s"">organize a WordPress event</a>?",
        [
          1 => "{{ data.location.description }}",
          2 => "https://make.wordpress.org/community/handbook/meetup-organizer/welcome/"
        ]
      );

      Echo ("        <# end; else then #>");
      Printf (
        -- translators: %s: Meetup organization documentation URL.
        abs "There are no events scheduled near you at the moment. Would you like to <a href=""%s"">organize a WordPress event</a>?",
        [1 => abs "https://make.wordpress.org/community/handbook/meetup-organizer/welcome/"]
      );
      Echo ("       <# end; #>");
      Echo ("    </li>");
      Echo ("</script>");
   end Wp_Print_Community_Events_Templates;

-- --
-- -- "WordPress Events and News" dashboard widget.
-- --
-- -- @since 2.7.0
-- -- @since 4.8.0 Removed popular plugins feed.
-- --
-- function wp_dashboard_primary() then
--         feeds = array(
--                 "news"   => array(

--                         --
--                         -- Filters the primary link URL for the "WordPress Events and News" dashboard widget.
--                         --
--                         -- @since 2.5.0
--                         --
--                         -- @param string link The widget"s primary link URL.
--                         --
--                         "link"         => apply_filters( "dashboard_primary_link", __( "https://wordpress.org/news/" ) ),

--                         --
--                         -- Filters the primary feed URL for the "WordPress Events and News" dashboard widget.
--                         --
--                         -- @since 2.3.0
--                         --
--                         -- @param string url The widget"s primary feed URL.
--                         --
--                         "url"          => apply_filters( "dashboard_primary_feed", __( "https://wordpress.org/news/feed/" ) ),

--                         --
--                         -- Filters the primary link title for the "WordPress Events and News" dashboard widget.
--                         --
--                         -- @since 2.3.0
--                         --
--                         -- @param string title Title attribute for the widget"s primary link.
--                         --
--                         "title"        => apply_filters( "dashboard_primary_title", __( "WordPress Blog" ) ),
--                         "items"        => 2,
--                         "show_summary" => 0,
--                         "show_author"  => 0,
--                         "show_date"    => 0,
--                 ),
--                 "planet" => array(

--                         --
--                         -- Filters the secondary link URL for the "WordPress Events and News" dashboard widget.
--                         --
--                         -- @since 2.3.0
--                         --
--                         -- @param string link The widget"s secondary link URL.
--                         --
--                         "link"         => apply_filters( "dashboard_secondary_link", __( "https://planet.wordpress.org/" ) ),

--                         --
--                         -- Filters the secondary feed URL for the "WordPress Events and News" dashboard widget.
--                         --
--                         -- @since 2.3.0
--                         --
--                         -- @param string url The widget"s secondary feed URL.
--                         --
--                         "url"          => apply_filters( "dashboard_secondary_feed", __( "https://planet.wordpress.org/feed/" ) ),

--                         --
--                         -- Filters the secondary link title for the "WordPress Events and News" dashboard widget.
--                         --
--                         -- @since 2.3.0
--                         --
--                         -- @param string title Title attribute for the widget"s secondary link.
--                         --
--                         "title"        => apply_filters( "dashboard_secondary_title", __( "Other WordPress News" ) ),

--                         --
--                         -- Filters the number of secondary link items for the "WordPress Events and News" dashboard widget.
--                         --
--                         -- @since 4.4.0
--                         --
--                         -- @param string items How many items to show in the secondary feed.
--                         --
--                         "items"        => apply_filters( "dashboard_secondary_items", 3 ),
--                         "show_summary" => 0,
--                         "show_author"  => 0,
--                         "show_date"    => 0,
--                 ),
--         );

--         wp_dashboard_cached_rss_widget( "dashboard_primary", "wp_dashboard_primary_output", feeds );
-- end;

-- --
-- -- Displays the WordPress events and news feeds.
-- --
-- -- @since 3.8.0
-- -- @since 4.8.0 Removed popular plugins feed.
-- --
-- -- @param string widget_id Widget ID.
-- -- @param array  feeds     Array of RSS feeds.
-- --
-- function wp_dashboard_primary_output( widget_id, feeds ) then
--         foreach ( feeds as type => args ) then
--                 args["type"] = type;
--                 echo "<div class="rss-widget">";
--                         wp_widget_rss_output( args["url"], args );
--                 echo "</div>";
--         end;
-- end;

-- --
-- -- Displays file upload quota on dashboard.
-- --
-- -- Runs on the {@see "activity_box_end"} hook in wp_dashboard_right_now().
-- --
-- -- @since 3.0.0
-- --
-- -- @return true|void True if not multisite, user can't upload files, or the space check option is disabled.
-- --
-- function wp_dashboard_quota() then
--         if ( ! is_multisite() || ! current_user_can( "upload_files" )
--                 || get_site_option( "upload_space_check_disabled" )
--         ) then
--                 return true;
--         end;

--         quota = get_space_allowed();
--         used  = get_space_used();

--         if ( used > quota ) then
--                 percentused = "100";
--         end; else then
--                 percentused = ( used / quota )-- 100;
--         end;

--         used_class  = ( percentused >= 70 ) ? " warning" : "";
--         used        = round( used, 2 );
--         percentused = number_format( percentused );

--         ?>
--         <h3 class="mu-storage"><?php _e( "Storage Space" ); ?></h3>
--         <div class="mu-storage">
--         <ul>
--                 <li class="storage-count">
--                         <?php
--                         text = sprintf(
--                                 -- translators: %s: Number of megabytes.--
--                                 __( "%s MB Space Allowed" ),
--                                 number_format_i18n( quota )
--                         );
--                         printf(
--                                 "<a href="%1s">%2s <span class="screen-reader-text">(%3s)</span></a>",
--                                 esc_url( admin_url( "upload.php" ) ),
--                                 text,
--                                 __( "Manage Uploads" )
--                         );
--                         ?>
--                 </li><li class="storage-count <?php echo used_class; ?>">
--                         <?php
--                         text = sprintf(
--                                 -- translators: 1: Number of megabytes, 2: Percentage.--
--                                 __( "%1s MB (%2s%%) Space Used" ),
--                                 number_format_i18n( used, 2 ),
--                                 percentused
--                         );
--                         printf(
--                                 "<a href="%1s" class="musublink">%2s <span class="screen-reader-text">(%3s)</span></a>",
--                                 esc_url( admin_url( "upload.php" ) ),
--                                 text,
--                                 __( "Manage Uploads" )
--                         );
--                         ?>
--                 </li>
--         </ul>
--         </div>
--         <?php
-- end;

   ------------------------------
   -- Wp_Dashboard_Browser_Nag --
   ------------------------------

   procedure Wp_Dashboard_Browser_Nag
   is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Vars;

--    global is_IE;

      Notice   : UString;
      Msg      : UString;
      Response : constant Array_Type := Wp_Check_Browser_Version;
   begin
      if Response /= Empty_Array then
         if Is_IE then
            Msg := +abs "Internet Explorer does not give you the best WordPress experience. Switch to Microsoft Edge, or another more modern browser to get the most from your site.";
         elsif As_Boolean (Get (Response, "insecure")) then
            Msg := +Sprintf (
              -- translators: %s: Browser name and link.
              abs "It looks like you're using an insecure version of %s. Using an outdated browser makes your computer unsafe. For the best WordPress experience, please update your browser.",
              [1 => Sprintf ("<a href=""%s"">%s</a>",
                [
                  1 => ESC_URL (Get_As_String (Response, "update_url")),
                  2 => ESC_HTML (Get_As_String (Response, "name"))
                ])
              ]
            );
         else
            Msg := +Sprintf (
              -- translators: %s: Browser name and link.
              abs "It looks like you're using an old version of %s. For the best WordPress experience, please update your browser.",
              [1 => Sprintf ("<a href=""%s"">%s</a>",
                [
                  1 => ESC_URL (Get_As_String (Response, "update_url")),
                  2 => ESC_HTML (Get_As_String (Response, "name"))
                ])
              ]
            );
         end if;

         declare
            Browser_Nag_Class : UString;
         begin
            if not Empty (Response, "img_src") then
               declare
                  Img_Src : constant String :=
                    (if Is_SSL and then not Empty (Response, "img_src_ssl")
                     then Get_As_String (Response, "img_src_ssl")
                     else Get_As_String (Response, "img_src"));
               begin
                  Append (Notice,
                          "<div class=""alignright browser-icon""><img src=""" &
                          ESC_URL (Img_Src) & """ alt="""" /></div>");
                  Browser_Nag_Class := +" has-browser-icon";
               end;
            end if;
            Append (Notice,
                    "<p class=""browser-update-nag" & Browser_Nag_Class &
                    """>" & Msg & "</p>");
         end;

         declare
            Browsehappy     : UString := +"https://browsehappy.com/";
            Msg_Browsehappy : UString;

            Locale : constant String  := Get_User_Locale;
         begin
            if "en_US" /= Locale then
               Browsehappy := +Add_Query_Arg ("locale", Locale, -Browsehappy);
            end if;

            if Is_IE then
               Msg_Browsehappy := +Sprintf (
                 -- translators: %s: Browse Happy URL.
                 abs "Learn how to <a href=""%s"" class=""update-browser-link"">browse happy</a>",
                 [1 => ESC_URL (-Browsehappy)]
               );
            else
               Msg_Browsehappy := +Sprintf (
                 -- translators: 1: Browser update URL, 2: Browser name, 3: Browse Happy URL.
                 abs "<a href=""%1s"" class=""update-browser-link"">Update %2s</a> or learn how to <a href=""%3s"" class=""browse-happy-link"">browse happy</a>",
                 [
                   1 => ESC_Attr (Get_As_String (Response, "update_url")),
                   2 => ESC_HTML (Get_As_String (Response, "name")),
                   3 => ESC_URL (-Browsehappy)
                 ]
               );
            end if;

            Append (Notice, "<p>" & (-Msg_Browsehappy) & "</p>");
            Append (Notice,
                    "<p class=""hide-if-no-js""><a href="""" class=""dismiss"" " &
                    "aria-label=""" &
                    ESC_Attr_XX ("Dismiss the browser warning panel") & """>" &
                    abs "Dismiss" & "</a></p>");
            Append (Notice, "<div class=""clear""></div>");
         end;

         --
         -- Filters the notice output for the "Browse Happy" nag meta box.
         --
         -- @since 3.2.0
         --
         -- @param string      notice   The notice content.
         -- @param array|false response An array containing web browser information, or
         --                             false on failure.
         --                             See wp_check_browser_version().
         --
         Echo (Apply_Filters ("browse-happy-notice", -Notice, Response));
      end if;
   end Wp_Dashboard_Browser_Nag;

   ---------------------------------
   -- Dashboard_Browser_Nag_Class --
   ---------------------------------

   function Dashboard_Browser_Nag_Class (Classes : List_Type)
                                         return List_Type
   is
      Response  : constant Array_Type := Wp_Check_Browser_Version;
      Classes_2 : List_Type  := Classes;
   begin
      if
        Response /= Empty_Array and then
        As_Boolean (Get (Response, "insecure"))
      then
         Classes_2.Append ("browser-insecure");
      end if;

      return Classes_2;
   end Dashboard_Browser_Nag_Class;

   ------------------------------
   -- Wp_Check_Browser_Version --
   ------------------------------

   function Wp_Check_Browser_Version
            return Array_Type
   is
      use Php.JSON;
      use Php.Misc;
      use Array_Lists;
      use Binder;
      use UStrings;
      use Inc_HTTP;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_Options;
   begin
      if Empty (X_SERVER, "HTTP_USER_AGENT") then
         return Empty_Array; -- False
      end if;

      declare
         Key : constant String :=
           MD5 (Get_As_String (X_SERVER, "HTTP_USER_AGENT"));

         Response : constant String_Maps.Map :=
           Get_Site_Transient ("browser_" & Key);
      begin
         if Response.Is_Empty then
--       if False = Response then
                -- Include an unmodified wp_version.
                -- require ABSPATH . WPINC . "/version.php";
            declare
               URL : UString :=
                 +"http://api.wordpress.org/core/browse-happy/1.1/";

               Options : constant Array_Type := To_Array_Type ([
                 Build ("body",
                        To_Array_Type ([Build ("useragent",
                                        Get_As_String (X_SERVER, "HTTP_USER_AGENT"))])),
                 Build ("user-agent",
                        "WordPress/" & Inc_Versions.Wp_Version & "; " & Home_URL ("/"))
               ]);
            begin
               if
                 Wp_HTTP_Supports (Capabilities =>
                                    To_Array_Type ([Build ("ssl", True)]))
               then
                  URL := +Set_URL_Scheme (-URL, "https");
               end if;

               declare
                  Response_2 : Array_Type := Wp_Remote_Post (-URL, Options);
               begin
                  if
                    Is_Wp_Error (Response_2) or else
                    200 /= Wp_Remote_Retrieve_Response_Code (Response_2)
                  then
                     return Empty_Array; -- false
                  end if;

                  --
                  -- Response should be an array with:
                  --  "platform" - string - A user-friendly platform name, if it can be
                  --                        determined
                  --  "name" - string - A user-friendly browser name
                  --  "version" - string - The version of the browser the user is using
                  --  "current_version" - string - The most recent version of the
                  --                               browser
                  --  "upgrade" - boolean - Whether the browser needs an upgrade
                  --  "insecure" - boolean - Whether the browser is deemed insecure
                  --  "update_url" - string - The url to visit to upgrade
                  --  "img_src" - string - An image representing the browser
                  --  "img_src_ssl" - string - An image (over SSL) representing the
                  --                           browser
                  --
                  Response_2 :=
                    JSON_Decode (Wp_Remote_Retrieve_Body (Response_2), True);

                  -- if not Is_Array (Response_2) then
                  --    return Empty_Array; -- False
                  -- end if;

                  Set_Site_Transient ("browser_" & Key, Response_2,
                                      Constants.WEEK_IN_SECONDS);
               end;
            end;
         end if;

         return Empty_Array; -- Response; -- XXX
      end;
   end Wp_Check_Browser_Version;

   --------------------------
   -- Wp_Dashboard_Php_Nag --
   --------------------------

   procedure Wp_Dashboard_PHP_Nag
   is
      use Php.Echoing;
      use Php.Misc;
      use Php.Strings;
      use UStrings;
      use Adi_Misc;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;

      Response : constant Array_Type := Wp_Check_PHP_Version;
      Message  : UString;
   begin
      if Response = Empty_Array then
         return;
      end if;

      if
        Isset (Response, "is_secure") and then
        not As_Boolean (Get (Response, "is_secure"))
      then
         -- The `is_secure` array key name doesn't actually imply this is a secure
         -- version of PHP. It only means it receives security updates.

         if As_Boolean (Get (Response, "is_lower_than_future_minimum")) then
            Message := +Sprintf (
              -- translators: %s: The server PHP version.
              abs "Your site is running on an outdated version of PHP (%s), which does not receive security updates and soon will not be supported by WordPress. Ensure that PHP is updated on your server as soon as possible. Otherwise you will not be able to upgrade WordPress.",
              [1 => PHP_VERSION]
            );
         else
            Message := +Sprintf (
              -- translators: %s: The server PHP version.
              abs "Your site is running on an outdated version of PHP (%s), which does not receive security updates. It should be updated.",
              [1 => PHP_VERSION]
            );
         end if;

      elsif As_Boolean (Get (Response, "is_lower_than_future_minimum")) then
         Message := +Sprintf (
           -- translators: %s: The server PHP version.
           abs "Your site is running on an outdated version of PHP (%s), which soon will not be supported by WordPress. Ensure that PHP is updated on your server as soon as possible. Otherwise you will not be able to upgrade WordPress.",
           [1 => PHP_VERSION]
         );
      else
         Message := +Sprintf (
           -- translators: %s: The server PHP version.
           abs "Your site is running on an outdated version of PHP (%s), which should be updated.",
           [1 => PHP_VERSION]
         );
      end if;

      Echo ("<p class=""bigger-bolder-text"">" & (-Message) & "</p>");

      Echo ("<p>");
      X_E ("What is PHP and how does it affect my site?");
      Echo ("</p>");
      Echo ("<p>");
      Echo ("    ");
      X_E ("PHP is one of the programming languages used to build WordPress. Newer versions of PHP receive regular security updates and may increase your site&#8217;s performance.");

      if not Empty (Response, "recommended_version") then
         Printf (
           -- translators: %s: The minimum recommended PHP version.
           abs "The minimum recommended version of PHP is %s.",
           [1 => Get_As_String (Response, "recommended_version")]
         );
      end if;
      Echo ("</p>");

      Echo ("<p class=""button-container"">");
      Printf (
        "<a class=""button button-primary"" href=""%1s"" target=""_blank"" rel=""noopener"">%2s <span class=""screen-reader-text"">%3s</span><span aria-hidden=""true"" class=""dashicons dashicons-external""></span></a>",
        [
          1 => ESC_URL (Wp_Get_Update_PHP_URL),
          2 => abs "Learn more about updating PHP",
               -- translators: Accessibility text.
          3 => abs "(opens in a new tab)"
        ]
      );
      Echo ("</p>");

      Wp_Update_PHP_Annotation;
      Wp_Direct_PHP_Update_Button;
   end Wp_Dashboard_PHP_Nag;

   -----------------------------
   -- Dashboard_Php_Nag_Class --
   -----------------------------

   function Dashboard_PHP_Nag_Class (Classes : List_Type)
                                     return List_Type
   is
      use Adi_Misc;

      Classes_2 : List_Type := Classes;
      Response : constant Array_Type := Wp_Check_PHP_Version;
   begin
      if Response = Empty_Array then
         return Classes_2;
      end if;

      if
        Isset (Response, "is_secure") and then
        As_Boolean (Get (Response, "is_secure"))
      then
         Classes_2.Append ("php-no-security-updates");
      elsif As_Boolean (Get (Response, "is_lower_than_future_minimum")) then
         Classes_2.Append ("php-version-lower-than-future-minimum");
      end if;

      return Classes_2;
   end Dashboard_PHP_Nag_Class;

   ------------------------------
   -- Wp_Dashboard_Site_Health --
   ------------------------------

   procedure Wp_Dashboard_Site_Health
   is
   begin
      Logging.Log ("wp_dashboard_site_health", "not implemented");
   end Wp_Dashboard_Site_Health;
--         get_issues = get_transient( "health-check-site-status-result" );

--         issue_counts = array();

--         if ( false !== get_issues ) then
--                 issue_counts = json_decode( get_issues, true );
--         end;

--         if ( ! is_array( issue_counts ) || ! issue_counts ) then
--                 issue_counts = array(
--                         "good"        => 0,
--                         "recommended" => 0,
--                         "critical"    => 0,
--                 );
--         end;

--         issues_total = issue_counts["recommended"] + issue_counts["critical"];
--         ?>
--         <div class="health-check-widget">
--                 <div class="health-check-widget-title-section site-health-progress-wrapper loading hide-if-no-js">
--                         <div class="site-health-progress">
--                                 <svg role="img" aria-hidden="true" focusable="false" width="100%" height="100%" viewBox="0 0 200 200" version="1.1" xmlns="http://www.w3.org/2000/svg">
--                                         <circle r="90" cx="100" cy="100" fill="transparent" stroke-dasharray="565.48" stroke-dashoffset="0"></circle>
--                                         <circle id="bar" r="90" cx="100" cy="100" fill="transparent" stroke-dasharray="565.48" stroke-dashoffset="0"></circle>
--                                 </svg>
--                         </div>
--                         <div class="site-health-progress-label">
--                                 <?php if ( false === get_issues ) : ?>
--                                         <?php _e( "No information yet&hellip;" ); ?>
--                                 <?php else : ?>
--                                         <?php _e( "Results are still loading&hellip;" ); ?>
--                                 <?php endif; ?>
--                         </div>
--                 </div>

--                 <div class="site-health-details">
--                         <?php if ( false === get_issues ) : ?>
--                                 <p>
--                                         <?php
--                                         printf(
--                                                 -- translators: %s: URL to Site Health screen.--
--                                                 __( "Site health checks will automatically run periodically to gather information about your site. You can also <a href="%s">visit the Site Health screen</a> to gather information about your site now." ),
--                                                 esc_url( admin_url( "site-health.php" ) )
--                                         );
--                                         ?>
--                                 </p>
--                         <?php else : ?>
--                                 <p>
--                                         <?php if ( issues_total <= 0 ) : ?>
--                                                 <?php _e( "Great job! Your site currently passes all site health checks." ); ?>
--                                         <?php elseif ( 1 === (int) issue_counts["critical"] ) : ?>
--                                                 <?php _e( "Your site has a critical issue that should be addressed as soon as possible to improve its performance and security." ); ?>
--                                         <?php elseif ( issue_counts["critical"] > 1 ) : ?>
--                                                 <?php _e( "Your site has critical issues that should be addressed as soon as possible to improve its performance and security." ); ?>
--                                         <?php elseif ( 1 === (int) issue_counts["recommended"] ) : ?>
--                                                 <?php _e( "Your site&#8217;s health is looking good, but there is still one thing you can do to improve its performance and security." ); ?>
--                                         <?php else : ?>
--                                                 <?php _e( "Your site&#8217;s health is looking good, but there are still some things you can do to improve its performance and security." ); ?>
--                                         <?php endif; ?>
--                                 </p>
--                         <?php endif; ?>

--                         <?php if ( issues_total > 0 && false !== get_issues ) : ?>
--                                 <p>
--                                         <?php
--                                         printf(
--                                                 -- translators: 1: Number of issues. 2: URL to Site Health screen.--
--                                                 _n(
--                                                         "Take a look at the <strong>%1d item</strong> on the <a href="%2s">Site Health screen</a>.",
--                                                         "Take a look at the <strong>%1d items</strong> on the <a href="%2s">Site Health screen</a>.",
--                                                         issues_total
--                                                 ),
--                                                 issues_total,
--                                                 esc_url( admin_url( "site-health.php" ) )
--                                         );
--                                         ?>
--                                 </p>
--                         <?php endif; ?>
--                 </div>
--         </div>

--         <?php
-- end;

-- --
-- -- Empty function usable by plugins to output empty dashboard widget (to be populated later by JS).
-- --
-- -- @since 2.5.0
-- --
-- function wp_dashboard_empty() thenend;

-- --
-- -- Displays a welcome panel to introduce users to WordPress.
-- --
-- -- @since 3.3.0
-- -- @since 5.9.0 Send users to the Site Editor if the active theme is block-based.
-- --
-- function wp_welcome_panel() then
--         list( display_version ) = explode( "-", get_bloginfo( "version" ) );
--         can_customize           = current_user_can( "customize" );
--         is_block_theme          = wp_is_block_theme();
--         ?>
--         <div class="welcome-panel-content">
--         <div class="welcome-panel-header">
--                 <div class="welcome-panel-header-image">
--                         <?php echo file_get_contents( dirname( __DIR__ ) . "/images/about-header-about.svg" ); ?>
--                 </div>
--                 <h2><?php _e( "Welcome to WordPress!" ); ?></h2>
--                 <p>
--                         <a href="<?php echo esc_url( admin_url( "about.php" ) ); ?>">
--                         <?php
--                                 -- translators: %s: Current WordPress version.--
--                                 printf( __( "Learn more about the %s version." ), display_version );
--                         ?>
--                         </a>
--                 </p>
--         </div>
--         <div class="welcome-panel-column-container">
--                 <div class="welcome-panel-column">
--                         <svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
--                                 <rect width="48" height="48" rx="4" fill="#1E1E1E"/>
--                                 <path fill-rule="evenodd" clip-rule="evenodd" d="M32.0668 17.0854L28.8221 13.9454L18.2008 24.671L16.8983 29.0827L21.4257 27.8309L32.0668 17.0854ZM16 32.75H24V31.25H16V32.75Z" fill="white"/>
--                         </svg>
--                         <div class="welcome-panel-column-content">
--                                 <h3><?php _e( "Author rich content with blocks and patterns" ); ?></h3>
--                                 <p><?php _e( "Block patterns are pre-configured block layouts. Use them to get inspired or create new pages in a flash." ); ?></p>
--                                 <a href="<?php echo esc_url( admin_url( "post-new.php?post_type=page" ) ); ?>"><?php _e( "Add a new page" ); ?></a>
--                         </div>
--                 </div>
--                 <div class="welcome-panel-column">
--                         <svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
--                                 <rect width="48" height="48" rx="4" fill="#1E1E1E"/>
--                                 <path fill-rule="evenodd" clip-rule="evenodd" d="M18 16h12a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H18a2 2 0 0 1-2-2V18a2 2 0 0 1 2-2zm12 1.5H18a.5.5 0 0 0-.5.5v3h13v-3a.5.5 0 0 0-.5-.5zm.5 5H22v8h8a.5.5 0 0 0 .5-.5v-7.5zm-10 0h-3V30a.5.5 0 0 0 .5.5h2.5v-8z" fill="#fff"/>
--                         </svg>
--                         <div class="welcome-panel-column-content">
--                         <?php if ( is_block_theme ) : ?>
--                                 <h3><?php _e( "Customize your entire site with block themes" ); ?></h3>
--                                 <p><?php _e( "Design everything on your site &#8212; from the header down to the footer, all using blocks and patterns." ); ?></p>
--                                 <a href="<?php echo esc_url( admin_url( "site-editor.php" ) ); ?>"><?php _e( "Open site editor" ); ?></a>
--                         <?php else : ?>
--                                 <h3><?php _e( "Start Customizing" ); ?></h3>
--                                 <p><?php _e( "Configure your site&#8217;s logo, header, menus, and more in the Customizer." ); ?></p>
--                                 <?php if ( can_customize ) : ?>
--                                         <a class="load-customize hide-if-no-customize" href="<?php echo wp_customize_url(); ?>"><?php _e( "Open the Customizer" ); ?></a>
--                                 <?php endif; ?>
--                         <?php endif; ?>
--                         </div>
--                 </div>
--                 <div class="welcome-panel-column">
--                         <svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
--                                 <rect width="48" height="48" rx="4" fill="#1E1E1E"/>
--                                 <path fill-rule="evenodd" clip-rule="evenodd" d="M31 24a7 7 0 0 1-7 7V17a7 7 0 0 1 7 7zm-7-8a8 8 0 1 1 0 16 8 8 0 0 1 0-16z" fill="#fff"/>
--                         </svg>
--                         <div class="welcome-panel-column-content">
--                         <?php if ( is_block_theme ) : ?>
--                                 <h3><?php _e( "Switch up your site&#8217;s look & feel with Styles" ); ?></h3>
--                                 <p><?php _e( "Tweak your site, or give it a whole new look! Get creative &#8212; how about a new color palette or font?" ); ?></p>
--                                 <a href="<?php echo esc_url( admin_url( "site-editor.php?styles=open" ) ); ?>"><?php _e( "Edit styles" ); ?></a>
--                         <?php else : ?>
--                                 <h3><?php _e( "Discover a new way to build your site." ); ?></h3>
--                                 <p><?php _e( "There is a new kind of WordPress theme, called a block theme, that lets you build the site you&#8217;ve always wanted &#8212; with blocks and styles." ); ?></p>
--                                 <a href="<?php echo esc_url( __( "https://wordpress.org/support/article/block-themes/" ) ); ?>"><?php _e( "Learn about block themes" ); ?></a>
--                         <?php endif; ?>
--                         </div>
--                 </div>
--         </div>
--         </div>
--         <?php
-- end;

end Adi_Dashboard;
