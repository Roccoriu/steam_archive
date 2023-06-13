create or replace function steam.upsert_cpu_count(
    _hw_survey_id bigint,
    _cpu_counts jsonb[]
)
    returns void
    language plpgsql as
$$
declare
    _cpu_count_id bigint;
    _cpu_count    jsonb;
    _count        int;
    _percentage   decimal(5, 2);
begin
    for i in 1..array_length(_cpu_counts, 1)
        loop
            _cpu_count := _cpu_counts[i];
            _count := steam.get_jsonb_value(_cpu_count, 'cpu_count');

            select id into _cpu_count_id from steam.cpucount where count = _count;

            if _cpu_count_id is null then
                insert into steam.cpucount(count)
                values (_count);
            end if;

            insert into steam.hw_survey_cpu_count(hw_survey_id, cpu_count_id, percentage)
            values (_hw_survey_id, _cpu_count_id, _percentage)
            on conflict (hw_survey_id, cpu_count_id, percentage)
                do update set percentage = _percentage;

        end loop;
end;
$$;