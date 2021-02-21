`timescale 1ns/1ps

module tb_RISCV_lite ();
	
	reg CLK_i;
	reg RST_i;
	wire [31:0] INS_ADDR_in_i;
    wire [31:0] DATA_ADDR_in_i;
	wire [31:0] INS_out_i;
	wire MemWrite_i;
	wire MemRead_i;
	wire [31:0] DATA_ADDR_in;
	wire [31:0] DATA_in_i;
	wire [31:0] DATA_out_i;

	RISCV_lite uP(
		.CLK(CLK_i),
		.RST(RST_i),
		.INS_in(INS_out_i),
		.DATA_in(DATA_out_i),
		.INS_ADDR_out(INS_ADDR_in_i),
		.DATA_ADDR_out(DATA_ADDR_in_i),
		.DATA_out(DATA_in_i),
		.MemWrite(MemWrite_i),
		.MemRead(MemRead_i));

	IRAM IMEM(
		.CLK(CLK_i),
		.RST(RST_i),
		.INS_ADDR_in(INS_ADDR_in_i),
		.INS_out(INS_out_i));

	DRAM DMEM(
		.CLK(CLK_i),
		.RST(RST_i),
		.DATA_ADDR_in(DATA_ADDR_in_i),
		.DATA_in(DATA_in_i),
		.MemWrite(MemWrite_i),
		.MemRead(MemRead_i),
		.DATA_out(DATA_out_i));

	initial begin
	RST_i = 0; #2;
	RST_i = 1;
	end
	always begin
	CLK_i = 0; #1;
	CLK_i = 1; #1;
	end
endmodule
