module Neighborhood
using Distances
using NearestNeighbors: inrangecount
export Euclidean, Chebyshev, Cityblock, Minkowski
export inrangecount

include("util.jl")
include("api.jl")
include("theiler.jl")
include("bruteforce.jl")
include("kdtree.jl")
include("Testing.jl")

"Currently supported search structures"
const SSS = [BruteForce, KDTree]

end  # module Neighborhood
