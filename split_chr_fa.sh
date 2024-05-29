#!/bin/bash

function trim_path {

        echo $1 | sed 's/\/$//'
}

arg=$1

if [ -z $arg ]
then
        echo 'Script requires path to FASTA files as argument'
fi

path=$( trim_path $arg )

for file in $path/*.fa
do
        faidx -x $file
done
