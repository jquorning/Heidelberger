--
-- Site API: WP_Site class
--
-- @package WordPress
-- @subpackage Multisite
-- @since 4.5.0
--

with Ada.Strings.Unbounded;

package Inc_Class_Wp_Sites
is
   use Ada.Strings.Unbounded;

   procedure Dummy;

   function To_Us (Item : String) return Unbounded_String
      renames To_Unbounded_String;

--
-- Core class used for interacting with a multisite site.
--
-- This class is used during load to populate the `current_blog` global and
-- setup the current site.
--
-- @since 4.5.0
--
-- @property int    id
-- @property int    network_id
-- @property string blogname
-- @property string siteurl
-- @property int    post_count
-- @property string home
--
-- #[AllowDynamicProperties]

   type WP_Site is tagged
      record

        --
        -- Site ID.
        --
        -- Named "blog" vs. "site" for legacy reasons.
        --
        -- A numeric string, for compatibility reasons.
        --
        -- @since 4.5.0
        -- @var string
        --
        Blog_Id : Integer; -- Unbounded_String;

        --
        -- Domain of the site.
        --
        -- @since 4.5.0
        -- @var string
        --
        Domain : Unbounded_String;

        --
        -- Path of the site.
        --
        -- @since 4.5.0
        -- @var string
        --
        Path : Unbounded_String;

        --
        -- The ID of the site"s parent network.
        --
        -- Named "site" vs. "network" for legacy reasons. An individual site"s "site" is
        -- its network.
        --
        -- A numeric string, for compatibility reasons.
        --
        -- @since 4.5.0
        -- @var string
        --
        Site_Id : Unbounded_String := To_Us ("0");

        --
        -- The date and time on which the site was created or registered.
        --
        -- @since 4.5.0
        -- @var string Date in MySQL"s datetime format.
        --
        Registered : Unbounded_String := To_Us ("0000-00-00 00:00:00");

        --
        -- The date and time on which site settings were last updated.
        --
        -- @since 4.5.0
        -- @var string Date in MySQL"s datetime format.
        --
        Last_Updated : Unbounded_String := To_Us ("0000-00-00 00:00:00");

        --
        -- Whether the site should be treated as public.
        --
        -- A numeric string, for compatibility reasons.
        --
        -- @since 4.5.0
        -- @var string
        --
        Xx : Unbounded_String := To_Us ("1");

        --
        -- Whether the site should be treated as archived.
        --
        -- A numeric string, for compatibility reasons.
        --
        -- @since 4.5.0
        -- @var string
        --
        Archived : Unbounded_String := To_Us ("0");

        --
        -- Whether the site should be treated as mature.
        --
        -- Handling for this does not exist throughout WordPress core, but custom
        -- implementations exist that require the property to be present.
        --
        -- A numeric string, for compatibility reasons.
        --
        -- @since 4.5.0
        -- @var string
        --
        Mature : Unbounded_String := To_Us ("0");

        --
        -- Whether the site should be treated as spam.
        --
        -- A numeric string, for compatibility reasons.
        --
        -- @since 4.5.0
        -- @var string
        --
        Spam : Unbounded_String := To_Us ("0");

        --
        -- Whether the site should be treated as deleted.
        --
        -- A numeric string, for compatibility reasons.
        --
        -- @since 4.5.0
        -- @var string
        --
        Deleted : Unbounded_String := To_Us ("0");

        --
        -- The language pack associated with this site.
        --
        -- A numeric string, for compatibility reasons.
        --
        -- @since 4.5.0
        -- @var string
        --
        Lang_Id : Unbounded_String := To_Us ("0");

      end record;

   Null_Site : constant Wp_Site := (Blog_Id => 0, others => Null_Unbounded_String);

end Inc_Class_Wp_Sites;
