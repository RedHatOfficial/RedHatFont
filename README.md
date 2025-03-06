# Red Hat Typeface Files

## Designers

### Jeremy Mickel

Jeremy Mickel runs [MCKL](https://www.mckltype.com), a Los Angeles-based type foundry and design studio publishing original fonts and creating custom designs for clients. Founded in 2012, MCKL has collaborated with leading design firms, companies, and organizations around the world to provide custom typeface and logo design services. Mickel's work has been recognized by the Type Directors Club and the AIGA, and he has taught at RISD and the Minneapolis College of Art and Design.

## About Red Hat Display and Red Hat Text

![Type specimen](type-specimen@2x.png)

Red Hat is an enterprise software company with an open source development model. We use collaboration and knowledge sharing to craft better, more reliable, and more adaptable technologies. How our words look is as important to our brand voice as the words we choose. That’s why we developed a type family that’s all our own.

The Red Hat Typeface is a superfamily of Display, Text, and Mono styles, each with a range of weights in roman and italic. The fonts were originally commissioned by Paula Scher / [Pentagram](https://www.pentagram.com/) and designed by Jeremy Mickel / [MCKL](https://www.mckltype.com) for the new Red Hat identity.

Red Hat is a fresh take on the geometric sans genre, taking inspiration from a range of American sans serifs including Tempo and Highway Gothic. The Display styles, made for headlines and big statements, are low contrast and spaced tightly, with a large x-height and open counters. The Text styles have a slightly smaller x-height and narrower width for better legibility, are spaced more generously, and have thinned joins for better performance at small sizes. In 2021 we added Light and Light Italic styles, and a Monospace family. The fonts can be used together seamlessly at a range of sizes.

As part of Red Hat’s commitment to open source software, the fonts are made available for use under the SIL Open Font License.

## Variable Fonts

 A demo for variable fonts is available at [https://redhatofficial.github.io/RedHatFont/](https://redhatofficial.github.io/RedHatFont/).

Variable fonts are available for each of the Red Hat Typeface families. The fonts include the `wght` axis, which allows for interpolation between light and black weights.

There are two versions of the variable fonts: with and without VF in the name. It is Red Hat's preference to name these differently than the OTF / TTF fonts, but Google requires the names to be the same. We recommend using ***either*** the VF or standard named variable fonts, but not both.

## Building the Fonts

From terminal, run the build script at `sources/build-all.sh`. Fonts output to `fonts/`.

NOTE: The first time you build, you will need to set up a virtual environment and install dependencies:

<details>
<summary><b><!-------->Setting up the build environment<!--------></b> (Click to expand)</summary>

### Set up the environment

**The basics**

You will need to open a terminal to run the following commands.

Clone the repo & navigate into it:

```
git clone https://github.com/RedHatOfficial/RedHatFont.git
cd RedHatFont
```

Check that you have Python 3:

```
which python3
```

It should return a path ending with `python3`, such as `/Library/Frameworks/Python.framework/Versions/3.7/bin/python3`. If it returns an error like `python3 not found`, you will need to [download Python 3](https://www.python.org/downloads/).

**Setting up a virtual environment**

To build, set up the virtual environment:

```bash
cd ~
python3 -m venv venv
```

Then activate it:

```bash
source venv/bin/activate
```

Now, install requirements:

```bash
cd RedHatFont
pip install -U -r requirements.txt
```


**Making woff2 files**

Finally, you will also need to separately install [google/woff2](https://github.com/google/woff2) to enable the `woff2_compress` and `woff2_decompress` commands. Open a new terminal session, window, or tab to do this step.

```bash
# open a new terminal session first, then run
git clone --recursive https://github.com/google/woff2.git
cd woff2
make clean all
```

To make sure woff2_compress is installed properly, enter the following inyour terminal window:

```
woff2_compress
```

If terminal cannot find the command, you may need to ensure binaries are in $PATH, [a description of which you can find here.](https://github.com/google/woff2/issues/131)

Once woff2_compress is working in your terminal, you can now run the build!

</details>

### Build fonts

Once you have set up the environment (see above), you can build fonts & prep releases!

1.030 uses GFTOOLS builder to build the fonts. It should be as simple as running

```bash
gftools builder source/Mono/config.yaml
```
```bash
gftools builder source/Proportional/RedHatDisplay/config.yaml
```
```bash
gftools builder source/Proportional/RedHatText/config.yaml
```


## Installation

The OTF or TTF folders contain the font files used by most user operating systems.

If you are running Fedora, Red Hat Enterprise Linux 7, CentOS 7, or any similar derivatives, you can install the fonts with the following:
```
sudo yum install redhat-display-fonts redhat-text-fonts
```
Note that Red Hat Enterprise Linux/CentOS users will need to [enable Fedora EPEL first](https://fedoraproject.org/wiki/EPEL).


If you are running Homebrew, you can install the fonts with the following:

```text
brew cask install homebrew/cask-fonts/font-redhat
```

## Bug reports and improvement requests

If you find a problem with a font file or have a request for future development of a font project, please [create a new issue in this project's issue tracker](https://github.com/RedHatOfficial/RedHatFont/issues).

## Self-Host Fonts Available From Red Hat

Since all the fonts available here are licensed with permission to redistribute, subject to the license terms, you are able to self-host the fonts in this project.

## Licensing

Copyright 2021 Red Hat, Inc.

Licensed under the SIL Open Font License, Version 1.1, with Reserved Font Name Red Hat.

The SIL OFL does not grant any rights under trademark law and all such rights are reserved. Modified versions must be renamed to avoid use of any Red Hat trademarks, including but not limited to "Red Hat".
