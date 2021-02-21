library IEEE;
use IEEE.std_logic_1164.all;

package instruction_set is

	-- The RISC-V Lite instruction set is a subset of the RV32I Base Instruction Set
	-- All instructions have a fixed 32-bit length
	
	----------- Instruction Types -------------------------------------------------------------------------------------------------------
	-- R-Type  : |    Funct7       | RS2 | RS1 |   Funct3    |     RD         | OPCODE |
	-- I-Type  : |    IMM11:0            | RS1 |   Funct3    |     RD         | OPCODE |
	-- S-Type  : |    IMM11:5      | RS2 | RS1 |   Funct3    |   IMM4:0       | OPCODE |
	-- B-Type : | IMM12 | IMM10:5 | RS2 | RS1 |   Funct3    | IMM4:1 | IMM11 | OPCODE | (IMM12+IMM10:5 = IMM11:5; IMM4:1 + IMM11 = IMM4:0; must be reordered)
	-- U-Type  : |   IMM31:12                                |     RD         | OPCODE |
	-- J-Type : | IMM20 | IMM10:1 | IMM11 | IMM19:12        |     RD         | OPCODE | (IM31:12, to be reordered)
	-------------------------------------------------------------------------------------------------------------------------------------

	----------- Instruction Fields -----------

	-- Funct7 (7 bits)
	constant Funct7_begin : integer := 31;
	constant Funct7_size  : integer := 7;
	constant Funct7_end   : integer := Funct7_begin - Funct7_size + 1;

	-- IMM11:0 (12 bits)
	constant IMM12_begin : integer := 31;
	constant IMM12_size  : integer := 12;
	constant IMM12_end   : integer := IMM12_begin - IMM12_size + 1;

	-- IMM11:5 (7 bits)
	constant IMM7_begin : integer := 31;
    constant IMM7_size  : integer := 7;
	constant IMM7_end   : integer := IMM7_begin - IMM7_size + 1;

	-- IMM31:12 (20 bits)
	constant IMM20_begin : integer := 31;
    constant IMM20_size  : integer := 20;
	constant IMM20_end   : integer := IMM20_begin - IMM20_size + 1;

	-- IMM4:0 (5 bits)
	constant IMM5_begin : integer := 11;
    constant IMM5_size  : integer := 5;
	constant IMM5_end   : integer := IMM5_begin - IMM5_size + 1;

	-- RS2 (5 bits)
	constant RS2_begin : integer := 24;
    constant RS2_size  : integer := 5;
	constant RS2_end   : integer := RS2_begin - RS2_size + 1;

	-- RS1 (5 bits)
	constant RS1_begin : integer := 19;
    constant RS1_size  : integer := 5;
	constant RS1_end   : integer := RS1_begin - RS1_size + 1;

	-- Funct3 (3 bits)
	constant Funct3_begin : integer := 14;
    constant Funct3_size  : integer := 3;
	constant Funct3_end   : integer := Funct3_begin - Funct3_size + 1;

	-- RD (5 bits)
	constant RD_begin : integer := 11;
    constant RD_size  : integer := 5;
	constant RD_end   : integer := RD_begin - RD_size + 1;

	-- OPCODE (7 bits) --
	constant OPCODE_begin: integer := 6;
	constant OPCODE_size : integer := 7;
	constant OPCODE_end  : integer := OPCODE_begin - OPCODE_size + 1;


	-- Instruction OPCODEs

	-- R-Type
		constant RType_Arith : std_logic_vector(OPCODE_size-1 downto 0) := "0110011";
		-- ADD
		constant ADD_OP : std_logic_vector(OPCODE_size-1 downto 0) := "0110011";
		constant ADD_Funct7 : std_logic_vector(Funct7_size-1 downto 0) := "0000000";
		constant ADD_Funct3 : std_logic_vector(Funct3_size-1 downto 0) := "000";
		-- XOR
		constant XOR_OP : std_logic_vector(OPCODE_size-1 downto 0) := "0110011";
		constant XOR_Funct7 : std_logic_vector(Funct7_size-1 downto 0) := "0000000";
		constant XOR_Funct3 : std_logic_vector(Funct3_size-1 downto 0) := "100";
		-- SLT (Set <)
		constant SLT_OP : std_logic_vector(OPCODE_size-1 downto 0) := "0110011";
		constant SLT_Funct7 : std_logic_vector(Funct7_size-1 downto 0) := "0000000";
		constant SLT_Funct3 : std_logic_vector(Funct3_size-1 downto 0) := "010";
		-- ABS (Computes absolute value)
		constant ABS_OP : std_logic_vector(OPCODE_size-1 downto 0) := "0110011";
		constant ABS_Funct7 : std_logic_vector(Funct7_size-1 downto 0) := "0000001";
		constant ABS_Funct3 : std_logic_vector(Funct3_size-1 downto 0) := "111";

	-- I-Type
		constant IType_Arith : std_logic_vector(OPCODE_size-1 downto 0) := "0010011";
		-- LW
		constant LW_OP : std_logic_vector(OPCODE_size-1 downto 0) := "0000011";
		constant LW_Funct3 : std_logic_vector(Funct3_size-1 downto 0) := "010";
		-- SRAI (Shift Right Arith Imm)
		constant SRAI_OP : std_logic_vector(OPCODE_size-1 downto 0) := "0010011";
		constant SRAI_Funct3 : std_logic_vector(Funct3_size-1 downto 0) := "101";
		-- ADDI
		constant ADDI_OP : std_logic_vector(OPCODE_size-1 downto 0) := "0010011";
		constant ADDI_Funct3 : std_logic_vector(Funct3_size-1 downto 0) := "000";
		-- ANDI
		constant ANDI_OP : std_logic_vector(OPCODE_size-1 downto 0) := "0010011";
		constant ANDI_Funct3 : std_logic_vector(Funct3_size-1 downto 0) := "111";

	-- S-Type
		-- SW
		constant SW_OP : std_logic_vector(OPCODE_size-1 downto 0) := "0100011";
		constant SW_Funct3 : std_logic_vector(Funct3_size-1 downto 0) := "010";

	-- B-Type
		-- BEQ
		constant BEQ_OP : std_logic_vector(OPCODE_size-1 downto 0) := "1100011";
		constant BEQ_Funct3 : std_logic_vector(Funct3_size-1 downto 0) := "000";

	-- U-Type
		-- LUI (Load Upper Immediate)
		constant LUI_OP : std_logic_vector(OPCODE_size-1 downto 0) := "0110111";
		-- AUIPC (Add Upper Imm. to PC)
		constant AUIPC_OP : std_logic_vector(OPCODE_size-1 downto 0) := "0010111";

	-- J-Type
		-- JAL
		constant JAL_OP : std_logic_vector(OPCODE_size-1 downto 0) := "1101111";

end package;
