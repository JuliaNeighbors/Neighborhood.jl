"""
    metricreturntype(metric, x, y=x)

Get the expected return type of `metric(x, y)`. This is inferred statically if
possible, otherwise the function is actually called with the supplied arguments.
Always returns a concrete type.
"""
function metricreturntype(metric, x, y=x)
    # The following should return a concrete type if metric is type stable:
    T = Core.Compiler.return_type(metric, Tuple{typeof(x), typeof(y)})
    isconcretetype(T) && return T
    return typeof(metric(x, y))
end
