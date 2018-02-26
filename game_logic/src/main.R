source("engine.R")
source("rl.R")
source("utils.R")

state = getState()
max_dist = getManDist(1, N_MAP * N_MAP)

playGame <- function(state = NULL, agent, export = FALSE, max_rounds = 1, max_iteration = 100){
    iteration = 1
    round = 0
    reward = 0
    while(isPlayerOk(state) & iteration < max_iteration){
      validMoves = getValidActions(state, which(state==1))
      validMoves = c(validMoves, validMoves)
      if(!is.null(validMoves)){
        state = applyAction(state = state, id = 1, action = sample(validMoves, 1))  
      }
      
      DEBUG(state)
      if(export){
        today = Sys.Date()
        if(!dir.exists(paste0("../img/",today))){
          dir.create(paste0("../img/",today))
        }
        dev.copy(png,paste0("../img/",today,"/",iteration,".png"))
        dev.off()  
      }
      iteration = iteration +1
      Sys.sleep(0.5)
      last_dist = getManDist(which(state == 1),which(state == 2))
      for(i in 2:max(G_IDS)){
        action = agent$get_action(state_ = state, step = iteration)
        newState = applyAction(state = state, id = i, action = (action+1))
        reward = 0
        DEBUG(newState)
        if(!isPlayerOk(newState)){
          reward = reward + (200-iteration)
          if(round < max_rounds){
            newState <<- resetState(newState)
            round = round + 1  
          }else{
            return(iteration)
          }
        }else{
          if(mean(newState == state) !=1 ){
            dist = getManDist(which(state == 1),which(state == 2))
            if(dist < last_dist){
              reward = reward + 1  
            }else{
              reward = reward -5*log(iteration)
            }
          }else{
            reward = reward-5*log(iteration)
          }
          
        }      
        # strat = qlearningupdate(strat, h(state), 
        #                         action, reward, nextstate=h(newState),
        #                         rewardcount=.5, gamma=.25)
        state = newState
      }  
    }
    if(isPlayerOk(state)){
      reward = reward -200
    }
    print(paste0("Reward: ",reward))
    return(iteration)
}
with(tf$Session() %as% sess, {
  agent$epsilon <- 0.01
  agent$epsilon_last_episode <- 0.01
  agent$debug <- TRUE
  saver <- tf$train$Saver()
  saver$restore(sess, "../data/tfmodel.mdl")
  state = resetState(state)
  playGame(state, agent)
  
})
