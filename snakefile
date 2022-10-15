import pandas as pd
import os

df = pd.read_csv('input/ibd_full.csv')
SAMPLES=set(df['Run'])
SAMPLES=[ os.path.basename(x) for x in SAMPLES ]
SAMPLES=[ os.path.splitext(x)[0] for x in SAMPLES ]
#SAMPLES=SAMPLES[:5] #SUBSETTING FIRST 5 SAMPLES


#SAMPLES=['SRR5962884','SRR5983264']
#SAMPLES,=glob_wildcards('inputs/{s}.sig')
MODELS,=glob_wildcards('model/{m}.sig')
#MODELS=['SRP057027_optimal_rf_seed1']
print(SAMPLES)
print(MODELS)

rule all:
    input:
        'output/all.predicts.csv'
        #expand('output/predict.{sig}.x.{model}.csv', sig=SAMPLES, model=MODELS)
        #expand('{sig}.x.{model}.sig',sig=SAMPLES,model=MODELS) 
        #expand('output/{sample}.downsample.sig', sample=SAMPLES)

rule get_metagenome:
    input:
        sig='/group/ctbrowngrp/irber/data/wort-data/wort-sra/sigs/{accession}.sig'
    output:
        sig=temporary('output/{accession}.downsample.sig')
    shell: '''
        sourmash sig downsample {input.sig} --scaled 2000 -k 31 -o {output.sig}
    '''

rule do_intersect:
    input:
        sig='output/{accession}.downsample.sig',
        model='model/{model}.sig'
    output:
        sig=temporary('output/{accession}.x.{model}.sig')
    shell: '''
        sourmash signature intersect -A {input.sig} {input.model} -o {output.sig}
    '''

rule do_rename:
    input:
        sig='output/{accession}.x.{model}.sig'
    output:
        sig=temporary('output/{accession}.rename.{model}.sig')
    shell: '''
        sourmash sig rename {input.sig} "{wildcards.accession}" -o {output.sig} 
    '''

rule sig_to_csv_abund:
    input:
        sig='output/{accession}.rename.{model}.sig'
    output:
        csv=temporary('output/{accession}.x.{model}.csv')
    shell: '''
        python scripts/sig_to_csv_abund.py {input} {output}
    '''

rule get_predict:
    input:
        csv='output/{accession}.x.{model}.csv',
        model='model/{model}.RDS'
    output:
        csv=temporary('output/{accession}.predict.{model}.csv')
    #conda: 'envs/R.yml'
    script: "scripts/predict.R"

rule cat_predicts:
    input:
        csv=expand('output/{accession}.predict.{model}.csv', accession=SAMPLES, model=MODELS)
    output:
        csv='output/all.predicts.csv'
    shell: '''
        awk '(NR == 1) || (FNR > 1)' {input.csv} > {output.csv}
        #FNR represents the number of the processed record in a single file. And NR represents it globally, so first line is accepted and the rest are ignored as before.
    '''
