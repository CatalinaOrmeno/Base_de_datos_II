/*Indices:
Es un objeto de base de datos que permite agregar velocidad
a la respuesta de una consulta*/
SELECT 
    to_char(c.numrun,'00g000g000')||'-'||c.dvrun RUT,
    c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno NOMBRE,
    po.nombre_prof_ofic PROFESION_OFICIO
FROM cliente c
    join profesion_oficio po on po.cod_prof_ofic = c.cod_prof_ofic
where po.nombre_prof_ofic in('Abogado','Vendedor','Administrador')
order by po.nombre_prof_ofic;

create index idx_nombre_pro on profesion_oficio(nombre_prof_ofic);