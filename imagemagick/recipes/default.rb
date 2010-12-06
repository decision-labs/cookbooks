include_recipe "portage"

file "/etc/portage/package.use/chef-x11-libs-cairo" do
  action :delete
end

portage_package_unmask   "=dev-libs/glib-2.25.17"
portage_package_keywords "=dev-libs/glib-2.25.17"

portage_package_unmask   "=x11-libs/gdk-pixbuf-2.22.0"
portage_package_keywords "=x11-libs/gdk-pixbuf-2.22.0"

portage_package_unmask   "=gnome-base/librsvg-2.32.1"
portage_package_keywords "=gnome-base/librsvg-2.32.1"
portage_package_use      "gnome-base/librsvg" do
  use %w(-gtk)
end

package "media-gfx/imagemagick"
