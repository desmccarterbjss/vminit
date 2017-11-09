
# Extracts the source URL

. ${PROVISION_SCRIPTS_FOLDER}/utils.sh

function run(){

artifactname="$1"
artifactnamel="`propertyToLinux ${artifactname}`"

targetdir="`getPropertyValue ${artifactnamel}.target.dir`"

sourceurl="`getPropertyValue ${artifactnamel}.source.url`"

artifact="`getFilenameFromUrl ${sourceurl}`"

	if [[ ! -f "${targetdir}/${artifact}" ]]
	then
		info "${targetdir}/${artifact} does not exist."

		doWGet "${sourceurl}" "${targetdir}"
	else
		downloadmsg "Artifact ${artifact} already exists"
	fi
}
