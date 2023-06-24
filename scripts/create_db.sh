#!/bin/bash

# Initialize our own variables
USER="postgres"
LOCAL_IP=$(hostname -I | awk '{print $1}')

help_msg=$(
    cat <<EOF
This script is used to set up a PostgreSQL database on a remote host.

Usage: $0 -h <host> -p <password> -d <dbname> -s <ssh_username> -P <ssh_password> [-u <username>]

Required parameters:
  -h <host>            The hostname or IP address of the remote server where the PostgreSQL server is running.
  -p <password>        The password for the PostgreSQL or custom database admin user.
  -d <dbname>          The name of the database to create.
  -s <ssh_username>    The username to use for SSH connections.
  -P <ssh_password>    The password for the SSH user on the remote machine to check for sudo permissions.
  -f <sql_file>        The path to the SQL file to execute.

Optional parameter:
  -u <username>        The PostgreSQL username. If not provided, 'postgres' will be used.
EOF
)

# Get the options
while getopts h:p:u:d:s:P:f: option; do
    case "${option}" in
    h) HOST=${OPTARG} ;;
    p) PASSWORD=${OPTARG} ;;
    u) USER=${OPTARG} ;;
    d) DB=${OPTARG} ;;
    s) SSHUSER=${OPTARG} ;;
    P) SSH_PASS=${OPTARG} ;;
    f) SQL_FILE=${OPTARG} ;;
    esac
done

# Check if all required parameters are provided
if [[ -z "${HOST}" ]] ||
    [[ -z "${PASSWORD}" ]] ||
    [[ -z "${DB}" ]] ||
    [[ -z "${SSHUSER}" ]] ||
    [[ -z "${SSH_PASS}" ]] ||
    [[ -z "${SQL_FILE}" ]]; then
    echo "${help_msg}"
    exit 1
fi

# Check if script is run as root
if [[ $EUID -eq 0 ]]; then
    echo "Script must not be run as root"
    exit 1
fi

# Check if the SQL file exists
if [[ ! -f "${SQL_FILE}" ]]; then
    echo "No SQL file provided"
    exit 1
fi

SQL_STMT=$(cat ${SQL_FILE})

# Check if the remote host is reachable
if ! ping -c 1 ${HOST} >/dev/null 2>&1; then
    echo "Remote host ${HOST} is not reachable"
    exit 3
fi

# Check if remote user has sudo permissions
if ! ssh ${SSHUSER}@${HOST} "echo ${SSH_PASS} | sudo -S -l" >/dev/null 2>&1; then
    echo "Remote user does not have sudo permissions"
    exit 3
fi

PG_HBA_CONF=$(ssh ${SSHUSER}@${HOST} "echo ${SSH_PASS} | sudo -S find / -name 'pg_hba.conf' | grep -E 'data/|main/' | head -n 1")
if [[ ${?} -ne 0 ]]; then
    echo "Failed to find pg_hba.conf"
    exit 4
fi

# Login to the remote server and create .pgpass and .pgservice.conf if they don't exist
ssh -t ${SSHUSER}@${HOST} <<EOF
    echo ${SSH_PASS} | sudo -S su

    ## Check if the necessary entries already exist in pg_hba.conf
    if ! sudo grep -qoE "^host\s+all\s+all\s+all\s+md5" ${PG_HBA_CONF}; then
        # Add an entry to pg_hba.conf and reload the PostgreSQL configuration
        echo -e "host\tall\t\tall\t\t${LOCAL_IP}\t\t\tmd5" | sudo tee -a ${PG_HBA_CONF}

        sudo systemctl reload postgresql
    fi

    # Switch to the postgres user
    sudo su - postgres

    ## Create .pgpass if it doesn't exist
    if [ ! -f ~/.pgpass ]; then
        echo "*:*:*:${USER}:${PASSWORD}" >~/.pgpass
        chmod 600 ~/.pgpass
    fi

    # Create .pgservice.conf if it doesn't exist
    if [ ! -f ~/.pg_service.conf ]; then
        echo -e "[${DB}]\nhost=${HOST}\ndbname=${DB}\nuser=${USER}\npassword=${PASSWORD}" >~/.pg_service.conf

        chmod 600 ~/.pg_service.conf
    fi

    # Check if the database already exists
    if ! psql -lqt | cut -d \| -f 1 | grep -w ${DB}; then
        psql -qc "CREATE DATABASE ${DB}
                    WITH
                    OWNER = postgres
                    ENCODING = 'UTF8'
                    LC_COLLATE = 'en_GB.UTF-8'
                    LC_CTYPE = 'en_GB.UTF-8'
                    TABLESPACE = pg_default
                    CONNECTION LIMIT = -1
                    IS_TEMPLATE = False;"

        psql -qd ${DB} -c "${SQL_STMT}"
    fi
EOF

# Check if the command was successful
if [[ $? -ne 0 ]]; then
    echo "Failed to create database ${DB}"
    exit 4
fi

echo "Successfully created database ${DB} on host ${HOST}"

exit 0
