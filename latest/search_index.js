var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#ParseTrees.parse_tree-Tuple{Any}",
    "page": "Home",
    "title": "ParseTrees.parse_tree",
    "category": "method",
    "text": "parse_tree(file, format = \"enhanced-plus-plus-dependencies\")\n\nProcess the results of the coreNLP parse annotator from an XML file.\n\nFor each sentence, will return meta data about each word as well as a tree of how the words are connected.\n\nYou can run coreNLP through the command line. A minimal command is java -cp \"*\" edu.stanford.nlp.pipeline.StanfordCoreNLP -annotators tokenize,ssplit,parse -fileList FILE_LIST from the folder where you unzipped coreNLP. The resulting files will be in the format FILE.xml, each of which you can parse with parse_tree.\n\njulia> using ParseTrees\n\njulia> result = parse_tree(\"hammurabi.txt.xml\");\n\njulia> result[31].meta\n17-element Array{NamedTuple{(:relationship, :text),Tuple{String,String}},1}:\n (relationship = \"mark\", text = \"If\")\n (relationship = \"det\", text = \"any\")\n (relationship = \"nsubj\", text = \"one\")\n (relationship = \"advcl:if\", text = \"steal\")\n (relationship = \"det\", text = \"the\")\n (relationship = \"amod\", text = \"minor\")\n (relationship = \"dobj\", text = \"son\")\n (relationship = \"case\", text = \"of\")\n (relationship = \"nmod:of\", text = \"another\")\n (relationship = \"punct\", text = \",\")\n (relationship = \"nsubjpass\", text = \"he\")\n (relationship = \"aux\", text = \"shall\")\n (relationship = \"auxpass\", text = \"be\")\n (relationship = \"root\", text = \"put\")\n (relationship = \"case\", text = \"to\")\n (relationship = \"nmod:to\", text = \"death\")\n (relationship = \"punct\", text = \".\")\n\njulia> result[31].tree\n{16, 15} directed simple Int64 graph\n\n\n\n\n\n"
},

{
    "location": "index.html#ParseTrees.separate_clauses-Tuple{Any,Any}",
    "page": "Home",
    "title": "ParseTrees.separate_clauses",
    "category": "method",
    "text": "separate_clauses(sentence, clause_types)\n\nPull out root level clauses from a parsed sentence that are one of the clause_types.\n\njulia> using ParseTrees\n\njulia> sentence = parse_tree(\"hammurabi.txt.xml\")[31];\n\njulia> result = separate_clauses(sentence, (\"advcl:if\", \"nsubjpass\", \"aux\"));\n\njulia> result.clauses[1]\n(clause_type = \"advcl:if\", text = \"If any one steal the minor son of another\")\n\njulia> result.clauses[2]\n(clause_type = \"nsubjpass\", text = \"he\")\n\njulia> result.clauses[3]\n(clause_type = \"aux\", text = \"shall\")\n\njulia> result.rest\n\", be put to death\"\n\n\n\n\n\n"
},

{
    "location": "index.html#ParseTrees.jl-1",
    "page": "Home",
    "title": "ParseTrees.jl",
    "category": "section",
    "text": "Modules = [ParseTrees]"
},

]}
