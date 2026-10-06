# Map coefficients to display rows -------------------------------------------
#
# Returns one row per displayed line of the fixed-effects block, including a
# header row and a reference-level row for every treatment-coded factor.

fixed_terms <- function(model) {
  tt <- if (inherits(model, "merMod")) stats::terms(model, fixed.only = TRUE) else stats::terms(model)
  tt
}

factor_levels <- function(x) {
  if (is.factor(x)) return(levels(x))
  if (is.logical(x)) return(c("FALSE", "TRUE"))
  if (is.character(x)) return(sort(unique(x)))
  NULL
}

pretty_label <- function(var, labels) {
  if (!is.null(labels) && var %in% names(labels)) unname(labels[[var]]) else var
}

term_map <- function(model, labels = NULL, intercept = TRUE) {
  X <- stats::model.matrix(model)
  assign <- attr(X, "assign")
  cn <- colnames(X)
  tt <- fixed_terms(model)
  labs <- attr(tt, "term.labels")
  mf <- stats::model.frame(model)
  rows <- list()
  add <- function(...) rows[[length(rows) + 1]] <<- data.frame(..., stringsAsFactors = FALSE)

  # factor variables in the model, used to prettify interaction labels
  in_mf <- labs[labs %in% names(mf)]
  lgl_vars <- in_mf[vapply(in_mf, function(l) is.logical(mf[[l]]), logical(1))]
  fac_vars <- setdiff(in_mf[vapply(in_mf, function(l) !is.null(factor_levels(mf[[l]])), logical(1))],
                      lgl_vars)

  if (intercept && any(assign == 0)) {
    add(key = "(Intercept)", term = cn[assign == 0][1], variable = "(Intercept)",
        level = NA_character_, label = "Intercept", row_type = "term", is_ref = FALSE)
  }

  for (i in seq_along(labs)) {
    lab <- labs[i]
    cols <- cn[assign == i]
    levs <- if (lab %in% names(mf)) factor_levels(mf[[lab]]) else NULL
    # TRUE/FALSE predictors read better as one row ("Female") than as a factor
    if (lab %in% names(mf) && is.logical(mf[[lab]])) levs <- NULL
    treatment <- !is.null(levs) &&
      sum(!paste0(lab, levs) %in% cols) == 1 &&
      all(cols %in% paste0(lab, levs))

    if (treatment) {
      vlab <- pretty_label(lab, labels)
      add(key = paste0(lab, "::header"), term = NA_character_, variable = lab,
          level = NA_character_, label = vlab, row_type = "header", is_ref = FALSE)
      for (lv in levs) {
        coef_name <- paste0(lab, lv)
        is_ref <- !coef_name %in% cols
        add(key = paste0(lab, "::", lv),
            term = if (is_ref) NA_character_ else coef_name,
            variable = lab, level = lv,
            label = if (is_ref) paste0(lv, " (ref.)") else lv,
            row_type = if (is_ref) "ref" else "level", is_ref = is_ref)
      }
    } else {
      for (cc in cols) {
        lbl <- if (length(cols) == 1 && !grepl(":", lab)) {
          pretty_label(lab, labels)
        } else {
          interaction_label(cc, fac_vars, labels, lgl_vars)
        }
        add(key = cc, term = cc, variable = lab, level = NA_character_,
            label = lbl, row_type = "term", is_ref = FALSE)
      }
    }
  }
  do.call(rbind, rows)
}

# "condLoss:age" -> "Loss x Age"
interaction_label <- function(coef_name, fac_vars, labels, lgl_vars = character()) {
  parts <- strsplit(coef_name, ":", fixed = TRUE)[[1]]
  pretty <- vapply(parts, function(p) {
    if (p %in% paste0(lgl_vars, "TRUE")) return(pretty_label(sub("TRUE$", "", p), labels))
    hit <- fac_vars[startsWith(p, fac_vars)]
    if (length(hit)) {
      v <- hit[which.max(nchar(hit))]
      return(sub(v, "", p, fixed = TRUE))
    }
    pretty_label(p, labels)
  }, character(1))
  paste(pretty, collapse = " \u00d7 ")
}
