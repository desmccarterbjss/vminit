
# Extracts the source URL

. ${PROVISION_SCRIPTS_FOLDER}/utils.sh

function run(){

artifactname="$1"
propertiesfile="$2"

targetdir=`getPropertyValue "${artifactname}.unzip.dir" provision.properties`
targetdir="`eval echo ${targetdir}`"
			
artifact=`getPropertyValue "${artifactname}.url" provision.properties | sed s/"^.*\/\([^\/]*\)$"/"\1"/g`

	if [[ ! -f "${targetdir}/${artifact}" ]]
	then
		doWGet "${url}" "${targetdir}"
	else
		downloadmsg "Artifact ${artifact} already exists"
	fi
}
