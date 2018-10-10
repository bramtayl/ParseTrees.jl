module ParseTrees

import Base.Iterators: Generator, Filter
import LightXML: parse_file, root, name, child_elements, find_element, content, attribute, has_attribute
import LightGraphs: DiGraph, add_edge!, nv, indegree, has_path, outneighbors, rem_edge!, vertices

export sentences
"""
    sentences(file)

Return an iterator over sentences.

Input the XML results a run of `coreNLP` including at least the `tokenize` and
`ssplit` annotators.

```jldoctest
julia> using ParseTrees

julia> result = sentences("hammurabi.txt.xml");

julia> typeof(first(result))
LightXML.XMLElement
```
"""
sentences(file) =
    file |> parse_file |> root |>
    (it -> find_element(it, "document")) |>
    (it -> find_element(it, "sentences")) |> child_elements

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
    end
end

export annotate
"""
    annotate(file, annotators = ("tokenize", "ssplit", "parse"), options = ``)

Return a command line call to `coreNLP` to be `run`.

Must be `run` with the working directory set to the location where you have
unzipped `coreNLP`. Will take a few minutes to complete.

```{julia}
julia> using ParseTrees

julia> annotate("hammurabi.txt")
`java -cp '*' edu.stanford.nlp.pipeline.StanfordCoreNLP -annotators tokenize,ssplit,parse -file hammurabi.txt`
```
"""
function annotate(file, annotators = ("tokenize", "ssplit", "parse"), options = ``)
    `java -cp "*" edu.stanford.nlp.pipeline.StanfordCoreNLP -annotators $(join(annotators, ",")) -file $file $options`
end

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
    dependencies(sentence, format = "basic-dependencies")

Return meta data about each token as well as a tree of how the tokens are connected.

Input one of the [`sentences`](@ref) of a `coreNLP` run containing at least the
`tokenize`, `ssplit`, and `parse` annotators.

```jldoctest
julia> using ParseTrees

julia> depencies_31 = collect(sentences("hammurabi.txt.xml"))[31] |> dependencies;

julia> depencies_31.meta
17-element Array{NamedTuple{(:relationship, :text),Tuple{String,String}},1}:
 (relationship = "mark", text = "If")
 (relationship = "det", text = "any")
 (relationship = "nsubj", text = "one")
 (relationship = "advcl", text = "steal")
 (relationship = "det", text = "the")
 (relationship = "amod", text = "minor")
 (relationship = "dobj", text = "son")
 (relationship = "case", text = "of")
 (relationship = "nmod", text = "another")
 (relationship = "punct", text = ",")
 (relationship = "nsubjpass", text = "he")
 (relationship = "aux", text = "shall")
 (relationship = "auxpass", text = "be")
 (relationship = "root", text = "put")
 (relationship = "case", text = "to")
 (relationship = "nmod", text = "death")
 (relationship = "punct", text = ".")

julia> depencies_31.tree
{16, 15} directed simple Int64 graph
```
"""
function dependencies(sentence, parse_type = "basic-dependencies")
    words =
        sentence |>
        child_elements |>
        (it -> Filter(
            node -> name(node) == "dependencies" &&
                attribute(node, "type") == parse_type,
            it)) |>
        first |>
        child_elements |>
        # TODO: figure out what extra means and how to deal with it.
        (it -> Filter(
            word -> !has_attribute(word, "extra"),
            it
        )) |>
        collect
    tree = DiGraph(length(words) - 1)
    meta = map(word -> add_branch!(tree, word), words)
    sort!(meta, lt = (word1, word2) -> isless(word1.order, word2.order))
    (tree = tree, meta = map(word -> (relationship = word.relationship, text = word.text), meta))
end

export clauses
"""
    clauses(meta, tree, clause_types)

Pull out root level clauses from a parsed sentence that are one of the
`clause_types`.

```jldoctest
julia> using ParseTrees

julia> depencies_31 = collect(sentences("hammurabi.txt.xml"))[31] |> dependencies;

julia> clauses_31 = clauses(depencies_31.meta, depencies_31.tree, ("advcl", "nsubjpass", "aux"));

julia> clauses_31.clauses[1]
(clause_type = "advcl", text = "If any one steal the minor son of another")

julia> clauses_31.clauses[2]
(clause_type = "nsubjpass", text = "he")

julia> clauses_31.clauses[3]
(clause_type = "aux", text = "shall")

julia> clauses_31.rest
", be put to death"
```
"""
function clauses(meta, tree, clause_types)
    root_id = first(Filter(word_id -> indegree(tree, word_id) == 0, 1:nv(tree)))
    clauses = collect(
        # type assertion because we know it won't be nothing
        NamedTuple{(:id, :clause_type, :text), Tuple{Int64, String, String}},
        Filter(
            clause -> clause !== nothing,
            map(
                clause_id -> parse_clause(tree, meta, clause_types, clause_id),
                outneighbors(tree, root_id)
            )
    ))
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
