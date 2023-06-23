create or replace function steam.upsert_hw_survey(
    _date date,
    _ram_configs json[],
    _os_versions json[],
    _cpu_counts json[],
    _gpu_configs json[]
)
    returns void
    language plpgsql as
$$
declare
    _hw_survey_id      bigint;
    _ram_configs_jsonb jsonb[];
    _os_versions_jsonb jsonb[];
    _cpu_counts_jsonb  jsonb[];
    _gpu_configs_jsonb jsonb[];
begin
    -- Cast json arrays to jsonb arrays
    _ram_configs_jsonb := ARRAY(SELECT j::jsonb FROM unnest(_ram_configs) j);
    _os_versions_jsonb := ARRAY(SELECT j::jsonb FROM unnest(_os_versions) j);
    _cpu_counts_jsonb := ARRAY(SELECT j::jsonb FROM unnest(_cpu_counts) j);
    _gpu_configs_jsonb := ARRAY(SELECT j::jsonb FROM unnest(_gpu_configs) j);

    insert into steam.hw_survey(date)
    values (_date)
    on conflict (date)
        do update set date = _date
    returning id into _hw_survey_id;

    perform steam.upsert_ram_config(_hw_survey_id, _ram_configs_jsonb);
    perform steam.upsert_os_version(_hw_survey_id, _os_versions_jsonb);
    perform steam.upsert_cpu_count(_hw_survey_id, _cpu_counts_jsonb);
    perform steam.upsert_gpu_config(_hw_survey_id, _gpu_configs_jsonb);
end;
$$
