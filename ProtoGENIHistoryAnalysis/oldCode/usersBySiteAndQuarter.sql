SELECT 
	quarter,
	SUBSTRING(urn, firstPlus+1, secondPlus-1) AS site,
	count(distinct creator_urn) as uniqueSliceCreators
FROM
	(
	SELECT 
		urn,
		CONCAT(YEAR(created), 'Q', QUARTER(created)) AS quarter, 
		creator_urn, 
		LOCATE('+', urn) AS firstPlus,
		LOCATE('+', substring(urn, LOCATE('+', urn) + 1 )) AS secondPlus
		FROM historyRecords
		WHERE (not derived_test_slice) and 
		  	  (not derived_test_site)
	) as recs 
GROUP by site, quarter
ORDER by quarter ASC;

