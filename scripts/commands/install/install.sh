. ${PROVISION_SCRIPTS_FOLDER}/utils.sh

function run(){

artifactname="$1"

artifact=`getPropertyValue "${artifactname}.wget.url" | sed s/"^.*\/\([^\/]*\)$"/"\1"/g`
artifactextension="`echo ${artifact} | sed s/'^.*\.\([^\.]*\)$'/'\1'/g`"

echo ext=$artifactextension

if [[ -z "${artifact}" ]]
then
	error "Artifact source URL (${artifactname}.wget.url) (for artifact ${artifactname}) not defined in property file"
	return 1
else

	targetdir=`getPropertyValue "${artifactname}.wget.dir"`
	unzipdir=`getPropertyValue "${artifactname}.unzip.dir"`

	if [[ -z "${unzipdir}" ]]
	then
		error "${artifactname}.unzip.dir property not set. Please set this property to the output of install"
		return 1
	fi

	unzipmsg "Extracting ${artifact} to ${unzipdir} ..."

	if [[ "${artifactextension}" == "gz" ]]
	then
		artifact_real_extension="`echo ${artifact} | sed s/'^.*\.\([^\.]*\)\.[^\.]*$'/'\1'/g`"

		if [[ ! -z ${artifact_real_extension} ]]
		then 
			if [[ ${artifact_real_extension} == "tar" ]]
			then

				if [[ ! -d "${unzipdir}" ]]
				then
					mkdir -p "${unzipdir}"
				
					if [[ "$?" != "0" ]]
					then
						error "Failed to create output directory ${unzipdir}"
						return 1
					fi
				fi

				cd ${unzipdir}

				if [[ "$?" != "0" ]]
				then
					error "Failed to change directory to ${unzipdir}"
					return 1
				fi

				tar -xvzf ${targetdir}/${artifact} > /dev/null 2>&1

				if [[ "$?" != "0" ]]
				then
					error "Extraction of ${artifact} to ${unzipdir} failed."
					return 1
				fi

				cd -
			fi
		fi

	elif [[ "${artifactextension}" == "zip" ]]
	then
		if [[ ! -z "${unzipdir}" ]]
		then
			unzip -o ${targetdir}/${artifact} -d "${unzipdir}" >/tmp/${artifact}_unzip.txt 2>/tmp/${artifact}_unzip_error.txt
		else
			unzip -o ${targetdir}/${artifact} >/tmp/${artifact}_unzip.txt 2>/tmp/${artifact}_unzip_error.txt
		fi
	fi

	if [[ "$?" == "0" ]]
	then
		unzipmsg "Extraction of ${artifact} complete."

		return 0
	else
		error "Extraction of ${artifact} FAILED."
	
		return 1
	fi
fi
}
