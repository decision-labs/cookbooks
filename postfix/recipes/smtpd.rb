include_recipe "postfix"

postmaster "smtp" do
  stype "inet"
  priv "n"
  command "smtpd"
end
