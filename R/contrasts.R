# Pairwise contrasts via emmeans ---------------------------------------------
#
# Contrasts compare estimated marginal means (averaged over other factors),
# use the same covariance matrix as the coefficient rows, and are adjusted
# within each factor by `contrast_adjust`. Logistic models report odds ratios.

pairwise_rows <- function(model, type, data, vars, V, se, adjust, conf_level,
                          exponentiate, lab_fun = make_labeller()) {
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
    pairs <- match_pairs(as.character(s$contrast), as.character(em@levels[[v]]))
    raw <- paste(pairs$a, "vs.", pairs$b)
    lab <- paste(vapply(pairs$a, function(l) lab_fun$level(v, l), ""), "vs.",
                 vapply(pairs$b, function(l) lab_fun$level(v, l), ""))

    vlab <- lab_fun$var(v)
    header <- data.frame(
      key = paste0("contrast::", v, "::header"), term = NA_character_, variable = v,
      level = NA_character_, label = vlab, row_type = "header", is_ref = FALSE,
      estimate = NA_real_, std.error = NA_real_, statistic = NA_real_, df = NA_real_,
      p.value = NA_real_, conf.low = NA_real_, conf.high = NA_real_,
      stringsAsFactors = FALSE
    )
    body <- data.frame(
      key = paste0("contrast::", v, "::", raw), term = raw, variable = v,
      level = raw, label = lab, row_type = "level", is_ref = FALSE,
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

# Recover which two levels each emmeans contrast compares. emmeans writes
# "A - B", or "(A) - (B)" when a level has spaces or symbols, and "/" for ratios.
match_pairs <- function(contrast, levels) {
  wrap <- function(l) if (grepl("^[[:alnum:]_.]+$", l)) l else paste0("(", l, ")")
  grid <- expand.grid(a = levels, b = levels, stringsAsFactors = FALSE)
  grid <- grid[grid$a != grid$b, ]
  keys <- unlist(lapply(c(" - ", " / "), function(op) {
    stats::setNames(seq_len(nrow(grid)),
                    paste0(vapply(grid$a, wrap, ""), op, vapply(grid$b, wrap, "")))
  }))
  keys2 <- stats::setNames(keys, gsub("[()]", "", names(keys)))
  idx <- keys[contrast]
  miss <- is.na(idx)
  idx[miss] <- keys2[gsub("[()]", "", contrast[miss])]
  if (anyNA(idx)) {
    stop("Could not match contrast labels to factor levels: ",
         paste(contrast[is.na(idx)], collapse = ", "), call. = FALSE)
  }
  grid[idx, ]
}
