module ParseTrees

import Base.Iterators: Generator, Filter
import LightXML: parse_file, root, name, child_elements, find_element, content, attribute, has_attribute
import LightGraphs: DiGraph, add_edge!, nv, indegree, has_path, outneighbors, rem_edge!, vertices

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

function parse_sentence(sentence, parse_type = "enhanced-plus-plus-dependencies")
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

export parse_tree
"""
    parse_tree(file, format = "enhanced-plus-plus-dependencies")

Process the results of the `coreNLP` parse annotator from an XML file.

For each sentence, will return meta data about each word as well as a tree
of how the words are connected.

You can run coreNLP through the command line. A minimal command is
`java -cp "*" edu.stanford.nlp.pipeline.StanfordCoreNLP -annotators tokenize,ssplit,parse -fileList FILE_LIST`
from the folder where you unzipped coreNLP. The resulting files will be in the format
`FILE.xml`, each of which you can parse with `parse_tree`.

```jldoctest
julia> using ParseTrees

julia> result = parse_tree("hammurabi.txt.xml");

julia> result[31].meta
17-element Array{NamedTuple{(:relationship, :text),Tuple{String,String}},1}:
 (relationship = "mark", text = "If")
 (relationship = "det", text = "any")
 (relationship = "nsubj", text = "one")
 (relationship = "advcl:if", text = "steal")
 (relationship = "det", text = "the")
 (relationship = "amod", text = "minor")
 (relationship = "dobj", text = "son")
 (relationship = "case", text = "of")
 (relationship = "nmod:of", text = "another")
 (relationship = "punct", text = ",")
 (relationship = "nsubjpass", text = "he")
 (relationship = "aux", text = "shall")
 (relationship = "auxpass", text = "be")
 (relationship = "root", text = "put")
 (relationship = "case", text = "to")
 (relationship = "nmod:to", text = "death")
 (relationship = "punct", text = ".")

julia> result[31].tree
{16, 15} directed simple Int64 graph
```
"""
parse_tree(file) =
    file |> parse_file |> root |>
    (it -> find_element(it, "document")) |>
    (it -> find_element(it, "sentences")) |> child_elements |>
    (it -> map(parse_sentence, it))

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

export separate_clauses
"""
    separate_clauses(sentence, clause_types)

Pull out root level clauses from a parsed sentence that are one of the
`clause_types`.

```jldoctest
julia> using ParseTrees

julia> sentence = parse_tree("hammurabi.txt.xml")[31];

julia> result = separate_clauses(sentence, ("advcl:if", "nsubjpass", "aux"));

julia> result.clauses[1]
(clause_type = "advcl:if", text = "If any one steal the minor son of another")

julia> result.clauses[2]
(clause_type = "nsubjpass", text = "he")

julia> result.clauses[3]
(clause_type = "aux", text = "shall")

julia> result.rest
", be put to death"
```
"""
function separate_clauses(sentence, clause_types)
    tree = sentence.tree
    meta = sentence.meta
    roots = filter(word_id -> indegree(tree, word_id) == 0, 1:nv(tree))
    if length(roots) == 1
        root_id = first(roots)
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
    else
        warning("No single root cannot be found in $sentence")
        missing
    end
end

end
