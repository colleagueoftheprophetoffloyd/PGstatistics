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
INSERT INTO debugTiming (event, eventTime) VALUES ('Start populate quarterly', now());

# Build quarterly statistics from scratch

DROP TABLE IF EXISTS quarterlyStatistics;

CREATE TABLE `quarterlyStatistics` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `quarterID` int(11) DEFAULT NULL,
  `quarterName` varchar(6) DEFAULT NULL,
  `startDate` date DEFAULT NULL,
  `endDate` date DEFAULT NULL,
  `siteName` varchar(200) DEFAULT NULL,
  `currentSlivers` int(11) DEFAULT NULL,
  `currentUsers` int(11) DEFAULT NULL,
  `latestYearUsers` int(11) DEFAULT NULL,
  `cumSlivers` int(11) DEFAULT NULL,
  `cumUsers` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

# Make a row for every quarter,site pair.
# Can grab current quarter statistics all in one go.
INSERT INTO quarterlyStatistics
	(quarterID,
	quarterName,
	startDate,
	endDate,
	siteName,
	currentSlivers,
	currentUsers)
SELECT
	q.id AS quarterID,
	q.quarterName AS quarterName,
	q.startDate AS startDate,
	q.endDate AS endDate,
	hr.derived_site_name AS siteName,
	count(uuid) AS currentSlivers,
	count(DISTINCT creator_urn) AS currentUsers
FROM
	historyRecords AS hr
	INNER JOIN
	quarters AS q
	ON (hr.derived_quarter = q.id)
GROUP BY
	hr.derived_site_name,
	hr.derived_quarter;

INSERT INTO debugTiming (event, eventTime) VALUES ('Done - quarterly current stats by site', now());

# Need subqueries for each cumulative statistic.
# There should be a better way, but remember that
# to preserve uniqueness, it is not OK just to sum,
# at least across users. Slivers could just be summed.
UPDATE quarterlyStatistics AS qs
SET
	cumSlivers = (SELECT COUNT(uuid)
				  FROM historyRecords as hr
				  WHERE ((hr.derived_quarter <= qs.quarterID) AND
				         (hr.derived_site_name = qs.siteName))),
	latestYearUsers = (SELECT COUNT(DISTINCT creator_urn)
				FROM historyRecords as hr
				WHERE ((hr.derived_quarter <= qs.quarterID) AND
				       (hr.derived_quarter > qs.quarterID-4) AND
				       (hr.derived_site_name = qs.siteName))),
	cumUsers = (SELECT COUNT(DISTINCT creator_urn)
				FROM historyRecords as hr
				WHERE ((hr.derived_quarter <= qs.quarterID) AND
				       (hr.derived_site_name = qs.siteName)))
WHERE qs.siteName != 'AllSites';

INSERT INTO debugTiming (event, eventTime) VALUES ('Done - quarterly cumulative stats by site', now());

# Add rows for 'AllSites' for each quarter.
INSERT
INTO quarterlyStatistics
	(quarterID,
	quarterName,
	startDate,
	endDate,
	siteName)
SELECT
	q.id AS quarterID,
	q.quarterName AS quarterName,
	q.startDate AS startDate,
	q.endDate AS endDate,
	'AllSites' AS siteName
FROM
	quarters AS q;

# Compute all the AllSites statistics.
UPDATE quarterlyStatistics as qs
SET
	qs.currentSlivers =
		(
		SELECT count(*)
		FROM historyRecords AS hr
		WHERE (hr.derived_quarter = qs.quarterID)
		),
	qs.currentUsers =
		(
		SELECT count(DISTINCT creator_urn)
		FROM historyRecords AS hr
		WHERE (hr.derived_quarter = qs.quarterID)
		),
	qs.latestYearUsers =
		(
		SELECT count(DISTINCT creator_urn)
		FROM historyRecords AS hr
		WHERE ((hr.derived_quarter <= qs.quarterID) AND
		       (hr.derived_quarter > qs.quarterID-4))
		),
	qs.cumSlivers = (
		SELECT count(*)
		FROM historyRecords AS hr
		WHERE (hr.derived_quarter <= qs.quarterID)
		),
	qs.cumUsers =
		(
		SELECT count(DISTINCT creator_urn)
		FROM historyRecords AS hr
		WHERE (hr.derived_quarter <= qs.quarterID)
		)
WHERE qs.siteName = 'AllSites';

INSERT INTO debugTiming (event, eventTime) VALUES ('Done - quarterly stats all sites', now());

INSERT INTO debugTiming (event, eventTime) VALUES ('End populate quarterly', now());
