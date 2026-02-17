# =============================================================
# JasperGold TCL script for linting + elaboration
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

