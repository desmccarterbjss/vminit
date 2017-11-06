#!/bin/bash

SETUP_FILE="setup.csv"

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

function downloadWithmaven(){

	url="$1"
	artifactid="$2"
	version="$3"
	targetfolder="$4"

	echo $url
	echo $artifactid
	echo $version
	echo $targetfolder

}

function getUrl(){

	line="$1"

	echo "${line}" | sed s/"^\([^,]*\).*$"/"\1"/g
}

function getArtifactId(){

	line="$1"

	echo "${line}" | sed s/"^[^,]*,\([^,]*\).*$"/"\1"/g
}

function getVersion(){

	line="$1"

	echo "${line}" | sed s/"^[^,]*,[^,]*,\([^,]*\).*$"/"\1"/g
}

function getDownloadFunction(){

	line="$1"

	echo "${line}" | sed s/"^[^,]*,[^,]*,[^,]*,\([^,]*\).*$"/"\1"/g
}

function getTargetFolder(){

	line="$1"

	echo "${line}" | sed s/"^[^,]*,[^,]*,[^,]*,[^,]*,\([^,]*\).*$"/"\1"/g
}

function processSetupFile(){

	file="$1"

	IFS=$'\n'

	for line in `cat ${file}`
	do
		URL=`getUrl ${line}`
		ARTIFACT_ID=`getArtifactId ${line}`
		VERSION=`getVersion ${line}`
		DOWNLOAD_FUNCTION="downloadWith`getDownloadFunction ${line}`"
		TARGET_FOLDER="`getTargetFolder ${line}`"

		$DOWNLOAD_FUNCTION "${URL}" "${ARTIFACT_ID}" "${VERSION}" "${TARGET_FOLDER}" "${TARGET_FOLDER}"
	done
}

verifyFileExists "${SETUP_FILE}"

processSetupFile "${SETUP_FILE}"
