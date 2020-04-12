#=
# Neighborhood.jl API

## Mandatory methods

Let `S` be the type of the search structure of your package.
To participate in this common API you should extend the following methods:

```julia
searchstructure(::Type{S}, data, metric)
search(ss::S, query, t::SearchType; kwargs...) → idxs, ds
```
for both types of `t`: `WithinRange, NeighborNumber`.
`search` returns the indices of the neighbors (in the original `data`) and their
distances from the `query`.
Notice that ::Type{S} only needs the supertype, e.g. `KDTree`, without the type-parameters.

## Performance methods
The following methods are implemented automatically from Neighborhood.jl if you
extend the mandatory methods. However, if there are performance benefits you should
write your own extentions.
```julia
isearch(ss::S, query, t::SearchType; kwargs...) → idxs  # only indices
bulksearch(ss::S, queries, ::SearchType; kwargs...) → vec_of_idxs, vec_of_ds
bulkisearch(ss::S, queries, ::SearchType; kwargs...) → vec_of_idxs
```

## Predicate methods
The following methods are **extremely useful** in e.g. timeseries analysis.
```julia
search(ss::S, query, t::SearchType, skip; kwargs...)
bulksearch(ss::S, queries, t::SearchType, skip; kwargs...)
```
These methods "skip" found neighbors depending on `skip`. In the first method
`skip` takes one argument: `skip(i)` the index of the found neighbor (in the original data)
and returns `true` if this neighbor should be skipped.
In the second version, `skip` takes two arguments `skip(i, j)` where now `j` is simply
the index of the query that we are currently searching for.

You can kill two birds with one stone and directly implement one method:
```julia
search(ss::S, query, t::SearchType, skip = alwaysfalse; kwargs...)
```
to satisfy both mandatory API as well as this one.

## Insertion/deletion methods
Simply extend `Base.insert!` and `Base.deleteat!` for your search structure.
=#

alwaysfalse(ags...; kwargs...) = false

export WithinRange, NeighborNumber, SearchType
export search, inrange, knn
export searchstructure, SearchStructure

"""
Supertype of all possible search types of the Neighborhood.jl common API.
"""
abstract type SearchType end

"""
Supertype of all search structures implementing the Neighborhood.jl common API.
"""
abstract type SearchStructure end

"""
    searchstructure(S, data, metric; kwargs...) → ss
Create a search structure `ss` of type `S` (e.g. `KDTree, BKTree` etc.) based on the
given `data` and `metric`. The data types and supported metric types are package-specific,
but typical choices are subtypes of `<:Metric` from Distances.jl.
"""
function searchstructure(::Type{S}, data::D, metric::M; kwargs...) where
                         {S, D, M}
    error("Given type $(S) has not implemented the Neighborhood.jl public API "*
          "for data type $(D) and metric type $(M).")
end
metric(ss::S) where {S} = error("Given type $(S) has not implemented `metric`.")

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
    search(ss, query, t::SearchType; kwargs... ) → idxs, ds
Perform a neighbor search in the search structure `ss` for the given
`query` with search type `t`. Return the indices of the neighbors (in the original data)
and the distances from the query.

Package-specific keywords are possible.
"""
function search(ss, query, t::SearchType; kwargs...)
    dsearch(ss, query, t; kwargs...)[1]
end

"""
    isearch(ss, query, t::SearchType; kwargs... ) → idxs
Same as [`search`](@ref) but only return the neighbor indices.
"""
function isearch(ss, query, t::SearchType; kwargs...)
    search(ss, query, t; kwargs...)[1]
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
