# -*- coding: utf-8 -*-
#
import os
from os.path import join

# Gobals  ---------------------------------------------------------------------
configfile: "config.json"

# define species
"""0: at, 1:hg, 2:mm
Please modify the correspond species in the config.json
"""
species = config["species"][config["aspecies"]]

# define num of thread
num_threads = config["num_threads"]

# define root path
root_dir = config["basedir"]

# define basic input
in_dir = join(root_dir, "in")
gene_dir = join(in_dir, "gene", species)
sample_dir = join(in_dir, "sample")

# define basic output
out_dir = join(root_dir, "out")
tmp_dir = join(out_dir, "userless")

# get files in a folder
"""origin input: xxx.bt2, expected output: xxx"""
gene_file = os.listdir(gene_dir)[0].split(".")[0]
gene_file_path = join(gene_dir, gene_file)

# get all case of treatments
batches = config["batches"]
treatment = batches["treatment"]
control = batches["control"]

# Rules -----------------------------------------------------------------------
rule all:
    input:
        expand(join(out_dir, "bowtie2", "{batch}.sam"),
               batch=set(treatment + control)),
        expand(join(out_dir, "macs2", "{trea}___{cont}/"),
               trea=treatment,
               cont=control)

rule bowtie2:
    input:
        join(sample_dir, "{batch}.fastq.gz")
    output:
        join(out_dir, "bowtie2", "{batch}.sam")
    params:
        gene = gene_file_path
    threads:
        4
    shell:
        "bowtie2 --threads " + num_threads + " -x {params.gene} -U {input} -S {output}"

rule macs2:
    input:
        t = join(out_dir, "bowtie2", "{trea}.sam"),
        c = join(out_dir, "bowtie2", "{cont}.sam")
    output:
        join(out_dir, "macs2", "{trea}___{cont}/")
    threads:
        4
    run:
        treat = input.t.split("/")[-1]
        contro = input.c.split("/")[-1]
        if len(set(treat) & set(contro)) > 0:
            shell("macs2 callpeak -t {input.t} -c {input.c} -f SAM -g hs -n {output} -B -q 0.01")
