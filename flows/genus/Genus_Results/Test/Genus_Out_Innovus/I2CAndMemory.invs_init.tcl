################################################################################
#
# Init setup file
# Created by Genus(TM) Synthesis Solution on 11/30/2025 21:03:23
#
################################################################################
if { ![is_common_ui_mode] } { error "ERROR: This script requires common_ui to be active."}

read_mmmc /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.mmmc.tcl

read_physical -lef {/mnt/apps/prebuilt/eda/designkits/xfab/XKIT/xh018/cadence/v7_0/techLEF/v7_0_3/xh018_xx43_HD_MET4_METMID_METTHK.lef /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/LEF/v3_0_0/xh018_D_CELLS_HD.lef /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/LEF/v3_0_0/xh018_xx43_MET4_METMID_METTHK_D_CELLS_HD_mprobe.lef /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/IO_CELLS_3V/v2_1/LEF/v2_1_0/xh018_xx43_MET4_METMID_METTHK_IO_CELLS_3V.lef}

read_netlist /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.v

init_design
