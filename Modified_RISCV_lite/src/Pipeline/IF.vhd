-- IF Stage top-level entity
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.instruction_set.all;
use work.ALU_OPs.all;

entity IF_Stage is
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
end IF_Stage;

architecture bhv of IF_Stage is

-- Component declarations
component PCReg is
	generic(N : integer);
	port( PC_in  : in std_logic_vector(N-1 downto 0);
		  CLK  : in std_logic; 
		  RST  : in std_logic;
		  PC_out : out std_logic_vector(N-1 downto 0));
end component;

component mux21 is
	generic(N : integer);
	port( A : in std_logic_vector(N-1 downto 0);
		  B : in std_logic_vector(N-1 downto 0);
		  S : in std_logic;
		  Z : out std_logic_vector(N-1 downto 0));
end component;

component IF_ID is
	port( CLK     : in std_logic; 
		  RST	  : in std_logic;
		  PC_IN   : in std_logic_vector(NBIT-1 downto 0); -- coming from PC reg
		  INS_IN  : in std_logic_vector(NBIT-1 downto 0); -- instruction coming from IRAM
		  PC_OUT  : out std_logic_vector(NBIT-1 downto 0); -- sent to ID_EX pipeline reg, adder, IRAM
		  INS_OUT : out std_logic_vector(NBIT-1 downto 0)); -- sent to decomposition unit and to CU
end component;

-- Signal declarations
signal PC_MUX_extORinc,PC_MUX_HazIncORNormal,PC_MUX_HazORNormal,INS_MUX_HazORNormal  : std_logic_vector(NBIT-1 downto 0);
signal PC_output    : std_logic_vector(NBIT-1 downto 0);
signal PC_increment : std_logic_vector(NBIT-1 downto 0);
signal sig_RST : std_logic;

begin

	sig_RST <= (NOT(PCSrc)) AND RST;
	ADDR_out <= PC_output;
	PC_increment <= PC_output + 4;


	PC_extORinc : mux21 generic map(N => NBIT)
		port map(A => PC_increment, B => PC_EXT, S => PCSrc, Z => PC_MUX_extORinc);
		
	PC_HazIncORNormal : mux21 generic map(N => NBIT)
		port map(A => PC_MUX_extORinc, B => PC_inc_HDU, S => Bubble_in, Z => PC_MUX_HazIncORNormal);
		
	PC_HazORNormal : mux21 generic map(N => NBIT)
		port map(A => PC_output, B => PC_IN_HDU, S => Bubble_in, Z => PC_MUX_HazORNormal);
		
	INS_HazORNormal : mux21 generic map(N => NBIT)
		port map(A => INS_IN, B => INS_IN_HDU, S => Bubble_in, Z => INS_MUX_HazORNormal);
		
	PC: PCReg generic map(N => NBIT)
		port map(PC_in => PC_MUX_HazIncORNormal, CLK => CLK, RST => RST, PC_out => PC_output); -- Program Counter
	
	F_D : IF_ID port map(PC_IN => PC_MUX_HazORNormal, INS_IN => INS_MUX_HazORNormal , CLK => CLK, RST => sig_RST, PC_OUT => PC_OUT, INS_OUT => INS_OUT);

end bhv;



