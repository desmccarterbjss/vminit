##
# @info     returns the current os enum [WINDOWS/MAC/LINUX]
# @param    na
# @return   os enum [WINDOWS , MAC , LINUX]
##

function getOs()
{
    local _ossig=`uname -s 2> /dev/null | tr "[:upper:]" "[:lower:]" 2> /dev/null`
    local _os_base="UNKNOWN"

    case "$_ossig" in
        *windowsnt*)_os_base="WINDOWS";;
        *darwin*)   _os_base="MAC";;
        *linux*)    
                    if [ -f /etc/redhat-release ] ; then
                        _os_base="LINUX-REDHAT"
                    elif [ -f /etc/SuSE-release ] ; then
                        _os_base="LINUX-SUSE"
                    elif [ -f /etc/mandrake-release ] ; then
                        _os_base="LINUX-MANDRAKE"
                    elif [ -f /etc/debian_version ] ; then
                        _os_base="LINUX-DEBIAN"             
                    else
                        _os_base="LINUX"            
                    fi
            ;;
        *)          _os_base="UNKNOWN";;
    esac

    echo $_os_base
}


function getRootFolderFromTarArchive(){

	if [[ -z "${1}" ]]
	then
		error "You need to specify the artifact location"
		return 1
	fi

	artifactlocation="$1"

        tar -tzf ${artifactlocation} | sed -n s/'^\([^\/]*\)\/README.*$'/'\1'/p 2>/dev/null
}

function appendEnvironmentVariable(){

	variablename="$1"

	variablevalue="$2"

	filetoedit="$3"

	if [[ -f "`eval echo $filetoedit`" ]]
	then
		echo "export $variablename=$variablevalue" >> ~/.bashrc
			
		info "Created $variablename=$variablevalue"
	else
		echo "export $variablename=$variablevalue" >> ~/.bashrc
			
		info "set $variablename=$variablevalue"
	fi
}

function updateEnvironmentVariable(){

	variablename="$1"

	variablevalue="$2"

	filetoedit="$3"

	created="-10"

	if [[ -f "`eval echo $filetoedit`" ]]
	then
		jhome=`cat ~/.bashrc | grep "^[ |	]*export[ |	]*$variablename="`

		if [[ ! -z "${jhome}" ]]
		then
			info "Environment variable ${variablename} has already been set in ${filetoedit}"

			exportdiresc="`echo ${variablevalue} | sed s/'\/'/'<delimiter>'/g`"

			sedtext="s/\(^[ |	]*export[ |	]*$variablename=\).*$/\1$exportdiresc/g"

			sed "$sedtext" ~/.bashrc | sed s/"<delimiter>"/"\/"/g > /tmp/bashrcnew

			mv /tmp/bashrcnew ~/.bashrc

			info "set $variablename=$variablevalue"
		else
			created="10"

			echo "export $variablename=$variablevalue" >> ~/.bashrc
			
			info "set $variablename=$variablevalue"
		fi
	else
		created="10"

		echo "export $variablename=$variablevalue" >> ~/.bashrc
			
		info "set $variablename=$variablevalue"
	fi

	return $created
}

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

function executewget(){

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

function executecurl(){

	if [[ -z ${1} ]]
	then
		error "URL not given for WGET"
		exit 1
	fi

	url="${1}"

	targetdir="${2}"

	shift;shift

	args=${*}

	outputfile="`echo $url | sed s/'^.*\/\([^\/]*\)$'/'\1'/g`"

	eval curl ${args} -o "${targetdir}/${outputfile}" "${url}" 
}
