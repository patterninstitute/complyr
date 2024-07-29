subst <- function(expr, env = rlang::caller_env()) {
  eval(rlang::expr(substitute(!!expr, !!env)))
}

subst2 <- function(expr, env = rlang::caller_env()) {
  expr <- rlang::enexpr(expr)
  eval(rlang::expr(substitute(!!expr, !!env)))
}

`%/.%` <- subst2
