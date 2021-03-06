library(tercen)
library(dplyr)

options("tercen.workflowId" = "74a523a114ef1230f3c7b957d100548e")
options("tercen.stepId"     = "f60619c1-aa6d-4d2b-9f90-e9f2493d7a8c")

getOption("tercen.workflowId")
getOption("tercen.stepId")


ctx = tercenCtx()

if (!any(ctx$cnames == "documentId")) stop("Column factor documentId is required") 

df <- ctx$cselect()

is_paired_end <- as.character(ctx$op.value('paired_end'))

if (is_paired_end == "yes") {
  if (length(df$documentId) != 2) stop("Must have two documentID if paired-ended sequencing") 
} else {
  if (length(df$documentId) != 1) stop("Must have only one documentID if single-ended sequencing") 
}


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
  
  cmd = '/salmon-latest_linux_x86_64/bin/salmon'
  args = paste('quant',
               '-i', '/hsapiens_index', 
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
  
  cmd = '/salmon-latest_linux_x86_64/bin/salmon'
  args = paste('quant',
               '-i', '/hsapiens_index', 
               '-l A',
               '-r', filename,
               '-p', parallel::detectCores(),
               '--validateMappings',
               '-o', out.filename,
               sep = ' ')
}

system2(cmd, args)

salmon_quant <- read.delim(paste(out.filename, 'quant.sf', sep = '/'))

salmon_quant %>%
  mutate(.ci = rep_len(0, nrow(.))) %>%
  ctx$addNamespace() %>%
  ctx$save()
