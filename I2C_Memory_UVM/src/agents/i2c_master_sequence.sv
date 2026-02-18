//We inherit from base sequence and build inside body() 
//a master base sequence object to actually make the item level transactions. This one 
//performs write operations on the slave device
class i2c_master_write_sequence extends i2c_master_base_sequence;// prefomr write on slave
  `uvm_object_utils(i2c_master_write_sequence)

  i2c_master_base_sequence    seq;

  rand int                    number_of_bytes;
  rand bit                    ignore_register; // flag to skip sending register address(some devices dont use it)

  // Item fields for Master Seq
  rand bit[7:1]               target_address;
  rand bit[7:0]               register_address;
  rand bit                    stop_condition;
  rand bit[7:0]               data[];// dynamic array of payload bytes
  rand int                    delay[]; //array of delays; note later sizing number_of_bytes+2 because delays include target and register bytes.
  rand bit[7:0]               ADC_out[0:2];
  rand bit                    drive_adc[0:2];
  rand bit                    selec_address[0:2]; // 3 LSB bits of the target address to select

  constraint c_master_write_target {
    soft ( !(target_address inside {RESERVED_ADDRESSES}) );
    soft (target_address inside {7'h08, 7'h09, 7'h0A, 7'h0B,
                               7'h0C, 7'h0D, 7'h0E, 7'h0F}); // avoid general call address
  }
  constraint c_master_write_nob {
    number_of_bytes > 0;
    soft (number_of_bytes < 20); 
  }
  constraint c_master_write_array_size {
    data.size() == number_of_bytes;
    delay.size() == number_of_bytes+2;// +2 for target and register address bytes
  }
  constraint c_master_write_delay {
    foreach(delay[i]) { 
      delay[i] >= 0; 
      soft (delay[i] == 0); 
    }
  }
  constraint c_master_write_ignore_reg {
    soft (ignore_register == 'b0); 
  }
  constraint c_master_write_reg_range {
    soft (register_address inside {[0:36]});
  }
  constraint c_master_adc_values {
    foreach (ADC_out[i]) {
      ADC_out[i] >= 0 && ADC_out[i] <= 8'hFF;
    }
  }
  constraint c_master_drive_adc {
    foreach (drive_adc[i]) {
      soft (drive_adc[i] == 1'b0);
    }
  }
  constraint c_master_selec_address {
    foreach (selec_address[i]) {
      soft (selec_address[i] == 1'b0);
    }
  }

  
  extern function new(string name = "i2c_master_write_sequence");
  extern virtual task body();
endclass // i2c_master_write_sequence

  //-------------------------------------------------------------------
  function i2c_master_write_sequence:: new(string name = "i2c_master_write_sequence");
      super.new(name);
  endfunction // i2c_master_write_sequence::new

  //-------------------------------------------------------------------
  task i2c_master_write_sequence:: body();
    int exit_flag;

    seq = i2c_master_base_sequence::type_id::create("seq");// create seq via factory

    forever begin
      exit_flag = 0;
      
      // Send target address
      if ( !seq.randomize() with { 
          transaction_type == WRITE;
          start_condition == 'b1;
          data == { target_address, `W };
          delay == local::delay[0];
          foreach (drive_adc[i]) {drive_adc[i] == local::drive_adc[i];}
          foreach (ADC_out[i]) { ADC_out[i] == local::ADC_out[i];}
          foreach (selec_address[i]) {selec_address[i] == local::selec_address[i];}
        }
      ) `uvm_error(get_type_name(), "Write Sequence Randomization failed at Target Adress")
      seq.start(p_sequencer, this);
      `uvm_info(get_name(), "Sent target address (W)", UVM_MEDIUM)
      exit_flag = seq.check_exit();
      if (exit_flag == 1) continue;
      if (exit_flag == 2) return;

      // Send register address
      if (!ignore_register) begin // if we want specific register
        if ( !seq.randomize() with { 
            transaction_type == WRITE;
            data == register_address;
            delay == local::delay[1];
            foreach (selec_address[i]) {selec_address[i] == local::selec_address[i];}
          }
        ) `uvm_error(get_type_name(), "Write Sequence Randomization failed at Register Address")
        seq.start(p_sequencer, this);
        `uvm_info(get_name(), "Sent register address", UVM_MEDIUM)
        exit_flag = seq.check_exit();
        if (exit_flag) return;
      end

      for ( int i = 0; i < number_of_bytes; i++) begin
        if ( !seq.randomize() with { 
            transaction_type == WRITE;
            data == local::data[i];
            if (local::i == number_of_bytes-1)  {
              stop_condition == local::stop_condition;
            }
            delay == local::delay[i+2];
            foreach (selec_address[i]) {selec_address[i] == local::selec_address[i];}
          }
        ) `uvm_error(get_type_name(), $sformatf("Write Sequence Randomization failed at %3d", i))
        seq.start(p_sequencer, this);
        `uvm_info(get_name(), $sformatf("Sent Data Byte %03d", i), UVM_MEDIUM)
        exit_flag = seq.check_exit();
        if (exit_flag) return;
      end

      // SEQUENCE FINISHED
      break; // or return;
    end

  endtask 

//We inherit from base sequence and build inside body() 
//a master base sequence object to actually make the item level transactions. This one 
//performs read operations from the slave device
class i2c_master_read_sequence extends i2c_master_base_sequence;
  `uvm_object_utils(i2c_master_read_sequence)

  i2c_master_base_sequence    seq;
  rand int                    number_of_bytes;
  rand bit                    ignore_register;

  // Item fields for Master Seq
  rand bit[7:1]               target_address;
  rand bit[7:0]               register_address;
  rand bit                    stop_condition;
  rand bit[7:0]               ack_nack[];
  rand int                    delay[];
  rand bit[7:0]               ADC_out[0:2];
  rand bit                    drive_adc[0:2];

  constraint c_master_read_target {
    soft ( !(target_address inside {RESERVED_ADDRESSES}) );
  }
  constraint c_master_read_nob {
    number_of_bytes > 0;
    soft (number_of_bytes < 20); 
  }
  constraint c_master_read_array_size {
    ack_nack.size() == number_of_bytes-1; // because last byte is NACK
    delay.size() == number_of_bytes+3;// +3 for target (W), register, target(R) bytes
  }
  constraint c_master_read_delay {
    foreach(delay[i]) { 
      delay[i] >= 0; 
      soft (delay[i] == 0); 
    } 
  }
  constraint c_master_write_ignore_reg {
    soft (ignore_register == 'b0);
  }
  constraint c_master_read_reg_range {
    register_address inside {[0:36]};
  }
  constraint c_master_adc_values {
    foreach (ADC_out[i]) {
      ADC_out[i] >= 0 && ADC_out[i] <= 8'hFF;
    }
  }
  constraint c_master_drive_adc {
    foreach (drive_adc[i]) {
      soft (drive_adc[i] == 1'b0);
    }
  }
  constraint c_master_selec_address {
    foreach (selec_address[i]) {
      soft (selec_address[i] == 1'b0);
    }
  }
  
  extern function new(string name = "i2c_master_read_sequence");
  extern virtual task body();
endclass // i2c_master_read_sequence

  //-------------------------------------------------------------------
  function i2c_master_read_sequence:: new(string name = "i2c_master_read_sequence");
      super.new(name);
  endfunction //i2c_sequence::new

  //-------------------------------------------------------------------
  task i2c_master_read_sequence:: body();
    int exit_flag;

    seq = i2c_master_base_sequence::type_id::create("seq");

    forever begin
      exit_flag = 0;

      // Send target address
      if ( !seq.randomize() with { 
          transaction_type == WRITE;
          start_condition == 'b1;
          data == { target_address, `W };
          delay == local::delay[0];
          foreach (drive_adc[i]) {drive_adc[i] == local::drive_adc[i];}
          foreach (ADC_out[i]) { ADC_out[i] == local::ADC_out[i];}
          foreach (selec_address[i]) {selec_address[i] == local::selec_address[i];}
        }
      ) `uvm_error(get_type_name(), "Read Sequence Randomization failed at Target Adress")
      seq.start(p_sequencer, this);
      `uvm_info(get_name(), "Sent target address (W)", UVM_MEDIUM)
      exit_flag = seq.check_exit();
      if (exit_flag == 1) continue;
      if (exit_flag == 2) return;

      // Send register address
      if (!ignore_register) begin
        if ( !seq.randomize() with { 
            transaction_type == WRITE;
            data == register_address;
            delay == local::delay[1];
            foreach (selec_address[i]) {selec_address[i] == local::selec_address[i];}
            foreach (ADC_out[i]) { ADC_out[i] == local::ADC_out[i];}
          }
        ) `uvm_error(get_type_name(), "Read Sequence Randomization failed at Register Address")
        seq.start(p_sequencer, this);
        `uvm_info(get_name(), "Sent register address", UVM_MEDIUM)
        exit_flag = seq.check_exit();
        if (exit_flag) return;
      end

      // Send target address again (read)
      if ( !seq.randomize() with { 
          transaction_type == WRITE;//that is likely because the base sequence's item 
          //is always driven as a one-byte transfer and the transaction_type may represent
          //a higher-level semantic; but in essence this constructed item places {target_address, R}
          //onto the bus. 
          //(If base seq expectsWRITEvsREAD` semantics, double-check consistency — 
          //but the code intends to send the address with the correct R/W bit set.)
          start_condition == 'b1;
          data == { target_address, `R };
          delay == local::delay[2];
          foreach (selec_address[i]) {selec_address[i] == local::selec_address[i];}
          foreach (ADC_out[i]) { ADC_out[i] == local::ADC_out[i];}
        }
      )  `uvm_error(get_type_name(), "Read Sequence Randomization failed at Target Adress")
      seq.start(p_sequencer, this);
      `uvm_info(get_name(), "Sent target address (R)", UVM_MEDIUM)
      exit_flag = seq.check_exit();
      if (exit_flag) return;
      for ( int i = 0; i < number_of_bytes; i++) begin
        if ( !seq.randomize() with { 
            transaction_type == READ;
            if (local::i == number_of_bytes-1)  {
              ack_nack == `NACK;
              stop_condition == local::stop_condition;
            }
            delay == local::delay[i+3];
            foreach (selec_address[i]) {selec_address[i] == local::selec_address[i];}
            foreach (ADC_out[i]) { ADC_out[i] == local::ADC_out[i];}
          }
        ) `uvm_error(get_type_name(), $sformatf("Read Sequence Randomization failed at %3d", i))
        seq.start(p_sequencer, this);
        `uvm_info(get_name(), $sformatf("Read Data Byte %03d", i), UVM_MEDIUM)
        exit_flag = seq.check_exit();
        if (exit_flag) return;
      end

      // SEQUENCE FINISHED
      break; // or return;
    end
  endtask 

class i2c_master_start_byte extends i2c_master_base_sequence;
  `uvm_object_utils(i2c_master_start_byte)

  constraint c_master_start_byte {
    start_condition == 'b1;
    data == 8'b0000_0001;
  }

  function new(string name = "i2c_master_start_byte");
    super.new(name);
  endfunction
endclass

class i2c_master_high_speed_mode extends i2c_master_base_sequence;
  `uvm_object_utils(i2c_master_high_speed_mode)

  constraint c_master_high_speed_mode {
    start_condition == 'b1;
    data[7:3] == 5'b000_01;
  }

  function new(string name = "i2c_master_high_speed_mode");
    super.new(name);
  endfunction
endclass

// ================================================
// ----------------WRITE SEQUENCES------------------  
// ================================================



///Mine sequences for specific addresses and registers

//-------------------------------------------------------------------
//  WRITE SPECIFIC ADRESS WITH RADNOM REG NO ADC
//-------------------------------------------------------------------
class i2c_master_write_spec_address extends i2c_master_write_sequence;
  `uvm_object_utils(i2c_master_write_spec_address)

  constraint c_master_write_spec_address {
    stop_condition == 1'b1;
    target_address == 7'h8;
    number_of_bytes == 1;
    foreach (drive_adc[i]) drive_adc[i] == 1'b0;
    foreach (delay[j]) delay[j] == 0;
    foreach (selec_address[m]) selec_address[m] == target_address[m+1];
  }

  function new(string name = "i2c_master_write_spec_address");
    super.new(name);
  endfunction
  virtual task body();
      if (!randomize() with { // assign 3 LSBs
      }) `uvm_error("RAND", "Randomization failed for specific register")


      super.body(); // perform the actual write for this register
  endtask


endclass

//-------------------------------------------------------------------
// WRITE SPECIFIC ADRESS WITH REG ORDER NO ADC
//-------------------------------------------------------------------

class i2c_master_write_spec_address_with_reg_order extends i2c_master_write_sequence;
  `uvm_object_utils(i2c_master_write_spec_address_with_reg_order)

  constraint c_master_write_spec_address_with_reg_order {
    stop_condition == 'b1;
    target_address == 7'h9;
    number_of_bytes == 1;
    foreach (drive_adc[i]) drive_adc[i] == 1'b0;
    foreach (delay[j]) delay[j] == 0;
    foreach (selec_address[m]) selec_address[m] == target_address[m+1];
  }

  function new(string name = "i2c_master_write_spec_address_with_reg_order");
    super.new(name);
  endfunction
  virtual task body();
    int registers_to_write[$] = {0, 1, 2}; // Add first registers
    
    for (int r = 6; r <= 36; r++) begin// Exclude ADC regs 3,4,5
      registers_to_write.push_back(r);
    end

    foreach (registers_to_write[i]) begin
      
      if (!randomize() with {
        register_address == registers_to_write[i]; 
      }) `uvm_error("RAND", "Randomization failed for specific register")

      super.body(); // perform the actual write for this register
    end
  endtask
endclass

//-------------------------------------------------------------------
//  WRITE ALL ADRESSES WITH REG ORDER NO ADC
//-------------------------------------------------------------------

class i2c_master_write_all_address_with_reg_order extends i2c_master_write_sequence;
  `uvm_object_utils(i2c_master_write_all_address_with_reg_order)

  constraint c_master_write_all_address_with_reg_order {
    stop_condition == 'b1;
    number_of_bytes == 1;
    foreach (drive_adc[i]) drive_adc[i] == 1'b0;
    foreach (delay[j]) delay[j] == 0;
  }

  function new(string name = "i2c_master_write_all_address_with_reg_order");
    super.new(name);
  endfunction

  virtual task body();
    int registers_to_write[$] = {0, 1, 2}; // initial registers
    int adress_to_write[$] = '{7'h08, 7'h09, 7'h0A, 7'h0B,
                               7'h0C, 7'h0D, 7'h0E, 7'h0F};
    bit[2:0] local_addr_bits;
    bit[7:1] target_address_temp;

    // add rest registers
    for (int r = 6; r <= 36; r++)
      registers_to_write.push_back(r);

    foreach (adress_to_write[k]) begin
      target_address_temp = adress_to_write[k];
      local_addr_bits = target_address_temp[3:1]; // extract 3 LSBs

      `uvm_info(get_type_name(),
        $sformatf("Target Address = %h -> adress_selec = %b", 
                  target_address, local_addr_bits),
        UVM_MEDIUM)

      foreach (registers_to_write[i]) begin
        if (!randomize() with {
              register_address == registers_to_write[i];
              target_address == target_address_temp;
              foreach (selec_address[m]) selec_address[m] == local_addr_bits[m]; // assign 3 LSBs
            })
          `uvm_error("RAND", "Randomization failed for specific register")

        super.body(); // perform the actual write
      end
    end
  endtask
endclass

//-------------------------------------------------------------------
//  WRITE INVALID ADRESSES WITH RANDOM REGISTER NO ADC
//-------------------------------------------------------------------
class i2c_master_write_invalid_address extends i2c_master_write_sequence;
  `uvm_object_utils(i2c_master_write_invalid_address)

  constraint c_master_write_invalid_address {
    stop_condition == 'b1;
    number_of_bytes == 1;
    foreach (drive_adc[i]) drive_adc[i] == 1'b0;
    foreach (delay[j]) delay[j] == 0;
  }

  function new(string name = "i2c_master_write_invalid_address");
    super.new(name);
  endfunction

  virtual task body();
    bit [7:1] invalid_addrs[$] = '{7'h00, 7'h07, 7'h10, 7'h20, 7'h7F};

    foreach (invalid_addrs[k]) begin
      bit [7:1] addr_fixed = invalid_addrs[k];

      `uvm_info(get_type_name(),
        $sformatf("Trying invalid target address: %h", addr_fixed),
        UVM_MEDIUM)

      //foreach (invalid_registers[i]) begin
        if (!randomize() with {
              target_address == addr_fixed;
            })
          `uvm_error("RAND", "Randomization failed for invalid target address test")

        super.body(); // perform the write — DUT should NACK or ignore
      //end
    end
  endtask
endclass

// ================================================
// WRITE VALID ADDRESS WITH INVALID REGISTER 
// ================================================
class i2c_master_write_invalid_register extends i2c_master_write_sequence;
  `uvm_object_utils(i2c_master_write_invalid_register)

  constraint c_master_write_invalid_register {
    stop_condition == 'b1;
    target_address == 7'h9;
    foreach (drive_adc[i]) drive_adc[i] == 1'b0;
    foreach (delay[j]) delay[j] == 0;
    foreach (selec_address[m]) selec_address[m] == target_address[m+1]; // assign 3 LSBs
    number_of_bytes == 1;
  }

  function new(string name = "i2c_master_write_invalid_register");
    super.new(name);
  endfunction

  virtual task body();
    int invalid_regs[$]    = '{3, 4, 5, 37, 38, 39, 40, 50};

    foreach (invalid_regs[i]) begin
      int reg_fixed = invalid_regs[i];

      `uvm_info(get_type_name(),
        $sformatf("Trying invalid register address: %0d", reg_fixed),
        UVM_MEDIUM)

      if (!randomize() with {
            register_address == reg_fixed;
          })
        `uvm_error("RAND", "Randomization failed for invalid register test")

      super.body(); // perform write — DUT should NACK or ignore
    end
  endtask
endclass

// ================================================
// WRITE VALID ADDRESS WITH REGISTERS (3,4,5) ADC REGS 
// ================================================
class i2c_write_adc_regs extends  i2c_master_write_sequence;
  `uvm_object_utils(i2c_write_adc_regs)

  constraint c_master_write_adc_regs {
     stop_condition == 'b1;
    target_address == 7'h9;
    foreach (drive_adc[i]) drive_adc[i] == 1'b0;
    foreach (delay[j]) delay[j] == 0;
    foreach (selec_address[m]) selec_address[m] == target_address[m+1]; // assign 3 LSBs
    number_of_bytes == 1;
  }

  function new(string name = "i2c_write_adc_regs");
    super.new(name);
  endfunction

  virtual task body();
    int invalid_regs[$]    = '{3, 4, 5};

    foreach (invalid_regs[i]) begin
      int reg_fixed = invalid_regs[i];

      `uvm_info(get_type_name(),
        $sformatf("Trying invalid register address: %0d", reg_fixed),
        UVM_MEDIUM)

      if (!randomize() with {
            register_address == reg_fixed;
          })
        `uvm_error("RAND", "Randomization failed for invalid register test")

      super.body(); // perform write — DUT should NACK or ignore
    end
  endtask
endclass

// ================================================
// ----------------READ SEQUENCES------------------  
// ================================================



// ================================================
// READ SPECIFIC ADRESS WITH RANDOM REG NO ADC  
// ================================================
class i2c_master_read_spec_address extends i2c_master_read_sequence;
  `uvm_object_utils(i2c_master_read_spec_address)

  constraint c_master_read_spec_address {
    stop_condition == 'b1;
    target_address == 7'h08;
    number_of_bytes == 1;
    foreach (drive_adc[i]) drive_adc[i] == 1'b0;
    foreach (delay[j]) delay[j] == 0;
    foreach (selec_address[m]) selec_address[m] == target_address[m+1];
  }

  function new(string name = "i2c_master_read_spec_address");
    super.new(name);
  endfunction
 virtual task body();
    
      // By default, re-enable all channels for randomization
     if (!randomize() with { // assign 3 LSBs
      }) `uvm_error("RAND", "Randomization failed for specific register")

      super.body(); // perform the actual write for this registe
  endtask

endclass

// ================================================
// READ SPECIFIC ADRESS WITH REG ORDER NO ADC  
// ================================================

class i2c_master_read_spec_address_with_reg_order extends i2c_master_read_sequence;
  `uvm_object_utils(i2c_master_read_spec_address_with_reg_order)

  constraint c_master_read_spec_address_with_reg_order {
    stop_condition == 'b1;
    target_address == 7'h08;
    number_of_bytes == 1;
    foreach (drive_adc[i]) drive_adc[i] == 1'b0;
    foreach (delay[j]) delay[j] == 0;
    foreach (selec_address[m]) selec_address[m] == target_address[m+1]; // assign 3 LSBs
  }

  function new(string name = "i2c_master_read_spec_address_with_reg_order");
    super.new(name);
  endfunction

  virtual task body();
    for (int r=0; r<37; r++) begin
      // By default, re-enable all channels for randomization
      if (!randomize() with {
        register_address == r;
      }) `uvm_error("RAND", "Randomization failed for specific register")

      super.body(); // perform the actual write for this register
    end
  endtask
endclass

// ================================================
// READ SPECIFIC ADRESS WITH RANDOM REG WITH ADC  
// ================================================
class i2c_master_read_spec_address_with_reg_order_adc extends i2c_master_read_sequence;
  `uvm_object_utils(i2c_master_read_spec_address_with_reg_order_adc)

  constraint c_master_read_spec_address_with_reg_order_adc {
    stop_condition == 'b1;
    target_address == 7'h9;
    number_of_bytes == 1;
    foreach (delay[j]) delay[j] == 0;
    foreach (selec_address[m]) selec_address[m] == target_address[m+1];
  }

  function new(string name = "i2c_master_read_spec_address_with_reg_order_adc");
    super.new(name);
  endfunction

  virtual task body();
    for (int r=0; r<37; r++) begin

        // Determine drive_adc mask based on r
      bit [2:0] drive_mask = 3'b000;
      case (r)
          3: drive_mask = 3'b001; // ADC_out[0] updates
          4: drive_mask = 3'b010; // ADC_out[1] updates
          5: drive_mask = 3'b100; // ADC_out[2] updates
          default: drive_mask = 3'b000; // no ADC updates
      endcase

      // By default, re-enable all channels for randomization
      if (!randomize() with {
        register_address == r;
        foreach (drive_adc[i]) drive_adc[i] == drive_mask[i];// use the computed mask
      }) `uvm_error("RAND", "Randomization failed for specific register")

      super.body(); // perform the actual write for this register
    end
  endtask
endclass

// ================================================
// READ SPECIFIC ADRESS WITH ADC REGS ONlY WITH ADC CHANGING ALL THE TIME   
// ================================================
/*
class i2c_master_read_spec_address_with_adc_regs_adc extends i2c_master_base_sequence;
  `uvm_object_utils(i2c_master_read_spec_address_with_adc_regs_adc)

  constraint c_master_read_spec_address_with_adc_regs_adc {
    stop_condition == 'b1;
    target_address == 7'h9;
    number_of_bytes == 1;
    foreach (selec_address[m]) selec_address[m] == target_address[m+1];
    foreach (drive_adc[i]) drive_adc[i] == 1'b1;
    foreach (delay[j]) delay[j] == 0;
  }

  function new(string name = "i2c_read_spec_address_with_adc_regs_adc");
    super.new(name);
  endfunction

  virtual task body();
    for (int r=3; r<6; r++) begin

        // Determine drive_adc mask based on r
      //bit [2:0] drive_mask = 3'b000;
      //case (r)
          //3: drive_mask = 3'b001; // ADC_out[0] updates
          //4: drive_mask = 3'b010; // ADC_out[1] updates
          //5: drive_mask = 3'b100; // ADC_out[2] updates
          //default: drive_mask = 3'b000; // no ADC updates
      //endcase

      // By default, re-enable all channels for randomization
      if (!randomize() with {
       
        register_address == r;
        //foreach (ADC_out[i]) ADC_out[i] == 8'hA0 + r; // example changing ADC values
       
      }) `uvm_error("RAND", "Randomization failed for specific register")

      super.body(); // perform the actual write for this register
    end
  endtask
endclass
*/
// ================================================
// READ SPECIFIC ADRESS WITH ADC REGS ONlY WITH ADC CHANGING ALL THE TIME   
// ================================================

class i2c_master_read_spec_address_with_adc_regs_adc extends i2c_master_base_sequence;
  `uvm_object_utils(i2c_master_read_spec_address_with_adc_regs_adc)

  i2c_master_base_sequence    seq;
  rand int                    number_of_bytes;
  rand bit                    ignore_register;

  // Item fields for Master Seq
  rand bit[7:1]               target_address;
  rand bit[7:0]               register_address;
  rand bit                    stop_condition;
  rand bit[7:0]               ack_nack[];
  rand int                    delay[];
  rand bit[7:0]               ADC_out[0:2];
  rand bit                    drive_adc[0:2];

  constraint c_master_read_target {
     soft ( !(target_address inside {RESERVED_ADDRESSES}) );
  }
  constraint c_master_read_nob {
    number_of_bytes == 1;
     
  }
  constraint c_master_read_array_size {
    ack_nack.size() == number_of_bytes-1; // because last byte is NACK
    delay.size() == number_of_bytes+3;// +3 for target (W), register, target(R) bytes
  }
  constraint c_master_read_delay {
    foreach(delay[i]) { 
      soft (delay[i] == 0);  
    } 
  }
  constraint c_master_write_ignore_reg {
    soft (ignore_register == 'b0);
  }
  constraint c_master_read_reg_range {
    register_address inside {[3:5]};
  }
  constraint c_master_adc_values {
    foreach (ADC_out[i]) {
      ADC_out[i] >= 0 && ADC_out[i] <= 8'hFF;
    }
  }
  constraint c_master_drive_adc {
    foreach (drive_adc[i]) {
      soft (drive_adc[i] == 1'b1);
    }
  }
  constraint c_master_selec_address {
    foreach (selec_address[i]) {
      soft (selec_address[i] == 1'b0);
    }
  }
  
  constraint c_master_read_spec_address {
    stop_condition == 'b1;
    target_address == 7'h8;
    foreach (drive_adc[i]) drive_adc[i] == 1'b1;
    foreach (selec_address[i]) selec_address[i] == target_address[i+1];
  }

  extern function new(string name = "i2c_master_read_spec_address_with_adc_regs_adc");
  extern virtual task body();
endclass // i2c_master_read_sequence

  //-------------------------------------------------------------------
  function i2c_master_read_spec_address_with_adc_regs_adc:: new(string name = "i2c_master_read_spec_address_with_adc_regs_adc");
      super.new(name);
  endfunction //i2c_sequence::new

  //-------------------------------------------------------------------
  task i2c_master_read_spec_address_with_adc_regs_adc:: body();
    int exit_flag;

    seq = i2c_master_base_sequence::type_id::create("seq");

    forever begin
      exit_flag = 0;
      for (int r=3; r<6; r++) begin
      // Determine drive_adc mask based on r
      // Send target address
        if ( !seq.randomize() with { 
            transaction_type == WRITE;
            start_condition == 'b1;
            data == { target_address, `W };
            delay == local::delay[0];
            foreach (drive_adc[i]) {drive_adc[i] == 1;}
            foreach (selec_address[i]) {selec_address[i] == local::selec_address[i];}
          }
        ) `uvm_error(get_type_name(), "Read Sequence Randomization failed at Target Adress")
        seq.start(p_sequencer, this);
        `uvm_info(get_name(), "Sent target address (W)", UVM_MEDIUM)
        exit_flag = seq.check_exit();
        if (exit_flag == 1) continue;
        if (exit_flag == 2) return;

        // Send register address
        if (!ignore_register) begin
          if ( !seq.randomize() with { 
              transaction_type == WRITE;
              data == r;
              delay == local::delay[1];
              foreach (drive_adc[i]) {drive_adc[i] == 1;}
              foreach (selec_address[i]) {selec_address[i] == local::selec_address[i];}
              //foreach (ADC_out[i]) { ADC_out[i] == local::ADC_out[i];}
            }
          ) `uvm_error(get_type_name(), "Read Sequence Randomization failed at Register Address")
          seq.start(p_sequencer, this);
          `uvm_info(get_name(), "Sent register address", UVM_MEDIUM)
          exit_flag = seq.check_exit();
          if (exit_flag) return;
        end

        // Send target address again (read)
        if ( !seq.randomize() with { 
            transaction_type == WRITE;//that is likely because the base sequence's item 
            //is always driven as a one-byte transfer and the transaction_type may represent
            //a higher-level semantic; but in essence this constructed item places {target_address, R}
            //onto the bus. 
            //(If base seq expectsWRITEvsREAD` semantics, double-check consistency — 
            //but the code intends to send the address with the correct R/W bit set.)
            start_condition == 'b1;
            data == { target_address, `R };
            delay == local::delay[2];
            foreach (drive_adc[i]) {drive_adc[i] == 1;}
            foreach (selec_address[i]) {selec_address[i] == local::selec_address[i];}
            //foreach (ADC_out[i]) { ADC_out[i] == local::ADC_out[i];}
          }
        )  `uvm_error(get_type_name(), "Read Sequence Randomization failed at Target Adress")
        seq.start(p_sequencer, this);
        `uvm_info(get_name(), "Sent target address (R)", UVM_MEDIUM)
        exit_flag = seq.check_exit();
        if (exit_flag) return;
        for ( int i = 0; i < number_of_bytes; i++) begin
          if ( !seq.randomize() with { 
              transaction_type == READ;
              if (local::i == number_of_bytes-1)  {
                ack_nack == `NACK;
                stop_condition == local::stop_condition;
              }
              delay == local::delay[i+3];
              foreach (selec_address[i]) {selec_address[i] == local::selec_address[i];}
              foreach (drive_adc[i]) {drive_adc[i] == 1;}
              //foreach (ADC_out[i]) { ADC_out[i] == local::ADC_out[i];}
            }
          ) `uvm_error(get_type_name(), $sformatf("Read Sequence Randomization failed at %3d", i))
          seq.start(p_sequencer, this);
          `uvm_info(get_name(), $sformatf("Read Data Byte %03d", i), UVM_MEDIUM)
          exit_flag = seq.check_exit();
          if (exit_flag) return;
        end
      end
      // SEQUENCE FINISHED
      break; // or return;
    end
  endtask 

/*
constraint c_master_read_spec_address {
    stop_condition == 'b1;
    target_address == 7'h8;
    foreach (drive_adc[i]) drive_adc[i] == 1'b0;
  }

  virtual task body();
    
      // By default, re-enable all channels for randomization
     if (!randomize() with {
        target_address == 7'h08;
        stop_condition == 1;
        number_of_bytes == 1;
        foreach (delay[j]) delay[j] == 0;
        foreach (selec_address[m]) selec_address[m] == target_address[m+1]; // assign 3 LSBs
      }) `uvm_error("RAND", "Randomization failed for specific register")

      super.body(); // perform the actual write for this registe
  endtask
  */