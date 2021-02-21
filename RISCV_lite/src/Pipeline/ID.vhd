-- ID Stage top-level entity
library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use work.instruction_set.all;
use work.ALU_OPs.all;

entity ID is
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
end ID;

architecture struct of ID is

-- Component declarations
component regn is
	generic(N : integer);
	port( DIN  : in std_logic_vector(N-1 downto 0);
		  CLK  : in std_logic; 
		  RST  : in std_logic;
		  DOUT : out std_logic_vector(N-1 downto 0));
end component;

component CU is
	port( CLK          : in std_logic; 
		  RST	   : in std_logic;
		  Bubble_in_CU : in std_logic;
		  INS_OUT  : in std_logic_vector(NBIT-1 downto 0); -- Coming from IF/ID register
		  Branch   : out std_logic; -- the instruction is a branch (BEQ or JAL)
	  	  Branch_type : out std_logic; -- if Branch_type = '1', it is a JAL instruction, if Branch_type = '0', it is a BEQ instruction
		  RegWrite : out std_logic; -- Writeback signal to regfile
		  ALUSrc1   : out std_logic; -- if '1' operand1 will be the PC, '0' operand1 comes from the regfile
		  ALUSrc2   : out std_logic_vector(1 downto 0); -- if '11' operand2 will be the immediate, '00' operand2 comes from the regfile
								-- if '01' operand2 will be 4 (used for the JAL)
		  ALUOp	   : out std_logic_vector(ALU_OPC_SIZE-1 downto 0); -- To ALU, selection of ALU operation to be performed
		  MemWrite : out std_logic; -- Write to data memory
		  MemRead  : out std_logic; -- Read from data memory
		  MemtoReg : out std_logic);
end component;

component instruction_type is
	port( INST_IN : in std_logic_vector(NBIT-1 downto 0); -- instruction to be split into the various fields coming from IF/ID register pipe
		  Rtype   : out std_logic;
		  Itype   : out std_logic;
		  Utype   : out std_logic;
		  Btype  : out std_logic;
		  Jtype  : out std_logic;
		  Stype   : out std_logic);
end component;

component instruction_decomposition is
	port( INST_IN : in std_logic_vector(NBIT-1 downto 0); -- instruction to be split into the various fields coming from IF/ID register pipe
		  Rtype   : in std_logic;
		  Itype   : in std_logic;
		  Utype   : in std_logic;
		  Btype  : in std_logic;
		  Jtype  : in std_logic;
		  Stype   : in std_logic;
		  ADD_RS1 : out std_logic_vector(NBIT_ADD-1 downto 0); -- sent to regfile
		  ADD_RS2 : out std_logic_vector(NBIT_ADD-1 downto 0); -- sent to regfile
		  ADD_RD  : out std_logic_vector(NBIT_ADD-1 downto 0); -- sent to intermediate reg in ID stage, to be used in writeback
		  IMM     : out std_logic_vector(NBIT-1 downto 0); -- sent to intermediate reg in ID stage
		  RS1     : out std_logic; -- sent to regfile
		  RS2     : out std_logic); -- sent to regfile
end component;

component registerfile is
	port( CLK     : in std_logic;
		  RST     : in std_logic;
		  ENABLE  : in std_logic;
		  RS1     : in std_logic; 
		  RS2     : in std_logic; 
		  WR      : in std_logic;
		  ADD_WR  : in std_logic_vector(NBIT_ADD-1 downto 0); -- coming from MEM/WB pipeline reg
		  ADD_RS1 : in std_logic_vector(NBIT_ADD-1 downto 0); -- extracted from the instruction
		  ADD_RS2 : in std_logic_vector(NBIT_ADD-1 downto 0); -- extracted from the instruction
		  DATAIN  : in std_logic_vector(NBIT-1 downto 0); -- data coming from the output mux after the MEM/WB reg
		  OUT1    : out std_logic_vector(NBIT-1 downto 0); -- sent to ID/EX pipeline reg
		  OUT2    : out std_logic_vector(NBIT-1 downto 0)); -- sent to ID/EX pipeline reg
end component;

-- Signal declarations
signal sig_Rtype, sig_Itype, sig_Utype, sig_Btype, sig_Jtype, sig_Stype:  std_logic;
signal sig_ADD_RS1, sig_ADD_RS2, sig_ADD_RD, ADD_RD_reg, ADD_RS1_reg, ADD_RS2_reg : std_logic_vector(NBIT_ADD-1 downto 0);		
signal sig_IMM, IMM_reg, PC_reg : std_logic_vector(NBIT-1 downto 0);
signal sig_RS1, sig_RS2 : std_logic;	
signal sig_OUT1, sig_OUT2 : std_logic_vector(NBIT-1 downto 0);
signal sig_ALUOp : std_logic_vector(ALU_OPC_SIZE-1 downto 0);
signal sig_Branch, sig_Branch_type, sig_RegWrite, sig_ALUSrc1, sig_MemWrite, sig_MemRead, sig_MemtoReg : std_logic;
signal sig_ALUSrc2: std_logic_vector(1 downto 0);
signal sig_RST : std_logic;

begin

	sig_RST <= (NOT(PCSrc)) AND RST;

	ctrl_unit : CU port map( CLK => CLK,
							 RST => sig_RST,
							Bubble_in_CU => Bubble_in,
							 INS_OUT => INS_IN,
							 Branch => Branch_out,
							 Branch_type => Branch_type_out,
							 RegWrite => RegWrite_out,
							 ALUSrc1 => ALUSrc1_out,
							 ALUSrc2 => ALUSrc2_out,
							 ALUOp => ALUOp_out,
							 MemWrite => MemWrite_out,
							 MemRead => MemRead_out,
							 MemtoReg => MemtoReg_out);
	
	ins_type : instruction_type port map( INST_IN => INS_IN,
						Rtype => sig_Rtype,
						Itype => sig_Itype,
						Utype => sig_Utype,
						Btype => sig_Btype,
						Jtype => sig_Jtype,
						Stype => sig_Stype);

	ins_dec : instruction_decomposition port map( INST_IN => INS_IN,
							Rtype => sig_Rtype,
							Itype => sig_Itype,
							Utype => sig_Utype,
							Btype => sig_Btype,
							Jtype => sig_Jtype,
							Stype => sig_Stype,					  	
							ADD_RS1 => sig_ADD_RS1,
							ADD_RS2 => sig_ADD_RS2,
							ADD_RD => sig_ADD_RD,
							IMM => sig_IMM,
							RS1 => sig_RS1,
							RS2 => sig_RS2);

	ADD_RS1_HDU <= sig_ADD_RS1;
	ADD_RS2_HDU <= sig_ADD_RS2;

	regPC : regn generic map(N => NBIT)
		port map(DIN => PC_IN, CLK => CLK, RST => sig_RST, DOUT => PC_OUT);
		
	regRD : regn generic map(N => NBIT_ADD)
		port map(DIN => sig_ADD_RD, CLK => CLK, RST => sig_RST, DOUT => ADD_RD_OUT);
		
	regRS1 : regn generic map(N => NBIT_ADD)
		port map(DIN => sig_ADD_RS1, CLK => CLK, RST => sig_RST, DOUT => ADD_RS1_OUT);
	
	regRS2 : regn generic map(N => NBIT_ADD)
		port map(DIN => sig_ADD_RS2, CLK => CLK, RST => sig_RST, DOUT => ADD_RS2_OUT);
		
	regIMM : regn generic map(N => NBIT)
		port map(DIN => sig_IMM, CLK => CLK, RST => sig_RST, DOUT => IMM_OUT);

	rf :registerfile port map(CLK => CLK,    
							  RST => RST,
							  ENABLE => '1',
							  RS1 => sig_RS1,   
							  RS2 => sig_RS2,   
							  WR => RegWrite,   
							  ADD_WR => ADD_WR_IN,
							  ADD_RS1 => sig_ADD_RS1,
							  ADD_RS2 => sig_ADD_RS2,
							  DATAIN => DATA_WR_IN,
							  OUT1 => RF_Data1_OUT, 
							  OUT2 => RF_Data2_OUT);		 


end struct;
