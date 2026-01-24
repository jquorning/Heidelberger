--
-- Toolbar API: WP_Admin_Bar class
--
-- @package WordPress
-- @subpackage Toolbar
-- @since 3.1.0
--

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

with Arrays;

with Class_Sites;

package Class_Admin_Bar
is
   use Ada.Strings.Unbounded;
   use Arrays;

   ---------------
   -- Blog_Type --
   ---------------

   type Blog_Type is
      record
         Userblog_Id : Integer;
         Blogname    : Unbounded_String;
      end record;

   ---------------
   -- Blog_List --
   ---------------

   package Blog_Vectors is new
      Ada.Containers.Vectors (Index_Type   => Positive,
                              Element_Type => Blog_Type);

   subtype Blog_List is Blog_Vectors.Vector;
   Empty_Blog_List : constant Blog_List := Blog_Vectors.Empty_Vector;

   ---------------
   -- User_Type --
   ---------------

   type User_Type is
      record
         Blogs          : Blog_List;
         Active_Blog    : Class_Sites.Wp_Site;
         Domain         : Unbounded_String;
         Account_Domain : Unbounded_String;
      end record;

   type Typ_Type is (Typ_Item, Typ_Group, Typ_Container);

   type Node_Array;
   type Node_Array_Access is access all Node_Array;

   ---------------
   -- Node_Args --
   ---------------

   type Node_Args is
      record
         Id     : Unbounded_String;
         --  ID of the item.

         Title  : Unbounded_String;
         --  Title of the node.

         Parent : Unbounded_String;
         --  Optional. ID of the parent node.

         Href   : Unbounded_String;
         --  Optional. Link for the item.

         Group  : Boolean;
         --  Optional. Whether or not the node is a group.
         --  Default false.

         Meta   : Array_Type;
         --  Meta data including the following keys:
         --  "html", "class", "rel", "lang", "dir",
         --  "onclick", "target", "title", "tabindex".
         --   Default empty.

         Typ      : Typ_Type;
         Children : Node_Array_Access;
      end record;

   Null_Node_Args : constant Node_Args :=
     (Group    => False,
      Meta     => Empty_Array,
      Typ      => Typ_Item,
      Children => null,
      others   => Ada.Strings.Unbounded.Null_Unbounded_String);

   ----------------
   -- Node_Array --
   ----------------

   package Node_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps
        (Key_Type     => String,
         Element_Type => Node_Args);

   type Node_Array is new Node_Maps.Map with null record;

   --
   -- Core class used to implement the Toolbar API.
   --
   -- @since 3.1.0
   --
   --#[AllowDynamicProperties]

   type Wp_Admin_Bar is tagged
      record
         -- private
         Nodes : Node_Array_Access :=
           new Node_Array'(Node_Maps.Empty_Map with null record);

         -- private
         Bound : Boolean := False;

         User : User_Type;
      end record;

   --
   -- @since 3.3.0
   --
   -- @param string name
   -- @return string|array|void
   --
   function X_Get (This : Wp_Admin_Bar;
                   Name : String)
                   return String;

   --
   -- Initializes the admin bar.
   --
   -- @since 3.1.0
   --
   procedure Initialize (This : in out Wp_Admin_Bar);

   --
   -- Adds a node (menu item) to the admin bar menu.
   --
   -- @since 3.3.0
   --
   -- @param array node The attributes that define the node.
   --
   procedure Add_Menu (This : in out Wp_Admin_Bar;
                       Node : Node_Args); -- Array_Type);

   --
   -- Removes a node from the admin bar.
   --
   -- @since 3.1.0
   --
   -- @param string id The menu slug to remove.
   --
   procedure Remove_Menu (This : in out Wp_Admin_Bar;
                          Id   : String);

   --
   -- Adds a node to the menu.
   --
   -- @since 3.1.0
   -- @since 4.5.0 Added the ability to pass "lang" and "dir" meta data.
   --
   -- @param array args {
   --     Arguments for adding a node.
   --
   --     @type string id     ID of the item.
   --     @type string title  Title of the node.
   --     @type string parent Optional. ID of the parent node.
   --     @type string href   Optional. Link for the item.
   --     @type bool   group  Optional. Whether or not the node is a group. Default
   --                          false.
   --     @type array  meta   Meta data including the following keys: "html",
   --                          "class", "rel", "lang", "dir", "onclick", "target",
   --                          "title", "tabindex". Default empty.
   -- }
   --
   procedure Add_Node (This : in out Wp_Admin_Bar;
                       Args : Node_Args); -- Array_Type);

   --
   -- @since 3.3.0
   --
   -- @param array args
   --
   -- final protected
   procedure X_Set_Node (This : in out Wp_Admin_Bar;
                         Args : Node_Args); -- Array_Type);

   --
   -- Gets a node.
   --
   -- @since 3.3.0
   --
   -- @param string id
   -- @return object|void Node.
   --
   -- final public
   function Get_Node (This : Wp_Admin_Bar;
                      Id   : String)
                      return Node_Args; -- Array_Type;

   --
   -- @since 3.3.0
   --
   -- @param string id
   -- @return object|void
   --
   -- final protected
   function X_Get_Node (This : Wp_Admin_Bar;
                        Id   : String)
                        return Node_Args; -- String;

   --
   -- @since 3.3.0
   --
   -- @return array|void
   --
   -- final public
   function Get_Nodes (This : Wp_Admin_Bar)
                       return Node_Array_Access; -- Array_Type;

   --
   -- @since 3.3.0
   --
   -- @return array|void
   --
   -- final protected
   function X_Get_Nodes (This : Wp_Admin_Bar)
                         return Node_Array_Access; -- Array_Type;

   --
   -- Adds a group to a toolbar menu node.
   --
   -- Groups can be used to organize toolbar items into distinct sections of a
   -- toolbar menu.
   --
   -- @since 3.3.0
   --
   -- @param array args {
   --     Array of arguments for adding a group.
   --
   --     @type string id     ID of the item.
   --     @type string parent Optional. ID of the parent node. Default "root".
   --     @type array  meta   Meta data for the group including the following keys:
   --                         "class", "onclick", "target", and "title".
   -- }
   --
   -- final public
   procedure Add_Group (This : in out Wp_Admin_Bar;
                        Args : Node_Args); -- Array_Type);

   --
   -- Remove a node.
   --
   -- @since 3.1.0
   --
   -- @param string id The ID of the item.
   --
   procedure Remove_Node (This : in out Wp_Admin_Bar;
                          Id   : String);

   --
   -- @since 3.3.0
   --
   -- @param string id
   --
   -- final protected
   procedure X_Unset_Node (This : in out Wp_Admin_Bar;
                           Id   : String);

   --
   -- @since 3.1.0
   --
   procedure Render (This : in out Wp_Admin_Bar);

   --
   -- @since 3.3.0
   --
   -- @return object|void
   --
   -- final protected
   function X_Bind (This : in out Wp_Admin_Bar)
            return Node_Args; -- Array_Type;

   --
   -- @since 3.3.0
   --
   -- @param object root
   --
   -- final protected
   procedure X_Render (This : Wp_Admin_Bar;
                       Root : Node_Args); -- Array_Type);

   --
   -- @since 3.3.0
   --
   -- @param object node
   --
   -- final protected
   procedure X_Render_Container (This : Wp_Admin_Bar;
                                 Node : Node_Args); -- Array_Type);

   --
   -- @since 3.3.0
   --
   -- @param object node
   --
   -- final protected
   procedure X_Render_Group (This : Wp_Admin_Bar;
                             Node : Node_Args); -- Array_Type);

   --
   -- @since 3.3.0
   --
   -- @param object node
   --
   -- final protected
   procedure X_Render_Item (This : Wp_Admin_Bar;
                            Node : Node_Args); -- Array_Type);

   --
   -- Renders toolbar items recursively.
   --
   -- @since 3.1.0
   -- @deprecated 3.3.0 Use WP_Admin_Bar::_render_item() or WP_Admin_bar::render() instead.
   -- @see WP_Admin_Bar::_render_item()
   -- @see WP_Admin_Bar::render()
   --
   -- @param string id    Unused.
   -- @param object node
   --
   procedure Recursive_Render (This : Wp_Admin_Bar;
                               Id   : String;
                               Node : Node_Args); -- Array_Type);

   --
   -- Adds menus to the admin bar.
   --
   -- @since 3.1.0
   --
   procedure Add_Menus (This : Wp_Admin_Bar);

end Class_Admin_Bar;
