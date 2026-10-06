plot_fixture <- function() {
  d <- make_data()
  res <- clean_regress(d, dvs = c(trust = "linear", share = "logistic"),
                       predictors = ~ condition * female, random = ~ (1 | id),
                       contrasts = "condition")
  list(d = d, p = d[!duplicated(d$id), ], res = res)
}

builds <- function(g) {
  expect_s3_class(g, "ggplot")
  expect_silent(ggplot2::ggplot_build(g))
  invisible(ggplot2::ggplot_build(g))
}

test_that("model means match emmeans and brackets match the table's contrasts", {
  f <- plot_fixture()
  g <- cr_plot_means(f$res, "trust", "condition", comparisons = "all")
  b <- builds(g)
  m <- emmeans::emmeans(f$res$models$trust, ~ condition, data = f$res$data$trust,
                        vcov. = as.matrix(f$res$vcov$trust), lmer.df = "satterthwaite")
  bars <- b$data[[1]]
  expect_equal(sort(bars$y), sort(summary(m)$emmean))
  lab <- b$data[[which(vapply(b$data, function(l) "label" %in% names(l) &&
                                any(l$label %in% c("ns", "*", "**", "***")), logical(1)))[1]]]$label
  tab <- cr_rows(f$res)
  tab <- tab[tab$dv == "trust" & tab$section == "contrast", ]
  want <- ifelse(tab$p.value < .05, fmt_stars(tab$p.value), "ns")
  expect_setequal(lab, want)
  expect_match(attr(g, "cr_note"), "Holm-adjusted")
})

test_that("every plot type builds and stays a ggplot you can add to", {
  f <- plot_fixture()
  builds(cr_plot_means(f$res, "trust", "condition", by = "female", type = "dot", p = "value"))
  builds(cr_plot_means(f$res, "share", "condition", by = "female") + ggplot2::labs(title = "x"))
  builds(cr_plot_means(f$p, "trust", "condition", type = "raincloud"))
  builds(cr_plot_means(f$p, "trust", "condition", type = "box", uncertainty = "sd"))
  builds(cr_plot_means(f$p, "trust", "condition", type = "dot", points = TRUE, style = "psychsci"))
  builds(cr_plot_means(f$d, "trust", "condition", facet = "female"))
  builds(cr_plot_interaction(f$res, "trust", "condition", "female"))
  builds(cr_plot_coef(f$res))
  builds(cr_plot_coef(f$res, dv = "share", contrasts = TRUE, p = "value"))
  builds(cr_plot_hist(f$p, "age"))
  builds(cr_plot_hist(f$p, "age", by = "condition", layout = "overlay"))
  d2 <- f$d; d2$age_c <- d2$age - mean(d2$age)
  r2 <- clean_regress(d2, dvs = c(trust = "linear"), predictors = ~ condition * age_c)
  builds(cr_plot_interaction(r2, "trust", "age_c", "condition"))
  builds(cr_plot_interaction(d2, "trust", "age_c", "condition", uncertainty = "se"))
})

test_that("raw means, SDs, and t-test brackets come from the data", {
  f <- plot_fixture()
  g <- cr_plot_means(f$p, "trust", "condition", uncertainty = "sd")
  b <- builds(g)
  bars <- b$data[[1]]
  want <- tapply(f$p$trust, f$p$condition, mean)
  expect_equal(sort(bars$y), sort(as.vector(want)))
  err <- b$data[[2]]
  sds <- tapply(f$p$trust, f$p$condition, sd)
  expect_equal(sort(err$ymax - err$y), sort(as.vector(sds)), tolerance = 1e-8)
  expect_error(cr_plot_means(f$res, "trust", "condition", uncertainty = "sd"), "raw data")
  expect_error(cr_plot_means(f$res, "trust", "condition", type = "raincloud"), "raw data")
})

test_that("palettes and themes follow the figure guide", {
  expect_equal(cr_palette(2), c("#20A49C", "#C05A3E"))
  expect_equal(cr_palette(3)[1], "#8A9BA8")
  expect_false(any(c("#8A9BA8", "#20A49C") %in% cr_palette(4)) &&
                 all(c("#8A9BA8", "#20A49C") %in% cr_palette(4)))
  expect_error(cr_palette(6), "facet")
  expect_equal(cr_palette(2, "forest_lilac"), unname(cr_palettes$forest_lilac[1:2]))
  for (s in c("nature", "psychsci", "jcr", "polsci")) expect_s3_class(theme_cr(s), "theme")
})

test_that("figures save at journal widths", {
  f <- plot_fixture()
  g <- cr_plot_means(f$res, "trust", "condition")
  dir <- withr_tempdir()
  exts <- c("pdf", "png", if (requireNamespace("svglite", quietly = TRUE)) "svg")
  for (ext in exts) {
    path <- file.path(dir, paste0("fig.", ext))
    cr_save(g, path, width = "1col")
    expect_true(file.exists(path) && file.size(path) > 0)
  }
  expect_error(cr_save(g, file.path(dir, "f.pdf"), width = "3col"), "width")
})
