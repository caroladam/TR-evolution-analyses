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

if [ -z $trf_dir ]
then
	echo 'Script requires path to TRF results directory as argument'
fi

if [ -z $outfile ]
then
	echo 'Script requires OUTFILE name as argument'
fi

if test -f "$outfile"
then
	echo "Outfile already exists"
	exit 1
else
	touch "$outfile"
fi

# concatenate TRF results
for file in $trf_dir/*.dat
do
	# Remove headers
	sed -i '/^[0-9]/!d' $file
	filename=$( trim_file $file)
	prefix=$( get_prefix $filename)
		cat $file | \
		# print columns of interest
		awk -v "chrom=$prefix" 'BEGIN{FS=" "; OFS="\t"} {print chrom, $1, $2, $3, $4, $14, $15}' | \
		# get TR total length
		awk '{tr_l = $3-$2} {print $1, $2, $3, tr_l, $4, $5, $6, $7}' OFS='\t' | \
		# keep only TRs with total length <= 10Kbp
		awk '{ if ($4 <= 10000) {print $1, $2, $3, $4, $5, $6, $7, $8} }' OFS='\t' | \
	 	# keep only TRs with copy number > 2.5
	 	awk '{ if ($6 >=2.5) {print $1, $2, $3, $4, $5, $6, $7, $8} }' OFS='\t' >> $outfile
done

# sort TRF output
sort -k1,1 -k2,2n -k3 ${outfile} > ${outfile}.sorted

# merge overlapping elements (up to 5bp apart)
mergeBed -i ${outfile}.sorted -d 5 > ${outfile}.merged

# keep TR with the smallest motif length (bedmap '--min-element' always consider the 5th element in the BED file)
bedmap --min-element ${outfile}.merged ${outfile}.sorted > ${outfile}.no_overlaps

sed -i 's/\.000000//g' $outfile.no_overlaps
