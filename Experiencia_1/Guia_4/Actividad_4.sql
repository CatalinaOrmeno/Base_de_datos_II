-- Caso 1:
SELECT 
    to_char(c.numrun,'00g000g000')||'-'||c.dvrun "RUN CLIENTE",
    initcap(c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno)"NOMBRE CLIENTE",
    to_char(c.fecha_nacimiento,'dd "de" Month')"DIA DE CUMPLEAÑOS",
    sr.direccion||'/'||Upper(r.nombre_region) "Dirección Sucursal/REGION SUCURSAL"
FROM cliente c
join sucursal_retail sr on sr.cod_region = c.cod_region and sr.cod_provincia = c.cod_provincia and sr.cod_comuna = c.cod_comuna
join region r on r.cod_region = c.cod_region
where extract(month from c.fecha_nacimiento) = extract(month from sysdate)+5
and r.cod_region = &Ingrese_region
order by 3,c.appaterno;

-- Caso 2:
SELECT 
    to_char(c.numrun,'00g000g000')||'-'||upper(c.dvrun) "RUN CLIENTE",
    c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno"NOMBRE CLIENTE",
    lpad(to_char(sum(ttc.monto_transaccion),'$999g999g999'),30) "MONTO COMPRAS/AVANCES/S.AVANCES",
    lpad(to_char((sum(ttc.monto_transaccion)/10000)*250,'999g999'),24)"TOTAL PUNTOS ACUMULADOS"
FROM cliente c
join tarjeta_cliente tc on tc.numrun = c.numrun
join transaccion_tarjeta_cliente ttc on ttc.nro_tarjeta = tc.nro_tarjeta
where extract(year from ttc.fecha_transaccion) = extract(year from sysdate)-1
group by c.numrun,c.dvrun,c.pnombre,c.snombre,c.appaterno,c.apmaterno
order by 4,c.appaterno;

-- Caso 3:
SELECT 
    to_char(ttc.fecha_transaccion,'MMYYYY')"MES TRANSACCIÖN",
    titt.nombre_tptran_tarjeta "TIPO TRANSACCIÖN",
    to_char(sum(ttc.monto_total_transaccion),'$999g999g999') "MONTO AVANSES/S.AVANCES",
    to_char(sum((ttc.monto_total_transaccion)*(ab.porc_aporte_sbif/100)),'$999g999') "APORTE A LA SBIF"
FROM tipo_transaccion_tarjeta titt
join transaccion_tarjeta_cliente ttc on ttc.cod_tptran_tarjeta = titt.cod_tptran_tarjeta
join aporte_sbif ab on ttc.monto_total_transaccion between ab.monto_inf_av_sav and ab.monto_sup_av_sav
where extract(year from ttc.fecha_transaccion) = extract(year from sysdate)and ttc.cod_tptran_tarjeta != 101
group by to_char(ttc.fecha_transaccion,'MMYYYY'),titt.nombre_tptran_tarjeta
order by 1,2;

-- Caso 4:
SELECT 
    to_char(c.numrun,'00g000g000')||'-'||upper(c.dvrun) "RUN CLIENTE",
    c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno"NOMBRE CLIENTE",
    lpad(to_char(NVL(sum(ttc.monto_total_transaccion),0),'$999g999g999'),23)"COMPRAS/AVANCES/S.AVANCES",
    case
        when NVL(sum(ttc.monto_total_transaccion),0) between 0 and 100000 then 'SIN CATEGORIZACION'
        when NVL(sum(ttc.monto_total_transaccion),0) between 100001 and 1000000 then 'BRONCE'
        when NVL(sum(ttc.monto_total_transaccion),0) between 1000001 and 4000000 then 'PLATA'
        when NVL(sum(ttc.monto_total_transaccion),0) between 4000001 and 8000000 then 'SILVER'
        when NVL(sum(ttc.monto_total_transaccion),0) between 8000001 and 15000000 then 'GOLD'
        when NVL(sum(ttc.monto_total_transaccion),0) > 15000000 then 'PLATINUM'
        else 'NO VALIDO'
    end "CATEGORIZACION CLIENTE"
FROM cliente c
left join tarjeta_cliente tc on tc.numrun = c.numrun
left join transaccion_tarjeta_cliente ttc on ttc.nro_tarjeta = tc.nro_tarjeta
group by c.numrun,c.dvrun,c.pnombre,c.snombre,c.appaterno,c.apmaterno
order by c.appaterno,3 desc;

-- Caso 5:
-- Caso 6: