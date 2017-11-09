. ${PROVISION_SCRIPTS_FOLDER}/utils.sh

function run(){

artifactname="$1"

echo a=$artifactname

artifact=`getPropertyValue "${artifactname}.source.url" | sed s/"^.*\/\([^\/]*\)$"/"\1"/g`

targetdir=`getPropertyValue "${artifactname}.target.dir"`
unzipdir=`getPropertyValue "${artifactname}.unzip.dir"`
echo $unzipdir $targetdir

	unzipmsg "Extracting ${artifact} ..."

	if [[ ! -z "${unzipdir}" ]]
	then
		unzip -o ${targetdir}/${artifact} -d "${unzipdir}" >/tmp/${artifact}_unzip.txt 2>/tmp/${artifact}_unzip_error.txt
	else
		unzip -o ${targetdir}/${artifact} >/tmp/${artifact}_unzip.txt 2>/tmp/${artifact}_unzip_error.txt
	fi

	if [[ "$?" == "0" ]]
	then
		unzipmsg "Extraction of ${artifact} complete."
	else
		error "Extraction of ${artifact} FAILED."
	fi
}
