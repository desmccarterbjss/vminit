. ${PROVISION_SCRIPTS_FOLDER}/utils.sh

function runPostInstall(){

        artifactname="$1"

        for gettype in $GET_TYPES
        do
                url=`getPropertyValue "${artifactname}.${gettype}.url"`
                targetdir=`getPropertyValue "${artifactname}.${gettype}.dir"`

                if [[ ! -z "${url}" ]]
                then
                        break;
                fi
        done

        artifact=`echo "${url}" | sed s/"^.*\/\([^\/]*\)$"/"\1"/g`

	unzipdir=`getPropertyValue "${artifactname}.unzip.dir"`

	script="${PROVISION_SCRIPTS_FOLDER}/commands/install/ubuntu${artifactname}.sh"

	if [[ ! -f "${script}" ]]
	then
		error "No script defined for ubuntu ${artifactname}"
		return 1
	fi

	. ${script}

	runPostInstall ${artifactname}

	if [[ "${?}" != "0" ]]
	then
		error "ERROR Setting up ${artifactname}, specifically for ubuntu"

		return 1
	else
		info "Successfully setup ${artifactname}, specifically for ubuntu"
	fi

	return 0
}
