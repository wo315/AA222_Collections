#!/usr/bin/env bash

if [[ ":$PATH:" == *":C:\Program Files\7-Zip:"* ]]; then
  echo "7-Zip in path."
else
  echo "Trying to add 7-Zip to path."
  echo "If not at C:\Program Files\7-Zip please modify this script."
  export PATH=$PATH:"C:\Program Files\7-Zip"
fi

lang="$(cat ./language.txt)"

if [[ "${lang}" == *"python"* ]] || [[ "${lang}" == *"julia"* ]]
then
	7z a -r project0.zip language.txt project0_py/*.py project0_jl/*.jl
else
	echo "language.txt does not contain a valid language. Make sure it says either julia or python, and nothing else."
fi
