#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user jmfernandesalves@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH --mem 20G
#SBATCH -t 24:00:00

# First define PATIENT_ID, WORKING_DIR and RESOURCES_DIR
# e.g.
WORKING_DIR="/mnt/lustre/scratch/home/uvi/be/jfa/"
RESOURCES_DIR="/mnt/netapp1/posadalab/phylocancer/RESOURCES"

SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" PATIENTID-Samples)

module purge
module load gatk/4.0.10.0

# Build RecalTable
gatk BaseRecalibrator \
	-R ${RESOURCES_DIR}/hs37d5.fa \
	-I ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.Merged.dedup.bam \
	--known-sites ${RESOURCES_DIR}/dbsnp_138.b37.vcf \
	--known-sites ${RESOURCES_DIR}/Mills_and_1000G_gold_standard.indels.b37.vcf \
	-O ${WORKING_DIR}/${PATIENT_ID}/RecalibrationReportI_${SAMPLE}.grp


# Apply recalibration
gatk ApplyBQSR \
	-R ${RESOURCES_DIR}/hs37d5.fa \
	-I ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.Merged.dedup.bam \
	--bqsr-recal-file ${WORKING_DIR}/${PATIENT_ID}/RecalibrationReportI_${SAMPLE}.grp \
	-O ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.Merged.Recal.bam
