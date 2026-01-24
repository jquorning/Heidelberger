--
-- Comment API: WP_Comment class
--
-- @package WordPress
-- @subpackage Comments
-- @since 4.4.0
--

with Globals;
with Hb_Common;
with Lists;

with Inc_Caches;
with Inc_Class_Wpdb;

package body Inc_Class_Wp_Comments
is

   ------------------
   -- Get_Instance --
   ------------------

   function Get_Instance (Id : Integer)
                          return Wp_Comment
   is
      use Globals;
      use Hb_Common;
      use Lists;
      use Inc_Caches;
      use Inc_Class_Wpdb;

      Comment_Id : constant Integer := Id; -- (int)
   begin
      if Comment_Id in 0 then
         return Null_Comment; -- False;
      end if;

      declare
         Found   : Boolean;
         Success : Boolean;

         X_Comment : Wp_Comment :=
           Wp_Cache_Get (Comment_Id, "comment", Found => Found);
      begin
         if X_Comment = Null_Comment then -- not
            X_Comment :=
              WpDB.Get_Row (
                WpDB.Prepare (
                  "SELECT * FROM wpdb.comments WHERE comment_ID = %d LIMIT 1",
                  To_List (Integer'Image (Comment_Id))),
                  Success => Success);

            if X_Comment = Null_Comment then -- not
               return Null_Comment; -- False;
            end if;

            Wp_Cache_Add (-X_Comment.Comment_Id, X_Comment, "comment");
         end if;

         return X_Construct (X_Comment);
      end;
   end Get_Instance;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Comment : Wp_Comment)
                         return Wp_Comment
   is
      This : Wp_Comment;
   begin
      -- for ( get_object_vars( comment ) as key => value ) loop
      --                   this.key = value;
      -- end loop;
      return This;
   end X_Construct;

--         --
--         -- Convert object to array.
--         --
--         -- @since 4.4.0
--         --
--         -- @return array Object as array.
--         --
--         public function to_array() then
--                 return get_object_vars( this );
--         end;

--         --
--         -- Get the children of a comment.
--         --
--         -- @since 4.4.0
--         --
--         -- @param array args then
--         --     Array of arguments used to pass to get_comments() and determine format.
--         --
--         --     @type string format        Return value format. 'tree' for a hierarchical tree, 'flat' for a flattened array.
--         --                                 Default 'tree'.
--         --     @type string status        Comment status to limit results by. Accepts 'hold' (`comment_status=0`),
--         --                                 'approve' (`comment_status=1`), 'all', or a custom comment status.
--         --                                 Default 'all'.
--         --     @type string hierarchical  Whether to include comment descendants in the results.
--         --                                 'threaded' returns a tree, with each comment's children
--         --                                 stored in a `children` property on the `WP_Comment` object.
--         --                                 'flat' returns a flat array of found comments plus their children.
--         --                                 Pass `false` to leave out descendants.
--         --                                 The parameter is ignored (forced to `false`) when `fields` is 'ids' or 'counts'.
--         --                                 Accepts 'threaded', 'flat', or false. Default: 'threaded'.
--         --     @type string|array orderby Comment status or array of statuses. To use 'meta_value'
--         --                                 or 'meta_value_num', `meta_key` must also be defined.
--         --                                 To sort by a specific `meta_query` clause, use that
--         --                                 clause's array key. Accepts 'comment_agent',
--         --                                 'comment_approved', 'comment_author',
--         --                                 'comment_author_email', 'comment_author_IP',
--         --                                 'comment_author_url', 'comment_content', 'comment_date',
--         --                                 'comment_date_gmt', 'comment_ID', 'comment_karma',
--         --                                 'comment_parent', 'comment_post_ID', 'comment_type',
--         --                                 'user_id', 'comment__in', 'meta_value', 'meta_value_num',
--         --                                 the value of meta_key, and the array keys of
--         --                                 `meta_query`. Also accepts false, an empty array, or
--         --                                 'none' to disable `ORDER BY` clause.
--         -- end;
--         -- @return WP_Comment[] Array of `WP_Comment` objects.
--         --
--         public function get_children( args = array() ) then
--                 defaults = array(
--                         'format'       => 'tree',
--                         'status'       => 'all',
--                         'hierarchical' => 'threaded',
--                         'orderby'      => '',
--                 );

--                 _args           = wp_parse_args( args, defaults );
--                 _args['parent'] = this.comment_ID;

--                 if ( is_null( this.children ) ) then
--                         if ( this.populated_children ) then
--                                 this.children = array();
--                         end; else then
--                                 this.children = get_comments( _args );
--                         end;
--                 end;

--                 if ( 'flat' === _args['format'] ) then
--                         children = array();
--                         foreach ( this.children as child ) then
--                                 child_args           = _args;
--                                 child_args['format'] = 'flat';
--                                 // get_children() resets this value automatically.
--                                 unset( child_args['parent'] );

--                                 children = array_merge( children, array( child ), child.get_children( child_args ) );
--                         end;
--                 end; else then
--                         children = this.children;
--                 end;

--                 return children;
--         end;

--         --
--         -- Add a child to the comment.
--         --
--         -- Used by `WP_Comment_Query` when bulk-filling descendants.
--         --
--         -- @since 4.4.0
--         --
--         -- @param WP_Comment child Child comment.
--         --
--         public function add_child( WP_Comment child ) then
--                 this.children[ child.comment_ID ] = child;
--         end;

--         --
--         -- Get a child comment by ID.
--         --
--         -- @since 4.4.0
--         --
--         -- @param int child_id ID of the child.
--         -- @return WP_Comment|false Returns the comment object if found, otherwise false.
--         --
--         public function get_child( child_id ) then
--                 if ( isset( this.children[ child_id ] ) ) then
--                         return this.children[ child_id ];
--                 end;

--                 return false;
--         end;

--         --
--         -- Set the 'populated_children' flag.
--         --
--         -- This flag is important for ensuring that calling `get_children()` on a childless comment will not trigger
--         -- unneeded database queries.
--         --
--         -- @since 4.4.0
--         --
--         -- @param bool set Whether the comment's children have already been populated.
--         --
--         public function populated_children( set ) then
--                 this.populated_children = (bool) set;
--         end;

--         --
--         -- Check whether a non-public property is set.
--         --
--         -- If `name` matches a post field, the comment post will be loaded and the post's value checked.
--         --
--         -- @since 4.4.0
--         --
--         -- @param string name Property name.
--         -- @return bool
--         --
--         public function __isset( name ) then
--                 if ( in_array( name, this.post_fields, true ) && 0 !== (int) this.comment_post_ID ) then
--                         post = get_post( this.comment_post_ID );
--                         return property_exists( post, name );
--                 end;
--         end;

--         --
--         -- Magic getter.
--         --
--         -- If `name` matches a post field, the comment post will be loaded and the post's value returned.
--         --
--         -- @since 4.4.0
--         --
--         -- @param string name
--         -- @return mixed
--         --
--         public function __get( name ) then
--                 if ( in_array( name, this.post_fields, true ) ) then
--                         post = get_post( this.comment_post_ID );
--                         return post.name;
--                 end;
--         end;
end Inc_Class_Wp_Comments;
