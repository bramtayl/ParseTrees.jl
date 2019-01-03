var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.jl",
    "category": "page",
    "text": ""
},

{
    "location": "#ParseTrees.clauses-Tuple{Any,Any}",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.clauses",
    "category": "method",
    "text": "clauses(dependencies_result, clause_types)\n\nPull out root level clauses that are of clause_types from the result of dependencies.\n\n\n\n\n\n"
},

{
    "location": "#ParseTrees.dependencies-Tuple{Any}",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.dependencies",
    "category": "method",
    "text": "dependencies(sentence)\n\nReturn meta-data about each token as well as a tree of how the tokens are connected.\n\n\n\n\n\n"
},

{
    "location": "#ParseTrees.rules-Tuple{Any}",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.rules",
    "category": "method",
    "text": "rules(document)\n\nFind the institutional grammar components in a coreNLP result.\n\njulia> using ParseTrees\n\njulia> result = rules(\"hammurabi.txt.xml\");\n\njulia> length(result)\n234\n\njulia> result[2]\n5-element Array{Pair{Symbol,String},1}:\n :Attribute => \"his accuser\"\n   :Deontic => \"shall\"\n       :aIm => \"take\"\n :Condition => \"If any one bring an accusation against a man , and the accused go to the river and leap into the river , if he sink in the river\"\n    :Object => \"possession of his house\"\n\n\n\n\n\n"
},

{
    "location": "#ParseTrees.sentences-Tuple{Any}",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.sentences",
    "category": "method",
    "text": "sentences(file)\n\nReturn an iterator over sentences of an XML coreNLP result.\n\nYou can run coreNLP through the command-line. This package only requires three annontators: tokenize, ssplit, and parse.\n\n\n\n\n\n"
},

{
    "location": "#ParseTrees.jl-1",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.jl",
    "category": "section",
    "text": "Modules = [ParseTrees]"
},

]}
