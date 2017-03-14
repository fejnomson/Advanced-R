
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
mem_change(rm(x))
# freed up 4 MB of R memory


mem_change(NULL)
# R tracks history, so everything takes up SOME memory...


# You don't have to delete unused objects to free up memory in R; R will
# 	automatically detect if no names point to an object and then delete it
# 	to free up memory
mem_change(x <- 1:1e6)
mem_change(y <- x) # not what should happen?
mem_change(rm(x)) # this adds memory? but in theory it isn't negative
# 	because y points to the same object, so R doesn't decide that it's no
# 	longer used and deletes it
mem_change(rm(y)) # NOW memory is freed because there are no names
# 	pointing to 1:1e6 any more, so it's deleted from memory


gc() # function all for garbage collection
# if R needs more space, it'll automatically run garbage collection, so
# 	should be fine to not use
# you can use gcinfo() to have R printout when it runs garbage collection
# 	to free up memory
# This might be helpful if i'm running a bunch of intense stuff on
# 	multiple consoles, etc., have a bunch of tableau workbooks open, etc.


f1 <- function() {
  x <- 1:1e6
  10
}
mem_change(x <- f1())
object_size(x)

f2 <- function() {
  x <- 1:1e6
  a ~ b
}
mem_change(y <- f2())
object_size(y)

f3 <- function() {
  x <- 1:1e6
  function() 10
}
mem_change(z <- f3())
object_size(z)

# So what this is saying is that x is released in f1, because the
# 	function is called, the result is returned, and then it's done.
# But in f2 and f3, the results have to return the ENCLOSING ENVIRONMENT,
# 	in f2 it's the enclosing environment of the formula object and in f3
# 	it's the enclosing environment of the function that's being returned.
#	Because the object returned has 'x' bound to it in the enclosing
# 	environment, the object x persists in memory even though nothing really
# 	points to it.
# This is known as memory leak; because R cant perform garbage collection
# 	on objects like 'x'. You continue to point to it even though it's not
# 	really intentional.
# So f1(), after it's done running, leaves memory unchanged - it defines
# 	x wihtin the function and then throws it out afterwards.
# where as f2() and f3() leave more memory used after after they're finished
# 	running, because they keep pointing to the x object in the enclosing
# 	environment of the function output



# looks like lineprof() is super useful and informative, especially for any
# 	functions I'm running 1 million times in a groupby operation; just
# 	looks like it's meant for RStudio...
# can't beleive that as.data.frame() makes over 600 duplications here!!!
# can use gctorture() to make everything much more precise during profiling
# I should do these exercises with lineprof, but don't feel like it right
# 	now...don't want to deal with installing Rstudio or finding out how to
# 	install it




x <- 1:10
address(x) # this is the location in memory where x is stored
refs(x) # this is the number of names that point to x's location in memory
c(address(x), refs(x)) # so there's only one name that points to x's address
y <- x
c(address(y), refs(y)) # so now there are two names pointing to that address

`<-`(x, 1:5)
`<-`(y, x)
rm(y)
refs(x) # should be 1. doesn't change even after garbage collection

`<-`(x, 1:5)
`<-`(y, x)
`<-`(z, x)
refs(x) # should be 3...
# so refs() isn't perfect, but it should at least be able to distinguish
# 	between 1 and more than 1 references to an address...

# IF REFS IS ONE, IT'S MOD IN PLACE; IF REFS IS MORE THAN ONE, R MADE A COPY
# I think the reasoning why is a little out of my range...
`<-`(x, 1:5)
`<-`(y, x)
c(address(x), address(y)) # same address; R just points to y to x

x[5] <- 6L
c(address(x), address(y)) # R made a copy of y, modified it, and stored
# 	it in a new address while keeping the name 'y'. wondering if this has
# 	to do with changing the dtype...


`<-`(x, 1:5)
tracemem(x)

x[5] <- 6L # x is modified in place
y <- x # y and x point to x's address
x[5] <- 6L # now that you're modifying x and not y, R makes a copy of x,
# 	modifys it, and stores it in a new location, leaving y unchanged.
# So tracemem() traces an object and prints a message every time that
# 	object is copied by R. So here it's saying that x moved from location 
# 	a to location b.
# tracemem() is a little better than refs() for interactive use, but harder
# 	to program with because it only prints stuff out

f <- function(x) x
{x <- 1:10; print(address(x)); f(x); refs(x); address(x)}
# NON-PRIMITIVE FUNCTIONS INCREMENT REFS().
# Even though it makes more references, it doesn't create a copy and store the copy at a new address
{x <- 1:10; print(address(x)); sum(x); refs(x); address(x)}
# PRIMITIVE FUNCTIONS DON'T INCREMENT REFS()
# Doesn't make a copy or a new reference; x stays in the same place

f <- function(x) 10
g <- function(x) substitute(x)
{x <- 1:10; f(x); refs(x)}
# These functions don't evaluate x, so don't add to the ref count

# These usually mod in place:
# 	[[<-, [<-, @<-, $<-, attr<-, attributes<-, class<-, dim<-, dimnames<-,
# 	names<-, and levels<-.

# PRIMITIVE REPLACEMENT FUNCTIONS WILL GENERALLY MOD IN PLACE, PROVIDED
# 	THAT THERE AREN'T MULTIPLE REFERENCES TO THE OBJECT BEING MODIFIED.
# So in short:
# 	R will have many objects point to the same address, which is efficient.
# 	But if you change an object pointing to an address as other objects,
# 		R has to make a copy of that object, apply the modifications, and then
# 		store the modified object at a different address under that same
# 		variable name. This is where operations become expensive...



x <- data.frame(matrix(runif(100 * 1e4), ncol = 100))
medians <- vapply(x, median, numeric(1))

for(i in seq_along(medians)) {
  x[, i] <- x[, i] - medians[i]
  # looks like it mods in place
}

for(i in 1:5) {
  x[, i] <- x[, i] - medians[i]
  print(c(address(x), refs(x)))
  # but you can see that x is stored under a new address with every iteration
}

# These are NOT primitive functions:
	# `[<-.data.frame`
	# `[[<-.data.frame`


y <- as.list(x)
for(i in 1:5) {
	y[[i]] <- y[[i]] - medians[i]
	print(c(address(y), refs(y)))
	# IF YOU CONVERT X TO A LIST, YOU CAN USE `[[<-`, WHICH IS PRIMITIVE AND
	# 	THEREFOR MODS IN PLACE AND DOESN'T INCREMENT REFS
}


microbenchmark::microbenchmark(
	'df' = {for(i in seq_along(medians)) {
	  x[, i] <- x[, i] - medians[i]
	  # print(c(address(x), refs(x)))
	}}
)
microbenchmark::microbenchmark(
	'list' = {for(i in seq_along(medians)) {
		y[[i]] <- y[[i]] - medians[i]
		# print(c(address(y), refs(y)))
	}}
)
# Not entirely sure how to handle this, but looks like dataframe is 8 seconds
# 	and list is de-minimis
# this is a HUGE difference for something seemily rote...


refs(y)
y <- as.list(x)
refs(y)
for(i in seq_along(medians)) {
	y[[i]] <- y[[i]] - medians[i]
	print(refs(y))
}
# So it looks like the duplication happens when you convert y from x;
# 	wondering if R thinks it can store y as a reference to the same address
# 	as x. Then when you modify y, R has to copy it, change it, then store 
# 	at a new location. But it only does that once; after the initial change
# 	is made, it can modify the object at that address without copying it.


to_df <- function(x) {
	message(pryr::refs(x))
  class(x) <- "data.frame"
  message(pryr::refs(x))
  attr(x, "row.names") <- .set_row_names(length(x[[1]]))
  message(pryr::refs(x))
  x
}
# not sure why the number of refs goes from 2 to 1...
