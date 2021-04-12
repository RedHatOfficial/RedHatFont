 #!/bin/sh
set -e

# A script to generate woff2 files for variable & static fonts
# Required: woff2_compress (https://github.com/google/woff2)

## ------------------------------------------------------------------
## variable woff2

mvfDir="fonts/mono/"
mvfWebDir="fonts/mono/web/"

mkdir -p $mvfWebDir

mvfs=$(ls $mvfDir/*.ttf)
echo mvfs
echo "Making woff2 files from VFs"
for vf in $mvfs
do
	woff2_compress $vf;

	woff2=$(basename -s .ttf $vf).woff2
	mv $mvfDir/$woff2 $mvfWebDir/$woff2
done

## ------------------------------------------------------------------
## static woff2

mstaticDir="fonts/mono/static/ttf/"
mstaticWebDir="fonts/mono/static/web"

mkdir -p $mstaticWebDir

mttfs=$(ls $mstaticDir/*.ttf)
echo "Making woff2 files from mono static TTFs"
for ttf in $mttfs
do
	woff2_compress $ttf;

	woff2=$(basename -s .ttf $ttf).woff2
	mv $mstaticDir/$woff2 $mstaticWebDir/$woff2
done




pvfDir="fonts/proportional/"
pvfWebDir="fonts/proportional/web/"

mkdir -p $pvfWebDir

pvfs=$(ls $pvfDir/*.ttf)
echo pvfs
echo "Making woff2 files from VFs"
for vf in $pvfs
do
	woff2_compress $vf;

	woff2=$(basename -s .ttf $vf).woff2
	mv $pvfDir/$woff2 $pvfWebDir/$woff2
done

## ------------------------------------------------------------------
## static woff2

pstaticDir="fonts/proportional/static/ttf/"
pstaticWebDir="fonts/proportional/static/web/"

mkdir -p $pstaticWebDir

pttfs=$(ls $pstaticDir/*.ttf)
echo "Making woff2 files from static TTFs"
for ttf in $pttfs
do
	woff2_compress $ttf;

	woff2=$(basename -s .ttf $ttf).woff2
	mv $pstaticDir/$woff2 $pstaticWebDir/$woff2
done

