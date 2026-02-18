

//--CUSTOM SEQUENCES--

  class i2c_virtual_master_write_spec_address extends i2c_virtual_base_sequence;
  `uvm_object_utils(i2c_virtual_master_write_spec_address)

  i2c_master_write_spec_address  m_seq;
  
  extern function new(string name = "i2c_virtual_master_write_spec_address");
  extern virtual task body();
endclass

  function i2c_virtual_master_write_spec_address:: new(string name = "i2c_virtual_master_write_spec_address");
    super.new(name);
  endfunction

  task i2c_virtual_master_write_spec_address:: body();
    m_seq = i2c_master_write_spec_address::type_id::create("m_seq");
    fork
      begin
        if(!m_seq.randomize() with {
          number_of_bytes == local::number_of_bytes;
        })
        `uvm_fatal("RNDERR", "Failed to randomize master sequence")
        m_seq.start(p_sequencer.m_seqr, this);
      end
    join
  endtask

 class i2c_virtual_master_read_spec_address extends i2c_virtual_base_sequence;
  `uvm_object_utils(i2c_virtual_master_read_spec_address)

  i2c_master_read_spec_address  m_seq;
  
  extern function new(string name = "i2c_virtual_master_read_spec_address");
  extern virtual task body();
endclass

  function i2c_virtual_master_read_spec_address:: new(string name = "i2c_virtual_master_read_spec_address");
    super.new(name);
  endfunction

  task i2c_virtual_master_read_spec_address:: body();
    m_seq = i2c_master_read_spec_address::type_id::create("m_seq");
    fork
      begin
        if(!m_seq.randomize() with {
          number_of_bytes == local::number_of_bytes;
        })
        `uvm_fatal("RNDERR", "Failed to randomize master sequence")
        m_seq.start(p_sequencer.m_seqr, this);
      end
    join
  endtask



