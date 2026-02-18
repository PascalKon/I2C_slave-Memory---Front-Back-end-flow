class i2c_virtual_base_sequence extends uvm_sequence;
  `uvm_object_utils(i2c_virtual_base_sequence) //Registers this class with the UVM factory.Allows creation via ::type_id::create().
  `uvm_declare_p_sequencer(i2c_virtual_sequencer)// Declares a handle to the sequencer of type i2c_virtual_sequencer.

  i2c_cfg cfg;

  //handles to master and slave base sequences
  i2c_master_base_sequence m_seq; 
  i2c_slave_base_sequence  s_seq;

  rand transaction_type_enum transaction_type; // READ or WRITE
  rand bit[7:0] data; //the byte to be written or read
  rand bit      ack_nack; //ACK (0) or NACK (1)

  rand bit      start_condition; //flags for start
  rand bit      stop_condition; //flags for stop
  rand int      delay;// cycle delay between transactions

  rand int      clock_stretch_data[7:0]; //how many cycles slave stretches SCL for each data bit.
  rand int      clock_stretch_ack; //how many cycles slave stretches SCL for each data bit.

  rand int      number_of_bytes; //How many bytes are transferred in one transaction.

  constraint c_virtual_defaults {
    soft (transaction_type == WRITE);
    soft (start_condition == 0);
    soft (stop_condition == 0);
    soft (delay == 0);
    soft (clock_stretch_ack == 0);
    foreach (clock_stretch_data[i]) {
      soft (clock_stretch_data[i] == 0);
    }
    number_of_bytes > 0;
    soft (number_of_bytes < 8);
  }

  extern function new(string name = "i2c_virtual_base_sequence");
  extern virtual task body();
endclass

function i2c_virtual_base_sequence:: new(string name = "i2c_virtual_base_sequence");
  super.new(name);
endfunction // i2c_sequence::new

task i2c_virtual_base_sequence:: body();
  m_seq = i2c_master_base_sequence :: type_id :: create ("m_seq"); // factory Creates Matsers n Slave sequneces
  s_seq = i2c_slave_base_sequence :: type_id :: create ("s_seq");

  fork // master and slave run concurrently
    begin
      if (!m_seq.randomize() with { // randomize m_seq with constraints copied from the Virtual Sequence
        transaction_type == local::transaction_type;
        data == local::data;
        ack_nack == local::ack_nack;
        start_condition == local::start_condition;
        stop_condition == local::stop_condition;
        delay == local::delay;
      })
      `uvm_fatal("RNDERR", "Failed to randomize master sequence")
      m_seq.start(p_sequencer.m_seqr, this); //The master sequencer inside virutal sequencer
    end
    begin
      if (!s_seq.randomize() with {
        if (local::transaction_type == WRITE) transaction_type == READ;
        else if (local::transaction_type == READ) transaction_type == WRITE;
        data == local::data;
        ack_nack == local::ack_nack;
        clock_stretch_ack == local::clock_stretch_ack;
        foreach (local::clock_stretch_data[i]) {
          clock_stretch_data[i] == local::clock_stretch_data[i];
        }
      })
      `uvm_fatal("RNDERR", "Failed to randomize master sequence")
      s_seq.start(p_sequencer.s_seqr, this);
    end
  join
endtask

// class to make custom sequences by passing different types 
//to the virtual sequence, we give a type of a master sequence and a type of a slave sequence, if no type is
// given it will default to the base sequences
class i2c_virtual_sequence#(type MSEQ=i2c_master_base_sequence, type SSEQ=i2c_slave_base_sequence) extends i2c_virtual_base_sequence;
  `uvm_object_param_utils(i2c_virtual_sequence#(MSEQ, SSEQ))

  MSEQ m_seq; // Overides master/slave handles with parametrized types
  SSEQ s_seq;

  extern function new(string name = "i2c_virtual_sequence");
  extern virtual task body();
endclass

function i2c_virtual_sequence:: new(string name = "i2c_virtual_sequence");
  super.new(name);
endfunction // i2c_sequence::new

task i2c_virtual_sequence:: body();
  m_seq = MSEQ :: type_id :: create ("m_seq");
  s_seq = SSEQ :: type_id :: create ("s_seq");

  fork // onyl constrain is number of bytes
    begin
      if (!m_seq.randomize() with {
        number_of_bytes == local::number_of_bytes;
      })
      `uvm_fatal("RNDERR", "Failed to randomize master sequence")
      m_seq.start(p_sequencer.m_seqr, this);
    end
    begin
      if (!s_seq.randomize() with {
        number_of_bytes == local::number_of_bytes;
      })
      `uvm_fatal("RNDERR", "Failed to randomize master sequence")
      s_seq.start(p_sequencer.s_seqr, this);
    end
  join
endtask