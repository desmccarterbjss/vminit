# AUTHOR 	: Des McCarter @ BJSS
# DATE		: 12/09/2017
# DESCRIPTION	: This script needs to be executed (only once) 
#		  once you have cloned the Royal Mail Test Project

BASHRC="~/.bashrc"

function VerifyLocation(){

	CURRENT_FOLDER="`pwd`"

	THIS_SCRIPT="`basename ${1}`"	

	if [[ ! -f ${THIS_SCRIPT} ]]
	then
		echo "[ERR] Please re-run ${THIS_SCRIPT} from the scripts folder"
		exit 1
	fi
}

# Set the scripts folder in 
# PATH in bashrc ...

function GetProvisionScriptsFolderExport(){
	cat ~/.bashrc | grep "^export[ ]*PROVISION_SCRIPTS_FOLDER" | grep "${PROVISION_SCRIPTS_FOLDER}"
}

PROVISION_SCRIPTS_FOLDER_EXPORT="`GetProvisionScriptsFolderExport`"

# START HERE ...

VerifyLocation "${0}"

# import utils ...

. ./utils.sh

# Add export of PROVISION_SCRIPTS_FOLDER
# to ~/.bashrc ...

if [ "a${PROVISION_SCRIPTS_FOLDER_EXPORT}" = "a" ]
then
	info "Updating ~/bashrc with PROVISION_SCRIPTS_FOLDER variable ..."

	echo "export PROVISION_SCRIPTS_FOLDER=\"`pwd`\"" >> ~/.bashrc

	completed "Updated ~/bashrc with PROVISION_SCRIPTS_FOLDER variable."
else
	info "~/.bash already contains PROVISION_SCRIPTS_FOLDER"
fi
