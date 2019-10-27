DECLARE @table NVARCHAR(200) = 'ScheduleEvent'

; WITH CTE AS (
	SELECT i.name AS index_name  
		,COL_NAME(ic.object_id,ic.column_id) AS column_name  
		,ic.index_column_id  
		,ic.key_ordinal  
		,i.index_id
		,ic.is_included_column  
		,i.object_id
	FROM sys.indexes AS i  
	INNER JOIN sys.index_columns AS ic
		ON i.object_id = ic.object_id AND i.index_id = ic.index_id  
	WHERE i.object_id = OBJECT_ID(@table)
),
index_sizes  AS (
	SELECT i.index_id,
		i.object_id,
		SUM(s.[used_page_count]) * 8 AS IndexSizeKB
		,MAX(p.[data_compression]) AS [data_compression]
	FROM sys.dm_db_partition_stats AS s
	INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
		AND s.[index_id] = i.[index_id]
	INNER JOIN sys.partitions p ON p.partition_id = s.partition_id
	WHERE i.object_id = OBJECT_ID(@table)
	GROUP BY i.index_id, i.object_id
)
SELECT 
	i.index_id,
	@table AS table_name,
	i.[name] as index_name,
   STUFF(
	(SELECT ', ' + COLUMN_name 
          FROM CTE
          WHERE CTE.index_id = i.index_id
		  AND is_included_column = 0
          ORDER BY index_column_id
          FOR XML PATH('')), 1, 1, '') AS [indexed_columns],

       COALESCE(STUFF(
			(SELECT ', ' + COLUMN_name 
				  FROM CTE
				  WHERE CTE.index_id = i.index_id
				  AND is_included_column = 1
				  ORDER BY index_column_id
				  FOR XML PATH('')), 1, 1, ''), '') AS [included_columns]
		, index_mb = FORMAT((SELECT (IndexSizeKB/1024) FROM index_sizes WHERE index_id = i.index_id), 'N0')
		, COALESCE(FORMAT(user_seeks + user_scans + user_lookups, 'N0'), '') AS [usage_count]
		,user_seeks
		,user_scans
		,user_lookups
		, COALESCE(i.filter_definition, '') AS filter_definition
		,[data_compression]
FROM sys.indexes i
LEFT JOIN index_sizes  ON index_sizes.index_id = i.index_id and index_sizes.object_id = i.object_id
LEFT JOIN sys.dm_db_index_usage_stats as S ON S.index_id = i.index_id AND s.object_id = i.object_id AND database_id = DB_ID()
WHERE i.object_id = OBJECT_ID(@table)
ORDER BY [Indexed_Columns], [Included_Columns]
