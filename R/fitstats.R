# Model-level statistics -----------------------------------------------------
#
# Mixed models: random-effect variances, adjusted ICC, and Nakagawa marginal /
# conditional R2 (random-intercept models; slopes leave ICC and R2 blank).
# Logistic mixed models use the latent-scale residual variance pi^2 / 3.

fit_stats <- function(model, type, lab_fun = make_labeller(clean = FALSE)) {
  out <- list(random = list(), fit = list())
  out$fit[["Observations"]] <- stats::nobs(model)

  if (is_mixed(type)) {
    vc <- as.data.frame(lme4::VarCorr(model))
    vc <- vc[is.na(vc$var2) & vc$grp != "Residual", , drop = FALSE]
    sigma2 <- if (type == "lmer") stats::sigma(model)^2 else pi^2 / 3
    out$random[["\u03c3\u00b2"]] <- sigma2
    for (i in seq_len(nrow(vc))) {
      nm <- if (vc$var1[i] == "(Intercept)") {
        sprintf("\u03c4\u2080\u2080 (%s)", lab_fun$var(vc$grp[i]))
      } else {
        sprintf("\u03c4 (%s: %s)", lab_fun$var(vc$grp[i]), lab_fun$var(vc$var1[i]))
      }
      out$random[[nm]] <- vc$vcov[i]
    }
    intercept_only <- all(vc$var1 == "(Intercept)")
    tau <- sum(vc$vcov)
    if (intercept_only) {
      out$random[["ICC"]] <- tau / (tau + sigma2)
    }
    ng <- lme4::ngrps(model)
    for (g in names(ng)) out$random[[sprintf("N (%s)", lab_fun$var(g))]] <- unname(ng[[g]])

    if (intercept_only) {
      X <- lme4::getME(model, "X")
      var_f <- stats::var(as.vector(X %*% lme4::fixef(model)))
      total <- var_f + tau + sigma2
      out$fit[["Marginal R\u00b2"]] <- var_f / total
      out$fit[["Conditional R\u00b2"]] <- (var_f + tau) / total
    }
  } else if (type == "lm") {
    out$fit[["R\u00b2"]] <- summary(model)$r.squared
  } else if (type == "logit") {
    p <- stats::fitted(model)
    y <- stats::model.response(stats::model.frame(model))
    if (is.factor(y)) y <- as.numeric(y != levels(y)[1])
    out$fit[["Tjur R\u00b2"]] <- mean(p[y == 1]) - mean(p[y == 0])
  }
  out$fit[["AIC"]] <- stats::AIC(model)
  out
}
