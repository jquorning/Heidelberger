--
-- kses 0.2.2 - HTML/XHTML filter that only allows some elements and attributes
-- Copyright (C) 2002, 2003, 2005  Ulf Harnhammar
--
-- This program is free software and open source software; you can redistribute
-- it and/or modify it under the terms of the GNU General Public License as
-- published by the Free Software Foundation; either version 2 of the License,
-- or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
-- more details.
--
-- You should have received a copy of the GNU General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
-- http://www.gnu.org/licenses/gpl.html
--
-- [kses strips evil scripts!]
--
-- Added wp_ prefix to avoid conflicts with existing kses users
--
-- @version 0.2.2
-- @copyright (C) 2002, 2003, 2005
-- @author Ulf Harnhammar <http://advogato.org/person/metaur/>
--
-- @package External
-- @subpackage KSES
--

package Inc_Kses
is
   procedure Dummy;

   --
   -- Converts and fixes HTML entities.
   --
   -- This function normalizes HTML entities. It will convert `AT&T` to the correct
   -- `AT&amp;T`, `&#00058;` to `&#058;`, `&#XYZZY;` to `&amp;#XYZZY;` and so on.
   --
   -- When `$context` is set to "xml", HTML entities are converted to their code
   -- points.  For example, `AT&T&hellip;&#XYZZY;` is converted to
   -- `AT&amp;T…&amp;#XYZZY;`.
   --
   -- @since 1.0.0
   -- @since 5.5.0 Added `$context` parameter.
   --
   -- @param string $string  Content to normalize entities.
   -- @param string $context Context for normalization. Can be either "html" or "xml".
   --                        Default "html".
   -- @return string Content with normalized entities.
   --
   function Wp_Kses_Normalize_Entities (Item    : String;
                                        Context : String := "html")
                                        return String
                                        is (Item);

end Inc_Kses;
