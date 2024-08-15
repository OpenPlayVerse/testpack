#!/bin/bash

### conf ###
serverID="40d42383"
pterodactylURL="https://panel.openplayverse.net"
packURL="https://github.com/OpenPlayVerse/testpack/raw/main/"
apiTokenPath="/home/noname/.mmmtk/api.token"
sshKeyPath="~/.ssh/nnh-g-50_test-nopasswd"
sshTarget="test@192.168.4.150"
sshArgs=""
updateScriptArgs="-S"

### init ###
set -e
error() {
	echo "ERROR: something went wrong. abandon update." 
	exit 1
}
trap "error" ERR

### update ###
echo
echo "### Create packwiz aliases ###"
./tools/createPackwizAliases.sh \
	--pack-url $packURL \
	--input "files" \
	--output "./packwiz" \
	--list-file ".collectedFiles" \
	-R

echo "packwiz refresh"
cd packwiz
packwiz refresh
cd ..

echo
echo "### push to git ###"
git add .
git commit -m "TEST"
git push

echo
echo "### Update server ###"
./tools/updateServer.sh \
   --server-id $serverID \
   --pterodactyl-url $pterodactylURL \
   --pack-url "${packURL}/packwiz/pack.toml" \
   --token $apiTokenPath \
   --ssh-args="-i $sshKeyPath $sshTarget $sshArgs" \
   --update-script-args="$updateScriptArgs" \
	--no-backup \
   $*