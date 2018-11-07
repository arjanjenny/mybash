#!/bin/bash
# Usage: optimize images
count=0
total=`find -type f -name '*.png' | wc -l`
pstr="[========================================]"
echo "Optimizing $total PNG files" | xargs
find . -name '*.png' -print0 | 
while IFS= read -r -d $'\0' line; do 
    # Get filesize before
    file_size_kb_before=`du -k "$line" | cut -f1`
    # Actual optimization line
    optipng -o7 -strip all -q $line
    # Get filesize after
    file_size_kb_after=`du -k "$line" | cut -f1`
    #
    percent=$(awk "BEGIN { pc=100*${file_size_kb_after}/${file_size_kb_before}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
    percentdecrease=$((100-${percent}))
    if [ $percent = "100" ]; then
       opt="Already optimized"
    else
       opt="Optimized: ${file_size_kb_after}kb = $percentdecrease%% decrease"
    fi
    count=$(( $count + 1 ))
    pd=$(( $count * 73 / $total ))
    printf "$count/$(set -f; echo $total): $line --> $opt \r\n"
    # printf "\r%3d.%1d%% %.${pd}s" $(( $count * 100 / $total )) $(( ($count * 1000 / $total) % 10 )) $pstr
done
echo "$total PNG files processed" | xargs