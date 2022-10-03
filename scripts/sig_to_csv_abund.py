#!/usr/bin/env python3
"""
Given a sourmash signature, extract the minhash integers and abund info
to a csv file with the basename of the sig file name as the name of the 
abund column.

Example:
python sig_to_csv_abund.py signature csv #if the ksize = 31
python sig_to_csv_abund.py -k 21 signature csv
python sig_to_csv_abund.py -ksize 51 signature csv
"""

from sourmash import signature
import pandas as pd
import os
import sys
import argparse

def main():
    p = argparse.ArgumentParser()
    p.add_argument('-k', '--ksize', default=31)  # kmer size to use
    p.add_argument('signature')       # sourmash signature
    p.add_argument('output')          # output csv file name
    args = p.parse_args()

    # load the signature from disk
    loaded_sig = signature.load_one_signature(args.signature, ksize=args.ksize)
    
    mins = loaded_sig.minhash.hashes.keys() # get minhashes
    abund = loaded_sig.minhash.hashes.values() # get abundances
    name = loaded_sig.name # use the signature name as the column name
    
    min_df = pd.DataFrame(mins) # make mins into a df
    abund_df = pd.DataFrame(abund) # make abunds into df

    df = pd.concat([min_df, abund_df], axis=1, ignore_index=True) # combine hashes and abundances
    
    df['name'] = name # make a column with sample identifier

    df = df.rename({0: 'hash', 1: 'abund'}, axis=1) # rename columns
    
    df.to_csv(args.output, index = False) # write to a csv

if __name__ == '__main__':
    sys.exit(main())
