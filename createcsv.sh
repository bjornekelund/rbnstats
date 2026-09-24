#!/usr/bin/env bash
# Creates a machine readable version of the previous day's spot statistics
WEBFOLDER="webfiles"
OUTFILE=$WEBFOLDER/statistics.csv

sort $1 | awk 'BEGIN {
  printf("# Created %s\n", strftime("%Y-%m-%d %H:%M:%S UTC"));
  printf("Callsign,Epoch date,Spot count\n");
  FS=" ";
}
{
  printf("%s,%s,%s\n", $1, $2, $3);
}' > $OUTFILE

echo "Spot count saved in" $OUTFILE
exit
