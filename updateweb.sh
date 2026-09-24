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

echo "Downloading RBN data for" $NEWDATE

wget --quiet --no-hsts http://www.reversebeacon.net/raw_data/dl.php?f=$NEWDATE -O $RBNFOLDER/rbndata.zip

FILESIZE=$(stat -c%s $RBNFOLDER/rbndata.zip)

if [[ $FILESIZE != "0" ]]; then
  gunzip < $RBNFOLDER/rbndata.zip > $RBNFOLDER/rbndata.csv
  echo "Downloaded "$((`wc -l < $RBNFOLDER/rbndata.csv` - 2))" spots"
  EPOCHDATE=$(($(date --utc --date="$date" +%s)/86400))
  # Process
  ./parse.sh $EPOCHDATE < $RBNFOLDER/rbndata.csv > $NEWFILE
  echo "Raw skimmer statistics from epoch day #"$EPOCHDATE" saved in" $NEWFILE
else
  echo "Failed to download RBN data"
  exit
fi

./createstats.sh
./createstatsp.sh
./createactdata.sh

#printf "Uploading to web hosting..."
./ftptohost.sh $CREDFILE $WEBFOLDER/rbnstats.txt $WEBFOLDER/rbnstatsp.txt $WEBFOLDER/rbnact.txt
#printf "done\n"

echo "Job ended "`date -u "+%F %T"`" UTC and took $((SECONDS-START)) seconds"

exit
