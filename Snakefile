# -*- coding: utf-8 -*-
#
import os
from os.path import join

# Gobals  ---------------------------------------------------------------------
configfile: "config.json"

# define root path
root_dir = config["basedir"]

# define basic input
in_dir = join(root_dir, "in")

# define basic output
out_dir = join(root_dir, "out")
tmp_dir = join(out_dir, "userless")

# define detailed output
raw_data_dir = join(out_dir, "bunzip")
fastqc_dir = join(out_dir, "fastqc")

# get files in a folder
origin_data_files = [f.split(".")[0]
                     for f in os.listdir(in_dir)]

# Rules -----------------------------------------------------------------------
rule all:
    input:
        expand(join(raw_data_dir, "{data}.fastq"), data=origin_data_files),
        expand(tmp_dir + "/{sample}_fastqc/", sample=origin_data_files)

rule bunzip:
    input:
        expand(join(in_dir, "{data}.fastq.bz2"), data=origin_data_files)
    output:
        join(raw_data_dir, "{data}.fastq")
    threads:
        1
    shell:
        "bunzip2 -d -c {input} > {output}"

rule fastqc:
    input:
        fastq = join(raw_data_dir, "{sample}.fastq")
    output:
        join(tmp_dir, "{sample}_fastqc/")
    params:
        dir = fastqc_dir
    log:
        join(fastqc_dir, "fastqc.log")
    threads:
        2
    shell:
        "fastqc -q -t {threads} --outdir {params.dir} {input.fastq} > {log}"
