test_that("cr_example_data() is the data the tests use and leaves the RNG alone", {
  expect_identical(cr_example_data(), make_data())
  set.seed(1)
  before <- .Random.seed
  d <- cr_example_data(n_id = 10, k = 2, seed = 7)
  expect_identical(.Random.seed, before)
  expect_equal(nrow(d), 20)
  expect_setequal(names(d), c("id", "condition", "age", "female", "trust", "share",
                              "score", "bought"))
  expect_equal(levels(d$condition), c("Control", "Gain", "Loss"))
})

test_that("the documented quick start runs on the example data", {
  d <- cr_example_data()
  res <- clean_regress(d, dvs = c(trust = "linear", share = "logistic"),
                       predictors = ~ condition + age, random = ~ (1 | id),
                       contrasts = "condition")
  expect_s3_class(res, "clean_results")
  expect_true(nrow(cr_tidy(res)) > 0)
})
