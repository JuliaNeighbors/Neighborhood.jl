using Test, Neighborhood, StaticArrays, Random

Random.seed!(54525)
data = [rand(SVector{3}) for i in 1:1000]
data[1:5] .= [SVector(0.0, 0.0, i*0.01) for i in 1:5]
query = SVector(0.99, 0.99, 0.99)
query2 = data[3]
queries = [query, query2]
r = 0.1
k = 5

# include("nearestneighbors.jl")
data
