--
-- Taxonomy API: WP_Term class
--
-- @package WordPress
-- @subpackage Taxonomy
-- @since 4.4.0
--
package body Class_Terms
is
   procedure Dummy is null;

        --
        -- Retrieve WP_Term instance.
        --
        -- @since 4.4.0
        --
        -- @global wpdb $wpdb WordPress database abstraction object.
        --
        -- @param int    $term_id  Term ID.
        -- @param string $taxonomy Optional. Limit matched terms to those matching `$taxonomy`. Only used for
        --                         disambiguating potentially shared terms.
        -- @return WP_Term|WP_Error|false Term object, if found. WP_Error if `$term_id` is shared between taxonomies and
        --                                there's insufficient data to distinguish which term is intended.
        --                                False for other failures.
        --
        -- public static function get_instance( $term_id, $taxonomy = null ) then
        --         global $wpdb;

        --         $term_id = (int) $term_id;
        --         if ( ! $term_id ) then
        --                 return false;
        --         end;

        --         $_term = wp_cache_get( $term_id, 'terms' );

        --         // If there isn't a cached version, hit the database.
        --         if ( ! $_term || ( $taxonomy && $taxonomy !== $_term->taxonomy ) ) then
        --                 // Any term found in the cache is not a match, so don't use it.
        --                 $_term = false;

        --                 // Grab all matching terms, in case any are shared between taxonomies.
        --                 $terms = $wpdb->get_results( $wpdb->prepare( "SELECT t.*, tt.* FROM $wpdb->terms AS t INNER JOIN $wpdb->term_taxonomy AS tt ON t.term_id = tt.term_id WHERE t.term_id = %d", $term_id ) );
        --                 if ( ! $terms ) then
        --                         return false;
        --                 end;

        --                 // If a taxonomy was specified, find a match.
        --                 if ( $taxonomy ) then
        --                         foreach ( $terms as $match ) then
        --                                 if ( $taxonomy === $match->taxonomy ) then
        --                                         $_term = $match;
        --                                         break;
        --                                 end;
        --                         end;

        --                         // If only one match was found, it's the one we want.
        --                 end; elseif ( 1 === count( $terms ) ) then
        --                         $_term = reset( $terms );

        --                         // Otherwise, the term must be shared between taxonomies.
        --                 end; else then
        --                         // If the term is shared only with invalid taxonomies, return the one valid term.
        --                         foreach ( $terms as $t ) then
        --                                 if ( ! taxonomy_exists( $t->taxonomy ) ) then
        --                                         continue;
        --                                 end;

        --                                 // Only hit if we've already identified a term in a valid taxonomy.
        --                                 if ( $_term ) then
        --                                         return new WP_Error( 'ambiguous_term_id', __( 'Term ID is shared between multiple taxonomies' ), $term_id );
        --                                 end;

        --                                 $_term = $t;
        --                         end;
        --                 end;

        --                 if ( ! $_term ) then
        --                         return false;
        --                 end;

        --                 // Don't return terms from invalid taxonomies.
        --                 if ( ! taxonomy_exists( $_term->taxonomy ) ) then
        --                         return new WP_Error( 'invalid_taxonomy', __( 'Invalid taxonomy.' ) );
        --                 end;

        --                 $_term = sanitize_term( $_term, $_term->taxonomy, 'raw' );

        --                 // Don't cache terms that are shared between taxonomies.
        --                 if ( 1 === count( $terms ) ) then
        --                         wp_cache_add( $term_id, $_term, 'terms' );
        --                 end;
        --         end;

        --         $term_obj = new WP_Term( $_term );
        --         $term_obj->filter( $term_obj->filter );

        --         return $term_obj;
        -- end;

        --
        -- Constructor.
        --
        -- @since 4.4.0
        --
        -- @param WP_Term|object $term Term object.
        --
        -- public function __construct( $term ) then
        --         foreach ( get_object_vars( $term ) as $key => $value ) then
        --                 $this->$key = $value;
        --         end;
        -- end;

        --
        -- Sanitizes term fields, according to the filter type provided.
        --
        -- @since 4.4.0
        --
        -- @param string $filter Filter context. Accepts 'edit', 'db', 'display', 'attribute', 'js', 'rss', or 'raw'.
        --
        -- public function filter( $filter ) then
        --         sanitize_term( $this, $this->taxonomy, $filter );
        -- end;

        --
        -- Converts an object to array.
        --
        -- @since 4.4.0
        --
        -- @return array Object as array.
        --
        -- public function to_array() then
        --         return get_object_vars( $this );
        -- end;

        --
        -- Getter.
        --
        -- @since 4.4.0
        --
        -- @param string $key Property to get.
        -- @return mixed Property value.
        --
        -- public function __get( $key ) then
        --         switch ( $key ) then
        --                 case 'data':
        --                         $data    = new stdClass();
        --                         $columns = array( 'term_id', 'name', 'slug', 'term_group', 'term_taxonomy_id', 'taxonomy', 'description', 'parent', 'count' );
        --                         foreach ( $columns as $column ) then
        --                                 $data->then$columnend; = isset( $this->then$columnend; ) ? $this->then$columnend; : null;
        --                         end;

        --                         return sanitize_term( $data, $data->taxonomy, 'raw' );
        --         end;
        -- end;

end Class_Terms;
