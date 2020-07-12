metric = Euclidean()
dists = [metric(query, d) for d in data]
ss = searchstructure(BruteForce, data, metric)

skip3(i) = i % 3 == 0
skip3inv(i) = !skip3(i)
skip3bulk(i, j) = skip3(i + j)


@testset "Search structure attributes" begin
    @test datatype(ss) === datatype(typeof(ss)) === eltype(data)
    @test getmetric(ss) === ss.metric
end


@testset "NeighborNumber" begin
    t = NeighborNumber(k)

    # Using bruteforcesearch function
    idxs1, ds1 = results1 = bruteforcesearch(data, metric, query, t)

    @test idxs1 == sortperm(dists)[1:k]
    check_search_results(data, metric, results1, query, t)

    # Using BruteForce instance
    @test search_allfuncs(ss, query, t) == results1

    # Again with skip function
    idxs2, ds2 = results2 = bruteforcesearch(data, metric, query, t, skip3)

    @test idxs2 == filter(skip3inv, sortperm(dists))[1:k]
    check_search_results(data, metric, results2, query, t, skip3)

    @test search_allfuncs(ss, query, t, skip3) == results2
end


@testset "WithinRange" begin
    t = WithinRange(r)

    # Using bruteforcesearch function
    idxs1, ds1 = results1 = bruteforcesearch(data, metric, query, t)

    @test Set(ds1) == Set(filter(<=(r), dists))
    check_search_results(data, metric, results1, query, t)

    # Using BruteForce instance
    @test search_allfuncs(ss, query, t) == results1

    # Again with skip function
    idxs2, ds2 = results2 = bruteforcesearch(data, metric, query, t, skip3)

    @test idxs2 == filter(skip3inv, idxs1)
    check_search_results(data, metric, results2, query, t, skip3)

    @test search_allfuncs(ss, query, t, skip3) == results2
end


@testset "Bulk search" begin
    for t in [NeighborNumber(k), WithinRange(r)]
        for skip in [nothing, skip3bulk]
            test_bulksearch(ss, queries, t, skip)
        end
    end
end
