library("hashFunction")

col_map = c("#000000FF", "#FFFFFFFF", "#00FF00FF")
for(i in 1:length(G_IDS)){
  col_map = c(col_map,"#FF0000FF")
}
DEBUG <- function(state){
  if(interactive()){
    image(matrix(state, N_MAP),col = col_map)
  }
}

getManDist <- function(posA, posB){
  posA = posA - 1
  posB = posB - 1
  
  posA_y = floor(posA/N_MAP)
  posB_y = floor(posB/N_MAP)
  
  posA_x = posA %% N_MAP
  posB_x = posB %% N_MAP
  
  return(abs(posB_x-posA_x)+abs(posB_y-posA_y))
}

h <- function(x){
  return(paste(x, collapse = " "))
  #return(as.character(hashFunction::murmur3.32(paste0(x))))
}