library(tidyverse)
library(jpeg)
library(png)
library("magick")
#source("http://bioconductor.org/biocLite.R")
#biocLite("EBImage")
library("EBImage")


importData <- function(x = c(URLencode("ghost pixel art"), URLencode("monster pixel art")), n = 200){
  # create url
  for(i in 1:length(x)){
    cmd <- paste0("python scraper.py --search '",x[i],"' --num_images ",n," --directory '../data/'")
    system(cmd)
  }
  imgs <- list.files("../data/")
  
  
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
}

exportData <- function(path = "../data/proc/gm/", export = TRUE){
  imgs <- list.files(path)
  d = array(0, dim = c(length(imgs)*4, 28,28))
  dd = array(0, dim = c(length(imgs)*4, 28,28, 3))
  index = 1
  for(i in 1:length(imgs)){
    tryCatch({
      x <- image_read(paste0(path,imgs[i])) %>%
        image_background(color = "#FFFFFF") %>%
        as_EBImage()
      img <- resize(x, w = 28, h = 28)
      y <- img@.Data[,,1]+img@.Data[,,2]+img@.Data[,,3]
      scaler <- max(y)/2
      d[index,,] <- (y-scaler) / scaler
      yy <- img@.Data[,,1:3]
      di <- dim(yy)
      yy <- apply(yy, 3, function(x)(x-max(x)/max(x)))
      dim(yy) <- di
      dd[index,,,] <- yy
      index <- index + 1
      img <- rotate(img, 0)
      y <- img@.Data[,,1]+img@.Data[,,2]+img@.Data[,,3]
      d[index,,] <- (y-scaler) / scaler
      yy <- img@.Data[,,1:3]
      di <- dim(yy)
      yy <- apply(yy, 3, function(x)(x-max(x)/max(x)))
      dim(yy) <- di
      dd[index,,,] <- yy
      index <- index + 1 
      img <- rotate(img, 0)
      y <- img@.Data[,,1]+img@.Data[,,2]+img@.Data[,,3]
      print(dim(img@.Data))
      d[index,,] <- (y-scaler) / scaler
      yy <- img@.Data[,,1:3]
      di <- dim(yy)
      yy <- apply(yy, 3, function(x)(x-max(x)/max(x)))
      dim(yy) <- di
      dd[index,,,] <- yy
      index <- index + 1 
      img <- rotate(img, 0)
      y <- img@.Data[,,1]+img@.Data[,,2]+img@.Data[,,3]
      d[index,,] <- (y-scaler) / scaler
      yy <- img@.Data[,,1:3]
      di <- dim(yy)
      yy <- apply(yy, 3, function(x)(x-max(x)/max(x)))
      dim(yy) <- di
      dd[index,,,] <- yy
      index <- index + 1 
      if(!export){
        grid.raster((dd[index-1,,,] +1)/2)
        Sys.sleep(1)
      }
    }, error = function(e){
      print(e)
    })
  }
  if(export){
    saveRDS(d, paste0(path,"data.dat"))
    saveRDS(dd, paste0(path,"cdata.dat"))  
  }
  
}


x <- c(
  URLencode("ghost pixel art"),
  URLencode("monster pixel art") 
)
n <- 200

x <- URLencode("sprite block pixel art")
importData(x,n)

exportData()
exportData(path = "../data/proc/pg/")

exportData(path = "../data/proc/block/")