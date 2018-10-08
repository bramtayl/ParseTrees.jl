using ParseTrees

import Documenter
Documenter.makedocs(
    modules = [ParseTrees],
    format = :html,
    sitename = "ParseTrees.jl",
    root = joinpath(dirname(dirname(@__FILE__)), "docs"),
    pages = Any["Home" => "index.md"],
    strict = true,
    linkcheck = true,
    checkdocs = :exports,
    authors = "Brandon Taylor"
)
