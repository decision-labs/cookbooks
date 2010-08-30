desc "Initialize chef repository"
task :init do
  unless File.exist?(File.join(TOPDIR, "cookbooks", ".git"))
    sh("git submodule update --init")
    Dir.chdir("cookbooks")
    sh("git checkout -q master")
  end
end
