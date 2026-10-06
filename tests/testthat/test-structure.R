test_that("reference categories appear as explicit rows", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(score = "linear"), predictors = ~ condition + female)
  tt <- cr_tidy(res)
  ref <- tt[tt$is_ref, ]
  expect_equal(ref$level, "Control")
  expect_true(all(is.na(ref$estimate)))
  # logical predictors collapse to one row
  expect_true("femaleTRUE" %in% tt$term)
  expect_false(any(tt$variable == "female" & tt$is_ref))
})

test_that("pairwise contrasts are adjusted within factor and match emmeans", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(score = "linear"), predictors = ~ condition,
                       contrasts = "condition", contrast_adjust = "holm")
  m <- lm(score ~ condition, data = d)
  em <- emmeans::emmeans(m, "condition", vcov. = sandwich::vcovHC(m, type = "HC3"))
  s <- summary(emmeans::contrast(em, "revpairwise", adjust = "holm"))
  tt <- cr_tidy(res)
  ct <- tt[tt$section == "contrast", ]
  expect_equal(nrow(ct), 3)
  expect_equal(ct$p.value, s$p.value, tolerance = 1e-8)
  expect_equal(ct$level, c("Gain vs. Control", "Loss vs. Control", "Loss vs. Gain"))
})

test_that("contrasts = TRUE picks factors with 3+ levels only", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(score = "linear"), predictors = ~ condition + female,
                       contrasts = TRUE)
  expect_equal(res$meta$score$contrast_vars, "condition")
})

test_that("across-outcome correction adjusts each row as one family", {
  d <- make_data()
  base <- clean_regress(d, dvs = c(score = "linear", bought = "logistic"),
                        predictors = ~ condition + age)
  adj <- clean_regress(d, dvs = c(score = "linear", bought = "logistic"),
                       predictors = ~ condition + age, dv_adjust = "holm",
                       dv_adjust_terms = "condition")
  b <- cr_tidy(base); a <- cr_tidy(adj)
  raw <- b$p.value[b$term %in% "conditionGain"]
  expect_equal(a$p.value[a$term %in% "conditionGain"], p.adjust(raw, "holm"))
  # untouched rows keep their p-values
  expect_equal(a$p.value[a$term %in% "age"], b$p.value[b$term %in% "age"])
  expect_equal(a$p.within, b$p.value)
})

test_that("both corrections stack: within factor, then across outcomes", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(score = "linear", bought = "logistic"),
                       predictors = ~ condition, contrasts = "condition",
                       contrast_adjust = "holm", dv_adjust = "BH")
  tt <- cr_tidy(res)
  r <- tt[tt$section == "contrast" & tt$level == "Loss vs. Gain", ]
  expect_equal(r$p.value, p.adjust(r$p.within, "BH"))
})

test_that("different predictors per outcome via formulas", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(trust = "linear", bought = "logistic"),
                       predictors = ~ condition, random = ~ (1 | id),
                       formulas = list(bought = bought ~ condition + age))
  expect_equal(res$meta$trust$type, "lmer")
  expect_equal(res$meta$bought$type, "logit")
})

test_that("informative errors", {
  d <- make_data()
  expect_error(clean_regress(d, dvs = "score", predictors = ~ condition), "Name each outcome")
  expect_error(clean_regress(d, dvs = c(score = "lmer"), predictors = ~ condition), "random")
  expect_error(clean_regress(d, dvs = c(score = "tobit"), predictors = ~ condition), "Unknown model type")
  expect_error(clean_regress(d, dvs = c(nope = "lm"), predictors = ~ condition), "not found")
})

test_that("interaction labels are readable", {
  d <- make_data()
  res <- clean_regress(d, dvs = c(score = "lm"), predictors = ~ condition * age,
                       labels = c(age = "Age"))
  expect_true("Loss × Age" %in% cr_tidy(res)$label)
})
