#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# 
# version 2.0
# Written by: Mischa van der Bent
#
# Permission is granted to use this code in any way you want.
# Credit would be nice, but not obligatory.
# Provided "as is", without warranty of any kind, express or implied.
#
# Original source:
# https://github.com/mvdbent/setDock/blob/main/setDock-defaultDock.sh
#
# DESCRIPTION
# This script configures users docks using docktutil
# source dockutil https://github.com/kcrawford/dockutil/
# 
# REQUIREMENTS
# dockutil Version 3.0.0 or higher installed to /usr/local/bin/
# Compatible with macOS 11.x and higher
#
# THIS FORK/VERSION
# This is a modification of Mischa's original by Anthony Reimer to allow more flexibility:
# • Dock items are split into three lists: alwaysApps, alwaysOthers, and optionalItems
#   (you no longer have to hardcode "Others" for the right side/bottom end of the Dock).
# • "always" items (Apps and Others) are added even if not present.
# • "optionalItems" (which can be Apps or Others) are only added if present.
# • You are allowed to specify dockutil options for alwaysOthers (in the optionsOthers 
#   list) and optionalItems (in the optionsOptional list).
#
# This version of the script requires root privileges. Use setDock-defaultDockOutset.sh if
# you want to run it the user space with user permissions, such as with a tool like Outset.
#
# Source for this fork/version:
# https://github.com/jazzace/setDock/blob/main/setDock-defaultDock.sh
#
# Code last edited 2022-06-03
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Full path to Applications to add to the Dock every time, even if they are not present on the system yet.
# Items will be added in order. None of the additional options of dockutil are used on these items.
alwaysApps=(
"/System/Applications/Launchpad.app"
"/System/Applications/Mission Control.app"
"/Applications/Safari.app"
"/Applications/Pages.app"
"/Applications/Numbers.app"
"/Applications/Keynote.app"
"/Applications/iMovie.app"
"/Applications/GarageBand.app"
"/System/Applications/System Preferences.app"
)

# Path to folders and files for the right side of the Dock ("others"); ~/ syntax may be used.
# This list pairs with optionsOthers to specify how you would like these items to be displayed
# (i.e., the first folder listed in alwaysOthers will be run with the options specified on the
# first line of optionsOthers).
alwaysOthers=(
"/Applications"
"~/Downloads"
)

# Display options for items in alwaysOthers in order.
# You should have one entry for each entry in alwaysOthers.
# For files, use a pair of quotes (null string) since there are no display options.
optionsOthers=(
"--view grid --display folder --sort name"
"--view list --display folder --sort dateadded"
)

# Path to items to add to the Dock (apps, folders, files) only if they are present.
# This list pairs with optionsOptional to specify how you would like these items to be displayed.
optionalItems=(
"/Applications/Google Chrome.app"
"/Applications/Microsoft Word.app"
"/Applications/Microsoft Excel.app"
"/Applications/Microsoft PowerPoint.app"
"/Applications/Final Cut Pro.app"
"/Applications/Logic Pro X.app"
"/Applications/Motion.app"
"/Applications/Remote Desktop.app"
)

# Display options for items in optionalItems in order.
# You should have one entry for each entry in optionalItems.
# If you do not want to specify options for an item, use a pair of quotes (null string).
#
# You must escape or quote (with a different type of quote mark) any argument that has a
# space in it (e.g., "--after 'Microsoft Word'" or "--after Microsoft\ Word").
# Using the app identifier instead of the app name is not supported by this script.
#
# Any relative options (e.g., --before, --after) will be applied to the Dock in the State
# it was in after the "always" apps and others are applied
optionsOptional=(
"--after Safari"
"--after Pages"
"--after Numbers"
"--after Keynote"
"--replacing iMovie"
"--replacing GarageBand"
"--before 'System Preferences'"
""
)

###############################################################
# You should not have to edit any of the code after this line #
###############################################################
# COLLECT IMPORTANT USER INFORMATION
# Get the currently logged in user
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

# Get uid logged in user
uid=$(id -u "${currentUser}")

# Current User home folder - do it this way in case the folder isn't in /Users
userHome=$(dscl . -read /users/${currentUser} NFSHomeDirectory | cut -d " " -f 2)

# Path to plist
plist="${userHome}/Library/Preferences/com.apple.dock.plist"

# Convenience function to run a command as the current user
# usage: runAsUser command arguments...
runAsUser() {  
	if [[ "${currentUser}" != "loginwindow" ]]; then
		launchctl asuser "$uid" sudo -u "${currentUser}" "$@"
	else
		echo "no user logged in"
		exit 1
	fi
}

# Check if dockutil is installed
if [[ -x "/usr/local/bin/dockutil" ]]; then
    dockutil="/usr/local/bin/dockutil"
else
    echo "dockutil not installed in /usr/local/bin, exiting"
    exit 1
fi

# Version dockutil
dockutilVersion=$(${dockutil} --version)
echo "Dockutil version = ${dockutilVersion}"

# Create a clean Dock
runAsUser "${dockutil}" --remove all --no-restart ${plist}
echo "All items removed from user’s Dock"

# Loop through alwaysApps and add item to the Dock. Log (only) if app is missing.
for app in "${alwaysApps[@]}"; 
do
	runAsUser "${dockutil}" --add "${app}" --no-restart ${plist};
	if [[ ! -e "${app}" ]]; then
		echo "${app} not installed but Dock item added"
    fi
done

# Need to restart the Dock to allow any relative options to be applied in further commands.
killall -KILL Dock

# Loop through alwaysOthers and add folder/file to the right part of the Dock, even if item is missing.

# Check first to see if there are matching options for each item and log any errors (but do not stop)
itemCount=${#alwaysOthers[@]}
optionsCount=${#optionsOthers[@]}
if [ $itemCount -gt $optionsCount ] ; then
    echo "There are more items for the right side of the Dock than there are matching options; some items will receve default options"
elif [ $itemCount -lt $optionsCount ] ; then
    echo "There are more options than there are items for the right side of the Dock; results may not be as anticipated"
fi

for (( i=0 ; i<itemCount ; i++)); 
do
	eval runAsUser "${dockutil}" --add \"${alwaysOthers[i]}\" ${optionsOthers[i]} --no-restart ${plist};
	if [[ ! -e "${alwaysOthers[i]}" ]] && [[ "${alwaysOthers[i]:0:1}" != '~' ]] ; then
		echo "${alwaysOthers[i]} not present but Dock item added"
    fi
done

# Loop through optionalItems and check if item is installed. If installed, add to the Dock
# using the options specified in optionsOptional.
itemCount=${#optionalItems[@]}
optionsCount=${#optionsOptional[@]}
if [ $itemCount -gt $optionsCount ] ; then
    echo "There are more optional Dock items than there are matching options; some items will receve default options"
elif [ $itemCount -lt $optionsCount ] ; then
    echo "There are more options than there are optional items for the Dock; results may not be as anticipated"
fi

for (( i=0 ; i<itemCount ; i++)); 
do
	if [[ -e "${optionalItems[i]}" ]]; then
		eval runAsUser "${dockutil}" --add \"${optionalItems[i]}\" ${optionsOptional[i]} --no-restart ${plist};
	else
		echo "${optionalItems[i]} not present and no Dock item added"
    fi
done

# Kill the Dock (again) to use all new settings
killall -KILL Dock
echo "Restarted the Dock"

echo "Finished creating default Dock"

exit 0
