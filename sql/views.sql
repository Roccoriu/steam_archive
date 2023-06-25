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
with manufacturer_totals as
         (select s.id                as hw_survey_id,
                 g.name              as gpu_manufacturer,
                 SUM(hsg.percentage) as total_percentage
          from steam.Hw_Survey as s
                   join steam.Hw_Survey_Gpu_Config as hsg
                        on s.id = hsg.hw_survey_id
                   join steam.GpuConfig as gc
                        on hsg.gpu_config_id = gc.id
                   join steam.GpuManufacturer as g
                        on gc.manufacturer_id = g.id
          group by s.id, g.name),

     manufacturer as
         (select hw_survey_id,
                 gpu_manufacturer,
                 total_percentage
          from (select hw_survey_id,
                       gpu_manufacturer,
                       total_percentage,
                       rank() over (partition by hw_survey_id order by total_percentage desc ) as rank
                from manufacturer_totals) t
          where rank = 1
            and gpu_manufacturer != 'other')

select hs.date,
       jsonb_build_object('manufacturer', a.gpu_manufacturer, 'total_percentage', a.total_percentage) as manufacturer
from hw_survey as hs
         join manufacturer a on hs.id = a.hw_survey_id;


CREATE OR REPLACE VIEW v_popular_pc_config as
WITH popular_cpu_count AS
         (SELECT hsc.hw_survey_id,
                 hsc.cpu_count_id,
                 hsc.percentage,
                 rank() OVER (PARTITION BY hsc.hw_survey_id ORDER BY hsc.percentage DESC) AS rn
          FROM steam.Hw_Survey_Cpu_Count hsc),
     popular_gpu_config AS
         (SELECT hsg.hw_survey_id,
                 hsg.gpu_config_id,
                 hsg.percentage,
                 rank() OVER (PARTITION BY hsg.hw_survey_id ORDER BY hsg.percentage DESC) AS rn
          FROM steam.Hw_Survey_Gpu_Config hsg
          WHERE gpu_config_id != (SELECT id
                                  FROM gpuconfig
                                  WHERE manufacturer_id =
                                        (SELECT id from gpumanufacturer WHERE gpumanufacturer.name = 'other'))),
     popular_ram_config AS
         (SELECT hsrc.hw_survey_id,
                 hsrc.ram_configuration_id,
                 hsrc.percentage,
                 rank()
                 OVER (PARTITION BY hsrc.hw_survey_id ORDER BY hsrc.percentage DESC) AS rn
          FROM steam.Hw_Survey_Ram_Configuration hsrc),
     popular_os_version AS
         (SELECT hsos.hw_survey_id,
                 hsos.os_version_id,
                 hsos.percentage,
                 rank()
                 OVER (PARTITION BY hsos.hw_survey_id ORDER BY hsos.percentage DESC) AS rn
          FROM steam.Hw_Survey_Os_Version hsos)
SELECT s.date,
       cc.count        AS popular_core_count,
       gc.model        AS popular_gpu_model,
       gc.sub_brand    AS popular_gpu_sub_brand,
       g.name          AS popular_gpu_manufacturer,
       rc.min_capacity AS popular_ram_min_capacity,
       rc.max_capacity AS popular_ram_max_capacity,
       os.os           AS popular_os,
       os.version      AS popular_os_version,
       os.architecture AS popular_os_architecture
FROM steam.Hw_Survey s
         LEFT JOIN popular_cpu_count pcc ON pcc.hw_survey_id = s.id AND pcc.rn = 1
         LEFT JOIN steam.CpuCount cc ON cc.id = pcc.cpu_count_id
         LEFT JOIN popular_gpu_config pgc ON pgc.hw_survey_id = s.id AND pgc.rn = 1
         LEFT JOIN steam.GpuConfig gc ON gc.id = pgc.gpu_config_id
         LEFT JOIN steam.GpuManufacturer g ON g.id = gc.manufacturer_id
         LEFT JOIN popular_ram_config prc ON prc.hw_survey_id = s.id AND prc.rn = 1
         LEFT JOIN steam.RamConfiguration rc ON rc.id = prc.ram_configuration_id
         LEFT JOIN popular_os_version pov ON pov.hw_survey_id = s.id AND pov.rn = 1
         LEFT JOIN steam.OsVersion os ON os.id = pov.os_version_id
ORDER BY s.date;
