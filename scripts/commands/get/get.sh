
# Extracts the source URL

. ${PROVISION_SCRIPTS_FOLDER}/utils.sh

function run(){

artifactname="$1"
artifactnamel="`propertyToLinux ${artifactname}`"

targetdir="`getPropertyValue ${artifactnamel}.wget.dir`"

sourceurl="`getPropertyValue ${artifactnamel}.wget.url`"

args="`getPropertyValue ${artifactnamel}.wget.args`"

artifact="`getFilenameFromUrl ${sourceurl}`"

	if [[ ! -f "${targetdir}/${artifact}" ]]
	then
		info "${targetdir}/${artifact} does not exist."

		doWGet "${sourceurl}" "${targetdir}" "${args}"
	else
		downloadmsg "Artifact ${artifact} already exists"
	fi
}
