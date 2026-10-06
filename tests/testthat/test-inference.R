test_that("lm uses HC3 robust SEs by default", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(score = "linear"), predictors = ~ condition + age)
  m <- lm(score ~ condition + age, data = d)
  se <- sqrt(diag(sandwich::vcovHC(m, type = "HC3")))
  tt <- cr_tidy(res)
  got <- tt$std.error[match(names(se), tt$term)]
  expect_equal(unname(got), unname(se), tolerance = 1e-8)
  expect_equal(res$meta$score$type, "lm")
})

test_that("logistic reports odds ratios with HC3 CIs", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(bought = "logistic"), predictors = ~ condition)
  m <- glm(bought ~ condition, data = d, family = binomial)
  se <- sqrt(diag(sandwich::vcovHC(m, type = "HC3")))
  tt <- cr_tidy(res)
  r <- tt[tt$term %in% "conditionGain", ]
  expect_equal(r$estimate, unname(exp(coef(m)["conditionGain"])), tolerance = 1e-8)
  expect_equal(r$conf.low, unname(exp(coef(m)["conditionGain"] - qnorm(.975) * se["conditionGain"])),
               tolerance = 1e-8)
  expect_equal(r$estimate_type, "OR")
})

test_that("lmer uses CR2 with Satterthwaite df, clustered by the grouping factor", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition + age,
                       random = ~ (1 | id))
  m <- lmerTest::lmer(trust ~ condition + age + (1 | id), data = d)
  ct <- clubSandwich::coef_test(m, vcov = clubSandwich::vcovCR(m, type = "CR2"),
                                test = "Satterthwaite")
  tt <- cr_tidy(res)
  got <- tt[match(ct$Coef, tt$term), ]
  expect_equal(got$std.error, ct$SE, tolerance = 1e-8)
  expect_equal(got$p.value, ct$p_Satt, tolerance = 1e-8)
  expect_equal(res$meta$trust$type, "lmer")
  expect_equal(res$meta$trust$cluster, "id")
})

test_that("glmer falls back to model-based SEs and says so", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(share = "logistic"), predictors = ~ condition,
                       random = ~ (1 | id))
  expect_true(res$meta$share$robust_fallback)
  expect_match(paste(cr_table(res)$grid$notes, collapse = " "), "not available for logistic mixed")
})

test_that("se = 'model' uses model-based SEs", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(score = "lm"), predictors = ~ condition, se = "model")
  m <- lm(score ~ condition, data = d)
  tt <- cr_tidy(res)
  expect_equal(tt$p.value[tt$term %in% "conditionLoss"],
               summary(m)$coefficients["conditionLoss", 4], tolerance = 1e-10)
})

test_that("explicit cluster on lm uses CR2", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(score = "lm"), predictors = ~ condition, cluster = "id")
  m <- lm(score ~ condition, data = d)
  ct <- clubSandwich::coef_test(m, vcov = clubSandwich::vcovCR(m, cluster = d$id, type = "CR2"),
                                test = "Satterthwaite")
  tt <- cr_tidy(res)
  expect_equal(tt$std.error[match(ct$Coef, tt$term)], ct$SE, tolerance = 1e-8)
})
