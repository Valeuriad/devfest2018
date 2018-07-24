library(keras)
library(progress)
library(abind)
library(grid)
library(magick)
library("dplyr")
k_set_image_data_format('channels_first')

# Functions ---------------------------------------------------------------


plotImages <- function(image, export = FALSE, ...){
  n <- floor(sqrt(dim(image)[1]))
  if(length(dim(image))>3){
    channel_first <- FALSE
    x <- dim(image)[2]
    y <- dim(image)[3]
    z <- dim(image)[4]
    if(dim(image)[4]>dim(image)[2]){
      channel_first <- TRUE
      x <- dim(image)[3]
      y <- dim(image)[4]
      z <- dim(image)[2]
    } 
    index <- 1
    imgs <- c()
    for(i in 1:n){
      img <- c()
      for(j in 1:n){
        c_img <- image[index,,,]
        dim(c_img) <- c(x,y,z)
        img <- abind(img, c_img, along = 1)
        index <- index + 1
      }
      imgs <- abind(imgs, img, along = 2)
    }
    image <- imgs
    if(z == 1){
      image = abind(image, imgs, along = 3)
      image = abind(image, imgs, along = 3)
    }
  }
  image = (image + 1)/2
  image[image<=0] = .Machine$double.eps
  image[image>=1] = 1- .Machine$double.eps
  grid.raster(EBImage::rotate(image, 0))
  if(export){
    EBImage::writeImage(EBImage::rotate(image, 180), ...)
  }
}


build_generator <- function(latent_size, channels = 1){
  
  cnn <- keras_model_sequential()
  
  cnn %>%
    layer_dense(1024, input_shape = latent_size, activation = "tanh") %>%
    layer_dense(128*7*7, activation = "tanh") %>%
    layer_batch_normalization() %>%
    layer_reshape(c(128, 7, 7)) %>%
    # Upsample to (..., 14, 14)
    layer_upsampling_2d(size = c(2, 2)) %>%
    layer_conv_2d(
      64, c(5,5), padding = "same", #activation = "tanh",
      kernel_initializer = "glorot_normal"
    ) %>%
    layer_activation_leaky_relu(alpha = 0.01) %>% 
    
    # Upsample to (..., 28, 28)
    layer_upsampling_2d(size = c(2, 2)) %>%
     layer_conv_2d(
       128, c(5,5), padding = "same", #activation = "tanh",
       kernel_initializer = "glorot_normal"
     ) %>%
    layer_activation_leaky_relu(alpha = 0.01) %>% 
    # layer_upsampling_2d(size = c(2, 2)) %>%
    # layer_conv_2d(
    #   256, c(5,5), padding = "same", activation = "tanh",
    #   kernel_initializer = "glorot_normal"
    # ) %>%
    # Take a channel axis reduction
    layer_conv_2d(
      channels, c(5,5), padding = "same", #activation = "tanh",
      kernel_initializer = "glorot_normal"
    ) 
  latent <- layer_input(shape = list(latent_size))
  fake_image <- cnn(latent)
  
  keras_model(latent, fake_image)
}

build_discriminator <- function(channels = 1){
  
  cnn <- keras_model_sequential()
  
  cnn %>%
    layer_conv_2d(
      64, c(5,5), 
      padding = "same", 
      strides = c(2,2),
      input_shape = c(channels, 28, 28)#, activation = "tanh"
    ) %>%
    layer_activation_leaky_relu(alpha = 0.01) %>%
    #layer_dropout(0.3) %>%
    layer_max_pooling_2d(pool_size = c(2,2)) %>%
    layer_conv_2d(
      128, c(5, 5), 
      padding = "same", 
      #activation = "tanh"
      strides = c(1,1)
      ) %>%
    layer_activation_leaky_relu(alpha = 0.01) %>%
    #layer_dropout(0.3) %>%  
    layer_max_pooling_2d(pool_size = c(2,2)) %>%
    
    layer_flatten()
  
  
  
  image <- layer_input(shape = c(channels, 28, 28))
  features <- cnn(image)
  
  fake <- features %>% 
    # layer_dense(128, activation = "tanh") %>%
    # layer_dense(64, activation = "tanh") %>%
    # layer_dense(32, activation = "tanh") %>%
    #test with only one dense layer
    layer_dense(1024, activation = "tanh") %>% 
    layer_dense(1, activation = "sigmoid", name = "generation")
  
  keras_model(image, fake)
}


# Data Preparation --------------------------------------------------------
d <- readRDS("../data/proc/pacman/cdata.dat")
#d <- readRDS("../data/proc/tiles/cdata.dat")
#dd <- readRDS("../data/proc/pg/data.dat")
#d <- abind(d,dd,along = 1)
#d = abind(d,d, along = 1)
d[is.na(d)] = .Machine$double.eps
channels = 1
if(length(dim(d))>3){
  channels = dim(d)[4]
}

imgs = NULL
index = 1
plotImages(d)

train_indexes <- sample(1:dim(d)[1],size = floor(0.8*dim(d)[1]))
test_indexes <- (1:dim(d)[1])[!(1:dim(d)[1])%in%train_indexes]
num_train <- length(train_indexes)
num_test <- length(test_indexes)
dataset = c()
if(channels>1){
  dataset$train$x <- d[train_indexes,,,]
  dataset$test$x <- d[test_indexes,,,]
  dim(dataset$train$x) <- c(num_train, 3, 28, 28)
  dim(dataset$test$x) <- c(num_test, 3, 28, 28)
}else{
  dataset$train$x <- d[train_indexes,,]
  dataset$test$x <- d[test_indexes,,]  
  dataset$train$x <- array_reshape(dataset$train$x, c(length(train_indexes), channels, 28, 28), order = "F")
  dataset$test$x <- array_reshape(dataset$test$x, c(length(test_indexes), channels, 28, 28), order = "F")
  
}





# Parameters --------------------------------------------------------------

# Batch and latent size taken from the paper
epochs <- 200 #on ghosts only; 200 too much; 100 good threshold
batch_size <- 5
latent_size <- 100

# Adam parameters suggested in https://arxiv.org/abs/1511.06434
adam_lr <- 0.00005 
adam_beta_1 <- 0.5

# Model Definition --------------------------------------------------------

# Build the discriminator
discriminator <- build_discriminator(channels)
discriminator %>% compile(
  #optimizer = optimizer_adam(lr = adam_lr, beta_1 = adam_beta_1),
  optimize = optimizer_sgd(lr = 0.0005, momentum = 0.9, nesterov = TRUE),
  loss = "binary_crossentropy"
)

# Build the generator

generator <- build_generator(latent_size,channels)
generator %>% compile(
  #optimizer = optimizer_adam(lr = adam_lr, beta_1 = adam_beta_1),
  optimize = "SGD",
  loss = "binary_crossentropy"
)

latent <- layer_input(shape = list(latent_size))
fake <- generator(latent)

# Only want to be able to train generation for the combined model
freeze_weights(discriminator)
results <- discriminator(fake)

combined <- keras_model(latent, results)
combined %>% compile(
  #optimizer = optimizer_adam(lr = adam_lr, beta_1 = adam_beta_1),
  optimize = optimizer_sgd(lr = 0.0005, momentum = 0.9, nesterov = TRUE),
  loss = "binary_crossentropy"
)


# Training ----------------------------------------------------------------

for(epoch in 1:epochs){
  
  num_batches <- trunc(num_train/batch_size)
  pb <- progress_bar$new(
    total = num_batches, 
    format = sprintf("epoch %s/%s :elapsed [:bar] :percent :eta", epoch, epochs),
    clear = FALSE
  )
  
  epoch_gen_loss <- NULL
  epoch_disc_loss <- NULL
  
  possible_indexes <- 1:num_train
  
  for(index in 1:num_batches){
    
    pb$tick()
    
    # Generate a new batch of noise
    noise <- runif(n = batch_size*latent_size, min = -1, max = 1) %>%
      matrix(nrow = batch_size, ncol = latent_size)
    
    # Get a batch of real images
    batch <- sample(possible_indexes, size = batch_size)
    possible_indexes <- possible_indexes[!possible_indexes %in% batch]
    image_batch <- dataset$train$x[batch,,,,drop = FALSE]

    # Generate a batch of fake images, using the generated labels as a
    # conditioner. We reshape the sampled labels to be
    # (batch_size, 1) so that we can feed them into the embedding
    # layer as a length one sequence
    generated_images <- predict(generator, noise)
    
    X <- abind(image_batch, generated_images, along = 1)
    y <- c(rep(1L, batch_size), rep(0L, batch_size)) %>% matrix(ncol = 1)

    # Check if the discriminator can figure itself out
    disc_loss <- train_on_batch(
      discriminator, x = X, 
      y = y
    )
    
    epoch_disc_loss <- rbind(epoch_disc_loss, unlist(disc_loss))
    
    # Make new noise. Generate 2 * batch size here such that
    # the generator optimizes over an identical number of images as the
    # discriminator
    noise <- runif(2*batch_size*latent_size, min = -1, max = 1) %>%
      matrix(nrow = 2*batch_size, ncol = latent_size)

    # Want to train the generator to trick the discriminator
    # For the generator, we want all the {fake, not-fake} labels to say
    # not-fake
    trick <- rep(1, 2*batch_size) %>% matrix(ncol = 1)
    
    combined_loss <- train_on_batch(
      combined, 
      noise,
      trick
    )
    
    epoch_gen_loss <- rbind(epoch_gen_loss, unlist(combined_loss))
    
  }
  
  cat(sprintf("\nTesting for epoch %02d:", epoch))
  
  # Evaluate the testing loss here
  
  # Generate a new batch of noise
  noise <- runif(num_test*latent_size, min = -1, max = 1) %>%
    matrix(nrow = num_test, ncol = latent_size)
  
  generated_images <- predict(generator, noise)
  
  X <- abind(dataset$test$x, generated_images, along = 1)
  y <- c(rep(1, num_test), rep(0, num_test)) %>% matrix(ncol = 1)

  # See if the discriminator can figure itself out...
  discriminator_test_loss <- evaluate(
    discriminator, X, y, 
    verbose = FALSE
  ) %>% unlist()
  
  discriminator_train_loss <- apply(epoch_disc_loss, 2, mean)
  
  # Make new noise
  noise <- runif(2*num_test*latent_size, min = -1, max = 1) %>%
    matrix(nrow = 2*num_test, ncol = latent_size)

  trick <- rep(1, 2*num_test) %>% matrix(ncol = 1)
  
  generator_test_loss = combined %>% evaluate(
    noise, 
    trick,
    verbose = FALSE
  )
  
  generator_train_loss <- apply(epoch_gen_loss, 2, mean)
  
  
  # Generate an epoch report on performance
  row_fmt <- "\n%22s : loss %4.2f "
  cat(sprintf(
    row_fmt, 
    "generator (train)",
    generator_train_loss[1]
  ))
  cat(sprintf(
    row_fmt, 
    "generator (test)",
    generator_test_loss[1]
  ))
  
  cat(sprintf(
    row_fmt, 
    "discriminator (train)",
    discriminator_train_loss[1]
  ))
  
  cat(sprintf(
    row_fmt, 
    "discriminator (test)",
    discriminator_test_loss[1]
  ))
  
  cat("\n")
  
  # Generate some digits to display
  noise <- runif(100*latent_size, min = -1, max = 1) %>%
    matrix(nrow = 100, ncol = latent_size)
  
  # Get a batch to display
  generated_images <- predict(
    generator,    
    noise
  )
  
  plotImages(generated_images)
}