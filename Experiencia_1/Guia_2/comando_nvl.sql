SELECT
    salario,
    case
        when salario between 0 and 500000 then 'Sueldo bajo'
        when salario between 500001 and 1100000 then 'Sueldo medio'
        when salario > 1100001 then 'Sueldo alto'
        else 'Sueldo no valido'
    end "RANGOS SUELDOS"
FROM empleado
order by 1 desc;

SELECT
    case 2
        when 1 then 'uno'
        when 2 then 'dos'
        when 3 then 'tres'
        else 'otro valor'
    end "CASE"
FROM dual;

SELECT
    alumnoid "ALUMNO",
    lpad(nvl(to_char(multa,'$9g999'),'No tiene multa'),15) "MULTA",
    nvl2(multa,'Tiene multa','No tiene multa')"MOSTRAR SI ES O NO NULL"
FROM prestamo;

SELECT
    count(multa)
FROM prestamo;

SELECT
    count(nvl(multa,0))
FROM prestamo;