#!/usr/bin/python
#----------------------------------------------------------------------
# Copyright (c) 2017 Raytheon BBN Technologies
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and/or hardware specification (the "Work") to
# deal in the Work without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Work, and to permit persons to whom the Work
# is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Work.
#
# THE WORK IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE WORK OR THE USE OR OTHER DEALINGS
# IN THE WORK.
#----------------------------------------------------------------------

''' Fetch history records from ProtoGENI.

    Store in text files named with the record index numbers.
    Like this: HistoryRecords-000000101-000000200.txt

    Arguments: start stop batchsize dir base
    start: starting index value (default 1)
    stop: ending index value (default none - keep going until last record)
    batchsize: number of records to fetch at a time (default 100)
    dir: directory for saving output files (default 'ProtoGENIHistory')
    base: base name for saved files (default 'HistoryRecords')

    Other options are handled by test-common.py.
    Good chance you'll want to specify --credentials=file.
    That file will need to point to a special delegated credential
    from the ProtoGENIclearinghouse.
'''
import optparse
import sys
import pwd
import getopt
import os
import re
import xmlrpclib
from M2Crypto import X509


usage = '''
%prog start stop batchsize dir base
    start: starting index value (default 1)
    stop: ending index value (default none - keep going until last record)
    batchsize: number of records to fetch at a time (default 100)
    dir: directory for saving output files (default 'ProtoGENIHistory')
    base: base name for saved files (default 'HistoryRecords')

    Other options are handled by test-common.py.
    Good chance you'll want to specify --credentials=file.
    That file will need to point to a special delegated credential
    from the ProtoGENIclearinghouse.
'''

def parseArgs(args):
    if len(args) > 0:
        try:
            firstIndex = int(args[0])
        except ValueError:
            Fatal('failed to parse starting index')
    else:
        firstIndex = 1

    if len(args) > 1:
        try:
            lastIndex = int(args[1])
        except ValueError:
            Fatal('failed to parse ending index')
    else:
        lastIndex = sys.maxint

    if len(args) > 2:
        try:
            batchSize = int(args[2])
        except ValueError:
            Fatal('failed to parse batch size')
    else:
        batchSize = 100

    if len(args) > 3:
        dirName = args[3]
    else:
        dirName = 'ProtoGENIHistory'

    if len(args) > 4:
        fileBase = args[4]
    else:
        fileBase = 'HistoryRecords'

    return firstIndex, lastIndex, batchSize, dirName, fileBase

def fetchRecords(mycredential, firstIndex, lastIndex, batchSize, dirName, fileBase):
    currentIndex = firstIndex
    stopReading = False
    outputFileFormat = fileBase + '-%09d-%09d.txt'

    while (currentIndex <= lastIndex) and (not stopReading):
        lastIndexThisBatch = min(lastIndex, currentIndex + batchSize - 1)
        count = lastIndexThisBatch - currentIndex + 1
        print 'Reading', count, 'record(s) starting at index', currentIndex

        # Read records from clearinghouse
        params = {}
        params["credential"] = mycredential
        params["index"]      = currentIndex
        params["count"]      = count
        rval,response = do_method("ch", "ReadHistoryRecords", params,
                                  URI="https://www.emulab.net/protogeni/xmlrpc")
        if rval:
            stopReading = True
        else:
            recordsReceived = len(response['value'])
            if recordsReceived > 0:
                lastIndexRead = currentIndex + recordsReceived - 1
                outputFileName = outputFileFormat % (currentIndex, lastIndexRead)
                if recordsReceived < count:
                    outputFileName += '-partial'
                fullOutputFileName = os.path.join(dirName, outputFileName)
                
                if recordsReceived == count:
                    print 'Writing', recordsReceived, 'records to', fullOutputFileName, '.'
                    outFile = open(fullOutputFileName, 'w')
                    outFile.write(str(response['value']))
                    outFile.close()
                    currentIndex = lastIndexRead + 1
                else:
                    print 'Not writing partial block of', recordsReceived, 'record(s).'
                    stopReading = True

    # Write starting number of next block of records.
    outFile = open('NEXT_RECORD_NUMBER', 'w')
    outFile.write(str(currentIndex))
    outFile.close()


def main():
    # Get my credential
    execfile("test-common.py", globals())
    mycredential = get_self_credential()

    # Parse arguments
    (firstIndex, lastIndex, batchSize, dirName, fileBase) = parseArgs(args)

    # Fetch records
    fetchRecords(mycredential, firstIndex, lastIndex, batchSize, dirName, fileBase)

if __name__ == '__main__':
    main()
