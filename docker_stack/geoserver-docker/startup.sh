#!/bin/sh

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

ADDITIONAL_LIBS_DIR=/opt/additional_libs/

# path to default extensions stored in image
EXTENSIONS_PATH=/opt/extensions/
VT_PLUGIN_PATH=$EXTENSIONS_PATH"vectortiles"
WPS_PLUGIN_PATH=$EXTENSIONS_PATH"wps"
IMG_MOSAIC_PLUGIN_PATH=$EXTENSIONS_PATH"imagemosaic-jdbc"

# VECTOR TILES
if [ "$USE_VECTOR_TILES" == 1 ]; then
  echo "Copy Vector Tiles extension to our GeoServer lib directory";
  ls -la $VT_PLUGIN_PATH
  cp $VT_PLUGIN_PATH/*.jar $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/
fi
# WPS
if [ "$USE_WPS" == 1 ]; then
  echo "Copy WPS extension to our GeoServer lib directory";
  ls -la $WPS_PLUGIN_PATH
  cp $WPS_PLUGIN_PATH/*.jar $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/
fi
# IMAGE MOSAIC JDBC
if [ "$USE_IMG_MOSAIC" == 1 ]; then
  echo "Copy Imagemosaic JDBC extension to our GeoServer lib directory";
  ls -la $IMG_MOSAIC_PLUGIN_PATH
  cp $IMG_MOSAIC_PLUGIN_PATH/*.jar $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/
fi

# copy additional geoserver libs before starting the tomcat
if [ -d "$ADDITIONAL_LIBS_DIR" ]; then
    cp $ADDITIONAL_LIBS_DIR/*.jar $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/
fi

# ENABLE CORS
if [ "$USE_CORS" == 1 ]; then
  echo "Enabling CORS for GeoServer"
  echo "Copy a modified web.xml to $CATALINA_HOME/geoserver/WEB-INF/";
  cp /opt/web-cors-enabled.xml $CATALINA_HOME/webapps/geoserver/WEB-INF/web.xml
fi

# start the tomcat
$CATALINA_HOME/bin/catalina.sh run
