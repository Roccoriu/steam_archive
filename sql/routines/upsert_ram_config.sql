create or replace function steam.upsert_ram_config(
    _hw_survey_id bigint,
    _configs jsonb[]
)
    returns void
    language plpgsql
as
$$
declare
    _ram_configuration_id bigint;
    _config               jsonb;
    _min_capacity         decimal(10, 2);
    _max_capacity         decimal(10, 2);
    _percentage           decimal(10, 2);
begin
    for i in 1..array_length(_configs, 1)
        loop
            _config := _configs[i];
            _min_capacity := steam.get_jsonb_value(_config, 'min_capacity')::decimal(10, 2);
            _max_capacity := steam.get_jsonb_value(_config, 'max_capacity')::decimal(10, 2);
            _percentage := steam.get_jsonb_value(_config, 'percentage')::decimal(10, 2);

            select id
            into _ram_configuration_id
            from steam.ramconfiguration
            where min_capacity = _min_capacity
              and max_capacity = _max_capacity;

            if _ram_configuration_id is null then
                insert into steam.ramconfiguration(min_capacity, max_capacity)
                values (_min_capacity, _max_capacity)
                returning id into _ram_configuration_id;
            end if;

            insert into steam.hw_survey_ram_configuration(hw_survey_id, ram_configuration_id, percentage)
            values (_hw_survey_id, _ram_configuration_id, _percentage)
            on conflict (hw_survey_id, ram_configuration_id, percentage)
                do update set percentage = _percentage;
        end loop;
end;
$$