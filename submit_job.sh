#! /bin/bash -login
#SBATCH -p high2
#SBATCH -J predict
#SBATCH -t 72:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 32
#SBATCH --mem=50GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ccbaumler@ucdavis.edu
#SBATCH -o /home/baumlerc/2022-ibd-hash-sra-search/2022-import-ranger-hashes/donut/reports/predict.out
#SBATCH -e /home/baumlerc/2022-ibd-hash-sra-search/2022-import-ranger-hashes/donut/reports/predict.err

# activate conda
. "/home/baumlerc/miniconda3/etc/profile.d/conda.sh"

# activate snakemake env
conda activate snakemake

#run snakemake job from magsearch.snakefile with 24 threads
#config-ibd.yml contains parameters
snakemake -j 24 --latency-wait 20

