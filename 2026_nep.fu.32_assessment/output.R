## Extract results, write TAF output tables
## Before: model/nep.fu.32.fit.rds, model/nep.fu.32.fit.management.rds
## After:  output/tables/nep.fu.32.*.csv

library(icesTAF)
library(dplyr)
library(tidyr)
library(spict)
<<<<<<< HEAD
=======
library(icesRound)
>>>>>>> f540422822232ea97c0379052e17058184756593

source("utilities/spict_assessment_functions.R")

mkdir("output")
mkdir("output/tables")

# ── Load model objects ────────────────────────────────────────────────────────
msg("Output: loading model results")
fit <- readRDS("model/nep.fu.32.fit.rds")
man <- readRDS("model/nep.fu.32.fit.management.rds")

# ── Parameter estimates ───────────────────────────────────────────────────────
msg("Output: parameter estimates")
parest <- as.data.frame(sumspict.parest(fit))
write.taf(parest, file = "nep.fu.32.parest.csv", dir = "output/tables")

# ── State estimates (B/Bmsy, F/Fmsy) ─────────────────────────────────────────
msg("Output: state estimates")
states <- as.data.frame(sumspict.states(fit))
write.taf(states, file = "nep.fu.32.states.csv", dir = "output/tables")

# ── Predicted catches ─────────────────────────────────────────────────────────
preds <- as.data.frame(sumspict.predictions(fit))
write.taf(preds, file = "nep.fu.32.predictions.csv", dir = "output/tables")

# ── Mohn rho (retrospective) ──────────────────────────────────────────────────
msg("Output: Mohn rho")
rho <- mohn(fit$retro)
rho_df <- data.frame(parameter = names(rho), mohn_rho = round(unlist(rho), 4))
write.taf(rho_df, file = "nep.fu.32.mohn.rho.csv", dir = "output/tables")

# ── Risk table ────────────────────────────────────────────────────────────────
msg("Output: risk table")
assessment_year <- 2026
TACyr           <- assessment_year + 1L

risk_yrs <- TACyr:(TACyr + 2L)
risk <- spictRisk(man, bmsyfrac = 0.5, TACyear = risk_yrs)
write.taf(risk, file = "nep.fu.32.risk.csv", dir = "output/tables")

# ── Management table ─────────────────────────────────────────────────────────
msg("Output: management table")
man_table <- make_management_table(man, risk)
write.taf(man_table, file = "nep.fu.32.management.csv", dir = "output/tables")

# ── Kobe / stock-status trajectory ───────────────────────────────────────────
msg("Output: stock status trajectory")
bbmsy <- get.par("logBBmsy", fit) |> as.data.frame() |>
  mutate(Year = as.numeric(rownames(get.par("logBBmsy", fit))),
         variable = "B/Bmsy")
ffmsy <- get.par("logFFmsy", fit) |> as.data.frame() |>
  mutate(Year = as.numeric(rownames(get.par("logFFmsy", fit))),
         variable = "F/Fmsy")
status <- bind_rows(bbmsy, ffmsy)
write.taf(status, file = "nep.fu.32.stock.status.csv", dir = "output/tables")

msg("Output: done")

