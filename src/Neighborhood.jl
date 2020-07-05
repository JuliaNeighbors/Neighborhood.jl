module Neighborhood
using Distances
export Euclidean, Chebyshev, Cityblock, Minkowski

include("api.jl")
include("theiler.jl")
include("kdtree.jl")
include("Testing.jl")

"Currently supported search structures"
const SSS = [KDTree]

end  # module Neighborhood
