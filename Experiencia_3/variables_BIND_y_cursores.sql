set serveroutput on;
create table empleado(
    id_empleado number(5) primary key,
    nombre varchar2(150),
    salario number
);
INSERT INTO empleado VALUES (100,'Alan Gajardo',1300000);
INSERT INTO empleado VALUES (200,'Adam Catril',750000);
INSERT INTO empleado VALUES (300,'Jose Lara',400000);

-- 1. Variable de enlace(BIND):
variable v_resultado number;
--Bloque anonimo:
begin
    :v_resultado := (500000*1.1);
end;
/
-- Mostrar resultado:
print v_resultado;

-- 2. Obtener el sueldo de Alan Gajardo en una variable de enlace:
variable v_salario number;
-- Obtener el salario por medio de un bloque:
begin
    SELECT salario 
    into :v_salario 
    FROM empleado where id_empleado = 100;
end;
/
-- Mostrar el salario de Alan:
print v_salario;

-- Cursores: Guardan la respuesta de una consulta.
declare
    cursor c_empleados is
        SELECT id_empleado,nombre,salario FROM empleado;
        -- SELECT * FROM empleado; 
    v_id        empleado.id_empleado%type;
    v_nombre    empleado.nombre%type;
    v_salario   empleado.salario%type;
begin
    open c_empleados;-- Para acceder al cursor, se debe abrir.
    loop
        fetch c_empleados into v_id,v_nombre,v_salario;
        exit when c_empleados%NOTFOUND;-- Sale del loop cuando ya no obtenga más información del cursor.
        
        dbms_output.put_line('ID '||v_id||' NOMBRE '||v_nombre||' $'||v_salario);
    end loop;
    close c_empleados;-- Luego de acceder, se debe cerrar.
end;
/

-- Guardar en una variable de enlace el total de empleados quie tienen un sueldo mayor al sueldo mínimo($529.000).
variable v_cantidad number; -- Variable BIND para guardar al total.
declare
    cursor c_empleados is
        SELECT salario FROM empleado;
    v_total             number := 0;
    v_salario           empleado.salario%type;
    v_sueldo_minimo     number := 529000;
begin
    open c_empleados;
    loop
        fetch c_empleados into v_salario;
        exit when c_empleados%NOTFOUND;
        if v_salario > v_sueldo_minimo then -- Si gana más del sueldo mínimo...
            v_total := v_total + 1; -- Se aumenta el contador.
        end if;
    end loop;
    close c_empleados;
    
    :v_cantidad := v_total; -- Se guarda el resultado en la variable BIND.
    dbms_output.put_line(:v_cantidad);
end;
/
print v_cantidad;

-- Utilizando una variable de enlace y un cursor, identificar quien es el empleado que gana el salario máximo (nombre del emleado).
variable v_nombre_empleado varchar2(150);
declare
    cursor c_empleados is
        SELECT nombre,salario FROM empleado;
    v_salario_max   empleado.salario%type;
    v_salario   empleado.salario%type;
    v_nombre    empleado.nombre%type;
begin
    SELECT max(salario) into v_salario_max FROM empleado;
    open c_empleados;
    loop
        fetch c_empleados into v_nombre,v_salario;
        exit when c_empleados%NOTFOUND;
        
        if v_salario = v_salario_max then
            :v_nombre_empleado := v_nombre;
        end if;
    end loop;
    close c_empleados;
    
    dbms_output.put_line(:v_nombre_empleado);
end;
/
print v_nombre_empleado;