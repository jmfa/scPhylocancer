# scPhylo
**Analysis of single-cell whole-genome sequencing data for the Phylocancer (ERC) Project.**

This repository contains all necessary information to perform the full analysis of single-cell sequencing data - from FASTQ to BEAST.
For reproducibility purposes, a small _toy set_ will be provided so that users can check the entire pipeline in a reasonable time frame.

All scripts adapted for a SLURM cluster.

Tools used:

```
# Processing
CutAdapt (1.18)
BWA (0.7.17)
Samtools (1.10)
Picard (2.18.14)
GATK (3.7.0 - later switched to 4.1.7.0)

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
*BEAST (1.10.4)
*BEAST2 (2.6.3)
Tracer (1.7.1)
FigTree (1.4.4)
```

This work was supported by the European Research Council (grant ERC-617457), Spanish Ministry of Economy and Competitiveness (grant BFU2015-63774-P) and Xunta de Galicia.
