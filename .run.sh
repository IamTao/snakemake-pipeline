rm -rf .snakemake
rm -rf data/out
snakemake --cores 4 --latency-wait 16
