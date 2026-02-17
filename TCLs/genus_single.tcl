
#I2C_Memory_AMS_FLOW

#----TECH LEF-----
# Tech lef_dir /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_Digital_RefKit-cadence/v1_0_1/pdk/xh018/cadence/v5_0/techLEF/v5_0_1_2/
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
set REPORTS_DIR /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Single/Genus_Reports
#end

#setups path for Output files to Innovus
set OUT_TO_INVS_DIR /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Single/Genus_Out_Innovus
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

#D_CELLS_HD timing libraries 
#D_CELLS_HD_LPMOS_fast_1_80V_25C.lib \
#D_CELLS_HD_LPMOS_fast_1_98V_125C.lib \
#D_CELLS_HD_LPMOS_fast_1_98V_175C.lib \
#D_CELLS_HD_LPMOS_fast_1_98V_m40C.lib \
#D_CELLS_HD_LPMOS_slow_1_62V_125C.lib \
#D_CELLS_HD_LPMOS_slow_1_62V_175C.lib \
#D_CELLS_HD_LPMOS_slow_1_62V_m40C.lib \
#D_CELLS_HD_LPMOS_typ_1_80V_25C.lib \
		
#IO_CELLS_3V timing libraries
#IO_CELLS_3V_LPMOS_fast_1_80V_3_30V_25C.lib \
#IO_CELLS_3V_LPMOS_fast_1_98V_3_60V_125C.lib \
#IO_CELLS_3V_LPMOS_fast_1_98V_3_60V_125C_wcl.lib \
#IO_CELLS_3V_LPMOS_fast_1_98V_3_60V_175C.lib \
#IO_CELLS_3V_LPMOS_fast_1_98V_3_60V_175C_wcl.lib \
#IO_CELLS_3V_LPMOS_fast_1_98V_3_60V_m40C.lib \
#IO_CELLS_3V_LPMOS_slow_1_62V_3_30V_125C.lib \
#IO_CELLS_3V_LPMOS_slow_1_62V_3_30V_175C.lib \
#IO_CELLS_3V_LPMOS_slow_1_62V_3_30V_m40C.lib \
#IO_CELLS_3V_LPMOS_typ_1_80V_3_30V_25C.lib \ 

#set timing library
set_db library {D_CELLS_HD_LPMOS_typ_1_80V_25C.lib \
		IO_CELLS_3V_LPMOS_typ_1_80V_3_30V_25C.lib }
#end

#set opreating conditions
set_db operating_conditions typ_1_80V_25C 
#end


set_db lef_library { /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/xh018/cadence/v7_0/techLEF/v7_0_3/xh018_xx43_HD_MET4_METMID_METTHK.lef \
		     /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/LEF/v3_0_0/xh018_D_CELLS_HD.lef \
		     /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/LEF/v3_0_0/xh018_xx43_MET4_METMID_METTHK_D_CELLS_HD_mprobe.lef \
		     /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/IO_CELLS_3V/v2_1/LEF/v2_1_0/xh018_xx43_MET4_METMID_METTHK_IO_CELLS_3V.lef }
#end

#Setup qrc library
read_qrc /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/QRC_pvs/v7_0_1_1/XH018_1143/QRC-Typ/qrcTechFile
#end

#==============================================================================
#===============================Reads==========================================
#==============================================================================

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

# write netlist
write_hdl > ${REPORTS_DIR}/netlist_rtl.v
#end

#read constraints
read_sdc /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Constraints/constraints.sdc
#end

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
#===============================Write Design Innovua============================
#===============================================================================
write_design -innovus -base_name ${OUT_TO_INVS_DIR}/${top_module}
puts $::dc::sdc_failed_commands
quit


