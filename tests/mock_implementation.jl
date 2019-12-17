using Neighborhood, NearestNeighbors, VPTrees, Distances, StaticArrays, Random

Random.seed!(5)
data = [rand(SVector{3}) for i in 1:1000]
query = SVector(0.99, 0.99, 0.99)
r = 0.1
k = 5

############# NearestNeighbors version

function Neighborhood.searchstructure(::Type{KDTree}, data, metric; kwargs...)
    return KDTree(data, metric; kwargs...)
end

function Neighborhood.search(tree::KDTree, query, K::FixedAmount; kwargs...)
    return NearestNeighbors.knn(tree, query, K.k; kwargs...)
end

function Neighborhood.search(tree::KDTree, query, R::FixedRange; kwargs...)
    idxs = NearestNeighbors.inrange(tree, query, R.r; kwargs...)
    if tree.reordered # TODO: I am actually not sure how to do this...
        ds = [evaluate(tree.metric, query, tree.data[tree.indices[i]]) for i in idxs]
    else
        ds = [evaluate(tree.metric, query, tree.data[i]) for i in idxs]
    end
    return idxs, ds
end


tree1 = searchstructure(KDTree, data, Euclidean(); reorder = true)
tree2 = searchstructure(KDTree, data, Euclidean(); reorder = false)

inn, dsnn = search(tree, query, FixedAmount(k))


idxs1, ds1 = search(tree1, query, FixedRange(r))
all(d -> d ≤ r, ds)
# For non-reordered trees it works
idxs2, ds2 = search(tree2, query, FixedRange(r))
all(d -> d ≤ r, ds)

############# VPTrees version
function Neighborhood.searchstructure(::Type{VPTree}, data, metric)
    VPTree(data, metric)
end

function Neighborhood.search(tree::VPTree, query, K::FixedAmount)
    idxs = VPTrees.find_nearest(tree, query, K.k)
    return idxs, [tree.metric(query, tree.data[i]) for i in idxs]
end

function Neighborhood.search(tree::VPTree, query, R::FixedRange)
    idxs = VPTrees.find(tree, query, R.r)
    return idxs, [tree.metric(query, tree.data[i]) for i in idxs]
end

f(a, b) = evaluate(Euclidean(), a, b)
vtree = searchstructure(VPTree, data, f)

idxs, ds = search(vtree, query, FixedAmount(k))
