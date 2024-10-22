
<!-- README.md is generated from README.Rmd. Please edit that file -->

# complyr

<!-- badges: start -->
<!-- badges: end -->

The goal of complyr is to facilitate the creation of compliance tests in
R.

> Given enough rules, all code conforms.

Key Features

- Compliance Definition: Meet predefined gold standards.
- Unit Tests: Use unit tests to ensure compliance.
- Third-Party Tests: Auditors or experts create compliance tests, not
  method authors.
- Compliance Packages: Auditors create packages with compliance tests,
  which can be documented, indexed, and versioned.
- Gold Standards: Provided as functions in auditor packages for checking
  results.
- Method Assessment: Methods’ packages can include compliance tests from
  auditor packages.
- CI Integration: Supports continuous integration (CI) for automated
  compliance reports and badges.
- Function Registration: Use roxygen2 tags to register functions for
  compliance testing, e.g., `#' @comply pkg test01`.
- Setting Expectations: Specific cases can have exact expectations to
  guide correctness.

## Installation

You can install the development version of complyr from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("patterninstitute/complyr")
```

## Example

In an auditor package you would define two functions, one with a gold
standard result and another that creates a compliance test that ensures
the fulfillment of requirements. Let us say for the sake of illustration
that we wanted to create a compliance policy when it comes to rounding
in R, see [Rounding in
R](https://psiaims.github.io/CAMIS/R/rounding.html). Let’s assume we
would take base R’s implementation of `round` as gold standard.

``` r
library(complyr)

# Gold standard implementation for rounding
std_rounding <- base::round

# Compliance test for rounding (very simple)
# Inside the test code, you use `.f()` as a placeholder verb for the method to
# be tested.
rounding_test <- new_compliance_test(desc = "rounding is compliant", code = {
  # rounds to the even number when equidistant
  testthat::expect_identical(.f(2.5), 2)
  testthat::expect_identical(.f(3.5), 4)
  
  # Otherwise, round to the nearest whole number
  testthat::expect_identical(.f(2.2), 2)
  testthat::expect_identical(.f(2.7), 3)
}, ref_fn = std_rounding)

# `rounding_test()` becomes self-validating if a reference implementation was
# passed to `ref_fn`.
rounding_test()
#> Test passed 🥳
```

Now, let us say that the janitor package wanted to be credited with also
complying with the above rounding definition. Then, janitor authors
would submit their function to the compliance test created above:

``` r
try(rounding_test(janitor::round_half_up))
#> ── Failure: rounding is compliant ──────────────────────────────────────────────
#> .f(2.5) not identical to 2.
#> 1/1 mismatches
#> [1] 3 - 2 == 1
#> 
#> Error : Test failed
```

This test fails purposely because janitor’s definition of rounding is
intentionally different.

## In the wild

In practice, an auditor package would have e.g. an R source file along
the lines of `R/rounding.R`:

``` r
#' Rounding implementation reference
#'
#' ...
#'
#'
#' @export
std_rounding <- base::round

#' Rounding compliance test 1
#'
#' @param .f A function to be tested for compliance. <Specify here the expected interface>.
#'
#' @returns Run for its side effect of performing the compliance test.
#'
#' @export
rounding_test <- new_compliance_test(desc = "rounding is compliant", code = {
  # rounds to the even number when equidistant
  testthat::expect_identical(.f(2.5), 2)
  testthat::expect_identical(.f(3.5), 4)
  
  # Otherwise, round to the nearest whole number
  testthat::expect_identical(.f(2.2), 2)
  testthat::expect_identical(.f(2.7), 3)
}, ref_fn = std_rounding)
```

And the package (e.g. janitor) providing the function to be tested would
include an roxygen2 tag indicating that a compliance test should be
generated by pulling from the auditor package `{auditor.rounding}`.

``` r
#' Round a numeric vector; halves will be rounded up, ala Microsoft Excel.
#'
#' @description
#' In base R `round()`, halves are rounded to even, e.g., 12.5 and
#' 11.5 are both rounded to 12.  This function rounds 12.5 to 13 (assuming
#' `digits = 0`).  Negative halves are rounded away from zero, e.g., -0.5 is
#' rounded to -1.
#'
#' This may skew subsequent statistical analysis of the data, but may be
#' desirable in certain contexts.  This function is implemented exactly from
#' <https://stackoverflow.com/a/12688836>; see that question and comments for
#' discussion of this issue.
#'
#' @param x a numeric vector to round.
#' @param digits how many digits should be displayed after the decimal point?
#' @returns A vector with the same length as `x`
#'
#' @comply auditor.rounding rounding_test
#' 
#' @export
#' @examples
#' round_half_up(12.5)
#' round_half_up(1.125, 2)
#' round_half_up(1.125, 1)
#' round_half_up(-0.5, 0) # negatives get rounded away from zero
#'
round_half_up <- function(x, digits = 0) {
  posneg <- sign(x)
  z <- abs(x) * 10^digits
  z <- z + 0.5 + sqrt(.Machine$double.eps)
  z <- trunc(z)
  z <- z / 10^digits
  z * posneg
}
```
