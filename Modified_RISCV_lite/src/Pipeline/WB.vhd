-- WB Stage top-level entity
library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use work.instruction_set.all;
use work.ALU_OPs.all;

entity WB is
	port( Data_in	   : in std_logic_vector(NBIT-1 downto 0);
		  ADD_RD_in    : in std_logic_vector(NBIT_ADD-1 downto 0);
		  ALU_RES_in   : in std_logic_vector(NBIT-1 downto 0);
		  RegWrite_in  : in std_logic;
		  MemtoReg_in  : in std_logic;
		  ADD_RD_out   : out std_logic_vector(NBIT_ADD-1 downto 0);
		  RegWrite_out : out std_logic;
		  Data_out	   : out std_logic_vector(NBIT-1 downto 0));
end WB;

architecture arch of WB is

-- Component declarations
component mux21 is
	generic(N : integer);
	port( A : in std_logic_vector(N-1 downto 0);
		  B : in std_logic_vector(N-1 downto 0);
		  S : in std_logic;
		  Z : out std_logic_vector(N-1 downto 0));
end component;

begin

	ADD_RD_out <= ADD_RD_in;
	RegWrite_out <= RegWrite_in;
	
	mux0 : mux21 generic map(N => NBIT)
		port map(A => ALU_RES_in, B => Data_in, S => MemtoReg_in, Z => Data_out);
	
end arch;