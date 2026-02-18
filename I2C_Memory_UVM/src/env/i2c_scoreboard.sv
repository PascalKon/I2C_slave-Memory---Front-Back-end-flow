`uvm_analysis_imp_decl(_m_mon) //Declares analysis imp port master monitor
`uvm_analysis_imp_decl(_s_mon) //Declares analysis imp port slave monitor

class i2c_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(i2c_scoreboard)

  i2c_cfg cfg; // Configuration object holds scorevoard settings

  uvm_analysis_imp_m_mon #(i2c_item, i2c_scoreboard) m_mon_imp; // master monitor
  uvm_analysis_imp_s_mon #(i2c_item, i2c_scoreboard) s_mon_imp; // slave monitor
  i2c_coverage cov; // coverage collector object
  
  i2c_item item_q[$]; // dynamic queue of transaction items
  i2c_item current_item; // temp value to hold current item being processed
  int write_flag; //A flag set to 1 when a new item is received (used to trigger processing).
  int start_index; //Stores the index in item_q where the START condition occurred.

  int expect_start;
  int expect_stop;
  int expect_ack;

  scoreboard_state_enum current_state;
  scoreboard_state_enum next_state;

  byte ADC_out_temp [0:2]; // ADC output values for registers 3,4,5

  bit  [7:0] register_file [0:36] ; // internal model of 37x8 register file
  int register;
  bit [6:0] current_target_address;
  bit wr;
  //function declaratoins
  extern function new (string name, uvm_component parent);
  extern virtual function void build_phase (uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void write_m_mon(i2c_item item);
  extern virtual function void write_s_mon(i2c_item item);
  extern virtual function void reset();
  extern virtual function void set_state(scoreboard_state_enum state);
  extern virtual function void check_start();
  extern virtual function void check_stop();
  extern virtual function void check_ack();
endclass // i2c_scoreboard

function i2c_scoreboard:: new(string name, uvm_component parent);
  super.new(name,parent);
endfunction // i2c_scoreboard::new

function void i2c_scoreboard:: build_phase(uvm_phase phase);
  super.build_phase(phase);

  m_mon_imp = new("m_mon_imp", this);
  s_mon_imp = new("s_mon_imp", this);
  if (!uvm_config_db#(i2c_cfg)::get(this, "", "cfg", cfg)) begin
    `uvm_fatal("build_phase", "cfg wasn't set through config db");

  for (int i=0; i<=36; i++) begin
    register_file[i] = 8'h00; // initialize internal register file to 0
  end

end
endfunction // i2c_scoreboard::build_phase

//Called when a master monitor sends a transaction item to the scoreboard.
function void i2c_scoreboard:: write_m_mon(i2c_item item);
  `uvm_info("Scoreboard", "Just recieved item from master monitor", UVM_FULL)
  // Store ADC values
  for(int i=0; i<3; i++) begin
    register_file[3+i] = item.ADC_out[i]; // update internal model
  end

endfunction // i2c_scoreboard::write_m_mon

//Called when slave monitor sends a transaction.
function void i2c_scoreboard:: write_s_mon(i2c_item item);
  `uvm_info("Scoreboard", "Just recieved item from slave monitor", UVM_MEDIUM)

  item_q.push_back(item);
  write_flag = 1;
endfunction // i2c_scoreboard::write_s_mon

/*
 * The scoreboard is implemented as a state machine.
 * This task is the main task of the scoreboard. It is responsible for
 * checking the data that is received from the monitors and comparing it
 * to the expected data. It also checks the start and stop conditions.
 * Depending on the data received, it will change the state of the scoreboard.
 */
task i2c_scoreboard:: run_phase(uvm_phase phase);
  current_state = WAIT_FOR_START;
  next_state = WAIT_FOR_START;

  forever begin
    wait (write_flag);
    write_flag = 0;
    
    current_item = item_q[$];

    check_start(); // verifly  if start condition rules are met line 345

    case (current_state)
    ADDRESSING: begin
     
        if (current_item.data[0] == `W) begin
          current_target_address = current_item.data[7:1];
          wr = 1'b0;
          `uvm_info("Scoreboard", $sformatf("Target Address WRITE %7b", current_item.data[7:1]), UVM_LOW)
          if (current_target_address < 7'h08 || current_target_address > 7'h0F) begin
            `uvm_warning("Scoreboard", $sformatf("Target Address out of possible addresses"))
          end
          next_state = NORMAL_WRITE;
        end
        else if (current_item.data[0] == `R) begin
          current_target_address = current_item.data[7:1];
          wr = 1'b1;
          `uvm_info("Scoreboard", $sformatf("Target Address READ %7b", current_item.data[7:1]), UVM_LOW)
          if (current_target_address < 7'h08 || current_target_address > 7'h0F) begin
            `uvm_warning("Scoreboard", $sformatf("Target Address out of possible addresses"))
          end
          next_state = NORMAL_READ;
        end
      //end : NORMAL_ADDRESSING


    end

    NORMAL_WRITE: begin

      if (item_q.size() == (start_index+1)+1) begin
        `uvm_info("Scoreboard", $sformatf("Register / Write Data %8b", current_item.data), UVM_LOW)
        register = current_item.data; // update internal model
        `uvm_info("Scoreboard", $sformatf("Register %8b",register), UVM_LOW)
        if (register > 36) begin
          `uvm_warning("Scoreboard", "Attempt to write to register out of memory range")
        end
      end
      else begin
        `uvm_info("Scoreboard", $sformatf("Write Data %8b", current_item.data), UVM_LOW)
        if (register < 3 || register > 5) begin
           register_file[register] = current_item.data; // update internal model
          if (cfg.has_coverage) begin
            cov.i2c_reg_access_cg.sample(current_target_address,register, 1'b0);
          end
        end
        else begin
          `uvm_warning("Scoreboard", "Attempt to write to read-only ADC register ignored")
          register_file[register] = current_item.ADC_out[register-3]; // keep ADC register updated
          if (cfg.has_coverage) begin
            cov.i2c_reg_access_cg.sample(current_target_address,register, 1'b0);
          end
        end
      end


      next_state = NORMAL_WRITE;

    end

    NORMAL_READ: begin

      `uvm_info("Scoreboard", $sformatf("Read Data %8b", current_item.data), UVM_LOW)
      // For ADC registers (3-5), just compare read value with what ADC should be
      if (register >= 3 && register <= 5) begin
          int expected_adc = register_file[register]; // from monitor
          
          if (current_item.data != expected_adc) begin
              `uvm_error("Scoreboard", 
                $sformatf("ADC Data Mismatch! Expected %8b, Received %8b", 
                          expected_adc, current_item.data))
          end else begin
              `uvm_info("Scoreboard", $sformatf("ADC Data Match %8b", current_item.data), UVM_LOW)
          end
          if (cfg.has_coverage) begin
            cov.i2c_reg_access_cg.sample(current_target_address,register, 1'b1);
          end
      end
      // For normal DAC/other registers
      else begin
          if (current_item.data != register_file[register]) begin
              `uvm_error("Scoreboard", 
                $sformatf("Data Mismatch! Expected %8b, Received %8b", 
                          register_file[register], current_item.data))
          end else begin
              `uvm_info("Scoreboard", "Data Match!", UVM_LOW)
          end
          if (cfg.has_coverage) begin
            cov.i2c_reg_access_cg.sample(current_target_address,register, 1'b1);
          end
      end

      next_state = NORMAL_READ;

    end

    default: begin
      `uvm_error("Scoreboard", "Invalid state")
    end
    endcase

    check_ack();
    check_stop();
    set_state(next_state);
  end
endtask // i2c_scoreboard::run_phase

/*
 * This function resets the scoreboard to its initial state.
 * Any data that was in the queue is deleted since it no longer affects
 * the current communication. It is called when a stop condition is detected.
 */
function void i2c_scoreboard:: reset();
  item_q.delete();
  expect_start = 0;
  expect_stop = 0;
  expect_ack = 0;
  start_index = -1;
endfunction // i2c_scoreboard::reset

/*
 * This function sets the state of the scoreboard.
 * It is called when a start condition is detected and when the whole transaction
 * item has been processed.
 */
function void i2c_scoreboard:: set_state(scoreboard_state_enum state);
  case (state)
    WAIT_FOR_START: begin
      expect_start = 1;
      expect_stop = 0;
      expect_ack = 0;
    end
    NORMAL_WRITE,
    ADDRESSING,
    GENERAL_CALL,
    CBUS_STATE,
    OTHER_BUS_STATE,
    FUTURE_PURPOSE_STATE,
    TEN_BIT_ADDR_WRITE: begin
      expect_start = 0;
      expect_stop = 0;
      expect_ack = 1;
    end
    NORMAL_READ,
    DEVICE_ID_READ,
    TEN_BIT_ADDR_READ: begin
      expect_start = 0;
      expect_stop = 0;
      expect_ack = 0;
    end
    default: begin
      `uvm_error("Scoreboard", "Invalid state")
    end
  endcase
  current_state = state;
endfunction // i2c_scoreboard::set_state

/*
 * This function checks if the start condition is correct.
 * It sets the start_index to the index of the start condition in the queue.
 * Immediately sets the state to ADDRESSING if start condition is detected.
 */
function void i2c_scoreboard:: check_start();
  if (expect_start == 1 && !current_item.start_condition) begin
    `uvm_error("Scoreboard", "Expected start condition")
  end
  if (expect_start == -1 && current_item.start_condition) begin
    `uvm_error("Scoreboard", "Unexpected start condition")
  end
  if (current_item.start_condition) begin
    `uvm_info("Scoreboard", "Initiating Communication", UVM_LOW)
    start_index = item_q.size()-1;
    set_state(ADDRESSING);
  end
  if (start_index < 0) begin
    `uvm_fatal("Scoreboard", "Expected start condition at the beginning")
  end
endfunction // i2c_scoreboard::check_start

/*
 * This function checks if the stop condition is correct.
 * It resets the scoreboard if stop condition is detected.
 */
function void i2c_scoreboard:: check_stop();
  if (expect_stop == 1 && !current_item.stop_condition) begin
    `uvm_error("Scoreboard", "Expected stop condition")
  end
  if (expect_stop == -1 && current_item.stop_condition) begin
    `uvm_error("Scoreboard", "Unexpected stop condition")
  end
  if (current_item.stop_condition) begin
    `uvm_info("Scoreboard", "BUS is IDLE\n", UVM_LOW)
    reset();
    cfg.reset_speed_mode();
    next_state = WAIT_FOR_START;
  end
endfunction // i2c_scoreboard::check_stop

/*
 * This function checks if the ack/nack is correct.
 */
function void i2c_scoreboard:: check_ack();
  if (expect_ack == 1 && current_item.ack_nack == `NACK) begin
    `uvm_error("Scoreboard", "Expected ack")
  end
  if (expect_ack == -1 && current_item.ack_nack == `ACK) begin
    `uvm_error("Scoreboard", "Unexpected ack")
  end
endfunction // i2c_scoreboard::check_ack
