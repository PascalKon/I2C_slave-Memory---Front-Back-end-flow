set REPORTS_DIR /home/p/paschalk/Desktop/I2C_Memory/flows/innovus/Innovus_Results/MMMC
set SAVES_DIR  /home/p/paschalk/Desktop/I2C_Memory/flows/innovus/Innovus_Results/MMMC/Saved_Designs
set MODE MMMC

setMultiCpuUsage -localCpu max
source Globals/I2CAndMemory_MMMC.globals
init_design

#===========Secify Floorplan=============
getIoFlowFlag
setIoFlowFlag 0
floorPlan -site core_hd -r 0.922495274102 0.75 15 15 15 15
uiSetTool select
getIoFlowFlag
fit

#============Power Core Ring============================
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer METTPL -stacked_via_bottom_layer MET1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
addRing -nets {vdd gnd} -type core_rings -follow core -layer {top METTP bottom METTP left METTPL right METTPL} -width {top 3 bottom 3 left 3 right 3} -spacing {top 3 bottom 3 left 3 right 3} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 1 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None

#============Power Stripes============================
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target none -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length stripe_width -stacked_via_top_layer METTPL -stacked_via_bottom_layer MET1 -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring  block_ring } -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape   }
addStripe -nets {vdd gnd} -layer METTPL -direction vertical -width 3 -spacing 3 -number_of_sets 3 -start_from left -start_offset 30 -stop_offset 30 -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit METTPL -padcore_ring_bottom_layer_limit MET1 -block_ring_top_layer_limit METTPL -block_ring_bottom_layer_limit MET1 -use_wire_group 0 -snap_wire_center_to_grid None


#=========Power Pins============

globalNetConnect vdd -type pgpin -pin vdd -inst *
globalNetConnect vdd -type tiehi -instanceBasename *
globalNetConnect gnd -type pgpin -pin gnd -inst *   
globalNetConnect gnd -type tielo -instanceBasename *
createPGPin vdd -net vdd -geom METTPL  9.06 0 12.06 12.06
createPGPin gnd -net gnd -geom METTPL  3.06 0 6.06 6.06

#==================S Route=============================

setSrouteMode -viaConnectToShape { stripe }
sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { MET1(1) METTPL(6) } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { MET1(1) METTPL(6) } -nets { vdd gnd } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { MET1(1) METTPL(6) }

saveDesign ${SAVES_DIR}/Top_${MODE}_1_Pre_Place.enc

#=========Place============

setRouteMode -earlyGlobalHonorMsvRouteConstraint false -earlyGlobalRoutePartitionPinGuide true
setEndCapMode -reset
setEndCapMode -boundary_tap false
setNanoRouteMode -quiet -droutePostRouteSpreadWire 1
setNanoRouteMode -quiet -timingEngine {}
setUsefulSkewMode -noBoundary false -maxAllowedDelay 1
setPlaceMode -reset
setPlaceMode -congEffort high -timingDriven 1 -clkGateAware 1 -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 0 -placeIOPins 1 -moduleAwareSpare 0 -preserveRouting 1 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0
setDesignMode -process 180
getPlaceMode
place_opt_design -out_dir ${REPORTS_DIR}/Post_Place/Place_Opt

report_power -output ${REPORTS_DIR}/Post_Place/ -outfile ${REPORTS_DIR}/Post_Place/${MODE}_Place_power_WC.txt -view PVT_1_80_V_WC_VIEW
report_power -output ${REPORTS_DIR}/Post_Place/ -outfile ${REPORTS_DIR}/Post_Place/${MODE}_Place_power_TYP.txt -view PVT_1_80_V_TYP_VIEW
report_power -output ${REPORTS_DIR}/Post_Place/ -outfile ${REPORTS_DIR}/Post_Place/${MODE}_Place_power_BC.txt -view PVT_1_80_V_BC_VIEW
report_timing > ${REPORTS_DIR}/Post_Place/${MODE}_Place_timing.txt
report_area > ${REPORTS_DIR}/Post_Place/${MODE}_Place_area.txt
checkPlace > ${REPORTS_DIR}/Post_Place/${MODE}_Place_check_placement.txt
saveDesign ${SAVES_DIR}/Top_${MODE}_2_Post_Place_Pre_GRoute.enc

#=========Early Global Route============
setRouteMode -earlyGlobalMinRouteLayer 2 -earlyGlobalMaxRouteLayer 6 -earlyGlobalHonorMsvRouteConstraint true -earlyGlobalRoutePartitionPinGuide true
earlyGlobalRoute


report_power -output ${REPORTS_DIR}/Post_GRoute/ -outfile ${REPORTS_DIR}/Post_GRoute/${MODE}_GRoute_power_WC.txt -view PVT_1_80_V_WC_VIEW
report_power -output ${REPORTS_DIR}/Post_GRoute/ -outfile ${REPORTS_DIR}/Post_GRoute/${MODE}_GRoute_power_TYP.txt -view PVT_1_80_V_TYP_VIEW
report_power -output ${REPORTS_DIR}/Post_GRoute/ -outfile ${REPORTS_DIR}/Post_GRoute/${MODE}_GRoute_power_BC.txt -view PVT_1_80_V_BC_VIEW
report_area > ${REPORTS_DIR}/Post_GRoute/${MODE}_GRoute_area.txt
report_timing > ${REPORTS_DIR}/Post_GRoute/${MODE}_GRoute_timing.txt
reportCongestion -hotSpot > ${REPORTS_DIR}/Post_GRoute/Congestion/${MODE}_GRoute_hotspot.txt
reportCongestion -overflow > ${REPORTS_DIR}/Post_GRoute/Congestion/${MODE}_GRoute_overflow.txt

saveDesign ${SAVES_DIR}/Top_${MODE}_3_Post_GRoute_Pre_CTS.enc

#=========Clock Tree Synthesis Global Route============
#-shield_net gnd // add shilding with gnd you can put vdd also
#-shield_side both_side // to both sides can also be single side
#maybe put skew 0.4
#also maybe change top and bottom layers

add_ndr -width {MET1 0.46 MET2 0.56 MET3 0.56 MET4 0.56 METTP 0.88 METTPL 6.0 } -name NDR_1

create_route_type -top_preferred_layer 4 -bottom_preferred_layer 3 -non_default_rule NDR_1 -name t_route -preferred_routing_layer_effort high
set_ccopt_property -net_type trunk -route_type t_route
set_ccopt_property target_skew 0.4
set_ccopt_property target_max_trans 0.6
create_route_type -top_preferred_layer 4 -bottom_preferred_layer 3 -name l_route -preferred_routing_layer_effort high
set_ccopt_property -net_type leaf -route_type l_route
set_ccopt_property target_skew 0.4
set_ccopt_property target_max_trans 0.6

create_ccopt_clock_tree_spec -file ${REPORTS_DIR}/Post_CTS/Clock_Tree_Spec/clock.spec
ccopt_design -outDir ${REPORTS_DIR}/Post_CTS/Ccopt_Design_Timing_Reports

optDesign -postCTS -outDir ${REPORTS_DIR}/Post_CTS/CTS_Opt_Design/

report_power -output ${REPORTS_DIR}/Post_CTS/ -outfile ${REPORTS_DIR}/Post_CTS/${MODE}_CTS_power_WC.txt -view PVT_1_80_V_WC_VIEW
report_power -output ${REPORTS_DIR}/Post_CTS/ -outfile ${REPORTS_DIR}/Post_CTS/${MODE}_CTS_power_TYP.txt -view PVT_1_80_V_TYP_VIEW
report_power -output ${REPORTS_DIR}/Post_CTS/ -outfile ${REPORTS_DIR}/Post_CTS/${MODE}_CTS_power_BC.txt -view PVT_1_80_V_BC_VIEW
report_area > ${REPORTS_DIR}/Post_CTS/${MODE}_CTS_area.txt
report_timing > ${REPORTS_DIR}/Post_CTS/${MODE}_CTS_timing.txt
report_ccopt_clock_trees > ${REPORTS_DIR}/Post_CTS/${MODE}_CTS_clock_trees.txt
report_ccopt_skew_groups > ${REPORTS_DIR}/Post_CTS/${MODE}_CTS_skew_groups.txt

saveDesign ${SAVES_DIR}/Top_${MODE}_4_Post_CTS_Pre_NRoute.enc

#================Nano Route=============

setNanoRouteMode -routeTopRoutingLayer 6
setNanoRouteMode -routeBottomRoutingLayer 1
setNanoRouteMode -drouteEndIteration default
setNanoRouteMode -routeWithTimingDriven true
setNanoRouteMode -routeWithSiDriven true
setNanoRouteMode -drouteUseMultiCutViaEffort medium
setNanoRouteMode -drouteFixAntenna true
setNanoRouteMode -routeInsertAntennaDiode true
setNanoRouteMode -routeAntennaCellName {ANTENNACELLN2HD ANTENNACELLNP2HD ANTENNACELLP2HD}
routeDesign -globalDetail

setDelayCalMode -engine aae -SIAware true
setAnalysisMode -analysisType onChipVariation -cppr both
optDesign -postRoute -setup -hold -outDir ${REPORTS_DIR}/Post_NRoute/NRoute_Opt_Design/

report_power -output ${REPORTS_DIR}/Post_NRoute/ -outfile ${REPORTS_DIR}/Post_NRoute/${MODE}_NRoute_power_WC.txt -view PVT_1_80_V_WC_VIEW
report_power -output ${REPORTS_DIR}/Post_NRoute/ -outfile ${REPORTS_DIR}/Post_NRoute/${MODE}_NRoute_power_TYP.txt -view PVT_1_80_V_TYP_VIEW
report_power -output ${REPORTS_DIR}/Post_NRoute/ -outfile ${REPORTS_DIR}/Post_NRoute/${MODE}_NRoute_power_BC.txt -view PVT_1_80_V_BC_VIEW
report_area > ${REPORTS_DIR}/Post_NRoute/${MODE}_NRoute_area.txt
report_timing > ${REPORTS_DIR}/Post_NRoute/${MODE}_NRoute_timing.txt
report_ccopt_clock_trees > ${REPORTS_DIR}/Post_NRoute/${MODE}_NRoute_clock_trees.txt
report_ccopt_skew_groups > ${REPORTS_DIR}/Post_NRoute/${MODE}_NRoute_skew_groups.txt



#====================Verify Drc Post Route==========================

set_verify_drc_mode -disable_rules {} -check_ndr_spacing auto -check_only default -check_same_via_cell true -exclude_pg_net false -ignore_trial_route false -ignore_cell_blockage false -use_min_spacing_on_block_obs auto -report ${REPORTS_DIR}/Post_NRoute/Verify_Post_NRoute/${MODE}_I2CAndMemory.drc.rpt -limit 1000
verify_drc -report ${REPORTS_DIR}/Post_NRoute/Verify_Post_NRoute/${MODE}_I2CAndMemory.drc.rpt


#=====================Verify Connectivity Post Route===========================

verifyConnectivity -type all -report ${REPORTS_DIR}/Post_NRoute/Verify_Post_NRoute/${MODE}_I2CAndMemory.conn.rpt -error 1000 -warning 50

#======================Verify Antenna=======================================
verifyProcessAntenna -report ${REPORTS_DIR}/Post_NRoute/Verify_Post_NRoute/${MODE}_I2CAndMemory.antenna.rpt -detailed -error 1000


#======================Metal Fill Post NRoute=============================
setMetalFill -layer MET1 -opcActiveSpacing 0.230 -minDensity 10.00
setMetalFill -layer MET2 -opcActiveSpacing 0.280 -minDensity 10.00
setMetalFill -layer MET3 -opcActiveSpacing 0.280 -minDensity 10.00
setMetalFill -layer MET4 -opcActiveSpacing 0.280 -minDensity 10.00
setMetalFill -layer METTP -opcActiveSpacing 0.460 -minDensity 10.00
setMetalFill -layer METTPL -opcActiveSpacing 2.500 -minDensity 10.00
addMetalFill -layer { MET1 MET2 MET3 MET4 METTP METTPL } -net { gnd vdd } > ${REPORTS_DIR}/Post_NRoute/Verify_Post_NRoute/${MODE}_I2CAndMemory.Metal_Fill.rpt


#=====================Verify Metal Fill Post NRoute===========================

setMetalFill -layer MET1 -windowSize 100.000 100.000 -windowStep 50.000 10.000 -minDensity 10.000 -maxDensity 80.000
setMetalFill -layer MET2 -windowSize 100.000 100.000 -windowStep 50.000 10.000 -minDensity 10.000 -maxDensity 80.000
setMetalFill -layer MET3 -windowSize 100.000 100.000 -windowStep 50.000 10.000 -minDensity 10.000 -maxDensity 80.000
setMetalFill -layer MET4 -windowSize 100.000 100.000 -windowStep 50.000 10.000 -minDensity 10.000 -maxDensity 80.000
setMetalFill -layer METTP -windowSize 100.000 100.000 -windowStep 50.000 10.000 -minDensity 10.000 -maxDensity 80.000
setMetalFill -layer METTPL -windowSize 100.000 100.000 -windowStep 50.000 10.000 -minDensity 10.000 -maxDensity 80.000
verifyMetalDensity -report ${REPORTS_DIR}/Post_NRoute/Verify_Post_NRoute/${MODE}_I2CAndMemory.density.rpt

saveDesign ${SAVES_DIR}/Top_${MODE}_5_Post_NRoute_Pre_Sign_Off.enc

#======================Sign OFF==============================
setMultiCpuUsage -remoteHost 4
setExtractRCMode -engine postRoute -effortLevel high -localCpu 4
extractRC
setExtractRCMode -engine postRoute -effortLevel signoff -coupled true -lefTechFileMap [glob -nocomplain extLogDir/extr.I2CAndMemory.layermap.log]
extractRC 
signoffTimeDesign -noEcoDB -reportOnly -outDir ${REPORTS_DIR}/Sign_Off_Timing_Reports/

