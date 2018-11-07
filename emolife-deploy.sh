#! /bin/bash
# Note: ~/.ssh/environment should not be used, as it3
file=~/emolifeservers.txt
while read -r line ; do
    server=$(echo "$line" | cut -f1 -d",")
    cddir=$(echo "$line" | cut -f2 -d",")
    ssh "$server" < /dev/null
    cd ... || "$cddir"
    pull origin master
done < ${file}