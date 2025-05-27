alter session set "_oracle_script"=true;

-- 1.- Crear usuarios:
-- Usuario dueño de las tablas:
create user MDY2131_P13_1 IDENTIFIED by "Duocadmin24."
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED on users;

-- Desarrolladores:
-- Desarrollador 1:
create user MDY2131_P13_2 IDENTIFIED by "Duocadmin24."
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED on users;
-- Desarrollador 2:
create user MDY2131_P13_3 IDENTIFIED by "Duocadmin24."
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED on users;

-- Consultores:
-- Consultor 1:
create user MDY2131_P13_4 IDENTIFIED by "Duocadmin24."
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 100m on users;
-- Consultor 2:
create user MDY2131_P13_5 IDENTIFIED by "Duocadmin24."
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 100m on users;
-- Consultor 3:
create user MDY2131_P13_6 IDENTIFIED by "Duocadmin24."
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 100m on users;

-- 2.-Otorgar privilegios:
-- Usuario dueño de las tablas:
grant create session,
      create table,
      create sequence,
      create ANY INDEX,
      create SYNONYM 
to MDY2131_P13_1;

-- Desarrolladores:
create role rol_desarrollador;
grant create session,
      create PROCEDURE,
      create TRIGGER,
      create view,
      create MATERIALIZED view
to rol_desarrollador;

grant rol_desarrollador to MDY2131_P13_2,MDY2131_P13_3;

alter user MDY2131_P13_2 default role rol_desarrollador;
alter user MDY2131_P13_3 default role rol_desarrollador;

-- Consultores:
create role rol_generico;
grant create session to rol_generico;

grant rol_generico to MDY2131_P13_4, MDY2131_P13_5,MDY2131_P13_6;

alter user MDY2131_P13_4 default role rol_generico;
alter user MDY2131_P13_5 default role rol_generico;
alter user MDY2131_P13_6 default role rol_generico;

-- 3.-Acceso a objetos de otros usuarios:
-- Desarrolladores:
grant select on MDY2131_P13_1.APORTE_A_SBIF to MDY2131_P13_2,MDY2131_P13_3;
grant select on MDY2131_P13_1.CLIENTE to MDY2131_P13_2,MDY2131_P13_3;
grant select on MDY2131_P13_1.COMUNA to MDY2131_P13_2,MDY2131_P13_3;
grant select on MDY2131_P13_1.CREDITO to MDY2131_P13_2,MDY2131_P13_3;
grant select, update, insert, delete on MDY2131_P13_1.CREDITO_CLIENTE to MDY2131_P13_2,MDY2131_P13_3;
grant select, update, insert, delete on MDY2131_P13_1.CUOTA_CREDITO_CLIENTE to MDY2131_P13_2,MDY2131_P13_3;
grant select on MDY2131_P13_1.FORMA_PAGO to MDY2131_P13_2,MDY2131_P13_3;
grant select on MDY2131_P13_1.MOVIMIENTO to MDY2131_P13_2,MDY2131_P13_3;
grant select on MDY2131_P13_1.PRODUCTO_INVERSION to MDY2131_P13_2,MDY2131_P13_3;
grant select, update, insert, delete on MDY2131_P13_1.PRODUCTO_INVERSION_CLIENTE to MDY2131_P13_2,MDY2131_P13_3;
grant select on MDY2131_P13_1.PROFESION_OFICIO to MDY2131_P13_2,MDY2131_P13_3;
grant select on MDY2131_P13_1.PROVINCIA to MDY2131_P13_2,MDY2131_P13_3;
grant select on MDY2131_P13_1.REGION to MDY2131_P13_2,MDY2131_P13_3;
grant select on MDY2131_P13_1.SUCURSAL to MDY2131_P13_2,MDY2131_P13_3;
grant select on MDY2131_P13_1.TIPO_CONTRATO to MDY2131_P13_2,MDY2131_P13_3;
grant select on MDY2131_P13_1.TIPO_MOVIMIENTO to MDY2131_P13_2,MDY2131_P13_3;

-- Consultores:
grant select on MDY2131_P13_1.CLIENTE to MDY2131_P13_4,MDY2131_P13_5,MDY2131_P13_6;
grant select on MDY2131_P13_1.REGION to MDY2131_P13_4,MDY2131_P13_5,MDY2131_P13_6;
grant select on MDY2131_P13_1.PROVINCIA to MDY2131_P13_4,MDY2131_P13_5,MDY2131_P13_6;
grant select on MDY2131_P13_1.COMUNA to MDY2131_P13_4,MDY2131_P13_5,MDY2131_P13_6;
-- Consultor 1:
grant select on MDY2131_P13_1.TIPO_MOVIMIENTO to MDY2131_P13_4;
grant select on MDY2131_P13_1.SUCURSAL to MDY2131_P13_4;
grant select on MDY2131_P13_1.TIPO_CONTRATO to MDY2131_P13_4;