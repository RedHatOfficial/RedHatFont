#!/bin/sh
set -e

# if [ -z "$1" ]
# then
# 	echo "No version number supplied. If you wish to update the version number in UFOs & built fonts, add one as a build argument:"
# 	echo "sources/build-vf.sh 1.000"
# else
# 	version=$1
# 	python mastering/scripts/edit-ufo-info/set-ufo-version.py sources/Mono $version --save
# fi

## ------------------------------------------------------------------
## Variable Fonts Build - Static build is at sources/build-statics.sh

echo "Generating modified VFs"
mkdir -p fonts/mono/
mkdir -p fonts/proportional/

# Mono fonts are _not_ modified for RedHat.com.
fontmake -m source/Mono/VF/RedHatMonoVF.designspace -o variable --no-production-names --output-path fonts/mono/RedHatMonoVF.ttf
fontmake -m source/Mono/VF/RedHatMonoVFItalic.designspace -o variable --no-production-names --output-path fonts/mono/RedHatMonoVF-Italic.ttf
fontmake -m source/Mono/RedHatMonoVF.designspace -o variable --no-production-names --output-path fonts/mono/RedHatMono.ttf
fontmake -m source/Mono/RedHatMonoVFItalic.designspace -o variable --no-production-names --output-path fonts/mono/RedHatMono-Italic.ttf
#split the mono out and put it in fonts/mono/

#split the proportional out and put them in fonts/proportional
fontmake -m source/Proportional/VF/RedHatTextVF-modified.designspace -o variable --no-production-names --output-path fonts/proportional/RedHatTextVFModified.ttf
fontmake -m source/Proportional/VF/RedHatTextItalicVF-modified.designspace -o variable --no-production-names --output-path fonts/proportional/RedHatTextVF-ItalicModified.ttf
fontmake -m source/Proportional/VF/RedHatDisplayVF-modified.designspace -o variable --no-production-names --output-path fonts/proportional/RedHatDisplayVFModified.ttf
fontmake -m source/Proportional/VF/RedHatDisplayItalicVF-modified.designspace -o variable --no-production-names --output-path fonts/proportional/RedHatDisplayVF-ItalicModified.ttf

fontmake -m source/Proportional/RedHatTextVF.designspace -o variable --no-production-names --output-path fonts/proportional/RedHatText[wght].ttf
fontmake -m source/Proportional/RedHatTextItalicVF.designspace -o variable --no-production-names --output-path fonts/proportional/RedHatText-Italic[wght].ttf
fontmake -m source/Proportional/RedHatDisplayVF.designspace -o variable --no-production-names --output-path fonts/proportional/RedHatDisplay[wght].ttf
fontmake -m source/Proportional/RedHatDisplayItalicVF.designspace -o variable --no-production-names --output-path fonts/proportional/RedHatDisplay-Italic[wght].ttf



mvfs=$(ls fonts/mono/*.ttf)
echo mvfs
echo "Post processing VFs"
for vf in $mvfs
do
	gftools fix-dsig -f $vf;
	#python mastering/scripts/fix_naming.py $vf;
	#ttfautohint-vf --stem-width-mode nnn $vf "$vf.fix";
	#mv "$vf.fix" $vf;
done

vfs=$(ls fonts/proportional/*.ttf)
echo vfs
echo "Post processing VFs"
for vf in $vfs
do
	gftools fix-dsig -f $vf;
done

echo "Fixing mono non Hinting"
for vf in $mvfs
do
	gftools fix-nonhinting $vf "$vf.fix";
	if [ -f "$vf.fix" ]; then mv "$vf.fix" $vf; fi
done

echo "Fixing proportional non Hinting"
for vf in $vfs
do
	gftools fix-nonhinting $vf "$vf.fix";
	if [ -f "$vf.fix" ]; then mv "$vf.fix" $vf; fi
done

echo "Add STAT table"
# Using a copy of the gen_stat.py script from texturina, to try and sort this once and for all.
python mastering/gen_stat_mono.py
python mastering/gen_stat_text.py
python mastering/gen_stat_disp.py
python mastering/gen_stat_monoVF.py
python mastering/gen_stat_textVF.py
python mastering/gen_stat_dispVF.py

echo "stat add complete"


rm -rf fonts/mono/*gasp*
rm -rf fonts/proportional/*gasp*

echo "Remove unwanted fvar instances"
for vf in $mvfs
do
	python mastering/scripts/removeUnwantedVFInstances.py $vf
done

echo "Dropping MVAR"
for vf in $mvfs
do
	# mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=fonts/mono/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done

echo "Fix name table"
for vf in $mvfs
do
    python mastering/scripts/fixNameTable.py $vf
done



echo "Remove unwanted fvar instances"
for vf in $vfs
do
	python mastering/scripts/removeUnwantedVFInstances.py $vf
done

echo "Dropping MVAR"
for vf in $vfs
do
	# mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=fonts/proportional/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done

echo "Fix name table"
for vf in $vfs
do
    python mastering/scripts/fixNameTable.py $vf
done


### Cleanup


rm -rf ./*/instances/
rm -f fonts/*.ttx
rm -f fonts/static/ttf/*.ttx
rm -f fonts/*gasp.ttf
rm -f fonts/static/ttf/*gasp.ttf

# ## -------------------------------------------------------------
# ## Improving version string detail

# echo "----------------------------------------------------------------------------------"
# echo "Adding the current commit hash to variable font version strings"
# font-v write --sha1 "fonts/RedHatMono[wght].ttf"
# font-v write --sha1 "fonts/RedHatMono-Italic[wght].ttf"

echo "Done Generating"

# # # You should check the fonts now with fontbakery, and generate a markdown file.
