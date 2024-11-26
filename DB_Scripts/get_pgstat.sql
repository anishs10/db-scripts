SELECT
    datname AS database_name,
    blks_read AS physical_reads,
    blks_hit AS logical_reads,
    tup_inserted AS rows_inserted,
    tup_updated AS rows_updated,
    tup_deleted AS rows_deleted
FROM
    pg_stat_database
WHERE
    datname IN ('zonos_oss', 'customer');
