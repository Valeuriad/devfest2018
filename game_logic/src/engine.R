N_MAP = 8
M_MAP = 8
BLK_PROB = 0.1

P_ID = 1
G_IDS = c(2)

ACTIONS_LABELS = c("left","up","right","down")
ACTIONS_FUNC = c(function(x){ifelse(x%%N_MAP!=1,x-1,x)},#left
                 function(x){x-N_MAP},                           #up
                 function(x){ifelse(x%%N_MAP!=0,x+1,x)},    #right
                 function(x){x+N_MAP}                            #down
                 ) 

getState <- function(path = NULL){
  if(!is.null(path)){
    if(file.exists(path)){
      return(readRDS(path))
    }
  }
  
  state = runif(N_MAP*M_MAP,0,1)
  state = ifelse(state<BLK_PROB,-1,0)
  for(i in 1:max(G_IDS)){
    pos = sample(which(state==0),1)
    state[pos] = i
  }
  
  DEBUG(state)

    return(state)
}

resetState <- function(state){
  state[state > 0 ] = 0
  for(i in 1:max(G_IDS)){
    pos = sample(which(state==0),1)
    state[pos] = i
  }
  return(state)
}

isPlayerOk <- function(state){
  return(sum(state == P_ID) > 0)
}

isValidPosition <- function(state, pos){
  if(pos < 1 | pos > length(state)){    #out of the map
    return(FALSE)
  }
  
  if(state[pos] < 0 | state[pos] > 1){ #wall or ghost (can go on player pos => win for ghost)
    return(FALSE)
  }
  
  return(TRUE)
}

applyAction <- function(state, id, action = round(runif(1,1,4))){
  print(paste0("Applying ",ACTIONS_LABELS[action]," to ", id))
  pos = which(state == id)
  
  target = ACTIONS_FUNC[[action]](pos)
  if(isValidPosition(state,target)){
    state[pos] = 0
    state[target] = id
  }
  
  return(state)
}