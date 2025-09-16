--
-- WordPress Post Administration API.
--
-- @package WordPress
-- @subpackage Administration
--

package body Adi_Posts
is
        procedure Dummy is null;
-- --
-- -- Renames `$_POST` data from form names to DB post columns.
-- --
-- -- Manipulates `$_POST` directly.
-- --
-- -- @since 2.6.0
-- --
-- -- @param bool       $update    Whether the post already exists.
-- -- @param array|null $post_data Optional. The array of post data to process.
-- --                              Defaults to the `$_POST` superglobal.
-- -- @return array|WP_Error Array of post data on success, WP_Error on failure.
-- --
-- function _wp_translate_postdata( $update = false, $post_data = null ) then

--         if ( empty( $post_data ) ) then
--                 $post_data = &$_POST;
--         end;

--         if ( $update ) then
--                 $post_data["ID"] = (int) $post_data["post_ID"];
--         end;

--         $ptype = get_post_type_object( $post_data["post_type"] );

--         if ( $update && ! current_user_can( "edit_post", $post_data["ID"] ) ) then
--                 if ( "page" === $post_data["post_type"] ) then
--                         return new WP_Error( "edit_others_pages", __( "Sorry, you are not allowed to edit pages as this user." ) );
--                 end; else then
--                         return new WP_Error( "edit_others_posts", __( "Sorry, you are not allowed to edit posts as this user." ) );
--                 end;
--         end; elseif ( ! $update && ! current_user_can( $ptype->cap->create_posts ) ) then
--                 if ( "page" === $post_data["post_type"] ) then
--                         return new WP_Error( "edit_others_pages", __( "Sorry, you are not allowed to create pages as this user." ) );
--                 end; else then
--                         return new WP_Error( "edit_others_posts", __( "Sorry, you are not allowed to create posts as this user." ) );
--                 end;
--         end;

--         if ( isset( $post_data["content"] ) ) then
--                 $post_data["post_content"] = $post_data["content"];
--         end;

--         if ( isset( $post_data["excerpt"] ) ) then
--                 $post_data["post_excerpt"] = $post_data["excerpt"];
--         end;

--         if ( isset( $post_data["parent_id"] ) ) then
--                 $post_data["post_parent"] = (int) $post_data["parent_id"];
--         end;

--         if ( isset( $post_data["trackback_url"] ) ) then
--                 $post_data["to_ping"] = $post_data["trackback_url"];
--         end;

--         $post_data["user_ID"] = get_current_user_id();

--         if ( ! empty( $post_data["post_author_override"] ) ) then
--                 $post_data["post_author"] = (int) $post_data["post_author_override"];
--         end; else then
--                 if ( ! empty( $post_data["post_author"] ) ) then
--                         $post_data["post_author"] = (int) $post_data["post_author"];
--                 end; else then
--                         $post_data["post_author"] = (int) $post_data["user_ID"];
--                 end;
--         end;

--         if ( isset( $post_data["user_ID"] ) && ( $post_data["post_author"] != $post_data["user_ID"] )
--                 && ! current_user_can( $ptype->cap->edit_others_posts ) ) then

--                 if ( $update ) then
--                         if ( "page" === $post_data["post_type"] ) then
--                                 return new WP_Error( "edit_others_pages", __( "Sorry, you are not allowed to edit pages as this user." ) );
--                         end; else then
--                                 return new WP_Error( "edit_others_posts", __( "Sorry, you are not allowed to edit posts as this user." ) );
--                         end;
--                 end; else then
--                         if ( "page" === $post_data["post_type"] ) then
--                                 return new WP_Error( "edit_others_pages", __( "Sorry, you are not allowed to create pages as this user." ) );
--                         end; else then
--                                 return new WP_Error( "edit_others_posts", __( "Sorry, you are not allowed to create posts as this user." ) );
--                         end;
--                 end;
--         end;

--         if ( ! empty( $post_data["post_status"] ) ) then
--                 $post_data["post_status"] = sanitize_key( $post_data["post_status"] );

--                 -- No longer an auto-draft.
--                 if ( "auto-draft" === $post_data["post_status"] ) then
--                         $post_data["post_status"] = "draft";
--                 end;

--                 if ( ! get_post_status_object( $post_data["post_status"] ) ) then
--                         unset( $post_data["post_status"] );
--                 end;
--         end;

--         -- What to do based on which button they pressed.
--         if ( isset( $post_data["saveasdraft"] ) && "" !== $post_data["saveasdraft"] ) then
--                 $post_data["post_status"] = "draft";
--         end;
--         if ( isset( $post_data["saveasprivate"] ) && "" !== $post_data["saveasprivate"] ) then
--                 $post_data["post_status"] = "private";
--         end;
--         if ( isset( $post_data["publish"] ) && ( "" !== $post_data["publish"] )
--                 && ( ! isset( $post_data["post_status"] ) || "private" !== $post_data["post_status"] )
--         ) then
--                 $post_data["post_status"] = "publish";
--         end;
--         if ( isset( $post_data["advanced"] ) && "" !== $post_data["advanced"] ) then
--                 $post_data["post_status"] = "draft";
--         end;
--         if ( isset( $post_data["pending"] ) && "" !== $post_data["pending"] ) then
--                 $post_data["post_status"] = "pending";
--         end;

--         if ( isset( $post_data["ID"] ) ) then
--                 $post_id = $post_data["ID"];
--         end; else then
--                 $post_id = false;
--         end;
--         $previous_status = $post_id ? get_post_field( "post_status", $post_id ) : false;

--         if ( isset( $post_data["post_status"] ) && "private" === $post_data["post_status"] && ! current_user_can( $ptype->cap->publish_posts ) ) then
--                 $post_data["post_status"] = $previous_status ? $previous_status : "pending";
--         end;

--         $published_statuses = array( "publish", "future" );

--         -- Posts "submitted for approval" are submitted to $_POST the same as if they were being published.
--         -- Change status from "publish" to "pending" if user lacks permissions to publish or to resave published posts.
--         if ( isset( $post_data["post_status"] )
--                 && ( in_array( $post_data["post_status"], $published_statuses, true )
--                 && ! current_user_can( $ptype->cap->publish_posts ) )
--         ) then
--                 if ( ! in_array( $previous_status, $published_statuses, true ) || ! current_user_can( "edit_post", $post_id ) ) then
--                         $post_data["post_status"] = "pending";
--                 end;
--         end;

--         if ( ! isset( $post_data["post_status"] ) ) then
--                 $post_data["post_status"] = "auto-draft" === $previous_status ? "draft" : $previous_status;
--         end;

--         if ( isset( $post_data["post_password"] ) && ! current_user_can( $ptype->cap->publish_posts ) ) then
--                 unset( $post_data["post_password"] );
--         end;

--         if ( ! isset( $post_data["comment_status"] ) ) then
--                 $post_data["comment_status"] = "closed";
--         end;

--         if ( ! isset( $post_data["ping_status"] ) ) then
--                 $post_data["ping_status"] = "closed";
--         end;

--         foreach ( array( "aa", "mm", "jj", "hh", "mn" ) as $timeunit ) then
--                 if ( ! empty( $post_data[ "hidden_" . $timeunit ] ) && $post_data[ "hidden_" . $timeunit ] != $post_data[ $timeunit ] ) then
--                         $post_data["edit_date"] = "1";
--                         break;
--                 end;
--         end;

--         if ( ! empty( $post_data["edit_date"] ) ) then
--                 $aa = $post_data["aa"];
--                 $mm = $post_data["mm"];
--                 $jj = $post_data["jj"];
--                 $hh = $post_data["hh"];
--                 $mn = $post_data["mn"];
--                 $ss = $post_data["ss"];
--                 $aa = ( $aa <= 0 ) ? gmdate( "Y" ) : $aa;
--                 $mm = ( $mm <= 0 ) ? gmdate( "n" ) : $mm;
--                 $jj = ( $jj > 31 ) ? 31 : $jj;
--                 $jj = ( $jj <= 0 ) ? gmdate( "j" ) : $jj;
--                 $hh = ( $hh > 23 ) ? $hh - 24 : $hh;
--                 $mn = ( $mn > 59 ) ? $mn - 60 : $mn;
--                 $ss = ( $ss > 59 ) ? $ss - 60 : $ss;

--                 $post_data["post_date"] = sprintf( "%04d-%02d-%02d %02d:%02d:%02d", $aa, $mm, $jj, $hh, $mn, $ss );

--                 $valid_date = wp_checkdate( $mm, $jj, $aa, $post_data["post_date"] );
--                 if ( ! $valid_date ) then
--                         return new WP_Error( "invalid_date", __( "Invalid date." ) );
--                 end;

--                 $post_data["post_date_gmt"] = get_gmt_from_date( $post_data["post_date"] );
--         end;

--         if ( isset( $post_data["post_category"] ) ) then
--                 $category_object = get_taxonomy( "category" );
--                 if ( ! current_user_can( $category_object->cap->assign_terms ) ) then
--                         unset( $post_data["post_category"] );
--                 end;
--         end;

--         return $post_data;
-- end;

-- --
-- -- Returns only allowed post data fields.
-- --
-- -- @since 5.0.1
-- --
-- -- @param array|WP_Error|null $post_data The array of post data to process, or an error object.
-- --                                       Defaults to the `$_POST` superglobal.
-- -- @return array|WP_Error Array of post data on success, WP_Error on failure.
-- --
-- function _wp_get_allowed_postdata( $post_data = null ) then
--         if ( empty( $post_data ) ) then
--                 $post_data = $_POST;
--         end;

--         -- Pass through errors.
--         if ( is_wp_error( $post_data ) ) then
--                 return $post_data;
--         end;

--         return array_diff_key( $post_data, array_flip( array( "meta_input", "file", "guid" ) ) );
-- end;

-- --
-- -- Updates an existing post with values provided in `$_POST`.
-- --
-- -- If post data is passed as an argument, it is treated as an array of data
-- -- keyed appropriately for turning into a post object.
-- --
-- -- If post data is not passed, the `$_POST` global variable is used instead.
-- --
-- -- @since 1.5.0
-- --
-- -- @global wpdb $wpdb WordPress database abstraction object.
-- --
-- -- @param array|null $post_data Optional. The array of post data to process.
-- --                              Defaults to the `$_POST` superglobal.
-- -- @return int Post ID.
-- --
-- function edit_post( $post_data = null ) then
--         global $wpdb;

--         if ( empty( $post_data ) ) then
--                 $post_data = &$_POST;
--         end;

--         -- Clear out any data in internal vars.
--         unset( $post_data["filter"] );

--         $post_ID = (int) $post_data["post_ID"];
--         $post    = get_post( $post_ID );

--         $post_data["post_type"]      = $post->post_type;
--         $post_data["post_mime_type"] = $post->post_mime_type;

--         if ( ! empty( $post_data["post_status"] ) ) then
--                 $post_data["post_status"] = sanitize_key( $post_data["post_status"] );

--                 if ( "inherit" === $post_data["post_status"] ) then
--                         unset( $post_data["post_status"] );
--                 end;
--         end;

--         $ptype = get_post_type_object( $post_data["post_type"] );
--         if ( ! current_user_can( "edit_post", $post_ID ) ) then
--                 if ( "page" === $post_data["post_type"] ) then
--                         wp_die( __( "Sorry, you are not allowed to edit this page." ) );
--                 end; else then
--                         wp_die( __( "Sorry, you are not allowed to edit this post." ) );
--                 end;
--         end;

--         if ( post_type_supports( $ptype->name, "revisions" ) ) then
--                 $revisions = wp_get_post_revisions(
--                         $post_ID,
--                         array(
--                                 "order"          => "ASC",
--                                 "posts_per_page" => 1,
--                         )
--                 );
--                 $revision  = current( $revisions );

--                 -- Check if the revisions have been upgraded.
--                 if ( $revisions && _wp_get_post_revision_version( $revision ) < 1 ) then
--                         _wp_upgrade_revisions_of_post( $post, wp_get_post_revisions( $post_ID ) );
--                 end;
--         end;

--         if ( isset( $post_data["visibility"] ) ) then
--                 switch ( $post_data["visibility"] ) then
--                         case "public":
--                                 $post_data["post_password"] = "";
--                                 break;
--                         case "password":
--                                 unset( $post_data["sticky"] );
--                                 break;
--                         case "private":
--                                 $post_data["post_status"]   = "private";
--                                 $post_data["post_password"] = "";
--                                 unset( $post_data["sticky"] );
--                                 break;
--                 end;
--         end;

--         $post_data = _wp_translate_postdata( true, $post_data );
--         if ( is_wp_error( $post_data ) ) then
--                 wp_die( $post_data->get_error_message() );
--         end;
--         $translated = _wp_get_allowed_postdata( $post_data );

--         -- Post formats.
--         if ( isset( $post_data["post_format"] ) ) then
--                 set_post_format( $post_ID, $post_data["post_format"] );
--         end;

--         $format_meta_urls = array( "url", "link_url", "quote_source_url" );
--         foreach ( $format_meta_urls as $format_meta_url ) then
--                 $keyed = "_format_" . $format_meta_url;
--                 if ( isset( $post_data[ $keyed ] ) ) then
--                         update_post_meta( $post_ID, $keyed, wp_slash( sanitize_url( wp_unslash( $post_data[ $keyed ] ) ) ) );
--                 end;
--         end;

--         $format_keys = array( "quote", "quote_source_name", "image", "gallery", "audio_embed", "video_embed" );

--         foreach ( $format_keys as $key ) then
--                 $keyed = "_format_" . $key;
--                 if ( isset( $post_data[ $keyed ] ) ) then
--                         if ( current_user_can( "unfiltered_html" ) ) then
--                                 update_post_meta( $post_ID, $keyed, $post_data[ $keyed ] );
--                         end; else then
--                                 update_post_meta( $post_ID, $keyed, wp_filter_post_kses( $post_data[ $keyed ] ) );
--                         end;
--                 end;
--         end;

--         if ( "attachment" === $post_data["post_type"] && preg_match( "#^(audio|video)/#", $post_data["post_mime_type"] ) ) then
--                 $id3data = wp_get_attachment_metadata( $post_ID );
--                 if ( ! is_array( $id3data ) ) then
--                         $id3data = array();
--                 end;

--                 foreach ( wp_get_attachment_id3_keys( $post, "edit" ) as $key => $label ) then
--                         if ( isset( $post_data[ "id3_" . $key ] ) ) then
--                                 $id3data[ $key ] = sanitize_text_field( wp_unslash( $post_data[ "id3_" . $key ] ) );
--                         end;
--                 end;
--                 wp_update_attachment_metadata( $post_ID, $id3data );
--         end;

--         -- Meta stuff.
--         if ( isset( $post_data["meta"] ) && $post_data["meta"] ) then
--                 foreach ( $post_data["meta"] as $key => $value ) then
--                         $meta = get_post_meta_by_id( $key );
--                         if ( ! $meta ) then
--                                 continue;
--                         end;
--                         if ( $meta->post_id != $post_ID ) then
--                                 continue;
--                         end;
--                         if ( is_protected_meta( $meta->meta_key, "post" ) || ! current_user_can( "edit_post_meta", $post_ID, $meta->meta_key ) ) then
--                                 continue;
--                         end;
--                         if ( is_protected_meta( $value["key"], "post" ) || ! current_user_can( "edit_post_meta", $post_ID, $value["key"] ) ) then
--                                 continue;
--                         end;
--                         update_meta( $key, $value["key"], $value["value"] );
--                 end;
--         end;

--         if ( isset( $post_data["deletemeta"] ) && $post_data["deletemeta"] ) then
--                 foreach ( $post_data["deletemeta"] as $key => $value ) then
--                         $meta = get_post_meta_by_id( $key );
--                         if ( ! $meta ) then
--                                 continue;
--                         end;
--                         if ( $meta->post_id != $post_ID ) then
--                                 continue;
--                         end;
--                         if ( is_protected_meta( $meta->meta_key, "post" ) || ! current_user_can( "delete_post_meta", $post_ID, $meta->meta_key ) ) then
--                                 continue;
--                         end;
--                         delete_meta( $key );
--                 end;
--         end;

--         -- Attachment stuff.
--         if ( "attachment" === $post_data["post_type"] ) then
--                 if ( isset( $post_data["_wp_attachment_image_alt"] ) ) then
--                         $image_alt = wp_unslash( $post_data["_wp_attachment_image_alt"] );

--                         if ( get_post_meta( $post_ID, "_wp_attachment_image_alt", true ) !== $image_alt ) then
--                                 $image_alt = wp_strip_all_tags( $image_alt, true );

--                                 -- update_post_meta() expects slashed.
--                                 update_post_meta( $post_ID, "_wp_attachment_image_alt", wp_slash( $image_alt ) );
--                         end;
--                 end;

--                 $attachment_data = isset( $post_data["attachments"][ $post_ID ] ) ? $post_data["attachments"][ $post_ID ] : array();

--                 -- This filter is documented in wp-admin/includes/media.php--
--                 $translated = apply_filters( "attachment_fields_to_save", $translated, $attachment_data );
--         end;

--         -- Convert taxonomy input to term IDs, to avoid ambiguity.
--         if ( isset( $post_data["tax_input"] ) ) then
--                 foreach ( (array) $post_data["tax_input"] as $taxonomy => $terms ) then
--                         $tax_object = get_taxonomy( $taxonomy );

--                         if ( $tax_object && isset( $tax_object->meta_box_sanitize_cb ) ) then
--                                 $translated["tax_input"][ $taxonomy ] = call_user_func_array( $tax_object->meta_box_sanitize_cb, array( $taxonomy, $terms ) );
--                         end;
--                 end;
--         end;

--         add_meta( $post_ID );

--         update_post_meta( $post_ID, "_edit_last", get_current_user_id() );

--         $success = wp_update_post( $translated );

--         -- If the save failed, see if we can sanity check the main fields and try again.
--         if ( ! $success && is_callable( array( $wpdb, "strip_invalid_text_for_column" ) ) ) then
--                 $fields = array( "post_title", "post_content", "post_excerpt" );

--                 foreach ( $fields as $field ) then
--                         if ( isset( $translated[ $field ] ) ) then
--                                 $translated[ $field ] = $wpdb->strip_invalid_text_for_column( $wpdb->posts, $field, $translated[ $field ] );
--                         end;
--                 end;

--                 wp_update_post( $translated );
--         end;

--         -- Now that we have an ID we can fix any attachment anchor hrefs.
--         _fix_attachment_links( $post_ID );

--         wp_set_post_lock( $post_ID );

--         if ( current_user_can( $ptype->cap->edit_others_posts ) && current_user_can( $ptype->cap->publish_posts ) ) then
--                 if ( ! empty( $post_data["sticky"] ) ) then
--                         stick_post( $post_ID );
--                 end; else then
--                         unstick_post( $post_ID );
--                 end;
--         end;

--         return $post_ID;
-- end;

-- --
-- -- Processes the post data for the bulk editing of posts.
-- --
-- -- Updates all bulk edited posts/pages, adding (but not removing) tags and
-- -- categories. Skips pages when they would be their own parent or child.
-- --
-- -- @since 2.7.0
-- --
-- -- @global wpdb $wpdb WordPress database abstraction object.
-- --
-- -- @param array|null $post_data Optional. The array of post data to process.
-- --                              Defaults to the `$_POST` superglobal.
-- -- @return array
-- --
-- function bulk_edit_posts( $post_data = null ) then
--         global $wpdb;

--         if ( empty( $post_data ) ) then
--                 $post_data = &$_POST;
--         end;

--         if ( isset( $post_data["post_type"] ) ) then
--                 $ptype = get_post_type_object( $post_data["post_type"] );
--         end; else then
--                 $ptype = get_post_type_object( "post" );
--         end;

--         if ( ! current_user_can( $ptype->cap->edit_posts ) ) then
--                 if ( "page" === $ptype->name ) then
--                         wp_die( __( "Sorry, you are not allowed to edit pages." ) );
--                 end; else then
--                         wp_die( __( "Sorry, you are not allowed to edit posts." ) );
--                 end;
--         end;

--         if ( -1 == $post_data["_status"] ) then
--                 $post_data["post_status"] = null;
--                 unset( $post_data["post_status"] );
--         end; else then
--                 $post_data["post_status"] = $post_data["_status"];
--         end;
--         unset( $post_data["_status"] );

--         if ( ! empty( $post_data["post_status"] ) ) then
--                 $post_data["post_status"] = sanitize_key( $post_data["post_status"] );

--                 if ( "inherit" === $post_data["post_status"] ) then
--                         unset( $post_data["post_status"] );
--                 end;
--         end;

--         $post_IDs = array_map( "intval", (array) $post_data["post"] );

--         $reset = array(
--                 "post_author",
--                 "post_status",
--                 "post_password",
--                 "post_parent",
--                 "page_template",
--                 "comment_status",
--                 "ping_status",
--                 "keep_private",
--                 "tax_input",
--                 "post_category",
--                 "sticky",
--                 "post_format",
--         );

--         foreach ( $reset as $field ) then
--                 if ( isset( $post_data[ $field ] ) && ( "" === $post_data[ $field ] || -1 == $post_data[ $field ] ) ) then
--                         unset( $post_data[ $field ] );
--                 end;
--         end;

--         if ( isset( $post_data["post_category"] ) ) then
--                 if ( is_array( $post_data["post_category"] ) && ! empty( $post_data["post_category"] ) ) then
--                         $new_cats = array_map( "absint", $post_data["post_category"] );
--                 end; else then
--                         unset( $post_data["post_category"] );
--                 end;
--         end;

--         $tax_input = array();
--         if ( isset( $post_data["tax_input"] ) ) then
--                 foreach ( $post_data["tax_input"] as $tax_name => $terms ) then
--                         if ( empty( $terms ) ) then
--                                 continue;
--                         end;
--                         if ( is_taxonomy_hierarchical( $tax_name ) ) then
--                                 $tax_input[ $tax_name ] = array_map( "absint", $terms );
--                         end; else then
--                                 $comma = _x( ",", "tag delimiter" );
--                                 if ( "," !== $comma ) then
--                                         $terms = str_replace( $comma, ",", $terms );
--                                 end;
--                                 $tax_input[ $tax_name ] = explode( ",", trim( $terms, " \n\t\r\0\x0B," ) );
--                         end;
--                 end;
--         end;

--         if ( isset( $post_data["post_parent"] ) && (int) $post_data["post_parent"] ) then
--                 $parent   = (int) $post_data["post_parent"];
--                 $pages    = $wpdb->get_results( "SELECT ID, post_parent FROM $wpdb->posts WHERE post_type = "page"" );
--                 $children = array();

--                 for ( $i = 0; $i < 50 && $parent > 0; $i++ ) then
--                         $children[] = $parent;

--                         foreach ( $pages as $page ) then
--                                 if ( (int) $page->ID === $parent ) then
--                                         $parent = (int) $page->post_parent;
--                                         break;
--                                 end;
--                         end;
--                 end;
--         end;

--         $updated          = array();
--         $skipped          = array();
--         $locked           = array();
--         $shared_post_data = $post_data;

--         foreach ( $post_IDs as $post_ID ) then
--                 -- Start with fresh post data with each iteration.
--                 $post_data = $shared_post_data;

--                 $post_type_object = get_post_type_object( get_post_type( $post_ID ) );

--                 if ( ! isset( $post_type_object )
--                         || ( isset( $children ) && in_array( $post_ID, $children, true ) )
--                         || ! current_user_can( "edit_post", $post_ID )
--                 ) then
--                         $skipped[] = $post_ID;
--                         continue;
--                 end;

--                 if ( wp_check_post_lock( $post_ID ) ) then
--                         $locked[] = $post_ID;
--                         continue;
--                 end;

--                 $post      = get_post( $post_ID );
--                 $tax_names = get_object_taxonomies( $post );

--                 foreach ( $tax_names as $tax_name ) then
--                         $taxonomy_obj = get_taxonomy( $tax_name );

--                         if ( ! $taxonomy_obj->show_in_quick_edit ) then
--                                 continue;
--                         end;

--                         if ( isset( $tax_input[ $tax_name ] ) && current_user_can( $taxonomy_obj->cap->assign_terms ) ) then
--                                 $new_terms = $tax_input[ $tax_name ];
--                         end; else then
--                                 $new_terms = array();
--                         end;

--                         if ( $taxonomy_obj->hierarchical ) then
--                                 $current_terms = (array) wp_get_object_terms( $post_ID, $tax_name, array( "fields" => "ids" ) );
--                         end; else then
--                                 $current_terms = (array) wp_get_object_terms( $post_ID, $tax_name, array( "fields" => "names" ) );
--                         end;

--                         $post_data["tax_input"][ $tax_name ] = array_merge( $current_terms, $new_terms );
--                 end;

--                 if ( isset( $new_cats ) && in_array( "category", $tax_names, true ) ) then
--                         $cats                       = (array) wp_get_post_categories( $post_ID );
--                         $post_data["post_category"] = array_unique( array_merge( $cats, $new_cats ) );
--                         unset( $post_data["tax_input"]["category"] );
--                 end;

--                 $post_data["post_ID"]        = $post_ID;
--                 $post_data["post_type"]      = $post->post_type;
--                 $post_data["post_mime_type"] = $post->post_mime_type;

--                 foreach ( array( "comment_status", "ping_status", "post_author" ) as $field ) then
--                         if ( ! isset( $post_data[ $field ] ) ) then
--                                 $post_data[ $field ] = $post->$field;
--                         end;
--                 end;

--                 $post_data = _wp_translate_postdata( true, $post_data );
--                 if ( is_wp_error( $post_data ) ) then
--                         $skipped[] = $post_ID;
--                         continue;
--                 end;
--                 $post_data = _wp_get_allowed_postdata( $post_data );

--                 if ( isset( $shared_post_data["post_format"] ) ) then
--                         set_post_format( $post_ID, $shared_post_data["post_format"] );
--                 end;

--                 -- Prevent wp_insert_post() from overwriting post format with the old data.
--                 unset( $post_data["tax_input"]["post_format"] );

--                 $post_id = wp_update_post( $post_data );
--                 update_post_meta( $post_id, "_edit_last", get_current_user_id() );
--                 $updated[] = $post_id;

--                 if ( isset( $post_data["sticky"] ) && current_user_can( $ptype->cap->edit_others_posts ) ) then
--                         if ( "sticky" === $post_data["sticky"] ) then
--                                 stick_post( $post_ID );
--                         end; else then
--                                 unstick_post( $post_ID );
--                         end;
--                 end;
--         end;

--         return array(
--                 "updated" => $updated,
--                 "skipped" => $skipped,
--                 "locked"  => $locked,
--         );
-- end;

-- --
-- -- Returns default post information to use when populating the "Write Post" form.
-- --
-- -- @since 2.0.0
-- --
-- -- @param string $post_type    Optional. A post type string. Default "post".
-- -- @param bool   $create_in_db Optional. Whether to insert the post into database. Default false.
-- -- @return WP_Post Post object containing all the default post data as attributes
-- --
-- function get_default_post_to_edit( $post_type = "post", $create_in_db = false ) then
--         $post_title = "";
--         if ( ! empty( $_REQUEST["post_title"] ) ) then
--                 $post_title = esc_html( wp_unslash( $_REQUEST["post_title"] ) );
--         end;

--         $post_content = "";
--         if ( ! empty( $_REQUEST["content"] ) ) then
--                 $post_content = esc_html( wp_unslash( $_REQUEST["content"] ) );
--         end;

--         $post_excerpt = "";
--         if ( ! empty( $_REQUEST["excerpt"] ) ) then
--                 $post_excerpt = esc_html( wp_unslash( $_REQUEST["excerpt"] ) );
--         end;

--         if ( $create_in_db ) then
--                 $post_id = wp_insert_post(
--                         array(
--                                 "post_title"  => __( "Auto Draft" ),
--                                 "post_type"   => $post_type,
--                                 "post_status" => "auto-draft",
--                         ),
--                         false,
--                         false
--                 );
--                 $post    = get_post( $post_id );
--                 if ( current_theme_supports( "post-formats" ) && post_type_supports( $post->post_type, "post-formats" ) && get_option( "default_post_format" ) ) then
--                         set_post_format( $post, get_option( "default_post_format" ) );
--                 end;
--                 wp_after_insert_post( $post, false, null );

--                 -- Schedule auto-draft cleanup.
--                 if ( ! wp_next_scheduled( "wp_scheduled_auto_draft_delete" ) ) then
--                         wp_schedule_event( time(), "daily", "wp_scheduled_auto_draft_delete" );
--                 end;
--         end; else then
--                 $post                 = new stdClass;
--                 $post->ID             = 0;
--                 $post->post_author    = "";
--                 $post->post_date      = "";
--                 $post->post_date_gmt  = "";
--                 $post->post_password  = "";
--                 $post->post_name      = "";
--                 $post->post_type      = $post_type;
--                 $post->post_status    = "draft";
--                 $post->to_ping        = "";
--                 $post->pinged         = "";
--                 $post->comment_status = get_default_comment_status( $post_type );
--                 $post->ping_status    = get_default_comment_status( $post_type, "pingback" );
--                 $post->post_pingback  = get_option( "default_pingback_flag" );
--                 $post->post_category  = get_option( "default_category" );
--                 $post->page_template  = "default";
--                 $post->post_parent    = 0;
--                 $post->menu_order     = 0;
--                 $post                 = new WP_Post( $post );
--         end;

--         --
--         -- Filters the default post content initially used in the "Write Post" form.
--         --
--         -- @since 1.5.0
--         --
--         -- @param string  $post_content Default post content.
--         -- @param WP_Post $post         Post object.
--         --
--         $post->post_content = (string) apply_filters( "default_content", $post_content, $post );

--         --
--         -- Filters the default post title initially used in the "Write Post" form.
--         --
--         -- @since 1.5.0
--         --
--         -- @param string  $post_title Default post title.
--         -- @param WP_Post $post       Post object.
--         --
--         $post->post_title = (string) apply_filters( "default_title", $post_title, $post );

--         --
--         -- Filters the default post excerpt initially used in the "Write Post" form.
--         --
--         -- @since 1.5.0
--         --
--         -- @param string  $post_excerpt Default post excerpt.
--         -- @param WP_Post $post         Post object.
--         --
--         $post->post_excerpt = (string) apply_filters( "default_excerpt", $post_excerpt, $post );

--         return $post;
-- end;

-- --
-- -- Determines if a post exists based on title, content, date and type.
-- --
-- -- @since 2.0.0
-- -- @since 5.2.0 Added the `$type` parameter.
-- -- @since 5.8.0 Added the `$status` parameter.
-- --
-- -- @global wpdb $wpdb WordPress database abstraction object.
-- --
-- -- @param string $title   Post title.
-- -- @param string $content Optional. Post content.
-- -- @param string $date    Optional. Post date.
-- -- @param string $type    Optional. Post type.
-- -- @param string $status  Optional. Post status.
-- -- @return int Post ID if post exists, 0 otherwise.
-- --
-- function post_exists( $title, $content = "", $date = "", $type = "", $status = "" ) then
--         global $wpdb;

--         $post_title   = wp_unslash( sanitize_post_field( "post_title", $title, 0, "db" ) );
--         $post_content = wp_unslash( sanitize_post_field( "post_content", $content, 0, "db" ) );
--         $post_date    = wp_unslash( sanitize_post_field( "post_date", $date, 0, "db" ) );
--         $post_type    = wp_unslash( sanitize_post_field( "post_type", $type, 0, "db" ) );
--         $post_status  = wp_unslash( sanitize_post_field( "post_status", $status, 0, "db" ) );

--         $query = "SELECT ID FROM $wpdb->posts WHERE 1=1";
--         $args  = array();

--         if ( ! empty( $date ) ) then
--                 $query .= " AND post_date = %s";
--                 $args[] = $post_date;
--         end;

--         if ( ! empty( $title ) ) then
--                 $query .= " AND post_title = %s";
--                 $args[] = $post_title;
--         end;

--         if ( ! empty( $content ) ) then
--                 $query .= " AND post_content = %s";
--                 $args[] = $post_content;
--         end;

--         if ( ! empty( $type ) ) then
--                 $query .= " AND post_type = %s";
--                 $args[] = $post_type;
--         end;

--         if ( ! empty( $status ) ) then
--                 $query .= " AND post_status = %s";
--                 $args[] = $post_status;
--         end;

--         if ( ! empty( $args ) ) then
--                 return (int) $wpdb->get_var( $wpdb->prepare( $query, $args ) );
--         end;

--         return 0;
-- end;

-- --
-- -- Creates a new post from the "Write Post" form using `$_POST` information.
-- --
-- -- @since 2.1.0
-- --
-- -- @global WP_User $current_user
-- --
-- -- @return int|WP_Error Post ID on success, WP_Error on failure.
-- --
-- function wp_write_post() then
--         if ( isset( $_POST["post_type"] ) ) then
--                 $ptype = get_post_type_object( $_POST["post_type"] );
--         end; else then
--                 $ptype = get_post_type_object( "post" );
--         end;

--         if ( ! current_user_can( $ptype->cap->edit_posts ) ) then
--                 if ( "page" === $ptype->name ) then
--                         return new WP_Error( "edit_pages", __( "Sorry, you are not allowed to create pages on this site." ) );
--                 end; else then
--                         return new WP_Error( "edit_posts", __( "Sorry, you are not allowed to create posts or drafts on this site." ) );
--                 end;
--         end;

--         $_POST["post_mime_type"] = "";

--         -- Clear out any data in internal vars.
--         unset( $_POST["filter"] );

--         -- Edit, don"t write, if we have a post ID.
--         if ( isset( $_POST["post_ID"] ) ) then
--                 return edit_post();
--         end;

--         if ( isset( $_POST["visibility"] ) ) then
--                 switch ( $_POST["visibility"] ) then
--                         case "public":
--                                 $_POST["post_password"] = "";
--                                 break;
--                         case "password":
--                                 unset( $_POST["sticky"] );
--                                 break;
--                         case "private":
--                                 $_POST["post_status"]   = "private";
--                                 $_POST["post_password"] = "";
--                                 unset( $_POST["sticky"] );
--                                 break;
--                 end;
--         end;

--         $translated = _wp_translate_postdata( false );
--         if ( is_wp_error( $translated ) ) then
--                 return $translated;
--         end;
--         $translated = _wp_get_allowed_postdata( $translated );

--         -- Create the post.
--         $post_ID = wp_insert_post( $translated );
--         if ( is_wp_error( $post_ID ) ) then
--                 return $post_ID;
--         end;

--         if ( empty( $post_ID ) ) then
--                 return 0;
--         end;

--         add_meta( $post_ID );

--         add_post_meta( $post_ID, "_edit_last", $GLOBALS["current_user"]->ID );

--         -- Now that we have an ID we can fix any attachment anchor hrefs.
--         _fix_attachment_links( $post_ID );

--         wp_set_post_lock( $post_ID );

--         return $post_ID;
-- end;

-- --
-- -- Calls wp_write_post() and handles the errors.
-- --
-- -- @since 2.0.0
-- --
-- -- @return int|void Post ID on success, void on failure.
-- --
-- function write_post() then
--         $result = wp_write_post();
--         if ( is_wp_error( $result ) ) then
--                 wp_die( $result->get_error_message() );
--         end; else then
--                 return $result;
--         end;
-- end;

-- --
-- -- Post Meta.
-- --

-- --
-- -- Adds post meta data defined in the `$_POST` superglobal for a post with given ID.
-- --
-- -- @since 1.2.0
-- --
-- -- @param int $post_ID
-- -- @return int|bool
-- --
-- function add_meta( $post_ID ) then
--         $post_ID = (int) $post_ID;

--         $metakeyselect = isset( $_POST["metakeyselect"] ) ? wp_unslash( trim( $_POST["metakeyselect"] ) ) : "";
--         $metakeyinput  = isset( $_POST["metakeyinput"] ) ? wp_unslash( trim( $_POST["metakeyinput"] ) ) : "";
--         $metavalue     = isset( $_POST["metavalue"] ) ? $_POST["metavalue"] : "";
--         if ( is_string( $metavalue ) ) then
--                 $metavalue = trim( $metavalue );
--         end;

--         if ( ( ( "#NONE#" !== $metakeyselect ) && ! empty( $metakeyselect ) ) || ! empty( $metakeyinput ) ) then
--                 /*
--                 -- We have a key/value pair. If both the select and the input
--                 -- for the key have data, the input takes precedence.
--                 --
--                 if ( "#NONE#" !== $metakeyselect ) then
--                         $metakey = $metakeyselect;
--                 end;

--                 if ( $metakeyinput ) then
--                         $metakey = $metakeyinput; -- Default.
--                 end;

--                 if ( is_protected_meta( $metakey, "post" ) || ! current_user_can( "add_post_meta", $post_ID, $metakey ) ) then
--                         return false;
--                 end;

--                 $metakey = wp_slash( $metakey );

--                 return add_post_meta( $post_ID, $metakey, $metavalue );
--         end;

--         return false;
-- end;

-- --
-- -- Deletes post meta data by meta ID.
-- --
-- -- @since 1.2.0
-- --
-- -- @param int $mid
-- -- @return bool
-- --
-- function delete_meta( $mid ) then
--         return delete_metadata_by_mid( "post", $mid );
-- end;

-- --
-- -- Returns a list of previously defined keys.
-- --
-- -- @since 1.2.0
-- --
-- -- @global wpdb $wpdb WordPress database abstraction object.
-- --
-- -- @return string[] Array of meta key names.
-- --
-- function get_meta_keys() then
--         global $wpdb;

--         $keys = $wpdb->get_col(
--                 "
--                         SELECT meta_key
--                         FROM $wpdb->postmeta
--                         GROUP BY meta_key
--                         ORDER BY meta_key"
--         );

--         return $keys;
-- end;

-- --
-- -- Returns post meta data by meta ID.
-- --
-- -- @since 2.1.0
-- --
-- -- @param int $mid
-- -- @return object|bool
-- --
-- function get_post_meta_by_id( $mid ) then
--         return get_metadata_by_mid( "post", $mid );
-- end;

-- --
-- -- Returns meta data for the given post ID.
-- --
-- -- @since 1.2.0
-- --
-- -- @global wpdb $wpdb WordPress database abstraction object.
-- --
-- -- @param int $postid A post ID.
-- -- @return array[] then
-- --     Array of meta data arrays for the given post ID.
-- --
-- --     @type array ...$0 then
-- --         Associative array of meta data.
-- --
-- --         @type string $meta_key   Meta key.
-- --         @type mixed  $meta_value Meta value.
-- --         @type string $meta_id    Meta ID as a numeric string.
-- --         @type string $post_id    Post ID as a numeric string.
-- --     end;
-- -- end;
-- --
-- function has_meta( $postid ) then
--         global $wpdb;

--         return $wpdb->get_results(
--                 $wpdb->prepare(
--                         "SELECT meta_key, meta_value, meta_id, post_id
--                         FROM $wpdb->postmeta WHERE post_id = %d
--                         ORDER BY meta_key,meta_id",
--                         $postid
--                 ),
--                 ARRAY_A
--         );
-- end;

-- --
-- -- Updates post meta data by meta ID.
-- --
-- -- @since 1.2.0
-- --
-- -- @param int    $meta_id    Meta ID.
-- -- @param string $meta_key   Meta key. Expect slashed.
-- -- @param string $meta_value Meta value. Expect slashed.
-- -- @return bool
-- --
-- function update_meta( $meta_id, $meta_key, $meta_value ) then
--         $meta_key   = wp_unslash( $meta_key );
--         $meta_value = wp_unslash( $meta_value );

--         return update_metadata_by_mid( "post", $meta_id, $meta_value, $meta_key );
-- end;

-- --
-- -- Private.
-- --

-- --
-- -- Replaces hrefs of attachment anchors with up-to-date permalinks.
-- --
-- -- @since 2.3.0
-- -- @access private
-- --
-- -- @param int|object $post Post ID or post object.
-- -- @return void|int|WP_Error Void if nothing fixed. 0 or WP_Error on update failure. The post ID on update success.
-- --
-- function _fix_attachment_links( $post ) then
--         $post    = get_post( $post, ARRAY_A );
--         $content = $post["post_content"];

--         -- Don"t run if no pretty permalinks or post is not published, scheduled, or privately published.
--         if ( ! get_option( "permalink_structure" ) || ! in_array( $post["post_status"], array( "publish", "future", "private" ), true ) ) then
--                 return;
--         end;

--         -- Short if there aren"t any links or no "?attachment_id=" strings (strpos cannot be zero).
--         if ( ! strpos( $content, "?attachment_id=" ) || ! preg_match_all( "/<a ([^>]+)>[\s\S]+?<\/a>/", $content, $link_matches ) ) then
--                 return;
--         end;

--         $site_url = get_bloginfo( "url" );
--         $site_url = substr( $site_url, (int) strpos( $site_url, ":--" ) ); -- Remove the http(s).
--         $replace  = "";

--         foreach ( $link_matches[1] as $key => $value ) then
--                 if ( ! strpos( $value, "?attachment_id=" ) || ! strpos( $value, "wp-att-" )
--                         || ! preg_match( "/href=(["\"])[^"\"]*\?attachment_id=(\d+)[^"\"]*\\1/", $value, $url_match )
--                         || ! preg_match( "/rel=["\"][^"\"]*wp-att-(\d+)/", $value, $rel_match ) ) then
--                                 continue;
--                 end;

--                 $quote  = $url_match[1]; -- The quote (single or double).
--                 $url_id = (int) $url_match[2];
--                 $rel_id = (int) $rel_match[1];

--                 if ( ! $url_id || ! $rel_id || $url_id != $rel_id || strpos( $url_match[0], $site_url ) === false ) then
--                         continue;
--                 end;

--                 $link    = $link_matches[0][ $key ];
--                 $replace = str_replace( $url_match[0], "href=" . $quote . get_attachment_link( $url_id ) . $quote, $link );

--                 $content = str_replace( $link, $replace, $content );
--         end;

--         if ( $replace ) then
--                 $post["post_content"] = $content;
--                 -- Escape data pulled from DB.
--                 $post = add_magic_quotes( $post );

--                 return wp_update_post( $post );
--         end;
-- end;

-- --
-- -- Returns all the possible statuses for a post type.
-- --
-- -- @since 2.5.0
-- --
-- -- @param string $type The post_type you want the statuses for. Default "post".
-- -- @return string[] An array of all the statuses for the supplied post type.
-- --
-- function get_available_post_statuses( $type = "post" ) then
--         $stati = wp_count_posts( $type );

--         return array_keys( get_object_vars( $stati ) );
-- end;

-- --
-- -- Runs the query to fetch the posts for listing on the edit posts page.
-- --
-- -- @since 2.5.0
-- --
-- -- @param array|false $q Optional. Array of query variables to use to build the query.
-- --                       Defaults to the `$_GET` superglobal.
-- -- @return array
-- --
-- function wp_edit_posts_query( $q = false ) then
--         if ( false === $q ) then
--                 $q = $_GET;
--         end;
--         $q["m"]     = isset( $q["m"] ) ? (int) $q["m"] : 0;
--         $q["cat"]   = isset( $q["cat"] ) ? (int) $q["cat"] : 0;
--         $post_stati = get_post_stati();

--         if ( isset( $q["post_type"] ) && in_array( $q["post_type"], get_post_types(), true ) ) then
--                 $post_type = $q["post_type"];
--         end; else then
--                 $post_type = "post";
--         end;

--         $avail_post_stati = get_available_post_statuses( $post_type );
--         $post_status      = "";
--         $perm             = "";

--         if ( isset( $q["post_status"] ) && in_array( $q["post_status"], $post_stati, true ) ) then
--                 $post_status = $q["post_status"];
--                 $perm        = "readable";
--         end;

--         $orderby = "";

--         if ( isset( $q["orderby"] ) ) then
--                 $orderby = $q["orderby"];
--         end; elseif ( isset( $q["post_status"] ) && in_array( $q["post_status"], array( "pending", "draft" ), true ) ) then
--                 $orderby = "modified";
--         end;

--         $order = "";

--         if ( isset( $q["order"] ) ) then
--                 $order = $q["order"];
--         end; elseif ( isset( $q["post_status"] ) && "pending" === $q["post_status"] ) then
--                 $order = "ASC";
--         end;

--         $per_page       = "edit_then$post_typeend;_per_page";
--         $posts_per_page = (int) get_user_option( $per_page );
--         if ( empty( $posts_per_page ) || $posts_per_page < 1 ) then
--                 $posts_per_page = 20;
--         end;

--         --
--         -- Filters the number of items per page to show for a specific "per_page" type.
--         --
--         -- The dynamic portion of the hook name, `$post_type`, refers to the post type.
--         --
--         -- Possible hook names include:
--         --
--         --  - `edit_post_per_page`
--         --  - `edit_page_per_page`
--         --  - `edit_attachment_per_page`
--         --
--         -- @since 3.0.0
--         --
--         -- @param int $posts_per_page Number of posts to display per page for the given post
--         --                            type. Default 20.
--         --
--         $posts_per_page = apply_filters( "edit_then$post_typeend;_per_page", $posts_per_page );

--         --
--         -- Filters the number of posts displayed per page when specifically listing "posts".
--         --
--         -- @since 2.8.0
--         --
--         -- @param int    $posts_per_page Number of posts to be displayed. Default 20.
--         -- @param string $post_type      The post type.
--         --
--         $posts_per_page = apply_filters( "edit_posts_per_page", $posts_per_page, $post_type );

--         $query = compact( "post_type", "post_status", "perm", "order", "orderby", "posts_per_page" );

--         -- Hierarchical types require special args.
--         if ( is_post_type_hierarchical( $post_type ) && empty( $orderby ) ) then
--                 $query["orderby"]                = "menu_order title";
--                 $query["order"]                  = "asc";
--                 $query["posts_per_page"]         = -1;
--                 $query["posts_per_archive_page"] = -1;
--                 $query["fields"]                 = "id=>parent";
--         end;

--         if ( ! empty( $q["show_sticky"] ) ) then
--                 $query["post__in"] = (array) get_option( "sticky_posts" );
--         end;

--         wp( $query );

--         return $avail_post_stati;
-- end;

-- --
-- -- Returns the query variables for the current attachments request.
-- --
-- -- @since 4.2.0
-- --
-- -- @param array|false $q Optional. Array of query variables to use to build the query.
-- --                       Defaults to the `$_GET` superglobal.
-- -- @return array The parsed query vars.
-- --
-- function wp_edit_attachments_query_vars( $q = false ) then
--         if ( false === $q ) then
--                 $q = $_GET;
--         end;
--         $q["m"]         = isset( $q["m"] ) ? (int) $q["m"] : 0;
--         $q["cat"]       = isset( $q["cat"] ) ? (int) $q["cat"] : 0;
--         $q["post_type"] = "attachment";
--         $post_type      = get_post_type_object( "attachment" );
--         $states         = "inherit";
--         if ( current_user_can( $post_type->cap->read_private_posts ) ) then
--                 $states .= ",private";
--         end;

--         $q["post_status"] = isset( $q["status"] ) && "trash" === $q["status"] ? "trash" : $states;
--         $q["post_status"] = isset( $q["attachment-filter"] ) && "trash" === $q["attachment-filter"] ? "trash" : $states;

--         $media_per_page = (int) get_user_option( "upload_per_page" );
--         if ( empty( $media_per_page ) || $media_per_page < 1 ) then
--                 $media_per_page = 20;
--         end;

--         --
--         -- Filters the number of items to list per page when listing media items.
--         --
--         -- @since 2.9.0
--         --
--         -- @param int $media_per_page Number of media to list. Default 20.
--         --
--         $q["posts_per_page"] = apply_filters( "upload_per_page", $media_per_page );

--         $post_mime_types = get_post_mime_types();
--         if ( isset( $q["post_mime_type"] ) && ! array_intersect( (array) $q["post_mime_type"], array_keys( $post_mime_types ) ) ) then
--                 unset( $q["post_mime_type"] );
--         end;

--         foreach ( array_keys( $post_mime_types ) as $type ) then
--                 if ( isset( $q["attachment-filter"] ) && "post_mime_type:$type" === $q["attachment-filter"] ) then
--                         $q["post_mime_type"] = $type;
--                         break;
--                 end;
--         end;

--         if ( isset( $q["detached"] ) || ( isset( $q["attachment-filter"] ) && "detached" === $q["attachment-filter"] ) ) then
--                 $q["post_parent"] = 0;
--         end;

--         if ( isset( $q["mine"] ) || ( isset( $q["attachment-filter"] ) && "mine" === $q["attachment-filter"] ) ) then
--                 $q["author"] = get_current_user_id();
--         end;

--         -- Filter query clauses to include filenames.
--         if ( isset( $q["s"] ) ) then
--                 add_filter( "wp_allow_query_attachment_by_filename", "__return_true" );
--         end;

--         return $q;
-- end;

-- --
-- -- Executes a query for attachments. An array of WP_Query arguments
-- -- can be passed in, which will override the arguments set by this function.
-- --
-- -- @since 2.5.0
-- --
-- -- @param array|false $q Optional. Array of query variables to use to build the query.
-- --                       Defaults to the `$_GET` superglobal.
-- -- @return array
-- --
-- function wp_edit_attachments_query( $q = false ) then
--         wp( wp_edit_attachments_query_vars( $q ) );

--         $post_mime_types       = get_post_mime_types();
--         $avail_post_mime_types = get_available_post_mime_types( "attachment" );

--         return array( $post_mime_types, $avail_post_mime_types );
-- end;

-- --
-- -- Returns the list of classes to be used by a meta box.
-- --
-- -- @since 2.5.0
-- --
-- -- @param string $box_id    Meta box ID (used in the "id" attribute for the meta box).
-- -- @param string $screen_id The screen on which the meta box is shown.
-- -- @return string Space-separated string of class names.
-- --
-- function postbox_classes( $box_id, $screen_id ) then
--         if ( isset( $_GET["edit"] ) && $_GET["edit"] == $box_id ) then
--                 $classes = array( "" );
--         end; elseif ( get_user_option( "closedpostboxes_" . $screen_id ) ) then
--                 $closed = get_user_option( "closedpostboxes_" . $screen_id );
--                 if ( ! is_array( $closed ) ) then
--                         $classes = array( "" );
--                 end; else then
--                         $classes = in_array( $box_id, $closed, true ) ? array( "closed" ) : array( "" );
--                 end;
--         end; else then
--                 $classes = array( "" );
--         end;

--         --
--         -- Filters the postbox classes for a specific screen and box ID combo.
--         --
--         -- The dynamic portions of the hook name, `$screen_id` and `$box_id`, refer to
--         -- the screen ID and meta box ID, respectively.
--         --
--         -- @since 3.2.0
--         --
--         -- @param string[] $classes An array of postbox classes.
--         --
--         $classes = apply_filters( "postbox_classes_then$screen_idend;_then$box_idend;", $classes );

--         return implode( " ", $classes );
-- end;

-- --
-- -- Returns a sample permalink based on the post name.
-- --
-- -- @since 2.5.0
-- --
-- -- @param int|WP_Post $post  Post ID or post object.
-- -- @param string|null $title Optional. Title to override the post"s current title
-- --                           when generating the post name. Default null.
-- -- @param string|null $name  Optional. Name to override the post name. Default null.
-- -- @return array then
-- --     Array containing the sample permalink with placeholder for the post name, and the post name.
-- --
-- --     @type string $0 The permalink with placeholder for the post name.
-- --     @type string $1 The post name.
-- -- end;
-- --
-- function get_sample_permalink( $post, $title = null, $name = null ) then
--         $post = get_post( $post );

--         if ( ! $post ) then
--                 return array( "", "" );
--         end;

--         $ptype = get_post_type_object( $post->post_type );

--         $original_status = $post->post_status;
--         $original_date   = $post->post_date;
--         $original_name   = $post->post_name;
--         $original_filter = $post->filter;

--         -- Hack: get_permalink() would return plain permalink for drafts, so we will fake that our post is published.
--         if ( in_array( $post->post_status, array( "draft", "pending", "future" ), true ) ) then
--                 $post->post_status = "publish";
--                 $post->post_name   = sanitize_title( $post->post_name ? $post->post_name : $post->post_title, $post->ID );
--         end;

--         -- If the user wants to set a new name -- override the current one.
--         -- Note: if empty name is supplied -- use the title instead, see #6072.
--         if ( ! is_null( $name ) ) then
--                 $post->post_name = sanitize_title( $name ? $name : $title, $post->ID );
--         end;

--         $post->post_name = wp_unique_post_slug( $post->post_name, $post->ID, $post->post_status, $post->post_type, $post->post_parent );

--         $post->filter = "sample";

--         $permalink = get_permalink( $post, true );

--         -- Replace custom post_type token with generic pagename token for ease of use.
--         $permalink = str_replace( "%$post->post_type%", "%pagename%", $permalink );

--         -- Handle page hierarchy.
--         if ( $ptype->hierarchical ) then
--                 $uri = get_page_uri( $post );
--                 if ( $uri ) then
--                         $uri = untrailingslashit( $uri );
--                         $uri = strrev( stristr( strrev( $uri ), "/" ) );
--                         $uri = untrailingslashit( $uri );
--                 end;

--                 -- This filter is documented in wp-admin/edit-tag-form.php--
--                 $uri = apply_filters( "editable_slug", $uri, $post );
--                 if ( ! empty( $uri ) ) then
--                         $uri .= "/";
--                 end;
--                 $permalink = str_replace( "%pagename%", "then$uriend;%pagename%", $permalink );
--         end;

--         -- This filter is documented in wp-admin/edit-tag-form.php--
--         $permalink         = array( $permalink, apply_filters( "editable_slug", $post->post_name, $post ) );
--         $post->post_status = $original_status;
--         $post->post_date   = $original_date;
--         $post->post_name   = $original_name;
--         $post->filter      = $original_filter;

--         --
--         -- Filters the sample permalink.
--         --
--         -- @since 4.4.0
--         --
--         -- @param array   $permalink then
--         --     Array containing the sample permalink with placeholder for the post name, and the post name.
--         --
--         --     @type string $0 The permalink with placeholder for the post name.
--         --     @type string $1 The post name.
--         -- end;
--         -- @param int     $post_id Post ID.
--         -- @param string  $title   Post title.
--         -- @param string  $name    Post name (slug).
--         -- @param WP_Post $post    Post object.
--         --
--         return apply_filters( "get_sample_permalink", $permalink, $post->ID, $title, $name, $post );
-- end;

-- --
-- -- Returns the HTML of the sample permalink slug editor.
-- --
-- -- @since 2.5.0
-- --
-- -- @param int|WP_Post $post      Post ID or post object.
-- -- @param string|null $new_title Optional. New title. Default null.
-- -- @param string|null $new_slug  Optional. New slug. Default null.
-- -- @return string The HTML of the sample permalink slug editor.
-- --
-- function get_sample_permalink_html( $post, $new_title = null, $new_slug = null ) then
--         $post = get_post( $post );

--         if ( ! $post ) then
--                 return "";
--         end;

--         list($permalink, $post_name) = get_sample_permalink( $post->ID, $new_title, $new_slug );

--         $view_link      = false;
--         $preview_target = "";

--         if ( current_user_can( "read_post", $post->ID ) ) then
--                 if ( "draft" === $post->post_status || empty( $post->post_name ) ) then
--                         $view_link      = get_preview_post_link( $post );
--                         $preview_target = " target="wp-preview-then$post->IDend;"";
--                 end; else then
--                         if ( "publish" === $post->post_status || "attachment" === $post->post_type ) then
--                                 $view_link = get_permalink( $post );
--                         end; else then
--                                 -- Allow non-published (private, future) to be viewed at a pretty permalink, in case $post->post_name is set.
--                                 $view_link = str_replace( array( "%pagename%", "%postname%" ), $post->post_name, $permalink );
--                         end;
--                 end;
--         end;

--         -- Permalinks without a post/page name placeholder don"t have anything to edit.
--         if ( false === strpos( $permalink, "%postname%" ) && false === strpos( $permalink, "%pagename%" ) ) then
--                 $return = "<strong>" . __( "Permalink:" ) . "</strong>\n";

--                 if ( false !== $view_link ) then
--                         $display_link = urldecode( $view_link );
--                         $return      .= "<a id="sample-permalink" href="" . esc_url( $view_link ) . """ . $preview_target . ">" . esc_html( $display_link ) . "</a>\n";
--                 end; else then
--                         $return .= "<span id="sample-permalink">" . $permalink . "</span>\n";
--                 end;

--                 -- Encourage a pretty permalink setting.
--                 if ( ! get_option( "permalink_structure" ) && current_user_can( "manage_options" )
--                         && ! ( "page" === get_option( "show_on_front" ) && get_option( "page_on_front" ) == $post->ID )
--                 ) then
--                         $return .= "<span id="change-permalinks"><a href="options-permalink.php" class="button button-small">" . __( "Change Permalink Structure" ) . "</a></span>\n";
--                 end;
--         end; else then
--                 if ( mb_strlen( $post_name ) > 34 ) then
--                         $post_name_abridged = mb_substr( $post_name, 0, 16 ) . "&hellip;" . mb_substr( $post_name, -16 );
--                 end; else then
--                         $post_name_abridged = $post_name;
--                 end;

--                 $post_name_html = "<span id="editable-post-name">" . esc_html( $post_name_abridged ) . "</span>";
--                 $display_link   = str_replace( array( "%pagename%", "%postname%" ), $post_name_html, esc_html( urldecode( $permalink ) ) );

--                 $return  = "<strong>" . __( "Permalink:" ) . "</strong>\n";
--                 $return .= "<span id="sample-permalink"><a href="" . esc_url( $view_link ) . """ . $preview_target . ">" . $display_link . "</a></span>\n";
--                 $return .= "&lrm;"; -- Fix bi-directional text display defect in RTL languages.
--                 $return .= "<span id="edit-slug-buttons"><button type="button" class="edit-slug button button-small hide-if-no-js" aria-label="" . __( "Edit permalink" ) . "">" . __( "Edit" ) . "</button></span>\n";
--                 $return .= "<span id="editable-post-name-full">" . esc_html( $post_name ) . "</span>\n";
--         end;

--         --
--         -- Filters the sample permalink HTML markup.
--         --
--         -- @since 2.9.0
--         -- @since 4.4.0 Added `$post` parameter.
--         --
--         -- @param string  $return    Sample permalink HTML markup.
--         -- @param int     $post_id   Post ID.
--         -- @param string  $new_title New sample permalink title.
--         -- @param string  $new_slug  New sample permalink slug.
--         -- @param WP_Post $post      Post object.
--         --
--         $return = apply_filters( "get_sample_permalink_html", $return, $post->ID, $new_title, $new_slug, $post );

--         return $return;
-- end;

-- --
-- -- Returns HTML for the post thumbnail meta box.
-- --
-- -- @since 2.9.0
-- --
-- -- @param int|null         $thumbnail_id Optional. Thumbnail attachment ID. Default null.
-- -- @param int|WP_Post|null $post         Optional. The post ID or object associated
-- --                                       with the thumbnail. Defaults to global $post.
-- -- @return string The post thumbnail HTML.
-- --
-- function _wp_post_thumbnail_html( $thumbnail_id = null, $post = null ) then
--         $_wp_additional_image_sizes = wp_get_additional_image_sizes();

--         $post               = get_post( $post );
--         $post_type_object   = get_post_type_object( $post->post_type );
--         $set_thumbnail_link = "<p class="hide-if-no-js"><a href="%s" id="set-post-thumbnail"%s class="thickbox">%s</a></p>";
--         $upload_iframe_src  = get_upload_iframe_src( "image", $post->ID );

--         $content = sprintf(
--                 $set_thumbnail_link,
--                 esc_url( $upload_iframe_src ),
--                 "", -- Empty when there"s no featured image set, `aria-describedby` attribute otherwise.
--                 esc_html( $post_type_object->labels->set_featured_image )
--         );

--         if ( $thumbnail_id && get_post( $thumbnail_id ) ) then
--                 $size = isset( $_wp_additional_image_sizes["post-thumbnail"] ) ? "post-thumbnail" : array( 266, 266 );

--                 --
--                 -- Filters the size used to display the post thumbnail image in the "Featured image" meta box.
--                 --
--                 -- Note: When a theme adds "post-thumbnail" support, a special "post-thumbnail"
--                 -- image size is registered, which differs from the "thumbnail" image size
--                 -- managed via the Settings > Media screen.
--                 --
--                 -- @since 4.4.0
--                 --
--                 -- @param string|int[] $size         Requested image size. Can be any registered image size name, or
--                 --                                   an array of width and height values in pixels (in that order).
--                 -- @param int          $thumbnail_id Post thumbnail attachment ID.
--                 -- @param WP_Post      $post         The post object associated with the thumbnail.
--                 --
--                 $size = apply_filters( "admin_post_thumbnail_size", $size, $thumbnail_id, $post );

--                 $thumbnail_html = wp_get_attachment_image( $thumbnail_id, $size );

--                 if ( ! empty( $thumbnail_html ) ) then
--                         $content  = sprintf(
--                                 $set_thumbnail_link,
--                                 esc_url( $upload_iframe_src ),
--                                 " aria-describedby="set-post-thumbnail-desc"",
--                                 $thumbnail_html
--                         );
--                         $content .= "<p class="hide-if-no-js howto" id="set-post-thumbnail-desc">" . __( "Click the image to edit or update" ) . "</p>";
--                         $content .= "<p class="hide-if-no-js"><a href="#" id="remove-post-thumbnail">" . esc_html( $post_type_object->labels->remove_featured_image ) . "</a></p>";
--                 end;
--         end;

--         $content .= "<input type="hidden" id="_thumbnail_id" name="_thumbnail_id" value="" . esc_attr( $thumbnail_id ? $thumbnail_id : "-1" ) . "" />";

--         --
--         -- Filters the admin post thumbnail HTML markup to return.
--         --
--         -- @since 2.9.0
--         -- @since 3.5.0 Added the `$post_id` parameter.
--         -- @since 4.6.0 Added the `$thumbnail_id` parameter.
--         --
--         -- @param string   $content      Admin post thumbnail HTML markup.
--         -- @param int      $post_id      Post ID.
--         -- @param int|null $thumbnail_id Thumbnail attachment ID, or null if there isn"t one.
--         --
--         return apply_filters( "admin_post_thumbnail_html", $content, $post->ID, $thumbnail_id );
-- end;

-- --
-- -- Determines whether the post is currently being edited by another user.
-- --
-- -- @since 2.5.0
-- --
-- -- @param int|WP_Post $post ID or object of the post to check for editing.
-- -- @return int|false ID of the user with lock. False if the post does not exist, post is not locked,
-- --                   the user with lock does not exist, or the post is locked by current user.
-- --
-- function wp_check_post_lock( $post ) then
--         $post = get_post( $post );

--         if ( ! $post ) then
--                 return false;
--         end;

--         $lock = get_post_meta( $post->ID, "_edit_lock", true );

--         if ( ! $lock ) then
--                 return false;
--         end;

--         $lock = explode( ":", $lock );
--         $time = $lock[0];
--         $user = isset( $lock[1] ) ? $lock[1] : get_post_meta( $post->ID, "_edit_last", true );

--         if ( ! get_userdata( $user ) ) then
--                 return false;
--         end;

--         -- This filter is documented in wp-admin/includes/ajax-actions.php--
--         $time_window = apply_filters( "wp_check_post_lock_window", 150 );

--         if ( $time && $time > time() - $time_window && get_current_user_id() != $user ) then
--                 return $user;
--         end;

--         return false;
-- end;

-- --
-- -- Marks the post as currently being edited by the current user.
-- --
-- -- @since 2.5.0
-- --
-- -- @param int|WP_Post $post ID or object of the post being edited.
-- -- @return array|false then
-- --     Array of the lock time and user ID. False if the post does not exist, or there
-- --     is no current user.
-- --
-- --     @type int $0 The current time as a Unix timestamp.
-- --     @type int $1 The ID of the current user.
-- -- end;
-- --
-- function wp_set_post_lock( $post ) then
--         $post = get_post( $post );

--         if ( ! $post ) then
--                 return false;
--         end;

--         $user_id = get_current_user_id();

--         if ( 0 == $user_id ) then
--                 return false;
--         end;

--         $now  = time();
--         $lock = "$now:$user_id";

--         update_post_meta( $post->ID, "_edit_lock", $lock );

--         return array( $now, $user_id );
-- end;

-- --
-- -- Outputs the HTML for the notice to say that someone else is editing or has taken over editing of this post.
-- --
-- -- @since 2.8.5
-- --
-- function _admin_notice_post_locked() then
--         $post = get_post();

--         if ( ! $post ) then
--                 return;
--         end;

--         $user    = null;
--         $user_id = wp_check_post_lock( $post->ID );

--         if ( $user_id ) then
--                 $user = get_userdata( $user_id );
--         end;

--         if ( $user ) then
--                 --
--                 -- Filters whether to show the post locked dialog.
--                 --
--                 -- Returning false from the filter will prevent the dialog from being displayed.
--                 --
--                 -- @since 3.6.0
--                 --
--                 -- @param bool    $display Whether to display the dialog. Default true.
--                 -- @param WP_Post $post    Post object.
--                 -- @param WP_User $user    The user with the lock for the post.
--                 --
--                 if ( ! apply_filters( "show_post_locked_dialog", true, $post, $user ) ) then
--                         return;
--                 end;

--                 $locked = true;
--         end; else then
--                 $locked = false;
--         end;

--         $sendback = wp_get_referer();
--         if ( $locked && $sendback && false === strpos( $sendback, "post.php" ) && false === strpos( $sendback, "post-new.php" ) ) then

--                 $sendback_text = __( "Go back" );
--         end; else then
--                 $sendback = admin_url( "edit.php" );

--                 if ( "post" !== $post->post_type ) then
--                         $sendback = add_query_arg( "post_type", $post->post_type, $sendback );
--                 end;

--                 $sendback_text = get_post_type_object( $post->post_type )->labels->all_items;
--         end;

--         $hidden = $locked ? "" : " hidden";

--         ?>
--         <div id="post-lock-dialog" class="notification-dialog-wrap<?php echo $hidden; ?>">
--         <div class="notification-dialog-background"></div>
--         <div class="notification-dialog">
--         <?php

--         if ( $locked ) then
--                 $query_args = array();
--                 if ( get_post_type_object( $post->post_type )->public ) then
--                         if ( "publish" === $post->post_status || $user->ID != $post->post_author ) then
--                                 -- Latest content is in autosave.
--                                 $nonce                       = wp_create_nonce( "post_preview_" . $post->ID );
--                                 $query_args["preview_id"]    = $post->ID;
--                                 $query_args["preview_nonce"] = $nonce;
--                         end;
--                 end;

--                 $preview_link = get_preview_post_link( $post->ID, $query_args );

--                 --
--                 -- Filters whether to allow the post lock to be overridden.
--                 --
--                 -- Returning false from the filter will disable the ability
--                 -- to override the post lock.
--                 --
--                 -- @since 3.6.0
--                 --
--                 -- @param bool    $override Whether to allow the post lock to be overridden. Default true.
--                 -- @param WP_Post $post     Post object.
--                 -- @param WP_User $user     The user with the lock for the post.
--                 --
--                 $override = apply_filters( "override_post_lock", true, $post, $user );
--                 $tab_last = $override ? "" : " wp-tab-last";

--                 ?>
--                 <div class="post-locked-message">
--                 <div class="post-locked-avatar"><?php echo get_avatar( $user->ID, 64 ); ?></div>
--                 <p class="currently-editing wp-tab-first" tabindex="0">
--                 <?php
--                 if ( $override ) then
--                         /* translators: %s: User"s display name.--
--                         printf( __( "%s is currently editing this post. Do you want to take over?" ), esc_html( $user->display_name ) );
--                 end; else then
--                         /* translators: %s: User"s display name.--
--                         printf( __( "%s is currently editing this post." ), esc_html( $user->display_name ) );
--                 end;
--                 ?>
--                 </p>
--                 <?php
--                 --
--                 -- Fires inside the post locked dialog before the buttons are displayed.
--                 --
--                 -- @since 3.6.0
--                 -- @since 5.4.0 The $user parameter was added.
--                 --
--                 -- @param WP_Post $post Post object.
--                 -- @param WP_User $user The user with the lock for the post.
--                 --
--                 do_action( "post_locked_dialog", $post, $user );
--                 ?>
--                 <p>
--                 <a class="button" href="<?php echo esc_url( $sendback ); ?>"><?php echo $sendback_text; ?></a>
--                 <?php if ( $preview_link ) then ?>
--                 <a class="button<?php echo $tab_last; ?>" href="<?php echo esc_url( $preview_link ); ?>"><?php _e( "Preview" ); ?></a>
--                         <?php
--                 end;

--                 -- Allow plugins to prevent some users overriding the post lock.
--                 if ( $override ) then
--                         ?>
--         <a class="button button-primary wp-tab-last" href="<?php echo esc_url( add_query_arg( "get-post-lock", "1", wp_nonce_url( get_edit_post_link( $post->ID, "url" ), "lock-post_" . $post->ID ) ) ); ?>"><?php _e( "Take over" ); ?></a>
--                         <?php
--                 end;

--                 ?>
--                 </p>
--                 </div>
--                 <?php
--         end; else then
--                 ?>
--                 <div class="post-taken-over">
--                         <div class="post-locked-avatar"></div>
--                         <p class="wp-tab-first" tabindex="0">
--                         <span class="currently-editing"></span><br />
--                         <span class="locked-saving hidden"><img src="<?php echo esc_url( admin_url( "images/spinner-2x.gif" ) ); ?>" width="16" height="16" alt="" /> <?php _e( "Saving revision&hellip;" ); ?></span>
--                         <span class="locked-saved hidden"><?php _e( "Your latest changes were saved as a revision." ); ?></span>
--                         </p>
--                         <?php
--                         --
--                         -- Fires inside the dialog displayed when a user has lost the post lock.
--                         --
--                         -- @since 3.6.0
--                         --
--                         -- @param WP_Post $post Post object.
--                         --
--                         do_action( "post_lock_lost_dialog", $post );
--                         ?>
--                         <p><a class="button button-primary wp-tab-last" href="<?php echo esc_url( $sendback ); ?>"><?php echo $sendback_text; ?></a></p>
--                 </div>
--                 <?php
--         end;

--         ?>
--         </div>
--         </div>
--         <?php
-- end;

-- --
-- -- Creates autosave data for the specified post from `$_POST` data.
-- --
-- -- @since 2.6.0
-- --
-- -- @param array|int $post_data Associative array containing the post data, or integer post ID.
-- --                             If a numeric post ID is provided, will use the `$_POST` superglobal.
-- -- @return int|WP_Error The autosave revision ID. WP_Error or 0 on error.
-- --
-- function wp_create_post_autosave( $post_data ) then
--         if ( is_numeric( $post_data ) ) then
--                 $post_id   = $post_data;
--                 $post_data = $_POST;
--         end; else then
--                 $post_id = (int) $post_data["post_ID"];
--         end;

--         $post_data = _wp_translate_postdata( true, $post_data );
--         if ( is_wp_error( $post_data ) ) then
--                 return $post_data;
--         end;
--         $post_data = _wp_get_allowed_postdata( $post_data );

--         $post_author = get_current_user_id();

--         -- Store one autosave per author. If there is already an autosave, overwrite it.
--         $old_autosave = wp_get_post_autosave( $post_id, $post_author );
--         if ( $old_autosave ) then
--                 $new_autosave                = _wp_post_revision_data( $post_data, true );
--                 $new_autosave["ID"]          = $old_autosave->ID;
--                 $new_autosave["post_author"] = $post_author;

--                 $post = get_post( $post_id );

--                 -- If the new autosave has the same content as the post, delete the autosave.
--                 $autosave_is_different = false;
--                 foreach ( array_intersect( array_keys( $new_autosave ), array_keys( _wp_post_revision_fields( $post ) ) ) as $field ) then
--                         if ( normalize_whitespace( $new_autosave[ $field ] ) !== normalize_whitespace( $post->$field ) ) then
--                                 $autosave_is_different = true;
--                                 break;
--                         end;
--                 end;

--                 if ( ! $autosave_is_different ) then
--                         wp_delete_post_revision( $old_autosave->ID );
--                         return 0;
--                 end;

--                 --
--                 -- Fires before an autosave is stored.
--                 --
--                 -- @since 4.1.0
--                 --
--                 -- @param array $new_autosave Post array - the autosave that is about to be saved.
--                 --
--                 do_action( "wp_creating_autosave", $new_autosave );

--                 return wp_update_post( $new_autosave );
--         end;

--         -- _wp_put_post_revision() expects unescaped.
--         $post_data = wp_unslash( $post_data );

--         -- Otherwise create the new autosave as a special post revision.
--         return _wp_put_post_revision( $post_data, true );
-- end;

-- --
-- -- Saves a draft or manually autosaves for the purpose of showing a post preview.
-- --
-- -- @since 2.7.0
-- --
-- -- @return string URL to redirect to show the preview.
-- --
-- function post_preview() then

--         $post_ID     = (int) $_POST["post_ID"];
--         $_POST["ID"] = $post_ID;

--         $post = get_post( $post_ID );

--         if ( ! $post ) then
--                 wp_die( __( "Sorry, you are not allowed to edit this post." ) );
--         end;

--         if ( ! current_user_can( "edit_post", $post->ID ) ) then
--                 wp_die( __( "Sorry, you are not allowed to edit this post." ) );
--         end;

--         $is_autosave = false;

--         if ( ! wp_check_post_lock( $post->ID ) && get_current_user_id() == $post->post_author
--                 && ( "draft" === $post->post_status || "auto-draft" === $post->post_status )
--         ) then
--                 $saved_post_id = edit_post();
--         end; else then
--                 $is_autosave = true;

--                 if ( isset( $_POST["post_status"] ) && "auto-draft" === $_POST["post_status"] ) then
--                         $_POST["post_status"] = "draft";
--                 end;

--                 $saved_post_id = wp_create_post_autosave( $post->ID );
--         end;

--         if ( is_wp_error( $saved_post_id ) ) then
--                 wp_die( $saved_post_id->get_error_message() );
--         end;

--         $query_args = array();

--         if ( $is_autosave && $saved_post_id ) then
--                 $query_args["preview_id"]    = $post->ID;
--                 $query_args["preview_nonce"] = wp_create_nonce( "post_preview_" . $post->ID );

--                 if ( isset( $_POST["post_format"] ) ) then
--                         $query_args["post_format"] = empty( $_POST["post_format"] ) ? "standard" : sanitize_key( $_POST["post_format"] );
--                 end;

--                 if ( isset( $_POST["_thumbnail_id"] ) ) then
--                         $query_args["_thumbnail_id"] = ( (int) $_POST["_thumbnail_id"] <= 0 ) ? "-1" : (int) $_POST["_thumbnail_id"];
--                 end;
--         end;

--         return get_preview_post_link( $post, $query_args );
-- end;

-- --
-- -- Saves a post submitted with XHR.
-- --
-- -- Intended for use with heartbeat and autosave.js
-- --
-- -- @since 3.9.0
-- --
-- -- @param array $post_data Associative array of the submitted post data.
-- -- @return mixed The value 0 or WP_Error on failure. The saved post ID on success.
-- --               The ID can be the draft post_id or the autosave revision post_id.
-- --
-- function wp_autosave( $post_data ) then
--         -- Back-compat.
--         if ( ! defined( "DOING_AUTOSAVE" ) ) then
--                 define( "DOING_AUTOSAVE", true );
--         end;

--         $post_id              = (int) $post_data["post_id"];
--         $post_data["ID"]      = $post_id;
--         $post_data["post_ID"] = $post_id;

--         if ( false === wp_verify_nonce( $post_data["_wpnonce"], "update-post_" . $post_id ) ) then
--                 return new WP_Error( "invalid_nonce", __( "Error while saving." ) );
--         end;

--         $post = get_post( $post_id );

--         if ( ! current_user_can( "edit_post", $post->ID ) ) then
--                 return new WP_Error( "edit_posts", __( "Sorry, you are not allowed to edit this item." ) );
--         end;

--         if ( "auto-draft" === $post->post_status ) then
--                 $post_data["post_status"] = "draft";
--         end;

--         if ( "page" !== $post_data["post_type"] && ! empty( $post_data["catslist"] ) ) then
--                 $post_data["post_category"] = explode( ",", $post_data["catslist"] );
--         end;

--         if ( ! wp_check_post_lock( $post->ID ) && get_current_user_id() == $post->post_author
--                 && ( "auto-draft" === $post->post_status || "draft" === $post->post_status )
--         ) then
--                 -- Drafts and auto-drafts are just overwritten by autosave for the same user if the post is not locked.
--                 return edit_post( wp_slash( $post_data ) );
--         end; else then
--                 -- Non-drafts or other users' drafts are not overwritten.
--                 -- The autosave is stored in a special post revision for each user.
--                 return wp_create_post_autosave( wp_slash( $post_data ) );
--         end;
-- end;

-- --
-- -- Redirects to previous page.
-- --
-- -- @since 2.7.0
-- --
-- -- @param int $post_id Optional. Post ID.
-- --
-- function redirect_post( $post_id = "" ) then
--         if ( isset( $_POST["save"] ) || isset( $_POST["publish"] ) ) then
--                 $status = get_post_status( $post_id );

--                 if ( isset( $_POST["publish"] ) ) then
--                         switch ( $status ) then
--                                 case "pending":
--                                         $message = 8;
--                                         break;
--                                 case "future":
--                                         $message = 9;
--                                         break;
--                                 default:
--                                         $message = 6;
--                         end;
--                 end; else then
--                         $message = "draft" === $status ? 10 : 1;
--                 end;

--                 $location = add_query_arg( "message", $message, get_edit_post_link( $post_id, "url" ) );
--         end; elseif ( isset( $_POST["addmeta"] ) && $_POST["addmeta"] ) then
--                 $location = add_query_arg( "message", 2, wp_get_referer() );
--                 $location = explode( "#", $location );
--                 $location = $location[0] . "#postcustom";
--         end; elseif ( isset( $_POST["deletemeta"] ) && $_POST["deletemeta"] ) then
--                 $location = add_query_arg( "message", 3, wp_get_referer() );
--                 $location = explode( "#", $location );
--                 $location = $location[0] . "#postcustom";
--         end; else then
--                 $location = add_query_arg( "message", 4, get_edit_post_link( $post_id, "url" ) );
--         end;

--         --
--         -- Filters the post redirect destination URL.
--         --
--         -- @since 2.9.0
--         --
--         -- @param string $location The destination URL.
--         -- @param int    $post_id  The post ID.
--         --
--         wp_redirect( apply_filters( "redirect_post_location", $location, $post_id ) );
--         exit;
-- end;

-- --
-- -- Sanitizes POST values from a checkbox taxonomy metabox.
-- --
-- -- @since 5.1.0
-- --
-- -- @param string $taxonomy The taxonomy name.
-- -- @param array  $terms    Raw term data from the "tax_input" field.
-- -- @return int[] Array of sanitized term IDs.
-- --
-- function taxonomy_meta_box_sanitize_cb_checkboxes( $taxonomy, $terms ) then
--         return array_map( "intval", $terms );
-- end;

-- --
-- -- Sanitizes POST values from an input taxonomy metabox.
-- --
-- -- @since 5.1.0
-- --
-- -- @param string       $taxonomy The taxonomy name.
-- -- @param array|string $terms    Raw term data from the "tax_input" field.
-- -- @return array
-- --
-- function taxonomy_meta_box_sanitize_cb_input( $taxonomy, $terms ) then
--         /*
--         -- Assume that a "tax_input" string is a comma-separated list of term names.
--         -- Some languages may use a character other than a comma as a delimiter, so we standardize on
--         -- commas before parsing the list.
--         --
--         if ( ! is_array( $terms ) ) then
--                 $comma = _x( ",", "tag delimiter" );
--                 if ( "," !== $comma ) then
--                         $terms = str_replace( $comma, ",", $terms );
--                 end;
--                 $terms = explode( ",", trim( $terms, " \n\t\r\0\x0B," ) );
--         end;

--         $clean_terms = array();
--         foreach ( $terms as $term ) then
--                 -- Empty terms are invalid input.
--                 if ( empty( $term ) ) then
--                         continue;
--                 end;

--                 $_term = get_terms(
--                         array(
--                                 "taxonomy"   => $taxonomy,
--                                 "name"       => $term,
--                                 "fields"     => "ids",
--                                 "hide_empty" => false,
--                         )
--                 );

--                 if ( ! empty( $_term ) ) then
--                         $clean_terms[] = (int) $_term[0];
--                 end; else then
--                         -- No existing term was found, so pass the string. A new term will be created.
--                         $clean_terms[] = $term;
--                 end;
--         end;

--         return $clean_terms;
-- end;

-- --
-- -- Prepares server-registered blocks for the block editor.
-- --
-- -- Returns an associative array of registered block data keyed by block name. Data includes properties
-- -- of a block relevant for client registration.
-- --
-- -- @since 5.0.0
-- --
-- -- @return array An associative array of registered block data.
-- --
-- function get_block_editor_server_block_settings() then
--         $block_registry = WP_Block_Type_Registry::get_instance();
--         $blocks         = array();
--         $fields_to_pick = array(
--                 "api_version"      => "apiVersion",
--                 "title"            => "title",
--                 "description"      => "description",
--                 "icon"             => "icon",
--                 "attributes"       => "attributes",
--                 "provides_context" => "providesContext",
--                 "uses_context"     => "usesContext",
--                 "supports"         => "supports",
--                 "category"         => "category",
--                 "styles"           => "styles",
--                 "textdomain"       => "textdomain",
--                 "parent"           => "parent",
--                 "ancestor"         => "ancestor",
--                 "keywords"         => "keywords",
--                 "example"          => "example",
--                 "variations"       => "variations",
--         );

--         foreach ( $block_registry->get_all_registered() as $block_name => $block_type ) then
--                 foreach ( $fields_to_pick as $field => $key ) then
--                         if ( ! isset( $block_type->then $field end; ) ) then
--                                 continue;
--                         end;

--                         if ( ! isset( $blocks[ $block_name ] ) ) then
--                                 $blocks[ $block_name ] = array();
--                         end;

--                         $blocks[ $block_name ][ $key ] = $block_type->then $field end;;
--                 end;
--         end;

--         return $blocks;
-- end;

-- --
-- -- Renders the meta boxes forms.
-- --
-- -- @since 5.0.0
-- --
-- function the_block_editor_meta_boxes() then
--         global $post, $current_screen, $wp_meta_boxes;

--         -- Handle meta box state.
--         $_original_meta_boxes = $wp_meta_boxes;

--         --
--         -- Fires right before the meta boxes are rendered.
--         --
--         -- This allows for the filtering of meta box data, that should already be
--         -- present by this point. Do not use as a means of adding meta box data.
--         --
--         -- @since 5.0.0
--         --
--         -- @param array $wp_meta_boxes Global meta box state.
--         --
--         $wp_meta_boxes = apply_filters( "filter_block_editor_meta_boxes", $wp_meta_boxes );
--         $locations     = array( "side", "normal", "advanced" );
--         $priorities    = array( "high", "sorted", "core", "default", "low" );

--         -- Render meta boxes.
--         ?>
--         <form class="metabox-base-form">
--         <?php the_block_editor_meta_box_post_form_hidden_fields( $post ); ?>
--         </form>
--         <form id="toggle-custom-fields-form" method="post" action="<?php echo esc_url( admin_url( "post.php" ) ); ?>">
--                 <?php wp_nonce_field( "toggle-custom-fields", "toggle-custom-fields-nonce" ); ?>
--                 <input type="hidden" name="action" value="toggle-custom-fields" />
--         </form>
--         <?php foreach ( $locations as $location ) : ?>
--                 <form class="metabox-location-<?php echo esc_attr( $location ); ?>" onsubmit="return false;">
--                         <div id="poststuff" class="sidebar-open">
--                                 <div id="postbox-container-2" class="postbox-container">
--                                         <?php
--                                         do_meta_boxes(
--                                                 $current_screen,
--                                                 $location,
--                                                 $post
--                                         );
--                                         ?>
--                                 </div>
--                         </div>
--                 </form>
--         <?php endforeach; ?>
--         <?php

--         $meta_boxes_per_location = array();
--         foreach ( $locations as $location ) then
--                 $meta_boxes_per_location[ $location ] = array();

--                 if ( ! isset( $wp_meta_boxes[ $current_screen->id ][ $location ] ) ) then
--                         continue;
--                 end;

--                 foreach ( $priorities as $priority ) then
--                         if ( ! isset( $wp_meta_boxes[ $current_screen->id ][ $location ][ $priority ] ) ) then
--                                 continue;
--                         end;

--                         $meta_boxes = (array) $wp_meta_boxes[ $current_screen->id ][ $location ][ $priority ];
--                         foreach ( $meta_boxes as $meta_box ) then
--                                 if ( false == $meta_box || ! $meta_box["title"] ) then
--                                         continue;
--                                 end;

--                                 -- If a meta box is just here for back compat, don"t show it in the block editor.
--                                 if ( isset( $meta_box["args"]["__back_compat_meta_box"] ) && $meta_box["args"]["__back_compat_meta_box"] ) then
--                                         continue;
--                                 end;

--                                 $meta_boxes_per_location[ $location ][] = array(
--                                         "id"    => $meta_box["id"],
--                                         "title" => $meta_box["title"],
--                                 );
--                         end;
--                 end;
--         end;

--         /*
--         -- Sadly we probably cannot add this data directly into editor settings.
--         --
--         -- Some meta boxes need `admin_head` to fire for meta box registry.
--         -- `admin_head` fires after `admin_enqueue_scripts`, which is where we create
--         -- our editor instance.
--         --
--         $script = "window._wpLoadBlockEditor.then( function() then
--                 wp.data.dispatch( \"core/edit-post\" ).setAvailableMetaBoxesPerLocation( " . wp_json_encode( $meta_boxes_per_location ) . " );
--         end; );";

--         wp_add_inline_script( "wp-edit-post", $script );

--         /*
--         -- When `wp-edit-post` is output in the `<head>`, the inline script needs to be manually printed.
--         -- Otherwise, meta boxes will not display because inline scripts for `wp-edit-post`
--         -- will not be printed again after this point.
--         --
--         if ( wp_script_is( "wp-edit-post", "done" ) ) then
--                 printf( "<script type="text/javascript">\n%s\n</script>\n", trim( $script ) );
--         end;

--         /*
--         -- If the "postcustom" meta box is enabled, then we need to perform
--         -- some extra initialization on it.
--         --
--         $enable_custom_fields = (bool) get_user_meta( get_current_user_id(), "enable_custom_fields", true );

--         if ( $enable_custom_fields ) then
--                 $script = "( function( $ ) then
--                         if ( $("#postcustom").length ) then
--                                 $( "#the-list" ).wpList( then
--                                         addBefore: function( s ) then
--                                                 s.data += "&post_id=$post->ID";
--                                                 return s;
--                                         end;,
--                                         addAfter: function() then
--                                                 $("table#list-table").show();
--                                         end;
--                                 end;);
--                         end;
--                 end; )( jQuery );";
--                 wp_enqueue_script( "wp-lists" );
--                 wp_add_inline_script( "wp-lists", $script );
--         end;

--         /*
--         -- Refresh nonces used by the meta box loader.
--         --
--         -- The logic is very similar to that provided by post.js for the classic editor.
--         --
--         $script = "( function( $ ) then
--                 var check, timeout;

--                 function schedule() then
--                         check = false;
--                         window.clearTimeout( timeout );
--                         timeout = window.setTimeout( function() then check = true; end;, 300000 );
--                 end;

--                 $( document ).on( "heartbeat-send.wp-refresh-nonces", function( e, data ) then
--                         var post_id, \$authCheck = $( "#wp-auth-check-wrap" );

--                         if ( check || ( \$authCheck.length && ! \$authCheck.hasClass( "hidden" ) ) ) then
--                                 if ( ( post_id = $( "#post_ID" ).val() ) && $( "#_wpnonce" ).val() ) then
--                                         data["wp-refresh-metabox-loader-nonces"] = then
--                                                 post_id: post_id
--                                         end;;
--                                 end;
--                         end;
--                 end;).on( "heartbeat-tick.wp-refresh-nonces", function( e, data ) then
--                         var nonces = data["wp-refresh-metabox-loader-nonces"];

--                         if ( nonces ) then
--                                 if ( nonces.replace ) then
--                                         if ( nonces.replace.metabox_loader_nonce && window._wpMetaBoxUrl && wp.url ) then
--                                                 window._wpMetaBoxUrl= wp.url.addQueryArgs( window._wpMetaBoxUrl, then "meta-box-loader-nonce": nonces.replace.metabox_loader_nonce end; );
--                                         end;

--                                         if ( nonces.replace._wpnonce ) then
--                                                 $( "#_wpnonce" ).val( nonces.replace._wpnonce );
--                                         end;
--                                 end;
--                         end;
--                 end;).ready( function() then
--                         schedule();
--                 end;);
--         end; )( jQuery );";
--         wp_add_inline_script( "heartbeat", $script );

--         -- Reset meta box data.
--         $wp_meta_boxes = $_original_meta_boxes;
-- end;

-- --
-- -- Renders the hidden form required for the meta boxes form.
-- --
-- -- @since 5.0.0
-- --
-- -- @param WP_Post $post Current post object.
-- --
-- function the_block_editor_meta_box_post_form_hidden_fields( $post ) then
--         $form_extra = "";
--         if ( "auto-draft" === $post->post_status ) then
--                 $form_extra .= "<input type="hidden" id="auto_draft" name="auto_draft" value="1" />";
--         end;
--         $form_action  = "editpost";
--         $nonce_action = "update-post_" . $post->ID;
--         $form_extra  .= "<input type="hidden" id="post_ID" name="post_ID" value="" . esc_attr( $post->ID ) . "" />";
--         $referer      = wp_get_referer();
--         $current_user = wp_get_current_user();
--         $user_id      = $current_user->ID;
--         wp_nonce_field( $nonce_action );

--         /*
--         -- Some meta boxes hook into these actions to add hidden input fields in the classic post form.
--         -- For backward compatibility, we can capture the output from these actions,
--         -- and extract the hidden input fields.
--         --
--         ob_start();
--         -- This filter is documented in wp-admin/edit-form-advanced.php--
--         do_action( "edit_form_after_title", $post );
--         -- This filter is documented in wp-admin/edit-form-advanced.php--
--         do_action( "edit_form_advanced", $post );
--         $classic_output = ob_get_clean();

--         $classic_elements = wp_html_split( $classic_output );
--         $hidden_inputs    = "";
--         foreach ( $classic_elements as $element ) then
--                 if ( 0 !== strpos( $element, "<input " ) ) then
--                         continue;
--                 end;

--                 if ( preg_match( "/\stype=[\""]hidden[\""]\s/", $element ) ) then
--                         echo $element;
--                 end;
--         end;
--         ?>
--         <input type="hidden" id="user-id" name="user_ID" value="<?php echo (int) $user_id; ?>" />
--         <input type="hidden" id="hiddenaction" name="action" value="<?php echo esc_attr( $form_action ); ?>" />
--         <input type="hidden" id="originalaction" name="originalaction" value="<?php echo esc_attr( $form_action ); ?>" />
--         <input type="hidden" id="post_type" name="post_type" value="<?php echo esc_attr( $post->post_type ); ?>" />
--         <input type="hidden" id="original_post_status" name="original_post_status" value="<?php echo esc_attr( $post->post_status ); ?>" />
--         <input type="hidden" id="referredby" name="referredby" value="<?php echo $referer ? esc_url( $referer ) : ""; ?>" />

--         <?php
--         if ( "draft" !== get_post_status( $post ) ) then
--                 wp_original_referer_field( true, "previous" );
--         end;
--         echo $form_extra;
--         wp_nonce_field( "meta-box-order", "meta-box-order-nonce", false );
--         wp_nonce_field( "closedpostboxes", "closedpostboxesnonce", false );
--         -- Permalink title nonce.
--         wp_nonce_field( "samplepermalink", "samplepermalinknonce", false );

--         --
--         -- Adds hidden input fields to the meta box save form.
--         --
--         -- Hook into this action to print `<input type="hidden" ... />` fields, which will be POSTed back to
--         -- the server when meta boxes are saved.
--         --
--         -- @since 5.0.0
--         --
--         -- @param WP_Post $post The post that is being edited.
--         --
--         do_action( "block_editor_meta_box_hidden_fields", $post );
-- end;

-- --
-- -- Disables block editor for wp_navigation type posts so they can be managed via the UI.
-- --
-- -- @since 5.9.0
-- -- @access private
-- --
-- -- @param bool   $value Whether the CPT supports block editor or not.
-- -- @param string $post_type Post type.
-- -- @return bool Whether the block editor should be disabled or not.
-- --
-- function _disable_block_editor_for_navigation_post_type( $value, $post_type ) then
--         if ( "wp_navigation" === $post_type ) then
--                 return false;
--         end;

--         return $value;
-- end;

-- --
-- -- This callback disables the content editor for wp_navigation type posts.
-- -- Content editor cannot handle wp_navigation type posts correctly.
-- -- We cannot disable the "editor" feature in the wp_navigation"s CPT definition
-- -- because it disables the ability to save navigation blocks via REST API.
-- --
-- -- @since 5.9.0
-- -- @access private
-- --
-- -- @param WP_Post $post An instance of WP_Post class.
-- --
-- function _disable_content_editor_for_navigation_post_type( $post ) then
--         $post_type = get_post_type( $post );
--         if ( "wp_navigation" !== $post_type ) then
--                 return;
--         end;

--         remove_post_type_support( $post_type, "editor" );
-- end;

-- --
-- -- This callback enables content editor for wp_navigation type posts.
-- -- We need to enable it back because we disable it to hide
-- -- the content editor for wp_navigation type posts.
-- --
-- -- @since 5.9.0
-- -- @access private
-- --
-- -- @see _disable_content_editor_for_navigation_post_type
-- --
-- -- @param WP_Post $post An instance of WP_Post class.
-- --
-- function _enable_content_editor_for_navigation_post_type( $post ) then
--         $post_type = get_post_type( $post );
--         if ( "wp_navigation" !== $post_type ) then
--                 return;
--         end;

--         add_post_type_support( $post_type, "editor" );
-- end;

end Adi_Posts;
