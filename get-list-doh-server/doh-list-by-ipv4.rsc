# Get Server IPv4
/tool fetch url="https://raw.githubusercontent.com/crypt0rr/public-doh-servers/master/ipv4.list" dst-path=doh-ips.txt
:delay 3s;

# Clear List
/ip firewall address-list remove [/ip firewall address-list find list=DOH-IPv4-List]

:global content [/file get doh-ips.txt content];
:global lineEnd 0;
:global line "";
:global lastEnd 0;

:while ($lineEnd < [:len $content]) do={
    :set lineEnd [:find $content "\n" $lastEnd];
    :if ([:len $lineEnd] = 0) do={ :set lineEnd [:len $content] };
    :set line [:pick $content $lastEnd $lineEnd];
    :set lastEnd ($lineEnd + 1);
    
    # Remove char "\n" from windows
    :if ([:find $line "\r"] > 0) do={ :set line [:pick $line 0 [:find $line "\r"]] };
    
    # Check, if have "#" for comment
    :if ([:pick $line 0 1] != "#" && [:len $line] > 0) do={
        
        # Validate duplicate on DOH-IPv4-List
        :if ([:len [/ip firewall address-list find list=DOH-IPv4-List address=$line]] = 0) do={
            /ip firewall address-list add list=DOH-IPv4-List address=$line timeout=2d
        }
    }
}
