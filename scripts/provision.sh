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

function getDownloadFunction(){

	line="$1"

	echo "${line}" | sed s/"^[^,]*,\([^,]*\).*$"/"\1"/g
}

function getTargetFolder(){

	line="$1"

	echo "${line}" | sed s/"^[^,]*,[^,]*,\([^,]*\).*$"/"\1"/g
}

function doWGet(){

	if [[ -z ${1} ]]
	then
		error "URL not given for WGET"
		exit 1
	fi

	url="${1}"

	targetdir="${2}"

	if [[ ! -z "${targetdir}" ]]
	then
		wget "${url}" -P "${targetdir}"
	else
		wget "${url}" -P ~
	fi
}

function commandunzipdir(){

echo
}


function validateExpression(){

	command="$1"

	if [[ -z ${command} ]]
	then
		error "COMMAND not given"
		exit 1
	fi

	file="$2"

	if [[ ! -f ${file} ]]
	then
		error "Setup file does not exist"
		exit 1
	fi

	commanddir="${PROVISION_SCRIPTS_FOLDER}/commands/${command}"

	if [[ ! -d "${commanddir}" ]]
	then
		error "Unknown command '${command}' found in setup script ${file}"
		exit 1
	fi
	
	sedresult=`sed -n -f "${PROVISION_SCRIPTS_FOLDER}/commands/${command}/${command}.sed" "${file}"`

	echo ${sedresult}
}


function importProperties(){

	for propnamesuffix in `getPropertyNames "${artifactname}" "provision.properties"`
	do
		commandscript="${PROVISION_SCRIPTS_FOLDER}/commandproc/${command}/`echo ${propnamesuffix} | sed s/"\."/""/g`.sh"

		echo c=$commandscript

		if [[ ! -f "${commandscript}" ]]
		then
			echo p=$propnamesuffix

			exit 1
		fi

		. ${commandscript} 

		runfunction=run

		${runfunction} "${artifactname}" "provision.properties"
	done
}

function processValidatedExpression(){

command="${1}"
file="${2}"

shift
shift

validatedExpresssion="${*}"

echo "${validatedExpressionResult}"

	executionscript="${PROVISION_SCRIPTS_FOLDER}/commands/${command}/${command}.sh"

	if [[ ! -f "${executionscript}" ]]
	then	
		error "Cannot find execution command for ${command}"
	else

		debug "Executing ${command} ..."

		. "${executionscript}" ${validatedExpressionResult}


		run

		exit 1

		debug "Executed ${command} ..."

	fi
}

function processSetupFile(){

	file="$1"

	IFS=$'\n'

	for line in `cat ${file}`
	do
		command=`getCommand ${line}`

		validatedExpression="`validateExpression ${command} ${file}`"

		if [[ -z "${validatedExpression}" ]]
		then
			error "Unknown command '${command}' expressed in set-up file ${file}"

			exit 1
		fi

		processValidatedExpression "${command}" "${file}" ${validatedExpression}
	done
}

processArgs ${ARGS}

verifyArgs

verifyFileExists "${SETUP_FILE}"

processSetupFile "${SETUP_FILE}"
