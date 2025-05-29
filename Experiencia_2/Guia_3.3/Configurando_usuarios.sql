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
      create ANY INDEX 
to MDY2131_P13_1;

-- Desarrolladores:
create role rol_desarrollador;
grant create session,
      create PROCEDURE,
      create TRIGGER,
      create view,
      create MATERIALIZED view,
      create SYNONYM
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

-- 3.-Perfiles:
-- Administrador:
create profile perf_admin limit
    CONNECT_TIME unlimited
    FAILED_LOGIN_ATTEMPTS 10
    PASSWORD_LIFE_TIME 120;
    
alter user MDY2131_P13_1 profile perf_admin;
    
-- Desarrolladores:
create profile perf_des limit
    CONNECT_TIME 240            -- Minutos.
    INACTIVE_ACCOUNT_TIME 60    -- Minutos: Tiempo en que el usuario tiene que estar inactivo para que se cierre la sesión.
    FAILED_LOGIN_ATTEMPTS 5     -- Intentos.
    PASSWORD_LOCK_TIME 1        -- Dias.
    PASSWORD_LIFE_TIME 90;      -- Dias.
    
alter user MDY2131_P13_2 profile perf_des;
alter user MDY2131_P13_3 profile perf_des;
    
-- Consultores:
create profile perf_con limit
    CONNECT_TIME 120
    INACTIVE_ACCOUNT_TIME 20
    FAILED_LOGIN_ATTEMPTS 2
    PASSWORD_LOCK_TIME 1
    PASSWORD_LIFE_TIME 90
    PASSWORD_GRACE_TIME 1;
    
alter user MDY2131_P13_4 profile perf_con;
alter user MDY2131_P13_5 profile perf_con;
alter user MDY2131_P13_6 profile perf_con;

-- 4.-Acceso a objetos de otros usuarios:
-- Desarrolladores:
grant select on MDY2131_P13_1.APORTE_A_SBIF to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select on MDY2131_P13_1.CLIENTE to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select on MDY2131_P13_1.COMUNA to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select on MDY2131_P13_1.CREDITO to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select, update, insert, delete on MDY2131_P13_1.CREDITO_CLIENTE to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select, update, insert, delete on MDY2131_P13_1.CUOTA_CREDITO_CLIENTE to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select on MDY2131_P13_1.FORMA_PAGO to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select on MDY2131_P13_1.MOVIMIENTO to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select on MDY2131_P13_1.PRODUCTO_INVERSION to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select, update, insert, delete on MDY2131_P13_1.PRODUCTO_INVERSION_CLIENTE to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select on MDY2131_P13_1.PROFESION_OFICIO to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select on MDY2131_P13_1.PROVINCIA to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select on MDY2131_P13_1.REGION to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select on MDY2131_P13_1.SUCURSAL to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select on MDY2131_P13_1.TIPO_CONTRATO to MDY2131_P13_2,MDY2131_P13_3 with grant option;
grant select on MDY2131_P13_1.TIPO_MOVIMIENTO to MDY2131_P13_2,MDY2131_P13_3 with grant option;

-- Consultores:
grant select on MDY2131_P13_1.CLIENTE to MDY2131_P13_4,MDY2131_P13_5,MDY2131_P13_6;
grant select on MDY2131_P13_1.REGION to MDY2131_P13_4,MDY2131_P13_5,MDY2131_P13_6;
grant select on MDY2131_P13_1.PROVINCIA to MDY2131_P13_4,MDY2131_P13_5,MDY2131_P13_6;
grant select on MDY2131_P13_1.COMUNA to MDY2131_P13_4,MDY2131_P13_5,MDY2131_P13_6;
-- Consultor 1:
grant select on MDY2131_P13_1.TIPO_MOVIMIENTO to MDY2131_P13_4;
grant select on MDY2131_P13_1.SUCURSAL to MDY2131_P13_4;
grant select on MDY2131_P13_1.TIPO_CONTRATO to MDY2131_P13_4;

-- Sinónimos públicos para las tablas que ven todos:
create public SYNONYM syn_c for MDY2131_P13_1.CLIENTE;
create public SYNONYM syn_r for MDY2131_P13_1.REGION;
create public SYNONYM syn_p for MDY2131_P13_1.PROVINCIA;
create public SYNONYM syn_co for MDY2131_P13_1.COMUNA;

-- Permiso para ver las vistas:
grant select on MDY2131_P13_2.V_TOTAL_CREDITOS_CLIENTE to MDY2131_P13_3;
grant select on MDY2131_P13_3.V_DATOS_CLIENTES to MDY2131_P13_5,MDY2131_P13_6;