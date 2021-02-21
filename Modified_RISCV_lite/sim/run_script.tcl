add wave sim:/tb_RISCV_lite/DMEM/clk
add wave sim:/tb_RISCV_lite/DMEM/rst

add wave sim:/tb_RISCV_lite/IMEM/irammem
add wave sim:/tb_RISCV_lite/DMEM/drammem
add wave sim:/tb_RISCV_lite/uP/decode/rf/registers

add wave sim:/tb_RISCV_lite/INS_ADDR_in_i
add wave sim:/tb_RISCV_lite/DATA_ADDR_in_i
add wave sim:/tb_RISCV_lite/INS_out_i
add wave sim:/tb_RISCV_lite/MemWrite_i
add wave sim:/tb_RISCV_lite/MemRead_i
add wave sim:/tb_RISCV_lite/DATA_in_i
add wave sim:/tb_RISCV_lite/DATA_out_i

add wave sim:/tb_RISCV_lite/DMEM/data_addr_in
add wave sim:/tb_RISCV_lite/DMEM/data_in
add wave sim:/tb_RISCV_lite/DMEM/memwrite
add wave sim:/tb_RISCV_lite/DMEM/memread
add wave sim:/tb_RISCV_lite/DMEM/data_out
add wave sim:/tb_RISCV_lite/DMEM/data_addr_masked
add wave sim:/tb_RISCV_lite/DMEM/data_addr

add wave sim:/tb_RISCV_lite/uP/fetch/pc_ext
add wave sim:/tb_RISCV_lite/uP/fetch/pcsrc
add wave sim:/tb_RISCV_lite/uP/fetch/pc_out
add wave sim:/tb_RISCV_lite/uP/fetch/ins_out
add wave sim:/tb_RISCV_lite/uP/fetch/pc_output

add wave sim:/tb_RISCV_lite/uP/decode/ctrl_unit/ins_out
add wave sim:/tb_RISCV_lite/uP/decode/ctrl_unit/branch
add wave sim:/tb_RISCV_lite/uP/decode/ctrl_unit/branch_type
add wave sim:/tb_RISCV_lite/uP/decode/ctrl_unit/regwrite
add wave sim:/tb_RISCV_lite/uP/decode/ctrl_unit/alusrc1
add wave sim:/tb_RISCV_lite/uP/decode/ctrl_unit/alusrc2
add wave sim:/tb_RISCV_lite/uP/decode/ctrl_unit/aluop
add wave sim:/tb_RISCV_lite/uP/decode/ctrl_unit/memwrite
add wave sim:/tb_RISCV_lite/uP/decode/ctrl_unit/memread
add wave sim:/tb_RISCV_lite/uP/decode/ctrl_unit/memtoreg
add wave sim:/tb_RISCV_lite/uP/decode/ctrl_unit/cw

add wave sim:/tb_RISCV_lite/uP/decode/rf/rs1
add wave sim:/tb_RISCV_lite/uP/decode/rf/rs2
add wave sim:/tb_RISCV_lite/uP/decode/rf/wr
add wave sim:/tb_RISCV_lite/uP/decode/rf/add_wr
add wave sim:/tb_RISCV_lite/uP/decode/rf/add_rs1
add wave sim:/tb_RISCV_lite/uP/decode/rf/add_rs2
add wave sim:/tb_RISCV_lite/uP/decode/rf/datain
add wave sim:/tb_RISCV_lite/uP/decode/rf/out1
add wave sim:/tb_RISCV_lite/uP/decode/rf/out2
add wave sim:/tb_RISCV_lite/uP/decode/rf_data1_out
add wave sim:/tb_RISCV_lite/uP/decode/rf_data2_out

add wave sim:/tb_RISCV_lite/uP/execute/imm_in
add wave sim:/tb_RISCV_lite/uP/execute/fwd/rs1
add wave sim:/tb_RISCV_lite/uP/execute/fwd/rs2
add wave sim:/tb_RISCV_lite/uP/execute/fwd/rd_exmem
add wave sim:/tb_RISCV_lite/uP/execute/fwd/rd_memwb
add wave sim:/tb_RISCV_lite/uP/execute/fwd/regwrite_exmem
add wave sim:/tb_RISCV_lite/uP/execute/fwd/regwrite_memwb
add wave sim:/tb_RISCV_lite/uP/execute/fwd/forwarda
add wave sim:/tb_RISCV_lite/uP/execute/fwd/forwardb

add wave sim:/tb_RISCV_lite/uP/execute/branch_in
add wave sim:/tb_RISCV_lite/uP/execute/branch_type_in
add wave sim:/tb_RISCV_lite/uP/execute/sig_op2
add wave sim:/tb_RISCV_lite/uP/execute/sig_op1
add wave sim:/tb_RISCV_lite/uP/execute/sig_alu_res
add wave sim:/tb_RISCV_lite/uP/execute/sig_zero
add wave sim:/tb_RISCV_lite/uP/execute/fwda
add wave sim:/tb_RISCV_lite/uP/execute/fwdb
add wave sim:/tb_RISCV_lite/uP/execute/alusrc1_in
add wave sim:/tb_RISCV_lite/uP/execute/alusrc2_in
add wave sim:/tb_RISCV_lite/uP/execute/op1_fw
add wave sim:/tb_RISCV_lite/uP/execute/op2_fw

add wave sim:/tb_RISCV_lite/uP/memory/zero_in
add wave sim:/tb_RISCV_lite/uP/memory/alu_res_in
add wave sim:/tb_RISCV_lite/uP/memory/branch_in
add wave sim:/tb_RISCV_lite/uP/memory/data_in
add wave sim:/tb_RISCV_lite/uP/memory/data_out
add wave sim:/tb_RISCV_lite/uP/memory/pcsrc
add wave sim:/tb_RISCV_lite/uP/memory/op_exmem
add wave sim:/tb_RISCV_lite/uP/memory/rd_exmem

add wave sim:/tb_RISCV_lite/uP/writeback/data_in
add wave sim:/tb_RISCV_lite/uP/writeback/alu_res_in
add wave sim:/tb_RISCV_lite/uP/writeback/add_rd_out
add wave sim:/tb_RISCV_lite/uP/writeback/data_out

add wave sim:/tb_RISCV_lite/uP/hdu/*

run 500 ns

