# ----------------------------------------
# Jasper Version Info
# tool      : Jasper 2022.09
# platform  : Linux 5.14.0-570.52.1.el9_6.x86_64
# version   : 2022.09 FCS 64 bits
# build date: 2022.09.22 12:46:24 UTC
# ----------------------------------------
# started   : 2026-02-05 13:53:54 EET
# hostname  : cn88.it.auth.gr.(none)
# pid       : 2891619
# arguments : '-label' 'session_0' '-console' '//127.0.0.1:36467' '-style' 'windows' '-data' 'AAAA7nicVY6xCsJAEETfIYKlhV8hKCIIFils7JSggq0c5tBISMScCDb6qf7JOZ4EdJadWZa5uTVA8gghENG6i7osWLJmLk7ZSmHMRD1lxIw9lgxHqckx4MKQHC+2XKVHTQdtI8zrqySGX5jV80+h3Rg/d6j7irYUqoobO0WX1OKzqlK81+eZ9ikbuTtyex1UaO5x0staPhePa/a8AWzLIGo=' '-proj' '/home/p/paschalk/Desktop/I2C_Memory/I2C_Memory_UVM/jgproject/sessionLogs/session_0' '-init' '-hidden' '/home/p/paschalk/Desktop/I2C_Memory/I2C_Memory_UVM/jgproject/.tmp/.initCmds.tcl' 'jasper.tcl'
# =============================================================
# JasperGold TCL script for linting + elaboration + formal checks
# =============================================================

set TOP "I2CAndMemory"   ;# <-- Change this to your actual top module name

clear -all

# --- Add design sources ---
analyze -sv {
    ./src/I2C_Slave.sv
    ./src/Memory.sv
    ./src/I2C_Memory.sv
    ./src/Assertions.sv
    ./src/Memory_bind.sv
}

# --- Elaborate top-level design (change top name if needed) ---
puts "=== Elaborating top module ==="
elaborate -top I2CAndMemory

clock -clear
clock -both_edges clk; 

reset -clear
reset -expression ~rst_n 

# 5. Check for basic setup/syntax/signal issues
# (sanity_check is valid in JasperGold; check_design is NOT)
sanity_check -waiver -add clk -type simple_clk

puts "=== JasperGold flow complete ==="

elaborate -top -top
elaborate -top I2C_Slave
prove -bg -all
