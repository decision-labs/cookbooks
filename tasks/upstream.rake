namespace :upstream do

  desc "Initialize private repository and upstream branch"
  task :init, :repo do |t, args|
    if args.repo
      # make private repository the new origin
      sh("git remote rm origin")
      sh("git remote add origin #{args.repo}")
      sh("git config branch.master.remote origin")
      sh("git config branch.master.merge refs/heads/master")
      sh("git push origin master")
    end

    # add public cookbooks as upstream branch
    sh("git remote add -f upstream https://github.com/hollow/cookbooks.git")
    sh("git branch -t upstream upstream/master")
    sh("git config push.default tracking")
  end

  desc "Show changes to upstream"
  task :changes do
    sh("git diff --diff-filter=DMT upstream master")
  end

  task :pull => [ :require_clean_working_tree ]
  task :pull do
    sh("git checkout upstream")
    sh("git pull")
  end

  desc "Merge upstream branch"
  task :merge => [ :pull ]
  task :merge do
    sh("git checkout master")

    %x(git cherry master upstream | sed 's/^+ //;tn;d;:n').chomp.split("\n").each do |ref|
      sh("git cherry-pick #{ref} || :")
    end

    sh("git push")
  end

  desc "Pick downstream commits"
  task :pick => [ :pull ]
  task :pick, :commit do |t, args|
    args.with_defaults({:commit => "master"})
    sh("git cherry-pick #{args.commit}")
    sh("git push")
    Rake::Task['upstream:merge'].execute
  end
end
