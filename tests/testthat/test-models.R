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
