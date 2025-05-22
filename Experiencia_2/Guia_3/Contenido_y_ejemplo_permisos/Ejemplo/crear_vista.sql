/*Vista que permita mostrar el rut del cliente,
el nombre completo, la cantidad de productos de inversión y
la suma total del monto total ahorrado.

- No puedes utilizar los nombres reales de las tablas.
- Debe quedar almacenado en una vista que pueda utilizar el consultor 3*/

create synonym Sujeto for admin23.cliente;
create synonym Sujeto_PROD_INV for admin23.producto_inversion_cliente;

create or replace view v_sujeto_inversion as
SELECT 
    to_char(s.numrun,'00g000g000')||'-'||s.dvrun RUN_SUJETO,
    initcap(s.pnombre||' '||s.snombre||' '||s.appaterno||' '||s.apmaterno) NOMBRE_COMPLETO,
    count(*) CANTIDAD_PRODUCTOS,
    sum(spi.monto_total_ahorrado + spi.ahorro_minimo_mensual) MONTO_TOTAL_AHORRADO
FROM sujeto s
join sujeto_prod_inv spi on spi.nro_cliente = s.nro_cliente
group by s.numrun,s.dvrun,s.pnombre,s.snombre,s.appaterno,s.apmaterno
order by 4 desc;