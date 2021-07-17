import NearestNeighbors
import NearestNeighbors: KDTree

export KDTree

###########################################################################################
# Standard API
###########################################################################################
function Neighborhood.searchstructure(::Type{KDTree}, data, metric; kwargs...)
    return KDTree(data, metric; kwargs...)
end

datatype(::Type{<:KDTree{V}}) where V = V
getmetric(tree::KDTree) = tree.metric

function Neighborhood.search(tree::KDTree, query, t::NeighborNumber, skip=alwaysfalse; sortds=true)
    return NearestNeighbors.knn(tree, query, t.k, sortds, skip)
end

function Neighborhood.search(tree::KDTree, query, t::WithinRange, skip=alwaysfalse; sortds=true)
    idxs = NearestNeighbors.inrange(tree, query, t.r)
    skip ≠ alwaysfalse && filter!(!skip, idxs)
    ds = _NN_get_ds(tree, query, idxs)
    if sortds # sort according to distances
        sp = sortperm(ds)
        sort!(ds)
        idxs = idxs[sp]
    end
    return idxs, ds
end

function _NN_get_ds(tree::KDTree, query, idxs)
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
function Neighborhood.isearch(tree::KDTree, query, t::WithinRange, skip=alwaysfalse; sortds=false)
    idxs = NearestNeighbors.inrange(tree, query, t.r, sortds)
    skip ≠ alwaysfalse && filter!(!skip, idxs)
    return idxs
end

###########################################################################################
# Bulk and skip predicates
###########################################################################################
function Neighborhood.bulksearch(tree::KDTree, queries, t::NeighborNumber; sortds=true)
    return NearestNeighbors.knn(tree, queries, t.k, sortds)
end

# no easy skip version for knn bulk search
function Neighborhood.bulksearch(tree::KDTree, queries, t::NeighborNumber, skip; sortds=true)
    k, N = t.k, length(queries)
    dists = [Vector{eltype(queries[1])}(undef, k) for _ in 1:N]
    idxs = [Vector{Int}(undef, k) for _ in 1:N]
    for j in 1:N
        # Notice that this `_skip` definition matches our API definition!
        _skip = i -> skip(i, j)
        @inbounds NearestNeighbors.knn_point!(tree, queries[j], sortds, dists[j], idxs[j], _skip)
    end
    return idxs, dists
end

# but there is an easy skip version for inrange bulk isearch!
function Neighborhood.bulkisearch(tree::KDTree, queries, t::WithinRange, skip=alwaysfalse)
    vec_of_idxs = NearestNeighbors.inrange(tree, queries, t.r)
    skip ≠ alwaysfalse && vecskipfilter!(vec_of_idxs, skip)
    return vec_of_idxs
end

function Neighborhood.bulksearch(tree::KDTree, queries, t::WithinRange, skip=alwaysfalse; sortds=true)
    vec_of_idxs = NearestNeighbors.inrange(tree, queries, t.r)
    vec_of_ds = [ _NN_get_ds(tree, queries[j], vec_of_idxs[j]) for j in 1:length(queries)]
    skip ≠ alwaysfalse && vecskipfilter!(vec_of_idxs, vec_of_ds, skip)
    if sortds # sort according to distances
        for i in 1:length(queries)
            @inbounds ds = vec_of_ds[i]
            length(ds) ≤ 1 && continue
            sp = sortperm(ds)
            sort!(ds)
            vec_of_idxs[i] = vec_of_idxs[i][sp]
        end
    end
    return vec_of_idxs, vec_of_ds
end

function vecskipfilter!(vec_of_idxs, skip)
    for j in 1:length(vec_of_idxs)
        @inbounds idxs = vec_of_idxs[j]
        filter!(i -> !skip(i, j), idxs)
    end
    return vec_of_idxs
end
function vecskipfilter!(vec_of_idxs, vec_of_ds, skip)
    for j in 1:length(vec_of_idxs)
        @inbounds idxs = vec_of_idxs[j]
        todelete = [i for i in 1:length(idxs) if skip(idxs[i], j)]
        deleteat!(idxs, todelete)
        deleteat!(vec_of_ds[j], todelete)
    end
    return vec_of_idxs
end
