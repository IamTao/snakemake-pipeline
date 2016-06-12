# -*- coding: utf-8 -*-
#
import os
from os.path import join

# Gobals  ---------------------------------------------------------------------
configfile: "config.json"

root_dir = config["basedir"]
out_dir = join(root_dir, "out")
raw_data_dir = join(out_dir, "bunzip")
tmp_dir = join(out_dir, "userless")
fastqc_dir = join(out_dir, "fastqc")

# Rules -----------------------------------------------------------------------
rule all:
    input:
        expand(raw_data_dir + "/{sample}.fastq",
               sample=config['data']),
        expand(tmp_dir + "/{sample}_fastqc/",
               sample=config['data'])

rule bunzip:
    input:
        lambda wildcards: expand("{basedir}{data}",
                                 basedir=config["basedir"],
                                 data=config["data"][wildcards.data])
    output:
        raw_data_dir + "/{data}.fastq"
    threads:
        1
    shell:
        "bunzip2 -d -c {input} > {output}"

rule fastqc:
    input:
        fastq = raw_data_dir + "/{sample}.fastq"
    output:
        tmp_dir + "/{sample}_fastqc/"
    params:
        dir = fastqc_dir
    log:
        fastqc_dir + "/fastqc.log"
    threads:
        2
    shell:
        "fastqc -q -t {threads} --outdir {params.dir} {input.fastq} > {log}"
