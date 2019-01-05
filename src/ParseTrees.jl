module ParseTrees

import Base.Iterators: Generator, Filter
import LightXML: parse_file, root, name, child_elements, find_element, content, attribute
import LightGraphs: DiGraph, add_edge!, indegree, has_path, outneighbors, rem_edge!, vertices
import MetaGraphs: MetaDiGraph, set_props!, get_prop

idx(clause) = parse(Int, attribute(clause, "idx"))

export sentences
"""
    sentences(file)

Return an iterator over sentences of an `coreNLP` rules XML file.

You can run `coreNLP` through the [`command-line`](https://stanfordnlp.github.io/CoreNLP/cmdline.html).
This package only uses the [`parse`](https://stanfordnlp.github.io/CoreNLP/parse.html)
annotator.

```jldoctest
julia> using ParseTrees

julia> sentence = sentences("hammurabi.txt.xml")[2]
{29, 28} directed Int64 metagraph with Float64 weights defined by :weight (default weight 1.0)

julia> flat(sentence)
"If any one ensnare another , putting a ban upon him , but he can not prove it , then he that ensnared him shall be put to death"

julia> flat(sentence, 4)
"If any one ensnare another , putting a ban upon him"
```
"""
sentences(file) = map(
    xml_sentence -> begin
        words = collect(child_elements(first(Filter(
            annotation ->
                name(annotation) == "dependencies" &&
                attribute(annotation, "type") == "basic-dependencies",
            child_elements(xml_sentence)
        ))))
        sentence = MetaDiGraph(DiGraph(length(words) - 1))
        foreach(
            word -> begin
                governor = idx(find_element(word, "governor"))
                dependent_clause = find_element(word, "dependent")
                dependent = idx(dependent_clause)
                if governor != 0
                    add_edge!(sentence, governor, dependent)
                end
                set_props!(sentence, dependent, Dict(
                    :type => attribute(word, "type"),
                    :content => content(dependent_clause)
                ))
            end,
            words
        )
        sentence
    end,
        child_elements(find_element(
            find_element(root(parse_file(file)), "document"),
            "sentences"
        ))
)

flat_inner(sentence, words) = join(Generator(
    word -> get_prop(sentence, word, :content),
    words
), " ")

"""
    flat(sentence)

The whole sentence

    flat(sentence, root)

Just the parts of the `sentence` connected to `root`.
"""
flat(sentence) = flat_inner(sentence, vertices(sentence))
flat(sentence, root) = flat_inner(sentence, Filter(
    word -> has_path(sentence, root, word),
    vertices(sentence)
))
export flat

"""
    const deontic

Default pattern to recognize `deontic`s.
"""
const deontic = r"(should)|(will)|(shall)|(must)|(may)|(can)"
export deontic

"""
    dictionary

A dictionary based on Elinor Ostrom's [`institutional grammar`](https://www.jstor.org/stable/2082975).
"""
dictionary = Dict(
    "acl" => :not_in_root, # adjectival clause
    "advcl" => :condition,  # adverbial clause modifier
    "advmod" => :condition, # adverbial modifier
    "amod" => :not_in_root, # adjectival modifier
    "apos" => :not_in_root, # appositional modifier
    "aux" => :deontic, # auxiliary
    "auxpass" => :root, # passive auxiliary
    "case" => :not_in_root, # case marking
    "cc" => :remove, # coordinating conjunction
    "ccomp" => :object, # clausal component
    "compound" => :root,
    "conj" => :recur, # conjunct
    "cop" => :root, # copula
    "csubj" => :attribute, # clausal subject
    "csubjpass" => :attribute, # clausal subject passive
    "dep" => :not_sure, # unspecified dependency
    "det" => :not_in_root, # determiner
    "discourse" => :remove,
    "dislocated" => :not_sure,
    "dobj" => :object, # direct object
    "expl" => :root, # expletive
    "foreign" => :not_sure, # foreign words
    "goeswith" => :root, # goes with
    "iobj" => :root, # indirect object
    "list" => :recur,
    "mark" => :not_in_root, # marker
    "mwe" => :root, # multiword expression
    "name" => :not_in_root,
    "neg" => :root, # negation modifier
    "nmod" => :condition, # nominal modifier
    "nsubj" => :attribute, # nominal subject
    "nsubjpass" => :attribute, # nominal subject passive
    "nummod" => :not_in_root, # numeric modifier
    "parataxis" => :recur,
    "punct" => :remove, # punctuation
    "remnant" => :not_sure, # remnant in ellipisis
    "reparandum" => :not_sure, # overridden disfluency
    "root" => :root,
    "vocative" => :remove,
    "xcomp" => :object, # open clausal component
)
export dictionary

function clauses!(rules, sentence, dictionary, deontic, root)
    clauses = Vector{Pair{Int, Symbol}}()
    is_rule = false
    for clause in copy(outneighbors(sentence, root))
        component = dictionary[split(get_prop(sentence, clause, :type), ':')[1]]
        if component == :recur
            clauses!(rules, sentence, dictionary, deontic, clause)
            rem_edge!(sentence, root, clause)
        elseif component == :deontic
            if occursin(deontic, flat(sentence, clause))
                is_rule = true
                rem_edge!(sentence, root, clause)
                push!(clauses, clause => component)
            else
                component = :root
            end
        elseif component == :remove
            rem_edge!(sentence, root, clause)
        elseif component != :root
            rem_edge!(sentence, root, clause)
            push!(clauses, clause => component)
        end
    end
    if is_rule
        push!(clauses, root => :root)
        push!(rules, map(
            clause -> clause.second => flat(sentence, clause.first),
            clauses
        ))
    end
end

"""
    split_rules(file; dictionary = dictionary, deontic = deontic)

Split `file` into rules. Split each rule into components based on `dictionary`,
starting at the root. The `dictionary` should be a map from [Universal
Dependencies (v1)](http://universaldependencies.org/docsv1/u/dep/all.html) to
clause components. `:deontic`s must additionally match the `deontic` pattern.
Rules must contain a deontic. `:recur` will look for a rule inside the rule,
`:remove` will remove the clause, and `:root` will include the root.

```jldoctest
julia> using ParseTrees

julia> parsed = split_rules("hammurabi.txt.xml");

julia> parsed[25]
6-element Array{Pair{Symbol,String},1}:
 :condition => "If the slave will not give the name of the master"
 :attribute => "the finder"
   :deontic => "shall"
    :object => "him"
 :condition => "to the palace"
      :root => "bring"
```
"""
function split_rules(file; dictionary = dictionary, deontic = deontic)
    rules = Vector{Vector{Pair{Symbol, String}}}()
    for sentence in sentences(file)
        roots = filter(word -> indegree(sentence, word) == 0, vertices(sentence))
        if length(roots) >= 1
            clauses!(rules, sentence, dictionary, deontic, first(roots))
        end
    end
    rules
end
export split_rules

end
