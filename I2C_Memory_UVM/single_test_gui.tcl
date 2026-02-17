#available testnames 
#i2c_simple_test
#i2c_spec_addr_reg_order_no_adc_test 
#i2c_spec_addr_reg_order_adc_test
#i2c_address_test 
#i2c_adc_test
#i2c_invalid_address_test 
#i2c_invalid_regs_test 
#i2c_invalid_adc_write_test 
#i2c_all_in_one_test


set TESTNAME = i2c_invalid_regs_test 
xrun -gui -f run.args  -coverage all +VERBOSITY=UVM_NONE +UVM_TESTNAME=$TESTNAME -l Single_Test_Gui_Xrun_Results/${TESTNAME}/${TESTNAME}.log +DUMPNAME=Single_Test_Gui_Xrun_Results/${TESTNAME}/"${TESTNAME}.vcd" -covtest ${TESTNAME}
