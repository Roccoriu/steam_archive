create or replace view v_popular_number_of_cores as
select hs.date,
       jsonb_build_object('cores', c.count, 'percentage', a.percentage) as cores
from hw_survey hs
         join(select hw_survey_id,
                     cpu_count_id,
                     percentage
              from steam.Hw_Survey_Cpu_Count
              where (hw_survey_id, percentage)
                        in (select hw_survey_id,
                                   MAX(percentage)
                            from steam.Hw_Survey_Cpu_Count
                            group by hw_survey_id)) a
             on hs.id = a.hw_survey_id
         join cpucount c on a.cpu_count_id = c.id
order by date desc;



create or replace view v_popular_gpu_manufacturer as
select hs.date,
       jsonb_build_object('manufacturer', a.gpu_manufacturer, 'total_percentage', a.total_percentage) as manufacturer
from hw_survey as hs
         join (with manufacturer_totals as
                        (select s.id                as hw_survey_id,
                                g.name              as gpu_manufacturer,
                                SUM(hsg.percentage) as total_percentage
                         from steam.Hw_Survey as s
                                  join steam.Hw_Survey_Gpu_Config as hsg on s.id = hsg.hw_survey_id
                                  join steam.GpuConfig as gc on hsg.gpu_config_id = gc.id
                                  join steam.GpuManufacturer as g on gc.manufacturer_id = g.id
                         group by s.id, g.name)
               select hw_survey_id, gpu_manufacturer, total_percentage
               from (select hw_survey_id,
                            gpu_manufacturer,
                            total_percentage,
                            rank() over (partition by hw_survey_id order by total_percentage desc ) as rank
                     from manufacturer_totals) t
               where rank = 1
                 and gpu_manufacturer != 'other') a
              on hs.id = a.hw_survey_id;
