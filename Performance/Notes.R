



# memory


# vectors

# theres some overhead to each vector; location in memory, attributes, etc.

# note that numeric is 8 bytes for every element while integer is 4


# R asks for chunks of memory from the OS and then manages it itself;
# 	so for making vectors it wont take the exact amount of memory needed
# Over 128 bytes, R asks for memory ad-hoc from the OS (in chunks of 8 bytes)


x <- 1:1e6
object_size(x)

y <- list(x, x, x)
object_size(y)
# here, R doesnt copy x three times, it just points to x
# y and x share components, so there isn't duplication accross memory

x1 <- 1:1e6
y1 <- list(1:1e6, 1:1e6, 1:1e6)
object_size(x1)
object_size(y1)
object_size(x1, y1)
# here, R can't point to anything when initializing y1, so y1 is three times
# 	the size of x1

# R stores each unique string in one place
# so i guess that means banana isn't copied in memory for each item in
# 	these vectors
object_size(c('banana', 'apple', 'carrot', 'soup'))
object_size(rep(c('banana', 'apple', 'carrot', 'soup'), 10))
object_size(rep(c('banana', 'apple', 'carrot', 'soup'), 100))
# although strings are closer to numeric if there are more values

object_size(c(1.1, 1.2, 10, 3))
object_size(rep(c(1.1, 1.2, 10, 3), 10))
object_size(rep(c(1.1, 1.2, 10, 3), 100)) # this is infinity more than the string vector...

object_size(c(1L, 2L, 10L, 3L))
object_size(rep(c(1L, 2L, 10L, 3L), 10))
object_size(rep(c(1L, 2L, 10L, 3L), 100))
# integer vect is like HALF of numeric... so crazy

object_size(c(TRUE, FALSE, TRUE, FALSE))
object_size(rep(c(TRUE, FALSE, TRUE, FALSE), 10))
object_size(rep(c(TRUE, FALSE, TRUE, FALSE), 100))
# looks like boolean is the exact same as integer...
# so boolean is much more efficient than string; better to keep things string
#		bool, or integer if possible...


col1 <- numeric(1000000)
col2 <- numeric(1000000)
col3 <- integer(1000000)
object_size(col1)
object_size(col2)
object_size(col3)
df <- data.frame(col1, col2, col3)
object_size(df)
# just sum of size of each vector
object_size(data.frame(numeric(1000000), numeric(1000000), integer(1000000)))


vec <- lapply(0:50, function(i) c("ba", rep("na", i)))
str <- lapply(vec, paste0, collapse = "")
sapply(vec, object_size)
sapply(str, object_size)
# looks like having vector of length one that's a string uses much less
#		memory
x <- vec[[length(vec)]]
object_size(factor(x))
object_size(x)
# looks like the factor takes up a bunch more memory
object_size(1:5)
object_size(list(1:5))
# overhead for list(); more complex representation than vector()


mem_used()
# size of all objects in R memory
# size of all R objects but not R interpreter


mem_change(x <- 1:1e6)
# memory used for R increased by 4 MB for the expression x <- 1:1e6






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
