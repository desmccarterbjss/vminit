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
