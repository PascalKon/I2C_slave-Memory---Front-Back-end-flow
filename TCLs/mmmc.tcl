

# ---------------------------------------------------------------------
# Constraint Mode
# ---------------------------------------------------------------------
create_constraint_mode \
    -name bc_mode \
    -sdc_files /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Constraints/constraints_bc.sdc

create_constraint_mode \
    -name typ_mode \
    -sdc_files /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Constraints/constraints_typ.sdc
    
create_constraint_mode \
    -name wc_mode \
    -sdc_files /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Constraints/constraints_wc.sdc

# ---------------------------------------------------------------------
# RC Corners
# ---------------------------------------------------------------------
create_rc_corner \
    -name MIN_RC \
    -temperature -40 \
    -qrc_tech /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/QRC_pvs/v7_0_1_1/XH018_1143/QRC-Min/qrcTechFile \
    -cap_table /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/capTbl/v7_0_2/xh018_xx43_MET4_METMID_METTHK_min.capTbl

create_rc_corner \
    -name TYP_RC \
    -temperature 25 \
    -qrc_tech /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/QRC_pvs/v7_0_1_1/XH018_1143/QRC-Typ/qrcTechFile \
    -cap_table /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/capTbl/v7_0_2/xh018_xx43_MET4_METMID_METTHK_typ.capTbl

create_rc_corner \
    -name MAX_RC \
    -temperature 175 \
    -qrc_tech /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/QRC_pvs/v7_0_1_1/XH018_1143/QRC-Max/qrcTechFile \
    -cap_table /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/capTbl/v7_0_2/xh018_xx43_MET4_METMID_METTHK_max.capTbl

# ---------------------------------------------------------------------
# Library Sets (ALL PVT combinations for D_CELLS_HD + IO_CELLS_3V)
# ---------------------------------------------------------------------


#PVT_1_80_V 

# ---------------------------------------------------------------------
# Library Sets (PVT_1_80_V combinations for D_CELLS_HD + IO_CELLS_3V)
# ---------------------------------------------------------------------

#PVT_1_80_V m40C
# Best Case fast, high V, low T
create_library_set \
    -name PVT_1_80_V_BC_LIBS \
    -timing [list \
		 /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/liberty_LPMOS/v3_0_0/PVT_1_80V_range/D_CELLS_HD_LPMOS_fast_1_98V_m40C.lib \
		 /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/IO_CELLS_3V/v2_1/liberty_LPMOS/v2_1_0/PVT_1_80V_3_30V_range/IO_CELLS_3V_LPMOS_fast_1_98V_3_60V_m40C.lib \
    ]
 
#PVT_1_80_V 25C    
# Typical Case fast, typ V, typ T
create_library_set \
    -name PVT_1_80_V_TYP_LIBS \
    -timing [list \
		 /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/liberty_LPMOS/v3_0_0/PVT_1_80V_range/D_CELLS_HD_LPMOS_typ_1_80V_25C.lib \
		 /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/IO_CELLS_3V/v2_1/liberty_LPMOS/v2_1_0/PVT_1_80V_3_30V_range/IO_CELLS_3V_LPMOS_typ_1_80V_3_30V_25C.lib \
    ]

#PVT_1_80_V 125C
# Worst Case slow, lowest V, Highest T
create_library_set \
    -name PVT_1_80_V_WC_LIBS \
    -timing [list \
		 /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/liberty_LPMOS/v3_0_0/PVT_1_80V_range/D_CELLS_HD_LPMOS_slow_1_62V_175C.lib \
		 /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/IO_CELLS_3V/v2_1/liberty_LPMOS/v2_1_0/PVT_1_80V_3_30V_range/IO_CELLS_3V_LPMOS_slow_1_62V_3_00V_175C.lib \
    ]


create_opcond \
    -name  PVT_1_80_V_BC_OC \
    -process 1 \
    -voltage 1.98 \
    -temperature -40

create_opcond \
    -name  PVT_1_80_V_TYP_OC \
    -process 1 \
    -voltage 1.80 \
    -temperature 25

create_opcond \
    -name  PVT_1_80_V_WC_OC \
    -process 1 \
    -voltage 1.62 \
    -temperature 175



# ---------------------------------------------------------------------
# Timing Conditions
# ---------------------------------------------------------------------

create_timing_condition -name PVT_1_80_V_BC_TC -library_sets PVT_1_80_V_BC_LIBS -opcond  PVT_1_80_V_BC_OC
create_timing_condition -name PVT_1_80_V_TYP_TC -library_sets PVT_1_80_V_TYP_LIBS -opcond  PVT_1_80_V_TYP_OC
create_timing_condition -name PVT_1_80_V_WC_TC -library_sets PVT_1_80_V_WC_LIBS -opcond  PVT_1_80_V_WC_OC

# ---------------------------------------------------------------------
# Delay Corners
# ---------------------------------------------------------------------

create_delay_corner -name PVT_1_80_V_BC_DELAY -timing_condition PVT_1_80_V_BC_TC -rc_corner MIN_RC
create_delay_corner -name PVT_1_80_V_TYP_DELAY -timing_condition PVT_1_80_V_TYP_TC -rc_corner TYP_RC
create_delay_corner -name PVT_1_80_V_WC_DELAY -timing_condition PVT_1_80_V_WC_TC -rc_corner MAX_RC

# ---------------------------------------------------------------------
# Analysis Views
# ---------------------------------------------------------------------

create_analysis_view -name PVT_1_80_V_BC_VIEW  -constraint_mode bc_mode -delay_corner PVT_1_80_V_BC_DELAY
create_analysis_view -name PVT_1_80_V_TYP_VIEW -constraint_mode typ_mode -delay_corner PVT_1_80_V_TYP_DELAY
create_analysis_view -name PVT_1_80_V_WC_VIEW  -constraint_mode wc_mode -delay_corner PVT_1_80_V_WC_DELAY

# ---------------------------------------------------------------------
# Final Setup for Analysis
# ---------------------------------------------------------------------
set_analysis_view \
    -setup [list \
		PVT_1_80_V_WC_VIEW \
		PVT_1_80_V_TYP_VIEW \
		PVT_1_80_V_BC_VIEW ] \
    -hold  [list \
		PVT_1_80_V_BC_VIEW \
		PVT_1_80_V_TYP_VIEW ] \
    -leakage [list \
		PVT_1_80_V_TYP_VIEW ] \
    -dynamic [list \
		PVT_1_80_V_TYP_VIEW ] 
	      


puts "MMMC setup successfully loaded for XFAB XH018 D_CELLS_HD / IO_CELLS_3V ."
