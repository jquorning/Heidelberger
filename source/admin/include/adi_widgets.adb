--
-- WordPress Widgets Administration API
--
-- @package WordPress
-- @subpackage Administration
--

with UStrings;
with Helpers;
with Lists;
with Php.Preg;
with Php.Strings;

with Class_Customize_Widgets;

package body Adi_Widgets
is
   use Lists;

   -------------
   -- Globals --
   -------------

   Wp_Registered_Widgets : Array_Type
     renames Class_Customize_Widgets.Global_Wp_Registered_Widgets;

   --------------------------
   -- X_Sort_Name_Callback --
   --------------------------

   function X_Sort_Name_Callback (A, B : Multi_Type)
                                  return Integer
   is
      use Php;
      use Php.Strings;

      Left  : constant String := As_String (Get (As_Array (A), "name"));
      Right : constant String := As_String (Get (As_Array (B), "name"));
   begin
      return Strnatcasecmp (Left, Right);
   end X_Sort_Name_Callback;

   ---------------------------------------------
   -- Wp_List_Widget_Controls_Dynamic_Sidebar --
   ---------------------------------------------

   Static_I : Natural := 0;

   function Wp_List_Widget_Controls_Dynamic_Sidebar (Params : Array_Type)
                                                     return Array_Type
   is
--    global wp_registered_widgets;
--    static i = 0;
      Params_2  : constant Array_Type := Params;
      Params_0  : Array_Type := As_Array (Get (Params_2, "[0]"));
      Widget_Id : constant String := As_String (Get (Params_0, "widget_id"));

      Id : constant String := (if Isset (Params_0, "_temp_id")
                               then As_String (Get (Params_0, "_temp_id"))
                               else Widget_Id);

      Hidden : constant String := (if Isset (Params_0, "_hide")
                                   then " style=""display:none;""" else "");
   begin
      Static_I := Static_I + 1;

      Set (Params_0, "before_widget", From_String (
           "<div id=""widget-" & Helpers.Image (Static_I) & "_" & Id &
           """ class=""widget""hidden>"));

      Set (Params_0, "after_widget", From_String ("</div>"));
      Set (Params_0, "before_title", From_String ("%BEG_OF_TITLE%")); -- Deprecated.
      Set (Params_0, "after_title",  From_String ("%END_OF_TITLE%")); -- Deprecated.

      if
        Kind_Of (Get (Ref_2 (Wp_Registered_Widgets, Widget_Id, "callback")))
        = Kind_Callable
      then
--    if Is_Callable (Ref_2 (Wp_Registered_Widgets, Widget_Id, "callback")) then
         Set_2 (Wp_Registered_Widgets, Widget_Id, "_callback",
                Get (Ref_2 (Wp_Registered_Widgets, Widget_Id, "callback")));
         Set_2 (Wp_Registered_Widgets, Widget_Id, "callback",
                From_String ("wp_widget_control"));
      end if;

      return Params_2;
   end Wp_List_Widget_Controls_Dynamic_Sidebar;

   ---------------------------
   -- Next_Widget_Id_Number --
   ---------------------------

   function Next_Widget_Id_Number (Id_Base : String)
                                   return Natural
   is
      use UStrings;
      use Php;
      use Php.Preg;

--    global wp_registered_widgets;
      Number : Natural := 1;
   begin
      for A in Wp_Registered_Widgets.Iterate loop
         declare
            Widget_Id : constant String := Key (A);
            Widget    : constant Multi_Type := Element (A);
            Matches   : List_Type;
         begin
            if
              Preg_Match ("/" & Preg_Quote (Id_Base, "/") & "-([0-9]+)/",
                          Widget_Id, Matches) /= 0
            then
               Number := Natural'Max (Number,
                                      Natural'Value (-Matches (1))); -- [1]
            end if;
         end;
      end loop;
      Number := Number + 1;

      return Number;
   end Next_Widget_Id_Number;

end Adi_Widgets;
