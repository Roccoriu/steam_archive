# Steam Archive

please make sure you create a .env file based on the .env.template file.
Replace the `change_me` with your actual postgres credentials.

## Create the steam_archive database

There are two cases which might apply to you:

1. You have a running postgres server and can run a create db statement
2. you use a docker container for your database

<br/>

### 1. Create the database with a running postgres server

Start a postgres shell on your server. Alternatively you can use pgAdmin for this.

```bash
psql -U postgres
```

Now create the database with the following statement. This will create a database called `steam_archive` with the owner `postgres`.

```sql
CREATE DATABASE steam_archive
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_GB.UTF-8'
    LC_CTYPE = 'en_GB.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

```

### 2. Create the database with a docker container

If you do not have a running postgres server, you can use the included docker-compose file to start a postgres container and an and adminer container to manage the database.

```bash
docker-compose up -d
```

You can use the adminer container to run further queries if you'd like. Open the adminer interface in your browser at `http://localhost:5050` and login with the the following credentials:

- admin: admin



