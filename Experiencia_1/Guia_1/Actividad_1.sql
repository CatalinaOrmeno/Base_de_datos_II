--Caso 1:
SELECT
    numrun_cli||'-'||dvrun_cli "RUN cliente",
    Lower(pnombre_cli||' '||snombre_cli)||' '||appaterno_cli||' '||apmaterno_cli "NOMBRE COMPLETO CLIENTE",
    to_char(fecha_nac_cli,'DD/MM/YYYY') "FECHA NACIMIENTO"
FROM cliente
where EXTRACT(day from fecha_nac_cli)=EXTRACT(day from SYSDATE+1) and 
    EXTRACT(month from fecha_nac_cli)=EXTRACT(month from SYSDATE+1)
ORDER BY appaterno_cli;

--Caso 2:
SELECT
    numrun_emp||' '||dvrun_emp "RUN EMPLEADO",
    pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp "NOMBRE COMPLETO EMPLEADO",
    sueldo_base "SUELDO BASE",
    trunc(sueldo_base/100000) "PORCENTAJE MOVILIZACI�N",
    round(trunc(sueldo_base/100000)/100 * sueldo_base) "VALOR MOVILIZACI�N"
FROM empleado
order by 4 desc;

--Caso 3:
SELECT
    numrun_emp||' '||dvrun_emp "RUN EMPLEADO",
    pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp "NOMBRE COMPLETO EMPLEADO",
    sueldo_base "SUELDO BASE",
    to_char(fecha_nac,'DD/MM/YYYY') "FECHA NACIMIENTO",
    SUBSTR(pnombre_emp,1,3)||length(pnombre_emp)||'*'||substr(sueldo_base,-1)||dvrun_emp||round(months_between(sysdate,fecha_contrato)/12) "NOMBRE USUARIO",
    SUBSTR(numrun_emp,3,1)||EXTRACT(year from fecha_contrato)+2||substr(sueldo_base,-3)-1||substr(appaterno_emp,-2)||extract(month from sysdate) "CLAVE"
FROM empleado
order by appaterno_emp;

--Caso 4:
drop table HIST_REBAJA_ARRIENDO;
create table HIST_REBAJA_ARRIENDO as
SELECT
    EXTRACT(year from SYSDATE)"ANNO_PROCESO",
    nro_patente "NRO_PATENTE",
    valor_arriendo_dia "VALOR_ARRIENDO_DIA_SR",
    valor_garantia_dia "VALOR_GARANTIA_DIA_SR",
    EXTRACT(year from sysdate)-anio "ANNOS_ANTIGUEDAD",
    valor_arriendo_dia-(valor_arriendo_dia * (EXTRACT(year from sysdate)-anio)/100) "VALOR_ARRIENDO_DIA_CR",
    valor_garantia_dia-(valor_garantia_dia * (EXTRACT(year from sysdate)-anio)/100) "VALOR_GARANTIA_DIA_CR"
FROM camion
where EXTRACT(year from sysdate)-anio > 5
order by 5 desc,nro_patente;
--Caso 5:
SELECT 
    to_char(sysdate,'MM/YYYY') "MES_ANNO_PROCESO",
    nro_patente,
    to_char(fecha_ini_arriendo,'DD/MM/YYYY')"FECHA_INI_ARRIENDO",
    dias_solicitados,
    to_char(fecha_devolucion,'DD/MM/YYYY')"FECHA_DEVOLUCION",
    trunc(months_between(sysdate,fecha_devolucion)/12*365) "DIAS_ATRASO",
    trunc(months_between(sysdate,fecha_devolucion)/12*365)*&Ingrese_valor_multa "VALOR_MULTA"
FROM arriendo_camion
where trunc(months_between(sysdate,fecha_devolucion)/12*365) > 0
order by fecha_ini_arriendo asc, nro_patente asc;
--Caso 6:
VARIABLE Utilidades int;
EXEC :Utilidades := &Ingrese_utilidades;
SELECT 
    to_char(sysdate,'MM/YYYY') "FECHA PROCESO",
    numrun_emp||'-'||dvrun_emp "RUN EMPLEADO",
    pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp "NOMBRE EMPLEADO",
    lpad('$'||sueldo_base,12) "SUELDO BASE",
    case
        when sueldo_base >= 320000 and sueldo_base <= 450000 then
            :Utilidades * (0.5/100)
        when sueldo_base >= 450001 and sueldo_base <= 600000 then
            :Utilidades * (0.35/100)
        when sueldo_base >= 600001 and sueldo_base <= 900000 then
            :Utilidades * (0.25/100)
        when sueldo_base >= 900001 and sueldo_base <= 1800000 then
            :Utilidades * (0.15/100)
        else
            :Utilidades * (0.1/100)
    end "BONIFICACION POR UTILIDADES"
FROM empleado
order by appaterno_emp;

--Caso 7:
SELECT 
    e.numrun_emp||'-'||e.dvrun_emp "RUN EMPLEADO",
    pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp "NOMBRE COMPLETO EMPLEADO",
    round(months_between(sysdate,e.fecha_contrato)/12) "AÑOS CONTRATADO",
    lpad('$'||sueldo_base,12) "SUELDO BASE",
    lpad('$'||round(trunc(sueldo_base/100000)/100 * sueldo_base),18) "VALOR MOVILIZACI�N",
    lpad('$'||
    case 
        when e.sueldo_base >=450000 then
        round(e.sueldo_base*(substr(e.sueldo_base,1,1)/100))
        else
        round(e.sueldo_base*(substr(e.sueldo_base,1,2)/100))
    end,23) "BONIF.EXTRA MOVILIZACION",
    lpad('$'||(round(trunc(sueldo_base/100000)/100 * sueldo_base) + 
    case 
        when e.sueldo_base >=450000 then
        round(e.sueldo_base*(substr(e.sueldo_base,1,1)/100))
        else
        round(e.sueldo_base*(substr(e.sueldo_base,1,2)/100))
    end),23) "VALOR MOVILIZACION TOTAL"
FROM empleado e join comuna c on e.id_comuna = c.id_comuna
where c.nombre_comuna in ('Mar�a Pinto','Curacav�','El Monte','Paine','Pirque')
order by e.appaterno_emp;