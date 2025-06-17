create table empleado(
    id number primary key,
    nombre varchar2(20),
    salario number
);

insert into empleado values(1,'Juan',1000);
insert into empleado values(2,'Maria',2000);
insert into empleado values(3,'Tomas',3000);
insert into empleado values(4,'Pablo',4000);
insert into empleado values(5,'Juana',5000);

set serverout on;

-- 1.Bloque anidado
/*
declare
begin
    -- Bloque interno
    declare
    begin
    end;
end;
/*/


-- 2.Bloque anidado controlando una excepción:
<<BLOQUE_PRINCIPAL>> -- Le pone un nombre al bloque.
declare
    resultado number;
begin
    -- Bloque interno:
    <<DIVISION_SEGURA>>
    declare
    numerador number := 10;
    denominador number := 2;
    begin
        resultado := numerador/denominador;
    exception
        when zero_divide then
            dbms_output.put_line('Error interno: División por cero');
    end DIVISION_SEGURA; 
    dbms_output.put_line('El resultado es '|| resultado);
    -- Aqui puedes colocar todo el código que quieras, ya que el resultado del bloque interno no es relevante.
exception
    when others then
        dbms_output.put_line('Error externo:');
end BLOQUE_PRINCIPAL;
/

-- 3.Recordando el comando if:
declare
    v_edad number := &Ingrese_su_edad;
begin
    if v_edad >17 then
        dbms_output.put_line('Es mayor de edad');
    elsif v_edad <= 17 and v_edad >= 0 then
        dbms_output.put_line('Es menor de edad');
    else
        dbms_output.put_line('La edad no puede ser negativa');
    end if;
end;
/

-- 4.Ejemplo utilizado if y DML:
-- Si el empleado gana menos de un valor, se le sube el sueldo.
declare
    v_id empleado.id_empleado%type := 1;
    v_nombre empleado.nombre%type;
    v_salario empleado.salario%type;
begin
    select nombre, salario into v_nombre, v_salario from empleado where id_empleado = v_id;
    if v_salario < 1800 then
        update empleado set salario = salario*1.1 where id_empleado = v_id;
        dbms_output.put_line('El sueldo de '||v_nombre||' ha aumentado en un 10%');
    else
        dbms_output.put_line(v_nombre||' no requiere aumento');
    end if;
exception
    when no_data_found then
        dbms_output.put_line('No hay datos relacionados a la id '||v_id);
end;
/

-- 5.Comando CASE:
declare
    v_dia number := &Ingrese_dia;
    nombre_dia varchar2(20);
begin
    nombre_dia := CASE v_dia
                    when 1 then 'Lunes'
                    when 2 then 'Martes'
                    when 3 then 'Miércoles'
                    when 4 then 'Jueves'
                    when 5 then 'Viernes'
                    when 6 then 'Sábado'
                    when 7 then 'Domingo'
                    else 'Valor no valido'
                  end;
    dbms_output.put_line('El día es '  ||nombre_dia);
end;
/

-- 6.Utilizar comando CASE con DML:
-- Bajar el sueldo del empleado con el sueldo más alto
-- Eliminar al empleado con el sueldo más alto
commit;
savepoint a1;
rollback to a1;
declare
    v_operacion varchar2(10) := '&ingrese_operacion';
begin
    case v_operacion
        when 'borrar' then
            delete from empleado where salario = (select max(salario) from empleado);
            dbms_output.put_line('Borrar el empleado con el sueldo más alto');
        when 'actualizar' then
            update empleado set salario = round(salario * 0.95)
                where salario = (select max(salario) from empleado);
            dbms_output.put_line('Actualizar el empleado con el sueldo más alto');
        else
            dbms_output.put_line('Operación no valida');
    end case;
end;
/

-- 7.Ciclos:
declare
    contador_l number :=1;
    contador_w number :=1;
begin
    -- Ciclo LOOP:
    loop
        dbms_output.put_line('Contador LOOP: '||contador_l);
        contador_l := contador_l + 1;
        exit when contador_l>3;
    end loop;
    
    --Ciclo FOR:
    for i in 1..3 loop
        dbms_output.put_line('Contador FOR: '||i);
    end loop;
    
    -- Ciclo WHILE:
    while contador_w <= 3 loop
        dbms_output.put_line('Contador WHILE: '||contador_w);
        contador_w := contador_w + 1;
    end loop;
end;
/