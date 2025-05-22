-- Creación de sinonimos para utilizar tablas:
create synonym persona for admin23.cliente;
create synonym pega for admin23.profesion_oficio;

-- Vista para entregar a los consultores:
create or replace view v_pega_persona as
SELECT 
    to_char(p.numrun,'00g000g000')||'-'||p.dvrun RUN_PERSONA,
    initcap(p.pnombre||' '||p.snombre||' '||p.appaterno||' '||p.apmaterno) NOMBRE_PERSONA,
    p.direccion DIRECCION_PERSONA,
    pe.nombre_prof_ofic TRABAJO_PERSONA
FROM persona p
join pega pe on pe.cod_prof_ofic = p.cod_prof_ofic
order by 2;