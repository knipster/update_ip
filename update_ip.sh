#!/bin/bash 
# Configuration Section
HOSTNAME="<ENTERYOURSUBDOMAINHERE>"
ROUTER_STATUS_PAGE="http://192.168.1.1/Status_Router.asp"
AFRAID_UPDATE_URL="http://freedns.afraid.org/dynamic/update.php?<ENTERYOURKEYHERE>" 
ROUTER_WGET_ARGS="--timeout=2 --tries=2"
AFRAID_UPDATE_WGET_ARGS="--timeout=2 --tries=2"
EXTRA_OUTPUT="/dev/null"  # Replace with /dev/stderr for more verbosity

#  Poor Man's Config File Technique:  
#    Copy the Above Block of variable definitions into ~/.update_iprc and replace
#    with your own configuration
if [ -e ~/.update_iprc ] ; then
    source ~/.update_iprc ; 
fi

function UPDATE_IP() {
    wget $AFRAID_UPDATE_WGET_ARGS -q -O - $AFRAID_UPDATE_URL
}

function DNS_IP() {
    echo -n "DNS IP: " >$EXTRA_OUTPUT
    DNS_LOOKUP | DNS_FILTER | tee $EXTRA_OUTPUT
}

# Command to get my linksys router's external ip
function ROUTER_IP() {
    echo -n "Router IP: " >$EXTRA_OUTPUT
    ROUTER_FETCH | ROUTER_FILTER | tee $EXTRA_OUTPUT
}

# router_filter: this is the function mostly likely to require customization.
# The body should be a Pipe Command that takes the contents of the router status page on STDIN and Dumps the WAN IP on STDOUT
function ROUTER_FILTER() {
    # sed:  scan STDIN for ipaddresses and dump them to STDOUT
    # sed -n:  do not print input lines except substitution is performed: s/old/new/p (p suffix causes print)
    # sed -r:  enable extended regexps such as {min,max}
    # sed -e:  use the following quoted string
    # sed regexp:  match all characters before a digit,subgroup(\d+.\d+.\d+.\d+), then rest of characters, replace with matched subgroup
    # head -1: print the first line of STDIN  (first ip address is the wan_ip on my router)
    sed -n -r -e 's/.*[^0-9]([1-9][0-9]{0,2}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*/\1/p' | head -1 
}

function ROUTER_FETCH() {
    # wget: Fetch the router status page; uses ~/.netrc for basic authentication (machine, login, password)
    # wget -q:  Silent Mode no output
    # wget -O -: dump output as stdout
    wget $ROUTER_WGET_ARGS -q -O - $ROUTER_STATUS_PAGE 
}

function DNS_FILTER() {
    # tail -1: print last line of STDIN
    # cut:  print the 4th "word"
    # cut -d ' ': use space as field delimeter
    # cut -f 4: print 4th field (1 indexed)
    tail -1 |  cut -d ' ' -f 4 
}

function DNS_LOOKUP() {
    # host:  lookup hostname from dns server
    host $HOSTNAME ns1.afraid.org 
}

# Back tick substitutes STDOUT of command for value
echo "Checking $HOSTNAME" > $EXTRA_OUTPUT
if [ `DNS_IP` = `ROUTER_IP` ]; then 
    echo  "IPs Match" > $EXTRA_OUTPUT ; 
else 
    echo "IPs do not match" >$EXTRA_OUTPUT ; 
    UPDATE_IP;
fi
