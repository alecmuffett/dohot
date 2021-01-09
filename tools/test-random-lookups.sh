#!/bin/sh
THIS=`basename $0`
HOST=`uname -n`
DIG="dig" # in case it needs a path prefix
LIMIT=100 # standard
SLUG="dig.$HOST.$$" # standard
PAUSE=70 # slightly more than 1 minute

umask 077

UnixTime() {
    date '+%s'
}

RandomIPAddress() {
    # This is not complete nor clever but that's okay; the code picks
    # random octets in the range 0..253 inclusive (ie: less than 254)
    # and then adds one, so that the final octets are 1..254
    # inclusive. The goal is to work the resolver.
    perl -e 'sub X {int(rand(254))+1} ; printf("%d.%d.%d.%d", X, X, X, X)' || exit 1
}

GenerateScript() {
    # scripts are precomputed so that we have a log of what happened
    # AND ALSO so that there's no dynamic lag other than spawning
    # "dig" processes serially.
    i=0
    while [ $i -lt $LIMIT ] ; do
	echo $DIG -x `RandomIPAddress`
	i=`expr $i + 1`
    done
}

InformUser() {
    # glorified echo-to-stderr
    echo "$THIS: $@ (`date`)" 1>&2
}

RunScript() {
    PASS=$1 ; shift
    PREFIX="$SLUG.$PASS"
    RUN="$PREFIX.sh"
    OUT="$PREFIX.out"
    ERR="$PREFIX.err"

    InformUser "generating $RUN"
    GenerateScript > $RUN
    InformUser "start $RUN"
    start=`UnixTime`
    sh $RUN </dev/null >$OUT 2>$ERR
    finish=`UnixTime`
    elapsed=`expr $finish - $start`
    echo "pass=$PASS file=$RUN limit=$LIMIT finish=$finish start=$start elapsed=$elapsed" "$@"
    InformUser "finish $RUN"
    test -s $ERR && InformUser "WARNING: error log $ERR contains data, please check"
}

# sniff-test to check that dig exists
if ! dig www.google.com >/dev/null 2>&1 ; then
    InformUser "$0: error: dig: command not working or not found"
    exit 1
fi

echo "what is your DOWNLOAD bandwidth in MEGABITS? eg: 10, 100, 1000, 0=unknown/other, ..."
read download

echo "what is your UPLOAD bandwidth in MEGABITS? eg: 10, 100, 1000, 0=unknown/other, ..."
read upload

echo "in one word, who is your DNS provider? eg: google, cloudflare, isp, unknown, ..."
read dns

# run the main test
LOG="$SLUG.log"
for pass in 1 2 3 4 5 ; do
    InformUser "starting pass $pass of 5, please be patient..."
    RunScript $pass "up=/$upload/" "down=/$download/" "dns=/$dns/"
    if [ $PASS != 5 ] ; then
	InformUser "sleeping $PAUSE seconds to be polite"
	sleep $PAUSE
    fi
done | tee $LOG
InformUser "finished, thank you; results are in: $LOG"
exit 0
