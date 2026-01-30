--
--
--

with Class_Styles;

package Adm_Load_Styles
is
   Global_Wp_Styles : Class_Styles.Wp_Styles :=
     Class_Styles.X_Construct; -- = new WP_Styles();

   procedure Run;

end Adm_Load_Styles;
