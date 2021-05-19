#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task 1
#SBATCH -t 04:00:00
#SBATCH --mem 5G

module load gcccore/6.4.0 cutadapt/1.18-python-3.7.0

# First define PATIENT_ID and WORKING_DIR
# e.g.
WORKING_DIR="/mnt/lustre/scratch/home/uvi/be/jfa/"
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" PATIENTID-Samples)

#LIB remove - KAPPA

Adapter1="AGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG"
Adapter2="AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT"

cutadapt --minimum-length 70 -a AdapterA=$Adapter1 -A AdapterB=$Adapter2 -o ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}".trimmed_1.fastq.gz" -p ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}".trimmed_2.fastq.gz" ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}"_1.fastq.gz" ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}"_2.fastq.gz"

#WGA remove - AMPLI1

AdapterWGA1="GTGAGTGATGGTTGAGGTAGTGTGGAG"
AdapterWGA2="CTCCACACTACCTCAACCATCACTCAC"

cutadapt --minimum-length 70 -a AdapterA=$AdapterWGA1 -A AdapterB=$AdapterWGA2 -o ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}".trimmed2_1.fastq.gz" -p ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}".trimmed2_2.fastq.gz" ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}".trimmed_1.fastq.gz" ${WORKING_DIR}/${PATIENT_ID}/${SAMPLE}".trimmed_2.fastq.gz"
