library(icesTAF)

## FLCore and stockassessment are required by FLSAM, so install those first

## FLCore 2.6.6 [2018-02-21]
taf.install("flr", "FLCore", "d0333c1")

## stockassessment 0.5.4, components branch [2018-03-12]
taf.install("fishfollower", "SAM", "25b3591", subdir="stockassessment")

## FLSAM 2.1.0, develop_V2 branch [2018-03-19]
taf.install("flr", "FLSAM", "7e078fa")

## bibtex::write.bib(taf.library(), "bootstrap/DEPENDENCIES.bib")




## cp("bootstrap/initial/data", "bootstrap")
## taf.citations("bootstrap/CITATIONS.md")
