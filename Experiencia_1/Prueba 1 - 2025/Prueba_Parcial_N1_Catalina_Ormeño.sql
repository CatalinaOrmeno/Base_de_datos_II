-- Caso 1:
-- Sub-consulta:
SELECT max(count(*)) FROM propiedad_arrendada p group by p.numrut_cli;

-- Consulta principal:
SELECT 
    to_char(c.numrut_cli,'00g000g000')||'-'||c.dvrut_cli "RUT CLIENTE",
    initcap(c.nombre_cli||' '||c.appaterno_cli||' '||c.apmaterno_cli) "NOMBRE CLIENTE",
    to_char(c.renta_cli,'$999g999g999')"RENTA",
    nvl(to_char(c.celular_cli),'SIN CELULAR')"CELULAR",
    count(pa.numrut_cli) "CANTIDAD DE ARRIENDOS"
FROM cliente c
left join propiedad_arrendada pa on pa.numrut_cli = c.numrut_cli
where c.renta_cli < 1300000
group by c.numrut_cli,c.dvrut_cli,c.nombre_cli,c.appaterno_cli,c.apmaterno_cli,c.renta_cli,c.celular_cli
having count(*) < (SELECT max(count(*)) FROM propiedad_arrendada p group by p.numrut_cli)
order by c.appaterno_cli;

-- Caso 2:
SELECT 
    extract(year from sysdate) "ANNO_DE_REGISTRO",
    p.nro_propiedad,
    p.valor_arriendo,
    p.valor_gasto_comun,
    count(pa.numrut_cli) "TOTAL_VECES_ARRENDADO"
FROM propiedad p
left join propiedad_arrendada pa on pa.nro_propiedad = p.nro_propiedad
group by p.nro_propiedad,p.valor_arriendo,p.valor_gasto_comun
order by 2;

-- Caso 3:
SELECT 
    to_char(emp.numrut_emp,'00g000g000')||'-'||emp.dvrut_emp "RUT EMPLEADO",
    initcap(emp.nombre_emp||' '||emp.appaterno_emp||' '||emp.apmaterno_emp) "NOMBRE COMPLETO",
    count(parr.nro_propiedad) "CANTIDAD ARRIENDOS VIGENTES",
    to_char(avg(pro.valor_arriendo),'$999g999g999') "PROMEDIO ARRIENDO",
    to_char(round(
    case
        when avg(pro.valor_arriendo) > 800000 then
            emp.sueldo_emp * 0.15
        when avg(pro.valor_arriendo) between 600001 and 800000 then
            emp.sueldo_emp * 0.1
         when avg(pro.valor_arriendo) between 300001 and 600000 then
            emp.sueldo_emp * 0.05
        when avg(pro.valor_arriendo) < 300000 then
            emp.sueldo_emp * 0
    end),'$999g999g999') "BONO ASIGNADO"
FROM empleado emp
join propiedad pro on pro.numrut_emp = emp.numrut_emp
join propiedad_arrendada parr on parr.nro_propiedad = pro.nro_propiedad
    where parr.fecter_arriendo is null
group by emp.numrut_emp,emp.dvrut_emp,emp.nombre_emp,emp.appaterno_emp,emp.apmaterno_emp,emp.sueldo_emp
having avg(pro.valor_arriendo) > 300000 and count(parr.nro_propiedad) > 0
order by 4 desc;