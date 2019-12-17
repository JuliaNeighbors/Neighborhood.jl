#=
This file defines the common API for finding neighbors in Julia. For a package
to participate in this common API it should extend the following methods:

Let `T` be the type of your search structure. Make sure that this `SS` is a subtype of
`SearchStrucutre`. Then define:

* searchstructure(::Type{T}, data, metric)  (this gives `ss`)
* search(ss::T, query, ::SearchType) (preferably for both SearchType types)

Notice that ::Type{T} only needs the supertype, e.g. `KDTree`, without the type-parameters.
=#

export FixedRange, FixedAmount, SearchType
export search, inrange, knn
export searchstructure, SearchStructure

"""
Supertype of all possible search types of the Neighborhood.jl common API.
"""
abstract type SearchType end


"""
    searchstructure(T, data, metric; kwargs...) → st
Create a search structure `st` of type `T` (e.g. `KDTree, BKTree` etc.) based on the
given `data` and `metric`. The data types and supported metric types are package-specific,
but typically all subtypes of `<:Metric` from Distances.jl are supported.
"""
function searchstructure(::Type{T}, data::D, metric::M; kwargs...) where
                         {T, D, M}
    error("Given type $(T) has not implemented the Neighborhood.jl public API "*
          "for data type $(D) and metric type $(M).")
end

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

Package-specific keywords could be possible, see the specific nearest neighbor package
for details.
"""
function search(ss, query, st::SearchType; kwargs...)
    error("`search` is not implemented for this combination of input types.")
end

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
