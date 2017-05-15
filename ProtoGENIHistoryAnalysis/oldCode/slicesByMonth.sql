SELECT month, count(*) as Slices
FROM 
	(
	SELECT SUBSTR(created, 1, 7) AS month 
	FROM historyRecords
	WHERE (not derived_test_slice) and 
		  (not derived_test_site)
	) AS months 
GROUP BY month;
