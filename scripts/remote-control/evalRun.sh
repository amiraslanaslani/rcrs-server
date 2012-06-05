#!/bin/bash

. $(dirname $0)/config.sh

CLUSTER=$1

SERVER=$(getServerHost $CLUSTER)

eval $(ssh $REMOTE_USER@$SERVER cat $KERNELDIR/boot/$LOCKFILE_NAME 2>/dev/null)
if [ ! -z $RUNNING_TEAM ]; then
    echo "There is still a server running on cluster $CLUSTER"
    echo "${TEAM_NAMES[$RUNNING_TEAM]} ($RUNNING_TEAM) on $RUNNING_MAP"
    exit 1
fi;

eval $(ssh $REMOTE_USER@$SERVER cat $KERNELDIR/boot/$STATFILE_NAME 2>/dev/null)
if [ -z $RUNNING_TEAM ]; then
    echo "No run recorded on cluster $CLUSTER"
    exit 1
fi;


echo "Evaluating run of ${TEAM_NAMES[$RUNNING_TEAM]} ($RUNNING_TEAM) on $RUNNING_MAP"

rsync -rcLv $REMOTE_USER@$SERVER:$LOGDIR $HOME

gunzip -c $HOME/$RESCUE_LOGFILE.gz > $HOME/$RESCUE_LOGFILE.tmp

evalLog.sh $HOME/$RESCUE_LOGFILE.tmp $RUNNING_MAP $RUNNING_TEAM

rm $HOME/$RESCUE_LOGFILE.tmp

echo "Rebuilding summary page for $RUNNING_MAP"

mapSummary.sh $RUNNING_MAP