--
--
--

with Inc_Class_Wp_Customize_Managers;

package Inc_Class_Wp_Customize_Manager_Indirect
is

   type Customize_Manager
     is access all Inc_Class_Wp_Customize_Manager.Wp_Customize_Manager;

end Inc_Class_Wp_Customize_Manager_Indirect;
