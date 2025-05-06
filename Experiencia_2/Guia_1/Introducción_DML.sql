/*
Introducción DML:
    CRUD    |        DML
----------------------------------
- C: create |  Insert - Guardar
- R: read   |  Select - Consultar
- U: Update |  Update - Actualizar
- D: Delete |  Delete - Eliminar
*/

-- C: Create.
-- Creación de tablas a partir de una consulta.
-- Create table nombre_tabla as ([consulta])
drop table EMP_MENOS_1M;
create table EMP_MENOS_1M as
SELECT 
    e.numrun_emp||'-'||e.dvrun_emp "RUT",
    e.pnombre_emp||' '||e.appaterno_emp "NOMBRE_EMPLEADO",
    e.sueldo_base "SUELDO_BASE"
FROM empleado e
where e.sueldo_base < 1000000
order by 3;

-- U: Update.
-- Se recomienda crear un punto de guardado:
SAVEPOINT s1;--Punto de guardado

update empleado set sueldo_base = round(sueldo_base * 1.1)
where numrun_emp||'-'||dvrun_emp in (select rut from emp_menos_1m);

-- D: Delete.
DELETE FROM emp_menos_1m WHERE RUT = '12648200-3';

-- Insert:
INSERT INTO emp_menos_1m(RUT,NOMBRE_EMPLEADO,SUELDO_BASE)--Guardar un insert a partir de una consulta.
SELECT 
    e.numrun_emp||'-'||e.dvrun_emp "RUT",
    e.pnombre_emp||' '||e.appaterno_emp "NOMBRE_EMPLEADO",
    e.sueldo_base "SUELDO_BASE"
FROM empleado e
where e.numrun_emp = 12648200;

-- Guardar datos de tablas diferentes:
CREATE TABLE camion_con_arriendos (
    nro_patente VARCHAR2(6) unique,
    cantidad_arriendos integer not null
);

CREATE TABLE camion_sin_arriendos (
    nro_patente VARCHAR2(6) unique,
    cantidad_arriendos integer not null
);

-- Insert con condiciones:
INSERT all 
    when cantidad_arriendos = 0 then -- Condición del insert, para que se guarden en la tabla correspondiente según la condición:
        into camion_sin_arriendos(nro_patente,cantidad_arriendos) 
        values(nro_patente,cantidad_arriendos)
    else -- Si la condición no se cumplio, el dato se guarda en la otra tabla que corresponde según el caso:
        into camion_con_arriendos(nro_patente,cantidad_arriendos) 
        values(nro_patente,cantidad_arriendos)
SELECT -- Consulta para identiticar camiones y cantidad de arriendos:
    c.nro_patente "NRO_PATENTE",
    count(ac.nro_patente) "CANTIDAD_ARRIENDOS"
FROM camion c
left join arriendo_camion ac on c.nro_patente = ac.nro_patente
group by c.nro_patente;

-- En caso de equivocarse, use un rollback:
ROLLBACK to s1;