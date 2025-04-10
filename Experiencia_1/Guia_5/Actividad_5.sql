-- Caso 1:
SELECT round(avg(count(*))) FROM atencion a 
where extract(month from a.fecha_atencion) = extract(month from sysdate)-1 and
      extract(year from a.fecha_atencion) = extract(year from sysdate)
group by a.fecha_atencion;

SELECT 
    ts.descripcion||', '||s.descripcion"SISTEMA_SALUD",
    count(*) "TOTAL ATENCIONES"
FROM tipo_salud ts
join salud s on ts.tipo_sal_id = s.tipo_sal_id
join paciente p on s.sal_id = p.sal_id
join atencion ate on p.pac_run = ate.pac_run
where extract(month from ate.fecha_atencion) = extract(month from sysdate)-1 and
      extract(year from ate.fecha_atencion) = extract(year from sysdate)
having count(*) > (SELECT round(avg(count(*))) FROM atencion a 
                    where extract(month from a.fecha_atencion) = extract(month from sysdate)-1 and
                          extract(year from a.fecha_atencion) = extract(year from sysdate)
                            group by a.fecha_atencion)
group by ts.descripcion,s.descripcion;