########### "Simple" Problem Definitons ###########

@counted function simple1(x::Vector)
    return -x[1] * x[2] + 2.0 / (3.0 * sqrt(3.0))
end

@counted function simple1_gradient(x::Vector)
    return [-x[2], -x[1]]
end

@counted function simple1_constraints(x::Vector)
    return [x[1] + x[2]^2 - 1,
            -x[1] - x[2]]
end

function simple1_init()
    return rand(2) * 2.0
end

@counted function simple2(x::Vector)
    return (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
end

@counted function simple2_gradient(x::Vector)
    storage = zeros(2)
    storage[1] = -2.0 * (1.0 - x[1]) - 400.0 * (x[2] - x[1]^2) * x[1]
    storage[2] = 200.0 * (x[2] - x[1]^2)
    return storage
end

@counted function simple2_constraints(x::Vector)
    return [(x[1]-1)^3 - x[2] + 1,
            x[1] + x[2] - 2]
end

function simple2_init()
    return rand(2) .* 2.0 .- 1.0
end

@counted function simple3(x::Vector)
    return x[1] - 2*x[2] + x[3] + sqrt(6.0)
end

@counted function simple3_gradient(x::Vector)
    return [1, -2, 1]
end

@counted function simple3_constraints(x::Vector)
    return [x[1]^2 + x[2]^2 + x[3]^2 - 1]
end

function simple3_init()
    b = 2.0 .* [1.0, -1.0, 0.0]
    a = -2.0 .* [1.0, -1.0, 0.0]
    return rand(3) .* (b-a) + a
end
