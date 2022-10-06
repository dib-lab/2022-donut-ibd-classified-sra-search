import pandas as pd
import os

df = pd.read_csv('ibd_full.csv')
SAMPLES=set(df['Run'])
SAMPLES=[ os.path.basename(x) for x in SAMPLES ]
SAMPLES=[ os.path.splitext(x)[0] for x in SAMPLES ]
SAMPLES=SAMPLES[:5] # subsetting first 5 samples

#SAMPLES=['SRR5962884','SRR5983264']
#SAMPLES,=glob_wildcards('inputs/{s}.sig')
#MODELS,=glob_wildcards('model/{m}.sig')
#MODELS=['SRP057027_optimal_rf_seed1.downsample']
print(SAMPLES)
#print(MODELS)

rule all:
    input:
        #expand('{sig}.x.{model}.predict.csv', sig=SAMPLES, model=MODELS)
        #expand('{sig}.x.{model}.sig',sig=SAMPLES,model=MODELS) 
        expand('{sample}.downsample.sig', sample=SAMPLES)

rule get_metagenome:
    input:
        #expand('{accession}', accession=SAMPLES)
        sig=expand(f'/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{accession}.sig', accession=SAMPLES)
    output:
        sig='{accession}.downsample.sig'
    shell: '''
        sourmash sig downsample {input.sig} --scaled 2000 -k 31 -o {output.sig}
    '''

rule do_intersect:
    input:
        sig='{accession}.downsample.sig',
        model='{model}.sig'
    output:
        sig='{accession}.x.{model}.sig'
    shell: '''
        sourmash signature intersect -A {input.sig} {input.model} -o {output.sig}
    '''

rule do_rename:
    input:
        sig='{accession}.x.{model}.sig'
    output:
        sig='{accession}.x.{model}.rename.sig'
    shell: '''
        sourmash sig rename {input.sig} "{wildcards.accession}" -o {output.sig} 
    '''

rule sig_to_csv_abund:
    input:
        sig='{accession}.x.{model}.rename.sig'
    output:
        csv='{accession}.x.{model}.csv'
    shell: '''
        python scripts/sig_to_csv_abund.py {input} {output}
    '''

rule get_predict:
    input:
        csv='{accession}.x.{model}.csv',
        model='{model}.RDS'
    output:
        csv='{accession}.x.{model}.predict.csv'
    conda: 'envs/R.yml'
    script: "scripts/predict.R"
