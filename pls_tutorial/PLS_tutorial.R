#!/usr/bin/Rscript

# Load dplyr to use %>%
library(dplyr)

# Create a vector with the x  matrix values
xvals  <- c(
  2, 5, 6, 1, 9, 1, 7, 6, 2, 1, 7, 3,
  4, 1, 5, 8, 8, 7, 2, 8, 6, 4, 8, 2,
  5, 8, 7, 3, 7, 1, 7, 4, 5, 1, 4, 3,
  3, 3, 7, 6, 1, 1, 10, 2, 2, 1, 7, 4,
  2, 3, 8, 7, 1, 6, 9, 1, 8, 8, 1, 6,
  1, 7, 3, 1, 1, 3, 1, 8, 1, 3, 9, 5,
  9, 0, 7, 1, 8, 7, 4, 2, 3, 6, 2, 7,
  8, 0, 6, 5, 9, 7, 4, 4, 2, 10, 3, 8,
  7, 7, 4, 5, 7, 6, 7, 6, 5, 4, 8, 8
)  %>%
  matrix(nrow = 9, ncol = 12, byrow = TRUE)

# Create the X matrix values
yvals <- c(
  15, 19, 18, 
  22, 21, 23, 
  29, 30, 30, 
  600, 520, 545, 
  426, 404, 411, 
  326, 309, 303
) %>%
 matrix(nrow = 9, ncol = 2, byrow = FALSE)


# Create a function to normalize the data: data will be scaled to mean = 0 and SS = 1

normalize_pls <- function(matrix) {
  normalize_column <- function(column) {
    centered <- column - mean(column)
    scaled <- centered / sqrt(sum((centered)^2))
    return(scaled)
  }
  apply(matrix, 2, normalize_column)
}
# In the tutorial data was normalized base on the mean of each condition, so 
# we will do the same thing here. Remember that there are 3 conditions and tree observations

# Now we normailize X 

X <- rbind(
    normalize_pls(xvals[1:3,]),
    normalize_pls(xvals[4:6,]),
    normalize_pls(xvals[7:9,])

)

# Now we normalize Y

Y <- rbind(

normalize_pls(yvals[1:3,]),
normalize_pls(yvals[4:6,]), 
normalize_pls(yvals[7:9,])

)

## Replace the Nans  with 0s 

X[is.nan(X)] <- 0.0
Y[is.nan(Y)] <- 0.0
## before we begin the analyses lets  quickly do a correlation matrix of X and Y matrices


library(corrplot)


par (mfrow = c(1,2))

corrplot(cor(X),method = "color" , tl.pos = "n")
corrplot(cor(Y),method = "color" , tl.pos = "n")

## Once we have normalized the data we will proced to calculate the product of YY 

XY <- rbind(

 t(Y[1:3,]) %*%  X[1:3,],
 t(Y[4:6,]) %*%  X[4:6,],
 t(Y[7:9,]) %*%  X[7:9,])

 XY
# sinvugular value decomplosition

SVD <- svd(XY) 

SVD

par(mfrow = c(3,1))


corrplot(SVD$u, method = "color", 
is.corr = F)
corrplot(diag(SVD$d), method = "color",is.corr = F)



# Calculate Lx 

Lx <- X %*% SVD$v * -1 

# Calculate Ly

Ly <- rbind(
Y[1:3,] %*% SVD$u[1:2,] *-1,
Y[4:6,] %*% SVD$u[3:4,] * -1,
Y[7:9,] %*% SVD$u[5:6,] * -1)

par(mfrow = c(1,1))

plot(Lx[,1],Ly[,1],
pch = 20, col = "black" ,
cex = 5)
abline(lm(Ly[,1] ~ Lx[,1]))


plot(Lx[,1], Lx[,2],
xlim = c(-2,2),
ylim = c(-2,2),
cex = 5, 
pch = 20
)
abline(h = 0)
abline(v = 0)

plot(Ly[,1], Ly[,2],
xlim = c(-1,1),
ylim = c(-.7,.7),
cex = 5,
pch = 20
)
abline(h = 0)
abline(v = 0)

