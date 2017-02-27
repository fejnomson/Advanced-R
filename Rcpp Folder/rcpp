



#include <Rcpp.h>
using namespace Rcpp;


// [[Rcpp::export]]
double meanC(NumericVector x) {
	int n = x.size();
	double total = 0;
	for(int i = 0; i < n; ++i) {
		total += x[i];
	}
	return total / n;
}


/*** R
library(microbenchmark)
x <- runif(1e5)
microbenchmark(
	mean(x),
	meanC(x)
)
*/


// [[Rcpp::export]]
double f1(NumericVector x) {
	int n = x.size();
	double y = 0;
	for(int i = 0; i < n; ++i) {
		y += x[i] / n;
	}
	return y;
}


// [[Rcpp::export]]
NumericVector f2(NumericVector x) {
	int n = x.size();
	NumericVector out(n);

	out[0] = x[0];
	for(int i = 1; i < n; ++i) {
		out[i] = out[i - 1] + x[i];
	}
	return out;
}


// [[Rcpp::export]]
bool f3(LogicalVector x) {
	int n = x.size();

	for(int i = 0; i < n; ++i) {
		if (x[i]) return true;
	}
	return false;
}


// [[Rcpp::export]]
int f4(Function pred, List x) {
	int n = x.size();

	for(int i = 0; i < n; ++i) {
		LogicalVector res = pred(x[i]);
		if (res[0]) return i + 1;
	}
	return 0;
}


// [[Rcpp::export]]
bool allC(LogicalVector x) {
	int n = x.size();

	for(int i = 0; i < n; ++i) {
		if (x[i] == false) return false;
	}
	return true;
}


// [[Rcpp::export]]
NumericVector cumprodC(NumericVector x) {
	int n = x.size();
	NumericVector out(n);
	out[0] = x[0];

	for(int i = 1; i < n; ++i) {
		out[i] = out[i - 1] * x[i];
	}
	return out;
}


// [[Rcpp::export]]
NumericVector cumminC(NumericVector x) {
	int n = x.size();
	NumericVector out(n);
	out[0] = x[0];

	for(int i = 1; i < n; ++i) {
		if (x[i] < out[i - 1]) {
			out[i] = x[i];
		} else {
			out[i] = out[i - 1];
		}
	}
	return out;
}

/*** R
library(microbenchmark)
x <- sample(999999)
microbenchmark(
	cummin(x),
	cumminC(x)
)
*/


// [[Rcpp::export]]
NumericVector cummaxC(NumericVector x) {
	int n = x.size();
	NumericVector out(n);
	out[0] = x[0];

	for(int i = 1; i < n; ++i) {
		if (x[i] > out[i - 1]) {
			out[i] = x[i];
		} else {
			out[i] = out[i - 1];
		}
	}
	return out;
}

// [[Rcpp::export]]
NumericVector diffC(NumericVector x) {
	int n = x.size();
	NumericVector out(n - 1);

	for(int i = 1; i < n; ++i) {
		out[i - 1] = x[i] - x[i - 1];
	}
	return out;
}


// [[Rcpp::export]]
NumericVector rangeC(NumericVector x) {
	int n = x.size();
	NumericVector out(2); // length 2

	double min = x[0];
	double max = x[0];
	for(int i = 0; i < n; ++i) {
		if (x[i] < min) min = x[i];
		if (x[i] > max) max = x[i];
	}
	out[0] = min;
	out[1] = max;
	return out;
}


// [[Rcpp::export]]
List scalar_missings() {
	int int_s = NA_INTEGER;
	String chr_s = NA_STRING;
	bool lgl_s = NA_LOGICAL;
	double num_s = NA_REAL;

	return List::create(int_s, chr_s, lgl_s, num_s);
}

// [[Rcpp::export]]
List missing_sampler() {
	return List::create(
		NumericVector::create(NA_REAL),
		IntegerVector::create(NA_INTEGER),
		LogicalVector::create(NA_LOGICAL),
		CharacterVector::create(NA_STRING));
}



