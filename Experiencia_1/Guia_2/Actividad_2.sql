--Caso 1:
SELECT
    carreraid "IDENTIFICACIÓN DE LA CARRERA",
    COUNT(*) "TOTAL ALUMNOS MATRICULADOS",
    'Le corresponden '||
    to_char(COUNT(*)*&Ingrese_valor,'$999g999g999')||
    ' del presupuesto total asignado para publicidad' "MONTO POR PUBLICIDAD"
FROM alumno
group by carreraid
ORDER BY 2 desc,1;

--Caso 2:
SELECT
    carreraid "CARRERA",
    COUNT(*) "TOTAL DE ALUMNOS"
FROM alumno
group by carreraid
having COUNT(*)>4
order by 1;

--Caso 3:
SELECT
    to_char(run_jefe,'00g000g000') "RUN JEFE SIN DV",
    COUNT(*) "TOTAL DE EMPLEDOS A SU CARGO",
    to_char(max(salario),'999g999g999') "SALARIO MAXIMO",
    lpad(COUNT(*)*10||'% del Salario Máximo',25) "PORCENTAJE DE BONIFICACION",
    to_char((COUNT(*)/10)*max(salario),'$999g999g999') "BONIFICACION"
FROM empleado
where run_jefe is not null
group by run_jefe
order by 2;

--Caso 4:
SELECT
    es.id_escolaridad "ESCOLARIDAD",
    es.desc_escolaridad "DESCRIPCIÓN ESCOLARIDAD",
    COUNT(*)"TOTAL DE EMPLEADOS",
    rpad(to_char(max(emp.salario),'$999g999g999'),16) "SALARIO MAXIMO",
    rpad(to_char(min(emp.salario),'$999g999g999'),16) "SALARIO MINIMO",
    rpad(to_char(sum(emp.salario),'$999g999g999'),16) "SALARIO TOTAL",
    rpad(to_char(avg(emp.salario),'$999g999g999'),16) "SALARIO PROMEDIO"
FROM empleado emp join escolaridad_emp es on emp.id_escolaridad = es.id_escolaridad
group by es.id_escolaridad,es.desc_escolaridad
order by 3 desc;

--Caso 5:
SELECT
    tituloid "CODIGO DEL LIBRO",
    COUNT(*) "TOTAL DE VECES SOLICITADO",
    case
        when COUNT(*)=1 then
            'No se requiere comprar nuevos ejemplares'
        when COUNT(*)=2 or COUNT(*)=3 then
            'Se requiere comprar 1 nuevo ejemplar'
        when COUNT(*)=4 or COUNT(*)=5 then
            'Se requiere comprar 2 nuevos ejemplares'
        else
            'Se requiere comprar 4 nuevos ejemplares'
    end "SUGERENCIA"
FROM prestamo
where EXTRACT(year from fecha_ini_prestamo) = EXTRACT(YEAR FROM SYSDATE)-1
group by tituloid
order by 2 desc;

--Caso 6: