try
    using AA222Testing
catch
    using Pkg
    Pkg.add(PackageSpec(url="https://github.com/sisl/AA222Testing.git"))
    using AA222Testing
end

using AA222Testing: Test, localtest

include(joinpath("project0_jl", "project0.jl"))

test_f(a, b) = () -> (f(a, b) == (a + b))

tests = [Test(test_f(1, 1)),
         Test(test_f(7.2, 9.0))]

localtest(tests, show_errors = get(ARGS, 1, true))