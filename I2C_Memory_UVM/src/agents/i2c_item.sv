class i2c_item extends uvm_sequence_item;
  `uvm_object_utils(i2c_item)
    
  // Interface fields
  rand bit[7:0]                 data;
  rand bit                      ack_nack;

  // Master Driver fields
  rand bit                      start_condition;
  rand bit                      stop_condition;
  rand int                      delay;

  // Slave Driver fields
  rand int                      clock_stretch_data[7:0];
  rand int                      clock_stretch_ack;

  // REQ/RSP fields
  rand transaction_type_enum    transaction_type;
  rand bit                      transfer_failed;

  //ADC Input fields
  rand bit                      [7:0] ADC_out[0:2]; // ADC outputs to be connected to the DUT
  rand bit                      drive_adc[0:2]; // Whether to drive the ADC outputs or not

  //Addressing fields
  rand bit                      selec_address[0:2]; // 3 LSB bits of the target address to select

  // Default/Universal Constraints
  constraint c_ack  { 
    soft (ack_nack == `ACK); 
  }

  constraint c_delay { 
    delay >= 0;
    soft (delay == 0); 
  }

  constraint c_clock_stretch_ack {
    clock_stretch_ack >= 0;
    soft (clock_stretch_ack == 0);
  }

  constraint c_clock_stretch_data { 
    foreach (clock_stretch_data[i]) {
      clock_stretch_data[i] >= 0;
      soft (clock_stretch_data[i] == 0);
    }
  }

  constraint c_start_stop { 
    soft (start_condition == 0);
    soft (stop_condition == 0);
  }

  constraint c_read_transaction { 
    if (transaction_type == READ) {start_condition == 0;}
  }

  constraint c_adc_range {
    foreach (ADC_out[i]) {
      ADC_out[i] >= 0 && ADC_out[i] <= 8'hFF;
    }
  }

  constraint c_drive_adc {
    foreach (drive_adc[i]) {
      soft (drive_adc[i] == 1'b0);
    }
  }

  constraint c_selec_address {
    foreach (selec_address[i]) {
      soft (selec_address[i] == 1'b0);
    }
  }

  extern function new(string name = "i2c_item");
endclass // i2c_item

function i2c_item:: new(string name = "i2c_item");
  super.new(name);
endfunction // i2c_item::new

