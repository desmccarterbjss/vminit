function writeToStdout(){

	prefix="${1}"

	text="${2}"

	snapshotdate="`date +\"%d-%m-%Y %H:%M:%S\"`"

	printf "[%-20s %-18s] %-40s\n" "${prefix}" "${snapshotdate}" "${text}"
}

function info(){
	writeToStdout "INFO" "$1"
}

function debug(){
	writeToStdout "DEBUG" "$1"
}

function error(){
	writeToStdout "ERR" "$1"
}

function completed(){
	writeToStdout "DONE" "$1"
}

function usagemsg(){
	writeToStdout "USAGE" "$1"
}

function downloadmsg(){
	writeToStdout "DOWNLOAD" "$1"
}

function unzipmsg(){
	writeToStdout "UNZIP" "$1"
}

function getPropertyValue(){

	name="$1"
	file="$2"

	if [[ -z ${name} ]]
	then
		return
	fi

	if [[ ! -z "${file}" ]]
	then
		if [[ ! -f ${file} ]]
		then
			return
		fi

		sed -n s/"^[ |	]*$name=\(.*\)$"/"\1"/p ${file}
	else
		getPropertyValueFromBashVariable "${name}"
	fi
}

function getPropertyNames(){

        name="$1"
        file="$2"

	if [[ -z ${name} ]]
	then
		return
	fi
	
	if [[ ! -f ${file} ]]
	then
		return
	fi

	if [[ "${name}" == "-all" ]]
	then
		sed -n s/"^[ |	]*\([^\=]*\)\=.*$"/"\1"/p "${file}"
	else
	        sed -n s/"^[ |  ]*$name\.\([^=]*\).*$"/"\1"/p ${file}
	fi
}

function propertyToLinux(){

	echo "${1}" | sed s/'[\.|-]'/''/g
}

function getFilenameFromUrl(){
	echo "${*}" | sed s/"^.*\/\([^\/]*\)$"/"\1"/g
}

function getPropertyValueFromBashVariable(){
	if [ ! -z ${1} ]
	then
		propertyname="${1}"
		propertynamebash=`propertyToLinux ${propertyname}`
		echo ${!propertynamebash}
	fi
}

function doWGet(){

	if [[ -z ${1} ]]
	then
		error "URL not given for WGET"
		exit 1
	fi

	url="${1}"

	targetdir="${2}"

	shift;shift

	args=${*}

	if [[ ! -z "${targetdir}" ]]
	then
		eval wget ${args} "${url}" -P "${targetdir}"
	else
		wget ${args} "${url}" -P ~
	fi
}
