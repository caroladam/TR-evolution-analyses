# Scripts for analysis in Adam et al

This directory contains scripts to run TRF analysis on a cluster and filter resulting TR files.

Reference genomes used to create TR catalogs were obtained from the T2T Consortium [Primate Project v2.0](https://github.com/marbl/Primates?tab=readme-ov-file) and [CHM13 Project v2.0](https://github.com/marbl/CHM13)
The catalogs of TRs identified in T2T genomes of ape species with [run_trf.sh](https://github.com/caroladam/TR-evolution-analyses/blob/main/run_trf.sh) and filtered with [TR_filter.sh](https://github.com/caroladam/TR-evolution-analyses/blob/main/TR_filter.sh) can be found here: 

***TBD - links for our catalog repository***
- **Homo sapiens**
- **Pan troglodytes**
- **Pan paniscus**
- **Gorilla gorilla**
- **Pongo abelii**
- **Pongo pygmaeous**
- **Symphalangus syndactylus**

### Prerequisites
- bedtools
- GNU Parallel
- EMBOSS Needle

Ensure that these tools are installed and available in your PATH or provide absolute paths for each tool.

## align_lifted_TRs.sh

This script processes tandem repeat (TR) data from two genomes, aligns the TR motif sequences, and calculates alignment similarity scores. 

### Usage
`./align_lifted_TRs.sh -a <lifted_trs> -b <query_tr_list> -c <target_prefix> -d <query_prefix>`

### Arguments
- -a **<lifted_trs>**: Lifted TRs file (.bed) from the target genome.
- -b **<query_tr_list>**: Filtered TRF catalog file (.bed) from the query genome.
- -c **<target_prefix>**: Prefix/ID of the target genome.
- -d **<query_prefix>**: Prefix/ID of the query genome.

### Example
`./align_lifted_TRs.sh -a lifted_trs.bed -b query_tr_list.bed -c target_genome -d query_genome`

### Outputs
The script generates the following outputs:

`shared_trs.bed`: TRs on the TRF query genome catalog lifted from the target genome and have at least 50% reciprocal overlap.

`sim_score_<target_prefix>_<query_prefix>`: File containing similarity scores for the pairwise alignment of TR motifs from target and query genomes.

`sim_score_50_50_<target_prefix>_<query_prefix>.bed`: Filtered BED file with overlapping TRs having at least 50% motif alignment similarity

## get_putative_homology.sh

This script processes tandem repeats (TRs) shared between two genomes and creates a putative homologous TR catalog for a species pair.

### Usage
`./get_putative_homology.sh -a <fst_genome_shared_trs> -b <snd_genome_shared_trs> -c <fst_genome_catalog> -d <snd_genome_catalog>`

### Parameters
- -a **<fst_genome_shared_trs>**: Shared TRs file (.bed) from previous alignment step - first genome
- -b **<snd_genome_shared_trs>**: Shared TRs file (.bed) from previous alignment step - second genome
- -c **<fst_genome_catalog>**: TRF catalog for the first genome
- -d **<snd_genome_catalog>**: TRF catalog for the second genome

### Example
`./get_putative_homology.sh -a genome1_shared_trs.bed -b genome2_shared_trs.bed -c genome1_trf_catalog.bed -d genome2_trf_catalog.bed`

### Output
The final output file is named `homologous_tr_catalog.bed` and contains the putative homologous TR catalog for the species pair.

## Questions?
Send your questions or suggestions to carolinaladam@gmail.com
