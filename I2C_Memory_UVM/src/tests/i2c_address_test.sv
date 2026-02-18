class i2c_address_test extends i2c_base_test;
  int number_of_bytes = 1;
  //int spec_address = 7'h09; // 7-bit address + R/W bit

  `uvm_component_utils(i2c_address_test)

  // those are master sequences 
  i2c_master_start_byte m_start_byte; //(generates a START condition + START byte).
  i2c_master_high_speed_mode m_high_speed_mode; ///(switch to High-Speed mode).
  i2c_master_write_all_address_with_reg_order seq4;
  i2c_master_read_spec_address_with_reg_order_adc seq3;
 
  extern function new(string name = "i2c_address_test", uvm_component parent=null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void start_of_simulation_phase(uvm_phase phase);
  extern virtual task run_phase (uvm_phase phase);
  extern virtual task bus_setup();
endclass 

//-------------------------------------------------------------------------------------------------------------
function i2c_address_test:: new(string name = "i2c_address_test", uvm_component parent=null);    
  super.new(name,parent);
endfunction // new

//-------------------------------------------------------------------------------------------------------------
// Its super.build runs also the base test build phase meaning connecntin the vifs handlers to the agents/drivers
function void i2c_address_test:: build_phase(uvm_phase phase);
  super.build_phase(phase);
  //Sequences are instantiated here.
  m_start_byte = i2c_master_start_byte::type_id::create("m_start_byte");
  m_high_speed_mode = i2c_master_high_speed_mode::type_id::create("m_high_speed_mode");
  //These are registered with the UVM factory (::type_id::create).
  seq4 = i2c_master_write_all_address_with_reg_order::type_id::create("seq4");
  seq3 = i2c_master_read_spec_address_with_reg_order_adc::type_id::create("seq3"); 
endfunction // build_phasen

//-------------------------------------------------------------------------------------------------------------
function void i2c_address_test:: start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
endfunction // start_of_simulation_phase

//-------------------------------------------------------------------------------------------------------------
task i2c_address_test:: run_phase (uvm_phase phase);
  super.run_phase(phase);
  phase.raise_objection(this);
  #(cfg.get_delay(FULL)*100);  
//--------------------------------------
//-------------WRITE PART--------------
//--------------------------------------

// * Test Write ALL Adresses with reg order no adc update *
//*
  for (int i=0; i<1; i++) begin
    //bus_setup();
    seq4.start(env.v_seqr.m_seqr);
    cfg.master_finish.wait_trigger();

  end
  #(cfg.get_delay(FULL)*100);
//*/

//--------------------------------------
//-------------READ PART--------------
//--------------------------------------

// * Test Read Sepc Adress with reg order and adc update *
//* 
  for (int i=0; i<1; i++) begin
  
    //bus_setup();
    seq3.start(env.v_seqr.m_seqr);
    cfg.master_finish.wait_trigger();

  end
  #(cfg.get_delay(FULL)*100);
//*/

  phase.drop_objection (this);
endtask // run_phase

//-------------------------------------------------------------------------------------------------------------
task i2c_address_test:: bus_setup();
  if (cfg.high_speed_only && cfg.current_speed_mode == cfg.default_speed_mode) begin
    if (!m_high_speed_mode.randomize()) `uvm_error("RNDERR", "High Speed Mode Sequence Randomization failed")
    m_high_speed_mode.start(env.master_agent.m_seqr);
  end
endtask // bus_setup