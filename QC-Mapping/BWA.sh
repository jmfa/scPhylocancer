#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 48:00:00
#SBATCH --mem 10G

module load gcc/6.4.0 
module load bwa samtools

# First define PATIENT_ID and WORKING_DIR
# e.g.
WORKING_DIR="/mnt/lustre/scratch/home/uvi/be/jfa/"
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" PATIENTID-Samples)

bwa mem -t 1 -M -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:Illumina\tLB:${SAMPLE}\tPU:HiSeq" ${RESOURCES}/hs37d5.fa ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}".trimmed2_1.fastq.gz ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}".trimmed2_2.fastq.gz | samtools view -Sbq 20 -@ 12 - > ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}.bam
