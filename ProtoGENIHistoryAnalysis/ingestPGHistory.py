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
#

import MySQLdb
import time
import sys

dbHost = 'localhost'
dbName = 'protogeniHistory'

tableName = 'historyRecords'
recordNames = ['index', 'destroyed', 'creator_uuid', 'creator_urn',
               'uuid', 'created', 'urn', 'slice_urn', 'slice_uuid', 'manifest']
columnNames = ['`pg_index`', '`destroyed`', '`creator_uuid`', '`creator_urn`',
               '`uuid`', '`created`', '`urn`', '`slice_urn`', '`slice_uuid`', '`manifest`']
valueFormat = '(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)'
insertFormat = "insert into `%s` (%s) values %s;"
timeFormat='%Y-%m-%d %H:%M:%S'

def formatEntry(record):
    '''Format one data record for insertion into database.

    Return a tuple for inclusion in a SQL insert values clause.'''

    values = []
    # Now loop over all columns.
    for name in recordNames:
	if (not name in record) or (record[name] == ''):
	    values.append('NULL')
	else:
	    values.append(str(record[name]))
    return tuple(values)

def insertValues(db, records):
    '''Write new values to DB.'''
    if len(records) > 0:
        cursor = db.cursor()
        valueParts = []
        for record in records:
            valueParts.append(formatEntry(record))
        sql = insertFormat % (tableName, ','.join(columnNames), valueFormat)
	#print valueParts
        cursor.executemany(sql, valueParts)
        cursor.close()
        db.commit()

def insertValuesSlowly(db, records):
    '''Write new values to DB.'''
    for record in records:
        valuesList = []
        for i in range(len(columnNames)):
            valuesList.append(str(record[recordNames[i]]))
        sql = insertFormat % (tableName, ','.join(columnNames), tuple(valuesList))
        print sql
        cursor = db.cursor()
        cursor.execute(sql)
        cursor.close()
        db.commit()
       
def main(argv=None):
    # Initialize from arguments.
    if argv is None:
        argv = sys.argv[1:]
    inputFilename = argv[0]

    # Read records from input file
    infile = open(inputFilename, 'r')
    text = infile.read()
    infile.close()
    records = eval(text.strip())

    # Summarize and quit
    print 'Got', len(records), 'records.'

    # Open DB connection
    db = MySQLdb.connect(host=dbHost,
                         db=dbName,
			 read_default_file="~/.my.cnf")

    # Update database.
    insertValues(db, records)
    #insertValuesSlowly(db, records)
    db.close()

if __name__ == '__main__':
    main()
