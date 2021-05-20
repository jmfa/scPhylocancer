#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user jmfernandesalves@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 72:00:00
#SBATCH --mem 40G

# First define PATIENT_ID, WORKING_DIR and RESOURCES_DIR
# e.g.
WORKING_DIR="/mnt/lustre/scratch/home/uvi/be/jfa/"
RESOURCES_DIR="/mnt/netapp1/posadalab/phylocancer/RESOURCES"
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" PATIENTID-Samples)

CHR=$(awk '{print $1}' ${RESOURCES_DIR}/hs37d5.chr.bed | sed "${SLURM_ARRAY_TASK_ID}q;d")

sc_samples=$(awk -v dir=${WORKDIR} '{print "-I "dir"/"$0"Merged.Recal.bam"}' ${WORKING_DIR}/${PATIENT_ID}/${PATIENTID}-Samples | tr '\n' ' ')


module load gatk/3.7-0-gcfedb67

java -Djava.io.tmpdir=/mnt/lustre/scratch/home/uvi/be/posadalustre/scripts_joao/ -jar $EBROOTGATK/GenomeAnalysisTK.jar \
  -T RealignerTargetCreator \
  ${sc_samples} \
  -L ${CHR} \
  -R ${RESOURCES_DIR}/hs37d5.fa \
  -known ${RESOURCES_DIR}/Mills_and_1000G_gold_standard.indels.b37.vcf \
  -known ${RESOURCES_DIR}/1000G_phase1.indels.b37.vcf \
  -o ${WORKING_DIR}/${PATIENT_ID}/${PATIENT_ID}.${CHR}.intervals


cat ${WORKING_DIR}/${PATIENT_ID}/${PATIENTID}-Samples | awk -v chr=$CHR '{print $0"Merged.Recal.bam\t"$0"real."chr".bam"}' > ${WORKING_DIR}/${PATIENT_ID}/${SLURM_JOBID}${CHR}.map

java -jar $EBROOTGATK/GenomeAnalysisTK.jar \
   -T IndelRealigner \
   ${sc_samples} \
   -known ${RESOURCES_DIR}/Mills_and_1000G_gold_standard.indels.b37.vcf \
   -known ${RESOURCES_DIR}/1000G_phase1.indels.b37.vcf \
   -targetIntervals ${WORKING_DIR}/${PATIENT_ID}/${PATIENT_ID}.${CHR}.intervals \
   -L ${CHR} \
   -R ${RESOURCES_DIR}/hs37d5.fa \
   --nWayOut ${WORKING_DIR}/${PATIENT_ID}/${SLURM_JOBID}${CHR}.map \
   --maxReadsForRealignment 1000000 
