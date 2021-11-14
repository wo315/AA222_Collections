
"""
    localtest.jl -- Feel free to modify anything you like in this file!

You can call this file as a script at the command line, or `include` it from within a julia session.

Example command-line usage:

    julia --color=yes localtest.jl                  # Evaluate all simple functions the default number of times (500):
    julia --color=yes localtest.jl 2000             # Evaluate all simple functions a custom number of times (2000 in this case):
    julia --color=yes localtest.jl simple1          # Evaluate only simple1 the default number of times:
    julia --color=yes localtest.jl simple3 2000     # Evaluate only simple3 a custom number of times:
"""

# Include the other relevant files:
include(joinpath("project2_jl", "helpers.jl"))
include(joinpath("project2_jl", "project2.jl"))

if length(ARGS) == 0
    # Default
    K = 500
    probnames = sort(collect(keys(PROBS)))
elseif length(ARGS) == 1
    # One input argument can be either evaluation count or function name, so
    # have to test for both. If it's not an integer it's got to be a function name
    K = tryparse(Int, ARGS[1])
    if K === nothing
        K = 500
        probnames = [ARGS[1]]
    else
        probnames = sort(collect(keys(PROBS)))
    end
elseif length(ARGS) == 2
    # Two inputs can come in at any order, so try both
    K = tryparse(Int, ARGS[1])
    if K === nothing
        K = tryparse(Int, ARGS[2])
        if K === nothing
            throw(ArgumentError("Can't detect which input is intended to be the evaluation count. Make sure it's an integer"))
        end
        probnames = [ARGS[1]]
    else
        probnames = [ARGS[2]]
    end
else
    throw(ArgumentError("Too many command-line inputs to localtest.jl"))
end

printstyled("\nTesting $K times\n\n", bold = true)
for nm in probnames
    try
        scores, n_evals, optima = main(nm, K, optimize)

        if maximum(n_evals) > PROBS[nm].n
            @warn "number of exaluations exceeded. Got $(maximum(n_evals)) on $nm."
        end

        # Check which optima are feasible
        feasible_optima = map(optima) do x
            all(<=(0), PROBS[nm].c(x))
        end

        # 95% of optima must be feasible!
        pass = sum(feasible_optima) >= (0.95*K)

        if pass
            printstyled("Pass: optimize returns a feasible solution on $(sum(feasible_optima))/$K random seeds.\n", color = :green)
        else
            printstyled("Fail: optimize returns a feasible solution on $(sum(feasible_optima))/$K random seeds.\n", color = :red)
        end

    catch e
        println("ERROR IN PROBLEM $nm")
        showerror(stdout, e, catch_backtrace())
    end
end


