#!/bin/bash

usage() {
    echo "Usage: $0 <path_to_fasta_files> <path_to_trf_executable>"
    exit 1
}

# Check if arguments are provided
if [ "$#" -ne 2 ]
then
    echo "Insufficient arguments."
    usage
fi

# Assign arguments to variables
genomes_dir="$1"
trf_dir="$2"

echo "Running TRF"

# trf config
matchscore=2
mismatchscore=5
indelscore=7
pm=80
pi=10
minscore=24 
maxperiod=2000 

# Run TRF on each .fa file in the genomes directory
for fasta_file in "$genomes_dir"/*.fa
do
    if [ ! -e "$fasta_file" ]
    then
        echo "No .fa files found in the directory."
        exit 1
    fi
    
    "$trf_dir"/trf "$fasta_file" "$match_score" "$mismatch_score" "$indel_score" "$pm" "$pi" "$min_score" "$max_period" -f -d -h -l 6
done

echo "TRF processing completed for all .fa files in $genomes_dir."
