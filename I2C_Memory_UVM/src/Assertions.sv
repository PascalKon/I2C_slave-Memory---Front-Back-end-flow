module register_file_assertions
(
    input logic        clk,
    input logic        rst_n,
    input logic        Reg_write,
    input logic        Reg_read,
    input logic [5:0]  Reg_addr,
    input logic [7:0]  Data_out,
    input logic [7:0]  registers [0:36],
    input logic        registers_en[0:36]
);

    // Helper function to detect ADC registers
    function automatic bit is_adc_addr(input logic [5:0] addr);
        return (addr >= 6'd3 && addr <= 6'd5);
    endfunction

    // 1. ADC registers must not change during a read
    
    property no_adc_overwrite_during_read;
        @(negedge clk)
        disable iff (!rst_n)
        (Reg_read && !Reg_write && is_adc_addr(Reg_addr) && registers_en[Reg_addr]) |=> 
            $stable(registers[Reg_addr]);
    endproperty
    assert property (no_adc_overwrite_during_read)
        else $error("ADC register %0d changed during read!", Reg_addr);

    // 2. Read data must match register value

    property adc_data_consistency;
        @(posedge clk)
        disable iff (!rst_n)
        (Reg_read && !Reg_write && is_adc_addr(Reg_addr) && !registers_en[Reg_addr]) |-> ##1 
            (Data_out ==  $past(registers[Reg_addr],1));
    endproperty
    assert property (adc_data_consistency)
        else $error("ADC read data mismatch for register %0d!", Reg_addr);

    // 3. No write enable during ADC read

    property no_write_enable_on_adc_during_read;
        @(negedge clk)
        disable iff (!rst_n)
        (Reg_read && is_adc_addr(Reg_addr) && registers_en[Reg_addr] ) 
        |-> ##1 (!registers_en[Reg_addr]) ##1 (registers_en[Reg_addr]); 
    endproperty

    assert property (no_write_enable_on_adc_during_read)
        else $error("ADC register %0d was write-enabled during read!", Reg_addr);
    
endmodule
