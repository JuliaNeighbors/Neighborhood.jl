"""Utilities for testing search structures."""
module Testing

using Test
using Neighborhood

export search_allfuncs, check_search_results, test_bulksearch


"""
Get arguments tuple to `search`, using the 3-argument version if `skip=nothing`.
"""
get_search_args(ss, query, t, skip) = isnothing(skip) ? (ss, query, t) : (ss, query, t, skip)


"""
    search_allfuncs(ss, query, t[, skip])

Call [`search`](@ref)`(ss, query, t[, skip])` and check that the result matches
those for [`isearch`](@ref) and [`knn`](@ref)/[`inrange`](@ref) (depending on
search type) for the equivalent arguments.

`skip` may be `nothing`, in which case the 3-argument methods of all functions
will be called. Uses `Test.@test` internally.
"""
function search_allfuncs(ss, query, t, skip=nothing)
    args = get_search_args(ss, query, t, skip)
    idxs, ds = result = search(args...)

    @test isearch(args...) == idxs
    @test _alt_search_func(args...) == result

    return result
end

# Call inrange() or knn() given arguments to search()
function _alt_search_func(ss, query, t::WithinRange, args...)
    inrange(ss, query, t.r, args...)
end
function _alt_search_func(ss, query, t::NeighborNumber, args...)
    knn(ss, query, t.k, args...)
end


"""
    check_search_results(data, metric, results, query, t[, skip])

Check that `results = search(ss, query, t[, skip])` make sense for a search
structure `ss` with data `data` and metric `metric`.

Note that this does not calculate the known correct value to compare to (which
may be expensive for large data sets), just that the results have the
expected properties. `skip` may be `nothing`, in which case the 3-argument
methods of all functions will be called. Uses `Test.@test` internally.

Checks the following:
* `results` is a 2-tuple of `(idxs, ds)`.
* `ds` is sorted.
* `ds[i] == metric(query, data[i])`.
* `skip(i)` is false for all `i` in `idxs`.
* For `t::NeighborNumber`:
  * `length(idxs) <= t.k`.
* For `t::WithinRange`:
  * `d <= t.r` for all `d` in `ds`.
"""
function check_search_results(data, metric, results, query, t, skip=nothing)
    idxs, ds = results

    @test issorted(ds)
    @test ds == [metric(query, data[i]) for i in idxs]

    !isnothing(skip) && @test !any(map(skip, idxs))
end

function _check_search_results(data, metric, (idxs, ds), query, t::NeighborNumber, skip)
    @test length(idxs) <= t.k
end

function _check_search_results(data, metric, (idxs, ds), query, t::WithinRange, skip)
    @test all(<=(t.r), ds)
end


"""
    test_bulksearch(ss, queries, t[, skip=nothing])

Test that [`bulksearch`](@ref) gives the same results as individual applications
of [`search`](@ref).

`skip` may be `nothing`, in which case the 3-argument methods of both functions
will be called. Uses `Test.@test` internally.
"""
function test_bulksearch(ss, queries, t, skip=nothing)
    args = get_search_args(ss, queries, t, skip)
    bidxs, bds = bulksearch(args...)

    @test bulkisearch(args...) == bidxs

    for (i, query) in enumerate(queries)
        result = if isnothing(skip)
            search(ss, query, t)
        else
            iskip = j -> skip(i, j)
            search(ss, query, t, iskip)
        end
        @test result == (bidxs[i], bds[i])
    end
end


end  # module
