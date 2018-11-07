#!/usr/bin/env sh
#
# This script automates images optimization
# is mainly used by a developer who manually
# can execute it when adding new images to the
# project
#
# Download and compile following binaries:
#
#   - [jpegtran](http://www.ijg.org/)
#   - [pngcrush](http://pmt.sourceforge.net/pngcrush)
#   - [OptiPNG](http://optipng.sourceforge.net/)
#   - [pngout](http://advsys.net/ken/utils.htm)
#   - [advpng](http://advancemame.sourceforge.net/comp-readme.html)
#

SCRIPTPATH=$(readlink -f "$0")
# Get directory path of this script
SCRIPTDIR=$(dirname "$SCRIPTPATH")

# Set path to directory with images
IMAGESDIR="$SCRIPTDIR/public_html/wp-content/uploads/"

##################
# Optimize JPEGS #
##################
if command -v jpegtran > /dev/null 2>&1
then
  echo "Optimizing JPEG images" | mail -s "Blog.neckermann.nl: Optimizer ran for JPG" arjan@infamousrepublic.com
  find $IMAGESDIR \( -mtime -7 -name "*.jpg" -o -name "*.jpeg" \) -exec jpegtran -copy none -optimize -outfile '{}' '{}' \;
else
  echo "Hmm, you're missing JPEGTRAN. I recommend you install it for best result"
fi

#################
# Optimize PNGs #
#################
if command -v optipng > /dev/null 2>&1
then
  echo "Optimizing PNG images using OptiPNG" | mail -s "Blog.neckermann.nl: Optimizer ran for PNG" arjan@infamousrepublic.com
  find $IMAGESDIR -mtime -7 -name "*.png" -exec optipng -o7 -q '{}' \;
else
  echo "Hmm, you're missing OptiPNG. I recommend you install it for best result"
fi