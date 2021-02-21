-- RISC-V lite top-level entity
library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use work.instruction_set.all;
use work.ALU_OPs.all;

entity RISCV_lite is
	port( CLK     : in std_logic; 
		  RST	  : in std_logic; -- Reset signal, active low
		  INS_in  : in std_logic_vector(NBIT-1 downto 0); -- from instruction memory
		  DATA_in  : in std_logic_vector(NBIT-1 downto 0); -- from data memory
		  INS_ADDR_out  : out std_logic_vector(NBIT-1 downto 0); -- from Fetch to instruction memory
		  DATA_ADDR_out : out std_logic_vector(NBIT-1 downto 0); -- from MEM to data memory
		  DATA_out      : out std_logic_vector(NBIT-1 downto 0); -- from MEM to data memory
		  MemWrite      : out std_logic; -- Data memory write signal
		  MemRead		: out std_logic); -- Data memory read signal
end RISCV_lite;

architecture struct of RISCV_lite is

-- Component declarations
component IF_Stage is
	port( CLK      : in std_logic; 
		  RST	   : in std_logic;
		  PC_EXT   : in std_logic_vector(NBIT-1 downto 0); -- coming from EX/MEM pipeline reg
		  PCSrc    : in std_logic; -- MUX selection: take the incremented PC or use an external PC from MEM stage (i.e. due to taken branch)
		  INS_IN   : in std_logic_vector(NBIT-1 downto 0); -- instruction that needs to be split into the various fields coming from the IRAM
		  PC_OUT   : out std_logic_vector(NBIT-1 downto 0); -- to stage output
		  ADDR_out : out std_logic_vector(NBIT-1 downto 0); -- to instruction memory
		  INS_OUT  : out std_logic_vector(NBIT-1 downto 0); -- instruction that needs to be split into the various fields exiting from the IF/ID pipeline reg
		  --- From HDU --
		  Bubble_in : in std_logic;
		  INS_IN_HDU: in std_logic_vector(NBIT-1 downto 0); --instruction causing the load use hazard
		  PC_IN_HDU : in std_logic_vector(NBIT-1 downto 0); --PC of the instruction causing the load use hazard
		  PC_inc_HDU : in std_logic_vector(NBIT-1 downto 0)); --PC of the instruction following the one causing the load use hazard to be stored in PCreg
end component;

component ID is
	port( CLK          : in std_logic; 
		  RST          : in std_logic;
		  Bubble_in : in std_logic;
	      PC_IN        : in std_logic_vector(NBIT-1 downto 0); -- PC coming from the IF stage
		  INS_IN       : in std_logic_vector(NBIT-1 downto 0); -- instruction to be split into the various fields coming from the IF stage
		  ADD_WR_IN    : in std_logic_vector(NBIT_ADD-1 downto 0); -- Address of the destination register, from WB stage
		  DATA_WR_IN   : in std_logic_vector(NBIT-1 downto 0); -- Data to be written in the RF coming from the WB stage
		  RegWrite     : in std_logic; -- Write enable coming from the WB stage
		  PCSrc		   : in std_logic; -- Used as flush if branch taken
		  PC_OUT       : out std_logic_vector(NBIT-1 downto 0); -- coming from PC
		  RF_Data1_OUT : out std_logic_vector(NBIT-1 downto 0);
		  RF_Data2_OUT : out std_logic_vector(NBIT-1 downto 0);
		  IMM_OUT      : out std_logic_vector(NBIT-1 downto 0);
		  ADD_RD_OUT   : out std_logic_vector(NBIT_ADD-1 downto 0);
		  ADD_RS1_OUT : out std_logic_vector(NBIT_ADD-1 downto 0); -- RS1 address for forwarding
		  ADD_RS2_OUT : out std_logic_vector(NBIT_ADD-1 downto 0); -- RS2 address for forwarding
		  -- From CU --
		  Branch_out      : out std_logic;
		  Branch_type_out : out std_logic;
		  RegWrite_out    : out std_logic;
		  ALUSrc1_out     : out std_logic;
		  ALUSrc2_out     : out std_logic_vector(1 downto 0);
		  ALUOp_out       : out std_logic_vector(ALU_OPC_SIZE-1 downto 0);
		  MemWrite_out    : out std_logic;
		  MemRead_out     : out std_logic;
		  MemtoReg_out    : out std_logic;
		--For HDU--
		  ADD_RS1_HDU : out std_logic_vector(NBIT_ADD-1 downto 0); 
		  ADD_RS2_HDU : out std_logic_vector(NBIT_ADD-1 downto 0));		  
end component;

component EX is
	port( CLK		     : in std_logic; 
		  RST 		     : in std_logic;
		  PC_in          : in std_logic_vector(NBIT-1 downto 0);
		  RF_Data1_IN    : in std_logic_vector(NBIT-1 downto 0);
		  RF_Data2_IN    : in std_logic_vector(NBIT-1 downto 0);
		  IMM_IN         : in std_logic_vector(NBIT-1 downto 0);
		  ADD_RD_IN      : in std_logic_vector(NBIT_ADD-1 downto 0);
		  RS1_IN	     : in std_logic_vector(NBIT_ADD-1 downto 0); -- For Forwarding
		  RS2_IN	     : in std_logic_vector(NBIT_ADD-1 downto 0); -- For Forwarding
		  RD_EXMEM	     : in std_logic_vector(NBIT_ADD-1 downto 0); -- Mem stage RD
		  RD_MEMWB       : in std_logic_vector(NBIT_ADD-1 downto 0); -- WB stage RD
		  RegWrite_EXMEM : in std_logic; -- Mem stage RegWrite
		  RegWrite_MEMWB : in std_logic; -- WB stage RegWrite
		  OP_EXMEM		 : in std_logic_vector(NBIT-1 downto 0);
		  OP_MEMWB		 : in std_logic_vector(NBIT-1 downto 0);
		  PCSrc 		 : in std_logic; -- Used as flush if branch taken
		  -- From CU --
		  Branch_in      : in std_logic;
		  Branch_type_in : in std_logic;
		  RegWrite_in    : in std_logic;
		  ALUSrc1_in     : in std_logic;
		  ALUSrc2_in     : in std_logic_vector(1 downto 0);
		  ALUOp_in	     : in std_logic_vector(ALU_OPC_SIZE-1 downto 0);
		  MemWrite_in    : in std_logic;
		  MemRead_in     : in std_logic;
		  MemtoReg_in    : in std_logic;
		  ---
		  PCext_out	   : out std_logic_vector(NBIT-1 downto 0);
		  Zero_out     : out std_logic;
		  ALU_RES_out  : out std_logic_vector(NBIT-1 downto 0);
		  RF_Data2_OUT : out std_logic_vector(NBIT-1 downto 0);
		  ADD_RD_out   : out std_logic_vector(NBIT_ADD-1 downto 0);
		  Branch_out      : out std_logic;
		  Branch_type_out : out std_logic;
		  RegWrite_out    : out std_logic;
		  MemWrite_out    : out std_logic;
		  MemRead_out     : out std_logic;
		  MemtoReg_out    : out std_logic);
end component;

component MEM is
	port( CLK		   : in std_logic; 
		  RST 		   : in std_logic;
		  PCext_in	   : in std_logic_vector(NBIT-1 downto 0);
		  Zero_in      : in std_logic;
		  ALU_RES_in   : in std_logic_vector(NBIT-1 downto 0);
		  RF_Data2_in  : in std_logic_vector(NBIT-1 downto 0);
		  ADD_RD_in    : in std_logic_vector(NBIT_ADD-1 downto 0);
		  -- From CU --
		  Branch_in    : in std_logic;
		  Branch_type_in : in std_logic;
		  RegWrite_in  : in std_logic;
		  MemWrite_in  : in std_logic;
		  MemRead_in   : in std_logic;
		  MemtoReg_in  : in std_logic;
		  ---
		  Data_in	   : in std_logic_vector(NBIT-1 downto 0); -- from Data memory
		  Data_out	   : out std_logic_vector(NBIT-1 downto 0);
		  ADD_RD_out   : out std_logic_vector(NBIT_ADD-1 downto 0);
		  ALU_RES_out  : out std_logic_vector(NBIT-1 downto 0);
		  ADDR_out	   : out std_logic_vector(NBIT-1 downto 0); -- ALU RES sent to Data memory
		  RF_Data2_out : out std_logic_vector(NBIT-1 downto 0); -- Data originally taken from the RF sent to Data memory
		  PCSrc	       : out std_logic;
		  PCext_out    : out std_logic_vector(NBIT-1 downto 0);
		  RegWrite_out : out std_logic;
		  MemWrite_out : out std_logic;
		  MemRead_out  : out std_logic;
		  MemtoReg_out : out std_logic;
		  -- Signals for forwarding
		  RegWrite_EXMEM : out std_logic;
		  OP_EXMEM : out std_logic_vector(NBIT-1 downto 0);
		  RD_EXMEM : out std_logic_vector(NBIT_ADD-1 downto 0));
end component;

component WB is
	port( Data_in	   : in std_logic_vector(NBIT-1 downto 0);
		  ADD_RD_in    : in std_logic_vector(NBIT_ADD-1 downto 0);
		  ALU_RES_in   : in std_logic_vector(NBIT-1 downto 0);
		  RegWrite_in  : in std_logic;
		  MemtoReg_in  : in std_logic;
		  ADD_RD_out   : out std_logic_vector(NBIT_ADD-1 downto 0);
		  RegWrite_out : out std_logic;
		  Data_out	   : out std_logic_vector(NBIT-1 downto 0));
end component;

component HazardDetUnit is
	port( 	RST : in std_logic;
			RS1_IFID : in std_logic_vector(NBIT_ADD-1 downto 0);
			RS2_IFID : in std_logic_vector(NBIT_ADD-1 downto 0);
			RD_IDEX : in std_logic_vector(NBIT_ADD-1 downto 0);
			MemRead_IDEX : in std_logic;
			INS_INPUT: in std_logic_vector(NBIT-1 downto 0);
			PC_INPUT : in std_logic_vector(NBIT-1 downto 0);
			Bubble_out: out std_logic;
			INS_OUTPUT_HDU: out std_logic_vector(NBIT-1 downto 0);
			PC_OUPUT_HDU : out std_logic_vector(NBIT-1 downto 0);
			PC_inc_HDU : out std_logic_vector(NBIT-1 downto 0));	-- Bubble ='1' if there is a stall  
end component;


-- Signal declarations
signal PC_EXT_EX, PC_EXT_MEM, PC_IFID, INS_OUT_IFID, DATA_WB, PC_IDEX, RF_Data1_IDEX, RF_Data2_IDEX, IMM_OUT_IDEX, ALU_RES_EXMEM, RF_Data2_EXMEM : std_logic_vector(NBIT-1 downto 0);
signal Data_out_MEMWB, ALU_RES_MEMWB : std_logic_vector(NBIT-1 downto 0);

signal PCSrc_MEM, RegWrite_WB, Branch_IDEX, RegWrite_IDEX, ALUSrc1_IDEX : std_logic;
signal ALUSrc2_IDEX : std_logic_vector(1 downto 0);
signal MemWrite_IDEX, MemRead_IDEX, MemtoReg_IDEX, Zero_EXMEM, Branch_EXMEM, RegWrite_EXMEM, MemWrite_EXMEM, MemRead_EXMEM, MemtoReg_EXMEM : std_logic;
signal Branch_typeIDEX, Branch_typeEXMEM, RegWrite_MEMWB, MemtoReg_MEMWB : std_logic;

signal ADD_WB, ADD_RD_IDEX, ADD_RS1_IDEX, ADD_RS2_IDEX, ADD_RD_EXMEM, ADD_RD_MEMWB : std_logic_vector(NBIT_ADD-1 downto 0);
signal RD_EXMEM, RD_MEMWB : std_logic_vector(NBIT_ADD-1 downto 0); -- RD for forwarding
signal RegWrite_EXMEMFW : std_logic; -- RegWrite EXMEM for forwarding
signal OP_EXMEM : std_logic_vector(NBIT-1 downto 0);
signal ALUOp_IDEX : std_logic_vector(ALU_OPC_SIZE-1 downto 0);
signal ADDRS1_HDU,ADDRS2_HDU : std_logic_vector(NBIT_ADD-1 downto 0);
signal sig_bubble: std_logic;
signal sig_INS_OUTPUT_HDU,sig_PC_OUPUT_HDU,sig_PC_inc_HDU : std_logic_vector(NBIT-1 downto 0);

begin

	Fetch : IF_Stage port map(  CLK => CLK,
					RST => RST,
					PC_EXT => PC_EXT_MEM,
					PCSrc => PCSrc_MEM,
					INS_IN => INS_in,
					PC_OUT => PC_IFID,
					ADDR_out => INS_ADDR_out,
					INS_OUT => INS_OUT_IFID,
					Bubble_in => sig_Bubble,
					INS_IN_HDU => sig_INS_OUTPUT_HDU,
					PC_IN_HDU => sig_PC_OUPUT_HDU,
					PC_inc_HDU => sig_PC_inc_HDU);	

	Decode : ID port map( CLK => CLK, 
						  RST => RST,
						  Bubble_in => sig_Bubble,
						  PC_IN => PC_IFID,
						  INS_IN => INS_OUT_IFID,
						  ADD_WR_IN => ADD_WB,
						  DATA_WR_IN => DATA_WB,
						  RegWrite => RegWrite_WB,
						  PCSrc => PCSrc_MEM,
						  PC_OUT => PC_IDEX,
						  RF_Data1_OUT => RF_Data1_IDEX,
						  RF_Data2_OUT => RF_Data2_IDEX,
						  IMM_OUT => IMM_OUT_IDEX,
						  ADD_RD_OUT => ADD_RD_IDEX,
						  ADD_RS1_OUT => ADD_RS1_IDEX,
						  ADD_RS2_OUT => ADD_RS2_IDEX,
						  Branch_out => Branch_IDEX,
						  Branch_type_out => Branch_typeIDEX,
						  RegWrite_out => RegWrite_IDEX,
						  ALUSrc1_out => ALUSrc1_IDEX,
						  ALUSrc2_out => ALUSrc2_IDEX,
						  ALUOp_out => ALUOp_IDEX,
						  MemWrite_out => MemWrite_IDEX,
						  MemRead_out => MemRead_IDEX,
						  MemtoReg_out => MemtoReg_IDEX,
						  ADD_RS1_HDU => ADDRS1_HDU,
		  				  ADD_RS2_HDU => ADDRS2_HDU);
	
	Execute : EX port map(CLK => CLK,
						  RST => RST,
						  PC_in => PC_IDEX,
						  RF_Data1_IN => RF_Data1_IDEX,
						  RF_Data2_IN  => RF_Data2_IDEX,
						  IMM_IN => IMM_OUT_IDEX,
						  ADD_RD_IN => ADD_RD_IDEX,
						  RS1_IN => ADD_RS1_IDEX,
						  RS2_IN => ADD_RS2_IDEX,
						  RD_EXMEM => RD_EXMEM,
						  RD_MEMWB => ADD_RD_MEMWB,
						  RegWrite_EXMEM => RegWrite_EXMEMFW,
						  RegWrite_MEMWB => RegWrite_WB,
						  OP_EXMEM => OP_EXMEM,
						  OP_MEMWB => DATA_WB,
						  PCSrc => PCSrc_MEM,
						  Branch_in => Branch_IDEX,
						  Branch_type_in => Branch_typeIDEX,
						  RegWrite_in => RegWrite_IDEX,
						  ALUSrc1_in => ALUSrc1_IDEX,
						  ALUSrc2_in => ALUSrc2_IDEX,
						  ALUOp_in => ALUOp_IDEX,
						  MemWrite_in => MemWrite_IDEX,
						  MemRead_in => MemRead_IDEX,
						  MemtoReg_in => MemtoReg_IDEX,
						  PCext_out => PC_EXT_EX,
						  Zero_out => Zero_EXMEM,
						  ALU_RES_out => ALU_RES_EXMEM,
						  RF_Data2_OUT => RF_Data2_EXMEM,
						  ADD_RD_out => ADD_RD_EXMEM,
						  Branch_out => Branch_EXMEM,
						  Branch_type_out => Branch_typeEXMEM,
						  RegWrite_out => RegWrite_EXMEM,
						  MemWrite_out => MemWrite_EXMEM,
						  MemRead_out => MemRead_EXMEM,
						  MemtoReg_out => MemtoReg_EXMEM);
	
	Memory : MEM port map(CLK => CLK,
						  RST => RST,
						  PCext_in => PC_EXT_EX,
						  Zero_in => Zero_EXMEM,
						  ALU_RES_in => ALU_RES_EXMEM,
						  RF_Data2_in => RF_Data2_EXMEM,
						  ADD_RD_in => ADD_RD_EXMEM,
						  Branch_in => Branch_EXMEM,
						  Branch_type_in => Branch_typeEXMEM,
						  RegWrite_in => RegWrite_EXMEM,
						  MemWrite_in => MemWrite_EXMEM,
						  MemRead_in => MemRead_EXMEM,
						  MemtoReg_in => MemtoReg_EXMEM,
						  Data_in => DATA_in,
						  Data_out => Data_out_MEMWB,
						  ADD_RD_out => ADD_RD_MEMWB,
						  ALU_RES_out => ALU_RES_MEMWB,
						  ADDR_out => DATA_ADDR_out,
						  RF_Data2_out => DATA_out,
						  PCSrc => PCSrc_MEM,
						  PCext_out => PC_EXT_MEM,
						  RegWrite_out => RegWrite_MEMWB,
						  MemWrite_out => MemWrite,
						  MemRead_out => MemRead,
						  MemtoReg_out => MemtoReg_MEMWB,
						  RegWrite_EXMEM => RegWrite_EXMEMFW,
						  OP_EXMEM => OP_EXMEM,
						  RD_EXMEM => RD_EXMEM);
	
	Writeback : WB port map(Data_in => Data_out_MEMWB,
							ADD_RD_in => ADD_RD_MEMWB,
							ALU_RES_in => ALU_RES_MEMWB,
							RegWrite_in => RegWrite_MEMWB,
							MemtoReg_in => MemtoReg_MEMWB,
							ADD_RD_out => ADD_WB,
							RegWrite_out => RegWrite_WB,
							Data_out => DATA_WB);

	HDU : HazardDetUnit port map (RST => RST,
					RS1_IFID => ADDRS1_HDU,
					RS2_IFID => ADDRS2_HDU,
					RD_IDEX => ADD_RD_IDEX,
					INS_INPUT =>INS_OUT_IFID,
					PC_INPUT => PC_IFID,
					MemRead_IDEX => MemRead_IDEX,
					Bubble_out => sig_Bubble,
					INS_OUTPUT_HDU => sig_INS_OUTPUT_HDU,
					PC_OUPUT_HDU => sig_PC_OUPUT_HDU,
					PC_inc_HDU =>sig_PC_inc_HDU);



end struct;
