--
-- Blocks API: WP_Block_Type_Registry class
--
-- @package WordPress
-- @subpackage Blocks
-- @since 5.0.0
--

with Ada.Containers.Indefinite_Ordered_Maps;

with Arrays;

with Class_Block_Type;

package Class_Block_Type_Registry
is
   use Arrays;

   package Block_Type_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps
        (Key_Type     => String,
         Element_Type => Class_Block_Type.Wp_Block_Type,
         "="          => Class_Block_Type."="); -- Array_Type);

   --
   -- Core class used for interacting with block types.
   --
   -- @since 5.0.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Block_Type_Registry is tagged
      record
         --
         -- Registered block types, as `$name => $instance` pairs.
         --
         -- @since 5.0.0
         -- @var WP_Block_Type[]
         --
         -- private
         Registered_Block_Types : Block_Type_Maps.Map; -- Array_Type;

      end record;

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

   --
   -- Retrieves a registered block type.
   --
   -- @since 5.0.0
   --
   -- @param string $name Block type name including namespace.
   -- @return WP_Block_Type|null The registered block type, or null if it is not
   --                             registered.
   --
   function Get_Registered (This : Wp_Block_Type_Registry;
                            Name : String)
                            return Class_Block_Type.Wp_Block_Type;
--                 if ( ! $this->is_registered( $name ) ) then
--                         return null;
--                 end;

--                 return $this->registered_block_types[ $name ];
--         end;

   --
   -- Retrieves all registered block types.
   --
   -- @since 5.0.0
   --
   -- @return WP_Block_Type[] Associative array of `$block_type_name => $block_type`
   --                          pairs.
   --
   function Get_All_Registered (This : Wp_Block_Type_Registry)
            return Block_Type_Maps.Map; -- Wp_Block_Type_Array; -- Array_Type
--                 return $this->registered_block_types;
--         end;

   --
   -- Checks if a block type is registered.
   --
   -- @since 5.0.0
   --
   -- @param string $name Block type name including namespace.
   -- @return bool True if the block type is registered, false otherwise.
   --
   function Is_Registered (This : Wp_Block_Type_Registry;
                           Name : String)
                           return Boolean;

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

   --
   -- Utility method to retrieve the main instance of the class.
   --
   -- The instance will be created if it does not exist yet.
   --
   -- @since 5.0.0
   --
   -- @return WP_Block_Type_Registry The main instance.
   --
   -- public static
   function Get_Instance
            return Wp_Block_Type_Registry;

   Null_Wp_Block_Type_Registry : constant Wp_Block_Type_Registry :=
     (Registered_Block_Types => Block_Type_Maps.Empty_Map);

   function From_Map (Map : Block_Type_Maps.Map)
                      return Array_Type;

   --
   -- Container for the main instance of the class.
   --
   -- @since 5.0.0
   -- @var WP_Block_Type_Registry|null
   --
   -- private static
   Static_Instance : Wp_Block_Type_Registry :=
     Null_Wp_Block_Type_Registry;

end Class_Block_Type_Registry;
