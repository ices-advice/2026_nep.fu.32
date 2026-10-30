## Development worksheet — run interactively to explore/debug each TAF step.
## This file is NOT part of the reproducible TAF workflow; do not source() it.

# ── Step-by-step execution ────────────────────────────────────────────────────
# 0. Set working directory to the TAF root
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# 1. Bootstrap (download / copy boot/data/)
library(icesTAF)
# taf.bootstrap()   # only needed if boot/data/ is empty

# 2. Data preparation
source("data.R")

# 3. Model fitting (slow — consider loading saved RDS instead)
source("model.R")
# fit <- readRDS("model/nep.fu.32.fit.rds")  # quick reload

# 4. Output extraction
source("output.R")

# 5. Report rendering
source("report.R")

# ── Quick diagnostics ─────────────────────────────────────────────────────────
library(spict)
fit <- readRDS("model/nep.fu.32.fit.rds")
plotspict.bbmsy(fit)
plotspict.ffmsy(fit)
plotspict.catch(fit)

man <- readRDS("model/nep.fu.32.fit.management.rds")
sumspict.manage(man)

