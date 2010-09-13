package "dev-java/sun-jdk"

execute "ensure java 1.6 is the system vm" do
  command "eselect java-vm set system sun-jdk-1.6"
  not_if "test $(eselect java-vm show system|tail -n1) = sun-jdk-1.6"
end
