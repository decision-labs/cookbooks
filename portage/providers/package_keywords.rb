include Gentoo::Portage::PackageConf

action :create do
  manage_package_conf(:create, "keywords", new_resource.name, new_resource.package, new_resource.keywords)
end

action :delete do
  manage_package_conf(:delete, "keywords", new_resource.name)
end
