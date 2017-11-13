. ${PROVISION_SCRIPTS_FOLDER}/provisionutils.sh

function runPostInstall(){

        artifactname="$1"

        sourceurl="`getArtifactGetPropertyValue ${artifactname} url`"

        targetdir="`getArtifactGetPropertyValue ${artifactname} dir`"

        artifact="`getFilenameFromUrl ${sourceurl}`"

	unzipdir=`getPropertyValue "${artifactname}.unzip.dir"`

	if [[ -z "${unzipdir}" ]]
	then
		error "${artifactname}.unzip.dir property not set. Please set this property to the output of install"
		return 1
	fi

        javafolder="`tar -tzf ${targetdir}/${artifact} | sed -n s/'^\([^\/]*\)\/README.*$'/'\1'/p 2>/dev/null`"

	filetoedit="~/.bashrc"

	updateEnvironmentVariable "JAVA_HOME" "${unzipdir}/${javafolder}" "${filetoedit}"

	if [[ "$?" == "10" ]]
	then
		appendEnvironmentVariable "PATH" "\"\${JAVA_HOME}/bin:\${PATH}\"" "${filetoedit}"
	fi

	updateEnvironmentVariable "JRE_HOME" "${unzipdir}/${javafolder}/123test" "${filetoedit}"

	info "update-alternatives --install ..."

	sudo update-alternatives --install "/usr/bin/java" "java" "${unzipdir}/${javafolder}/jre/bin/java" 1

	info "update-alternatives --set ..."

	sudo update-alternatives --set "java" "${unzipdir}/${javafolder}/jre/bin/java"
}
