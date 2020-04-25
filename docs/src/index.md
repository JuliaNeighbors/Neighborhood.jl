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

## Theiler window
```@docs
Theiler
```
