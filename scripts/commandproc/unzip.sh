. ${PROVISION_SCRIPTS_FOLDER}/utils.sh

function run(){

artifactname="$1"
propertiesfile="$2"

artifact=`getPropertyValue "${artifactname}.url" ${propertiesfile} | sed s/"^.*\/\([^\/]*\)$"/"\1"/g`

targetdir=`getPropertyValue "${artifactname}.url" ${propertiesfile} | sed s/"^.*\/\([^\/]*\)$"/"\1"/g`
unzipdir=`getPropertyValue "${artifactname}.unzip.dir" "${propertiesfile}"`

	unzipmsg "Extracting ${artifact} ..."

	if [[ ! -z "${unzipdir}" ]]
	then
		unzip -o ${targetdir}/${artifact} -d "${unzipdir}" >/tmp/${artifact}_unzip.txt 2>/dev/null
	else
		unzip -o ${targetdir}/${artifact} >/tmp/${artifact}_unzip.txt 2>/dev/null
	fi

	unzipmsg "Extraction of ${artifact} complete."
}
