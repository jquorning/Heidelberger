--
--
--

with Class_Customize_Managers;

package Class_Customize_Manager_Indirect
is

   type Customize_Manager
     is access all Class_Customize_Manager.Wp_Customize_Manager;

end Class_Customize_Manager_Indirect;
