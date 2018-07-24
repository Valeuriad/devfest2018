source("Engine.R")
source("utils.R")
engine <- Engine$new()
engine$debug = T

with(tf$Session() %as% sess, {
  agent$epsilon <- 0.01
  agent$epsilon_last_episode <- 0.01
  agent$debug <- TRUE
  saver <- tf$train$Saver()
  saver$restore(sess, "../data/tfmodel_alt.mdl")
  engine$resetState()
  engine$playGame(agent, step = 100)
  
})
