var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.jl",
    "category": "page",
    "text": ""
},

{
    "location": "#ParseTrees.institutional_grammar",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.institutional_grammar",
    "category": "constant",
    "text": "institutional_grammar\n\nA clause dict based on Elinor Ostrom\'s institutional grammar. Of the forty universal dependencies, many are labelled as :not_applicable, meaning they will not occur in the root. Several are labelled :not_sure, meaning it could or could not be one of the 6 components of institutional grammar. Then there are the ABDICO components, less Or else, which can\'t be determined grammatically, and aIm, which will end up as rest. Sub-clauses are marked for recursion, and superfluous clauses are marked for removel.\n\n\n\n\n\n"
},

{
    "location": "#ParseTrees.flat-Tuple{Any}",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.flat",
    "category": "method",
    "text": "flat(sentence)\n\nJust add water\n\nflat(sentence, id)\n\nJust the parts of the sentence connected to id.\n\n\n\n\n\n"
},

{
    "location": "#ParseTrees.rules-Tuple{Any,Any}",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.rules",
    "category": "method",
    "text": "rules(file, clause_dict; rest = :rest)\n\nSplit the sentences of a file into groups of clauses based on clause_dict, starting at the root. Clause dict should be a map from Universal Dependencies (v1) to clause categories. There are three reserved clause categories, :recur (which will look for a rule inside the rule), :remove, (which will ignore the clause), and rest (which will gobble up any uncategorized root-level clauses).\n\njulia> using ParseTrees\n\njulia> result = rules(\"hammurabi.txt.xml\", institutional_grammar; rest = :aIm);\n\njulia> result[237]\n5-element Array{Pair{Symbol,String},1}:\n :Condition => \"If any one hire a cart alone\"\n :Attribute => \"he\"\n   :Deontic => \"shall\"\n    :oBject => \"forty ka of corn per day\"\n       :aIm => \"pay\"\n\n\n\n\n\n"
},

{
    "location": "#ParseTrees.sentences-Tuple{Any}",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.sentences",
    "category": "method",
    "text": "sentences(file)\n\nReturn an iterator over sentences of an XML coreNLP result.\n\nYou can run coreNLP through the command-line. This package only requires three annontators: tokenize, ssplit, and parse.\n\njulia> using ParseTrees\n\njulia> result = sentences(\"hammurabi.txt.xml\");\n\njulia> result[2]\n{29, 28} directed Int64 metagraph with Float64 weights defined by :weight (default weight 1.0)\n\njulia> flat(result[2])\n\"If any one ensnare another , putting a ban upon him , but he can not prove it , then he that ensnared him shall be put to death\"\n\njulia> flat(result[2], 4)\n\"If any one ensnare another , putting a ban upon him\"\n\n\n\n\n\n"
},

{
    "location": "#ParseTrees.jl-1",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.jl",
    "category": "section",
    "text": "Modules = [ParseTrees]"
},

]}
