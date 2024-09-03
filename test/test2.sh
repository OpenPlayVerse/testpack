#!/bin/bash

string="foo/test/TEST/"


while [[ "${string: -1}" == "/" ]]; do
	string=${string::-1}
done

echo $string
echo ${string%/*}