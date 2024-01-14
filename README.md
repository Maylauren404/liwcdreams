# LiwcDreams
## Advanced Representation of Dream Analysis Using LIWC Linguistic and Semantic Categories

### Script: liwcdreams1.0.pl
#### Description
This script efficiently processes linguistic data using the LIWC (Linguistic Inquiry and Word Count) dictionaries. Key features include:
- **Efficient Loading**: Rapidly loads LIWC dictionaries into memory.
- **Dream Corpus Analysis**: Analyzes a corpus of dreams, examining each word.
- **Vector Compilation**: For every identified word, cross-references the LIWC dictionaries and compiles a comprehensive vector quantifying each term's occurrence.

### Script: simdreamvec1.0.pl
#### Description
A utility designed for analyzing vectorial representations from dream narratives. It employs various algorithms to ascertain similarities between two vectors:
- **Cosine Similarity**: Measures the cosine of the angle between vectors, indicating orientation in multi-dimensional space.
- **Jaccard Similarity**: Evaluates the similarity and diversity of sample sets.
- **Euclidean Distance**: Calculates 'straight-line' distance between points in Euclidean space.
- **Integration**: Intended to work seamlessly with the output from liwcdreams1.0.pl.

### Resource File: liwcdreams1.0.xlsx
#### Description
A comprehensive resource file that includes:
- **Dreams and Analyses**: A curated collection of dreams and their analyses.
- **LIWC Categorization**: Represented as vectors categorizing various LIWC dimensions, essential for in-depth exploration of dream narratives.
