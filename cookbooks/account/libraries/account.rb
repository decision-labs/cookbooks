module ChefUtils
  module Account
    def getpwnam(user)
      pwent = Etc.getpwnam(user)
      user = Mash[pwent.members.zip(pwent.values)]

      pwent = Etc.getgrgid(user[:gid])
      user[:group] = Mash[pwent.members.zip(pwent.values)]

      user
    end
  end
end
