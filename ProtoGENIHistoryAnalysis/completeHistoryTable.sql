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
UPDATE historyRecords
SET derived_site_name =
        SUBSTRING(urn,
		  LOCATE('+', urn) + 1,
		  LOCATE('+', substring(urn, LOCATE('+', urn) + 1 )) - 1),
    derived_quarter =
	(SELECT id from quarters WHERE startDate < created ORDER BY id DESC LIMIT 1),
    derived_epoch =
	(SELECT id from gecEpochs WHERE startDate < created ORDER BY id DESC LIMIT 1);
	
INSERT INTO debugTiming (event, eventTime) VALUES ('Done completing history records.', now());

# MEB: Commenting this out - catching more legit slivers than bad ones.
#UPDATE historyRecords
#SET derived_test_slice =
#	(slice_urn LIKE '%+%+slice+acc%') or
#	(slice_urn LIKE '%.acc%') or
#	(slice_urn LIKE '%+%+slice+non%') or
#	(slice_urn LIKE '%.non%') or
#	(slice_urn LIKE '%+%+slice+bad%') or
#	(slice_urn LIKE '%.bad%') or
#	(slice_urn LIKE '%+%+slice+down%') or
#	(slice_urn LIKE '%.down%');
#
#UPDATE historyRecords
#SET derived_test_site =
#derived_site_name in ('pgeni1.gpolab.bbn.com', 
#					  'pgeni3.gpolab.bbn.com', 
#					  'jonlab.tbres.emulab.net');
