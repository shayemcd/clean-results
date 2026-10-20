# CR2 small-sample df for emmeans-based rows (contrasts, plotted means,
# brackets). emmeans ignores the df that go with a user `vcov.`, so these
# tests pin every emmeans-based output to clubSandwich's Satterthwaite df.

test_that("adjusted_inference reproduces emmeans p-values and CIs at a fixed df", {
  m <- lm(mpg ~ factor(cyl) + factor(gear), data = mtcars)
  for (adj in c("none", "holm", "bonferroni", "fdr", "sidak", "tukey", "scheffe")) {
    em <- emmeans::emmeans(m, "cyl", df = 7)
    pr <- emmeans::contrast(em, method = "revpairwise", adjust = adj)
    s <- as.data.frame(summary(pr, infer = c(TRUE, TRUE)))
    a <- cleanresults:::adjusted_inference(s$t.ratio, rep(7, nrow(s)), adj, 0.95,
                                           n_means = pr@misc$famSize,
                                           rank = qr(pr@linfct)$rank)
    expect_equal(a$p, s$p.value, tolerance = 1e-6, label = paste("p,", adj))
    expect_equal(s$estimate - a$crit * s$SE, s$lower.CL, tolerance = 1e-6,
                 label = paste("CI,", adj))
  }
})

test_that("lmer contrast rows use the CR2 Satterthwaite df of the coefficient rows", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition,
                       random = ~ (1 | id), contrasts = "condition", contrast_adjust = "none")
  tt <- cr_tidy(res)
  coef_row <- tt[tt$section == "fixed" & tt$term %in% "conditionGain", ]
  ctr_row <- tt[tt$section == "contrast" & tt$level %in% "Gain vs. Control", ]
  expect_equal(ctr_row$estimate, coef_row$estimate, tolerance = 1e-8)
  expect_equal(ctr_row$std.error, coef_row$std.error, tolerance = 1e-8)
  expect_equal(ctr_row$df, coef_row$df, tolerance = 1e-6)
  expect_equal(ctr_row$p.value, coef_row$p.value, tolerance = 1e-6)
})

test_that("clustered lm contrasts match clubSandwich::linear_contrast", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(score = "lm"), predictors = ~ condition, cluster = "id",
                       contrasts = "condition", contrast_adjust = "none")
  m <- lm(score ~ condition, data = d)
  V <- clubSandwich::vcovCR(m, cluster = d$id, type = "CR2")
  L <- rbind(c(0, -1, 1))  # Loss vs. Gain
  lc <- clubSandwich::linear_contrast(m, vcov = V, contrasts = L, test = "Satterthwaite")
  tt <- cr_tidy(res)
  r <- tt[tt$section == "contrast" & tt$level %in% "Loss vs. Gain", ]
  expect_equal(r$estimate, lc$Est, tolerance = 1e-8)
  expect_equal(r$df, lc$df, tolerance = 1e-6)
  expect_equal(r$conf.low, lc$CI_L, tolerance = 1e-6)
})

test_that("plot brackets carry the same adjusted p-values as the table contrasts", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition,
                       random = ~ (1 | id), contrasts = "condition")
  comps <- cleanresults:::model_comparisons(res, "trust", "condition", character(0))
  tt <- cr_tidy(res)
  ctr <- tt[tt$section == "contrast" & !is.na(tt$p.value), ]
  key <- paste(comps$a, "vs.", comps$b)
  expect_equal(comps$p, ctr$p.value[match(key, ctr$level)], tolerance = 1e-6)
})

test_that("plotted model means use CR2 Satterthwaite CIs", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition,
                       random = ~ (1 | id))
  mm <- cleanresults:::model_means(res, "trust", "condition", 0.95)$means
  m <- res$models$trust
  V <- res$vcov$trust
  L <- rbind(c(1, 0, 0), c(1, 1, 0), c(1, 0, 1))
  lc <- clubSandwich::linear_contrast(m, vcov = V, contrasts = L, test = "Satterthwaite")
  expect_equal(mm$mean, lc$Est, tolerance = 1e-8)
  expect_equal(mm$lo, lc$CI_L, tolerance = 1e-6)
  expect_equal(mm$hi, lc$CI_U, tolerance = 1e-6)
})

test_that("rank-deficient lmer: a contrast on a dropped column is not estimable", {
  d <- make_data()
  d$period <- factor(ifelse(d$condition == "Loss", "late", sample(c("early", "mid"), nrow(d), TRUE)))
  res <- suppressWarnings(suppressMessages(
    clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition + period,
                  random = ~ (1 | id), contrasts = "condition", contrast_adjust = "none")))
  tt <- cr_tidy(res)
  ctr <- tt[tt$section == "contrast" & !is.na(tt$level), ]
  expect_gt(nrow(ctr), 0)
  # Loss sits entirely in the "late" period, so contrasts involving Loss are not
  # estimable; Gain vs. Control is, and gets a finite CR2 df.
  gc <- ctr[ctr$level %in% "Gain vs. Control", ]
  expect_true(is.finite(gc$df) && gc$df > 0)
  expect_true(all(is.finite(ctr$df) | is.na(ctr$estimate)))
})

test_that("cr_table notes CR2 tests with Satterthwaite df below 4", {
  d <- make_data()
  d$site <- factor(as.integer(d$id) %% 3)
  few <- clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition,
                       random = ~ (1 | id), cluster = "site")
  expect_match(paste(cr_table(few)$grid$notes, collapse = " "), "df below 4")
  many <- clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition,
                        random = ~ (1 | id))
  expect_no_match(paste(cr_table(many)$grid$notes, collapse = " "), "df below 4")
})
