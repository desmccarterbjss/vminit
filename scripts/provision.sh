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

function processSetupFile(){

	file="$1"

	IFS=$'\n'

	for line in `cat ${file}`
	do
		echo "URL=`getUrl ${line}`"
		echo "ARTIFACT_ID=`getArtifactId ${line}`"
		echo "VERSION=`getVersion ${line}`"
		echo "DOWNLOAD_FUNCTION=`getDownloadFunction ${line}`"
	done
}

verifyFileExists "${SETUP_FILE}"

processSetupFile "${SETUP_FILE}"
