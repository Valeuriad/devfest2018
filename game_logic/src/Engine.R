library("R6")

Engine <- R6Class(
  "Engine",
  public = list(
    state = c(),
    last_played_action = 0,
    N_MAP = 8,
    M_MAP = 8,
    BLK_PROB = 0.1,
    P_ID = 1,
    G_IDS = c(2),
    debug = FALSE,
    ACTIONS_FUNC = c(function(x, N_MAP, M_MAP) { #left
      ifelse(x %% N_MAP != 1, x - 1, x)
    },
    function(x, N_MAP, M_MAP) {
      ifelse(x - N_MAP >= 1, x - N_MAP, x) #up
    },
    function(x, N_MAP, M_MAP) {
      ifelse(x %% N_MAP != 0, x + 1, x) #right
    },
    function(x, N_MAP, M_MAP) {
      ifelse(x + N_MAP <=N_MAP * M_MAP, x + N_MAP, x) #down
    }),
    initialize = function(n = 8,
                          m = 8,
                          b_prob = 0.1,
                          gs = 1) {
      self$N_MAP = n
      self$M_MAP = m
      self$BLK_PROB = b_prob
      self$G_IDS = self$P_ID + (1:gs)
      self$loadState(path = "../data/map_3.dat")
      
    },
    setState = function(state = NULL) {
      if (!is.null(state)) {
        self$state = state
      }
      invisible(self)
    },
    getState = function() {
      return(self$state)
    },
    loadState = function(path = NULL) {
      if (!is.null(path)) {
        if (file.exists(path)) {
          self$state <- readRDS(path)
        }
      } 
      if(is.null(self$state)){
        state <- runif(self$N_MAP * self$M_MAP, 0, 1)
        state <- ifelse(self$state < self$BLK_PROB, -1, 0)
        for (i in 1:max(self$G_IDS)) {
          pos <- sample(which(state == 0), 1)
          state[pos] <- i
        }
        self$state <- state
      }
      if(self$debug){
        DEBUG(self$state)  
      }
      
      invisible(self)
    },
    resetState = function(state = self$state) {
      state[state > 0] = 0
      for (i in 1:max(self$G_IDS)) {
        if (i == 1) {
          pos <- which(state == 0)[1]
        } else{
          pos <- which(state == 0)[length(which(state == 0))]
        }
        
        state[pos] <- i
      }
      self$state <- state
      invisible(self)
    },
    isPlayerOk = function() {
      return(sum(self$state == self$P_ID) > 0)
    },
    getValidActions = function(pos) {
      state = self$state
      res = c()
      for (i in 1:length(self$ACTIONS_FUNC)) {
        if (self$state[self$ACTIONS_FUNC[[i]](pos, self$N_MAP, self$M_MAP)] == 0) {
          res = c(res, i)
        }
      }
      return(res)
    },
    isValidPosition = function(pos) {
      state = self$state
      if (pos < 1 | pos > length(state)) {
        #out of the map
        return(FALSE)
      }
      
      if (state[pos] < 0 |
          state[pos] > 1) {
        #wall or ghost (can go on player pos => win for ghost)
        return(FALSE)
      }
      
      return(TRUE)
    },
    applyAction = function(id, action = round(runif(1, 1, 4))) {
      state = self$state
      if (action == 0) {
        return(state)
      }
      pos = which(state == id)
      target = self$ACTIONS_FUNC[[action]](pos, self$N_MAP, self$M_MAP)
      if (self$isValidPosition(target)) {
        state[pos] = 0
        state[target] = id
      }
      self$state = state
      invisible(self)
    },
    getManDist = function(posA, posB) {
      posA = posA - 1
      posB = posB - 1
      
      posA_y = floor(posA / self$N_MAP)
      posB_y = floor(posB / self$N_MAP)
      
      posA_x = posA %% self$N_MAP
      posB_x = posB %% self$N_MAP
      
      return(abs(posB_x - posA_x) + abs(posB_y - posA_y))
    },
    playRound = function(agent,
                         iteration = 1,
                         export = FALSE, 
                         p_action = NULL,
                         ...
                         ) {
      private$setPlayerAction(p_action)
      if(self$debug){
        DEBUG(self$state, export)  
      }
      reward = 0
      for (i in 2:max(self$G_IDS)) {
        last_dist = self$getManDist(which(self$state == self$P_ID), which(self$state == i))
        if (!is.null(agent)) {
          action = agent$get_action(state_ = self$state,...) + 1
          self$last_played_action = action -1
        } else{
          validMoves = getValidActions(which(self$state == i))
          validMoves = c(validMoves, validMoves)
          if (!is.null(validMoves)) {
            action = sample(validMoves, 1)
          } else{
            action = 0
          }
          self$last_played_action = action
        }
        
        self$applyAction(id = i, action = action)
        
  
        if(self$debug){
          DEBUG(self$state, export)  
        }
        
        
        if (!self$isPlayerOk()) {
          reward = 200 - iteration
        } else{
          dist = self$getManDist(which(self$state == self$P_ID), which(self$state == i))
          if (dist < last_dist) {
            reward = 1
          } else{
            reward =  0
          }
        }
      }
      return(reward)
    },
    playGame = function(agent,
                        export = FALSE,
                        max_iteration = 100, ...) {
      iteration = 1
      round = 0
      reward = 0
      while (self$isPlayerOk() & iteration < max_iteration) {
        reward = reward + self$playRound(agent, iteration, export, ...)
        iteration = iteration + 1
        if(self$debug){
          print(paste0("Reward: ", reward))
          print(paste0("Iteration: ", iteration))  
        }
      }
      if (self$isPlayerOk()) {
        reward = reward - 200
      }
      print(paste0("Ended in ",iteration, " iterations - Reward: ",reward))
      return(reward)
    }
  ), 
  private = list(
    setPlayerAction = function(p_action = NULL){
      if(!is.null(p_action)){
        self$applyAction(id = 1, action = p_action)
      }else{
        validMoves = self$getValidActions(which(self$state == 1))
        validMoves = c(validMoves, validMoves)
        if (!is.null(validMoves)) {
          self$applyAction(id = 1, action = sample(validMoves, 1))
        }  
      }
      
    }
  )
)

engine = Engine$new()
engine$resetState()
