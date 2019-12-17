#=
This file defines the common API for finding neighbors in Julia. For a package
to participate in this common API it should extend the following methods:

Let `SS` be your search structure. Then define:

* searchstructure(::T, data, metric)  (this gives `ss`)
* search(ss::SS, query, ::SearchType) (preferably for both SearchType types)

=#
export FixedRange, FixedAmount, SearchType
export search, inrange, knn
export searchstructure

abstract type SearchType end

"""
    FixedRange(r) <: SearchType
Search type representing all neighbors with distance `≤ r` from the query.
"""
struct FixedRange{R} <: SearchType; r::R; end

"""
    FixedAmount(k) <: SearchType
Search type representing the `k` nearest neighbors of the query.
"""
struct FixedAmount <: SearchType; k::Int; end

"""
    search(ss, query, st::SearchType; kwargs... ) → neighbors
Perform a neighbor search in the search structure `ss` for the given
`query` with search type `st`.

Structure-specific keywords could be possible, see the specific nearest neighbor package
for details.
"""
function search end

"""
    inrange(ss, query, r; kwargs...) → neighbors
Find all neighbors of the `query` with distance `≤ r` in the search structure `ss`.
If none exist, and empty vector (of the same type) is returned.
"""
inrange(a, b, r; kwargs...) = search(a, b, FixedRange(r); kwargs...)

"""
    knn(ss, query, k::Integer; kwargs...) → neighbors
Find the `k` nearest neighbors (or approximate ones, depending on `ss`) of the `query`
in the search structure `ss`.
"""
knn(a, b, k::Integer; kwargs...) = search(a, b, FixedAmount(k); kwargs...)


"""
    searchstructure(T, data, metric; kwargs...) → st
Create a search structure `st` of type `T` (e.g. `KDTree, BallTree` etc.) based on the
given `data` and `metric`. The data types and supported metric types are package-specific,
but typically all subtypes of `<:Metric` from Distances.jl are supported.
"""
function searchstructure end
