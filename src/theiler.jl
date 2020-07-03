"""
    Theiler(w::Int, nidxs = nothing)
Struct that generates skip functions representing a Theiler window of size `w ≥ 0`.
This is useful when the query of a search is also part of the data used to create the
search structure, typical in timeseries analysis. In this case, you do not want to
find the query itself as its neighbor, and you typically want to avoid points with
indices very close to the query as well.

Let `theiler = Theiler(w)`. Then, `theiler` by itself can be used as a skip function
in [`bulksearch`](@ref), because `theiler(i, j) ≡ abs(i-j) ≤ w`.
In addition, if the given argument `nidxs` is _not_ `nothing`, then
`theiler(i, j) ≡ abs(i-nidxs[j]) ≤ w`. (useful to give as `nidxs` the indices of the
queries in the original data)

However `theiler` can also be used in single searches. `theiler(n)` (with one argument)
generates the function `i -> abs(i-n) ≤ w`. So `theiler(n)` can be given to
[`search`](@ref) as the `skip` argument.
"""
struct Theiler{R} <: Function
    w::Int
    nidxs::R
end
Theiler(w) = Theiler(w, nothing)
Theiler() = Theiler(0)

(t::Theiler)(n) = i -> abs(i-n) ≤ t.w
(t::Theiler{Nothing})(i, j) = abs(i-j) ≤ t.w
(t::Theiler)(i, j) = abs(i - t.nidxs[j]) ≤ t.w

export Theiler
