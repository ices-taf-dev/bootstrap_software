## Convert data to model format, write model input files

## Before: data.RData (data)
## After:  data.RData (input)

library(icesTAF)

mkdir("input")
cp("data/data.RData", "input", move=TRUE)
