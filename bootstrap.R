library(icesTAF)

## FLCore 2.6.6 [2018-02-21]
taf.install("flr", "FLCore", "d0333c17e8ba093de41d426df88db4776fcdc8c7")

## stockassessment 0.5.4 [2017-10-11]
taf.install("fishfollower", "SAM", "25b35914cdf2f210a8b3bc0712e32dfbc1dde73b",
            subdir="stockassessment")

## FLSAM 2.1.0 [2018-01-24]
taf.install("flr", "FLSAM", "7e078fa5258ce7051fe7db39716ca66fda84c750")

################################################################################

## Notes
##
## Option 1. API with warning
## download("https://api.github.com/repos/flr/FLCore/tarball/d0333c17e8ba093de41d426df88db4776fcdc8c7", destfile="x1.tar.gz")
##
## Option 2. API and suppress warning
## suppressWarnings(download("https://api.github.com/repos/flr/FLCore/tarball/d0333c17e8ba093de41d426df88db4776fcdc8c7", destfile="x2.tar.gz"))
##
## Option 3. CodeLoad server
## download("https://codeload.github.com/flr/FLCore/legacy.tar.gz/d0333c17e8ba093de41d426df88db4776fcdc8c7", destfile="x3.tar.gz")
