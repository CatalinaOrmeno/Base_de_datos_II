-- Join simple:
SELECT 
    e.nombre_empleado,
    e.id_departamento,
    d.nombre_departamento
FROM empleado e
join departamento d on e.id_departamento = d.id_departamento;

-- Left Join: Mostrar los datos que se unen y los que no se unen, y están en la tabla izquierda(la tabla izquierda es la que se llama primero).
SELECT 
    e.nombre_empleado,
    e.id_departamento,
    d.nombre_departamento
FROM empleado e
left join departamento d on e.id_departamento = d.id_departamento;

-- Left Join + where [atributo] is null: Mostrar los datos que no se unen.
SELECT 
    e.nombre_empleado,
    e.id_departamento,
    d.nombre_departamento
FROM empleado e
left join departamento d on e.id_departamento = d.id_departamento
where d.id_departamento is null;

-- Right join: Mostrar los datos que se unen y los que no se unen, y están en la tabla derecha(la tabla derecha es la que se llama después).
SELECT 
    e.nombre_empleado,
    e.id_departamento,
    d.nombre_departamento
FROM empleado e
right join departamento d on e.id_departamento = d.id_departamento;

-- Right join + where [atributo] is null: Mostrar los datos que no se unen.
SELECT 
    e.nombre_empleado,
    e.id_departamento,
    d.nombre_departamento
FROM empleado e
right join departamento d on e.id_departamento = d.id_departamento
where e.id_departamento is null;

-- Full join: Mostrar todo.
SELECT 
    e.nombre_empleado,
    e.id_departamento,
    d.nombre_departamento
FROM empleado e
full join departamento d on e.id_departamento = d.id_departamento;

-- Full join + where [atributo 1] is null or [atributo 2] is null: Se muestra todos los datos vacios de ambas tablas.
SELECT 
    e.nombre_empleado,
    e.id_departamento,
    d.nombre_departamento
FROM empleado e
full join departamento d on e.id_departamento = d.id_departamento
where e.id_departamento is null or d.id_departamento is null;

-- Cross join: Une cada elemento de un conjunto con cada elemento del segundo conjunto.
SELECT 
    e.nombre_empleado,
    e.id_departamento,
    d.nombre_departamento
FROM empleado e
cross join departamento d;

-- Self join: Una tabla que se une consigo misma.
SELECT 
    j.nombre_empleado "NOMBRE JEFE",
    e.nombre_empleado "NOMBRE EMPLEADO"
FROM empleado j
Right join empleado e on j.rut = e.rut_jefe;

-- NONEQUINJOIN: Un join entre 2 tablas que en principio no tienen relación.
SELECT 
    e.nombre_empleado"NOMBRE EMPLEADO",
    e.anios_antiguedad"AÑOS DE ANTIGUEDAD",
    p.porcentaje_bono||'%'"PORCENTAJE BONO"
FROM empleado e
join porc_bono_anios p on e.anios_antiguedad between p.anio_ini and p.anio_ter;