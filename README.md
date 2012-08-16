update_ip
=========

Utility to update freedns.afraid.org from behind Linksys Router


Installation
	git clone https://github.com/knipster/update_ip.git

Configuration
    head -5 update_ip.sh | tail -3 >~/.update_iprc
    chmod 600 ~/.update_iprc

    Then edit ~/.update_iprc and replace with your freedns hostname and direct update link

    Finally, edit ~/.netrc
    	     machine 192.168.1.1  
	     login <router_user>
	     password <router_password>

    chmod 600 ~/.netrc 

Advanced Configuration
    If your router isn't either a Linksys WRT610N or compatible, modify the router_filter function to
    