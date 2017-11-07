# Extracts the source URL

. ${PROVISION_SCRIPTS_FOLDER}/util.sh

artifactname="$1"
propertiesfile="$2"

url=`getPropertyValue "${artifactname}.source.url" ${propertiesfile}`
artifact="`echo ${url} | sed s/'^.*\/\([^\/]*\)$'/'\1'/g`"

info "Source URL:       ${url}"
info "Artifact:         ${artifact}"
