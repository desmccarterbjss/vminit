# Extracts the source URL

. ${PROVISION_SCRIPTS_FOLDER}/utils.sh

export GET_TYPES="wget curl"

function run(){

	artifactname="$1"
	artifactnamel="`propertyToLinux ${artifactname}`"

	unset GET_TYPE
	unset IFS

	for gettype in ${GET_TYPES}
	do	
		sourceurl="`getPropertyValue ${artifactnamel}.${gettype}.url`"

		if [ ! -z "${sourceurl}" ]
		then
			targetdir="`getPropertyValue ${artifactnamel}.${gettype}.dir`"
			args="`getPropertyValue ${artifactnamel}.${gettype}.args`"

			GET_TYPE=$gettype

			debug "Using '$GET_TYPE' to retreive artifact"

			break
		fi
	done

	artifact="`getFilenameFromUrl ${sourceurl}`"

	installtype="`getPropertyValue ${artifactname}.install.type`"

	if [[ ! -z "${GET_TYPE}" ]]
	then
		if [[ ! -f "${targetdir}/${artifact}" ]]
		then
			info "${targetdir}/${artifact} does not exist."

			execute${GET_TYPE} "${sourceurl}" "${targetdir}" "${args}"
		else
			downloadmsg "Artifact ${artifact} already exists"
		fi
	elif [[ ! -z "${installtype}" ]]
	then
		script="${PROVISION_SCRIPTS_FOLDER}/commands/get/${artifactname}.sh"

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
