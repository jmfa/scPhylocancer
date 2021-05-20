# PATIENT1 - Filtering VCF calls - Example script
### load tools
module load bcftools vcftools htslib picard

nbcells=$(cat PATIENT1-SampleList | wc -l)

### FIRST STEP - remove indels from VCF
while read file
do
for i in {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,X,Y}
do
vcftools --vcf ${file}.${i}.SC-caller.2ndRUN.vcf --remove-indels --recode --out ${file}.${i}.fixed.SNVs
grep -v "#" ${file}.${i}.fixed.SNVs.recode.vcf  | awk 'BEGIN{FS="\t"}{if ($4=="\.") print $0}' > temp.remove
vcftools --vcf ${file}.${i}.fixed.SNVs.recode.vcf --exclude-positions temp.remove --recode --out temp
mv temp.recode.vcf ${file}.${i}.fixed.SNVs.recode.vcf

old=$(grep "#CHROM" ${file}.${i}.fixed.SNVs.recode.vcf | cut -f 10)
echo $old $file > temp.rehead
bcftools reheader --samples temp.rehead -o ${file}.${i}.fixed.SNVs.vcf ${file}.${i}.fixed.SNVs.recode.vcf
done
sed "s/NAME/${file}/g" PATIENT1-2ndRUN.VCFs > temp.list
java -jar $EBROOTPICARD/picard.jar MergeVcfs I=temp.list O=${file}.MERGED.SC-Caller.2ndRUN.vcf
rm temp.list
rm temp.rehead
rm *fixed*
done < PATIENT1-SampleList

#######################################################

## SECOND - remove CN-DELETIONS using GINKGO output
for i in $(seq 1 $nbcells)
do
sample=$(sed "${i}q;d" PATIENT1-SampleList)
j=$((i + 3))
cut -f 1,2,3,${j} ${WORKING_DIR}/PATIENT1/GINKGO/SegCopy > temp.cnv
head temp.cnv
awk 'BEGIN{FS="\t"}{if ($4>=2&&$1!="chrX"||$4>=2&&$1!="chrY"||$4>=1&&$1=="chrX"||$4>=1&&$1=="chrY") print $0}' temp.cnv | awk 'BEGIN{FS="\t"}{print $1"\t"$2"\t"$3}' | sed 's/chr//g' > temp.diploid.bed
vcftools --vcf ${sample}.MERGED.SC-Caller.2ndRUN.vcf --bed temp.diploid.bed --recode --out ${sample}.2ndRUN-SCCaller-noDELETIONS
rm temp*
done

#######################################################

### THIRD - Apply Bulk Filter
#Filters:
#1. Co-ocorrence: bulk+sc 
#OR
#2. NO FALSE && Co-ocorrence: sc+sc

#### BULK PRESENT
BULK="PATH_TO_BULK_MUTECT".vcf
grep -v "#" $BULK.vcf | grep "PASS" | cut -f 1,2 > PATIENT1.BiAllelic.POSITIONS

for i in $(seq 1 $nbcells)
do
sample=$(sed "${i}q;d" PATIENT1-SampleList)
vcftools --vcf ${sample}.2ndRUN-SCCaller-noDELETIONS.recode.vcf --positions PATIENT1.BiAllelic.POSITIONS --recode --out ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKPRESENT
grep -v "#" ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKPRESENT.recode.vcf  | grep "True" |  cut -f 1,2 > temp.pos
vcftools --vcf ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKPRESENT.recode.vcf --positions temp.pos --recode --out ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKPRESENT.NoFalse
rm temp*
done

#### BULK ABSENT
for i in $(seq 1 $nbcells)
do
sample=$(sed "${i}q;d" PATIENT1-SampleList)
vcftools --vcf ${sample}.2ndRUN-SCCaller-noDELETIONS.recode.vcf --exclude-positions PATIENT1.BiAllelic.POSITIONS --recode --out ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKABSENT
grep -v "#" ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKABSENT.recode.vcf | grep "True" | cut -f 1,2 > temp.pos
vcftools --vcf ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKABSENT.recode.vcf --positions temp.pos --recode --out ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKABSENT.NoFalse
sed -i 's/##FORMAT=<ID=AD,Number=R/##FORMAT=<ID=AD,Number=./g' ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKABSENT.NoFalse.recode.vcf
sed -i 's/##FORMAT=<ID=PL,Number=G/##FORMAT=<ID=PL,Number=./g' ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKABSENT.NoFalse.recode.vcf
bgzip ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKABSENT.NoFalse.recode.vcf
tabix -p vcf ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKABSENT.NoFalse.recode.vcf.gz
done

ls *BULKABSENT.NoFalse.recode.vcf.gz > list.ABSENT
# Merge BULKABSENT vcfs
bcftools merge -l list.ABSENT -o PATIENT1-BULKABSENT-noDELETIONS-NoFalse-MERGED.vcf -O vcf
# get Genotypes:
vcftools --vcf PATIENT1-BULKABSENT-noDELETIONS-NoFalse-MERGED.vcf --extract-FORMAT-info GT --out PATIENT1-BULKABSENT-noDELETIONS-NoFalse-MERGED.Genotypes
# get Co-Occurrence Positions from GTs:
cat PATIENT1-BULKABSENT-noDELETIONS-NoFalse-MERGED.Genotypes.GT.FORMAT | sed 's#0/0#0#g' | sed 's#0/1#1#g' | sed 's#1/1#1#g' | sed 's#./.#0#g' | awk '{sum=0; for(i=3; i<=NF; i++) sum += $i; print $1"\t"$2"\t"sum}' | awk 'BEGIN{FS="\t"}{if ($3>=2) print $1"\t"$2}' > 2SC.Pos_1allele
cat PATIENT1-BULKABSENT-noDELETIONS-NoFalse-MERGED.Genotypes.GT.FORMAT | sed 's#0/0#0#g' | sed 's#0/2#1#g' | sed 's#2/2#1#g' | sed 's#1/2#1#g' | sed 's#./.#0#g' | awk '{sum=0; for(i=3; i<=NF; i++) sum += $i; print $1"\t"$2"\t"sum}' | awk 'BEGIN{FS="\t"}{if ($3>=2) print $1"\t"$2}' > 2SC.Pos_2alleles
catPATIENT1-BULKABSENT-noDELETIONS-NoFalse-MERGED.Genotypes.GT.FORMAT | sed 's#0/0#0#g' | sed 's#0/3#1#g' | sed 's#3/3#1#g' | sed 's#./.#0#g' | awk '{sum=0; for(i=3; i<=NF; i++) sum += $i; print $1"\t"$2"\t"sum}' | awk 'BEGIN{FS="\t"}{if ($3>=2) print $1"\t"$2}' > 2SC.Pos_3alleles

cat 2SC.Pos_1allele 2SC.Pos_2alleles 2SC.Pos_3alleles | uniq | sort -k1,1V -k2,2n > 2SC.Pos

for i in $(seq 1 $nbcells)
do
sample=$(sed "${i}q;d" PATIENT1-SampleList)
gunzip ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKABSENT.NoFalse.recode.vcf.gz
vcftools --vcf ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKABSENT.NoFalse.recode.vcf --positions 2SC.Pos --recode --out ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKABSENT.NoFalse.2SCs
done

#######################################################

#### FOURTH - concat all SC files
for i in $(seq 1 $nbcells)
do
sample=$(sed "${i}q;d" PATIENT1-SampleList)
bgzip ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKABSENT.NoFalse.2SCs.recode.vcf
bgzip ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKPRESENT.NoFalse.recode.vcf
tabix -p vcf ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKABSENT.NoFalse.2SCs.recode.vcf.gz
tabix -p vcf ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKPRESENT.NoFalse.recode.vcf.gz
bcftools concat ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKABSENT.NoFalse.2SCs.recode.vcf.gz ${sample}.2ndRUN-SCCaller-noDELETIONS.BULKPRESENT.NoFalse.recode.vcf.gz -a -O v -o temp.concat.vcf
vcf-sort -c temp.concat.vcf > ${sample}.noDELETIONS_Consensus.vcf
rm temp.concat.vcf
done

#######################################################

#### FIFTH - update alternative, merge cells and apply genotype filter 
for i in $(seq 1 $nbcells)
do
sample=$(sed "${i}q;d" PATIENT1-SampleList)
sed -i 's/##FORMAT=<ID=AD,Number=./##FORMAT=<ID=AD,Number=R/g' ${sample}.noDELETIONS_Consensus.vcf
sed -i 's/##FORMAT=<ID=PL,Number=./##FORMAT=<ID=PL,Number=G/g' ${sample}.noDELETIONS_Consensus.vcf

grep "#" ${sample}.noDELETIONS_Consensus.vcf > head
grep -v "#" ${sample}.noDELETIONS_Consensus.vcf > tail

awk 'BEGIN{FS="\t"}{if ($4=="A"&&$5=="\."||$4=="C"&&$5=="\."||$4=="T"&&$5=="\.") print $1"\t"$2"\t"$3"\t"$4"\tG\t"$6"\t"$7"\t"$8"\t"$9"\t"$10;
	else if ($4=="G"&&$5=="\.") print $1"\t"$2"\t"$3"\t"$4"\tA\t"$6"\t"$7"\t"$8"\t"$9"\t"$10;
	else print $0}' tail > tail.new

cat head tail.new > ${sample}.noDELETIONS_Consensus.Updated.vcf
bgzip ${sample}.noDELETIONS_Consensus.Updated.vcf
tabix -p vcf ${sample}.noDELETIONS_Consensus.Updated.vcf.gz
rm head
rm tail*
done


#### Fix PL field 

while read file
do
gunzip ${file}.noDELETIONS_Consensus.Updated.vcf.gz
grep "#" ${file}.noDELETIONS_Consensus.Updated.vcf > head1
grep -v "#" ${file}.noDELETIONS_Consensus.Updated.vcf > tail
grep "1/1" tail | awk 'BEGIN{FS="\t"}{if ($5 ~ /.,./) print $0}' > tailfix
grep -v -f tailfix tail > tailready
grep -v "/2" tailready > tailready2
mv tailready2 tailready 

cut -d "," -f 1 tailfix > tail1
cut -f 6- tailfix > tail2
paste tail1 tail2 > tailfixed

cat head1 tailready tailfixed > ${file}.fixed.vcf
vcf-sort -c ${file}.fixed.vcf >  ${file}.fixed.sorted.vcf

bgzip ${file}.fixed.sorted.vcf
tabix -p vcf ${file}.fixed.sorted.vcf.gz
bcftools annotate -x FORMAT/G10 ${file}.fixed.sorted.vcf.gz -O v -o ${file}.final_fixed.vcf

rm tail
rm head1
rm tailfix
rm tail*
done < PATIENT1-SampleList

while read file
do
bgzip ${file}.final_fixed.vcf
tabix -p vcf ${file}.final_fixed.vcf.gz
bcftools annotate -x FORMAT/AD ${file}.final_fixed.vcf.gz -O v -o ${file}.final_fixed_noAD.vcf

bgzip ${file}.final_fixed_noAD.vcf
tabix -p vcf ${file}.final_fixed_noAD.vcf.gz
done < PATIENT1-SampleList

ls *.final_fixed_noAD.vcf.gz > mergeList
bcftools merge -l mergeList -o PATIENT1-FinalFixed.vcf -O vcf

### Apply geno filter - less than 50% missing data allowed:
genofilter=$(echo $nbcells/2 | bc -l)
vcftools --vcf PATIENT1-FinalFixed.vcf --extract-FORMAT-info GT --out PATIENT1-FinalFixed
sed 's#0/0#0#g' PATIENT1-FinalFixed.GT.FORMAT | sed 's#0/1#0#g' | sed 's#1/1#0#g' | sed 's#\./\.#1#g' | sed 's#2/2#0#g' | sed 's#0/2#0#g' | sed 's#3/3#0#g' | sed 's#0/3#0#g' | awk '{sum=0; for(i=3; i<=NF; i++) sum += $i; print $1"\t"$2"\t"sum}' | awk -v gf=$genofilter 'BEGIN{FS="\t"}{if ($3<=gf) print $0}' > PATIENT1-FinalPosition-SET
vcftools --vcf PATIENT1-FinalFixed.vcf --positions CRC14-FinalPosition-SET --recode --out PATIENT1-FinalFixed.GenoFilter

# Remove invariable sites
bgzip PATIENT1-FinalFixed.GenoFilter.recode.vcf
tabix -p vcf PATIENT1-FinalFixed.GenoFilter.recode.vcf.gz
vcftools --vcf PATIENT1-FinalFixed.GenoFilter.vcf --freq2 --out temp
cat temp.frq | awk 'BEGIN{FS="\t"}{if ($5==1) print $0}' > temp.remove
vcftools --vcf PATIENT1-FinalFixed.GenoFilter.vcf --exclude-positions temp.remove --recode --out PATIENT1-FinalFixed.GenoFilter.vcf.noINV
mv PATIENT1-FinalFixed.GenoFilter.vcf.noINV.recode.vcf PATIENT1-FinalSet.Fixed.vcf
