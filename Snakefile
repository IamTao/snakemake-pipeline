# -*- coding: utf-8 -*-
#
import os
from os.path import join

# Gobals  ---------------------------------------------------------------------
configfile: "config.json"

# define species
"""0: at, 1:hg, 2:mm"""
species = config["species"][1]

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
batches = config["batch"]
bowtie2_tests = []
bowtie2_tasks = []
macs2_tests = []
macs2_treatments = []
macs2_control = []

for k, v in batches.items():
    treatment = set(v["treatment"])
    control = set(v["control"])
    bowtie2_tasks += treatment
    bowtie2_tasks += control
    bowtie2_tests += [k] * (len(treatment) + len(control))
    macs2_tests += [k] * 2 * len(v["treatment"])
    macs2_treatments += v["treatment"]
    macs2_control += v["control"]

# Rules -----------------------------------------------------------------------
rule all:
    input:
        expand(join(out_dir, "{test}/bowtie2", "{task}.sam"),
               test=bowtie2_tests,
               task=bowtie2_tasks),
        expand(join(out_dir, "{test}/macs2", "{treatment}__{control}/"),
               test=macs2_tests,
               treatment=macs2_treatments,
               control=macs2_control)

rule bowtie2:
    input:
        join(sample_dir, "{test}/{task}.fastq.gz")
    output:
        join(out_dir, "{test}/bowtie2", "{task}.sam")
    params:
        gene = gene_file_path
    threads:
        4
    shell:
        "bowtie2 --threads 4 -x {params.gene} -U {input} -S {output}"

rule macs2:
    input:
        treatment = join(out_dir, "{test}/bowtie2", "{treatment}.sam"),
        control = join(out_dir, "{test}/bowtie2", "{control}.sam")
    output:
        join(out_dir, "{test}/macs2", "{treatment}__{control}/")
    params:
        dir = join(out_dir, "{test}/macs2", "{treatment}__{control}/")
    threads:
        4
    shell:
        """
        macs2 callpeak -t {input.treatment} -c {input.control} -f SAM -g hs -n {params.dir} -B -q 0.01
        """
