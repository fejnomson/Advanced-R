

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


