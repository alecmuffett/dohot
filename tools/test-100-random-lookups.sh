#!/bin/sh
LIMIT=100
CMD=/tmp/dig-test.$$
LOG=$CMD.log
OUT=$CMD.out
ERR=$CMD.err

umask 077

Address() { # not complete nor clever but that's okay
    perl -e 'sub X {int(rand(254))+1} ; printf("%d.%d.%d.%d", X, X, X, X)' || exit 1
}

UnixTime() {
    date '+%s'
}

i=0
while [ $i -lt $LIMIT ] ; do
    echo dig -x `Address`
    i=`expr $i + 1`
done >$CMD

if ! dig www.google.com >/dev/null 2>&1 ; then
    echo $0: error: dig: command not working or not found 1>&2
    exit 1
fi

echo "running $CMD : please be patient..."
(
    start=`UnixTime`
    sh $CMD </dev/null >$OUT 2>$ERR
    finish=`UnixTime`
    elapsed=`expr $finish - $start`
    echo "file=$CMD limit=$LIMIT finish=$finish start=$start elapsed=$elapsed"
) 2>&1 | tee $LOG

exit 0
