--Caso 1:
SELECT
    numrun_cli||'-'||dvrun_cli "RUN cliente",
    Lower(pnombre_cli||' '||snombre_cli)||' '||appaterno_cli||' '||apmaterno_cli "Nombre completo",
    to_char(fecha_nac_cli,'DD/MM/YYYY') "Fecha de nacimiento"
FROM cliente
where EXTRACT(day from fecha_nac_cli)=EXTRACT(day from SYSDATE+1) and 
    EXTRACT(month from fecha_nac_cli)=EXTRACT(month from SYSDATE+1)
ORDER BY appaterno_cli;

--Caso 2:
SELECT
    numrun_emp||' '||dvrun_emp "RUN EMPLEADO",
    pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp "NOMBRE COMPLETO EMLEADO",
    sueldo_base "SUELDO BASE",
    trunc(sueldo_base/100000) "PORCENTAJE MOVILIZACI�N",
    round(trunc(sueldo_base/100000)/100 * sueldo_base) "VALOR MOVILIZACI�N"
FROM empleado
order by 4 desc;

--Caso 3:
SELECT
    numrun_emp||' '||dvrun_emp "RUN EMPLEADO",
    pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp "NOMBRE COMPLETO EMLEADO",
    sueldo_base "SUELDO BASE",
    to_char(fecha_nac,'DD/MM/YYYY') "FECHA NACIMIENTO",
    SUBSTR(pnombre_emp,1,3)||length(pnombre_emp)||'*'||substr(sueldo_base,-1)||dvrun_emp||round(months_between(sysdate,fecha_contrato)/12) "NOMBRE USUARIO",
    SUBSTR(numrun_emp,3,1)||EXTRACT(year from fecha_contrato)+2||substr(sueldo_base,-3)-1||substr(appaterno_emp,-2)||extract(month from sysdate) "CLAVE"
FROM empleado
order by appaterno_emp;

--Caso 4:

--Caso 5:

--Caso 6:

--Caso 7:
SELECT 
    e.numrun_emp||'-'||e.dvrun_emp "RUN EMPLEADO",
    pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp "NOMBRE COMPLETO EMLEADO",
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