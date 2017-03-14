# Performance (skimmed)

# method dispatch slows function calls by 3x

# the more environments R has to look thru to find the data bound to a
# 	symbol, the longer it'll take to find variables

# Adding more function arguments slows down function calls
# 	R has to do extra work for each additional function argument; R has to
# 	store the promise object containing the expression and the environment
# 	in which to perform the computation



microbenchmark::microbenchmark(
  "[32, 11]"      = mtcars[32, 11],
  "$carb[32]"     = mtcars$carb[32],
  "[[c(11, 32)]]" = mtcars[[c(11, 32)]],
  "[[11]][32]"    = mtcars[[11]][32],
  ".subset2"      = .subset2(mtcars, 11)[32]
)

microbenchmark::microbenchmark(
  "mtcars$cyl" = mtcars$cyl, 
  "mtcars[['cyl']]" = mtcars[['cyl']], # so this is faster than $???
  "`[`(mtcars, TRUE, 'cyl')" = `[`(mtcars, TRUE, 'cyl'), # THIS IS TWICE AS SLOW AS mtcars[['cyl']]?!?!?
  "`[.data.frame`(mtcars, TRUE, 'cyl')" = `[.data.frame`(mtcars, TRUE, 'cyl'), # THIS IS TWICE AS SLOW AS mtcars[['cyl']]?!?!?
  ".subset(mtcars, 'cyl')" = .subset(mtcars, 'cyl'), # [ operator
  ".subset2(mtcars, 'cyl')" = .subset2(mtcars, 'cyl') # [[ operator # so these are 13 to 250x faster than mtcars[['cyl']]??? wtf
)


squish_ife <- function(x, a, b) {
  ifelse(x <= a, a, ifelse(x >= b, b, x))
}
squish_p <- function(x, a, b) {
  pmax(pmin(x, b), a)
}
squish_in_place <- function(x, a, b) {
  x[x <= a] <- a
  x[x >= b] <- b
  x
}
x_small <- runif(10, -1.5, 1.5)
x_med <- runif(1000, -1.5, 1.5)
x_large <- runif(10000, -1.5, 1.5)
microbenchmark::microbenchmark(
	squish_ife(x_small, -1, 1),
	squish_p(x_small, -1, 1),
	squish_in_place(x_small, -1, 1)
)
microbenchmark::microbenchmark(
	squish_ife(x_med, -1, 1),
	squish_p(x_med, -1, 1),
	squish_in_place(x_med, -1, 1)
)
microbenchmark::microbenchmark(
	squish_ife(x_large, -1, 1),
	squish_p(x_large, -1, 1),
	squish_in_place(x_large, -1, 1)
)
# So it looks like the faster version - in_place - scales very well;
# 	from 3.7x faster at small size to 8x faster at large size. guessing its
# 	because there's less overhead...

a_list <- as.list(mtcars)
a_matrix <- as.matrix(mtcars)
a_df <- mtcars

microbenchmark::microbenchmark(
	'element from list' = a_list$cyl,
	'column from matrix' = a_matrix[ , 2],
	'column from data frame' = a_df$cyl,
	'column from data frame 2' = a_df[ , 'cyl'],
	'row from data frame' = a_df[10, ]
)
# HOW IS ROW FROM DATA FRAME THIS SLOW? HOW IS IT 10X SLOWER THAN COLUMN?


# Sometimes a simple C++ implementation is much better than the best
# 	pure R implementation
# not entirely sure why, but sometimes it's expensive for R to generate
#	 and allocate	memory for a bunch of intermediate vectors, where C++
# 	doesn't have to make all these copies...
# The low overhead looping in C++ means you don't need to make all these
# 	intermediate vectors and variables to store and eat up memory
# So looks like vectorization can be taxing if there's big data, etc., and
# 	if you tap out r's resources with vectorization, a simple C++
# 	implementation can take it to the next level
