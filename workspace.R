library(tercen)
library(dplyr)

options("tercen.workflowId" = "994a884b38f62643bc46779ff4006817")
options("tercen.stepId"     = "87257e37-de66-48e7-8a7d-ece2881d041f")

getOption("tercen.workflowId")
getOption("tercen.stepId")


ctx = tercenCtx()

if (!any(ctx$cnames == "documentId")) stop("Column factor documentId is required") 

if (length(df$documentId) > 2) stop("Can only have one documentID if single-ended or two if paired-ended sequencing") 

df <- ctx$cselect()

if (length(df$documentId) == 2) {
  
  docId = df$documentId[1]
  doc = ctx$client$fileService$get(docId)
  filename_r1 = paste0(tempfile(), '.fastq')
  writeBin(ctx$client$fileService$download(docId), filename_r1)
  on.exit(unlink(filename_r1))
  
  docId = df$documentId[2]
  doc = ctx$client$fileService$get(docId)
  filename_r2 = paste0(tempfile(), '.fastq')
  writeBin(ctx$client$fileService$download(docId), filename_r2)
  on.exit(unlink(filename_r2))
  
  out.filename = tempfile()
  
  cmd = 'salmon'
  args = paste('quant',
               '-i', 'hsapiens_index', 
               '-l A',
               '-1', filename_r1,
               '-2', filename_r2,
               '-p', parallel::detectCores(),
               '--validateMappings',
               '-o', out.filename,
               sep = ' ')
} else if (length(df$documentId) == 1) {
  
  docId = df$documentId[1]
  doc = ctx$client$fileService$get(docId)
  filename = paste0(tempfile(), '.fastq')
  writeBin(ctx$client$fileService$download(docId), filename)
  on.exit(unlink(filename))
  
  out.filename = tempfile()
  
  cmd = 'salmon'
  args = paste('quant',
               '-i', 'hsapiens_index', 
               '-l A',
               '-r', filename,
               '-p', parallel::detectCores(),
               '--validateMappings',
               '-o', out.filename,
               sep = ' ')
}

system2(cmd, args)

salmon_quant <- read.delim(paste(out.filename, 'quant.sf', sep = '/'))

(ctx = salmon_quant %>%
  ctx$addNamespace() %>%
  ctx$save())
