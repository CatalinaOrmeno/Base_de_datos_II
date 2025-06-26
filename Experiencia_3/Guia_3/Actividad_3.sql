set serveroutput on;

-- Caso 1:
-- Consulta para el caso:
-- Se calcula todo en la consulta.
SELECT 
    p.pac_run,
    p.dv_run,
    p.pnombre||' '||p.snombre||' '||p.apaterno||' '||p.amaterno PAC_NOMBRE,
    a.ate_id,
    pa.fecha_venc_pago,
    pa.fecha_pago,
    pa.fecha_pago - pa.fecha_venc_pago DIAS_MOROSIDAD,
    esp.nombre ESPECIALIDAD_ATENCION,
    (
        (
            (
                case
                    when esp.esp_id in (100,300) then 1200
                    when esp.esp_id = 200 then 1300
                    when esp.esp_id in (400,900) then 1700
                    when esp.esp_id in (500,600) then 1900
                    when esp.esp_id = 700 then 1100
                    when esp.esp_id = 1100 then 2000
                    when esp.esp_id in (1400,1800) then 2300
                end
            ) * (pa.fecha_pago - pa.fecha_venc_pago)
        ) * (1-(NVL(porc.porcentaje_descto,0)/100))-- Porcenaje
    ) MONTO_MULTA,
    (trunc(months_between(sysdate,p.fecha_nacimiento)/12)) EDAD,
    (NVL(porc.porcentaje_descto,0)/100) PORC
FROM paciente p
    join atencion a on p.pac_run = a.pac_run
    join pago_atencion pa on pa.ate_id = a.ate_id
    join especialidad esp on esp.esp_id = a.esp_id
    left join porc_descto_3ra_edad porc on (trunc(months_between(sysdate,p.fecha_nacimiento)/12)) 
                                    between porc.anno_ini and porc.anno_ter
where (pa.fecha_pago - pa.fecha_venc_pago) > 0 and
    Extract(year from pa.fecha_venc_pago) = extract(year from sysdate)-1
order by pa.fecha_venc_pago, p.apaterno;

-- Bloque:
-- Se calculara el descuento de tercera edad dentro del bloque.
declare
    cursor c_caso1 is
        SELECT 
            p.pac_run,
            p.dv_run,
            p.pnombre||' '||p.snombre||' '||p.apaterno||' '||p.amaterno PAC_NOMBRE,
            a.ate_id,
            pa.fecha_venc_pago,
            pa.fecha_pago,
            pa.fecha_pago - pa.fecha_venc_pago DIAS_MOROSIDAD,
            esp.nombre ESPECIALIDAD_ATENCION,
            (
                (
                    case
                        when esp.esp_id in (100,300) then 1200
                        when esp.esp_id = 200 then 1300
                        when esp.esp_id in (400,900) then 1700
                        when esp.esp_id in (500,600) then 1900
                        when esp.esp_id = 700 then 1100
                        when esp.esp_id = 1100 then 2000
                        when esp.esp_id in (1400,1800) then 2300
                    end
                ) * (pa.fecha_pago - pa.fecha_venc_pago)
            ) MONTO_MULTA,
            (NVL(porc.porcentaje_descto,0)/100) PORC
        FROM paciente p
            join atencion a on p.pac_run = a.pac_run
            join pago_atencion pa on pa.ate_id = a.ate_id
            join especialidad esp on esp.esp_id = a.esp_id
            left join porc_descto_3ra_edad porc on (trunc(months_between(sysdate,p.fecha_nacimiento)/12)) 
                                            between porc.anno_ini and porc.anno_ter
        where (pa.fecha_pago - pa.fecha_venc_pago) > 0 and
            Extract(year from pa.fecha_venc_pago) = extract(year from sysdate)-1
        order by pa.fecha_venc_pago, p.apaterno;
    v_rut           paciente.pac_run%type;
    v_dv            paciente.dv_run%type;
    v_nombre        varchar2(150);
    v_ate_id        atencion.ate_id%type;
    v_fecha_venc    pago_atencion.fecha_venc_pago%type;
    v_fecha_pago    pago_atencion.fecha_pago%type;
    v_morosidad     number;
    v_esp           especialidad.nombre%type;
    v_multa         number;
    v_porc          number;
    v_monto_total   number;
begin
    open c_caso1;
    loop
        fetch c_caso1 into v_rut,v_dv,v_nombre,v_ate_id,v_fecha_venc,v_fecha_pago,v_morosidad,v_esp,v_multa,v_porc;
        exit when c_caso1%notfound;
        
        v_monto_total := round(v_multa * (1 - v_porc));
        dbms_output.put_line(v_rut||' '||v_nombre||' '||v_monto_total);
        
        INSERT INTO pago_moroso VALUES (v_rut,v_dv,v_nombre,v_ate_id,v_fecha_venc,v_fecha_pago,v_morosidad,v_esp,v_monto_total);
    end loop;
    close c_caso1;
end;
/

SELECT * FROM pago_moroso;

-- Caso 2:
-- Caso 3:
-- Caso 4: