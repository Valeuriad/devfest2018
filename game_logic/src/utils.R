
G_IDS = c(2)
col_map = c("#000000FF", "#FFFFFFFF", "#00FF00FF")
for(i in 1:length(G_IDS)){
  col_map = c(col_map,"#FF0000FF")
}
DEBUG <- function(state, export = FALSE){
  if(interactive()){
    image(matrix(state, sqrt(length(state))),col = col_map)
    if(export){
      today = Sys.Date()
      if(!dir.exists(paste0("../img/",today))){
        dir.create(paste0("../img/",today))
      }
      dev.copy(png,paste0("../img/",today,"/",iteration,".png"))
      dev.off()  
    }
    Sys.sleep(0.25)
  }
}
