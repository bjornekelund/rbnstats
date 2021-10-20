#!/bin/bash
# Calculate a new set of reference skimmers for the next night's run
# Built to be called from script updateweb or initweb

gawk --assign date=$1 '\
BEGIN {
  FS=",";
  skimmers = 0;
}
{
  if ($1 ~ /^[A-Z0-9]/) {
    if (skimmer[$1] == 0)
      skimmers++;
    skimmer[$1]++;
  }
}
END {
  for (callsign in skimmer) {
    printf("%s %d %d\n", callsign, date, skimmer[callsign]);
  }
}'
