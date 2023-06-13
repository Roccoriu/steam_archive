create or replace function steam.get_jsonb_value(
    _data jsonb,
    key text,
    _default_value text default null
)
    returns text
    language plpgsql as
$$
declare
    _result text;
begin
    if _data ? key THEN
        _result := _data ->> key;
    else
        _result := _default_value;
    end if;
    return _result;
end;
$$
;