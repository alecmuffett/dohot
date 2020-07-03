#!/bin/sh
# testing DoHoT and DoHoO
# explanation: https://twitter.com/AlecMuffett/status/1011504656667770880
# v1.2 - alec.muffett@gmail.com 2020-07-03
# v1.1 - alec.muffett@gmail.com 2020-02-15
# v1.0 - alec.muffett@gmail.com 2018-06-26

# You need to have TorBrowser running locally to provide a SOCKS5
# relay to Tor on port 9150 (see below) for the Onion lookup to work;
# or you can amend this script to point at another tor/socks relay.

TARGET="www.openrightsgroup.org"
TOR_PROXY="127.0.0.1:9150" # amend this, if your tor proxy is elsewhere
CFONION=dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion # for brevity

while read src url curl_opts; do
    test "x$src" = "x" && continue
    test "x$src" = "x#" && continue
    echo :::: testing $src over clearnet ::::
    curl -H 'accept: application/dns-json' $curl_opts $url
    echo ""
    echo ""
    echo :::: testing $src over tor ::::
    curl -H 'accept: application/dns-json' -x  socks5h://$TOR_PROXY/ $url
    echo ""
    echo ""
done <<EOF
cf            https://cloudflare-dns.com/dns-query?name=$TARGET
cf-ip1001     https://1.0.0.1/dns-query?name=$TARGET
cf-ip1111     https://1.1.1.1/dns-query?name=$TARGET
cf-onion      https://$CFONION/dns-query?name=$TARGET
google        https://dns.google/resolve?name=$TARGET
quad9         https://dns.quad9.net:5053/dns-query?name=$TARGET
quad9-ip9999  https://9.9.9.9:5053/dns-query?name=$TARGET
EOF

exit 0
