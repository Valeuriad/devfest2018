source("Agent.R")
source("Memory.R")
source("train.R")
source("Engine.R")
library("tensorflow")
N_EPISODE <- 500
BATCH_SIZE <- 32

engine <- Engine$new()
tf$reset_default_graph()
agent <-
  Agent$new(
    input_shape = engine$N_MAP*engine$M_MAP,
    output_dim = length(engine$ACTIONS_FUNC),
    epsilon_last_episode = 100
  )
agent$debug <- FALSE
memory <- Memory$new(capacity = 50000)



rewards <- c()
toplot <- c()
with(tf$Session() %as% sess, {
  
  saver <- tf$train$Saver()
  
  init <- tf$global_variables_initializer()
  sess$run(init)
  
  for (episode_i in 1:N_EPISODE) {
    done <- FALSE
    engine$resetState()
    total_reward = 0
    iteration = 0
    while (!done) {
      iteration = iteration +1
      state <- engine$getState()
      reward <- engine$playRound(agent,iteration, export = FALSE, step = episode_i)
      if(!engine$isPlayerOk() | iteration >= 100){
        done <- TRUE
      }
      memory$push(state, engine$last_played_action, reward, done, engine$getState())                        
      
      if (memory$length > BATCH_SIZE) {
        batch <- memory$sample(BATCH_SIZE)
        train(agent, batch)
      }
      total_reward <- total_reward + reward
    }
    
    cat(paste0("[Episode: ",episode_i,"] Reward: ",total_reward,", Epsilon: ",agent$epsilon,"\n"))
    
    rewards <- append(rewards, total_reward)
    toplot <- c(toplot, total_reward)
    plot(toplot,type = "l")
    if (length(rewards) > 100) {
      rewards <- rewards[2:length(rewards)]
      if (length(unique(rewards[(length(rewards)-5):length(rewards)]))==1) {
        cat("Converged")
        break
      }
    }
  }
  saver$save(sess,"../data/tfmodel_alt.mdl")
})

