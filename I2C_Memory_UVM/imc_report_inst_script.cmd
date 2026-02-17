load ./cov_work/scope/final
load -refinement refine.vRefine
exec mkdir -p Imc_Report
report -html -detail \
	-out Imc_Report/test_final_report_inst_html \
	-metrics block:expression:toggle:covergroup:assertion:functional  \
	-overwrite \
	-both \
	-exclComments \
	-kind expand \ 
	-aspect both \ 
	-assertionStatus \
	-allAssertionCounters
