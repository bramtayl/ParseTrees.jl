var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#ParseTrees.annotate",
    "page": "Home",
    "title": "ParseTrees.annotate",
    "category": "function",
    "text": "annotate(file, annotators = (\"tokenize\", \"ssplit\", \"parse\"), options = ``)\n\nReturn a command line call to coreNLP to be run.\n\nMust be run with the working directory set to the location where you have unzipped coreNLP. Will take a few minutes to complete, and the resulting file will be an XML file with the same name as the input.\n\njulia> using ParseTrees\n\njulia> annotate(\"hammurabi.txt\")\n`java -cp \'*\' edu.stanford.nlp.pipeline.StanfordCoreNLP -annotators tokenize,ssplit,parse -file hammurabi.txt`\n\n\n\n\n\n"
},

{
    "location": "index.html#ParseTrees.clauses-Tuple{Any,Any,Any}",
    "page": "Home",
    "title": "ParseTrees.clauses",
    "category": "method",
    "text": "clauses(tree, meta, clause_types)\n\nPull out root level clauses that are of clause_types.\n\nInput the dependency tree and metadata that result from dependencies.\n\njulia> using ParseTrees\n\njulia> depencies_31 = collect(sentences(\"hammurabi.txt.xml\"))[31] |> dependencies;\n\njulia> clauses_31 = clauses(depencies_31.tree, depencies_31.meta, (\"advcl\", \"nsubjpass\", \"aux\"));\n\njulia> clauses_31.clauses[1]\n(clause_type = \"advcl\", text = \"If any one steal the minor son of another\")\n\njulia> clauses_31.clauses[2]\n(clause_type = \"nsubjpass\", text = \"he\")\n\njulia> clauses_31.clauses[3]\n(clause_type = \"aux\", text = \"shall\")\n\njulia> clauses_31.rest\n\", be put to death\"\n\n\n\n\n\n"
},

{
    "location": "index.html#ParseTrees.dependencies-Tuple{Any}",
    "page": "Home",
    "title": "ParseTrees.dependencies",
    "category": "method",
    "text": "dependencies(sentence)\n\nReturn meta data about each token as well as a tree of how the tokens are connected.\n\nInput one of the sentences of a coreNLP run containing at least the tokenize, ssplit, and parse annotators.\n\njulia> using ParseTrees\n\njulia> depencies_31 = collect(sentences(\"hammurabi.txt.xml\"))[31] |> dependencies;\n\njulia> depencies_31.tree\n{16, 15} directed simple Int64 graph\n\njulia> depencies_31.meta\n17-element Array{NamedTuple{(:relationship, :text),Tuple{String,String}},1}:\n (relationship = \"mark\", text = \"If\")\n (relationship = \"det\", text = \"any\")\n (relationship = \"nsubj\", text = \"one\")\n (relationship = \"advcl\", text = \"steal\")\n (relationship = \"det\", text = \"the\")\n (relationship = \"amod\", text = \"minor\")\n (relationship = \"dobj\", text = \"son\")\n (relationship = \"case\", text = \"of\")\n (relationship = \"nmod\", text = \"another\")\n (relationship = \"punct\", text = \",\")\n (relationship = \"nsubjpass\", text = \"he\")\n (relationship = \"aux\", text = \"shall\")\n (relationship = \"auxpass\", text = \"be\")\n (relationship = \"root\", text = \"put\")\n (relationship = \"case\", text = \"to\")\n (relationship = \"nmod\", text = \"death\")\n (relationship = \"punct\", text = \".\")\n\n\n\n\n\n"
},

{
    "location": "index.html#ParseTrees.sentences-Tuple{Any}",
    "page": "Home",
    "title": "ParseTrees.sentences",
    "category": "method",
    "text": "sentences(file)\n\nReturn an iterator over sentences.\n\nInput the XML results of a run of an annotate command, including at least the tokenize and ssplit annotators.\n\njulia> using ParseTrees\n\njulia> result = sentences(\"hammurabi.txt.xml\");\n\njulia> typeof(first(result))\nLightXML.XMLElement\n\n\n\n\n\n"
},

{
    "location": "index.html#ParseTrees.jl-1",
    "page": "Home",
    "title": "ParseTrees.jl",
    "category": "section",
    "text": "Modules = [ParseTrees]"
},

]}
