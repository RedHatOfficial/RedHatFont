# !/bin/bash

set -e

# if [ -z "$1" ]
# then
# 	echo "No version number supplied. If you wish to update the version number in UFOs & built fonts, add one as a build argument:"
# 	echo "sources/build-all.sh 1.001"
# else
# 	version=$1
# 	python mastering/scripts/edit-ufo-info/set-ufo-version.py source/Mono $version --save
# 	python mastering/scripts/edit-ufo-info/set-ufo-version.py source/Proportional $version --save
# fi

build-scripts/build-vf.sh $version

build-scripts/build-statics.sh 

build-scripts/make-woff2s.sh

echo "bump up version"
gftools update-version ./fonts/proportional/RedHatDisplay-Italic\[wght\].ttf ./fonts/proportional/RedHatDisplay\[wght\].ttf ./fonts/proportional/RedHatText-Italic\[wght\].ttf ./fonts/proportional/RedHatText\[wght\].ttf ./fonts/mono/RedHatMono-Italic\[wght\].ttf ./fonts/mono/RedHatMono\[wght\].ttf 1.010 1.021

mv -f ./fonts/proportional/RedHatDisplay-Italic\[wght\].ttf.fix ./fonts/proportional/RedHatDisplay-Italic\[wght\].ttf
mv -f ./fonts/proportional/RedHatDisplay\[wght\].ttf.fix ./fonts/proportional/RedHatDisplay\[wght\].ttf
mv -f ./fonts/proportional/RedHatText-Italic\[wght\].ttf.fix ./fonts/proportional/RedHatText-Italic\[wght\].ttf
mv -f ./fonts/proportional/RedHatText\[wght\].ttf.fix ./fonts/proportional/RedHatText\[wght\].ttf
mv -f ./fonts/mono/RedHatMono-Italic\[wght\].ttf.fix ./fonts/mono/RedHatMono-Italic\[wght\].ttf
mv -f ./fonts/mono/RedHatMono\[wght\].ttf.fix ./fonts/mono/RedHatMono\[wght\].ttf

echo "Complete"