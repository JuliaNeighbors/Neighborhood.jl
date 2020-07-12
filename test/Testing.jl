@testset "cmp_search_results" begin
    idxs = shuffle!(randsubseq(1:100, 0.5))
    ds = rand(Float64, length(idxs))

    p = randperm(length(idxs))
    @test cmp_search_results((idxs, ds), (idxs[p], ds[p]))

    @test !cmp_search_results((idxs, ds), (idxs[2:end], ds[2:end]))
    @test !cmp_search_results((idxs, ds), (idxs[p], ds))
end

@testset "knn_bf_ties" begin
    hamming(a, b) = count_ones(xor(a, b))

    # The # of data points with hamming weight n goes like 8 choose n for n in 0:8
    # 1 8 28 56 70 56 28 8 1
    # This will be the distribution of distances (regardless of query)
    data = UInt8.(0:255)
    query = 0b01101001

    dists = [hamming(query, d) for d in data]

    # For k=10 tied distance will be 2
    k = 10
    nearest, ties = Neighborhood.Testing.knn_bf_ties(data, hamming, query, k)

    @test length(nearest) == 1 + 8
    @test all(dists[nearest] .< 2)
    @test length(ties) == 28
    @test all(dists[ties] .== 2)

    # Without thinking about exactly which data points are at odd/even indices,
    # counts above after skipping every other will be at least
    # 0 4 14 28 35 28 14 4 0
    # so tied distance will still be 2
    nearest2, ties2 = Neighborhood.Testing.knn_bf_ties(data, hamming, query, k, isodd)
    @test issetequal(nearest2, filter(iseven, nearest))
    @test issetequal(ties2, filter(iseven, ties))
end
