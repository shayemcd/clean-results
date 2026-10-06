# Pairwise contrasts via emmeans ---------------------------------------------
#
# Contrasts compare estimated marginal means (averaged over other factors),
# use the same covariance matrix as the coefficient rows, and are adjusted
# within each factor by `contrast_adjust`. Logistic models report odds ratios.

pairwise_rows <- function(model, type, data, vars, V, se, adjust, conf_level,
                          exponentiate, labels) {
  if (!length(vars)) return(NULL)
  mf <- stats::model.frame(model)
  out <- list()
  for (v in vars) {
    if (!v %in% names(mf) || is.null(factor_levels(mf[[v]]))) next
    em_args <- list(object = model, specs = v, data = data)
    if (se == "robust" && robust_available(type)) em_args$vcov. <- as.matrix(V)
    if (type == "lmer") em_args$lmer.df <- "satterthwaite"
    if (is_logistic(type) && exponentiate) em_args$type <- "response"
    em <- suppressMessages(do.call(emmeans::emmeans, em_args))
    pr <- emmeans::contrast(em, method = "revpairwise", adjust = adjust)
    s <- as.data.frame(summary(pr, infer = c(TRUE, TRUE), level = conf_level))

    est_col <- intersect(c("estimate", "odds.ratio", "ratio"), names(s))[1]
    lcl <- grep("(lower\\.CL|LCL)$", names(s), value = TRUE)[1]
    ucl <- grep("(upper\\.CL|UCL)$", names(s), value = TRUE)[1]
    stat_col <- intersect(c("t.ratio", "z.ratio"), names(s))[1]
    lab <- gsub(" - | / ", " vs. ", as.character(s$contrast))
    lab <- gsub("[()]", "", lab)

    vlab <- pretty_label(v, labels)
    header <- data.frame(
      key = paste0("contrast::", v, "::header"), term = NA_character_, variable = v,
      level = NA_character_, label = vlab, row_type = "header", is_ref = FALSE,
      estimate = NA_real_, std.error = NA_real_, statistic = NA_real_, df = NA_real_,
      p.value = NA_real_, conf.low = NA_real_, conf.high = NA_real_,
      stringsAsFactors = FALSE
    )
    body <- data.frame(
      key = paste0("contrast::", v, "::", lab), term = lab, variable = v,
      level = lab, label = lab, row_type = "level", is_ref = FALSE,
      estimate = s[[est_col]], std.error = s$SE, statistic = s[[stat_col]],
      df = s$df, p.value = s$p.value, conf.low = s[[lcl]], conf.high = s[[ucl]],
      stringsAsFactors = FALSE
    )
    out[[v]] <- rbind(header, body)
  }
  if (!length(out)) return(NULL)
  res <- do.call(rbind, out)
  res$section <- "contrast"
  rownames(res) <- NULL
  res
}
