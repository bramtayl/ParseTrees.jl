module ParseTrees

import LightXML: parse_file, root, name, child_elements, find_element, content, attribute
import Base.Iterators.Filter
import Base: Generator
import LightGraphs: DiGraph, add_edge!

is_tree(node) =
    name(node) == "dependencies" &&
    attribute(node, "type") == "enhanced-plus-plus-dependencies"

get_id(node) = parse(Int, attribute(node, "idx"))

function add_branch!(tree, meta, word)
    parent_id = get_id(find_element(word, "governor"))
    child = find_element(word, "dependent")
    id = get_id(child)
    if parent_id != 0
        add_edge!(tree, parent_id, id)
    end
    meta[id] = (
        relationship = attribute(word, "type"),
        text = content(child)
    )
end

function parse_sentence(sentence)
    words =
        sentence |>
        child_elements |>
        (it -> Filter(is_tree, it)) |>
        first|>
        child_elements |>
        collect
    tree = DiGraph(length(words))
    meta = Dict{
        Int,
        NamedTuple{(:relationship, :text), Tuple{String, String}}
    }()
    foreach(word -> add_branch!(tree, meta, word), words)
    (tree = tree, meta = meta)
end

export parse_tree
"""
    parse_tree(file)

Process the results of the `coreNLP` parse annotator from an XML file.

You can run coreNLP through the command line. A minimal command is
`java -cp "*" edu.stanford.nlp.pipeline.StanfordCoreNLP -annotators tokenize,ssplit,parse -file FILE`.

```jldoctest
julia> using ParseTrees

julia> result = parse_tree("hammurabi.txt.xml");

julia> first(result).meta[1]
(relationship = "root", text = "1")

julia> first(result).tree
{2, 1} directed simple Int64 graph
```
"""
parse_tree(file) =
    file |>
    parse_file |>
    root |>
    (it -> find_element(it, "document")) |>
    (it -> find_element(it, "sentences")) |>
    child_elements |>
    (it -> Generator(parse_sentence, it))

end
