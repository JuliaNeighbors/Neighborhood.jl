using Distances
import NearestNeighbors
import NearestNeighbors: KDTree

using Neighborhood: alwaysfalse

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

__idxs, = inrange(tree1, queries[1], 0.005)
@test sort!(__idxs) == 48:52
__idxs, = inrange(tree1, queries[1], 0.005, theiler1(nidxs[1]))
@test sort!(__idxs) == 50:52
__idxs, = inrange(tree1, queries[2], 0.005, theiler2(nidxs[2]))
@test isempty(__idxs)

###########################################################################################
# Bulk and skip predicates
###########################################################################################
# no easy skip for knn bulk search
function Neighborhood.bulksearch(tree::KDTree, queries, t::NeighborNumber; sortds=true)
    return NearestNeighbors.knn(tree, queries, t.k, sortds)
end

function Neighborhood.bulksearch(tree::KDTree, queries, t::NeighborNumber, skip; sortds=true)
    k, N = t.k, length(queries)
    dists = [Vector{eltype(queries[1])}(undef, k) for _ in 1:N]
    idxs = [Vector{Int}(undef, k) for _ in 1:N]
    for j in 1:N
        # The skip predicate also skips the point itself for w ≥ 0
        _skip = i -> skip(i, j)
        @inbounds NearestNeighbors.knn_point!(tree, queries[j], sortds, dists[j], idxs[j], _skip)
    end
    return idxs, dists
end

# but there is an easy skip for inrange bulk isearch
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
        filter!(i -> skip(i, j), idxs)
    end
    return vec_of_idxs
end
function vecskipfilter!(vec_of_idxs, vec_of_ds, skip)
    for j in 1:length(vec_of_idxs)
        @inbounds idxs = vec_of_idxs[j]
        @show idxs
        todelete = [i for i in 1:length(idxs) if skip(idxs[i], j)]
        @show todelete
        deleteat!(idxs, todelete)
        deleteat!(vec_of_ds[j], todelete)
    end
    return vec_of_idxs
end



vec_of_idxs, vec_of_ds = bulksearch(tree1, queries, NeighborNumber(k))
@test length(vec_of_idxs) == length(nidxs)
@test vec_of_idxs[1] == 48:52
@test vec_of_idxs[3] == 52:-1:48
@test sort(vec_of_idxs[1]) == sort(vec_of_idxs[2])
@test vec_of_ds[1] == vec_of_ds[3] == [(i-1)*0.001 for i in 1:5] # also tests sorting

vec_of_idxs, vec_of_ds = bulksearch(tree1, queries, NeighborNumber(k), theiler1)

@test 48 ∉ vec_of_idxs[1]
@test 49 ∉ vec_of_idxs[1]
@test 50 ∈ vec_of_idxs[1]
@test 51 ∉ vec_of_idxs[3]
@test 52 ∉ vec_of_idxs[3]
@test 50 ∈ vec_of_idxs[3]
@test 48 ∈ vec_of_idxs[2]
@test 52 ∈ vec_of_idxs[2]
@test 50 ∉ vec_of_idxs[2]

vec_of_idxs, vec_of_ds = bulksearch(tree1, queries, NeighborNumber(k), theiler2)
@test vec_of_idxs[1] == isearch(tree1, queries[1], NeighborNumber(k), theiler2(48))
for j in 48:52
    @test j ∉ vec_of_idxs[2]
end

_vec_of_idxs = bulkisearch(tree1, queries, WithinRange(0.002))
@test length.(_vec_of_idxs) == [3, 5, 3]

vec_of_idxs, vec_of_ds = bulksearch(tree1, queries, WithinRange(0.002))
for ds in vec_of_ds
    @test issorted(ds)
end
@test vec_of_idxs[1] == [48, 49, 50]
@test sort(vec_of_idxs[2]) == [48, 49, 50, 51, 52]

# final test, theiler window

vec_of_idxs, vec_of_ds = bulksearch(tree1, queries, WithinRange(0.002), theiler1)
@test vec_of_idxs[1] == vec_of_idxs[3] == [50]
@test vec_of_ds[1] == vec_of_ds[3] == [0.002]
@test vec_of_idxs[2] == [48, 52]
@test vec_of_ds[2] == [0.002, 0.002]

vec_of_idxs, vec_of_ds = bulksearch(tree1, queries, WithinRange(0.002), theiler2)
for (x, y) in zip(vec_of_idxs, vec_of_ds)
    @test isempty(x)
    @test isempty(y)
end
