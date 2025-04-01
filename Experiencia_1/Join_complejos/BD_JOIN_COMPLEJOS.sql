DROP TABLE DEPARTAMENTO CASCADE CONSTRAINTS;
DROP TABLE EMPLEADO CASCADE CONSTRAINTS;
DROP TABLE PORC_BONO_ANIOS CASCADE CONSTRAINTS;

create table DEPARTAMENTO(
id_departamento integer primary key,
nombre_departamento varchar2(200) not null
);

create table EMPLEADO(
rut varchar2(20) primary key,
nombre_empleado varchar2(200) not null,
anios_antiguedad integer not null,
id_departamento integer,
rut_jefe varchar2(20),
constraint FK_DEPARTAMENTO foreign key (id_departamento)REFERENCES DEPARTAMENTO(id_departamento), 
constraint FK_JEFE foreign key (rut_jefe)REFERENCES EMPLEADO(rut) );

CREATE TABLE PORC_BONO_ANIOS(
ANIO_INI INTEGER NOT NULL,
ANIO_TER INTEGER NOT NULL,
PORCENTAJE_BONO INTEGER NOT NULL
);

insert into DEPARTAMENTO values(10,'Marketing');
insert into DEPARTAMENTO values(20,'Informática');
insert into DEPARTAMENTO values(30,'Recursos Humanos');
insert into DEPARTAMENTO values(40,'Ventas');

insert into EMPLEADO values('15.563.763-3','Pilar',20,null,null);
insert into EMPLEADO values('13.456.457-2','Valentina',13,20,'15.563.763-3');
insert into EMPLEADO values('14.534.765-3','Matias',18,20,'15.563.763-3');
insert into EMPLEADO values('13.563.456-7','Jordán',5,10,'15.563.763-3');
insert into EMPLEADO values('18.654.834-1','Alan',9,40, '14.534.765-3');
insert into EMPLEADO values('17.348.654-4','Camila',2,40, '14.534.765-3');

INSERT INTO PORC_BONO_ANIOS VALUES(1,3,5);
INSERT INTO PORC_BONO_ANIOS VALUES(4,7,7);
INSERT INTO PORC_BONO_ANIOS VALUES(8,11,10);
INSERT INTO PORC_BONO_ANIOS VALUES(12,19,15);
INSERT INTO PORC_BONO_ANIOS VALUES(20,30,20);
COMMIT;