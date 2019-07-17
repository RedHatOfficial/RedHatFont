import sys
import os 
import os.path
import tempfile
import re
from fontTools.ttLib import TTFont
from fontTools import ttLib
from fontTools.ttLib.tables._k_e_r_n import KernTable_format_0


def makeotf(outlineSourcePath, featuresPath=None, glyphOrderPath=None, menuNamePath=None, fontInfoPath=None, releaseMode=True, setOS2Bit6=False):
    """
    Run makeotf.
    The arguments will be converted into arguments
    for makeotf as follows:

    =================  ===
    outlineSourcePath  -f
    featuresPath       -ff
    glyphOrderPath     -gf
    menuNamePath       -mf
    fontInfoPath       -fi
    releaseMode        -r
    =================  ===
    """
    cmds = ["makeotf", "-nshw", "-sp", "-f", outlineSourcePath]
    if featuresPath:
        cmds.extend(["-ff", featuresPath])
    if glyphOrderPath:
        cmds.extend(["-gf", glyphOrderPath])
    if menuNamePath:
        cmds.extend(["-mf", menuNamePath])
    if fontInfoPath:
        cmds.extend(["-fi", fontInfoPath])
    if releaseMode:
        cmds.append("-r")
    if setOS2Bit6:
        cmds.extend(["-osbOn", "6"])
        cmds.extend(["-osbOn", "8"])
    stderr, stdout = _execute(cmds)
    return stderr, stdout

def autohint(fontPath):
    """
    Run autohint.
    The following arguments will be passed to autohint.

    * -nb
    * -a
    * -r
    * -q
    """
    cmds = ["autohint", "-nb", "-a", "-r", "-q", fontPath]
    stderr, stdout = _execute(cmds)
    return stderr, stdout

def lookUpDirTree(fileName):
    """ 
    This is called when we are using a default name for either the FontMenuNamDB or the GlyphOrderAndAliasDB files.
    These are often located one or two dir levels above the font file, as they are shared by the font family.
    """

    maxLevels = 2
    i = 0
    found = 0
    dirPath, fileName = os.path.split(fileName)
    while i <= maxLevels:
        path = os.path.join(dirPath,fileName)
        if os.path.exists(path):
            found = 1
            break
        dirPath = os.path.join(dirPath, "..")
        i += 1
    if not found:
        path = None
    return path

def getNameChanges(path):
    p = os.path.join(path, 'GlyphOrderAndAliasDB')
    goaadb = lookUpDirTree(p)
    if goaadb is not None:
        d = {}
        with open(goaadb) as f:
            for line in f:
               if len(line) > 1:
                   val = line.split()[0]
                   key = line.split()[1]
                   d[key] = val
        return d
    else:
        return {}

def subsetFlatKerning(kerning, path):
    plinc = ['space', 'exclam', 'quotesingle', 'quotedbl', 'numbersign', 'dollar', 'percent', 'ampersand', 'parenleft', 'parenright', 'asterisk', 'plus', 'comma', 'hyphen', 'period', 'slash', 'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'colon', 'semicolon', 'less', 'equal', 'greater', 'question', 'at', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'bracketleft', 'backslash', 'bracketright', 'asciicircum', 'underscore', 'grave', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'braceleft', 'bar', 'braceright', 'asciitilde', 'exclamdown', 'cent', 'sterling', 'currency', 'yen', 'brokenbar', 'section', 'dieresis', 'copyright', 'ordfeminine', 'guillemotleft', 'logicalnot', 'registered', 'macron', 'degree', 'plusminus', 'twosuperior', 'threesuperior', 'acute', 'mu', 'paragraph', 'periodcentered', 'cedilla', 'onesuperior', 'ordmasculine', 'guillemotright', 'onequarter', 'onehalf', 'threequarters', 'questiondown', 'Agrave', 'Aacute', 'Acircumflex', 'Atilde', 'Adieresis', 'Aring', 'AE', 'Ccedilla', 'Egrave', 'Eacute', 'Ecircumflex', 'Edieresis', 'Igrave', 'Iacute', 'Icircumflex', 'Idieresis', 'Eth', 'Ntilde', 'Ograve', 'Oacute', 'Ocircumflex', 'Otilde', 'Odieresis', 'multiply', 'Oslash', 'Ugrave', 'Uacute', 'Ucircumflex', 'Udieresis', 'Yacute', 'Thorn', 'germandbls', 'agrave', 'aacute', 'acircumflex', 'atilde', 'adieresis', 'aring', 'ae', 'ccedilla', 'egrave', 'eacute', 'ecircumflex', 'edieresis', 'igrave', 'iacute', 'icircumflex', 'idieresis', 'eth', 'ntilde', 'ograve', 'oacute', 'ocircumflex', 'otilde', 'odieresis', 'divide', 'oslash', 'ugrave', 'uacute', 'ucircumflex', 'udieresis', 'yacute', 'thorn', 'ydieresis', 'dotlessi', 'circumflex', 'caron', 'breve', 'dotaccent', 'ring', 'ogonek', 'tilde', 'hungarumlaut', 'quoteleft', 'quoteright', 'minus']
    
    nameChanges = getNameChanges(path)
    
    new_plinc = []
    for x in plinc:
        if x in nameChanges.keys():
            new_plinc.append(nameChanges[x])
        else:
            new_plinc.append(x)
    new_kerning = {}
    
    for key, value in kerning.items():
        old = len(value)
        new_values = {}
        for p, v in value.items():
            if p[0] in new_plinc and p[1] in new_plinc:
                new_values[p] = v
        print 'Subset kerning'
        print 'Old pairs were: ' + str(old) +'. New pairs are: ' + str(len(new_values))
        new_kerning[key] = new_values
    return new_kerning


def versionClean(font):
    from fontTools.ttLib.tables._n_a_m_e import NameRecord, table__n_a_m_e
    
    nameIDs = [(5, 1, 0, 0), (5, 3, 1, 1033)]
    nameTable = font["name"]
    
    for n in nameIDs:
        nameRecord = nameTable.getName(n[0], n[1], n[2], n[3])
        s = nameRecord.string
        nameTable.names.remove(nameRecord)
        
        parts = s.split(';')
        
        s = ''
        for p in parts:
            if p != 'PS (version unavailable)':
                s = s + p + ';'
        s = s[:-1]
        
        record = NameRecord()
        record.nameID = n[0]
        record.platformID = n[1]
        record.platEncID = n[2]
        record.langID = n[3]
        record.string = s
        nameTable.names.append(record)

def nameTableTweak(font):
    nameIDs = [(16, 1, 0, 0), (17, 1, 0, 0)]
    nameTable = font["name"]
    
    for n in nameIDs:
        nameRecord = nameTable.getName(n[0], n[1], n[2], n[3])
        if nameRecord is not None:
            nameTable.names.remove(nameRecord)

def makeDSIG(font):
    from fontTools.ttLib.tables.D_S_I_G_ import SignatureRecord
    newDSIG = ttLib.newTable("DSIG")
    newDSIG.ulVersion = 1
    newDSIG.usFlag = 1
    newDSIG.usNumSigs = 1
    sig = SignatureRecord()
    sig.ulLength = 20
    sig.cbSignature = 12
    sig.usReserved2 = 0
    sig.usReserved1 = 0
    sig.pkcs7 = '\xd3M4\xd3M5\xd3M4\xd3M4'
    sig.ulFormat = 1
    sig.ulOffset = 20
    newDSIG.signatureRecords = [sig]
    font.tables["DSIG"] = newDSIG        

def _flat_kern_count(glyph, keys):
    count = 0
    for x in keys:
        if x[0] == glyph:
            count += 1
    return count

def processFont(path, d, flatKernData):
    font = TTFont(path)
    oldD, f = os.path.split(path)
    new = os.path.join(d, f)
    
    name = font['name'].getName(6, 1, 0, 0).string
    
    # Make a flat kerning table
    if flatKernData is not None:
        newKern = ttLib.newTable("kern")
        newKern.version = 0
        newKern.kernTables = [KernTable_format_0()]
    
    
        flat = flatKernData[name]
        sortedKeys = flat.keys()
        sortedKeys.sort()
    
    
        left = ''
        i = 0
        for key in sortedKeys:
            if left == '':
                left = key[0]
                kern_table = {key:flat[key]}
                count = _flat_kern_count(left, sortedKeys)
                i += 1
            elif i+1 < len(sortedKeys) and left != sortedKeys[i+1][0]:
                if count + _flat_kern_count(sortedKeys[i+1][0], sortedKeys) > 10920:
                    kern_table[key] = flat[key]
                
                    t = len(newKern.kernTables) - 1
                
                    table = newKern.kernTables[t]
                    table.kernTable = kern_table
                    table.version = 0
                    table.coverage = 1
                    table.apple = False
                    newKern.kernTables.append(KernTable_format_0())
                    left = ''
                else:                    
                    kern_table[key] = flat[key]
                    left = sortedKeys[i+1][0]
                    count = _flat_kern_count(sortedKeys[i+1][0], sortedKeys) + count
                i += 1
            elif len(sortedKeys) == i + 1:
                kern_table[key] = flat[key]
                t = len(newKern.kernTables) - 1
                table = newKern.kernTables[t]
                table.kernTable = kern_table
                table.version = 0
                table.coverage = 1
                table.apple = False
                i += 1
            else:
                kern_table[key] = flat[key]
                i += 1

        # Add this table back to the font
        font.tables["kern"] = newKern
    
    # Fix the ugly id string
    versionClean(font)
    nameTableTweak(font)
    makeDSIG(font)
    

    font.save(new)


def getFiles(path, extension):
    if not extension.startswith('.'):
        extension = '.' + extension
    if extension == '.ufo':
        return [dir for (dir, dirs, files) in os.walk(path) if dir[-len(extension):] == extension]
    else:
        return [os.sep.join((dir, file)) for (dir, dirs, files) in os.walk(path) for file in files if file[-len(extension):] == extension]

# --------------
# Internal Tools
# --------------

if sys.platform == "darwin":
    _fdkToolDirectory = os.path.join(os.environ["HOME"], "bin/FDK/Tools/osx")
else:
    _fdkToolDirectory = None

def _makeEnviron():
    env = dict(os.environ)
    if _fdkToolDirectory not in env["PATH"].split(":"):
        env["PATH"] += (":%s" % _fdkToolDirectory)
    kill = ["ARGVZERO", "EXECUTABLEPATH", "PYTHONHOME", "PYTHONPATH", "RESOURCEPATH"]
    for key in kill:
        if key in env:
            del env[key]
    return env

def _execute(cmds):
    import subprocess
    # for some reason, autohint and/or checkoutlines
    # locks up when subprocess.PIPE is given. subprocess
    # requires a real file so StringIO is not acceptable
    # here. thus, make a temporary file.
    stderrPath = tempfile.mkstemp()[1]
    stdoutPath = tempfile.mkstemp()[1]
    stderrFile = open(stderrPath, "w")
    stdoutFile = open(stdoutPath, "w")
    # get the os.environ
    env = _makeEnviron()
    # make a string of escaped commands
    cmds = subprocess.list2cmdline(cmds)
    # go
    popen = subprocess.Popen(cmds, stderr=stderrFile, stdout=stdoutFile, env=env, shell=True)
    popen.wait()
    # get the output
    stderrFile.close()
    stdoutFile.close()
    stderrFile = open(stderrPath, "r")
    stdoutFile = open(stdoutPath, "r")
    stderr = stderrFile.read()
    stdout = stdoutFile.read()
    stderrFile.close()
    stdoutFile.close()
    # trash the temp files
    os.remove(stderrPath)
    os.remove(stdoutPath)
    # done
    return stderr, stdout


    
def main():
    # make output dir
    d = os.getcwd() + '/fonts'
    try:
        os.makedirs(d)
    except OSError:
        if not os.path.isdir(d):
            raise
    
    # make sure output dir contains no otfs
    files = getFiles(d, 'otf')
    if len(files) != 0:
        for file in files:
            os.remove(file)
    
    print "Make Initial OTFs"
    print '-----------------------'
    
    # Make initial OTFs
    print os.getcwd()
    files = getFiles(os.getcwd(), 'ufo')
    print files
    result = ""
    for file in files:
        print file
        six = False
        font_style = file.split("-")[-1][:-4]
        if font_style not in ["Regular", "Italic", "Bold", "BoldItalic"]:
            if "Italic" not in font_style:
                six = True
        if six:
            stderr, stdout = makeotf(file, setOS2Bit6=True)
        else:
            stderr, stdout = makeotf(file)
        result += '------------------\nOutput for: ' + file + '\n\n'+ stderr + stdout
    path = os.path.join(os.getcwd(), 'makeOTF_report.txt')
    print path
    file = open(path, 'w')
    file.write(result)
    file.close()
    
    # TTX Magic
    print "TTX Magic Time"
    print '-----------------------'
    files = getFiles(os.getcwd(), 'otf')
    for file in files:
        print file
        try:
            current_directory = os.path.dirname(file)
            kerning_file = os.path.join(current_directory, 'flatKerning.py')
            with open(kerning_file,'r') as inf:
                flat_kerning = eval(inf.read())
            print 'Got flat kerning'
        except:
            flat_kerning = None
            print 'No flat kerning found'
        subset = os.path.join(current_directory, 'subset')
        if os.path.exists(subset):
            flat_kerning = subsetFlatKerning(flat_kerning, current_directory)
            
        processFont(file, d, flat_kerning)
    
    # Remove otfs used in the TTX operation
    for f in files:
        os.remove(f)
    
    
    # Autohint the ttxed otfs
    print "Autohint time"
    print '-----------------------'
    files = getFiles(d, 'otf')
    result = ""
    for file in files:
        print file
        stderr, stdout = autohint(file)
        result += '------------------\nOutput for: ' + file + '\n\n'+ stderr + stdout
    path = os.path.join(os.getcwd(), 'autohint_report.txt')
    print path
    file = open(path, 'w')
    file.write(result)
    file.close()    
    
if __name__ == "__main__":
    main()
