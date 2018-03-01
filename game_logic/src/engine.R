library("R6")

Engine <- R6Class("Engine",
  public = list(
    state = c(),
    N_MAP = 8,
    M_MAP = 8,
    BLK_PROB = 0.1,
    P_ID = 1,
    G_IDS = c(2),
    ACTIONS_LABELS = c("left","up","right","down"),                      
    ACTIONS_FUNC = c(function(x){ifelse(x%%self$N_MAP!=1,x-1,x)},                             #left
                     function(x){ifelse(x-self$N_MAP>=1,x-self$N_MAP,x)},                     #up
                     function(x){ifelse(x%%self$N_MAP!=0,x+1,x)},                             #right
                     function(x){ifelse(x+self$N_MAP<=self$N_MAP*self$M_MAP,x+self$N_MAP,x)}  #down
    ),
    initialize(n = 8, m = 8, b_prob = 0.1, gs = 1){
      self$N_MAP = n
      self$M_MAP = m
      self$BLK_PROB = b_prob
      self$G_IDS = P_ID + (1:gs)
    },
    getState <- function(){
      return(self$state)
    },
    loadState <- function(path = NULL){
      if(!is.null(path)){
        if(file.exists(path)){
          return(readRDS(path))
        }
      }
      
      state <- runif(self$N_MAP*self$M_MAP,0,1)
      state <- ifelse(self$state<self$BLK_PROB,-1,0)
      for(i in 1:max(self$G_IDS)){
        pos <- sample(which(state==0),1)
        state[pos] <- i
      }
      
      DEBUG(state)
      self$state <- state
      invisible(self)
    },
    resetState <- function(state = self$state){
      state[state > 0 ] = 0
      for(i in 1:max(G_IDS)){
        if(i == 1){
          pos <- which(state==0)[1]  
        }else{
          pos <- which(state==0)[length(which(state==0))]
        }
        
        state[pos] <- i
      }
      self$state <- state
      invisible(self)
    },
    isPlayerOk <- function(){
      return(sum(self$state == self$P_ID) > 0)
    },
    getValidActions <- function(pos){
      state = self$state
      res = c()
      for(i in 1:length(ACTIONS_FUNC)){
        if(state[ACTIONS_FUNC[[i]](pos)] == 0){
          res = c(res, i)
        }
      }
      return(res)
    },
    isValidPosition <- function(pos){
      state = self$state
      if(pos < 1 | pos > length(state)){    #out of the map
        return(FALSE)
      }
      
      if(state[pos] < 0 | state[pos] > 1){ #wall or ghost (can go on player pos => win for ghost)
        return(FALSE)
      }
      
      return(TRUE)
    },
    applyAction <- function(id, action = round(runif(1,1,4))){
      state = self$state
      if(action == 0){
        return(state)
      }
      pos = which(state == id)
      target = ACTIONS_FUNC[[action]](pos)
      if(isValidPosition(state,target)){
        state[pos] = 0
        state[target] = id
      }
      self$state = state
      invisible(self)
    }
    
    
  )
)







