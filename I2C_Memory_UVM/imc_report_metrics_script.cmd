load ./cov_work/scope/final
load -refinement refine.vRefine
exec mkdir -p Imc_Report
report_metrics -detail \
  -out Imc_Report/test_final_report_metrics_html \
  -metrics block:expression:toggle:covergroup:assertion:functional \
  -both -exclComments -overwrite -kind expand -aspect both -assertionStatus \
  
    
   
