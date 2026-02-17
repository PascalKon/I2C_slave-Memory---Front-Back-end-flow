// =========================================================
// I²C-SLAVE FSM  — with detailed comments for every state
// =========================================================
module I2C_Slave (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        SCL,
    inout  logic        SDA,
    output logic [7:0]  Data_out,
    input  logic [7:0]  Data_in,
    output logic [5:0]  Reg_addr,
    output logic        Reg_write,
    output logic        Reg_read,
    input  logic        A_0,
    input  logic        A_1,
    input  logic        A_2
);

    // SDA I/O handling (open-drain emulation)
    logic sda_in, sda_out, read_only_reg, sda_en;// sda_internal;
    
    
    assign sda_in = SDA;
    //assign SDA    = sda_out;
    // Sample SDA only when not driving it
    //assign sda_in = (sda_en == 1'b0) ? SDA : 1'b0;
    // ((sda_out === 1'b0) ? 1'b0 : 1'b1); // or keep last value if you have a latch

    // Drive SDA only when enabled (open-drain)
    assign SDA = (sda_en == 1'b1) ? sda_out : 1'bz;


    // Synchronize SCL/SDA and detect edges
    logic [2:0] scl_sync, sda_sync;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scl_sync <= 3'b000;
            sda_sync <= 3'b000;
        end else begin
            scl_sync <= {scl_sync[1:0], SCL}; // Latest SCL sample in LSB
            sda_sync <= {sda_sync[1:0], SDA}; // Latest SCL sample in LSB
        end
    end

    // Detect rising and falling edges of SCL/SDA
    logic scl_rising, scl_falling, start_cond, stop_cond;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
             scl_rising  <= 1'b0;
             scl_falling <= 1'b0;
             start_cond  <= 1'b0;
             stop_cond   <= 1'b0;
        end else begin
            // Detect a rising edge of SCL: 0 → 1
            scl_rising  <= (scl_sync[2:1] == 2'b01);
             // Detect a falling edge of SCL: 1 → 0
            scl_falling <= (scl_sync[2:1] == 2'b10);
            // I²C START condition: SDA goes high→low **while** SCL is high
            start_cond  <= (sda_sync[2:1] == 2'b10) && scl_sync[2];
            // I²C STOP condition: SDA goes low→high **while** SCL is high
            stop_cond   <= (sda_sync[2:1] == 2'b01) && scl_sync[2];
        end
    end

    // FSM declaration
    typedef enum logic [3:0] {
        IDLE, DEV_ADDR, R_W, ACK_ADDR, DEV_REG, ACK_REG,
        DATA_W, ACK_DATA, DATA_R, NACK, WAIT
    } state_t;

    state_t state, next_state;

    // Internal registers and constants
    logic [3:0] bit_cnt; 
    logic [1:0] clk_cnt;
    logic [7:0] shift_reg;
    logic       rw_bit;

    
    logic [7:1] MY_ADDR ;
    localparam logic [7:0] VALID_REG = 8'h24; // nubmer of registers in memory

    // Address selection
    always_comb begin
        case ({A_2, A_1, A_0})
            3'b000: MY_ADDR = 7'b000_1000; // 0x08
            3'b001: MY_ADDR = 7'b000_1001; // 0x09
            3'b010: MY_ADDR = 7'b000_1010; // 0x0A
            3'b011: MY_ADDR = 7'b000_1011; // 0x0B
            3'b100: MY_ADDR = 7'b000_1100; // 0x0C
            3'b101: MY_ADDR = 7'b000_1101; // 0x0D
            3'b110: MY_ADDR = 7'b000_1110; // 0x0E
            3'b111: MY_ADDR = 7'b000_1111; // 0x0F
            default: MY_ADDR = 7'b000_1000; // 0x08
        endcase
    end


     // Reg_write/ Reg_Read/ Data_out/ Data_in/ Reg_addr signals to/from Memory
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt     <= 3'd0;
            Reg_write   <= 1'b0;
            Reg_read    <= 1'b0;
            Data_out    <= 8'd0; 
            Reg_addr    <= 8'd0;

        // ============================================================
        // Making Reg_addr taking the DEV_REG value to select register from memory
        // ============================================================    
        end else if(state==DEV_REG && bit_cnt == 4'd8 && scl_falling) begin
            Reg_addr <= shift_reg[5:0];
        
        // ============================================================
        // Making Data_out take the DATA_W value and make Reg_write High to allow writing to memory
        // ============================================================     
        end else if(state==DATA_W && bit_cnt == 4'd8  && scl_falling) begin
            Data_out   <= shift_reg;
            Reg_write  <= 1'b1;
            clk_cnt    <= clk_cnt +2'd1;   
        
        // ============================================================
        // Keep Reg_write high for 2 SCL cycles to allow writing to memory
        // ============================================================
        end else if(Reg_write == 1'b1 && clk_cnt!=2'd2) begin
            clk_cnt    <= clk_cnt + 2'd1;
        end else if(Reg_write == 1'b1 && clk_cnt == 2'd2) begin
            Reg_write  <= 1'b0;
            clk_cnt    <= 2'd0;

        // ============================================================
        // make Reg_Read High to allow reading to memory
        // ============================================================ 
        end else if(state==ACK_ADDR && scl_falling && rw_bit == 1'b1) begin
            Reg_read   <= 1'b1;
            clk_cnt    <= clk_cnt + 2'd1;

        // ============================================================
        // Keep Reg_Read high for 2 SCL cycles to allow writing to memory
        // ============================================================    
        end else if(Reg_read == 1'b1 && clk_cnt != 2'd2) begin
            clk_cnt    <= clk_cnt + 2'd1;
        end else if(Reg_read == 1'b1 && clk_cnt == 2'd2) begin
            Reg_read   <= 1'b0;
            clk_cnt    <= 3'd0;

        // ============================================================    
        end else begin
            clk_cnt     <= clk_cnt;
            Reg_write   <= Reg_write;
            Reg_read    <= Reg_read;
            Data_out    <= Data_out; 
            Reg_addr    <= Reg_addr;
        end
    end

    // ============================================================
    // Always ff block for FSM current state and input/output logic
    // ============================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg      <= 8'd0;
            rw_bit         <= 1'b0;
            sda_en         <= 1'b0;
            sda_out        <= 1'bz;
            state          <= IDLE;
            bit_cnt        <= 4'd0;
            read_only_reg  <= 1'b0; 
        end else begin
            state <= next_state;
            if (stop_cond || start_cond)begin
                bit_cnt <= 4'd0;  
            end case (state)

                IDLE: begin
                    sda_en  <= 1'b0;
                    sda_out <= 1'bz;
                    bit_cnt <= 4'd0;
                    read_only_reg  <= 1'b0;
                    // No action here. Transition out is handled globally.
                end
                // ============================================================
                // DEV_ADDR: Shift in 7-bit address
                // ============================================================
                DEV_ADDR: begin
                    sda_en  <= 1'b0;
                    sda_out <= 1'bz;
                    if (scl_rising) begin
                    bit_cnt <= bit_cnt + 4'd1;    
                    shift_reg <= {shift_reg[6:0], sda_in}; // Shift in address bits
                    end
                end

                // ============================================================
                // R_W: Capture R/W bit and determine address match
                // ============================================================
                R_W: begin
                    sda_en  <= 1'b0;
                    sda_out <= 1'bz;
                    if (scl_falling) begin
                        rw_bit <= sda_in;
                    end else if(scl_rising) begin
                        bit_cnt <= bit_cnt + 4'd1;
                    end else begin
                        bit_cnt <= bit_cnt;
                    end
                end
                
                // ============================================================
                // ACK_ADDR: Acknowledge device address; move to REG or DATA_R
                // ============================================================
                ACK_ADDR: begin
                    sda_en  <= 1'b1;
                    sda_out <= 1'b0;
                    if (scl_rising) begin
                        bit_cnt <= 4'd0;
                    end else if (scl_falling && rw_bit) begin
                        bit_cnt <= 4'd1;
                    end else begin
                        bit_cnt <= bit_cnt;
                    end

                end

                // ============================================================
                // DEV_REG: Receive the 8-bit register address
                // ============================================================
                DEV_REG: begin
                    sda_en  <= 1'b0;
                    sda_out <= 1'bz;
                    if (scl_rising) begin
                        bit_cnt <= bit_cnt + 4'd1;
                        shift_reg <= {shift_reg[6:0], sda_in}; //shift in the dev_reg bits   
                    end
                end

                // ============================================================
                // ACK_REG: Acknowledge register selection; allow Sr here
                // ============================================================
                ACK_REG: begin
                    sda_en  <= 1'b1;
                    sda_out <= 1'b0;
                    if (scl_rising) begin
                        bit_cnt <= 4'd0;
                    end
                    if (shift_reg >= 7'h3 && shift_reg <= 7'h5/*&& rw_bit == 1'b0*/) begin
                        read_only_reg <= 1'b1;
                    end else
                        read_only_reg <= 1'b0;
                end

                // ============================================================
                // DATA_W: Receive 8-bit data byte to write
                // ============================================================
                DATA_W: begin
                    sda_en  <= 1'b0;
                    sda_out <= 1'bz;
                    if (scl_rising) begin
                        bit_cnt <= bit_cnt + 4'd1;
                        shift_reg <= {shift_reg[6:0], sda_in}; //Shift in the data bits
                    end   
                end

                // ============================================================
                // ACK_DATA: Acknowledge data write and go to WAIT
                // ============================================================
                ACK_DATA: begin
                    sda_en  <= 1'b1; // Enable SDA output
                    sda_out <= 1'b0;
                    if (scl_rising) begin
                        bit_cnt <= 4'd0;
                    end
                end

                // ============================================================
                // DATA_R: Send 8-bit data to master
                // ============================================================
                DATA_R: begin

                    sda_en  <= 1'b1; // Enable SDA output
                    sda_out <= (Data_in[3'd7 - 3'(bit_cnt) + 3'd1]) ? 1'bz : 1'b0;
                    if (scl_falling && bit_cnt < 4'd8) begin
                        bit_cnt <= bit_cnt + 4'd1;    
                    end else if (scl_falling && bit_cnt == 4'd8) begin
                        bit_cnt <= 4'd0; // Reset bit count after sending data
                    end else begin
                        bit_cnt <= bit_cnt;
                    end
                end

                // ============================================================
                // NACK: Release SDA (no drive); go to WAIT after 1 SCL
                // ============================================================
                NACK: begin
                    sda_en  <= 1'b0; // Release SDA
                    sda_out <= 1'bz;
                    bit_cnt <= 4'd0;
                end
                
                // ============================================================
                // WAIT: SDA released; await STOP or Sr from master
                // ============================================================
                WAIT: begin
                    sda_en  <= 1'b0;
                    sda_out <= 1'bz;
                end
                default: begin
                    shift_reg      <= 8'd0;
                    rw_bit         <= 1'b0;
                    sda_en         <= 1'b0;
                    sda_out        <= 1'bz;
                    read_only_reg  <= 1'b0;
                end
            endcase
        end
    end

    // ============================================================
    // Always comb block for FSM next state logic
    // ============================================================
    always_comb begin
        next_state = state;
        // Handle STOP/START globally
        if (stop_cond) begin
            next_state = IDLE;
        end else if (start_cond) begin
            next_state = DEV_ADDR;
        end else begin
            next_state = state;
            case (state)
            
            // ============================================================
            // IDLE: Wait for START condition
            // ============================================================
            IDLE: begin
                // No action here. Transition out is handled globally.
            end

            // ============================================================
            // DEV_ADDR: Shift in 7-bit address
            // ============================================================
            DEV_ADDR: begin
                next_state = state;
                if (bit_cnt == 4'd7 && scl_falling) begin
                    next_state = R_W;
                end else begin                   
                    next_state = state;
                end
            end


            // ============================================================
            // R_W: Capture R/W bit and determine address match
            // ============================================================
            R_W: begin
                if (scl_falling && shift_reg[6:0] == MY_ADDR) begin
                    // ACK the address match
                    next_state = ACK_ADDR;
                end else if(scl_falling && shift_reg[6:0] != MY_ADDR) begin
                    // NACK and go to NACK state
                    next_state = NACK;
                end else begin
                    next_state = state;
                end
            end

            // ============================================================
            // ACK_ADDR: Acknowledge device address; move to REG or DATA_R
            // ============================================================
            ACK_ADDR: begin
                if (scl_falling) begin
                    next_state = rw_bit ? DATA_R : DEV_REG;
                end else begin
                    next_state = state;
                end
            end

            // ============================================================
            // DEV_REG: Receive the 8-bit register address
            // ============================================================
            DEV_REG: begin // experimental
                if (shift_reg <= VALID_REG && scl_falling && bit_cnt == 4'd8 ) begin// 
                    next_state = ACK_REG;
                end else if(shift_reg > VALID_REG && scl_falling && bit_cnt == 4'd8 ) begin//
                    next_state = NACK;
                end
            end
            
            // ============================================================
            // ACK_REG: Acknowledge register selection; allow Sr here
            // ============================================================
            ACK_REG: begin
                // Sr condition is handled globally
                if (scl_falling) begin
                    //next_state = rw_bit ? DATA_R : DATA_W;
                    next_state = DATA_W;
                end else begin
                    next_state = state;
                end
            end


            // ============================================================
            // DATA_W: Receive 8-bit data byte to write
            // ============================================================
            DATA_W: begin // experimental
                if (scl_falling && bit_cnt == 4'd8 && read_only_reg == 1'b0) begin// moda to scl_falling
                    next_state = ACK_DATA;
                end else if(scl_falling && bit_cnt == 4'd8 && read_only_reg == 1'b1 ) begin//
                    next_state = NACK;
                end else 
                    next_state = state;
            end

            // ============================================================
            // ACK_DATA: Acknowledge data write and go to WAIT
            // ============================================================
            ACK_DATA: begin
                if (scl_falling) begin
                    next_state = WAIT;
                end else begin
                    next_state = state;
                end
            end

            // ============================================================
            // DATA_R: Send 8-bit data to master
            // ============================================================
            DATA_R: begin               
                if (bit_cnt == 4'd8 && scl_falling) begin 
                    next_state = IDLE; // Wait for master NACK
                end else begin
                    next_state = state; // Hold value
                end
            end

            // ============================================================
            // NACK: Release SDA (no drive); go to WAIT after 1 SCL
            // ============================================================
            NACK: begin
                // Open-drain: SDA released
                if (scl_falling) begin
                    next_state = WAIT;
                end else begin  
                    next_state = state;
                end
            end

            // ============================================================
            // WAIT: SDA released; await STOP or Sr from master
            // ============================================================
            WAIT: begin
                next_state = state;
                // Self-loop if no STOP or START (handled globally)
            end

            //default: begin
                // Default case to avoid latches
                //next_state = next_state;
            //end
            endcase
        end
    end  
endmodule