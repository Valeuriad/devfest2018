library("h2o")

localH2O = h2o.init(ip = "localhost", port = 54321, startH2O = TRUE)

sizes = list(c(8,8),c(16,16),c(32,32),c(64,64))
dat = c()
for(i in 1:5000){
  x = floor(runif(1,-100,100))
  y = floor(runif(1,-100,100))
  z = floor(runif(1,-5,5))
  s = floor(runif(1,1,length(sizes)))
  dat = rbind(dat, data.frame(x = x, y = z, z = z, h = sizes[[s]][1], w = sizes[[s]][2]))
}

dat$target = 0
dat$target[dat$x>=0 & dat$y>=0 & dat$x<=dat$w & dat$y <=dat$h & dat$z<=1 & dat$z>=-1] = 1

dat_h20 = as.h2o(dat)

model = h2o.gbm(x = 1:5, y = 6, training_frame = dat_h20, ntrees = 100, max_depth = 10)

res = as.data.frame(predict(model, dat_h20))

res = round(res$predict)

dat[which(res!=dat$target),]