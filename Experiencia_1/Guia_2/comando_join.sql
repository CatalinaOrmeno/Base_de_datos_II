SELECT
    a.alumnoid "ID ALUMNO",
    a.nombre||' '||a.apaterno||' '||a.amaterno "NOMBRE COMPLETO",
    a.genero "GENERO",
    a.fecha_nacimiento "FECHA NACIMIENTO",
    c.descripcion "CARRERA",
    es.descripcion "ESCUELA"
FROM alumno a 
    join carrera c on a.carreraid = c.carreraid
    join escuela es on c.escuelaid = es.escuelaid
order by es.descripcion,c.descripcion;