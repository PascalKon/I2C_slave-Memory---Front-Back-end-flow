#!/bin/bash
#source /mnt/apps/prebuilt/eda/cadence-2022-23.bash
#xrun ../../component_tbs/testbench.sv -svseed random -access +rwc -gui -timescale 1ns/10ps -f ../filelists/rtl.f -f ../filelists/rtl_tb.f -coverage all

xrun -sv /home/p/paschalk/Desktop/I2C_Memory/component_tbs/I2C_Memory_tb.sv -access +rwc -gui -timescale 1ns/10ps -f  /home/p/paschalk/Desktop/I2C_Memory/filelists/rtl.f -f /home/p/paschalk/Desktop/I2C_Memory/filelists/rtl_tb.f 


