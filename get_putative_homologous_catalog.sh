#!/bin/bash

# Arguments
fst_genome_shared_trs="$1"
snd_genome_shared_trs="$2"
fst_genome_catalog="$3"
snd_genome_catalog="$4"

# Check for required arguments
if [ -z "$fst_genome_shared_trs" ]
then
  echo "Script requires shared TRs file (.bed) from previous alignment step - first genome"
  exit 1
fi

if [ -z "$snd_genome_shared_trs" ]
then
  echo "Script requires shared TRs file (.bed) from previous alignment step - second genome"
  exit 1
fi

if [ -z "$fst_genome_catalog" ]
then
  echo "Script requires TRF catalog for the first genome"
  exit 1
fi

if [ -z "$snd_genome_catalog" ]
then
  echo "Script requires TRF catalog for the second genome"
  exit 1
fi

# Intersect files resulting from previous alignment step for both genomes
# Get index positions from fst_genome file which correspond to the snd_genome species
awk 'BEGIN {FS="\t"; OFS="\t"} {print $5, $6, $7, $8}' "$fst_genome_shared_trs" > tmp1

bedtools intersect -a tmp1 -b "$snd_genome_shared_trs" -wb > tmp2

# Keep only columns of interest and sort file
gawk -i inplace 'BEGIN {FS="\t"; OFS="\t"} {print $1, $2, $3, $4, $9, $10, $11, $12}' tmp2
sort -k1,1 -k2,2n -k3,3 tmp2 > tmp2_sorted

# Intersect file with TRF catalog for the first genome and rearrange to get indx positions for the second genome
bedtools intersect -a "$fst_genome_catalog" -b tmp2_sorted -wa -wb > tmp3
gawk -i inplace 'BEGIN {FS="\t"; OFS="\t"} {print $14, $15, $16, $17, $1, $2, $3, $4, $5, $6, $7, $8, $13}' tmp3

# Intersect file with TRF catalog for the second genome
bedtools intersect -a "$snd_genome_catalog" -b tmp3 -wa -wb > final_list_all_info.bed
# Keep columns of interest and rearrange to keep first genome fields in the initial fields
gawk -i inplace 'BEGIN {FS="\t"; OFS="\t"} {print $14, $15, $16, $17, $18, $19, $20, $21, $22, $1, $2, $3, $4, $5, $6, $7, $8, $9}' final_list_all_info.bed

# Remove temporary files
rm tmp*

echo "You have a putative homologous TR catalog for your species pair!"
