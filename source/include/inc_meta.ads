with Arrays;

package Inc_Meta
is
   use Arrays;
--
-- Retrieves the value of a metadata field for the specified object type and ID.
--
-- If the meta field exists, a single value is returned if `$single` is true,
-- or an array of values if it's false.
--
-- If the meta field does not exist, the result depends on get_metadata_default().
-- By default, an empty string is returned if `$single` is true, or an empty array
-- if it's false.
--
-- @since 2.9.0
--
-- @see get_metadata_raw()
-- @see get_metadata_default()
--
-- @param string $meta_type Type of object metadata is for. Accepts 'post', 'comment', 'term', 'user',
--                          or any other object type with an associated meta table.
-- @param int    $object_id ID of the object metadata is for.
-- @param string $meta_key  Optional. Metadata key. If not specified, retrieve all metadata for
--                          the specified object. Default empty.
-- @param bool   $single    Optional. If true, return only the first value of the specified `$meta_key`.
--                          This parameter has no effect if `$meta_key` is not specified. Default false.
-- @return mixed An array of values if `$single` is false.
--               The value of the meta field if `$single` is true.
--               False for an invalid `$object_id` (non-numeric, zero, or negative value),
--               or if `$meta_type` is not specified.
--               An empty string if a valid but non-existing object ID is passed.
--
   function Get_Metadata (Meta_Type : String;
                          Object_Id : Integer;
                          meta_key  : String  := "";
                          Single    : Boolean := False)
                          return Array_Type is (Empty_Array);

--
-- Determines if a meta field with the given key exists for the given object ID.
--
-- @since 3.3.0
--
-- @param string $meta_type Type of object metadata is for. Accepts 'post', 'comment', 'term', 'user',
--                          or any other object type with an associated meta table.
-- @param int    $object_id ID of the object metadata is for.
-- @param string $meta_key  Metadata key.
-- @return bool Whether a meta field with the given key exists.
--
   function Metadata_Exists (Meta_Type : String;
                             Object_Id : Positive;  -- Integer;
                             Meta_Key  : String)
                             return Boolean;

--
-- Updates the metadata cache for the specified objects.
--
-- @since 2.9.0
--
-- @global wpdb $wpdb WordPress database abstraction object.
--
-- @param string       $meta_type  Type of object metadata is for. Accepts 'post', 'comment', 'term', 'user',
--                                 or any other object type with an associated meta table.
-- @param string|int[] $object_ids Array or comma delimited list of object IDs to update cache for.
-- @return array|false Metadata cache for the specified objects, or false on failure.
--
   type Integer_Array is array (Positive range <>) of Integer;

   function Update_Meta_Cache (Meta_Type  : String;
                               Object_Ids : Integer_Array)
                               return Array_Type
                               is (Empty_Array);

end Inc_Meta;
