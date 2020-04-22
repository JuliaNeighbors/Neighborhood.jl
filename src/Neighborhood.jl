module Neighborhood

include("api.jl")
include("theiler.jl")
include("kdtree.jl")

"Currently supported search structures"
const SSS = [KDTree]

end  # module Neighborhood
