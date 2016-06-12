import os
from os.path import join

configfile: "config.json"

rule all:
    input:
        expand("{basedir}out/bunzip/{sample}.fastq",
               basedir=config["basedir"],
               sample=config['data']),
        expand("{basedir}out/useless/{sample}_fastqc/",
               basedir=config["basedir"],
               sample=config['data'])

rule bunzip:
    input:
        lambda wildcards: expand("{basedir}{data}",
                                 basedir=config["basedir"],
                                 data=config["data"][wildcards.data])
    output:
        "{basedir}out/bunzip/{data}.fastq"
    log:
        "{basedir}out/{data}.log"
    threads:
        1
    shell:
        "bunzip2 -d -c {input} > {output}"

rule fastqc:
    input:
        fastq = "{basedir}out/bunzip/{sample}.fastq"
    output:
        "{basedir}out/useless/{sample}_fastqc/"
    params:
        dir = "{basedir}out/fastqc"
    log:
        "fastqc.log"
    threads:
        2
    shell:
        "fastqc -q -t {threads} --outdir {params.dir} {input.fastq} > {params.dir}/{log}"
