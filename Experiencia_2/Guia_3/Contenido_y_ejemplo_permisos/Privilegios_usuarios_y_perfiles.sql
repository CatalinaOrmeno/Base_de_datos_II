alter session set "_oracle_script" = true;
-- DCL: Data Control Languaje

-- 1.Crear los usuarios:
-- Usuario admin dueño de la base de datos:
create user admin23 identified by "Duocadmin25"
default tablespace users -- Determina el espacio determinado.
TEMPORARY TABLESPACE temp -- Crea un espacio de trabajo temporal.
QUOTA UNLIMITED on users; 

-- Usuarios técnicos que utilizaran la base de datos:
create user tec23_1 identified by "Duocadmin25"
default tablespace users
TEMPORARY TABLESPACE temp
QUOTA 100m on users; 

create user tec23_2 identified by "Duocadmin25"
default tablespace users
TEMPORARY TABLESPACE temp
QUOTA 100m on users; 

-- Consultores que consultaran la base de datos:
create user con23_1 identified by "Duocadmin25"
default tablespace users
TEMPORARY TABLESPACE temp
QUOTA 10m on users; 

create user con23_2 identified by "Duocadmin25"
default tablespace users
TEMPORARY TABLESPACE temp
QUOTA 10m on users; 

create user con23_3 identified by "Duocadmin25"
default tablespace users
TEMPORARY TABLESPACE temp
QUOTA 10m on users; 


-- 2.Otorgar privilegios:
-- Admin: No se crea un rol para administrador, ya que solo existe 1, si hubieran más, si seria necesario un rol.
grant create session,-- Permite conectarse a la base de datos.
      create table,
      create sequence,
      create SYNONYM,
      create PROCEDURE,
      create TRIGGER 
to admin23;

-- Técnicos:
-- Creación de rol del los técnicos:
create role rol_tec;
grant create session,
      create view,
      create synonym
to rol_tec;

-- Permitir uso del rol a los usuarios destinados:
grant rol_tec to tec23_1,tec23_2;

-- Asignar el rol a los técnicos:
alter user tec23_1 default role rol_tec;
alter user tec23_2 default role rol_tec;

-- Consultores:
-- Creación de rol del los consultores:
create role rol_con;
grant create session to rol_con;

-- Permitir uso del rol a los usuarios destinados:
grant rol_con to con23_1,con23_2,con23_3;

-- Asignar el rol a los consultores:
alter user con23_1 DEFAULT role rol_con;
alter user con23_2 DEFAULT role rol_con;
alter user con23_3 DEFAULT role rol_con;


-- 3.Privilegios sobre objetos de otros usuarios:
grant select on admin23.aporte_a_sbif to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.cliente to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.comuna to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.credito to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.credito_cliente to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.cuota_credito_cliente to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.forma_pago to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.movimiento to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.producto_inversion to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.producto_inversion_cliente to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.profesion_oficio to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.provincia to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.region to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.sucursal to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.tipo_contrato to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.tipo_movimiento to tec23_1,tec23_2 with grant OPTION;
grant select on admin23.tipo_movimiento to tec23_1,tec23_2 with grant OPTION;

grant insert,delete,update on admin23.movimiento to tec23_1;
grant insert,delete,update on admin23.cliente to tec23_1;
grant insert,delete,update on admin23.sucursal to tec23_1;

grant select on tec23_1.v_pega_persona to con23_1,con23_2;

-- 4.Perfiles => Límites de las cuentas:
-- Administrador(admin23):
create profile perf_admin LIMIT
    CONNECT_TIME UNLIMITED -- Determina el tiempo de conexión(En este caso, tiene tiempo ilimitado).
    FAILED_LOGIN_ATTEMPTS 3 -- Intentos fallidos permitidos.
    PASSWORD_LOCK_TIME 2 -- Tiempo de bloqueo(Esta en dias, por lo cual, la cuenta se bloqueara en 2 dias de inactividad).
    PASSWORD_LIFE_TIME 60 -- En cuantos dias caduce la contraseña.
    PASSWORD_GRACE_TIME 2; -- Tiempo de gracia para cambiar la contraseña.

-- Técnicos:
create profile perf_tec LIMIT
    CONNECT_TIME 60 -- Determina el tiempo de conexión en minutos.
    FAILED_LOGIN_ATTEMPTS 5 -- Intentos fallidos permitidos.
    PASSWORD_LOCK_TIME 7 -- Tiempo de bloqueo(Esta en dias, por lo cual, la cuenta se bloqueara en 2 dias de inactividad).
    PASSWORD_LIFE_TIME 30; -- En cuantos dias caduce la contraseña.

-- Consultores:
create profile perf_con LIMIT
    CONNECT_TIME 30 -- Determina el tiempo de conexión en minutos.
    FAILED_LOGIN_ATTEMPTS 1 -- Intentos fallidos permitidos.
    PASSWORD_LOCK_TIME 365*2 -- Tiempo de bloqueo(Esta en dias, por lo cual, la cuenta se bloqueara en 2 dias de inactividad).
    PASSWORD_LIFE_TIME 14; -- En cuantos dias caduce la contraseña.
    
-- Como se desbloquea una cuenta bloqueada:
alter user con23_3 account unlock;

-- Asignar los perfiles:
-- Administrador:
alter user admin23 profile perf_admin;

-- Técnicos:
alter user tec23_1 profile perf_tec;
alter user tec23_2 profile perf_tec;

-- Consultores:
alter user con23_1 profile perf_con;
alter user con23_2 profile perf_con;
alter user con23_3 profile perf_con;