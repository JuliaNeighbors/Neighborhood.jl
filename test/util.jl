using Neighborhood: metricreturntype

const metric = Euclidean()


# Retuns same value as metric but compiler cannot infer type based on arguments
function typeunstable_metric(x, y)
    isnan(x[1]) && return "foo"  # Confuse the compiler
    return metric(x, y)
end


# Wraps a function and records if it was called
struct CalledChecker{F}
    f::F
    called::Ref{Bool}

    CalledChecker(f) = new{typeof(f)}(f, Ref(false))
end

function (c::CalledChecker)(args...)
    c.called[] = true
    return c.f(args...)
end


@testset "metricreturntype" begin
    for T in [Float64, Float32, Int]
        x = zeros(T, 3)

        metric_checked = CalledChecker(metric)
        @test metricreturntype(metric_checked, x) === typeof(metric(x, x))
        @test !metric_checked.called[]  # Function should never have actually been called

        # Return value should itself be inferrable
        @inferred metricreturntype(metric, x)

        # No inference possible, but should still get the correct result by calling the function
        @test metricreturntype(typeunstable_metric, x) === typeof(typeunstable_metric(x, x))
    end
end
