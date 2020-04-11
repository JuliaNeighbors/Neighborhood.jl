#=
This file defines the common API for finding neighbors in Julia.

Let `T` be the type of the search structure of your package.
To participate in this common API you should extend the following methods:

* searchstructure(::Type{T}, data, metric) → ss
* search(ss::T, query, ::SearchType) → idxs
* dsearch(ss::T, query, ::SearchType) → idxs, ds

`search` returns the indices of the neighbors (in the original `data`).
`dsearch`  returns the distances from the query as well.
Notice that ::Type{T} only needs the supertype, e.g. `KDTree`, without the type-parameters.

If possible (allowing performance benefits), you can also extend:
* bulksearch(ss::T, queries, ::SearchType) → idxs
* dbulksearch(ss::T, queries, ::SearchType) → idxs, ds
which do more eficient bulk searches for multiple queries.
=#

# TODO: Discuss whether `search` should return:
# * IDXS+DISTANCES
# * POINTS+DISTANCES
# * only IDXS
# TODO: Discuss if it is worth it (or just too much effort) to implement 2 functions:
# one returning only indices, one indices and distances...?

export WithinRange, NeighborNumber, SearchType
export search, inrange, knn
export searchstructure

"""
Supertype of all possible search types of the Neighborhood.jl common API.
"""
abstract type SearchType end


"""
    searchstructure(T, data, metric; kwargs...) → st
Create a search structure `st` of type `T` (e.g. `KDTree, BKTree` etc.) based on the
given `data` and `metric`. The data types and supported metric types are package-specific,
but typical choices are subtypes of `<:Metric` from Distances.jl.
"""
function searchstructure(::Type{T}, data::D, metric::M; kwargs...) where
                         {T, D, M}
    error("Given type $(T) has not implemented the Neighborhood.jl public API "*
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
Search type representing the `k` nearest neighbors of the query.
"""
struct NeighborNumber <: SearchType; k::Int; end

"""
    search(ss, query, st::SearchType; kwargs... ) → idxs, ds
Perform a neighbor search in the search structure `ss` for the given
`query` with search type `st`. Return the indices of the neighbors (in the original data)
and the distances from the query.

Package-specific keywords could be possible, see the specific nearest neighbor package
for details.
"""
function search(ss, query, st::SearchType; kwargs...)
    error("`search` is not implemented for this combination of input types.")
end

"""
    inrange(ss, query, r; kwargs...)
Basically [`search`](@ref) for `WithinRange(r)` search type.
"""
inrange(a, b, r; kwargs...) = search(a, b, WithinRange(r); kwargs...)

"""
    knn(ss, query, k::Integer; kwargs...)
Basically [`search`](@ref) for `NeighborNumber(k)` search type.
"""
knn(a, b, k::Integer; kwargs...) = search(a, b, NeighborNumber(k); kwargs...)



##########################################################################################
# Delete and insertion: mutable search structures
##########################################################################################

"""
    insert!(ss, index, point)
Insert a new `point` to the search structure `ss` at the given `index`
(similarly with `Base.insert!`).

The `index` type is package-specific.
"""
function Base.insert!(ss::T, index, point) where {T}
    error("Given type $(T) has either not implemented the Neighborhood.jl public API "*
          "or uses an immutable search structure.")
end

"""
    deleteat!(ss, index)
Remove the point of the search structure specified by the given `index`
(similarly with `Base.deletat!`).

The `index` type is package-specific.
"""
function Base.deleteat!(ss::T, index) where {T}
    error("Given type $(T) has either not implemented the Neighborhood.jl public API "*
          "or uses an immutable search structure.")
end
