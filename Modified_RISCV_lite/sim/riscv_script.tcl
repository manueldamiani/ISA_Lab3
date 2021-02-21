vcom -93 -work ./work ../src/constants.vhd
vcom -93 -work ./work ../src/instruction_set.vhd
vcom -93 -work ./work ../src/ALU_OPs.vhd

vcom -93 -work ./work ../src/HazardDetUnit.vhd


######## FETCH STAGE ########
vcom -93 -work ./work ../src/Pipeline/Fetch/IF_ID.vhd
vcom -93 -work ./work ../src/Pipeline/Fetch/mux21.vhd
vcom -93 -work ./work ../src/Pipeline/Fetch/PCReg.vhd
vcom -93 -work ./work ../src/Pipeline/IF.vhd

######## DECODE STAGE ########
vcom -93 -work ./work ../src/Pipeline/Decode/instruction_type.vhd
vcom -93 -work ./work ../src/Pipeline/Decode/instruction_decomposition.vhd
vcom -93 -work ./work ../src/Pipeline/Decode/registerfile.vhd
vcom -93 -work ./work ../src/Pipeline/Decode/CU.vhd
vcom -93 -work ./work ../src/Pipeline/Decode/regn.vhd
vcom -93 -work ./work ../src/Pipeline/ID.vhd

######## EXECUTE STAGE ########
vcom -93 -work ./work ../src/Pipeline/Execute/ABS_Value.vhd
vcom -93 -work ./work ../src/Pipeline/Execute/ALU.vhd
vcom -93 -work ./work ../src/Pipeline/Execute/EX_MEM.vhd
vcom -93 -work ./work ../src/Pipeline/Execute/FWD_Unit.vhd
vcom -93 -work ./work ../src/Pipeline/Execute/mux21.vhd
vcom -93 -work ./work ../src/Pipeline/Execute/mux41.vhd
vcom -93 -work ./work ../src/Pipeline/EX.vhd

######## MEMORY STAGE ########
vcom -93 -work ./work ../src/Pipeline/Memory/DFF.vhd
vcom -93 -work ./work ../src/Pipeline/Memory/regn.vhd
vcom -93 -work ./work ../src/Pipeline/MEM.vhd

######## WRITE BACK STAGE ########
vcom -93 -work ./work ../src/Pipeline/Write_Back/mux21.vhd
vcom -93 -work ./work ../src/Pipeline/WB.vhd

vcom -93 -work ./work ../src/HazardDetUnit.vhd
#vcom -93 -work ./work ../src/RISCV_lite.vhd
vlog -work ./work ../netlist/RISCV_lite_post_syn.v

######## TESTBENCH ########
vcom -93 -work ./work ../tb/DRAM.vhd
vcom -93 -work ./work ../tb/IRAM.vhd
vlog -work ./work ../tb/tb_RISCV_lite.v
#vsim work.tb_RISCV_lite
vsim -L /software/dk/nangate45/verilog/msim6.2g work.tb_RISCV_lite
