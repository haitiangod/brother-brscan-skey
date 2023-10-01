#!/bin/bash
#######################################################################
# Name: install_and_configure.sh
#
# Description: This script is used to install and configure the
# 			brother-brscan-skey package on a debian based system.
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
		customlog "E" "Not running as root! Please run as root or with sudo privileges"
		return 1
	fi
}

# Global variables and default values
SCRIPT_NAME=$(basename $0)

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
shift "$(($OPTIND - 1))"

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

	# Check for root privileges
	if ! checkroot; then
		customlog "E" "Script must be run as root or with sudo privileges."
		exit 1
	fi

	# Download the Brother drivers
	customlog "I" "Downloading Brother drivers..."
	mkdir -p /tmp/brother
	cd /tmp/brother
	wget -q --show-progress --no-check-certificate https://download.brother.com/welcome/dlf105200/brscan4-0.4.11-1.amd64.deb
	wget -q --show-progress --no-check-certificate https://download.brother.com/welcome/dlf006652/brscan-skey-0.3.2-0.amd64.deb

	# Install the Brother drivers
	customlog "I" "Installing Brother drivers..."

	# Install the drivers
	dpkg -i --force-all brscan4-0.4.11-1.amd64.deb
	dpkg -i --force-all brscan-skey-0.3.2-0.amd64.deb

	# Capture the output of the dpkg command
	scanner_driver_output=$(dpkg -l | grep 'Brother Scanner Driver')
	skey_tool_output=$(dpkg -l | grep 'Brother Linux scanner S-KEY tool')

	# Check if the outputs are empty or not
	if [[ -z "$scanner_driver_output" ]]; then
		customlog "E" "Brother Scanner Driver is not installed."
	else
		customlog "I" "Brother Scanner Driver is installed."
	fi

	if [[ -z "$skey_tool_output" ]]; then
		customlog "E" "Brother Linux scanner S-KEY tool is not installed."
	else
		customlog "I" "Brother Linux scanner S-KEY tool is installed."
	fi

	# Configure ImageMagick policy
	customlog "I" "Configuring ImageMagick policy..."
	sed -i '/pattern="PDF"/s/rights="none"/rights="read|write"/' /etc/ImageMagick-6/policy.xml

	# Clean up temporary directory
	customlog "I" "Cleaning up temporary directory..."
	rm -rf /tmp/brother

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
