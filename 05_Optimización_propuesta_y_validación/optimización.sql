-- 1. Ver el plan de ejecución original
EXPLAIN PLAN FOR
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE department_id = 60
  AND salary > 8000;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
--RESULTADO:
/*
Plan hash value: 1445457117
 
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |     2 |   130 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMPLOYEES |     2 |   130 |     2   (0)| 00:00:01 |
-------------------------------------------------------------------------------
*/

-- 2 Crear un índice compuesto para mejorar el acceso
CREATE INDEX idx_emp_dept_salary
ON employees(department_id, salary);

-- 3. Actualizar estadísticas para que el optimizador use el nuevo índice
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(
        ownname => 'sys',
        tabname => 'EMPLOYEES'
    );
END;
/

--NUEVO_RESULTADO:
/*
Plan hash value: 4196744019
 
-----------------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name                | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |                     |     3 |    81 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEES           |     3 |    81 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN                  | IDX_EMP_DEPT_SALARY |     3 |       |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------------
*/











