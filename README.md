# Quantify gene expression from counts with Salmon

##### Description
`FastQ to Counts` takes in fastq files from one RNA-seq sample and processes them using Salmon. It then outputs the gene expression levels for each _H. sapiens_ gene.

##### Usage

Input projection| Description
---|---
`column names`   | character, documentId corresponding to the files to quantify


| Input parameters           | Description                                                                                 |
| -------------------------- | ------------------------------------------------------------------------------------------- |
| `paired-end`                | "yes" or "no", specifying whether the sequencing was paired end or not |


Output relations| Description
---|---
`Name` | character, the Ensembl transcript ID
`Length`                | numeric, the length of the transcript
`EffectiveLength`                | numeric, the effective transcript length
`TPM` | numeric, the number of transcripts per million reads
`NumReads` | numeric, salmon’s estimate of the number of reads mapping to each transcript

##### Details
The output relations let can then be combined with other samples to perform analysis using the DESeq2 operator or the single-cell RNA-seq operators.


#### References
Patro, R., Duggal, G., Love, M. I., Irizarry, R. A., & Kingsford, C. (2017). Salmon provides fast and bias-aware quantification of transcript expression. Nature Methods.

["Salmon website"](https://combine-lab.github.io/salmon/)

##### See Also

#### Examples
