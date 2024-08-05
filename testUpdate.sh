#!/bin/bash

./tools/updateServer.sh \
	--server-id 95b6cd22 \
	--pterodactyl-url https://panel.openplayverse.net \
	--pack-url https://raw.githubusercontent.com/OpenPlayVerse/testpack/main/packwiz/pack.toml \
	--token ~/.mmmtk/api.token \
	--ssh-args="-i ~/.ssh/nnh-g-50_test-nopasswd test@192.168.4.150" \
	-m 1 -s 30 \
	--update-script-args="-S" \
	$*
	