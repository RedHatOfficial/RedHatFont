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
