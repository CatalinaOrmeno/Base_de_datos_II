set SERVEROUTPUT on;

-- Caso 1:
drop table PROY_MOVILIZACION;
create table PROY_MOVILIZACION(
    anno_proceso        number,
    numrut_emp          number,
    dvrun_emp           varchar2(1),
    nombre_empleado     varchar2(150),
    sueldo_base         number,
    porc_movil_normal   number,
    valor_movil_normal  number,
    valor_movil_adic    number,
    valor_total_movil   number
);

declare
    v_anno          number := Extract(year from sysdate);
    v_run           empleado.numrun_emp%type := &Ingrese_run;
    v_dv            empleado.dvrun_emp%type;
    v_sueldo        empleado.sueldo_base%type;
    v_comuna        empleado.id_comuna%type;
    v_nombre        varchar2(150);
    v_porc_norm     number;
    v_valor_norm    number;
    v_valor_adic    number;
    v_valor_total   number;
begin
    select dvrun_emp,sueldo_base into v_dv,v_sueldo from empleado
        where numrun_emp = v_run;
    select pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp into v_nombre from empleado
        where numrun_emp = v_run;
    select id_comuna into v_comuna from empleado where numrun_emp = v_run;
    v_porc_norm := trunc(v_sueldo/100000);
    v_valor_norm := round(v_sueldo * (v_porc_norm/100));
    case v_comuna
        when 117 then
            v_valor_adic := 20000;
        when 118 then
            v_valor_adic := 25000;
        when 119 then
            v_valor_adic := 30000;
        when 120 then
            v_valor_adic := 35000;
        when 121 then
            v_valor_adic := 40000;
        else
            v_valor_adic := 0;
    end case;
    v_valor_total := v_valor_norm + v_valor_adic;
    INSERT INTO proy_movilizacion VALUES (v_anno,v_run,v_dv,v_nombre,v_sueldo,v_porc_norm,v_valor_norm,v_valor_adic,v_valor_total);
    dbms_output.put_line('Se ha calculado el valor del bono de movilidad de '|| v_nombre);
exception
    when no_data_found then
        dbms_output.put_line('No hay datos asociados al rut '|| v_run);
end;
/

SELECT * FROM proy_movilizacion;

-- Caso 2:
drop table usuario_clave;
SELECT 
        e.dvrun_emp,
        e.pnombre_emp,
        e.snombre_emp,
        e.appaterno_emp,
        e.apmaterno_emp,
        e.sueldo_base,
        e.fecha_contrato,
        round(Months_between(sysdate,e.fecha_contrato)/12),
        e.fecha_nac,
        ec.nombre_estado_civil,
        c.nombre_comuna
FROM empleado e
    join estado_civil ec on ec.id_estado_civil = e.id_estado_civil
    join comuna c on e.id_comuna = c.id_comuna;

declare
    v_mes_anno      usuario_clave.mes_anno%type := to_char(sysdate,'MMYYYY');
    v_numrun        empleado.numrun_emp%type := &Ingrese_run;
    v_dv            empleado.dvrun_emp%type;
    v_pnombre       empleado.pnombre_emp%type;
    v_snombre       empleado.snombre_emp%type;
    v_appaterno     empleado.appaterno_emp%type;
    v_apmaterno     empleado.apmaterno_emp%type;
    v_sueldo        empleado.sueldo_base%type;
    v_fecha_cont    empleado.fecha_contrato%type;
    v_annos_trab    number;
    v_anno_nac      empleado.fecha_nac%type;
    v_est_civil     estado_civil.nombre_estado_civil%type;
    v_comuna        comuna.nombre_comuna%type;
    v_nom_usuario   usuario_clave.nombre_usuario%type;
    v_clave         usuario_clave.clave_usuario%type;
begin
    SELECT 
        e.dvrun_emp,
        e.pnombre_emp,
        e.snombre_emp,
        e.appaterno_emp,
        e.apmaterno_emp,
        e.sueldo_base,
        e.fecha_contrato,
        round(Months_between(sysdate,e.fecha_contrato)/12),
        e.fecha_nac,
        ec.nombre_estado_civil,
        c.nombre_comuna
    INTO
        v_dv,
        v_pnombre,
        v_snombre,
        v_appaterno,
        v_apmaterno,
        v_sueldo,
        v_fecha_cont,
        v_annos_trab,
        v_anno_nac,
        v_est_civil,
        v_comuna
    FROM empleado e
        join estado_civil ec on ec.id_estado_civil = e.id_estado_civil
        join comuna c on e.id_comuna = c.id_comuna
    where e.numrun_emp = v_numrun;
    
    v_nom_usuario := 
        substr(v_pnombre,1,3)||
        length(v_pnombre)||
        '*'||
        substr(to_char(v_sueldo),-1,1)||
        v_dv||
        v_annos_trab||
        case
            when v_annos_trab < 10 then
                'X'
            else 
                ''
        end
    ;
    
    v_clave :=
        substr(to_char(v_numrun), 3, 1) ||
        to_char(extract(year from v_anno_nac) + 2) ||
        case substr(to_char(v_sueldo), -3, 3)
            when 0 then '999'
            else to_char(to_number(substr(to_char(v_sueldo), -3, 3))- 1)
        end ||
        case 
            when v_est_civil in ('CASADO', 'ACUERDO DE UNION CIVIL') then
                lower(substr(v_appaterno,1,2))
            when v_est_civil in ('DIVORCIADO', 'SOLTERO') then
                lower(substr(v_appaterno,1,1)||substr(v_appaterno,-1,1))
            when v_est_civil = 'VIUDO' then
                lower(substr(v_appaterno,-3,2))
            when v_est_civil = 'SEPARADO' then
                lower(substr(v_appaterno,-2,2))
            else ''
        end ||
        v_mes_anno ||
        substr(v_comuna,1,1)
    ;
    
    INSERT INTO usuario_clave VALUES (
        v_mes_anno,
        v_numrun,
        v_dv,
        v_pnombre||' '||v_snombre||' '||v_appaterno||' '||v_apmaterno,
        v_nom_usuario,
        v_clave
    );
end;
/

SELECT * FROM usuario_clave;