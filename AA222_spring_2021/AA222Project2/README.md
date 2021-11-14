# Project2 Starter Code

## Code overview
- `language.txt` is a text file specifying the programming language in which the assignment is completed. *This is the very first thing you should edit*
- `project2_py` is a folder with starter code for completing the project in python
    - `project2_py/project2.py` contains the function `optimize` in which your code must be written.
    - `project2_py/helpers.py` contains optimization problems, random search, and test functions.
- `project2_jl` is a folder with starter code for completing the project in Julia.
    - `project2_jl/project2.jl` contains the function `optimize` in which your code must be written.
    - `project2_jl/helpers.jl` contains optimization problems, random search, and test functions.
- `localtest.py` runs tests on `project2_py`
- `localtest.jl` runs tests on `project2_jl`
- `make_submission.sh` is a shell script which will create a zip file for submission to gradescope (Unix).
- `make_submission_gitbash.sh` is a shell script which will create a zip file for submission to gradescope (Windows GitBash).
- `make_submission.bat` is a batch script to create a zip file for submission to gradescope (Windows Command Prompt)


## Rules
In this project, you will be implementing a function `optimize` that minimizes a function with a limited number of evaluations.
- We provide you a function `f(x)`, it's gradient `g(x)`, a function evaluating the constraints `c(x)`, and a number of allowed evaluations `n`.
- Each call to `f` or `c` counts as one evaluation while each call to `g` counts as two evaluations. Note that `f` returns a scalar, while `g` and `c` both return vectors.
- The only external libraries allowed for your implementation of optimize are numpy and scipy.stats in Python and Statistics and Distributions in Julia. In addition to those, you may use any of the standard libraries of either language.
- You can use different optimization strategies for each problem, since we pass you a string `prob` in the call to `optimize`.
- You can base your algorithm on those found in the book or online, but you must give credit.
- Although you may discuss your algorithm with others, you must not share code.


## Deliverables

The core deliverables for this project consist of submitting an optimization algorithm to an autograder, and comparing different optimization algorithms in a write-up. 

### Pass the autograder
The autograder will call the function `optimize` (located at `project2_jl/project2.jl` or `project2_py/project2.py` depending on the language chosen. In order to pass on a given problem, `optimize` must return a feasible point for at least 475 out of 500 different initial guesses (`x0`). The autograder does not require that you use a different algorithm for each problem, but you are free to do so. 

To locally test if your implementation is working, you should run one of the following commands, depending on your choice of language. 
`julia localtest.jl`
`python3 localtest.py`
You should see `Pass: optimize returns a feasible solution on X/500 random seeds.` for all the simple problems. 

To submit your code to the autograder, create the zip file for your submission by running (Unix)
`bash ./make_submission.sh`
or (CommandPrompt):
`bash ./make_submission.bat`

Then, submit the created zip file `project2.zip` on `Gradescope/AA222/Project2`.

### Prepare your README.pdf
In the README, you will be required to describe the algorithms called by `optimize`, as well as compare the performance of at least two distinct algorithms on the simple problems. 

#### Description of algorithms
For each of the five problems given, describe:
- The algorithm you chose to solve it.
- How you decided which hyperparameters to choose.
- Why you think it works.
- At least one pro and one con to the chosen algorithm.

#### Comparison of algorithms
You must compare the performance of at least two algorithms by doing the following.
- For `simple1` and `simple2`, plot the feasible region (where `c(x) <= 0`) on top of a contour plot of `f(x)`. Show the path taken by the algorithm for at least three initial conditions on this plot. Make a separate plot for at least two distinct algorithms (four plots). For both problems the axis limits should be (-3, 3).
- For only `simple2`, and for at least two distinct algorithms, plot the objective function versus iteration, and maximum constraint violation versus iteration, for at least three initial conditions. Plot the curves for different initial conditions on the same plot, but make a separate plot for the objective and constraint violation, and for each of the two algorithms compared (four plots). 

Submit your README.pdf on `Gradescope/AA222/Project2 Writeup`.

## FAQ

#### My strategy involves randomness. Are the score averaged with different random seeds?
Yes! The scores are averaged over 500 runs with different seeds.

#### Where are the Hessians?
We are not providing the Hessian function for you to use. But feel free to estimate it with calls to f and g. The cost would depend on the number of calls to f and g you end up making.

#### How many submission can we make?
Unlimited!

#### Can we exceed the max number of evaluations when making the plots for the README?
Yes! In python, you can get around the assertion error by calling the `problem.nolimit()` method to allow infinite evaluations. In Julia, you can pass in `n = Inf` to optimize.

#### How long does the autograder take to grade?
It shouldn't take more than 10 minutes to grade. If your submission times-out during grading, please contact us on Piazza.

#### How are leaderboard scores computed?
All of the problems are designed to have an optimal value near 0. The closer you are to 0, the closer you are to winning! The total score is the sum of all 5 problems (all of the problems are weighted the same). Constraint violations will still yield finite scores, but subject to huge penalties.

#### Can I write code outside of the `optimize` function?
Yes, you can organize your code however you want as long as, at the end of the day, optimize works as described. Note that if you decide to create additional files, please make sure to import/include (python/julia respectively) them in your project2 file, or else they won’t be available to the autograder.

#### Can I change the starter code files?
Yes, they are not used in the autograder, so you have complete ownership over them!

#### Do I have to manually keep track of how many times the functions have been called?
Nope, we've decided to be very generous and provide a method for doing just that!

- In Julia:
`count(f)` will return how many times the function `f` has been called. For convenience, `count(f, g)` will give `count(f) + 2*count(g) + count(c)`. Ex:
```julia
function optimize(f, g, c, x0, n, prob)
    while count(f, g, c) < n
        # ... do some optimization
    end
    return x_best
end
```

- In Python: the `optimize` function has additional input argument `count`, which takes no arguments and evaluates to `f + 2g`. Ex:
```python
def optimize(f, g, c, x0, n, count, prob):
    while count() < n:
        # ... do some optimization
    return x_best
```
* In Python, do not use the AssertionError as an indication that you have reached the count limit. On Gradescope we do not throw that error.

#### My README plots require an optimization path, but optimize only returns the optimum itself!
`optimize` is geared towards the autograder's evaluation of your method, so it only returns the final point. However, if you're coding with the README in mind (which is a good idea!), you may want to design your code in a way that is conducive to both requirements by writing methods thats collect the optimization history. See the following julia example:
```julia
function optimize(f, g, c, x0, n, prob)
    if prob == "simple1"
        x_history = some_method(f, g, c, x0, n)
    else
        x_history = some_other_method(f, g, c, x0, n)
    end
    return last(x_history)
end
```
