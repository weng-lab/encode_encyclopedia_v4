

genome=$1
rdhs=../$genome-rDHS.bed 
summary=~/Lab/ENCODE/Encyclopedia/V5/$genome-DNase/$genome-rDHS-Filtered-Summary.txt
dhsAll=~/Lab/ENCODE/Encyclopedia/V5/$genome-DNase/$genome-DHS-Filtered.bed
scriptDir=~/Projects/ENCODE/Encyclopedia/Version5/ccRE-Pipeline

cd ~/Lab/ENCODE/Encyclopedia/V5/Registry/V5-$genome/

echo "Intersecting rDHSs..."
bedtools intersect -c -a $summary -b $dhsAll > $genome-rDHS-Counts.txt

mkdir -p maxZ
cp $genome-*-maxZ.txt maxZ
cd maxZ

if [[ $genome == "mm10" ]]
then
tss=~/Lab/Reference/Mouse/GencodeM4/TSS.Filtered.4K.bed
ChromInfo=~/Lab/Reference/Mouse/ChromInfo.txt
elif [[ $genome == "hg38" ]]
then
tss=~/Lab/Reference/Human/$genome/GENCODE24/TSS.Filtered.4K.bed
ChromInfo=~/Lab/Reference/Human/hg38/chromInfo.txt
elif [[ $genome == "hg19" ]]
then
TSS=~/Lab/Reference/Human/Gencode19/TSS.Filtered.4K.bed
ChromInfo=~/Lab/Reference/Human/hg19/chromInfo.txt
fi

echo "Splitting ccREs into groups..."
awk '{if ($2 >= 1.64) print $0}' $genome-DNase-maxZ.txt > list
awk 'FNR==NR {x[$1];next} ($4 in x)' list $rdhs > bed
bedtools intersect -u -a bed -b  $tss > prox
bedtools intersect -v -a bed -b $tss > distal

awk 'FNR==NR {x[$4];next} ($1 in x)' prox $genome-H3K4me3-maxZ.txt | \
    awk '{if ($2 >= 1.64) print $0}' > H3K4me3-proximal
awk 'FNR==NR {x[$4];next} ($1 in x)' distal $genome-H3K27ac-maxZ.txt | \
    awk '{if ($2 >= 1.64) print $0}' > H3K27ac-distal

awk 'FNR==NR {x[$4];next} ($1 in x)' prox $genome-H3K4me3-maxZ.txt | \
    awk '{if ($2 < 1.64) print $0}' > no1
awk 'FNR==NR {x[$1];next} ($1 in x)' no1 $genome-H3K27ac-maxZ.txt | \
    awk '{if ($2 >= 1.64) print $0}' > H3K27ac-proximal
awk 'FNR==NR {x[$1];next} ($1 in x)' no1 $genome-H3K27ac-maxZ.txt | \
    awk '{if ($2 < 1.64) print $0}' > no

awk 'FNR==NR {x[$4];next} ($1 in x)' distal $genome-H3K27ac-maxZ.txt | \
    awk '{if ($2 < 1.64) print $0}' > no1
awk 'FNR==NR {x[$1];next} ($1 in x)' no1 $genome-H3K4me3-maxZ.txt | \
    awk '{if ($2 >= 1.64) print $0}' > H3K4me3-distal
awk 'FNR==NR {x[$1];next} ($1 in x)' no1 $genome-H3K4me3-maxZ.txt | \
    awk '{if ($2 < 1.64) print $0}' >> no

awk 'FNR==NR {x[$1];next} ($1 in x)' no $genome-CTCF-maxZ.txt | \
    awk '{if ($2 >= 1.64) print $0}' > ctcf-like
awk 'FNR==NR {x[$1];next} ($1 in x)' no $genome-CTCF-maxZ.txt | \
    awk '{if ($2 < 1.64) print $0}' > no2

awk 'FNR==NR {x[$1];next} ($1 in x)' no2 $genome-DNase-maxZ.txt | \
    awk '{if ($2 >= 1.64) print $0}' > dnase-like
awk 'FNR==NR {x[$1];next} ($1 in x)' no2 $genome-DNase-maxZ.txt | \
    awk '{if ($2 < 1.64) print $0}' > none

cat H3K4me3-proximal H3K4me3-distal > promoter-like
cat H3K27ac-distal H3K27ac-proximal > enhancer-like

echo "Accessioning ccREs..."
awk 'FNR==NR {x[$1];next} ($4 in x)' ctcf-like $rdhs | \
    awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" "CTCF-only" }' > l.bed
awk 'FNR==NR {x[$1];next} ($4 in x)' enhancer-like $rdhs | \
    awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" "Enhancer-like"}' >> l.bed
awk 'FNR==NR {x[$1];next} ($4 in x)' promoter-like $rdhs | \
    awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" "Promoter-like"}' >> l.bed

#awk 'FNR==NR {x[$1$2$3];next} ($1$2$3 in x)' filter.tmp l.bed > m.bed
cp l.bed m.bed
python $scriptDir/make.cre.accession.py m.bed $genome ccRE | \
    awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $6 "\t" $5}' | \
    sort -k1,1 -k2,2n > $genome-ccREs-Unfiltered.bed
    
mv $genome-ccREs-Unfiltered.bed ~/Lab/ENCODE/Encyclopedia/V5/Registry/V5-$genome/

