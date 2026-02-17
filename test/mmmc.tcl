#################################################################################
#
# Created by Genus(TM) Synthesis Solution 22.13-s093_1 on Sat Nov 29 15:54:35 EET 2025
#
#################################################################################

## library_sets
create_library_set -name PVT_1_80_V_BC_LIBS \
    -timing { /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/liberty_LPMOS/v3_0_0/PVT_1_80V_range/D_CELLS_HD_LPMOS_fast_1_98V_m40C.lib \
              /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/IO_CELLS_3V/v2_1/liberty_LPMOS/v2_1_0/PVT_1_80V_3_30V_range/IO_CELLS_3V_LPMOS_fast_1_98V_3_60V_m40C.lib }
create_library_set -name PVT_1_80_V_TYP_LIBS \
    -timing { /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/liberty_LPMOS/v3_0_0/PVT_1_80V_range/D_CELLS_HD_LPMOS_typ_1_80V_25C.lib \
              /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/IO_CELLS_3V/v2_1/liberty_LPMOS/v2_1_0/PVT_1_80V_3_30V_range/IO_CELLS_3V_LPMOS_typ_1_80V_3_30V_25C.lib }
create_library_set -name PVT_1_80_V_WC_LIBS \
    -timing { /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/liberty_LPMOS/v3_0_0/PVT_1_80V_range/D_CELLS_HD_LPMOS_slow_1_62V_175C.lib \
              /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/IO_CELLS_3V/v2_1/liberty_LPMOS/v2_1_0/PVT_1_80V_3_30V_range/IO_CELLS_3V_LPMOS_slow_1_62V_3_00V_175C.lib }

## opcond
create_opcond -name PVT_1_80_V_BC_OC \
    -process 1.0 \
    -voltage 1.98 \
    -temperature -40.0
create_opcond -name PVT_1_80_V_TYP_OC \
    -process 1.0 \
    -voltage 1.8 \
    -temperature 25.0
create_opcond -name PVT_1_80_V_WC_OC \
    -process 1.0 \
    -voltage 1.62 \
    -temperature 175.0

## timing_condition
create_timing_condition -name PVT_1_80_V_BC_TC \
    -opcond PVT_1_80_V_BC_OC \
    -library_sets { PVT_1_80_V_BC_LIBS }
create_timing_condition -name PVT_1_80_V_TYP_TC \
    -opcond PVT_1_80_V_TYP_OC \
    -library_sets { PVT_1_80_V_TYP_LIBS }
create_timing_condition -name PVT_1_80_V_WC_TC \
    -opcond PVT_1_80_V_WC_OC \
    -library_sets { PVT_1_80_V_WC_LIBS }

## rc_corner
create_rc_corner -name MIN_RC \
    -temperature -40.0 \
    -qrc_tech /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/QRC_pvs/v7_0_1_1/XH018_1143/QRC-Min/qrcTechFile \
    -cap_table /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/capTbl/v7_0_2/xh018_xx43_MET4_METMID_METTHK_min.capTbl \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0} \
    -post_route_clock_cross_cap {1.0 1.0 1.0}
create_rc_corner -name TYP_RC \
    -temperature 25.0 \
    -qrc_tech /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/QRC_pvs/v7_0_1_1/XH018_1143/QRC-Typ/qrcTechFile \
    -cap_table /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/capTbl/v7_0_2/xh018_xx43_MET4_METMID_METTHK_typ.capTbl \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0} \
    -post_route_clock_cross_cap {1.0 1.0 1.0}
create_rc_corner -name MAX_RC \
    -temperature 175.0 \
    -qrc_tech /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/QRC_pvs/v7_0_1_1/XH018_1143/QRC-Max/qrcTechFile \
    -cap_table /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/capTbl/v7_0_2/xh018_xx43_MET4_METMID_METTHK_max.capTbl \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0} \
    -post_route_clock_cross_cap {1.0 1.0 1.0}

## delay_corner
create_delay_corner -name PVT_1_80_V_BC_DELAY \
    -early_timing_condition { PVT_1_80_V_BC_TC } \
    -late_timing_condition { PVT_1_80_V_BC_TC } \
    -early_rc_corner MIN_RC \
    -late_rc_corner MIN_RC
create_delay_corner -name PVT_1_80_V_TYP_DELAY \
    -early_timing_condition { PVT_1_80_V_TYP_TC } \
    -late_timing_condition { PVT_1_80_V_TYP_TC } \
    -early_rc_corner TYP_RC \
    -late_rc_corner TYP_RC
create_delay_corner -name PVT_1_80_V_WC_DELAY \
    -early_timing_condition { PVT_1_80_V_WC_TC } \
    -late_timing_condition { PVT_1_80_V_WC_TC } \
    -early_rc_corner MAX_RC \
    -late_rc_corner MAX_RC

## constraint_mode
create_constraint_mode -name bc_mode \
    -sdc_files { ./test/bc_mode.sdc }
create_constraint_mode -name typ_mode \
    -sdc_files { ./test/typ_mode.sdc }
create_constraint_mode -name wc_mode \
    -sdc_files { ./test/wc_mode.sdc }

## analysis_view
create_analysis_view -name PVT_1_80_V_BC_VIEW \
    -constraint_mode bc_mode \
    -delay_corner PVT_1_80_V_BC_DELAY
create_analysis_view -name PVT_1_80_V_TYP_VIEW \
    -constraint_mode typ_mode \
    -delay_corner PVT_1_80_V_TYP_DELAY
create_analysis_view -name PVT_1_80_V_WC_VIEW \
    -constraint_mode wc_mode \
    -delay_corner PVT_1_80_V_WC_DELAY

## set_analysis_view
set_analysis_view -setup { PVT_1_80_V_WC_VIEW PVT_1_80_V_TYP_VIEW } \
                  -hold { PVT_1_80_V_BC_VIEW PVT_1_80_V_TYP_VIEW } \
                  -leakage PVT_1_80_V_TYP_VIEW \
                  -dynamic PVT_1_80_V_TYP_VIEW
