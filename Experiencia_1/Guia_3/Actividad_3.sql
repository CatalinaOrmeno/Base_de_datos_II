-- Caso 1:
SELECT
    to_char(c.numrun,'00g000g000')||'-'||c.dvrun "RUN CLIENTE",
    INITCAP(c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno)"NOMBRE CLIENTE",
    po.nombre_prof_ofic "PROFESION/OFICIO",
    to_char(c.fecha_nacimiento,'DD "de" Month') "DIA CUMPLEAÑOS"
FROM cliente c
join profesion_oficio po on c.cod_prof_ofic = po.cod_prof_ofic
where extract(month from c.fecha_nacimiento)=extract(month from sysdate)+1
order by 4, c.appaterno;

-- Caso 2:
SELECT
    to_char(c.numrun,'00g000g000')||'-'||c.dvrun "RUN CLIENTE",
    c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno"NOMBRE CLIENTE",
    to_char(sum(crc.monto_solicitado),'$99g999g999')"MONTO SOLICITADO CREDITOS",
    to_char((sum(crc.monto_solicitado)/100000)*1200,'$999g999')"TOTAL PESOS TODOSUMA"
FROM cliente c
join credito_cliente crc on crc.nro_cliente = c.nro_cliente
where extract(year from crc.fecha_solic_cred) = extract(year from sysdate)-1
GROUP by c.numrun,c.dvrun,c.pnombre,c.snombre,c.appaterno,c.apmaterno
order by 4,c.appaterno;

-- Caso 3:
SELECT
    to_char(crc.fecha_solic_cred,'MMYYYY') "MES TRANSACCIÓN",
    upper(ce.nombre_credito) "TIPO CREDITO",
    sum(crc.monto_credito)"MONTO SOLICITADO CREDITOS",
    case
        when sum(crc.monto_credito) between 100000 and 1000000 then
            sum(crc.monto_credito)*0.01
        when sum(crc.monto_credito) between 1000001 and 2000000 then
            sum(crc.monto_credito)*0.02
        when sum(crc.monto_credito) between 2000001 and 4000000 then
            sum(crc.monto_credito)*0.03
        when sum(crc.monto_credito) between 4000001 and 6000000 then
            sum(crc.monto_credito)*0.04
        when sum(crc.monto_credito) > 6000000 then
            sum(crc.monto_credito)*0.07
        else 'MENOR A 100000'
    end "APORTE A LA SBIF"
FROM credito_cliente crc
join credito ce on crc.cod_credito = ce.cod_credito
where extract(year from crc.fecha_solic_cred) = extract(year from sysdate)-1
group by to_char(crc.fecha_solic_cred,'MMYYYY'),ce.nombre_credito,ce.tasa_interes_anual
order by 1,2;

-- Caso 4:
SELECT
    to_char(c.numrun,'00g000g000')||'-'||c.dvrun "RUN CLIENTE",
    c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno"NOMBRE CLIENTE",
    to_char(pic.monto_total_ahorrado,'$999g999g999') "MONTO TOTAL AHORRADO",
    case
        when pic.monto_total_ahorrado between 100000 and 1000000 then
            'BRONZE'
        when pic.monto_total_ahorrado between 1000001 and 4000000 then
            'PLATA'
        when pic.monto_total_ahorrado between 4000001 and 8000000 then
            'SILVER'
        when pic.monto_total_ahorrado between 8000001 and 15000000 then
            'GOLD'
        when pic.monto_total_ahorrado > 15000000 then
            'PLATINUM'
    end "CATEGORIA CLIENTE"
FROM producto_inversion_cliente pic
join cliente c on pic.nro_cliente = c.nro_cliente
--where pic.monto_total_ahorrado >99999
order by c.appaterno,3 desc;