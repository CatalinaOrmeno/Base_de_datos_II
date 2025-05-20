SELECT * FROM admin22.cliente;
SELECT * FROM admin22.producto_inversion_cliente;
SELECT * FROM admin22.producto_inversion;

-- Parte 1:
INSERT INTO datos
SELECT 
   extract(year from sysdate) ANNO_TRIBUTARIO,
   to_char(c.numrun,'00g000g000')||'-'||c.dvrun RUN_CLIENTE,
   initcap(c.pnombre||' '||substr(c.snombre,1,1)||'. '||c.appaterno||' '||c.apmaterno) NOMBRE_CLIENTE,
   to_char(count(*)) TOTAL_PROD_INV_AFECTOS_OMPTO,
   to_char(sum(pic.monto_total_ahorrado+pic.ahorro_minimo_mensual)) MONTO_TOTAL_AHORRADO
FROM admin22.cliente c
join admin22.producto_inversion_cliente pic on pic.nro_cliente = c.nro_cliente
    and pic.cod_prod_inv in (30,35,40,45,50,55)
group by extract(year from sysdate),c.numrun,c.dvrun,c.pnombre,c.snombre,c.appaterno,c.apmaterno
order by c.appaterno;

-- Parte 2:
create table DATOS(
    ANNO_TRIBUTARIO integer not null,
    RUN_CLIENTE varchar2(30) not null,
    NOMBRE_CLIENTE varchar2(150) not null,
    TOTAL_PROD_INV_AFECTOS_OMPTO varchar2(10) not null,
    MONTO_TOTAL_AHORRADO varchar2(20) not null
);
drop sequence seq_enc1;
create SEQUENCE seq_enc1
    start with 10
    increment by 2
    NOCACHE;
drop sequence seq_enc2;
create SEQUENCE seq_enc2
    start with 1
    increment by 3
    NOCACHE;
create sequence seq_enc3
start with 1
increment by 1
nocache;

create sequence seq_enc4
start with 1
increment by 1
nocache;

update datos set run_cliente = seq_enc1.nextval||' '||run_cliente;
update datos set run_cliente = substr(run_cliente,1,length(run_cliente)-1)||'-'||seq_enc2.nextval||substr(run_cliente,-1,1);
update datos set total_prod_inv_afectos_ompto = (seq_enc3.nextval*seq_enc4.nextval)||total_prod_inv_afectos_ompto