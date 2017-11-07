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

	if [[ ! -f ${file} ]]
	then
		return
	fi

	sed -n s/"^[ |	]*$name=\(.*\)$"/"\1"/p ${file}
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

        sed -n s/"^[ |  ]*$name\.\([^=]*\).*$"/"\1"/p ${file}
}
