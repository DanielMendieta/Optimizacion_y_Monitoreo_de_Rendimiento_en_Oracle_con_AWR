-- 1. Verificar si AWR está habilitado
COLUMN SNAP_INTERVAL FORMAT A20
COLUMN RETENTION FORMAT A20
SELECT SNAP_INTERVAL, RETENTION
FROM DBA_HIST_WR_CONTROL;

-- 2. Ajustar intervalo de captura de snapshots a 10 minutos para pruebas
-- (en producción, normalmente es 60 minutos)
BEGIN
  DBMS_WORKLOAD_REPOSITORY.modify_snapshot_settings(
    interval  => 10,   -- minutos
    retention => 691201 -- minutos (1 día de retención para pruebas)
  );
END;
/

-- 3. Confirmar cambios
SELECT SNAP_INTERVAL, RETENTION
FROM DBA_HIST_WR_CONTROL;

-- 4. Crear usuario de trabajo para análisis (opcional)

CREATE USER backup_daniel IDENTIFIED BY "Oracle123"
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

GRANT CONNECT, RESOURCE TO backup_daniel;

-- Permisos para vistas AWR
GRANT SELECT_CATALOG_ROLE TO backup_daniel;

-- 5. Información de la instancia y parámetros clave
SELECT INSTANCE_NAME, HOST_NAME, VERSION, STATUS
FROM V$INSTANCE;

SELECT NAME, VALUE
FROM V$PARAMETER
WHERE NAME IN ('statistics_level','control_management_pack_access');


