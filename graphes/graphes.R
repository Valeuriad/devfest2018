library("xkcd")

download.file("http://simonsoftware.se/other/xkcd.ttf",
              dest="xkcd.ttf", mode="wb")
system("mkdir ~/.fonts")
system("cp xkcd.ttf ~/.fonts")
font_import(pattern = "[X/x]kcd", prompt=FALSE)
fonts()
fonttable()
if(.Platform$OS.type != "unix") {
  ## Register fonts for Windows bitmap output
  loadfonts(device="win")
} else {
  loadfonts()
}


### Plot CLassification 1
points=data.frame(new_pos = runif(100,1,64), board_size = runif(100,1,64), legit = 0)
points$legit[points$new_pos <= points$board_size] = 1
xrange = range(points$new_pos)
yrange = range(points$board_size)
ratioxy <- diff(xrange) / diff(yrange)

mapping <- aes(x, y, scale, ratioxy, angleofspine,
               anglerighthumerus, anglelefthumerus,
               anglerightradius, angleleftradius,
               anglerightleg, angleleftleg, angleofneck)
dataman <- data.frame( x= c(5,8), y=c(50,60),
                       scale = 10 ,
                       ratioxy = ratioxy,
                       angleofspine = -pi/2 ,
                       anglerighthumerus = c(-pi/6, -pi/6),
                       anglelefthumerus = c(-pi/2 - pi/6, -pi/2 - pi/6),
                       anglerightradius = c(pi/5, -pi/5),
                       angleleftradius = c(pi/5, -pi/5),
                       angleleftleg = 3*pi/2 + pi / 12 ,
                       anglerightleg = 3*pi/2 - pi / 12,
                       angleofneck = runif(1, 3*pi/2-pi/10, 3*pi/2+pi/10))

set.seed(123) # for reproducibility
p <- ggplot() + geom_point(aes(board_size, new_pos, col = legit), data=points) +
  xkcdaxis(xrange,yrange) +
  scale_color_continuous(low = "#132B43", high = "#86bd34ff") 
p

### Plot CLassification 2
p <- ggplot() + geom_point(aes(board_size, new_pos, col = legit), data=points) +
  xkcdaxis(xrange,yrange) +
  scale_color_continuous(low = "#132B43", high = "#86bd34ff") +
  geom_smooth(mapping=aes(x=x, y =y),
              data =data.frame(x = c(0,5,10,18,50,60),y=c(0,6,11,18,50,60)), colour = "#86bd34ff", method="loess")
p

### Plot CLassification 3
datalines = data.frame(xbegin = 9, ybegin = 52, xend = 12, yend = 59)
set.seed(123) # for reproducibility
p <- ggplot() + geom_point(aes(board_size, new_pos, col = legit), data=points) +
  xkcdaxis(xrange,yrange) +
  scale_color_continuous(low = "#132B43", high = "#86bd34ff") +
  geom_smooth(mapping=aes(x=x, y =y),
              data =data.frame(x = c(0,5,10,18,50,60),y=c(0,6,11,18,50,60)), colour = "#86bd34ff", method="loess")+
  annotate("text", x=12, y = 60,
           label = "BOOOO!", family="xkcd", size = 8 ) +
  xkcdline(aes(x=xbegin,y=ybegin,xend=xend,yend=yend),
           datalines, xjitteramount = 0.5)+
  xkcdman(mapping, dataman[1,])
p


### Plot Decision tree
dat = data.frame(x = c(2.015625, 1.000000, 3.031250, 2.000000,
                       4.062500, 3.000000, 5.125000, 4.000000,
                       6.250000, 5.000000, 7.500000, 6.500000,
                       6.000000, 7.000000, 8.500000, 8.000000, 9.000000)
                 ,y = c(1.0000000, 0.9661089, 0.9661089, 0.9320200,
                        0.9320200, 0.8775814, 0.8775814, 0.6369129,
                        0.6369129, 0.4652045, 0.4652045, 0.3241585,
                        0.1865072, 0.1865072, 0.3241585, 0.2652489, 0.2652489),
                 text = c("pos_y < -0.5", "0", "pos_y >= 1.5", "0", "pos_x < -0.5", "0", "pos_x >= 30.5",
                          "0","ite < 0.5", "0", "board_size < 24", "pos_x >= 15.5", "0", "1",
                          "ite < 100", "1", "2"))
datalines = data.frame()
for (i in 1:nrow(dat)){
  #lignes horizontales :
  if(i < (nrow(dat)-1) & i%%2 == 1 & i <= 10 | i == 12 | i == 15){
    x = dat$x[i+1]
    y = dat$y[i+1]
    xend = dat$x[i+2]
    yend = dat$y[i+2]
    datalines = rbind(datalines, data.frame(x,y,xend,yend))
  }
}
datalines = rbind(datalines, data.frame(x=6.5, xend=8.5, y = 0.3241585, yend = 0.3241585))

datalines$y = datalines$y + 0.015
datalines$yend = datalines$yend + 0.015
index = 3
for(i in 1:nrow(dat)){
  #lignes verticales
  if(dat[i,"text"]!="0" & dat[i,"text"]!="1" & dat[i,"text"]!="2" & i > 3){
    x = dat$x[i]
    y = dat$y[i] - 0.015
    xend = dat$x[i]
    yend = datalines$y[index]
    index = index +1
    datalines = rbind(datalines, data.frame(x,y,xend,yend))
  }
}
datalines[12,"yend"] = 0.3391585
datalines[13,"yend"] = 0.2015072
datalines[14,"yend"] = 0.2802489
set.seed(123) # for reproducibility
p <- ggplot() +
  xkcdaxis(c(0,10),c(0,1)) +
  annotate("text", x = dat$x, y = dat$y, label = dat$text, family="xkcd")

for(i in 1:nrow(datalines)){
  p = p + xkcdline(aes(x=x,y=y,xend=xend,yend=yend),
                   datalines[i,], xjitteramount = 0.5)
}
p


### Plot Entropy 1
set.seed(123)
dat = data.frame(x = runif(30,-2,2), y = runif(30,-2,2), c = round(runif(30,0,1)))

p <- ggplot() + 
  xkcdline(aes(x=x,y=y,diameter = d),data.frame(x=0,y=0,d=6.6),typexkcdline = "circunference", xjitteramount = 0.5, yjitteramount=0.5) +
  geom_point(aes(x, y, col = c,size = 3), data=dat) +
  scale_color_continuous(low = "#132B43", high = "#86bd34ff") +
   xkcdaxis(c(-3,3),c(-3,3))+
  annotate("text", x = c(0.5), y = c(-2.8), label = "Group A", family="xkcd", size= 10)
p  
### Plot Entropy 2
dat$c = 1
dat$c[c(1,2,3)] = 0
p <- ggplot() + 
  xkcdline(aes(x=x,y=y,diameter = d),data.frame(x=0,y=0,d=6.6),typexkcdline = "circunference", xjitteramount = 0.5, yjitteramount=0.5) +
  geom_point(aes(x, y, col = c,size = 3), data=dat) +
  scale_color_continuous(low = "#132B43", high = "#86bd34ff") +
  xkcdaxis(c(-3,3),c(-3,3))+
  annotate("text", x = c(0.5), y = c(-2.8), label = "Group B", family="xkcd", size = 10)
p  
### Plot Entropy 3
dat$c = 1
p <- ggplot() + 
  xkcdline(aes(x=x,y=y,diameter = d),data.frame(x=0,y=0,d=6.6),typexkcdline = "circunference", xjitteramount = 0.5, yjitteramount=0.5) +
  geom_point(aes(x, y, col = c,size = 3), data=dat) +
  scale_color_continuous(low = "#132B43", high = "#86bd34ff") +
  xkcdaxis(c(-3,3),c(-3,3))+
  annotate("text", x = c(0.5), y = c(-2.8), label = "Group C", family="xkcd", size = 10)
p  


### Desc Gen Algorithm
text_boxes = data.frame(x = c(1,1,1,2,2), y = c(3,2,1,2,1), label = c(
  "Initialization","Selection","Terminate","Mutation","Cross-over"))
arrows = data.frame(x = c(1,1,1.1,2,1.85), y = c(2.95,1.95,1.95,1.05,2), xend = c(1,1,1.90,2,1.15), yend=c(2.05,1.05,1.05,1.9,2))
p <- ggplot() +
  xkcdline(data = arrows, aes(x=x,y=y,xend=xend,yend=yend),xjitteramount = 0.5) +
  xkcdaxis(c(0,3),c(0,3))+
  annotate("text", x = text_boxes$x, y = text_boxes$y, label = text_boxes$label, family="xkcd")
p