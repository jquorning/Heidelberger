--
-- WordPress Dashboard Widget Administration Screen API
--
-- @package WordPress
-- @subpackage Administration
--

with Arrays;
with Lists;

with Class_Comments;

package Adi_Dashboard
is
   use Arrays;
   use Lists;

   --
   -- Registers dashboard widgets.
   --
   -- Handles POST data, sets up filters.
   --
   -- @since 2.5.0
   --
   -- @global array wp_registered_widgets
   -- @global array wp_registered_widget_controls
   -- @global callable[] wp_dashboard_control_callbacks
   --
   procedure Wp_Dashboard_Setup;

   --
   -- Adds a new dashboard widget.
   --
   -- @since 2.7.0
   -- @since 5.6.0 The `context` and `priority` parameters were added.
   --
   -- @global callable[] wp_dashboard_control_callbacks
   --
   -- @param string   widget_id        Widget ID  (used in the "id" attribute for
   --                                  the widget).
   -- @param string   widget_name      Title of the widget.
   -- @param callable callback         Function that fills the widget with the desired
   --                                  content. The function should echo its output.
   -- @param callable control_callback Optional. Function that outputs controls for
   --                                  the widget. Default null.
   -- @param array    callback_args    Optional. Data that should be set as the args
   --                                  property of the widget array (which is the
   --                                  second parameter passed to your callback).
   --                                  Default null.
   -- @param string   context          Optional. The context within the screen where
   --                                  the box should display. Accepts "normal",
   --                                  "side", "column3", or "column4". Default
   --                                  "normal".
   -- @param string   priority         Optional. The priority within the context where
   --                                  the box should show. Accepts "high", "core",
   --                                  "default", or "low". Default "core".
   --
   procedure Wp_Add_Dashboard_Widget
               (Widget_Id        : String;
                Widget_Name      : String;
                Callback         : Callable;
                Control_Callback : Callable   := null;
                Callback_Args    : Array_Type := Empty_Array; -- null;
                Context          : String     := "normal";
                Priority         : String     := "core");

   --
   -- Outputs controls for the current dashboard widget.
   --
   -- @access private
   -- @since 2.7.0
   --
   -- @param mixed dashboard
   -- @param array meta_box
   --
   procedure X_Wp_Dashboard_Control_Callback (Dashboard : Multi_Type;
                                              Meta_Box  : Array_Type);

   --
   -- The Quick Draft widget display and creation of drafts.
   --
   -- @since 3.8.0
   --
   -- @global int post_ID
   --
   -- @param string|false error_msg Optional. Error message. Default false.
   --
   procedure Wp_Dashboard_Quick_Press (Error_Msg : String := ""); -- = false

   --
   -- Show recent drafts of the user on the dashboard.
   --
   -- @since 2.7.0
   --
   -- @param WP_Post[]|false drafts Optional. Array of posts to display. Default false.
   --
   procedure Wp_Dashboard_Recent_Drafts (Drafts : Boolean := False)
   is null;

   --
   -- Outputs a row for the Recent Comments widget.
   --
   -- @access private
   -- @since 2.7.0
   --
   -- @global WP_Comment comment Global comment object.
   --
   -- @param WP_Comment comment   The current comment.
   -- @param bool       show_date Optional. Whether to display the date.
   --
   procedure X_Wp_Dashboard_Recent_Comments_Row
               (Comment   : in out Class_Comments.Wp_Comment;
                Show_Date : Boolean := True);

   --
   -- Displays the dashboard.
   --
   -- @since 2.5.0
   --
   procedure Wp_Dashboard;

   ----------------------------
   ---- Dashboard Widgets. ----
   ----------------------------

   --
   -- Dashboard widget that displays some basic stats about the site.
   --
   -- Formerly "Right Now". A streamlined "At a Glance" as of 3.8.
   --
   -- @since 2.7.0
   --
   procedure Wp_Dashboard_Right_Now;

   --
   -- @since 3.1.0
   --
   procedure Wp_Network_Dashboard_Right_Now;

   --
   -- Callback function for Activity widget.
   --
   -- @since 3.8.0
   --
   procedure Wp_Dashboard_Site_Activity;

   --
   -- Generates Publishing Soon and Recently Published sections.
   --
   -- @since 3.8.0
   --
   -- @param array args {
   --     An array of query and display arguments.
   --
   --     @type int    max     Number of posts to display.
   --     @type string status  Post status.
   --     @type string order   Designates ascending ("ASC") or descending ("DESC")
   --                          order.
   --     @type string title   Section title.
   --     @type string id      The container id.
   -- }
   -- @return bool False if no posts were found. True otherwise.
   --
   function Wp_Dashboard_Recent_Posts (Args : Array_Type)
                                       return Boolean;

   --
   -- Show Comments section.
   --
   -- @since 3.8.0
   --
   -- @param int total_items Optional. Number of comments to query. Default 5.
   -- @return bool False if no comments were found. True otherwise.
   --
   function Wp_Dashboard_Recent_Comments (Total_Items : Natural := 5)
                                          return Boolean;

   --
   -- Renders the events templates for the Event and News widget.
   --
   -- @since 4.8.0
   --
   procedure Wp_Print_Community_Events_Templates;

   --
   -- Displays the browser update nag.
   --
   -- @since 3.2.0
   -- @since 5.8.0 Added a special message for Internet Explorer users.
   --
   -- @global bool is_IE
   --
   procedure Wp_Dashboard_Browser_Nag;

   --
   -- Adds an additional class to the browser nag if the current version is insecure.
   --
   -- @since 3.2.0
   --
   -- @param string[] classes Array of meta box classes.
   -- @return string[] Modified array of meta box classes.
   --
   function Dashboard_Browser_Nag_Class (Classes : List_Type)
                                         return List_Type;

   --
   -- Checks if the user needs a browser update.
   --
   -- @since 3.2.0
   --
   -- @return array|false Array of browser data on success, false on failure.
   --
   function Wp_Check_Browser_Version
            return Array_Type;

   --
   -- Displays the PHP update nag.
   --
   -- @since 5.1.0
   --
   procedure Wp_Dashboard_PHP_Nag;

   --
   -- Adds an additional class to the PHP nag if the current version is insecure.
   --
   -- @since 5.1.0
   --
   -- @param string[] classes Array of meta box classes.
   -- @return string[] Modified array of meta box classes.
   --
   function Dashboard_PHP_Nag_Class (Classes : List_Type)
                                     return List_Type;

   --
   -- Displays the Site Health Status widget.
   --
   -- @since 5.4.0
   --
   procedure Wp_Dashboard_Site_Health;

   --
   -- Renders the Events and News dashboard widget.
   --
   -- @since 4.8.0
   --
   procedure Wp_Dashboard_Events_News;

   --
   -- Calls widget control callback.
   --
   -- @since 2.5.0
   --
   -- @global callable[] wp_dashboard_control_callbacks
   --
   -- @param int|false widget_control_id Optional. Registered widget ID. Default false.
   --
   procedure Wp_Dashboard_Trigger_Widget_Control
               (Widget_Control_Id : String := ""); -- Integer := 0); -- false

end Adi_Dashboard;
