/*BLOQUES ANÓNIMOS*/

--Algo asi como "programacion" de base de datos

/*Es una unidad de codigo de SQL que se ejecuta de manera anonima, esto quiere
decir que a diferencia de los procedimientos, funciones, trigger, los bloques
anonimos no se guardan.

Una vez que se ejecutan, estos terminan y desaparecen de la memoria*/

/* Estructura de bloque anonimo:
DECLARE 
  --comando opcional para declarar variables
BEGIN
  --comando obligatorio para la ejecucion de codigo
EXCEPTION 
  --comando opcional para controlar errores
END
  --comando obligatorio para determinar el fin del bloque
*/

--0 comando para activar los mensajes por DBMS_OUTPUT
set serveroutput on;

--1.- Mostrar mensajes por bloque anonimo (Hola mundo)
begin
  dbms_output.put_line('Hola mundo desde un bloque anonimo');
end;
/

--2.- Trabajo de variables en bloques anonimos
-- nombre_variable TIPO_DATO [ := valor_inicial];
declare
  --Declaramos las variable
  v_nombre  varchar2(50) :='Alan Soto';
  v_edad   number(3)  := 34;
  v_salario  number(10,2);
  v_fecha_hoy date     := sysdate;
  v_es_activo boolean   := true;
  
begin
  --asignamos el valor en el begin
  v_salario := 5500.75;

  DBMS_output.put_line('Nombre  :'||v_nombre);
  DBMS_output.put_line('Edad   :'||v_edad);
  DBMS_output.put_line('Salario  :'||v_salario);
  DBMS_output.put_line('Fecha   :'||to_char(v_fecha_hoy,'DD/MM/YYYY hh24:MI::SS'));
  
  -- Validar la variable booleana
    if v_es_activo then
        dbms_output.put_line('Estado   :Activo');
    else
        dbms_output.put_line('Estado   :Inactivo');
    end if;
end;
/

--3.Tomar los tipos de una tabla:
-- Tabla ejemplo:
create table empleado(
    id_empleado number(5) primary key,
    nombre varchar2(100),
    salario number(10,2)
);

insert into empleado values(1,'Ana Lopez',6000.50);
insert into empleado values(2,'Ana Lopez2',7000.50);
insert into empleado values(3,'Ana Lopez3',8000.50);
commit;

-- BLoque anónimo:
declare
    v_id_empleado empleado.id_empleado%TYPE := 1;
    v_nombre_empleado empleado.nombre%type := 'Ana López';
    v_salario empleado.salario%type := 6000.50;
begin
    dbms_output.put_line('---- Detalle del empleado ----');
    dbms_output.put_line('Código    :'||v_id_empleado);
    dbms_output.put_line('Nombre    :'||v_nombre_empleado);
    dbms_output.put_line('Salario   :'||v_salario);
end;
/

--4.Consulta en un bloque anónimo:
declare
    v_id_empleado empleado.id_empleado%TYPE := &Ingrese_codigo;
    v_nombre_empleado empleado.nombre%type;
    v_salario_empleado empleado.salario%type;
begin
    select nombre,salario
        into v_nombre_empleado, v_salario_empleado
    from empleado
    where id_empleado = v_id_empleado;
    
    dbms_output.put_line('---- INFORMACIÓN EMPLEADO ----');
    dbms_output.put_line('Código    :'||v_id_empleado);
    dbms_output.put_line('Nombre    :'||v_nombre_empleado);
    dbms_output.put_line('Salario   :'||v_salario_empleado);
exception
    when no_data_found then
        dbms_output.put_line('❌ ERROR: No existe un empleado con el código '||v_id_empleado);
    when too_many_rows then
        dbms_output.put_line('❌ ERROR: Demasiadas filas en la id '||v_id_empleado);
    when others then
        dbms_output.put_line('❌ ERROR inesperado en la id '||v_id_empleado);
end;
/

--5.Ciclos en bloques anónimos:
begin
    for i in 1..5 loop
        dbms_output.put_line('Iteración número: '||i);
    end loop;
end;
/

--6.Ciclo para mostrar los empleados de una tabla:
declare
    v_total_empleados number :=0;
begin
    dbms_output.put_line('DETALLES DE EMPLEADOS');
    dbms_output.put_line('=====================');
    --Ciclo para recorrer la tabla:
    for emp in (select id_empleado,nombre,salario from empleado) loop
        dbms_output.put_line('Código    :'||emp.id_empleado);
        dbms_output.put_line('Nombre    :'||emp.nombre);
        dbms_output.put_line('Salario    :'||emp.salario);
        dbms_output.put_line('');
        v_total_empleados := v_total_empleados + 1;
    end loop;
    dbms_output.put_line('********************');
    dbms_output.put_line('Cantidad empleados: '||v_total_empleados);
exception
    when others then
        dbms_output.put_line('❌ ERROR inesperado');
end;
/