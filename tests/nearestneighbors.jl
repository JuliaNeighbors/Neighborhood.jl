using Distances
import NearestNeighbors
import NearestNeighbors: KDTree

using Neighborhood: alwaysfalse, vecskipfilter!

###########################################################################################
# Standard API
###########################################################################################
function Neighborhood.searchstructure(::Type{KDTree}, data, metric; kwargs...)
    return KDTree(data, metric; kwargs...)
end

function Neighborhood.search(tree::KDTree, query, t::NeighborNumber, skip=alwaysfalse; sortds=true)
    return NearestNeighbors.knn(tree, query, t.k, sortds, skip)
end

function Neighborhood.search(tree::KDTree, query, t::WithinRange, skip=alwaysfalse; sortds=true)
    idxs = NearestNeighbors.inrange(tree, query, t.r)
    skip ≠ alwaysfalse && filter!(skip, idxs)
    ds = _NN_get_ds(tree, query, idxs)
    if sortds # sort according to distances
        sp = sortperm(ds)
        sort!(ds)
        idxs = idxs[sp]
    end
    return idxs, ds
end

function _NN_get_ds(tree, query, idxs)
    if tree.reordered
        ds = [
            evaluate(tree.metric, query, tree.data[
                findfirst(isequal(i), tree.indices)
            ]) for i in idxs]
    else
        ds = [evaluate(tree.metric, query, tree.data[i]) for i in idxs]
    end
end

# Performance method when distances are not required (can't sort then)
function Neighborhood.isearch(tree::KDTree, query, t::WithinRange, skip=alwaysfalse)
    idxs = NearestNeighbors.inrange(tree, query, t.r)
    skip ≠ alwaysfalse && filter!(skip, idxs)
    return idxs
end

tree1 = searchstructure(KDTree, data, Euclidean(); reorder = true)
tree2 = searchstructure(KDTree, data, Euclidean(); reorder = false)

idxs, ds = knn(tree1, query, 5)
@test issorted(ds)
@test isearch(tree1, query, NeighborNumber(5)) == idxs
@test search(tree1, query, NeighborNumber(5)) == (idxs, ds)

ridxs, rds = inrange(tree1, query, maximum(ds))
@test issorted(rds)
@test ridxs == idxs
@test rds == ds
ridxs_srt, rds_srt = inrange(tree2, query,  maximum(ds))
@test ridxs_srt == idxs
@test rds_srt == ds

# TODO: Predicate tests
