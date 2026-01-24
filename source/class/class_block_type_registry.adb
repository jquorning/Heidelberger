--
-- Blocks API: WP_Block_Type_Registry class
--
-- @package WordPress
-- @subpackage Blocks
-- @since 5.0.0
--

package body Class_Block_Type_Registry
is

--         --
--         -- Registers a block type.
--         --
--         -- @since 5.0.0
--         --
--         -- @see WP_Block_Type::__construct()
--         --
--         -- @param string|WP_Block_Type $name Block type name including namespace, or alternatively
--         --                                   a complete WP_Block_Type instance. In case a WP_Block_Type
--         --                                   is provided, the $args parameter will be ignored.
--         -- @param array                $args Optional. Array of block type arguments. Accepts any public property
--         --                                   of `WP_Block_Type`. See WP_Block_Type::__construct() for information
--         --                                   on accepted arguments. Default empty array.
--         -- @return WP_Block_Type|false The registered block type on success, or false on failure.
--         --
--         public function register( $name, $args = array() ) then
--                 $block_type = null;
--                 if ( $name instanceof WP_Block_Type ) then
--                         $block_type = $name;
--                         $name       = $block_type->name;
--                 end;

--                 if ( ! is_string( $name ) ) then
--                         _doing_it_wrong(
--                                 __METHOD__,
--                                 __( 'Block type names must be strings.' ),
--                                 '5.0.0'
--                         );
--                         return false;
--                 end;

--                 if ( preg_match( '/[A-Z]+/', $name ) ) then
--                         _doing_it_wrong(
--                                 __METHOD__,
--                                 __( 'Block type names must not contain uppercase characters.' ),
--                                 '5.0.0'
--                         );
--                         return false;
--                 end;

--                 $name_matcher = '/^[a-z0-9-]+\/[a-z0-9-]+$/';
--                 if ( ! preg_match( $name_matcher, $name ) ) then
--                         _doing_it_wrong(
--                                 __METHOD__,
--                                 __( 'Block type names must contain a namespace prefix. Example: my-plugin/my-custom-block-type' ),
--                                 '5.0.0'
--                         );
--                         return false;
--                 end;

--                 if ( $this->is_registered( $name ) ) then
--                         _doing_it_wrong(
--                                 __METHOD__,
--                                 /* translators: %s: Block name.--
--                                 sprintf( __( 'Block type "%s" is already registered.' ), $name ),
--                                 '5.0.0'
--                         );
--                         return false;
--                 end;

--                 if ( ! $block_type ) then
--                         $block_type = new WP_Block_Type( $name, $args );
--                 end;

--                 $this->registered_block_types[ $name ] = $block_type;

--                 return $block_type;
--         end;

--         --
--         -- Unregisters a block type.
--         --
--         -- @since 5.0.0
--         --
--         -- @param string|WP_Block_Type $name Block type name including namespace, or alternatively
--         --                                   a complete WP_Block_Type instance.
--         -- @return WP_Block_Type|false The unregistered block type on success, or false on failure.
--         --
--         public function unregister( $name ) then
--                 if ( $name instanceof WP_Block_Type ) then
--                         $name = $name->name;
--                 end;

--                 if ( ! $this->is_registered( $name ) ) then
--                         _doing_it_wrong(
--                                 __METHOD__,
--                                 /* translators: %s: Block name.--
--                                 sprintf( __( 'Block type "%s" is not registered.' ), $name ),
--                                 '5.0.0'
--                         );
--                         return false;
--                 end;

--                 $unregistered_block_type = $this->registered_block_types[ $name ];
--                 unset( $this->registered_block_types[ $name ] );

--                 return $unregistered_block_type;
--         end;

   --------------------
   -- Get_Registered --
   --------------------

   function Get_Registered (This : Wp_Block_Type_Registry;
                            Name : String)
                            return Class_Block_Type.Wp_Block_Type
   is
      use Class_Block_Type;
   begin
      if not This.Is_Registered (Name) then
         return Null_Wp_Block_Type; -- null
      end if;

      return This.Registered_Block_Types (Name);
   end Get_Registered;

   ------------------------
   -- Get_All_Registered --
   ------------------------

   function Get_All_Registered (This : Wp_Block_Type_Registry)
            return Block_Type_Maps.Map -- Array_Type
   is
   begin
      return This.Registered_Block_Types;
   end Get_All_Registered;

   -------------------
   -- Is_Registered --
   -------------------

   function Is_Registered (This : Wp_Block_Type_Registry;
                           Name : String)
                           return Boolean
   is
   begin
      return Block_Type_Maps.Has_Element (This.Registered_Block_Types.Find (Name));
--    return Isset (This.Registered_Block_Types, Name);
   end Is_Registered;

--         public function __wakeup() then
--                 if ( ! $this->registered_block_types ) then
--                         return;
--                 end;
--                 if ( ! is_array( $this->registered_block_types ) ) then
--                         throw new UnexpectedValueException();
--                 end;
--                 foreach ( $this->registered_block_types as $value ) then
--                         if ( ! $value instanceof WP_Block_Type ) then
--                                 throw new UnexpectedValueException();
--                         end;
--                 end;
--         end;

   ------------------
   -- Get_Instance --
   ------------------

   function Get_Instance
            return Wp_Block_Type_Registry
   is
      S : Wp_Block_Type_Registry;
   begin
      if Null_Wp_Block_Type_Registry = Static_Instance then -- null
         Static_Instance := S; -- new self();
      end if;

      return Static_Instance;
   end Get_Instance;

   --------------
   -- From_Map --
   --------------

   function From_Map (Map : Block_Type_Maps.Map)
                      return Array_Type
   is
   begin
      raise Program_Error with "not implemented";
      return Empty_Array;
   end From_Map;

end Class_Block_Type_Registry;
