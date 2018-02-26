source("Agent.R")
source("Memory.R")
source("train.R")
library("tensorflow")
N_EPISODE <- 500
BATCH_SIZE <- 32


tf$reset_default_graph()
agent <-
  Agent$new(
    input_shape = N_MAP*M_MAP,
    output_dim = length(ACTIONS_FUNC),
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
    state = resetState(state)
    total_reward = 0
    iteration = 0
    while (!done) {
      iteration = iteration +1
      newState <- applyAction(state = state, id = 1)                            #player randomly moves
      last_dist = getManDist(which(state == 1),which(state == 2))               #dist between bot and player
      action <- agent$get_action(state_ = newState, step = episode_i)           #bot makes decision
      
      newState <- applyAction(state = newState, id = 2, action = (action + 1))  #bot moves
      if(!isPlayerOk(newState) | iteration == 100){                             #player down, bot wins
        if(!isPlayerOk(newState)){
          reward <- 200-(iteration)                                             #hUge reward  
        }else{
          reward <- -200          
        }
        done <- TRUE     
      }else{
        if(mean(state == newState) != 1){                                       #bot moved/did not move
          dist <- getManDist(which(newState == 1),which(newState == 2))               #new distance
          if(dist < last_dist){
            reward <- 1                                                         #making progress: small reward
          }else{
            reward <- -5*log(iteration)                                         #coward: don't flee
          }
        }else{
          reward <- -10*log(iteration)                                          #try to move !!
        }
        done <- FALSE
      }
      memory$push(state, action, reward, done, newState)                        #Remember this !
      
      if (memory$length > BATCH_SIZE) {
        batch <- memory$sample(BATCH_SIZE)
        train(agent, batch)
      }
      state <- newState
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
  saver$save(sess,"../data/tfmodel.mdl")
})

