include Gentoo::Portage::PackageConf

action :create do
  manage_package_conf(:create, "use", new_resource.package, new_resource.use)
end

action :delete do
  manage_package_conf(:delete, "use", new_resource.name)
end
