module ParseTrees

import Base.Iterators: Generator, Filter
import LightXML: parse_file, root, name, child_elements, find_element, content, attribute, has_attribute
import LightGraphs: DiGraph, add_edge!, nv, indegree, has_path, outneighbors, rem_edge!, vertices

export sentences
"""
    sentences(file)

Return an iterator over sentences of an XML coreNLP result.

You can run coreNLP through the command-line. This package only requires three
annontators: tokenize, ssplit, and parse.
"""
sentences(file) =
    file |> parse_file |> root |>
    (it -> find_element(it, "document")) |>
    (it -> find_element(it, "sentences")) |> child_elements

get_id(node) = parse(Int, attribute(node, "idx"))

function add_branch!(tree, word)
    parent_id = get_id(find_element(word, "governor"))
    child = find_element(word, "dependent")
    id = get_id(child)
    if parent_id != 0
        add_edge!(tree, parent_id, id)
    end
    (
        relationship = attribute(word, "type"),
        text = content(child),
        order = id
    )
end

export dependencies
"""
    dependencies(sentence)

Return meta-data about each token as well as a tree of how the tokens are
connected.
"""
function dependencies(sentence)
    words =
        sentence |>
        child_elements |>
        (it -> Filter(
            node -> name(node) == "dependencies" &&
                attribute(node, "type") == "basic-dependencies",
            it)) |>
        first |>
        child_elements |>
        collect
    tree = DiGraph(length(words) - 1)
    meta = map(word -> add_branch!(tree, word), words)
    sort!(meta, lt = (word1, word2) -> isless(word1.order, word2.order))
    (tree = tree, meta = map(word -> (relationship = word.relationship, text = word.text), meta))
end

function parse_clause(tree, meta, clause_types, clause_id)
    clause_type = meta[clause_id].relationship
    if in(clause_type, clause_types)
        (
            id = clause_id,
            clause_type = clause_type,
            text = join(Generator(
                word_id -> meta[word_id].text,
                Filter(
                    word_id -> has_path(tree, clause_id, word_id),
                    1:nv(tree)
                )
            ), " ")
        )
    else
        nothing
    end
end

reconstitute(meta) = join(Generator(x -> x.text, meta), " ")

export clauses
"""
    clauses(dependencies_result, clause_types)

Pull out root level clauses that are of `clause_types` from the result of
[`dependencies`](@ref).
"""
function clauses(dependency, clause_types)
    tree = dependency.tree
    meta = dependency.meta
    root_ids = filter(word_id -> indegree(tree, word_id) == 0, 1:nv(tree))
    if length(root_ids) != 1
        @debug "The sentence \"$(reconstitute(meta))\" does not contain 1 and only 1 root"
        nothing
    else
        root_id = first(root_ids)
        clauses = collect(
            # type assertion because we know it won't be nothing
            NamedTuple{(:id, :clause_type, :text), Tuple{Int64, String, String}},
            Filter(
                clause -> clause !== nothing,
                Generator(
                    clause_id -> parse_clause(tree, meta, clause_types, clause_id),
                    outneighbors(tree, root_id)
                )
            )
        )
        clause_ids = map(clause -> clause.id, clauses)
        rest = join(Generator(
            word_id -> meta[word_id].text,
            Filter(
                word_id -> all(
                    clause_id -> !has_path(tree, clause_id, word_id),
                    clause_ids
                ),
                vertices(tree)
            )
        ), " ")
        (rest = rest, clauses = map(
            clause -> (clause_type = clause.clause_type, text = clause.text),
            clauses)
        )
    end
end

const relationships_coreNLP_to_institutional_grammar = Dict(
    "nsubj" => :Attribute,
    "nsubjpass" => :Attribute,
    "csubj" => :Attribute,

    "aux" => :Deontic,

    "nmod" => :Condition,
    "advmod" => :Condition,
    "xcomp" => :Condition,
    "ccomp" => :Condition,
    "advcl" => :Condition,

    "dobj" => :Object,
    "dep" => :Object,

    "punct" => :remove,
    "cc" => :remove,
    "conj" => :remove,
    "dep" => :remove,
    "parataxis" => :remove,
)

is_rule(components) = components !== nothing && any(
    component ->
        component.first == :Deontic &&
        occursin(r"(should)|(will)|(shall)|(must)|(may)|(can)", component.second),
    components
)

const ADICO_order = Dict(
    :Attribute => 1,
    :Deontic => 2,
    :aIm => 3,
    :Condition => 4,
    :Object => 5
)

process_sentence(::Nothing) = nothing
function process_sentence(parsed)
    result = map(
        clause -> relationships_coreNLP_to_institutional_grammar[clause.clause_type] => clause.text,
        parsed.clauses
    )
    filter!(clause -> clause.first != :remove, result)
    push!(result, :aIm => parsed.rest)
    sort!(result, by = x -> ADICO_order[x.first])
    result
end

parse_sentence(sentence) =
    process_sentence(clauses(
        dependencies(sentence),
        keys(relationships_coreNLP_to_institutional_grammar)
    ))

export rules
"""
    rules(document)

Find the institutional grammar components in a coreNLP result.

```jldoctest
julia> using ParseTrees

julia> result = rules("hammurabi.txt.xml");

julia> length(result)
234

julia> result[2]
5-element Array{Pair{Symbol,String},1}:
 :Attribute => "his accuser"
   :Deontic => "shall"
       :aIm => "take"
 :Condition => "If any one bring an accusation against a man , and the accused go to the river and leap into the river , if he sink in the river"
    :Object => "possession of his house"
```
"""
rules(document) = filter(is_rule, parse_sentence.(sentences(document)))

end
