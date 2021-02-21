library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;

entity IF_ID is
	port( CLK     : in std_logic; 
		  RST	  : in std_logic;
		  PC_IN   : in std_logic_vector(NBIT-1 downto 0); -- coming from PC reg
		  INS_IN  : in std_logic_vector(NBIT-1 downto 0); -- instruction coming from IRAM
		  PC_OUT  : out std_logic_vector(NBIT-1 downto 0); -- sent to ID_EX pipeline reg, adder, IRAM
		  INS_OUT : out std_logic_vector(NBIT-1 downto 0)); -- sent to decomposition unit and to CU
end IF_ID;

architecture bhv of IF_ID is
begin
	process(CLK, RST)
	begin
		if(RST = '0') then
			PC_OUT <= (others =>'0');
			INS_OUT <= (others =>'0');
		elsif(CLK = '1' and CLK'event) then
			PC_OUT <= PC_IN;
			INS_OUT <= INS_IN;
		end if;
	end process;
end bhv;
