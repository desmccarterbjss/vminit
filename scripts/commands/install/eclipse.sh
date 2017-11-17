. ${PROVISION_SCRIPTS_FOLDER}/provisionutils.sh

function runPostInstall(){

        artifactname="$1"

        sourceurl="`getArtifactGetPropertyValue ${artifactname} url`"

        targetdir="`getArtifactGetPropertyValue ${artifactname} dir`"

        artifact="`getFilenameFromUrl ${sourceurl}`"

        unzipdir=`getPropertyValue "${artifactname}.unzip.dir"`

	operatingsystem=$(getPropertyValue "${artifactname}.operatingsystem")

	if [[ -z "${operatingsystem}" ]]
	then
		error "Please specify either 'linux' or 'win32' for ${artifactname}.operatingsystem"
		return 1
	fi	

	case $operatingsystem in
		"linux") o1=$operatingsystem;;
		"win32") o1=$operatingsystem;;
	esac

	if [[ -z "${unzipdir}" ]]
	then
		error "${artifactname}.unzip.dir property not set. Please set this property to the output of install"
		return 1
	fi

	mirror="http://mirror.cc.columbia.edu/pub/software/eclipse/eclipse/downloads"

	release=$(curl -a http://download.eclipse.org/eclipse/downloads/ 2>/dev/null | sed -n s/"^.*a[ ]*href=\"\([^\"]*\)\".*title=\"Latest Release.*$"/"\1"/p)

	artifact=$(curl -a http://download.eclipse.org/eclipse/downloads/${release} 2>/dev/null | grep eclipse-platform | sed s/"^.*>\([^<]*\)<\/a.*$"/"\1"/g | grep $o1 | grep "x86_64")

	info $artifact

	curl -a ${mirror}/${release}/${artifact} > /tmp/${artifact}

	prevdir="`pwd`"

	mkdir -p $unzipdir

	extension=$(echo ${artifact} | sed s/"^.*\.\([a-z|A-Z]*\)$"/"\1"/g)

	if [[ "${extension}" == "gz" ]]
	then
		cd "${unzipdir}"

		tar -zxvf /tmp/${artifact}

		cd "${prevdir}"
	elif [[ "${extension}" == "zip" ]]
	then
		unzip -d "${unzipdir}" -o /tmp/${artifact} 
	else
		error "Unknown archive type ${extension}"
		return 1
	fi
}
