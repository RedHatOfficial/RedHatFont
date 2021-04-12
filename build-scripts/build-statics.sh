#!/bin/sh
set -e

# Only use this when necesdsary, are currently not all instances are defined in the VF designspace files.
# generate static designspace referencing csv and variable designspace file
# later, this might not be done dynamically
# python mastering/scripts/generate_fonts_designspace.py

## -------------------------------------------------------------
## Static TTF

echo "Cleaning out old static TTF fonts"

rm -rf fonts/mono/static/ttf
rm -rf fonts/proportional/static/ttf

echo "Generating Static TTF fonts"
echo "Generating mono Statics"

mkdir -p fonts/mono/static/ttf
mkdir -p fonts/proportional/static/ttf

fontmake -M -u source/Mono/RedHatMono-Bold.ufo -o ttf --no-production-names --output-dir fonts/mono/static/ttf/
fontmake -M -u source/Mono/RedHatMono-BoldItalic.ufo -o ttf --no-production-names --output-dir fonts/mono/static/ttf/
fontmake -M -u source/Mono/RedHatMono-Italic.ufo -o ttf --no-production-names --output-dir fonts/mono/static/ttf/
fontmake -M -u source/Mono/RedHatMono-Light.ufo -o ttf --no-production-names --output-dir fonts/mono/static/ttf/
fontmake -M -u source/Mono/RedHatMono-LightItalic.ufo -o ttf --no-production-names --output-dir fonts/mono/static/ttf/
fontmake -M -u source/Mono/RedHatMono-Medium.ufo -o ttf --no-production-names --output-dir fonts/mono/static/ttf/
fontmake -M -u source/Mono/RedHatMono-MediumItalic.ufo -o ttf --no-production-names --output-dir fonts/mono/static/ttf/
fontmake -M -u source/Mono/RedHatMono-Regular.ufo -o ttf --no-production-names --output-dir fonts/mono/static/ttf/

#separate out the mono from the Proportional

#Display styles below. The masters are a 1 to 1 with their instances. Fontmake strips out panose values when generating from designsapces, so instead of building statics from designspaces we are opting to build from ufo ---> corresponding instance. Fontmake's maintainters reference this here: https://github.com/googlefonts/fontmake/issues/688
echo "Generating Display Statics"

fontmake -M -u source/Proportional/RedHatDisplay-Black.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatDisplay-BlackItalic.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatDisplay-Bold.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatDisplay-BoldItalic.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatDisplay-Italic.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatDisplay-Light.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatDisplay-LightItalic.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatDisplay-Medium.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatDisplay-MediumItalic.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatDisplay-Regular.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/

#Text styles below.

echo "Generating Text Statics"

fontmake -M -u source/Proportional/RedHatText-Bold.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatText-BoldItalic.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatText-Italic.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatText-Light.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatText-LightItalic.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatText-Medium.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatText-MediumItalic.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/
fontmake -M -u source/Proportional/RedHatText-Regular.ufo -o ttf --no-production-names --output-dir fonts/proportional/static/ttf/


echo "Post processing mono TTFs"
ttfs=$(ls fonts/mono/static/ttf/*.ttf)
for ttf in $ttfs
do
    gftools fix-dsig -f $ttf;
    if [ -f "$ttf.fix" ]; then mv "$ttf.fix" $ttf; fi
    ttfautohint $ttf "$ttf.fix";
    if [ -f "$ttf.fix" ]; then mv "$ttf.fix" $ttf; fi
    gftools fix-hinting $ttf;
    if [ -f "$ttf.fix" ]; then mv "$ttf.fix" $ttf; fi
    # gftools fix-nonhinting $ttf $ttf.fix
    # mv  $ttf.fix $ttf                                    
    python mastering/scripts/fixNameTable.py $ttf
done

rm -f fonts/mono/static/ttf/*gasp.ttf 

echo "Post processing Proportional TTFs"
ttfs=$(ls fonts/proportional/static/ttf/*.ttf)
for ttf in $ttfs
do
    gftools fix-dsig -f $ttf;
    if [ -f "$ttf.fix" ]; then mv "$ttf.fix" $ttf; fi
    ttfautohint $ttf "$ttf.fix";
    if [ -f "$ttf.fix" ]; then mv "$ttf.fix" $ttf; fi
    gftools fix-hinting $ttf;
    if [ -f "$ttf.fix" ]; then mv "$ttf.fix" $ttf; fi
    # gftools fix-nonhinting $ttf $ttf.fix
    # mv  $ttf.fix $ttf                                    
    python mastering/scripts/fixNameTable.py $ttf
done

rm -f fonts/proportional/static/ttf/*gasp.ttf 

## -------------------------------------------------------------
## Static OTF

echo "Cleaning out old static OTF fonts"
rm -rf fonts/mono/static/otf
rm -rf fonts/proportional/static/otf


echo "Generating Static OTF fonts"
mkdir -p fonts/mono/static/otf
mkdir -p fonts/proportional/static/otf

fontmake -M -u source/Mono/RedHatMono-Bold.ufo -o otf --no-production-names --output-dir fonts/mono/static/otf/
fontmake -M -u source/Mono/RedHatMono-BoldItalic.ufo -o otf --no-production-names --output-dir fonts/mono/static/otf/
fontmake -M -u source/Mono/RedHatMono-Italic.ufo -o otf --no-production-names --output-dir fonts/mono/static/otf/
fontmake -M -u source/Mono/RedHatMono-Light.ufo -o otf --no-production-names --output-dir fonts/mono/static/otf/
fontmake -M -u source/Mono/RedHatMono-LightItalic.ufo -o otf --no-production-names --output-dir fonts/mono/static/otf/
fontmake -M -u source/Mono/RedHatMono-Medium.ufo -o otf --no-production-names --output-dir fonts/mono/static/otf/
fontmake -M -u source/Mono/RedHatMono-MediumItalic.ufo -o otf --no-production-names --output-dir fonts/mono/static/otf/
fontmake -M -u source/Mono/RedHatMono-Regular.ufo -o otf --no-production-names --output-dir fonts/mono/static/otf/

#separate out the mono from the Proportional

#Display styles below. The masters are a 1 to 1 with their instances. Fontmake strips out panose values when generating from designsapces, so instead of building statics from designspaces we are opting to build from ufo ---> corresponding instance. Fontmake's maintainters reference this here: https://github.com/googlefonts/fontmake/issues/688
echo "Generating Display Statics"

fontmake -M -u source/Proportional/RedHatDisplay-Black.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatDisplay-BlackItalic.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatDisplay-Bold.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatDisplay-BoldItalic.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatDisplay-Italic.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatDisplay-Light.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatDisplay-LightItalic.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatDisplay-Medium.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatDisplay-MediumItalic.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatDisplay-Regular.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/

#Text styles below.

echo "Generating Text Statics"

fontmake -M -u source/Proportional/RedHatText-Bold.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatText-BoldItalic.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatText-Italic.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatText-Light.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatText-LightItalic.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatText-Medium.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatText-MediumItalic.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/
fontmake -M -u source/Proportional/RedHatText-Regular.ufo -o otf --no-production-names --output-dir fonts/proportional/static/otf/

echo "Post processing mono OTFs"
otfs=$(ls fonts/mono/static/otf/*.otf)
for otf in $otfs
do
    gftools fix-dsig -f $otf;
    if [ -f "$otf.fix" ]; then mv "$otf.fix" $otf; fi
    gftools fix-nonhinting $otf $otf.fix
    mv  $otf.fix $otf                                    # TODO: add back hinting? added below. 
    python mastering/scripts/fixNameTable.py $otf
    psautohint $otf;
done

rm -f fonts/mono/static/otf/*gasp.otf 

echo "Post processing proportional OTFs"
otfs=$(ls fonts/proportional/static/otf/*.otf)
for otf in $otfs
do
    gftools fix-dsig -f $otf;
    if [ -f "$otf.fix" ]; then mv "$otf.fix" $otf; fi
    gftools fix-nonhinting $otf $otf.fix
    mv  $otf.fix $otf                                    # TODO: add back hinting? Added below. 
    python mastering/scripts/fixNameTable.py $otf
    psautohint $otf;
done

rm -f fonts/proportional/static/otf/*gasp.otf 

## -------------------------------------------------------------
## Improving version string detail

# echo "----------------------------------------------------------------------------------"
# echo "Adding the current commit hash to static font version strings"
# allStaticFonts=$(find fonts/static -type f -name "*.ttf"  -o -name "*.otf")
# for font in $allStaticFonts; do
#     font-v write --sha1 "$font"
# done
