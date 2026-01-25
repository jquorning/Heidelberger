--
-- Taxonomy API: WP_Term class
--
-- @package WordPress
-- @subpackage Taxonomy
-- @since 4.4.0
--

with Ada.Containers.Vectors;

with UStrings;

package Class_Terms
is

   --
   -- Core class used to implement the WP_Term object.
   --
   -- @since 4.4.0
   --
   -- @property-read object $data Sanitized term data.
   --
   -- #[AllowDynamicProperties]

   type Wp_Term is tagged
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
         Name : UStrings.UString;

         --
         -- The term's slug.
         --
         -- @since 4.4.0
         -- @var string
         --
         Slug : UStrings.UString;

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
         Taxonomy : UStrings.UString;

         --
         -- The term's description.
         --
         -- @since 4.4.0
         -- @var string
         --
         Description : UStrings.UString;

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
         Filter : UStrings.UString :=
           UStrings.To_UString ("raw");

      end record;

   Null_Term : constant Wp_Term :=
     (Term_Id          => 0,
      Term_Group       => 0,
      Term_Taxonomy_Id => 0,
      Parent           => 0,
      Count            => 0,
      others           => UStrings.Null_UString);

   package Term_Vectors is new
      Ada.Containers.Vectors (Index_Type   => Positive,
                              Element_Type => Wp_Term);

   subtype Wp_Term_Array is Term_Vectors.Vector;
   Empty_Term_Array : constant Wp_Term_Array := Term_Vectors.Empty_Vector;

   procedure Dummy;

end Class_Terms;
