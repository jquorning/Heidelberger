--
-- Toolbar API: WP_Admin_Bar class
--
-- @package WordPress
-- @subpackage Toolbar
-- @since 3.1.0
--

with Php.Echoing;
with Php.Strings;
with Php.Types;

with Lists;

with Inc_Admin_Bar;
with Inc_Ms_Functions;
with Inc_Formatting;
with Inc_Functions;
with Inc_Functions_Wp_Styles;
with Inc_Functions_Wp_Scripts;
with Inc_L10n;
with Inc_Link_Templates;
with Inc_Load;
with Inc_Pluggables;
with Inc_Plugins;
with Inc_Themes;
with Inc_Users;
with Inc_Vars;

package body Class_Admin_Bar
is
   use Lists;

   -----------
   -- X_Get --
   -----------

   function X_Get (This : Wp_Admin_Bar;
                   Name : String)
                   return String
   is
      use Inc_Functions;
      use Inc_Load;
   begin
      if Name = "proto" then
         return (if Is_SSL
                 then "https://"
                 else "http://");

      elsif Name = "menu" then
         X_Deprecated_Argument
           ("WP_Admin_Bar", "3.3.0",
            "Modify admin bar nodes with WP_Admin_Bar::get_node(), WP_Admin_Bar::add_node(), and WP_Admin_Bar::remove_node(), not the <code>menu</code> property.");
         return "";  -- array(); -- Sorry, folks.
      end if;
      return "";
   end X_Get;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (This : in out Wp_Admin_Bar)
   is
      use UStrings;
      use Inc_Admin_Bar;
      use Class_Sites;
      use Inc_Ms_Functions;
      use Inc_Formatting;
      use Inc_Functions_Wp_Styles;
      use Inc_Functions_Wp_Scripts;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_Pluggables;
      use Inc_Plugins;
      use Inc_Themes;
      use Inc_Users;
   begin
--    this.User := new stdClass;

      if Is_User_Logged_In then
         -- Populate settings we need for the menu based on the current user.
         This.User.Blogs := Get_Blogs_Of_User (Get_Current_User_Id);
         if Is_Multisite then
            This.User.Active_Blog :=
              Get_Active_Blog_For_User (Get_Current_User_Id);

            This.User.Domain         :=
              +(if This.User.Active_Blog = Null_Site
                then User_Admin_URL
                else Trailing_Slash_It (
                        Get_Home_URL (-This.User.Active_Blog.Blog_Id)));

            This.User.Account_Domain := This.User.Domain;
         else
--          this.user.Active_Blog    := This.User.Blogs (Get_Current_Blog_Id);
            This.User.Domain         := +Trailing_Slash_It (Home_URL);
            This.User.Account_Domain := This.User.Domain;
         end if;
      end if;

      Add_Action ("wp_head",    Wp_Admin_Bar_Header'Access);
--    Add_Action ("admin_head", Wp_Admin_Bar_Header'Access);

      declare
         Admin_Bar_Args  : List_Type;
         Header_Callback : UString;
      begin
         if Current_Theme_Supports ("admin-bar") then
            --
            -- To remove the default padding styles from WordPress for the Toolbar,
            -- use the following code:
            -- add_theme_support( "admin-bar", array( "callback" => "__return_false"));
            --
            Admin_Bar_Args  := Get_Theme_Support ("admin-bar");
            Header_Callback := +"XXX-970";
            -- Get (-Admin_Bar_Args.First_Element, "callback");
         end if;

         if Header_Callback = "" then
            Header_Callback := +"_admin_bar_bump_cb";
         end if;

--       Add_Action ("wp_head", -Header_Callback);
      end;

      Wp_Enqueue_Script ("admin-bar");
      Wp_Enqueue_Style  ("admin-bar");

      --
      -- Fires after WP_Admin_Bar is initialized.
      --
      -- @since 3.1.0
      --
      Do_Action ("admin_bar_init");
   end Initialize;

   --------------
   -- Add_Menu --
   --------------

   procedure Add_Menu (This : in out Wp_Admin_Bar;
                       Node : Node_Args) -- Array_Type)
   is
   begin
      This.Add_Node (Node);
   end Add_Menu;

   -----------------
   -- Remove_Menu --
   -----------------

   procedure Remove_Menu (This : in out Wp_Admin_Bar;
                          Id   : String)
   is
   begin
      This.Remove_Node (Id);
   end Remove_Menu;

   --------------
   -- Add_Node --
   --------------

   procedure Add_Node (This : in out Wp_Admin_Bar;
                       Args : Node_Args) -- Array_Type)
   is
      use Php.Strings;
      use UStrings;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;

      Args_2 : Node_Args := Args;

      Defaults : Node_Args := -- Array_Type := To_Array ((
        (Id       => +"",   --              Build ("id",     "false"),
         Title    => +"",   --              Build ("title",  "false"),
         Parent   => +"",   --              Build ("parent", "false"),
         Href     => +"",   --              Build ("href",   "false"),
         Group    => False, --              Build ("group",  "false"),
         Meta     => Empty_Array, --        Build ("meta",   Empty_Array)
         Typ      => Typ_Item,
         Children => null);

   begin
      -- Shim for old method signature: add_node( parent_id, menu_obj, args).
      -- if Func_Num_Args >= 3 and then Is_String (Args) then
      --         args = array_merge( array( "parent" => args), func_get_arg( 2));
      -- end if;

      -- if Is_Object (Args)  then
      --         args = get_object_vars( args);
      -- end if;

      -- Ensure we have a valid title.
      if Args_2.Id = "" then -- Empty (Args ("id")) then
         if Args_2.Title = "" then -- Empty (Args ("title")) then
            return;
         end if;

         X_Doing_It_Wrong ("__METHOD__",
                           abs "The menu ID should not be empty.", "3.3.0");
         -- Deprecated: Generate an ID from the title.
         Args_2.Id := +ESC_Attr (Sanitize_Title (Trim (-Args_2.Title)));
      end if;

      -- If the node already exists, keep any data that isn"t provided.
      declare
         Maybe_Defaults : constant Node_Args := This.Get_Node (-Args_2.Id);
      begin
         if Maybe_Defaults /= Null_Node_Args then
            Defaults := Maybe_Defaults; -- Get_Object_Vars (Maybe_Defaults);
         end if;
      end;

      -- Do the same for "meta" items.
      if Defaults.Meta.Is_Empty and then Args_2.Meta.Is_Empty then
         Args_2.Meta := Wp_Parse_Args (Args_2.Meta, Defaults.Meta);
      end if;

      Args_2 := Node_Args'
        (Id       => (if Args_2.Id = Defaults.Id       then Defaults.Id    else Args_2.Id),
         Title    => (if Args_2.Title = Defaults.Title then Defaults.Title else Args_2.Title),
         Parent   => Defaults.Parent,   -- same here
         Href     => Defaults.Href,     --    "
         Group    => Defaults.Group,    --    "
         Meta     => Defaults.Meta,     --    "
         Typ      => Defaults.Typ,      --    "
         Children => Defaults.Children);

--    Args_2 := Wp_Parse_Args (Args_2, Defaults);

      declare
         Back_Compat_Parents : constant Array_Type := Arrays.To_Array ((
            Build ("my-account-with-avatar",
                   Arrays.To_Array ((1 => Build ("my-account", "3.3")))),
            Build ("my-blogs",
                   Arrays.To_Array ((1 => Build ("my-sites",   "3.3"))))
         ));
         New_Parent : UString;
         Version    : UString;
      begin
         if Isset (Back_Compat_Parents, -Args_2.Parent) then
--          New_Parent := Back_Compat_Parents (-Args_2.Parent) (New_Parent);
--          Version    := Back_Compat_Parents (-Args_2.Parent) (Version);

            X_Deprecated_Argument (
              "__METHOD__", -Version,
              Sprintf ("Use <code>%s</code> as the parent for the <code>%s</code> admin bar node instead of <code>%s</code>.",
                To_List (List => (1 => New_Parent,
                                  2 => Args_2.Id,
                                  3 => Args_2.Parent))));
            Args_2.Parent := New_Parent;
         end if;
      end;
      This.X_Set_Node (Args_2);
   end Add_Node;

   ----------------
   -- X_Set_Node --
   ----------------

   procedure X_Set_Node (This : in out Wp_Admin_Bar;
                         Args : Node_Args) -- Array_Type)
   is
      use UStrings;
   begin
      This.Nodes.Include (Key      => -Args.Id,
                          New_Item => Args); -- (object)
   end X_Set_Node;

   --------------
   -- Get_Node --
   --------------

   function Get_Node (This : Wp_Admin_Bar;
                      Id   : String)
                      return Node_Args -- Array_Type
   is
      Node : constant Node_Args := This.X_Get_Node (Id);
   begin
      if Node /= Null_Node_Args then
         return Node; -- clone
      end if;
      return Null_Node_Args;
   end Get_Node;

   ----------------
   -- X_Get_Node --
   ----------------

   function X_Get_Node (This : Wp_Admin_Bar;
                        Id   : String)
                        return Node_Args -- String
   is
      use UStrings;
      use Node_Maps;

      Id_2 : UString := +Id;
   begin
      if This.Bound then
         return Null_Node_Args;
      end if;

      if Id_2 = "" then
         Id_2 := +"root";
      end if;

      if Has_Element (This.Nodes.Find (-Id_2)) then
         return Element (This.Nodes.Find (-Id_2));
      end if;

      -- for A in This.Nodes.First_Index .. This.Nodes.Last_Index loop
      --    if Id_2 = -This.Nodes (A).Id then
      --       return This.Nodes (A);
      --    end if;
      -- end loop;

      return Null_Node_Args;
   end X_Get_Node;

   ---------------
   -- Get_Nodes --
   ---------------

   function Get_Nodes (This : Wp_Admin_Bar)
                       return Node_Array_Access -- Array_Type
   is
      Nodes : constant Node_Array_Access := This.X_Get_Nodes;
   begin
      if Nodes.Is_Empty then
         return null; -- Empty_Node_Map; -- Empty_Array;
      end if;

      for Node of Nodes.all loop --  &node
         null; -- Node := Node;  -- clone
      end loop;
      return Nodes;
   end Get_Nodes;

   -----------------
   -- X_Get_Nodes --
   -----------------

   function X_Get_Nodes (This : Wp_Admin_Bar)
                         return Node_Array_Access
   is
   begin
      if This.Bound then
         return null; -- Empty_Node_Map; -- Empty_Array;
      end if;

      return This.Nodes;
   end X_Get_Nodes;

   ---------------
   -- Add_Group --
   ---------------

   procedure Add_Group (This : in out Wp_Admin_Bar;
                        Args : Node_Args)
   is
      Args_2 : Node_Args := Args;
   begin
      Args_2.Group := True;

      This.Add_Node (Args_2);
   end Add_Group;

   -----------------
   -- Remove_Node --
   -----------------

   procedure Remove_Node (This : in out Wp_Admin_Bar;
                          Id   : String)
   is
   begin
      This.X_Unset_Node (Id);
   end Remove_Node;

   ------------------
   -- X_Unset_Node --
   ------------------

   procedure X_Unset_Node (This : in out Wp_Admin_Bar;
                           Id   : String)
   is
   begin
      if Node_Maps.Has_Element (This.Nodes.Find (Id)) then
         This.Nodes.Delete (Id);
      end if;
   end X_Unset_Node;

   ------------
   -- Render --
   ------------

   procedure Render (This : in out Wp_Admin_Bar)
   is
      Root : constant Node_Args := This.X_Bind;
   begin
      if Root /= Null_Node_Args then
         This.X_Render (Root);
      end if;
   end Render;

   ------------
   -- X_Bind --
   ------------

   function X_Bind (This : in out Wp_Admin_Bar)
            return Node_Args
   is
      use UStrings;

      Parent : Node_Args;
   begin
      if This.Bound then
         return Null_Node_Args;
      end if;

      -- Add the root node.
      -- Clear it first, just in case. Don"t mess with The Root.
      This.Remove_Node ("root");
      declare
         N : Node_Args := Null_Node_Args;
      begin
         N.Id    := +"root";
         N.Group := False;

         This.Add_Node (N);
      end;
      -- This.Add_Node (
      --    To_Array ((
      --       Build ("id",    "root"),
      --       Build ("group", "false")
      --    ))
      -- );

      -- Normalize nodes: define internal "children" and "type" properties.
      for Node of This.X_Get_Nodes.all loop
         Node.Children := null;
         Node.Typ      := (if Node.Group then Typ_Group else Typ_Item);
--       Unset (Node.Group);

         -- The Root wants your orphans. No lonely items allowed.
         if Node.Parent = "" then
            Node.Parent := +"root";
         end if;
      end loop;

      for Node of This.X_Get_Nodes.all loop
         if "root" = Node.Id then
            goto Continue;
         end if;

         -- Fetch the parent node. If it isn"t registered, ignore the node.
         Parent := This.X_Get_Node (-Node.Parent);
         if Parent = Null_Node_Args then
            goto Continue;
         end if;

         -- Generate the group class (we distinguish between top level and other
         -- level groups).
         declare
            Group_Class : String := (if "root" = Node.Parent
                                     then "ab-top-menu" else "ab-submenu");
         begin
            if Typ_Group = Node.Typ then
               if Empty (Node.Meta, "class") then
                  Set (Node.Meta, "class", From_String (Group_Class));
               else
                  Set (Node.Meta, "class",
                       From_String (
                         As_String (Get (Node.Meta, "class")) & " " & Group_Class));
               end if;
            end if;

            -- Items in items aren"t allowed. Wrap nested items in "default" groups.
            if Typ_Item = Parent.Typ and then Typ_Item = Node.Typ then
               declare
                  Default_Id : constant String    := -(Parent.Id & "-default");
                  Default    : Node_Args := This.X_Get_Node (Default_Id);
               begin
                  -- The default group is added here to allow groups that are
                  -- added before standard menu items to render first.
                  if Default = Null_Node_Args then
                     -- Use _set_node because add_node can be overloaded.
                     -- Make sure to specify default settings for all properties.
                     This.X_Set_Node (
                        Node_Args'(
                           Id       =>  +Default_Id,
                           Parent   =>  Parent.Id,
                           Typ      =>  Typ_Group,
                           Children =>  null,
                           Meta     =>  Arrays.To_Array ((
                                 1 => Build ("class", Group_Class)
                              )),
                           Title    => +"",
                           Href     => +"",
                           Group    => False
                        ));
                        -- To_Array ((
                        --    Build ("id",       Default_Id),
                        --    Build ("parent",   parent.Id),
                        --    Build ("type",     "group"),
                        --    Build ("children", Empty_Array),
                        --    Build ("meta",     To_Array ((
                        --          1 => Build ("class", Group_Class))
                        --       )),
                        --    Build ("title",    "false"),
                        --    Build ("href",     "false")
                        -- ))

                     Default := This.X_Get_Node (Default_Id);
                     Parent.Children.Include (Key      => "XXX-989",
                                              New_Item => Default);
                     -- .Append (Default); -- ()
                  end if;
                  Parent := Default;
               end;

            -- Groups in groups aren"t allowed. Add a special "container" node.
            -- The container will invisibly wrap both groups.
            elsif Typ_Group = Parent.Typ and then Typ_Group = Node.Typ then
               declare
                  Container_Id : constant String := -Parent.Id & "-container";
                  Container    : Node_Args := This.X_Get_Node (Container_Id);
               begin
                  -- We need to create a container for this group, life is sad.
                  if Container = Null_Node_Args then
                     -- Use _set_node because add_node can be overloaded.
                     -- Make sure to specify default settings for all properties.
                     declare
                        V : Node_Array; -- := To_Vector (Parent, Length => 1);
                     begin
                        V.Include (Key => "XXX-988", New_Item => Parent);
                        This.X_Set_Node (
                           Node_Args'(
                              Id       =>  +Container_Id,
                              Typ      =>  Typ_Container,
                              Children =>  new Node_Array'(V),
--                            Children =>  To_Array (Parent),
                              Parent   =>  +"",
                              Title    =>  +"",
                              Href     =>  +"",
                              Meta     =>  Empty_Array,
                              Group    =>  False
                           ));
                     end;
                     Container := This.X_Get_Node (Container_Id);

                     -- Link the container node if a grandparent node exists.
                     declare
                        Grandparent : constant Node_Args :=
                           This.X_Get_Node (-Parent.Parent);

                        Index : Node_Maps.Cursor := Node_Maps.No_Element;
--                      Index : Integer := 0;
                     begin
                        if Grandparent /= Null_Node_Args then
                           Container.Parent := Grandparent.Id;

--                         Index :=
--                           Array_Search (Parent, Grandparent.Children.all, True);

                           for A in Grandparent.Children.Iterate loop
                              if
                                Parent.Id =
                                Grandparent.Children (Node_Maps.Key (A)).Id
                              then
                                 Index := A;
                                 exit;
                              end if;
                           end loop;

                           if Node_Maps.Has_Element (Index) then
--                         if Index = 0 then
                              Grandparent.Children.Include (Key      => "XXX-987",
                                                            New_Item => Container);
                           else
                              Grandparent.Children.Replace_Element (Index, Container);
                           end if;
                           -- Index := Array_Search (Parent,
                           --                        Grandparent.Children, True);
                           -- if Index = 0 then
                           --    Grandparent.Children.Append (Container); -- ()
                           -- else
                           --    Array_Splice (Grandparent.Children, Index, 1,
                           --                  To_Array (Container));
                           -- end if;
                        end if;
                     end;

                     Parent.Parent := Container.Id;
                  end if;
                  Parent := Container;
               end;
            end if;

            -- Update the parent ID (it might have changed).
            Node.Parent := Parent.Id;

            -- Add the node to the tree.
--          Parent.Children.Append (Node);
            Parent.Children.Include (Key      => "XXX-986",
                                     New_Item => Node);
         end;
         << Continue >>
      end loop;

      This.Bound := True;
      return This.X_Get_Node ("root");
   end X_Bind;

   --------------
   -- X_Render --
   --------------

   procedure X_Render (This : Wp_Admin_Bar;
                       Root : Node_Args) -- Array_Type)
   is
      use UStrings;

      Class : UString := +"nojq nojs";
   begin
      -- Add browser classes.
      -- We have to do this here since admin bar shows on the front end.
      if Inc_Vars.Wp_Is_Mobile then
         Class := Class & " mobile";
      end if;
           -- ?>
           -- <div id="wpadminbar" class="<?php echo class; ?>">
           --         <?php if (! is_admin() && ! did_action("wp_body_open")) then ?>
           --                 <a class="screen-reader-shortcut" href="#wp-toolbar" tabindex="1"><?php _e("Skip to toolbar"); ?></a>
           --         <?php end; ?>
           --         <div class="quicklinks" id="wp-toolbar" role="navigation" aria-label="<?php esc_attr_e("Toolbar"); ?>">
           --                 <?php
         for Group of Root.Children.all loop
            This.X_Render_Group (Group);
         end loop;
           --                 ?>
           --         </div>
           --         <?php if (is_user_logged_in()) : ?>
           --         <a class="screen-reader-shortcut" href="<?php echo esc_url(wp_logout_url()); ?>"><?php _e("Log Out"); ?></a>
           --         <?php endif; ?>
           -- </div>
           -- <?php
   end X_Render;

   ------------------------
   -- X_Render_Container --
   ------------------------

   procedure X_Render_Container (This : Wp_Admin_Bar;
                                 Node : Node_Args) -- Array_Type)
   is
      use Php.Echoing;
      use UStrings;
      use Inc_Formatting;
   begin
      if Typ_Container /= Node.Typ or else Node.Children = null then
         return;
      end if;

      Echo ("<div id=""" & ESC_Attr ("wp-admin-bar-" & (-Node.Id)) &
            """ class=""ab-group-container"">");

      for Group of Node.Children.all loop
         This.X_Render_Group (Group);
      end loop;

      Echo ("</div>");
   end X_Render_Container;

   --------------------
   -- X_Render_Group --
   --------------------

   procedure X_Render_Group (This : Wp_Admin_Bar;
                             Node : Node_Args) -- Array_Type)
   is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Inc_Formatting;

      Class : UString;
   begin
      if Typ_Container = Node.Typ then
         This.X_Render_Container (Node);
         return;
      end if;

      if Typ_Group /= Node.Typ or else Node.Children = null then
         return;
      end if;

      if not Empty (Node.Meta, "class") then
         Class :=
           +" class=""" &
           ESC_Attr (Trim (As_String (Get (Node.Meta, "class")))) &
           """";
      else
         Class := +"";
      end if;

      Echo ("<ul id=""" &
            ESC_Attr ("wp-admin-bar-" &
            (-Node.Id)) & "" &
            (-Class) & ">");

      for Item of Node.Children.all loop
         This.X_Render_Item (Item);
      end loop;
      Echo ("</ul>");
   end X_Render_Group;

   -------------------
   -- X_Render_Item --
   -------------------

   procedure X_Render_Item (This : Wp_Admin_Bar;
                            Node : Node_Args) -- Array_Type)
   is
      use Php.Echoing;
      use Php.Strings;
      use Php.Types;
      use UStrings;
      use Inc_Formatting;

      Is_Parent             : constant Boolean := Node.Children /= null;
      Has_Link              : constant Boolean := Node.Href /= "";
      Is_Root_Top_Item      : constant Boolean := "root-default"  = Node.Parent;
      Is_Top_Secondary_Item : constant Boolean := "top-secondary" = Node.Parent;

      -- Allow only numeric values, then casted to integers, and allow a tabindex
      -- value of `0` for a11y.
      Tabindex : constant Integer := (if
                               Isset (Node.Meta, "tabindex") and then
                               Is_Numeric (As_String (Get (Node.Meta, "tabindex")))
                             then Integer'Value (As_String (Get (Node.Meta, "tabindex"))) else 0);

      Aria_Attributes : UString :=
         +(if 0 /= Tabindex
           then " tabindex=""" & Tabindex'Image & """" else "");

      Menuclass : UString;
      Arrow     : UString;

      Attributes : List_Type;
   begin
      if Typ_Item /= Node.Typ then
         return;
      end if;

      if Is_Parent then
         Menuclass        := +"menupop ";
         Aria_Attributes  := Aria_Attributes & " aria-haspopup=""true""";
      end if;

      if not Empty (Node.Meta, "class") then
         Menuclass := Menuclass & As_String (Get (Node.Meta, "class"));
      end if;

      -- Print the arrow icon for the menu children with children.
      if
        not Is_Root_Top_Item and then
        not Is_Top_Secondary_Item and then
        Is_Parent
      then
         Arrow := +"<span class=""wp-admin-bar-arrow"" aria-hidden=""true""></span>";
      end if;

      if Menuclass /= "" then
         Menuclass := +" class=""" & ESC_Attr (Trim (-Menuclass)) & """";
      end if;

      Echo ("<li id=""" & ESC_Attr ("wp-admin-bar-" & (-Node.Id)) & """menuclass>");

      if Has_Link then
         Attributes := To_List (List => (+"onclick", +"target", +"title",
                                         +"rel", +"lang", +"dir"));
         Echo ("<a class=""ab-item""aria_attributes href=""" & ESC_URL (-Node.Href) &
               """");
      else
         Attributes := To_List (List => (+"onclick", +"target", +"title",
                                         +"rel", +"lang", +"dir"));
         Echo ("<div class=""ab-item ab-empty-item""" & (-Aria_Attributes));
      end if;

      for Attribute of Attributes loop
         if Empty (Node.Meta, Attribute) then
            goto Continue_2;
         end if;

         if "onclick" = Attribute then
            Echo (" attribute=""" & ESC_JS (As_String (Get (Node.Meta, Attribute))) & """");
         else
            Echo (" attribute=""" & ESC_Attr (As_String (Get (Node.Meta, Attribute))) & """");
         end if;
         << Continue_2 >>
      end loop;

      Echo (">" & (-Arrow) & (-Node.Title));

      if Has_Link then
         Echo ("</a>");
      else
         Echo ("</div>");
      end if;

      if Is_Parent then
         Echo ("<div class=""ab-sub-wrapper"">");
         for Group of Node.Children.all loop
            This.X_Render_Group (Group);
         end loop;
         Echo ("</div>");
      end if;

      if not Empty (Node.Meta, "html") then
         Echo (As_String (Get (Node.Meta, "html")));
      end if;

      Echo ("</li>");
   end X_Render_Item;

   ----------------------
   -- Recursive_Render --
   ----------------------

   procedure Recursive_Render (This : Wp_Admin_Bar;
                               Id   : String;
                               Node : Node_Args) -- Array_Type)
   is
      use Inc_Functions;
   begin
      X_Deprecated_Function
        ("__METHOD__", "3.3.0",
         "WP_Admin_bar::render(), WP_Admin_Bar::_render_item()");
      This.X_Render_Item (Node);
   end Recursive_Render;

   ---------------
   -- Add_Menus --
   ---------------

   procedure Add_Menus (This : Wp_Admin_Bar)
   is
--    use Inc_Admin_Bar;
      use Inc_Load;
      use Inc_Plugins;
   begin
      -- User-related, aligned right.
--    Add_Action ("admin_bar_menu", Wp_Admin_Bar_My_Account_Menu'Access, 0);
--    Add_Action ("admin_bar_menu", Wp_Admin_Bar_Search_Menu'Access, 4);
--    Add_Action ("admin_bar_menu", Wp_Admin_Bar_My_Account_Item'Access, 7);
--    Add_Action ("admin_bar_menu", Wp_Admin_Bar_Recovery_Mode_Menu'Access, 8);

      -- Site-related.
--    Add_Action ("admin_bar_menu", Wp_Admin_Bar_Sidebar_Toggle'Access, 0);
--    Add_Action ("admin_bar_menu", Wp_Admin_Bar_Wp_Menu'Access, 10);
--    Add_Action ("admin_bar_menu", Wp_Admin_Bar_My_Sites_Menu'Access, 20);
--    Add_Action ("admin_bar_menu", Wp_Admin_Bar_Site_Menu'Access, 30);
--    Add_Action ("admin_bar_menu", Wp_Admin_Bar_Edit_Site_Menu'Access, 40);
--    Add_Action ("admin_bar_menu", Wp_Admin_Bar_Customize_Menu'Access, 40);
--    Add_Action ("admin_bar_menu", Wp_Admin_Bar_Updates_Menu'Access, 50);

      -- Content-related.
      if not Is_Network_Admin and then not Is_User_Admin then
--       Add_Action ("admin_bar_menu", Wp_Admin_Bar_Comments_Menu'Access, 60);
--       Add_Action ("admin_bar_menu", Wp_Admin_Bar_New_Content_Menu'Access, 70);
         null;
      end if;
--    Add_Action ("admin_bar_menu", Wp_Admin_Bar_Edit_Menu'Access, 80);

--    Add_Action ("admin_bar_menu", Wp_Admin_Bar_Add_Secondary_Groups'Access, 200);

      --
      -- Fires after menus are added to the menu bar.
      --
      -- @since 3.1.0
      --
      Do_Action ("add_admin_bar_menus");
   end Add_Menus;

end Class_Admin_Bar;
