#I2C_Memory_AMS_FLOW

#----TECH LEF-----
# Tech lef_dir /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/xh018/cadence/v7_0/techLEF/v7_0_3/

#file xh018_xx43_HD_MET4_METMID_METTHK.lef

#----QRC FILE----
#qrc file_dir /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/QRC_assura/v7_0_1/XH018_1143/QRC-Typ/

#file qrcTechFile


#----LEF FILES----
#D_CELLS_HD lef_dir /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/LEF/v3_0_0/

#files xh018_D_CELLS_HD.lef - xh018_xx43_MET4_METMID_METTHK_D_CELLS_HD_mprobe.lef

#----------------
#IO_CELLS_3V lef_dir /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/IO_CELLS_3V/v2_1/LEF/v2_1_0/

#file xh018_xx43_MET4_METMID_METTHK_IO_CELLS_3V.lef

#--------


# ==============================================================================
#============================START_OF_COMMANDS==================================
# ==============================================================================

#set_db message_level debug
#set_db log_verbosity high

-verbose

# ==============================================================================
#===============================SETS============================================
# ==============================================================================

#setup path for library
set_db init_lib_search_path { \
	/mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/liberty_LPMOS/v3_0_0/PVT_1_80V_range/ \
	/mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/IO_CELLS_3V/v2_1/liberty_LPMOS/v2_1_0/PVT_1_80V_3_30V_range/ }
#end

#setups path for reports
set REPORTS_DIR /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Reports
#end

#setups path for Output files to Innovus
set OUT_TO_INVS_DIR /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus
#end

#setup top module
set top_module  "I2CAndMemory"
#end

#setup script path
set_db script_search_path /home/p/paschalk/Desktop/I2C_Memory/flows/genus/
#end

#set verification dir
set_db verification_directory ${REPORTS_DIR}/fv/
#end

#==============================================================================
#===============================Libraries_Setup================================
#==============================================================================

set_db lef_library { /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/xh018/cadence/v7_0/techLEF/v7_0_3/xh018_xx43_HD_MET4_METMID_METTHK.lef \
		     /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/LEF/v3_0_0/xh018_D_CELLS_HD.lef \
		     /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/LEF/v3_0_0/xh018_xx43_MET4_METMID_METTHK_D_CELLS_HD_mprobe.lef \
		     /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/IO_CELLS_3V/v2_1/LEF/v2_1_0/xh018_xx43_MET4_METMID_METTHK_IO_CELLS_3V.lef }
#end

#==============================================================================
#===============================Reads==========================================
#==============================================================================

# Read mmmc
read_mmmc TCLs/mmmc.tcl
#end

# Read design
read_hdl -sv -f /home/p/paschalk/Desktop/I2C_Memory/filelists/rtl.f
#end


#==============================================================================
#===============================Elaboration====================================
#==============================================================================

#elaborate design
elaborate ${top_module}
#end

#Verification rtl vs elab step
write_netlist -lec > ${REPORTS_DIR}/Rtl_Elab_LEC/elab.v
write_do_lec -top ${top_module}  -golden_design rtl -revised_design elab.v -log_file rtl_elab.lec.log > ${REPORTS_DIR}/Rtl_Elab_LEC/rtl_elab.do
#end

#init db
init_design
#end


# write netlist
write_hdl > ${REPORTS_DIR}/netlist_rtl.v
#end

#==============================================================================
#===============================DFT  SETUP=====================================
#==============================================================================
set_db / .dft_scan_style muxed_scan
set_db / .dft_prefix DFT_
set_db / .dft_identify_top_level_test_clocks true
set_db / .dft_identify_test_signals true
set_db / .dft_identify_internal_test_clocks false
set_db / .use_scan_seqs_for_non_dft false
set_db "design:I2CAndMemory" .dft_scan_map_mode tdrc_pass
set_db "design:I2CAndMemory" .dft_connect_shift_enable_during_mapping tie_off
set_db "design:I2CAndMemory" .dft_connect_scan_data_pins_during_mapping loopback
set_db "design:I2CAndMemory" .dft_scan_output_preference auto
set_db "design:I2CAndMemory" .dft_lockup_element_type preferred_level_sensitive
set_db "design:I2CAndMemory" .dft_mix_clock_edges_in_scan_chains true
define_test_clock -name scanclk -period 20000 clk
define_shift_enable -name se -active high -create_port se
define_test_mode -name test_mode -active high -create_port test_mode
define_scan_chain -name top_chain -sdi scan_in -sdo scan_out -shift_enable se -create_ports

#DFT CHECKS
check_dft_rules > ${REPORTS_DIR}/Pre_Syn/DFT/DFT_rules.txt
report_scan_registers > ${REPORTS_DIR}/Pre_Syn/DFT/DFT_scan_registers.txt
report_scan_setup > ${REPORTS_DIR}/Pre_Syn/DFT/DFT_scan_setup.txt

check_dft_rules -advanced > ${REPORTS_DIR}/Pre_Syn/DFT/DFT_rules_advanced.txt
connect_scan_chains -auto_create_chains 
report_scan_chains > ${REPORTS_DIR}/Pre_Syn/DFT/DFT_scan_chains.txt


#Cheks pre synth
check_design -all >  ${REPORTS_DIR}/Pre_Syn/Check_design_all_pre_syn.txt
check_timing_intent > ${REPORTS_DIR}/Pre_Syn/Check_timing_intent_pre_syn.rpt
check_design -constant  >  ${REPORTS_DIR}/Pre_Syn/Check_design_constant_pre_syn.txt
#end

# ==============================================================================
# Optimization settings (optional)

set_db syn_generic_effort high
set_db syn_map_effort high 
set_db syn_opt_effort high

# ==============================================================================
#============================Synthesis_Generic==================================
# ==============================================================================

#synthesize with generic gates
syn_generic
#end

#verification rtl vs generic map
write_netlist -lec > ${REPORTS_DIR}/Rtl_Gen_LEC/gen.v
write_do_lec -top ${top_module}  -golden_design rtl  -revised_design gen.v -log_file rtl_gen.lec.log > ${REPORTS_DIR}/Rtl_Gen_LEC/rtl_gen.do
#end

#===============================================================================
#============================Synthesis_Mapped===================================
#===============================================================================

#synthezise with tech mapped gates
syn_map
#end

# Verification rtl vs fv_map step
write_netlist -lec > ${REPORTS_DIR}/Rtl_Map_LEC/map.v
write_do_lec -top ${top_module}  -golden_design rtl -revised_design map.v -log_file rtl_map.lec.log >${REPORTS_DIR}/Rtl_Map_LEC/rtl_map.do

#===============================================================================
#============================Synthesis_Opt======================================
#===============================================================================

#optimize synthesis
syn_opt
#end

# Increamental optimization
syn_opt -incremental
#end

#===============================================================================
#===============================Checks post synthesis===========================
#===============================================================================

#Checks
check_design -all >  ${REPORTS_DIR}/Post_Syn/Check_design_all_post_syn.txt
check_timing_intent > ${REPORTS_DIR}/Post_Syn/Check_timing_intent_post_syn.rpt
check_design -constant >${REPORTS_DIR}/Post_Syn/Check_design_constant_post_syn.txt
#end

#===============================================================================
#=============================Universal  Reports================================
#===============================================================================
#report Quality of results
report_qor -levels_of_logic > ${REPORTS_DIR}/report_qor.rpt
#end

#report area
report_area -detail > ${REPORTS_DIR}/report_area_detailed.rpt
#end

#report timing
report_timing -nets -max_paths 100 > ${REPORTS_DIR}/report_timing.rpt
#end

#report gates
report_gates > ${REPORTS_DIR}/gates.rpt
#end

#report power
report_power > ${REPORTS_DIR}/power.rpt
#end

#===============================================================================
#======================Reports per Analysis view================================
#===============================================================================

#Qor reports
report_qor -levels_of_logic -view PVT_1_80_V_BC_VIEW > ${REPORTS_DIR}/PVT_1_80_V_BC_VIEW/BC_report_qor.rpt
report_qor -levels_of_logic -view PVT_1_80_V_TYP_VIEW > ${REPORTS_DIR}/PVT_1_80_V_TYP_VIEW/TYP_report_qor.rpt
report_qor -levels_of_logic -view PVT_1_80_V_WC_VIEW > ${REPORTS_DIR}/PVT_1_80_V_WC_VIEW/WC_report_qor.rpt
#end

#Timing reports
report_timing -nets -max_paths 100 -view PVT_1_80_V_BC_VIEW > ${REPORTS_DIR}/PVT_1_80_V_BC_VIEW/BC_report_timing.rpt
report_timing -nets -max_paths 100 -view PVT_1_80_V_TYP_VIEW > ${REPORTS_DIR}/PVT_1_80_V_TYP_VIEW/TYP_report_timing.rpt
report_timing -nets -max_paths 100 -view PVT_1_80_V_WC_VIEW > ${REPORTS_DIR}/PVT_1_80_V_WC_VIEW/WC_report_timing.rpt
#end

#Gate reports
report_gates -view PVT_1_80_V_BC_VIEW -power  > ${REPORTS_DIR}/PVT_1_80_V_BC_VIEW/BC_gates.rpt
report_gates -view PVT_1_80_V_TYP_VIEW -power  > ${REPORTS_DIR}/PVT_1_80_V_TYP_VIEW/TYP_gates.rpt
report_gates -view PVT_1_80_V_WC_VIEW -power  > ${REPORTS_DIR}/PVT_1_80_V_WC_VIEW/WC_gates.rpt
#end

#Power reports
report_power -view PVT_1_80_V_BC_VIEW  > ${REPORTS_DIR}/PVT_1_80_V_BC_VIEW/BC_power.rpt
report_power -view PVT_1_80_V_TYP_VIEW  > ${REPORTS_DIR}/PVT_1_80_V_TYP_VIEW/TYP_power.rpt
report_power -view PVT_1_80_V_WC_VIEW  > ${REPORTS_DIR}/PVT_1_80_V_WC_VIEW/WC_power.rpt
#end



#===============================================================================
#======================DFT 		Reports	================================
#===============================================================================
check_dft_rules > ${REPORTS_DIR}/Post_Syn/DFT/DFT_rules.txt
report_scan_registers > ${REPORTS_DIR}/Post_Syn/DFT/DFT_scan_registers.txt
report_scan_setup > ${REPORTS_DIR}/Post_Syn/DFT/DFT_scan_setup.txt

check_dft_rules -advanced > ${REPORTS_DIR}/Post_Syn/DFT/DFT_rules_advanced.txt
connect_scan_chains -auto_create_chains 
report_scan_chains > ${REPORTS_DIR}/Post_Syn/DFT/DFT_scan_chains.txt



# ==============================================================================
# Write design for innovus
write_design -innovus -base_name ${OUT_TO_INVS_DIR}/${top_module}
#write_scandef -scanDEF
#write_dft_abstract_model > ${OUT_TO_INVS_DIR}/${top_module}/dft_abs_model.tcl
#write_hdl -abstract > ${OUT_TO_INVS_DIR}/${top_module}/hdl_abs.v
#write_script -analyze_all_scan_chains > ${OUT_TO_INVS_DIR}/${top_module}/script_analyze_chains.tcl
puts $::dc::sdc_failed_commands
quit



