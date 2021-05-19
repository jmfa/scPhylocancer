# PHYLOCANCER
**Analysis of single-cell whole-genome sequencing data for the Phylocancer (ERC) Project.**

This repository contains all necessary information to perform the full analysis of single-cell sequencing data - from FASTQ to BEAST.
For reproducibility purposes, a small _toy set_ is provided so that users can check the entire pipeline in reasonable time.

All scripts adapted for a SLURM cluster.

Tools used:

```
# Processing
CutAdapt (1.18)
BWA (0.7.17)
Samtools (1.10)
Picard (2.18.14)
GATK (3.7.0 - later switched to v4.1.7.0)

# SNV Calling:
SCcaller (2.0.0)
SCcaller-LabVersion (2.0.0)
VCFtools (0.1.16)

# CNV Calling:
bedtools (2.28.0)
GINKGO (local install)

# VCF annotation:
Annovar (2020-06-07)

# Phylogenetic reconstruction:
CellPhy
*BEAST (v1.10.4)
*BEAST2 (v2.6.3)
```

This work was supported by the European Research Council (grant ERC-617457), Spanish Ministry of Economy and Competitiveness (grant BFU2015-63774-P) and Xunta de Galicia.
