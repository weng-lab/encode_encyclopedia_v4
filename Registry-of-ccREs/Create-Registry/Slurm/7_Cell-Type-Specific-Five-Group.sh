

scriptDir=~/Projects/ENCODE/Encyclopedia/Version5/ccRE-Pipeline

cd ~/Lab/ENCODE/Encyclopedia/V5/Registry/V5-hg38
python $scriptDir/match.biosamples.py > Cell-Type-Specific/Master-Cell-List.txt

files=~/Lab/ENCODE/Encyclopedia/V5/Registry/V5-hg38/Cell-Type-Specific/Master-Cell-List.txt
num=$(wc -l $files | awk '{print $1}')

for j in `seq 1 1 $num`
do
    group=$(awk '{if (NR == '$j') print $10}' $files)
    echo $group
    sbatch --nodes 1 --mem=1G --time=00:30:00 \
        --output=/home/moorej3/Job-Logs/jobid_%A.output \
        --error=/home/moorej3/Job-Logs/jobid_%A.error \
        $scriptDir/Cell-Type-Specific-Scripts/Split-cREs.$group.sh $files $j
done


