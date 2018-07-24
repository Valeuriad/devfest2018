library("h2o")

localH2O = h2o.init(ip = "localhost", port = 54321, startH2O = TRUE)

sizes = list(c(8,8),c(16,16),c(32,32),c(64,64))
dat = c()
for(i in 1:100000){
  x = floor(runif(1,-100,100))
  y = floor(runif(1,-100,100))
  z = floor(runif(1,-5,5))
  s = floor(runif(1,1,length(sizes)))
  ite = floor(runif(1,-100,200))
  dat = rbind(dat, data.frame(x = x, y = z, z = z, h = sizes[[s]][1], w = sizes[[s]][2], ite = ite))
}
test = c()
for(i in 1:5000){
  x = floor(runif(1,-100,100))
  y = floor(runif(1,-100,100))
  z = floor(runif(1,-5,5))
  s = floor(runif(1,1,length(sizes)))
  ite = floor(runif(1,-100,200))
  test = rbind(test, data.frame(x = x, y = z, z = z, h = sizes[[s]][1], w = sizes[[s]][2], ite = ite))
}

dat$target = 0
dat$target[dat$x>=0 & dat$y>=0 & dat$x<dat$w & dat$y <dat$h & dat$z<=1 & dat$z>-1 & dat$ite >= 1] = 1
dat$target[dat$target == 1 & dat$ite >= 100] = 2

test$target = 0
test$target[test$x>=0 & test$y>=0 & test$x<test$w & test$y <test$h & test$z<=1 & test$z>-1] = 1
test$target[test$target == 1 & test$ite >= 100] = 2

dat_h20 = as.h2o(dat)

model = h2o.randomForest(x = 1:6, y = 7, training_frame = dat_h20, ntrees = 500, max_depth = 10)

test_h2o = as.h2o(test)
res = as.data.frame(predict(model, test_h2o))

res = round(res$predict)

mean(res==test$target)

dat[which(res!=test$target),]