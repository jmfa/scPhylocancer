#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 24:00:00
#SBATCH --mem 40G

# First define PATIENT_ID and WORKING_DIR
# e.g.
WORKING_DIR="/mnt/lustre/scratch/home/uvi/be/jfa/"
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" PATIENTID-Samples)

ls ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}*sorted.bam > ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.listTemp

samtools merge -b ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.listTemp ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.Merged.bam
samtools sort -o${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.Merged.sorted.bam ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.Merged.bam
samtools index ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.Merged.sorted.bam

module load picard/2.18.14

java -jar $EBROOTPICARD/picard.jar MarkDuplicates \
	I=${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.Merged.sorted.bam \
	OUTPUT=${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.Merged.dedup.bam \
	CREATE_INDEX=true \
	REMOVE_DUPLICATES=false \
	TMP_DIR=${WORKING_DIR}/${PATIENT_ID}/ \
	M=${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.txt \
	VALIDATION_STRINGENCY=LENIENT
