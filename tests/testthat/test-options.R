messy_data <- function() {
  d <- make_data()
  d$frame_condition <- factor(c(Control = "ControlGroup", Gain = "GainFraming",
                                Loss = "Loss-Framing")[as.character(d$condition)],
                              levels = c("ControlGroup", "GainFraming", "Loss-Framing"))
  d$age_years <- d$age
  d$trust_score <- d$trust
  d
}
fit_messy <- function(...) {
  clean_regress(messy_data(), dvs = c(trust_score = "linear", bought = "logistic"),
                predictors = ~ frame_condition + age_years, contrasts = "frame_condition", ...)
}
cells <- function(tbl) grid_matrix(tbl$grid)

test_that("clean_label handles camelCase, underscores, dashes, ranges, acronyms", {
  expect_equal(
    clean_label(c("GainFraming", "age_years", "low-income", "18-24", "SES_score",
                  "participant_id", "a-b-c")),
    c("Gain framing", "Age years", "Low income", "18–24", "SES score",
      "Participant ID", "A b c"))
  expect_equal(clean_label("GainFraming", "title"), "Gain Framing")
  expect_equal(clean_label("GainFraming", "asis"), "Gain Framing")
})

test_that("labels are cleaned by default and explicit labels win", {
  res <- fit_messy(labels = c(age_years = "Age"),
                   level_labels = list(frame_condition = c(GainFraming = "Gain frame")))
  m <- cells(cr_table(res))
  expect_true(all(c("Frame condition", "Control group (ref.)", "Gain frame", "Loss framing",
                    "Age", "Gain frame vs. Control group") %in% m[, 1]))
  expect_equal(res$settings$dv_labels[["trust_score"]], "Trust score")
  raw <- fit_messy(clean_labels = FALSE)
  expect_true("GainFraming" %in% cells(cr_table(raw))[, 1])
})

test_that("contrast levels with dashes map back to the right pair", {
  res <- fit_messy()
  tt <- cr_tidy(res)
  expect_equal(tt$level[tt$section == "contrast" & tt$dv == "trust_score"],
               c("GainFraming vs. ControlGroup", "Loss-Framing vs. ControlGroup",
                 "Loss-Framing vs. GainFraming"))
  # inline lookup works with raw or displayed names
  a <- cr_inline(res, "trust_score", "frame_condition", "Loss-Framing vs. GainFraming")
  b <- cr_inline(res, "trust_score", "frame_condition", "Loss framing vs. Gain framing")
  expect_identical(a, b)
})

test_that("uncertainty, p, and layout options shape the columns", {
  res <- fit_messy()
  h <- function(...) cr_table(res, ...)$grid$sub_head[1:3]
  expect_equal(h(), c("b", "95% CI", "p"))
  expect_equal(h(uncertainty = "se"), c("b", "SE", "p"))
  expect_equal(cr_table(res, p = "stars")$grid$sub_head[1:2], c("b", "95% CI"))
  expect_equal(cr_table(res, uncertainty = "se", layout = "inline", p = "stars")$grid$sub_head[1],
               "b (SE)")
  expect_equal(cr_table(res, uncertainty = "none", p = "none")$grid$per, 1L)

  inline <- cells(cr_table(res, uncertainty = "se", layout = "inline", p = "stars"))
  expect_true(any(grepl("^-?[0-9.]+\\**\\s\\([0-9.]+\\)$", inline[, 2])))
  stacked <- cr_table(res, style = "stargazer")
  types <- vapply(stacked$grid$rows, `[[`, "", "type")
  expect_true(any(types == "se"))
  both <- cells(cr_table(res, p = "both"))
  expect_true(any(grepl("\\*", both[, 2])) || any(grepl("\\*", both[, 5])))
})

test_that("contrasts can be included, excluded, or tabled alone", {
  res <- fit_messy()
  lab <- function(t) cells(t)[, 1]
  expect_true("Pairwise contrasts" %in% lab(cr_table(res)))
  ex <- cr_table(res, contrasts = "exclude")
  expect_false(any(grepl(" vs. ", lab(ex))))
  expect_false(grepl("Pairwise contrasts compare", ex$grid$notes[1]))
  only <- cr_contrast_table(res)
  expect_true(all(grepl(" vs. |Frame condition", lab(only))))
  expect_equal(only$grid$sub_head[1], "Diff.")
  expect_false(any(c("Intercept", "Model fit") %in% lab(only)))
  no_ctr <- clean_regress(messy_data(), dvs = c(trust_score = "lm"), predictors = ~ age_years)
  expect_error(cr_contrast_table(no_ctr), "No pairwise contrasts")
})

test_that("every layout compiles to LaTeX without stray unicode", {
  res <- fit_messy()
  for (args in list(list(), list(style = "stargazer"), list(style = "compact"),
                    list(uncertainty = "se", p = "both"), list(contrasts = "only"))) {
    tex <- cr_latex(do.call(cr_table, c(list(res), args)))
    expect_false(grepl("[^\\x01-\\x7F]", tex, perl = TRUE))
  }
})
