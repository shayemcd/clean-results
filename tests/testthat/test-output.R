res_fixture <- function() {
  d <- make_data()
  clean_regress(d, dvs = c(trust = "linear", share = "logistic"),
                predictors = ~ condition + age, random = ~ (1 | id),
                contrasts = "condition", labels = c(condition = "Condition"),
                dv_labels = c(trust = "Trust", share = "Shared"))
}

test_that("formatting helpers follow APA conventions", {
  expect_equal(fmt_p(c(0.0004, 0.0321, 0.5)), c("< .001", ".032", ".500"))
  expect_equal(fmt_num(c(-0.001, 1.234)), c("0.00", "1.23"))
  expect_equal(fmt_stars(c(.04, .009, .0001, .2)), c("*", "**", "***", ""))
})

test_that("cr_save writes every format", {
  res <- res_fixture()
  dir <- withr_tempdir()
  for (ext in c("docx", "tex", "html", "csv")) {
    p <- file.path(dir, paste0("t.", ext))
    cr_save(res, p, caption = "Main results", label = "tab:main")
    expect_true(file.exists(p) && file.size(p) > 0)
  }
  tex <- readLines(file.path(dir, "t.tex"))
  expect_true(any(grepl("\\toprule", tex, fixed = TRUE)))
  expect_true(any(grepl("\\label{tab:main}", tex, fixed = TRUE)))
  expect_true(any(grepl("Control (ref.)", tex, fixed = TRUE)))
  expect_false(any(grepl("σ|τ|×|—", tex)))   # pdfLaTeX-safe
  expect_error(cr_save(res, file.path(dir, "t.pdf")), "Unsupported")
})

test_that("Quarto float mode omits the table environment", {
  tex <- cr_latex(res_fixture(), float = FALSE)
  expect_false(grepl("\\begin{table}", tex, fixed = TRUE))
  expect_true(grepl("threeparttable", tex, fixed = TRUE))
})

test_that("both table styles build and print", {
  res <- res_fixture()
  expect_output(print(res), "Trust")
  se <- cr_table(res, style = "se")
  expect_output(print(se), "\\(")
  expect_s3_class(cr_flextable(se), "flextable")
})

test_that("cr_inline reports APA strings", {
  res <- res_fixture()
  s <- cr_inline(res, "trust", "condition", "Gain")
  expect_match(s, "^\\*b\\* = -?[0-9.]+, 95% CI \\[.*\\], \\*p\\* [=<] ")
  s2 <- cr_inline(res, "share", "condition", "Loss vs. Control", format = "plain")
  expect_match(s2, "^OR = ")
  expect_match(cr_inline(res, "trust", "age", stats = "test"), "\\*t\\*\\(")
  expect_error(cr_inline(res, "trust", "condition", "Control"), "reference")
})

test_that("omit hides matched rows from the table and lists them in the note", {
  res <- res_fixture()
  full <- cr_table(res)
  tab <- cr_table(res, omit = "^condition$")
  labs <- function(t) vapply(t$grid$rows, `[[`, "", "label")
  expect_true(any(labs(full) == "Condition"))
  expect_false(any(labs(tab) %in% c("Condition", "Gain", "Loss", "Control (ref.)")))
  expect_true(any(labs(tab) == "Age"))
  expect_true(any(grepl("Also controls for: Condition.", tab$grid$notes, fixed = TRUE)))
  expect_identical(cr_table(res, omit = NULL)$grid, full$grid)
  # the underlying results keep every row
  expect_identical(tab$results$estimates, res$estimates)
  expect_false(any(grepl("Also controls", cr_table(res, omit = "^condition$", auto_note = FALSE)$grid$notes)))
  expect_warning(cr_table(res, omit = "^nomatch$"), "matched no table rows")
  tex <- cr_latex(tab)
  expect_false(grepl("Gain", tex, fixed = TRUE))
})
