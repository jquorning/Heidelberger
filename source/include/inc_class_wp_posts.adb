with Php;

with Globals;
with Hb_Common;

with Adi_Caches;

with Inc_Category_Templates;
with Inc_Class_Wp_Terms;
with Inc_Class_Wpdb;
with Inc_Functions;
with Inc_Meta;
with Inc_Posts;
with Inc_Taxonomys;

package body Inc_Class_Wp_Posts
is
   function "-" (Item : Unbounded_String) return String
      renames To_String;

   use Adi_Caches;

   procedure Get_Instance (Id      : Post_Id;
                           Post    : out Wp_Post;
                           Success : out Boolean)
   is
      use Hb_Common;
--           Success : Boolean;
--           Post    : Post_Type;
   begin
 --               global wpdb;

 --               if Post_Id = 0 then
 --                  raise Constraint_Error with "illegal post_id";
 --                end if;

      Wp_Cache_Get (Key     => Id'Image,
                    Group   => "posts",
                    Post    => Post,
                    Success => Success);
--                _post = wp_cache_get( post_id, "posts" );

      if not Success then
         declare
            use Globals;

            Statement : constant String
              := WpDB.Prepare
                ("SELECT * FROM wpdb->posts WHERE ID = %d LIMIT 1",
                 (To_List (Item => Id'Image)));
         begin
            Inc_Class_Wpdb.Get_Row (WpDB, Post,
                                    Query   => Statement,
                                    Success => Success);
--            Post := Wpdb.Get_Row (Statement, Success);
         end;

         if not Success then
            Success := False;  -- To be clear
            return;
         end if;

         Post := Inc_Posts.Sanitize_Post (Post, "raw");
         Wp_Cache_Add (Post.Id'Image, Post, "posts");

      elsif Post.Filter = "" or else "raw" /= Post.Filter then
         Post := Inc_Posts.Sanitize_Post (Post, "raw");
      end if;

      Success := True;
      return; --  new WP_Post( _post );
   end Get_Instance;

        --
        -- Constructor.
        --
        -- @since 3.5.0
        --
        -- @param WP_Post|object post Post object.
        --
--        public function __construct( post ) then

   function X_Construct (Post : Wp_Post) return Wp_Post
   is
   begin
      return Post;
--       foreach ( get_object_vars( post ) as key => value ) then
--          this.key = value;
--       end;
   end X_Construct;

        --
        -- Isset-er.
        --
        -- @since 3.5.0
        --
        -- @param string key Property to check if set.
        -- @return bool
        --
   function X_Isset (Post : Wp_Post;
                     Key  : String)
                     return Boolean
   is
   begin
      if "ancestors" = Key then
         return True;
      end if;

      if "page_template" = Key then
         return True;
      end if;

      if "post_category" = Key then
         return True;
      end if;

      if "tags_input" = Key then
         return True;
      end if;

      return Inc_Meta.Metadata_Exists ("post", Integer (Post.Id), Key);
   end X_Isset;

        --
        -- Getter.
        --
        -- @since 3.5.0
        --
        -- @param string key Key to get.
        -- @return mixed
        --
   function X_Get (Post : Wp_Post;
                   Key  : String)
                   return Array_Type
   is
      use Inc_Class_Wp_Terms;
      use Inc_Category_Templates;
      use Inc_Functions;
      use Inc_Taxonomys;
   begin
      if "page_template" = Key and then Post.X_Isset (Key) then
         return Inc_Posts.Get_Post_Meta
                  (Post.Id, "_wp_page_template", True);
      end if;

      if "post_category" = Key then
         declare
            Terms : Wp_Term_Array
               := (if Is_Object_In_Taxonomy (-Post.Post_Type, "category")
                   then Get_The_Terms (Post, "category") -- Wp_Post;
                   else (Empty_Term_Array));
         begin

--                        if Empty (Terms) then
--                                return Empty_Array;
--                        end if;

            return Wp_List_Pluck (Terms, "term_id");

         exception
            when No_Terms =>
               return Empty_Array;
         end;
      end if;

      if "tags_input" = Key then
         declare
            Terms : Wp_Term_Array -- Wp_Post;
               := (if Is_Object_In_Taxonomy (-Post.Post_Type, "post_tag")
                   then Get_The_Terms (Post, "post_tag")
                   else (Empty_Term_Array));
         begin
--                        if Empty (Terms) then
--                                return Empty_Array;
--                        end if;

            return Wp_List_Pluck (Terms, "name");

         exception
            when No_Terms =>
               return Empty_Array;
         end;
      end if;

      -- Rest of the values need filtering.
      declare
         use Inc_Posts;

         Value_2 : Array_Type -- Post_Id_List
            := (if "ancestors" = Key
                then Get_Post_Ancestors (Post)
                else Get_Post_Meta (Post.Id, Key, Single => True));

         Value : Array_Type  -- Post_Id_List
            := (if Post.Filter /= ""
                then Sanitize_Post_Field (Key, Value_2, Post.Id, -Post.Filter)
                else Value_2);
      begin
         return Value;
      end;
   end X_Get;

        --
        -- {@Missing Summary}
        --
        -- @since 3.5.0
        --
        -- @param string filter Filter.
        -- @return WP_Post
        --
   function Filter (Post   : Wp_Post;
                    Filter : String)
                    return Wp_Post
   is
   begin
      if Post.Filter = Filter then
         return Post;
      end if;

      if "raw" = Filter then
         declare
            Unused_Success : Boolean;
            Post_2         : Wp_Post;
         begin
            Get_Instance (Post.Id, Post_2, Unused_Success);  -- self::
--          return Post.Get_Instance (Post.ID);  -- self::
            return Post_2;
         end;
      end if;

      return Inc_Posts.Sanitize_Post (Post, Filter);
   end Filter;

   --
   -- Convert object to array.
   --
   -- @since 3.5.0
   --
   -- @return array Object as array.
   --
   function To_Array (Post : Wp_Post) return Array_Type
   is
      use Hb_Common;

      Post_2 : Array_Type := Php.Get_Object_Vars (Post);
   begin
      for
        Key of To_List (List => (+"ancestors", +"page_template",
                                 +"post_category", +"tags_input"))
      loop
         if X_Isset (Post_2, -Key) then
            Set (Post_2, -Key, From_String (As_String (Get (Post_2, -Key)))); -- x_get
         end if;
      end loop;

      return Post_2;
   end To_Array;

end Inc_Class_Wp_Posts;
