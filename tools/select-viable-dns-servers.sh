#!/bin/sh

# 'legacy' file for servers <= 2.0.42
url=https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md

# re: $stamp_exe, see notes in `stampgen.sh`
# example: stamp_exe=/Users/alecm/Library/Python/3.7/bin/dnsstamp.py
stamp_exe=/path/to/dnsstamp.py # FIX THIS TO MATCH INSTALL

# scratch
tags=tags.txt
tf=/tmp/doh$$.txt

test -s $tags ||
    curl $url | awk '$1=="##"{tag=$2} /^sdns/{print tag, $1}' >$tags ||
    exit 1

echo "#" `date`
echo "# these stamps appear to be suitable for DoHoT"
echo ""

while read tag stamp ; do
    $stamp_exe parse $stamp >$tf
    grep '^Hostname:' $tf >/dev/null || continue
    grep '^DNSSEC: yes' $tf >/dev/null || continue
    grep '^No filter: yes' $tf >/dev/null || continue
    echo "'$tag'," # is okay to use
done <$tags
