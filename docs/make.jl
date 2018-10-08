import Documenter

Documenter.deploydocs(
    repo = "github.com/bramtayl/ParseTrees.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
    julia = "1.0"
)