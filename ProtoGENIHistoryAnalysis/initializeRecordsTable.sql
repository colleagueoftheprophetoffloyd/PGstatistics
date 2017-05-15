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
DROP TABLE IF EXISTS historyRecords;

CREATE TABLE `historyRecords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pg_index` int(11) NOT NULL,
  `destroyed` datetime DEFAULT NULL,
  `creator_uuid` varchar(200) NOT NULL DEFAULT '',
  `creator_urn` varchar(200) NOT NULL DEFAULT '',
  `uuid` varchar(200) NOT NULL DEFAULT '',
  `created` datetime NOT NULL,
  `urn` varchar(200) NOT NULL DEFAULT '',
  `slice_urn` varchar(200) NOT NULL DEFAULT '',
  `slice_uuid` varchar(200) NOT NULL DEFAULT '',
  `manifest` mediumtext NOT NULL,
  `derived_site_name` varchar(200) DEFAULT NULL,
  `derived_test_slice` tinyint(1) DEFAULT NULL,
  `derived_test_site` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

