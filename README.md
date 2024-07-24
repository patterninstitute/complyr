
<!-- README.md is generated from README.Rmd. Please edit that file -->

# complyr

<!-- badges: start -->
<!-- badges: end -->

The goal of complyr is to facilitate the creation of compliance tests in
R.

> Given enough rules, all code conforms.

Desired features and key ideas:

- **Compliance Definition:** Compliance refers to meeting predefined
  gold standards. For example, if under certain circumstances, the exact
  results of a statistical test can be predicted using mathematical
  theory, one may define a gold standard with specific numerical
  accuracy.
- **Unit Tests for Compliance:** Utilize unit tests as a method for
  recognizing or enforcing compliance.
- **Third-Party Compliance Tests:** Compliance tests are written by
  third parties, such as auditors or domain experts, rather than the
  authors of the methods being tested.
- **Compliance Packages:** Auditors create compliance packages that
  include compliance tests as functions. These packages can be
  documented, indexed in a compliance specification, and versioned like
  any other package.
- **Gold Standards as Functions:** Gold standards are provided as
  functions within auditor packages as part of their API, enabling
  method implementors to check against these fixtures.
- **Assessment of Methods’ Packages:** Methods’ packages can be assessed
  by compliance packages by integrating compliance tests from auditor
  packages into their own testing framework.
- **CI Integration:** complyr should support continuous integration
  (CI), enabling the automation of compliance reports and the showing
  off of badges/stamps/seals of compliance.
- **Function Registration:** Facilitate the registration of functions in
  methods’ packages using dedicated roxygen2 tags for testing with
  compliance packages, e.g., `#' @comply pkg test01`.
- Even though in general it may be difficult to set expectations, in
  specific notable cases it may be possible to set expectations about
  methods’ results very accurately or even exactly. If enough of these
  notable cases are provided, then one might be able to steer an
  implementor towards correctness.

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
rounding_cmpl_test01 <- create_compliance_test(desc = "rounding is compliant", code = {
  # rounds to the even number when equidistant
  testthat::expect_identical(.f(2.5), 2)
  testthat::expect_identical(.f(3.5), 4)
  
  # Otherwise, round to the nearest whole number
  testthat::expect_identical(.f(2.2), 2)
  testthat::expect_identical(.f(2.7), 3)
}, .f = std_rounding)

# `rounding_cmpl_test01()` becomes self-validating if an implementation was
# passed to `.f`
rounding_cmpl_test01()
#> Test passed 🥳
```

Now, let us say that the janitor package wanted to be credited with also
complying with the above rounding definition. Then, janitor authors
would submit their function to the compliance test created above:

``` r
try(rounding_cmpl_test01(janitor::round_half_up))
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
rounding_cmpl_test01 <- create_compliance_test(desc = "rounding is compliant", code = {
  # rounds to the even number when equidistant
  testthat::expect_identical(.f(2.5), 2)
  testthat::expect_identical(.f(3.5), 4)
  
  # Otherwise, round to the nearest whole number
  testthat::expect_identical(.f(2.2), 2)
  testthat::expect_identical(.f(2.7), 3)
}, .f = std_rounding)
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
#' @comply auditor.rounding rounding_cmpl_test01
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
