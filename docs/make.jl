using Pkg
CI = get(ENV, "CI", nothing) == "true" || get(ENV, "GITHUB_TOKEN", nothing) !== nothing
CI && Pkg.activate(@__DIR__)
CI && Pkg.instantiate()
using Documenter, Neighborhood
using DocumenterTools: Themes

for w in ("light", "dark")
    header = read(joinpath(@__DIR__, "style.scss"), String)
    theme = read(joinpath(@__DIR__, "$(w)defs.scss"), String)
    write(joinpath(@__DIR__, "$(w).scss"), header*"\n"*theme)
end
Themes.compile(joinpath(@__DIR__, "light.scss"), joinpath(@__DIR__, "src/assets/themes/documenter-light.css"))
Themes.compile(joinpath(@__DIR__, "dark.scss"), joinpath(@__DIR__, "src/assets/themes/documenter-dark.css"))

# %% actually make the docs
makedocs(
    modules=[Neighborhood],
    sitename= "Neighborhood.jl",
    authors = "George Datseris.",
    format = Documenter.HTML(
        prettyurls = CI,
        assets = [
            "assets/logo.ico",
            asset("https://fonts.googleapis.com/css?family=Montserrat|Source+Code+Pro&display=swap", class=:css),
            ],
        collapselevel = 2,
        ),
    doctest=false,
    pages = [
        "Public API" => "index.md",
        "Dev Docs" => "dev.md",
        ]
)

if CI
    deploydocs(
        repo = "github.com/JuliaNeighbors/Neighborhood.jl.git",
        target = "build",
        push_preview = true
    )
end
