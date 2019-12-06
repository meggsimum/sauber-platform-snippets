#! /bin/sh

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

# Read docker secrets. 
secrets=(
    GEOSERVER_USER
	GEOSERVER_PASSWORD
)

for e in "${secrets[@]}"; do
		file_env "$e"
done

# Ensure mandatory environment vars are set and forward then to tomcat via CATALINA_OPTS

envs=(
    GEOSERVER_USER
	GEOSERVER_PASSWORD
)

for e in "${envs[@]}"; do
	if [ -z ${!e:-} ]; then
		echo "error: $e is not set"
		exit 1
	fi
done

export CATALINA_OPTS="${CATALINA_OPTS} \
	-Djdbc.username=\"${POSTGRES_USER}\" \
	-Djdbc.password=\"${POSTGRES_PASSWORD}\""


# Initially populate our mounted folder GEOSERVER_DATA_DIR from GEOSERVER_INIT_DATA_DIR.
# If the workspaces folder in GEOSERVER_DATA_DIR exists,
# then assume the service has already been initialized.

if [ -d "${GEOSERVER_DATA_DIR}/workspaces" ]; then
	echo "${GEOSERVER_DATA_DIR}/workspaces already exists, skipping initialization"
else
	echo "initializing ${GEOSERVER_DATA_DIR}"
	source /usr/local/bin/import-data.sh ${GEOSERVER_INIT_DATA_DIR}
fi

# Since geoserver users cannot be configure via environment vars
# inject their content into the geoserver config file.
# Do this on every restart of the service, as secrets could potentially change.

configs=(
    security/usergroup/default/users.xml
	security/role/default/roles.xml
)

# see http://stackoverflow.com/a/2705678/433558
sed_escape_lhs() {
    echo "$@" | sed -e 's/[]\/$*.^|[]/\\&/g'
}

sed_escape_rhs() {
    echo "$@" | sed -e 's/[\/&]/\\&/g'
}

set_config() {
    key=$(sed_escape_lhs "$1")
    value=$(sed_escape_rhs "$2")
	sed -ri -e "s/$key/$value/" $3
} 

for e in "${configs[@]}"; do
	cp "${GEOSERVER_INIT_DATA_DIR}/$e" "${GEOSERVER_DATA_DIR}/$e"
	set_config 'GEOSERVER_DEFAULT_USER' "$GEOSERVER_USER" "${GEOSERVER_DATA_DIR}/$e"
	set_config 'GEOSERVER_DEFAULT_PASSWORD' "$GEOSERVER_PASSWORD" "${GEOSERVER_DATA_DIR}/$e"
done