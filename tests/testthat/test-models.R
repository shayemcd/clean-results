model_data <- function(seed = 3) {
  d <- make_data(seed)
  set.seed(seed)
  d$lik <- pmin(5, pmax(1, round(d$trust)))
  d$days <- rpois(nrow(d), exp(0.5 + 0.4 * (d$condition == "Loss")))
  d$trust_pre <- d$trust + rnorm(nrow(d))
  d
}
one_per_person <- function(d) d[!duplicated(d$id), ]

test_that("ordinal models match ordinal::clm, with robust SEs and polr alias", {
  skip_if_not_installed("ordinal")
  p <- one_per_person(model_data())
  res <- clean_regress(p, dvs = c(lik = "ordinal"), predictors = ~ condition + age)
  m <- ordinal::clm(factor(lik, ordered = TRUE) ~ condition + age, data = p)
  r <- cr_find(res, "lik", "condition", "Gain")
  expect_equal(r$estimate, unname(exp(m$beta["conditionGain"])))
  expect_equal(r$std.error / r$estimate,
               unname(sqrt(diag(sandwich::sandwich(m)))["conditionGain"]))
  expect_equal(r$est_name, "OR")
  expect_false("(Intercept)" %in% res$estimates$key)
  pol <- MASS::polr(factor(lik, ordered = TRUE) ~ condition + age, data = p, Hess = TRUE)
  alias <- clean_regress(p, dvs = c(lik = "polr"), predictors = ~ condition + age)
  expect_equal(log(cr_find(alias, "lik", "condition", "Gain")$estimate),
               unname(coef(pol)["conditionGain"]), tolerance = 1e-4)
  expect_match(paste(cr_table(res)$grid$notes, collapse = " "), "cumulative odds ratio")
  expect_match(cr_sentence(res, "lik", "condition", "Gain"), "Lik|lik")
  mixed <- clean_regress(model_data(), dvs = c(lik = "ordinal"), predictors = ~ condition,
                         random = ~ (1 | id))
  expect_equal(mixed$meta$lik$type, "ordinal_mixed")
  expect_true(mixed$meta$lik$robust_fallback)
  expect_true(any(grepl("^N \\(", names(mixed$stats$lik$random))))
})

test_that("count models report incidence rate ratios", {
  p <- one_per_person(model_data())
  res <- clean_regress(p, dvs = c(days = "poisson"), predictors = ~ condition)
  m <- glm(days ~ condition, family = poisson, data = p)
  r <- cr_find(res, "days", "condition", "Loss")
  expect_equal(r$estimate, unname(exp(coef(m)["conditionLoss"])))
  expect_equal(r$std.error / r$estimate,
               unname(sqrt(diag(sandwich::vcovHC(m, type = "HC3")))["conditionLoss"]))
  expect_equal(r$est_name, "IRR")
  # simulated counts are Poisson, so theta runs off toward infinity: expected warnings
  nb <- suppressWarnings(clean_regress(p, dvs = c(days = "negbin"), predictors = ~ condition))
  mn <- suppressWarnings(MASS::glm.nb(days ~ condition, data = p))
  expect_equal(log(cr_find(nb, "days", "condition", "Loss")$estimate),
               unname(coef(mn)["conditionLoss"]))
  skip_if_not_installed("glmmTMB")
  nbm <- suppressWarnings(clean_regress(model_data(), dvs = c(days = "negbin"),
                                        predictors = ~ condition, random = ~ (1 | id),
                                        contrasts = "condition"))
  expect_equal(nbm$meta$days$type, "negbin_mixed")
  expect_true(any(nbm$estimates$section == "contrast"))
})

test_that("baseline adds a centered covariate; lin interacts it", {
  p <- one_per_person(model_data())
  res <- clean_regress(p, dvs = c(trust = "linear"), predictors = ~ condition,
                       baseline = c(trust = "trust_pre"))
  p$pre_c <- p$trust_pre - mean(p$trust_pre)
  m <- lm(trust ~ condition + pre_c, data = p)
  expect_equal(cr_find(res, "trust", "condition", "Gain")$estimate,
               unname(coef(m)["conditionGain"]))
  expect_true("Baseline (centered)" %in% res$estimates$label)
  lin <- clean_regress(p, dvs = c(trust = "linear"), predictors = ~ condition,
                       baseline = "trust_pre", lin = "condition")
  ml <- lm(trust ~ condition * pre_c, data = p)
  expect_equal(cr_find(lin, "trust", "condition", "Gain")$estimate,
               unname(coef(ml)["conditionGain"]))
  expect_true(any(grepl("× Baseline", lin$estimates$label)))
  expect_error(clean_regress(p, dvs = c(trust = "linear"), predictors = ~ condition,
                             baseline = "trust_pre", lin = "nope"), "lin")
})

test_that("contrast_by gives simple effects within moderator levels", {
  d <- model_data()
  res <- clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition * female,
                       random = ~ (1 | id), contrasts = "condition", contrast_by = "female",
                       se = "model")
  m <- lmerTest::lmer(trust ~ condition * female + (1 | id), data = d)
  em <- emmeans::emmeans(m, ~ condition | female, lmer.df = "satterthwaite")
  ref <- as.data.frame(summary(emmeans::contrast(em, "revpairwise", adjust = "holm"),
                               infer = TRUE))
  got <- cr_find(res, "trust", "condition", "Loss vs. Control", subgroup = "Female: TRUE")
  want <- ref[ref$contrast == "Loss - Control" & ref$female == "TRUE", ]
  expect_equal(got$estimate, want$estimate)
  expect_equal(got$p.value, want$p.value)
  expect_match(cr_sentence(res, "trust", "condition", "Loss vs. Control",
                           subgroup = "Female: TRUE"), "\\(Female: TRUE\\)")
  expect_match(paste(cr_table(res)$grid$notes, collapse = " "), "within each level of female")
  expect_error(clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition,
                             contrasts = "condition", contrast_by = "female"), "contrast_by")
})

test_that("equivalence tests match a hand TOST", {
  p <- one_per_person(model_data())
  res <- clean_regress(p, dvs = c(trust = "linear", share = "logistic"),
                       predictors = ~ condition)
  eq <- cr_equivalence(res, bounds = 0.5, dv = "trust", variable = "condition", level = "Gain")
  r <- cr_find(res, "trust", "condition", "Gain")
  p_lo <- pt((r$estimate + 0.5) / r$std.error, r$df, lower.tail = FALSE)
  p_hi <- pt((r$estimate - 0.5) / r$std.error, r$df)
  expect_equal(eq$rows$p.value, max(p_lo, p_hi))
  expect_equal(eq$rows$conf_level, 0.90)
  expect_match(cr_sentence(eq, "trust", "condition", "Gain"), "equivalence bounds of ±0.50")
  ratio <- cr_equivalence(res, bounds = c(0.5, 2), dv = "share", variable = "condition",
                          level = "Loss")
  o <- cr_find(res, "share", "condition", "Loss")
  z_hi <- (log(o$estimate) - log(2)) / (o$std.error / o$estimate)
  z_lo <- (log(o$estimate) - log(0.5)) / (o$std.error / o$estimate)
  expect_equal(ratio$rows$p.value, max(pnorm(z_hi), pnorm(z_lo, lower.tail = FALSE)))
  expect_error(cr_equivalence(res, bounds = c(-1, 2), dv = "share", variable = "condition",
                              level = "Loss"), "positive")
  tt <- cr_ttest(p, "trust", "condition", adjust = "none")
  dd <- cr_equivalence(tt, bounds = 0.5, scale = "d")
  expect_equal(nrow(dd$rows), 3)
  expect_match(as.character(cr_report(dd)), "in d units")
  hyp <- cr_hypotheses(H0 = cr_h(eq, "trust", "condition", "Gain", expect = "equiv"))
  met <- eq$rows$p.value < .05
  if (met) expect_true(cr_expect(hyp)) else expect_error(cr_expect(hyp), "H0")
})

test_that("Bayesian models report medians, credible intervals, and pd", {
  skip_if(Sys.getenv("CLEANRESULTS_BRMS_TESTS") == "", "set CLEANRESULTS_BRMS_TESTS=1 to run")
  skip_if_not_installed("brms")
  if (requireNamespace("rstan", quietly = TRUE) && !nzchar(rstan::rstan_options("boost_lib")) &&
      dir.exists("/usr/include/boost")) {
    rstan::rstan_options(boost_lib = "/usr/include")
  }
  p <- one_per_person(model_data())
  res <- clean_regress(p, dvs = c(trust = "bayes_linear", share = "bayes_logistic"),
                       predictors = ~ condition, contrasts = "condition",
                       fit_args = list(chains = 2, iter = 1000))
  r <- cr_find(res, "trust", "condition", "Gain")
  draws <- as.matrix(res$models$trust, variable = "b_conditionGain")
  expect_equal(r$estimate, median(draws), tolerance = 1e-6)
  expect_equal(r$conf.low, unname(quantile(draws, .025)), tolerance = 1e-6)
  expect_true(is.na(r$p.value) && r$pd >= .5)
  expect_equal(r$interval, "CrI")
  expect_match(cr_inline(res, "trust", "condition", "Gain"), "95% CrI .*\\*pd\\* = ")
  expect_match(cr_sentence(res, "share", "condition", "Loss"), "odds of share")
  g <- cr_table(res)$grid
  expect_true(all(c("pd", "95% CrI") %in% g$sub_head))
  expect_match(paste(g$notes, collapse = " "), "credible intervals")
  expect_error(cr_equivalence(res, bounds = 0.2, dv = "trust", variable = "condition",
                              level = "Gain"), "ROPE")
})

test_that("model calls refer to the data by name instead of inlining it", {
  res <- clean_regress(make_data(), dvs = c(trust = "linear", share = "logistic"),
                       predictors = ~ condition + age, random = ~ (1 | id))
  for (m in res$models) {
    call_txt <- paste(deparse(stats::getCall(m)), collapse = " ")
    expect_false(grepl("structure(list", call_txt, fixed = TRUE))
    expect_lt(length(capture.output(summary(m))), 100)
  }
  # the data can still be recovered from the model, as emmeans and update() need
  expect_s4_class(emmeans::emmeans(res$models$trust, ~ condition), "emmGrid")
})

test_that("d for logistic and ordinal models is ln(OR) over the latent logistic SD", {
  sd0 <- sqrt(pi^2 / 3)
  p <- one_per_person(model_data())
  # logit: log OR / (pi / sqrt(3)), with the CI moved the same way
  lg <- clean_regress(p, dvs = c(share = "logistic"), predictors = ~ condition + age,
                      contrasts = "condition", contrast_adjust = "none")
  r <- cr_find(lg, "share", "condition", "Loss")
  expect_equal(r$es, log(r$estimate) / sd0)
  expect_equal(c(r$es.low, r$es.high), log(c(r$conf.low, r$conf.high)) / sd0)
  d <- cr_d(lg, dv = "share")
  expect_true(all(c("Loss vs. Control", "Gain vs. Control", "Loss vs. Gain") %in% d$comparison))
  expect_equal(d$d[d$comparison == "Loss vs. Control"], r$es)
  # the reference row, intercept, and continuous terms get no d
  expect_true(is.na(cr_find(lg, "share", "age")$es))
  # unexponentiated estimates are already log odds
  raw <- clean_regress(p, dvs = c(share = "logistic"), predictors = ~ condition, exponentiate = FALSE)
  rr <- cr_find(raw, "share", "condition", "Loss")
  expect_equal(rr$es, rr$estimate / sd0)
  # the table shows a d column and says how it was computed
  tab <- cr_table(lg, effect_size = TRUE)
  expect_true("es" %in% tab$grid$spec$cols)
  expect_match(paste(tab$grid$notes, collapse = " "), "latent")
  # a Bonferroni widening across outcomes keeps d consistent with the estimate's CI
  two <- clean_regress(p, dvs = c(share = "logistic", bought = "logistic"), predictors = ~ condition,
                       dv_adjust = "bonferroni")
  r2 <- cr_find(two, "share", "condition", "Loss")
  expect_equal(c(r2$es, r2$es.low, r2$es.high), log(c(r2$estimate, r2$conf.low, r2$conf.high)) / sd0)
})

test_that("d for mixed logistic models adds the random-effect variance", {
  skip_if_not_installed("lme4")
  m <- clean_regress(model_data(), dvs = c(share = "logistic"), predictors = ~ condition,
                     random = ~ (1 | id))
  r <- cr_find(m, "share", "condition", "Loss")
  fit <- m$models$share
  sdv <- sqrt(pi^2 / 3 + as.numeric(lme4::VarCorr(fit)$id))
  expect_equal(r$es, log(r$estimate) / sdv)
  # smaller than the fixed-effects version, because the latent variance is larger
  expect_lt(abs(r$es), abs(log(r$estimate)) / sqrt(pi^2 / 3))
})

test_that("d for ordinal models, fixed and mixed (with a random slope)", {
  skip_if_not_installed("ordinal")
  sd0 <- sqrt(pi^2 / 3)
  p <- one_per_person(model_data())
  o <- clean_regress(p, dvs = c(lik = "ordinal"), predictors = ~ condition + age)
  r <- cr_find(o, "lik", "condition", "Gain")
  expect_equal(r$es, log(r$estimate) / sd0)
  dd <- model_data()
  dd$x <- as.numeric(scale(dd$age))
  om <- suppressWarnings(clean_regress(dd, dvs = c(lik = "ordinal"), predictors = ~ condition + x,
                                       random = ~ (1 + x | id)))
  fit <- om$models$lik
  Sigma <- as.matrix(ordinal::VarCorr(fit)$id)
  Z <- cbind(`(Intercept)` = 1, x = dd$x[stats::complete.cases(dd[c("lik", "condition", "x", "id")])])
  extra <- mean(rowSums((Z %*% Sigma[colnames(Z), colnames(Z)]) * Z))
  rm_ <- cr_find(om, "lik", "condition", "Gain")
  expect_equal(rm_$es, log(rm_$estimate) / sqrt(pi^2 / 3 + extra), tolerance = 1e-6)
})

test_that("d is left empty for models without a defined standardized difference", {
  p <- one_per_person(model_data())
  pm <- clean_regress(p, dvs = c(days = "poisson"), predictors = ~ condition)
  expect_true(all(is.na(pm$estimates$es)))
  expect_error(cr_d(pm), "linear, logistic, and ordinal")
})

test_that("the d note describes only the kinds of d that are shown, and travels with cr_d()", {
  p <- one_per_person(model_data())
  lg <- clean_regress(p, dvs = c(share = "logistic"), predictors = ~ condition)
  note <- cr_d_note(lg)
  expect_length(note, 1)
  expect_match(note, "Chinn, 2000", fixed = TRUE)
  expect_match(note, "approximation")
  expect_false(grepl("random-effect", note))             # fixed-effects logit: no mixed-model clause
  expect_false(grepl("pooled within-group", note))       # and no linear-model sentence
  expect_equal(attr(cr_d(lg, dv = "share", pairs = "ref"), "note"), note)
  # a table note appears only when the d column is requested
  expect_false(grepl("Chinn", paste(cr_table(lg)$grid$notes, collapse = " ")))
  expect_match(paste(cr_table(lg, effect_size = TRUE)$grid$notes, collapse = " "), "Chinn")
  # linear and logistic together: both sentences; the dv filter narrows it
  both <- clean_regress(p, dvs = c(trust = "linear", share = "logistic"), predictors = ~ condition)
  expect_match(cr_d_note(both), "pooled within-group")
  expect_match(cr_d_note(both), "Chinn")
  expect_false(grepl("Chinn", cr_d_note(both, dv = "trust")))
  # no d, no note
  num <- clean_regress(p, dvs = c(trust = "linear"), predictors = ~ age)
  expect_length(cr_d_note(num), 0)
  expect_error(cr_d_note(mtcars), "clean_results")
  skip_if_not_installed("lme4")
  mm <- clean_regress(model_data(), dvs = c(share = "logistic"), predictors = ~ condition, random = ~ (1 | id))
  expect_match(cr_d_note(mm), "random-effect variance for mixed models")
})
