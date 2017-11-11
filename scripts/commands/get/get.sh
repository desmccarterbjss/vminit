
# Extracts the source URL

. ${PROVISION_SCRIPTS_FOLDER}/utils.sh

function run(){

artifactname="$1"
artifactnamel="`propertyToLinux ${artifactname}`"

targetdir="`getPropertyValue ${artifactnamel}.wget.dir`"

sourceurl="`getPropertyValue ${artifactnamel}.wget.url`"

args="`getPropertyValue ${artifactnamel}.wget.args`"

artifact="`getFilenameFromUrl ${sourceurl}`"

installtype="`getPropertyValue ${artifactname}.install.type`"

	if [[ ! -z "${sourceurl}" ]]
	then
		if [[ ! -f "${targetdir}/${artifact}" ]]
		then
			info "${targetdir}/${artifact} does not exist."

			doWGet "${sourceurl}" "${targetdir}" "${args}"
		else
			downloadmsg "Artifact ${artifact} already exists"
		fi
	elif [[ ! -z "${installtype}" ]]
	then
		script="${PROVISION_SCRIPTS_FOLDER}/get/${artifactname}.sh"

		if [[ -f "${script}" ]]	
		then
			. ${script}

			run "${artifactname}"
		else
			error "Set-up (get) script does not exist for ${artifactname}"

			return 1
		fi
	else
		error "No source URL given nor ${artifactname}.install.type set in properties file for ${artifactname}"

		return 1
	fi
}
