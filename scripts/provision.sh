#!/bin/bash

ARGS="${*}"

# Make sure scripts folder var is defined ...

if [[ -z "${PROVISION_SCRIPTS_FOLDER}" ]]
then
	echo "[ERR] PROVISION_SCRIPTS_FOLDER has not been defined. Please run init.sh and run THIS script again"
	exit 1
fi

# Make sure scripts folder exists ...

if [[ ! -f "${PROVISION_SCRIPTS_FOLDER}/utils.sh" ]]
then
	echo "[ERR] Cannot find utils.sh. Please make sure the PROVISION_SCRIPTS_FOLDER variable is set correctly (run/re-run init.sh if needbe)"
	exit 1
fi

# Import utils ...

. ${PROVISION_SCRIPTS_FOLDER}/utils.sh

function processArgs(){

	while [[ ! -z "$1" ]]
	do
		if [[ "${1}" == "-setupfile" ]]
		then
			shift

			if [[ -z "${1}" ]]
			then
				error "-setupfile requires an argument"
				usage
				exit 1
			fi

			SETUP_FILE="${1}"
		fi

		shift
	done
}

function usage(){

	usagemsg "`basename ${0}` -setupfile <the setup file>"
}

function verifyArgs(){

	if [[ -z "${SETUP_FILE}" ]]
	then
		error "Setup file not given"
		exit 1
	fi
}

function verifyFileExists(){

	file="$1"

	# Check filename given ...

	if [[ -z "${file}" ]]
	then
		error "File not supplied."

		usage

		exit 1

	fi

	# Make sure file exists ...

	if [[ ! -f "${file}" ]]
	then
		echo "[ERR] Setup file ${file} does not exist!"

		usage

		exit 1
	fi
}

function downloadWithwget(){

	url="$1"
	targetfolder="$2"

	if [ ! -d "${targetfolder}" ]
	then
		mkdir -p "${targetfolder}"

		info "Created target folder ${targetfolder}"
	fi

	file="`echo ${url} | sed s/'^.*\/\([^\/]*\)$'/'\1'/g`"

	if [ ! -f "${targetfolder}/${file}" ]
	then
		wget "${url}" -P "${targetfolder}"
	fi
}

function getCommand(){

	line="$1"

	echo "${line}" | sed s/"^\([^ |	]*\).*$"/"\1"/g
}

function getArgument(){

	line="$1"

	echo "${line}" | sed s/"^[^ |	]*\(.*\)$"/"\1"/g
}

function getDownloadFunction(){

	line="$1"

	echo "${line}" | sed s/"^[^,]*,\([^,]*\).*$"/"\1"/g
}

function getTargetFolder(){

	line="$1"

	echo "${line}" | sed s/"^[^,]*,[^,]*,\([^,]*\).*$"/"\1"/g
}

function validateExpression(){

	command="$1"

	if [[ -z ${command} ]]
	then
		error "COMMAND not given"
		exit 1
	fi

	line="$2"

	if [[ -z ${line} ]]
	then
		error "'LINE' not given"
		exit 1
	fi

	setupfile="$3"

	if [[ ! -f ${setupfile} ]]
	then
		error "Setup file '${setupfile}' does not exist"
		exit 1
	fi

	commanddir="${PROVISION_SCRIPTS_FOLDER}/commands/${command}"

	if [[ ! -d "${commanddir}" ]]
	then
		error "Unknown command[1] '${command}' found in setup script ${setupfile}"
		exit 1
	fi
	
	if [[ ! -f "${commanddir}/${command}.sed" ]]
	then
		error "Unknown command[2] '${command}' found in setup script ${setupfile}"
		exit 1
	fi

	sedresult=`echo ${line} | sed -n -f "${PROVISION_SCRIPTS_FOLDER}/commands/${command}/${command}.sed"`

	echo ${sedresult}
}


function importProperties(){

	artifactname="${1}"

	for propname in `getPropertyNames "-all" "provision.properties"`
	do
		varname="`echo ${propname} | sed s/'[\.|\-]*'/''/g`"

		export $varname="`getPropertyValue ${propname} 'provision.properties'`"

		export ${varname}="`eval echo ${!varname}`"

		debug "${varname} = ${!varname}"
	done
}

function processValidatedExpression(){

command="${1}"
file="${2}"

shift
shift

validatedExpresssionResult="${*}"

	executionscript="${PROVISION_SCRIPTS_FOLDER}/commands/${command}/${command}.sh"

	if [[ ! -f "${executionscript}" ]]
	then	
		error "Cannot find execution command for ${command}"

		return 1
	else
		. "${executionscript}"

		run ${validatedExpresssionResult}

		if [[ "$?" != "0" ]]
		then
			return 1
		else
			return 0
		fi
	fi
}

function processSetupFile(){

	# Import all properties ...

	importProperties

	# Validate expressions and execute them ...

	SETUP_FILE="$1"

	IFS=$'\n'

	for line in `cat ${SETUP_FILE}`
	do
		command=`getCommand ${line}`

		validatedExpression="`validateExpression "${command}" "${line}" ${SETUP_FILE}`"

		if [[ -z "${validatedExpression}" ]]
		then
			error "Unknown command '${command}' expressed in set-up file ${SETUP_FILE}"

			exit 1
		fi

		info "Executing	'${line}' ..."

		processValidatedExpression "${command}" "${SETUP_FILE}" ${validatedExpression}

		if [[ "$?" != "0" ]]
		then
			error "Execution of '${line}' failed. Stopping setup."

			exit 1
		fi

		info "Execution of '${line}' was successful."
	done
}

processArgs ${ARGS}

verifyArgs

verifyFileExists "${SETUP_FILE}"

processSetupFile "${SETUP_FILE}"
