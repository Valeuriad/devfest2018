library("hashFunction")

state = getState()
max_dist = getManDist(1, N_MAP * N_MAP)



playGame <- function(strat, export = FALSE){
    ITERATION = 1
    while(isPlayerOk(state)){
      state = applyAction(state = state, id = 1)
      DEBUG(state)
      if(export){
        today = Sys.Date()
        if(!dir.exists(paste0("../img/",today))){
          dir.create(paste0("../img/",today))
        }
        dev.copy(png,paste0("../img/",today,ITERATION,".png"))
        dev.off()  
      }
      ITERATION <<- ITERATION +1
      Sys.sleep(0.5)
      for(i in 2:max(G_IDS)){
        action =  qlearningaction(strat, h(state), exploration = 0.1)
        newState = applyAction(state = state, id = i, action = match(action, ACTIONS_LABELS))
        reward = 0
        if(!isPlayerOk(newState)){
          reward = 1000
          newState <<- resetState(newState)
        }else{
          if(mean(newState == state) !=1 ){
            reward = (max_dist - getManDist(which(newState == 1),which(newState == 2)))  
          }else{
            reward = -10
          }
          
        }      
        strat = qlearningupdate(strat, h(state), 
                                action, reward, nextstate=h(newState),
                                rewardcount=.5, gamma=.25)
        state = newState
      }  
   }
}

playGame(strat)
