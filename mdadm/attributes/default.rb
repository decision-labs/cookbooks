if FileTest.exists?("/proc/mdstat") and FileTest.exists?("/sbin/mdadm")
    default[:mdadm][:devices] = %x(/sbin/mdadm -Q --examine --brief /dev/sd*).split("\n")
end
