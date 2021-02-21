-- EX Stage top-level entity
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.instruction_set.all;
use work.ALU_OPs.all;

entity EX is
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
		  PCSrc			 : in std_logic;
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
end EX;

architecture struct of EX is

-- Component declarations
component mux21 is
	generic(N : integer);
	port( A : in std_logic_vector(N-1 downto 0);
		  B : in std_logic_vector(N-1 downto 0);
		  S : in std_logic;
		  Z : out std_logic_vector(N-1 downto 0));
end component;

component mux41 is
	generic(N : integer);
	port( A : in std_logic_vector(N-1 downto 0);
		  B : in std_logic_vector(N-1 downto 0);
		  C : in std_logic_vector(N-1 downto 0);
		  D : in std_logic_vector(N-1 downto 0);
		  S : in std_logic_vector(1 downto 0);
		  Z : out std_logic_vector(N-1 downto 0));
end component;

component FWD_Unit is
	port (	RST 		   : in std_logic;
			RS1 		   : in std_logic_vector(NBIT_ADD-1 downto 0); -- Ex stage RS1
			RS2 		   : in std_logic_vector(NBIT_ADD-1 downto 0); -- Ex stage RS2
			RD_EXMEM	   : in std_logic_vector(NBIT_ADD-1 downto 0); -- Mem stage RD
			RD_MEMWB       : in std_logic_vector(NBIT_ADD-1 downto 0); -- WB stage RD
			RegWrite_EXMEM : in std_logic; -- Mem stage RegWrite
			RegWrite_MEMWB : in std_logic; -- WB stage RegWrite
			ForwardA 	   : out std_logic_vector(1 downto 0); -- 00 OP1 from RF, 10 OP1 forwarded from EXMEM, 01 OP1 from MEMWB
			ForwardB 	   : out std_logic_vector(1 downto 0));  -- 00 OP2 from RF, 10 OP2 forwarded from EXMEM, 01 OP2 from MEMWB
end component;

component ALU is
	port( OP1     : in std_logic_vector(NBIT-1 downto 0);   -- coming from ID/EX pipeline reg, read data 1
		  OP2     : in std_logic_vector(NBIT-1 downto 0);   -- coming from mux after ID/EX pipeline reg, read data 2 OR immediate based on signal ALUSrc
		  ALU_OPC : in std_logic_vector(ALU_OPC_SIZE-1 downto 0); -- coming from Control Unit
		  ZERO    : out std_logic; -- Zero flag, going to EX/MEM Pipeline reg
		  ALU_RES : out std_logic_vector(NBIT-1 downto 0)); -- going to EX/MEM Pipeline reg
end component;	

component EX_MEM is
	port( CLK          : in std_logic; 
		  RST	       : in std_logic;
		  PCext_in	   : in std_logic_vector(NBIT-1 downto 0);
		  Zero_in      : in std_logic;
		  ALU_RES_in   : in std_logic_vector(NBIT-1 downto 0);
		  RF_Data2_IN  : in std_logic_vector(NBIT-1 downto 0);
		  ADD_RD_in    : in std_logic_vector(NBIT_ADD-1 downto 0);
		  Branch_in    : in std_logic;
		  Branch_type_in : in std_logic;
		  RegWrite_in  : in std_logic;
		  MemWrite_in  : in std_logic;
		  MemRead_in   : in std_logic;
		  MemtoReg_in  : in std_logic;
		  PCext_out	   : out std_logic_vector(NBIT-1 downto 0);
		  Zero_out     : out std_logic;
		  ALU_RES_out  : out std_logic_vector(NBIT-1 downto 0);
		  RF_Data2_OUT : out std_logic_vector(NBIT-1 downto 0);
		  ADD_RD_out   : out std_logic_vector(NBIT_ADD-1 downto 0);
		  Branch_out   : out std_logic;
		  Branch_type_out : out std_logic;
		  RegWrite_out : out std_logic;
		  MemWrite_out : out std_logic;
		  MemRead_out  : out std_logic;
		  MemtoReg_out : out std_logic);
end component;

-- Signal declarations
signal sig_IMM_BEQ, sig_IMM_Branch, sig_PCext, sig_OP2, sig_OP1, sig_ALU_RES : std_logic_vector(NBIT-1 downto 0); 
signal sig_Zero, sig_RST : std_logic;
signal FWDA, FWDB : std_logic_vector(1 downto 0); -- FWD Selection signals
signal OP1_FW, OP2_FW : std_logic_vector(NBIT-1 downto 0);

begin
	
	sig_RST <= (NOT(PCSrc)) AND RST;
	sig_IMM_Branch <= IMM_IN(NBIT-2 downto 0) & '0';

	sig_PCext <= PC_in + sig_IMM_Branch;

	FWD: FWD_Unit port map( RST => sig_RST,
				RS1 => RS1_IN,
				RS2 => RS2_IN,
				RD_EXMEM => RD_EXMEM,
				RD_MEMWB => RD_MEMWB,
				RegWrite_EXMEM => RegWrite_EXMEM,
				RegWrite_MEMWB => RegWrite_MEMWB,
				ForwardA => FWDA,
				ForwardB => FWDB);
	
	FW1: mux41 generic map(N => NBIT)
		port map( A => RF_Data1_IN, B => (others => '0'), C => OP_MEMWB, D => OP_EXMEM, S => FWDA, Z => OP1_FW);
	
	FW2: mux41 generic map(N => NBIT)
		port map( A => RF_Data2_IN, B => (others => '0'), C => OP_MEMWB, D => OP_EXMEM, S => FWDB, Z => OP2_FW);
	
	OPSel1: mux21 generic map(N => NBIT)
		port map(A => OP1_FW, B => PC_in, S => ALUSrc1_in, Z => sig_OP1);

	OPSel2: mux41 generic map(N => NBIT)
		port map(A => OP2_FW, B => IMM_IN, C => std_logic_vector(to_unsigned(4,sig_OP2'length)), D=>(others => '0'), S => ALUSrc2_in, Z => sig_OP2);
	-- the second operand of the ALU can be: from register file, Immediate or 4 (used for JAL instruction where rd <- PC +4)
	
	ALU0: ALU port map(OP1 => sig_OP1, OP2 => sig_OP2, ALU_OPC => ALUOp_in, ZERO => sig_Zero, ALU_RES => sig_ALU_RES);

	
	
	reg0: EX_MEM port map( CLK => CLK,
						   RST => RST,
						   PCext_in => sig_PCext,
						   Zero_in => sig_Zero,
						   ALU_RES_in => sig_ALU_RES,
						   RF_Data2_IN => OP2_FW,
						   ADD_RD_in => ADD_RD_IN,
						   Branch_in => Branch_in,
						   Branch_type_in => Branch_type_in,
						   RegWrite_in => RegWrite_in,
						   MemWrite_in => MemWrite_in,
						   MemRead_in => MemRead_in,
						   MemtoReg_in => MemtoReg_in,
						   PCext_out => PCext_out,
						   Zero_out => Zero_out,
						   ALU_RES_out => ALU_RES_out,
						   RF_Data2_OUT => RF_Data2_OUT,
						   ADD_RD_out => ADD_RD_out,
						   Branch_out => Branch_out,
						   Branch_type_out => Branch_type_out,
						   RegWrite_out => RegWrite_out,
						   MemWrite_out => MemWrite_out,
						   MemRead_out => MemRead_out,
						   MemtoReg_out => MemtoReg_out);

end struct;
