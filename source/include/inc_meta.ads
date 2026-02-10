--
-- Core Metadata API
--
-- Functions for retrieving and manipulating metadata of various WordPress object
-- types. Metadata for an object is a represented by a simple key-value pair. Objects
-- may contain multiple metadata entries that share the same key and differ only in
-- their value.
--
-- @package WordPress
-- @subpackage Meta
--

with Arrays;

package Inc_Meta
is
   use Arrays;

   --
   -- Updates metadata for the specified object. If no value already exists for the
   -- specified object ID and metadata key, the metadata will be added.
   --
   -- @since 2.9.0
   --
   -- @global wpdb $wpdb WordPress database abstraction object.
   --
   -- @param string $meta_type  Type of object metadata is for. Accepts 'post',
   --                           'comment', 'term', 'user', or any other object type
   --                           with an associated meta table.
   -- @param int    $object_id  ID of the object metadata is for.
   -- @param string $meta_key   Metadata key.
   -- @param mixed  $meta_value Metadata value. Must be serializable if non-scalar.
   -- @param mixed  $prev_value Optional. Previous value to check before updating.
   --                           If specified, only update existing metadata entries
   --                           with this value. Otherwise, update all entries.
   --                           Default empty.
   -- @return int|bool The new meta field ID if a field with the given key didn't exist
   --                  and was therefore added, true on successful update,
   --                  false on failure or if the value passed to the function
   --                  is the same as the one that is already in the database.
   --
   function Update_Metadata (Meta_Type  : Integer;
                             Object_Id  : String;
                             Meta_Key   : String;
                             Meta_Value : Multi_Type;
                             prev_value : Multi_Type := From_String (""))
                             return Integer;

   --
   -- Deletes metadata for the specified object.
   --
   -- @since 2.9.0
   --
   -- @global wpdb $wpdb WordPress database abstraction object.
   --
   -- @param string $meta_type  Type of object metadata is for. Accepts 'post',
   --                           'comment', 'term', 'user', or any other object type
   --                           with an associated meta table.
   -- @param int    $object_id  ID of the object metadata is for.
   -- @param string $meta_key   Metadata key.
   -- @param mixed  $meta_value Optional. Metadata value. Must be serializable if
   --                           non-scalar. If specified, only delete metadata entries
   --                           with this value. Otherwise, delete all entries with
   --                           the specified meta_key. Pass `null`, `false`, or an
   --                           empty string to skip this check. (For backward
   --                           compatibility, it is not possible to pass an empty
   --                           string to delete those entries with an empty string
   --                           for a value.)
   -- @param bool   $delete_all Optional. If true, delete matching metadata entries
   --                           for all objects, ignoring the specified object_id.
   --                           Otherwise, only delete matching metadata entries for
   --                           the specified object_id. Default false.
   -- @return bool True on successful delete, false on failure.
   --
   function Delete_Metadata (Meta_Type  : String;
                             Object_Id  : Integer;
                             Meta_Key   : String;
                             Meta_Value : Multi_Type := From_String ("");
                             Delete_All : Boolean    := False)
                             return Boolean;

   procedure Delete_Metadata (Meta_Type  : String;
                              Object_Id  : Integer;
                              Meta_Key   : String;
                              Meta_Value : Multi_Type := From_String ("");
                              Delete_All : Boolean    := False);

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
   -- @param string $meta_type Type of object metadata is for. Accepts 'post',
   --                          'comment', 'term', 'user', or any other object type
   --                          with an associated meta table.
   -- @param int    $object_id ID of the object metadata is for.
   -- @param string $meta_key  Optional. Metadata key. If not specified, retrieve all
   --                          metadata for the specified object. Default empty.
   -- @param bool   $single    Optional. If true, return only the first value of the
   --                          specified `$meta_key`. This parameter has no effect if
   --                          `$meta_key` is not specified. Default false.
   -- @return mixed An array of values if `$single` is false.
   --               The value of the meta field if `$single` is true.
   --               False for an invalid `$object_id` (non-numeric, zero, or negative
   --               value), or if `$meta_type` is not specified.
   --               An empty string if a valid but non-existing object ID is passed.
   --
   function Get_Metadata (Meta_Type : String;
                          Object_Id : Integer;
                          Meta_Key  : String  := "";
                          Single    : Boolean := False)
                          return Array_Type is (Empty_Array);

   --
   -- Determines if a meta field with the given key exists for the given object ID.
   --
   -- @since 3.3.0
   --
   -- @param string $meta_type Type of object metadata is for. Accepts 'post',
   --                          'comment', 'term', 'user', or any other object type
   --                          with an associated meta table.
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
   -- @param string       $meta_type  Type of object metadata is for. Accepts 'post',
   --                                 'comment', 'term', 'user', or any other object
   --                                 type with an associated meta table.
   -- @param string|int[] $object_ids Array or comma delimited list of object IDs to
   --                                 update cache for.
   -- @return array|false Metadata cache for the specified objects, or false on
   --                     failure.
   --
   type Integer_Array is array (Positive range <>) of Integer;

   function Update_Meta_Cache (Meta_Type  : String;
                               Object_Ids : Integer_Array)
                               return Array_Type
                               is (Empty_Array);

   --
   -- Retrieves the name of the metadata table for the specified object type.
   --
   -- @since 2.9.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string type Type of object metadata is for. Accepts "post", "comment",
   --                     "term", "user", or any other object type with an associated
   --                     meta table.
   -- @return string|false Metadata table name, or false if no metadata table exists
   --
   function X_Get_Meta_Table (Typ : String)
                              return String;

   --
   -- Determines whether a meta key is considered protected.
   --
   -- @since 3.1.3
   --
   -- @param string $meta_key  Metadata key.
   -- @param string $meta_type Optional. Type of object metadata is for. Accepts
   --                          'post', 'comment', 'term', 'user', or any other object
   --                          type with an associated meta table. Default empty.
   -- @return bool Whether the meta key is considered protected.
   --
   function Is_Protected_Meta (Meta_Key  : String;
                               Meta_Type : String := "")
                               return Boolean;

   --
   -- Returns the object subtype for a given object ID of a specific type.
   --
   -- @since 4.9.8
   --
   -- @param string $object_type Type of object metadata is for. Accepts 'post',
   --                             'comment', 'term', 'user', or any other object type
   --                             with an associated meta table.
   -- @param int    $object_id   ID of the object to retrieve its subtype.
   -- @return string The object subtype or an empty string if unspecified subtype.
   --
   function Get_Object_Subtype (Object_Type : String;
                                Object_Id   : Integer)
                                return String;

end Inc_Meta;
