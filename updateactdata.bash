#!/bin/bash
# Analyses the content of webserver/rbndata.csv and
# creates summaries of station and skimmer activity
# per continent and band.
# Result is saved in rbnact.txt
#set -x

FOLDER="rbndata"
DATE=`date -u --date="1 days ago" +%Y-%m-%d`
DFILE="$FOLDER/.rbndata.csv"
OFILE="$FOLDER/rbnact.txt"

./cunique -f $DFILE > $OFILE

echo >> $OFILE
echo "Last updated "`date -u "+%F %T"`" UTC" >> $OFILE

echo "RBN activity statistics saved in" $OFILE

exit
