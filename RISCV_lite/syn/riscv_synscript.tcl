analyze -f vhdl -lib WORK ../src/constants.vhd
analyze -f vhdl -lib WORK ../src/instruction_set.vhd
analyze -f vhdl -lib WORK ../src/ALU_OPs.vhd

######## FETCH STAGE ########
analyze -f vhdl -lib WORK ../src/Pipeline/Fetch/IF_ID.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/Fetch/mux21.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/Fetch/PCReg.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/Fetch/regn.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/IF.vhd

######## DECODE STAGE ########
analyze -f vhdl -lib WORK ../src/Pipeline/Decode/instruction_type.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/Decode/instruction_decomposition.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/Decode/registerfile.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/Decode/CU.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/Decode/regn.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/ID.vhd

######## EXECUTE STAGE ########
analyze -f vhdl -lib WORK ../src/Pipeline/Execute/ALU.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/Execute/EX_MEM.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/Execute/FWD_Unit.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/Execute/mux21.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/Execute/mux41.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/EX.vhd

######## MEMORY STAGE ########
analyze -f vhdl -lib WORK ../src/Pipeline/Memory/DFF.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/Memory/regn.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/MEM.vhd

######## WRITE BACK STAGE ########
analyze -f vhdl -lib WORK ../src/Pipeline/Write_Back/mux21.vhd
analyze -f vhdl -lib WORK ../src/Pipeline/WB.vhd

analyze -f vhdl -lib WORK ../src/HazardDetUnit.vhd
analyze -f vhdl -lib WORK ../src/RISCV_lite.vhd

set power_preserve_rtl_hier_names true
elaborate RISCV_lite -arch struct -lib WORK > ./elaborate.txt
create_clock -name MY_CLK -period 0 CLK
set_dont_touch_network MY_CLK
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] CLK]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]

compile
report_resources > ./report_resources.txt
report_timing > ./report_timing.txt
report_area > ./report_area.txt
ungroup -all -flatten
change_names -hierarchy -rules verilog
write_sdf ../netlist/RISCV_lite.sdf
write -f verilog -hierarchy -output ../netlist/RISCV_lite_post_syn.v
write_sdc ../netlist/RISCV_lite.sdc
