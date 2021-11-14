#!/usr/bin/env bash

lang="$(cat ./language.txt)"

if [[ "${lang}" == *"julia"* ]]
then
    zip -r project2.zip language.txt project2_jl/*.jl
elif [[ "${lang}" == *"python"* ]]
then
    zip -r project2.zip language.txt project2_py/*.py
else
    echo "language.txt does not contain a valid language. Make sure it says either julia or python, and nothing else."
fi
