#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user jmfernandesalves@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 24
#SBATCH -t 48:00:00
#SBATCH --mem 60G

module load bison/3.1
module load gmp/6.1.2
module load gcccore/6.4.0 htslib/1.9
module load gcccore/6.4.0 cmake/3.10.3

module load gcc/6.4.0 R/3.6.0
export R_LIBS_USER=/home/uvi/be/jfa/R_packages/

./cellphy.sh FULL -t 24 -p ${PATIENT_ID} -m GTGTR4+FO+E ${PATIENT_ID}.Final.vcf
