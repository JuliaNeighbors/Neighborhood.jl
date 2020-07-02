"`alwaysfalse(ags...; kwargs...) = false`"
alwaysfalse(ags...; kwargs...) = false

export WithinRange, NeighborNumber, SearchType
export searchstructure
export search, isearch, inrange, knn
export bulksearch, bulkisearch

"""
Supertype of all possible search types of the Neighborhood.jl common API.
"""
abstract type SearchType end

"""
    searchstructure(S, data, metric; kwargs...) → ss
Create a search structure `ss` of type `S` (e.g. `KDTree, BKTree, VPTree` etc.) based on the
given `data` and `metric`. The data types and supported metric types are package-specific,
but typical choices are subtypes of `<:Metric` from Distances.jl.
Some common metrics are re-exported by Neighborhood.jl.
"""
function searchstructure(::Type{S}, data::D, metric::M; kwargs...) where
                         {S, D, M}
    error("Given type $(S) has not implemented the Neighborhood.jl public API "*
          "for data type $(D) and metric type $(M).")
end

"""
    WithinRange(r::Real) <: SearchType
Search type representing all neighbors with distance `≤ r` from the query
(according to the search structure's metric).
"""
struct WithinRange{R} <: SearchType; r::R; end

"""
    NeighborNumber(k::Int) <: SearchType
Search type representing the `k` nearest neighbors of the query (or approximate
neighbors, depending on the search structure).
"""
struct NeighborNumber <: SearchType; k::Int; end

"""
    datatype(::Type{S}) :: Type

Get the type of the data points (arguments to the metric function) of a search
struture of type `S`.
"""
datatype(::Type) = Any
datatype(ss) = datatype(typeof(ss))

"""
    getmetric(ss)

Get the metric function used by the search structure `ss`.
"""
function getmetric end

"""
    search(ss, query, t::SearchType [, skip]; kwargs... ) → idxs, ds
Perform a neighbor search in the search structure `ss` for the given
`query` with search type `t` (see [`SearchType`](@ref)). Return the indices of the neighbors (in the original data)
and the distances from the query.

Optional `skip` function takes as input the index of the found neighbor
(in the original data) `skip(i)` and returns `true` if this neighbor should be skipped.

Package-specific keywords are possible.
"""
function search(ss::S, query::Q, t::T; kwargs...) where {S, Q, T<: SearchType}
    error("Given type $(S) has not implemented the Neighborhood.jl public API "*
          "for data type $(D) and search type $(T).")
end
function search(ss::S, query::Q, t::T, skip; kwargs...) where {S, Q, T<: SearchType}
    error("Given type $(S) has not implemented the Neighborhood.jl public API "*
          "for data type $(D), search type $(T) and skip function.")
end

"""
    isearch(args...; kwargs... ) → idxs
Same as [`search`](@ref) but only return the neighbor indices.
"""
isearch(args...; kwargs...) = search(args...; kwargs...)[1]

"""
    inrange(ss, query, r::Real [, skip]; kwargs...)
[`search`](@ref) for `WithinRange(r)` search type.
"""
inrange(a, b, r, args...; kwargs...) = search(a, b, WithinRange(r), args...; kwargs...)

"""
    knn(ss, query, k::Int [, skip]; kwargs...)
[`search`](@ref) for `NeighborNumber(k)` search type.
"""
knn(a, b, k::Integer, args...; kwargs...) =
search(a, b, NeighborNumber(k), args...; kwargs...)

###########################################################################################
# Bulk
###########################################################################################
"""
    bulksearch(ss, queries, t::SearchType [, skip]; kwargs... ) → vec_of_idxs, vec_of_ds
Same as [`search`](@ref) but many searches are done for many input query points.

In this case `skip` takes two arguments `skip(i, j)` where now `j` is simply
the index of the query that we are currently searching for (`j` is the index in
`queries` and goes from 1 to `length(queries)`).
"""
function bulksearch(ss, queries, t; kwargs...)
    i1, d1 = search(ss, queries[1], t; kwargs...)
    idxs, ds = [i1], [d1]
    sizehint!(idxs, length(queries))
    sizehint!(ds, length(queries))
    for j in 2:length(queries)
        i, d = search(ss, queries[j], t; kwargs...)
        push!(idxs, i); push!(ds, d)
    end
    return idxs, ds
end
function bulksearch(ss, queries, t, skip; kwargs...)
    i1, d1 = search(ss, queries[1], t, i -> skip(i, 1); kwargs...)
    idxs, ds = [i1], [d1]
    sizehint!(idxs, length(queries))
    sizehint!(ds, length(queries))
    for j in 2:length(queries)
        sk = k -> skip(i, k)
        i, d = search(ss, queries[j], t, sk; kwargs...)
        push!(idxs, i); push!(ds, d)
    end
    return idxs, ds
end

"""
    bulkisearch(ss, queries, t::SearchType [, skip]; kwargs... ) → vec_of_idxs
Same as [`bulksearch`](@ref) but return only the indices.
"""
bulkisearch(args...; kwargs...) = bulksearch(args...; kwargs...)[1]
