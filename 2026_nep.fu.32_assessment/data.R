## Preprocess data, write TAF data tables
## Before: boot/data/nep.fu.32_total_landings.rds, boot/data/nep.fu.32_survey_index.rds
## After:  data/nep.fu.32.catch.csv, data/nep.fu.32.index.csv, data/nep.fu.32.input.csv

library(icesTAF)
library(dplyr)
library(tidyr)
library(spict)

source("utilities/spict_assessment_functions.R")

mkdir("data")

# ── Settings ────────────────────────────────────────────────────────────────
assessment_year <- 2026
iuuF            <- 1/4   # recreational multiplier (creel -> rec)
survival_rate   <- 0.25  # assumed discard survival rate

# ── Load raw data ────────────────────────────────────────────────────────────
msg("Data: loading landings data")
catch <- readRDS("boot/data/nep.fu.32_total_landings.rds")

msg("Data: loading survey index")
index <- readRDS("boot/data/nep.fu.32_survey_index.rds")

# ── Aggregate catch components ───────────────────────────────────────────────
msg("Data: aggregating catch components")
totcatch <- prepare_catch_components(catch, survival_rate, iuuF)

# ── Combine into model input data frame ─────────────────────────────────────
msg("Data: building model input data frame")
input_df <- prepare_input_df(catch, totcatch, index, assessment_year, iuuF)

# ── Write TAF tables ─────────────────────────────────────────────────────────
write.taf(totcatch,  file = "nep.fu.32.catch.csv",  dir = "data")
write.taf(
  index |> rename(Year = year, Index = index, CV = se),
  file = "nep.fu.32.index.csv", dir = "data", quote = TRUE
)
write.taf(input_df,  file = "nep.fu.32.input.csv",  dir = "data")

msg("Data: done")

