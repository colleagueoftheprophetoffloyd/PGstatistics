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
# A table for timing statistics. Mostly useful for debugging.
CREATE TABLE IF NOT EXISTS `debugTiming` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `event` text,
  `eventTime` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

# Clear out old timing data (keep 8 days so we have info from last weekly run).
DELETE FROM debugTiming
WHERE eventTime < DATE_ADD(CURRENT_DATE, INTERVAL - 8 DAY);

# And insert an entry for now.
INSERT INTO debugTiming (event, eventTime) VALUES ('Cleaned debugTiming table.', now());


# All the sites where anyone has ever created a sliver, plus a catch-all.
DROP TABLE IF EXISTS siteNames;
CREATE TABLE `siteNames` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `siteName` varchar(200) DEFAULT NULL,
   PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT INTO siteNames(siteName)
SELECT DISTINCT derived_site_name
FROM historyRecords
WHERE
	(NOT derived_test_slice) and
	(NOT derived_test_site);

INSERT INTO siteNames(siteName)
VALUES ('AllSites');

INSERT INTO debugTiming (event, eventTime) VALUES ('Initialized siteNames table.', now());


# For slicing time by quarters.
DROP TABLE IF EXISTS quarters;

CREATE TABLE `quarters` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `quarterName` varchar(6) DEFAULT NULL,
  `startDate` date DEFAULT NULL,
  `endDate` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT
INTO quarters (`quarterName`, `startDate`, `endDate`)
VALUES
	('2009Q1', '2009-01-01', '2009-03-31'),
	('2009Q2', '2009-04-01', '2009-06-30'),
	('2009Q3', '2009-07-01', '2009-09-30'),
	('2009Q4', '2009-10-01', '2009-12-31'),
	('2010Q1', '2010-01-01', '2010-03-31'),
	('2010Q2', '2010-04-01', '2010-06-30'),
	('2010Q3', '2010-07-01', '2010-09-30'),
	('2010Q4', '2010-10-01', '2010-12-31'),
	('2011Q1', '2011-01-01', '2011-03-31'),
	('2011Q2', '2011-04-01', '2011-06-30'),
	('2011Q3', '2011-07-01', '2011-09-30'),
	('2011Q4', '2011-10-01', '2011-12-31'),
	('2012Q1', '2012-01-01', '2012-03-31'),
	('2012Q2', '2012-04-01', '2012-06-30'),
	('2012Q3', '2012-07-01', '2012-09-30'),
	('2012Q4', '2012-10-01', '2012-12-31'),
	('2013Q1', '2013-01-01', '2013-03-31'),
	('2013Q2', '2013-04-01', '2013-06-30'),
	('2013Q3', '2013-07-01', '2013-09-30'),
	('2013Q4', '2013-10-01', '2013-12-31'),
	('2014Q1', '2014-01-01', '2014-03-31'),
	('2014Q2', '2014-04-01', '2014-06-30'),
	('2014Q3', '2014-07-01', '2014-09-30'),
	('2014Q4', '2014-10-01', '2014-12-31'),
	('2015Q1', '2015-01-01', '2015-03-31'),
	('2015Q2', '2015-04-01', '2015-06-30'),
	('2015Q3', '2015-07-01', '2015-09-30'),
	('2015Q4', '2015-10-01', '2015-12-31'),
	('2016Q1', '2016-01-01', '2016-03-31'),
	('2016Q2', '2016-04-01', '2016-06-30'),
	('2016Q3', '2016-07-01', '2016-09-30'),
	('2016Q4', '2016-10-01', '2016-12-31'),
	('2017Q1', '2017-01-01', '2017-03-31'),
	('2017Q2', '2017-04-01', '2017-06-30'),
	('2017Q3', '2017-07-01', '2017-09-30'),
	('2017Q4', '2017-10-01', '2017-12-31')
;

INSERT INTO debugTiming (event, eventTime) VALUES ('Initialized quarters table.', now());

# For slicing time by GECs.
DROP TABLE IF EXISTS gecEpochs;

CREATE TABLE `gecEpochs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `epoch` varchar(6) DEFAULT NULL,
  `startDate` date DEFAULT NULL,
  `endDate` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT
INTO gecEpochs (`epoch`, `startDate`, `endDate`)
VALUES
	('GEC01', '2000-01-01', '2007-10-11'),
	('GEC02', '2007-10-12', '2008-03-04'),
	('GEC03', '2008-03-05', '2008-10-31'),
	('GEC04', '2008-11-01', '2009-04-02'),
	('GEC05', '2009-04-03', '2009-07-22'),
	('GEC06', '2009-07-23', '2009-11-18'),
	('GEC07', '2009-11-19', '2010-03-18'),
	('GEC08', '2010-03-19', '2010-07-22'),
	('GEC09', '2010-07-23', '2010-11-04'),
	('GEC10', '2010-11-05', '2011-03-17'),
	('GEC11', '2011-03-18', '2011-07-28'),
	('GEC12', '2011-07-29', '2011-11-04'),
	('GEC13', '2011-11-05', '2012-03-15'),
	('GEC14', '2012-03-16', '2012-07-11'),
	('GEC15', '2012-07-12', '2012-10-25'),
	('GEC16', '2012-10-26', '2013-03-21'),
	('GEC17', '2013-03-22', '2013-07-23'),
	('GEC18', '2013-07-24', '2013-10-29'),
	('GEC19', '2013-10-30', '2014-03-19'),
	('GEC20', '2014-03-20', '2014-07-24'),
	('GEC21', '2014-07-25', '2014-10-23'),
	('GEC22', '2014-10-24', '2015-03-26'),
	('GEC23', '2015-03-27', '2015-06-18'),
	('GEC24', '2015-06-19', '2016-03-09'),
	('GEC25', '2016-03-10', '2017-03-15'),
	('GEC26', '2017-03-15', '2099-12-31')
;

INSERT INTO debugTiming (event, eventTime) VALUES ('Initialized gecEpochs table.', now());
