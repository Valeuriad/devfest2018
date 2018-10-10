library(R6)
library(tensorflow)
source("Engine.R")
Agent <- R6Class(
    "Agent",
    public = list(
        input_shape = NULL,
        output_dim = NULL,
        epsilon = 1.0,
        states = NULL,
        Q_target = NULL,
        pred = NULL,
        loss = NULL,
        debug = FALSE,
        train_op = NULL,
        epsilon_last_episode = 100,
        initialize = function(input_shape,
                              output_dim,
                              epsilon_last_episode = NULL) {
            self$input_shape <- input_shape
            self$output_dim <- output_dim
            if (!is.null(epsilon_last_episode)) {
                self$epsilon_last_episode <- epsilon_last_episode
                self$epsilon = epsilon_last_episode
            }
            self$states <-
                tf$placeholder(tf$float32,
                               shape = shape(NULL, input_shape),
                               name = "states")
            self$Q_target <-
                tf$placeholder(tf$float32,
                               shape = shape(NULL, output_dim),
                               name = "Q_target")
            
            with(tf$variable_scope("layer1"), {
                net <- self$states
                W_conv1 <- weight_variable(shape(2L, 2L, 1L, 32L))
                b_conv1 <- bias_variable(shape(32L))
                x_image <- tf$reshape(net, shape(-1L, 8L, 8L, 1L))
                h_conv1 <- tf$nn$relu(conv2d(x_image, W_conv1) + b_conv1)
                h_pool1 <- max_pool_2x2(h_conv1)

                # net <- tf$layers$dense(net,
                #                        units = 64L,
                #                        activation = tf$nn$relu)
            })
            with(tf$variable_scope("layer2"), {
              
              W_conv2 <- weight_variable(shape = shape(2L, 2L, 32L, 16L))
              b_conv2 <- bias_variable(shape = shape(16L))

              h_conv2 <- tf$nn$relu(conv2d(h_pool1, W_conv2) + b_conv2)
              h_pool2 <- max_pool_2x2(h_conv2)

              
                # net <- tf$layers$dense(net,
                #                        units = 64L,
                #                        activation = tf$nn$relu)
            })
            with(tf$variable_scope("layer3"), {
              # net <- tf$layers$dense(net,
              #                        units = 16L,
              #                        activation = tf$nn$relu)
              
              W_conv3 <- weight_variable(shape = shape(2L, 2L, 16L, 16L))
              b_conv3 <- bias_variable(shape = shape(16L))
              
              h_conv3 <- tf$nn$relu(conv2d(h_pool2, W_conv3) + b_conv3)
              h_pool3 <- max_pool_2x2(h_conv3)
              
              h_pool_flat <- tf$reshape(h_pool3, shape(-1L, 16L))
              
              self$pred <- tf$layers$dense(h_pool_flat,
                                           units = output_dim)
              
              # self$pred <- tf$nn$relu(tf$matmul(h_pool2_flat, W_fc1) + b_fc1)
              
            })
            with(tf$variable_scope("layer4"), {
              # net <- tf$layers$dense(net,
              #                        units = 8L,
              #                        activation = tf$nn$relu)
            })
            # self$pred <-
            #     tf$layers$dense(net, units = self$output_dim)
            self$loss <-
                tf$reduce_mean(tf$squared_difference(self$pred, self$Q_target))
            
            optim <- tf$train$AdamOptimizer()
            self$train_op <- optim$minimize(self$loss)
        },
        
        get_action = function(state_, step = 20) {
            if (runif(1) < self$epsilon) {
                action <- sample.int(self$output_dim, size = 1) - 1L
                if(self$debug){
                  cat("[Agent] Exploring")
                  cat(paste0(", sampling action ",action,"\n"))  
                }
                
            } else {
                sess <- tf$get_default_session()
                states <- self$states
                feed <-
                    dict(states = matrix(state_, nrow = 1, byrow = TRUE))
                action_probs <- sess$run(self$pred, feed)
                action <- which.max(action_probs) - 1L
                if(self$debug){
                  cat("[Agent] Inferring")
                  cat(paste0(", chosing action ",action,"\n"))  
                }
            }
            
            self$epsilon <-
                max(0.01, -1 / self$epsilon_last_episode * step + 1.0)
            action 
        },
        
        predict = function(states_) {
            sess <- tf$get_default_session()
            states <- self$states
            feed <- dict(states = states_)
            sess$run(self$pred, feed)
        },
        
        train = function(states_, targets_) {
            states <- self$states
            Q_target <- self$Q_target
            
            feed <- dict(states = states_,
                         Q_target = targets_)
            sess <- tf$get_default_session()
            sess$run(self$train_op, feed)
        }
    )
)

conv2d <- function(x, W) {
  tf$nn$conv2d(x, W, strides=c(1L, 1L, 1L, 1L), padding='SAME')
}

max_pool_2x2 <- function(x) {
  tf$nn$max_pool(
    x, 
    ksize=c(1L, 2L, 2L, 1L),
    strides=c(1L, 2L, 2L, 1L), 
    padding='SAME')
}

weight_variable <- function(shape) {
  initial <- tf$truncated_normal(shape, stddev=0.1)
  tf$Variable(initial)
}

bias_variable <- function(shape) {
  initial <- tf$constant(0.1, shape=shape)
  tf$Variable(initial)
}

agent <-
  Agent$new(
    input_shape = engine$N_MAP*engine$M_MAP,
    output_dim = length(engine$ACTIONS_FUNC),
    epsilon_last_episode = 0.01
  )

#* @filter cors
cors <- function(req,res){
  res$setHeader("Access-Control-Allow-Origin","*")
  if (req$REQUEST_METHOD == "OPTIONS"){
    res$setHeader("Acess-Control-Allow-Methods","*")
    res$setHeader("Access-Control-Allow-Headers",req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200
    return(list())
  }  else{
    plumber::forward()  
  }
  
}

#* @get /bot_next_move
#* @post /bot_next_move
function(rawMap=NULL){
  rawMap <- as.vector(t(rawMap[nrow(rawMap):1,])-1)
  with(tf$Session() %as% sess, {
    saver <- tf$train$Saver()
    saver$restore(sess, "../data/tfmodel_alt.mdl")
    action = agent$get_action(rawMap, step = 100) + 1
    print(paste("BOt PLaying ==>",action))
    return(action)
    
  })  
}

# 
# tf$reset_default_graph()
# agent <- Agent$new(N_MAP*M_MAP, length(ACTIONS_FUNC), 0)
# s <- matrix(state, nrow = 1, byrow = T)
# with(tf$Session() %as% sess, {
#     init <- tf$global_variables_initializer()
#     sess$run(init)
#     agent$get_action(s, 0.0)
# })
