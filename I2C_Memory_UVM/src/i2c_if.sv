//lives in top-level src directory since used by both TB and DUt
interface i2c_if (input bit system_clock, input bit reset_n);
  logic uvc_sda;                      //driven by UVC (testbench side)
  logic uvc_scl;                      //driven by UVC (testbench side)
  logic[7:0] uvc_ADC_out[0:2];        // ADC outputs driven by UVC (testbench side)
  logic      uvc_selec_address[0:2];  // Address selection bits driven by UVC (testbench side)

  wire sda;                           // Αctual i2c bus(DUT side)
  wire scl;                           // Αctual i2c bus(DUT side)     
  wire [7:0] ADC_out[0:2];            // Αctual ADC outputs to DUT (driven from testbench) ===

  modport dut (   //dut modport → allows the DUT to connect directly to the bus (sda, scl).
    inout sda, scl
  );

  modport uvc (    //dut modport → allows the DUT to connect directly to the bus (sda, scl).
    output sda, scl,
    input uvc_sda, uvc_scl,
    output uvc_ADC_out,
    output uvc_selec_address
  );

  initial begin
    uvc_sda = 'bz;
    uvc_scl = 'bz;
    for (int i = 0; i < 3; i++) begin
      uvc_ADC_out[i] = 8'b0;
      uvc_selec_address[i] = 1'b0; // Address selection bits driven by UVC (testbench side)

    end


  end

  // Counter for clock pulses
  int counter;      //counter → tracks bits within one byte (0–8 → 8 bits + ACK).
  int full_counter;  //full_counter → total number of clock edges seen.

  always @(posedge reset_n) begin
    counter <= 0;
    full_counter <= 0;
  end

  // Set the counters at START condition
  always @(negedge sda iff scl) begin
    counter <= counter - 1;
    full_counter <= full_counter - 1;
  end

  // Reset the counter at STOP condition
  always @(posedge sda iff scl) begin
    counter <= 0;
  end

  // Increment the counter at every positive edge of SCL
  always @(posedge scl) begin
    counter <= counter + 1;
    full_counter <= full_counter + 1;
  end
endinterface