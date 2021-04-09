from fontTools.otlLib.builder import buildStatTable, _addName
from fontTools.ttLib import TTFont
import sys


AXES = [
    dict(
        tag="wght",
        name="Weight",
        ordering=0,
        values=[
            dict(nominalValue=300, rangeMinValue=200, rangeMaxValue=350, name="Light"),
            dict(nominalValue=400, rangeMinValue=350, rangeMaxValue=400, name="Regular", flags=0x2, linkedValue=700),
            dict(nominalValue=500, rangeMinValue=450, rangeMaxValue=650, name="Medium"),
            dict(nominalValue=700, rangeMinValue=650, rangeMaxValue=850, name="Bold"),
            dict(nominalValue=900, rangeMinValue=850, rangeMaxValue=950, name="Black"),
            # dict(value=400, name="Regular", flags=0x2, linkedValue=700),  # Regular
        ],
    ),
    dict(
        tag="ital",
        name="Italic",
        ordering=1,
        values=[
            dict(nominalValue=0, name="Roman", flags=0x2, linkedValue=1),
        ],
    ),
]

def update_fvar(ttfont):
    fvar = ttfont['fvar']
    nametable = ttfont['name']
    family_name = nametable.getName(16, 3, 1, 1033) or nametable.getName(1, 3, 1, 1033)
    family_name = family_name.toUnicode().replace(" ", "")
    nametable.setName(family_name, 25, 3, 1, 1033)
    for instance in fvar.instances:
        instance_style = nametable.getName(instance.subfamilyNameID, 3, 1, 1033).toUnicode()
        ps_name = f"{family_name}-{instance_style.replace(' ', '')}"
        instance.postscriptNameID = _addName(nametable, ps_name, 256)


def main():
    filepath = sys.argv[1]
    tt = TTFont(filepath)

    # remove & replace last item in AXES to work for italic font
    if "Italic" in filepath:
        AXES.pop()
        AXES.append(dict(
                tag="ital",
                name="Italic",
                ordering=4,
                values=[
                    dict(nominalValue=1, name="Italic"),
                ],
            ))

    buildStatTable(tt, AXES)
    update_fvar(tt)
    tt.save(filepath)
    print(f"Added STAT table to {filepath}")


if __name__ == "__main__":
    main()
