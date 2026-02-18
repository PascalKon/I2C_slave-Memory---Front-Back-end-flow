class i2c_all_in_one_test extends i2c_base_test;
  int N = 36;
 
  `uvm_component_utils(i2c_all_in_one_test)

  // those are master sequences 
  i2c_master_start_byte m_start_byte; //(generates a START condition + START byte).
  i2c_master_high_speed_mode m_high_speed_mode; ///(switch to High-Speed mode).
  // those are virtual sequences
  i2c_master_write_spec_address_with_reg_order seq1;
  i2c_master_read_spec_address_with_reg_order seq2;
  i2c_master_read_spec_address_with_reg_order_adc seq3;
  i2c_master_write_all_address_with_reg_order seq4;
  i2c_master_write_invalid_address seq5;
  i2c_master_write_invalid_register seq6;
  i2c_write_adc_regs seq7;
  i2c_master_read_spec_address_with_adc_regs_adc seq8;
  i2c_master_write_spec_address seq9; //(virtual write sequence).
  i2c_master_read_spec_address seq10; //(virtual read sequence).

  extern function new(string name = "i2c_all_in_one_test", uvm_component parent=null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void start_of_simulation_phase(uvm_phase phase);
  extern virtual task run_phase (uvm_phase phase);
  extern virtual task bus_setup();
endclass 

//-------------------------------------------------------------------------------------------------------------
function i2c_all_in_one_test:: new(string name = "i2c_all_in_one_test", uvm_component parent=null);    
  super.new(name,parent);
endfunction // new

//-------------------------------------------------------------------------------------------------------------
// Its super.build runs also the base test build phase meaning connecntin the vifs handlers to the agents/drivers
function void i2c_all_in_one_test:: build_phase(uvm_phase phase);
  super.build_phase(phase);

  //Sequences are instantiated here.
  //These are registered with the UVM factory (::type_id::create).
  m_start_byte = i2c_master_start_byte::type_id::create("m_start_byte");
  m_high_speed_mode = i2c_master_high_speed_mode::type_id::create("m_high_speed_mode");

  seq1 = i2c_master_write_spec_address_with_reg_order::type_id::create("seq1");
  seq2 = i2c_master_read_spec_address_with_reg_order::type_id::create("seq2");
  seq3 = i2c_master_read_spec_address_with_reg_order_adc::type_id::create("seq3");
  seq4 = i2c_master_write_all_address_with_reg_order::type_id::create("seq4");
  seq5 = i2c_master_write_invalid_address::type_id::create("seq5");
  seq6 = i2c_master_write_invalid_register::type_id::create("seq6");
  seq7 = i2c_write_adc_regs::type_id::create("seq7");
  seq8 = i2c_master_read_spec_address_with_adc_regs_adc::type_id::create("seq8");
  seq9 = i2c_master_write_spec_address::type_id::create("v_seq9");
  seq10 = i2c_master_read_spec_address::type_id::create("v_seq9");
   
endfunction // build_phasen

//-------------------------------------------------------------------------------------------------------------
function void i2c_all_in_one_test:: start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
endfunction // start_of_simulation_phase

//-------------------------------------------------------------------------------------------------------------
task i2c_all_in_one_test:: run_phase (uvm_phase phase);
  super.run_phase(phase);
  phase.raise_objection(this);
  #(cfg.get_delay(FULL)*100);
  

//--------------------------------------
//-------------WRITE TESTS--------------
//--------------------------------------

// * Test Simple Write * 
///*
  for (int i=0; i<N; i++) begin
  
    bus_setup();
    seq9.start(env.v_seqr.m_seqr);
    cfg.master_finish.wait_trigger();

  end

  #(cfg.get_delay(FULL)*100);
//*/

// * Test Write Sepc Adress with reg order no adc update *
///*
  for (int i=0; i<1; i++) begin
  
    bus_setup();
    seq1.start(env.v_seqr.m_seqr);
    cfg.master_finish.wait_trigger();

  end

  #(cfg.get_delay(FULL)*100);
//*/

// * Test Write ALL Adresses with reg order no adc update *
///*
  for (int i=0; i<1; i++) begin
  
    bus_setup();
    seq4.start(env.v_seqr.m_seqr);
    cfg.master_finish.wait_trigger();

  end

  #(cfg.get_delay(FULL)*100);
//*/

//* Test Write Invalid Adress *
///*
 for (int i=0; i<1; i++) begin
  
    bus_setup();
    seq5.start(env.v_seqr.m_seqr);
    cfg.master_finish.wait_trigger();

  end

  #(cfg.get_delay(FULL)*100);
//*/

//* Test Write Invalid Register *
///*
 for (int i=0; i<1; i++) begin
  
    bus_setup();
    seq6.start(env.v_seqr.m_seqr);
    cfg.master_finish.wait_trigger();

  end

  #(cfg.get_delay(FULL)*100);
//*/

//* Test Write Adc Registers *
///*
 for (int i=0; i<i; i++) begin
  
    bus_setup();
    seq7.start(env.v_seqr.m_seqr);
    cfg.master_finish.wait_trigger();

  end

  #(cfg.get_delay(FULL)*100);
//*/

//--------------------------------------
//-------------READ TESTS---------------
//--------------------------------------

// * Test Simple Read *
///*
  for (int i=0; i<N; i++) begin
  
    bus_setup();
    seq10.start(env.v_seqr.m_seqr);
    cfg.master_finish.wait_trigger();

  end
//*/

// * Test Read Sepc Adress with reg order and No adc update *
///* 
  for (int i=0; i<1; i++) begin
  
    bus_setup();
    seq2.start(env.v_seqr.m_seqr);
    cfg.master_finish.wait_trigger();

  end

  #(cfg.get_delay(FULL)*100);
//*/


// * Test Read Sepc Adress with reg order and adc update *
///* 
  for (int i=0; i<1; i++) begin
  
    bus_setup();
    seq3.start(env.v_seqr.m_seqr);
    cfg.master_finish.wait_trigger();

  end

  #(cfg.get_delay(FULL)*100);
//*/

// * Test Read Sepc Adress with ADC regs and adc update *
///* 
  for (int i=0; i<1; i++) begin
    bus_setup();
    seq8.start(env.v_seqr.m_seqr);
    cfg.master_finish.wait_trigger();

  end

  #(cfg.get_delay(FULL)*100);
//*/

 
  #(cfg.get_delay(FULL)*100);
  phase.drop_objection (this);
endtask // run_phase

//-------------------------------------------------------------------------------------------------------------
task i2c_all_in_one_test:: bus_setup();
  if (cfg.high_speed_only && cfg.current_speed_mode == cfg.default_speed_mode) begin
    if (!m_high_speed_mode.randomize()) `uvm_error("RNDERR", "High Speed Mode Sequence Randomization failed")
    m_high_speed_mode.start(env.master_agent.m_seqr);
  end
endtask // bus_setup