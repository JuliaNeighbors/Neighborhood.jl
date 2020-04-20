using Test, Neighborhood, StaticArrays, Random

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

# include("nearestneighbors.jl")
