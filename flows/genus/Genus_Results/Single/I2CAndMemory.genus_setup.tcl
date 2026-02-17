################################################################################
#
# Genus(TM) Synthesis Solution setup file
# Created by Genus(TM) Synthesis Solution 21.15-s080_1
#   on 11/25/2025 21:44:51
#
# This file can only be run in Genus Common UI mode.
#
################################################################################


# This script is intended for use with Genus(TM) Synthesis Solution version 21.15-s080_1


# Remove Existing Design
################################################################################
if {[::legacy::find -design design:I2CAndMemory] ne ""} {
  puts "** A design with the same name is already loaded. It will be removed. **"
  delete_obj design:I2CAndMemory
}


# To allow user-readonly attributes
################################################################################
::legacy::set_attribute -quiet force_tui_is_remote 1 /


# Libraries
################################################################################
::legacy::set_attribute library {/mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/liberty_LPMOS/v3_0_0/PVT_1_80V_range//D_CELLS_HD_LPMOS_typ_1_80V_25C.lib /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/IO_CELLS_3V/v2_1/liberty_LPMOS/v2_1_0/PVT_1_80V_3_30V_range//IO_CELLS_3V_LPMOS_typ_1_80V_3_30V_25C.lib} /

::legacy::set_attribute lef_library {/mnt/apps/prebuilt/eda/designkits/xfab/XKIT/xh018/cadence/v7_0/techLEF/v7_0_3/xh018_xx43_HD_MET4_METMID_METTHK.lef /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/LEF/v3_0_0/xh018_D_CELLS_HD.lef /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/D_CELLS_HD/v3_0/LEF/v3_0_0/xh018_xx43_MET4_METMID_METTHK_D_CELLS_HD_mprobe.lef /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/diglibs/IO_CELLS_3V/v2_1/LEF/v2_1_0/xh018_xx43_MET4_METMID_METTHK_IO_CELLS_3V.lef} /
::legacy::set_attribute qrc_tech_file /mnt/apps/prebuilt/eda/designkits/xfab/XKIT/x_all/cadence/XFAB_AMS_RefKit-cadence_IC61/v2_5_1/pdk/xh018/cadence/v7_0/QRC_assura/v7_0_1/XH018_1143/QRC-Typ/qrcTechFile /


# Design
################################################################################
read_netlist -top I2CAndMemory /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Single/Genus_Out_Innovus/I2CAndMemory.v
read_metric -id current /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Single/Genus_Out_Innovus/I2CAndMemory.metrics.json

phys::read_script /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Single/Genus_Out_Innovus/I2CAndMemory.g
puts "\n** Restoration Completed **\n"


# Data Integrity Check
################################################################################
# program version
if {"[string_representation [::legacy::get_attribute program_version /]]" != "21.15-s080_1"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-91] "golden program_version: 21.15-s080_1  current program_version: [string_representation [::legacy::get_attribute program_version /]]"
}
# license
if {"[string_representation [::legacy::get_attribute startup_license /]]" != "Genus_Synthesis"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-91] "golden license: Genus_Synthesis  current license: [string_representation [::legacy::get_attribute startup_license /]]"
}
# slack
set _slk_ [::legacy::get_attribute slack design:I2CAndMemory]
if {[regexp {^-?[0-9.]+$} $_slk_]} {
  set _slk_ [format %.1f $_slk_]
}
if {$_slk_ != "50966.9"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-92] "golden slack: 50966.9,  current slack: $_slk_"
}
unset _slk_
# multi-mode slack
# tns
set _tns_ [::legacy::get_attribute tns design:I2CAndMemory]
if {[regexp {^-?[0-9.]+$} $_tns_]} {
  set _tns_ [format %.0f $_tns_]
}
if {$_tns_ != "0"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-92] "golden tns: 0,  current tns: $_tns_"
}
unset _tns_
# cell area
set _cell_area_ [::legacy::get_attribute cell_area design:I2CAndMemory]
if {[regexp {^-?[0-9.]+$} $_cell_area_]} {
  set _cell_area_ [format %.0f $_cell_area_]
}
if {$_cell_area_ != "53937"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-92] "golden cell area: 53937,  current cell area: $_cell_area_"
}
unset _cell_area_
# net area
set _net_area_ [::legacy::get_attribute net_area design:I2CAndMemory]
if {[regexp {^-?[0-9.]+$} $_net_area_]} {
  set _net_area_ [format %.0f $_net_area_]
}
if {$_net_area_ != "20859"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-92] "golden net area: 20859,  current net area: $_net_area_"
}
unset _net_area_
