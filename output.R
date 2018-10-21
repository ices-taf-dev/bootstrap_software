## Extract results of interest, write TAF output tables

## Before: data.RData results.RData (model)
## After:  fatage.csv, natage.csv, summary.csv (output)

library(icesTAF)
taf.library()
suppressWarnings(suppressMessages(library(FLSAM)))

mkdir("output")

load("model/data.RData")
load("model/results.RData")

setwd("output")

## N at age, F at age
write.taf(flr2taf(NSH.sam@stock.n), "natage.csv")
write.taf(flr2taf(NSH.sam@harvest), "fatage.csv")

## Summary
vlu <- c("value", "lbnd", "ubnd")
summary <- data.frame(
  rec(NSH.sam)$year,
  rec(NSH.sam)[vlu],
  tsb(NSH.sam)[vlu],
  ssb(NSH.sam)[vlu],
  catch(NSH.sam)[vlu],
  fbar(NSH.sam)[vlu],
  c(catch(NSH), NA),
  c(sop(NSH), NA), row.names=NULL)
names(summary) <- c(
  "Year",
  "Rec",   "Rec_lo",   "Rec_hi",
  "TSB",   "TSB_lo",   "TSB_hi",
  "SSB",   "SSB_lo",   "SSB_hi",
  "Catch", "Catch_lo", "Catch_hi",
  "Fbar",  "Fbar_lo",  "Fbar_hi",
  "Landings", "SOP")
write.taf(summary, "summary.csv")

setwd("..")
