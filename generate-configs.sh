#!/bin/sh

# settings
export TOR_SOCKS_ADDR='127.0.0.1' # we use local Tor daemon
export TOR_SOCKS_PORT='9050' # we expect Tor to use standard SOCKS port

export DNSCP_ADDR='0.0.0.0' # we listen to all interfaces
export DNSCP_PORT='53' # we serve on port 53
export DNSCP_BLOCK_IPV6='false' # we do not block ipv6 lookups, else 'true'
export DNSCP_BOOTSTRAP_NAME='fallback' # newer config files (>= 2.0.46) will use 'bootstrap'
export DNSCP_LOG_DIR='/var/log/dnscrypt-proxy' # our logfiles go here

# where the server gets lists of resolvers
export DNSCP_LIST_1='https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master'
export DNSCP_LIST_2='https://download.dnscrypt.info/resolvers-list'
export DNSCP_LIST_VERSION='v3'
export DNSCP_MINISIGN_KEY='RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'

# install metadata
export DNSCP_VERSION_MIN=2.0.43 # point at which v3 protocols arrived

# brute force
while read suffix vars ; do
    for template in templates/*.tmpl ; do
	name=`basename $template .tmpl` # strip the suffix
	name=`echo $name | sed -e "s/XXXX/$suffix/"`
	env $vars ./tools/expand.pl $template > $name
    done
done <<EOF
cloudflare     DNSCP_BOOTSTRAP_ADDR=1.1.1.1
cloudflare-v4  DNSCP_BOOTSTRAP_ADDR=1.1.1.1  DNSCP_BLOCK_IPV6=true
google         DNSCP_BOOTSTRAP_ADDR=8.8.8.8
google-v4      DNSCP_BOOTSTRAP_ADDR=8.8.8.8  DNSCP_BLOCK_IPV6=true
EOF

exit 0
