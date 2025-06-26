set serveroutput on;
-- Array -> colección:
create or replace type lista_nombres as varray(5) of varchar2(50);

-- Bloque
declare
    v_lista lista_nombres := lista_nombres('Pedro','Alan','Juan','Javier','Camila');
begin
    FOR i in 1..v_lista.count loop
        dbms_output.put_line(v_lista(i));
    end loop;
end;
/