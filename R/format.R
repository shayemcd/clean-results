# Display grid ---------------------------------------------------------------
#
# One backend-neutral grid (labels, cells, row types, headers, notes) feeds the
# Word, LaTeX, HTML, and text renderers so every format shows the same table.

fmt_num <- function(x, digits = 2) {
  out <- ifelse(is.na(x), "", formatC(x, format = "f", digits = digits))
  zero <- formatC(0, format = "f", digits = digits)
  out[out == paste0("-", zero)] <- zero
  out
}

fmt_p <- function(p, digits = 3, apa = TRUE) {
  thresh <- 10^-digits
  out <- formatC(p, format = "f", digits = digits)
  out[!is.na(p) & p < thresh] <- paste0("< ", formatC(thresh, format = "f", digits = digits))
  if (apa) out <- sub("^(< )?0\\.", "\\1.", out)
  out[is.na(p)] <- ""
  out
}

fmt_stars <- function(p, cuts = c(0.05, 0.01, 0.001)) {
  s <- ifelse(is.na(p), "", ifelse(p < cuts[3], "***", ifelse(p < cuts[2], "**",
         ifelse(p < cuts[1], "*", ""))))
  s
}

fmt_ci <- function(lo, hi, digits = 2) {
  ifelse(is.na(lo), "", sprintf("[%s, %s]", fmt_num(lo, digits), fmt_num(hi, digits)))
}

adjust_name <- function(m) {
  nm <- c(holm = "Holm", hochberg = "Hochberg", hommel = "Hommel", bonferroni = "Bonferroni",
          BH = "Benjamini-Hochberg (FDR)", fdr = "Benjamini-Hochberg (FDR)",
          BY = "Benjamini-Yekutieli", tukey = "Tukey", sidak = "Sidak",
          scheffe = "Scheffe", mvt = "multivariate-t")
  if (m %in% names(nm)) unname(nm[m]) else m
}

build_grid <- function(x, style = c("ci", "se"), digits = 2, p_digits = 3,
                       stars = NULL, fit = TRUE, random = TRUE,
                       show_model_type = TRUE, note = NULL) {
  style <- match.arg(style)
  if (is.null(stars)) stars <- style == "se"
  dvs <- x$settings$dvs
  est <- x$estimates
  per <- if (style == "ci") 3L else 1L
  ncell <- per * length(dvs)
  rows <- list()
  add_row <- function(label, type, indent, cells = rep("", ncell)) {
    rows[[length(rows) + 1]] <<- list(label = label, type = type, indent = indent, cells = cells)
  }
  block <- function(j) ((j - 1) * per + 1):(j * per)

  emit_section <- function(sec) {
    sub <- est[est$section == sec, , drop = FALSE]
    keys <- unique(sub$key)
    for (k in keys) {
      r0 <- sub[sub$key == k, , drop = FALSE][1, ]
      indent <- if (r0$row_type %in% c("level", "ref")) 1L else 0L
      cells <- rep("", ncell); se_cells <- rep("", ncell)
      for (j in seq_along(dvs)) {
        r <- sub[sub$key == k & sub$dv == dvs[j], , drop = FALSE]
        if (!nrow(r)) next
        r <- r[1, ]
        b <- block(j)
        if (r$row_type == "header") next
        if (isTRUE(r$is_ref)) {
          cells[b[1]] <- "\u2014"
          next
        }
        e <- fmt_num(r$estimate, digits)
        if (stars) e <- paste0(e, fmt_stars(r$p.value))
        if (style == "ci") {
          cells[b] <- c(e, fmt_ci(r$conf.low, r$conf.high, digits), fmt_p(r$p.value, p_digits))
        } else {
          cells[b] <- e
          se_cells[b] <- sprintf("(%s)", fmt_num(r$std.error, digits))
        }
      }
      type <- if (r0$row_type == "header") "header" else r0$row_type
      add_row(r0$label, type, indent, cells)
      if (style == "se" && type %in% c("term", "level")) add_row("", "se", indent, se_cells)
    }
  }

  emit_section("fixed")
  if (any(est$section == "contrast")) {
    add_row("Pairwise contrasts", "section", 0L)
    emit_section("contrast")
  }

  emit_stats <- function(which, title) {
    nms <- unique(unlist(lapply(dvs, function(d) names(x$stats[[d]][[which]]))))
    nms <- c(setdiff(nms, "AIC"), intersect(nms, "AIC"))
    if (!length(nms)) return()
    add_row(title, "section", 0L)
    for (nm in nms) {
      cells <- rep("", ncell)
      for (j in seq_along(dvs)) {
        v <- x$stats[[dvs[j]]][[which]][[nm]]
        if (is.null(v) || is.na(v)) next
        integer_stat <- nm == "Observations" || startsWith(nm, "N (")
        cells[block(j)[1]] <- if (integer_stat) format(v, big.mark = ",") else fmt_num(v, digits)
      }
      add_row(nm, "stat", 1L, cells)
    }
  }
  if (random) emit_stats("random", "Random effects")
  if (fit) emit_stats("fit", "Model fit")

  est_lab <- vapply(dvs, function(d) if (x$meta[[d]]$exponentiate) "OR" else "b", "")
  sub_head <- if (style == "ci") {
    unlist(lapply(est_lab, function(l) c(l, sprintf("%g%% CI", 100 * x$settings$conf_level), "p")))
  } else NULL
  mtype <- vapply(dvs, function(d) .type_labels[[x$meta[[d]]$type]], "")
  if (style == "se") mtype <- sprintf("%s (%s)", mtype, est_lab)

  list(
    rows = rows,
    style = style,
    per = per,
    dv_labels = unname(x$settings$dv_labels[dvs]),
    model_types = if (show_model_type) unname(mtype) else NULL,
    sub_head = sub_head,
    notes = table_notes(x, style, stars, note)
  )
}

table_notes <- function(x, style, stars, note = NULL) {
  dvs <- x$settings$dvs
  meta <- x$meta
  lab <- x$settings$dv_labels
  out <- character()

  any_lin <- any(!vapply(meta, `[[`, logical(1), "exponentiate"))
  any_or <- any(vapply(meta, `[[`, logical(1), "exponentiate"))
  est_txt <- c(if (any_lin) "b = unstandardized coefficient", if (any_or) "OR = odds ratio")
  out <- c(out, paste0(paste(est_txt, collapse = "; "), "; CI = confidence interval."))

  se_txt <- vapply(meta, `[[`, character(1), "se_text")
  if (length(unique(se_txt)) == 1) {
    out <- c(out, sprintf("CIs and p-values use %s.", se_txt[1]))
  } else {
    parts <- vapply(unique(se_txt), function(t) {
      sprintf("%s (%s)", t, paste(lab[names(se_txt)[se_txt == t]], collapse = ", "))
    }, character(1))
    out <- c(out, sprintf("CIs and p-values use %s.", paste(parts, collapse = "; ")))
  }
  if (any(vapply(meta, `[[`, logical(1), "robust_fallback"))) {
    out <- c(out, "Cluster-robust SEs are not available for logistic mixed models, so those models use model-based Wald SEs.")
  }
  if (style == "se") {
    out <- c(out, if (any_or) "Standard errors in parentheses (delta-method SEs for odds ratios)."
             else "Standard errors in parentheses.")
  }
  if (any(x$estimates$is_ref, na.rm = TRUE)) {
    out <- c(out, "(ref.) marks the reference category for each factor.")
  }
  if (any(x$estimates$section == "contrast")) {
    adj <- x$settings$contrast_adjust
    adj_txt <- if (adj == "none") "are unadjusted" else
      sprintf("and CIs are %s-adjusted within each factor", adjust_name(adj))
    or_txt <- if (any_or) " (ratios of odds for logistic models)" else ""
    out <- c(out, sprintf(
      "Pairwise contrasts compare estimated marginal means averaged over other predictors%s; their p-values %s.",
      or_txt, adj_txt))
  }
  if (x$settings$dv_adjust != "none" && length(dvs) > 1) {
    terms <- x$settings$dv_adjust_terms
    which_txt <- if (is.null(terms)) "All non-intercept p-values" else
      sprintf("p-values for %s", paste(vapply(terms, pretty_label, "", x$settings$labels),
                                       collapse = ", "))
    out <- c(out, sprintf("%s are additionally %s-adjusted across the %d outcomes.",
                          which_txt, adjust_name(x$settings$dv_adjust), length(dvs)))
  }
  if (stars) out <- c(out, "* p < .05. ** p < .01. *** p < .001.")
  c(paste("Note.", paste(out, collapse = " ")), note)
}

grid_matrix <- function(g) {
  lab <- vapply(g$rows, `[[`, "", "label")
  cells <- do.call(rbind, lapply(g$rows, `[[`, "cells"))
  cbind(lab, cells)
}
