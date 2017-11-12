
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

	if [[ -z "${unzipdir}" ]]
	then
		error "${artifactname}.unzip.dir property not set. Please set this property to the output of install"
		return 1
	fi

	# Find out if JAVA_HOME already exists in ~/.bashrc. If so then replace it with new JAVA_HOME.
	# If JAVA_HOME does not exist, then simply append the export to ~/.bashrc ...

        mavenfolder="`tar -tzf ${targetdir}/${artifact} | sed -n s/'^\([^\/]*\)\/README.*$'/'\1'/p 2>/dev/null`"

	if [[ -f ~/.bashrc ]]
	then
		jhome="`cat ~/.bashrc | grep '^[ |	]*export[ |	]*MAVEN_HOME'`"

		if [[ ! -z "${jhome}" ]]
		then

			info "Maven root folder is ${mavenfolder}"

			if [[ "$?" != "0" ]]
			then
				error "Failed to locate Maven folder from archive"
				return 1
			fi

			unzipdiresc="`echo ${unzipdir} | sed s/'\/'/'<delimiter>'/g`"

			sedtext="s/\(^[ |	]*export[ |	]*MAVEN_HOME=\).*$/\1$unzipdiresc\/$mavenfolder/g"

			sed "$sedtext" ~/.bashrc | sed s/"<delimiter>"/"\/"/g > /tmp/bashrcnew

			mv /tmp/bashrcnew ~/.bashrc
		else
			echo "export MAVEN_HOME=$unzipdir/$mavenfolder" >> ~/.bashrc
			echo "export PATH=\"\${MAVEN_HOME}/bin:\${PATH}\"" >> ~/.bashrc
		fi
	else
		echo "export MAVEN_HOME=$unzipdir/$mavenfolder" >> ~/.bashrc
		echo "export PATH=\"\${MAVEN_HOME}/bin:\${PATH}\"" >> ~/.bashrc
	fi
}
