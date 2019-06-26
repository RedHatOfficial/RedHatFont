# -*- coding: UTF-8 -*-
import sys
import os 
import os.path
import tempfile
import re
from fontTools.ttLib import TTFont
from fontTools import ttLib
from fontTools.ttLib.tables._k_e_r_n import KernTable_format_0
from fontTools.ttLib.tables.D_S_I_G_ import SignatureRecord


def _convert_line_endings(temp, mode):
    """ Converts line endings to the proper mode:
        Modes:  0 - Unix
                1 - Mac
                2 - DOS
    """
    if mode == 0:
            temp = string.replace(temp, '\r\n', '\n')
            temp = string.replace(temp, '\r', '\n')
    elif mode == 1:
            temp = string.replace(temp, '\r\n', '\r')
            temp = string.replace(temp, '\n', '\r')
    elif mode == 2:
            import re
            temp = re.sub("\r(?!\n)|(?<!\r)\n", "\r\n", temp)
    return temp

def ttfautohint(fontPath, d):
    """
    Run ttfautohint.
    The following arguments will be passed to autohint.

    * -c
    * -n
    * -W
    """
    d2, f = os.path.split(fontPath)
    np = os.path.join(d, f)
    print fontPath
    print np
    cmds = ["/usr/local/bin/ttfautohint", "-c", "-n", "-W", fontPath, np]
    stderr, stdout = _execute(cmds)
    print stderr
    print stdout
    return stderr, stdout


def versionClean(font):
    from fontTools.ttLib.tables._n_a_m_e import NameRecord, table__n_a_m_e
    
    nameIDs = [(5, 1, 0, 0), (5, 3, 1, 1033)]
    nameTable = font["name"]
    
    for n in nameIDs:
        nameRecord = nameTable.getName(n[0], 1, 0, 0)
        s = nameRecord.string
        nameTable.names.remove(nameTable.getName(n[0], n[1], n[2], n[3]))
        
        parts = s.split(';')
        if nameTable.getName(4, 1, 0, 0) is not None:
            f = parts[0] + '; ' + nameTable.getName(4, 1, 0, 0).string
        if n[1] == 3:
            f = _convert_line_endings(f, 2)
            f = f.encode("utf_16_be")      
        record = NameRecord()
        record.nameID = n[0]
        record.platformID = n[1]
        record.platEncID = n[2]
        record.langID = n[3]
        record.string = f
        nameTable.names.append(record)

def nameTableTweak(font):
    from fontTools.ttLib.tables._n_a_m_e import NameRecord, table__n_a_m_e
    nameIDs = [(16, 1, 0, 0), (17, 1, 0, 0)]
    nameTable = font["name"]
    
    for n in nameIDs:
        nameRecord = nameTable.getName(n[0], n[1], n[2], n[3])
        if nameRecord is not None:
            nameTable.names.remove(nameRecord)
            
    nameIDs = [(4, 1, 0, 0), (4, 3, 1, 1033)]
    nameTable = font["name"]
    
    nameRecord = nameTable.getName(4, 1, 0, 0)
    if nameRecord is not None:
        if "Italic" in nameRecord.string:
            for n in nameIDs:
                nameRecord = nameTable.getName(n[0], n[1], n[2], n[3])
                if nameRecord is not None:
                    s = nameRecord.string
                    nameTable.names.remove(nameRecord)
                    record = NameRecord()
                    record.nameID = n[0]
                    record.platformID = n[1]
                    record.platEncID = n[2]
                    record.langID = n[3]
                    if n[1] == 3:
                        record.string = s[:-8]
                    else:
                        record.string = s[:-4]
                    nameTable.names.append(record)
                    
                    
                
def processFont(path, d):
    
    font = TTFont(path)
    oldD, f = os.path.split(path)
    new = os.path.join(d, f)
        
    # Fix the ugly id string
    versionClean(font)

    # Remove Mac ID 16 and 17
    nameTableTweak(font)

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
    d = os.getcwd() + '/processed_fonts'
    try:
        os.makedirs(d)
    except OSError:
        if not os.path.isdir(d):
            raise
    
    # make sure output dir contains no otfs
    files = getFiles(d, 'ttf')
    if len(files) != 0:
        for file in files:
            os.remove(file)
    
    
    # TTX Magic
    print "TTX Magic Time"
    print '-----------------------'
    files = getFiles(os.getcwd(), 'ttf')
    temp = tempfile.mkdtemp()
    for file in files:
        print file
        processFont(file, temp)
            
    # TTFautohint
    print "TTF Autohint Magic Time"
    print '-----------------------'
    files = getFiles(temp, 'ttf')
    for file in files:
        print "Hinting " + file
        ttfautohint(file, d)
    
    for f in files:
        os.remove(f)
    os.rmdir(temp)
    
if __name__ == "__main__":
    main()
