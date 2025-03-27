-- Join simple:

-- Join con on: podemos declarar la clave primaria y foranea que une ambas tablas:
SELECT
    r.nombre_region,
    p.nombre_provincia
FROM region r
join provincia p on r.cod_region = p.cod_region;

-- Join using: nosotros declaramos solo 1 atributo que use ambas tablas. 
-- Requerimiento: Los atributos se deben llamar igual.
SELECT
    r.nombre_region,
    p.nombre_provincia
FROM region r
join provincia p using(cod_region);

-- Natural join: Las tablas se unen por todos los atributos  que se llaman igual.
SELECT
    r.nombre_region,
    p.nombre_provincia
FROM region r
natural join provincia p;