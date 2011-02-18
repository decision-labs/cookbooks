class PHP
  def self.slot
    @@slot ||= %x(eix --pure-packages --format '<bestversion:NAMEASLOT>' -e dev-lang/php|cut -d: -f2).strip
  end
end
