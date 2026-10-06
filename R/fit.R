# Model fitting ---------------------------------------------------------------

.type_aliases <- c(
  lm = "lm", ols = "lm",
  logit = "logit", glm = "logit", binomial = "logit",
  lmer = "lmer", lmm = "lmer", mixed_linear = "lmer",
  glmer = "glmer", glmm = "glmer", mixed_logistic = "glmer", mixed_logit = "glmer"
)

.type_labels <- c(
  lm = "Linear", logit = "Logistic",
  lmer = "Linear mixed", glmer = "Logistic mixed"
)

# "linear" and "logistic" resolve to the mixed version when a random term is given.
resolve_type <- function(type, has_random) {
  t <- tolower(type)
  if (t %in% c("linear", "gaussian")) return(if (has_random) "lmer" else "lm")
  if (t %in% c("logistic")) return(if (has_random) "glmer" else "logit")
  out <- unname(.type_aliases[t])
  if (is.na(out)) {
    stop(sprintf(
      "Unknown model type '%s'. Use one of: linear, logistic, lm, logit, lmer, glmer.",
      type
    ), call. = FALSE)
  }
  if (out %in% c("lmer", "glmer") && !has_random) {
    stop(sprintf("Model type '%s' needs a `random` term, e.g. random = ~ (1 | id).", type),
         call. = FALSE)
  }
  out
}

is_mixed <- function(type) type %in% c("lmer", "glmer")
is_logistic <- function(type) type %in% c("logit", "glmer")

rhs_text <- function(x) {
  if (is.null(x)) return(NULL)
  if (inherits(x, "formula")) {
    rhs <- x[[length(x)]]
    return(paste(deparse(rhs, width.cutoff = 500L), collapse = " "))
  }
  if (is.character(x)) return(paste(x, collapse = " + "))
  stop("`predictors` and `random` must be a one-sided formula or a character vector.",
       call. = FALSE)
}

build_formula <- function(dv, predictors, random) {
  rhs <- rhs_text(predictors)
  rnd <- rhs_text(random)
  if (!is.null(rnd)) rhs <- paste(rhs, "+", rnd)
  stats::as.formula(paste(sprintf("`%s`", dv), "~", rhs), env = globalenv())
}

fit_one <- function(type, formula, data, fit_args = list()) {
  args <- c(list(formula = formula, data = data), fit_args)
  switch(type,
    lm    = do.call(stats::lm, args),
    logit = do.call(stats::glm, c(args, list(family = stats::binomial()))),
    lmer  = {
      need_pkg("lme4"); need_pkg("lmerTest")
      do.call(lmerTest::lmer, args)
    },
    glmer = {
      need_pkg("lme4")
      do.call(lme4::glmer, c(args, list(family = stats::binomial())))
    }
  )
}

need_pkg <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(sprintf("Package '%s' is required for this model type. install.packages('%s')",
                 pkg, pkg), call. = FALSE)
  }
}

grouping_factors <- function(model) {
  if (!inherits(model, "merMod")) return(character())
  names(lme4::getME(model, "flist"))
}
