--
-- User API: WP_Roles class
--
-- @package WordPress
-- @subpackage Users
-- @since 4.4.0
--

with Php.Arrays;

with Globals;
with Hb_Common;

with Inc_Load;
with Inc_Ms_Blogs;
with Inc_Options;
with Inc_Plugins;

package body Inc_Class_Wp_Roles
is
   Global_Wp_User_Roles : Array_Type;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Site_Id : Integer := 0)
                         return Wp_Roles
   is
--    use Hb_Common;

      This : Wp_Roles;
   begin
      This.Use_DB := Global_Wp_User_Roles.Is_Empty;

      This.For_Site (Site_Id);

      return This;
   end X_Construct;

   --------------
   -- Get_Role --
   --------------

   function Get_Role (This : Wp_Roles;
                      Role : String)
                      return Inc_Class_Wp_Role.Wp_Role
   is
--    use Hb_Common;
      use Inc_Class_Wp_Role;
      use Inc_Class_Wp_Roles.Role_Maps;
   begin
      if Has_Element (This.Role_Objects.Find (Role)) then
--    if Isset (This.Role_Objects, Role) then
         return This.Role_Objects (Role);
      else
         return Null_Role;
      end if;
   end Get_Role;

   ----------------
   -- Init_Roles --
   ----------------

   procedure Init_Roles (This : in out Wp_Roles)
   is
      use Hb_Common;
      use Php;
      use Php.Arrays;
      use Inc_Class_Wp_Role;
      use Inc_Plugins;
   begin
      if This.Roles.Is_Empty then
         return;
      end if;

      This.Role_Objects := Role_Maps.Empty_Map; -- Empty_Array;
      This.Role_Names   := Empty_List;

      for Role_2 of List_Type'(Array_Keys (This.Roles)) loop
         declare
            Role : constant String := -Role_2;
         begin
            This.Role_Objects (Role) :=
              Wp_Role'(X_Construct (Role, As_Array (Get (
                                    Ref_2 (This.Roles, Role, "capabilities")))));

--          This.Role_Names.Append (+Role,
--            Get (Ref_2 (This.Roles, Role, "name")));
         end;
      end loop;

      --
      -- Fires after the roles have been initialized, allowing plugins to add their
      -- own roles.
      --
      -- @since 4.7.0
      --
      -- @param WP_Roles wp_roles A reference to the WP_Roles object.
      --
      Do_Action ("wp_roles_init", This);
   end Init_Roles;

   --------------
   -- For_Site --
   --------------

   procedure For_Site (This    : in out Wp_Roles;
                       Site_Id : Integer := 0)
   is
      use Hb_Common;
      use Inc_Load;
--    global wpdb;
   begin
      if Site_Id /= 0 then
--    if not Empty (Site_Id) then
         This.Site_Id := Site_Id; -- abs
      else
         This.Site_Id := Get_Current_Blog_Id;
      end if;

      This.Role_Key :=
        +Globals.WpDB.Get_Blog_Prefix (This.Site_Id) & "user_roles";

      if
        not This.Roles.Is_Empty and then -- not Empty (This.Roles) and then
        not This.Use_DB
      then
         return;
      end if;

      This.Roles := This.Get_Roles_Data; -- ()

      This.Init_Roles; -- ();
   end For_Site;

   --------------------
   -- Get_Roles_Data --
   --------------------

   function Get_Roles_Data (This : Wp_Roles)
                            return Array_Type
   is
      use Hb_Common;
      use Inc_Load;
      use Inc_Ms_Blogs;
      use Inc_Options;
--    use Inc_Plugins;
   begin
      if not Global_Wp_User_Roles.Is_Empty then
         return Global_Wp_User_Roles;
      end if;

      if Is_Multisite and then Get_Current_Blog_Id /= This.Site_Id then
--       Remove_Action ("switch_blog", Wp_Switch_Roles_And_User'Access, 1);
         declare
            Roles : constant Array_Type :=
              Get_Blog_Option (This.Site_Id, -This.Role_Key, Empty_Array);
         begin
--          Add_Action ("switch_blog", Wp_Switch_Roles_And_User'Access, 1, 2);

            return Roles;
         end;
      end if;

      return Get_Option (-This.Role_Key, Empty_Array);
   end Get_Roles_Data;

end Inc_Class_Wp_Roles;
