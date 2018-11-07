#! /bin/bash
# Note: ~/.ssh/environment should not be used, as it
for HOST in $(<./serverlist.txt)
do
    echo "Uploading .bashrc to $HOST"
    scp ~/.bashrc $HOST:~/.bashrc
done
