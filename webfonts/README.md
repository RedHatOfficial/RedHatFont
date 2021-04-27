# Red Hat web font files

## Font file CSS

Original fonts are available via `./font.css`

Modified fonts are available via `./red-hat-font.css`

Minified versions of both of these are available at:

* `./font.min.css`
* `./red-hat-font.min.css`

## Local development

Generate new minified versions of the CSS files by running `npm run minifiy` at the project root.

Spin up a local browser to review the `./index.html` file by running `npm run local` at the project root.

## Why are there two font CSS files?

[RedHat.com](https://www.redhat.com/en) uses a range (but not all) of the font weights available.

Font weight | Used by RedHat.com
-----|--------------------
RedHatDisplay-Black | ✅
RedHatDisplay-Bold | ✅
RedHatDisplay-Medium | ✅
RedHatDisplay-Regular | ✅
RedHatDisplay-Light | 🚫
RedHatText-Bold | 🚫
RedHatText-Medium | ✅
RedHatText-Regular | ✅
RedHatText-Light | 🚫

To support variable fonts, which do not let us map a weight to a specific font, we need to modify the variable font file.

These modified files are located at `./source/Proportional/VF`.
- `Modified-RedHatDisplayItalicVF.designspace`
- `Modified-RedHatDisplayVF.designspace`
- `Modified-RedHatTextItalicVF.designspace`
- `Modified-RedHatTextVF.designspace`

**Mono fonts are not modified.**

See the [Red Hat digital design system](https://ux.redhat.com/foundations/typography/) for more font weight information.

## How do I recompile the modified font files?

First, follow the instructions in the [readme](../README.md) to set up your environment for font building.

Next, run the modified build script with:

```bash
./build-scripts/build-modified-vf.sh
```

That will give you the updated `.ttf` files. Convert them to woff2 files for the web using:

```bash
./build-scripts/make-woff2s.sh
```

Finally move the new `.woff2` files into the webfonts directory using:

```bash
npm run copy-to-webfonts
```

Test the updated `.woff2` files using `npm run local`. The standard variable fonts are visible at [http://localhost:3000](http://localhost:3000) and the modified files are visible at [http://localhost:3000](http://localhost:3000)
