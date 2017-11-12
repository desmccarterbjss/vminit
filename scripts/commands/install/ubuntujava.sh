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

	# Find out if JAVA_HOME already exists in ~/.bashrc. If so then replace it with new JAVA_HOME.
	# If JAVA_HOME does not exist, then simply append the export to ~/.bashrc ...

	if [[ -f ~/.bashrc ]]
	then
		jhome="`cat ~/.bashrc | grep '^[ |	]*export[ |	]*JAVA_HOME'`"

		if [[ ! -z "${jhome}" ]]
		then
                        javafolder="`tar -tzf ${targetdir}/${artifact} | sed -n s/'^\([^\/]*\)\/README.*$'/'\1'/p 2>/dev/null`"

			info "Java root folder is ${javafolder}"

			if [[ "$?" != "0" ]]
			then
				error "Failed to locate Java folder from archive"
				return 1
			fi

			unzipdiresc="`echo ${unzipdir} | sed s/'\/'/'<delimiter>'/g`"

			sedtext="s/\(^[ |	]*export[ |	]*JAVA_HOME=\).*$/\1$unzipdiresc\/$javafolder/g"

			sed "$sedtext" ~/.bashrc | sed s/"<delimiter>"/"\/"/g > /tmp/bashrcnew

			mv /tmp/bashrcnew ~/.bashrc
		else
			echo "export JAVA_HOME=$unzipdir/$javafolder" >> ~/.bashrc
		fi
	else
		echo "export JAVA_HOME=$unzipdir" >> ~/.bashrc
	fi

	unzipdiresc="`echo ${unzipdiresc} | sed s/'<delimiter>'/'\/'/g`"

	# update UBUNTU alternatives ...
	sudo update-alternatives --install "/usr/bin/java" "java" "${unzipdiresc}/${javafolder}/jre/bin/java" 1

	sudo update-alternatives --set "java" "${unzipdiresc}/${javafolder}/jre/bin/java"
}
