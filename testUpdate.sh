#!/bin/bash

### conf ###
packName="testpack"
serverID="40d42383"
pterodactylURL="https://panel.openplayverse.net"
packURL="https://github.com/OpenPlayVerse/testpack/raw/"
packAPIURL="https://api.github.com/repos/OpenPlayVerse/testpack"
branch="main"
pterodactylTokenPath="/home/noname/.mmmtk/pterodactyl.token"
githubTokenPath="/home/noname/.mmmtk/github.token"
sshKeyPath="~/.ssh/nnh-g-50_test-nopasswd"
sshTarget="test@192.168.4.150"
sshArgs=""
updateScriptArgs="-S"
tmpReleaseFileLocation=".release"

### init ###
# error detection
set -e
error() {
	echo "ERROR: something went wrong. abandon update." 
	exit 1
}
trap "error" ERR

# generate runtime vars
workingDir=$(pwd)
packVersion=$(head -n 1 changelog.txt)
changelog=$(< changelog.txt)
currentGitBlob=""

### update ###
echo
echo "### push prep to git ###"
git add .
git commit -m "v${packVersion}_prep"
git push
currentGitBlob=$(git rev-parse HEAD)

echo
echo "### Create packwiz aliases ###"
./tools/createPackwizAliases.sh \
	--pack-url ${packURL}/${currentGitBlob} \
	--input "files" \
	--output "./packwiz" \
	--list-file ".collectedFiles" \
	-R

echo "packwiz refresh"
cd packwiz
packwiz refresh
cd ..

echo
echo "### push final to git ###"
git add .
git commit -m "v${packVersion}"
git push
currentGitBlob=$(git rev-parse HEAD)

### create multimc releases ###
mkdir $tmpReleaseFileLocation

cp -r multimc ${tmpReleaseFileLocation}/${packName}_latest
cd ${tmpReleaseFileLocation}/${packName}_latest
echo PreLaunchCommand="\$INST_JAVA" -jar packwiz-installer-bootstrap.jar -s client ${packURL}/${branch}/packwiz/pack.toml >> instance.cfg
cd $workingDir

cp -r multimc ${tmpReleaseFileLocation}/${packName}_$packVersion
cd ${tmpReleaseFileLocation}/${packName}_$packVersion
echo PreLaunchCommand="\$INST_JAVA" -jar packwiz-installer-bootstrap.jar -s client ${packURL}/${currentGitBlob}/packwiz/pack.toml >> instance.cfg
cd $workingDir

./tools/createGithubRelease.sh \
	--upstream "${packAPIURL}/releases" \
	--tag "$packVersion" \
	--name "v$packVersion" \
	--description "$changelog" \
	--branch "$branch" \
	--token "$githubTokenPath" \
	--release-folder "${tmpReleaseFileLocation}" \
	--release-files-only


rm -r ${tmpReleaseFileLocation}


: '
echo
echo "### Update server ###"
./tools/updateServer.sh \
   --server-id $serverID \
   --pterodactyl-url $pterodactylURL \
   --pack-url "${packURL}/${branch}/packwiz/pack.toml" \
   --token $pterodactylTokenPath \
   --ssh-args="-i $sshKeyPath $sshTarget $sshArgs" \
   --update-script-args="$updateScriptArgs" \
	--no-backup \
   $*
	
'