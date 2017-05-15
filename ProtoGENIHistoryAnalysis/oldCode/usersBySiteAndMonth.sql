SELECT 
	month,
	SUBSTRING(urn, firstPlus+1, secondPlus-1) AS site,
	count(distinct creator_urn) as uniqueSliceCreators
FROM
	(
	SELECT 
		urn,
		SUBSTR(created, 1, 7) AS month, 
		creator_urn, 
		LOCATE('+', urn) AS firstPlus,
		LOCATE('+', substring(urn, LOCATE('+', urn) + 1 )) AS secondPlus
		FROM historyRecords
		WHERE (not derived_test_slice) and 
		  	  (not derived_test_site)
	) as recs 
GROUP by site, month
ORDER by month ASC;

