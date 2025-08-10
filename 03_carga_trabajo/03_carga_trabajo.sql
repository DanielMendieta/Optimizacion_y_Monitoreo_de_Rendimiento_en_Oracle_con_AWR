DECLARE
  v_start_time TIMESTAMP := SYSTIMESTAMP;
  v_end_time   TIMESTAMP;
  v_loop_count INTEGER := 0;
  v_max_loops  INTEGER := 1000;

  -- Array de IDs de departamento válidos (ajusta si son diferentes)
  TYPE t_dept_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  v_dept_ids t_dept_ids;
BEGIN
  -- Inicializa los IDs de departamento
  v_dept_ids(1) := 10;
  v_dept_ids(2) := 20;
  v_dept_ids(3) := 30;
  v_dept_ids(4) := 40;
  v_dept_ids(5) := 50;
  v_dept_ids(6) := 60;
  v_dept_ids(7) := 70;
  v_dept_ids(8) := 80;
  v_dept_ids(9) := 90;
  v_dept_ids(10) := 100;
  
  v_end_time := v_start_time + INTERVAL '5' MINUTE;

  WHILE SYSTIMESTAMP < v_end_time LOOP
    v_loop_count := v_loop_count + 1;
    
    -- Inserta un registro ficticio en JOB_HISTORY
    INSERT INTO HR.JOB_HISTORY (EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID)
    VALUES (
      MOD(v_loop_count, 107) + 100,
      TRUNC(SYSDATE) - (MOD(v_loop_count, 365) + 1), -- START_DATE siempre será menor
      TRUNC(SYSDATE) - MOD(v_loop_count, 365),
      'IT_PROG',
      v_dept_ids(MOD(v_loop_count, 10) + 1)
    );
    
    -- Actualiza salarios de un empleado
    UPDATE HR.EMPLOYEES
    SET SALARY = SALARY + 10
    WHERE EMPLOYEE_ID = MOD(v_loop_count, 107) + 100;
    
    -- Consulta para generar carga de CPU y I/O
    FOR rec IN (
      SELECT EMPLOYEE_ID, SALARY
      FROM HR.EMPLOYEES
      WHERE SALARY > 5000
    )
    LOOP
      NULL;
    END LOOP;
    
    -- Commit cada 50 iteraciones para no saturar undo
    IF MOD(v_loop_count, 50) = 0 THEN
      COMMIT;
    END IF;
    
    -- Breve pausa para evitar saturación extrema
    DBMS_LOCK.SLEEP(0.01);
  END LOOP;
  
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('Carga de trabajo simulada completada. Iteraciones: ' || v_loop_count);
END;
/
