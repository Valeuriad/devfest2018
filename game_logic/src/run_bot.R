library("plumber")

app = plumb("Agent.R")
app$run(host="0.0.0.0", port = 4242)

