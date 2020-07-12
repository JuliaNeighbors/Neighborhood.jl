export BruteForce


"""
    bruteforcesearch(data, metric, query, t::SearchType[, skip])

Perform a brute-force search of type `t` against data array `data`
(by calculating the metric for `query` and and every point in `data`).
"""
function bruteforcesearch end


function bruteforcesearch(data, metric, query, t::NeighborNumber, skip=nothing)
    dists = [metric(query, d) for d in data]
    indices = sortperm(dists)
    !isnothing(skip) && filter!(i -> !skip(i), indices)
    length(indices) > t.k && resize!(indices, t.k)
    return indices, dists[indices]
end


function bruteforcesearch(data, metric, query, t::WithinRange, skip=nothing)
    indices = Int[]
    dists = metricreturntype(metric, first(data))[]
    for (i, datum) in enumerate(data)
        !isnothing(skip) && skip(i) && continue
        d = metric(query, datum)
        if d <= t.r
            push!(indices, i)
            push!(dists, d)
        end
    end
    return indices, dists
end


"""
    BruteForce

A "search structure" which simply performs a brute-force search through the
entire data array.
"""
struct BruteForce{T, M}
    data::Vector{T}
    metric::M

    BruteForce(data::Vector, metric) = new{eltype(data), typeof(metric)}(data, metric)
end

searchstructure(::Type{BruteForce}, data, metric) = BruteForce(data, metric)

datatype(::Type{<:BruteForce{T}}) where T = T
getmetric(bf::BruteForce) = bf.metric

function search(bf::BruteForce, query, t::SearchType, skip=alwaysfalse)
    bruteforcesearch(bf.data, bf.metric, query, t, skip)
end
