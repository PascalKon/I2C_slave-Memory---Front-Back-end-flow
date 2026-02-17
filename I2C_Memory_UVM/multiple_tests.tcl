#!/bin/tcsh

# Array of test names
 set TESTNAMES = (i2c_simple_test i2c_address_test i2c_spec_addr_reg_order_no_adc_test i2c_spec_addr_reg_order_adc_test i2c_invalid_address_test i2c_invalid_regs_test i2c_invalid_adc_write_test i2c_adc_test)

 # Number of times to run each test
 set N = 1

 # Iterate over test names
 foreach TESTNAME ($TESTNAMES)
 	# Inner loop to run each test N times
 	foreach i (`seq 1 $N`)
 	# Run the command with the current test name and seed
 		echo "\n\nRunning test: $TESTNAME, seed: $i\n\n"
 		xrun -batch -f run.args  -coverage all +VERBOSITY=UVM_NONE +UVM_TESTNAME=$TESTNAME -l Multiple_Tests_xrun_Results/${TESTNAME}_$i.log +DUMPNAME=Multiple_Tests_xrun_Results/"${TESTNAME}_$i.vcd" -covtest "MT_${TESTNAME}" -covoverwrite
 	end
 end
