#!/bin/sh

# DNSCrypt-Proxy relies upon "stamps" to encode all DNS metadata into
# a convenient single string; regrettably they are not terribly well
# known outside that tool, and are weakly documented.  This script
# exists to generate a stamp for the Cloudflare DoH Tor Onion, and its
# output has already been hardcoded into `dnscrypt-proxy.toml`

# I am leaving this script here because it may be useful to other
# people; I also used it as part of some EOTK-related experiments.

# see also: online stamp generator https://dnscrypt.info/stamps
# via: https://github.com/jedisct1/vue-dnsstamp

# DNS STAMP REFERENCE LIST:
# https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v2/public-resolvers.md

# STAMP GENERATION:
# source:  https://github.com/chrisss404/python-dnsstamps
# install: python3 -m pip install --user dnsstamps
# example: stampgen=/Users/alecm/Library/Python/3.7/bin/dnsstamp.py
stampgen=/path/to/dnsstamp.py # FIX THIS TO MATCH INSTALL

# dnsstamp.py has no apparent documentation, seems to be:
# -s: DNSSEC switch
# -a <addr>: IP address
# -n <name>: hostname
# -p <path>: query path
# -l: no logs
# -f: no filter

# for brevity
cf_onion=dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion

# temp file to hold all the output/junk
tf=/tmp/stampgen_$$

# do it
while read name args ; do
    test "x$name" = "x" && continue
    test "x$name" = "x#" && continue
    echo :::: $name::::
    echo $stampgen $args
    $stampgen $args >$tf || exit 1
    grep -v '^$' $tf
    sdns=`grep sdns:// <$tf`
    echo ""
    echo "[static.'$name']"
    echo "stamp = '$sdns'"
    echo ""
done <<EOF
# test that the code works / parses pre-existing stamps
cloudflare      parse sdns://AgcAAAAAAAAABzEuMC4wLjEAEmRucy5jbG91ZGZsYXJlLmNvbQovZG5zLXF1ZXJ5
cloudflare-ipv6 parse sdns://AgcAAAAAAAAAGVsyNjA2OjQ3MDA6NDcwMDo6MTExMV06NTMAEmRucy5jbG91ZGZsYXJlLmNvbQovZG5zLXF1ZXJ5
google          parse sdns://AgUAAAAAAAAABzguOC44LjigHvYkz_9ea9O63fP92_3qVlRn43cpncfuZnUWbzAMwbkgdoAkR6AZkxo_AEMExT_cbBssN43Evo9zs5_ZyWnftEUKZG5zLmdvb2dsZQovZG5zLXF1ZXJ5

# generate a stamp for the cloudflare onion, based upon reversing the above
cloudflare-onion doh -l -s -f -n $cf_onion -p /dns-query
EOF

# done
rm $tf
exit 0
