/*Subconsultas: Una consulta dentro de otra.
Es responder una pregunta pequeña, para responder una pregunta mayor.*/

-- Subconsultas de una fila(Solo entrega 1 resultado):
-- 1.- Se desea identificar el rut y el nombre de todos los médicos que ganan un sueldo sobre el promedio:
SELECT 
    round(avg(med.sueldo_base))"Promedio"
FROM medico med;

SELECT 
    to_char(m.med_run,'00g000g000')||'-'||m.dv_run "RUN MEDICO",
    m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno "NOMBRE MEDICO",
    to_char(m.sueldo_base,'$999g999g999')"SUELDO"
FROM medico m
where m.sueldo_base > 
(SELECT round(avg(med.sueldo_base))FROM medico med)-- Subconsulta: promedio sueldo
order by 3 desc;

-- 2.- Identificar quien o quienes son lpos medicos que ganan el sueldo más alto:
SELECT max(med.sueldo_base) FROM medico med;

SELECT 
    to_char(m.med_run,'00g000g000')||'-'||m.dv_run "RUN MEDICO",
    m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno "NOMBRE MEDICO",
    to_char(m.sueldo_base,'$999g999g999')"SUELDO"
FROM medico m
where m.sueldo_base = (SELECT max(med.sueldo_base)FROM medico med)
order by 2;

-- 3.- Se desea identificar quienes son los medicos que ganan un sueldo mayor al sueldo más alto de la unidad de traumatologia;
SELECT max(med.sueldo_base) FROM medico med where med.uni_id = 1000;

SELECT 
    to_char(m.med_run,'00g000g000')||'-'||m.dv_run "RUN MEDICO",
    m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno "NOMBRE MEDICO",
    to_char(m.sueldo_base,'$999g999g999')"SUELDO"
FROM medico m
where m.sueldo_base > (SELECT max(med.sueldo_base) FROM medico med where med.uni_id = 1000)
order by 3 desc;

-- 4..- Se desea identificar quienes ganan un sueldo entre los sueldos de Ana Betanzo y Lucinda Soto:
SELECT med.sueldo_base FROM medico med1 where med.med_run = 6783834;
SELECT med.sueldo_base FROM medico med2 where med.med_run = 6231787;

SELECT 
    to_char(m.med_run,'00g000g000')||'-'||m.dv_run "RUN MEDICO",
    m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno "NOMBRE MEDICO",
    to_char(m.sueldo_base,'$999g999g999')"SUELDO"
FROM medico m
where m.sueldo_base between (SELECT med1.sueldo_base FROM medico med1 where med1.med_run = 6231787)and(SELECT med2.sueldo_base FROM medico med2 where med2.med_run = 6783834)
order by 3 desc;

-- Subconsultas de una multiples filas(Entrega más de 1 resultado):
-- 1.- Se desea identificar que medicos que medicos ganan un sueldo igual a alguno de los sueldos de la unidad de atencion ambulatoria:
SELECT med.sueldo_base FROM medico med where med.uni_id = 100 order by 1;

SELECT 
    to_char(m.med_run,'00g000g000')||'-'||m.dv_run "RUN MEDICO",
    m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno "NOMBRE MEDICO",
    to_char(m.sueldo_base,'$999g999g999')"SUELDO",
    u.nombre "UNIDAD"
FROM medico m
join unidad u on u.uni_id = m.uni_id
where m.sueldo_base in (SELECT med.sueldo_base FROM medico med where med.uni_id = 100) and u.uni_id != 100
order by 3 desc;

-- 2.-Se desea identificar cuales son los medicos que ganan un sueldo menos a cualquiera de los sueldos de la unidad de traumatologia adulto:
select med.sueldo_base from medico med where med.uni_id = 1000;

SELECT 
    to_char(m.med_run,'00g000g000')||'-'||m.dv_run "RUN MEDICO",
    m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno "NOMBRE MEDICO",
    to_char(m.sueldo_base,'$999g999g999')"SUELDO",
    u.nombre "UNIDAD"
FROM medico m
join unidad u on u.uni_id = m.uni_id
where m.sueldo_base <any (select med.sueldo_base from medico med where med.uni_id = 1000)
order by 3 desc;