namespace :upstream do

  desc "Initialize upstream branch"
  task :init do
    sh "git remote add -f upstream https://github.com/hollow/cookbooks.git &>/dev/null || :"
    sh "git branch -t upstream upstream/master &>/dev/null || :"
  end

  desc "Show changes to upstream"
  task :changes => [ :init ]
  task :changes do
    sh "git diff --diff-filter=DMT upstream master"
  end

  task :pull => [ :init, :require_clean_working_tree ]
  task :pull do
    sh "git checkout upstream"
    sh "git pull"
  end

  desc "Merge upstream branch"
  task :merge => [ :pull ]
  task :merge do
    sh "git checkout master"
    sh "git merge upstream"
  end

  desc "Pick downstream commits"
  task :pick => [ :pull ]
  task :pick do
    sh "git cherry-pick #{ENV['COMMITS']}"
    sh "git push"
    sh "git checkout master"
  end
end
