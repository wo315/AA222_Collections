@echo off
set project="project0"
set py_name="%project%_py"
set jl_name="%project%_jl"
set zip_name="%project%.zip"
set /p lang=<language.txt
if "%lang%" == "julia" (
    7z a -r %zip_name% language.txt %jl_name%/*.jl
) else if "%lang%" == "python" (
    7z a -r %zip_name% language.txt %py_name%/*.py
) else (
    echo language.txt does not contain a valid language. Make sure it says either julia or python, and nothing else.
)