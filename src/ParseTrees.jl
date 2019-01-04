module ParseTrees

import Base.Iterators: Generator, Filter
import LightXML: parse_file, root, name, child_elements, find_element, content, attribute
import LightGraphs: DiGraph, add_edge!, indegree, has_path, outneighbors, rem_edge!, vertices
import MetaGraphs: MetaDiGraph, set_props!, get_prop

get_id(node) = parse(Int, attribute(node, "idx"))

export sentences
"""
    sentences(file)

Return an iterator over sentences of an `coreNLP` result XML file.

You can run `coreNLP` through the [`command-line`](https://stanfordnlp.github.io/CoreNLP/cmdline.html).
This package only uses the [`parse`](https://stanfordnlp.github.io/CoreNLP/parse.html)
annotator.

```jldoctest
julia> using ParseTrees

julia> result = sentences("hammurabi.txt.xml");

julia> result[2]
{29, 28} directed Int64 metagraph with Float64 weights defined by :weight (default weight 1.0)

julia> flat(result[2])
"If any one ensnare another , putting a ban upon him , but he can not prove it , then he that ensnared him shall be put to death"

julia> flat(result[2], 4)
"If any one ensnare another , putting a ban upon him"
```
"""
sentences(file) = map(
    xml_sentence -> begin
        words =
            xml_sentence |>
            child_elements |>
            (it -> Filter(
                node -> name(node) == "dependencies" && attribute(node, "type") == "basic-dependencies",
                it
            )) |>
            first |>
            child_elements |>
            collect
        sentence = MetaDiGraph(DiGraph(length(words) - 1))
        foreach(
            word -> begin
                parent_id = get_id(find_element(word, "governor"))
                child = find_element(word, "dependent")
                id = get_id(child)
                if parent_id != 0
                    add_edge!(sentence, parent_id, id)
                end
                set_props!(sentence, id, Dict(
                    :relationship => attribute(word, "type"),
                    :text => content(child)
                ))
            end,
            words
        )
        sentence
    end,
    file |>
        parse_file |>
        root |>
        (it -> find_element(it, "document")) |>
        (it -> find_element(it, "sentences")) |>
        child_elements
)

flat_inner(sentence, the_vertices) =
    join(Generator(
        word_id -> get_prop(sentence, word_id, :text),
        the_vertices
    ), " ")

"""
    flat(sentence)

Just add water

    flat(sentence, id)

Just the parts of the `sentence` connected to `id`.
"""
flat(sentence) = flat_inner(sentence, vertices(sentence))
flat(sentence, id) = flat_inner(sentence, Filter(
    word_id -> has_path(sentence, id, word_id),
    vertices(sentence)
))
export flat

"""
    institutional_grammar

A clause dict based on Elinor Ostrom's institutional grammar. Of the forty
universal dependencies, many are labelled as `:not_applicable`, meaning they
will not occur in the root. Several are labelled `:not_sure`, meaning it could
or could not be one of the 6 components of institutional grammar. Then there
are the ABDICO components, less `Or else`, which can't be determined
grammatically, and `aIm`, which will end up as `rest`. Sub-clauses are
marked for `recur`sion, and superfluous clauses are marked for `remove`l.
"""
institutional_grammar = Dict(
    "acl" => :not_applicable, # adjectival clause
    "advcl" => :Condition,  # adverbial clause modifier
    "advmod" => :Condition, # adverbial modifier
    "amod" => :not_applicable, # adjectival modifier
    "apos" => :not_applicable, # appositional modifier
    "aux" => :Deontic, # auxiliary
    # "auxpass" => :aIm, # passive auxiliary
    "case" => :not_applicable, # case marking
    "cc" => :remove, # coordinating conjunction
    "ccomp" => :oBject, # clausal component
    # "compound" -> :aIm,
    "conjunct" => :recur, # conjunct
    # "cop" => :aIm, # copula
    "csubj" => :Attribute, # clausal subject
    "csubjpass" => :Attribute, # clausal subject passive
    "dep" => :not_sure, # unspecified dependency
    "det" => :not_applicable, # determiner
    "discourse" => :remove,
    "dislocated" => :not_sure,
    "dobj" => :oBject, # direct object
    # "expl" => :aIm, # expletive
    "foreign" => :not_sure, # foreign words
    # "goeswith" => :aIm, # goes with
    # "iobj" => :aIm, # indirect object
    "list" => :recur,
    "mark" => :not_applicable, # marker
    # "mwe" => :aIm, # multiword expression
    "name" => :not_applicable,
    # "neg" => :aIm, # negation modifier
    "nmod" => :Condition, # nominal modifier
    "nsubj" => :Attribute, # nominal subject
    "nsubjpass" => :Attribute, # nominal subject passive
    "nummod" => :not_applicable, # numeric modifier
    "parataxis" => :recur,
    "punct" => :remove, # punctuation
    "remnant" => :not_sure, # remnant in ellipisis
    "reparandum" => :not_sure, # overridden disfluency
    # root => :aIm,
    "vocative" => :remove,
    "xcomp" => :oBject, # open clausal component
)
export institutional_grammar

seek_clauses!(result, sentence, clause_dict, ::Nothing, rest) = nothing
function seek_clauses!(result, sentence, clause_dict, root_id, rest)
    locations = Vector{Pair{Int, Symbol}}()
    is_rule = false
    neighbors = copy(outneighbors(sentence, root_id))
    for clause_id in neighbors
        clause_type = split(get_prop(sentence, clause_id, :relationship), ':')[1]
        if haskey(clause_dict, clause_type)
            clause_category = clause_dict[clause_type]
            if clause_category == :recur
                seek_clauses!(result, sentence, clause_dict, clause_id, rest)
            end
            if clause_category == :Deontic
                if occursin(r"(should)|(will)|(shall)|(must)|(may)|(can)", flat(sentence, clause_id))
                    is_rule = true
                    rem_edge!(sentence, root_id, clause_id)
                    push!(locations, clause_id => clause_category)
                end
            else
                rem_edge!(sentence, root_id, clause_id)
                if clause_category != :remove && clause_category != :recur
                    push!(locations, clause_id => clause_category)
                end
            end
        end
    end
    if is_rule
        push!(locations, root_id => :aIm)
        push!(result, map(
            location -> location.second => flat(sentence, location.first),
            locations
        ))
    end
end

"""
    rules(file, clause_dict; rest = :rest)

Split the sentences of a `file` into groups of clauses based on `clause_dict`,
starting at the root. Clause dict should be a map from [Universal Dependencies
(v1)](http://universaldependencies.org/docsv1/u/dep/all.html) to clause
categories. There are three reserved clause categories, `:recur` (which will
look for a rule inside the rule), `:remove`, (which will ignore the clause), and
`rest` (which will gobble up any uncategorized root-level clauses).

```jldoctest
julia> using ParseTrees

julia> result = rules("hammurabi.txt.xml", institutional_grammar; rest = :aIm);

julia> result[237]
5-element Array{Pair{Symbol,String},1}:
 :Condition => "If any one hire a cart alone"
 :Attribute => "he"
   :Deontic => "shall"
    :oBject => "forty ka of corn per day"
       :aIm => "pay"
```
"""
function rules(file, clause_dict; rest = :rest)
    result = Vector{Vector{Pair{Symbol, String}}}()
    foreach(
        sentence -> begin
            root_ids = filter(word_id -> indegree(sentence, word_id) == 0, vertices(sentence))
            root_id = if length(root_ids) != 1
                nothing
            else
                first(root_ids)
            end
            seek_clauses!(result, sentence, clause_dict, root_id, rest)
        end,
        sentences(file)
    )
    result
end
export rules

end
