SELECT 
	month, count(distinct creator_urn) as uniqueSliceCreators
FROM
	(
	SELECT 
		substr(created, 1, 7) as month, 
		creator_urn FROM historyRecords
		WHERE (not derived_test_slice) and 
		  	  (not derived_test_site)
	) as recs 
GROUP by month;
