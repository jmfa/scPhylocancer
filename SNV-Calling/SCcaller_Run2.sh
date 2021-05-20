#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user jmfernandesalves@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 8
#SBATCH -t 48:00:00
#SBATCH --mem 60G

SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" PATIENTID-scIDs)
echo $SAMPLE

module purge
module load gcc/6.4.0 samtools/1.9
module load gcccore/6.4.0 bcftools/1.9
module load gcc/6.4.0 vcftools/0.1.15
module load miniconda2/4.5.11
source activate /home/uvi/be/jfa/.conda/envs/jmfSCCaller


### IMPORTANT INFO:
### THE TARGET BED IS 0-BASED! DONT FORGET THIS, OTHERWISE YOUR CALLS WILL NOT FALL ON THE EXPECTED POSITIONS
### VCFs and BAMs need to be in the same folder
### VCFs need to have a specific prefix:
# e.g.
# bam ID: patient1_TP_TS17.real.10.bam
# vcf ID: SCcaller.patient1_TP_TS17.10.vcf


HEALTHY="PATH_TO_BULK_HEALTHY_SAMPLE"
DBSNP="${RESOURCES_DIR}/dbsnp_138.b37.vcf"
REF="${RESOURCES_DIR}/hs37d5.fa"


for CHR in {1..24}
do
chr=$(sed "${CHR}q;d" ${RESOURCES_DIR}/hs37d5.chr.bed)

python ${RESOURCES_DIR}/SCcaller-2.0.0/sccaller_v2.0.0_2ndRound.py \
        --bam ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}real.${chr}".bam" \
        --bulk $HEALTHY.${chr}.bam \
        --fasta $REF \
        --output ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}${chr}-SC-Caller-2ndRun.vcf \
        --snp_type dbsnp \
        --snp_in $DBSNP \
        --cpu_num 8 \
        --engine samtools \
        --mapq 30 \
        --min_depth 1 \
        --minvar 0 \
        --bias 0.6 \
        --lamb 2000 \
        --target ${WORKING_DIR}/${PATIENT_ID}/${PATIENT_ID}.${chr}.VarSites.bed
done
