#################################################################################
#
# Created by Genus(TM) Synthesis Solution 21.15-s080_1 on Tue Nov 25 21:44:46 EET 2025
#
#################################################################################

## library_sets
create_library_set -name default_emulate_libset_max \
    -timing { /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/liberty_LPMOS/v3_0_0/PVT_1_80V_range//D_CELLS_HD_LPMOS_typ_1_80V_25C.lib \
              /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/IO_CELLS_3V/v2_1/liberty_LPMOS/v2_1_0/PVT_1_80V_3_30V_range//IO_CELLS_3V_LPMOS_typ_1_80V_3_30V_25C.lib }

## opcond
create_opcond -name default_emulate_opcond \
    -process 1.0 \
    -voltage 1.799999 \
    -temperature 25.0

## timing_condition
create_timing_condition -name default_emulate_timing_cond_max \
    -opcond default_emulate_opcond \
    -library_sets { default_emulate_libset_max }

## rc_corner
create_rc_corner -name default_emulate_rc_corner \
    -temperature 25.0 \
    -qrc_tech /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/QRC_assura/v7_0_1/XH018_1143/QRC-Typ/qrcTechFile \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0}

## delay_corner
create_delay_corner -name default_emulate_delay_corner \
    -early_timing_condition { default_emulate_timing_cond_max } \
    -late_timing_condition { default_emulate_timing_cond_max } \
    -early_rc_corner default_emulate_rc_corner \
    -late_rc_corner default_emulate_rc_corner

## constraint_mode
create_constraint_mode -name default_emulate_constraint_mode \
    -sdc_files { /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Single/Genus_Out_Innovus/I2CAndMemory.default_emulate_constraint_mode.sdc }

## analysis_view
create_analysis_view -name default_emulate_view \
    -constraint_mode default_emulate_constraint_mode \
    -delay_corner default_emulate_delay_corner

## set_analysis_view
set_analysis_view -setup { default_emulate_view } \
                  -hold { default_emulate_view }
