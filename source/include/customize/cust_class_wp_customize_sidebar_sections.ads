--
-- Customize API: WP_Customize_Sidebar_Section class
--
-- @package WordPress
-- @subpackage Customize
-- @since 4.4.0
--

with Ada.Strings.Unbounded;

with Arrays;

with Class_Customize_Sections;
limited with Class_Customize_Managers;

package Cust_Class_Wp_Customize_Sidebar_Sections
is
   use Ada.Strings.Unbounded;
   use Arrays;

   --
   -- Customizer section representing widget area (sidebar).
   --
   -- @since 4.1.0
   --
   -- @see WP_Customize_Section
   --
   type Wp_Customize_Sidebar_Section is
      new Class_Customize_Sections.Wp_Customize_Section with
      record
         --
         -- Type of this section.
         --
         -- @since 4.1.0
         -- @var string
         --
         Typ : Unbounded_String := To_Unbounded_String ("sidebar");

         --
         -- Unique identifier.
         --
         -- @since 4.1.0
         -- @var string
         --
         Sidebar_Id : Unbounded_String;
      end record;

   overriding
   function X_Construct
              (Manager : access Class_Customize_Managers.Wp_Customize_Manager;
               Id      : String;
               Args    : Array_Type := Empty_Array)
               return Wp_Customize_Sidebar_Section;

        --  --
        --  -- Gather the parameters passed to client JavaScript via JSON.
        --  --
        --  -- @since 4.1.0
        --  --
        --  -- @return array The array to be exported to the client as JSON.
        --  --
        -- public function json() then
        --         json              = parent::json();
        --         json["sidebarId"] = this.sidebar_id;
        --         return json;
        -- end;

        -- --
        -- -- Whether the current sidebar is rendered on the page.
        -- --
        -- -- @since 4.1.0
        -- --
        -- -- @return bool Whether sidebar is rendered.
        -- --
        -- public function active_callback() then
        --         return this.manager.widgets.is_sidebar_rendered( this.sidebar_id );
        -- end;

end Cust_Class_Wp_Customize_Sidebar_Sections;
