--
-- Site API
--
-- @package WordPress
-- @subpackage Multisite
-- @since 5.1.0
--

with Wp_Common;

with Inc_Load;
with Inc_Meta;

package body Inc_Ms_Sites
is

   --------------
   -- Get_Site --
   --------------

   function Get_Site (Site : Integer) -- null
                      return Class_Sites.Wp_Site
   is
      use Wp_Common;
      use Class_Sites;
      use Inc_Load;

      Site_2 : constant Integer :=
        (if Site = 0
         then Get_Current_Blog_Id
         else Site);

      X_Site : constant Wp_Site := X_Construct (Site_2);
   begin
        -- if ( site instanceof WP_Site ) then
        --         _site = site;
        -- end; elseif ( is_object( site ) ) then
        --         _site = new WP_Site( site );
        -- end; else then
        --         _site = WP_Site::get_instance( site );
        -- end;

      if X_Site = Null_Site then
         return Null_Site;
      end if;

      --
      -- Fires after a site is retrieved.
      --
      -- @since 4.6.0
      --
      -- @param WP_Site _site Site data.
      --
      return Apply_Filters ("get_site", X_Site);
   end Get_Site;

   ----------------------
   -- Update_Site_Meta --
   ----------------------

   function Update_Site_Meta (Site_Id    : Integer;
                              Meta_Key   : String;
                              Meta_Value : Multi_Type;
                              Prev_Value : Multi_Type := From_String (""))
                              return Integer
   is
      use Inc_Meta;
   begin
      return
        Update_Metadata ( -- "blog" -- ???,
          Site_Id, "blog", Meta_Key, Meta_Value, Prev_Value);
   end Update_Site_Meta;

   ----------------------
   -- Update_Site_Meta --
   ----------------------

   procedure Update_Site_Meta (Site_Id    : Integer;
                               Meta_Key   : String;
                               Meta_Value : Multi_Type;
                               Prev_Value : Multi_Type := From_String (""))
   is
      Unused : constant Integer :=
        Update_Site_Meta (Site_Id, Meta_Key, Meta_Value, Prev_Value);
   begin
      null;
   end Update_Site_Meta;

end Inc_Ms_Sites;
