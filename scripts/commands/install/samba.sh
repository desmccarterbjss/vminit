#!/bin/bash

. ${PROVISION_SCRIPTS_FOLDER}/provisionutils.sh

function runPostInstall(){

	artifactname="$1"

	sambaconf=/etc/samba/smb.conf

	if [[ ! -f "${sambaconf}" ]]
	then
		error "ERROR ${sambaconf} does not exist. Terminating samba install"
		return 1
	fi

	propertynames="`getPropertyNames -all \"${PROPERTIES_FILE}\"`"

	unset IFS

	for propname in $propertynames
	do
		sambadef=`echo $propname | sed -n s/"^$artifactname\.\([^\.]*\)\.exposefolder$"/"\1"/p`

		if [[ ! -z $sambadef ]]
		then
			sambadefexists=`sed -n s/"^\([ |	]*\[[ |	]*$sambadef[ |	]*\][ |	]*\)$"/"\1"/p ${sambaconf}`

			if [[ -z "${sambadefexists}" ]]
			then
				exposedfolderpath="`getPropertyValue ${propname}`"

				tempfile="/tmp/sambatext.txt" 

				> ${tempfile}

				if [[ "$?" != 0 ]]
				then
					error "Failed to create SAMBA temp file ${tempfile}"
					return 1
				fi
	
				echo "[$sambadef]" >> ${tempfile}
				echo "   comment = $sambadef - Publically exposed foler" >> ${tempfile}
				echo "   path = $exposedfolderpath" >> ${tempfile}
				echo "   browseable = yes" >> ${tempfile}
				echo "   read only = no" >> ${tempfile}
				echo "   guest ok = no" >> ${tempfile}
	
				echo "cat ${tempfile} >> ${sambaconf}" >> /tmp/docat.sh && chmod 755 /tmp/docat.sh
	
				sudo /tmp/docat.sh

				info "Updated ${sambaconf} as ${sambadef} based on .exposefolder for artifact ${artifact}"
			else
				info "WARNING - Samba entry exists for ${sambadef}. Ignoring .exposefolder for artifact ${artifact}"
			fi

			break;
		fi
	done
}

