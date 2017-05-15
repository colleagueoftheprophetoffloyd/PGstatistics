UPDATE historyRecords
SET derived_test_slice =
	(slice_urn LIKE '%+%+slice+acc%') or
	(slice_urn LIKE '%.acc%') or
	(slice_urn LIKE '%+%+slice+non%') or
	(slice_urn LIKE '%.non%') or
	(slice_urn LIKE '%+%+slice+bad%') or
	(slice_urn LIKE '%.bad%') or
	(slice_urn LIKE '%+%+slice+down%') or
	(slice_urn LIKE '%.down%');

UPDATE historyRecords
SET derived_test_site =
	(urn LIKE '%+pgeni1.gpolab.bbn.com+%') or
	(urn LIKE '%+pgeni3.gpolab.bbn.com+%') or
	(urn LIKE '%+jonlab.tbres.emulab.net+%');
	