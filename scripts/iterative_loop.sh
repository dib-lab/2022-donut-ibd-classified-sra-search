#!/bin/bash

###
#This script will iterate through each of the 36 RF seeds created by Taylor.
#It will intersect and rename the MAGsearch signatures across each of the 36 classifiers.
#It has been written to run from a `~/scripts` directory pointing at the signature directory.

#Example: ./iterative_loop.sh ../sigs
#https://tldp.org/LDP/abs/html/refcards.html#AEN22828
###

sigs="../sigs/*seed[1-6].sig"
files="$1*.sig"
for f in $files
do
    for s in $sigs
    do
	base_sigs=$(basename ${s})
	base_files=$(basename ${f})
	echo ${base_sigs}
	echo ${base_files}
        echo " "
        echo "Processing ${base_sigs:0:-4} seed with ${base_files%.*} file"
        echo " "
        sourmash signature intersect -A $f $s -o ${f%/*}/${base_files%.*}\_${base_sigs%.*}.sig
        sourmash signature rename ${f%/*}/${base_files%.*}\_${base_sigs%.*}.sig "${base_files%.*}" -o ${f%/*}/${base_files%.*}\_${base_sigs%.*}\.renam.sig
        python sig_to_csv_abund.py ${f%/*}/${base_files%.*}\_${base_sigs%.*}\.renam.sig ${f%/*}/${base_files%.*}\_${base_sigs%.*}\.renam.csv
        echo " "
        echo "${base_sigs:0:-4} seed with ${base_files%.*} file complete!"
        echo ""
    done
done
