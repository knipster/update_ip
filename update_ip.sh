#!/bin/bash
# Command to get Afraid.org's definition
AFRAID_HOSTNAME="<ENTERYOURSUBDOMAINHERE>"
ROUTER_STATUS_PAGE="http://192.168.1.1/Status_Router.asp"
AFRAID_UPDATE_URL="http://freedns.afraid.org/dynamic/update.php?<ENTERYOURKEYHERE>" 

function afraid_ip() {
    # host:  lookup hostname from dns server
    # tail -1: print last line of STDIN
    # cut:  print the 4th "word"
    # cut -d ' ': use space as field delimeter
    # cut -f 4: print 4th field (1 indexed)

    host $AFRAID_HOSTNAME ns1.afraid.org | tail -1 | cut -d ' ' -f 4
}
# Command to get my linksys router's external ip
function router_ip() {
    # wget: Fetch the router status page; uses ~/.netrc for basic authentication (machine, login, password)
    # wget -q:  Silent Mode no output
    # wget -O -: dump output as stdout
    # sed:  scan STDIN for ipaddresses and dump them to STDOUT
    # sed -n:  do not print input lines except substitution is performed: s/old/new/p (p suffix causes print)
    # sed -r:  enable extended regexps such as {min,max}
    # sed -e:  use the following quoted string
    # sed regexp:  match all characters before a digit,subgroup(\d+.\d+.\d+.\d+), then rest of characters, replace with matched subgroup
    # head -1: print the first line of STDIN  (first ip address is the wan_ip on my router)
    wget -q -O - $ROUTER_STATUS_PAGE | \
	sed -n -r -e 's/.*[^0-9]([1-9][0-9]{0,2}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*/\1/p' | head -1
}

# Back tick substitutes STDOUT of command for value
if [ `afraid_ip` = `router_ip` ]; then 
    echo "IPs Match" ; 
else 
    echo "IPs do not match" ; 
    wget -q -O - $AFRAID_UPDATE_URL
fi
