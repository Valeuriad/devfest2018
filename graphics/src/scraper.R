library(tidyverse)
library(jpeg)
library(png)
x <- c(
  URLencode("ghost pixel art"),
  URLencode("monster pixel art") 
  
)
n <- 200
# create url
for(i in 1:length(x)){
  cmd <- paste0("python scraper.py --search '",x[i],"' --num_images ",n," --directory '../data/'")
  system(cmd)
}
imgs <- list.files("../data/")

#source("http://bioconductor.org/biocLite.R")
#biocLite("EBImage")
library("EBImage")
for(i in 1:length(imgs)){
  tryCatch({
    x <- readImage(paste0("../data/",imgs[i]))
    y <- resize(x, w = 64, h = 64)
    image(y)
    Sys.sleep(1)
    EBImage::writeImage(y,paste0("../data/proc/",i,".png"))  
  }, error = function(e){
    print(e)
  })
}


exportData <- function(path = "../data/proc/gm/"){
  imgs <- list.files(path)
  d = array(0, dim = c(length(imgs), 28,28))
  for(i in 1:length(imgs)){
    tryCatch({
      x <- readImage(paste0(path,imgs[i]))
      y <- resize(x, w = 28, h = 28)
      y <- y@.Data[,,1]+y@.Data[,,2]+y@.Data[,,3]
      d[i,,] <- y / max(y)
      image(d[i,,])
      Sys.sleep(1)
    }, error = function(e){
      print(e)
    })
  }
  saveRDS(d, paste0(path,"data.dat"))
}

exportData()
exportData(path = "../data/proc/pg/")