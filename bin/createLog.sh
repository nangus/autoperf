#!/bin/bash
PHANTOM='/home/njones/bin/phantomjs'
WD='/home/njones/src/njones/autoperf'
BINDIR=$WD/bin
GENSESSLOG=$BINDIR/genSessLog.js
GETFIRSTMIP=$BINDIR/getFirstMip.js
TMPDIR=$WD/logs
HOME='http://www.yellowpages.com'
SRP=$HOME/atlanta-ga/massage-therapists
echo empty old log files
echo -n > $TMPDIR/hom.log
echo -n > $TMPDIR/srp.log
echo -n > $TMPDIR/mip.log
echo waiting for log generation to finish
#start creating the srp and homepage files no need to wait for mip string creation
${PHANTOM} ${GENSESSLOG} --file $TMPDIR/hom.log --runs 10 $HOME&
${PHANTOM} ${GENSESSLOG} --file $TMPDIR/hom.log --runs 10 $HOME&
${PHANTOM} ${GENSESSLOG} --file $TMPDIR/srp.log --runs 10 $SRP&
${PHANTOM} ${GENSESSLOG} --file $TMPDIR/srp.log --runs 10 $SRP&
echo getting mip
#${PHANTOM} ${GETFIRSTMIP} $SRP
MIP=$(${PHANTOM} ${GETFIRSTMIP} $SRP)
RETCODE=$?
echo done getting mip
if [[ $RETCODE  != 0 ]]; then
    if [[ $RETCODE == 2 ]]; then 
        echo MIP class has changed please fix the scipt with the new mip class string
    elif [[ $RETCODE == 3 ]]; then
        echo srp page load timed out, or url not found when trying to create the mip
    else
        echo an unknown error occured when trying to create the MIP string
    fi
    echo $MIP
    exit $RETCODE
fi
if [[ $(echo $MIP|head -c 4) == 'http' ]]; then
    echo MIP ok
    echo $MIP
else
    MIP=$HOME$MIP
fi
MIP=$(echo -n $MIP|sed 's#\([^:]\)//#\1/#g')
echo $MIP
mkdir -p $TMPDIR
${PHANTOM} ${GENSESSLOG} --file $TMPDIR/mip.log --runs 10 $MIP&
${PHANTOM} ${GENSESSLOG} --file $TMPDIR/mip.log --runs 10 $MIP&
wait
echo log generation finished

