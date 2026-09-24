#!/usr/bin/env bash
# Does incremental analysis of RBN skimmer activity
#set -x

# Move to correct folder to allow cron execution
[ -d "/home/sm7iun/rbnstats" ] && cd /home/sm7iun/rbnstats

RBNFOLDER="rbndata"
WEBFOLDER="webfiles"
NEWFILE="$RBNFOLDER/`date -u --date="1 days ago" +%Y%m%d`.txt"
NEWDATE="`date -u --date="1 days ago" +%Y%m%d`"
OLDFILE="$RBNFOLDER/`date -u --date="11 days ago" +%Y%m%d`.txt"
CREDFILE="WEBCREDENTIALS"

echo "---"
echo "Job started "`date -u "+%F %T"`UTC

START=$SECONDS

OLDESTRBN="$RBNFOLDER/`date -u --date="10 days ago" +%Y%m%d`.txt"
[ -f $OLDESTRBN ] || ./initialize.sh

[ -f cunique ] || make

rm -rf $OLDFILE

printf "Downloading RBN data for $NEWDATE..."

wget --quiet --no-hsts http://www.reversebeacon.net/raw_data/dl.php?f=$NEWDATE -O $RBNFOLDER/rbndata.zip

FILESIZE=$(stat -c%s $RBNFOLDER/rbndata.zip)

if [[ $FILESIZE != "0" ]]; then
  gunzip < $RBNFOLDER/rbndata.zip > $RBNFOLDER/rbndata.csv
  echo "done ("$((`wc -l < $RBNFOLDER/rbndata.csv` - 2))" spots)"
  EPOCHDATE=$(($(date --utc --date="$date" +%s)/86400))
  ./parse.sh $EPOCHDATE < $RBNFOLDER/rbndata.csv > $NEWFILE
  echo "Skimmer statistics saved in $NEWFILE"
else
  printf "\nERROR: Failed to download RBN data!\n"
  exit 1
fi

./createstats.sh
./createstatsp.sh
./createactdata.sh
./createcsv.sh $NEWFILE

./ftptohost.sh $CREDFILE $WEBFOLDER/rbnstats.txt $WEBFOLDER/rbnstatsp.txt $WEBFOLDER/rbnact.txt $WEBFOLDER/statistics.csv

echo "Job ended "`date -u "+%F %T"`" UTC and took $((SECONDS-START)) seconds"

exit
