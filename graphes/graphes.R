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

p <- ggplot() + geom_point(aes(board_size, new_pos, col = legit), data=points) +
  xkcdaxis(xrange,yrange) +
  scale_color_continuous(low = "#132B43", high = "#86bd34ff") +
  geom_smooth(mapping=aes(x=x, y =y),
              data =data.frame(x = c(0,5,10,18,50,60),y=c(0,6,11,18,50,60)), colour = "#86bd34ff", method="loess")
p

datalines = data.frame(xbegin = 9, ybegin = 52, xend = 12, yend = 58)
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