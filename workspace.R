library(tercen)
library(dplyr)

options("tercen.workflowId" = "994a884b38f62643bc46779ff4006817")
options("tercen.stepId"     = "87257e37-de66-48e7-8a7d-ece2881d041f")

getOption("tercen.workflowId")
getOption("tercen.stepId")


ctx = tercenCtx()

if (!any(ctx$cnames == "documentId")) stop("Column factor documentId is required") 

df <- ctx$cselect()

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
system2(cmd, args)

(ctx = tercenCtx())  %>% 
  select(.y, .ci, .ri) %>% 
  group_by(.ci, .ri) %>%
  summarise(median = median(.y)) %>%
  ctx$addNamespace() %>%
  ctx$save()
