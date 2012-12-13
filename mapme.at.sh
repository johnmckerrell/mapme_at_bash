#!/bin/bash
##
# mapme.at DNS updater
# (c) John McKerrell 2009
# This code has been released into the public domain and may be modified
# and distributed without restriction.

##
# Function for performing the DNS update
#
# Accepts either a single argument which should be a favourite label or
# two arguments, a latitude and a longitude. It then calculates the
# correct domain and requests it, attempts to parse the response and 
# output it to the user.
mapme() {
    # Retrieves the unix timestamp
    DATE=`date +%s`

    # Parses the arguments
    if [ "$2" == "" ]; then
        # Favourite label is easy to handle
        DOMAIN="$1."
    else
        # Latitude and longitude need the decimal point replacing
        # and an 'l' placed at the beginning.
        LAT=`echo "$1" | sed 's/\./d/g'`
        LON=`echo "$2" | sed 's/\./d/g'`
        DOMAIN="l$LAT.l$LON."
    fi

    # Put the parts together to create the domain
    DOMAIN="$DOMAIN$DATE.$SHORTCODE.dns.mapme.at"
    #echo $DOMAIN

    # Request the domain and attempt to parse the response
    echo `dig txt $DOMAIN | grep -A 1 'ANSWER SECTION' | tail -1 | sed -E 's/(.*TXT.\"|\")//g'`

    # If the dig failed completely, alert the user.
    if [ "$?" != "0" ]; then
        echo "There was a problem logging you at this location."
    fi
}

##
# Function for getting the directory that the script resides in
# Resolves links, etc.
# Found at: http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
source_dir() {
    SOURCE="${BASH_SOURCE[0]}"
    DIR="$( dirname "$SOURCE" )"
    while [ -h "$SOURCE" ]
    do 
      SOURCE="$(readlink "$SOURCE")"
      [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
      DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd )"
    done
    SOURCE_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
}

# Prepare the directory for the mapme.at settings
SDIR="$HOME/.mapme.at"
SFILE="$SDIR/shortcode"
if [ ! -d $SDIR ]; then
    mkdir -p $SDIR
fi

# If requested, store the shortcode
if [ "$1" == "shortcode" ]; then
    if [ "$2" == "" ]; then
        echo "Enter your shortcode:"
        read SHORTCODE
    else
        SHORTCODE="$2"
    fi
    echo "Please remember that your shortcode is stored in plaintext here:"
    echo "  $SFILE"
    echo "Anyone with access to this file will be able to set your location."
    echo -n "$SHORTCODE" > $SFILE
    chmod 0600 $SFILE
    exit;
fi

# If no arguments given, show the instructions
if [ "$1" == "" ]; then
    echo "mapme.at.sh instructions"
    echo "You must set your shortcode before you can use this script. This"
    echo "will then be stored in plaintext on your system:"
    echo "  mapme.at.sh shortcode [<shortcode>]"
    echo
    echo "Once shortcode has been set you can update location using either"
    echo "a favourite label or a raw lat/lon, e.g.:"
    echo "  mapme.at.sh home"
    echo "  mapme.at.sh 56.493773 0.439453"
    exit
fi

# If there is no shortcode file, alert the user
if [ ! -f $SFILE ]; then
    echo "You must set your shortcode before you can use this script:"
    echo "  mapme.at.sh shortcode <shortcode>"
    exit
fi
SHORTCODE=`cat $SFILE`

# If a character device has been given as the first argument
# then assume it's a GPS and attempt to read an NMEA position
# using the gps.mapme.at.rb ruby script.
if [ -c $1 ]; then
    source_dir
    echo "Reading your location from GPS found at: $1"
    POS=`$SOURCE_DIR/gps.mapme.at.rb $1`
    if [ "$POS" == "" ]; then
        echo "Couldn't read your position from the specified GPS device."
    else
        LAT="${POS/ */}"
        LON="${POS/* /}"
        echo "Mapping you at ($LAT,$LON)"
        mapme $LAT $LON
    fi
else
    # If no second argument has been passed then assume
    # the user has passed in a favourite label.
    if [ "$2" == "" ]; then
        echo "Mapping you at $1"
        mapme $1
    else
        # Otherwise we must have been passed a latitude and longitude
        echo "Mapping you at ($1,$2)"
        mapme $1 $2
    fi
fi
