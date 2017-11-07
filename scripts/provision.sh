#!/bin/bash

SETUP_FILE="provision.properties"

function usage(){

	echo "`basename ${0}`"
}

function verifyFileExists(){

	file="$1"

	# Check filename given ...

	if [[ -z "${file}" ]]
	then
		echo "[ERR] File not supplied."

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

verifyFileExists "${SETUP_FILE}"

processSetupFile "${SETUP_FILE}"
