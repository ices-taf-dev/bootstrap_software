## Run analysis, write model results

## Before: data.RData (input)
## After:  config.RData, data.RData, results.RData (model)

library(icesTAF)
taf.library()
suppressWarnings(suppressMessages(library(FLSAM)))
library(methods)

mkdir("model")

### ============================================================================
### Construct control object
### ============================================================================

load("input/data.RData")
cp("input/data.RData", "model") # required by output.R

NSH.ctrl <- FLSAM.control(NSH, NSH.tun)

catchRow <- grep("catch", rownames(NSH.ctrl@f.vars))
laiRow   <- grep("LAI", rownames(NSH.ctrl@obs.vars))

## Variance in N random walks (set 1st one free is usually best)
NSH.ctrl@logN.vars[] <- c(1, rep(2,dims(NSH)$age-1))

## All fishing mortality states are free, except oldest ages to ensure stability
NSH.ctrl@states[catchRow,]           <- seq(dims(NSH)$age)
NSH.ctrl@states[catchRow, ac(7:8)]   <- 101

## Group observation variances of catches to ensure stability
NSH.ctrl@obs.vars[catchRow,]          <- c(0, 0, 1, 1, 1, 1, 2, 2, 2)
NSH.ctrl@obs.vars["HERAS", ac(1:8)]   <- c(101, rep(102,5), rep(103,2))
NSH.ctrl@obs.vars["IBTS-Q1", ac(1)]   <- 201
NSH.ctrl@obs.vars["IBTS0", ac(0)]     <- 301
NSH.ctrl@obs.vars["IBTS-Q3", ac(0:5)] <- c(400, 401, rep(402,4))
NSH.ctrl@obs.vars[laiRow, 1]          <- 501

## Catchabilities of the surveys. Set LAI all to 1 value, rest can be varied.
NSH.ctrl@catchabilities["HERAS", ac(1:8)]   <- c(101, 102, rep(103,6))
NSH.ctrl@catchabilities["IBTS-Q1", ac(1)]   <- c(201)
NSH.ctrl@catchabilities["IBTS-Q3", ac(0:5)] <- c(300:305)
NSH.ctrl@catchabilities[laiRow, 1]          <- 401

## Add correlation correction for Q3 survey, not for HERAS
idx <- which(rownames(NSH.ctrl@cor.obs) == "IBTS-Q3")
NSH.ctrl@cor.obs[idx, 1:5] <- c(rep(101,5))
NSH.ctrl@cor.obs.Flag[idx] <- as.factor("AR")

## Variance of F random walks
NSH.ctrl@f.vars[1,] <- c(101, 101, rep(102,4), rep(103,3))
## No correlation structure among ages in F random walks
NSH.ctrl@cor.F <- 0
## Finalise
NSH.ctrl@name <- "North Sea Herring"
NSH.ctrl      <- update(NSH.ctrl)

save(NSH.ctrl, file="model/config.RData")

start.time <- proc.time()[3]
options(stringsAsFactors=FALSE)

### ============================================================================
### Assessment
### ============================================================================

NSH.sam     <- FLSAM(NSH, NSH.tun, NSH.ctrl)
NSH@stock.n <- NSH.sam@stock.n[,ac(range(NSH)["minyear"]:range(NSH)["maxyear"])]
NSH@harvest <- NSH.sam@harvest[,ac(range(NSH)["minyear"]:range(NSH)["maxyear"])]
save(NSH.sam, file="model/results.RData")

### ============================================================================
### Run retrospective
### ============================================================================

n.retro.years   <- 7  # Number of years for which to run the retrospective
NSH.ctrl@residuals <- FALSE
## NSH.retro <- retro(NSH, NSH.tun, NSH.ctrl, retro=n.retro.years)
## save(NSH.retro, file="model/retro.RData")
