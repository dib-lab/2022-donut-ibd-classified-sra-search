WIP! Here ther' be dragons!

This repo exist to answer the question of "what if we took classified hashes from a Random Forest model and used them to search the entire SRA database?".

The general workflow:
1. merge the population of classified hashes into a single signature file of `k=31` and `scaled=2000`.
2. use that merged signature file in MAGsearch to find all related signature files from the `Wort-SRA` database.
3. use the classifier to predict the outcome of signature files from the SRA search.
4. ...
5. ?
6. who knows... 
