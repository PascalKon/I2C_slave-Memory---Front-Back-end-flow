################################################################################
#
# Innovus setup file
# Created by Genus(TM) Synthesis Solution 22.13-s093_1
#   on 11/30/2025 21:03:23
#
################################################################################
#
# Genus(TM) Synthesis Solution setup file
# This file can only be run in Innovus Common UI mode.
#
################################################################################


# Version Check
###########################################################

      namespace eval ::genus_innovus_version_check { 
        set minimum_version 22
        set maximum_version 23
        regexp {\d\d} [get_db program_version] this_version
        puts "Checking Innovus major version against Genus expectations ..."
        if { $this_version < $minimum_version || $this_version > $maximum_version } {
          error "**ERROR: this operation requires Innovus major version to be between '$minimum_version' and '$maximum_version'."
        }
      }
    
set _t0 [clock seconds]
puts [format  {%%%s Begin Genus to Innovus Setup (%s)} \# [clock format $_t0 -format {%m/%d %H:%M:%S}]]
set_db read_physical_allow_multiple_port_pin_without_must_join true
set_db must_join_all_ports true
set_db timing_cap_unit 1pf
set_db timing_time_unit 1ns


# Design Import
################################################################################
source -quiet /mnt/apps/prebuilt/eda/cadence/2023-24/RHELx86/DDIEXPORT_22.33.000/GENUS221/tools.lnx86/lib/cdn/rc/edi/innovus_procs_common_ui.tcl
## Reading FlowKit settings file
source /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.flowkit_settings.tcl

source /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.invs_init.tcl
update_analysis_view -name PVT_1_80_V_BC_VIEW -constraint_mode bc_mode -latency_file /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.PVT_1_80_V_BC_VIEW_latency.sdc
update_analysis_view -name PVT_1_80_V_TYP_VIEW -constraint_mode typ_mode -latency_file /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.PVT_1_80_V_TYP_VIEW_latency.sdc
update_analysis_view -name PVT_1_80_V_WC_VIEW -constraint_mode wc_mode -latency_file /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.PVT_1_80_V_WC_VIEW_latency.sdc

# Reading metrics file
################################################################################
read_metric -id current /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.metrics.json

## Reading common preserve file for dont_touch and dont_use preserve settings
source -quiet /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.preserve.tcl

read_def /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.scan.def
## Reading Innovus Mode attributes file
pqos_eval {rcp::read_taf /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.mode_attributes.taf.gz}


# Mode Setup
################################################################################
source /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.mode


# MSV Setup
################################################################################

# Reading write_name_mapping file
################################################################################

      if { [is_attribute -obj_type port original_name] &&
           [is_attribute -obj_type pin original_name] &&
           [is_attribute -obj_type pin is_phase_inverted]} {
        source /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.wnm_attrs.tcl
      }
    

# Reading NDR file
source /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.ndr.tcl

# Reading Instance Attributes file
pqos_eval { rcp::read_taf /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.inst_attributes.taf.gz}

# Reading subdesign attributes file
pqos_eval { rcp::read_taf /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.subdesign_attributes.taf.gz}

# Reading minimum routing layer data file
################################################################################
pqos_eval {rcp::load_min_layer_file /home/p/paschalk/Desktop/I2C_Memory/flows/genus/Genus_Results/Test/Genus_Out_Innovus/I2CAndMemory.min_layer {MET1 MET2 MET3 MET4 METTP METTPL} {1 2 3 4 5 6}}

      # Setting attribute to hold the LEC DFT pin constraints from the last LEC run done by Genus"
      if { [is_attribute -obj_type design write_lec_dft_constraints] } {  
        set_db designs .write_lec_dft_constraints {{design_view revised module {} pins_to_0 {se test_mode} ignored_output scan_out}}
      }
    
eval_legacy {set edi_pe::pegConsiderMacroLayersUnblocked 1}
eval_legacy {set edi_pe::pegPreRouteWireWidthBasedDensityCalModel 1}

      set _t1 [clock seconds]
      puts [format  {%%%s End Genus to Innovus Setup (%s, real=%s)} \# [clock format $_t1 -format {%m/%d %H:%M:%S}] [clock format [expr {28800 + $_t1 - $_t0}] -format {%H:%M:%S}]]
    
