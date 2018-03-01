library("GA")

maps = ga(type = "binary",
            fitness = gitGud,
            min = array(data = 0, dim = N_MAP*M_MAP),
            max = array(data = 1, dim = N_MAP*M_MAP),
            nBits = N_MAP*M_MAP,
            parallel = TRUE,
            maxiter = 50
  )



gitGud <- function(map){
  map = map -1
  cat(map)
  map = resetState(map)
  return(100-playGame(state = map, agent = NULL))
}




saveRDS(maps@solution[1,]-1,"../data/map_2.dat")