class i2c_coverage extends uvm_component;
	`uvm_component_utils(i2c_coverage)
	
  i2c_cfg cfg; 

  covergroup i2c_reg_access_cg with function sample(
  bit [6:0] target_address,  // i2c address used (7-bit)
  bit [5:0] reg_addr,        // register number 0–35
  bit write_or_read               // 1=write, 0=read
  );

  // --- Coverpoint 1: DUT Register accessed ---
  cp_register: coverpoint reg_addr {
    bins all_registers[] = {[0:35]}; // all registers
  }

  // --- Coverpoint 2: Operation type ---
  cp_operation: coverpoint write_or_read {
    bins write = {0};
    bins read  = {1};
  }

  // --- Coverpoint 3: Target address (8 unique combinations) ---
  cp_i2c_address: coverpoint target_address {
    // assuming 8 possible addresses, for example 7'h08 to 7'h0F
    bins dut_addresses[] = {7'h08, 7'h09, 7'h0A, 7'h0B, 7'h0C, 7'h0D, 7'h0E, 7'h0F};
  }

  // --- Cross coverage: Operation per Register ---
  reg_vs_operation: cross cp_register, cp_operation {
    ignore_bins ignore_ADC_write = binsof(cp_register) intersect {3,4,5} && binsof(cp_operation) intersect {1'b0}; // ignore ADC write attempts
    // this ensures both read and write occur per register
  }

  // --- Cross coverage: Address, Write , And Regs ---
  addr_vs_operation: cross cp_i2c_address, cp_operation, cp_register{
    ignore_bins ignore_Read_Operation = binsof(cp_operation) intersect {1'b1} ; // ignore ADC write attempts
    ignore_bins ignore_ADC_Regs = binsof(cp_register) intersect {3,4,5}; // ignore ADC write attempts
    // shows that all addresses were tested for both read/write
  }

  endgroup : i2c_reg_access_cg



  extern function new(string name, uvm_component parent);
  extern virtual function void build_phase(uvm_phase phase);
endclass

function i2c_coverage::new(string name, uvm_component parent);
  super.new(name, parent);
  i2c_reg_access_cg = new();
endfunction // i2c_coverage::new

function void  i2c_coverage::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  if (!uvm_config_db#(i2c_cfg)::get(this, "", "cfg", cfg))   
    `uvm_fatal("build_phase", "cfg wasn't set through config db");
endfunction // i2c_coverage::build_phase

