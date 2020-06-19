#!/bin/bash

echo 'Log available at "build.log"'
echo '' > build.log


/bin/mkdir -p ./Output/
/bin/rm -rf ./Output/*

echo 'Building and archiving'
/usr/bin/xcodebuild archive \
                    -allowProvisioningUpdates \
                    -project FurMark.xcodeproj \
                    -scheme FurMark \
                    -configuration Release \
                    -archivePath Output/FurMark.xcarchive >> build.log

if [ ! $? -eq 0 ]; then
  echo 'Unable to build and archive. Please check build.log for more info'
  exit 1
fi

echo 'Exporting archive'
/usr/bin/xcodebuild -exportArchive \
                    -archivePath ./Output/FurMark.xcarchive \
                    -exportOptionsPlist exportOptions.plist \
                    -exportPath Output/ >> build.log

if [ ! $? -eq 0 ]; then
  echo 'Unable to export the archive. Please check build.log for more info'
  exit 1
fi

/bin/rm -rf ./Output/*.xcarchive

echo 'Done! Available at ./Output/FurMark.app'
exit 0
