// =====================================================================
//  Test-bench for top_i2c_memory : 1× WRITE followed by 1× READ
//  – Drives the I²C bus exactly as the original slave-only TB
//  – Verifies that the data written into the Memory block can be
//    read back through the I²C interface.
// =====================================================================
`timescale 1ns/1ps
module tb_top_i2c_memory;

    // ------------------------------------------------------------
    // 1. Fast DUT clock (8 MHz)  – much faster than the 100 kHz bus
    // ------------------------------------------------------------
    logic clk = 0;
    always #62.5ns clk = ~clk;

    // ------------------------------------------------------------
    // 2. I²C Standard-mode timing constants (µs → ns literals)
    // ------------------------------------------------------------
    parameter time T_LOW     = 5_000ns;  // tLOW ≥ 4.7 µs| The minimum time the SCL line must be low. This defines the low part of the SCL clock.
    parameter time T_HIGH    = 5_000ns;  // tHIGH≥ 4.0 µs|  (fSCL≈100 kHz) The minimum time the SCL line must be high. This defines the high part of the clock.
    parameter time T_HD_STA  = 4_000ns;  // tHD;STA |Hold time for a START condition. SDA must remain stable after going low before SCL goes low.
    parameter time T_SU_STA  = 4_700ns;  // tSU;STA |Setup time for a repeated START condition. Time between SCL going high and SDA going low again.
    parameter time T_HD_DAT  =   300ns;  // tHD;DAT |Data hold time. Time SDA must remain stable after the SCL falling edge.
    parameter time T_SU_DAT  =   300ns;  // tSU;DAT |Data setup time. Time SDA must be valid before the next SCL rising edge.
    parameter time T_BUF     = 4_700ns;  // bus-free (STOP→START) |Bus free time between STOP and START. Time the bus must be idle (both lines high) between operations.

    // ------------------------------------------------------------
    // 3. I²C bus lines  (open-drain emulation with weak pull-up)
    // ------------------------------------------------------------
    tri1  SDA;                 // bidirectional data
    //pullup (SDA);             // weak pull-up when nothing drives

    logic sda_drive;          // 1 → master drives LOW, 0 → release
    assign SDA = sda_drive ? 1'b0 : 1'bz;

    logic SCL = 0;            // master always drives SCL

    // ------------------------------------------------------------
    // 4. Device address strap pins and reset
    // ------------------------------------------------------------
    logic A_0, A_1, A_2;
    logic rst_n = 0;

    // ------------------------------------------------------------
    // 5. Analogue-block side of the top (just tie-offs for TB)
    // ------------------------------------------------------------
    logic [7:0] ADC_in   [0:2] = '{default:8'h00};

    logic [7:0] DAC_out  [0:30];
    logic [2:0] CS_control [0:2];
    logic  CP_reset   [0:2];
    logic  Timer_EN   [0:2];
    logic  Timer_FEN  [0:2];
    logic  Amp_EN     [0:2];

    // ------------------------------------------------------------
    // 6. DUT  – the full I²C-to-Memory wrapper
    // ------------------------------------------------------------
    I2CAndMemory dut (
        .clk        (clk),
        .rst_n      (rst_n),

        .SCL        (SCL),
        .SDA        (SDA),

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

    // ------------------------------------------------------------
    // 7. Convenience tasks – identical to the original TB
    // ------------------------------------------------------------
    task scl_low ; begin SCL = 0; #T_LOW ;  end endtask
    task scl_high; begin SCL = 1; #T_HIGH; end endtask

    task address_selector(input logic [6:0] addr);
        begin
            A_0 = addr[0];
            A_1 = addr[1];
            A_2 = addr[2];
        end
    endtask

    // START (S) – SDA high→low while SCL high
    task i2c_start;
    begin
        sda_drive = 0;         // let SDA float high
        scl_high;
        #T_SU_STA;
        sda_drive = 1;         // pull SDA low
        #T_HD_STA;
        scl_low;
    end
    endtask

    // STOP (P) – SDA low→high while SCL high
    task i2c_stop;
    begin
        sda_drive = 1;         // keep SDA low
        scl_high;
        #T_SU_STA;
        sda_drive = 0;         // release SDA → high
        #T_BUF;                // bus-free
    end
    endtask

    // Low-level bit transfers (MSB-first)
    task send_bit (input logic b);
    begin
        scl_low;
        sda_drive = (b == 0);  // ‘0’ pulls low, ‘1’ releases
        #T_SU_DAT;
        scl_high;              // slave samples
        #T_HD_DAT;
    end
    endtask

    task recv_bit (output logic bit_val);
    begin
        scl_low;
        sda_drive = 0;         // release line
        #T_SU_DAT;
        scl_high;
        #T_HD_DAT;
        bit_val = SDA;         // sample while SCL high
    end
    endtask

    // Send 8 bits, receive ACK
    task send_byte(input  [7:0] data,
                   output logic ack);
        integer i;
    begin
        for (i = 7; i >= 0; i--) send_bit(data[i]);
        // ACK phase
        scl_low;
        sda_drive = 0;
        scl_high;
        ack = ~SDA;            // ACK driven low by slave
        scl_low;
    end
    endtask

    // Receive 8 bits, then send ACK(0) or NACK(1)
    task recv_byte(output [7:0] data,
                   input  logic send_nack);
        integer i;
    begin
        for (i = 7; i >= 0; i--) recv_bit(data[i]);

        // Master ACK / NACK
        scl_low;
        sda_drive = send_nack ? 0 : 1; // ACK = drive LOW
        scl_high;
        scl_low;
        sda_drive = 0;                 // release
    end
    endtask

    // I²C Write Sequence Task: START → SLA+W → REG → DATA → STOP
    task i2c_write_byte(input logic [7:0] reg_addr, input logic [7:0] data);
        bit ack;
        begin
            i2c_start;
            send_byte(8'h10, ack);     // SLA+W (slave addr 0x08 << 1)
            send_byte(reg_addr, ack);  // register address
            send_byte(data, ack);      // data to write
            i2c_stop;
        end
    endtask

    // I²C Read Sequence Task: START → SLA+W → REG → REP START → SLA+R → DATA ← STOP
    task i2c_read_byte(input logic [7:0] reg_addr, output logic [7:0] data);
        bit ack;
        begin
            // Write address phase (register pointer setup)
            i2c_start;
            send_byte(8'h10, ack);     // SLA+W
            send_byte(reg_addr, ack);  // register address

            // Repeated START and read
            i2c_start;
            send_byte(8'h11, ack);     // SLA+R
            recv_byte(data, 1'b1);     // read + NACK
            i2c_stop;
        end
    endtask

    // ------------------------------------------------------------
    // 8. I²C stimulus  (write 0xA5 to reg 0x36, then read back)
    // ------------------------------------------------------------
    bit  ack;
    byte rd;

    initial begin
        // Give analogue inputs some benign value
        ADC_in[0] = 8'h55;
        ADC_in[1] = 8'hAA;
        ADC_in[2] = 8'hFF;

        // Strap device address (matches the original TB)
        // 7-bit slave address 0b0100_001 = 0x21 → 
        // write 0x10, read 0x11 on the 8-bit bus.
        address_selector(7'h8);

        // Global reset pulse
        rst_n = 1;
        #200 
        rst_n = 0;

        // ----------------  WRITE to registers -----------------
        i2c_write_byte(8'h01, 8'hA6); // write 0xA6 to register 1
        i2c_write_byte(8'h00, 8'hFF); // write 0xFF to register 0
        i2c_write_byte(8'h06, 8'hA6); // write 0xA6 to register 6
        // ----------------  READ from register 6 ----------------
        i2c_read_byte(8'h06, rd);
        // ----------------  WRITE to registers -----------------
        i2c_write_byte(8'h06, 8'hA7); // write 0xA7 to register 6

        // ----------------  Results -----------------------
        $display("------------------------------------------------");
        $display("READ-BACK value = 0x%02h", rd);
        // Peek at some internal signals for curiosity
        $display("Reg_write asserted? %0d", dut.i2c_inst.Reg_write);
        $display("Data_out seen by Memory = 0x%02h", dut.i2c_inst.Data_out);
        if (rd == 8'hA6) $display("TEST PASS ✔");
        else              $display("TEST FAIL ✘");
        $display("------------------------------------------------");
        #1000 $finish;
    end

endmodule

