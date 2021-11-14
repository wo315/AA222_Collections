#!/usr/bin/env bash

lang="$(cat ./language.txt)"

if [[ "${lang}" == *"python"* ]] || [[ "${lang}" == *"julia"* ]]
then
	zip -r project0.zip language.txt project0_py/*.py project0_jl/*.jl
else
	echo "language.txt does not contain a valid language. Make sure it says either julia or python, and nothing else."
fi
