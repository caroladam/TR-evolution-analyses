#!/bin/bash

function trim_path {
	echo $1 | sed 's/\/$//'
}

function trim_file {
  echo $1 | grep -o '[^\/]*$' | sed 's/\.[^\.]*$//'
}

function get_prefix {
  echo "${1%%.*}"
}

trf_dir=$1
outfile=$2

# Check for required arguments
if [ -z "$trf_dir" ]
then
	echo 'Script requires path to TRF results directory as argument'
	exit 1
fi

if [ -z "$outfile" ]
then
	echo 'Script requires OUTFILE name as argument'
	exit 1
fi

# Check if outfile already exists
if [ -f "$outfile" ]
then
	echo "Outfile $outfile already exists"
	exit 1
else
	touch "$outfile"
fi

# Concatenate and process TRF results
for file in "$trf_dir"/*.dat
do
	# Remove headers
	sed -i '/^[0-9]/!d' "$file"
	filename=$( trim_file "$file" )
	prefix=$( get_prefix "$filename" )
	cat "$file" | \
		# Extract columns of interest and calculate TR total length
		awk -v "chrom=$prefix" 'BEGIN{FS=" "; OFS="\t"} {tr_l = $3-$2} {print chrom, $1, $2, $3, tr_l, $4, $14, $15}' | \
		# Filter TRs with total length <= 10Kbp and copy number >= 2.5
		awk '{ if ($5 <= 10000 && $6 >= 2.5) {print $1, $2, $3, $4, $6, $7, $8, $9} }' OFS='\t' >> "$outfile"
done

# Sort TRF output
sort -k1,1 -k2,2n -k3 "$outfile" > "${outfile}.sorted"

# Merge overlapping elements (up to 5bp apart)
mergeBed -i "${outfile}.sorted" -d 5 > "${outfile}.merged"

# Select TR with the smallest motif length using bedmap
bedmap --min-element "${outfile}.merged" "${outfile}.sorted" > "${outfile}.no_overlaps"

# Remove trailing decimals
sed -i 's/\.000000//g' "${outfile}.no_overlaps"

echo "Tandem Repeat filtering completed successfully"
