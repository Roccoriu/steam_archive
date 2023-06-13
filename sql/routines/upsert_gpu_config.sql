create or replace function steam.upsert_gpu_config(
    _hw_survey_id bigint,
    _gpu_configs jsonb[]
)
    returns void
    language plpgsql as
$$
declare
    _manufacturer_id bigint;
    _gpu_config_id   bigint;
    _gpu_config      jsonb;
    _name            varchar(255);
    _model           varchar(255);
    _percentage      decimal(5, 2);
begin
    for i in 1..array_length(_gpu_configs, 1)
        loop
            _gpu_config := _gpu_configs[i];
            _name := steam.get_jsonb_value(_gpu_config, 'name');
            _model := steam.get_jsonb_value(_gpu_config, 'model');
            _percentage := steam.get_jsonb_value(_gpu_config, 'percentage')::decimal(5, 2);

            select id into _manufacturer_id from steam.gpumanufacturer where name = _name;

            if _manufacturer_id is null then
                insert into steam.gpumanufacturer(name)
                values (_name);
            end if;

            select id
            into _gpu_config_id
            from steam.gpuconfig
            where model = _model
              and manufacturer_id = _manufacturer_id;

            if _gpu_config_id is null then
                insert into steam.gpuconfig(model, manufacturer_id)
                values (_model, _manufacturer_id);
            end if;

            insert into steam.hw_survey_gpu_config(hw_survey_id, gpu_config_id, percentage)
            values (_hw_survey_id, _gpu_config_id, _percentage)
            on conflict (hw_survey_id, gpu_config_id, percentage)
                do update set percentage=_percentage;

        end loop;
end;
$$;