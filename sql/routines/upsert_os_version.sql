create or replace function steam.upsert_os_version(
    _hw_survey_id bigint,
    _os_versions jsonb[]
)
    returns void
    language plpgsql as
$$
declare
    _os_version_id bigint;
    _os_version    jsonb;
    _os            varchar(255);
    _version       varchar(255);
    _architecture  varchar(255);
    _percentage    decimal(10, 2);
begin
    for i in 1..array_length(_os_versions, 1)
        loop
            _os_version := _os_versions[i];
            _os := steam.get_jsonb_value(_os_version, 'os');
            _version := steam.get_jsonb_value(_os_version, 'version');
            _architecture := steam.get_jsonb_value(_os_version, 'architecture');
            _percentage := steam.get_jsonb_value(_os_version, 'percentage')::decimal(10, 2);

            select id
            into _os_version_id
            from steam.osversion
            where os = _os
              and version = _version
              and architecture = _architecture;

            if _os_version_id is null then
                insert into steam.osversion(os, version, architecture)
                values (_os, _version, _architecture) returning id into _os_version_id;
            end if;

            insert into steam.hw_survey_os_version(hw_survey_id, os_version_id, percentage)
            values (_hw_survey_id, _os_version_id, _percentage)
            on conflict (hw_survey_id, os_version_id, percentage)
                do update set percentage = _percentage;
        end loop;
end;
$$