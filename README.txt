Step 1: Convert each of the two pkl files (Python pickle) to JSON, specifying the input and the output files. This is what pkl_to_json.py does. It 'flattens' the data into three JSON files are generated containing lists:
- one with the words, i.e. the key. This is a list of length n.
- one with the years, i.e. a list of (n) lists, one for each word. The years are an index for the change values. They need not be in chronological order.
- one with the values, i.e. the similarity scores. This is a list of n lists. Each element corresponds to its equivalent in the years file.
The aim of the flattening is for easier processing (using maplist) in Prolog.

Step 2: Postprocess the JSON files.
The unpickle / json dump script of step 1 generates NaN for missing values (in the values file). However, the JSON parser in SWI Prolog does not recognise these. This issue is solved when the NaN are quoted, like this: 
sed -i 's/NaN/"NaN"/g' consec-values
sed -i 's/NaN/"NaN"/g' vsnow-values
Beware that on Mac OS, you need to specify a file extension for the original file that is automatcially backed up. So the sed in its form above will not work on Mac OS.

Step 3: Map the data against WordNet and put into RDF.
This is what script map does. It first loads WordNet (pre-downloaded as nt.gz) into a graph, then calls wordnet_mapping.pl to loop over the complementary JSON files and process the {word, year, score} values. The main actions are these:
- take the direct lexical match whenever possible, else match on the porter stemmed form;
- if the word did not appear in WN but matches a WN form when stemmed, then define it as a lexicalvariant of that WN form;
- convert the similarity score to a distance one using arccos.

