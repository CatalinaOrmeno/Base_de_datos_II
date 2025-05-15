--Caso 1:
create or replace view V_CASO1 as
SELECT 
    to_char(c.numrun,'00g000g000')||'-'||c.dvrun RUN_CLIENTE,
    c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno NOMBRE_CLIENTE,
    po.nombre_prof_ofic PROFESION_OFICIO,
    tc.nombre_tipo_contrato TIPO_CONTRATO,
    lpad(to_char(sum(pic.monto_total_ahorrado + pic.ahorro_minimo_mensual),'$999g999g999'),21) MONTO_TOTAL_AHORRADO,
    case
        when sum(pic.monto_total_ahorrado + pic.ahorro_minimo_mensual) between 100000 and 1000000 then
            'BRONCE'
        when sum(pic.monto_total_ahorrado + pic.ahorro_minimo_mensual) between 1000001 and 4000000 then
            'PLATA'
        when sum(pic.monto_total_ahorrado + pic.ahorro_minimo_mensual) between 4000001 and 8000000 then
            'SILVER'
        when sum(pic.monto_total_ahorrado + pic.ahorro_minimo_mensual) between 8000001 and 15000000 then
            'GOLD'
        when sum(pic.monto_total_ahorrado + pic.ahorro_minimo_mensual) > 15000000 then
            'PLATINUM'
        else 'CARTÓN'
    end CATEGORIA_CLIENTE
FROM cliente c
join profesion_oficio po on po.cod_prof_ofic = c.cod_prof_ofic
join tipo_contrato tc on tc.cod_tipo_contrato = c.cod_tipo_contrato
join producto_inversion_cliente pic on pic.nro_cliente = c.nro_cliente
group by c.numrun,c.dvrun,c.pnombre,c.snombre,c.appaterno,c.apmaterno,po.nombre_prof_ofic,tc.nombre_tipo_contrato
order by c.appaterno,5 desc;

-- Caso 2:
create table BDY1102_P7_2 as
SELECT 
    to_char(crc.fecha_solic_cred,'MMYYYY') MES_TRANSACCIÓN,
    c.nombre_credito TIPO_CREDITO,
    sum(crc.monto_credito) MONTO_SOLICITADO_CREDITO,
    sum(crc.monto_credito*(aas.porc_entrega_sbif/100)) APORTE_A_LA_SBIF
FROM credito c
left join credito_cliente crc on crc.cod_credito = c.cod_credito
    and extract(year from crc.fecha_solic_cred) = extract(year from sysdate)-1
join aporte_a_sbif aas on crc.monto_credito between aas.monto_credito_desde and aas.monto_credito_hasta 
group by to_char(crc.fecha_solic_cred,'MMYYYY'),c.nombre_credito
order by 1,2;
create SYNONYM Caso2 for KOPERA.BDY1102_P7_2;

SELECT * FROM caso2;

-- Caso 3:
create SEQUENCE seq_caso3_numrut
    start with 10
    increment by 2
    NOCACHE;
create SEQUENCE seq_caso3_dvrut
    start with 1
    increment by 3
    NOCACHE;

update 
SELECT 
    to_char(seq_caso3_numrut.nextval)||' '||to_char(c.numrun,'00g000g000')||'-'||to_char(seq_caso3_dvrut.nextval)||c.dvrun RUN_CLIENTE,
    count(*) TOTAL_PROD_INV_AFECTOS_OMPTO,
    sum(pic.monto_total_ahorrado+pic.ahorro_minimo_mensual) MONTO_TOTAL_AHORRADO
FROM cliente c
join producto_inversion_cliente pic on pic.nro_cliente = c.nro_cliente
    and pic.cod_prod_inv in (30,35,40,45,50,55)
group by extract(year from sysdate),c.numrun,c.dvrun,c.pnombre,c.snombre,c.appaterno,c.apmaterno;
--order by c.appaterno;

create table caso_3 as
SELECT 
   extract(year from sysdate) ANNO_TRIBUTARIO,
   to_char(c.numrun,'00g000g000')||'-'||c.dvrun RUN_CLIENTE,
   initcap(c.pnombre||' '||substr(c.snombre,1,1)||'. '||c.appaterno||' '||c.apmaterno) NOMBRE_CLIENTE,
   count(*) TOTAL_PROD_INV_AFECTOS_OMPTO,
   sum(pic.monto_total_ahorrado+pic.ahorro_minimo_mensual) MONTO_TOTAL_AHORRADO
FROM cliente c
join producto_inversion_cliente pic on pic.nro_cliente = c.nro_cliente
    and pic.cod_prod_inv in (30,35,40,45,50,55)
group by extract(year from sysdate),c.numrun,c.dvrun,c.pnombre,c.snombre,c.appaterno,c.apmaterno
order by c.appaterno;
