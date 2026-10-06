# Coefficient inference -------------------------------------------------------
#
# Defaults (se = "robust"):
#   lm / logit, no cluster  -> HC3 (sandwich); t (lm) or z (logit)
#   lm / logit, cluster     -> CR2 (clubSandwich) with Satterthwaite df
#   lmer                    -> CR2 clustered on `cluster` (default: first
#                              grouping factor) with Satterthwaite df
#   glmer                   -> model-based Wald z; clubSandwich does not
#                              support glmer, so the table notes the fallback
# se = "model" uses each model's own SEs (Satterthwaite df for lmer).

robust_available <- function(type) type != "glmer"

model_vcov <- function(model, type, se, cluster_vec) {
  if (se == "robust" && robust_available(type)) {
    if (is.null(cluster_vec) && type %in% c("lm", "logit")) {
      return(sandwich::vcovHC(model, type = "HC3"))
    }
    V <- clubSandwich::vcovCR(model, cluster = cluster_vec, type = "CR2")
    return(V)
  }
  as.matrix(stats::vcov(model))
}

infer_coefs <- function(model, type, se, V, conf_level) {
  est <- if (inherits(model, "merMod")) lme4::fixef(model) else stats::coef(model)
  est <- est[!is.na(est)]
  use_robust <- se == "robust" && robust_available(type)

  if (use_robust && inherits(V, "clubSandwich")) {
    ct <- clubSandwich::coef_test(model, vcov = V, test = "Satterthwaite")
    out <- data.frame(
      term = as.character(ct$Coef), estimate = ct$beta, std.error = ct$SE,
      statistic = ct$tstat, df = ct$df_Satt, p.value = ct$p_Satt,
      stringsAsFactors = FALSE
    )
  } else {
    se_vec <- sqrt(diag(as.matrix(V)))[names(est)]
    stat <- est / se_vec
    df <- switch(type,
      lm    = rep(stats::df.residual(model), length(est)),
      lmer  = if (use_robust) rep(Inf, length(est)) else lmer_satt_df(model)[names(est)],
      rep(Inf, length(est))
    )
    p <- 2 * stats::pt(abs(stat), df = df, lower.tail = FALSE)
    out <- data.frame(
      term = names(est), estimate = unname(est), std.error = unname(se_vec),
      statistic = unname(stat), df = unname(df), p.value = unname(p),
      stringsAsFactors = FALSE
    )
  }
  crit <- stats::qt(1 - (1 - conf_level) / 2, df = out$df)
  out$conf.low <- out$estimate - crit * out$std.error
  out$conf.high <- out$estimate + crit * out$std.error
  out
}

lmer_satt_df <- function(model) {
  cf <- summary(model)$coefficients
  if ("df" %in% colnames(cf)) stats::setNames(cf[, "df"], rownames(cf))
  else stats::setNames(rep(Inf, nrow(cf)), rownames(cf))
}

# Exponentiate estimate and CI; SE becomes the delta-method SE of the OR.
exponentiate_rows <- function(df) {
  df$std.error <- exp(df$estimate) * df$std.error
  df$estimate <- exp(df$estimate)
  df$conf.low <- exp(df$conf.low)
  df$conf.high <- exp(df$conf.high)
  df
}

se_method_text <- function(type, se, cluster_name) {
  if (se != "robust") {
    return(if (type == "lmer") "model-based SEs with Satterthwaite df" else "model-based SEs")
  }
  if (type == "glmer") return("model-based (Wald) SEs")
  if (type %in% c("lm", "logit") && is.null(cluster_name)) return("HC3 robust SEs")
  sprintf("CR2 cluster-robust SEs clustered by %s with Satterthwaite df", cluster_name)
}
