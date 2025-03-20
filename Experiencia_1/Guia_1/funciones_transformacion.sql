--Funciones de transformación
/*
Transformación implicita.
Transformación explicita.
*/
--to_number: de texto a número.
SELECT 
    '10'+5 "Transformación implicita",
    to_number('10')+5 "Transformación explicita"
FROM dual;

--to_date: de texto a fecha.
SELECT
    '01/10/2024' "Valor original",
    to_date('01/10/2024') "Forma 1",
    to_date('01/10/2024','DD/MM/YYYY') "Forma 2",
    to_date('01/10/2024','mm/dd/yyyy') "Forma 3",
    extract(Month from to_date('01/10/2024')) "Uso"
FROM dual;

--to_char: fecha o número a un formato de texto.
SELECT
    sueldo_base "salario",
    to_char(sueldo_base) "Forma 1",
    to_char(sueldo_base,'999999999') "Forma 2",
    to_char(sueldo_base,'000000000') "Forma 3",
    to_char(sueldo_base,'$999g999g999d99') "Forma 4",
    to_char(sueldo_base,'999,999,999.99') "Forma 5",
    to_char(sueldo_base,'L999g999g999d99') "Forma 6"
FROM empleado;

SELECT
    sysdate "fecha_actual",
    to_char(sysdate,'dd-mm-yyyy') "Forma 1",
    to_char(sysdate,'dd-mm-yyyy -> hh:mi:ss') "Forma 2",
    to_char(sysdate,'fm day dd "de" month "del" yyyy') "Forma 3",
    to_char(sysdate,'fm Day dd "de" Month "del" yyyy') "Forma 2"
FROM dual;