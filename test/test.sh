#!/bin/bash

./tools/createGithubRelease.sh \
	--upstream "https://api.github.com/repos/OpenPlayVerse/testpack/releases" \
	--tag "6.1.0d" \
	--name "TEST NAME 1" \
	--description "TEST DESCRIPTION 1" \
	--branch "main" \
	--token "/home/noname/.mmmtk/github.token" \
	--release-folder ".release" \
	--release-files-only
