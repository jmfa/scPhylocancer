#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 6:00:00
#SBATCH --mem 15G

module load gcccore/6.4.0 bedtools/2.28.0

SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" PATIENTID-scIDs)
bedtools bamtobed -i ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.Recal.bam > ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.Recal.bed
