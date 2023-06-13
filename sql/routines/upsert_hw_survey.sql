create or replace function steam.upsert_hw_survey(
    _date date,
    _ram_configs jsonb[],
    _os_versions jsonb[],
    _cpu_counts jsonb[],
    _gpu_configs jsonb[]
)
    returns void
    language plpgsql as
$$
declare
    _hw_survey_id bigint;
begin
    insert into steam.hw_survey(date)
    values (_date)
    on conflict (date)
        do update set date = _date
    returning id into _hw_survey_id;

    perform steam.upsert_ram_config(_hw_survey_id, _ram_configs);
    perform steam.upsert_os_version(_hw_survey_id, _os_versions);
    perform steam.upsert_cpu_count(_hw_survey_id, _cpu_counts);
    perform steam.upsert_gpu_config(_hw_survey_id, _gpu_configs);
end;
$$