# Steam Archive

please make sure you create a .env file based on the .env.template file.
Replace the `change_me` with your actual postgres credentials.

## Create the steam_archive database

There are two cases which might apply to you:

1. you have a running postgres server and use the cli to create it
2. you use a docker container for your database

<br/>

### 1. Create the database with a running postgres server

if you have a running postgres server, you can create the database with the following command:

```bash
# using the python cli (recommended)
./main.py db create -h <host> -p <password> -d <dbname> -s <ssh_username> -P <ssh_password> [-u <username>]

# using the create_db.sh script directly (discouraged)
./create_db.sh -h <host> -p <password> -d <dbname> -s <ssh_username> -P <ssh_password> [-u <username>]
```

### 2. Create the database with a docker container

If you do not have a running postgres server, you can use the included docker-compose file to start a postgres container and an and adminer container to manage the database.

```bash
docker-compose up -d
```

You can use the adminer container to run further queries if you'd like. Open the adminer interface in your browser at `http://localhost:5050` and login with the the following credentials:

- admin: admin
