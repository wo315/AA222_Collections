# Project0 Starter Code

## Code overview
- `language.txt` is a text file specifying the programming language in which the assignment is completed. *This is the very first thing you should edit.*
- `project0_py` is a folder with starter code for completing the project in python.
  - `project0_py/project0.py` contains the function `f` in which your code must be written.

- `project0_jl` is a folder with starter code for completing the project in Julia.
  - `project0_jl/project0.jl` contains the function `f` in which your code must be written.
- `localtest.py` runs tests on `project0_py`.
- `localtest.jl` runs tests on `project0_jl`.
- `make_submission.sh` is a shell script to create the zip file for submission to gradescope (Unix).
- `make_submission_gitbash.sh` is a shell script to create the zip file for submission to gradescope (Windows GitBash).
- `make_submission.bat` is a batch file to create a zip file for submission to gradescope (Windows Command Prompt)

## Deliverables

### Required installs for Windows only
Install Git from <https://git-scm.com/download/win> and ensure you install GitBash when asked whether you want to.
Install 7-Zip from <https://www.7-zip.org/> and try to install it at the recommended location:
`C:\Program Files\7-Zip`


### Choose a programming language
First, pick either Julia1.5+ or Python3+ as a programming language. Depending on your choice, go to `language.txt` and change `notalanguage` to either `julia` or `python`.

### Complete the required code
Second, if you chose Julia, go to `project0_jl/project0.jl` and complete the function `f`. If you chose Python, go to `project0_py/project0.py` and complete the function `f`.

### Test your completed code
Third, if you chose Julia test your completed code by running:
`julia localtest.jl` 
If you chose Python, test your completed code by running:
`python3 localtest.py`

### Create the submission
Fourth, create the zip file for your submission by running (on Unix)
`bash ./make_submission.sh`
or running (on Windows in GitBash)
`bash ./make_submission_gitbash.sh`

### Submit on Gradescope
Finally, submit the created zip file `project0.zip` on `Gradescope/AA222/Project 0`
