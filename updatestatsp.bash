#!/bin/bash
# Uses saved analysis results from the last ten days
# to assemble a table sorted by skimmer callsign
# updatewebdata creates the required result files.
# These have be to manually created before the first run.
#set -x

FOLDER="rbndata"
OUTFILE=rbnstatsp.txt
FILES="$FOLDER/`date -u --date="1 days ago" +%Y%m%d`.txt $FOLDER/`date -u --date="2 days ago" +%Y%m%d`.txt \
 $FOLDER/`date -u --date="3 days ago" +%Y%m%d`.txt $FOLDER/`date -u --date="4 days ago" +%Y%m%d`.txt \
 $FOLDER/`date -u --date="5 days ago" +%Y%m%d`.txt $FOLDER/`date -u --date="6 days ago" +%Y%m%d`.txt \
 $FOLDER/`date -u --date="7 days ago" +%Y%m%d`.txt $FOLDER/`date -u --date="8 days ago" +%Y%m%d`.txt \
 $FOLDER/`date -u --date="9 days ago" +%Y%m%d`.txt $FOLDER/`date -u --date="10 days ago" +%Y%m%d`.txt"

#echo "\$FILES="$FILES

# Produce header of output file
# Print data in reverse chronological order with newest data to the left

cat $FILES > .history.txt

awk '{
  array[$1][$2] = $3;
  call = $1;
}
END {
# Find a call that has been active all ten days
  for (trycall in array) {
    if (isarray(array[trycall])) {
      k = 0;
      for (elem in array[trycall])
        k++;
      if (k == 10) {
        call = trycall;
        break;
      }
    }
  }
  printf("Skimmer  ");
  j = 0
  for (datestring in array[call]) {
    date[j++] = strftime("%m%d", datestring*86400);
  }
# Print in antichronological order
  for (j = 9; j >= 0; j--) {
    printf("%6s", date[j]);
  }
  printf("\n---------------------------------------------------------------------\n");
}' .history.txt > $OUTFILE

# Produce meat of output file
# Print data in reverse chronological order with newest data to the left
awk '
{
  array[$1][$2] = $3;
  call = $1;
  daytotal[$2] += $3;
}
END {
# Find a call that has been active all ten days
  for (trycall in array) {
    if (isarray(array[trycall])) {
      k = 0;
      for (elem in array[trycall])
        k++;
      if (k == 10)
        call = trycall;
    }
  }
# Put the date of the last ten days in date[]
  j = 0
  for (datestring in array[call]) {
    date[j++] = datestring;
#    printf("daytotal[%s]=%d\n", datestring, daytotal[datestring]) > "/dev/stderr";
  }
  for (i in array) {
	printf("%-9s", i);
    if (isarray(array[i])) {
# Print data in row in antichronological order
      for (j = 9; j >= 0; j--) {
        element = array[i][date[j]];
        if (element != "") {
          share = 1000.0 * element / daytotal[date[j]];
#          printf((share >= 10.0) ? "%5.1f%s" : "%5.2f%s", share, "&#x2030");
#          printf((share >= 10.0) ? "%5.1f%s" : "%5.2f%s", share, "&#x2030");
          printf("%6.2f", share);
        }
        else
          printf("%6s", element);
      }
	  printf("\n");
    }
}}' .history.txt | sort >> $OUTFILE

echo >> $OUTFILE
echo "Last updated "`date -u "+%F %T"`" UTC" >> $OUTFILE

echo "Analysis done, result stored in" $OUTFILE
exit
