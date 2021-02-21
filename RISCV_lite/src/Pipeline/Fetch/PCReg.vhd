library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;

entity PCReg is
	generic(N : integer);
	port( PC_in  : in std_logic_vector(N-1 downto 0);
		  CLK  : in std_logic; 
		  RST  : in std_logic;
		  PC_out : out std_logic_vector(N-1 downto 0));
end PCReg;

architecture bhv of PCReg is
begin
	process(CLK, RST)
	begin
		if(RST = '0') then
			PC_out <= BASE_ADDR_text;
		elsif(CLK = '1' and CLK'event) then
			PC_out <= PC_in;
		end if;
	end process;
end bhv;
