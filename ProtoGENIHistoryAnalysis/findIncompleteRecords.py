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
dbUser = 'pgHistorian'
dbPassword = 'pgHistorian'
dbName = 'protogeniHistory'

tableName = 'historyRecords'
recordNames = ['index', 'destroyed', 'creator_uuid', 'creator_urn',
               'uuid', 'created', 'urn', 'slice_urn', 'slice_uuid', 'manifest']
columnNames = ['`pg_index`', '`destroyed`', '`creator_uuid`', '`creator_urn`',
               '`uuid`', '`created`', '`urn`', '`slice_urn`', '`slice_uuid`', '`manifest`']
valueFormat = '(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)'
insertFormat = "insert into `%s` (%s) values %s;"
timeFormat='%Y-%m-%d %H:%M:%S'

def findMissing(db):
    '''Find records with missing destroy date.'''
    cursor = db.cursor()
    sql = "SELECT id, pg_index, created, destroyed FROM historyRecords WHERE destroyed < '2000-01-01' or destroyed is null"
    cursor.execute(sql)
    result = cursor.fetchall()
    cursor.close()
    return result

def main(argv=None):
    # Open DB connection
    db = MySQLdb.connect(host=dbHost,
                         db=dbName,
			 read_default_file="~/.my.cnf")

    # Find records of interest.
    missing = findMissing(db)
    for r in missing:
      print r
    db.close()

if __name__ == '__main__':
    main()
