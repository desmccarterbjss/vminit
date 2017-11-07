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

function getUrl(){

	line="$1"

	echo "${line}" | sed s/"^\([^,]*\).*$"/"\1"/g
}

function getDownloadFunction(){

	line="$1"

	echo "${line}" | sed s/"^[^,]*,\([^,]*\).*$"/"\1"/g
}

function getTargetFolder(){

	line="$1"

	echo "${line}" | sed s/"^[^,]*,[^,]*,\([^,]*\).*$"/"\1"/g
}

function processSetupFile(){

	file="$1"

	IFS=$'\n'

	for line in `cat ${file}`
	do
		URL=`getUrl ${line}`
		DOWNLOAD_FUNCTION="downloadWith`getDownloadFunction ${line}`"
		TARGET_FOLDER="`getTargetFolder ${line}`"

		$DOWNLOAD_FUNCTION "${URL}" "${TARGET_FOLDER}"
	done
}

processArgs ${ARGS}

verifyArgs

verifyFileExists "${SETUP_FILE}"

exit 0

processSetupFile "${SETUP_FILE}"
