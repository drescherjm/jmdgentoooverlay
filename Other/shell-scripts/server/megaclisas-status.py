#!/usr/bin/python2

import os
import re
import sys

binarypath = "/opt/bin/megacli"

# Adding a quick check to see if we're root, because on most cards I've tried this on
# We need root access to query
if __name__ == '__main__':
    if os.getenv('USER') != 'root':
        print 'You can only run this script as root or with sudo, sucks I know. Blame the RAID card'
        sys.exit(5)

if len(sys.argv) > 2:
    print 'Usage: megaclisas-status [--nagios]'
    sys.exit(1)

nagiosmode = False
nagiosoutput = ''
nagiosgoodarray = 0
nagiosbadarray = 0
nagiosgooddisk = 0
nagiosbaddisk = 0

# Check command line arguments to enable nagios or not
if len(sys.argv) > 1:
    if sys.argv[1] == '--nagios':
        nagiosmode = True
    else:
        print 'Usage: megaclisas-status [--nagios]'
        sys.exit(1)

# Check binary exists (and +x), if not print an error message
# or return UNKNOWN nagios error code
if os.path.exists(binarypath) and os.access(binarypath, os.X_OK):
    pass
else:
    if nagiosmode:
        print 'UNKNOWN - Cannot find ' + binarypath
    else:
        print 'Cannot find ' + binarypath + '. Please install it.'
    sys.exit(3)


# Get command output
def getOutput(cmd):
    output = os.popen(cmd)
    lines = []
    for line in output:
        line = line.strip()
        if not re.match(r'^$', line):
            lines.append(line)
    return lines


def returnControllerNumber(output):
    for line in output:
        line = line.strip()
        if re.match(r'^Controller Count.*$', line):
            return int(line.split(':')[1].strip().strip('.'))


def returnControllerModel(output):
    for line in output:
        if re.match(r'^Product Name.*$', line.strip()):
            return line.split(':')[1].strip()
			
def returnControllerFirmware(output):
    for line in output:
        if re.match(r'^FW Package Build.*$', line.strip()):
            return line.split(':')[1].strip()


def returnArrayNumber(output):
    i = 0
    for line in output:
        if re.match(r'^Number of Virtual (Disk|Drive).*$', line.strip()):
            i = line.split(':')[1].strip()
    return i

def returnNextArrayNumber(output,curNumber):
    #Virtual Drive: 2 (Target Id: 2)
    for line in output:
	vdisk = re.match(r'^Virtual Drive: \d+ \(Target Id: (\d+)\)$', line.strip())
        if vdisk and int(vdisk.group(1)) > curNumber:
	    return int(vdisk.group(1))
    return -1

def returnArrayInfo(output, controllerid, arrayid):
    _id = 'c%du%d' % (controllerid, arrayid)
    operationlinennumber = False
    linenumber = 0
    ldpdcount = 0
    spandepth = 0

    for line in output:
        line = line.strip()
        if re.match(r'Number Of Drives\s*((per span))?:.*[0-9]+$', line):
            ldpdcount = line.split(':')[1].strip()
        if re.match(r'Span Depth *:.*[0-9]+$', line):
            spandepth = line.split(':')[1].strip()
        if re.match(r'^RAID Level\s*:.*$', line):
            raidlevel = line.split(':')[1].split(',')[0].split('-')[1].strip()
            raid_type = 'RAID' + raidlevel
        if re.match(r'^Size\s*:.*$', line):
            # Size reported in MB
            if re.match(r'^.*MB$', line.split(':')[1]):
                size = line.split(':')[1].strip('MB').strip()
                size = str(int(round((float(size) / 1000)))) + 'G'
            # Size reported in TB
            elif re.match(r'^.*TB$', line.split(':')[1]):
                size = line.split(':')[1].strip('TB').strip()
                size = str(int(round((float(size) * 1000)))) + 'G'
            # Size reported in GB (default)
            else:
                size = line.split(':')[1].strip('GB').strip()
                size = str(int(round((float(size))))) + 'G'
        if re.match(r'^State\s*:.*$', line):
            state = line.split(':')[1].strip()
        if re.match(r'^Ongoing Progresses\s*:.*$', line):
            operationlinennumber = linenumber
        linenumber += 1
        if operationlinennumber:
            inprogress = output[operationlinennumber + 1]
        else:
            inprogress = 'None'

    if ldpdcount and (int(spandepth) > 1):
        ldpdcount = int(ldpdcount) * int(spandepth)
        if int(raidlevel) < 10:
            raid_type = raid_type + "0"

    return [_id, raid_type, size, state, inprogress]


def returnDiskInfo(output, controllerid):
    arrayid = False
    diskid = False
    table = []
    state = 'undef'
    model = 'undef'
    for line in output:
        line = line.strip()
        if re.match(r'^Virtual (Disk|Drive): [0-9]+.*$', line):
            arrayid = line.split('(')[0].split(':')[1].strip()
        if re.match(r'Firmware state: .*$', line):
            state = line.split(':')[1].strip()
        if re.match(r'Inquiry Data: .*$', line):
            model = line.split(':')[1].strip()
            model = re.sub(' +', ' ', model)
        if re.match(r'PD: [0-9]+ Information.*$', line):
            diskid = line.split()[1].strip()

        if arrayid and state != 'undef' and model != 'undef' and diskid:
            table.append([str(arrayid), str(diskid), state, model])
            state = 'undef'
            model = 'undef'

    return table

cmd = binarypath + ' -adpCount -NoLog'
output = getOutput(cmd)
controllernumber = returnControllerNumber(output)

bad = False

# List available controller
if not nagiosmode:
    print '-- Controller informations --'
    print '-- ID | Model | Firmware'
    controllerid = 0
    while controllerid < controllernumber:
        cmd = '%s -AdpAllInfo -a%d -NoLog' % (binarypath, controllerid)
        output = getOutput(cmd)
        controllermodel = returnControllerModel(output)
	firmwareversion = returnControllerFirmware(output)
        print 'c%d | %s | %s' % (controllerid, controllermodel, firmwareversion)
        controllerid += 1
    print ''

controllerid = 0
if not nagiosmode:
    print '-- Arrays informations --'
    print '-- ID | Type | Size | Status | InProgress'

while controllerid < controllernumber:
    cmd = '%s -LdInfo -Lall -a%d -NoLog' % (binarypath, controllerid)
    arrayoutput = getOutput(cmd)
    arrayid = returnNextArrayNumber(arrayoutput,-1)
    cmd = '%s -LdGetNum -a%d -NoLog' % (binarypath, controllerid)
    output = getOutput(cmd)
    arraynumber = int(returnArrayNumber(output))
    while arraynumber > 0:
        cmd = '%s -LDInfo -l%d -a%d -NoLog' % (binarypath,
                                                arrayid, controllerid)
        output = getOutput(cmd)
        arrayinfo = returnArrayInfo(output, controllerid, arrayid)
        if not nagiosmode:
            print ' | '.join(arrayinfo)
        if not arrayinfo[3] == 'Optimal':
            bad = True
            nagiosbadarray += 1
        else:
            nagiosgoodarray += 1
        #arrayid += 1
	arrayid = returnNextArrayNumber(arrayoutput,arrayid)
	arraynumber -= 1
    controllerid += 1
if not nagiosmode:
    print ''

if not nagiosmode:
    print '-- Disks informations'
    print '-- ID | Model | Status'

controllerid = 0
while controllerid < controllernumber:
    arrayid = 0
    cmd = '%s -LDInfo -lall -a%d -NoLog' % (binarypath, controllerid)
    output = getOutput(cmd)
    cmd = '%s -LdPdInfo -a%d -NoLog' % (binarypath, controllerid)
    output = getOutput(cmd)
    arraydisk = returnDiskInfo(output, controllerid)
    for array in arraydisk:
        if not array[2] == 'Online' and not array[2] == 'Online, Spun Up':
            bad = True
            nagiosbaddisk += 1
        else:
            nagiosgooddisk += 1
        if not nagiosmode:
            print 'c%du%sp%s | %s | %s' % (controllerid, array[0],
                    array[1], array[3], array[2])
    controllerid += 1

if nagiosmode:
    status_line = 'Arrays: OK:%d Bad:%d - Disks: OK:%d Bad:%d' % \
                (nagiosgoodarray, nagiosbadarray, nagiosgooddisk, nagiosbaddisk)
    if bad:
        print 'RAID ERROR - ' + status_line
        sys.exit(2)
    else:
        print 'RAID OK - ' + status_line
else:
    if bad:
        print '\nThere is at least one disk/array in a NOT OPTIMAL state.'
        sys.exit(1)
