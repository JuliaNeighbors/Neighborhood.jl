module Neighborhood
using Distances
export Euclidean, Chebyshev, Cityblock, Minkowski

include("util.jl")
include("api.jl")
include("theiler.jl")
include("bruteforce.jl")
include("kdtree.jl")
include("Testing.jl")

"Currently supported search structures"
const SSS = [BruteForce, KDTree]

end  # module Neighborhood
