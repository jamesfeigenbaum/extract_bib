# extract_bib
## feigenbaum
## 24feb2017

### Introduction
`extract_bib` is a simple `R` script to create minimal a `bibtex` library file for an article. Some journals require `tex` and `bib` files with submissions. However, I have only one *master* `bib` file. That file currently contains 3543 references. Rather than send all of that to the journal to help typeset my manuscript, I only want to send a `bib` file with the references included in my article. This script does that.

### Work flow

- Read a `tex` file
- Extract all of the citations
- Read a master `bib` file
- Match the citations from the `tex` file to the master library `bib` file
- Output a minimal library for submission

### To Do

- I use `natbib` and so the citations I search for in the `tex` file are only `citet{}` and `citep{}`. Expand this to other citation functions.
- I remove some crud from the library put there by my citation manager (Mendeley](https://www.mendeley.com/)), including annotations and file locations, as well as abstracts. If there are other unneeded fields, they can be removed from the minimal library output.
- Expand to work with multiple input libraries or multiple input `tex` files?
