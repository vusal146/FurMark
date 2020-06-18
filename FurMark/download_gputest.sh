#!/bin/sh

#  download_gputest.sh
#  FurMark
#
#  Created by Keaton Burleson on 6/17/20.
#  Copyright © 2020 Keaton Burleson. All rights reserved.

DOWNLOAD_URL="http://www.ozone3d.net/gputest/dl/GpuTest_OSX_x64_0.7.0.zip"

cd ~/
mkdir -p Applications/GpuTest

cd ~/Applications/GpuTest
curl -o GpuTest.zip $DOWNLOAD_URL
unzip -o ./GpuTest.zip

rm -rf __MACOSX
rm -rf GpuTest.zip
