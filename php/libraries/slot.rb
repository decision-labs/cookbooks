class PHP
  def self.slot
    @@slot ||= %x(eix --installed --pure-packages --format '<bestversion:NAMEASLOT>' -e dev-lang/php|cut -d: -f2).strip
  end
end
