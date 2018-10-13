d = readRDS("../data/proc/pg/cdata.dat")
write.table(d,"../data/proc/pg.csv", row.names = F, col.names = F)

d = readRDS("../data/proc/gm//cdata.dat")
write.table(d,"../data/proc/gm.csv", row.names = F, col.names = F)

d = readRDS("../data/proc/tiles/cdata.dat")
d[is.na(d)] = mean(d, na.rm = T)
write.table(d,"../data/proc/tiles.csv", row.names = F, col.names = F)

d = readRDS("../data/proc/pacman//cdata.dat")
write.table(d,"../data/proc/pacman.csv", row.names = F, col.names = F)