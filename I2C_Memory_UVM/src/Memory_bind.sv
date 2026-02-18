bind Memory register_file_assertions regfile_asrt (
    .clk(clk),
    .rst_n(rst_n),
    .Reg_write(Reg_write),
    .Reg_read(Reg_read),
    .Reg_addr(Reg_addr),
    .Data_out(Data_out),
    .registers(registers),
    .registers_en(registers_en)
);