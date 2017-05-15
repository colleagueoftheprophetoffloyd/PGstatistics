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

# Credentials and config
CREDENTIALFILE=$HOME/.ssl/meb-emulab-special-cred.txt
CERTFILE=$HOME/.ssl/utah-emulab-cleartext.pem

# MySQL
HISTORYDB=protogeniHistory

# Directories
BASE=$HOME/statistics
SCRIPTSDIR=$BASE/protogeni-test-scripts
HISTORYDIR=$BASE/ProtoGENIHistory
NOTINGESTEDBLOCKSDIR=$HISTORYDIR/notIngested/blocks
INGESTEDBLOCKSDIR=$HISTORYDIR/ingested/blocks
ANALYSISDIR=$BASE/ProtoGENIHistoryAnalysis

# Programs
FETCH=$SCRIPTSDIR/fetchHistoryRecords.py
INGEST=$ANALYSISDIR/ingestPGHistory.py
UPDATEALLSTATS=$ANALYSISDIR/updateAllStatistics.sql

# File for tracking records read
NEXTRECORDFILE=$SCRIPTSDIR/NEXT_RECORD_NUMBER
