## Preprocess data, write TAF data tables
## Part 1: Construct FLR objects

## Before: canum.txt, caton.txt, fleet.txt, fprop.txt, index.txt, lai.txt,
##         matprop.txt, mprop.txt,
##         Smoothed_span50_M_NotExtrapolated_NSASSMS2016.csv, weca.txt,
##         west_raw.txt (bootstrap/user/data)
## After:  data.RData (data)

library(icesTAF)
taf.library()
suppressMessages(library(FLCore))
library(methods)
library(reshape2)
source("utilities.R")

mkdir("data")

setwd("bootstrap/user/data")

### ============================================================================
### Prepare stock object for assessment
### ============================================================================

## Load object
NSH <- readFLStock("index.txt", no.discards=TRUE)

## Catch is calculated from: catch.wt * catch.n, however, the reported landings
## are normally different (due to SoP corrections). Hence we overwrite the
## calculate landings are we not using catches data then?
NSH@catch <- NSH@landings
units(NSH)[1:17] <- as.list(c(rep(c("tonnes","thousands","kg"),4),
                              rep("NA",2), "f", rep("NA",2)))

## Set object details
NSH@name                           <- "North Sea Herring"
range(NSH)[c("minfbar","maxfbar")] <- c(2, 6)
NSH                                <- setPlusGroup(NSH, NSH@range["max"])

## Historical data is only provided for ages 0-8 prior to 1960
## (rather than 0-9 after)
## We therefore need to fill in the last ages by applying the following
## assumptions
##  - weight in the catch and weight in the stock at age 9 is the same
##    as in period 1960-1983 (constant in both cases)
##  - catch at age reported as 8+ is split evenly between age 8 and 9
##  - natural mortality at age 9 is 0.1 (same as age 8)
##  - proportion mature at age 9 is 1.0 (same as age 8)
##  - harvest.spwn and m.spwn are the same as elsewhere
hist.yrs                      <- as.character(1947:1959)
## Automatic population of catch.wt introduces NAs, so we use landings.wt
NSH@catch.wt                  <- NSH@landings.wt
NSH@catch.wt["9",hist.yrs]    <- 0.271
NSH@landings.wt["9",hist.yrs] <- 0.271
NSH@catch.n["9",hist.yrs]     <- NSH@catch.n["8",hist.yrs] / 2
NSH@catch.n["8",hist.yrs]     <- NSH@catch.n["9",hist.yrs]
NSH@landings.n["9",hist.yrs]  <- NSH@landings.n["8",hist.yrs] / 2
NSH@landings.n["8",hist.yrs]  <- NSH@landings.n["9",hist.yrs]
NSH@stock.wt["9",hist.yrs]    <- 0.312
NSH@m["9",hist.yrs]           <- 0.1
NSH@mat["9",hist.yrs]         <- 1

## No catches of age 9 in 1977 so stock.wt does not get filled there.
## Hence, we copy the stock weight for that age from the previous year.
## Note that because we use a fixed stock.wt prior to 1983, there is no
## need to use averaging or anything fancier.
NSH@stock.wt["9","1977"] <- NSH@stock.wt["9","1976"]

## Use a running mean(y-2,y-1,y) of input wests (i.e. west_raw)
## to calculate west
NSH@stock.wt[,3:dim(NSH@stock.wt)[2]] <-
  (NSH@stock.wt[,3:(dim(NSH@stock.wt)[2]-0)] +
   NSH@stock.wt[,2:(dim(NSH@stock.wt)[2]-1)] +
   NSH@stock.wt[,1:(dim(NSH@stock.wt)[2]-2)]) / 3

### ============================================================================
### Prepare natural mortality estimates
### ============================================================================

## Read in estimates from external file
M2           <- read.csv("Smoothed_span50_M_NotExtrapolated_NSASSMS2016.csv")

colnames(M2) <- sub("X", "", colnames(M2))
rownames(M2) <- M2[,1]
M2           <- M2[,-1]  # Trim off first column as it contains 'ages'
## Keep only years with data
M2           <- M2[,apply(M2,2,function(x){all(is.na(x))==FALSE})]

## Extract key data from default assessment
NSHM2        <- NSH
NSHM2@m[]    <- NA
yrs          <- dimnames(NSHM2@m)$year
yrs          <- yrs[which(yrs %in% colnames(M2))]
NSHM2@m[,yrs][] <- as.matrix(M2)

## Apply 5 year running average
extryrs      <- dimnames(NSHM2@m)$year[which(!dimnames(NSHM2@m)$year %in% yrs)]
extryrsfw    <- extryrs[which(extryrs > max(an(yrs)))]
extryrsbw    <- extryrs[which(extryrs <= max(an(yrs)))]
ages         <- dimnames(NSHM2@m)$age
extrags      <- names(which(apply(M2,1,function(x){all(is.na(x))==TRUE})==TRUE))
yrAver       <- 1
for(iYr in as.numeric(rev(extryrs))){
  for(iAge in ages[!ages%in%extrags]){
    if(iYr %in% extryrsbw)
      NSHM2@m[ac(iAge),ac(iYr)] <-
        yearMeans(NSHM2@m[ac(iAge), ac((iYr+1):(iYr+yrAver)),], na.rm=TRUE)
    if(iYr %in% extryrsfw)
      NSHM2@m[ac(iAge),ac(iYr)] <-
        yearMeans(NSHM2@m[ac(iAge), ac((iYr-1):(iYr-yrAver)),], na.rm=TRUE)
  }
}
if(length(extrags) > 0){
  for(iAge in extrags)
    NSHM2@m[ac(iAge),] <- NSHM2@m[ac(as.numeric(min(sort(extrags)))-1),]
}

## Write new M values into the original stock object
addM <- 0.11  # M profiling based on 2018 benchmark meeting
NSH@m <- NSHM2@m + addM

### ============================================================================
### Prepare index object for assessment
### ============================================================================

## Load and modify all numbers at age data
NSH.tun <- readFLIndices("fleet.txt")
NSH.tun <- lapply(NSH.tun, function(x){x@type <- "number"; return(x)})
NSH.tun[["IBTS0"]]@range["plusgroup"] <- NA

## LAI index: read in raw LAI data
surveyLAI <- read.table("lai.txt", stringsAsFactors=FALSE, header=TRUE)
ORSH      <- subset(surveyLAI, Area == "Or/Sh")
CNS       <- subset(surveyLAI, Area == "CNS")
BUN       <- subset(surveyLAI, Area == "Buchan")
SNS       <- subset(surveyLAI, Area == "SNS")

## Put data into FLR format
ORSH   <- formatLAI(ORSH, 1972, range(NSH)["maxyear"])
CNS    <- formatLAI(CNS, 1972, range(NSH)["maxyear"])
BUN    <- formatLAI(BUN, 1972, range(NSH)["maxyear"])
SNS    <- formatLAI(SNS, 1972, range(NSH)["maxyear"])
FLORSH <- FLIndex(index=FLQuant(t(ORSH), dimnames=list(age=colnames(ORSH),
                                                       year=rownames(ORSH),
                                                       unit="ORSH",season="all",
                                                       area="unique",iter="1")))
FLCNS  <- FLIndex(index=FLQuant(t(CNS), dimnames=list(age=colnames(CNS),
                                                      year=rownames(CNS),
                                                      unit="CNS", season="all",
                                                      area="unique", iter="1")))
FLBUN  <- FLIndex(index=FLQuant(t(BUN), dimnames=list(age=colnames(BUN),
                                                      year=rownames(BUN),
                                                      unit="BUN", season="all",
                                                      area="unique", iter="1")))
FLSNS  <- FLIndex(index=FLQuant(t(SNS), dimnames=list(age=colnames(SNS),
                                                      year=rownames(SNS),
                                                      unit="SNS", season="all",
                                                      area="unique", iter="1")))
range(FLORSH)[6:7] <- range(FLCNS)[6:7] <-
  range(FLBUN)[6:7] <- range(FLSNS)[6:7] <- c(0.67,0.67)
name(FLORSH) <- "LAI-ORSH"
name(FLCNS)  <- "LAI-CNS"
name(FLBUN)  <- "LAI-BUN"
name(FLSNS)  <- "LAI-SNS"
type(FLORSH) <- type(FLCNS) <- type(FLBUN) <- type(FLSNS) <- "partial"
FLORSH@index@.Data[which(is.na(FLORSH@index))] <- -1
FLCNS@index@.Data[which(is.na(FLCNS@index))] <- -1
FLBUN@index@.Data[which(is.na(FLBUN@index))] <- -1
FLSNS@index@.Data[which(is.na(FLSNS@index))] <- -1
NSH.tun[(length(NSH.tun)+1):(length(NSH.tun)+4)] <- c(FLORSH,FLBUN,FLCNS,FLSNS)
names(NSH.tun)[(length(NSH.tun)-3):(length(NSH.tun))] <-
  paste("LAI", c("ORSH","BUN","CNS","SNS"), sep="-")

### ============================================================================
### Apply plusgroup to all data sets
### ============================================================================

pg <- 8

## This function already changes the stock and landings.wts correctly
NSH <- setPlusGroup(NSH,pg)

NSH.tun[["HERAS"]]@index[ac(pg),] <- quantSums(
  NSH.tun[["HERAS"]]@index[ac(pg:dims(NSH.tun[["HERAS"]]@index)$max),])
NSH.tun[["HERAS"]] <- trim(NSH.tun[["HERAS"]],
                           age=dims(NSH.tun[["HERAS"]]@index)$min:pg)
NSH.tun[["HERAS"]]@range["plusgroup"] <- pg

NSH.tun[["IBTS-Q3"]] <- trim(NSH.tun[["IBTS-Q3"]], age=0:5)
NSH.tun[["IBTS-Q1"]] <- trim(NSH.tun[["IBTS-Q1"]], age=1)
NSH.tun[["HERAS"]] <- trim(NSH.tun[["HERAS"]], age=1:8)

### ============================================================================
### Closure data deletion
### ============================================================================

## We don't believe the closure catch data, so put it to NA
NSH@catch.n[, ac(1978:1979)] <- NA

setwd("../../..")

save(NSH, NSH.tun, file="data/data.RData")
