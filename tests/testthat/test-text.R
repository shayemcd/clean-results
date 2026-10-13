res_text <- function() {
  d <- make_data()
  clean_regress(d, dvs = c(trust = "linear", share = "logistic"),
                predictors = ~ condition + age, random = ~ (1 | id), contrasts = "condition")
}
person_data <- function() {
  d <- make_data()
  d[!duplicated(d$id), ]
}

test_that("cr_rows gives one schema with groups and d", {
  res <- res_text()
  r <- cr_rows(res)
  expect_true(all(row_cols %in% names(r)))
  g <- r[r$dv == "trust" & r$section == "fixed" & r$level %in% "Gain", ]
  expect_equal(g$group1, "Gain")
  expect_equal(g$group2, "Control")
  vc <- as.data.frame(lme4::VarCorr(res$models$trust))
  expect_equal(g$es, g$estimate / sqrt(sum(vc$vcov)))
  # lm: pooled within-group SD of the raw outcome, unaffected by covariates
  d <- make_data()
  r1 <- clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition + age)
  lv <- cr_find(r1, "trust", "condition", "Gain")
  ns <- table(d$condition); vs <- tapply(d$trust, d$condition, var)
  sp <- sqrt(sum((ns - 1) * vs) / (sum(ns) - length(ns)))
  expect_equal(lv$es, lv$estimate / sp)
  expect_true(all(is.na(r$es[r$dv == "share"])))
})

test_that("cr_inline supports APA, econ, and effect sizes", {
  res <- res_text()
  expect_match(cr_inline(res, "trust", "condition", "Gain"), "^\\*b\\* = ")
  expect_match(cr_inline(res, "trust", "condition", "Gain", style = "econ"),
               "^b = -?[0-9.]+ \\(SE = [0-9.]+, p = 0\\.")
  expect_match(cr_inline(res, "trust", "condition", "Gain", stats = c("est", "es")),
               "\\*d\\* = -?[0-9.]+, 95% CI")
  expect_match(cr_inline(res, "trust", "condition", "Gain", format = "html"), "<i>b</i>")
  expect_error(cr_inline(res, "trust", "condition", "Nope"), "Available")
})

test_that("direction and significance words follow the estimate", {
  res <- res_text()
  b <- cr_rows(res)
  b <- b[b$dv == "trust" & b$variable == "age", ]
  expect_equal(cr_direction(res, "trust", "age"), if (b$estimate > 0) "higher" else "lower")
  expect_equal(cr_sig(res, "trust", "age"), if (b$p.value < .05) "was" else "was not")
})

test_that("cr_expect stops when a claim fails and passes otherwise", {
  res <- res_text()
  r <- cr_find(res, "trust", "age")
  good <- if (r$estimate > 0) "+" else "-"
  bad <- if (good == "+") "-" else "+"
  expect_true(cr_expect(res, "trust", "age", sign = good))
  expect_error(cr_expect(res, "trust", "age", sign = bad, claim = "age effect"), "age effect")
  expect_warning(cr_expect(res, "trust", "age", sign = bad, action = "warning"))
})

test_that("sentences use significance-dependent wording", {
  res <- res_text()
  rows <- cr_rows(res)
  for (i in which(!rows$is_ref & rows$variable != "(Intercept)")) {
    s <- row_sentence(rows[i, ])
    sig <- rows$p.value[i] < .05
    expect_equal(grepl("not significantly|did not differ", s), !sig)
    expect_match(s, "\\.$")
  }
})

test_that("cr_report covers results without repeating contrasts", {
  res <- res_text()
  txt <- as.character(cr_report(res))
  expect_equal(length(gregexpr("Gain and Control|Gain than for Control|Compared with Control, Gain",
                               txt)[[1]]), 2)  # once per outcome
  expect_s3_class(cr_report(res), "cr_text")
  tex <- as.character(cr_text_as(cr_report(res), "latex"))
  expect_match(tex, "\\\\textit\\{b\\}")
  expect_match(tex, "95\\\\% CI")
})

test_that("hypothesis map drives reports, status, and expectations", {
  res <- res_text()
  tt <- cr_ttest(person_data(), "trust", "condition")
  hyp <- cr_hypotheses(
    H1 = cr_h(res, "trust", "condition", "Gain", expect = "+",
              robustness = list("t-test" = cr_h(tt, "trust", "condition", "Gain vs. Control"))),
    H2 = list(cr_h(res, "share", "condition", "Loss", expect = "any"),
              cr_h(res, "share", "age")),
    labels = c(H1 = "Gain raises trust")
  )
  expect_output(print(hyp), "robustness \\(t-test\\)")
  txt <- as.character(cr_report(hyp))
  expect_match(txt, "^\\*\\*H1: Gain raises trust\\.\\*\\*")
  expect_match(txt, "In the robustness check \\(t-test\\)")
  expect_match(txt, "\\*\\*H2\\.\\*\\*")
  r <- cr_find(res, "trust", "condition", "Gain")
  met <- r$estimate > 0 && r$p.value < .05
  if (met) expect_true(cr_expect(hyp)) else expect_error(cr_expect(hyp), "H1")
  expect_error(cr_hypotheses(cr_h(res, "trust", "age")), "Name every")
})

test_that("pairwise t-tests and d match base R", {
  d <- person_data()
  tt <- cr_d(d, "trust", "condition", adjust = "none")
  expect_s3_class(tt, "cr_tests")
  expect_equal(nrow(tt$rows), 3)
  r <- tt$rows[tt$rows$level == "Gain vs. Control", ]
  a <- d$trust[d$condition == "Gain"]; b <- d$trust[d$condition == "Control"]
  base <- t.test(a, b)
  expect_equal(r$statistic, unname(base$statistic))
  expect_equal(r$p.value, base$p.value)
  sp <- sqrt(((length(a) - 1) * var(a) + (length(b) - 1) * var(b)) / (length(a) + length(b) - 2))
  expect_equal(r$es, (mean(a) - mean(b)) / sp)
  expect_true(r$es.low < r$es && r$es < r$es.high)
  ref <- cr_d(d, "trust", "condition", pairs = "ref", ref = "Loss")
  expect_setequal(ref$rows$level, c("Control vs. Loss", "Gain vs. Loss"))
  one <- cr_d(d, "trust", "condition", pairs = "Loss vs. Gain")
  expect_equal(one$rows$level, "Loss vs. Gain")
  holm <- cr_d(d, "trust", "condition")
  expect_equal(holm$rows$p.value, p.adjust(tt$rows$p.value, "holm"))
  g <- cr_d(d, "trust", "condition", effect = "g")
  expect_true(all(abs(g$rows$es) < abs(tt$rows$es)))
  sub <- cr_d(d, "trust", "condition", by = "female")
  expect_equal(nrow(sub$rows), 6)
  expect_match(cr_inline(sub, "trust", "condition", "Gain vs. Control", subgroup = "TRUE"), "\\*t\\*")
})

test_that("paired t-test uses d_z", {
  d <- make_data()
  d$time <- rep(c("pre", "post"), length.out = nrow(d))
  d <- d[!duplicated(paste(d$id, d$time)), ]
  tt <- cr_ttest(d, "trust", "time", id = "id", pairs = "post vs. pre")
  w <- reshape(d[, c("id", "time", "trust")], idvar = "id", timevar = "time", direction = "wide")
  dif <- w$trust.post - w$trust.pre
  expect_equal(tt$rows$es, mean(dif) / sd(dif))
  expect_equal(tt$rows$statistic, unname(t.test(w$trust.post, w$trust.pre, paired = TRUE)$statistic))
})

test_that("d from models filters pairs", {
  res <- res_text()
  all <- cr_d(res)
  expect_equal(nrow(all), 3)
  expect_equal(nrow(cr_d(res, pairs = "ref")), 2)
  expect_equal(cr_d(res, pairs = "Loss vs. Gain")$comparison, "Loss vs. Gain")
})

test_that("chi-square, ANOVA, and correlations report correctly", {
  d <- person_data()
  ch <- cr_chisq(d, "share", "condition", pairs = "all", exact = FALSE)
  ov <- ch$rows[ch$rows$section == "overall", ]
  base <- suppressWarnings(chisq.test(table(d$condition, d$share), correct = FALSE))
  expect_equal(ov$statistic, unname(base$statistic))
  expect_match(cr_inline(ch, "share", "condition"), "χ²\\(2, \\*N\\* = 80\\)")
  expect_match(cr_inline(ch, "share", "condition", "Loss vs. Control", stats = "es"), "\\*h\\*")
  an <- cr_anova(d, "trust", "condition")
  a <- summary(aov(trust ~ condition, d))[[1]]
  expect_equal(an$rows$statistic, a[1, "F value"])
  expect_match(cr_inline(an, "trust", "condition"), "\\*F\\*\\(2, 77\\)")
  expect_match(cr_inline(an, "trust", "condition", style = "apa"), "η² = \\.")
  co <- cr_cor(d, c("trust", "age", "score"))
  expect_equal(nrow(co$rows), 3)
  expect_equal(co$rows$estimate[1], cor(d$trust, d$age))
  expect_identical(cr_inline(co, "trust", "age"), cr_inline(co, "age", "trust"))
  expect_match(cr_inline(co, "trust", "age"), "^\\*r\\*\\(78\\) = -?\\.")
  expect_match(as.character(cr_report(co)), "correlated")
})

test_that("ground truth exports, round-trips, and diffs", {
  res <- res_text()
  hyp <- cr_hypotheses(H1 = cr_h(res, "trust", "condition", "Gain"))
  gt <- cr_ground_truth(res, hyp)
  expect_s3_class(gt, "cr_ground_truth")
  expect_true(all(c("reported", "stars", "source") %in% names(gt$terms)))
  expect_equal(nrow(gt$hypotheses), 1)
  expect_equal(gt$models$model, c("trust", "share"))
  dir <- withr_tempdir()
  f <- file.path(dir, "gt.json")
  cr_ground_truth(res, hyp, path = f)
  expect_true(file.exists(f))
  expect_equal(nrow(cr_diff(f, gt)), 0)
  d2 <- make_data()
  d2$trust <- d2$trust - 2 * (d2$condition == "Gain")
  res <- clean_regress(d2, dvs = c(trust = "linear", share = "logistic"),
                       predictors = ~ condition + age, random = ~ (1 | id),
                       contrasts = "condition")
  expect_message(cr_ground_truth(res, path = f), "changed")
  df <- cr_diff(gt, cr_ground_truth(res))
  expect_true(any(grepl("SIGN FLIP", df$change)))
  md <- file.path(dir, "gt.md")
  cr_save(gt, md)
  expect_match(paste(readLines(md), collapse = "\n"), "## Estimates")
})

test_that("cr_verify finds unmatched and sign-flipped numbers", {
  res <- res_text()
  r <- cr_find(res, "trust", "condition", "Loss vs. Gain")
  good <- fmt_num(r$estimate, 3)
  flipped <- fmt_num(-r$estimate, 3)
  txt <- sprintf("In Study 2 (H1), b = %s, 95%% CI. Also b = %s and t = 12.34.", good, flipped)
  v <- cr_verify(txt, res)
  expect_equal(v$status[v$value == "2"], "label")
  expect_false("1" %in% v$value)  # "H1" is a label, not a number
  expect_equal(v$status[v$value == "95"], "CI level")
  expect_true("matched" %in% v$status[v$value == good])
  expect_equal(v$status[v$value == "12.34"], "unmatched")
  expect_equal(v$status[v$value == flipped], "SIGN DIFFERS")
  expect_error(cr_verify(txt, res, strict = TRUE), "do not match")
  dir <- withr_tempdir()
  q <- file.path(dir, "x.qmd")
  writeLines(c("---", "title: x", "---", "```{r}", "x <- 99.99", "```",
               "Inline `r cr_inline(res, 'trust', 'age')` and typed 77.77."), q)
  vq <- cr_verify(q, res)
  expect_equal(vq$value, "77.77")
})

test_that("text saves to tex, md, html, txt", {
  res <- res_text()
  rep <- cr_report(res, dv = "trust")
  dir <- withr_tempdir()
  for (ext in c("tex", "md", "html", "txt")) {
    p <- file.path(dir, paste0("r.", ext))
    cr_save(rep, p)
    expect_true(file.exists(p))
  }
  expect_match(paste(readLines(file.path(dir, "r.tex")), collapse = ""), "textit")
  expect_match(paste(readLines(file.path(dir, "r.html")), collapse = ""), "<i>b</i>")
})

test_that("tables can show d", {
  res <- res_text()
  tb <- cr_table(res, effect_size = TRUE)
  expect_true("d" %in% tb$grid$sub_head)
  expect_match(paste(tb$grid$notes, collapse = " "), "standardized mean difference")
  expect_match(paste(cr_latex(tb), collapse = "\n"), "\\$d\\$")
})

test_that("d, g, and d_z agree with the effectsize package", {
  skip_if_not_installed("effectsize")
  d <- person_data()
  x <- cr_d(d, "trust", "condition", pairs = "Gain vs. Control", adjust = "none")$rows
  sub <- droplevels(subset(d, condition %in% c("Gain", "Control")))
  sub$condition <- relevel(sub$condition, "Gain")
  e <- effectsize::cohens_d(trust ~ condition, data = sub)
  expect_equal(c(x$es, x$es.low, x$es.high), c(e$Cohens_d, e$CI_low, e$CI_high),
               tolerance = 1e-4)
  g <- cr_d(d, "trust", "condition", pairs = "Gain vs. Control", effect = "g",
            adjust = "none")$rows
  eg <- effectsize::hedges_g(trust ~ condition, data = sub)
  expect_equal(c(g$es, g$es.low, g$es.high), c(eg$Hedges_g, eg$CI_low, eg$CI_high),
               tolerance = 1e-3)   # Hedges' J: approximation vs exact gamma form
  w <- make_data()
  w$time <- rep(c("pre", "post"), length.out = nrow(w))
  w <- w[!duplicated(paste(w$id, w$time)), ]
  z <- cr_ttest(w, "trust", "time", id = "id", pairs = "post vs. pre")$rows
  wide <- reshape(w[, c("id", "time", "trust")], idvar = "id", timevar = "time",
                  direction = "wide")
  ez <- effectsize::cohens_d(wide$trust.post, wide$trust.pre, paired = TRUE)
  expect_equal(c(z$es, z$es.low, z$es.high), c(ez[[1]], ez$CI_low, ez$CI_high),
               tolerance = 1e-4)
})

test_that("CIs are Bonferroni-adjusted when p-values are", {
  d <- person_data()
  adj <- cr_d(d, "trust", "condition")             # 3 pairs, Holm
  raw <- cr_d(d, "trust", "condition", adjust = "none")
  expect_equal(unique(adj$rows$conf_level), 1 - 0.05 / 3)
  expect_true(all(adj$rows$es.high - adj$rows$es.low > raw$rows$es.high - raw$rows$es.low))
  expect_match(cr_inline(adj, "trust", "condition", "Gain vs. Control", stats = "es"),
               "98\\.3% CI")
  expect_match(adj$rows$adjustment[1], "Bonferroni-adjusted for 3 comparisons")
  # a CI that excludes zero always comes with a significant Holm p
  ex <- adj$rows$es.low > 0 | adj$rows$es.high < 0
  expect_true(all(adj$rows$p.value[ex] < .05))
  expect_equal(unique(raw$rows$conf_level), 0.95)
  ch <- cr_chisq(d, "share", "condition", pairs = "all", exact = FALSE)
  expect_equal(unique(ch$rows$conf_level[ch$rows$section == "pairwise"]), 1 - 0.05 / 3)
})

test_that("mixed-model d counts random-slope variance", {
  d <- make_data()
  d$t <- rep(0:3, length.out = nrow(d))
  # the simulated slopes are near-singular, so lme4 warns about convergence
  res <- suppressWarnings(suppressMessages(
    clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition + t,
                  random = ~ (1 + t | id))))
  m <- res$models$trust
  vc <- lme4::VarCorr(m)$id
  zz <- cbind(1, d$t)
  manual <- mean(rowSums((zz %*% vc) * zz)) + sigma(m)^2
  r <- cr_find(res, "trust", "condition", "Gain")
  expect_equal(r$es, r$estimate / sqrt(manual))
})

test_that("regression CIs carry their real level and widen with dv_adjust", {
  d <- make_data()
  base <- clean_regress(d, dvs = c(trust = "linear", score = "linear"),
                        predictors = ~ condition + age, contrasts = "condition")
  # Holm contrasts: emmeans gives Bonferroni CIs, so the text says 98.3%
  expect_match(cr_inline(base, "trust", "condition", "Gain vs. Control"), "98\\.3% CI")
  expect_match(cr_inline(base, "trust", "condition", "Gain"), "95% CI")
  adj <- clean_regress(d, dvs = c(trust = "linear", score = "linear"),
                       predictors = ~ condition + age, contrasts = "condition",
                       dv_adjust = "bonferroni")
  b <- cr_find(base, "trust", "condition", "Gain"); a <- cr_find(adj, "trust", "condition", "Gain")
  expect_equal(a$conf_level, 1 - 0.05 / 2)
  q <- qt(1 - 0.05 / 4, b$df)
  expect_equal(a$conf.high, b$estimate + q * b$std.error)
  ac <- cr_find(adj, "trust", "condition", "Loss vs. Gain")
  expect_equal(ac$conf_level, 1 - 0.05 / 6)
  expect_true(a$es.high - a$es.low > b$es.high - b$es.low)
  # odds ratios rescale on the log scale
  lg <- clean_regress(d, dvs = c(share = "logistic", bought = "logistic"),
                      predictors = ~ condition, dv_adjust = "holm")
  lb <- clean_regress(d, dvs = c(share = "logistic", bought = "logistic"),
                      predictors = ~ condition)
  o <- cr_find(lg, "share", "condition", "Loss"); ob <- cr_find(lb, "share", "condition", "Loss")
  z <- qnorm(1 - 0.05 / 4) / qnorm(0.975)
  expect_equal(log(o$conf.high / o$estimate), z * log(ob$conf.high / ob$estimate))
  expect_match(paste(cr_table(adj)$grid$notes, collapse = " "), "p-values and CIs")
})

test_that("simple-test CIs cover pairs x outcomes when both are adjusted", {
  d <- person_data()
  tt <- cr_d(d, c("trust", "score"), "condition", dv_adjust = "holm")
  expect_equal(unique(tt$rows$conf_level), 1 - 0.05 / 6)
  expect_match(tt$rows$adjustment[1], "6 comparisons")
})
