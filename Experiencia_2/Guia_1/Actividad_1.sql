SAVEPOINT original;

-- Caso 1:
insert into bonif_arriendos_mensual
SELECT 
    to_char(sysdate,'YYYYMM') "ANNO_MES",
    e.numrun_emp "NUMRUN_EMP",
    initcap(e.pnombre_emp||' '||e.snombre_emp||' '||e.appaterno_emp||' '||e.apmaterno_emp) "NOMBRE_EMPLEADO",
    e.sueldo_base "SUELDO_BASE",
    count(*) "TOTAL_ARRIENDO_MENSUAL",
    round(e.sueldo_base*(count(*)/100)) "BONIF_POR_ARRIENDOS"
FROM empleado e
join camion on e.numrun_emp = camion.numrun_emp
join arriendo_camion ac on camion.nro_patente = ac.nro_patente
where to_char(sysdate,'YYYYMM') = to_char(ac.fecha_ini_arriendo,'YYYYMM') -- Para compararlo con la fecha actual.
--where to_char(sysdate,'YYYY')||'09' = to_char(ac.fecha_ini_arriendo,'YYYYMM') -- Para compararlo con la fecha de la guia.
group by to_char(sysdate,'YYYYMM'),e.numrun_emp,e.pnombre_emp,e.snombre_emp,e.appaterno_emp,e.apmaterno_emp,e.sueldo_base
order by e.appaterno_emp;

SAVEPOINT caso1;

-- Caso 2:
--Paso 1:
-- Sub-consulta:
SELECT 
    round(avg(count(arr.numrun_cli)))
FROM cliente cl
left join arriendo_camion arr on cl.numrun_cli = arr.numrun_cli
where extract(year from sysdate) = extract(year from arr.fecha_ini_arriendo)
group by cl.numrun_cli;

/*
SELECT 
    round(avg(count(*)))
FROM arriendo_camion arr
where extract(year from sysdate) = extract(year from arr.fecha_ini_arriendo)
group by arr.numrun_cli;*/

-- Consulta principal:
INSERT INTO clientes_arriendos_menos_prom(ANNO_PROCESO,NOMBRE_CLIENTE,TOTAL_ARRIENDOS)
SELECT 
    extract(year from sysdate) "ANNO_PROCESO",
    initcap(c.pnombre_cli||' '||c.snombre_cli||' '||c.appaterno_cli||' '||c.apmaterno_cli) "NOMBRE_CLIENTE",
    count(ac.numrun_cli)"TOTAL_ARRIENDOS"
FROM cliente c
left join arriendo_camion ac on c.numrun_cli = ac.numrun_cli
    and extract(year from sysdate) = extract(year from ac.fecha_ini_arriendo)
group by extract(year from sysdate),c.pnombre_cli,c.snombre_cli,c.appaterno_cli,c.apmaterno_cli
having count(ac.numrun_cli) < (SELECT round(avg(count(arr.numrun_cli))) FROM cliente cl
                                    left join arriendo_camion arr on cl.numrun_cli = arr.numrun_cli
                                    where extract(year from sysdate) = extract(year from arr.fecha_ini_arriendo)
                                    group by cl.numrun_cli)
order by c.appaterno_cli;

SAVEPOINT caso2_paso1;

-- Paso 2:
update cliente c set c.id_categoria_cli = 100 
    where initcap(c.pnombre_cli||' '||c.snombre_cli||' '||c.appaterno_cli||' '||c.apmaterno_cli) =any (select nombre_cliente FROM clientes_arriendos_menos_prom);

SAVEPOINT caso2_paso2;

SELECT 
    c.numrun_cli,
    c.pnombre_cli,
    c.snombre_cli,
    c.appaterno_cli,
    c.apmaterno_cli,
    id_categoria_cli
FROM cliente c
where initcap(c.pnombre_cli||' '||c.snombre_cli||' '||c.appaterno_cli||' '||c.apmaterno_cli) =any 
    (select nombre_cliente FROM clientes_arriendos_menos_prom)
order by c.appaterno_cli;

-- Caso 3:
SELECT 
    cl.numrun_cli||'-'||cl.dvrun_cli "RUT",
    count(arr.numrun_cli)
FROM cliente cl
left join arriendo_camion arr on cl.numrun_cli = arr.numrun_cli
    and extract(year from arr.fecha_ini_arriendo) = extract(year from sysdate)-2
group by cl.numrun_cli,cl.dvrun_cli
having count(arr.numrun_cli) = 0;

--ROLLBACK original;