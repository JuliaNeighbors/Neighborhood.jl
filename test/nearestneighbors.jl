using Distances

@testset "KDTree" begin

tree1 = searchstructure(KDTree, data, Euclidean(); reorder = true)
tree2 = searchstructure(KDTree, data, Euclidean(); reorder = false)

@test datatype(tree1) === datatype(typeof(tree1)) === eltype(data)
@test getmetric(tree1) === tree1.metric
@test datatype(tree2) === datatype(typeof(tree2)) === eltype(data)
@test getmetric(tree2) === tree2.metric

idxs, ds = knn(tree1, query, 5)
@test issorted(ds)
@test isearch(tree1, query, NeighborNumber(5)) == idxs
@test search(tree1, query, NeighborNumber(5)) == (idxs, ds)

ridxs, rds = inrange(tree1, query, maximum(ds))
@test issorted(rds)
@test ridxs == idxs
@test rds == ds
ridxs_srt, rds_srt = inrange(tree2, query,  maximum(ds))
@test ridxs_srt == idxs
@test rds_srt == ds

__idxs, = inrange(tree1, queries[1], 0.005)
@test sort!(__idxs) == 48:52
__idxs, = inrange(tree1, queries[1], 0.005, theiler1(nidxs[1]))
@test sort!(__idxs) == 50:52
__idxs, = inrange(tree1, queries[2], 0.005, theiler2(nidxs[2]))
@test isempty(__idxs)

vec_of_idxs, vec_of_ds = bulksearch(tree1, queries, NeighborNumber(k))
@test length(vec_of_idxs) == length(nidxs)
@test vec_of_idxs[1] == 48:52
@test vec_of_idxs[3] == 52:-1:48
@test sort(vec_of_idxs[1]) == sort(vec_of_idxs[2])
@test vec_of_ds[1] == vec_of_ds[3] == [(i-1)*0.001 for i in 1:5] # also tests sorting

vec_of_idxs, vec_of_ds = bulksearch(tree1, queries, NeighborNumber(k), theiler1)

@test 48 ∉ vec_of_idxs[1]
@test 49 ∉ vec_of_idxs[1]
@test 50 ∈ vec_of_idxs[1]
@test 51 ∉ vec_of_idxs[3]
@test 52 ∉ vec_of_idxs[3]
@test 50 ∈ vec_of_idxs[3]
@test 48 ∈ vec_of_idxs[2]
@test 52 ∈ vec_of_idxs[2]
@test 50 ∉ vec_of_idxs[2]

vec_of_idxs, vec_of_ds = bulksearch(tree1, queries, NeighborNumber(k), theiler2)
@test vec_of_idxs[1] == isearch(tree1, queries[1], NeighborNumber(k), theiler2(48))
for j in 48:52
    @test j ∉ vec_of_idxs[2]
end

_vec_of_idxs = bulkisearch(tree1, queries, WithinRange(0.002))
@test length.(_vec_of_idxs) == [3, 5, 3]

vec_of_idxs, vec_of_ds = bulksearch(tree1, queries, WithinRange(0.002))
for ds in vec_of_ds
    @test issorted(ds)
end
@test vec_of_idxs[1] == [48, 49, 50]
@test sort(vec_of_idxs[2]) == [48, 49, 50, 51, 52]

# final test, theiler window

vec_of_idxs, vec_of_ds = bulksearch(tree1, queries, WithinRange(0.002), theiler1)
@test vec_of_idxs[1] == vec_of_idxs[3] == [50]
@test vec_of_ds[1] == vec_of_ds[3] == [0.002]
@test vec_of_idxs[2] == [48, 52]
@test vec_of_ds[2] == [0.002, 0.002]

vec_of_idxs, vec_of_ds = bulksearch(tree1, queries, WithinRange(0.002), theiler2)
for (x, y) in zip(vec_of_idxs, vec_of_ds)
    @test isempty(x)
    @test isempty(y)
end

@testset "inrangecount" begin
    N = 10
    x = [rand(SVector{3}) for i = 1:N]
    D = pairwise(Euclidean(), x)
    ds = [sort(D[setdiff(1:N, i), i]) for i = 1:N]
    min_ds = minimum.(ds)
    max_ds = maximum.(ds)
    tree = KDTree(x, Euclidean())
    # Slightly extend bounds to check for both none and all neighbors.
    rmins = [WithinRangeCount(min_ds[i] * 0.99) for (i, xᵢ) in enumerate(x)]
    rmaxs = [WithinRangeCount(max_ds[i] * 1.01) for (i, xᵢ) in enumerate(x)
    ns_min = [inrangecount(tree, xᵢ, rmins[i]) - 1 for (i, xᵢ) in enumerate(x)]
    ns_max = [inrangecount(tree, xᵢ, rmaxs[i]) - 1 for (i, xᵢ) in enumerate(x)]
    @test all(ns_min .== 0)
    @test all(ns_max .== N - 1)

    # For each point, there should be exactly three neighbors within these radii
    r3s = [WithinRangeCount(ds[i][3] * 1.01) for (i, xᵢ) in enumerate(x)]
    ns_3s = [inrangecount(tree, xᵢ, r3s[i]) - 1 for (i, xᵢ) in enumerate(x)]
    @test all(ns_3s .== 3)
end

end
