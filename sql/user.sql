-- create a user for the steam archive database
-- the user only has full privileges on the steam schema
-- the user has no privileges on the public schema
-- the user is altered to include both the steam and public schemas in the search path

CREATE USER steam_archive_user password 'Vieh12468';

-- the steam_archive_user is set to be the owner of the steam schema
-- thus the user has full privileges on the steam schema.
-- no further privileges are granted to the user on the public schema
CREATE SCHEMA steam AUTHORIZATION steam_archive_user;
ALTER ROLE steam_archive_user SET search_path TO steam,public;