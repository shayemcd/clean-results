make_data <- function(seed = 42) {
  set.seed(seed)
  n_id <- 80; k <- 4
  d <- data.frame(
    id = factor(rep(seq_len(n_id), each = k)),
    condition = factor(rep(sample(c("Control", "Gain", "Loss"), n_id, TRUE), each = k),
                       levels = c("Control", "Gain", "Loss")),
    age = rep(round(rnorm(n_id, 40, 12)), each = k),
    female = rep(rbinom(n_id, 1, .5) == 1, each = k)
  )
  u <- rnorm(n_id)[d$id]
  d$trust <- 3 + 0.4 * (d$condition == "Gain") + 0.01 * d$age + u + rnorm(nrow(d))
  d$share <- rbinom(nrow(d), 1, plogis(-0.3 + 0.7 * (d$condition == "Loss") + 0.5 * u))
  d$score <- 2 + 0.5 * (d$condition == "Loss") + rnorm(nrow(d))
  d$bought <- rbinom(nrow(d), 1, plogis(-0.2 + 0.6 * (d$condition == "Gain")))
  d
}

withr_tempdir <- function() {
  p <- tempfile("cr"); dir.create(p); p
}
