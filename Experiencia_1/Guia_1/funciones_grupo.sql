/* Funciones de grupo y agrupaci�n
No entran los valores nulos!*/
SELECT
    COUNT(*) "Contar",
    '$'||sum(sueldo_base) "Suma",
    round(avg(sueldo_base)) "Promedio",
    max(sueldo_base) "M�ximo",
    min(sueldo_base) "M�nimo"
FROM empleado;

-- group by -> Agrupar las consultas a partir de un atributo.
SELECT
    sexo "G�nero",
    COUNT(*) "Cantidad",
    round(avg(sueldo_base)) "Promedio salarial",
    max(sueldo_base) "Sueldo m�ximo",
    min(sueldo_base) "Sueldo m�nimo"
FROM empleado
group by sexo;

-- Cantidad de arriendos por camion:
SELECT
    nro_patente "Cami�n",
    COUNT(*) "Cantidad arriendos"
FROM arriendo_camion
group by nro_patente
order by 2 desc;

-- Cantidad de clientes que existen segun cada tipo:
SELECT
    id_tipo_cli "Tipo cliente",
    COUNT(*) "Cantidad de clientes"
FROM cliente
group by id_tipo_cli
order by 1;