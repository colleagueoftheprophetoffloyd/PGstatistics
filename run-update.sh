#!/bin/sh
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

# Get common variables.
. ./vars.sh

# Write start time.
echo -n "Starting statistics update at "
date

# Make sure output directories exist.
mkdir -p $NOTINGESTEDBLOCKSDIR
mkdir -p $INGESTEDBLOCKSDIR

# Read new history records from server.
# Store them in 100 record blocks in notIngested/blocks.
# Discard any partial blocks - we'll get them next time.
echo "Reading new records from server."
cd $SCRIPTSDIR
NEXTRECORD=`cat $NEXTRECORDFILE`
$FETCH --credentials $CREDENTIALFILE --certificate $CERTFILE $NEXTRECORD 5000000 100 $NOTINGESTEDBLOCKSDIR

# Check for records to ingest.
if stat -t $NOTINGESTEDBLOCKSDIR/* >/dev/null 2>&1
then
    # Loop over blocks and insert records into database.
    echo "Storing new records into database."
    for f in $NOTINGESTEDBLOCKSDIR/*; do $INGEST $f && mv $f $INGESTEDBLOCKSDIR && echo $f; sleep 2; done

    # Update statistics database tables.
    echo -n "Updating database statistics (takes a while) "
    date
    cd $ANALYSISDIR
    mysql -h localhost --database=$HISTORYDB < $UPDATEALLSTATS

else
    echo "No new records - skipping database update."
fi

# Write end time.
echo -n "Finished statistics update at "
date
