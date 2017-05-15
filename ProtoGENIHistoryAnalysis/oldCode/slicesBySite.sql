SELECT 
	SUBSTRING(urn, firstPlus+1, secondPlus-1) AS site,
	count(urn) 
FROM
	(
	SELECT 
		urn,
		LOCATE('+', urn) AS firstPlus,
		LOCATE('+', substring(urn, LOCATE('+', urn) + 1 )) AS secondPlus
		FROM historyRecords
		WHERE (not derived_test_slice) and 
		  	  (not derived_test_site)
	) as recs 
GROUP by site;
