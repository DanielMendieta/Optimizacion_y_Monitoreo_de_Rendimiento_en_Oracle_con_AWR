DECLARE
  v_start_time TIMESTAMP := SYSTIMESTAMP;
  v_end_time   TIMESTAMP;
  v_loop_count INTEGER := 0;
  v_max_loops  INTEGER := 1000; -- Ajusta para controlar duración
BEGIN
  -- Establecemos fin del loop: correr al menos 5 minutos
  v_end_time := v_start_time + INTERVAL '5' MINUTE;

  WHILE SYSTIMESTAMP < v_end_time LOOP
    v_loop_count := v_loop_count + 1;

    -- Inserta un registro ficticio en JOB_HISTORY
    INSERT INTO HR.JOB_HISTORY (EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID)
    VALUES (
      MOD(v_loop_count, 100) + 1, -- EMPLOYEE_ID 1-100
      TRUNC(SYSDATE) - MOD(v_loop_count, 365),
      TRUNC(SYSDATE) - MOD(v_loop_count - 1, 365),
      'IT_PROG',
      MOD(v_loop_count, 10) + 10
    );

    -- Actualiza salarios de un empleado
    UPDATE HR.EMPLOYEES
    SET SALARY = SALARY + 10
    WHERE EMPLOYEE_ID = MOD(v_loop_count, 100) + 1;

    -- Consulta para generar carga de CPU y I/O
    FOR rec IN (
      SELECT EMPLOYEE_ID, SALARY
      FROM HR.EMPLOYEES
      WHERE SALARY > 5000
    )
    LOOP
      NULL; -- No hacemos nada, solo iteramos
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
