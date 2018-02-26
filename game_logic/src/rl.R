library("QLearning")


trainBot <- function(){
  validMoves = getValidActions(state, which(state==1))
  validMoves = c(validMoves,validMoves)
  if(!is.null(validMoves)){
    currentState = applyAction(state, 1, sample(validMoves, 1))  
  }else{
    currentState = state
  }
  
  #hState = h(currentState)
  #print(hState)
  player1 <- 'choose'
  last_dist = getManDist(which(state == 1),which(state == 2))
  state <<- applyAction(currentState, 2, match(player1, ACTIONS_LABELS))
  
  reward = 0
  if(!isPlayerOk(state)){
    reward = 100
    state <<- resetState(state)
  }else{
    if(mean(state == currentState) != 1){
      dist = getManDist(which(state == 1),which(state == 2))
      if(dist < last_dist){
        reward = 0.1  
      }else{
        reward = -0.1
      }
    }else{
      reward = 0
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