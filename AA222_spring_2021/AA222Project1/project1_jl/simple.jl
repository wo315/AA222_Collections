
########### "Simple" Problem Definitons ###########

####
# Rosenbrock's
@counted function rosenbrock(x::Vector)
    return (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
end

@counted function rosenbrock_gradient(x::Vector)
    storage = zeros(2)
    storage[1] = -2.0 * (1.0 - x[1]) - 400.0 * (x[2] - x[1]^2) * x[1]
    storage[2] = 200.0 * (x[2] - x[1]^2)
    return storage
end

function rosenbrock_init()
    return clamp.(randn(2), -3.0, 3.0)
end



####
# Himmelblau's
@counted function himmelblau(x::Vector)
    return (x[1]^2 + x[2] - 11)^2 + (x[1] + x[2]^2 - 7)^2
end

@counted function himmelblau_gradient(x::Vector)
    storage = zeros(2)
    storage[1] = 4.0 * x[1]^3 + 4.0 * x[1] * x[2] -
        44.0 * x[1] + 2.0 * x[1] + 2.0 * x[2]^2 - 14.0
    storage[2] = 2.0 * x[1]^2 + 2.0 * x[2] - 22.0 +
        4.0 * x[1] * x[2] + 4.0 * x[2]^3 - 28.0 * x[2]
    return storage
end

function himmelblau_init()
    return clamp.(randn(2), -3.0, 3.0)
end



####
# Powell's
@counted function powell(x::Vector)
    return (x[1] + 10.0 * x[2])^2 + 5.0 * (x[3] - x[4])^2 +
        (x[2] - 2.0 * x[3])^4 + 10.0 * (x[1] - x[4])^4
end

@counted function powell_gradient(x::Vector)
    storage = zeros(4)
    storage[1] = 2.0 * (x[1] + 10.0 * x[2]) + 40.0 * (x[1] - x[4])^3
    storage[2] = 20.0 * (x[1] + 10.0 * x[2]) + 4.0 * (x[2] - 2.0 * x[3])^3
    storage[3] = 10.0 * (x[3] - x[4]) - 8.0 * (x[2] - 2.0 * x[3])^3
    storage[4] = -10.0 * (x[3] - x[4]) - 40.0 * (x[1] - x[4])^3
    return storage
end

function powell_init()
    return clamp.(randn(4), -3.0, 3.0)
end
