--
-- Taxonomy API: WP_Term class
--
-- @package WordPress
-- @subpackage Taxonomy
-- @since 4.4.0
--

with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

package Inc_Class_Wp_Terms
is
   use Ada.Strings.Unbounded;

--
-- Core class used to implement the WP_Term object.
--
-- @since 4.4.0
--
-- @property-read object $data Sanitized term data.
--
-- #[AllowDynamicProperties]

   type WP_Term is tagged
      record

        --
        -- Term ID.
        --
        -- @since 4.4.0
        -- @var int
        --
        Term_Id : Integer;

        --
        -- The term's name.
        --
        -- @since 4.4.0
        -- @var string
        --
        Name : Unbounded_String;

        --
        -- The term's slug.
        --
        -- @since 4.4.0
        -- @var string
        --
        Slug : Unbounded_String;

        --
        -- The term's term_group.
        --
        -- @since 4.4.0
        -- @var int
        --
        Term_Group : Integer; --  = '';

        --
        -- Term Taxonomy ID.
        --
        -- @since 4.4.0
        -- @var int
        --
        Term_Taxonomy_Id : Integer := 0;

        --
        -- The term's taxonomy name.
        --
        -- @since 4.4.0
        -- @var string
        --
        Taxonomy : Unbounded_String;

        --
        -- The term's description.
        --
        -- @since 4.4.0
        -- @var string
        --
        Description : Unbounded_String;

        --
        -- ID of a term's parent term.
        --
        -- @since 4.4.0
        -- @var int
        --
        Parent : Integer := 0;

        --
        -- Cached object count for this term.
        --
        -- @since 4.4.0
        -- @var int
        --
        Count : Integer := 0;

        --
        -- Stores the term object's sanitization level.
        --
        -- Does not correspond to a database field.
        --
        -- @since 4.4.0
        -- @var string
        --
        Filter : Unbounded_String := To_Unbounded_String ("raw");

        end record;

   package Term_Vectors is new
      Ada.Containers.Vectors (Index_Type   => Positive,
                              Element_Type => Wp_Term);
--                              "="          => Inc_Class_Wp_Terms."=");
   subtype Wp_Term_Array is Term_Vectors.Vector;
   Empty_Term_Array : constant Wp_Term_Array := Term_Vectors.Empty_Vector;

procedure Dummy;
end Inc_Class_Wp_Terms;
