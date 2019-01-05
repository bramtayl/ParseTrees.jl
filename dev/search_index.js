var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.jl",
    "category": "page",
    "text": ""
},

{
    "location": "#ParseTrees.deontic",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.deontic",
    "category": "constant",
    "text": "const deontic\n\nDefault pattern to recognize deontics.\n\n\n\n\n\n"
},

{
    "location": "#ParseTrees.dictionary",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.dictionary",
    "category": "constant",
    "text": "dictionary\n\nA dictionary based on Elinor Ostrom\'s institutional grammar.\n\n\n\n\n\n"
},

{
    "location": "#ParseTrees.flat-Tuple{Any}",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.flat",
    "category": "method",
    "text": "flat(sentence)\n\nThe whole sentence\n\nflat(sentence, root)\n\nJust the parts of the sentence connected to root.\n\n\n\n\n\n"
},

{
    "location": "#ParseTrees.sentences-Tuple{Any}",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.sentences",
    "category": "method",
    "text": "sentences(file)\n\nReturn an iterator over sentences of an coreNLP rules XML file.\n\nYou can run coreNLP through the command-line. This package only uses the parse annotator.\n\njulia> using ParseTrees\n\njulia> sentence = sentences(\"hammurabi.txt.xml\")[2]\n{29, 28} directed Int64 metagraph with Float64 weights defined by :weight (default weight 1.0)\n\njulia> flat(sentence)\n\"If any one ensnare another , putting a ban upon him , but he can not prove it , then he that ensnared him shall be put to death\"\n\njulia> flat(sentence, 4)\n\"If any one ensnare another , putting a ban upon him\"\n\n\n\n\n\n"
},

{
    "location": "#ParseTrees.split_rules-Tuple{Any}",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.split_rules",
    "category": "method",
    "text": "split_rules(file; dictionary = dictionary, deontic = deontic)\n\nSplit file into rules. Split each rule into components based on dictionary, starting at the root. The dictionary should be a map from Universal Dependencies (v1) to clause components. :deontics must additionally match the deontic pattern. Rules must contain a deontic. :recur will look for a rule inside the rule, :remove will remove the clause, and :root will include the root.\n\njulia> using ParseTrees\n\njulia> parsed = split_rules(\"hammurabi.txt.xml\");\n\njulia> parsed[25]\n6-element Array{Pair{Symbol,String},1}:\n :condition => \"If the slave will not give the name of the master\"\n :attribute => \"the finder\"\n   :deontic => \"shall\"\n    :object => \"him\"\n :condition => \"to the palace\"\n      :root => \"bring\"\n\n\n\n\n\n"
},

{
    "location": "#ParseTrees.jl-1",
    "page": "ParseTrees.jl",
    "title": "ParseTrees.jl",
    "category": "section",
    "text": "Modules = [ParseTrees]"
},

]}
