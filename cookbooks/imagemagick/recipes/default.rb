portage_package_use "x11-libs/gdk-pixbuf" do
  use %w(-X)
end

portage_package_use "gnome-base/librsvg" do
  use %w(-gtk)
end

package "media-gfx/imagemagick"
