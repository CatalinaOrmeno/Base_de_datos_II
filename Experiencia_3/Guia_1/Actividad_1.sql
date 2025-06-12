set serveroutput on;

--Caso 1:
declare
    v_porc_extra    number(10,2) := &Ingrese_porcentaje;
    v_rut           VARCHAR2(15) := '&Ingrese_rut';
    v_nombre        empleado.nombre_emp%type;
    v_appaterno     empleado.appaterno_emp%type;
    v_apmaterno     empleado.apmaterno_emp%type;
    v_sueldo        empleado.sueldo_emp%type;
    v_bonificacion  number(10,2);
begin
    SELECT nombre_emp,appaterno_emp,apmaterno_emp,sueldo_emp
    into v_nombre,v_appaterno,v_apmaterno,v_sueldo
    FROM empleado
    where numrut_emp||'-'||dvrut_emp =v_rut;
    
    v_bonificacion :=  v_sueldo * v_porc_extra;
    
    dbms_output.put_line('DATOS CALCULO BONIFICACION EXTRA DEL '||(v_porc_extra*100)||'% DEL SUELDO');
    dbms_output.put_line('Nombre empleado: '||v_nombre||' '||v_appaterno||' '||v_apmaterno);
    dbms_output.put_line('RUN: '||v_rut);
    dbms_output.put_line('Sueldo: '||v_sueldo);
    dbms_output.put_line('Bonificación extra: '||v_bonificacion);
exception
    when no_data_found then
        dbms_output.put_line('No se encontro empleado con el rut '||v_rut);
    when others then
        dbms_output.put_line('Error inesperado en el rut '||v_rut);
end;
/

--Caso 2:
--Caso 3:
--Caso 4: