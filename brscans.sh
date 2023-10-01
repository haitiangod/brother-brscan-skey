#!/bin/bash
#######################################################################
# Name: brscans.sh
#
# Description: This script is used to run the brother-brscan-skey
#               package on a debian based system.
#
# Usage: See below function for how to use.
#
# Creator: Edge Fabre
# Created: 10-01-2023
# Maintainers: Edge Fabre
#
# CHANGELOG
#    10-01-2023: Creation of script
#######################################################################

# Usage function that shows how to use this script
usage() {
    echo "Usage:"
    echo "$(basename $0) [-t] [-q] [-d] [-h] [-y '/path/to/log'] [-x 'Sample Param']"
    echo ""
    echo "Options:"
    echo "  -t                  Runs the script in trial mode, remove for real deal"
    echo "  -q                  Runs script non-interactively using defaults"
    echo "  -d                  Runs the script in debug mode, very loud output"
    echo "  -h                  Prints help menu, which you are currently reading"
    echo "  -y '/path/to/log'   Path to write log file"
    echo "  -x 'Sample Param'   Example of how to input parameters"
    exit 1
}

# Custom logger function for my scripts
customlog() {
    datenowstamp=$(date '+%m/%d/%Y %H:%M:%S')
    if [ "$1" = "D" -a "$d_value" = "true" ]; then
        echo "$datenowstamp $1: $2" >/dev/stdout
    elif [ "$1" != "D" ]; then
        echo "$datenowstamp $1: $2" >/dev/stdout
    fi
    echo "$datenowstamp $1: $2" >>$y_value'/'$SCRIPT_NAME.log
}

# function that checks if command is run as root
checkroot() {
    if [ $(id -u) -eq 0 ]; then
        customlog "D" "Currently running as root."
        return 0
    else
        customlog "E" "Only root may add a user to the system."
        return 1
    fi
}

# Global variables and default values
SCRIPT_NAME=$(basename "$0")

# This section reads flags using getopts
# Default flag values
t_value='false'
q_value='false'
d_value='false'
y_value='/var/log'
x_value='Default Param'

while getopts 'tqdhy:x:' OPTION; do
    case "$OPTION" in
    t)
        t_value='true'
        ;;

    q)
        q_value='true'
        ;;

    d)
        d_value='true'
        ;;

    h)
        usage
        ;;

    y)
        y_value="$OPTARG"
        ;;

    x)
        x_value="$OPTARG"
        ;;

    ?)
        usage
        ;;
    esac
done
shift "$((OPTIND - 1))"

customlog "I" "*****************************************************"
customlog "I" "Running '$SCRIPT_NAME'!"

# Make script mode announcements
if [ "$d_value" = "true" ]; then
    customlog "I" "Running in DEBUG Mode"
fi

# Check for script parameters
customlog "D" "t_value equals $t_value"
customlog "D" "q_value equals $q_value"
customlog "D" "d_value equals $d_value"

###############################
### DO NOT ALTER ABOVE CODE ###
### Insert Code Logic Below ###
###############################

# This function executes if script is running non-interactively.
# It will check for missing parameters, if checks fail, script must stop
noninteractivepod() {
    customlog "I" "Now in 'noninteractivepod()'"

    # Indicate destinations where to save copy of pdf and save logs
    PDF_DEST1="/scans"
    PDF_DEST2="/var/brscans"
    LOG_FILE=/var/log/$(basename "$0" .sh).log
    # Default values in case the environment variables are not set
    DENSITY=${DENSITY:-150}
    COMPRESS=${COMPRESS:-jpeg}
    QUALITY=${QUALITY:-100}
    MONOCHROME=${MONOCHROME:-false}

    customlog "D" "The value of DENSITY is: $DENSITY, COMPRESS is: $COMPRESS, QUALITY is: $QUALITY, MONOCHROME is: $MONOCHROME"

    rm -rf *.pdf
    cp "$original" "$F"

    # Set monochrome option
    if [ "$MONOCHROME" = "true" ]; then
        MONOCHROME_OPTION="-monochrome"
    else
        MONOCHROME_OPTION=""
    fi

    # Create save locations if they do not exist
    mkdir -p $PDF_DEST1
    mkdir -p $PDF_DEST2

    # Stop hanged brscan-skey-exe processes
    pkill -9 brscan-skey-exe

    # Check for mandatory environment variables
    if [[ -z "$NAME" || -z "$MODEL" || -z "$IPADDRESS" ]]; then
        customlog "E" "Environment variables NAME, MODEL, and IPADDRESS must be set."
        exit 1
    fi

    # Configure the printer
    brsaneconfig4 -a name="$NAME" model="$MODEL" ip="$IPADDRESS"

    # Verify the printer configuration
    output=$(brsaneconfig4 -q | grep "$MODEL.*$IPADDRESS") # Query and filter for the desired scanner and IP

    # Check the output and log accordingly
    if [[ $output == *"$MODEL"* && $output == *"$IPADDRESS"* ]]; then
        customlog "I" "Successfully detected scanner: $output" # Logs the scanner model and IP address indicating it's detected
    else
        customlog "E" "Scanner $MODEL at $IPADDRESS not detected."
    fi
    customlog "D" "Running as $(whoami)"
    customlog "I" "Starting brscan-skey daemon. Waiting for scanner events…"
    brscan-skey | while read -r msg; do
        F="$(echo "$msg" | sed -e 's/^\(.*\) is created\..*$/\1/')"
        FB="${F%%.tif}"
        B=$(basename "$F")
        BB=$(basename "$FB")
        D=$(dirname "$F")

        customlog "D" "F=$F"
        customlog "D" "FB=$FB"
        customlog "D" "B=$B"
        customlog "D" "BB=$BB"
        customlog "D" "D=$D"

        customlog "I" "Received: $B"

        Y="Failed: MISSING INPUT FILE"
        test -f "$F" && Y=$(convert -density "$DENSITY" -compress "$COMPRESS" -quality "$QUALITY" $MONOCHROME_OPTION -page letter "$F" "$PDF_DEST1/$BB.pdf" 2>&1)
        customlog "I" "Conversion to $BB.pdf Y:${Y:-OK}"
        customlog "I" "$PDF_DEST1/$BB.pdf Y:${Y:-OK}"
    done
    customlog "E" "brscan-skey died for some reason…"
}

# This function executes if script is running interactively.
# It will check and prompt for missing parameters.
interactivepod() {
    customlog "I" "Now in 'interactivepod()'"
    exit 1
}

###############################
### DO NOT ALTER BELOW CODE ###
### Insert Code Logic Above ###
###############################

if [ "$q_value" = "true" ]; then
    customlog "I" "Script running non-interactively"
    noninteractivepod
else
    customlog "I" "Script running interactively"
    interactivepod
fi

customlog "I" "Completed '$SCRIPT_NAME'!"
