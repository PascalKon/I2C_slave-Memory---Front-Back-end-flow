load ./cov_work/scope/final
load -refinement refine.vRefine
exec mkdir -p Imc_Report
report -html -detail \
	-out Imc_Report/test_final_report_type_html \
	-metrics block:expression:toggle:covergroup:assertion:functional  \
	-type * \
	-overwrite \
	-both \
	-exclComments \
	-kind expand \ 
	-aspect both \ 
	-assertionStatus \
	-allAssertionCounters
	

