// ============================================================
//  Top-level wrapper: I²C-to-Memory bridge
// ============================================================
module I2CAndMemory
(
    // System
    input  logic        clk,
    input  logic        rst_n,

    // I²C physical interface
    input  logic        SCL,
    inout  logic        SDA,

    // I²C hardware-address pins
    input  logic        A_0,
    input  logic        A_1,
    input  logic        A_2,

    // Analogue-block interface (pass-through to Memory)
    input  logic [7:0]  ADC_in [0:2],      // three 8-bit ADC channels
    output logic [7:0]  DAC_out[0:30],     // thirty-one 8-bit DAC channels
    output logic [2:0]  CS_control[0:2],   // chip-selects
    output logic        CP_reset [0:2],    // charge-pump resets
    output logic        Timer_EN  [0:2],
    output logic        Timer_FEN [0:2],
    output logic        Amp_EN    [0:2]
);

    // ------------------------------------------------------------------
    // Internal wires that join the two blocks
    // ------------------------------------------------------------------
    logic [5:0] reg_addr;          // 6-bit register address
    logic       reg_write;         // write strobe
    logic       reg_read;          // read  strobe
    logic [7:0] i2c_to_mem_data;   // I2C  → Memory  (Data_out of I2C)
    logic [7:0] mem_to_i2c_data;   // Memory → I2C  (Data_out of Memory)

    // ------------------------------------------------------------------
    // I²C-slave instance
    // ------------------------------------------------------------------
    I2C_Slave i2c_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .SCL       (SCL),
        .SDA       (SDA),
        // Register-file interface
        .Data_out  (i2c_to_mem_data),   // drives Memory.Data_in
        .Data_in   (mem_to_i2c_data),   // driven by Memory.Data_out
        .Reg_addr  (reg_addr),
        .Reg_write (reg_write),
        .Reg_read  (reg_read),
        // Fixed address strap pins
        .A_0       (A_0),
        .A_1       (A_1),
        .A_2       (A_2)
    );

    // ------------------------------------------------------------------
    // Register-file / Memory instance
    // ------------------------------------------------------------------
    Memory mem_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        // Analogue-block signals
        .ADC_in     (ADC_in),
        .DAC_out    (DAC_out),
        .CS_control (CS_control),
        .CP_reset   (CP_reset),
        .Timer_EN   (Timer_EN),
        .Timer_FEN  (Timer_FEN),
        .Amp_EN     (Amp_EN),
        // I²C register interface
        .Reg_addr   (reg_addr),
        .Data_in    (i2c_to_mem_data),   // fed by I2C.Data_out
        .Reg_write  (reg_write),
        .Reg_read   (reg_read),
        .Data_out   (mem_to_i2c_data)    // drives I2C.Data_in
    );

endmodule
