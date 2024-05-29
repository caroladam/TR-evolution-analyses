#!/bin/bash

genomesdir=$1
trfdir=$2

if [ -z $genomesdir ]
then
	echo 'Script requires path to FASTA files as argument'
fi

if [ -z $trfdir ]
then
	echo 'Script requires path to TRF executable as argument'
fi

echo "Running TRF"

# trf config
matchscore=2
mismatchscore=5
indelscore=7
pm=80
pi=10
minscore=24 
maxperiod=2000 

# run trf 
for file in $genomesdir/*.fa
do
	$trfdir/trf $file ${matchscore} ${mismatchscore} ${indelscore} ${pm} ${pi} ${minscore} ${maxperiod} -f -d -h -l 6
done
