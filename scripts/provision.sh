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
	file="$2"

	if [[ -z ${command} ]]
	then
		error "COMMAND not given"
		exit 1
	fi

	if [[ ! -f ${file} ]]
	then
		error "Setup file does not exist"
		exit 1
	fi

	if [[ ! -f "${PROVISION_SCRIPTS_FOLDER}/commandexpr/${command}.sed" ]]
	then	
		error "Invalid command ${command}"
	else
		propertynamearg=`sed -n -f "${PROVISION_SCRIPTS_FOLDER}/commandexpr/${command}.sed" "${file}"`

		debug "Property Name Arg is [${propertynamearg}]"

		url=`getPropertyValue "${propertynamearg}.source.url" provision.properties`

		targetdir=`getPropertyValue "${propertynamearg}.target.dir" provision.properties`
		targetdir="`eval echo ${targetdir}`"

		# Attenpt to doenload using wget ...

		artifact="`echo ${url} | sed s/'^.*\/\([^\/]*\)$'/'\1'/g`"

		if [[ ! -f "${targetdir}/${artifact}" ]]
		then
			doWGet "${url}" "${targetdir}"
		else
			downloadmsg "Artifact ${artifact} already exists"
		fi
	
		IFS=$'\n'

		for propnamesuffix in `getPropertyNames "${propertynamearg}" "provision.properties"`
		do
			if [[ "${propnamesuffix}" == "unzip.dir" ]]
			then
				UNZIP_DIR="`getPropertyValue ${propertynamearg}.${propnamesuffix} 'provision.properties'`"
				UNZIP_DIR="`eval echo ${UNZIP_DIR}`"
			elif [[ "${propnamesuffix}" == "unzip" ]]
			then
				UNZIP_OK="`getPropertyValue ${propertynamearg}.${propnamesuffix} 'provision.properties'`"
			fi	
		done

		if [[ "${UNZIP_OK}" == "true" ]]
		then
			if [[ ! -z "${UNZIP_DIR}" ]]
			then
				unzip ${targetdir}/${artifact} -d "${UNZIP_DIR}"
			else
				unzip ${targetdir}/${artifact}
			fi
		fi
	fi
}

function processSetupFile(){

	file="$1"

	IFS=$'\n'

	for line in `cat ${file}`
	do
		command=`getCommand ${line}`

		validateExpression ${command} ${file}
	done
}

processArgs ${ARGS}

verifyArgs

verifyFileExists "${SETUP_FILE}"

processSetupFile "${SETUP_FILE}"
