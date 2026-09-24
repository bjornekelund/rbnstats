#!/usr/bin/env bash
# Analyses the content of rbndata/rbndata.csv and
# creates summaries of station and skimmer activity
# per continent and band.
# Result is saved in rbnact.txt
#set -x

RBNFOLDER="rbndata"
WEBFOLDER="webfiles"
DATE=`date -u --date="1 days ago" +%Y-%m-%d`
INFILE="$RBNFOLDER/rbndata.csv"
OUTFILE="$WEBFOLDER/rbnact.txt"

test -e "$WEBFOLDER" || mkdir $WEBFOLDER

./cunique -f $INFILE > $OUTFILE

echo >> $OUTFILE
echo "Last updated "`date -u "+%F %T"`" UTC" >> $OUTFILE

echo "RBN activity statistics saved in" $OUTFILE

exit
