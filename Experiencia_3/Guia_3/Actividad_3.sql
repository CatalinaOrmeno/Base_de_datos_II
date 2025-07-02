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
-- Subconsulta:
SELECT 
    max(count(at.med_run)) MAX_ATEN_MEDICAS
FROM medico me
    left join atencion at on at.med_run = me.med_run
        and extract(year from at.fecha_atencion) = extract(year from sysdate)-1
group by me.med_run;

-- Cursor:
SELECT 
    u.nombre UNIDAD,
    to_char(m.med_run,'00g000g000')||'-'||m.dv_run RUN_MEDICO,
    m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno NOMBRE_MEDICO,
    substr(u.nombre,1,2)||
    substr(m.apaterno,-3,2)||
    substr(m.telefono,-3,3)||
    to_char(m.fecha_contrato,'DDMM')||
    '@medicocktk.cl' 
    CORREO_INSTITUCIONAL,
    count(a.med_run) TOTAL_ATEN_MEDICAS,
    CASE
        when u.uni_id in (400,100) then
            'Servicio de Atención Primaria de Urgencia (SAPU)'
        when u.uni_id in (200,700,800,1000) then
            case
                when count(a.med_run) between 0 and 3 then
                    'Servicio de Atención Primaria de Urgencia (SAPU)'
                when count(a.med_run) > 3 then
                    'Hospitales del área de la Salud Pública'
            end
        when u.uni_id in (900,500,300) then
            'Hospitales del área de la Salud Pública'
        when u.uni_id = 600 then
            'Centros de Salud Familiar (CESFAM)'
    END
    DESTINACION
FROM medico m
    join unidad u on u.uni_id = m.uni_id
    left join atencion a on a.med_run = m.med_run
        and extract(year from a.fecha_atencion) = extract(year from sysdate)-1
group by u.nombre,m.med_run,m.dv_run,m.pnombre,m.snombre,m.apaterno,m.amaterno,u.uni_id,m.telefono,m.fecha_contrato
having count(a.med_run) < (
    SELECT 
        max(count(at.med_run)) MAX_ATEN_MEDICAS
    FROM medico me
        left join atencion at on at.med_run = me.med_run
            and extract(year from at.fecha_atencion) = extract(year from sysdate)-1
    group by me.med_run
)
order by u.nombre,m.apaterno;

-- Bloque anonimo:
declare
    cursor c_medicos is 
        SELECT 
            u.uni_id ID_UNIDAD,
            u.nombre UNIDAD,
            to_char(m.med_run,'00g000g000')||'-'||m.dv_run RUN_MEDICO,
            m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno NOMBRE_MEDICO,
            substr(u.nombre,1,2)||
            substr(m.apaterno,-3,2)||
            substr(m.telefono,-3,3)||
            to_char(m.fecha_contrato,'DDMM')||
            '@medicocktk.cl' 
            CORREO_INSTITUCIONAL,
            count(a.med_run) TOTAL_ATEN_MEDICAS
        FROM medico m
            join unidad u on u.uni_id = m.uni_id
            left join atencion a on a.med_run = m.med_run
                and extract(year from a.fecha_atencion) = extract(year from sysdate)-1
        group by u.nombre,m.med_run,m.dv_run,m.pnombre,m.snombre,m.apaterno,m.amaterno,u.uni_id,m.telefono,m.fecha_contrato
        having count(a.med_run) < (
            SELECT 
                max(count(at.med_run)) MAX_ATEN_MEDICAS
            FROM medico me
                left join atencion at on at.med_run = me.med_run
                    and extract(year from at.fecha_atencion) = extract(year from sysdate)-1
            group by me.med_run
        )
        order by u.nombre,m.apaterno;
    
    v_uni_id            Unidad.uni_id%type;
    v_unidad            MEDICO_SERVICIO_COMUNIDAD.unidad%type;
    v_run               MEDICO_SERVICIO_COMUNIDAD.run_medico%type;
    v_nombre            MEDICO_SERVICIO_COMUNIDAD.nombre_medico%type;
    v_correo            MEDICO_SERVICIO_COMUNIDAD.correo_institucional%type;
    v_atenciones        MEDICO_SERVICIO_COMUNIDAD.total_aten_medicas%type;
    v_destinacion       MEDICO_SERVICIO_COMUNIDAD.destinacion%type;
begin
    open c_medicos;
    loop
        FETCH c_medicos into v_uni_id,v_unidad,v_run,v_nombre,v_correo,v_atenciones;
        exit when c_medicos%notfound;
        
        v_destinacion := 
            CASE
                when v_uni_id in (400,100) then
                    'Servicio de Atención Primaria de Urgencia (SAPU)'
                when v_uni_id in (200,700,800,1000) then
                    case
                        when v_atenciones between 0 and 3 then
                            'Servicio de Atención Primaria de Urgencia (SAPU)'
                        when v_atenciones > 3 then
                            'Hospitales del área de la Salud Pública'
                    end
                when v_uni_id in (900,500,300) then
                    'Hospitales del área de la Salud Pública'
                when v_uni_id = 600 then
                    'Centros de Salud Familiar (CESFAM)'
            END
        ;
        
        dbms_output.put_line(v_nombre||' =======>> '||v_destinacion);
        INSERT INTO medico_servicio_comunidad
            (UNIDAD,RUN_MEDICO,NOMBRE_MEDICO,CORREO_INSTITUCIONAL,TOTAL_ATEN_MEDICAS,DESTINACION) 
            VALUES (v_unidad,v_run,v_nombre,v_correo,v_atenciones,v_destinacion);
    end loop;
    close c_medicos;
end;
/

-- Caso 3:
    -- Parte 3.1:
        -- Crear copia:
        drop table pago_atencion_2025;
        create table pago_atencion_2025 as
            SELECT * FROM pago_atencion;
        
        -- Cursor:
        SELECT 
            pa.ate_id,
            pa.monto_a_cancelar
        FROM pago_atencion_2025 pa
        where Extract(year from pa.fecha_pago) = Extract(year from sysdate) -1
        order by pa.ate_id;
        
        -- BIND:
        variable v_porcentaje number;
        
        -- Establecer porcentaje:
        begin
            :v_porcentaje := 23;
        end;
        /
        
        -- Bloque:
        declare
            cursor c_pagos_2025 is
                SELECT 
                    pa.ate_id,
                    pa.monto_a_cancelar
                FROM pago_atencion_2025 pa
                where Extract(year from pa.fecha_pago) = Extract(year from sysdate) -1
                order by pa.ate_id;
            
            v_ate_id            pago_atencion_2025.ate_id%type;
            v_monto_a_cancelar  pago_atencion_2025.monto_a_cancelar%type;
            v_porc_decimal      number:= :v_porcentaje/100;
            v_observación       pago_atencion_2025.obs_pago%type;
            v_contador          number:= 0;
        begin
            open c_pagos_2025;
            loop
                fetch c_pagos_2025 into v_ate_id,v_monto_a_cancelar;
                exit when c_pagos_2025%notfound;
                
                -- dbms_output.put_line(v_monto_a_cancelar);
                v_monto_a_cancelar := v_monto_a_cancelar * (1-v_porc_decimal);
                -- dbms_output.put_line(v_monto_a_cancelar);
                
                v_observación := 'descuento aplicado '||to_char(sysdate,'dd/MM/YY');
                -- dbms_output.put_line(v_observación);
                
                UPDATE pago_atencion_2025 set
                    monto_a_cancelar = v_monto_a_cancelar,
                    OBS_PAGO = v_observación
                where ate_id = v_ate_id;
                
                v_contador := v_contador + 1;
            end loop;
            close c_pagos_2025;
            dbms_output.put_line('FIN PROCESO');
            dbms_output.put_line('Se Aplicó Descuento a: '||to_char(v_contador)||' atenciones del año '||to_char(extract(year from sysdate)-1));
            dbms_output.put_line('Revise la tabla de simulación PAGO_ATENCION_2025');
        end;
        /

    -- Parte 3.2:
        -- Crear copia:
        drop table pago_atencion_fase2;
        create table pago_atencion_fase2 as
            SELECT * FROM pago_atencion order by ate_id;
        
        -- Cursor:
        SELECT 
            pa.ate_id,
            pa.monto_a_cancelar,
            es.nombre,
            s.descripcion,
            case
                when s.sal_id in (10,20) then
                    10
                when s.sal_id in (30,40) then
                    20
            end||'%' PORC_DESC
        FROM pago_atencion_fase2 pa
            join atencion a on pa.ate_id = a.ate_id
            join especialidad es on es.esp_id = a.esp_id
                and es.esp_id in (100,200,600,700)
            join paciente p on p.pac_run = a.pac_run
            join salud s on s.sal_id = p.sal_id
                and s.tipo_sal_id = 'F'
        where Extract(year from pa.fecha_venc_pago) = Extract(year from sysdate) -1
        order by pa.ate_id;
        
        -- BIND:
        variable v_desc_AB number;
        variable v_desc_CD number;
        
        BEGIN
          :v_desc_AB := 0.1;
          :v_desc_CD := 0.2;
        END;
        /
        
        -- Bloque:
        declare
            cursor c_atenciones is
                SELECT 
                    pa.ate_id,
                    pa.monto_a_cancelar,
                    s.descripcion
                FROM pago_atencion_fase2 pa
                    join atencion a on pa.ate_id = a.ate_id
                    join especialidad es on es.esp_id = a.esp_id
                        and es.esp_id in (100,200,600,700)
                    join paciente p on p.pac_run = a.pac_run
                    join salud s on s.sal_id = p.sal_id
                        and s.tipo_sal_id = 'F'
                where Extract(year from pa.fecha_venc_pago) = Extract(year from sysdate) -1
                order by pa.ate_id;
            
            v_ate_id            pago_atencion_fase2.ate_id%type;
            v_monto_a_cancelar  pago_atencion_fase2.monto_a_cancelar%type;
            v_tramo             salud.descripcion%type;
            v_observación       pago_atencion_fase2.obs_pago%type;
            v_porcentaje        number;
            v_contador_10       number:= 0;
            v_contador_20       number:= 0;
        begin
            open c_atenciones;
            loop
                fetch c_atenciones into v_ate_id,v_monto_a_cancelar,v_tramo;
                exit when c_atenciones%notfound;
                
                if v_tramo in ('Tramo A','Tramo B') then
                        v_porcentaje := :v_desc_AB;
                        v_contador_10 := v_contador_10 + 1;
                elsif v_tramo in ('Tramo C','Tramo D') then
                        v_porcentaje := :v_desc_CD;
                        v_contador_20 := v_contador_20 + 1;
                end if;
                
                -- dbms_output.put_line(v_monto_a_cancelar);
                v_monto_a_cancelar := v_monto_a_cancelar * (1 - v_porcentaje);
                -- dbms_output.put_line(v_monto_a_cancelar);
                
                v_observación := 'Descuento aplicado '||to_char(v_porcentaje*100)||'% en '||to_char(sysdate,'Month "del" YYYY');
                -- dbms_output.put_line(v_observación);
                
                UPDATE pago_atencion_fase2 set
                    monto_a_cancelar = v_monto_a_cancelar,
                    obs_pago = v_observación
                where ate_id = v_ate_id;
                
            end loop;
            close c_atenciones;
            dbms_output.put_line('FIN PROCESO');
            dbms_output.put_line('Se Aplicó Descuento del 10% a: '||to_char(v_contador_10)||' atenciones del año '||to_char(extract(year from sysdate)-1));
            dbms_output.put_line('Se Aplicó Descuento del 20% a: '||to_char(v_contador_20)||' atenciones del año '||to_char(extract(year from sysdate)-1));
            dbms_output.put_line('Revise la tabla de simulación PAGO_ATENCION_FASE2');
        end;
        /

-- Caso 4:
    -- Cursor:
    SELECT 
        extract(year from sysdate) ANNO_TRIBUTARIO,
        m.med_run,
        m.dv_run,
        m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno NOMBRE_COMPLETO,
        c.nombre CARGO,
        trunc(
            case 
                when months_between(to_date('01-01-'||extract(year from sysdate)),m.fecha_contrato) > 12 then
                    12
                else months_between(to_date('01-01-'||extract(year from sysdate)),m.fecha_contrato)
            end
        ) MESES,
        m.sueldo_base SUELDO_MENSUAL,
        m.sueldo_base * 12 SUELDO_ANUAL,
        count(ate.ate_id)
    FROM medico m
        left join atencion ate on m.med_run = ate.med_run
            and extract(year from ate.fecha_atencion) = extract(year from sysdate) - 1
        join cargo c on m.car_id = c.car_id
    group by m.med_run,m.dv_run,m.pnombre,m.snombre,m.apaterno,m.amaterno,c.nombre,m.fecha_contrato,m.sueldo_base
    order by m.med_run;
    
    -- Subconsulta: Obtiene la información sobre cuantos profecionales cumplen con las condiciones para el bono por ganacia.
    Select count(*) from (
        SELECT 
            count(ate.ate_id)
        FROM medico m
            left join atencion ate on m.med_run = ate.med_run
                and extract(year from ate.fecha_atencion) = extract(year from sysdate) - 1
        group by m.med_run
        having count(ate.ate_id) > 5
    );
    
    -- Bloque anonimo:
    declare
        cursor c_medicos is
            SELECT 
                extract(year from sysdate) ANNO_TRIBUTARIO,
                m.med_run,
                m.dv_run,
                m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno NOMBRE_COMPLETO,
                c.nombre CARGO,
                trunc(
                    case 
                        when months_between(to_date('01-01-'||extract(year from sysdate)),m.fecha_contrato) > 12 then
                            12
                        else months_between(to_date('01-01-'||extract(year from sysdate)),m.fecha_contrato)
                    end
                ) MESES,
                m.sueldo_base SUELDO_MENSUAL,
                m.sueldo_base * trunc(
                    case 
                        when months_between(to_date('01-01-'||extract(year from sysdate)),m.fecha_contrato) > 12 then
                            12
                        else months_between(to_date('01-01-'||extract(year from sysdate)),m.fecha_contrato)
                    end
                ) SUELDO_ANUAL,
                count(ate.ate_id)
            FROM medico m
                left join atencion ate on m.med_run = ate.med_run
                    and extract(year from ate.fecha_atencion) = extract(year from sysdate) - 1
                join cargo c on m.car_id = c.car_id
            group by m.med_run,m.dv_run,m.pnombre,m.snombre,m.apaterno,m.amaterno,c.nombre,m.fecha_contrato,m.sueldo_base
            order by m.med_run;
        
        v_ANNO_TRIBUTARIO           info_medico_sii.anno_tributario%type;
        v_NUMRUN                    info_medico_sii.numrun%type;
        v_DV_RUN                    info_medico_sii.dv_run%type;
        v_NOMBRE_COMPLETO           info_medico_sii.nombre_completo%type;
        v_CARGO                     info_medico_sii.cargo%type;
        v_MESES_TRABAJADOS          info_medico_sii.meses_trabajados%type;
        v_SUELDO_BASE_MENSUAL       info_medico_sii.sueldo_base_mensual%type;
        v_SUELDO_BASE_ANUAL         info_medico_sii.sueldo_base_anual%type;
        v_BONIF_ESPECIAL            info_medico_sii.bonif_especial%type := 0;
        v_SUELDO_BRUTO_ANUAL        info_medico_sii.sueldo_bruto_anual%type;
        v_RENTA_IMPONIBLE_ANUAL     info_medico_sii.renta_imponible_anual%type;
        v_movilizacion              number := 0;
        v_colacion                  number := 0;
        v_numero_atenciones         number;
        v_div_ganacias              number;
        v_ganacias_anuales          number := &Ingrese_ganacias;
        v_bono_ganacias             number := v_ganacias_anuales * 0.03;
        v_bono_asig                 number := 0;
        v_porcentaje_bono_atm       number := 0;
        v_cifrado_rut               number := 100;
        v_cifrado_dv                number := 10;
        v_cifrado_sueldo            number := 900;
        
        -- Variables para calculos:
        v_med_rut_ganacias          info_medico_sii.numrun%type;
    begin
        open c_medicos;
        loop
            fetch c_medicos into v_anno_tributario,v_numrun,v_dv_run,v_nombre_completo,v_cargo,
                        v_meses_trabajados,v_sueldo_base_mensual,v_sueldo_base_anual,v_numero_atenciones;
            exit when c_medicos%notfound;
            
            Select count(*) into v_div_ganacias from (
                SELECT 
                    count(ate.ate_id)
                FROM medico m
                    left join atencion ate on m.med_run = ate.med_run
                        and extract(year from ate.fecha_atencion) = extract(year from sysdate) - 1
                group by m.med_run
                having count(ate.ate_id) > 5
            );
            
            -- Calcular bonificaciones especiales:
                --dbms_output.put_line(v_BONIF_ESPECIAL||' = '||v_bono_ganacias||'/'||v_div_ganacias);
                if v_numero_atenciones > 5 then
                    v_BONIF_ESPECIAL := trunc(v_bono_ganacias/v_div_ganacias);
                else 
                    v_BONIF_ESPECIAL := 0;
                end if;
                --dbms_output.put_line(v_BONIF_ESPECIAL);
                
                BEGIN
                    SELECT porc_asig
                    INTO v_porcentaje_bono_atm
                    FROM tramo_asig_atmed
                    WHERE v_numero_atenciones BETWEEN tramo_inf_atm AND tramo_sup_atm;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        v_porcentaje_bono_atm := 0;
                END;
                --dbms_output.put_line(v_porcentaje_bono_atm);
            
            -- Calcular bono de asignación especial:
                if v_porcentaje_bono_atm != 0 then
                    v_bono_asig := v_sueldo_base_mensual*(v_porcentaje_bono_atm/100);
                else 
                    v_bono_asig := 0;
                end if;
                --dbms_output.put_line(v_bono_asig);
            
            -- Calcular movilización:
                v_movilizacion := trunc(v_sueldo_base_anual * 0.12);
                --dbms_output.put_line(v_movilizacion);
            
            -- Calcular colación:
                v_colacion := trunc(v_sueldo_base_anual * 0.2);
                --dbms_output.put_line(v_colacion);
            
            -- Calcular renta imponible anual:
                v_renta_imponible_anual := v_sueldo_base_anual + v_BONIF_ESPECIAL + v_bono_asig;
                --dbms_output.put_line(v_renta_imponible_anual);
            
            -- Calcular sueldo bruto:
                v_SUELDO_BRUTO_ANUAL := v_renta_imponible_anual + v_colacion + v_movilizacion;
                --dbms_output.put_line(v_SUELDO_BRUTO_ANUAL);
            
            -- Cifrado:
                -- NumRut:
                    v_NUMRUN := to_char(v_NUMRUN)||to_char(v_cifrado_rut); 
                    --dbms_output.put_line(v_NUMRUN);
                    
                    v_cifrado_rut := v_cifrado_rut + 1;
                
                -- DV:
                    v_dv_run := to_char(v_cifrado_dv,'000')||to_char(v_dv_run);
                    --dbms_output.put_line(v_dv_run);
                    
                    v_cifrado_dv := v_cifrado_dv + 3;
                
                -- Sueldo base mensual:
                    v_sueldo_base_mensual := to_char(v_sueldo_base_mensual)||to_char(v_cifrado_sueldo);
                    --dbms_output.put_line(v_sueldo_base_mensual);
                    
                    v_cifrado_sueldo := v_cifrado_sueldo - 10;
            
            -- Guardar los datos en la tabla:
            INSERT INTO info_medico_sii VALUES (
                v_anno_tributario,v_numrun,v_dv_run,v_nombre_completo,v_cargo,
                v_meses_trabajados,v_sueldo_base_mensual,v_sueldo_base_anual,
                (v_BONIF_ESPECIAL + v_bono_asig),v_SUELDO_BRUTO_ANUAL,v_renta_imponible_anual);
        end loop;
        close c_medicos;
    end;
    /
    -- DELETE FROM info_medico_sii;