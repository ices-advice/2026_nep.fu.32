## Render assessment report
## Before: output/tables/, model/nep.fu.32.fit.rds
## After:  report/nep.fu.32.assessment.html

library(icesTAF)
library(quarto)

mkdir("report")

# Render the main assessment QMD from the parent project.
# The QMD reads data from assessment/2026/ and saves outputs back there;
# it does not re-run SPiCT when load_from_files = TRUE.
msg("Report: rendering SPiCT assessment document")
quarto::quarto_render(
  input       = "../5_SPiCT_assessment_tbc.qmd",
  output_file = "nep.fu.32.2026.assessment.html",
  output_dir  = "report"
)

msg("Report: done")

