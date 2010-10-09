include_recipe "postfix"
include_recipe "spamassassin"

postmaster "spamassassin" do
  stype "unix"
  unpriv "n"
  command "pipe"
  args "user=spamd argv=/usr/bin/spamc -e /usr/sbin/sendmail -oi -f ${sender} ${recipient}"
end

# XXX: this is ugly
t = resources(:template => "/etc/postfix/master.cf")
t.variables[:services].each do |s|
  if s[:name] == "smtp"
    s[:args] = "-o content_filter=spamassassin"
  end
end
