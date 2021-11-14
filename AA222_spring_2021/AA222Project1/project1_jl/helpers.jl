
"""
    helpers.jl -- Feel free to modify anything you like in this file!

Provides the problem structure and some useful functions. In particular, students may be
interested in `count` - to help with writing their algorithm, and `main` - to test their
methods. Note that `starter_code/localtest.jl` provides an identical test to that found
in the autograder. `main`, on the other hand, returns other metrics that may be of
interest during development.
"""

# Statistics is the only allowed external package (Random is part of the standard library)
# If you would like to use any other (standard) packages, make sure to do so in `project1.jl`
# *NOT HERE*.
using Random
using Statistics

# A global counter that keeps track of how many times each function has been called.
# It may seem like a clever hack to edit this dictionary as part of your optimize
# method to get infinite function evaluations, but beware...
# you'll regret it when it goes through the autograder
const COUNTERS = Dict{String, Int}()

"""
    @counted

A function defined with this macro increments the global counter `COUNTERS`
each time it's called.

Example:
    @counted f(x) = 2x  #each time `f(x)` is called, we also have `COUNTERS["f"] += 1`
"""
macro counted(f)
    name = f.args[1].args[1]
    name_str = String(name)
    body = f.args[2]
    update_counter = quote
        if !haskey(COUNTERS, $name_str)
            COUNTERS[$name_str] = 0
        end
        COUNTERS[$name_str] += 1
    end
    insert!(body.args, 1, update_counter)
    return f
end


# simple.jl defines the 3 simple problems. It's included down here rather than at the
# top because it relies on @counted and COUNTERS to track the evaluation counts.
include("simple.jl")

const PROBS = Dict("simple1" => (f=rosenbrock, g=rosenbrock_gradient, x0=rosenbrock_init, n=20),
                   "simple2" => (f=himmelblau, g=himmelblau_gradient, x0=himmelblau_init, n=40),
                   "simple3" => (f=powell, g=powell_gradient, x0=powell_init, n=100))



"""
    count(f::Function)
    count(f::Function, g::Function)

Check how many times the function f has been called, or calculate f + 2g.
"""
Base.count(f::Function)              = get(COUNTERS, string(nameof(f)), 0)
Base.count(f::Function, g::Function) = count(f) + 2*count(g)


"""
    get_score(f, g, x_star_hat, n)

The score is computed as `f(x⋆)` using the potential optimum `x_star_hat`.
If `count(f, g) > n`, the score in necessarily `Inf` (didn't adhere to constraints).
Also returns the number of evaluations for use in `main` and `localtest`.
"""
function get_score(f, g, x_star_hat, n)
    num_evals = count(f, g)

    score = num_evals <= n ? f(x_star_hat) : Inf

    return num_evals, score
end


"""
    main(probname, repeat, opt_func)

Evaluates a problem given by `probname` `repeat` times using `opt_func`
as the optimization (pass in your `optimize`).

## Arguments:
    - `probname`: Name of optimization problem (e.g. "simple1")
    - `repeat`: Number of Monte Carlo evaluations
    - `opt_func`: Optimization algorithm
## Returns:
    - (`mean_score`, `max_evals`)
"""
function main(probname::String, repeat::Int, opt_func, seed = 42)
    scores = zeros(repeat)
    nevals = zeros(Int, repeat)

    prob = PROBS[probname]

    # Repeat the optimization with a different initialization
    for i in 1:repeat
        empty!(COUNTERS) # fresh eval-count each time
        Random.seed!(seed + i)
        x_star_hat = opt_func(prob.f, prob.g, prob.x0(), prob.n, probname)
        nevals[i], scores[i] = get_score(prob.f, prob.g, x_star_hat, prob.n)
    end

    return scores, nevals
end
