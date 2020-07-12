var documenterSearchIndex = {"docs":
[{"location":"dev/#Dev-Docs-1","page":"Dev Docs","title":"Dev Docs","text":"","category":"section"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"Here is what you have to do to bring your package into Neighborhood.jl.","category":"page"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"Add your package as a dependency to Neighborhood.jl.\nAdd the search type into the constant SSS in src/Neighborhood.jl and export it.\nThen, proceed through this page and add as many methods as you can.","category":"page"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"An example implementation for KDTrees of NearestNeighbors.jl is in src/kdtree.jl.","category":"page"},{"location":"dev/#Mandatory-methods-1","page":"Dev Docs","title":"Mandatory methods","text":"","category":"section"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"Let S be the type of the search structure of your package. To participate in this common API you should extend the following methods:","category":"page"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"searchstructure(::Type{S}, data, metric; kwargs...) → ss\r\nsearch(ss::S, query, t::SearchType; kwargs...) → idxs, ds","category":"page"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"for both types of t: WithinRange, NeighborNumber. search returns the indices of the neighbors (in the original data) and their distances from the query. Notice that ::Type{S} only needs the supertype, e.g. KDTree, without the type-parameters.","category":"page"},{"location":"dev/#Performance-methods-1","page":"Dev Docs","title":"Performance methods","text":"","category":"section"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"The following methods are implemented automatically from Neighborhood.jl if you extend the mandatory methods. However, if there are performance benefits you should write your own extensions.","category":"page"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"isearch(ss::S, query, t::SearchType; kwargs...) → idxs  # only indices\r\nbulksearch(ss::S, queries, ::SearchType; kwargs...) → vec_of_idxs, vec_of_ds\r\nbulkisearch(ss::S, queries, ::SearchType; kwargs...) → vec_of_idxs","category":"page"},{"location":"dev/#Predicate-methods-1","page":"Dev Docs","title":"Predicate methods","text":"","category":"section"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"The following methods are extremely useful in e.g. timeseries analysis.","category":"page"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"search(ss::S, query, t::SearchType, skip; kwargs...)\r\nbulksearch(ss::S, queries, t::SearchType, skip; kwargs...)","category":"page"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"(and their \"i\" complements, isearch, bulkisearch).","category":"page"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"These methods \"skip\" found neighbors depending on skip. In the first method skip takes one argument: skip(i) the index of the found neighbor (in the original data) and returns true if this neighbor should be skipped. In the second version, skip takes two arguments skip(i, j) where now j is simply the index of the query that we are currently searching for.","category":"page"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"You can kill two birds with one stone and directly implement one method:","category":"page"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"search(ss::S, query, t::SearchType, skip = alwaysfalse; kwargs...)","category":"page"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"to satisfy both mandatory API as well as this one.","category":"page"},{"location":"dev/#Insertion/deletion-methods-1","page":"Dev Docs","title":"Insertion/deletion methods","text":"","category":"section"},{"location":"dev/#","page":"Dev Docs","title":"Dev Docs","text":"Simply extend Base.insert! and Base.deleteat! for your search structure.","category":"page"},{"location":"#Public-API-1","page":"Public API","title":"Public API","text":"","category":"section"},{"location":"#","page":"Public API","title":"Public API","text":"Neighborhood.jl is a Julia package that provides a unified interface for doing neighbor searches in Julia. This interface is described in this page.","category":"page"},{"location":"#Search-Structures-1","page":"Public API","title":"Search Structures","text":"","category":"section"},{"location":"#","page":"Public API","title":"Public API","text":"searchstructure","category":"page"},{"location":"#Neighborhood.searchstructure","page":"Public API","title":"Neighborhood.searchstructure","text":"searchstructure(S, data, metric; kwargs...) → ss\n\nCreate a search structure ss of type S (e.g. KDTree, BKTree, VPTree etc.) based on the given data and metric. The data types and supported metric types are package-specific, but typical choices are subtypes of <:Metric from Distances.jl. Some common metrics are re-exported by Neighborhood.jl.\n\n\n\n\n\n","category":"function"},{"location":"#","page":"Public API","title":"Public API","text":"All currently supported search structures are:","category":"page"},{"location":"#","page":"Public API","title":"Public API","text":"using Neighborhood # hide\nfor ss in Neighborhood.SSS # hide\n    println(ss) # hide\nend # hide","category":"page"},{"location":"#Search-functions-1","page":"Public API","title":"Search functions","text":"","category":"section"},{"location":"#","page":"Public API","title":"Public API","text":"search\nisearch\ninrange\nknn","category":"page"},{"location":"#Neighborhood.search","page":"Public API","title":"Neighborhood.search","text":"search(ss, query, t::SearchType [, skip]; kwargs... ) → idxs, ds\n\nPerform a neighbor search in the search structure ss for the given query with search type t (see SearchType). Return the indices of the neighbors (in the original data) and the distances from the query.\n\nOptional skip function takes as input the index of the found neighbor (in the original data) skip(i) and returns true if this neighbor should be skipped.\n\nPackage-specific keywords are possible.\n\n\n\n\n\n","category":"function"},{"location":"#Neighborhood.isearch","page":"Public API","title":"Neighborhood.isearch","text":"isearch(args...; kwargs... ) → idxs\n\nSame as search but only return the neighbor indices.\n\n\n\n\n\n","category":"function"},{"location":"#Neighborhood.inrange","page":"Public API","title":"Neighborhood.inrange","text":"inrange(ss, query, r::Real [, skip]; kwargs...)\n\nsearch for WithinRange(r) search type.\n\n\n\n\n\n","category":"function"},{"location":"#Neighborhood.knn","page":"Public API","title":"Neighborhood.knn","text":"knn(ss, query, k::Int [, skip]; kwargs...)\n\nsearch for NeighborNumber(k) search type.\n\n\n\n\n\n","category":"function"},{"location":"#Search-types-1","page":"Public API","title":"Search types","text":"","category":"section"},{"location":"#","page":"Public API","title":"Public API","text":"SearchType\nWithinRange\nNeighborNumber","category":"page"},{"location":"#Neighborhood.SearchType","page":"Public API","title":"Neighborhood.SearchType","text":"Supertype of all possible search types of the Neighborhood.jl common API.\n\n\n\n\n\n","category":"type"},{"location":"#Neighborhood.WithinRange","page":"Public API","title":"Neighborhood.WithinRange","text":"WithinRange(r::Real) <: SearchType\n\nSearch type representing all neighbors with distance ≤ r from the query (according to the search structure's metric).\n\n\n\n\n\n","category":"type"},{"location":"#Neighborhood.NeighborNumber","page":"Public API","title":"Neighborhood.NeighborNumber","text":"NeighborNumber(k::Int) <: SearchType\n\nSearch type representing the k nearest neighbors of the query (or approximate neighbors, depending on the search structure).\n\n\n\n\n\n","category":"type"},{"location":"#Bulk-searches-1","page":"Public API","title":"Bulk searches","text":"","category":"section"},{"location":"#","page":"Public API","title":"Public API","text":"Some packages support higher performance when doing bulk searches (instead of individually calling search many times).","category":"page"},{"location":"#","page":"Public API","title":"Public API","text":"bulksearch\nbulkisearch","category":"page"},{"location":"#Neighborhood.bulksearch","page":"Public API","title":"Neighborhood.bulksearch","text":"bulksearch(ss, queries, t::SearchType [, skip]; kwargs... ) → vec_of_idxs, vec_of_ds\n\nSame as search but many searches are done for many input query points.\n\nIn this case skip takes two arguments skip(i, j) where now j is simply the index of the query that we are currently searching for (j is the index in queries and goes from 1 to length(queries)).\n\n\n\n\n\n","category":"function"},{"location":"#Neighborhood.bulkisearch","page":"Public API","title":"Neighborhood.bulkisearch","text":"bulkisearch(ss, queries, t::SearchType [, skip]; kwargs... ) → vec_of_idxs\n\nSame as bulksearch but return only the indices.\n\n\n\n\n\n","category":"function"},{"location":"#Theiler-window-1","page":"Public API","title":"Theiler window","text":"","category":"section"},{"location":"#","page":"Public API","title":"Public API","text":"Theiler","category":"page"},{"location":"#Neighborhood.Theiler","page":"Public API","title":"Neighborhood.Theiler","text":"Theiler(w::Int, nidxs = nothing)\n\nStruct that generates skip functions representing a Theiler window of size w ≥ 0. This is useful when the query of a search is also part of the data used to create the search structure, typical in timeseries analysis. In this case, you do not want to find the query itself as its neighbor, and you typically want to avoid points with indices very close to the query as well.\n\nLet theiler = Theiler(w). Then, theiler by itself can be used as a skip function in bulksearch, because theiler(i, j) ≡ abs(i-j) ≤ w. In addition, if the given argument nidxs is not nothing, then theiler(i, j) ≡ abs(i-nidxs[j]) ≤ w. (useful to give as nidxs the indices of the queries in the original data)\n\nHowever theiler can also be used in single searches. theiler(n) (with one argument) generates the function i -> abs(i-n) ≤ w. So theiler(n) can be given to search as the skip argument.\n\n\n\n\n\n","category":"type"}]
}