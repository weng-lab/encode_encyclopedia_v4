#!/bin/bash

#Jill E. Moore
#Weng Lab
#UMass Medical School
#Updated October 2017

#ENCODE Encyclopedia Version 5

genome=$1
dir=~/Lab/ENCODE/Encyclopedia/V5/$genome-DNase/
scriptDir=/home/moorej3/Projects/ENCODE/Encyclopedia/Version5/ccRE-Pipeline

cd $dir/Processed-DHSs

echo -e "Combining DHSs..."
cat output.* > tmp
mv tmp $dir/$genome-DHS-All.bed

echo -e "Filtering DHSs..."
cd $dir
awk '{if ($3-$2 > 150 && $5 > 0.258) print $0}' $genome-DHS-All.bed > $genome-DHS-Filtered.bed
#0.258 is 25th percentile of signal for 1 million randomly selected DHSs

mkdir scratch
cp $genome-DHS-Filtered.bed scratch/tmp.bed
cd scratch

echo -e "Sorting DHSs..."
sort -k1,1 -k2,2n tmp.bed > sorted
rm -f rPeaks
num=$(wc -l sorted | awk '{print $1}')

echo -e "Merging DHSs..."
while [ $num -gt 0 ]
do
    echo -e "\t" $num
    bedtools merge -i sorted -c 4,5 -o collapse,collapse > merge
    python $scriptDir/pick.best.peak.py merge > peak-list
    awk 'FNR==NR {x[$1];next} ($4 in x)' peak-list sorted >> rPeaks
    bedtools intersect -v -a sorted -b rPeaks > remaining
    mv remaining sorted
    num=$(wc -l sorted | awk '{print $1}')
done

mv rPeaks ../tmp.bed
cd ../
rm -r scratch

echo -e "Accessioning rDHSs..."
sort -k1,1 -k2,2n tmp.bed > sorted.bed
python $scriptDir/make.cre.accession.py sorted.bed $genome rDHS \
    > $genome-rDHS-Filtered-Summary.txt
awk '{print $1 "\t" $2 "\t" $3 "\t" $10}' $genome-rDHS-Filtered-Summary.txt \
    > $genome-rDHS-Filtered.bed

rm sorted.bed
rm tmp.bed
