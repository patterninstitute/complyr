create_unit_test_expr <- function(desc, code, env = rlang::caller_env()) {
  # TODO: Except for `.f`, ensure that all objects in `code` are available.
  #expr <- rlang::expr(testthat::test_that(desc = !!rlang::enexpr(desc), code = !!rlang::enexpr(code)))
  expr <- rlang::call2(rlang::expr(testthat::test_that), rlang::enexpr(desc), rlang::enexpr(code))
  # rlang::inject(rlang::expr(!!expr), env = env)
  subst(expr, env = env)
}

#' Create a compliance test
#'
#' A compliance test is a unit test whose expectations are defined around
#' a compliant function. Use the pronoun `.f` in test `code` to refer
#' to this function.
#'
#' @param desc Compliance test description.
#' @param code Compliance test code.
#' @param ref_fn A reference implementation, i.e. a function that passes
#' the test. This is used as default argument value for the returned function
#' (see Value).
#' @param opts Optional arguments for tuning the test behavior.
#'
#' @returns A [function] that runs the test. The first argument is a function
#' candidate at complying with the test. Following arguments are those
#' passed in `opts`.
#'
#' @export
new_compliance_test <- function(desc, code, ref_fn, opts = list()) {
  # TODO:
  #  - Add assertions for checking that `ref_fn()` usage in `code` is compatible
  #    with formals of passed function object `ref_fn`.
  #  - Add assertions for `desc` and `code`.
  #  - Ponder on injecting `library(testthat)` into `code`.
  test_args <- if (missing(ref_fn)) {
    rlang::exprs(.f = )
  }
  else {
    rlang::exprs(.f = !!ref_fn, !!!opts)
  }

  rlang::new_function(args = test_args,
                      body = create_unit_test_expr(!!rlang::enexpr(desc), !!rlang::enexpr(code)))
}
