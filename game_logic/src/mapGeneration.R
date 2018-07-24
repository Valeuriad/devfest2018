library("GA")
source("Engine.R")
source("Agent.R")
source("utils.R")

gitGud <- function(map,engine,agent){
  map = map -1
  #cat(map)
  DEBUG(map)
  map = engine$resetState(map)
  return(engine$playGame(agent))
}

agent <-
  Agent$new(
    input_shape = engine$N_MAP*engine$M_MAP,
    output_dim = length(engine$ACTIONS_FUNC),
    epsilon_last_episode = 100
  )

with(tf$Session() %as% sess, {
  engine <- Engine$new()
  engine$debug = F
  
  #init <- tf$global_variables_initializer()
  #sess$run(init)
  
  saver <- tf$train$Saver()
  saver$restore(sess, "../data/tfmodel_alt.mdl")
  
  agent$debug <- FALSE
  agent$epsilon <- 0.01
  agent$epsilon_last_episode <- 0.01
  #agent$debug <- TRUE
  
  #engine$resetState()
  #engine$playGame(agent, step = 100)
  
  maps = ga(type = "binary",
            fitness = gitGud,engine,agent,
            min = array(data = 0, dim = N_MAP*M_MAP),
            max = array(data = 1, dim = N_MAP*M_MAP),
            nBits = engine$N_MAP*engine$M_MAP,
            parallel = FALSE,
            maxiter = 50
  )  
  saveRDS(maps@solution[1,]-1,"../data/map_3.dat")
})


