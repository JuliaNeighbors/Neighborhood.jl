@testset "cmp_search_results" begin
    idxs = shuffle!(randsubseq(1:100, 0.5))
    ds = rand(Float64, length(idxs))

    p = randperm(length(idxs))
    @test cmp_search_results((idxs, ds), (idxs[p], ds[p]))

    @test !cmp_search_results((idxs, ds), (idxs[2:end], ds[2:end]))
    @test !cmp_search_results((idxs, ds), (idxs[p], ds))
end
