download_github <- function(repo, path, ref="master", dir=".")
{
  url <- paste("https://github.com", repo, "raw", ref, path, sep="/")
  download(url, dir=dir)
}

mkdir("bootstrap/packages")


repo <- "flr/R"
path <- "src/contrib/FLCore_2.6.6.tar.gz"
ref <- "7b25d8f4059f549110b456b486e6b0bd0f7ca178"

download_github(repo, path, ref, dir="bootstrap/packages")


ref <- "25b35914cdf2f210a8b3bc0712e32dfbc1dde73b"


"https://github.com/User/repo/archive/master.tar.gz"

download("https//github.com/fishfollower/SAM/archive/25b35914cdf2f210a8b3bc0712e32dfbc1dde73b.tar.gz")
download("https//github.com/fishfollower/SAM/archive/master.tar.gz")

repo <- "fishfollower/SAM"
ref <- "25b35914cdf2f210a8b3bc0712e32dfbc1dde73b"

download("https://github.com/admb-project/adstudio/releases/download/construction/auctex121-built.zip")

################################################################################

url <- paste0("https://api.github.com/repos/",
              "fishfollower/SAM",
              "/tarball/",
              "25b3591")

https://api.github.com/repos/fishfollower/SAM/zipball/25b35914cdf2f210a8b3bc0712e32dfbc1dde73b
https://api.github.com/repos/ices-tools-prod/icesTAF/zipball/master
https://api.github.com/repos/ices-tools-prod/icesTAF/tarball/master

download(url)

url <- paste0("https://codeload.github.com/repos/",
              "fishfollower/SAM",
              "/tarball/",
              "25b35914cdf2f210a8b3bc0712e32dfbc1dde73b")



url <- "https://codeload.github.com/ices-tools-prod/icesTAF/legacy.tar.gz/master"
download(url)

url <- "https://codeload.github.com/fishfollower/SAM/legacy.tar.gz/25b35914cdf2f210a8b3bc0712e32dfbc1dde73b"

url <- paste("https://codeload.github.com",
             "fishfollower/SAM",
             "legacy.tar.gz",
             "25b35914cdf2f210a8b3bc0712e32dfbc1dde73b",
             sep="/")

################################################################################

## 1  icesTAF

## 1.1  browser -> install

"https://codeload.github.com/ices-tools-prod/icesTAF/legacy.tar.gz/master"
install.packages("~/ices-tools-prod-icesTAF-1.6-2-1-gca7d511.tar.gz")

## 2  stockassessment

## 2.1  browser -> install

## "https://codeload.github.com/fishfollower/SAM/legacy.tar.gz/25b35914cdf2f210a8b3bc0712e32dfbc1dde73b"

"https://api.github.com/repos/fishfollower/SAM/tarball/25b3591"
"https://codeload.github.com/fishfollower/SAM/legacy.tar.gz/25b3591"
cp("~/fishfollower-SAM-v0.03-505-g25b3591.tar.gz", "bootstrap/packages", move=TRUE)
untar("bootstrap/packages/fishfollower-SAM-v0.03-505-g25b3591.tar.gz", exdir="bootstrap/packages")
install.packages("bootstrap/packages/fishfollower-SAM-25b3591/stockassessment", repos=NULL)

## 2.2  download -> install

mkdir("bootstrap/packages")
download("https://codeload.github.com/fishfollower/SAM/legacy.tar.gz/25b3591",
         destfile="bootstrap/packages/fishfollower-SAM-25b3591.tar.gz")

untar("bootstrap/packages/fishfollower-SAM-25b3591.tar.gz",
      exdir="bootstrap/packages")

mkdir("bootstrap/library")
install.packages("bootstrap/packages/fishfollower-SAM-25b3591/stockassessment",
                 lib="bootstrap/library", repos=NULL)

################################################################################

https://codeload.github.com/flr/FLSAM/legacy.tar.gz/7e078fa
