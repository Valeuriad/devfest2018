library("QLearning")


trainBot <- function(){
  currentState = applyAction(state, 1)
  #hState = h(currentState)
  #print(hState)
  player1 <- 'choose'
  state <<- applyAction(currentState, 2, match(player1, ACTIONS_LABELS))
  
  reward = 0
  if(!isPlayerOk(state)){
    reward = 1000
    state <<- resetState(state)
  }else{
    if(mean(state == currentState) != 1){
      reward = (max_dist - getManDist(which(state == 1),which(state == 2)))  
    }else{
      reward = -10
    }
    
  }
  
  print(paste0("Iteration: ",i,"/",max_ite))
  i <<- i + 1
  return(reward)
}
i = 1
max_ite = 1000000
strat <- qlearn(game="trainBot",statevars="currentState",possibleactions=ACTIONS_LABELS,
                playername="player1",numiter=max_ite)