-- 1-Crear un snapshot inicial en AWR
BEGIN
    DBMS_WORKLOAD_REPOSITORY.create_snapshot;
END;
/

-- Snapshot inicial creado en AWR

-- 2 Obtener el ID del snapshot recién creado
COLUMN snap_id FORMAT 99999
COLUMN begin_interval_time FORMAT A30

SELECT snap_id, begin_interval_time
FROM dba_hist_snapshot
WHERE begin_interval_time = (
    SELECT MAX(begin_interval_time) FROM dba_hist_snapshot
);

-- 3 Consultar métricas clave de rendimiento
COLUMN metric_name FORMAT A50
COLUMN value FORMAT 999999999.99

SELECT metric_name, value
FROM v$sysmetric
WHERE metric_name IN (
    'Database CPU Time Ratio',
    'Database Wait Time Ratio',
    'SQL Service Response Time',
    'Executions Per Sec',
    'Redo Generated Per Sec'
);

