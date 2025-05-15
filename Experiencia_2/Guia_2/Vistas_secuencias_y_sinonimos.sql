-- Vistas, sequencias y sinónimos:
-- Vistas:
-- Original:
create view V_DIRE_CLIENTE as
SELECT 
    c.numrun||'-'||c.dvrun "RUT",
    c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno "NOMBRE_CLIENTE",
    c.direccion "DIRECCION"
FROM cliente c
order by 2;

-- Crear o remplazar: Para que si ya existe esa vista, se reemplaze por el contenido de la consulta.
create or REPLACE view V_DIRE_CLIENTE as
SELECT 
    c.numrun||'-'||c.dvrun "RUT_CLIENTE",
    c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno "NOMBRE_CLIENTE",
    c.direccion "DIRECCION",
    po.nombre_prof_ofic "PROFESION"
FROM cliente c
join profesion_oficio po on po.cod_prof_ofic = c.cod_prof_ofic
order by 2
with read ONLY;-- Hace que la vista solo se pueda revisar, y que no se pueda modificar.

-- Revisar la vista:
SELECT 
    nombre_cliente,
    direccion
FROM v_dire_cliente;

-- Eliminar vista:
drop view V_DIRE_CLIENTE;

SAVEPOINT A1;
-- Si se DML en la vista, tambien se cambiaran en la tabla original:
INSERT into v_dire_cliente VALUES('11111111-1','Pepito Jara','Su casa','Analista programador'); -- No funciona.
update v_dire_cliente set direccion = 'DUOC UC Puente Alto'
where rut_cliente = '8333032-5';
rollback to a1;

-- Secuencias: Se puede usar en cualquier parte.
-- Eliminar:
drop SEQUENCE seq_producto;
-- Crear:
create SEQUENCE seq_producto
    START with 1 -- En que número empieza a contar.
    INCREMENT by 1 -- Por cuanto se incrementa.
    MINVALUE 1 -- Valor mínimo.
    MAXVALUE 100; -- Valor máximo.
--  NOCACHE; -- hace se borre los datos de de la sequencia, si se cierra el servidor.

drop table producto;
create table producto(
    codigo integer primary key,
    nombre varchar2(50) unique not null
);

insert into producto VALUES(seq_producto.nextval,'switch'); -- Al poner seq_producto.nextval, ponen el proximo número de la secuencia.
insert into producto VALUES(seq_producto.nextval,'PC');
insert into producto VALUES(seq_producto.nextval,'Polera');
insert into producto VALUES(seq_producto.nextval,'Bebida');
insert into producto VALUES(seq_producto.nextval,'Clavo');
insert into producto VALUES(seq_producto.nextval,'Pegamemento');

-- Columna auto-incrementable: Se puede usar solo en la tabla.
create table marca(
    codigo integer GENERATED always as IDENTITY
                    start with 10 
                    increment by 10 
                    PRIMARY key,
    nombre varchar2(50) unique not null
);
insert into marca(nombre) values('Nike');
insert into marca(nombre) values('Adidas');
insert into marca(nombre) values('Sony');
insert into marca(nombre) values('Acuenta');
insert into marca(nombre) values('Samsung');

-- Sinónimos: Cambiar nombre de acceso a las tablas.
create synonym zona for KOPERA.region; -- Crea el sinónimo.
SELECT * FROM zona; -- Consulta con el sinónimo.

-- Públicos: Lo puede ver cualquier usuario dentro del entorno.
create public SYNONYM establecimiento for KOPERA.sucursal;
SELECT * FROM establecimiento;

-- Privados: Solo los que tienen los permisos necesarios.