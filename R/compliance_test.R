create_unit_test_expr <- function(desc, code) {
  # TODO: Except for `.f`, ensure that all objects in `code` are available.
  rlang::expr(testthat::test_that(desc = !!rlang::enexpr(desc), code = !!rlang::enexpr(code)))
}

#' Create a compliance test
#'
#' A compliance test is a unit test whose expectations are defined around
#' a complier function.
#'
#' @param desc Test description.
#' @param code Test code.
#' @param .f A gold standard complier function, i.e. a function that passes
#' the test. This is used as default argument value for the returned function
#' (see Value).
#'
#' @returns A [function] that runs the test. This function takes one single
#' argument, a candidate complier function.
#'
#' @examples
#' # Create a compliance test for a function that implements addition of two
#' # numbers.
#'
#' # Use .f to specify a reference complier function.
#' test_add_two_numbers <-
#'   create_compliance_test("add_two_numbers", code = {
#'     testthat::expect_identical(.f(2, 3), 5)
#'     testthat::expect_identical(.f(-2, 3), 1)
#'   }, .f = \(x, y) x + y)
#'
#' # By default `.f` will take the value of `.f` when the test was created.
#' test_add_two_numbers()
#'
#' # Different but equivalent implementation also complies.
#' test_add_two_numbers(.f = \(x, y) y + x)
#'
#' try(test_add_two_numbers(.f = \(x, y) x + y + 0.1))
#'
#' @export
create_compliance_test <- function(desc, code, .f) {
  # TODO:
  #  - Add assertions for checking that `.f()` usage in `code` is compatible
  #    with formals of passed function object `.f`.
  #  - Add assertions for `desc` and `code`.
  #  - Ponder on injecting `library(testthat)` into `code`.
  fn_arg <- if (missing(.f)) rlang::exprs(.f = ) else rlang::exprs(.f = !!.f)

  rlang::new_function(args = fn_arg,
                      body = create_unit_test_expr(!!rlang::enexpr(desc), !!rlang::enexpr(code)))
}
