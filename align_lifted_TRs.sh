#!/bin/bash

lifted_trs="$1"
query_tr_list="$2"
target_prefix="$3"
query_prefix="$4"

# Check if you provided all arguments
if [ -z "$lifted_trs" ]
then
  echo "Script requires lifted TRs file (.bed) as argument"
  exit 1
fi

if [ -z "$query_tr_list" ]
then
  echo "Script requires filtered TRF catalog file (.bed) from query genome as argument"
  exit 1
fi

if [ -z "$target_prefix" ]
then
  echo "Script requires ID of target genome as argument"
  exit 1
fi

if [ -z "$query_prefix" ]
then
  echo "Script requires ID of query genome as argument"
  exit 1
fi

# Create directories for fasta files and aligned files
fasta_dir=$(mktemp -d fasta_XXXXXX)
aligned_dir="aligned"
mkdir -p "$aligned_dir"

# Intersect regions of the lifted TRs file with TRF catalog for the query genome
shared_trs="shared_trs.bed"
bedtools intersect -a "$lifted_trs" -b "$query_tr_list" -wa -wb -f 0.50 -r > "$shared_trs"

# Add species names and keep only columns of interest - index and motif sequence, then split file to keep one TR per file
awk -v tgt="$target_prefix" -v qry="$query_prefix" \
    'BEGIN {FS="\t"; OFS="\t"} {print tgt, $1, $2, $3, $7, qry, $1, $2, $3, $19, $10, $11, $12, tgt}' "$shared_trs" | split -l 1 - "$fasta_dir/x"

# Structure each file as FASTA
cd "$fasta_dir"
for file in x*
do
    awk 'BEGIN {FS="\t"; OFS="_"} {print ">"$1, $2, $3, $4"\n"$5"\n"">"$6, $7, $8, $9, $11, $12, $13, $14"\n"$10}' "$file" > "$file.fa"
done

# Align fasta files with Needle using GNU Parallel
parallel -j $(nproc) "needle -asequence {1} -bsequence {1} -gapopen 10 -gapextend 0.5 -outfile ${aligned_dir}/{1}.out" ::: *.fa

cd ../

# Get alignment similarity scores
for file in "${aligned_dir}"/*.out
do
    # Extract similarity scores
    grep "Similarity" "${file}" | grep -o "[0-9]*\.[0-9]*" >> score.txt
    grep ">${query_prefix}" "${file}" >> bedloc.txt
done

# Combine bed locations and scores into a single file with target and query prefixes
paste bedloc.txt score.txt > "sim_score_${target_prefix}_${query_prefix}"
rm bedloc.txt score.txt

# Clean up unnecessary text from the output file
sed -i 's/[a-z]*\.fa\.out:>//g' "sim_score_${target_prefix}_${query_prefix}"

rm -r "$fasta_dir"

# Get subset of TRs with >=50% alignment similarity
awk '$2 >= 50' sim_score_${target_prefix}_${query_prefix} | sed 's/_/\t/g; s/"//g'
awk 'BEGIN {FS="\t"; OFS="\t"} {print $2, $3, $4, $1, $5, $6, $7, $8}' sim_score_${target_prefix}_${query_prefix} > sim_score_50_50_${target_prefix}_${query_prefix}.bed

echo "Alignment similarity score extraction and formatting completed."
