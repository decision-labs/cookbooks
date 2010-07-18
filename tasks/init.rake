desc "Initialize git submodules"
task :init do
  sh("git submodule update --init")
  Dir.chdir("cookbooks")
  sh("git checkout -q master")
end
