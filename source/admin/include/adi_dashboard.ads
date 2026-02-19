--
-- WordPress Dashboard Widget Administration Screen API
--
-- @package WordPress
-- @subpackage Administration
--

package Adi_Dashboard
is

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
   procedure Wp_Dashboard_Setup
   is null;

   --
   -- The Quick Draft widget display and creation of drafts.
   --
   -- @since 3.8.0
   --
   -- @global int post_ID
   --
   -- @param string|false error_msg Optional. Error message. Default false.
   --
   procedure Wp_Dashboard_Quick_Press (Error_Msg : String := "") -- = false
                                       is null;

   --
   -- Displays the dashboard.
   --
   -- @since 2.5.0
   --
   procedure Wp_Dashboard;

   --
   -- Renders the events templates for the Event and News widget.
   --
   -- @since 4.8.0
   --
   procedure Wp_Print_Community_Events_Templates
   is null;

end Adi_Dashboard;
