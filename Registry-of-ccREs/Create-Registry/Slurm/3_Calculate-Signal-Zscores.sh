#!/bin/bash
#Jill E. Moore
#Weng Lab
#UMass Medical School
#Updated October 2017

#ENCODE Encyclopedia Version 5

genome=$1
mode=$2

dir=~/Lab/ENCODE/Encyclopedia/V5/Registry/V5-$genome
files=$dir/$mode-List.txt
output=$dir/signal-output
scriptDir=~/Projects/ENCODE/Encyclopedia/Version5/ccRE-Pipeline

peaks=$dir/$genome-rDHS.bed

if [ $mode == "DNase" ] || [ $mode == "CTCF" ]
then
width=0
elif [ $mode == "H3K27ac" ] || [ $mode == "H3K4me3" ]
then
width=500
else
echo "ERROR! Please select a valid mode!"
fi
echo $width

##Step 1 - Retreive Signal Rank###

num=$(wc -l $files | awk '{print $1}')
sbatch --nodes 1 --array=1-$num%50 --mem=5G --time=04:00:00 \
    --output=/home/moorej3/Job-Logs/jobid_%A_%a.output \
    --error=/home/moorej3/Job-Logs/jobid_%A_%a.error \
    RetrieveSignal.sh $peaks $mode $files $output $genome $width

