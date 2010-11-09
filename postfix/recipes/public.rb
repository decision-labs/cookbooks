include_recipe "postfix"
include_recipe "postfix::postgrey"
include_recipe "postfix::spamassassin"
include_recipe "postfix::tls"

smtpd_helo_restrictions = %w(
  permit_mynetworks
  reject_invalid_helo_hostname
  permit
)

smtpd_sender_restrictions = %w(
  reject_non_fqdn_sender
  reject_unknown_sender_domain
  permit_mynetworks
  permit_sasl_authenticated
  permit
)

smtpd_recipient_restrictions = %w(
  reject_non_fqdn_recipient
  reject_unknown_recipient_domain
  permit_mynetworks
  permit_sasl_authenticated
  reject_unauth_destination
  reject_unauth_pipelining
)

node[:postfix][:rbl_servers].each do |s|
  smtpd_recipient_restrictions << "reject_rbl_client #{s}"
end

smtpd_recipient_restrictions += [
  "check_policy_service unix:private/postgrey",
  "permit"
]

postconf "Restrictions for public SMTP servers" do
  set :smtpd_helo_required => "yes",
      :disable_vrfy_command => "yes",
      :strict_rfc821_envelopes => "yes",
      :smtpd_helo_restrictions => smtpd_helo_restrictions.join(", "),
      :smtpd_sender_restrictions => smtpd_sender_restrictions.join(", "),
      :smtpd_recipient_restrictions => smtpd_recipient_restrictions.join(", ")
end

# nagios service checks
if tagged?("nagios-client")
  node.default[:nagios][:services]["SMTP"][:check_command] = "check_smtp!25!3"
end
