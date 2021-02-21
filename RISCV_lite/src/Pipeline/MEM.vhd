-- MEM Stage top-level entity
library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use work.instruction_set.all;
use work.ALU_OPs.all;

entity MEM is
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
end MEM;

architecture struct of MEM is

-- Component declarations
component regn is
	generic(N : integer);
	port( DIN  : in std_logic_vector(N-1 downto 0);
		  CLK  : in std_logic; 
		  RST  : in std_logic;
		  DOUT : out std_logic_vector(N-1 downto 0));
end component;

component DFF is
	port( D   : in std_logic;
		  CLK : in std_logic; 
		  RST : in std_logic;
		  Q   : out std_logic);
end component;

-- Signal declarations
signal sig_MemtoReg, sig_RegWrite : std_logic;
signal sig_ALU_RES : std_logic_vector(NBIT-1 downto 0);
signal sig_ADD_RD : std_logic_vector(NBIT_ADD-1 downto 0);

begin
	
	--if Branch = '1' and Branch_type = '0' (BEQ) and Zero (flag computed in ALU) = '1', PCSrc = '1' (evaluated in MEM stage) => BEQ
	--if Branch = '1' and Branch_type = '1' (JAL) , PCSrc = '1' => JAL
	PCSrc <= (Zero_in and (not(Branch_type_in)) and Branch_in) OR (Branch_type_in and Branch_in);
	
	MemWrite_out <= MemWrite_in;
	MemRead_out <= MemRead_in;
	ADDR_out <= ALU_RES_in;
	PCext_out <= PCext_in;
	RF_Data2_out <= RF_Data2_in;
	
	FF0 : DFF port map(D => MemtoReg_in, CLK => CLK, RST => RST, Q => sig_MemtoReg);
	
	FF1 : DFF port map(D => RegWrite_in, CLK => CLK, RST => RST, Q => sig_RegWrite);
	
	RegWrite_EXMEM <= RegWrite_in;
	
	RegALU1 : regn generic map(N => NBIT)
		port map(DIN => ALU_RES_in, CLK => CLK, RST => RST, DOUT => sig_ALU_RES);
		
	OP_EXMEM <= ALU_RES_in;

	RegRD1 : regn generic map(N => NBIT_ADD)
		port map(DIN => ADD_RD_in, CLK => CLK, RST => RST, DOUT => sig_ADD_RD);

	RD_EXMEM <= ADD_RD_in;
	
	
	Data_out <= Data_in;
	ADD_RD_out <= sig_ADD_RD;
	ALU_RES_out <= sig_ALU_RES;
	RegWrite_out <= sig_RegWrite;
	MemtoReg_out <= sig_MemtoReg;
	
end struct;
