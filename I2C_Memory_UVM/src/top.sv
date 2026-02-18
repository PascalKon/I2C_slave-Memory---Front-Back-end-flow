
`include "uvm_macros.svh" //brings in UVM macros like uvm_component_utils, etc.
`include "i2c_env_pkg.sv" //contains the I²C environment (drivers, monitors, agents, env).
`include "I2C_Memory.sv" //contains the I²C sequence items, sequences, and other related classes.
`include "I2C_Slave.sv" //contains the I²C interface definition.
`include "Memory.sv" //contains the DUT (I²C Memory model).
`include "Assertions.sv"
`include "Memory_bind.sv" //binds the assertions to the Memory module.

module top;
  
  import uvm_pkg::*; //makes the classes/types from those packages accessible here.
  import i2c_pkg::*;
  import i2c_env_pkg::*;

  tri1 sda;
  tri1 scl;
    
  bit system_clock, reset_n;
  
  // 25MHz clock freq for timescale 1ns
  parameter CLK_CYCLE = 20; 
  localparam delay_reset = 105;
  string logfile = "dump.vcd";

  // ------------------------------------------------------------
  // 4. Device address strap pins and reset
  // ------------------------------------------------------------
  logic A_0, A_1, A_2;

  // ------------------------------------------------------------
  // 5. Analogue-block side of the top (just tie-offs for TB)
  // ------------------------------------------------------------
  logic [7:0] ADC_in   [0:2];// = '{default:8'h01};

  logic [7:0] DAC_out  [0:30];
  logic [2:0] CS_control [0:2];
  logic  CP_reset   [0:2];
  logic  Timer_EN   [0:2];
  logic  Timer_FEN  [0:2];
  logic  Amp_EN     [0:2];

  // DUT
  I2CAndMemory dut (
    .clk(system_clock),
    .rst_n(reset_n),
    .SCL(scl),
    .SDA(sda),

    .A_0        (A_0),
    .A_1        (A_1),
    .A_2        (A_2),

    .ADC_in     (ADC_in),
    .DAC_out    (DAC_out),
    .CS_control (CS_control),
    .CP_reset   (CP_reset),
    .Timer_EN   (Timer_EN),
    .Timer_FEN  (Timer_FEN),
    .Amp_EN     (Amp_EN)
);

  // Clock Generation
  initial begin
    system_clock =0;
    forever #(CLK_CYCLE) system_clock = ~system_clock;
  end 

  // Reset Initialization
  initial begin
    reset_n = 0;
    #delay_reset;
    reset_n = 1;
    #delay_reset;
    reset_n = 0;
    #delay_reset; //async reset
    reset_n = 1;
  end
  
  i2c_if i2c_vif_master (system_clock,reset_n);
  i2c_if i2c_vif_slave  (system_clock,reset_n);
  

  // Connect UVC logic to Top Pull-Up wire (tri1)
  assign A_0 = i2c_vif_master.uvc_selec_address[0]; //Connect the Address selection bits from the interface to the DUT.
  assign A_1 = i2c_vif_master.uvc_selec_address[1];
  assign A_2 = i2c_vif_master.uvc_selec_address[2];
  assign ADC_in = i2c_vif_master.uvc_ADC_out; //Connect the ADC outputs from the interface to the DUT.
  assign sda = i2c_vif_master.uvc_sda; //Each UVC (master, slave) drives its SDA/SCL into the top-level wires.
  assign scl = i2c_vif_master.uvc_scl;
  assign sda = i2c_vif_slave.uvc_sda;
  assign scl = i2c_vif_slave.uvc_scl;


  // Connect Top Pull-Up to internal IF wires
  assign i2c_vif_master.sda = sda; //The top-level wires are fed back to the UVCs → so everyone sees the same bus.
  assign i2c_vif_master.scl = scl;
  assign i2c_vif_slave.sda = sda;
  assign i2c_vif_slave.scl = scl;

  // Set Interface
  initial begin //Places the virtual interfaces into the UVM config DB. but only for uvm_test_top level thats why it null
    uvm_config_db#(virtual i2c_if)::set(null,"uvm_test_top", "i2c_vif_master", i2c_vif_master);
    uvm_config_db#(virtual i2c_if)::set(null,"uvm_test_top", "i2c_vif_slave", i2c_vif_slave);
  end
  
  // invoking simulation phases of all components
  initial begin
    run_test(""); //"" means → look for the test name from command line (+UVM_TESTNAME=my_test).
  end
  // Waves
  initial begin
    if (!$value$plusargs("DUMPNAME=%s", logfile))
      $warning("DUMPNAME not specified");
    $dumpfile(logfile); 
    $dumpvars;
  end

endmodule 

