import Main.ParseTrees
using Documenter: makedocs, deploydocs

makedocs(
    modules = [ParseTrees],
    sitename = "ParseTrees.jl",
    strict = true
)

deploydocs(
    repo = "github.com/bramtayl/ParseTrees.jl.git"
)
