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
INSERT INTO debugTiming (event, eventTime) VALUES ('Start populate by GEC', now());

DROP TABLE IF EXISTS gecEpochStatistics;

CREATE TABLE `gecEpochStatistics` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `epochID` int(11) DEFAULT NULL,
  `epochName` varchar(6) DEFAULT NULL,
  `startDate` date DEFAULT NULL,
  `endDate` date DEFAULT NULL,
  `siteName` varchar(200) DEFAULT NULL,
  `currentSlivers` int(11) DEFAULT NULL,
  `currentUsers` int(11) DEFAULT NULL,
  `cumSlivers` int(11) DEFAULT NULL,
  `cumUsers` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

# Make a row for every epoch,site pair.
# Can grab current epoch statistics all in one go.
INSERT INTO gecEpochStatistics
        (epochID,
        epochName,
        startDate,
        endDate,
        siteName,
        currentSlivers,
        currentUsers)
SELECT
        g.id AS epochID,
        g.epoch AS epochName,
        g.startDate AS startDate,
        g.endDate AS endDate,
        hr.derived_site_name AS siteName,
        count(uuid) AS currentSlivers,
        count(DISTINCT creator_urn) AS currentUsers
FROM
        historyRecords AS hr
        INNER JOIN
        gecEpochs as g
        ON (hr.derived_epoch = g.id)
GROUP BY
        hr.derived_site_name,
        hr.derived_epoch;

INSERT INTO debugTiming (event, eventTime) VALUES ('Done - GEC current stats by site', now());

# Need subqueries for each cumulative statistic.
# There should be a better way, but remember that
# to preserve uniqueness, it is not OK just to sum,
# at least across users. Slivers could just be summed.
UPDATE gecEpochStatistics AS gs
SET
        cumSlivers = (SELECT COUNT(uuid)
                                  FROM historyRecords as hr
                                  WHERE ((hr.derived_epoch <= gs.epochID) AND
                                         (hr.derived_site_name = gs.siteName))),
        cumUsers = (SELECT COUNT(DISTINCT creator_urn)
                                FROM historyRecords as hr
                                WHERE ((hr.derived_epoch <= gs.epochID) AND
                                       (hr.derived_site_name = gs.siteName)))
WHERE gs.siteName != 'AllSites';

INSERT INTO debugTiming (event, eventTime) VALUES ('Done - GEC cumulative stats by site', now());

# Add rows for 'AllSites' for each epoch.
INSERT
INTO gecEpochStatistics
        (epochID,
        epochName,
        startDate,
        endDate,
        siteName)
SELECT
        g.id AS epochID,
        g.epoch AS epochName,
        g.startDate AS startDate,
        g.endDate AS endDate,
        'AllSites' AS siteName
FROM
        gecEpochs as g;

# Compute all the AllSites statistics.
UPDATE gecEpochStatistics as gs
SET
        gs.currentSlivers =
                (
                SELECT count(*)
                FROM historyRecords AS hr
                WHERE (hr.derived_epoch = gs.epochID)
                ),
        gs.currentUsers =
                (
                SELECT count(DISTINCT creator_urn)
                FROM historyRecords AS hr
                WHERE (hr.derived_epoch = gs.epochID)
                ),
        gs.cumSlivers = (
                SELECT count(*)
                FROM historyRecords AS hr
                WHERE (hr.derived_epoch <= gs.epochID)
                ),
        gs.cumUsers =
                (
                SELECT count(DISTINCT creator_urn)
                FROM historyRecords AS hr
                WHERE (hr.derived_epoch <= gs.epochID)
                )
WHERE gs.siteName = 'AllSites';

INSERT INTO debugTiming (event, eventTime) VALUES ('Done - GEC stats - AllSites', now());

INSERT INTO debugTiming (event, eventTime) VALUES ('End populate by GEC', now());

