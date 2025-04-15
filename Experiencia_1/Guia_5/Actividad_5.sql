-- Caso 1:
-- Sub consulta:
SELECT round(avg(count(*))) FROM atencion a 
where extract(month from a.fecha_atencion) = extract(month from sysdate)-1 and
      extract(year from a.fecha_atencion) = extract(year from sysdate)
group by a.fecha_atencion;

-- Consulta principal:
SELECT 
    ts.descripcion||', '||s.descripcion"SISTEMA_SALUD",
    count(*) "TOTAL ATENCIONES"
FROM tipo_salud ts
join salud s on ts.tipo_sal_id = s.tipo_sal_id
join paciente p on s.sal_id = p.sal_id
join atencion ate on p.pac_run = ate.pac_run
where extract(month from ate.fecha_atencion) = extract(month from sysdate)-1 and
      extract(year from ate.fecha_atencion) = extract(year from sysdate) and
      (ts.descripcion = 'Fonasa' or ts.descripcion = 'Isapre')
having count(*) > (SELECT round(avg(count(*))) FROM atencion a 
                    where extract(month from a.fecha_atencion) = extract(month from sysdate)-1 and
                          extract(year from a.fecha_atencion) = extract(year from sysdate)
                            group by a.fecha_atencion)
group by ts.descripcion,s.descripcion;

-- Sub consulta:
SELECT 
    p.pac_run
FROM paciente p 
join atencion a on p.pac_run = a.pac_run
where round(months_between(sysdate,p.fecha_nacimiento)/12) > 64.5 and 
        extract(year from a.fecha_atencion) = extract(year from sysdate)
group by p.pac_run
having count(*) > 4;

-- Consulta principal:
SELECT 
    to_char(pa.pac_run,'00g000g000')||'-'||pa.dv_run "RUT PACIENTE",
    pa.pnombre||' '||pa.snombre||' '||pa.apaterno||' '||pa.amaterno "NOMBRE PACIENTE",
    round(months_between(sysdate,pa.fecha_nacimiento)/12) "AÑOS",
    'Le corresponde un '||pd3e.porcentaje_descto||
    '% de descuento en la primera consulta médica del año '||(extract(year from sysdate)+1) 
    "PORCENTAJE DESCUENTO"
FROM paciente pa
join porc_descto_3ra_edad pd3e on round(months_between(sysdate,pa.fecha_nacimiento)/12) 
    between pd3e.anno_ini and pd3e.anno_ter
where pa.pac_run =any (SELECT p.pac_run FROM paciente p 
                        join atencion a on p.pac_run = a.pac_run
                        where round(months_between(sysdate,p.fecha_nacimiento)/12) > 64.5 and 
                        extract(year from a.fecha_atencion) = extract(year from sysdate)
                        group by p.pac_run having count(*) > 4)
order by pa.apaterno;

-- Caso 2:
-- Sub consulta:
SELECT 
    a.esp_id"ID",
    es.nombre "ESPECIALIDAD",
    count(*) "CONSULTAS DURANTE EL AÑO"
FROM atencion a
join especialidad es on es.esp_id = a.esp_id
where extract(year from a.fecha_atencion) = extract(year from sysdate)-1
group by a.esp_id,es.nombre
having count(*) < 10;

-- Consulta principal:
SELECT 
    espe.nombre "ESPECIALIDAD",
    to_char(m.med_run,'00g000g000')||'-'||m.dv_run"RUT",
    upper(m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno)"MEDICO"
FROM especialidad_medico esm
join medico m on m.med_run = esm.med_run
join especialidad espe on espe.esp_id = esm.esp_id
where esm.esp_id =any (SELECT a.esp_id FROM atencion a 
                            join especialidad es on es.esp_id = a.esp_id
                            where extract(year from a.fecha_atencion) = 
                            extract(year from sysdate)-1
                            group by a.esp_id,es.nombre having count(*) < 10)
order by 1,m.apaterno;

-- Caso 3:!!!
-- Sub consulta:
SELECT 
    u.uni_id,
    u.nombre,
    m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno"MEDICO",
    count(*)
FROM atencion a
left join medico m on m.med_run = a.med_run
join unidad u on u.uni_id = m.uni_id
where extract(year from a.fecha_atencion) = extract(year from sysdate)-1
group by u.uni_id, u.nombre,m.med_run,m.pnombre,m.snombre,m.apaterno,m.amaterno
order by 2,4 desc;

-- Consulta principal:
create table MEDICOS_SERVICIO_COMUNIDAD as
SELECT 
    uni.nombre "UNIDAD",
    me.pnombre||' '||me.snombre||' '||me.apaterno||' '||me.amaterno"MEDICO",
    me.telefono "TELEFONO",
    substr(uni.nombre,1,2)||substr(me.apaterno,-3,2)||substr(me.telefono,-3,3)||
    to_char(me.fecha_contrato,'ddMM')||'@medicocktk.cl'"CORREO_MEDICO",
    count(ate.ate_id)"ATENCIONES_MEDICAS"
FROM medico me
join unidad uni on uni.uni_id = me.uni_id
left join atencion ate on me.med_run = ate.med_run 
    and extract(year from ate.fecha_atencion) = extract(year from sysdate)-1
group by uni.nombre,me.pnombre,me.snombre,me.apaterno,me.amaterno,me.telefono,uni.nombre,me.fecha_contrato
having count(*) <any (SELECT count(*) FROM atencion a
            left join medico m on m.med_run = a.med_run
            join unidad u on u.uni_id = m.uni_id
            where extract(year from a.fecha_atencion) = extract(year from sysdate)-1
            group by u.uni_id,m.med_run)
order by 1,me.apaterno;

-- Caso 4:
-- Informe 1:
-- Sub consulta:
SELECT 
    round(avg(count(*)))"Promedio mensual"
FROM atencion a
group by to_char(a.fecha_atencion,'YYYY/MM');

-- Consulta principal:
SELECT 
    to_char(ate.fecha_atencion,'YYYY/MM') "AÑO Y MES",
    count(*)"TOTAL DE ATENCIONES",
    lpad(to_char(sum(ate.costo),'$999g999g999'),27)"VALOR TOTAL DE LAS ATENCIONES"
FROM atencion ate
group by to_char(ate.fecha_atencion,'YYYY/MM')
having count(*) >= (SELECT round(avg(count(*)))"Promedio mensual" 
                    FROM atencion a 
                    group by to_char(a.fecha_atencion,'YYYY/MM'))
order by 1;

-- Informe 2:!!!
-- Sub consulta:
SELECT 
    round(avg(sum(pa.fecha_pago - pa.fecha_venc_pago)))
FROM pago_atencion pa
group by to_char(pa.fecha_pago,'YYYY/MM');

-- Consulta principal:
SELECT 
    to_char(p.pac_run,'00g000g000')||'-'||p.dv_run "RUT PACIENTE",
    p.pnombre||' '||p.snombre||' '||p.apaterno||' '||p.amaterno "NOMBRE PACIENTE",
    pag.ate_id "ID ATENCION",
    to_char(pag.fecha_venc_pago,'DD/MM/YYYY')"FECHA VENCIMIENTO PAGO",
    to_char(pag.fecha_pago,'DD/MM/YYYY')"FECHA PAGO",
    pag.fecha_pago - pag.fecha_venc_pago "DIAS MOROSIDAD",
    to_char((pag.fecha_pago - pag.fecha_venc_pago)*2000,'$999g999g999')"VALOR MULTA"
FROM paciente p
join atencion a on p.pac_run = a.pac_run
join pago_atencion pag on pag.ate_id = a.ate_id
where (pag.fecha_pago - pag.fecha_venc_pago) > (SELECT round(avg(sum(pa.fecha_pago - pa.fecha_venc_pago))) FROM pago_atencion pa
                group by to_char(pa.fecha_pago,'YYYY/MM'))
order by pag.fecha_venc_pago,6 desc;

-- Caso 5:
-- Sub consulta:
SELECT 
    m.med_run
FROM atencion a
join medico m on m.med_run = a.med_run
where extract(year from a.fecha_atencion) = extract(year from sysdate)
group by m.med_run
having count(*) > 7;

-- Consulta principal:
Variable Ganancias int;
exec :Ganancias := :&Ingrese_ganancias;
SELECT 
    to_char(me.med_run,'00g000g000')||'-'||me.dv_run "RUT MEDICO",
    me.pnombre||' '||me.snombre||' '||me.apaterno||' '||me.amaterno"NOMBRE MEDICO",
    count(*)"TOTAL ATENCIONES MEDICAS",
    to_char(me.sueldo_base,'$999g999g999')"SUELDO BASE",
    lpad(to_char(
        (:Ganancias * 0.05)/
        (
            Select count(*) 
            from (
                SELECT m.med_run FROM atencion a 
                        join medico m on m.med_run = a.med_run
                        where extract(year from a.fecha_atencion) = extract(year from sysdate)
                        group by m.med_run having count(*) > 7)
        )
    ,'$999g999g999'),25)"BONIFICACION POR GANANCIAS",
    to_char(
        me.sueldo_base +
        ((:Ganancias * 0.05)/
        (
            Select count(*) 
            from (
                SELECT m.med_run FROM atencion a 
                        join medico m on m.med_run = a.med_run
                        where extract(year from a.fecha_atencion) = extract(year from sysdate)
                        group by m.med_run having count(*) > 7)
        ))
    ,'$999g999g999')"SUELDO TOTAL"
FROM medico me
join atencion ate on me.med_run = ate.med_run
where extract(year from ate.fecha_atencion) = extract(year from sysdate) and
    me.med_run =any (SELECT m.med_run FROM atencion a 
                        join medico m on m.med_run = a.med_run
                        where extract(year from a.fecha_atencion) = extract(year from sysdate)
                        group by m.med_run having count(*) > 7)
group by me.med_run,me.dv_run,me.pnombre,me.snombre,me.apaterno,me.amaterno,me.sueldo_base
order by me.med_run,me.apaterno;
