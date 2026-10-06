#' Fit regressions for one or more outcomes and collect publication-ready results
#'
#' Fits one model per dependent variable (linear, logistic, linear mixed, or
#' logistic mixed), computes robust or model-based inference, keeps reference
#' categories as explicit rows, optionally adds pairwise contrasts, and applies
#' multiple-comparison corrections within factors and/or across outcomes.
#' Render the result with [cr_table()] (or just print it in a Quarto chunk),
#' save it with [cr_save()], and cite numbers in text with [cr_inline()].
#'
#' @param data A data frame.
#' @param dvs Named character vector mapping each outcome to a model type, e.g.
#'   `c(trust = "linear", donated = "logistic")`. Types: `"linear"`,
#'   `"logistic"` (mixed automatically when `random` is given), or explicit
#'   `"lm"`, `"logit"`, `"lmer"`, `"glmer"`. An unnamed vector of outcome names
#'   is allowed when `type` is supplied.
#' @param predictors One-sided formula (`~ condition + age`) or character
#'   vector of predictor terms shared by all outcomes.
#' @param random Random-effects term(s) for mixed models, e.g. `~ (1 | id)`.
#' @param formulas Optional named list of full formulas that override
#'   `predictors`/`random` for specific outcomes.
#' @param type Model type used for every outcome when `dvs` is unnamed.
#' @param cluster Column name to cluster robust SEs on. Defaults to the first
#'   grouping factor for mixed models and to none (HC3) for lm/logit.
#' @param se `"robust"` (default; HC3, or CR2 when clustered or mixed) or `"model"`.
#' @param contrasts Pairwise contrasts: `NULL` (none), `TRUE` (every factor
#'   predictor with 3+ levels), or a character vector of factor names.
#' @param contrast_adjust Correction across the pairwise contrasts of each factor
#'   (any `emmeans` adjust method: `"holm"`, `"tukey"`, `"bonferroni"`,
#'   `"fdr"`, `"none"`, ...).
#' @param dv_adjust Correction across outcomes, applied to each row separately
#'   (the same coefficient or contrast across all outcomes is one family). Any
#'   [stats::p.adjust()] method; `"none"` by default.
#' @param dv_adjust_terms Variables whose rows get the across-outcome
#'   correction. `NULL` means every non-intercept row.
#' @param exponentiate Report odds ratios for logistic models.
#' @param conf_level Confidence level.
#' @param labels Named vector of display labels for predictors.
#' @param dv_labels Named vector of display labels for outcomes.
#' @param intercept Show the intercept row.
#' @param fit_args List of extra arguments passed to every model fitter, e.g.
#'   `list(control = lme4::glmerControl(optimizer = "bobyqa"))`.
#'
#' @return An object of class `clean_results`.
#' @export
#' @examples
#' \dontrun{
#' res <- clean_regress(
#'   d,
#'   dvs = c(trust = "linear", donated = "logistic"),
#'   predictors = ~ condition + age,
#'   random = ~ (1 | id),
#'   contrasts = "condition",
#'   dv_adjust = "holm"
#' )
#' res
#' cr_save(res, "tables/table2.docx")
#' }
clean_regress <- function(data, dvs, predictors = NULL, random = NULL, formulas = NULL,
                          type = NULL, cluster = NULL, se = c("robust", "model"),
                          contrasts = NULL, contrast_adjust = "holm",
                          dv_adjust = "none", dv_adjust_terms = NULL,
                          exponentiate = TRUE, conf_level = 0.95,
                          labels = NULL, dv_labels = NULL, intercept = TRUE,
                          fit_args = list()) {
  se <- match.arg(se)
  if (!is.data.frame(data)) stop("`data` must be a data frame.", call. = FALSE)
  dv_adjust <- match.arg(dv_adjust, stats::p.adjust.methods)
  dvs <- normalize_dvs(dvs, type)
  if (is.null(predictors) && is.null(formulas)) {
    stop("Supply `predictors` (or per-outcome `formulas`).", call. = FALSE)
  }
  if (!is.null(cluster) && !cluster %in% names(data)) {
    stop(sprintf("Cluster column '%s' not found in `data`.", cluster), call. = FALSE)
  }

  models <- list(); stats_list <- list(); est_list <- list(); meta <- list()
  for (dv in names(dvs)) {
    f <- if (!is.null(formulas[[dv]])) formulas[[dv]] else build_formula(dv, predictors, random)
    has_random <- any(grepl("|", deparse(f, width.cutoff = 500L), fixed = TRUE))
    mtype <- resolve_type(dvs[[dv]], has_random)

    vars <- unique(c(all.vars(f), cluster))
    missing_vars <- setdiff(vars, names(data))
    if (length(missing_vars)) {
      stop(sprintf("Variables not found in `data`: %s", paste(missing_vars, collapse = ", ")),
           call. = FALSE)
    }
    d_i <- data[stats::complete.cases(data[vars]), , drop = FALSE]
    m <- fit_one(mtype, f, d_i, fit_args)

    cluster_name <- cluster
    if (is.null(cluster_name) && is_mixed(mtype)) cluster_name <- grouping_factors(m)[1]
    cluster_vec <- if (!is.null(cluster_name)) d_i[[cluster_name]] else NULL

    V <- model_vcov(m, mtype, se, cluster_vec)
    coefs <- infer_coefs(m, mtype, se, V, conf_level)
    map <- term_map(m, labels = labels, intercept = intercept)
    fixed <- merge(map, coefs, by = "term", all.x = TRUE, sort = FALSE)
    fixed <- fixed[match(map$key, fixed$key), , drop = FALSE]
    fixed$section <- "fixed"
    exp_i <- exponentiate && is_logistic(mtype)
    if (exp_i) fixed <- exponentiate_rows(fixed)

    cvars <- contrast_vars(contrasts, m)
    ctr <- pairwise_rows(m, mtype, d_i, cvars, V, se, contrast_adjust, conf_level,
                         exp_i, labels)
    est <- rbind(fixed[, names(ctr %||% fixed)], ctr)
    est$dv <- dv
    est$p.within <- est$p.value
    est_list[[dv]] <- est

    models[[dv]] <- m
    stats_list[[dv]] <- fit_stats(m, mtype)
    meta[[dv]] <- list(
      type = mtype, exponentiate = exp_i, cluster = cluster_name,
      se_text = se_method_text(mtype, se, cluster_name),
      robust_fallback = se == "robust" && !robust_available(mtype),
      contrast_vars = cvars, n = stats::nobs(m)
    )
  }

  estimates <- do.call(rbind, est_list)
  rownames(estimates) <- NULL
  estimates <- adjust_across_dvs(estimates, dv_adjust, dv_adjust_terms, length(dvs))

  dv_lab <- stats::setNames(names(dvs), names(dvs))
  if (!is.null(dv_labels)) dv_lab[intersect(names(dv_labels), names(dvs))] <-
    dv_labels[intersect(names(dv_labels), names(dvs))]

  structure(list(
    estimates = estimates,
    models = models,
    stats = stats_list,
    meta = meta,
    settings = list(
      dvs = names(dvs), dv_labels = dv_lab, se = se, conf_level = conf_level,
      contrast_adjust = contrast_adjust, dv_adjust = dv_adjust,
      dv_adjust_terms = dv_adjust_terms, labels = labels
    )
  ), class = "clean_results")
}

normalize_dvs <- function(dvs, type) {
  if (is.list(dvs)) dvs <- unlist(dvs)
  if (is.null(names(dvs)) || any(names(dvs) == "")) {
    if (is.null(type)) {
      stop("Name each outcome with its model type, e.g. dvs = c(trust = \"linear\"), ",
           "or supply `type`.", call. = FALSE)
    }
    dvs <- stats::setNames(rep(type, length(dvs)), dvs)
  }
  dvs
}

contrast_vars <- function(contrasts, model) {
  if (is.null(contrasts) || isFALSE(contrasts)) return(character())
  mf <- stats::model.frame(model)
  labs <- attr(fixed_terms(model), "term.labels")
  if (isTRUE(contrasts)) {
    return(labs[vapply(labs, function(l) {
      l %in% names(mf) && length(factor_levels(mf[[l]])) >= 3
    }, logical(1))])
  }
  bad <- setdiff(contrasts, labs)
  if (length(bad)) {
    warning(sprintf("Contrast variable(s) not in model, skipped: %s", paste(bad, collapse = ", ")),
            call. = FALSE)
  }
  intersect(contrasts, labs)
}

# Each displayed row (same key and section) across outcomes is one family.
adjust_across_dvs <- function(est, method, terms, n_dv) {
  est$p.value <- est$p.within
  est$dv_adjusted <- FALSE
  if (method == "none" || n_dv < 2) return(est)
  eligible <- !is.na(est$p.within) & est$key != "(Intercept)"
  if (!is.null(terms)) eligible <- eligible & est$variable %in% terms
  grp <- paste(est$section, est$key, sep = "|")
  for (g in unique(grp[eligible])) {
    idx <- which(grp == g & eligible)
    est$p.value[idx] <- stats::p.adjust(est$p.within[idx], method = method)
  }
  est$dv_adjusted <- eligible
  est
}

`%||%` <- function(a, b) if (is.null(a)) b else a
