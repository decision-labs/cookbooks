namespace :git do

  desc "Initialize upstream branch"
  task :upstream_init do
    system("git remote add -f upstream https://github.com/hollow/cookbooks.git")
    system("git branch -t upstream upstream/master")
    system("git checkout master")
  end

  desc "Show changes to upstream"
  task :upstream_changes => [ :upstream_init ]
  task :upstream_changes do
    system("git diff --diff-filter=DMT upstream master")
  end
end
