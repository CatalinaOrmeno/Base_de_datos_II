alter session set "_oracle_script" = true;
-- DCL: Data Control Languaje

-- Usuario admin dueño de la base de datos:
create user admin22 identified by "Duocadmin25"
default tablespace users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED on users; 

-- Usuarios técnicos que utilizaran la base de datos:
create user tec22_1 identified by "Duocadmin25"
default tablespace users
TEMPORARY TABLESPACE temp
QUOTA 100m on users; 

create user tec22_2 identified by "Duocadmin25"
default tablespace users
TEMPORARY TABLESPACE temp
QUOTA 100m on users; 

-- Privilegios:
-- Admin:
grant create session, create table, create sequence, create SYNONYM to admin22;

-- Técnicos:
grant create session, create table, create sequence, create view to tec22_1, tec22_2;

-- Privilegios sobre objetos de otros usuarios:
grant select on admin22.cliente to tec22_1 with grant option;
grant select on admin22.producto_inversion_cliente to tec22_1 with grant option;
grant select on admin22.producto_inversion to tec22_1 with grant option;