# Public API
Neighborhood.jl is a Julia package that provides a unified interface for doing neighbor searches in Julia.
This interface is described in this page.

## Search Structures
```@docs
searchstructure
```

All currently supported search structures are:
```@example sss
using Neighborhood # hide
for ss in Neighborhood.SSS # hide
    println(ss) # hide
end # hide
```

The following functions are defined for search structures:
```@docs
Neighborhood.datatype
Neighborhood.getmetric
```

## Search functions
```@docs
search
isearch
inrange
knn
```

## Search types
```@docs
SearchType
WithinRange
NeighborNumber
```

## Bulk searches
Some packages support higher performance when doing bulk searches (instead of individually calling `search` many times).
```@docs
bulksearch
bulkisearch
```

## Brute-force searches

The [`BruteForce`](@ref) "search structure" performs a linear search
through its data array, calculating the distance from the query to each data
point. This is the slowest possible implementation but can be used to check
results from other search structures for correctness. The
[`bruteforcesearch`](@ref) function can be used instead without having to create
the search structure.

```@docs
bruteforcesearch
BruteForce
```

## Theiler window
```@docs
Theiler
```
