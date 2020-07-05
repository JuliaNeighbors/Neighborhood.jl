# Dev Docs

Here is what you have to do to bring your package into Neighborhood.jl.

* Add your package as a dependency to Neighborhood.jl.
* Add the search type into the constant `SSS` in `src/Neighborhood.jl` and export it.
* Then, proceed through this page and add as many methods as you can.

An example implementation for KDTrees of NearestNeighbors.jl is in `src/kdtree.jl`.

## Mandatory methods

Let `S` be the type of the search structure of your package.
To participate in this common API you should extend the following methods:

```julia
searchstructure(::Type{S}, data, metric; kwargs...) → ss
search(ss::S, query, t::SearchType; kwargs...) → idxs, ds
```
for both types of `t`: `WithinRange, NeighborNumber`.
`search` returns the indices of the neighbors (in the original `data`) and their
distances from the `query`.
Notice that `::Type{S}` only needs the supertype, e.g. `KDTree`, without the type-parameters.

## Performance methods
The following methods are implemented automatically from Neighborhood.jl if you
extend the mandatory methods. However, if there are performance benefits you should
write your own extensions.
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
(and their "i" complements, `isearch, bulkisearch`).

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


## Testing

The [`Neighborhood.Testing`](@ref) submodule contains utilities for testing the
return value of [`search`](@ref) and related functions for your search structure.
These functions use `Test.@test` internally, so just call within a `@testset`
in your unit tests.

```@docs
Neighborhood.Testing
Neighborhood.Testing.search_allfuncs
Neighborhood.Testing.check_search_results
Neighborhood.Testing.test_bulksearch
```
