#!/bin/sh

#  launch_multiple_simulators.sh
#  iOSApp
#
#  Created by Eric Gustin on 5/21/20.
#  Copyright © 2020 Eric Gustin. All rights reserved.

xcrun simctl shutdown all # Remove this line if you dont need to launch every time

path=$(find ~/Library/Developer/Xcode/DerivedData/iOSApp-*/Build/Products/Debug-iphonesimulator -name "iOSApp.app" | head -n 1)
echo "${path}"

filename=MultiSimConfig.txt
grep -v '^#' $filename | while read -r line
do
xcrun simctl boot "$line" # Boot the simulator with identifier hold by $line var
xcrun simctl install "$line" "$path" # Install the .app file located at location hold by $path var at booted simulator with identifier hold by $line var
xcrun simctl launch "$line" com.eric.iOSApp # Launch .app using its bundle at simulator with identifier hold by $line var
done
