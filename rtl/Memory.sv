module Memory (
    input  logic        clk,
    input  logic        rst_n,

    // ADC inputs from analog block
    input  logic [7:0]  ADC_in[0:2],
    
    // DAC outputs to analog block
    output logic [7:0]  DAC_out [0:30],

    // Control outputs for analog components
    output logic [2:0]  CS_control  [0:2],
    output logic        CP_reset    [0:2],
    output logic        Timer_EN    [0:2],
    output logic        Timer_FEN   [0:2],
    output logic        Amp_EN      [0:2],

    // Register interface for I2C module
    input  logic [5:0]  Reg_addr,    // 6-bit address (0–35)
    input  logic [7:0]  Data_in, // input data line from I2C
    input  logic        Reg_write,   // write enable
    input  logic        Reg_read,    // read enable
    output logic [7:0]  Data_out // output data line to I2C
    );

    // Internal register storage: 36 8-bit registers
    logic [7:0] registers [0:36];
    logic       registers_en [0:36];
    logic       rw_en;             // signal to check if read/write is performed

    // Register WRITE and READ logic: 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Data_out <= 8'd0;
            for (int i = 0; i < 3; i++) begin
                Amp_EN[i]     <= 1'b0;
                Timer_EN[i]   <= 1'b0;
                Timer_FEN[i]  <= 1'b0;
                CP_reset[i]   <= 1'b0;
                CS_control[i] <= 3'b000;
            end

            // Reset DAC outputs (6–36)
            for (int i = 0; i < 31; i++) begin
                DAC_out[i] <= 8'd0;
            end

            // Reset All registers (3–5)
            for (int i = 0; i < 37; i++) begin
                registers[i] <= 8'd0;
            end
                  
        end else begin
            // WRITE LOGIC
            if (Reg_write && !Reg_read && registers_en[Reg_addr]== 0) begin                                          // Let the I2C drive the wire 
                 registers[Reg_addr] <= Data_in;                                              // Read operation has been done 
            // READ LOGIC   
            end else if(Reg_read && !Reg_write && registers_en[Reg_addr]== 0) begin
                 Data_out <= registers[Reg_addr];                            // Drive read data
            // NEITHER WRITE OR READ
            end

            // Control Signal Updates (regs 0–2)
            for (int i = 0; i < 3; i++) begin
                if (registers_en[i] == 1) begin
                    Amp_EN[i]     <= registers[i][6];
                    Timer_EN[i]   <= registers[i][5];
                    Timer_FEN[i]  <= registers[i][4];
                    CP_reset[i]   <= registers[i][3];
                    CS_control[i] <= registers[i][2:0];
                end
            end

            // ------------------------------
            // ADC REGISTER UPDATE (regs 3–5)
            // ------------------------------
            for (int i = 0; i < 3; i++) begin
                if (registers_en[i+3] == 1) begin
                    registers[i+3] <= ADC_in[i];
                end
            end

            // ------------------------------
            // DAC OUTPUT UPDATE (regs 6–36)
            // ------------------------------
            for (int i = 0; i < 31; i++) begin
                if (registers_en[i+6] == 1) begin
                    DAC_out[i] <= registers[i+6];
                end
            end


        end
    end

    // ENABLE WRITE-READ
    always_ff @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rw_en <= 1'b0;
            for (int i = 0; i < 37; i++) begin                               // if we have NO read or write let registers be updated from other sources
                registers_en[i] <= 1'b1;  
            end 
        end else begin
            if (Reg_addr<37)begin
                // READ-ENABLE
                if (Reg_read == 1 && !Reg_write && !rw_en) begin                     //if Read enable the register[reg_addr] 
                    registers_en[Reg_addr]<= 1'b0;
                    rw_en <= 1'b1;
                    
                // WRITE-ENABLE
                end else if (Reg_write == 1 && !Reg_read && !rw_en) begin            //if Write check for ADC regs(cant be written)
                    if (!(Reg_addr >= 3 && Reg_addr <= 5)) begin    //if Regs are not for ADCs enable Write for register[reg_addr]
                        registers_en[Reg_addr]<= 1'b0;
                        rw_en <= 1'b1;    
                    end else begin
                        registers_en[Reg_addr]<= registers_en[Reg_addr]; 
                    end
                // NOTHING ENABLE (lets registers be updated from other sources)
                end else begin
                    rw_en <= 1'b0;
                    for (int i = 0; i < 37; i++) begin                               // if we have NO read or write let registers be updated from other sources
                        registers_en[i] <= 1'b1;  
                    end                                                             
                end
            end else begin
                rw_en <= 1'b0;
                for (int i = 0; i < 37; i++) begin                               // if we have NO read or write let registers be updated from other sources
                    registers_en[i] <= 1'b1;  
                end 
            end
        end
    end

endmodule
 