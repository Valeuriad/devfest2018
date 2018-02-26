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
  print(map)
  map = resetState(map)
  return(100-playGame(state = map, strat = strat))
}

saveRDS(maps@solution[1,]-1,"../data/map_1.dat")