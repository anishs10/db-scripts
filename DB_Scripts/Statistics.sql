--- Lock  statistics

EXEC DBMS_STATS.lock_schema_stats('HR');
EXEC DBMS_STATS.lock_table_stats('HR', 'TEST');
EXEC DBMS_STATS.lock_partition_stats('HR', 'TEST', 'TEST_FEB2021');

-- Unlock statistics

EXEC DBMS_STATS.unlock_schema_stats('HR');
EXEC DBMS_STATS.unlock_table_stats('HR', 'TEST');
EXEC DBMS_STATS.unlock_partition_stats('HR', 'TEST', 'TEST_FEB2021');

--- check stats status:

SELECT stattype_locked FROM dba_tab_statistics WHERE table_name = 'TEST' and owner = 'HR';


-- Delete statistics of the complete database


EXEC DBMS_STATS.delete_database_stats;

-- Delete statistics of a single schema

EXEC DBMS_STATS.delete_schema_stats('ENBLGLB');

-- Delete statistics of single tabale
EXEC DBMS_STATS.delete_table_stats('ENBLGLB', 'XYZ');

-- Delete statistics of a column
EXEC DBMS_STATS.delete_column_stats('ENBLGLB', 'XYZ', 'CLASS');

--Delete statistics of an index

EXEC DBMS_STATS.delete_index_stats('ENBLGLB', 'CLASS_IDX');

--Delete dictionary a in db

EXEC DBMS_STATS.delete_dictionary_stats;