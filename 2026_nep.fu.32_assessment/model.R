## Run analysis, write model results
## Before: data/nep.fu.32.input.csv
## After:  model/nep.fu.32.fit.rds, model/nep.fu.32.fit.management.rds,
##         model/nep.fu.32.fit.sensitivity.rds

library(icesTAF)
library(dplyr)
library(tidyr)
library(spict)

source("utilities/spict_assessment_functions.R")

mkdir("model")

# ── Settings ────────────────────────────────────────────────────────────────
assessment_year <- 2026
TACyr           <- assessment_year + 1L
n_retro         <- 5L   # retrospective peels

# ── Load prepared data ───────────────────────────────────────────────────────
msg("Model: loading input data")
input_df <- read.taf("data/nep.fu.32.input.csv")

# ── Configure and fit SPiCT ──────────────────────────────────────────────────
msg("Model: configuring SPiCT input")
inp <- configure_spict_inp(input_df)

msg("Model: fitting SPiCT")
fit <- fit_spict_full(inp)
calc.om(fit)

# ── Diagnostics ──────────────────────────────────────────────────────────────
msg("Model: retrospective analysis")
fit <- retro(fit, nretroyear = n_retro)

msg("Model: hindcast")
fit <- hindcast(fit)

msg("Model: initial values sensitivity")
fit <- check.ini(fit, ntrials = 30)

saveRDS(fit, "model/nep.fu.32.fit.rds")

# ── Management scenarios ─────────────────────────────────────────────────────
msg("Model: management scenarios")
man <- fit

man <- add.man.scenario(man, "35th percentile",
  fractiles  = list(catch = 0.35),
  breakpointB = 0.5,
  maninterval = c(TACyr, TACyr + 1),
  maneval     = TACyr + 1,
  limitB      = 0.3)

man <- add.man.scenario(man, "F=Fmsy",
  breakpointB = 0.5,
  maninterval = c(TACyr, TACyr + 1),
  maneval     = TACyr + 1)

man <- add.man.scenario(man, "F=Fsq",
  ffac        = 1,
  maninterval = c(TACyr, TACyr + 1),
  maneval     = TACyr + 1)

man <- add.man.scenario(man, "F=0",
  ffac        = 0,
  maninterval = c(TACyr, TACyr + 1),
  maneval     = TACyr + 1)

last_advice <- 53  # tonnes — update to current TAC if changed
man <- add.man.scenario(man, paste("TAC", last_advice, "t"),
  catchval    = last_advice,
  maninterval = c(TACyr, TACyr + 1),
  maneval     = TACyr + 1)

saveRDS(man, "model/nep.fu.32.fit.management.rds")

# ── Sensitivity runs ─────────────────────────────────────────────────────────
msg("Model: sensitivity analysis")
sensitivity <- list(
  base          = fit,
  no_discards   = {
    inp2 <- inp; inp2$obsC <- input_df$Landings[seq_len(length(inp$obsC))]
    inp2$stdevfacC <- rep(1, length(inp2$obsC))
    fit_spict_full(inp2)
  },
  no_rec        = {
    inp3 <- inp
    inp3$obsC <- (input_df$Landings + input_df$Discards_est)[seq_len(length(inp$obsC))]
    fit_spict_full(inp3)
  },
  no_catchCV    = {
    inp4 <- inp; inp4$stdevfacC <- rep(1, length(inp4$obsC))
    fit_spict_full(inp4)
  },
  no_indexCV    = {
    inp5 <- inp; inp5$stdevfacI <- rep(1, length(inp5$stdevfacI))
    fit_spict_full(inp5)
  }
)

saveRDS(sensitivity, "model/nep.fu.32.fit.sensitivity.rds")

msg("Model: done")

