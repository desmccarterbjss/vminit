. ${PROVISION_SCRIPTS_FOLDER}/utils.sh

function runPostInstall(){

	debug "sudo apt-get install samba"

	sudo apt-get install samba

	if [[ "$?" != 0 ]]
	then
		error "Failed sudo apt-get install samba"

		return 1
	fi

}
