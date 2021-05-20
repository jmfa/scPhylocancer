#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user jmfernandesalves@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 5
#SBATCH -t 48:00:00
#SBATCH --mem 60G

# Create a loop to go through each chromosome. 

SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" PATIENTID-scIDs)
echo $SAMPLE

module load gcc/6.4.0
module load samtools/1.9
module load python/2.7.15
module load pysam/0.15.1-python-2.7.15
module load numpy/1.15.2-python-2.7.15

SCcaller="${RESOURCES_DIR}/SCcaller-2.0.0/sccaller_v2.0.0.py"
HEALTHY="PATH_TO_BULK_HEALTHY_SAMPLE"
DBSNP="${RESOURCES_DIR}/dbsnp_138.b37.vcf"
REF="${RESOURCES_DIR}/hs37d5.fa"

for CHR in {1..24}
do
chr=$(sed "${CHR}q;d" ${RESOURCES_DIR}/hs37d5.chr.bed)

python $SCcaller \
    --bam ${WORKING_DIR}/${PATIENT_ID}/$SAMPLE."real."$chr".bam" \
    --fasta $REF \
    --output ${WORKING_DIR}/${PATIENT_ID}/SCcaller.$SAMPLE"."$chr".vcf" \
    --snp_type dbsnp \
    --snp_in $DBSNP \
    --cpu_num 5 \
    --engine samtools \
    --bulk $HEALTHY"."$chr".bam" \
	--min_depth 1 \
	--minvar 0 \
	--bias 0.6 \
	--lamb 2000 \
	--mapq 30
done
