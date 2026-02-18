// lives in agent.
class i2c_monitor extends uvm_monitor; 
  `uvm_component_utils(i2c_monitor)

  uvm_analysis_port #(i2c_item)   i2c_mon_analysis_port;// this analysis port send  observed 
  //transactions to scoreboard

  virtual i2c_if                  i2c_vif;// virtual interface handle allow monitor to observe signals in simulation
  i2c_cfg                         cfg;
  i2c_item                        i2c_trans;// instance of transaction class to store capture data for a single i2c transfer
 
  int                             bit_counter;
  bit                             start_cond_from_prev_trans;// tracks if a start con
  bit                             captured_next_msb;//used to handle msb carry-over between tasks
  bit                             msb;

  bit                             transfer_done;
  bit                             bus_active;
  
  extern function new (string name, uvm_component parent);
  extern virtual function void build_phase (uvm_phase phase);
  extern virtual task  run_phase(uvm_phase phase);  
  extern virtual task  do_monitor();

  extern virtual task  check_start_cond();
  extern virtual task  check_stop_cond();
  extern virtual task  check_data_transfer();
  extern virtual task  monitor_ADC_inputs();
endclass // i2c_monitor_class

//-----------------------------------------------------------------------
function i2c_monitor:: new (string name, uvm_component parent);
  super.new(name, parent);
endfunction // i2c_monitor::new

//-------------------------------------------------------------------------------------------------------------
function void i2c_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);

  `uvm_info("build_phase","BUILD i2c_MONITOR",UVM_MEDIUM);
  if(!uvm_config_db#(virtual i2c_if)::get(this, "", "i2c_vif", i2c_vif)) 
    `uvm_fatal("build_phase",{"virtual interface must be set for: ",get_full_name(),".i2c_vif"});

  if (!uvm_config_db#(i2c_cfg)::get(this, "", "cfg",cfg)) begin
    `uvm_fatal("build_phase", "cfg wasn't set through config db");
  end

  i2c_mon_analysis_port = new("i2c_mon_analysis_port",this);
endfunction

//-------------------------------------------------------------------------------------------------------------
task  i2c_monitor::run_phase(uvm_phase phase);
  super.run_phase(phase);

	@(posedge i2c_vif.reset_n);// waits for reset to be de-asserted
	// repeat(3) @(posedge i2c_vif.system_clock);
  
  transfer_done = 'b1;// marks transfer as done (no transfer in progress)

 // -------------------------------
    // Start continuous ADC monitoring
    //fork
        //forever begin
            //@(posedge i2c_vif.system_clock); // or whichever clock drives ADCs
            //foreach (i2c_vif.uvc_ADC_out[i])
                //i2c_trans.ADC_out[i] = i2c_vif.uvc_ADC_out[i];
        //end
    //join_none
    // -------------------------------


  forever begin
    i2c_trans = new();// creates a new transcation object 
    //monitor_ADC_inputs();
    do_monitor();//calls montor to observe next transfer
  end       
endtask

/* 
* This task is responsible for monitoring the I2C bus and capturing the data
* that is being transferred. It is also responsible for detecting the start
* and stop conditions. 
* It is important to note that this task is not
* responsible for checking the validity of the data being transferred. That
* is the responsibility of the scoreboard.
* Another important note is that only check_data_transfer() returns and joins
* the forked tasks. This is because the other tasks are not expected to return.
*/
task i2c_monitor::do_monitor();
  if (start_cond_from_prev_trans) i2c_trans.start_condition = 'b1; // captures the start condition if carried from previous transcaction
  start_cond_from_prev_trans = 'b0;


  fork// monitors start,stop, and data transfer in parallel
    check_start_cond();
    check_stop_cond();
    check_data_transfer();
    monitor_ADC_inputs();
  join_any
  disable fork;

  i2c_mon_analysis_port.write(i2c_trans);// writes the captured i2c_trans to the analysis port
endtask

/*
* This task is responsible for detecting the start condition. It is also
* responsible for detecting invalid start conditions (early start conditions)
* Repeated start conditions break the loop to allow writing the captured data
*/
task i2c_monitor::check_start_cond();
  forever begin
    @(negedge i2c_vif.sda iff i2c_vif.scl);

    `uvm_info("Monitor", "detected start condition", UVM_HIGH)

    // else if... (invalid/early start condition)
    if (!transfer_done) begin
      i2c_trans.transfer_failed = 'b1;
      start_cond_from_prev_trans = 'b1;
      `uvm_error("Monitor", "Early START condition")
      break;  // break to exit and listen for next address
    end

    // else if ... (repeated Start Condition)
    if (bus_active == 'b1) begin
      start_cond_from_prev_trans = 'b1;  // already detected START, next one would be a repeated.
      break;
    end

    // else... (valid start condition)
    i2c_trans.start_condition = 'b1;
    bus_active = 'b1;
  end
endtask

/*
 * This task is responsible for detecting the stop condition. It is also
 * responsible for detecting invalid stop conditions (early stop conditions).
 * Any stop condition breaks the loop to allow writing the captured data
 */
task i2c_monitor::check_stop_cond();
  forever begin
    @(posedge i2c_vif.sda iff i2c_vif.scl);

    // else if... 
      // if... (early/invalid stop condition)
    if (!transfer_done) begin
      i2c_trans.transfer_failed = 'b1;
      `uvm_error("Monitor", "Early STOP condition")
    end

    i2c_trans.stop_condition = 'b1;
    bus_active = 'b0;

    `uvm_info("Monitor", "detected stop condition", UVM_HIGH)
    break; 
  end
endtask

/*
 * This task is responsible for capturing the data being transferred.
 */
task i2c_monitor::check_data_transfer();// captures 8 bits of data 
  bit_counter = 0;
  //monitor_ADC_inputs();
  while (bit_counter < 8) begin// loop until 8 data bits are captured
    // if previous task call captured current MSB, retrieve it (only enters at bit_counter == 0)
    if (captured_next_msb) begin
      if (bit_counter != 0) `uvm_fatal("Monitor", "Unexpected behavior")
      captured_next_msb = 0;
      i2c_trans.data[`rev_put(bit_counter)] = msb;
      bit_counter++;
      continue;
    end

    @(posedge i2c_vif.scl); //at posedege of SCL, sample data
    i2c_trans.data[`rev_put(bit_counter)] = i2c_vif.sda;// macro to reverse bit order
    @(negedge i2c_vif.scl);

    transfer_done = 'b0; // at this point data transfer has begun
    bit_counter++;
  end

  @(posedge i2c_vif.scl);   // after 8 bits are captured, sample ACK/NACK bit
  i2c_trans.ack_nack = i2c_vif.sda;
  @(negedge i2c_vif.scl);

  `uvm_info("Monitor", "Detected data transfer (byte)", UVM_HIGH)
  transfer_done = 'b1;
  bit_counter++;

  @(posedge i2c_vif.scl);
  msb = i2c_vif.sda;
  @(negedge i2c_vif.scl);//on the falling edge of SCL, checks that SDA hasnt changed
  if (i2c_vif.sda != msb) `uvm_fatal("Monitor", "Expected data item to be finished by now")

  captured_next_msb = 'b1;// so that next call to check_data_transfer() knows it already has the MSB
  transfer_done = 'b0;// not done yet since more data coming
endtask

task i2c_monitor::monitor_ADC_inputs();
  forever begin
    @(posedge i2c_vif.system_clock); // or whichever clock drives ADCs
    foreach (i2c_vif.uvc_ADC_out[i]) begin
      i2c_trans.ADC_out[i] = i2c_vif.uvc_ADC_out[i];
    end
  end
endtask