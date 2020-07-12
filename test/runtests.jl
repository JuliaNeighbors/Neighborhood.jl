using Test, Neighborhood, StaticArrays, Random, Distances
using Neighborhood: datatype, getmetric, bruteforcesearch, BruteForceSearch
using Neighborhood.Testing


Random.seed!(54525)
data = [rand(SVector{3}) for i in 1:1000]
query = SVector(0.99, 0.99, 0.99)

# Theiler window and skip predicate related
data[48:52] .= [SVector(0.0, 0.0, i*0.001) for i in 1:5]
nidxs = 48:2:52
queries = [data[i] for i in nidxs]
theiler1 = Theiler(1, nidxs)
theiler2 = Theiler(2, nidxs)

r = 0.1
k = 5


@testset "Utils" begin include("util.jl") end
@testset "Neighborhood.Testing" begin include("Testing.jl") end
@testset "Brute force" begin include("bruteforce.jl") end
include("nearestneighbors.jl")
